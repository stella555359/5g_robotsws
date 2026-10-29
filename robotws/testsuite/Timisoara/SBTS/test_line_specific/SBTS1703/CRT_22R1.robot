*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS22R1  SRAN  CLOUD_SRAN_LW_1FSMF_1FBBC_1FSMF_2FBBC_2FRGX_2FXJB_1AHDB
Library           XML  use_lxml=True
Resource    ../../FM/test_resources/FM__BBMOD_LTE_hot_insert_runtime.robot
Resource    ../../FM/test_resources/FM__BBMOD_hot_remove_transparent_RMOD.robot
Resource    ../../FM/test_resources/FM__FR_spontaneous_reset.robot
Resource    ../../FM/test_resources/FM__GSM_DSP_crash_RAT_recovery_reset.robot
Resource    ../../FM/test_resources/FM__GSM_faults_handling_fault_2412_startup.robot
Resource    ../../FM/test_resources/FM__Iub_CNBAP_link_break.robot
Resource    ../../FM/test_resources/FM__Iub_DNBAP_link_break.robot
Resource    ../../FM/test_resources/FM__LTE_CCplane_crash_RAT_recovery_reset.robot
Resource    ../../FM/test_resources/FM__LTE_DSP_crash_DSP_recovery_reset.robot
Resource    ../../FM/test_resources/FM__LTE_L3_crash_VN_recovery_reset.robot
Resource    ../../FM/test_resources/FM__Primary_core_power_off_on.robot
Resource    ../../FM/test_resources/FM__RAT_recovery_reset_counter_cleared_manual_site_reset.robot
Resource    ../../FM/test_resources/FM__RAT_reset_actForceAutoReset_false_degraded_cell.robot
Resource    ../../FM/test_resources/FM__RAT_reset_actForceAutoReset_false_faulty_cells.robot
Resource    ../../FM/test_resources/FM__RAT_reset_actForceAutoReset_true_enabled_cells.robot
Resource    ../../FM/test_resources/FM__RAT_reset_counter_exceeded__multi_RAT.robot
Resource    ../../FM/test_resources/FM__RF_hot_remove_hot_insert.robot
Resource    ../../FM/test_resources/FM__RF_module_alarm_cancel_fault_1907.robot
Resource    ../../FM/test_resources/FM__RF_module_alarm_with_reco_reset.robot
Resource    ../../FM/test_resources/FM__RMOD_hot_remove_hot_insert_long_fibers.robot
Resource    ../../FM/test_resources/FM__SC_hot_remove_hot_insert.robot
Resource    ../../FM/test_resources/FM__SC_late_startup_actForceAutoReset_true.robot
Resource    ../../FM/test_resources/FM__Site_reset_counter_cleared_timer_exceeded.robot
Resource    ../../FM/test_resources/FM__Site_reset_counter_exceeded.robot
Resource    ../../FM/test_resources/FM__Site_reset_recovery_counter_cleared_-_manual_site_reset.robot
Resource    ../../FM/test_resources/FM__VN_CCplane_LTE_reset_counter_exceeded.robot
Resource    ../../FM/test_resources/FM__VN_reset_counter_exceeded.robot
Resource    ../../FM/test_resources/FM__WCDMA_Cplane_fault_RAT_recovery_reset.robot
Resource    ../../FM/test_resources/FM__WCDMA_DSP_crash_RAT_recovery_reset.robot
Resource    ../../FM/test_resources/FM__WCDMA_VN_crash_RAT_recovery_reset.robot
Resource    ../../FM/test_resources/FM__fault_handling_LTE_CPlane.robot
Resource    ../../FM/test_resources/FM__link_break_Abis_long.robot
Resource    ../../FM/test_resources/FM__link_break_Abis_short.robot
Resource    ../../FM/test_resources/FM__link_break_Abis_startup.robot
Resource    ../../FM/test_resources/FM__link_break_IuB_CNBAP_short.robot
Resource    ../../FM/test_resources/FM__link_break_IuB_DNBAP_short.robot
Resource    ../../FM/test_resources/FM__link_break_IuB_long.robot
Resource    ../../FM/test_resources/FM__link_break_IuB_short.robot
Resource    ../../FM/test_resources/FM__link_break_IuB_startup.robot
Resource    ../../FM/test_resources/FM__link_break_S1_long.robot
Resource    ../../FM/test_resources/FM__link_break_S1_short.robot
Resource    ../../FM/test_resources/FM__link_break_SBTS_long.robot
Resource    ../../FM/test_resources/FM__link_break_SBTS_short.robot
Resource    ../../CIT/test_resources/SWM__SCF_validation_errors_check.robot


*** Variables ***
${SCF_ID}    01


*** Test Cases ***
[1]SWM__SCF_validation_errors_check
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${SKIP_PARAM_RELATION_ERRORS}    ${TRUE}
    
    ...    AND    SWM__SCF_validation_errors_check.TC Setup
    ...    AND    Modify Resource Search Order    SWM__SCF_validation_errors_check
    TC__SWM__SCF_validation_errors_check
    [Teardown]    Run Keywords    SWM__SCF_validation_errors_check.TC Teardown
    ...    AND    Restore Resource Search Order


[1][1.0] Automated__FM__link_break_IuB_CNBAP_short
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NUMBER_OF_LOOPS}    10
    
    ...    AND    FM__link_break_IuB_CNBAP_short.TC Setup
    ...    AND    Modify Resource Search Order    FM__link_break_IuB_CNBAP_short
    TC__FM__link_break_IuB_CNBAP_short
    [Teardown]    Run Keywords    FM__link_break_IuB_CNBAP_short.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__link_break_IuB_startup
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Timer}    600
    
    ...    AND    FM__link_break_IuB_startup.TC Setup
    ...    AND    Modify Resource Search Order    FM__link_break_IuB_startup
    TC__FM__link_break_IuB_startup
    [Teardown]    Run Keywords    FM__link_break_IuB_startup.TC Teardown
    ...    AND    Restore Resource Search Order


[1][1.0] Automated__FM__RF_module_alarm_with_reco_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER}    ${EMPTY}
    ...    AND    Set Test Variable    ${CARRIERS_RESTORE_TIMEOUT}    180
    ...    AND    Set Test Variable    ${Active_Carriers_Before}    0
    ...    AND    Set Test Variable    ${Active_Carriers_After}    0
    
    ...    AND    FM__RF_module_alarm_with_reco_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__RF_module_alarm_with_reco_reset
    TC__FM__RF_module_alarm_with_reco_reset
    [Teardown]    Run Keywords    FM__RF_module_alarm_with_reco_reset.TC Teardown
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


[1]Automated__FM__BBMOD_hot_remove_transparent_RMOD
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_L_DIST_NAME}    /MRBTS-1/RAT-1/BTS_L-4/EQM_L-1/CABINET_L-1/BBMOD_L-1
    
    ...    AND    FM__BBMOD_hot_remove_transparent_RMOD.TC Setup
    ...    AND    Modify Resource Search Order    FM__BBMOD_hot_remove_transparent_RMOD
    TC__FM__BBMOD_hot_remove_transparent_RMOD
    [Teardown]    Run Keywords    FM__BBMOD_hot_remove_transparent_RMOD.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__BBMOD_LTE_hot_insert_runtime
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    
    ...    AND    FM__BBMOD_LTE_hot_insert_runtime.TC Setup
    ...    AND    Modify Resource Search Order    FM__BBMOD_LTE_hot_insert_runtime
    TC__FM__BBMOD_LTE_hot_insert_runtime
    [Teardown]    Run Keywords    FM__BBMOD_LTE_hot_insert_runtime.TC Teardown
    ...    AND    Restore Resource Search Order


[1][1.0] FM__RAT_reset_actForceAutoReset_false_degraded_cell
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    EA163510243
    ...    AND    Set Test Variable    ${FAULT_ID}    1907
    ...    AND    Set Test Variable    ${ANTL}    1
    
    ...    AND    FM__RAT_reset_actForceAutoReset_false_degraded_cell.TC Setup
    ...    AND    Modify Resource Search Order    FM__RAT_reset_actForceAutoReset_false_degraded_cell
    TC__FM__RAT_reset_actForceAutoReset_false_degraded_cell
    [Teardown]    Run Keywords    FM__RAT_reset_actForceAutoReset_false_degraded_cell.TC Teardown
    ...    AND    Restore Resource Search Order


[1][1.0] FM__SC_late_startup_actForceAutoReset_true
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


[1]FM__Primary_Core_power_off_on
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    @{EXPECTED_FAULT_ID}    4592
    ...    AND    Set Test Variable    @{EXPECTED_FAULT_NAME}    BTS Reset Cause
    ...    AND    Set Test Variable    @{EXPECTED_ALARM_ID}    7115
    ...    AND    Set Test Variable    @{EXPECTED_ALARM_NAME}    BASE STATION INFORMATION
    ...    AND    Set Test Variable    @{SEVERITY}    warning
    
    ...    AND    FM__Primary_core_power_off_on.TC Setup
    ...    AND    Modify Resource Search Order    FM__Primary_core_power_off_on
    TC__FM__Primary_Core_power_off_on
    [Teardown]    Run Keywords    FM__Primary_core_power_off_on.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__link_break_IuB_CNBAP
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NUMBER_OF_LOOPS}    1
    
    ...    AND    FM__Iub_CNBAP_link_break.TC Setup
    ...    AND    Modify Resource Search Order    FM__Iub_CNBAP_link_break
    TC__FM__Iub_CNBAP_link_break
    [Teardown]    Run Keywords    FM__Iub_CNBAP_link_break.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__link_break_IuB_DNBAP
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NUMBER_OF_LOOPS}    1
    
    ...    AND    FM__Iub_DNBAP_link_break.TC Setup
    ...    AND    Modify Resource Search Order    FM__Iub_DNBAP_link_break
    TC__FM__Iub_DNBAP_link_break
    [Teardown]    Run Keywords    FM__Iub_DNBAP_link_break.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__link_break_IuB_DNBAP_short
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NUMBER_OF_LOOPS}    10
    
    ...    AND    FM__link_break_IuB_DNBAP_short.TC Setup
    ...    AND    Modify Resource Search Order    FM__link_break_IuB_DNBAP_short
    TC__FM__link_break_IuB_DNBAP_short
    [Teardown]    Run Keywords    FM__link_break_IuB_DNBAP_short.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__link_break_IuB_short
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NUMBER_OF_LOOPS}    3
    
    ...    AND    FM__link_break_IuB_short.TC Setup
    ...    AND    Modify Resource Search Order    FM__link_break_IuB_short
    TC__FM__link_break_IuB_short
    [Teardown]    Run Keywords    FM__link_break_IuB_short.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__link_break_IuB_long
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    
    ...    AND    FM__link_break_IuB_long.TC Setup
    ...    AND    Modify Resource Search Order    FM__link_break_IuB_long
    TC__FM__link_break_IuB_long
    [Teardown]    Run Keywords    FM__link_break_IuB_long.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__link_break_S1_short
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NUMBER_OF_LOOPS}    3
    
    ...    AND    FM__link_break_S1_short.TC Setup
    ...    AND    Modify Resource Search Order    FM__link_break_S1_short
    TC__FM__link_break_S1_short
    [Teardown]    Run Keywords    FM__link_break_S1_short.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__link_break_S1_long
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    
    ...    AND    FM__link_break_S1_long.TC Setup
    ...    AND    Modify Resource Search Order    FM__link_break_S1_long
    TC__FM__link_break_s1_long
    [Teardown]    Run Keywords    FM__link_break_S1_long.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__link_break_Abis_short
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NUMBER_OF_LOOPS}    3
    
    ...    AND    FM__link_break_Abis_short.TC Setup
    ...    AND    Modify Resource Search Order    FM__link_break_Abis_short
    TC__FM__link_break_Abis_short
    [Teardown]    Run Keywords    FM__link_break_Abis_short.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__link_break_Abis_long
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    
    ...    AND    FM__link_break_Abis_long.TC Setup
    ...    AND    Modify Resource Search Order    FM__link_break_Abis_long
    TC__FM__link_break_Abis_long
    [Teardown]    Run Keywords    FM__link_break_Abis_long.TC Teardown
    ...    AND    Restore Resource Search Order


[1][1.0] Automated__FM__link_break_SBTS_short
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${NUMBER_OF_LOOPS}    3
    
    ...    AND    FM__link_break_SBTS_short.TC Setup
    ...    AND    Modify Resource Search Order    FM__link_break_SBTS_short
    TC__FM__link_break_SBTS_short
    [Teardown]    Run Keywords    FM__link_break_SBTS_short.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__link_break_SBTS_long
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    
    ...    AND    FM__link_break_SBTS_long.TC Setup
    ...    AND    Modify Resource Search Order    FM__link_break_SBTS_long
    TC__FM__link_break_SBTS_long
    [Teardown]    Run Keywords    FM__link_break_SBTS_long.TC Teardown
    ...    AND    Restore Resource Search Order


[1][1.0] Automated__FM__RMOD_spontaneous_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${TESTED_RMOD_SN}    
    
    ...    AND    FM__FR_spontaneous_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__FR_spontaneous_reset
    TC__FM__FR_spontaneous_reset
    [Teardown]    Run Keywords    FM__FR_spontaneous_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__GSM_faults_handling_fault_2412
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    
    ...    AND    FM__GSM_faults_handling_fault_2412_startup.TC Setup
    ...    AND    Modify Resource Search Order    FM__GSM_faults_handling_fault_2412_startup
    TC__FM__GSM_faults_handling_fault_2412_startup
    [Teardown]    Run Keywords    FM__GSM_faults_handling_fault_2412_startup.TC Teardown
    ...    AND    Restore Resource Search Order


[1][1.0] Automated__FM__RMOD_fault_without_recovery
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    
    ...    AND    Set Test Variable    ${FAULT_ID}    1907
    ...    AND    Set Test Variable    ${ANTL}    1
    
    ...    AND    FM__RF_module_alarm_cancel_fault_1907.TC Setup
    ...    AND    Modify Resource Search Order    FM__RF_module_alarm_cancel_fault_1907
    TC__FM__RF_module_alarm_cancel_fault_1907
    [Teardown]    Run Keywords    FM__RF_module_alarm_cancel_fault_1907.TC Teardown
    ...    AND    Restore Resource Search Order


[1][1.0] Automated__FM__RMOD_hot_remove_hot_insert
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    EA163510243
    ...    AND    Set Test Variable    ${PING_RMOD_TIMEOUT}    300
    ...    AND    Set Test Variable    ${CELLS_ONLINE_TIMEOUT}    300
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID}    10
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}    No connection to unit
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}    7116
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}    BASE STATION SERVICE PROBLEM
    ...    AND    Set Test Variable    ${SEVERITY}    Critical
    ...    AND    Set Test Variable    ${CHECK_NA_ALARM}    True
    
    ...    AND    FM__RF_hot_remove_hot_insert.TC Setup
    ...    AND    Modify Resource Search Order    FM__RF_hot_remove_hot_insert
    TC__FM__RF_hot_remove_hot_insert
    [Teardown]    Run Keywords    FM__RF_hot_remove_hot_insert.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__RAT_reset_counter_exceeded__multi_RAT
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    360
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    
    ...    AND    FM__RAT_reset_counter_exceeded__multi_RAT.TC Setup
    ...    AND    Modify Resource Search Order    FM__RAT_reset_counter_exceeded__multi_RAT
    TC__FM__RAT_reset_counter_exceeded_multi_RAT
    [Teardown]    Run Keywords    FM__RAT_reset_counter_exceeded__multi_RAT.TC Teardown
    ...    AND    Restore Resource Search Order


[1][1.0] Automated__FM__WCDMA_DSP_crash_RAT_recovery_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    
    ...    AND    FM__WCDMA_DSP_crash_RAT_recovery_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__WCDMA_DSP_crash_RAT_recovery_reset
    TC__FM__WCDMA_DSP_crash_RAT_recovery_reset
    [Teardown]    Run Keywords    FM__WCDMA_DSP_crash_RAT_recovery_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1][1.0] Automated__FM__WCDMA_CPlane_fault_RAT_recovery_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    
    ...    AND    FM__WCDMA_Cplane_fault_RAT_recovery_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__WCDMA_Cplane_fault_RAT_recovery_reset
    TC__FM__WCDMA_Cplane_fault_RAT_recovery_reset
    [Teardown]    Run Keywords    FM__WCDMA_Cplane_fault_RAT_recovery_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__LTE_L3_crash_VN_recovery_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    360
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    
    ...    AND    FM__LTE_L3_crash_VN_recovery_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__LTE_L3_crash_VN_recovery_reset
    TC__FM___LTE_L3_crash_VN_recovery_reset
    [Teardown]    Run Keywords    FM__LTE_L3_crash_VN_recovery_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__LTE_DSP_crash_DSP_recovery_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    350
    
    ...    AND    FM__LTE_DSP_crash_DSP_recovery_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__LTE_DSP_crash_DSP_recovery_reset
    TC__FM__LTE_DSP_crash_DSP_recovery_reset
    [Teardown]    Run Keywords    FM__LTE_DSP_crash_DSP_recovery_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1][1.0] Automated__FM__Site_reset_counter_exceeded
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


[1]Automated__FM__SC_hot_remove_hot_insert
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    360
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    
    ...    AND    FM__SC_hot_remove_hot_insert.TC Setup
    ...    AND    Modify Resource Search Order    FM__SC_hot_remove_hot_insert
    TC__FM__SC_hot_remove_hot_insert
    [Teardown]    Run Keywords    FM__SC_hot_remove_hot_insert.TC Teardown
    ...    AND    Restore Resource Search Order


[1][1.0] Automated__FM__VN_CCplane_LTE_reset_counter_exceeded
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


[1]Automated__FM__link_break_Abis_startup
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${Timer}    600
    
    ...    AND    FM__link_break_Abis_startup.TC Setup
    ...    AND    Modify Resource Search Order    FM__link_break_Abis_startup
    TC__FM__link_break_Abis_startup
    [Teardown]    Run Keywords    FM__link_break_Abis_startup.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__GSM_DSP_crash_RAT_recovery_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    360
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    @{EXPECTED_FAULT_ID}    6707    6708    6709    4019
    ...    AND    Set Test Variable    @{EXPECTED_FAULT_NAME}    RAT autonomous reset as recovery action
    ...    AND    Set Test Variable    @{EXPECTED_ALARM_ID}    7101
    ...    AND    Set Test Variable    @{EXPECTED_ALARM_NAME}    BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...    AND    Set Test Variable    @{SEVERITY}    warning
    
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


[1]Automated__FM__fault_handling_LTE_CPlane
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${COMMISSIONING_STATE}    ${FALSE}
    
    ...    AND    FM__fault_handling_LTE_CPlane.TC Setup
    ...    AND    Modify Resource Search Order    FM__fault_handling_LTE_CPlane
    TC__FM__fault_handling_LTE_CPlane
    [Teardown]    Run Keywords    FM__fault_handling_LTE_CPlane.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__Site_reset_counter_cleared__manual_site_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${PING_TIMEOUT}    120
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    
    ...    AND    FM__Site_reset_recovery_counter_cleared_-_manual_site_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__Site_reset_recovery_counter_cleared_-_manual_site_reset
    TC__FM__Site_reset_recovery_counter_cleared_-_manual_site_reset
    [Teardown]    Run Keywords    FM__Site_reset_recovery_counter_cleared_-_manual_site_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__RAT_reset_actForceAutoreset_true_enabled_cell
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    
    ...    AND    FM__RAT_reset_actForceAutoReset_true_enabled_cells.TC Setup
    ...    AND    Modify Resource Search Order    FM__RAT_reset_actForceAutoReset_true_enabled_cells
    TC__FM__RAT_reset_actForceAutoReset_true_enabled_cells
    [Teardown]    Run Keywords    FM__RAT_reset_actForceAutoReset_true_enabled_cells.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__RAT_reset_counter_cleared__manual_site_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    360
    
    ...    AND    FM__RAT_recovery_reset_counter_cleared_manual_site_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__RAT_recovery_reset_counter_cleared_manual_site_reset
    TC__FM__RAT_recovery_reset_counter_cleared_manual_site_reset
    [Teardown]    Run Keywords    FM__RAT_recovery_reset_counter_cleared_manual_site_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__VN_reset_counter_exceeded
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    180
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    300
    
    ...    AND    FM__VN_reset_counter_exceeded.TC Setup
    ...    AND    Modify Resource Search Order    FM__VN_reset_counter_exceeded
    TC__FM__VN_reset_counter_exceeded
    [Teardown]    Run Keywords    FM__VN_reset_counter_exceeded.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__RAT_reset_actForceAutoReset_false_faulty_cells
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    360
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    
    ...    AND    FM__RAT_reset_actForceAutoReset_false_faulty_cells.TC Setup
    ...    AND    Modify Resource Search Order    FM__RAT_reset_actForceAutoReset_false_faulty_cells
    TC__FM__RAT_reset_actForceAutoReset_false_faulty_cells
    [Teardown]    Run Keywords    FM__RAT_reset_actForceAutoReset_false_faulty_cells.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__Site_reset_counter_cleared__timer_exceeded
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${PING_TIMEOUT}    120
    
    ...    AND    FM__Site_reset_counter_cleared_timer_exceeded.TC Setup
    ...    AND    Modify Resource Search Order    FM__Site_reset_counter_cleared_timer_exceeded
    TC__FM__Site_reset_counter_cleared_timer_exceeded
    [Teardown]    Run Keywords    FM__Site_reset_counter_cleared_timer_exceeded.TC Teardown
    ...    AND    Restore Resource Search Order


[1][1.0] FM__RMOD_hot_remove_hot_insert_long_fibers
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_SN}    6Q190905756
    ...    AND    Set Test Variable    ${MIN_FIBER_LENGTH}    10000
    ...    AND    Set Test Variable    ${PING_TIMEOUT}    1200
    
    ...    AND    FM__RMOD_hot_remove_hot_insert_long_fibers.TC Setup
    ...    AND    Modify Resource Search Order    FM__RMOD_hot_remove_hot_insert_long_fibers
    TC__FM__RMOD_hot_remove_hot_insert_long_fibers.robot
    [Teardown]    Run Keywords    FM__RMOD_hot_remove_hot_insert_long_fibers.TC Teardown
    ...    AND    Restore Resource Search Order



*** Keywords ***
