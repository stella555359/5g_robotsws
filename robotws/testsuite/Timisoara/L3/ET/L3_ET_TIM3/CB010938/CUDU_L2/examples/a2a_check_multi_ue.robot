*** Settings ***
Documentation
...    a2a example for check csv file

Resource         ./../common_setup_teardown.robot

*** Variables ***
${UE_ID}                1    #11 for NSA
${PROFILE_ID}          1
${GNB_ID}              2
${CELL_ID}             1
${BEARER_ID}           2
${ASP_BOARD_TYPE}    ABIO
*** Test Cases ***

A2A_Case_1
    ta_a2a.Check Log With Au2anlysis    ${CURDIR}/ttitrace_a2a/a2a_1/ttitrace_1.ini    i    ${CURDIR}/dlFdSchedData_3.csv
    ...    save_log_directory=${CURDIR}

*** Keywords ***
Suite Setup Update GNB
    Clean Up Env
    Create Suite Directory
    Get All Testline Information And Set Suite Variable
    Print Testline Info Ahead Of Report


