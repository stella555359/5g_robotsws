*** Settings ***
Documentation   author: Casbo Xing
...  Decondary core fallback, scenario fault 4082
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/common.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/upgrade_rollback.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001756/Resource/NetAct.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/fallback_common.robot
#Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/System_Upgrade.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001756/Resource/NetAct.robot
#Resource      testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001756/Resource/Common.robot


Suite Setup    Test fallback suite setup    webui_tool=COAM    upgrade_tool=webui
Suite Teardown    Test fallback suite teardown   webui_tool=COAM


*** Test Cases ***
Secondary Core Fallback
    [Documentation]
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing secondary core fallback due to max reset loop
    ...
    ...    The main steps performed for the test are:
    ...
    ...     - Update BTS SW to target version
    ...     - Login to secondary core and execute ddal -s ddal_boot_set_reset_loop_count 3
    ...     ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN
    ...     - Check if fallback occurred on secondary core(4082)
    ...     - Provision BTS to current running package
    ...     - Check if fault 4082 cleared and BTS startup
    ...     - Check final BTS state
    ...
    ...    Pass criteria: BTS startup normally after reprovision(fault 23 is as expected in this case)
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 14.04.2023 - Case Draft
    ...    - 17.04.2023 -
    ...    Author: casbo.xing@nokia-sbell.com
    [Setup]  Test Fallback Setup    upgrade_tool=webui    webui_tool=COAM
    ${target_version}   Check gNB Version is Common Build   ${upgrade_version}
    run keyword if   '${ACTIVE_GNB_VERSION}' != '${target_version}'     Update BTS to Target Version
    Trigger SW Fallback on Secondary Core
    Check BTS Status After Secondary Core Fallback
    [Teardown]  Test Teardown      dir=fallback

*** Variables ***
${alarm_list_1}   [4082]
${alarm_list_2}   [23]

*** Keywords ***
Test fallback suite setup
    [Arguments]    ${webui_tool}=COAM    ${upgrade_tool}=webui
    run keyword if  not ${${DEBUG}}   selenium_netact.enable_virtual_display
    run keyword and ignore error     Delete Code and Log from TAF
    Remove logs    savefolder=${webui_tool}
    Remove Planned Space
    Check running nms mode
#    Set gNB SW version and Release
#    Switch to source build
    ${bts_id}   convert to string   ${MRBTS_ID}
    set suite variable    ${bts_id}
    Set gNB SW version and Release

Test fallback suite teardown
    [Arguments]     ${webui_tool}=COAM
    run keyword and ignore error    Upload TAF Log to FTP Server
    run keyword if  not ${${DEBUG}}   selenium_netact.disable_virtual_display

Update BTS to Target Version
    COAM Upgrade package    package=${upgrade_version}
    Wait Until Keyword Succeeds   50 min   10 s    Validate IP Reachability from Test PC
    ...   ip_addr=${cu_addr}   exp_status=${False}
    Wait Until Keyword Succeeds   10 min   30 s    Validate IP Reachability from Test PC
    ...   ip_addr=${cu_addr}  exp_status=${True}
    wait until keyword succeeds  25min   1min   Check Cell Status after SW Version Modified

Trigger SW Fallback on Secondary Core
    csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}   alias=primary_core
    csn.Connect to   hostname=fct4s0icom.local    username=${asik_username}    password=${asik_password}
    ...    alias=secondary_core   proxy=primary_core
    csn.execute   command=ddal -s ddal_boot_set_reset_loop_count 3   timeout=60  connection=secondary_core
    csn.execute   command=ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN   connection=secondary_core
    [Teardown]  Run Keywords    csn.Disconnect    connection=primary_core
    ...   AND   csn.Disconnect    connection=secondary_core

Check BTS Status After Secondary Core Fallback
    wait until keyword succeeds  7min   30s   Check Alarm after Fallback
#    ${active_version}   ${passive_version}   Get gNB SW version
    Log to console    Secondary core fallback!
    Sleep   5 min
    Set gNB SW version and Release
    should be equal    ${ACTIVE_GNB_RELEASE}_${ACTIVE_GNB_VERSION}   ${upgrade_version}
    Log to console   Provision to clear fault 4082
    COAM Upgrade package    package=${ACTIVE_GNB_RELEASE}_${ACTIVE_GNB_VERSION}
    wait until keyword succeeds   20 min   30s   Check If Alarm As Expected    ${alarm_list_1}
    ${module}   ${fault}   Check BTS Status After SW Reprovision
    run keyword if   ${module}   wait until keyword succeeds  10 min   30s    Check Cell Status after SW Version Modified
    run keyword if  not ${fault}   run keywords   COAM Upgrade package    package=${ACTIVE_GNB_RELEASE}_${ACTIVE_GNB_VERSION}
    ...   AND   wait until keyword succeeds  10 min   30s    Check Cell Status after SW Version Modified


Check If Alarm As Expected
    [Arguments]  ${Expected_alarm}
    gnb_handler.login   ip=${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}   gnb_type=coam   connection=gnb
    @{return_active_alarm}   gnb_handler.get_active_alarms   connection=gnb   except_alarms=${Ignore_Fault}
    ${fault_exist}   UUF_common.find_value_in_list   check_list=@{return_active_alarm}   check_key=faultId   check_value_list=${Expected_alarm}
    should not be true   ${fault_exist}
    [Teardown]  run keyword and ignore error  gnb_handler.logout


Check BTS Status After SW Reprovision
    FOR  ${i}   IN RANGE  ${45}
        ${if_module_detected}   run keyword and return status   Check Module Status
        exit for loop if  ${if_module_detected}
        ${if_fault_23}   run keyword and return status    Check If Alarm As Expected   ${alarm_list_2}
        exit for loop if  ${if_fault_23}==${False}
     END
    [Return]  ${if_module_detected}  ${if_fault_23}

Check Module Status
     [Arguments]   ${ip}=${WEBUI_ADDR}    ${username}=${WEBUI_USER}   ${password}=${WEBUI_PASSWORD}
     Log To Console  Coam Check Site Status
     gnb_handler.login   ip=${ip}   username=${username}   password=${password}   gnb_type=coam   connection=gnb
     run keyword and continue on failure    Check ASIK Status Coam
     run keyword and continue on failure    Check ABIL Status Coam
     run keyword and continue on failure    Check RU Status Coam
     [Teardown]   run keyword and ignore error  gnb_handler.logout   connection=gnb

Test Teardown
    [Arguments]  ${dir}
    run keyword if test passed    Remove Fallback Logs
    run keyword if test failed    Save Fallback Logs     ${TEST_NAME}/${dir}
