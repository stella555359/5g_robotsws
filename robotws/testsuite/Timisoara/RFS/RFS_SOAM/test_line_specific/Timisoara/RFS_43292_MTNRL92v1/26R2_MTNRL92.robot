*** Settings ***
Documentation  Test Suite
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    CLOUD_HRAN_RFS_AIL_MTNRL92    SBTS26R2    STATE_SKIP_AGENT    CRT
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RM_LockUnlock.robot
Resource    ../../../test_resources/SBTS__STATE__RAT_Reset_from_WEBEM.robot
Resource    ../../../test_resources/SBTS__STATE__RM_Reset_from_WEBEM.robot
Resource    ../../../test_resources/SBTS__STATE__RM_Power_Off_On.robot
Resource    ../../../test_resources/SBTS__STATE__Site_Block_Unblock_from_WEBEM.robot
Resource    ../../../test_resources/RRM__RFS__Data_Transfer_Taf_Ue.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__LOGS__SBTS_snapshot_from_WEBEM.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__CM__Planned_Recommissioning_template.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables



*** Test Cases ***
[1]SBTS__STATE__Site_Block_Unblock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts__state__site_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${SBTS_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${SBTS_MAX_WAIT_TIME}    900

    ...    AND    SBTS__STATE__Site_Block_Unblock_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS__STATE__Site_Block_Unblock_from_WEBEM
    ...    AND    Set Library Search Order    SBTS__STATE__Site_Block_Unblock_from_WEBEM
    TC__SBTS__STATE__Site_Block_Unblock_from_WEBEM
    [Teardown]    Run Keywords    SBTS__STATE__Site_Block_Unblock_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[1]SBTS__STATE__RM_Power_Off_On
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts__state__rm_power_off_on_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
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


[1][1.0] Automated_RFSplit_SBTS__STATE__RM_Reset_from_WEBEM
    [Timeout]    43600
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts__state__rm_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    10
    ...    AND    Set Test Variable    ${HW_RESET_TIME_INTERVAL}    480
    ...    AND    Set Test Variable    ${HW_RESET_WRN_THR}    288
    ...    AND    Set Test Variable    ${HW_RESET_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True

    ...    AND    SBTS__STATE__RM_Reset_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS__STATE__RM_Reset_from_WEBEM
    ...    AND    Set Library Search Order    SBTS__STATE__RM_Reset_from_WEBEM
    TC__SBTS__STATE__RM_Reset_from_WEBEM
    [Teardown]    Run Keywords    SBTS__STATE__RM_Reset_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order



[1][1.0] Automated_RFSplit_SBTS__STATE__RAT_Reset_from_WEBEM_Hard
    [Timeout]    43600
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts__state__rat_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    10
    ...    AND    Set Test Variable    ${RAT_TECH}    all
    ...    AND    Set Test Variable    ${NR_RESET_WRN_THR}    270
    ...    AND    Set Test Variable    ${LTE_RESET_WRN_THR}    270
    ...    AND    Set Test Variable    ${WCDMA_RESET_WRN_THR}    120
    ...    AND    Set Test Variable    ${GSM_RESET_WRN_THR}    120
    ...    AND    Set Test Variable    ${MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RESET_TYPE}    Hard
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

[1][1.0] Automated_RFS_SBTS_SBTS__LOGS__SBTS_snapshot_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__logs__sbts_snapshot_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${SNAPSHOT_BTS}    ALL
    ...    AND    Set Test Variable    ${SNAPSHOT_DIR_PATH}
    ...    AND    Set Test Variable    ${DELAY_BETWEEN_SNAPSHOTS}    30
    ...    AND    Set Test Variable    ${RMOD_SN_list}
    ...    AND    SBTS_SBTS_SBTS_SBTS__LOGS__SBTS_snapshot_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__LOGS__SBTS_snapshot_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__LOGS__SBTS_snapshot_from_WEBEM
    TC__SBTS_SBTS_SBTS_SBTS__LOGS__SBTS_snapshot_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__LOGS__SBTS_snapshot_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[1][1.0] Automated_L3_call_with_UL_DL_Throughput
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    LTE
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    300 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    200 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    600 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_2
    ...    AND    Set Test Variable    ${MBN_PROFILE}    None
    ...    AND    Set Test Variable    ${DETACH_UE}    False
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    False
    ...    AND    Set Test Variable    ${IMPORT_CELL_TARGET_BW_FROM_CONFIG}    False
    ...    AND    RRM__RFS__Data_Transfer_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    TC__RRM__RFS__Data_Transfer_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Data_Transfer_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order


[2]RRM__RFS__Data_Transfer_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    GSM
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    150 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    200 kbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_3
    ...    AND    Set Test Variable    ${MBN_PROFILE}    None
    ...    AND    Set Test Variable    ${DETACH_UE}    False
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    False
    ...    AND    Set Test Variable    ${IMPORT_CELL_TARGET_BW_FROM_CONFIG}    False
    ...    AND    RRM__RFS__Data_Transfer_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    TC__RRM__RFS__Data_Transfer_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Data_Transfer_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order


[3]RRM__RFS__Data_Transfer_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    NR
    ...    AND    Set Test Variable    ${BTS_CALL}    BTS1
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    350 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    200 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    300 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_1
    ...    AND    Set Test Variable    ${MBN_PROFILE}    None
    ...    AND    Set Test Variable    ${DETACH_UE}    False
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    False
    ...    AND    Set Test Variable    ${IMPORT_CELL_TARGET_BW_FROM_CONFIG}    False
    ...    AND    RRM__RFS__Data_Transfer_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    TC__RRM__RFS__Data_Transfer_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Data_Transfer_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order

[1][3.0] Automated_RFS_SBTS-SBTS_BTS1_BTS2_Cell_BlockUnblock from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__cell_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${RAT_LIST}    GSM
    ...    AND    Set Test Variable    ${LTE_IOT_SA_action}    False
    ...    AND    Set Test Variable    ${LTE_IOT_check}    False
    ...    AND    Set Test Variable    ${NR_CELL_BLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${NR_CELL_UNBLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${LTE_CELL_BLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${LTE_CELL_UNBLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${WCDMA_CELL_BLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${WCDMA_CELL_UNBLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${GSM_CELL_BLOCK_WRN_THR}    130
    ...    AND    Set Test Variable    ${GSM_CELL_UNBLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${CELL_BLOCK_MAX_WAIT_TIME}    200
    ...    AND    Set Test Variable    ${CELL_UNBLOCK_MAX_WAIT_TIME}    20
    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order

[1][2.0] Automated_RFSplit_SBTS__CM__Planned_Recommissioning_template
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__cm__planned_recommissioning_template_alarms_definitions.py
    ...    AND    Set Test Variable    ${RECOMMISSIONING_BTS1}    /home/ute/testline_configuration/10_18_UTESRANRFSMTNRL92/OUT_OF_RANGE2.xml
    ...    AND    Set Test Variable    ${RECOMMISSIONING_BTS2}    NONE
    ...    AND    Set Test Variable    ${RECOMMISSIONING_BTS3}    NONE
    ...    AND    Set Test Variable    ${RECOMMISSIONING_BTS4}    NONE
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    1
    ...    AND    Set Test Variable    ${RESET_CONFIGURATION}    False
    ...    AND    Set Test Variable    ${BTS_SCF_VALIDATION}    False
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RECOVER_INITIAL_SCF}    True
    ...    AND    SBTS_SBTS_SBTS_SBTS__CM__Planned_Recommissioning_template.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__CM__Planned_Recommissioning_template
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__CM__Planned_Recommissioning_template
    TC__SBTS_SBTS_SBTS_SBTS__CM__Planned_Recommissioning_template
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__CM__Planned_Recommissioning_template.TC Teardown
    ...    AND    Restore Resource Search Order

