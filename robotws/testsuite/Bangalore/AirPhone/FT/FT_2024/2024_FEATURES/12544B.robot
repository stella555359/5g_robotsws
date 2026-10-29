*** Settings ***
Documentation  Script for feature 12544B
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
    [Setup]     Prepare for test Case_12544B
    Read WTS Output For Pattern And Print matching Lines    ${r17_12544_2}    ${Timeout_SA}
    Read WTS Output For Pattern And Print matching Lines    ${r17_12544_3}    ${Timeout_SA}
    Read WTS Output For Pattern And Print matching Lines    ${r17_12544_1}    ${Timeout_SA}
    sleep    30s
    Log to Console     Starting log collection\n
##    Collect Logs For The Test   ${Log_Path}
    Log to Console      \n Starting Tear Down for Test Case
#   [Teardown]      Run Keyword And Ignore Error       Common test case tear down




