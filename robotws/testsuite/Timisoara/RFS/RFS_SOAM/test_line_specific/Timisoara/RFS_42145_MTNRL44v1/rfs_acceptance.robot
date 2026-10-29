*** Settings ***
Documentation  Test Suite
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RM_LockUnlock.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM.robot
Resource    ../../../test_resources/SBTS__CM__Planned_Recommissioning_template.robot
Resource    ../../../test_resources/SBTS__CM__Re-Commissioning_of_parameter_implying_reset.robot
Resource    ../../../test_resources/SBTS__CM__Re-Commissioning_of_parameter_not_implying_reset.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Lock_Unlock_from_WebEm.robot
Resource    ../../../test_resources/SBTS__STATE__RAT_Block_Unblock_from_WEBEM.robot
Resource    ../../../test_resources/SBTS__STATE__RAT_Reset_from_WEBEM.robot
Resource    ../../../test_resources/SBTS__STATE__RM_Power_Off_On.robot
Resource    ../../../test_resources/SBTS__STATE__RM_Reset_from_WEBEM.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__BTS_Power_Off_On.robot
Resource    ../../../test_resources/SBTS__STATE__Site_Block_Unblock_from_WEBEM.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
${POWER_ON_FLAG}    ${True}
${CNI_127210_ENABLED}    ${True}



*** Test Cases ***
[1]SBTS__STATE__BBMOD_LockUnlock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts1_bts2_bbmod_lock_unlock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    2
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${BBMOD_SN_LIST}

    ...    AND    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Lock_Unlock_from_WebEm.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Lock_Unlock_from_WebEm
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Lock_Unlock_from_WebEm
    TC__SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Lock_Unlock_from_WebEm
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Lock_Unlock_from_WebEm.TC Teardown
    ...    AND    Restore Resource Search Order


[1]SBTS__STATE__BBMOD_Reset_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts1_bts2_bbmod_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    2
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${BBMOD_RESET_WRN_THR}    270
    ...    AND    Set Test Variable    ${BBMOD_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RESET_BBMOD_TYPE_LIST}    ABIO
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK}
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    720
    ...    AND    Set Test Variable    ${HISTORICAL_ALARMS_CHECK}    True

    ...    AND    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    TC__SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM.TC Teardown
    ...    AND    Restore Resource Search Order


[1]SBTS__STATE__Cell_BlockUnblock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__cell_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    2
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
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    2
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
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    2
    ...    AND    Set Test Variable    ${RAT_TECH}    all
    ...    AND    Set Test Variable    ${NR_RESET_WRN_THR}    350
    ...    AND    Set Test Variable    ${LTE_RESET_WRN_THR}    130
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
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    2
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


[1]SBTS__STATE__RM_Power_Off_On
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts__state__rm_power_off_on_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    2
    ...    AND    Set Test Variable    ${OPERATION_ORDER}    ONE_BY_ONE
    ...    AND    Set Test Variable    ${HW_RESET_TIME_INTERVAL}    480
    ...    AND    Set Test Variable    ${HW_POWER_ON_WRN_THR}    240
    ...    AND    Set Test Variable    ${HW_POWER_MAX_WAIT_TIME}    900

    ...    AND    SBTS__STATE__RM_Power_Off_On.TC Setup
    ...    AND    Modify Resource Search Order    SBTS__STATE__RM_Power_Off_On
    ...    AND    Set Library Search Order    SBTS__STATE__RM_Power_Off_On
    TC__SBTS__STATE__RM_Power_Off_On
    [Teardown]    Run Keywords    SBTS__STATE__RM_Power_Off_On.TC Teardown
    ...    AND    Restore Resource Search Order


[1]SBTS__STATE__RM_Reset_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts__state__rm_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    2
    ...    AND    Set Test Variable    ${HW_RESET_TIME_INTERVAL}    480
    ...    AND    Set Test Variable    ${HW_RESET_WRN_THR}    260
    ...    AND    Set Test Variable    ${HW_RESET_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True

    ...    AND    SBTS__STATE__RM_Reset_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS__STATE__RM_Reset_from_WEBEM
    ...    AND    Set Library Search Order    SBTS__STATE__RM_Reset_from_WEBEM
    TC__SBTS__STATE__RM_Reset_from_WEBEM
    [Teardown]    Run Keywords    SBTS__STATE__RM_Reset_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[1]SBTS__STATE__SBTS_Power_Off_On
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts_power_off_on_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    2
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK_LIST}
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    720
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_PROCEDURE}    LANE
    ...    AND    Set Test Variable    ${BTS_POWER_ON_WRN_THR_LIST}    600
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${SWCONFIG_CHANGE_FLAG}    False
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_ACTION}    add
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_LIST}    0x4F0214

    ...    AND    SBTS_SBTS__STATE__BTS_Power_Off_On.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BTS_Power_Off_On
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BTS_Power_Off_On
    TC__SBTS_SBTS__STATE__BTS_Power_Off_On
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BTS_Power_Off_On.TC Teardown
    ...    AND    Restore Resource Search Order


[1]SBTS__STATE__Site_Block_Unblock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts__state__site_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    2
    ...    AND    Set Test Variable    ${SBTS_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${SBTS_MAX_WAIT_TIME}    900

    ...    AND    SBTS__STATE__Site_Block_Unblock_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS__STATE__Site_Block_Unblock_from_WEBEM
    ...    AND    Set Library Search Order    SBTS__STATE__Site_Block_Unblock_from_WEBEM
    TC__SBTS__STATE__Site_Block_Unblock_from_WEBEM
    [Teardown]    Run Keywords    SBTS__STATE__Site_Block_Unblock_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[1]SBTS__STATE__Site_Reset_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__site_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    2
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${BTS1_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${BTS2_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${BTS3_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${BTS4_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${CB007447_SHARED_RM_SN_EXCEPTIONS_LIST}
    ...    AND    Set Test Variable    ${SWCONFIG_CHANGE_FLAG}    False
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_ACTION}    add
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_LIST}    0x4F0214
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK_LIST}
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}       720
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_PROCEDURE}  LANE
    ...    AND    Set Test Variable    ${ASOx_counters_flag}    False
    ...    AND    Set Test Variable    ${PM_Counters_Check}    False
    ...    AND    Set Test Variable    ${cpriSyncBreakTime}    500
    ...    AND    Set Test Variable    ${stickToSyncSourcePeriod}    400
    ...    AND    Set Test Variable    ${DELAY_BETWEEN_SNAPSHOTS}   30

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[1]SBTS__CM__Re-Commissioning_of_parameter_implying_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts__cm__re-commissioning_of_parameter_implying_reset_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    2
    ...    AND    Set Test Variable    ${BTS_TIMEZONE_LIST}    (GMT+8) Asia/Hong_Kong, (GMT-11) US/Samoa, (GMT-5) Brazil/Acre
    ...    AND    Set Test Variable    ${BTS_SCF_VALIDATION}    True

    ...    AND    SBTS__CM__Re-Commissioning_of_parameter_implying_reset.TC Setup
    ...    AND    Modify Resource Search Order    SBTS__CM__Re-Commissioning_of_parameter_implying_reset
    ...    AND    Set Library Search Order    SBTS__CM__Re-Commissioning_of_parameter_implying_reset
    TC__SBTS__CM__Re-Commissioning_of_parameter_implying_reset
    [Teardown]    Run Keywords    SBTS__CM__Re-Commissioning_of_parameter_implying_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]SBTS__CM__Re-Commissioning_of_parameter_not_implying_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts__cm__re-commissioning_of_parameter_not_implying_reset_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    2
    ...    AND    Set Test Variable    ${BTS_NAME_LIST}    BTS_NAME_AUTO1, BTS_NAME_AUTO2
    ...    AND    Set Test Variable    ${BTS_SCF_VALIDATION}    True

    ...    AND    SBTS__CM__Re-Commissioning_of_parameter_not_implying_reset.TC Setup
    ...    AND    Modify Resource Search Order    SBTS__CM__Re-Commissioning_of_parameter_not_implying_reset
    ...    AND    Set Library Search Order    SBTS__CM__Re-Commissioning_of_parameter_not_implying_reset
    TC__SBTS__CM__Re-Commissioning_of_parameter_not_implying_reset
    [Teardown]    Run Keywords    SBTS__CM__Re-Commissioning_of_parameter_not_implying_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]SBTS__CM__Planned_Recommissioning_template
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts__cm__planned_recommissioning_template_alarm_definitions.py
    ...    AND    Set Test Variable    ${RECOMMISSIONING_SBTS}    NONE
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    2
    ...    AND    Set Test Variable    ${SBTS_SCF_VALIDATION}    True
    ...    AND    Set Test Variable    ${SBTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${SBTS_RESET_WRN_THR}    504
    ...    AND    Set Test Variable    ${VERDICT_WRONG_SBTS_RESET_NUMBER}    PASS
    ...    AND    Set Test Variable    ${RESET_CONFIGURATION}    False

    ...    AND    SBTS__CM__Planned_Recommissioning_template.TC Setup
    ...    AND    Modify Resource Search Order    SBTS__CM__Planned_Recommissioning_template
    ...    AND    Set Library Search Order    SBTS__CM__Planned_Recommissioning_template
    TC__SBTS__CM__Planned_Recommissioning_template
    [Teardown]    Run Keywords    SBTS__CM__Planned_Recommissioning_template.TC Teardown
    ...    AND    Restore Resource Search Order
