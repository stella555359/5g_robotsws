*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SRAN  CLOUD_SRAN_NL_10760_2ASIB_4ABIA_2ABIL_3AHPMDA_3AREA_3ARGA_3AZNA_3AEQE  STATE_COMMISSIONED
Library           XML  use_lxml=True

Resource    ../../FM/test_resources/FM__RMOD_reset_counter_exceeded_FID1900.robot
Resource    ../../FM/test_resources/FM__RMOD_reset_counter_exceeded_FID1901.robot
Resource    ../../FM/test_resources/FM__RMOD_crash_fault_signature_check.robot
Resource    ../../FM/test_resources/FM__SC_late_startup_actForceAutoReset_true.robot


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${ENB_BUILD}    SBTS00_ENB_9999_211207_000006
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1760


*** Test Cases ***
[1]FM__RMOD_reset_counter_exceeded_FID1900
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    400
    ...    AND    Set Test Variable    @{RMOD_TYPE}    AEQE
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID}    1900
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}    Radio autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}    7101
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}    BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...    AND    Set Test Variable    ${SEVERITY}    warning
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_SECOND}    TX out of order
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID_SECOND}    7116
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME_SECOND}    BASE STATION SERVICE PROBLEM
    ...    AND    Set Test Variable    ${SEVERITY_SECOND}    Critical
    ...    AND    Set Test Variable    ${RMOD_USERNAME}    rfsw
    ...    AND    Set Test Variable    ${RMOD_PASSWORD}    gSDBExyEbO33komYWL6iPrtSaYc5XimHAGrsJ/K8+AY= 

    ...    AND    FM__RMOD_reset_counter_exceeded_FID1900.TC Setup
    ...    AND    Modify Resource Search Order    FM__RMOD_reset_counter_exceeded_FID1900
    TC__FM__RMOD_reset_counter_exceeded_FID1900
    [Teardown]    Run Keywords    FM__RMOD_reset_counter_exceeded_FID1900.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__RMOD_reset_counter_exceeded_FID1901
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1200
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    400
    ...    AND    Set Test Variable    @{RMOD_TYPE}    AEQE
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID}    1901
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}    Radio autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}    7101
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}    BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...    AND    Set Test Variable    ${SEVERITY}    warning
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME_SECOND}    TX out of order
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID_SECOND}    7116
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME_SECOND}    BASE STATION SERVICE PROBLEM
    ...    AND    Set Test Variable    ${SEVERITY_SECOND}    Critical
    ...    AND    Set Test Variable    ${RMOD_USERNAME}    rfsw
    ...    AND    Set Test Variable    ${RMOD_PASSWORD}    gSDBExyEbO33komYWL6iPrtSaYc5XimHAGrsJ/K8+AY= 

    ...    AND    FM__RMOD_reset_counter_exceeded_FID1901.TC Setup
    ...    AND    Modify Resource Search Order    FM__RMOD_reset_counter_exceeded_FID1901
    TC__FM__RMOD_reset_counter_exceeded_FID1901
    [Teardown]    Run Keywords    FM__RMOD_reset_counter_exceeded_FID1901.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__RMOD_crash_fault_signature_check
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_TYPE}    AEQE
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    360
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID}    4589
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}    Unit power reset
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}    7115
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}    BASE STATION INFORMATION
    ...    AND    Set Test Variable    ${SEVERITY}    warning

    ...    AND    FM__RMOD_crash_fault_signature_check.TC setup
    ...    AND    Modify Resource Search Order    FM__RMOD_crash_fault_signature_check
    FM__RMOD_crash_fault_signature_check
    [Teardown]    Run Keywords    FM__RMOD_crash_fault_signature_check.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__SC_Late_Startup_actForce_True
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    360
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Library Search Order  coam   ute_admin   hran_frame_sbts_taf   hran_frame_sbts_siso
    ...    AND    Modify Resource Search Order    FM__SC_late_startup_actForceAutoReset_true
    ...    AND    FM__SC_late_startup_actForceAutoReset_true.TC Setup
    TC__FM__SC_Late_Startup_actForce_True
    [Teardown]    Run Keywords    FM__SC_late_startup_actForceAutoReset_true.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Set Library Search Order  ute_admin   taf.sbts.oam.coam.admin   hran_frame_sbts_siso   hran_frame_sbts_taf
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun'  CIT Recover Test Line By Power Reset
