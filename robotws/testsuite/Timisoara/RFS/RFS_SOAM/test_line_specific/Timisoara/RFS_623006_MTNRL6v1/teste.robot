*** Settings ***
Documentation  Test Suite
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_Lock_Unlock_Site_Reset.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RM_LockUnlock.robot
Resource    ../../../test_resources/SBTS__STATE__RAT_Block_Unblock_from_WEBEM.robot
Resource    ../../../test_resources/SBTS__STATE__RAT_Reset_from_WEBEM.robot
Resource    ../../../test_resources/SBTS__STATE__RM_Power_Off_On.robot
Resource    ../../../test_resources/SBTS__STATE__RM_Reset_from_WEBEM.robot
Resource    ../../../test_resources/SBTS__STATE__Site_Block_Unblock_from_WEBEM.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables



*** Test Cases ***
[1]SBTS__STATE__Cell_BlockUnblock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__cell_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${RAT_LIST}    ALL
    ...    AND    Set Test Variable    ${LTE_IOT_SA_action}    True
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Set Test Variable    ${NR_CELL_BLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${NR_CELL_UNBLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${LTE_CELL_BLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${LTE_CELL_UNBLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${WCDMA_CELL_BLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${WCDMA_CELL_UNBLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${GSM_CELL_BLOCK_WRN_THR}    130
    ...    AND    Set Test Variable    ${GSM_CELL_UNBLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${CELL_BLOCK_MAX_WAIT_TIME}    200
    ...    AND    Set Test Variable    ${CELL_UNBLOCK_MAX_WAIT_TIME}    200

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order



[1]SBTS__STATE__RAT_Block_Unblock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts__state__rat_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${RAT_TECH}

    ...    AND    SBTS__STATE__RAT_Block_Unblock_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS__STATE__RAT_Block_Unblock_from_WEBEM
    ...    AND    Set Library Search Order    SBTS__STATE__RAT_Block_Unblock_from_WEBEM
    TC__SBTS__STATE__RAT_Block_Unblock_from_WEBEM
    [Teardown]    Run Keywords    SBTS__STATE__RAT_Block_Unblock_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order



[1]SBTS__STATE__RAT_Reset_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts__state__rat_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${RAT_TECH}    all
    ...    AND    Set Test Variable    ${NR_RESET_WRN_THR}    120
    ...    AND    Set Test Variable    ${LTE_RESET_WRN_THR}    120
    ...    AND    Set Test Variable    ${WCDMA_RESET_WRN_THR}    120
    ...    AND    Set Test Variable    ${GSM_RESET_WRN_THR}    120
    ...    AND    Set Test Variable    ${MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RESET_TYPE}    Soft
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True

    ...    AND    SBTS__STATE__RAT_Reset_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS__STATE__RAT_Reset_from_WEBEM
    ...    AND    Set Library Search Order    SBTS__STATE__RAT_Reset_from_WEBEM
    TC__SBTS__STATE__RAT_Reset_from_WEBEM
    [Teardown]    Run Keywords    SBTS__STATE__RAT_Reset_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order



[1]SBTS__STATE__RM_LockUnlock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__rm_lockunlock_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
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



[1]SBTS__STATE__RM_Reset_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts__state__rm_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${HW_RESET_TIME_INTERVAL}    480
    ...    AND    Set Test Variable    ${HW_RESET_WRN_THR}    240
    ...    AND    Set Test Variable    ${HW_RESET_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True

    ...    AND    SBTS__STATE__RM_Reset_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS__STATE__RM_Reset_from_WEBEM
    ...    AND    Set Library Search Order    SBTS__STATE__RM_Reset_from_WEBEM
    TC__SBTS__STATE__RM_Reset_from_WEBEM
    [Teardown]    Run Keywords    SBTS__STATE__RM_Reset_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order



[1]SBTS__STATE__Site_Block_Unblock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts__state__site_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    5
    ...    AND    Set Test Variable    ${SBTS_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${SBTS_MAX_WAIT_TIME}    900

    ...    AND    SBTS__STATE__Site_Block_Unblock_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS__STATE__Site_Block_Unblock_from_WEBEM
    ...    AND    Set Library Search Order    SBTS__STATE__Site_Block_Unblock_from_WEBEM
    TC__SBTS__STATE__Site_Block_Unblock_from_WEBEM
    [Teardown]    Run Keywords    SBTS__STATE__Site_Block_Unblock_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order
