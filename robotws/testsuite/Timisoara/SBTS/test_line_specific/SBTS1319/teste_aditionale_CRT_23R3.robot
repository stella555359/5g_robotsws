*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SRAN  CLOUD_SRAN_NL_10319_1ASIK_3ABIL_3AZQL_1ARPA  STATE_COMMISSIONED
Library           XML  use_lxml=True
Resource    ../../FM/test_resources/FM__FHNET_crash_VN_recovery_reset_AS.robot
Resource    ../../FM/test_resources/FM__Primary_core_power_off_on.robot
Resource    ../../FM/test_resources/FM__5G_RAT_reset_executed_as_autonomous_recovery_action.robot
Resource    ../../FM/test_resources/FM__5G_BBMOD_unit_recovery_reset_counter_exceeded.robot


*** Variables ***
${SCF_ID}    01


*** Test Cases ***
[1]Automated__FM__FHNET_crash_VN_recovery_reset_AS
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    600
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    300

    ...    AND    FM__FHNET_crash_VN_recovery_reset_AS.TC Setup
    ...    AND    Modify Resource Search Order    FM__FHNET_crash_VN_recovery_reset_AS
    TC__FM__FHNET_crash_VN_recovery_reset_AS
    [Teardown]    Run Keywords    FM__FHNET_crash_VN_recovery_reset_AS.TC Teardown
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


[1]Autonomous_recovery_reset_counter_with_BBMOD_fault
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    600
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    180
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIL
    ...    AND    Set Test Variable    @{EXPECTED_FAULT_ID}    2087
    ...    AND    Set Test Variable    @{EXPECTED_FAULT_NAME}    SoC autonomous reset as recovery action
    ...    AND    Set Test Variable    @{EXPECTED_ALARM_ID}    7101
    ...    AND    Set Test Variable    @{EXPECTED_ALARM_NAME}    BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...    AND    Set Test Variable    @{SEVERITY}    warning
    ...    AND    Set Test Variable    @{EXPECTED_FAULT_ID_SECOND}    4341
    ...    AND    Set Test Variable    @{EXPECTED_FAULT_NAME_SECOND}    Baseband card autonomous reset as recovery action
    
    ...    AND    FM__5G_BBMOD_unit_recovery_reset_counter_exceeded.TC Setup
    ...    AND    Modify Resource Search Order    FM__5G_BBMOD_unit_recovery_reset_counter_exceeded
    TC__TC__5G_BBMOD_unit_recovery_reset_counter_exceeded
    [Teardown]    Run Keywords    FM__5G_BBMOD_unit_recovery_reset_counter_exceeded.TC Teardown
    ...    AND    Restore Resource Search Order