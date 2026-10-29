*** Settings ***
Documentation
...    Author:  Yanqing.li
...    Contact: yanqing.li@nokia-sbell.com
...    Feature: testability_eCPRI_72a
...    Release: 25R1
Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown
Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown
Resource          ../../resources/common_resources.robot

Force Tags    5G_RAN_TDD    CRT    SBTS00    QCD_MN_RAN    QCP_RAN_RF

*** Variables ***
@{ALLOWED_FAULT}    8101
${ROTTA_PATH}    //eseefsn50.emea.nsn-net.net/rotta4internal/LTE_2/7_2a_regression
${scfc_file}    Testability_ABIO_1xAVQL_NRTDD_1xNRCEL_72a_${btsid}.xml
${ue_index}    UE_1

*** Test Cases ***
Testability_TC13_NR_FR1_TDD_eCPRI_ABIO_72a_DU_RU_IQ_event_trigger_mode_EPhyEvent_NdmSrsBlindGrasp
    [Tags]    ABIP    SMAwave    Trunk    Testability    TC13
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}Testability${/}${scfc_file}
    SMAwave UE attach    rat=5G    cell_id=None    band=78    specific_UE_index=${ue_index}
    SMAwave Start Data Traffic    100M    20M    udp    1000

    ${ul_subcell_index_list}=    Create List    [BBMOD_R-2(ABIO)] [PCI: 300][7-2a]NRCELL-1: Subcell 0
    ${polar_list_minus}    Create List    0    4
    ${polar_list_plus}     Create List    16    20
    ${antenna_list_group}=    Create Dictionary    Antenna list=Set1(-45 polarization, +45 polarization)    -45 Polarization=${polar_list_minus}
    ...    +45 Polarization=${polar_list_plus}

    Configure IQ capture via webUI     ul_subcell_index_list=${ul_subcell_index_list}    dl_subcell_index_list=${None}
    ...    lte_ul_cell_ids=${None}    lte_dl_cell_ids=${None}    enable_capture_on=Event    capture_from=BBU and RU
    ...    profile_prefix=UL_PROFILE_3    buffer_cycle=16_FRAMES    capture_frame_offset=0    antenna_list_group=${antenna_list_group}

    ADMIN Set RAD debug parameters    CommonPhy    nbOfEventsToTrigAutoBTSSnapshot    1
    ${NrUlPhy_list}    Set Variable    [{'name': 'enableRespCapture', 'value': '80'}, {'name': 'phyEventEnableExt', 'value': '32768'}]
    ADMIN Set Multiple RAD debug parameters    NrUlPhy    ${NrUlPhy_list}

    SMAwave Verify throughput for DL and UL    100M    20M    30%    5G    78
    [Teardown]    Run keywords    Case Teardown And Check Log In IQ    AND    SMAwave Stop Data And Detach

*** Keywords ***
Case Teardown And Check Log In IQ
    ${isTrigger}    Run Keyword And Return Status    ute_syslog.Message Should Exist In Syslog File    regexp=recordEvent     alias=enb_testSetup
    Run Keyword If    ${isTrigger}    Log To Console    [ERROR] recordEvent is NOT filtered in syslog.

    ${L1_ERR_rt_message_num}=     Count Syslog messages    regexp=ERR/l1_application_rt    alias=enb_testSetup
    ${L1_ERR_nrt_message_num}=    Count Syslog messages    regexp=ERR/l1_application_nrt    alias=enb_testSetup
    ${L1_ERR_nrt_message_num}=    Count Syslog messages    regexp=ERR/l1_application    alias=enb_testSetup
    ${L1_WRN_rt_message_num}=     Count Syslog messages    regexp=WRN/l1_application_rt    alias=enb_testSetup
    ${L1_WRN_nrt_message_num}=    Count Syslog messages    regexp=WRN/l1_application_nrt    alias=enb_testSetup
    ${L1_WRN_nrt_message_num}=    Count Syslog messages    regexp=WRN/l1_application    alias=enb_testSetup
    Run Keyword And Ignore Error    Check L1 ERR and WRN in syslog

    Run Keyword And Ignore Error    Stop Collect GNB Syslog    ${TEST_LOG_DIR}
    Run Keyword And Ignore Error    ute_syslog.Teardown All Aliases For Syslog
    Get Alarms State    alarm_management=Active
    Get Alarms State    alarm_management=Historic
    Run Keyword And Ignore Error    sbts_admin.teardown    connection=${connection}
    Run Keyword And Ignore Error    WebUI disconnection    suite

    ${snapshot}    Save Snapshot Via WebUI
    Run Keyword And Continue On Failure    Filter And Check DU L1 Journal Log    ${snapshot}
    Run Keyword And Continue On Failure    Filter And Check RU L1 Runtime Log    ${snapshot}
    ${Nr_fine_flag}    Run Keyword And Return Status    Check NrFine slot    ${snapshot}
    Should Be True    ${Nr_fine_flag}    [ERROR] NrFine_slot file not found
    ${isUploaded}    Run Keyword If    ${Nr_fine_flag}    Run Keyword And Return Status    jenkins_upload_file_to_ROTTA
    ...    ${snapshot}    ${ROTTA_PATH}
    Should Be True    ${isUploaded}    [ERROR] Upload to rotta failure
    ${local_path}    ${snapshot_name}    Split String From Right    ${snapshot}    /    1
    ${isAnalyzed}    Run Keyword If    ${isUploaded}    Run Keyword And Return Status    iq_data_analyzer
    ...    l1iq_log_path=${ROTTA_PATH}/${snapshot_name}    local_file=${TEST_LOG_DIR}/archive.zip    target_board=DU    event_trigger_only=True
    ...    is_72e_ul=False    is_72e_dl=False
    Should Be True    ${isAnalyzed}    [ERROR] jenkins analysis failure with | event_trigger_only=True | is_72e_ul=False | is_72e_dl=False |.
    # Check iq pcap    # UL_PROFILE_3: no ecpri pcap
    Check DU iq REQ and RESP message

    # Check RU iq #
    Extract trbl log and check ru iq log    ${snapshot}    NdmSrsBlindGrasp

Check NrFine slot
    [Arguments]     ${snapshot}
    ${node_id}    Get Node Id    ABIO    loki_1
    ${first_zip}     ${path}     Get Target Logs From Snapshot    ${snapshot}    ${node_id.strip('0x')}D_l1a_up_trace.tgz
    ${second_zip}    ${path1}    Extract Target file From Compressed File    ${snapshot}    ${first_zip}[0]
    ${third_zip}     ${path2}    Extract Target file From Compressed File     ${path1}/${second_zip}    ${node_id.strip('0x')}D_l1a_up_trace.tgz
    ${forth_zip}     ${path3}    Extract Target file From Compressed File     ${path2}/${third_zip}    NrFine_slot
    File Should Exist    ${path3}/${forth_zip}    [ ERROR ] filename NOT EXIST
    Remove files    ${path2}/${third_zip}    ${path3}/${forth_zip}

Check DU iq REQ and RESP message
    [Arguments]    ${iq_log}=${TEST_LOG_DIR}/archive.zip
    ${resp_txt}    ${path1}    Extract Target file From Compressed File     compress_file=${iq_log}    target_startswith=RESP
    ${req_txt}    ${path2}    Extract Target file From Compressed File     compress_file=${iq_log}   target_startswith=REQ
    ${msg1}    Run    cat ${path1}/${resp_txt} | grep UlData_SrsReceiveRespBmPs
    Should Not Be Empty    ${msg1}    [ERROR] ${msg1} is NOT found in <resp_txt>
    ${msg2}    Run    cat ${path2}/${req_txt} | grep UlData_SrsReceiveReq
    Should Not Be Empty    ${msg2}    [ERROR] ${msg2} is NOT found in <req_txt>

Check iq pcap
    [Arguments]    ${iq_log}=${TEST_LOG_DIR}/archive.zip
    ${ecpri_bin_pcap}    ${path1}    Extract Target file From Compressed File    compress_file=${iq_log}    target_startswith=ecpri.*.pcap
    ${file_size}=    Get File Size    ${path1}/${ecpri_bin_pcap}
    Log    File size is: ${file_size}
    Should Be True    ${file_size} > 0    [ ERROR ] ${ecpri_bin_pcap} size should be greater than 0
