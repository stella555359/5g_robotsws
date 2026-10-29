*** Settings ***
Documentation
...  author: Wang Dali
...  contact: dali.wang@nokia-sbell.com

Resource   ./Resource/Common.robot
Test Setup     Append To List  ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ANDROID_SA_ASIMR_ABINB4_AHPE    SBTS00    CRT_UTE    PY36

Suite Setup    Common Suite Setup for COAM     swconfig_flag=${True}
Suite Teardown   Run Keyword And Ignore Error    Common.7040 COAM Teardown gnb connections


*** Variables ***
@{ALL_TEST_STATUS}
#${BTS}   ${tl.gnbs[0].instance_id}

*** Test Cases ***
[1]CB007040_A_02_power_reset_triggered_via_provisions_plan_from_BTS_EM
    [Tags]   AUTHOR_dali.wang@nokia-sbell.com
    [Timeout]   1h
    [Setup]     Common Case Setup for 7040
    Wait Until Keyword Succeeds   5x   30s    Add SWRESETREQ-1    powerReset
    Wait Until Keyword Succeeds   15 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${WEBUI_ADDR}  exp_status=${False}
    ${LOG_PATH}    Stop and Save BTS Log Collection
    ${message}    Print BTSlog    message_name=PowerReset    bts_logs_path=${LOG_PATH}
    Should Contain    ${message}    PowerReset
    wait until keyword succeeds   15m   1min   COAM Check All Cells Onair
    [Teardown]    Common Case Teardown for 7040


[1]CB007040_A_03_power_reset_triggered_via_CLI
    [Tags]   AUTHOR_dali.wang@nokia-sbell.com
    [Timeout]   1h
    [Setup]     Common Case Setup for 7040
    ${status}    run keyword and return status    coam.Power_Reset    connection=COAM
    Should Be Equal    ${status}    ${true}
#    Wait Until Keyword Succeeds   15 min   20 s    Validate IP Reachability from Test PC
#    ...   ip_addr=${WEBUI_ADDR}  exp_status=${False}
    ${LOG_PATH}    Stop and Save BTS Log Collection
    ${message}    Print BTSlog    message_name=PowerReset    bts_logs_path=${LOG_PATH}
    Should Contain    ${message}    PowerReset
    wait until keyword succeeds   15m   1m   COAM Check All Cells Onair
    [Teardown]    Common Case Teardown for 7040

[1]CB007040_A_05_power_reset_triggered_by_click_BTS_EM_GUI_button
    [Tags]   AUTHOR_dali.wang@nokia-sbell.com
    [Timeout]   1h
    [Setup]     Common Case Setup for 7040
    ${status}    run keyword and return status    selenium_coam.power_reset
    Should Be Equal    ${status}    ${true}
    Wait Until Keyword Succeeds   15 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${WEBUI_ADDR}  exp_status=${False}
    ${LOG_PATH}    Stop and Save BTS Log Collection
    ${message}    Print BTSlog    message_name=PowerReset    bts_logs_path=${LOG_PATH}
    Should Contain    ${message}    PowerReset
    wait until keyword succeeds   15m   1m   COAM Check All Cells Onair
    [Teardown]    Common Case Teardown for 7040

[1]CB007040_A_16_Remote_power_reset_reject_when_CM_operation_is_on_going
    [Tags]   AUTHOR_dali.wang@nokia-sbell.com
    [Timeout]   1h
    [Setup]     Common Case Setup for 7040
    ${pmax_value}    selenium_coam.get_parameter_value     dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    ...    filter_param=Maximum output power
    ${pmax_value}   fetch from left   ${pmax_value}   ${space}
    ${new_pmax_value}    evaluate    ${${pmax_value}}+1
    selenium_coam.set_parameter_value     dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    ...    filter_param=Maximum output power   new_value=${new_pmax_value}
    Run Keyword and Ignore Error    selenium_coam.validate_plan
    Run Keyword and Ignore Error    selenium_coam.activate_plan   download_plan_without_activation=${False}
    ...    activate_plan_despite_errors=${True}   execute=${True}   timeout=180
    selenium_coam.set_parameter_value     dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    ...    filter_param=Maximum output power   new_value=${pmax_value}
    Run Keyword and Ignore Error    selenium_coam.validate_plan
    Run Keyword and Ignore Error    selenium_coam.activate_plan   download_plan_without_activation=${False}
    ...    activate_plan_despite_errors=${True}   execute=${True}   timeout=5
    ${status}    run keyword and return status    coam.Power_Reset    connection=COAM
    Should Not Be True    ${status}
    sleep   5min
    wait until keyword succeeds   15m   1m   COAM Check All Cells Onair
    [Teardown]   Common Case Teardown for 7040

[1]CB007040_A_13_Power_reset_for_uncommissioned NE
    [Tags]   AUTHOR_dali.wang@nokia-sbell.com
    [Timeout]   1h
#    [Setup]     Case Setup for 7040
#    COAM Backup SCF
#    wait until keyword succeeds    5min   30s    COAM Reset Configuration
#    Run Keyword and Ignore Error   COAM WEBUI Logout
#    ${action}    Create Dictionary  modal_name=Additional hardware detected   button=close
#    ${action_list}    Create List  ${action}
#    ${version}   set variable if   '${gnb_release}'=='SBTS23R1'    23R1   ${None}
#    Wait Until Keyword Succeeds   10min   1m
#    ...   COAM WEBUI Login    url=https://${LMP_ADDR}   version=${version}
#    ...    modal_action_configurations=${action_list}
#    run keyword and ignore error    Wait Until Keyword Succeeds   3min   1m
#    ...    selenium_coam.continue_after_plug_and_play_modal_appear
#    sleep    10min
#    ${status}    run keyword and return status    selenium_coam.power_reset
#    Should Be Equal    ${status}    ${true}
#    ${LOG_PATH}    Stop and Save BTS Log Collection
##    ${message}    Print BTSlog    message_name=[Reset::PowerResetHelper]    bts_logs_path=${LOG_PATH}
##    Should Contain    ${message}    SystemModulePowerReset::receiveResetResp
#    Wait Until Keyword Succeeds   15min   20s    Validate IP Reachability from Test PC
#    ...   ip_addr=${LMP_ADDR}  exp_status=${False}
#    ${LOG_PATH}    Stop and Save BTS Log Collection
##    ${message}    Print BTSlog    message_name=[Reset::PowerResetHelper]    bts_logs_path=${LOG_PATH}
##    Should Contain    ${message}    SystemModulePowerReset::receiveResetResp
#    [Teardown]   Case Teardown for 7040 steps
    [Setup]
    LOG    PASS EXECUTION
    [Teardown]
