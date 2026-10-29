*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO, VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...             RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00   CONFIGURED

Documentation
...
...             author       : neravati.dheeraj_nehru@nokia.com
...             maintainer   : neravati.dheeraj_nehru@nokia.com
...             Introduction : This Test scenario validates high edge PRB blanking with 3BWP's i.e 20Mhz,30Mhz and 40Mhz
...             Test Set Name: [1]CB008954_B_IWK7_3_BWPs_with_PRB_blanking_interaction_CB010850
...             Testing Split: CB008954 Split B testPlan
...             Contacts     : I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             References   : CB008954 CFAM

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Library           ta5g_enb


Resource         ./CB008954_resource.robot
Resource         ../CB012261/CB012261_resource.robot

#Suite Setup         Run keywords    Prepare TL with all config files
#...                 AND    Run Keyword and Ignore Error      Suite setup from scratch
Suite Setup         Run keywords     Suite setup from scratch
#...					AND    Prepare TL with IPHY file change
...					AND    Sleep  60s
...                 AND    Perform SCF Delta Commissioning with CB008954_B_IWK7_3.json
...                 AND    Add routes
...                 AND    gnb.Perform gNB reboot
...                 AND    Sleep   300s    reason=wait for RMOD to comeup
...                 AND    Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND    sleep  65s   reason=wait for mib sib

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

Test Setup       Start_capture_testcase_default_logging
Test Teardown    Run Keywords       Log To console   Teardown_started
#...                 AND     Dump RMOD BBMOD And Cell Status
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
...                 AND     Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
#${wts_cfg_file}      ${CURDIR}/config/wts/basic_setup_FDD_highedge_prb_blanking_4cell.cfg
${wts_cfg_file}      ${CURDIR}/config/wts/basic_setup.cfg
${WTS_DIR}          /opt/iphy/latest
${start_ue}        1
${end_ue}          3
${nwslice_ID}      1
${gw_ID}           1
${Pdu_session_ID}       1
${QFI_ID}          1
${TRF_ID}          1
${TRF_ID2}         2
${largebwp_id}     1
${secondbwp_id}    2
${smallbwp_id}     3
${epc_log_path}    /tmp/
${TEST_NAME}            Cell_setup
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
#${SCFC}=                   ${CURDIR}/config/SBTS24R2/High_edge_prb_blanking_CA_case.xml
${AP_XML}=                 ${CURDIR}/config/wts/iphy_4cell_fdd_40Mhz_prb_blanking.xml

*** Test Cases ***
[1]CB008954_B_IWK7_3_BWPs_with_PRB_blanking_interaction_CB010850
    [Documentation]  This Test scenario validates high edge PRB blanking with 3BWP's i.e 20Mhz,30Mhz and 40Mhz

     ${large_bwp_rnti}    MultiUE Register should be Successful     ${81}    ${81}
     MultiUE Trigger UL Traffic for SA    ${81}  ${81}  Traffic_rate=mbps     ul_rate=10   pdu_id=1   trf_id=1   qfi_id=1
     MultiUE Trigger DL Traffic for SA    ${81}  ${81}  Traffic_rate=mbps     dl_rate=50   pdu_id=1   trf_id=1   qfi_id=1
#    Start Log         ttitrace    btslog
#     sleep    5s
#     ${scen3}     Stop Log     ttitrace      btslog        test_scenario=mix1

#     Get Configured Measurements of UE${start_ue}
#     Start Log      btslog     cprt
#     ${houe_small_bwp_rnti}    Trigger A3 RsrpAndRsrq Measurement for intragnb HO Custom   51     52    1    53
#     Verify Counters incrementing as expected

#     ${scen1}     Stop Log      btslog     cprt
#     Verify locationAndBandwith for allocated BWP     ${scen1}[cprt]/NODECPRT_GNB.pcap     32174


#     Start Log         ttitrace
#     sleep    5s
#     ${scen4}     Stop Log     ttitrace         test_scenario=mix2
#     MultiUE Deregister should be Successful     ${51}      ${52}
     sleep   5s
     ${second_bwp_rnti}    MultiUE Register should be Successful     ${82}    ${82}
     MultiUE Trigger UL Traffic for SA    ${82}  ${82}  Traffic_rate=mbps     ul_rate=10   pdu_id=1   trf_id=1   qfi_id=1
     MultiUE Trigger DL Traffic for SA    ${82}  ${82}  Traffic_rate=mbps     dl_rate=50   pdu_id=1   trf_id=1   qfi_id=1
#     Verify 8954 counters cell3

#     Start Log         ttitrace
#     sleep    5s
#     ${scen5}     Stop Log     ttitrace         test_scenario=mix3
#     MultiUE Deregister should be Successful     ${54}      ${54}
     sleep   5s

     ${small_bwp_rnti}    MultiUE Register should be Successful     ${83}    ${83}
     MultiUE Trigger UL Traffic for SA    ${83}  ${83}  Traffic_rate=mbps     ul_rate=10   pdu_id=1   trf_id=1   qfi_id=1
     MultiUE Trigger DL Traffic for SA    ${83}  ${83}  Traffic_rate=mbps     dl_rate=50   pdu_id=1   trf_id=1   qfi_id=1
#    Verify 8954 counters cell4
     sleep    5s
#     Start Log         ttitrace
     Start TTI_TRACE custom
     sleep    3s
     ${scen3}     Stop Log     ttitrace         test_scenario=Mix1


     Decode TTI Trace   Mix1
     ${small_bwp_id}    Set variable    ${2}
     ${second_bwp_id}   Set Variable    ${3}
     ${large_bwp_id}   Set Variable    ${1}
     ${small_bwp_size}    Set Variable    ${52}
     ${second_bwp_size}    Set Variable    ${79}
     ${large_bwp_num_prb}    Set Variable    ${106}
     ${Mix1}    validate_bwps    ${scen3}[ttitrace]/output_dl_formated.csv    dlFdSchedData    ${small_bwp_id}
     ...    ${second_bwp_id}    ${large_bwp_id}     ${small_bwp_size}    ${second_bwp_size}    ${large_bwp_num_prb}
     ...     large_bwp_ues=${large_bwp_rnti}     small_bwp_ues=${small_bwp_rnti}     second_bwp_ues=${second_bwp_rnti}
     should contain    ${Mix1}     pass

#     Decode TTI Trace   mix2
#     ${small_bwp_id}    Set variable    ${1}
#     ${second_bwp_id}   Set Variable    ${3}
#     ${large_bwp_id}   Set Variable    ${2}
#     ${small_bwp_size}    Set Variable    ${160}
#     ${second_bwp_size}    Set Variable    ${0}
#     ${large_bwp_num_prb}    Set Variable    ${216}
#     ${Mix2}     validate_bwps    ${scen4}[ttitrace]/output_dl_formated.csv    dlFdSchedData    ${small_bwp_id}  ${second_bwp_id}   ${large_bwp_id}
#     ...     ${small_bwp_size}   ${second_bwp_size}    ${large_bwp_num_prb}    small_bwp_ues=${houe_small_bwp_rnti}
#     should contain    ${Mix2}     pass

#     Decode TTI Trace   mix3
#     ${small_bwp_id}    Set variable    ${1}
#     ${second_bwp_id}   Set Variable    ${3}
#     ${large_bwp_id}   Set Variable    ${2}
#     ${small_bwp_size}    Set Variable    ${106}
#     ${second_bwp_size}    Set Variable    ${0}
#     ${large_bwp_num_prb}    Set Variable    ${160}
#     ${Mix3}    validate_bwps    ${scen5}[ttitrace]/output_dl_formated.csv    dlFdSchedData    ${small_bwp_id}  ${second_bwp_id}    ${large_bwp_id}
#    ...     ${small_bwp_size}    ${second_bwp_size}    ${large_bwp_num_prb}    small_bwp_ues=${small_bwp_rnti}
#    should contain    ${Mix3}     pass

#     Decode TTI Trace   mix4
#     ${small_bwp_id}    Set variable    ${1}
#     ${second_bwp_id}   Set Variable    ${3}
#     ${large_bwp_id}   Set Variable    ${2}
#     ${small_bwp_size}    Set Variable    ${160}
#     ${second_bwp_size}    Set Variable    ${0}
#     ${large_bwp_num_prb}    Set Variable    ${216}
#     ${Mix4}     validate_bwps    ${scen6}[ttitrace]/output_dl_formated.csv    dlFdSchedData    ${small_bwp_id}  ${second_bwp_id}    ${large_bwp_id}
#    ...     ${small_bwp_size}    ${second_bwp_size}    ${large_bwp_num_prb}    large_bwp_ues=${large1_bwp_rnti}
#    should contain    ${Mix4}     pass


*** Keywords ***
Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}




Start TTI_TRACE custom
    [Arguments]    ${cell_id}=${60}
    Common Start Ttitrace With Streaming Mode_3 custom        pysical_cell_ids=${cell_id}

Common Start Ttitrace With Streaming Mode_3 custom
    [Arguments]    ${pysical_cell_ids}=50    ${names}=l2stream3_ttitrace
    [Documentation]    This keyword is used to start ttitrace with streaming mode.
    ...    examples 1: catch 1 cell
    ...    Start Ttitrace With Streaming Mode
    ...    examples 2: catch 2 cells
    ...    Start Ttitrace With Streaming Mode    50,51
    ${executor}=  Create Dictionary
    ...  host=192.168.255.129
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
#    ${nr_phy_cell_ids}=    Common Get PhysCellId Of GNB Runtime
    ${nr_phy_cell_ids}    Create List    ${pysical_cell_ids}
    ${nr_phy_cell_ids}=    Evaluate  map(int, $nr_phy_cell_ids)
    Log Many    ${pysical_cell_ids}       ${nr_phy_cell_ids}
#    ${localIpAddr}=    Get localIpAddr Of GNB
#10.0.1.2 for ute
    ${localIpAddr}=    set variable    10.0.1.2
#    ${web_card}    ${dest_ip}=    Get EIF Info Of Control PC
    ${web_card}    ${dest_ip}=    Common Get EIF Info Of Control PC
    ${l2_stream_config_1}=  Create Dictionary
    ...  nr_phy_cell_ids=${nr_phy_cell_ids}
    @{l2_stream_configuration}=  Create List  ${l2_stream_config_1}
    TCPDUMP.create tcpdump collector
    ...  name=tcpdump_ttitrace
    ...  options=-i ${web_card} udp and dst ${dest_ip} and dst port 5678
    ...  sudo_password=ute
    L2STREAM3.Create Sbts L2stream Collector
    ...  name=${names}
    ...  destination_ip_addr=${dest_ip}
    ...  collector=tcpdump_ttitrace
    ...  l2_stream_configuration=${l2_stream_configuration}
    ...  webservice=${executor}
    L2STREAM3.Set Suite Alias
    ...  alias=${names}
    CORE.setup_collectors
    ...  names=${names}
    CORE.start_collectors
    ...  names=${names}

