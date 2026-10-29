*** Settings ***
Documentation  Test Suite
Resource    ../../../test_resources/SBTS_SBTS__STATE__Uncontrolled_L1Soc_Reset_CB010846.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables



*** Test Cases ***
[1]SBTS_SBTS__STATE__Uncontrolled_L1Soc_Reset_CB010846
    [Timeout]    144000
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__uncontrolled_l1soc_reset_cb010846_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${uncntrldResetMplaneBreakTime}    420
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK}    Master
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_PROCEDURE}    LANE
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    480
    ...    AND    Set Test Variable    ${ALLOWED_L1SOC_RESET_BBMOD_SN_LIST}    L1204706514,L1204706514
    ...    AND    Set Test Variable    ${SoC_Index_TO_BE_RESET_LIST}    1,2
    ...    AND    Set Test Variable    ${L1_PROCESS_NAME}    l1_application_rt
    ...    AND    Set Test Variable    ${SoC_MAX_WAIT_TIME}    900

    ...    AND    SBTS_SBTS__STATE__Uncontrolled_L1Soc_Reset_CB010846.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Uncontrolled_L1Soc_Reset_CB010846
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Uncontrolled_L1Soc_Reset_CB010846
    TC__SBTS_SBTS__STATE__Uncontrolled_L1Soc_Reset_CB010846
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Uncontrolled_L1Soc_Reset_CB010846.TC Teardown
    ...    AND    Restore Resource Search Order
