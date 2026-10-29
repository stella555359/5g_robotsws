*** Settings ***
Force tags    QCD_MN_RAN    QCP_RAN_VRF    25R3    CLOUD_10_18_UTESRANRFCMTNRL147

Documentation
...   contact: VRF_SISO
...   maintainer: Raluca Butcovan
Resource    ../../../test_resources/CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset.robot
Resource    ../../../test_resources/CBTS_SBTS__STATE__Cell_BlockUnblock.robot
Resource    ../../../test_resources/CBTS_SBTS__STATE__RM_LockUnlock.robot
Resource    ../../../test_resources/CBTS_SBTS__STATE__RM_Reset.robot
Resource    ../../../test_resources/RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.robot
Resource    ../../../test_resources/CBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode.robot
Resource    ../../../test_resources/CBTS_SBTS__STATE__RM_Power_Off_On.robot
Resource    ../../../test_resources/CBTS_SBTS__STATE__Secondary_Controller_SharedRM_LockUnlock.robot
Resource    ../../../test_resources/CBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
${POWER_ON_FLAG}    ${True}
${RP_CA}    VRF_SiSo
${RP_LOCATION}    VRF_TSR2
${RP_ORGANIZATION}    VRF_TSR2_T02
${SCOUT_TL_NAME}    10_18_UTESRANRFSCMTNRL147
${USB_Byte_Protocol}  ${True}



*** Test Cases ***
[1][1.0] Automated_L3_call_with_UL_DL_Throughput
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.py
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESSES}    None
    ...    AND    Set Test Variable    ${UEs_CAPABILITIES}    BTS1_NR BTS2_LTE
    ...    AND    Set Test Variable    ${UEs_BTS_CALL}    BTS1 BTS2
    ...    AND    Set Test Variable    ${UEs_TECHNOS}    NR LTE
    ...    AND    Set Test Variable    ${CELLS}    DEFAULT;DEFAULT
    ...    AND    Set Test Variable    ${CALL_DIRECTIONS_UEs}    downlink downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    10
    ...    AND    Set Test Variable    ${PROTOCOLS}    udp udp
    ...    AND    Set Test Variable    ${DETACH_UEs}    False
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    False
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${SKIP_FAILING_UE}    False
    ...    AND    Set Test Variable    ${DELAY_BETWEEN_SNAPSHOTS}    30
    ...    AND    Set Test Variable    ${THPUT_CHECK_BTS_LOGS}    False
    ...    AND    Set Test Variable    ${UL_UE_GROUP_UEs}    0 0 0 0
    ...    AND    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    TC__RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order

[1][1.0] Automated_CBTS_SBTS__STATE__RM_Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__state__rm_reset_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RMOD_SHARING_INFO}    ALL
    ...    AND    Set Test Variable    ${RMOD_RESET_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RMOD_RESET_WRN_THR}    240

    ...    AND    CBTS_SBTS__STATE__RM_Reset.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__STATE__RM_Reset
    ...    AND    Set Library Search Order    CBTS_SBTS__STATE__RM_Reset
    TC__CBTS_SBTS__STATE__RM_Reset
    [Teardown]    Run Keywords    CBTS_SBTS__STATE__RM_Reset.TC Teardown
    ...    AND    Restore Resource Search Order

[1][1.0] CB012220_RFS_vRAN-SRAN_RU_lock_unlock_and_reset_from_secondary_controller_with_CB007878_activated
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
    ...    AND    Set Test Variable    ${RMOD_RESET_WRN_THR}    230
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN_SBTS}    True
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN_CBTS}    True
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True

    ...    AND    CBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset
    ...    AND    Set Library Search Order    CBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset
    TC__CBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset
    [Teardown]    Run Keywords    CBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset.TC Teardown
    ...    AND    Restore Resource Search Order

[1][2.0] Automated_CBTS_SBTS__STATE__Cell_BlockUnblock
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__state__cell_blockunblock_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${SBTS_RAT_LIST}    ALL
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Set Test Variable    ${NR_CELL_BLOCK_WRN_THR}    20
    ...    AND    Set Test Variable    ${NR_CELL_UNBLOCK_WRN_THR}    20
    ...    AND    Set Test Variable    ${LTE_CELL_BLOCK_WRN_THR}    20
    ...    AND    Set Test Variable    ${LTE_CELL_UNBLOCK_WRN_THR}    20
    ...    AND    Set Test Variable    ${WCDMA_CELL_BLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${WCDMA_CELL_UNBLOCK_WRN_THR}    30
    ...    AND    Set Test Variable    ${GSM_CELL_BLOCK_WRN_THR}    130
    ...    AND    Set Test Variable    ${GSM_CELL_UNBLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${CELL_BLOCK_MAX_WAIT_TIME}    300
    ...    AND    Set Test Variable    ${CELL_UNBLOCK_MAX_WAIT_TIME}    300

    ...    AND    CBTS_SBTS__STATE__Cell_BlockUnblock.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__STATE__Cell_BlockUnblock
    ...    AND    Set Library Search Order    CBTS_SBTS__STATE__Cell_BlockUnblock
    TC__CBTS_SBTS__STATE__Cell_BlockUnblock
    [Teardown]    Run Keywords    CBTS_SBTS__STATE__Cell_BlockUnblock.TC Teardown
    ...    AND    Restore Resource Search Order

[1][1.0] Automated_CBTS_SBTS__STATE__RM_LockUnlock
    [Timeout]    14400
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

[1][1.0] Automated_CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__state__cbts_vdu_reset_sbts_site_reset_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${BTS1_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${BTS2_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${FHGW_CONNECT}    False
    ...    AND    Set Test Variable    ${SWCONFIG_CHANGE_FLAG}    False
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_ACTION}    add
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_LIST}    0x4F0214

    ...    AND    CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset
    ...    AND    Set Library Search Order    CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset
    TC__CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset
    [Teardown]    Run Keywords    CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated_RFS_CBTS_SBTS__STATE__Enable_Disable_PIMC_Bypass_Mode
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

[1]CB005763_RFSplit_Dying_gasp_alarm_check_after_RM_Power_Off_On
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
    ...    AND    Set Test Variable    ${CB005763_CHECK}    True
    ...    AND    Set Test Variable    ${CB005763_EXEMPTED_RMOD_SERIAL_NUMBER_LIST}

    ...    AND    CBTS_SBTS__STATE__RM_Power_Off_On.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__STATE__RM_Power_Off_On
    ...    AND    Set Library Search Order    CBTS_SBTS__STATE__RM_Power_Off_On
    TC__CBTS_SBTS__STATE__RM_Power_Off_On
    [Teardown]    Run Keywords    CBTS_SBTS__STATE__RM_Power_Off_On.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated_CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/cbts_sbts__state__cbts_vdu_reset_sbts_site_reset_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${BTS1_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${BTS2_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${FHGW_CONNECT}    False
    ...    AND    Set Test Variable    ${SWCONFIG_CHANGE_FLAG}    False
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_ACTION}    add
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_LIST}    0x4F0214

    ...    AND    CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset.TC Setup
    ...    AND    Modify Resource Search Order    CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset
    ...    AND    Set Library Search Order    CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset
    TC__CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset
    [Teardown]    Run Keywords    CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset.TC Teardown
    ...    AND    Restore Resource Search Order