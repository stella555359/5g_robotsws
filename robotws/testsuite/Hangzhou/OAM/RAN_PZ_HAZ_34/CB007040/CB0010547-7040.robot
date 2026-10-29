*** Settings ***
Force Tags    PY36
Documentation     author: Luo Menghua
...               contact: menghua.luo@nokia-sbell.com
...               squad group: SG_07
...               feature : CB007040 CB009029 CB009800 CB10547
Resource    ./Resource/Common.robot
Library    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/global_vars.py

Suite Setup    Common Suite Setup for COAM on UTE    swconfig_flag=${False}
Suite Teardown   Run Keyword And Ignore Error    Common.7040 COAM Teardown gnb connections

*** Variables ***
@{ALL_TEST_STATUS}
${LSS_Server_ip}   ${tl.test_pc.default_ssh_connection_details.addr}
${LSS_Server_Username}   coam
${LSS_Server_Password}   zO&n1W*ktp7
${LSS_Server_Port_Num}   22


*** Test Cases ***
[1]CB010547_CB007040_PowerReset_via_WebUI_botton_without_snapshot_ASOF_FDD_or_TDD
    [Tags]    CRT_TRUNK    CRT_24R1
    [Timeout]    120 min
    [Setup]    CB010547 Case Setup For 7040
    ${coamexist}    Check LSS Coam Account Exist
    run keyword if   '${coamexist}'!='True'    Create LSS Coam Account
    Remove LSS Snapshot
    Config LSS Server on WebEM
    ${status}    run keyword and return status    selenium_coam.power_reset    with_snapshot_collection=${True}
    Should Be Equal    ${status}    ${true}
    Wait Until Keyword Succeeds   15 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${WEBUI_ADDR}  exp_status=${False}
    ${LOG_PATH}    Stop and Save BTS Log Collection
    ${message}    Print BTSlog    message_name=PowerReset    bts_logs_path=${LOG_PATH}
    Should Contain    ${message}    PowerReset
    Check Snapshot Upload to LSS Status
    wait until keyword succeeds   10m   30s   COAM Check All Cells Onair
    [Teardown]   CB010547 Case Teardown For 7040

#[1]CB010547_CB007040_PowerReset_via_delta_plan_commission_with_snapshot_ASOF_FDD_or_TDD
#    [Tags]    CRT_TRUNK    CRT_24R1
#    [Timeout]    120 min
#    [Setup]     Run Keywords
#     ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#     ...    Case Setup for 7040
#    Wait Until Keyword Succeeds   5x   30s    Add SWRESETREQ-1    powerReset
#    Wait Until Keyword Succeeds   15 min   20 s    Validate IP Reachability from Test PC
#    ...   ip_addr=${WEBUI_ADDR}  exp_status=${False}
#    ${LOG_PATH}    Stop and Save BTS Log Collection
#    ${message}    Print BTSlog    message_name=PowerReset    bts_logs_path=${LOG_PATH}
#    Should Contain    ${message}    PowerReset
#    wait until keyword succeeds   10m   30s   COAM Check All Cells Onair
#    [Teardown]    Case Teardown for 7040

#[1]CB010547_CB007040_CRT
#    [Tags]    CRT_TRUNK    CRT_24R1
#    [Timeout]    60 min
#    [Setup]     robot_common_operations.Common Case Setup
#    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
#    List Should Not Contain Value   ${ALL_TEST_STATUS}   FAIL
#    [Teardown]    robot_common_operations.Common Case Teardown

#[1]CB010547_CB007040_PowerReset_via_WebUI_botton_without_snapshot_ASOF_FDD_or_TDD
#    Log     The case has been covered by CB009029-7040-ABIP.roobot on T846 with adding an ABIQ;
#    LOG   PASS EXECUTION
#
#[1]CB010547_CB007040_PowerReset_via_delta_plan_commission_with_snapshot_ASOF_FDD_or_TDD
#    Log     The case has been covered by CB009029-7040-ABIP.roobot on T846 with adding an ABIQ;
#    LOG   PASS EXECUTION
#
#[1]CB010547_CB007040_CRT
#    Log     The case has been covered by CB009029-7040-ABIP.roobot on T846 with adding an ABIQ;
#    LOG   PASS EXECUTION
