*** Settings ***
Documentation  Test Suite
Resource    ../../../test_resources/CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check.robot
Resource    ../../../test_resources/CBTS_SBTS__STATE__Cell_BlockUnblock.robot
Resource    ../../../test_resources/CBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode.robot
Resource    ../../../test_resources/CBTS_SBTS__STATE__RM_LockUnlock.robot
Resource    ../../../test_resources/CBTS_SBTS__STATE__RM_Power_Off_On.robot
Resource    ../../../test_resources/CBTS_SBTS__STATE__Secondary_Controller_SharedRM_LockUnlock.robot
Resource    ../../../test_resources/CBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables



*** Test Cases ***
[1]CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__cm__cbts_cell_power_validation_with_fid_1900_check_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}
    ...    AND    Set Test Variable    ${pMax_value}    46

    ...    AND    CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
    ...    AND    Set Library Search Order    CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
    TC__CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
    [Teardown]    Run Keywords    CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check.TC Teardown
    ...    AND    Restore Resource Search Order



[1]CBTS_SBTS__STATE__Cell_BlockUnblock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__state__cell_blockunblock_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${SBTS_RAT_LIST}    ALL
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

    ...    AND    CBTS_SBTS__STATE__Cell_BlockUnblock.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__STATE__Cell_BlockUnblock
    ...    AND    Set Library Search Order    CBTS_SBTS__STATE__Cell_BlockUnblock
    TC__CBTS_SBTS__STATE__Cell_BlockUnblock
    [Teardown]    Run Keywords    CBTS_SBTS__STATE__Cell_BlockUnblock.TC Teardown
    ...    AND    Restore Resource Search Order



[1]CBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__state__enable_disable_pimc_bypass_mode_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${ALLOWED_RMOD_SN_LIST}    ALL
    ...    AND    Set Test Variable    ${DELTA_POWER_THR}    30

    ...    AND    CBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    ...    AND    Set Library Search Order    CBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    TC__CBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
    [Teardown]    Run Keywords    CBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode.TC Teardown
    ...    AND    Restore Resource Search Order



[1]CBTS_SBTS__STATE__RM_LockUnlock
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
    [Teardown]    Run Keywords    CBTS_SBTS__STATE__RM_LockUnlock.TC Teardown
    ...    AND    Restore Resource Search Order



[1]CBTS_SBTS__STATE__RM_Power_Off_On
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__state__rm_power_off_on_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RMOD_SHARING_INFO}    ALL
    ...    AND    Set Test Variable    ${RMOD_POWER_ON_WRN_THR}    240
    ...    AND    Set Test Variable    ${RMOD_POWER_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RMOD_RESET_TIME_INTERVAL}    480
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Set Test Variable    ${CB005763_CHECK}    False
    ...    AND    Set Test Variable    ${CB005763_EXEMPTED_RMOD_SERIAL_NUMBER_LIST}

    ...    AND    CBTS_SBTS__STATE__RM_Power_Off_On.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__STATE__RM_Power_Off_On
    ...    AND    Set Library Search Order    CBTS_SBTS__STATE__RM_Power_Off_On
    TC__CBTS_SBTS__STATE__RM_Power_Off_On
    [Teardown]    Run Keywords    CBTS_SBTS__STATE__RM_Power_Off_On.TC Teardown
    ...    AND    Restore Resource Search Order



[1]CBTS_SBTS__STATE__Secondary_Controller_SharedRM_LockUnlock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__state__secondary_controller_sharedrm_lockunlock_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${SHARED_RMOD_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RMOD_LOCK_MAX_WAIT_TIME}    300
    ...    AND    Set Test Variable    ${RMOD_UNLOCK_MAX_WAIT_TIME}    300
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True

    ...    AND    CBTS_SBTS__STATE__Secondary_Controller_SharedRM_LockUnlock.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__STATE__Secondary_Controller_SharedRM_LockUnlock
    ...    AND    Set Library Search Order    CBTS_SBTS__STATE__Secondary_Controller_SharedRM_LockUnlock
    TC__CBTS_SBTS__STATE__Secondary_Controller_SharedRM_LockUnlock
    [Teardown]    Run Keywords    CBTS_SBTS__STATE__Secondary_Controller_SharedRM_LockUnlock.TC Teardown
    ...    AND    Restore Resource Search Order



[1]CBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__state__secondary_controller_sharedrm_reset_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${SHARED_RMOD_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RMOD_RESET_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RMOD_RESET_WRN_THR}    180
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN_SBTS}    True
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN_CBTS}    True
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True

    ...    AND    CBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset
    ...    AND    Set Library Search Order    CBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset
    TC__CBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset
    [Teardown]    Run Keywords    CBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset.TC Teardown
    ...    AND    Restore Resource Search Order



[2]CBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__state__secondary_controller_sharedrm_reset_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${SHARED_RMOD_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RMOD_RESET_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RMOD_RESET_WRN_THR}    180
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN_SBTS}    True
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN_CBTS}    True
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True

    ...    AND    CBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset
    ...    AND    Set Library Search Order    CBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset
    TC__CBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset
    [Teardown]    Run Keywords    CBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset.TC Teardown
    ...    AND    Restore Resource Search Order
