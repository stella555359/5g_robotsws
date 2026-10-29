*** Settings ***
Documentation
...    copyright: Nokia
...    maintainer: Wojciech Szczesniak (wojciech.szczesniak@nokia.com)

Force Tags    CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD    CRT    SBTS00    RAN_5G    RAN_5G_FDD

Resource    ../resources/5G_SW_WRO_Keywords.robot
Library     ../resources/Python/webem_alarms.py
Library     OperatingSystem
Library     taf.transport.ssh               WITH NAME    ssh
Library     taf.collectors.tcpdump          WITH NAME    tcpdump
Library     taf.collectors.l2stream3        WITH NAME    tcl
Library     taf.collectors.core             WITH NAME    tcc
Library     taf.converters.eventdecoder     WITH NAME    tce
Library     taf.sbts.oam.coam.admin         WITH NAME    coam
Resource    ./resources/CB008229_keywords.robot
Library     ./resources/get_ul_number_of_prbs.py


Suite Setup    Run Keywords    Configure VM interfaces
...            AND             Update Iphy Configuration And Modify Swconfig
...                            iphy_xml_filepath=${CURDIR}/config/iphy_2xAHFII.xml
...            AND             Start Default Logging
...            AND             Find Scfc And Fix And Send Full Commissioning
...                            scfc_filename=full_CB008229_NSA.xml
...            AND             Check Radios Availability
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/basic_NSA_setup.cfg

Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND   Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${SMOD}    ASIB
${GNB_IP}    192.168.255.129
${NOKIA_USERNAME}    toor4nsn
${NOKIA_PASS}    oZPS0POrRieRtu
${PRB_blanking}    delta_prb_blanking_enable.json

*** Test Cases ***
CB008229-A_B1_B4_Intra-gNB_HO_between_dfifferent_BW_NSA_PRB_blanking
    Set X2 interface
    Enable PDSCH decoding in the multiplexed slots
    Attach Ue To Enb And Start Gnb Addition    ue_id=11   target_cells=1
    Sleep    10s    reason=Wait for UE to attach
    Start Data Traffic for NSA UEs
    Verify Average Tput For UE NSA    ue_id=11    id=2    dir=dl    unit=M    expected_tput=195
    Verify Average Tput For UE NSA    ue_id=11    id=2    dir=ul    unit=M    expected_tput=195
    Perform INTER HO In Both Ways NSA
    Stop All Data Transfers And Detach UE NSA    ue_id=11
    Find Scfc And Send Delta Commissioning    scfc_filename=${PRB_blanking}
    Sleep    60s
    Attach Ue To Enb And Start Gnb Addition    ue_id=11   target_cells=1
    Sleep    10s    reason=Wait for UE to attach
    Start Data Traffic for NSA UE and Blanked PRBs in UL
    Verify Average Tput For UE NSA    ue_id=11    id=2    dir=dl    unit=M    expected_tput=180
    Verify Average Tput For UE NSA    ue_id=11    id=2    dir=ul    unit=M    expected_tput=95
    Start TTI trace
    Sleep    5s    reason=Collect TTI trace for 5 seconds
    Stop TTI trace
    Convert TTI trace from pcap to excelCsv
    ${max_num_of_prbs_ul}=    Get Max UL Number of PRBs    ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/output_ul.csv
    Should Be True    ${max_num_of_prbs_ul} < 79    Maximum number of used UL PRBs is greater than 79    #133 avaliable PRBs, 54 PRBs blanked
    [Teardown]    Stop All Data Transfers And Detach UE NSA    ue_id=11

*** Keywords ***
Attach Ue To Enb And Start Gnb Addition
    [Arguments]    ${ue_id}    ${target_cells}
    Attach Ue To Enb    ue_id=${ue_id}
    Start Gnb Addition Procedure
    ...    ue=${ue_id}
    ...    target_cells=${target_cells}
    ...    target_gnb=2
    ...    bearer=2
    ...    dc_type=split_scg
    Sleep    15s

Start Data Traffic for NSA UEs
    Execute Egate Command    cmd=trf_data_start id=2 ue=11 dir=dl mbps=100 trf_id=1 size=8000
    Sleep    3s
    Execute Egate Command    cmd=trf_data_start id=2 ue=11 dir=dl mbps=100 trf_id=2 size=8000
    Sleep    3s
    Execute Egate Command    cmd=trf_data_start id=2 ue=11 dir=ul mbps=100 trf_id=1 size=8000
    Sleep    3s
    Execute Egate Command    cmd=trf_data_start id=2 ue=11 dir=ul mbps=100 trf_id=2 size=8000
    Sleep    20s

Start Data Traffic for NSA UE and Blanked PRBs in UL
    Execute Egate Command    cmd=trf_data_start id=2 ue=11 dir=dl mbps=100 trf_id=1 size=8000
    Sleep    3s
    Execute Egate Command    cmd=trf_data_start id=2 ue=11 dir=dl mbps=100 trf_id=2 size=8000
    Sleep    3s
    Execute Egate Command    cmd=trf_data_start id=2 ue=11 dir=ul mbps=100 trf_id=1 size=8000
    Sleep    20s    reason=Wait for throughput stabilization

Configure VM interfaces
    Start Vm Ethernet Interface    if_name=eth3:xn    ip_with_mask=10.0.1.51/24
    Start Vm Ethernet Interface    if_name=eth3:ng    ip_with_mask=10.0.1.50/24
    Start Vm Ethernet Interface    if_name=eth3:SGNB3_S1U  ip_with_mask=10.0.1.53/24
    Start Vm Ethernet Interface    if_name=eth3:SGNB3_X2   ip_with_mask=10.0.1.54/24

Perform INTER HO In Both Ways NSA
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=11 meas_id=1 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=51 nrsrp_nr=30 nrsrq_nr=30
    ...    pass_regexp=UE11: Successfully reconfigured dual connectivity
    ...    timeout=20
    Sleep    50s    reason=Wait before next handover
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=11 meas_id=1 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=50 nrsrp_nr=30 nrsrq_nr=30
    ...    pass_regexp=UE11: Successfully reconfigured dual connectivity
    ...    timeout=20

Start TTI trace
    ${configurations}=  tcc.Load Configurations
    ...  ${CURDIR}/resources/ttitrace_collectors.yaml
    tcc.Create collectors
    ...  names=l2stream3
    ...  configurations=${configurations['collectors']}
    tcl.Set suite alias
    ...  alias=l2stream3
    tcc.Setup collectors
    ...  names=l2stream3
    tcc.Start collectors
    ...  names=l2stream3

Stop TTI trace
    tcc.Stop collectors
    ...  names=l2stream3
    tcc.Collect collectors
    ...  names=l2stream3
    tcc.Teardown collectors
    ...  names=l2stream3

Convert TTI trace from pcap to excelCsv
    tce.Create eventDecoder converter
    ...  name=ttitrace_converter
    ...  input_file_path=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/l2stream3/tcpdump/tcpdump.pcap
    ...  output_file_format=excelCsv
    ...  output_file_path=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/output
    tce.Convert
    ...  name=ttitrace_converter

