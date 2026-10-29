*** Settings ***
Documentation  Script for Feature 7103B
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...           CRT   RAN_5G_TDD   RAN_5G    SBTS00     CONFIGURED

Resource    resources/Keywords/common_keywords.robot
Resource    resources/Keywords/Testcase_KW.robot
Resource    resources/ute/sosReport.robot

Suite Setup        Updated Suite Setup
#Suite Teardown    Common Suite Teardown

*** Variables  ***
${UE1}        1
${UE2}        2
${Log_Path}   /home/ute/logs
${profile_id}   3


*** Test Cases ***
Make L3 SA call
    Log to Console      Starting the test case\n
    [Setup]     Prepare for test Case_7103B
    Log to Console      Registering UE\n
    UE Register should be Successful for SA     ${UE1}
    Start and Validate Traffic For SA       UE_ID=${UE1}
    wtsrunner.ul_sinr_testmode_nr   profile_id=${profile_id}    pathloss=100
    wtsrunner.ue_testmode_set_nr    id=${UE1}   testmode=ul_sinr    profile_id=${profile_id}    action=activate
    wtsrunner.ul_sinr_testmode_nr   profile_id=${profile_id}    pathloss=110
    wtsrunner.ue_testmode_set_nr    id=${UE1}   testmode=ul_sinr    profile_id=${profile_id}    action=activate
    wtsrunner.ul_sinr_testmode_nr   profile_id=${profile_id}    pathloss=120
    wtsrunner.ue_testmode_set_nr    id=${UE1}   testmode=ul_sinr    profile_id=${profile_id}    action=activate
    UE pathloss_7103    ${profile_id}
    Stop Data Traffic for SA    ${UE1}
    sleep    30s
    Log to Console     Starting log collection\n
    Collect Logs For The Test   ${Log_Path}
    Log to Console      \n Starting Tear Down for Test Case
#   [Teardown]      Run Keyword And Ignore Error       Common test case tear down




