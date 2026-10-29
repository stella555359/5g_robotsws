*** Settings ***
Documentation     author: Casbo Xing
...         contact: casbo.xing@nokia-sbell.com
...         Robustness test-unexpected gNB reset during SW download
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/common.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/upgrade_rollback.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/netact_swm.robot

Force Tags    SG_07    CA_5G_OAM
...    PY36

Suite Setup    Test regression robust suite setup    webui_tool=COAM    upgrade_tool=netact
Suite Teardown    Test regression robust suite teardown    webui_tool=COAM

#*** Variables ***
#${NETACT_IP}   10.110.144.147
#${upgrade_version}   SBTS00_ENB_9999_210830_000007
##${upgrade_version}  SBTS00_ENB_9999_210902_000002
#${origin_version}   SBTS00_ENB_9999_210902_000002
#${stand_alone}   NSA+SA
#${input_btsname}   MRBTS-298

*** Test Cases ***
Robust_Unexpected_Reset_Occurred_During_SW_download
    [Setup]    Test robust setup    upgrade_tool=netact    webui_tool=COAM   action=before_upgrade
    wait until keyword succeeds   3 times   5min   Trigger SW Operation from NetAct   operation=Download   taget_version=${upgrade_version}
    Get SWM Operation Status in NetAct
    Site Reset by Command
    wait until keyword succeeds  25min   1min   Check Cell Status after SW Version Modified   #check cell status after unexpected site reset
    Check If SWM Operation Finished afer Interrupt
#    Check gNB SW Version After Unexpected Interrupt
#Download again after gNB startup from reboot
    wait until keyword succeeds   3 times   5min   Trigger SW Operation from NetAct   operation=Download   taget_version=${upgrade_version}
    ${operation_status}   Check Operation Status in NetAct   operation=Download
    should contain any    ${operation_status}   Successful    Timeout-Success
    NetAct SWM Upload
    ${netct_active}  ${netact_passive}  ${netact_planned}   Get gNB SW Version From Netact SWM
    ${input_target_version}   Check gNB Version is Common Build   ${upgrade_version}
    should be equal   ${netact_planned}  ${input_target_version}
#Repeat download when target build is alrady in planned
    wait until keyword succeeds   3 times   5min   Trigger SW Operation from NetAct   operation=Download   taget_version=${upgrade_version}
    should contain any    ${operation_status}   Successful    Timeout-Success
    ${repeat_download_duration}   Get Netact SWM Operation Duration
    ${duration}   Split String   ${repeat_download_duration}   .   1
    should be true   ${duration}[0] < 180
#    run keyword and continue on failure    Check if Unexpected Active Alarm Exist and Set Stop Flag
#Activate SW after download
    wait until keyword succeeds   3 times   5min   Trigger SW Operation from NetAct   operation=Activation   taget_version=${upgrade_version}
    Wait Until Keyword Succeeds   60 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${cu_addr}  exp_status=${False}
    Wait Until Keyword Succeeds   15 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${cu_addr}  exp_status=${True}
#    Catch Realtime Log    operation=provision
    Wait Until Keyword Succeeds   10 min   30 s    Check If Active Software Version Updated
    wait until keyword succeeds  25min   1min   Check Cell Status after SW Version Modified
    ${cellDepType_status}   run keyword and return status   should contain   ${cellDepType}   both
    run keyword if   ${cellDepType_status}   sleep   5min
    repeat keyword  5 min   Coam Check Site Status
    Check Site Status After Upgrade or Rollback
    run keyword if  'both' in ${cellDepType} or 'SA' in ${cellDepType}   Check AMF Status from WebEM   ${WEBUI_URL}
    [Teardown]    Test Robust Teardown     dir=reboot

