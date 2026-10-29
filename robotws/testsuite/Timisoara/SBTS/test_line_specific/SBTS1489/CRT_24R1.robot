*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS24R1  SRAN  CLOUD_SRAN_NLWG_1489_2ASIB_2ABIA_1ABIO_1ABIN_2FXCB_1AHDB_1AHHB_1AHFIB STATE_SKIP_AGENT
Library           XML  use_lxml=True
Resource    ../../FM/test_resources/FM__GSM_DSP_crash_RAT_recovery_reset.robot
Resource    ../../FM/test_resources/FM__LTE_CCplane_crash_RAT_recovery_reset.robot
Resource    ../../FM/test_resources/FM__LTE_L3_crash_VN_recovery_reset.robot
Resource    ../../FM/test_resources/FM__RAT_reset_counter_exceeded__multi_RAT.robot
Resource    ../../FM/test_resources/FM__Site_reset_counter_exceeded.robot
Resource    ../../FM/test_resources/FM__VN_CCplane_LTE_reset_counter_exceeded.robot
Resource    ../../FM/test_resources/FM__WCDMA_VN_crash_RAT_recovery_reset.robot
Resource    ../../FM/test_resources/FM__5G_RAT_reset_executed_as_autonomous_recovery_action.robot
Resource    ../../FM/test_resources/FM__A_L1_5G_Loki_autonomous_reset_on_critical_failure.robot
Resource    ../../FM/test_resources/FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.robot
Resource    ../../FM/test_resources/FM__B_L1Soc_NR_UL_DSP_successful_recovery.robot
Resource    ../../FM/test_resources/FM__B_L1Soc_NR_UL_DSP_unsuccessful_recovery_reset_loop_detection.robot
Resource    ../../FM/test_resources/FM__BBPOOL_reset_allowBbPoolRecoveryReset_true_faulty_cell.robot
Resource    ../../FM/test_resources/FM__C_Capacity_core_unit_5G_L3_SW_reset_escalation.robot
Resource    ../../FM/test_resources/FM__C_L1Soc_NR_DL_DSP_successful_recovery.robot
Resource    ../../FM/test_resources/FM__C_L1Soc_NR_DL_DSP_unsuccessful_recovery_reset_loop_detection.robot
Resource    ../../FM/test_resources/FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation.robot
Resource    ../../FM/test_resources/FM__FID4383_fault_signature_active_UP_4G_L2_process_crashed.robot
Resource    ../../FM/test_resources/FM__FID4383_fault_signature_active_UP_5G_L2_process_crashed.robot
Resource    ../../FM/test_resources/FM__FSP_common_reset_counter_exceeded.robot
Resource    ../../FM/test_resources/FM__Link_break_GTPU.robot
Resource    ../../FM/test_resources/FM__Primary_core_power_off_on.robot
Resource    ../../FM/test_resources/FM__SC_late_startup_actForceAutoReset_true.robot
Resource    ../../FM/test_resources/FM__SC_reset_counter_cleared_manual_site_reset.robot
Resource    ../../FM/test_resources/FM__Secondary_core_power_off_on.robot
Resource    ../../FM/test_resources/FM__Improved_combined_FM_service_with_multiple_alarms.robot
Resource    ../../FM/test_resources/FM__Suppression_of_toggling_external_alarm.robot
Resource    ../../FM/test_resources/FM__Suppression_of_toggling_transport_alarms.robot
Resource    ../../FM/test_resources/FM__Ping_lost_between_node_CCandS_and_application_FSM_BTSOM.robot
Resource    ../../FM/test_resources/FM__Ping_lost_between_node_CCandS_and_application_FSM_RROM.robot
Resource    ../../FM/test_resources/FM__FSP_recovery_fault_243.robot
Resource    ../../FM/test_resources/FM__FSP_Lom_Fault_Service_crash.robot
Resource    ../../FM/test_resources/FM__FSP_Lom_Fault_Service_crash.robot
Resource    ../../FM/test_resources/FM__LTE_DSP_reset_actForceUnitAutoReset_false_faulty_cells_6709.robot

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
@{GSMVlan}            ${251}  ${252}
${WCDMAVlan}          ${351}
${LTEVlan}            ${451}
${Switch_IP}          10.255.6.18
${Switch_type}        Nokia_Nuage
${INTERFACE_TYPE}     GigabitEthernet
${INTERFACE_ID}       9
${Switch_USER}        AutoUser
${Switch_PASSWORD}    AutoPass123$
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1489


*** Test Cases ***
[1]Automated__FM__GSM_DSP_crash_RAT_recovery_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    360
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    @{EXPECTED_FAULT_IDS}    6707  6708  6709  4019
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}    RAT autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}    7101
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}    BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...    AND    Set Test Variable    ${SEVERITY}    Warning

    ...    AND    FM__GSM_DSP_crash_RAT_recovery_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__GSM_DSP_crash_RAT_recovery_reset
    TC__FM__GSM_DSP_crash_RAT_recovery_reset
    [Teardown]    Run Keywords    FM__GSM_DSP_crash_RAT_recovery_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__LTE_CCplane_crash_RAT_recovery_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    300

    ...    AND    FM__LTE_CCplane_crash_RAT_recovery_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__LTE_CCplane_crash_RAT_recovery_reset
    TC__FM__LTE_CCplane_crash_RAT_recovery_reset
    [Teardown]    Run Keywords    FM__LTE_CCplane_crash_RAT_recovery_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__LTE_L3_crash_VN_recovery_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    300

    ...    AND    FM__LTE_L3_crash_VN_recovery_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__LTE_L3_crash_VN_recovery_reset
    TC__FM___LTE_L3_crash_VN_recovery_reset
    [Teardown]    Run Keywords    FM__LTE_L3_crash_VN_recovery_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__RAT_reset_counter_exceeded__multi_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    360
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600

    ...    AND    FM__RAT_reset_counter_exceeded__multi_RAT.TC Setup
    ...    AND    Modify Resource Search Order    FM__RAT_reset_counter_exceeded__multi_RAT
    TC__FM__RAT_reset_counter_exceeded_multi_RAT
    [Teardown]    Run Keywords    FM__RAT_reset_counter_exceeded__multi_RAT.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__Site_reset_counter_exceeded
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${PING_TIMEOUT}    120
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600

    ...    AND    FM__Site_reset_counter_exceeded.TC Setup
    ...    AND    Modify Resource Search Order    FM__Site_reset_counter_exceeded
    TC__FM__Site_reset_counter_exceeded
    [Teardown]    Run Keywords    FM__Site_reset_counter_exceeded.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__VN_CCplane_LTE_reset_counter_exceeded
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    300
	
    ...    AND    FM__VN_CCplane_LTE_reset_counter_exceeded.TC Setup
    ...    AND    Modify Resource Search Order    FM__VN_CCplane_LTE_reset_counter_exceeded
    TC__FM_VN_CCplane_LTE_reset_counter_exceeded
    [Teardown]    Run Keywords    FM__VN_CCplane_LTE_reset_counter_exceeded.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__WCDMA_VN_crash_RAT_recovery_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600

    ...    AND    FM__WCDMA_VN_crash_RAT_recovery_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__WCDMA_VN_crash_RAT_recovery_reset
    TC__FM__WCDMA_VN_crash_RAT_recovery_reset
    [Teardown]    Run Keywords    FM__WCDMA_VN_crash_RAT_recovery_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__5G RAT reset executed as autonomous recovery action
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    360
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    660

    ...    AND    FM__5G_RAT_reset_executed_as_autonomous_recovery_action.TC Setup
    ...    AND    Modify Resource Search Order    FM__5G_RAT_reset_executed_as_autonomous_recovery_action
    TC__FM__5G_RAT_reset_executed_as_autonomous_recovery_action
    [Teardown]    Run Keywords    FM__5G_RAT_reset_executed_as_autonomous_recovery_action.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__A_L1_5G_Loki_autonomous_reset_on_critical_failure
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    180
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIO
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID}    2087
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}    SoC autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}    7101
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}    BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...    AND    Set Test Variable    ${SEVERITY}    Warning
    ...    AND    Set Test Variable    ${EXPECTED_SCOPE}    SoC
    ...    AND    Set Test Variable    ${EXPECTED_CATEGORY}    SW_FAILURE
	
    ...    AND    FM__A_L1_5G_Loki_autonomous_reset_on_critical_failure.TC Setup
    ...    AND    Modify Resource Search Order    FM__A_L1_5G_Loki_autonomous_reset_on_critical_failure
    TC__FM__A_L1_5G_Loki_autonomous_reset_on_critical_failure
    [Teardown]    Run Keywords    FM__A_L1_5G_Loki_autonomous_reset_on_critical_failure.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__B_L1Soc_NR_UL_DSP_recovery_escalation_procedure
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9100
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044241600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044201600 64 1

    ...    AND    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    TC__FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure
    [Teardown]    Run Keywords    FM__B_L1Soc_NR_UL_DSP_recovery_escation_procedure.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__B_L1Soc_NR_UL_DSP_successful_recovery
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9101
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${HW_VARIANT}    Loki
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044241600 64 1

    ...    AND    FM__B_L1Soc_NR_UL_DSP_successful_recovery.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_L1Soc_NR_UL_DSP_successful_recovery
    TC__FM__B_L1Soc_NR_UL_DSP_successful_recovery
    [Teardown]    Run Keywords    FM__B_L1Soc_NR_UL_DSP_successful_recovery.TC Teardown
    ...    AND    Restore Resource Search Order
	
	
[1]FM__B_L1Soc_NR_UL_DSP_unsuccessful_recovery_reset_loop_detection
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9000
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044281600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044201600 64 1

    ...    AND    FM__B_L1Soc_NR_UL_DSP_unsuccessful_recovery_reset_loop_detection.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_L1Soc_NR_UL_DSP_unsuccessful_recovery_reset_loop_detection
    TC__FM__B_L1Soc_NR_UL_DSP_unsuccessful_recovery_reset_loop_detection
    [Teardown]    Run Keywords    FM__B_L1Soc_NR_UL_DSP_unsuccessful_recovery_reset_loop_detection.TC Teardown
    ...    AND    Restore Resource Search Order
	
	
[1]FM__BBPOOL_reset_allowBbPoolRecoveryReset_true_faulty_cell
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    200
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID}    6710
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}    BBPOOL autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}    7101
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}    BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...    AND    Set Test Variable    ${SEVERITY}    Warning
	
    ...    AND    FM__BBPOOL_reset_allowBbPoolRecoveryReset_true_faulty_cell.TC Setup
    ...    AND    Modify Resource Search Order    FM__BBPOOL_reset_allowBbPoolRecoveryReset_true_faulty_cell
    TC__FM__BBPOOL_reset_allowBbPoolRecoveryReset_true_faulty_cell
    [Teardown]    Run Keywords    FM__BBPOOL_reset_allowBbPoolRecoveryReset_true_faulty_cell.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__C_Capacity_core_unit_5G_L3_SW_reset_escalation
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELLS_FAILED_TIMEOUT}    180
    ...    AND    Set Test Variable    ${CELLS_ONLINE_TIMEOUT}    600
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIO
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID}    4383
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}    Internal BTS processes autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_RAT_RESET}    RAT autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}    7101
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}    BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...    AND    Set Test Variable    ${SEVERITY}    Warning

    ...    AND    FM__C_Capacity_core_unit_5G_L3_SW_reset_escalation.TC Setup
    ...    AND    Modify Resource Search Order    FM__C_Capacity_core_unit_5G_L3_SW_reset_escalation
    TC__FM__C_Capacity_core_unit_5G_L3_SW_reset_escalation
    [Teardown]    Run Keywords    FM__C_Capacity_core_unit_5G_L3_SW_reset_escalation.TC Teardown
    ...    AND    Restore Resource Search Order
	

[1]FM__C_L1Soc_NR_DL_DSP_successful_recovery
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9101
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${HW_VARIANT}    Loki
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E044181600 64 1

    ...    AND    FM__C_L1Soc_NR_DL_DSP_successful_recovery.TC Setup
    ...    AND    Modify Resource Search Order    FM__C_L1Soc_NR_DL_DSP_successful_recovery
    TC__FM__C_L1Soc_NR_DL_DSP_successful_recovery
    [Teardown]    Run Keywords    FM__C_L1Soc_NR_DL_DSP_successful_recovery.TC Teardown
    ...    AND    Restore Resource Search Order
	

[1]FM__C_L1Soc_NR_DL_DSP_unsuccessful_recovery_reset_loop_detection
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9000
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${UNIT_TYPE}    ABIO
    ...    AND    Set Test Variable    ${CRASH_COMMAND}    devmem 0x87E0441C1600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044E01600 64 1

    ...    AND    FM__C_L1Soc_NR_DL_DSP_unsuccessful_recovery_reset_loop_detection.TC Setup
    ...    AND    Modify Resource Search Order    FM__C_L1Soc_NR_DL_DSP_unsuccessful_recovery_reset_loop_detection
    TC__FM__C_L1Soc_NR_DL_DSP_unsuccessful_recovery_reset_loop_detection
    [Teardown]    Run Keywords    FM__C_L1Soc_NR_DL_DSP_unsuccessful_recovery_reset_loop_detection.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${CELLS_FAILED_TIMEOUT}    180
    ...    AND    Set Test Variable    ${CELLS_ONLINE_TIMEOUT}    600
    ...    AND    Set Test Variable    ${MODULE_TYPE}    ABIO
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    180
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID}    4383
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}    Internal BTS processes autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_RAT_RESET}    RAT autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}    7101
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}    BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...    AND    Set Test Variable    ${SEVERITY}    Warning

    ...    AND    FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation.TC Setup
    ...    AND    Modify Resource Search Order    FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    TC__FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation
    [Teardown]    Run Keywords    FM__E_Capacity_core_unit_5G_L2_RT_SW_reset_escalation.TC Teardown
    ...    AND    Restore Resource Search Order
	

[1]FM__FID4383_fault_signature_active_UP_4G_L2_process_crashed
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIN
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID}    4383
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}    Internal BTS processes autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}    7101
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}    BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...    AND    Set Test Variable    ${SEVERITY}    Warning
	
    ...    AND    FM__FID4383_fault_signature_active_UP_4G_L2_process_crashed.TC Setup
    ...    AND    Modify Resource Search Order    FM__FID4383_fault_signature_active_UP_4G_L2_process_crashed
    TC__FM__FID4383_fault_signature_active_UP_4G_L2_process_crashed
    [Teardown]    Run Keywords    FM__FID4383_fault_signature_active_UP_4G_L2_process_crashed.TC Teardown
    ...    AND    Restore Resource Search Order
	

[1]FM__FID4383_fault_signature_active_UP_5G_L2_process_crashed
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIO
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID}    4383
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}    Internal BTS processes autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}    7101
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}    BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...    AND    Set Test Variable    ${SEVERITY}    Warning
	
    ...    AND    FM__FID4383_fault_signature_active_UP_5G_L2_process_crashed.TC Setup
    ...    AND    Modify Resource Search Order    FM__FID4383_fault_signature_active_UP_5G_L2_process_crashed
    TC__FM__FID4383_fault_signature_active_UP_5G_L2_process_crashed
    [Teardown]    Run Keywords    FM__FID4383_fault_signature_active_UP_5G_L2_process_crashed.TC Teardown
    ...    AND    Restore Resource Search Order
	

[1]FM__FSP_common_reset_counter_exceeded
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIO
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    900
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    600
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    120
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    60
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID}    2078
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}    7101
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID_SECOND}    7100
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}    Baseband card autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_SECOND}    Baseband card power autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_THIRD}    Eeprom read error
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}    BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME_SECOND}    BASE STATION HARDWARE PROBLEM
    ...    AND    Set Test Variable    ${SEVERITY_1}    Warning
    ...    AND    Set Test Variable    ${SEVERITY_2}    Critical
	
    ...    AND    FM__FSP_common_reset_counter_exceeded.TC Setup
    ...    AND    Modify Resource Search Order    FM__FSP_common_reset_counter_exceeded
    TC__FM__FSP_common_reset_counter_exceeded
    [Teardown]    Run Keywords    FM__FSP_common_reset_counter_exceeded.TC Teardown
    ...    AND    Restore Resource Search Order
	

[1]FM__link_break_GTPU
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    FM__Link_break_GTPU.TC Setup
    ...    AND    Modify Resource Search Order    FM__Link_break_GTPU
    TC__FM__Link_break_GTPU
    [Teardown]    Run Keywords    FM__Link_break_GTPU.TC Teardown
    ...    AND    Restore Resource Search Order
	

[1]FM__Primary core power off-on - fault signature
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    120
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID_FIRST}    4590
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID_SECOND}    4592
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_FIRST}    Fault signature for crash or failure
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_SECOND}    BTS Reset Cause
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}    7115
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}    BASE STATION INFORMATION
    ...    AND    Set Test Variable    ${SEVERITY}    Warning
    ...    AND    Set Test Variable    ${EXPECTED_SCOPE}    Site
    ...    AND    Set Test Variable    ${EXPECTED_CATEGORY_1}    POWER_OFF
    ...    AND    Set Test Variable    ${EXPECTED_CATEGORY_2}    POWER_OFF
    ...    AND    Set Test Variable    ${EXPECTED_INFO_1}    Unknown power reset. Possible causes e.g. HW watchdog or external power off/on cycle
    ...    AND    Set Test Variable    ${EXPECTED_INFO_2}    Power off/on reset

    ...    AND    FM__Primary_core_power_off_on.TC Setup
    ...    AND    Modify Resource Search Order    FM__Primary_core_power_off_on
    TC__FM__Primary_core_power_off_on
    [Teardown]    Run Keywords    FM__Primary_core_power_off_on.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__SC_late_startup_actForceAutoReset_true
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    360
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600

    ...    AND    FM__SC_late_startup_actForceAutoReset_true.TC Setup
    ...    AND    Modify Resource Search Order    FM__SC_late_startup_actForceAutoReset_true
    TC__FM__SC_Late_Startup_actForce_True
    [Teardown]    Run Keywords    FM__SC_late_startup_actForceAutoReset_true.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__SC_reset_counter_cleared_-_manual_site_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${PING_TIMEOUT}    120

    ...    AND    FM__SC_reset_counter_cleared_manual_site_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__SC_reset_counter_cleared_manual_site_reset
    TC__FM__SC_reset_counter_cleared_manual_site_reset
    [Teardown]    Run Keywords    FM__SC_reset_counter_cleared_manual_site_reset.TC Teardown
    ...    AND    Restore Resource Search Order
	

[1]FM__Secondary_core_power_off_on
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    360

    ...    AND    FM__Secondary_core_power_off_on.TC Setup
    ...    AND    Modify Resource Search Order    FM__Secondary_core_power_off_on
    TC__FM__Secondary_core_power_off_on
    [Teardown]    Run Keywords    FM__Secondary_core_power_off_on.TC Teardown
    ...    AND    Restore Resource Search Order
	

[1]LTE3342_Improved_combined_FM_Service_with_multiple_alarms
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    60

    ...    AND    FM__Improved_combined_FM_service_with_multiple_alarms.TC Setup
    ...    AND    Modify Resource Search Order    FM__Improved_combined_FM_service_with_multiple_alarms
    TC__FM__Improved_combined_FM_service_with_multiple_alarms
    [Teardown]    Run Keywords    FM__Improved_combined_FM_service_with_multiple_alarms.TC Teardown
    ...    AND    Restore Resource Search Order
	

[1]LTE656 - Suppression of toggling external alarm
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    FM__Suppression_of_toggling_external_alarm.TC Setup
    ...    AND    Modify Resource Search Order    FM__Suppression_of_toggling_external_alarm
    TC__FM__Suppression_of_toggling_external_alarm
    [Teardown]    Run Keywords    FM__Suppression_of_toggling_external_alarm.TC Teardown
    ...    AND    Restore Resource Search Order
	
	
[1]LTE656 - Suppression of toggling transport alarms
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation

    ...    AND    FM__Suppression_of_toggling_transport_alarms.TC Setup
    ...    AND    Modify Resource Search Order    FM__Suppression_of_toggling_transport_alarms
    TC__FM__Suppression_of_toggling_transport_alarms
    [Teardown]    Run Keywords    FM__Suppression_of_toggling_transport_alarms.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Ping_lost_between_node_CC&S_and_application_FSM_BTSOM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${PROCESS_NAME}    BTSOMexe
    ...    AND    Set Test Variable    ${ENB_ROOT_USER}    toor4nsn
    ...    AND    Set Test Variable    ${ENB_ROOT_PASS}    oZPS0POrRieRtu
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    960

    ...    AND    FM__Ping_lost_between_node_CCandS_and_application_FSM_BTSOM.TC Setup
    ...    AND    Modify Resource Search Order    FM__Ping_lost_between_node_CCandS_and_application_FSM_BTSOM
    TC__FM__Ping_lost_between_node_CCandS_and_application_FSM_BTSOM
    [Teardown]    Run Keywords    FM__Ping_lost_between_node_CCandS_and_application_FSM_BTSOM.TC Teardown
    ...    AND    Restore Resource Search Order
	

[1]Ping_lost_between_node_CC&S_and_application_FSM_RROM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{SPURIOUS_RES_APPS}    Create List    BTSOMexe  bm  SysAdapter
    ...    AND    Set Test Variable    ${PROCESS_NAME}    RROMexe
    ...    AND    Set Test Variable    ${ENB_ROOT_USER}    toor4nsn
    ...    AND    Set Test Variable    ${ENB_ROOT_PASS}    oZPS0POrRieRtu

    ...    AND    FM__Ping_lost_between_node_CCandS_and_application_FSM_RROM.TC Setup
    ...    AND    Modify Resource Search Order    FM__Ping_lost_between_node_CCandS_and_application_FSM_RROM
    TC__FM__Ping_lost_between_node_CCandS_and_application_FSM_RROM
    [Teardown]    Run Keywords    FM__Ping_lost_between_node_CCandS_and_application_FSM_RROM.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__FSP_recovery_fault_243_regression
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    360
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600

    ...    AND    FM__FSP_recovery_fault_243.TC Setup
    ...    AND    Modify Resource Search Order    FM__FSP_recovery_fault_243
    TC__FM__FSP_recovery_fault_243
    [Teardown]    Run Keywords    FM__FSP_recovery_fault_243.TC Teardown
    ...    AND    Restore Resource Search Order


[1]CNI-93958-C4_FM_FSP_LOM_Fault_service_crash_handling-ABIA
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIA
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    900

    ...    AND    FM__FSP_Lom_Fault_Service_crash.TC Setup
    ...    AND    Modify Resource Search Order    FM__FSP_Lom_Fault_Service_crash
    TC__FM__FSP_Lom_Fault_Service_crash
    [Teardown]    Run Keywords    FM__FSP_Lom_Fault_Service_crash.TC Teardown
    ...    AND    Restore Resource Search Order


[1]CNI-93958-C4_FM_FSP_LOM_Fault_service_crash_handling-ABIO
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIO
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    900

    ...    AND    FM__FSP_Lom_Fault_Service_crash.TC Setup
    ...    AND    Modify Resource Search Order    FM__FSP_Lom_Fault_Service_crash
    TC__FM__FSP_Lom_Fault_Service_crash
    [Teardown]    Run Keywords    FM__FSP_Lom_Fault_Service_crash.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__LTE_DSP_reset_actForceUnitAutoReset_false_faulty_cells_6709
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    240
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    660

    ...    AND    FM__LTE_DSP_reset_actForceUnitAutoReset_false_faulty_cells_6709.TC Setup
    ...    AND    Modify Resource Search Order    FM__LTE_DSP_reset_actForceUnitAutoReset_false_faulty_cells_6709
    TC__FM__LTE_DSP_reset_actForceUnitAutoReset_false_faulty_cells_6709
    [Teardown]    Run Keywords    FM__LTE_DSP_reset_actForceUnitAutoReset_false_faulty_cells_6709.TC Teardown
    ...    AND    Restore Resource Search Order
