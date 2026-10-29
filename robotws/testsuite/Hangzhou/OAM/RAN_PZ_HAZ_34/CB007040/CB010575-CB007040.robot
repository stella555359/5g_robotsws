*** Settings ***
Documentation
...  author: MengHua Luo (NSB)

Library   taf.sbts.oam.coam.admin    WITH NAME    coam
Resource    ./Resource/Common.robot
Library    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/global_vars.py
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001821/Resource/coam.robot

Suite Setup    Common Suite Setup for COAM     swconfig_flag=${False}
Suite Teardown   Run Keyword And Ignore Error    Common.7040 COAM Teardown gnb connections

#Test Setup     Append To List  ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}

*** Variables ***
${LSS_Server_ip}   ${tl.test_pc.default_ssh_connection_details.addr}
${LSS_Server_Username}   coam
${LSS_Server_Password}   zO&n1W*ktp7
${LSS_Server_Port_Num}   22
@{ALL_TEST_STATUS}

*** Test Cases ***
#CB010575-E-CB007040_Remote_power_reset_with_automatic _snapshot_collection_and_upload_to_LSS
#    [Timeout]   5h
#    [Setup]     Case Setup for 7040
#    Remove LSS Snapshot
#    Config LSS Server on WebEM
#    ${status}    run keyword and return status    selenium_coam.power_reset    with_snapshot_collection=${True}
#    Should Be Equal    ${status}    ${true}
#    Wait Until Keyword Succeeds   15 min   20 s    Validate IP Reachability from Test PC
#    ...   ip_addr=${WEBUI_ADDR}  exp_status=${False}
#    ${LOG_PATH}    Stop and Save BTS Log Collection
#    ${message}    Print BTSlog    message_name=PowerReset    bts_logs_path=${LOG_PATH}
#    Should Contain    ${message}    PowerReset
#    Check Snapshot Upload to LSS Status
#    wait until keyword succeeds   10m   30s   COAM Check All Cells Onair
#    [Teardown]    Case Teardown for 7040
#
#CB010575-E-CB007040_Remote_power_reset_without _snapshot_collection
#    [Timeout]   5h
#    [Setup]     Run Keywords   Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND   Case Setup for 7040
#    Remove LSS Snapshot
#    Config LSS Server on WebEM
#    ${status}    run keyword and return status    selenium_coam.power_reset    with_snapshot_collection=${False}
#    Should Be Equal    ${status}    ${true}
#    Wait Until Keyword Succeeds   15 min   20 s    Validate IP Reachability from Test PC
#    ...   ip_addr=${WEBUI_ADDR}  exp_status=${False}
#    ${LOG_PATH}    Stop and Save BTS Log Collection
#    ${message}    Print BTSlog    message_name=PowerReset    bts_logs_path=${LOG_PATH}
#    Should Contain    ${message}    PowerReset
#    Check Snapshot Upload to LSS Status   snapshot=${False}
#    wait until keyword succeeds   10m   30s   COAM Check All Cells Onair
#    [Teardown]    Case Teardown for 7040

CB010575_CB007040_CRT
    [Timeout]    5h
    [Setup]     Tribe Common Case Setup
#    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
#    List Should Not Contain Value   ${ALL_TEST_STATUS}   FAIL
    Append To List  ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
    Run Keyword And Continue On Failure    CB010575-E-CB007040_Remote_power_reset_with_automatic _snapshot_collection_and_upload_to_LSS
    Run Keyword And Continue On Failure    CB010575-E-CB007040_Remote_power_reset_without _snapshot_collection
    [Teardown]    Tribe Common Case Teardown

*** Keywords ***
Case Teardown for 10575-7040
    [Documentation]   Stop btslog collection, and logout WEBUI connection
    Check Extra Reset From Blackbox
    run keyword and ignore error   COAM WEBUI Whether Close Start Up View Window
    run keyword and ignore error   Syslog Capture Stop and Collect
    Run Keyword If   $KEYWORD_STATUS=='FAIL'    Run Keyword And Ignore Error    Screenshot for case fail
    Run Keyword If   $KEYWORD_STATUS=='FAIL'    Run Keyword And Ignore Error    Save Snapshot logs On COAM  IP_WEBUI=${WEBUI_ADDR}
    Run Keyword and Ignore Error   COAM WEBUI Logout
    Run Keyword and Ignore Error   COAM Logout

CB010575-E-CB007040_Remote_power_reset_with_automatic _snapshot_collection_and_upload_to_LSS
    [Timeout]   5h
    Case Setup for 7040
    Remove LSS Snapshot
    Config LSS Server on WebEM
#    ${status}    run keyword and return status    selenium_coam.power_reset    with_snapshot_collection=${True}
    ${status}    run keyword and return status   coam.Power_Reset   reset_with_snapshot=${True}   wait_for_reconnection=${False}   connection=COAM
    Should Be Equal    ${status}    ${true}
    Wait Until Keyword Succeeds   10m   30s    Validate IP Reachability from Test PC 7040
    ...   ip_addr=${WEBUI_ADDR}  exp_status=${False}
    ${LOG_PATH}    Stop and Save BTS Log Collection
    ${message}    Print BTSlog    message_name=PowerReset    bts_logs_path=${LOG_PATH}
    Should Contain    ${message}    PowerReset
    Check Snapshot Upload to LSS Status
    wait until keyword succeeds   15m   30s   COAM Check All Cells Onair
    [Teardown]    Case Teardown for 10575-7040

CB010575-E-CB007040_Remote_power_reset_without _snapshot_collection
    [Timeout]   5h
    Case Setup for 7040
    Remove LSS Snapshot
    Config LSS Server on WebEM
#    ${status}    run keyword and return status    selenium_coam.power_reset    with_snapshot_collection=${False}
    ${status}    run keyword and return status   coam.Power_Reset   reset_with_snapshot=${False}   wait_for_reconnection=${False}   connection=COAM
    Should Be Equal    ${status}    ${true}
    Wait Until Keyword Succeeds   10m   30s    Validate IP Reachability from Test PC 7040
    ...   ip_addr=${WEBUI_ADDR}  exp_status=${False}
    ${LOG_PATH}    Stop and Save BTS Log Collection
    ${message}    Print BTSlog    message_name=PowerReset    bts_logs_path=${LOG_PATH}
    Should Contain    ${message}    PowerReset
    Check Snapshot Upload to LSS Status   snapshot=${False}
    wait until keyword succeeds   15m   30s   COAM Check All Cells Onair
    [Teardown]    Case Teardown for 10575-7040

Tribe Common Case Setup
    robot_common_operations.Common Case Setup

Tribe Common Case Teardown
    robot_common_operations.Common Case Teardown
    CI_interface.Common Case Teardown
