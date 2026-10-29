*** Settings ***
Documentation
...   author: Cristian Croitoru
...   maintainer: cristian.croitoru@nokia.com

Resource    ../../../test_resources/CBTS_SBTS__STATE__Cell_BlockUnblock.robot
Resource    ../../../test_resources/CBTS_SBTS__STATE__RM_LockUnlock.robot
Resource    ../../../test_resources/CBTS_SBTS__STATE__RM_Reset.robot
Resource    ../../../test_resources/CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset.robot
Resource    ../../../test_resources/CBTS_SBTS__STATE__FHGW_Reset.robot
Resource    ../../../test_resources/CBTS_SBTS__STATE__FHGW_RINLINE_Link_Break.robot
Resource    ../../../test_resources/CBTS_SBTS__STATE__Check_TRM_feature_with_FHGW_config.robot
Resource    ../../../test_resources/CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check.robot

*** Variables ***
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables

*** Test Cases ***
[1]CBTS_SBTS__STATE__Cell_BlockUnblock
    [Timeout]    6h
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__state__cell_blockunblock_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${SBTS_RAT_LIST}    ALL
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Set Test Variable    ${NR_CELL_BLOCK_WRN_THR}    35
    ...    AND    Set Test Variable    ${NR_CELL_UNBLOCK_WRN_THR}    35
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

[1]CBTS_SBTS__STATE__RM_LockUnlock
    [Timeout]    18000
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__state__rm_lockunlock_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RMOD_SHARING_INFO}    ALL
    ...    AND    Set Test Variable    ${RMOD_LOCK_MAX_WAIT_TIME}    300
    ...    AND    Set Test Variable    ${RMOD_UNLOCK_MAX_WAIT_TIME}    300

    ...    AND    CBTS_SBTS__STATE__RM_LockUnlock.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__STATE__RM_LockUnlock
    ...    AND    Set Library Search Order    CBTS_SBTS__STATE__RM_LockUnlock
    TC__CBTS_SBTS__STATE__RM_LockUnlock
    [Teardown]    Run Keywords    CBTS_SBTS__STATE__RM_LockUnlock.TC Teardown
    ...    AND    Restore Resource Search Order

[1]CBTS_SBTS__STATE__RM_Reset
    [Timeout]    18000
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__state__rm_reset_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RMOD_SHARING_INFO}    ALL
    ...    AND    Set Test Variable    ${RMOD_RESET_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RMOD_RESET_WRN_THR}    600

    ...    AND    CBTS_SBTS__STATE__RM_Reset.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__STATE__RM_Reset
    ...    AND    Set Library Search Order    CBTS_SBTS__STATE__RM_Reset
    TC__CBTS_SBTS__STATE__RM_Reset
    [Teardown]    Run Keywords    CBTS_SBTS__STATE__RM_Reset.TC Teardown
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

    ...    AND    CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset
    ...    AND    Set Library Search Order    CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset
    TC__CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset
    [Teardown]    Run Keywords    CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset.TC Teardown
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

[1]CBTS_SBTS__STATE__FHGW_RINLINE_Link_Break
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__state__fhgw_rinline_link_break_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${SWITCH_USER_LINK_DOWN}    cmntrl144-down-C4
    ...    AND    Set Test Variable    ${SWITCH_PASSWORD_LINK_DOWN}    Aikon_144-down
    ...    AND    Set Test Variable    ${SWITCH_USER_LINK_UP}    cmntrl144-up-C4
    ...    AND    Set Test Variable    ${SWITCH_PASSWORD_LINK_UP}    Aikon_144-up
    ...    AND    Set Test Variable    ${SWITCH_IP_ADDRESS}    10.255.11.5
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    240

    ...    AND    CBTS_SBTS__STATE__FHGW_RINLINE_Link_Break.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__STATE__FHGW_RINLINE_Link_Break
    ...    AND    Set Library Search Order    CBTS_SBTS__STATE__FHGW_RINLINE_Link_Break
    TC__CBTS_SBTS__STATE__FHGW_RINLINE_Link_Break
    [Teardown]    Run Keywords    CBTS_SBTS__STATE__FHGW_RINLINE_Link_Break.TC Teardown
    ...    AND    Restore Resource Search Order

[1]CBTS_SBTS__STATE__Check_TRM_feature_with_FHGW_config
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__state__check_trm_feature_with_fhgw_config_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${tempRadioMasterTriggerTime}    2
    ...    AND    Set Test Variable    ${tempRadioMasterRecovTime}    0
    ...    AND    Set Test Variable    ${FHGW_BMC_IP}    10.5.46.48
    ...    AND    Set Test Variable    ${FHGW_BMC_PORT}    443
    ...    AND    Set Test Variable    ${FHGW_BMC_USERNAME}    bmc_user
    ...    AND    Set Test Variable    ${FHGW_BMC_PASSWORD}    Aikon_1234
    ...    AND    Set Test Variable    ${FHGW_BMC_INTERFACE}    redfish_oe_19

    ...    AND    CBTS_SBTS__STATE__Check_TRM_feature_with_FHGW_config.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__STATE__Check_TRM_feature_with_FHGW_config
    ...    AND    Set Library Search Order    CBTS_SBTS__STATE__Check_TRM_feature_with_FHGW_config
    TC__CBTS_SBTS__STATE__Check_TRM_feature_with_FHGW_config
    [Teardown]    Run Keywords    CBTS_SBTS__STATE__Check_TRM_feature_with_FHGW_config.TC Teardown

[1]CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__cm__cbts_cell_power_validation_with_fid_1900_check_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    YK214600105
    ...    AND    Set Test Variable    ${pMax_value}    46

    ...    AND    CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
    ...    AND    Set Library Search Order    CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
    TC__CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
    [Teardown]    Run Keywords    CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check.TC Teardown
    ...    AND    Restore Resource Search Order

[2]CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__cm__cbts_cell_power_validation_with_fid_1900_check_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    BL2221N405R
    ...    AND    Set Test Variable    ${pMax_value}    46

    ...    AND    CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
    ...    AND    Set Library Search Order    CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
    TC__CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
    [Teardown]    Run Keywords    CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check.TC Teardown
    ...    AND    Restore Resource Search Order

[3]CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__cm__cbts_cell_power_validation_with_fid_1900_check_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    BL2214N400R
    ...    AND    Set Test Variable    ${pMax_value}    46

    ...    AND    CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
    ...    AND    Set Library Search Order    CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
    TC__CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
    [Teardown]    Run Keywords    CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check.TC Teardown
    ...    AND    Restore Resource Search Order

[4]CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__cm__cbts_cell_power_validation_with_fid_1900_check_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    BL2330H60AJ
    ...    AND    Set Test Variable    ${pMax_value}    46

    ...    AND    CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
    ...    AND    Set Library Search Order    CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
    TC__CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
    [Teardown]    Run Keywords    CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check.TC Teardown
    ...    AND    Restore Resource Search Order
