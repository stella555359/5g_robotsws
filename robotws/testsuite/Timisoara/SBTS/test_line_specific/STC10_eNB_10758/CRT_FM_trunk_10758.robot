*** Settings ***
Documentation
    ...  This testsuite was created for CRT runs.
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS00  SRAN  CLOUD_SRAN_L_10758_1ASIB_2ABIA_1ABIO_1ASIB_2ABIO_3AHPMDA_2AREA_2ARGA_6AZNA
Library           XML  use_lxml=True
Resource    ../../FM/test_resources/FM__FID4383_fault_signature_active_UP_4G_L2_process_crashed.robot
Resource    ../../FM/test_resources/FM__E_L1Soc_LTE_DL_DSP_unsuccessful_recovery_reset_loop_detection.robot
Resource    ../../FM/test_resources/FM__D_L1Soc_LTE_UL_DSP_unsuccessful_recovery_reset_loop_detection.robot
Resource    ../../FM/test_resources/FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.robot
Resource    ../../FM/test_resources/FM__B_L1Soc_NR_UL_DSP_unsuccessful_recovery_reset_loop_detection.robot
Resource    ../../FM/test_resources/FM__RMOD_reset_counter_exceeded_FID1907.robot
Resource    ../../FM/test_resources/FM__RMOD_crash_fault_signature_check.robot
Resource    ../../FM/test_resources/FM__RMOD_crash_FID4590.robot
Resource    ../../FM/test_resources/FM__LTE_L2_MACPS_sw_critical_failure.robot
Resource    ../../FM/test_resources/FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation.robot
Resource    ../../FM/test_resources/FM__FSP_common_reset_counter_exceeded.robot
Resource    ../../FM/test_resources/FM__Site_reset_escalation_to_BTS_power_reset.robot
Resource    ../../FM/test_resources/FM__Robustness_trigger_different_faults_RMOD.robot
Resource    ../../FM/test_resources/FM__LTE_NR_cells_degraded_when_1_RU_power_off.robot
Resource    ../../FM/test_resources/FM__EDA_5G_cell_availabilityStatus_transitions.robot
Resource    ../../FM/test_resources/FM__RU_resiliency_to_BTS_DU_L1Soc_reset_Controlled_case.robot
Resource    ../../FM/test_resources/FM__Suppress_alarms_based_on_both_fault_and_alarm_Id.robot
Resource    ../../FM/test_resources/FM__Alarm_suppression_by_MOC_PC_mix_severity.robot
Resource    ../../FM/test_resources/FM__A2_Cell_Setup_with_Failed_Tx_Rx_in_Degraded_State.robot
Resource    ../../FM/test_resources/FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered.robot
Resource    ../../FM/test_resources/FM__B3_Tx_Rx_Failure_after_RF_recovery_reset.robot
Resource    ../../FM/test_resources/FM__C2_only_one_RF_Recovery_Reset_in_Maintenance_Window.robot
Resource    ../../FM/test_resources/FM__RU_L1Soc_NR_DSP_recovery_escalation_procedure.robot
Resource    ../../FM/test_resources/FM__Snapshot_Collection_after_autonomous_reset_reported_using_FIDs_which_support_faultsignature.robot
Resource    ../../FM/test_resources/FM__5G_fault_tolerant_setup_degraded_cell.robot

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1758

*** Test Cases ***
[1]FM__E_L1Soc_LTE_DL_DSP_unsuccessful_recovery_reset_loop_detection
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    950
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9000
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    LTE
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044041600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044001600 64 1

    ...    AND    FM__E_L1Soc_LTE_DL_DSP_unsuccessful_recovery_reset_loop_detection.TC Setup
    ...    AND    Modify Resource Search Order    FM__E_L1Soc_LTE_DL_DSP_unsuccessful_recovery_reset_loop_detection
    TC__FM__E_L1Soc_LTE_DL_DSP_unsuccessful_recovery_reset_loop_detection
    [Teardown]    Run Keywords    FM__E_L1Soc_LTE_DL_DSP_unsuccessful_recovery_reset_loop_detection.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__D_L1Soc_LTE_UL_DSP_unsuccessful_recovery_reset_loop_detection
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    950
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9000
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    LTE
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIN
    ...    AND    Set Test Variable    ${SERIAL_NUMBER_SOC}   ${EMPTY}
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044181600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044981600 64 1
    ...    AND    FM__D_L1Soc_LTE_UL_DSP_unsuccessful_recovery_reset_loop_detection.TC Setup
    ...    AND    Modify Resource Search Order    FM__D_L1Soc_LTE_UL_DSP_unsuccessful_recovery_reset_loop_detection
    TC__FM__D_L1Soc_LTE_UL_DSP_unsuccessful_recovery_reset_loop_detection
    [Teardown]    Run Keywords    FM__D_L1Soc_LTE_UL_DSP_unsuccessful_recovery_reset_loop_detection.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__B_L1Soc_NR_UL_DSP_recovery_escalation_procedure
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    950
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9100
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIN
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044241600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044201600 64 1

    ...    AND    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    TC__FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    [Teardown]    Run Keywords    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__B_L1Soc_NR_UL_DSP_unsuccessful_recovery_reset_loop_detection
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    950
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9000
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044281600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044981600 64 1

    ...    AND    FM__B_L1Soc_NR_UL_DSP_unsuccessful_recovery_reset_loop_detection.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_L1Soc_NR_UL_DSP_unsuccessful_recovery_reset_loop_detection
    TC__FM__B_L1Soc_NR_UL_DSP_unsuccessful_recovery_reset_loop_detection
    [Teardown]    Run Keywords    FM__B_L1Soc_NR_UL_DSP_unsuccessful_recovery_reset_loop_detection.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__FID4383_fault_signature_active_UP_4G_L2_process_crashed
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    950
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    180
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    300
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIO

    ...    AND    FM__FID4383_fault_signature_active_UP_4G_L2_process_crashed.TC Setup
    ...    AND    Modify Resource Search Order    FM__FID4383_fault_signature_active_UP_4G_L2_process_crashed
    TC__FM__FID4383_fault_signature_active_UP_4G_L2_process_crashed
    [Teardown]    Run Keywords    FM__FID4383_fault_signature_active_UP_4G_L2_process_crashed.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM_RMOD_power_off_on_FID4589
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_TYPE}    AQNA
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    360

    ...    AND    FM__RMOD_crash_fault_signature_check.TC setup
    ...    AND    Modify Resource Search Order    FM__RMOD_crash_fault_signature_check
    FM__RMOD_crash_fault_signature_check
    [Teardown]    Run Keywords    FM__RMOD_crash_fault_signature_check.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM_RMOD_crash_FID4590
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_TYPE}    AQNA
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1500
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    120

    ...    AND    FM__RMOD_crash_FID4590.TC Setup
    ...    AND    Modify Resource Search Order    FM__RMOD_crash_FID4590
    TC__FM__RMOD_crash_FID4590
    [Teardown]    Run Keywords    FM__RMOD_crash_FID4590.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__LTE_L2_MACPS_critical_failure
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${MODULE_TYPE}    ABIO
    ...    AND    Set Test Variable    ${RAT}    LNCEL
    ...    AND    Set Test Variable    ${TECHNOLOGY}    FDD
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    950
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    900
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    180

    ...    AND    FM__LTE_L2_MACPS_sw_critical_failure.TC Setup
    ...    AND    Modify Resource Search Order    FM__LTE_L2_MACPS_sw_critical_failure
    FM__LTE_L2_MACPS_sw_critical_failure
    [Teardown]    Run Keywords    FM__LTE_L2_MACPS_sw_critical_failure.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${MODULE_TYPE}    ABIN
    ...    AND    Set Test Variable    ${CELLS_FAILED_TIMEOUT}    180
    ...    AND    Set Test Variable    ${CELLS_ONLINE_TIMEOUT}    600
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}           180

    ...    AND    FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation.TC Setup
    ...    AND    Modify Resource Search Order    FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    TC__FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    [Teardown]    Run Keywords    FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__FSP_common_reset_counter_exceeded
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIO
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    900
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    900
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    120
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    60

    ...    AND    FM__FSP_common_reset_counter_exceeded.TC Setup
    ...    AND    Modify Resource Search Order    FM__FSP_common_reset_counter_exceeded
    TC__FM__FSP_common_reset_counter_exceeded
    [Teardown]    Run Keywords    FM__FSP_common_reset_counter_exceeded.TC Teardown
    ...    AND    Restore Resource Search Order


[2]FM__FSP_common_reset_counter_exceeded
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABI0
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    900
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    900
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    120
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    60

    ...    AND    FM__FSP_common_reset_counter_exceeded.TC Setup
    ...    AND    Modify Resource Search Order    FM__FSP_common_reset_counter_exceeded
    TC__FM__FSP_common_reset_counter_exceeded
    [Teardown]    Run Keywords    FM__FSP_common_reset_counter_exceeded.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__5G_cell_availabilityStatus_transitions
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{BBMOD_LIST}                   ABIA  ABIO  ABIN
    ...    AND    Set Test Variable    @{ACCEPTED_CELLS_LIST}          NR    LTE    WCDMA    GSM
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}                180
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}               300
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT}                300
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}             600

    ...    AND    FM__EDA_5G_cell_availabilityStatus_transitions.TC Setup
    ...    AND    Modify Resource Search Order    FM__EDA_5G_cell_availabilityStatus_transitions
    TC__FM__EDA_5G_cell_availabilityStatus_transitions
    [Teardown]    Run Keywords    FM__EDA_5G_cell_availabilityStatus_transitions.TC Teardown
    ...    AND    Restore Resource Search Order

[1]FM__US009504_A1_Cell_Setup_with_Failed_Tx_Rx_recovered
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_TYPE}  AQNA
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}  900

    ...    AND    FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered.TC Setup
    ...    AND    Modify Resource Search Order    FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered
    TC__FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered
    [Teardown]    Run Keywords    FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered.TC Teardown
    ...    AND    Restore Resource Search Order

[1]FM__US009504_A2_Cell_Setup_with_Failed_Tx_Rx_in_Degraded_State
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}  900

    ...    AND    FM__A2_Cell_Setup_with_Failed_Tx_Rx_in_Degraded_State.TC Setup
    ...    AND    Modify Resource Search Order    FM__A2_Cell_Setup_with_Failed_Tx_Rx_in_Degraded_State
    TC__FM__A2_Cell_Setup_with_Failed_Tx_Rx_in_Degraded_State
    [Teardown]    Run Keywords    FM__A2_Cell_Setup_with_Failed_Tx_Rx_in_Degraded_State.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__RMOD_reset_counter_exceeded_FID1907
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    900
    ...    AND    Set Test Variable    ${RMOD_TYPE}    AQQL

    ...    AND    FM__RMOD_reset_counter_exceeded_FID1907.TC Setup
    ...    AND    Modify Resource Search Order    FM__RMOD_reset_counter_exceeded_FID1907
    FM__RMOD_reset_counter_exceeded_FID1907
    [Teardown]    Run Keywords    FM__RMOD_reset_counter_exceeded_FID1907.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__US009504_B3_Tx_Rx_Failure_detection_after_RF_recovery_reset_further_faults_appear
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    300


    ...    AND    FM__B3_Tx_Rx_Failure_after_RF_recovery_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__B3_Tx_Rx_Failure_after_RF_recovery_reset
    TC__FM__B3_Tx_Rx_Failure_after_RF_recovery_reset
    [Teardown]    Run Keywords    FM__B3_Tx_Rx_Failure_after_RF_recovery_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__US009504_C2_only_one_RF_Recovery_Reset_in_Maintenance_Window
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    300


    ...    AND    FM__C2_only_one_RF_Recovery_Reset_in_Maintenance_Window.TC Setup
    ...    AND    Modify Resource Search Order    FM__C2_only_one_RF_Recovery_Reset_in_Maintenance_Window
    TC__FM__C2_only_one_RF_Recovery_Reset_in_Maintenance_Window
    [Teardown]    Run Keywords    FM__C2_only_one_RF_Recovery_Reset_in_Maintenance_Window.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__RU_L1Soc_NR_DSP_recovery_escalation_procedure
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_TYPE}    AQNA
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    300



    ...    AND    FM__RU_L1Soc_NR_DSP_recovery_escalation_procedure.TC Setup
    ...    AND    Modify Resource Search Order    FM__RU_L1Soc_NR_DSP_recovery_escalation_procedure
    TC__FM__RU_L1Soc_NR_DSP_recovery_escalation_procedure
    [Teardown]    Run Keywords    FM__RU_L1Soc_NR_DSP_recovery_escalation_procedure.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__CPRI_RU_resiliency_to_BTS_DU_L1Soc_reset_Controlled_case
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    300
    ...    AND    Set Test Variable    ${CELLS_TIMEOUT}    180
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    180
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    600
    ...    AND    Set Test Variable    ${BREAK_TIME_VALUE}    220


    ...    AND    FM__RU_resiliency_to_BTS_DU_L1Soc_reset_Controlled_case.TC Setup
    ...    AND    Modify Resource Search Order    FM__RU_resiliency_to_BTS_DU_L1Soc_reset_Controlled_case
    TC__FM__RU_Resiliency_to_BTS_DU_L1SoC_Reset_Controlled_Case
    [Teardown]    Run Keywords    FM__RU_resiliency_to_BTS_DU_L1Soc_reset_Controlled_case.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__Suppress_all_alarms_with_few_exceptions_based_on Fault_ID_and_both_FID_AlarmID
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    L1221604145
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    360
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    60

    ...    AND    FM__Suppress_alarms_based_on_both_fault_and_alarm_Id.TC Setup
    ...    AND    Modify Resource Search Order    FM__Suppress_alarms_based_on_both_fault_and_alarm_Id
    TC__FM__Suppress_alarms_based_on_both_fault_and_alarm_Id
    [Teardown]    Run Keywords    FM__Suppress_alarms_based_on_both_fault_and_alarm_Id.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM_Alarm_suppression_by_MOC_PC_warning_severity
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_1_SN}    L1221604145
    ...    AND    Set Test Variable    ${RMOD_2_SN}    L1223806979
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    360
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    60
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    800

    ...    AND    FM__Alarm_suppression_by_MOC_PC_mix_severity.TC Setup
    ...    AND    Modify Resource Search Order    FM__Alarm_suppression_by_MOC_PC_mix_severity
    TC__FM__Alarm_suppression_by_MOC_PC_mix_severity
    [Teardown]    Run Keywords    FM__Alarm_suppression_by_MOC_PC_mix_severity.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__Robustness_trigger_different_faults_RMOD
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}             30m
    ...    AND    Set Test Variable    ${PING_LOSS_TIMEOUT}           10m
    ...    AND    Set Test Variable    ${PING_REGAIN_TIMEOUT}         10m
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}               180

    ...    AND    FM__Robustness_trigger_different_faults_RMOD.TC Setup
    ...    AND    Modify Resource Search Order    FM__Robustness_trigger_different_faults_RMOD
    TC__FM__Robustness_trigger_different_faults_RMOD
    [Teardown]    Run Keywords    FM__Robustness_trigger_different_faults_RMOD.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__Site_rst_escalation_to_BTS_power_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_SN}    	L1214206771
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIO
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    900
    ...    AND    Set Test Variable    ${PING_TIMEOUT}    240
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    240
    ...    AND    Set Test Variable    ${PING_LOSS_TIMEOUT}    900
    ...    AND    Set Test Variable    ${PING_REGAIN_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RESTORE_TIMEOUT}    1800

    ...    AND    FM__Site_reset_escalation_to_BTS_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__Site_reset_escalation_to_BTS_power_reset
    TC__FM__Site_reset_escalation_to_BTS_power_reset
    [Teardown]    Run Keywords    FM__Site_reset_escalation_to_BTS_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__Snapshot_Collection_after_autonomous_reset_reported_using_FIDs_which_support_faultsignature
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SNAPSHOT_TIMEOUT}    	30

    ...    AND    FM__Snapshot_Collection_after_autonomous_reset_reported_using_FIDs_which_support_faultsignature.TC Setup
    ...    AND    Modify Resource Search Order    FM__Snapshot_Collection_after_autonomous_reset_reported_using_FIDs_which_support_faultsignature
    FM__Snapshot_Collection_after_autonomous_reset_reported_using_FIDs_which_support_faultsignature
    [Teardown]    Run Keywords    FM__Snapshot_Collection_after_autonomous_reset_reported_using_FIDs_which_support_faultsignature.TC Teardown
    ...    AND    Restore Resource Search Order


