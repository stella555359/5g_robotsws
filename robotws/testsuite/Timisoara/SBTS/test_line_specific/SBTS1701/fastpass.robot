*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS00  SRAN  CLOUD_SRAN_LWG_1ASIA_2ABIA_1ASIA_3ABIA_2FRGY_2FXDB_1AHEB STATE_SKIP_AGENT
Library           XML  use_lxml=True
Resource    ../../FM/test_resources/FM__Activate_Deactivate_EnhX2LinkSupervision.robot
Resource    ../../FM/test_resources/FM__BBPOOL_reset_allowBbPoolRecoveryReset_true_faulty_cell.robot
Resource    ../../FM/test_resources/FM__GSM_DSP_crash_RAT_recovery_reset.robot
Resource    ../../FM/test_resources/FM__Primary_core_power_off_on.robot

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
@{GSMVlan}            ${261}  ${262}
${WCDMAVlan}          ${464}
${LTEVlan}            ${461}
${Switch_IP}          10.255.10.109
${Switch_type}        Nokia_Nuage
${INTERFACE_TYPE}     GigabitEthernet
${INTERFACE_ID}       1
${Switch_USER}        AutoUser
${Switch_PASSWORD}    AutoPass123$
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    MRBTS-10701


*** Test Cases ***
[1][1.0] FM__GSM_DSP_crash_RAT_recovery_reset
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


[1][1.0] FM__BBPOOL_reset_allowBbPoolRecoveryReset_true_faulty_cell
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    200
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    @{EXPECTED_FAULT_ID}    6710
    ...    AND    Set Test Variable    @{EXPECTED_FAULT_NAME}    BBPOOL autonomous reset as recovery action
    ...    AND    Set Test Variable    @{EXPECTED_ALARM_ID}    7101
    ...    AND    Set Test Variable    @{EXPECTED_ALARM_NAME}    BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...    AND    Set Test Variable    @{SEVERITY}    warning
    
    ...    AND    FM__BBPOOL_reset_allowBbPoolRecoveryReset_true_faulty_cell.TC Setup
    ...    AND    Modify Resource Search Order    FM__BBPOOL_reset_allowBbPoolRecoveryReset_true_faulty_cell
    TC__FM__BBPOOL_reset_allowBbPoolRecoveryReset_true_faulty_cell
    [Teardown]    Run Keywords    FM__BBPOOL_reset_allowBbPoolRecoveryReset_true_faulty_cell.TC Teardown
    ...    AND    Restore Resource Search Order


[1][1.0] [1.0] FM_Activate_EnhX2LinkSupervision_fault_7324_reported
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${ADJ_ENB_ID}    10702
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    60
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID}    7324
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}    Maximum of X2 links reached
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}    7115
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}    BASE STATION INFORMATION
    ...    AND    Set Test Variable    ${SEVERITY}    Minor
    ...    AND    Set Test Variable    ${COMMISSIONING_STATE}    ${FALSE}
    
    ...    AND    FM__Activate_Deactivate_EnhX2LinkSupervision.TC Setup
    ...    AND    Modify Resource Search Order    FM__Activate_Deactivate_EnhX2LinkSupervision
    TC__FM__Activate_Deactivate_EnhX2LinkSupervision
    [Teardown]    Run Keywords    FM__Activate_Deactivate_EnhX2LinkSupervision.TC Teardown
    ...    AND    Restore Resource Search Order


[1][1.0] [1.0] FM_deactivate_EnhX2LinkSupervision_feature_fault_7324_cleared
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${ADJ_ENB_ID}    10702
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    60
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_ID}    7324
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}    Maximum of X2 links reached
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}    7115
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}    BASE STATION INFORMATION
    ...    AND    Set Test Variable    ${SEVERITY}    Minor
    ...    AND    Set Test Variable    ${COMMISSIONING_STATE}    ${FALSE}
    
    ...    AND    FM__Activate_Deactivate_EnhX2LinkSupervision.TC Setup
    ...    AND    Modify Resource Search Order    FM__Activate_Deactivate_EnhX2LinkSupervision
    TC__FM__Activate_Deactivate_EnhX2LinkSupervision
    [Teardown]    Run Keywords    FM__Activate_Deactivate_EnhX2LinkSupervision.TC Teardown
    ...    AND    Restore Resource Search Order


[1][1.0] FM__Primary_Core_power_off_on
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



*** Keywords ***
