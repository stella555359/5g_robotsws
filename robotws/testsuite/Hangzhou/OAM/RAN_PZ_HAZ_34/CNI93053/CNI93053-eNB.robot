# *** Settings ***
# Documentation
# ...  author: Wang Dali
# ...  contact: dali.wang@nokia-sbell.com
# 
# Resource   ./Resource/Common.robot
# Library     taf.selenium.sbts    WITH NAME    selenium_coam
# #Suite Setup    Common.Common Setup
# #Suite Teardown   Common.Common Teardown
# Test Setup     Append To List  ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
# Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ANDROID_SA_ASIMR_ABINB4_AHPE    SBTS00    CRT_UTE    PY36
# 
# Suite Setup    Common Suite Setup for COAM     swconfig_flag=${True}
# Suite Teardown   Run Keyword And Ignore Error    Common.COAM Teardown gnb connections
# 
# *** Variables ***
# @{ALL_TEST_STATUS}
# ${sh}    ./scheduleForcedBtsSiteReset.sh
# ${params}    --bts-host=192.168.255.129 --bts-port=443 --bts-username=Nemuadmin --bts-password=nemuuser
# 
# *** Test Cases ***
# [1]CNI-93053_2_Emergency_reset during_ongoing_snapshot_collection_or_upload
#     [Tags]   AUTHOR_dali.wang@nokia-sbell.com
#     [Timeout]   1h
#     [Setup]     Case Setup for 93053
#     Syslog Capture Start
#     run keyword and ignore error    selenium_coam.collect_snapshot    snapshot_waiting_timeout=20
# #    ${status}    run keyword and return status    COAM Reset Site
# #    Should Be Equal    ${status}    ${True}
# #     csn.connect to    hostname=${host_addr}    username=${host_username}    password=${host_password}    alias=VM
# #     csn.Execute  command=cd /home/ute/admin_test/ &&${sh} ${params}    connection=VM
# #     csn.disconnect    connection=VM
#     sleep    3min
#     selenium_coam.disable_screen_lock
#     ${start_view}   selenium_coam.start_up_view_window_exists
#     Run Keyword If   ${start_view}   selenium_coam.close_start_up_view_window
#     ${status}    coam.schedule_forced_bts_site_reset    connection=COAM
#     log to console    ${status}
#     Should Contain    ${status}    Schedule forced BTS site reset succeeded
#     Syslog Capture Stop and Collect
#     ${message}    Print BTSlog    message_name=SiteResetPrepare::StartSiteResetPrepareTimer: Timer running
#     ${message}    Print BTSlog    message_name=System module site reset : Recovery
#     sleep  10min
#     Wait Until Keyword Succeeds   15 min   20 s    Validate IP Reachability from Test PC
#     ...   ip_addr=${WEBUI_ADDR}  exp_status=${False}
#     wait until keyword succeeds   10m   30s   COAM Check All Cells Onair
# #    Wait Until Keyword Succeeds   3x   1m     Data Transfer Conducted    cell_index=1
#     [Teardown]   Case Teardown
# 
# [1]CNI-93053_4_Emergency_reset_when_CM_operation_is_on_going
#     [Tags]   AUTHOR_dali.wang@nokia-sbell.com
#     [Timeout]   1h
#     [Setup]     Case Setup for 93053
#     ${pmax_value}    selenium_coam.get_parameter_value     dist_name=MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-1
#     ...    filter_param=Maximum output power
#     ${pmax_value}    fetch from left    ${pmax_value}    ${space}
#     ${new_pmax_value}    Evaluate    ${${pmax_value}}+1
#     Syslog Capture Start
#     selenium_coam.set_parameter_value     dist_name=MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-1
#     ...    filter_param=Maximum output power   new_value=${new_pmax_value}
#     Run Keyword and Ignore Error    selenium_coam.validate_plan
#     Run Keyword and Ignore Error    selenium_coam.activate_plan   download_plan_without_activation=${False}
#     ...    activate_plan_despite_errors=${True}   execute=${True}   timeout=180
#     selenium_coam.set_parameter_value     dist_name=MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-1
#     ...    filter_param=Maximum output power   new_value=${pmax_value}
#     Run Keyword and Ignore Error    selenium_coam.validate_plan
#     Run Keyword and Ignore Error    selenium_coam.activate_plan   download_plan_without_activation=${False}
#     ...    activate_plan_despite_errors=${True}   execute=${True}   timeout=5
# #    sleep    4min
# #    selenium_coam.disable_screen_lock
# #    ${start_view}   selenium_coam.start_up_view_window_exists
# #    Run Keyword If   ${start_view}   selenium_coam.close_start_up_view_window
# #    ${status}    selenium_coam.Schedule_Forced_Bts_Reset
#     ${status}    coam.schedule_forced_bts_site_reset    connection=COAM
#     log to console    ${status}
#     Should Contain    ${status}    Schedule forced BTS site reset succeeded
#     Syslog Capture Stop and Collect
#     ${message}    Print BTSlog    message_name=SiteResetPrepare::StartSiteResetPrepareTimer: Timer running
#     ${message}    Print BTSlog    message_name=System module site reset : Recovery
#     sleep  10min
#     Wait Until Keyword Succeeds   15 min   20 s    Validate IP Reachability from Test PC
#     ...   ip_addr=${WEBUI_ADDR}  exp_status=${False}
#     wait until keyword succeeds   10m   30s   COAM Check All Cells Onair
#     [Teardown]   Case Teardown
