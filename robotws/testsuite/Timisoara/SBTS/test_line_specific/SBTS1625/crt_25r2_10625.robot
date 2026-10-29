*** Settings ***
Documentation  This suite contains the FM test cases from 25R2 on SBTS10625 platform.

Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS25R2  SRAN  CLOUD_SRAN_NLWG_1625_1ASIB_1ABIA_1ABIO_1FSMF_2FBBC_2FXDB_2FRGY_1AHPMDA_1AHCA_1AEHC

Library           XML  use_lxml=True
Resource    ../../FM/test_resources/FM__GSM_DSP_crash_RAT_recovery_reset.robot
Resource    ../../FM/test_resources/FM__Secondary_core_power_off_on.robot
Resource    ../../FM/test_resources/FM__RAT_reset_counter_exceeded__multi_RAT.robot
Resource    ../../FM/test_resources/FM__VN_CCplane_LTE_reset_counter_exceeded.robot
Resource    ../../FM/test_resources/FM__SC_late_startup_actForceAutoReset_true.robot
Resource    ../../FM/test_resources/FM__VN_recovery_reset_counter_cleared_-_manual_site_reset.robot
Resource    ../../FM/test_resources/FM__Site_reset_actForceAutoReset_false_enabled_cell.robot
Resource    ../../FM/test_resources/FM__Alarm_synchronization_after_reconnecting_to_NetAct.robot

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
@{GSMVlan}            ${261}  ${262}
${WCDMAVlan}          ${464}
${LTEVlan}            ${461}
${Switch_IP}          10.255.6.18
${Switch_type}        Nokia_Nuage
${INTERFACE_TYPE}     GigabitEthernet
${INTERFACE_ID}       5
${Switch_USER}        AutoUser
${Switch_PASSWORD}    AutoPass123$
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1625

*** Test Cases ***
[1]Automated__FM__GSM_DSP_crash_RAT_recovery_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}        600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    360
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    @{EXPECTED_FAULT_ID}    6707    6708    6709    4019
    ...    AND    Set Test Variable    ${EXPECTED_FAULT_NAME}    RAT autonomous reset as recovery action
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_ID}    7101
    ...    AND    Set Test Variable    ${EXPECTED_ALARM_NAME}    BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...    AND    Set Test Variable    ${SEVERITY}    Warning

    ...    AND    FM__GSM_DSP_crash_RAT_recovery_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__GSM_DSP_crash_RAT_recovery_reset
    TC__FM__GSM_DSP_crash_RAT_recovery_reset
    [Teardown]    Run Keywords    FM__GSM_DSP_crash_RAT_recovery_reset.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Secondary_core_power_off_on_fault_signature_v2
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${EXPECTED_FAULT}    4590

    ...    AND    FM__Secondary_core_power_off_on.TC Setup
    ...    AND    Modify Resource Search Order    FM__Secondary_core_power_off_on
    TC__FM__Secondary_Core_power_off_on
    [Teardown]    Run Keywords    FM__Secondary_core_power_off_on.TC Teardown
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

[1]FM__VN_reset_counter_cleared__manual_site_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    180
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    300

    ...    AND    FM__VN_recovery_reset_counter_cleared_-_manual_site_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__VN_recovery_reset_counter_cleared_-_manual_site_reset
    TC__FM__VN_recovery_reset_counter_cleared_-_manual_site_reset
    [Teardown]    Run Keywords    FM__VN_recovery_reset_counter_cleared_-_manual_site_reset.TC Teardown
    ...    AND    Restore Resource Search Order

[1]FM__Site_reset_actForceAutoReset_false_enabled_cell
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${PING_TIMEOUT}    300

    ...    AND    FM__Site_reset_actForceAutoReset_false_enabled_cell.TC Setup
    ...    AND    Modify Resource Search Order    FM__Site_reset_actForceAutoReset_false_enabled_cell
    TC__FM__Site_reset_actForceAutoReset_false_enabled_cell
    [Teardown]    Run Keywords    FM__Site_reset_actForceAutoReset_false_enabled_cell.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Alarm_synchronization_after_reconnecting_to_NMS
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BLOCK_TIMEOUT}    300
    ...    AND    Set Test Variable    ${UNBLOCK_TIMEOUT}    300
    ...    AND    Set Test Variable    ${NETACT_ALARM_TIMEOUT}    600

    ...    AND    FM__Alarm_synchronization_after_reconnecting_to_NetAct.TC Setup
    ...    AND    Modify Resource Search Order    FM__Alarm_synchronization_after_reconnecting_to_NetAct
    TC__FM__Alarm_synchronization_after_reconnecting_to_NetAct
    [Teardown]    Run Keywords    FM__Alarm_synchronization_after_reconnecting_to_NetAct.TC Teardown
    ...    AND    Restore Resource Search Order