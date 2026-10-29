*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SBTS24R2  SRAN  CLOUD_SRAN_LWG_1ASIB_2ABIA_1FSMF_2FBBC_2FXDB_2FRGY_1AHPMDA_1AHCA
Library           XML  use_lxml=True

Resource    ../../FM/test_resources/FM__Site_reset_actForceAutoReset_false_enabled_cell.robot
Resource    ../../FM/test_resources/FM__Alarm_synchronization_after_reconnecting_to_NetAct.robot
Resource    ../../FM/test_resources/FM__VN_recovery_reset_counter_cleared_-_manual_site_reset.robot
Resource    ../../FM/test_resources/FM__VN_CCplane_LTE_reset_counter_exceeded.robot
Resource    ../../FM/test_resources/FM__RAT_reset_counter_exceeded__multi_RAT.robot


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


*** Test Cases ***
[1]FM__Site_reset_actForceAutoReset_false_enabled_cell
    [Timeout]    14400
    [Tags]    QC_784569
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${PING_TIMEOUT}    300

    ...    AND    FM__Site_reset_actForceAutoReset_false_enabled_cell.TC Setup
    ...    AND    Modify Resource Search Order    FM__Site_reset_actForceAutoReset_false_enabled_cell
    TC__FM__Site_reset_actForceAutoReset_false_enabled_cell
    [Teardown]    Run Keywords    FM__Site_reset_actForceAutoReset_false_enabled_cell.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__Secondary_core_power_off_on_fault_signature
    [Timeout]    14400
    [Tags]    QC_784569
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${EXPECTED_FAULT}    4590

    ...    AND    FM__Secondary_core_power_off_on.TC Setup
    ...    AND    Modify Resource Search Order    FM__Secondary_core_power_off_on
    TC__FM__Secondary_Core_power_off_on
    [Teardown]    Run Keywords    FM__Secondary_core_power_off_on.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Alarm_synchronization_after_reconnecting_to_NMS
    [Timeout]    14400
    [Tags]    QC_784572
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
    

[1]FM__VN_reset_counter_cleared__manual_site_reset
    [Timeout]    14400
    [Tags]    QC_784583
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    180
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    300

    ...    AND    FM__VN_recovery_reset_counter_cleared_-_manual_site_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__VN_recovery_reset_counter_cleared_-_manual_site_reset
    TC__FM__VN_recovery_reset_counter_cleared_-_manual_site_reset
    [Teardown]    Run Keywords    FM__VN_recovery_reset_counter_cleared_-_manual_site_reset.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__VN_CCplane_LTE_reset_counter_exceeded
    [Timeout]    14400
    [Tags]    QC_784588
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    300

    ...    AND    FM__VN_CCplane_LTE_reset_counter_exceeded.TC Setup
    ...    AND    Modify Resource Search Order    FM__VN_CCplane_LTE_reset_counter_exceeded
    TC__FM_VN_CCplane_LTE_reset_counter_exceeded
    [Teardown]    Run Keywords    FM__VN_CCplane_LTE_reset_counter_exceeded.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__RAT_reset_counter_exceeded__multi_RAT
    [Timeout]    14400
    [Tags]    QC_784594
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
