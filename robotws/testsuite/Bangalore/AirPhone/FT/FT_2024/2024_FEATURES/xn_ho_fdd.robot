*** Settings ***
Documentation  Script for xn_ho_fdd
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...           CRT   RAN_5G_TDD   RAN_5G    SBTS00     CONFIGURED

Resource    resources/Keywords/common_keywords.robot
Resource    resources/Keywords/Testcase_KW.robot

Suite Setup        Updated Suite Setup
#Suite Teardown    Common Suite Teardown

*** Variables  ***
${UE1}        1
${UE2}        2
${LOG_DIR}              /home/ute/logs
${IEFR_a2meas_id}   1
${IEFR_a3meas_id}   5


*** Test Cases ***
Make L3 SA call
    Log to Console      Starting the test case\n
    [Setup]     Prepare for Xn Handover test Case for FDD
    Log to Console      Registering UE\n
    UE Register should be Successful for SA     ${UE1}
    sleep    10s
    Log to Console      Starting HO
#    Start and Validate Traffic For SA       UE_ID=${UE1}
    Trigger A2 Measurement    ${UE_ID}    ${IEFR_a2meas_id}    50
    sleep   10s
    Trigger HO from Real to Sim with A3     ${UE1}    ${IEFR_a3meas_id}    52
    Sleep   30s
#    Stop Data Traffic for SA    ${UE1}
    Log to Console      \n Starting Tear Down for Test Case\n
#   [Teardown]      Run Keyword And Ignore Error       Common test case tear down




