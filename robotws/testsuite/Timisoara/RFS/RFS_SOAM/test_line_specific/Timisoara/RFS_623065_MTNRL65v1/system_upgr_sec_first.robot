*** Settings ***
Documentation  Test Suite
Resource    ../../../test_resources/RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__SWM__SW_Update_CNI_103974.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables



*** Test Cases ***
[1]RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.py
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESSES}    None
    ...    AND    Set Test Variable    ${UEs_CAPABILITIES}    LTE2 NR1
    ...    AND    Set Test Variable    ${UEs_BTS_CALL}    BTS2 BTS1
    ...    AND    Set Test Variable    ${UEs_TECHNOS}    LTE NR
    ...    AND    Set Test Variable    ${CELLS}    159248643;10208296964
    ...    AND    Set Test Variable    ${CALL_DIRECTIONS_UEs}    uplink_downlink uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${PROTOCOLS}    udp udp
    ...    AND    Set Test Variable    ${DETACH_UEs}    False
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    False
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    YES
    ...    AND    Set Test Variable    ${SKIP_FAILING_UE}    False
    ...    AND    Set Test Variable    ${DELAY_BETWEEN_SNAPSHOTS}    30
    ...    AND    Set Test Variable    ${THPUT_CHECK_BTS_LOGS}    False
    ...    AND    Set Test Variable    ${UL_UE_GROUP_UEs}    0 0

    ...    AND    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    TC__RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order



[1]SBTS_SBTS__SWM__SW_Update_CNI_103974
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__swm__sw_update_cni_103974_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS SW Update}    BTS2
    ...    AND    Set Test Variable    ${Target SW name BTS1}    None
    ...    AND    Set Test Variable    ${Target SW dir BTS1}    /home/ute/btsauto/TARGET_SW_MASTER
    ...    AND    Set Test Variable    ${Target SW name BTS2}    None
    ...    AND    Set Test Variable    ${Target SW dir BTS2}    /home/ute/btsauto/TARGET_SW_SLAVE
    ...    AND    Set Test Variable    ${Target SW name BTS3}    None
    ...    AND    Set Test Variable    ${Target SW dir BTS3}    None
    ...    AND    Set Test Variable    ${Target SW name BTS4}    None
    ...    AND    Set Test Variable    ${Target SW dir BTS4}    None
    ...    AND    Set Test Variable    ${Activate SW}    True
    ...    AND    Set Test Variable    ${SW Update Timeout}    3000
    ...    AND    Set Test Variable    ${BTS_RESET_WRN_THR}    606
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${BTS_SCF_VALIDATION}    True
    ...    AND    Set Test Variable    ${FORCE_TARGET_BTS_SW_DL}    True
    ...    AND    Set Test Variable    ${WFT_BTS1_target_sw}
    ...    AND    Set Test Variable    ${WFT_BTS2_target_sw}
    ...    AND    Set Test Variable    ${WFT_BTS3_target_sw}
    ...    AND    Set Test Variable    ${WFT_BTS4_target_sw}
    ...    AND    Set Test Variable    ${RFS_CUSTOM_SHARE_SW_DL}    False
    ...    AND    Set Test Variable    ${Remote target SW path BTS1}    None
    ...    AND    Set Test Variable    ${Remote target SW path BTS2}    None
    ...    AND    Set Test Variable    ${Remote target SW path BTS3}    None
    ...    AND    Set Test Variable    ${Remote target SW path BTS4}    None
    ...    AND    Set Test Variable    ${TWO_STEP_DOWNLOAD_ACTIVATE}    False
    ...    AND    Set Test Variable    ${SYNCHRONIZE_ACTIVE_PASSIVE_SW_VERSION}    False
    ...    AND    Set Test Variable    ${HISTORICAL_ALARMS_CHECK}    True
    ...    AND    Set Test Variable    ${SNAPSHOT_CHECK}    True

    ...    AND    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update_CNI_103974.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update_CNI_103974
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update_CNI_103974
    TC__SBTS_SBTS_SBTS_SBTS__SWM__SW_Update_CNI_103974
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update_CNI_103974.TC Teardown
    ...    AND    Restore Resource Search Order



[2]RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.py
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESSES}    None
    ...    AND    Set Test Variable    ${UEs_CAPABILITIES}    LTE2 NR1
    ...    AND    Set Test Variable    ${UEs_BTS_CALL}    BTS2 BTS1
    ...    AND    Set Test Variable    ${UEs_TECHNOS}    LTE NR
    ...    AND    Set Test Variable    ${CELLS}    159248643;10208296964
    ...    AND    Set Test Variable    ${CALL_DIRECTIONS_UEs}    uplink_downlink uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${PROTOCOLS}    udp udp
    ...    AND    Set Test Variable    ${DETACH_UEs}    False
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    False
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    YES
    ...    AND    Set Test Variable    ${SKIP_FAILING_UE}    False
    ...    AND    Set Test Variable    ${DELAY_BETWEEN_SNAPSHOTS}    30
    ...    AND    Set Test Variable    ${THPUT_CHECK_BTS_LOGS}    False
    ...    AND    Set Test Variable    ${UL_UE_GROUP_UEs}    0 0

    ...    AND    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    TC__RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order



[2]SBTS_SBTS__SWM__SW_Update_CNI_103974
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__swm__sw_update_cni_103974_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS SW Update}    BTS1
    ...    AND    Set Test Variable    ${Target SW name BTS1}    None
    ...    AND    Set Test Variable    ${Target SW dir BTS1}    /home/ute/btsauto/TARGET_SW_MASTER
    ...    AND    Set Test Variable    ${Target SW name BTS2}    None
    ...    AND    Set Test Variable    ${Target SW dir BTS2}    /home/ute/btsauto/TARGET_SW_SLAVE
    ...    AND    Set Test Variable    ${Target SW name BTS3}    None
    ...    AND    Set Test Variable    ${Target SW dir BTS3}    None
    ...    AND    Set Test Variable    ${Target SW name BTS4}    None
    ...    AND    Set Test Variable    ${Target SW dir BTS4}    None
    ...    AND    Set Test Variable    ${Activate SW}    True
    ...    AND    Set Test Variable    ${SW Update Timeout}    3000
    ...    AND    Set Test Variable    ${BTS_RESET_WRN_THR}    606
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${BTS_SCF_VALIDATION}    True
    ...    AND    Set Test Variable    ${FORCE_TARGET_BTS_SW_DL}    True
    ...    AND    Set Test Variable    ${WFT_BTS1_target_sw}
    ...    AND    Set Test Variable    ${WFT_BTS2_target_sw}
    ...    AND    Set Test Variable    ${WFT_BTS3_target_sw}
    ...    AND    Set Test Variable    ${WFT_BTS4_target_sw}
    ...    AND    Set Test Variable    ${RFS_CUSTOM_SHARE_SW_DL}    False
    ...    AND    Set Test Variable    ${Remote target SW path BTS1}    None
    ...    AND    Set Test Variable    ${Remote target SW path BTS2}    None
    ...    AND    Set Test Variable    ${Remote target SW path BTS3}    None
    ...    AND    Set Test Variable    ${Remote target SW path BTS4}    None
    ...    AND    Set Test Variable    ${TWO_STEP_DOWNLOAD_ACTIVATE}    False
    ...    AND    Set Test Variable    ${SYNCHRONIZE_ACTIVE_PASSIVE_SW_VERSION}    False
    ...    AND    Set Test Variable    ${HISTORICAL_ALARMS_CHECK}    True
    ...    AND    Set Test Variable    ${SNAPSHOT_CHECK}    True

    ...    AND    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update_CNI_103974.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update_CNI_103974
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update_CNI_103974
    TC__SBTS_SBTS_SBTS_SBTS__SWM__SW_Update_CNI_103974
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update_CNI_103974.TC Teardown
    ...    AND    Restore Resource Search Order



[3]RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.py
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESSES}    None
    ...    AND    Set Test Variable    ${UEs_CAPABILITIES}    LTE2 NR1
    ...    AND    Set Test Variable    ${UEs_BTS_CALL}    BTS2 BTS1
    ...    AND    Set Test Variable    ${UEs_TECHNOS}    LTE NR
    ...    AND    Set Test Variable    ${CELLS}    159248643;10208296964
    ...    AND    Set Test Variable    ${CALL_DIRECTIONS_UEs}     uplink_downlink uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${PROTOCOLS}    udp udp
    ...    AND    Set Test Variable    ${DETACH_UEs}    False
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    False
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    YES
    ...    AND    Set Test Variable    ${SKIP_FAILING_UE}    False
    ...    AND    Set Test Variable    ${DELAY_BETWEEN_SNAPSHOTS}    30
    ...    AND    Set Test Variable    ${THPUT_CHECK_BTS_LOGS}    False
    ...    AND    Set Test Variable    ${UL_UE_GROUP_UEs}    0 0

    ...    AND    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    TC__RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order



[1]SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__swm__sw_rollback_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS_SW_Rollback}    BTS1
    ...    AND    Set Test Variable    ${BTS_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${BTS_RESET_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${CB015052_CHECK}    False
    ...    AND    Set Test Variable    ${tempRadioMasterTriggerTime}    0

    ...    AND    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    TC__SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback.TC Teardown
    ...    AND    Restore Resource Search Order



[4]RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.py
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESSES}    None
    ...    AND    Set Test Variable    ${UEs_CAPABILITIES}    LTE2 NR1
    ...    AND    Set Test Variable    ${UEs_BTS_CALL}    BTS2 BTS1
    ...    AND    Set Test Variable    ${UEs_TECHNOS}    LTE NR
    ...    AND    Set Test Variable    ${CELLS}    159248643;10208296964
    ...    AND    Set Test Variable    ${CALL_DIRECTIONS_UEs}    uplink_downlink uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${PROTOCOLS}    udp udp
    ...    AND    Set Test Variable    ${DETACH_UEs}    False
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    False
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    YES
    ...    AND    Set Test Variable    ${SKIP_FAILING_UE}    False
    ...    AND    Set Test Variable    ${DELAY_BETWEEN_SNAPSHOTS}    30
    ...    AND    Set Test Variable    ${THPUT_CHECK_BTS_LOGS}    False
    ...    AND    Set Test Variable    ${UL_UE_GROUP_UEs}    0 0

    ...    AND    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    TC__RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order



[2]SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__swm__sw_rollback_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS_SW_Rollback}    BTS2
    ...    AND    Set Test Variable    ${BTS_RESET_WRN_THR}    600
    ...    AND    Set Test Variable    ${BTS_RESET_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${CB015052_CHECK}    False
    ...    AND    Set Test Variable    ${tempRadioMasterTriggerTime}    0

    ...    AND    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    TC__SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__SWM__SW_Rollback.TC Teardown
    ...    AND    Restore Resource Search Order



[5]RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.py
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESSES}    None
    ...    AND    Set Test Variable    ${UEs_CAPABILITIES}    LTE2 NR1
    ...    AND    Set Test Variable    ${UEs_BTS_CALL}     BTS2 BTS1
    ...    AND    Set Test Variable    ${UEs_TECHNOS}    LTE NR
    ...    AND    Set Test Variable    ${CELLS}    159248643;10208296964
    ...    AND    Set Test Variable    ${CALL_DIRECTIONS_UEs}    uplink_downlink uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${PROTOCOLS}    udp udp
    ...    AND    Set Test Variable    ${DETACH_UEs}    False
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    False
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    YES
    ...    AND    Set Test Variable    ${SKIP_FAILING_UE}    False
    ...    AND    Set Test Variable    ${DELAY_BETWEEN_SNAPSHOTS}    30
    ...    AND    Set Test Variable    ${THPUT_CHECK_BTS_LOGS}    False
    ...    AND    Set Test Variable    ${UL_UE_GROUP_UEs}    0 0

    ...    AND    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    TC__RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order
