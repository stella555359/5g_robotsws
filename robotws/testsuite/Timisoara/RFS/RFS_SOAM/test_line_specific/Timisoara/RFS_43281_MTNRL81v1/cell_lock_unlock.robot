*** Settings ***
Documentation  Test Suite
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Cell_Lock_Unlock_via_PLAN.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables



*** Test Cases ***
[1]SBTS_SBTS_SBTS_SBTS__STATE__Cell_Lock_Unlock_via_PLAN
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__cell_lock_unlock_via_plan_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    1
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${RAT_LIST}    ALL
    ...    AND    Set Test Variable    ${LTE_IOT_SA_action}    True
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Set Test Variable    ${NR_CELL_LOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${NR_CELL_UNLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${LTE_CELL_LOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${LTE_CELL_UNLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${CELL_LOCK_MAX_WAIT_TIME}    200
    ...    AND    Set Test Variable    ${CELL_UNLOCK_MAX_WAIT_TIME}    200

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Lock_Unlock_via_PLAN.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Lock_Unlock_via_PLAN
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Lock_Unlock_via_PLAN
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Cell_Lock_Unlock_via_PLAN
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Lock_Unlock_via_PLAN.TC Teardown
    ...    AND    Restore Resource Search Order