*** Settings ***
Documentation  Test Suite
Resource    ../../../test_resources/SBTS_SBTS__STATE__Uncontrolled_BBMOD_Reset_CB010846.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables



*** Test Cases ***
[1]SBTS_SBTS__STATE__Uncontrolled_BBMOD_Reset_CB010846
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__uncontrolled_bbmod_reset_cb010846_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${uncntrldResetMplaneBreakTime}    420
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK}
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_PROCEDURE}    LANE
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    480
    ...    AND    Set Test Variable    ${ALLOWED_RESET_BBMOD_SN_LIST}    L1204706796
    ...    AND    Set Test Variable    ${BBMOD_MAX_WAIT_TIME}    900

    ...    AND    SBTS_SBTS__STATE__Uncontrolled_BBMOD_Reset_CB010846.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Uncontrolled_BBMOD_Reset_CB010846
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Uncontrolled_BBMOD_Reset_CB010846
    TC__SBTS_SBTS__STATE__Uncontrolled_BBMOD_Reset_CB010846
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Uncontrolled_BBMOD_Reset_CB010846.TC Teardown
    ...    AND    Restore Resource Search Order
