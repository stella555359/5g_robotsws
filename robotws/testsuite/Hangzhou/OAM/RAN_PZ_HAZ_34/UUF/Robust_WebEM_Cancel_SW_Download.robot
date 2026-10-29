*** Settings ***
Documentation     author: Casbo Xing
...         contact: casbo.xing@nokia-sbell.com
...         Robustness test-Cancel Netact  SW download
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/common.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/upgrade_rollback.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/netact_swm.robot

Force Tags    SG_07    CA_5G_OAM
...    PY36

Suite Setup    Test regression robust suite setup    webui_tool=COAM    upgrade_tool=webui
Suite Teardown    Test regression robust suite teardown    webui_tool=COAM

#*** Variables ***
#${NETACT_IP}   10.110.144.147
##${upgrade_version}   SBTS00_ENB_9999_210830_000007
#${upgrade_version}  SBTS00_ENB_9999_210915_000001
#${origin_version}   SBTS00_ENB_9999_210912_000003
#${stand_alone}   NSA+SA
#${input_btsname}   MRBTS-298

*** Test Cases ***
Robust_WebEM_Cancel_SW_Download
    [Setup]    Test robust setup    upgrade_tool=webui    webui_tool=COAM   action=before_upgrade
    WebEM Trigger Software Update   package=${upgrade_version}
    WebEM Cancel Software Update
    Check Cell Status after SW Version Modified
#    Check if Unexpected Active Alarm Exist and Set Stop Flag
#Check passive load(for different SMOD) need to be added later, so far only check planned and compare netact and webem
    Check gNB SW Version After Unexpected Interrupt
#WebEM SW update again after download canceled
    COAM Upgrade package   package=${upgrade_version}
    Wait Until Keyword Succeeds   10 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${cu_addr}  exp_status=${False}
    Wait Until Keyword Succeeds   10 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${cu_addr}  exp_status=${True}
#    Catch Realtime Log    operation=provision
    Wait Until Keyword Succeeds   10 min   30 s    Check If Active Software Version Updated
    wait until keyword succeeds  25min   1min   Check Cell Status after SW Version Modified
    ${cellDepType_status}   run keyword and return status   should contain   ${cellDepType}   both
    run keyword if   ${cellDepType_status}   sleep   5min
    repeat keyword  5 min   Coam Check Site Status
    Check Site Status After Upgrade or Rollback
#    Check NMS Status from WebEM   ${oamtls_value}   ${WEBUI_URL}
    run keyword if  'both' in ${cellDepType} or 'SA' in ${cellDepType}   Check AMF Status from WebEM   ${WEBUI_URL}
    [Teardown]   Test Robust Teardown     dir=robustness-cancel     #teardown need to be updated in robust test
