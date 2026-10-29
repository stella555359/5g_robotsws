# *** Settings ***
# Documentation
# ...   author: Jiang Johnny
# ...   contact: johnny.1.jiang@nokia-sbell.com
# 
# Resource   ./Resource/common.robot
# Resource   ./Resource/702.robot
# Resource   ./Resource/coam.robot
# Suite Setup   Suite Setup Steps
# Suite Teardown   Suite Teardown Steps
# Force Tags   SG_08   CA_5G_Siso         CRT
# ...    PY36
# 
# *** Variables ***
# ${dist_name}   MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].instance_id}
# 
# *** Test Cases ***
# [1]FGCR-6373_Increase_PSD_on_AAHF_for_non_FCC_markets_20M_exceed_pmax
#     [Tags]    AUTHOR_johnny.1.jiang@nokia-sbell.com
#     [Timeout]    60 min
#     [Setup]   Run Keywords    COAM Login   alias=${coam_alias}
#     ...   AND   COAM WEBUI Login   display=${${DEBUG}}
#     ${start_view}   selenium_coam.start_up_view_window_exists
#     Run Keyword If   ${start_view}   selenium_coam.close_start_up_view_window
#     ${bandwidth}    selenium_coam.get_parameter_value   dist_name=${dist_name}/NRCELL-1   filter_param=Channel bandwidth
#     ${pmax}    selenium_coam.get_parameter_value   dist_name=${dist_name}/NRCELL-1   filter_param=Maximum output power
#     Modify Bandwidth and Pmax   bandwidth=${bandwidth}
#     Sleep   10m
#     Wait until keyword succeeds  10min   30s   Check Alarm Exist
#     ${start_view}   selenium_coam.start_up_view_window_exists
#     Run Keyword If   ${start_view}   selenium_coam.close_start_up_view_window
#     [Teardown]   Run Keywords   Recovery Bandwidth and Pmax   bandwidth=${bandwidth}   pmax=${pmax}
#     ...   AND   run keyword and ignore error   COAM WEBUI Logout   display=${${DEBUG}}
#     ...   AND   COAM Logout   connection=${coam_alias}
# 
# *** Keywords ***
# Modify Bandwidth and Pmax
#      [Arguments]      ${bandwidth}
#      Run Keyword If   '${bandwidth}'!='20MHz'
#      ...   selenium_coam.set_parameter_value     dist_name=${dist_name}/NRCELL-1   filter_param=Channel bandwidth    new_value=20MHz
#      Run Keyword If   '${bandwidth}'!='20MHz'
#      ...   selenium_coam.set_parameter_value     dist_name=${dist_name}/NRCELL-2   filter_param=Channel bandwidth    new_value=20MHz
#      selenium_coam.set_parameter_value     dist_name=${dist_name}/NRCELL-1   filter_param=Maximum output power   new_value=33
#      run keyword and ignore error   selenium_coam.validate_plan
#      run keyword and ignore error   selenium_coam.activate_plan   download_plan_without_activation=${False}    activate_plan_despite_errors=${True}
#      ...   execute=${True}   timeout=180
# 
# Check Alarm Exist
#     @{alarm_list}    taf_coam.COAM Get Active Alarms    connection=${coam_alias}
#     ${active_alarm_list}    Create List
#     :FOR   ${alarm}   IN    @{alarm_list}
#         ${faultid}    Set Variable    ${alarm['faultId']}
#         Append to list    ${active_alarm_list}    ${faultid}
#     END
#     ${active_alarm_list}   convert to string   ${active_alarm_list}
#     Should Contain Any   ${active_alarm_list}   4008   1900
# 
# Recovery Bandwidth and Pmax
#     [Arguments]      ${bandwidth}   ${pmax}
#     ${start_view}   selenium_coam.start_up_view_window_exists
#     Run Keyword If   ${start_view}   selenium_coam.close_start_up_view_window
#     Run Keyword If   '${bandwidth}'!='20MHz'
#     ...   selenium_coam.set_parameter_value     dist_name=${dist_name}/NRCELL-1   filter_param=Channel bandwidth    new_value=${bandwidth}
#     Run Keyword If   '${bandwidth}'!='20MHz'
#     ...   selenium_coam.set_parameter_value     dist_name=${dist_name}/NRCELL-2   filter_param=Channel bandwidth    new_value=${bandwidth}
#     selenium_coam.set_parameter_value     dist_name=${dist_name}/NRCELL-1    filter_param=Maximum output power   new_value=${pmax}
#     run keyword and ignore error   selenium_coam.validate_plan
#     run keyword and ignore error   selenium_coam.activate_plan   download_plan_without_activation=${False}    activate_plan_despite_errors=${True}
#     ...   execute=${True}
#     Wait Until Keyword Succeeds   20m   60s   COAM Check All Cells Onair