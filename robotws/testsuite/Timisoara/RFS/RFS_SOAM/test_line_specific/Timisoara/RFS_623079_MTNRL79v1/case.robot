*** Settings ***
Documentation  Test Suite
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__BTS_BlockUnblock_from_WEBEM.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RAT_Block_Unblock_from_WEBEM.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RM_LockUnlock.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables



*** Test Cases ***
[1]SBTS_SBTS_SBTS_SBTS__STATE__RAT_Block_Unblock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state_rat_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${MAX_WAIT_TIME}    300

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__RAT_Block_Unblock_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RAT_Block_Unblock_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RAT_Block_Unblock_from_WEBEM
    TC__SBTS_SBTS_SBTS_SBTS__STATE__RAT_Block_Unblock_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__RAT_Block_Unblock_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order



[1]SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts1_bts2_rat_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    BTS1,BTS2
    ...    AND    Set Test Variable    ${NR_RESET_WRN_THR}    300
    ...    AND    Set Test Variable    ${LTE_RESET_WRN_THR}    120
    ...    AND    Set Test Variable    ${WCDMA_RESET_WRN_THR}    120
    ...    AND    Set Test Variable    ${GSM_RESET_WRN_THR}    120
    ...    AND    Set Test Variable    ${MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RAT_TECH}    ALL
    ...    AND    Set Test Variable    ${RESET_TYPE}    Soft
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True

    ...    AND    SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM
    TC__SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order



[1]SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__rm_power_off_on_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RMOD_SHARING_INFO}    ALL
    ...    AND    Set Test Variable    ${RMOD_POWER_ON_WRN_THR}    240
    ...    AND    Set Test Variable    ${RMOD_POWER_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RMOD_RESET_TIME_INTERVAL}    480
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Set Test Variable    ${CB005763_CHECK}    False
    ...    AND    Set Test Variable    ${CB005763_EXEMPTED_RMOD_SERIAL_NUMBER_LIST}

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On
    TC__SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On.TC Teardown
    ...    AND    Restore Resource Search Order



[1]SBTS_SBTS_SBTS_SBTS__STATE__RM_LockUnlock
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



[2]SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__rm_power_off_on_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RMOD_SHARING_INFO}    ALL
    ...    AND    Set Test Variable    ${RMOD_POWER_ON_WRN_THR}    240
    ...    AND    Set Test Variable    ${RMOD_POWER_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RMOD_RESET_TIME_INTERVAL}    480
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Set Test Variable    ${CB005763_CHECK}    False
    ...    AND    Set Test Variable    ${CB005763_EXEMPTED_RMOD_SERIAL_NUMBER_LIST}

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On
    TC__SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On.TC Teardown
    ...    AND    Restore Resource Search Order



[1]SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__rm_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RM_CONFIGURED_INFO}    ALL
    ...    AND    Set Test Variable    ${RM_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RM_RESET_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RM_RESET_TIME_INTERVAL}    480
    ...    AND    Set Test Variable    ${RM_RESET_WRN_THR}    180
    ...    AND    Set Test Variable    ${CNI_103974}    True
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    TC__SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.TC Teardown
    ...    AND    Restore Resource Search Order



[1]SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__cell_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    BTS1,BTS2
    ...    AND    Set Test Variable    ${RAT_LIST}    ALL
    ...    AND    Set Test Variable    ${LTE_IOT_SA_action}    True
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Set Test Variable    ${NR_CELL_BLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${NR_CELL_UNBLOCK_WRN_THR}    20
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



[1]SBTS_SBTS_SBTS_SBTS__STATE__BTS_BlockUnblock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__bts_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    BTS1,BTS2
    ...    AND    Set Test Variable    ${BTS1_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${BTS2_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${BTS3_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${BTS4_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__BTS_BlockUnblock_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__BTS_BlockUnblock_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__BTS_BlockUnblock_from_WEBEM
    TC__SBTS_SBTS_SBTS_SBTS__STATE__BTS_BlockUnblock_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__BTS_BlockUnblock_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order
