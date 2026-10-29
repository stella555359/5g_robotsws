*** Settings ***
Documentation  Scipt for ConsoleLogCollection
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...           CRT   RAN_5G_TDD   RAN_5G    SBTS00     CONFIGURED

Resource    resources/Keywords/common_keywords.robot
Resource    resources/Keywords/Testcase_KW.robot
Resource    resources/ute/sosReport.robot
#Resource    ../resources/Keywords/generic_kw.robot

#Suite Setup        Updated Suite Setup
#Suite Teardown    Common Suite Teardown

*** Variables  ***
${UE1}        1
${UE2}        2
${Log_Path1}   /home/ute/logs/logs_before_test
${Log_Path2}   /home/ute/logs/logs_after_test

*** Test Cases ***
AP_PDU_RESET
    Log to Console     Starting log collection before test\n
    Collect Logs For The Test   ${Log_Path1}
    Log to Console     Starting log collection after test\n
    Collect Logs For The Test   ${Log_Path2}
#    Log to Console      \n Starting Tear Down for Test Case
#    [Teardown]      Run Keyword And Ignore Error       Common test case tear down




