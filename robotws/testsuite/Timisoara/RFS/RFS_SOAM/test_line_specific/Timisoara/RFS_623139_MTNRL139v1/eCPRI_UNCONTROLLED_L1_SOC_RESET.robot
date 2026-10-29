*** Settings ***
Documentation  Test Suite
Resource    ../../../test_resources/SBTS_SBTS__STATE__Uncontrolled_L1Soc_Reset_CB010846.robot
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    CLOUD_10_18_UTESRANRFSMTNRL139    SBTS00    STATE_SKIP_AGENT    CRT

*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables



*** Test Cases ***
[1][1.0] Automated_RFS SBTS_SBTS__STATE__Uncontrolled_L1Soc_Reset_CB010846
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__uncontrolled_l1soc_reset_cb010846_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${uncntrldResetMplaneBreakTime}    420
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK}
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_PROCEDURE}    LANE
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    480
    ...    AND    Set Test Variable    ${ALLOWED_L1SOC_RESET_BBMOD_SN_LIST}    L1204706796,L1204706796
    ...    AND    Set Test Variable    ${SoC_Index_TO_BE_RESET_LIST}    1,2
    ...    AND    Set Test Variable    ${L1_PROCESS_NAME}    l1_application_rt
    ...    AND    Set Test Variable    ${SoC_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${SCOUT_TL_NAME}    10_18_UTESRANRFSMTNRL139_2

    ...    AND    SBTS_SBTS__STATE__Uncontrolled_L1Soc_Reset_CB010846.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Uncontrolled_L1Soc_Reset_CB010846
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Uncontrolled_L1Soc_Reset_CB010846
    TC__SBTS_SBTS__STATE__Uncontrolled_L1Soc_Reset_CB010846
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Uncontrolled_L1Soc_Reset_CB010846.TC Teardown
    ...    AND    Restore Resource Search Order
