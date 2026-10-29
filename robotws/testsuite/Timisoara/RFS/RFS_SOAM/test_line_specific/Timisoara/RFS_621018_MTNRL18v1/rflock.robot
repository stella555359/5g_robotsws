*** Settings ***
Documentation  Test Suite
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RM_LockUnlock.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables



*** Test Cases ***
[1]SBTS_SBTS__STATE__SharedRM_Lock_Unlock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__rm_lockunlock_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RMOD_SHARING_INFO}    ALL
    ...    AND    Set Test Variable    ${RMOD_LOCK_MAX_WAIT_TIME}    300
    ...    AND    Set Test Variable    ${RMOD_UNLOCK_MAX_WAIT_TIME}    300
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__RM_LockUnlock.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_LockUnlock
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_LockUnlock
    TC__SBTS_SBTS_SBTS_SBTS__STATE__RM_LockUnlock
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__RM_LockUnlock.TC Teardown
    ...    AND    Restore Resource Search Order
