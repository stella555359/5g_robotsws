*** Settings ***
Documentation    Author: xiaofei.zhao@nokia-sbell.com


Suite Setup          Run Keywords    robot_common_operations.Common Suite Setup
...    AND     GlobeCommon_Suite_Setup   is_commission=${False}
Suite Teardown       robot_common_operations.Common Suite Teardown
Test Setup           MMW5 Common Case Setup    allowed_faults_ids=6327,7319,7300,62003,7513,4038,7509,4220,7511,10,1811
Test Teardown        robot_common_operations.Common Case Teardown

Force Tags    5G_SISO    mmw_05    CRT_22R1    CRT_23R1    CRT_Trunk
...   PY36

Resource    Resources/Globe_keywords_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot

*** Variables ***
${bts_filter1}   CELL NOTIFICATION 4329 Radio memory consumption exceeds abnormal threshold
${bts_filter2}   FaultId: 4329
${bts_filter3}   FaultId: 4330
${bts_filter4}   Detector 4329
${bts_filter5}   Detector 4330
${bts_filter6}   active 4329
${bts_filter7}   active 4330
${bts_filter8}   4330 Radio memory consumption exceeds critical threshold
${TS_CASE_LOG_PATH}   ${OUTPUT DIR}

*** Test Cases ***
[1]E2E_Reset_with_HWF_deletion
    [Documentation]    author: xiaofei.zhao@nokia-sbell.com
    [Timeout]    600min
    [Tags]    CRT_22R1    CRT_23R1    CRT_Trunk

    ${swconfig_list}=   Create List   0x190030=0    0x4F0214=0
    Globe Modify Swconfig File   para_update=${swconfig_list}
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    1 min    5 sec   Connect to gnb coam via ssl
    start btslog capture  name=btslog
    coam.reset_site    timeout=600    wait_for_reconnection=${True}    connection=GNB_OAM
    sleep   10min
    ${gnb_status_status}   Run Keyword And Return Status   Verify Gnb Ready And All Cell On Air
    Set Test Variable   ${gnb_status_status}
    stop btslog and collect logs   status=FAIL
    ${bts_log_path}=   set variable   ${TS_CASE_LOG_PATH}/btslog/syslog_files.tgz
    Should Be True    ${gnb_status_status} == True
    Globe_Check_btslog_After_Reset   log_path=${bts_log_path}
    Globe_Check_gNB_Startup_log
    Wait Until Keyword Succeeds    1 min    5 sec  Connect to gnb coam via ssl
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT}
    Run Keyword And Continue On Failure    Unexpect History Alarm Should Not Exist  allowed_faults=${ALLOWED_HISTORY_FAULT}
    Run Keyword If   '${enb_length}'!='${0}'  Connect to eNB via ssl   enb_index=${0}  connection=enblte_0
    Run Keyword If   '${enb_length}'!='${0}'  coam.reset_site    connection=enblte_0
    Run Keyword If   '${enb_length}'!='${0}'  sleep   8min
    Run Keyword If   '${enb_length}'!='${0}'  Wait until keyword succeeds    10 min    20 sec
                     ...             Globe_keywords_common.Verify Enb All Cell On Air    enb_index=${0}
    sleep   1min
    Run Keyword If   '${enb_length}'!='${0}'  Connect to eNB via ssl   enb_index=${0}  connection=enblte_0
    ${ALLOWED_FAULT_ENB}    Evaluate    ${ALLOWED_FAULT} + [{'faultId':4290}]
    Log To Console    ${ALLOWED_FAULT_ENB}
    Run Keyword If   '${enb_length}'!='${0}'  Run Keyword And Continue On Failure
                     ...   Unexpect Alarm Should Not Exist  allowed_faults=${ALLOWED_FAULT_ENB}  connection=enblte_0
    Run Keyword If   '${enb_length}'!='${0}'  Run Keyword And Continue On Failure  Unexpect History Alarm Should Not Exist
                     ...   allowed_faults=@{ALLOWED_HISTORY_FAULT}  connection=enblte_0
    Run Keyword If   '${enb_length}'!='${0}'  Verify Gnb Ready And All Cell On Air  timeout=3min

    [Teardown]   Run Keywords
	             ...    Run Keyword And Ignore Error    Globe Common Case Teardown  is_save_snapshot=True    AND
				 ...    Run Keyword And Ignore Error    Run Keyword If Test Failed    Collect Enb Snapshot Log    AND
				 ...    robot_common_operations.Common Case Teardown    AND
                 ...    CI_interface.Common Case Teardown
