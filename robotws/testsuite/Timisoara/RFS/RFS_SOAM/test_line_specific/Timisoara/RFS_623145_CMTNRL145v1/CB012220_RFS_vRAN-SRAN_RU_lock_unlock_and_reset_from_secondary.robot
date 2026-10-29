*** Settings ***
Documentation  Test Suite
Resource    ../../../test_resources/CBTS_SBTS__STATE__RM_LockUnlock.robot
Resource    ../../../test_resources/CBTS_SBTS__STATE__RM_Reset.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
${USER_RTWP_CHECK}   ${FALSE}
${POWER_ON_FLAG}    ${True}
${USER_UPDATE_DCAP}  ${FALSE}
${RP_CA}    VRF_SiSo
${RP_LOCATION}    VRF_TSR2
${RP_ORGANIZATION}    VRF_TSR2_T02
${SCOUT_TL_NAME}    10_18_UTESRANRFSCMTNRL145
${TEST STATUS}  PASSED



*** Test Cases ***
[1]CB012220_RFS_vRAN-SRAN_RU_lock_unlock_and_reset_from_secondary_controller_with_CB007878_activated
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__state__rm_lockunlock_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RMOD_SHARING_INFO}    ALL
    ...    AND    Set Test Variable    ${RMOD_LOCK_MAX_WAIT_TIME}    300
    ...    AND    Set Test Variable    ${RMOD_UNLOCK_MAX_WAIT_TIME}    300
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True

    ...    AND    CBTS_SBTS__STATE__RM_LockUnlock.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__STATE__RM_LockUnlock
    ...    AND    Set Library Search Order    CBTS_SBTS__STATE__RM_LockUnlock
    TC__CBTS_SBTS__STATE__RM_LockUnlock
    CBTS_SBTS__STATE__RM_LockUnlock.TC Teardown
    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__state__rm_reset_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RMOD_SHARING_INFO}    ALL
    ...    AND    Set Test Variable    ${RMOD_RESET_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RMOD_RESET_WRN_THR}    180
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN_SBTS}    True
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN_CBTS}    True
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    CBTS_SBTS__STATE__RM_Reset.TC Setup

    ...    AND    Modify Resource Search Order    CBTS_SBTS__STATE__RM_Reset
    ...    AND    Set Library Search Order    CBTS_SBTS__STATE__RM_Reset
    ${subtests_test_status}    Run Keyword And Return Status    TC__CBTS_SBTS__STATE__RM_Reset
    Log    Status for subtests test: ${subtests_test_status}
    [Teardown]    Run Keywords    CBTS_SBTS__STATE__RM_LockUnlock.TC Teardown
    ...    AND    Restore Resource Search Order