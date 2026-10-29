*** Settings ***
Resource    ../../CIT/test_resources/STATE__Site_reset.robot
Resource    ../../FM/test_resources/FM__5G_BBMOD_unit_recovery_reset_counter_exceeded.robot
Resource    ../../FM/test_resources/FM__B_5G_RAT_reset_counter_cleared__manual_site_reset.robot
Resource    ../../FM/test_resources/FM__5G_cell_graceful_shutdown_when_SC_escalates_to_site_reset.robot
Resource    ../../FM/test_resources/FM__Activate_Deactivate_EnhX2LinkSupervision.robot
Resource    ../../FM/test_resources/FM__BBPOOL_reset_allowBbPoolRecoveryReset_true_faulty_cell.robot
Resource    ../../FM/test_resources/FM__FSP_recovery_fault_243.robot
Resource    ../../FM/test_resources/FM__GSM_DSP_crash_RAT_recovery_reset.robot
Resource    ../../FM/test_resources/FM__LTE_DSP_reset_actForceUnitAutoReset_false_faulty_cells_6709.robot
Resource    ../../FM/test_resources/FM__Primary_core_power_off_on.robot
Resource    ../../FM/test_resources/FM__RAT_reset_counter_exceeded__multi_RAT.robot
Resource    ../../FM/test_resources/FM__SC_late_startup_actForceAutoReset_true.robot
Resource    ../../FM/test_resources/FM__SC_reset_actForceAutoReset_false_faulty_cells.robot
Resource    ../../FM/test_resources/FM__SC_reset_counter_cleared_manual_site_reset.robot
Resource    ../../FM/test_resources/FM__fault_handling_WCDMA_UPlane.robot
Resource    ../../FM/test_resources/FM__RMOD_reset_counter_exceeded_FID1907.robot
Resource    ../../FM/test_resources/FM__RMOD_crash_fault_signature_check.robot
Resource    ../../FM/test_resources/FM__C_L1Soc_NR_DL_DSP_unsuccessful_recovery_reset_loop_detection.robot
Resource    ../../FM/test_resources/FM__FID4383_fault_signature_active_5G_RT_NRT_process.robot
Resource    ../../FM/test_resources/FM__RMOD_crash_FID4590.robot
Resource    ../../FM/test_resources/FM__Site_reset_counter_exceeded.robot


Documentation  CRT Trunk suite for SBTS 10723.


*** Variables ***
${SCF_ID}    01


*** Test Cases ***
[1]Automated__FM__GSM_DSP_crash_RAT_recovery_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    360
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    @{EXPECTED_FAULT_ID}    6707    6708    6709    4019
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}    RAT autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}    7101
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}    BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...    AND    Set Test Variable    ${SEVERITY}    warning
    ...    AND    FM__GSM_DSP_crash_RAT_recovery_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__GSM_DSP_crash_RAT_recovery_reset
    TC__FM__GSM_DSP_crash_RAT_recovery_reset
    [Teardown]    Run Keywords    FM__GSM_DSP_crash_RAT_recovery_reset.TC Teardown
    ...    AND    Restore Resource Search Order



[1]FM__Primary_Core_power_off_on
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    120
    ...    AND    FM__Primary_core_power_off_on.TC Setup
    ...    AND    Modify Resource Search Order    FM__Primary_core_power_off_on
    TC__FM__Primary_Core_power_off_on
    [Teardown]    Run Keywords    FM__Primary_core_power_off_on.TC Teardown
    ...    AND    Restore Resource Search Order

[1]FM__BBPOOL_reset_allowBbPoolRecoveryReset_true_faulty_cell
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    200
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    720
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    7600
    ...    AND    FM__BBPOOL_reset_allowBbPoolRecoveryReset_true_faulty_cell.TC Setup
    ...    AND    Modify Resource Search Order    FM__BBPOOL_reset_allowBbPoolRecoveryReset_true_faulty_cell
    TC__FM__BBPOOL_reset_allowBbPoolRecoveryReset_true_faulty_cell
    [Teardown]    Run Keywords    FM__BBPOOL_reset_allowBbPoolRecoveryReset_true_faulty_cell.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__LTE_DSP_reset_actForceUnitAutoReset_false_faulty_cells_6709
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    240
    ...    AND    FM__LTE_DSP_reset_actForceUnitAutoReset_false_faulty_cells_6709.TC Setup
    ...    AND    Modify Resource Search Order    FM__LTE_DSP_reset_actForceUnitAutoReset_false_faulty_cells_6709
    TC__FM__LTE_DSP_reset_actForceUnitAutoReset_false_faulty_cells_6709
    [Teardown]    Run Keywords    FM__LTE_DSP_reset_actForceUnitAutoReset_false_faulty_cells_6709.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__B_5G_RAT_reset_counter_cleared__manual_site
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    360
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    660
    ...    AND    FM__B_5G_RAT_reset_counter_cleared__manual_site_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__B_5G_RAT_reset_counter_cleared__manual_site_reset
    TC__FM__B_5G_RAT_reset_counter_cleared__manual_site_reset
    [Teardown]    Run Keywords    FM__B_5G_RAT_reset_counter_cleared__manual_site_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__fault_handling_WCDMA_UPlane
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${TIMEOUT}    600s
    ...    AND    FM__fault_handling_WCDMA_UPlane.TC Setup
    ...    AND    Modify Resource Search Order    FM__fault_handling_WCDMA_UPlane
    TC__FM__fault_handling_WCDMA_UPlane
    [Teardown]    Run Keywords    FM__fault_handling_WCDMA_UPlane.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__5G_cell_graceful_shutdown_and_Default_System_Time_check
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${PING_TIMEOUT}    120
    ...    AND    FM__5G_cell_graceful_shutdown_when_SC_escalates_to_site_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__5G_cell_graceful_shutdown_when_SC_escalates_to_site_reset
    TC__FM__5G_cell_graceful_shutdown_when_SC_escalates_to_site_reset
    [Teardown]    Run Keywords    FM__5G_cell_graceful_shutdown_when_SC_escalates_to_site_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__Trigger_fault_243_on_BB_card
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    120
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    300
    ...    AND    FM__FSP_recovery_fault_243.TC Setup
    ...    AND    Modify Resource Search Order    FM__FSP_recovery_fault_243
    TC__FM__FSP_recovery_fault_243
    [Teardown]    Run Keywords    FM__FSP_recovery_fault_243.TC Teardown
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
    ...    AND    Set Test Variable    ${PING_TIMEOUT}    120
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    1200
    ...    AND    FM__SC_reset_counter_cleared_manual_site_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__SC_reset_counter_cleared_manual_site_reset
    TC__FM__SC_reset_counter_cleared_manual_site_reset
    [Teardown]    Run Keywords    FM__SC_reset_counter_cleared_manual_site_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__SC_reset_actForceAutoReset_false_faulty_cells
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    FM__SC_reset_actForceAutoReset_false_faulty_cells.TC Setup
    ...    AND    Modify Resource Search Order    FM__SC_reset_actForceAutoReset_false_faulty_cells
    TC__FM__SC_reset_actForceAutoReset_false_faulty_cells
    [Teardown]    Run Keywords    FM__SC_reset_actForceAutoReset_false_faulty_cells.TC Teardown
    ...    AND    Restore Resource Search Order

[1]FM__RMOD_reset_counter_exceeded_FID1907
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_7_1_GENERATION}    AVQL
    ...    AND    FM__RMOD_reset_counter_exceeded_FID1907.TC Setup
    ...    AND    Modify Resource Search Order    FM__RMOD_reset_counter_exceeded_FID1907
    FM__RMOD_reset_counter_exceeded_FID1907
    [Teardown]    Run Keywords    FM__RMOD_reset_counter_exceeded_FID1907.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__C_L1Soc_NR_DL_DSP_unsuccessful_recovery_reset_loop_detection
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${FAULT_NUMBER}    9000
    ...    AND    Set Test Variable    ${TRIGGER_TYPE}    onFaultDetection
    ...    AND    Set Test Variable    ${RAT_TYPE}    NR
    ...    AND    Set Test Variable    ${RCRASH_COMMAND}    devmem 0x87E0441C1600 64 1
    ...    AND    Set Test Variable    ${CRASH_COMMAND_ABIP}    devmem 0x87E044E01600 64 1
    ...    AND    FM__C_L1Soc_NR_DL_DSP_unsuccessful_recovery_reset_loop_detection.TC Setup
    ...    AND    Modify Resource Search Order    FM__C_L1Soc_NR_DL_DSP_unsuccessful_recovery_reset_loop_detection
    TC__FM__C_L1Soc_NR_DL_DSP_unsuccessful_recovery_reset_loop_detection
    [Teardown]    Run Keywords    FM__C_L1Soc_NR_DL_DSP_unsuccessful_recovery_reset_loop_detection.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__FID4383_fault_signature_active_UP_5G_L2_process_crashed
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    180
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    300
    ...    AND    FM__FID4383_fault_signature_active_5G_RT_NRT_process.TC Setup
    ...    AND    Modify Resource Search Order    FM__FID4383_fault_signature_active_5G_RT_NRT_process
    TC__FM__FID4383_fault_signature_active_5G_RT_NRT_process
    [Teardown]    Run Keywords    FM__FID4383_fault_signature_active_5G_RT_NRT_process.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM_RMOD_power_off_on_FID4589
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_TYPE}    AVQC
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    300
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    600

    ...    AND    FM__RMOD_crash_fault_signature_check.TC setup
    ...    AND    Modify Resource Search Order    FM__RMOD_crash_fault_signature_check
    FM__RMOD_crash_fault_signature_check
    [Teardown]    Run Keywords    FM__RMOD_crash_fault_signature_check.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM_RMOD_crash_FID4590
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_TYPE}   AVQL
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1500
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    120
    ...    AND    FM__RMOD_crash_FID4590.TC Setup
    ...    AND    Modify Resource Search Order    FM__RMOD_crash_FID4590
    TC__FM__RMOD_crash_FID4590
    [Teardown]    Run Keywords    FM__RMOD_crash_FID4590.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__FM__Site_reset_counter_exceeded
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    360
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600

    ...    AND    FM__Site_reset_counter_exceeded.TC Setup
    ...    AND    Modify Resource Search Order    FM__Site_reset_counter_exceeded
    TC__FM__Site_reset_counter_exceeded
    [Teardown]    Run Keywords    FM__Site_reset_counter_exceeded.TC Teardown
    ...    AND    Restore Resource Search Order




*** Keywords ***
Set additional ignored alarms variable
    ${ADDITIONAL_IGNORED_ALARMS}  Catenate
    ...  [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220'], ['faultId', '7300', 'alarmId', '7107'],
    ...  ['faultId', '7319', 'alarmId', '7107'], ['faultId', '6327', 'alarmId', '7107'], ['faultId', '4527', 'alarmId', '7115']]
    Set test variable ${ADDITIONAL_IGNORED_ALARMS}
