*** Settings ***
Documentation  Test Suite
Resource    ../../../test_resources/CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check.robot
Resource    ../../../test_resources/CBTS_SBTS__LOGS__Stability.robot
Resource    ../../../test_resources/CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset.robot
Resource    ../../../test_resources/CBTS_SBTS__STATE__Cell_BlockUnblock.robot
Resource    ../../../test_resources/CBTS_SBTS__STATE__FHGW_Reset.robot
Resource    ../../../test_resources/CBTS_SBTS__STATE__RM_LockUnlock.robot
Resource    ../../../test_resources/CBTS_SBTS__STATE__RM_Reset.robot
Resource    ../../../test_resources/CBTS_SBTS__STATE__RMOD_fan_temp_control_profiles_CB010874.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables



*** Test Cases ***
[1]CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__cm__cbts_cell_power_validation_with_fid_1900_check_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    AH214201661
    ...    AND    Set Test Variable    ${pMax_value}    37

    ...    AND    CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
    ...    AND    Set Library Search Order    CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
    TC__CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
    [Teardown]    Run Keywords    CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check.TC Teardown
    ...    AND    Restore Resource Search Order


[1]CBTS_SBTS__LOGS__Stability
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__logs__stability_alarms_definitions.py
    ...    AND    Set Test Variable    ${STABILITY_PERIOD}    60
    ...    AND    Set Test Variable    ${CHECK_INTERVAL}    10
    ...    AND    Set Test Variable    ${CHECK_SW_VERSION_CBTS}    True
    ...    AND    Set Test Variable    ${CHECK_SW_VERSION_SBTS}    False
    ...    AND    Set Test Variable    ${Target_SW_name_BTS1_CU}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS1_VDU}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS1}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS2_CU}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS2_VDU}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS2}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS3_CU}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS3_VDU}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS3}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS4_CU}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS4_VDU}    Current
    ...    AND    Set Test Variable    ${Target_SW_name_BTS4}    Current

    ...    AND    CBTS_SBTS__LOGS__Stability.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__LOGS__Stability
    ...    AND    Set Library Search Order    CBTS_SBTS__LOGS__Stability
    TC__CBTS_SBTS__LOGS__Stability
    [Teardown]    Run Keywords    CBTS_SBTS__LOGS__Stability.TC Teardown
    ...    AND    Restore Resource Search Order


[1]CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__state__cbts_vdu_reset_sbts_site_reset_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${BTS1_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${BTS2_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${FHGW_CONNECT}    True
    ...    AND    Set Test Variable    ${SWCONFIG_CHANGE_FLAG}    False
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_ACTION}    add
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_LIST}    0x4F0214
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN_SBTS}    True
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN_CBTS}    True

    ...    AND    CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset
    ...    AND    Set Library Search Order    CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset
    TC__CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset
    [Teardown]    Run Keywords    CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]CBTS_SBTS__STATE__Cell_BlockUnblock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__state__cell_blockunblock_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${SBTS_RAT_LIST}    ALL
    ...    AND    Set Test Variable    ${LTE_IOT_check}    False
    ...    AND    Set Test Variable    ${NR_CELL_BLOCK_WRN_THR}    20
    ...    AND    Set Test Variable    ${NR_CELL_UNBLOCK_WRN_THR}    20
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


[1]CBTS_SBTS__STATE__FHGW_Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__state__fhgw_reset_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${FHGW_ID_CUSTOM_LIST}    ALL
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900

    ...    AND    CBTS_SBTS__STATE__FHGW_Reset.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__STATE__FHGW_Reset
    ...    AND    Set Library Search Order    CBTS_SBTS__STATE__FHGW_Reset
    TC__CBTS_SBTS__STATE__FHGW_Reset
    [Teardown]    Run Keywords    CBTS_SBTS__STATE__FHGW_Reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]CBTS_SBTS__STATE__RM_Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__state__rm_reset_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RMOD_SHARING_INFO}    ALL
    ...    AND    Set Test Variable    ${RMOD_RESET_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RMOD_RESET_WRN_THR}    240
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN_SBTS}    True
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN_CBTS}    True
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True

    ...    AND    CBTS_SBTS__STATE__RM_Reset.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__STATE__RM_Reset
    ...    AND    Set Library Search Order    CBTS_SBTS__STATE__RM_Reset
    TC__CBTS_SBTS__STATE__RM_Reset
    [Teardown]    Run Keywords    CBTS_SBTS__STATE__RM_Reset.TC Teardown
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


[1]CBTS_SBTS__STATE__RMOD_fan_temp_control_profiles_CB010874
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__state__rmod_fan_temp_control_profiles_cb010874_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RMOD_CLIMATE_CONTROL_PROFILING_LIST}    ALL
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${CB010874_EXEMPTED_RMOD_SERIAL_NUMBER_LIST}
    ...    AND    Set Test Variable    ${CB010874_SNAPSHOT_REMOVE}    True

    ...    AND    CBTS_SBTS__STATE__RMOD_fan_temp_control_profiles_CB010874.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__STATE__RMOD_fan_temp_control_profiles_CB010874
    ...    AND    Set Library Search Order    CBTS_SBTS__STATE__RMOD_fan_temp_control_profiles_CB010874
    TC__CBTS_SBTS__STATE__RMOD_fan_temp_control_profiles_CB010874
    [Teardown]    Run Keywords    CBTS_SBTS__STATE__RMOD_fan_temp_control_profiles_CB010874.TC Teardown
    ...    AND    Restore Resource Search Order
