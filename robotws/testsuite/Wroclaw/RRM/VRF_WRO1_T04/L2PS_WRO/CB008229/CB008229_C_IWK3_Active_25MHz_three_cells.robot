*** Settings ***
Force Tags    CLOUD_5G_O_H_AP_LOO    RAN_5G    RAN_5G_FDD    CRT     SBTS00

Resource     ../resources/5G_SW_WRO_Keywords.robot
Resource     resources/CB008229-C_keywords.robot
Resource    ../CB007813/connect.robot
Library     resources/CB008229_keywords.py
Library    ../resources/Python/webem_alarms.py
Library    OperatingSystem
Library    ../CB007813/CB007813-B_keywords.py
Library    ../CB007813/vendor_file_modifier.py
Library    Collections
Library     taf.collectors.tcpdump          WITH NAME    tcpdump
Library     taf.collectors.l2stream3        WITH NAME    tcl
Library     taf.collectors.core             WITH NAME    tcc
Library     taf.converters.eventdecoder     WITH NAME    tce
Library     taf.sbts.oam.coam.admin         WITH NAME    coam
Library     taf.transport.ssh               WITH NAME    ssh
Resource     ../resources/configuration_id.robot

Documentation
...    author: Kamil Galczynski
...    release: 22R4

Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_AHFIB_8229_C_PRB_pooling.xml
    ...                        swconfig_flags_list=@{SWCONFIG_FLAGS}
    ...        AND             Start Default Logging
    ...        AND             Download and Modify Vendor File and perform commissioning
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/basic_setup_8229_C_PRB_pooling.cfg


Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND   Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${SMOD}    ASIB
${GNB_IP}    192.168.255.129
${NOKIA_USERNAME}    toor4nsn
${NOKIA_PASS}    oZPS0POrRieRtu
@{SWCONFIG_FLAGS}=      0x5808FF=0     0x580900=32    0x580901=0    0x580902=4096   0x580903=0    0x580904=0     0x580905=0

*** Test Cases ***
CB008229-C_IWK3_Active_25MHz_three_cells_from_same_active_PRB_pool_SA
    Set Internal Traffic Type To UE
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Start Data Traffic In DL And In UL   ue_id=1    pdu=1   tput_dl=20   tput_ul=10
    Verify Tput For UE    ue_id=1   dir=ul    expected_tput=9.5
    Verify Tput For UE    ue_id=1   dir=dl    expected_tput=30
    Attach Ue    ue_id=2
    Establish Pdu Session    ue_id=2    pdu_id=2    gw_id=2
    Start Data Traffic In DL And In UL   ue_id=2    pdu=2   tput_dl=150   tput_ul=20
    Verify Tput For UE    ue_id=2   dir=ul    expected_tput=9.5
    Verify Tput For UE    ue_id=2   dir=dl    expected_tput=30
    Attach Ue    ue_id=3
    Establish Pdu Session    ue_id=3    pdu_id=3    gw_id=2
    Start Data Traffic In DL And In UL   ue_id=3    pdu=3   tput_dl=150   tput_ul=20
    Verify Tput For UE    ue_id=3   dir=ul    expected_tput=9.5
    Verify Tput For UE    ue_id=3   dir=dl    expected_tput=30
    Attach Ue    ue_id=4
    Establish Pdu Session    ue_id=4    pdu_id=4    gw_id=2
    Start Data Traffic In DL And In UL   ue_id=4    pdu=4   tput_dl=150   tput_ul=20
    Verify Tput For UE    ue_id=4   dir=ul    expected_tput=9.5
    Verify Tput For UE    ue_id=4   dir=dl    expected_tput=30
    Attach Ue    ue_id=5
    Establish Pdu Session    ue_id=5    pdu_id=5    gw_id=2
    Start Data Traffic In DL And In UL   ue_id=5    pdu=5   tput_dl=2   tput_ul=2
    Verify Tput For UE    ue_id=5   dir=ul    expected_tput=1.5
    Verify Tput For UE    ue_id=5   dir=dl    expected_tput=1.5
    Collect Tti Trace For 1 Seconds
    Check DL PRB Allocated by BBRM to UE1 and UE3
    Check UL PRB Allocated by BBRM to UE1 and UE3
    [Teardown]    Run Keywords    Stop All Data Transfers And Detach UE SA
    ...    AND    Send Configuration ID To Scout

*** Keywords ***
Set Internal Traffic Type To UE
    Execute Egate Command   cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute Egate Command   cmd=set_pdu_param ue=2 pdu=2 trf_type=internal
    Execute Egate Command   cmd=set_pdu_param ue=3 pdu=3 trf_type=internal
    Execute Egate Command   cmd=set_pdu_param ue=4 pdu=4 trf_type=internal
    Execute Egate Command   cmd=set_pdu_param ue=5 pdu=5 trf_type=internal

Start Data Traffic In DL And In UL
    [Arguments]   ${ue_id}    ${pdu}    ${tput_ul}    ${tput_dl}
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} dir=dl mbps=${tput_dl} trf_id=1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} dir=ul mbps=${tput_ul}
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu} dir=dl mbps=${tput_dl} trf_id=2
    Sleep    30s

Verify Tput For UE
    [Arguments]   ${ue_id}    ${dir}    ${expected_tput}
    ${avg_tput}=    Get Avg Data Traffic For Given Cc    ue_id=${ue_id}   cc=0   direction=${dir}    unit=Mbps
    Should Be True    ${avg_tput} > ${expected_tput}

Stop All Data Transfers And Detach UE SA
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off

Collect Tti Trace For ${time} Seconds
    Start TTI trace
    Sleep    ${time}s
    Stop TTI trace
    Convert TTI trace from pcap to excelCsv

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
    ...  target_dir=${OUTPUT_DIR}
    tcc.Teardown collectors
    ...  names=l2stream3

Convert TTI trace from pcap to excelCsv
    tce.Create eventDecoder converter
    ...  name=ttitrace_converter
    ...  input_file_path=${OUTPUT_DIR}/l2stream3/tcpdump/tcpdump.pcap
    ...  output_file_format=excelCsv
    ...  output_file_path=${OUTPUTDIR}/TTI_TRACE/
    tce.Convert
    ...  name=ttitrace_converter

    Move File    ${OUTPUT_DIR}/l2stream3/tcpdump/tcpdump.pcap    ${OUTPUT_DIR}/TTI_TRACE/tcpdump.pcap
    Move File    ${OUTPUT_DIR}/TTI_TRACE_dl*.csv   ${OUTPUT_DIR}/TTI_TRACE/TTI_TRACE_dl.csv
    Move File    ${OUTPUT_DIR}/TTI_TRACE_ul*.csv   ${OUTPUT_DIR}/TTI_TRACE/TTI_TRACE_ul.csv
