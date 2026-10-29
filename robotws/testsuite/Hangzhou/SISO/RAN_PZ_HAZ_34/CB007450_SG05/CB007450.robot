*** Settings ***
Suite Setup          SBTS Suite Setup
Suite Teardown       SBTS Suite Teardown
Test Setup           SBTS Test Setup
Test Teardown        SBTS Test Teardown
Test Timeout         60min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_LTE.robot
Resource    ${BASIC_PATH_COMMON}/SBTS_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_COMMON}/Manual_SiSo_CM_Recommissioning.robot
Resource    ${BASIC_PATH_COMMON}/Manual_SiSo_CM_Commissioning_Configuration_reset.robot
Resource    ${BASIC_PATH_COMMON}/General_KPI_Test_Case.robot
Resource    ${BASIC_PATH_COMMON}/Auto_BTS_site_reset.robot
Resource    ${BASIC_PATH_COMMON}/Manual_SiSo_SWM_Software_download_and_activation.robot
Resource    ${BASIC_PATH_LTE}/Manual_SiSo_SM_BTS_Site_Reset.robot

Documentation
...    Author:liu yue
...    contact:yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature SRAN in 22R3 program

*** Variables ***

*** Test Cases ***

[1]NL_CB007450_5_Manual_SiSo_SM_LTE_RAT_reset
    [Tags]    CRT_TRUNK
    Manual_SiSo_SM_BTS_Site_Reset    ul_tp=9    dl_tp=10

*** Keywords ***
