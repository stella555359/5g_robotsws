*** Settings ***
Documentation  This suite contains the FM test cases of SBTS10625 for the 25R3 branch regression.

Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS25R3  SRAN  CLOUD_SRAN_NLWG_1625_1ASIB_1ABIA_1ABIO_1FSMF_2FBBC_2FXDB_2FRGY_1AHPMDA_1AHCA_1AEHC

Library           XML  use_lxml=True
Resource    ../../FM/test_resources/FM__GSM_DSP_crash_RAT_recovery_reset.robot
Resource    ../../FM/test_resources/FM__Secondary_core_power_off_on.robot
Resource    ../../FM/test_resources/FM__RAT_reset_counter_exceeded__multi_RAT.robot
Resource    ../../FM/test_resources/FM__VN_CCplane_LTE_reset_counter_exceeded.robot
Resource    ../../FM/test_resources/FM__SC_late_startup_actForceAutoReset_true.robot
Resource    ../../FM/test_resources/FM__VN_recovery_reset_counter_cleared_-_manual_site_reset.robot
Resource    ../../FM/test_resources/FM__Site_reset_actForceAutoReset_false_enabled_cell.robot
Resource    ../../FM/test_resources/FM__Alarm_synchronization_after_reconnecting_to_NetAct.robot
Resource    ../../FM/test_resources/FM__FSP_recovery_fault_242.robot
Resource    ../../FM/test_resources/FM__LTE_L3_crash_VN_recovery_reset.robot
Resource    ../../FM/test_resources/FM__WCDMA_VN_crash_RAT_recovery_reset.robot

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
[1]FM_FSP_recovery_fault_242
    [Tags]  QC_209979
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    900
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    600
    ...    AND    Set Test Variable    ${TIME_BBMOD_STATE}    300
    ...    AND    Set Test Variable    ${TIME_SMOD_STATE}    300
    ...    AND    Set Test Variable    ${TIME_APPEAR_ALARM}    260
    ...    AND    Set Test Variable    ${TIME_DISAPPEAR_ALARM}    180

    ...    AND    FM__FSP_recovery_fault_242.TC Setup
    ...    AND    Modify Resource Search Order    FM__FSP_recovery_fault_242
    TC__FM__FSP_recovery_fault_242
    [Teardown]    Run Keywords    FM__FSP_recovery_fault_242.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__FM__GSM_DSP_crash_RAT_recovery_reset
    [Tags]  QC_209984
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}        600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    360
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600

    ...    AND    FM__GSM_DSP_crash_RAT_recovery_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__GSM_DSP_crash_RAT_recovery_reset
    TC__FM__GSM_DSP_crash_RAT_recovery_reset
    [Teardown]    Run Keywords    FM__GSM_DSP_crash_RAT_recovery_reset.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Secondary_core_power_off_on_fault_signature_v2
    [Tags]  QC_209977
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
    [Tags]  QC_209983
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

[1]Automated__FM__WCDMA_VN_crash_RAT_recovery_reset
    [Tags]  QC_209981
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600

    ...    AND    FM__WCDMA_VN_crash_RAT_recovery_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__WCDMA_VN_crash_RAT_recovery_reset
    TC__FM__WCDMA_VN_crash_RAT_recovery_reset
    [Teardown]    Run Keywords    FM__WCDMA_VN_crash_RAT_recovery_reset.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__FM__LTE_L3_crash_VN_recovery_reset
    [Tags]  QC_209989
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    300
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600

    ...    AND    FM__LTE_L3_crash_VN_recovery_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__LTE_L3_crash_VN_recovery_reset
    TC__FM___LTE_L3_crash_VN_recovery_reset
    [Teardown]    Run Keywords    FM__LTE_L3_crash_VN_recovery_reset.TC Teardown
    ...    AND    Restore Resource Search Order

[1]FM__VN_reset_counter_cleared__manual_site_reset
    [Tags]  QC_209993
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


[1]Alarm_synchronization_after_reconnecting_to_NMS
    [Tags]  QC_209976
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