*** Settings ***
Library     Collections
Library     String
Library     OperatingSystem
Library     taf.transport.ssh   WITH NAME   csn
Library     taf.sbts.oam.coam.admin   WITH NAME   sbts
Library     counter_ops.py
Library     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/global_vars.py

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/gnb.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variables ***
${coam_alias}    COAM
*** Keywords ***
Suite Common Setup
#    COAM Login
    robot_common_operations.Common Suite Setup
    Connect to gnb coam via ssl   connection=${coam_alias}
    &{var_dict}   CI_commssion._Set Variables For Test   gnb_index=${0}   du_index= ${0}   common_unit_index=${0}
    CI_commssion.All Hw Should Be Detected   testline=${var_dict}[testline]   build=${var_dict}[build]
    ...   stream=${var_dict}[stream]   ute_env=${var_dict}[ute_env]   connection=COAM
    ${bbmod_num}    Get BBMOD Number
    ${ru_num}    Get RU Number
    ${gnb_release}   Get gnb release
    set suite variable   ${gnb_release}
    set suite variable    ${bbmod_num}
    set suite variable    ${ru_num}
    COAM WEBUI Login
#    ${errors}   Validate Plan and Return Error
#    Should Be True   ${errors[0]}==0
    Set Recovery Delay

Suite Common Teardown
    ${url_addr}    fetch from right    ${asik_addr}    https://
    ${alias_dict}   Get COAM Alias Dict   url=${url_addr}
    run keyword and ignore error    CASE Teardown Operation
    Run Keyword and Ignore Error   selenium_coam.disable_message_box   &{alias_dict}
    Run Keyword and Ignore Error   selenium_coam.disable_screen_lock   &{alias_dict}
    ${exists}   Run Keyword and Ignore Error   selenium_coam.start_up_view_window_exists   &{alias_dict}
    Run Keyword If   ${exists}   Run Keyword and Ignore Error    selenium_coam.close_start_up_view_window   &{alias_dict}
    Run Keyword and Ignore Error   COAM WEBUI Logout
    Run Keyword and Ignore Error   COAM Logout
    Run Keyword and Ignore Error    robot_common_operations.Common Suite Teardown

CASE Teardown Operation
    COAM Reset Site
    wait until keyword succeeds   900    5    Check All Components while OnAir
    Catch Snapshot COAM

Cleared reset counter
   [Arguments]    ${coam_alias}
   ${counter_status}    run keyword and return status    assert restartCounter value     expected=0   alias=${coam_alias}
   run keyword if  '${counter_status}' == 'False'    run keywords
   ...     COAM Reset Site    AND
   ...     wait until keyword succeeds   10m   30s   COAM Check All Cells Onair  AND
   ...     assert restartCounter value     expected=0    alias=${coam_alias}   AND
   ...     sleep    5m


Check All Components while OnAir
    COAM Check GNB ASIK status    connection=COAM
    COAM Check GNB ABIL status    connection=COAM
    COAM Check GNB RU status    connection=COAM


Check components status while recovery action
   [Arguments]     ${recovery_component}=RMOD    ${index}=1
   Cell Should Be Disabled   cell_idx=${index}  cell_group_idx=${${index}-1}   connection=${coam_alias}
   RU Should Be Power Off   ru_index=${index}   connection=${coam_alias}
   run keyword if    '${recovery_component}'=='BBMOD'      bbmod Should Be offline   bbmod_index=1    connection=${coam_alias}
   ...     ELSE       run keywords        COAM Check GNB ASIK status    connection=COAM    AND
   ...                                    COAM Check GNB ABIL status    connection=COAM

Check component reset status
   [Arguments]     ${recovery_component}    ${index}=1
       ${states}         run keyword if    '${recovery_component}'=='BBMOD'    BBMOD Should Be initializing    bbmod_index=1
   ...     ELSE       RU Should Be initializing   rmod_index=${index}

Wait Fault with Alarm to appear
    [Arguments]  ${FaultID}     ${AlarmID}
    wait until keyword succeeds  3000      5    Fault With Alarm Should Be Present   ${FaultID}    ${AlarmID}

Wait Fault with Alarm to disappear
    [Arguments]  ${FaultID}     ${AlarmID}
    wait until keyword succeeds  1000      5    Fault With Alarm Should Not Be Present   ${FaultID}    ${AlarmID}

Failed Operation case teardown
     run keyword and ignore error   Catch Snapshot COAM
     run keyword and ignore error   COAM Reset Site
     run keyword and ignore error   wait until keyword succeeds   900    5    Check All Components while OnAir

Set Recovery Delay
    ${return_delay}   selenium_coam.get_parameter_value   MRBTS-${GLOBAL_BTS_ID}/MNL-1/MNLENT-1   Recovery reset delay
    ${delay_num}    Get Regexp Matches    ${return_delay}    \\d*
    run keyword if   ${${delay_num[0]}} < ${30}       run keywords   selenium_coam.set_parameter_value
    ...     MRBTS-${GLOBAL_BTS_ID}/MNL-1/MNLENT-1    Recovery reset delay   60
    ...   AND   Run Keyword And Ignore Error   selenium_coam.validate_plan
    ...   AND   sleep  5s
    ...   AND   Run Keyword And Ignore Error   selenium_coam.activate_plan   activate_plan_despite_errors=True
    ...   AND   sleep  10s
