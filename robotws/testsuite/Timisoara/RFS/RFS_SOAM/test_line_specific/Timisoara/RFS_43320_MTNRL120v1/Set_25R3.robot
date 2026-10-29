*** Settings ***
Documentation    Robot Test Suite

Force Tags    QCD_MN_RAN    QCP_RAN_VRF    CLOUD_HRAN_RFS_ASOG_ASOE_MTNRL120_3xAEHC_3XAWHHD    SBTS25R3

Resource    ../../../test_resources/SBTS_SBTS__STATE__Site_Reset_from_WEBEM_force_primary_link.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__BTS_Power_Off_On.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__SWM__SW_Update.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__NR_Cell_LockUnlock_and_Ng_LockUnlock_with_Fid_7107_Check.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Site_Reset_same_time_from_WEBEM.robot
Resource    ../../../test_resources/NRL__FM__RMOD_Voltage_threshold_check_CB009903.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__RM_Reset_when_critical_DFE_is_broken_CNI_113670.robot
Resource    ../../../test_resources/SBTS_SBTS__STATE__RM_Reset_when_non_critical_DFE_is_broken_CNI_113670.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
${CNI_127210_ENABLED}    ${True}
@{rezultate_test_voltage}

*** Test Cases ***
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
