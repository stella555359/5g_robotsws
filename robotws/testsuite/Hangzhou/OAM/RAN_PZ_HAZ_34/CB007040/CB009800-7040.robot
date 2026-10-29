*** Settings ***
Force Tags    PY36
Documentation     author: Wang Lei
...               contact: lei.24.wang@nokia-sbell.com
...               squad group: SG_07
...               feature : CB009469 CB009799 CB009800 CB009801
Resource    ./Resource/Common.robot
Library    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/global_vars.py

Suite Setup    Common Suite Setup for COAM     swconfig_flag=${False}
Suite Teardown   Run Keyword And Ignore Error    Common.7040 COAM Teardown gnb connections

*** Variables ***
@{ALL_TEST_STATUS}
${LSS_Server_ip}   ${tl.test_pc.default_ssh_connection_details.addr}
${LSS_Server_Username}   coam
${LSS_Server_Password}   zO&n1W*ktp7
${LSS_Server_Port_Num}   22
@{sas_faults_list}    6823   6824   6825   6826   6827   6828   6829   6830   6831   6832   6833

*** Test Cases ***
[1]CB009800_CB007040_CRT
    [Tags]    CRT_TRUNK    CRT_24R1
    [Timeout]    4h
    [Setup]     Tribe Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=${sas_faults_list}
    run keyword and continue on failure   CB009800_CB007040_PowerReset_via_WebUI_botton_without_snapshot_ASOF_FDD_or_TDD
#    run keyword and continue on failure   CB009800_CB007040_PowerReset_via_delta_plan_commission_with_snapshot_ASOF_FDD_or_TDD
#    run keyword and continue on failure   CB009223_case_regression_summary
    [Teardown]    Tribe Common Case Teardown

[1]CB009223_case_regression_summary
    [Tags]    CRT_TRUNK    CRT_24R1
    [Timeout]   1h
    [Setup]   Tribe Common Case Setup
    run keyword and continue on failure   CB009223_case_regression_summary
    [Teardown]   Tribe Common Case Teardown


*** Keywords ***
CB009800_CB007040_PowerReset_via_WebUI_botton_without_snapshot_ASOF_FDD_or_TDD
    [Timeout]    120 min
    Case Setup for 7040
    AlarmWatchdog.add_allow_alarms    fault_id=${sas_faults_list}
    Remove LSS Snapshot
    Config LSS Server on WebEM
    ${status}    run keyword and return status    selenium_coam.power_reset    with_snapshot_collection=${True}
    Should Be Equal    ${status}    ${true}
    Wait Until Keyword Succeeds   15 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${WEBUI_ADDR}  exp_status=${False}
    Wait Until Keyword Succeeds   15 min   30 s    Validate IP Reachability from Test PC
    ...   ip_addr=${WEBUI_ADDR}  exp_status=${True}
    ${LOG_PATH}    Stop and Save BTS Log Collection
    ${message}    Print BTSlog    message_name=PowerReset    bts_logs_path=${LOG_PATH}
    Should Contain    ${message}    PowerReset
    Check Snapshot Upload to LSS Status
    wait until keyword succeeds   10m   30s   COAM Check All Cells Onair
    [Teardown]    Case Teardown for 7040

CB009800_CB007040_PowerReset_via_delta_plan_commission_with_snapshot_ASOF_FDD_or_TDD
    [Timeout]    120 min
    Case Setup for 7040
    AlarmWatchdog.add_allow_alarms    fault_id=6825
    AlarmWatchdog.add_allow_alarms    fault_id=6832
    Wait Until Keyword Succeeds   5x   30s    Add SWRESETREQ-1    powerReset
    Wait Until Keyword Succeeds   15 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${WEBUI_ADDR}  exp_status=${False}
    Wait Until Keyword Succeeds   15 min   30 s    Validate IP Reachability from Test PC
    ...   ip_addr=${WEBUI_ADDR}  exp_status=${True}
    ${LOG_PATH}    Stop and Save BTS Log Collection
    ${message}    Print BTSlog    message_name=PowerReset    bts_logs_path=${LOG_PATH}
    Should Contain    ${message}    PowerReset
    wait until keyword succeeds   10m   30s   COAM Check All Cells Onair
    [Teardown]    Case Teardown for 7040

CB009223_case_regression_summary
   [Timeout]    60 min
    #   [Setup]  Case Setup: ASOF_CRT
    #   Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
    #   List Should Not Contain Value   ${ALL_TEST_STATUS}   FAIL
    #   [Teardown]  Case Teardown: ASOF_CRT
    robot_common_operations.Common Case Setup
    Log   Pass Execution
