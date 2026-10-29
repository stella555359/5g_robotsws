*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SRAN  CLOUD_SRAN_LWG_10227_2ASIA_6ABIA_2FXEA_1FXED_1FXDD_1FXDA_2FRGP_3FRHB_1FRMC  STATE_COMMISSIONED
Library           XML  use_lxml=True
Resource    ../../FM/test_resources/FM__GSM_DSP_crash_RAT_recovery_reset.robot
Resource    ../../FM/test_resources/FM__RAT_reset_counter_exceeded__multi_RAT.robot
Resource    ../../FM/test_resources/FM__LTE_DSP_reset_actForceUnitAutoReset_false_faulty_cells_6709.robot
Resource    ../../FM/test_resources/FM__SC_late_startup_actForceAutoReset_false.robot
Resource    ../../FM/test_resources/FM__BBPOOL_reset_allowBbPoolRecoveryReset_true_faulty_cell.robot
Resource    ../../FM/test_resources/FM__Primary_core_power_off_on.robot

Suite Setup      Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso   ca_CIT_general   ca_swm_general

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${ENB_BUILD}    SBTS00_ENB_9999_211207_000006
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1227
${SKIP_RU_POWER_CHECK}    ${TRUE}

*** Test Cases ***
[1]Automated__FM__GSM_DSP_crash_RAT_recovery_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    360
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    
    ...    AND    FM__GSM_DSP_crash_RAT_recovery_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__GSM_DSP_crash_RAT_recovery_reset
    TC__FM__GSM_DSP_crash_RAT_recovery_reset
    [Teardown]    Run Keywords    FM__GSM_DSP_crash_RAT_recovery_reset.TC Teardown
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
    ...    AND    Set Test Variable    ${SEVERITY}    warning
    
    ...    AND    FM__BBPOOL_reset_allowBbPoolRecoveryReset_true_faulty_cell.TC Setup
    ...    AND    Modify Resource Search Order    FM__BBPOOL_reset_allowBbPoolRecoveryReset_true_faulty_cell
    TC__FM__BBPOOL_reset_allowBbPoolRecoveryReset_true_faulty_cell
    [Teardown]    Run Keywords    FM__BBPOOL_reset_allowBbPoolRecoveryReset_true_faulty_cell.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__SC_late_startup_actForceAutoReset_false
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    360
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    2700
    
    ...    AND    FM__SC_late_startup_actForceAutoReset_false.TC Setup
    ...    AND    Modify Resource Search Order    FM__SC_late_startup_actForceAutoReset_false
    TC__FM__SC_Late_Startup_actForce_False
    [Teardown]    Run Keywords    FM__SC_late_startup_actForceAutoReset_false.TC Teardown
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

