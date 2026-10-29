*** Settings ***
Documentation  Script for feature intraG_interF_HO
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
${Log_Path}         /home/ute/logs
${IEFR_a2meas_id}   1
${IEFR_a3meas_id}   3


*** Test Cases ***
Make L3 SA call
    Log to Console      Starting the test case\n
    [Setup]     Prepare for IntraGnb Inter Frequency HO
    Log to Console      Registering UE\n
    UE Register should be Successful for SA     ${UE1}
    sleep    10s
    Log to Console      Starting HO
#    Start and Validate Traffic For SA       UE_ID=${UE1}
    Trigger A2 Measurement    ${UE_ID}    ${IEFR_a2meas_id}    50
    Trigger A3 Measurement for Intra GNB Inter Frequency HO     ${UE_ID}    ${IEFR_a3meas_id}   51
    Sleep   30s
#    Stop Data Traffic for SA    ${UE1}
    Collect Logs For The Test   ${Log_Path}
    Log to Console      \n Starting Tear Down for Test Case\n
#   [Teardown]      Run Keyword And Ignore Error       Common test case tear down




