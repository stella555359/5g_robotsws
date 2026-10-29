*** Settings ***
Documentation   author: Casbo Xing
...  For fallback case, scenario fault 4082
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/common.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/upgrade_rollback.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001756/Resource/NetAct.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/fallback_common.robot
#Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/System_Upgrade.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001756/Resource/NetAct.robot
#Resource      testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001756/Resource/Common.robot


Force Tags    HAZ4_SG_07_OAM

Suite Setup    Test fallback suite setup    webui_tool=COAM    upgrade_tool=webui
Suite Teardown    Test fallback suite teardown   webui_tool=COAM

*** Test Cases ***
SW_Fallback_4082
    [Setup]    Test Fallback Setup    upgrade_tool=webui    webui_tool=COAM
#    run keyword if   ${if_not_run}   Log to console   Skip test
    Trigger SW Fallback 4082
    [Teardown]   Test Fallback Teardown      dir=fallback

*** Keywords ***
Test fallback suite setup
    [Arguments]    ${webui_tool}=COAM    ${upgrade_tool}=webui
    run keyword if  not ${${DEBUG}}   selenium_netact.enable_virtual_display
    run keyword and ignore error     Delete Code and Log from TAF
    Remove logs    savefolder=${webui_tool}
    Remove Planned Space
    Check running nms mode
    Set gNB SW version and Release
    Switch to source build
    ${bts_id}   convert to string   ${MRBTS_ID}
    set suite variable    ${bts_id}
    Set gNB SW version and Release
#    COAM Download SCF to Current Dir    filename=X2ENB_SCF_BACKUP.xml    bts_host=${ENBs[0]['addr']}
#    ${x2_enb_mrbtsId}    get_bts_info.Get_LNBTS_ID    ${cpri_scf}/X2ENB_SCF_BACKUP.xml
#    set suite variable    ${x2_enb_mrbtsId}

Test fallback suite teardown
    [Arguments]     ${webui_tool}=COAM
    run keyword and ignore error    Upload TAF Log to FTP Server
    run keyword if  not ${${DEBUG}}   selenium_netact.disable_virtual_display
