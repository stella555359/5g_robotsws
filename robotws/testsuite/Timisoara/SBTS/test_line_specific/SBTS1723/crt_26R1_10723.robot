*** Settings ***
Resource    ../../CIT/test_resources/STATE__Site_reset.robot
Resource    ../../FM/test_resources/FM__B_5G_RAT_reset_counter_cleared__manual_site_reset.robot
Resource    ../../FM/test_resources/FM__RMOD_reset_counter_exceeded_FID1907.robot
Resource    ../../FM/test_resources/FM__SC_reset_counter_cleared_manual_site_reset.robot
Resource    ../../FM/test_resources/FM__RMOD_crash_fault_signature_check.robot
Resource    ../../FM/test_resources/FM__C_L1Soc_NR_DL_DSP_unsuccessful_recovery_reset_loop_detection.robot
Resource    ../../FM/test_resources/FM__FID4383_fault_signature_active_UP_5G_L2_process_crashed.robot
Resource    ../../FM/test_resources/FM__FID4383_fault_signature_active_UP_4G_L2_process_crashed.robot
Resource    ../../FM/test_resources/FM__RMOD_crash_FID4590.robot

Documentation  CRT Trunk suite for SBTS 10723.

*** Variables ***
${SCF_ID}    01


*** Test Cases ***


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


*** Keywords ***
Set additional ignored alarms variable
    ${ADDITIONAL_IGNORED_ALARMS}  Catenate
    ...  [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220'], ['faultId', '7300', 'alarmId', '7107'],
    ...  ['faultId', '7319', 'alarmId', '7107'], ['faultId', '6327', 'alarmId', '7107'], ['faultId', '4527', 'alarmId', '7115']]
    Set test variable ${ADDITIONAL_IGNORED_ALARMS}
