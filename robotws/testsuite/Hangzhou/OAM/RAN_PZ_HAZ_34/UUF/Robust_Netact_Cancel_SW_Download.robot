*** Settings ***
Documentation     author: Casbo Xing
...         contact: casbo.xing@nokia-sbell.com
...         Robustness test-Cancel Netact  SW download
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/common.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/upgrade_rollback.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/netact_swm.robot

Force Tags    SG_07    CA_5G_OAM
...    PY36

Suite Setup    Test regression robust suite setup    webui_tool=COAM    upgrade_tool=netact
Suite Teardown    Test regression robust suite teardown    webui_tool=COAM

*** Test Cases ***
Robust_Netac_Cancel_SW_Download
    [Setup]    Test robust setup    upgrade_tool=netact    webui_tool=COAM   action=before_upgrade
    wait until keyword succeeds   3 times   5min   Trigger SW Operation from NetAct   operation=Download   taget_version=${upgrade_version}
    Get SWM Operation Status in NetAct
    Cancel Netact SW Download
    Check Cell Status after SW Version Modified
#    Check if Unexpected Active Alarm Exist and Set Stop Flag
#Check passive load need to be added later, so far only check planned
    Check gNB SW Version After Unexpected Interrupt
#Download again after download canceled
    wait until keyword succeeds   3 times   5min   Trigger SW Operation from NetAct   operation=Download   taget_version=${upgrade_version}
    ${operation_status}   Check Operation Status in NetAct   operation=Download
    should contain any    ${operation_status}   Successful    Timeout-Success
    NetAct SWM Upload
    ${netct_active}  ${netact_passive}  ${netact_planned}   Get gNB SW Version From Netact SWM
    ${input_target_version}   Check gNB Version is Common Build   ${upgrade_version}
    should be equal   ${netact_planned}  ${input_target_version}
#Activate SW after download
    wait until keyword succeeds   3 times   5min   Trigger SW Operation from NetAct   operation=Activation   taget_version=${upgrade_version}
    Wait Until Keyword Succeeds   20 min   20 s    Validate IP Reachability from Test PC
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
    [Teardown]   Test Robust Teardown     dir=robustness-cancel     #teardown need to be updated in robust test