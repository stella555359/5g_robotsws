*** Settings ***
Documentation    Robot Test Suite

Force Tags    QCD_MN_RAN    QCP_RAN_VRF    CLOUD_HRAN_RFS_ASOG_ASOE_MTNRL120_3xAEHC_3XAWHHD    SBTS00

Resource    ../../../test_resources/SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__SWM__SW_Update.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__NR_Cell_LockUnlock_and_Ng_LockUnlock_with_Fid_7107_Check.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_same_time_from_WEBEM.robot
Resource    ../../../test_resources/NRL__FM__RMOD_Voltage_threshold_check_CB009903.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__RM_Reset_when_critical_DFE_is_broken_CNI_113670.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__RM_Reset_when_non_critical_DFE_is_broken_CNI_113670.robot
Resource    ../../../test_resources/RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__BTS_Power_Off_On.robot
Resource    ../../../test_resources/UUF_SW_UPGRADE_ROLLBACK.robot

*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
${CNI_127210_ENABLED}    ${True}
@{rezultate_test_voltage}
${allow_alarms_1}    61675,4773,1815,6134,62003,7509,7575,16,7316,7320,7317,10,1815,4652
${RP_CA}    VRF_SiSo
${RP_LOCATION}    VRF_TSR2
${RP_ORGANIZATION}    VRF_TSR2_T02

*** Test Cases ***
[1][2.0] Automated_RFS_SBTS_SBTS__SWM__BTS1_BTS2_SWDL
    [Tags]    STOPONFAIL
    [Timeout]    24400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__swm__sw_update_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS SW Update}    ALL
    ...    AND    Set Test Variable    ${Target SW name BTS1}    None
    ...    AND    Set Test Variable    ${Target SW dir BTS1}    /home/ute/btsauto/TARGET_SW_MASTER
    ...    AND    Set Test Variable    ${Target SW name BTS2}    None
    ...    AND    Set Test Variable    ${Target SW dir BTS2}    /home/ute/btsauto/TARGET_SW_SLAVE
    ...    AND    Set Test Variable    ${Target SW name BTS3}    None
    ...    AND    Set Test Variable    ${Target SW dir BTS3}    /home/ute/btsauto/TARGET_SW_SLAVE1
    ...    AND    Set Test Variable    ${Target SW name BTS4}    None
    ...    AND    Set Test Variable    ${Target SW dir BTS4}    /home/ute/btsauto/TARGET_SW_SLAVE2
    ...    AND    Set Test Variable    ${Activate SW}    True
    ...    AND    Set Test Variable    ${SW Update Timeout}    3000
    ...    AND    Set Test Variable    ${BTS_RESET_WRN_THR}    806
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${BTS_SCF_VALIDATION}    False
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
    ...    AND    Set Test Variable    ${CB015052_CHECK}    False
    ...    AND    Set Test Variable    ${tempRadioMasterTriggerTime}    0

    ...    AND    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update
    TC__SBTS_SBTS_SBTS_SBTS__SWM__SW_Update
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update.TC Teardown
    ...    AND    Restore Resource Search Order


[1][1.0] Automated_RFS_UUF_SW_UPGRADE_ROLLBACK
    [Timeout]    58400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BTS1_testline_object}    ${tl.gnbs[0]}
    ...    AND    Set Test Variable    ${BTS2_testline_object}    ${tl.enbs[0]}
    ...    AND    Set Test Variable    ${BTS3_testline_object}
    ...    AND    Set Test Variable    ${BTS4_testline_object}
    ...    AND    Set Test Variable    ${BTS1_source_sw}
    ...    AND    Set Test Variable    ${BTS2_source_sw}
    ...    AND    Set Test Variable    ${BTS3_source_sw}
    ...    AND    Set Test Variable    ${BTS4_source_sw}
    ...    AND    Set Test Variable    ${BTS1_target_sw}
    ...    AND    Set Test Variable    ${BTS2_target_sw}
    ...    AND    Set Test Variable    ${BTS3_target_sw}
    ...    AND    Set Test Variable    ${BTS4_target_sw}
    ...    AND    Set Test Variable    ${BTS1_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS2_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS3_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS1_custom_allowed_alarms}    ${allow_alarms_1}
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}    ${allow_alarms_1}
    ...    AND    Set Test Variable    ${BTS3_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_custom_allowed_alarms}
    ...    AND    Set Test Variable    &{BTS1_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS2_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS3_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS4_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    ${SYNCHRONIZE_SW_ON_PASSIVE}    True
    ...    AND    Set Test Variable    ${TEST_NODES_DETAILS_LIST}    ALL
    ...    AND    Set Test Variable    ${ROLLBACK_REVERSE_ORDER}    False
    ...    AND    Set Test Variable    ${RESTORE_TO_TARGET_SW}    True
    ...    AND    Set Test Variable    ${ITERATIONS_PER_NODE}    5
    ...    AND    Set Test Variable    ${CUSTOMERS_LIST}    Generic
    ...    AND    Set Test Variable    ${CALCULATE_KPI}    True
    ...    AND    Set Test Variable    ${KPI_NAMES}
    ...    AND    Set Test Variable    ${KPI_THRESHOLDS}
    ...    AND    Set Test Variable    ${USE_DCAP}    False
    ...    AND    Set Test Variable    ${L3_CALL_METHOD}    None
    ...    AND    Set Test Variable    ${STOP_TEST_AFTER_FAIL}    False
    ...    AND    Set Test Variable    ${REPORT}    True
    ...    AND    Set Test Variable    ${QC_PROJECT}    RAN_VRF
    ...    AND    Set Test Variable    ${QC_DOMAIN}    MN
    ...    AND    Set Test Variable    ${QC_ID}    None
    ...    AND    Set Test Variable    ${SW_BUILD}    ${None}
    ...    AND    Set Test Variable    ${TOPOLOGY}    CLOUD_HRAN_RFS_ASOG_ASOE_MTNRL120_3xAEHC_3XAWHHD
    ...    AND    Set Test Variable    ${RP_CA}    VRF_SiSo
    ...    AND    Set Test Variable    ${RP_LOCATION}    VRF_TSR2
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR2_T02
    ...    AND    Set Test Variable    &{TEST_PARAMETERS}    &{EMPTY}

    ...    AND    UUF_SW_UPGRADE_ROLLBACK.TC Setup
    ...    AND    Modify Resource Search Order    UUF_SW_UPGRADE_ROLLBACK
    ...    AND    Set Library Search Order    UUF_SW_UPGRADE_ROLLBACK
    TC__UUF_SW_UPGRADE_ROLLBACK
    [Teardown]    Run Keywords    UUF_SW_UPGRADE_ROLLBACK.TC Teardown
    ...    AND    Restore Resource Search Order


[1]RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue_TOTAL
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.py
    ...    AND    Set Test Variable    ${BTS_OAM_IP_ADDRESSES}    None
    ...    AND    Set Test Variable    ${UEs_CAPABILITIES}    NR_AEHC LTE_AEHC LTE_AWHHD NR_AWHHD
    ...    AND    Set Test Variable    ${UEs_BTS_CALL}    BTS1 BTS2 BTS2 BTS1
    ...    AND    Set Test Variable    ${UEs_TECHNOS}    NR LTE LTE NR
    ...    AND    Set Test Variable    ${CELLS}    DEFAULT;DEFAULT;DEFAULT;DEFAULT
    ...    AND    Set Test Variable    ${CALL_DIRECTIONS_UEs}    uplink_downlink uplink_downlink uplink_downlink uplink_downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    100
    ...    AND    Set Test Variable    ${PROTOCOLS}    udp udp udp udp
    ...    AND    Set Test Variable    ${DETACH_UEs}    False
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    False
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    NO
    ...    AND    Set Test Variable    ${SKIP_FAILING_UE}    True
    ...    AND    Set Test Variable    ${DELAY_BETWEEN_SNAPSHOTS}    30
    ...    AND    Set Test Variable    ${THPUT_CHECK_BTS_LOGS}    False
    ...    AND    Set Test Variable    ${UL_UE_GROUP_UEs}    0 0 0 0

    ...    AND    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    TC__RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order



[1][3.0] Automated_RFS_NRL__STATE__NR_RM_Power_Off_On
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__rm_power_off_on_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RMOD_SHARING_INFO}    ALL
    ...    AND    Set Test Variable    ${RMOD_POWER_ON_WRN_THR}    540
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


[1][2.0] Automated_SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_same_time_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__site_reset_same_time_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${BTS1_RESET_WRN_THR}    800
    ...    AND    Set Test Variable    ${BTS2_RESET_WRN_THR}    800
    ...    AND    Set Test Variable    ${BTS3_RESET_WRN_THR}    800
    ...    AND    Set Test Variable    ${BTS4_RESET_WRN_THR}    800
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${SWCONFIG_CHANGE_FLAG}    False
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_ACTION}    add
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_LIST}    0x4F0214
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    False

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_same_time_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_same_time_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_same_time_from_WEBEM
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_same_time_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_same_time_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order


[1]NRL__FM__RMOD_Voltage_threshold_check_CB009903_HIGH
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/nrl__fm__rmod_voltage_threshold_check_CB009903_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RMOD_SN_LIST}    EB2237R0331, EB2237R0323
    ...    AND    Set Test Variable    ${PSU_HOST_IP}    10.255.5.158
    ...    AND    Set Test Variable    ${PSU_PORT}    1
    ...    AND    Set Test Variable    ${PSU_TYPE}    PSU
    ...    AND    Set Test Variable    ${THRESHOLD_VOLTAGE_LEVEL}    HIGH
    ...    AND    Set Test Variable    ${alVoltUnstableThreshold}    3
    ...    AND    Set Test Variable    ${alVoltLowThreshold}    -116
    ...    AND    Set Test Variable    ${alVoltHighThreshold}    114
    ...    AND    Set Test Variable    ${alVoltLowThresholdMinor}    -106
    ...    AND    Set Test Variable    ${alVoltHighThresholdMinor}    101
    ...    AND    Set Test Variable    ${PSU_VoltageLow}    36
    ...    AND    Set Test Variable    ${PSU_VoltageHigh}    59
    ...    AND    Set Test Variable    ${PSU_VoltageLowMinor}    38
    ...    AND    Set Test Variable    ${PSU_VoltageHighMinor}    58

    ...    AND    NRL__FM__RMOD_Voltage_threshold_check_CB009903.TC Setup
    ...    AND    Modify Resource Search Order    NRL__FM__RMOD_Voltage_threshold_check_CB009903
    ...    AND    Set Library Search Order    NRL__FM__RMOD_Voltage_threshold_check_CB009903
    TC__NRL__FM__RMOD_Voltage_threshold_check_CB009903
    [Teardown]    Run Keywords    NRL__FM__RMOD_Voltage_threshold_check_CB009903.TC Teardown
    ...    AND    Get Status  ${rezultate_test_voltage}
    ...    AND    Restore Resource Search Order

[1]NRL__FM__RMOD_Voltage_threshold_check_CB009903_LOW
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/nrl__fm__rmod_voltage_threshold_check_CB009903_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RMOD_SN_LIST}    EB2237R0331, EB2237R0323
    ...    AND    Set Test Variable    ${PSU_HOST_IP}    10.255.5.158
    ...    AND    Set Test Variable    ${PSU_PORT}    1
    ...    AND    Set Test Variable    ${PSU_TYPE}    PSU
    ...    AND    Set Test Variable    ${THRESHOLD_VOLTAGE_LEVEL}    LOW
    ...    AND    Set Test Variable    ${alVoltUnstableThreshold}    3
    ...    AND    Set Test Variable    ${alVoltLowThreshold}    -116
    ...    AND    Set Test Variable    ${alVoltHighThreshold}    114
    ...    AND    Set Test Variable    ${alVoltLowThresholdMinor}    -106
    ...    AND    Set Test Variable    ${alVoltHighThresholdMinor}    101
    ...    AND    Set Test Variable    ${PSU_VoltageLow}    36
    ...    AND    Set Test Variable    ${PSU_VoltageHigh}    59
    ...    AND    Set Test Variable    ${PSU_VoltageLowMinor}    38
    ...    AND    Set Test Variable    ${PSU_VoltageHighMinor}    58

    ...    AND    NRL__FM__RMOD_Voltage_threshold_check_CB009903.TC Setup
    ...    AND    Modify Resource Search Order    NRL__FM__RMOD_Voltage_threshold_check_CB009903
    ...    AND    Set Library Search Order    NRL__FM__RMOD_Voltage_threshold_check_CB009903
    TC__NRL__FM__RMOD_Voltage_threshold_check_CB009903
    [Teardown]    Run Keywords    NRL__FM__RMOD_Voltage_threshold_check_CB009903.TC Teardown
    ...    AND    Get Status  ${rezultate_test_voltage}
    ...    AND    Restore Resource Search Order


[1][1.0] Automated_RFS_NRL__FM__RMOD_Voltage_threshold_check_CB009903
    Evaluare Status    ${rezultate_test_voltage}



[1]SBTS_SBTS__STATE__RM_Reset_when_critical_DFE_is_broken_CNI_113670
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__rm_reset_when_critical_dfe_is_broken_cni_113670.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RM_CONFIGURED_INFO}    ALL
    ...    AND    Set Test Variable    ${RM_SERIAL_NUMBER_LIST}    L1210303036
    ...    AND    Set Test Variable    ${USER_RSI_INFO_COLLECT}    True

    ...    AND    SBTS_SBTS__STATE__RM_Reset_when_critical_DFE_is_broken_CNI_113670.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__RM_Reset_when_critical_DFE_is_broken_CNI_113670
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__RM_Reset_when_critical_DFE_is_broken_CNI_113670
    TC__SBTS_SBTS__STATE__RM_Reset_when_critical_DFE_is_broken_CNI_113670
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__RM_Reset_when_critical_DFE_is_broken_CNI_113670.TC Teardown
    ...    AND    Restore Resource Search Order


[1]SBTS_SBTS__STATE__RM_Reset_when_non_critical_DFE_is_broken_CNI_113670
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__rm_reset_when_non_critical_dfe_is_broken_cni_113670_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RM_CONFIGURED_INFO}    ALL
    ...    AND    Set Test Variable    ${RM_SERIAL_NUMBER_LIST}    L1210303036
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True
    ...    AND    Set Test Variable    ${USER_RSI_INFO_COLLECT}    True

    ...    AND    SBTS_SBTS__STATE__RM_Reset_when_non_critical_DFE_is_broken_CNI_113670.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__RM_Reset_when_non_critical_DFE_is_broken_CNI_113670
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__RM_Reset_when_non_critical_DFE_is_broken_CNI_113670
    TC__SBTS_SBTS__STATE__RM_Reset_when_non_critical_DFE_is_broken_CNI_113670
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__RM_Reset_when_non_critical_DFE_is_broken_CNI_113670.TC Teardown
    ...    AND    Restore Resource Search Order


*** comment ***
[1][3.0] Automated_RFS_NRL__STATE__LTE_Site_Reset_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__site_reset_from_webem_force_primary_link_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    BTS2
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK_BEFORE_BTS1_RESET}
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK_BEFORE_BTS2_RESET}
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    120
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_PROCEDURE}    LANE
    ...    AND    Set Test Variable    ${BTS1_RESET_WRN_THR}    660
    ...    AND    Set Test Variable    ${BTS2_RESET_WRN_THR}    660
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${SWCONFIG_CHANGE_FLAG}    False
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_ACTION}    add
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_LIST}    0x4F0214
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True

    ...    AND    SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link
    TC__SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link.TC Teardown
    ...    AND    Restore Resource Search Order


[1][3.0] Automated_RFS_NRL__STATE__NR_Site_Reset_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__site_reset_from_webem_force_primary_link_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    BTS1
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK_BEFORE_BTS1_RESET}
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK_BEFORE_BTS2_RESET}
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    120
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_PROCEDURE}    LANE
    ...    AND    Set Test Variable    ${BTS1_RESET_WRN_THR}    660
    ...    AND    Set Test Variable    ${BTS2_RESET_WRN_THR}    660
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${SWCONFIG_CHANGE_FLAG}    False
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_ACTION}    add
    ...    AND    Set Test Variable    ${SWCONFIG_FLAG_LIST}    0x4F0214
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True

    ...    AND    SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link
    TC__SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link.TC Teardown
    ...    AND    Restore Resource Search Order


[1][1.0] Automated_RFS_SBTS_SBTS__STATE__NR_Cell_LockUnlock_and_Ng_LockUnlock_with_Fid_7107_Check
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__nr_cel_lock_unlock_and_ng_lock_unlock_with_fid_7107_check_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${saCellActivationAlarmTimer}    60
    ...    AND    Set Test Variable    ${Cell_administrativeState_lock}    Locked
    ...    AND    Set Test Variable    ${Cell_administrativeState_unlock}    Unlocked
    ...    AND    Set Test Variable    ${Ng_administrativeState_lock}    Locked
    ...    AND    Set Test Variable    ${Ng_administrativeState_unlock}    Unlocked

    ...    AND    SBTS_SBTS__STATE__NR_Cell_LockUnlock_and_Ng_LockUnlock_with_Fid_7107_Check.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__NR_Cell_LockUnlock_and_Ng_LockUnlock_with_Fid_7107_Check
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__NR_Cell_LockUnlock_and_Ng_LockUnlock_with_Fid_7107_Check
    TC__SBTS_SBTS__STATE__NR_Cell_LockUnlock_and_Ng_LockUnlock_with_Fid_7107_Check
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__NR_Cell_LockUnlock_and_Ng_LockUnlock_with_Fid_7107_Check.TC Teardown
    ...    AND    Restore Resource Search Order


[1][3.0] Automated_RFS_NRL__STATE__NR_SM_Power_Off_Ondown
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts__state__bts_power_off_on_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${BTS_PRIMARY_LINK_LIST}
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_TIME}    720
    ...    AND    Set Test Variable    ${SET_PRIMARY_LINK_PROCEDURE}    LANE
    ...    AND    Set Test Variable    ${BTS_POWER_ON_WRN_THR_LIST}    600
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900

    ...    AND    SBTS_SBTS__STATE__BTS_Power_Off_On.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS__STATE__BTS_Power_Off_On
    ...    AND    Set Library Search Order    SBTS_SBTS__STATE__BTS_Power_Off_On
    TC__SBTS_SBTS__STATE__BTS_Power_Off_On
    [Teardown]    Run Keywords    SBTS_SBTS__STATE__BTS_Power_Off_On.TC Teardown
    ...    AND    Restore Resource Search Order



[1][4.0] Automated_RFS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__secondary_controller_sharedrm_reset_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${SHARED_RM_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RM_RESET_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RM_RESET_TIME_INTERVAL}    480
    ...    AND    Set Test Variable    ${RM_RESET_WRN_THR}    520
    ...    AND    Set Test Variable    ${CNI_103974}    True
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1][2.0] Automated_RFS_SBTS_SBTS__SWM__BTS1_BTS2_SWDL
    [Tags]    STOPONFAIL
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__swm__sw_update_alarms_definitions.py
    ...    AND    Set Test Variable    ${BTS SW Update}    ALL
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/btsauto/TARGET_SW_MASTER
    ...    AND    Set Test Variable    ${Target SW name}    None
    ...    AND    Set Test Variable    ${Activate SW}    True
    ...    AND    Set Test Variable    ${SW Update Timeout}    3000
    ...    AND    Set Test Variable    ${BTS_RESET_WRN_THR}    808
    ...    AND    Set Test Variable    ${BTS_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${BTS_SCF_VALIDATION}    False
    ...    AND    Set Test Variable    ${FORCE_CURRENT_SW_DL}    True
    ...    AND    Set Test Variable    ${Remote target SW path}    None
    ...    AND    Set Test Variable    ${RFS_CUSTOM_SHARE_SW_DL}    False
    ...    AND    Set Test Variable    ${TWO_STEP_DOWNLOAD_ACTIVATE}    False

    ...    AND    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update
    TC__SBTS_SBTS_SBTS_SBTS__SWM__SW_Update
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__SWM__SW_Update.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***
Get Status
    [Arguments]    ${lista_rezultate}
    Append To List    ${lista_rezultate}  ${TEST_STATUS}

Evaluare status
    [Arguments]    ${lista_rezultate}
    Set Test Variable    ${test_passed}    0
    Set Test Variable    ${test_total}    0
    FOR    ${status}    IN    @{lista_rezultate}
        ${test_total}=    Evaluate    ${test_total} + 1
        IF    '${status}'=='PASS'
            ${test_passed}=    Evaluate    ${test_passed} + 1
        END
    END
    IF    ${test_total} != ${test_passed}
        Log    Rezultat FAIL, au trecut doar ${test_passed} din ${test_total} teste.    console=True
        FAIL
    ELSE
    	Log    Rezultat PASS, au trecut toate ${test_passed} din ${test_total} teste.    console=True
    END
