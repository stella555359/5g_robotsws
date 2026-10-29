*** Settings ***
Documentation     author: Ruiyu Han
...               contact: ruiyu.han@nokia-sbell.com
...               Upgrade and Rollback UUF case.
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/gnb.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/webui_coam.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/common.robot
Variables   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/global_vars.py
Library   taf.transport.ssh   WITH NAME   csn
Library           taf.hw.switch    WITH NAME    switch


*** Keywords ***
Disable Switch Port
    log to console     Disable Switch Port
    switch.connect_to   hostname=${switch_addr}   username=${switch_username}   password=${switch_password}   alias=switch
    switch.disable_interface    interface_id=${switch_port}    connection=switch
    sleep   10 s
    switch.interface_active    interface_id=${switch_port}    connection=switch

Enable Switch Port
    log to console     Enable Switch Port
    switch.connect_to   hostname=${switch_addr}   username=${switch_username}   password=${switch_password}   alias=switch
    switch.enable_interface    interface_id=${switch_port}    connection=switch
    sleep   10 s
    switch.interface_active    interface_id=${switch_port}    connection=switch

#Test Fallback Setup
#    [Arguments]    ${upgrade_tool}   ${webui_tool}
#    Define NMS Type   ${nms_index}
#    Check if taget SW package exist      upgradetool=${upgrade_tool}    version=${upgrade_version}
#    run keyword and ignore error   Start BTS LOG Collection On Gnb And Rus
#    selenium_coam.enable_virtual_display
#    Set gNB SW version and Release
#    Switch to source build
#    run keyword    Check Cell Setup in ${webui_tool}

Test Fallback Setup
    [Arguments]    ${upgrade_tool}   ${webui_tool}
#    [Arguments]    ${upgrade_tool}   ${webui_tool}   ${nms_index}
#    Define NMS Type and Set Run Flag   ${nms_index}
    Check taget SW package exist in taf server     version=${upgrade_version}
    Set gNB SW version and Release
    run keyword and ignore error   Start BTS LOG Collection On Gnb And Rus

Test Fallback Teardown
    [Arguments]  ${dir}
    run keyword if test passed    Remove Fallback Logs
    ${if_fallback}   run keyword and return status   Check Alarm after Fallback
    run keyword if   ${if_fallback}    Recover BTS from fallback
    run keyword if test failed    Save Fallback Logs     ${TEST_NAME}/${dir}

Check Cell Status after SW Version Modified
    [Arguments]   ${login_ip}=${WEBUI_ADDR}
    log to console    Check Cell Status
    gnb_handler.login   ip=${login_ip}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}   gnb_type=coam   connection=gnb
    Get Cell Status Coam
    [Teardown]   gnb_handler.logout   connection=gnb

Remove Fallback Logs
    Log    pass
    run keyword and ignore error    Stop And Remove BTS LOG Collection On Gnb And Rus

Save Fallback Logs
    [Arguments]   ${dir}
    run keyword and ignore error    Screenshot for COAM     dir=${dir}
    run keyword and ignore error    Stop And Download And Remove BTS LOG Collection On Gnb And Rus     dir=${dir}
    run keyword and ignore error    Save Snapshot logs    dir=${dir}

#Check SW Version after Fallback
#    ${active_version}   ${passive_version}   wait until keyword succeeds   5 min   30 s   gnb_handler.get_sw_version_by_ssh   gnb_ip=${cu_addr}
#    should be equal    ${active_version}   ${origin_version}

Trigger SW Fallback 4082
    COAM Upgrade package    package=${upgrade_version}
    Wait Until Keyword Succeeds   50 min   10 s    Validate IP Reachability from Test PC
    ...   ip_addr=${cu_addr}   exp_status=${False}
    Wait Until Keyword Succeeds   10 min   30 s    Validate IP Reachability from Test PC
    ...   ip_addr=${cu_addr}  exp_status=${True}
    wait until keyword succeeds  25min   1min   Check Cell Status after SW Version Modified
    Execute reset loop
    run keyword and continue on failure   Check connection status after reset
    wait until keyword succeeds  7min   30s   Check Alarm after Fallback
    Check SW Version after Fallback
    Check if log file generated after fallback

Check SW Version after Fallback
    ${active_version}   ${passive_version}   Get gNB SW version
#    ${active_gNB}   Check gNB Version is Common Build   ${active_version}
    ${upgrade_build}   Check gNB Version is Common Build   ${upgrade_version}
    ${origin_build}   Check gNB Version is Common Build   ${origin_version}
    should be equal  ${origin_build}    ${active_version}

Check Alarm after Fallback
    gnb_handler.login   ip=${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}   gnb_type=coam   connection=gnb
     @{return_active_alarm}   gnb_handler.get_active_alarms   connection=gnb   except_alarms=${Ignore_Fault_Fallback}
     ${active_alarm_list}    create list
     FOR   ${alarm}   IN    @{return_active_alarm}
         ${fault}    Set Variable    ${alarm['faultName']}
         Append to list    ${active_alarm_list}    ${fault}
     END
     should contain   ${active_alarm_list}   SW fallback
#     lists should be equal   ${active_alarm_list}   ${Exp_Fault_Fallback}
    [Teardown]  run keyword and ignore error  gnb_handler.logout

Execute reset loop
    Wait Until Keyword Succeeds    10 min    1 min
    ...   csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    csn.execute   command=ddal -s ddal_boot_set_reset_loop_count 3   timeout=60  connection=gnb
    csn.execute   command=ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN   timeout=60   connection=gnb

Check connection status after reset
    Wait Until Keyword Succeeds   15 min   30 s    Validate IP Reachability from Test PC
    ...   ip_addr=${asik_addr}  exp_status=${False}
    Wait Until Keyword Succeeds   15 min   30 s    Validate IP Reachability from Test PC
    ...   ip_addr=${asik_addr}  exp_status=${True}
    Wait Until Keyword Succeeds   15 min   30 s    Validate IP Reachability from Test PC
    ...   ip_addr=${asik_addr}  exp_status=${False}
    Wait Until Keyword Succeeds   15 min   30 s    Validate IP Reachability from Test PC
    ...   ip_addr=${asik_addr}  exp_status=${True}

Check if log file generated after fallback
    csn.Connect to   hostname=${cu_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    ${output}   csn.execute    command=ls -l /ffs/run/config/fallbackCause.txt    timeout=15   connection=gnb
    should not contain   ${output}   No such file or directory
    [Teardown]  run keyword and ignore error    csn.Disconnect   connection=gnb

Check if Dual Core setup
    COAM Login
    ${smod_list}   coam.get_fsm_info   connection=COAM
    ${is_dual_core}   Set Variable If   len(${smod_list}) > 1   ${True}   ${False}
    [Teardown]   COAM Logout

Check bts status should be
    [Arguments]   ${status}   ${host}=${WEBUI_ADDR}
    ${bts_status}   Get bts status   host=${host}
    Should Be Equal   ${status}   ${bts_status}

Get bts status
    [Arguments]   ${host}=${WEBUI_ADDR}
    wait until keyword succeeds   1 min   10 s   gnb_handler.login   ip=${host}   gnb_type=coam   connection=gnb
    ${bts_status}   gnb_handler.get_bts_status   connection=gnb
    [Return]  ${bts_status}
    [Teardown]   run keyword and ignore error  gnb_handler.logout   connection=gnb

Fallback recovery condition A
    csn.Connect to   hostname=${cu_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
    csn.execute    command=rm /ffs/run/config/fallbackCause.txt  timeout=15   connection=gnb
    csn.execute    command=reboot   connection=gnb
    Wait Until Keyword Succeeds   5 min   10 s    Validate IP Reachability from Test PC
    ...   ip_addr=${cu_addr}   exp_status=${False}
    Wait Until Keyword Succeeds   5 min   30 s    Validate IP Reachability from Test PC
    ...   ip_addr=${cu_addr}  exp_status=${True}
    wait until keyword succeeds  25min   1min   Check Cell Status after SW Version Modified
    [Teardown]  run keyword and ignore error    csn.Disconnect   connection=gnb

Fallback recovery condition B
#    ${active_version}   ${passive_version}   wait until keyword succeeds  5 min   30 s   gnb_handler.get_sw_version_by_ssh   gnb_ip=${cu_addr}
    Check taget SW package exist in taf server    ${upgrade_version}
    COAM Upgrade package  ${upgrade_version}
    run keyword and ignore error    Wait Until Keyword Succeeds   15 min   10 s    Validate IP Reachability from Test PC
    ...   ip_addr=${cu_addr}   exp_status=${False}
    Wait Until Keyword Succeeds   10 min   10 s    Validate IP Reachability from Test PC
    ...   ip_addr=${cu_addr}  exp_status=${True}
    wait until keyword succeeds  25min   1min   Check Cell Status after SW Version Modified
    COAM Rollback package
    Wait Until Keyword Succeeds   10 min   10 s    Validate IP Reachability from Test PC
    ...   ip_addr=${cu_addr}  exp_status=${False}
    Wait Until Keyword Succeeds   10 min   10 s    Validate IP Reachability from Test PC
    ...   ip_addr=${cu_addr}  exp_status=${True}
    wait until keyword succeeds  15 min   10s   Check Cell Status after SW Version Modified

Recover BTS from fallback
    Log to console   Recovery action of Fallback
    ${bts_status}   Get bts status
    ${is_onair}   run keyword and return status   should be equal   ${bts_status}   OnAir
    run keyword if   ${is_onair}    Fallback recovery condition A
    ...   ELSE   run keyword   Fallback recovery condition B