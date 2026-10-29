*** Settings ***
Documentation    Robot Test Suite
Resource    ../../../test_resources/SBTS_SBTS__STATE__RM_Power_Off_On.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables



*** Test Cases ***
[1]SBTS_SBTS__STATE__RM_Power_Off_On
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__rm_power_off_on_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RM_SHARED_INFO}    ALL
    ...    AND    Set Test Variable    ${HW_POWER_ON_WRN_THR}    240
    ...    AND    Set Test Variable    ${HW_POWER_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${HW_RESET_TIME_INTERVAL}    480

    ...    AND    SBTS_SBTS__STATE__RM_Power_Off_On.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__RM_Power_Off_On
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__RM_Power_Off_On
    TC__SBTS_SBTS__STATE__RM_Power_Off_On
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__RM_Power_Off_On.TC Teardown
    ...    AND    Restore Resource Search Order



