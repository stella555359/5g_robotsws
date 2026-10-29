*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS25R3  SRAN  CLOUD_SRAN_NLG_1328_2ASIL_4ABIO_1ABIP_1ABIA_2AZHL_3AHLOA_3AHFIB_1AHDB_1AENB
Library           XML  use_lxml=True

Documentation  crt_trunk_10328

Resource    ../../FM/test_resources/FM__FSP_common_reset_counter_exceeded.robot
Resource    ../../FM/test_resources/FM__FID4383_fault_signature_active_5G_RT_NRT_process.robot
Resource    ../../FM/test_resources/FM__B4_RF_Recovery_Reset_Tx_Rx_Failure_cell_degraded.robot
Resource    ../../FM/test_resources/FM__Site_reset_counter_cleared__manual_site_reset_fid_246.robot
Resource    ../../FM/test_resources/FM__Site_reset_escalation_to_BTS_power_reset.robot

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
@{GSMVlan}            ${261}  ${262}
${WCDMAVlan}          ${464}
${LTEVlan}            ${461}
${Switch_IP}
${Switch_type}        Nokia_Nuage
${INTERFACE_TYPE}     GigabitEthernet
${INTERFACE_ID}       5
${Switch_USER}        AutoUser
${Switch_PASSWORD}    AutoPass123$
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1328


*** Test Cases ***

[1]FM__FSP_common_reset_counter_exceeded
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIO
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    900
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    600
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    560

    ...    AND    FM__FSP_common_reset_counter_exceeded.TC Setup
    ...    AND    Modify Resource Search Order    FM__FSP_common_reset_counter_exceeded
    TC__FM__FSP_common_reset_counter_exceeded
    [Teardown]    Run Keywords    FM__FSP_common_reset_counter_exceeded.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__A_L1_5G_SoC_reset_escalation_actForceUnitReset=false
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    600
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}     560
    ...    AND    Set Test Variable    ${HW_VARIANT}    Thor
    ...    AND    Set Test Variable    ${SOC_TYPE}   ABIP

    ...    AND    FM__SoC_reset_actForceUnitAutoReset_false_same_fault_in_one_hour.TC Setup
    ...    AND    Modify Resource Search Order    FM__SoC_reset_actForceUnitAutoReset_false_same_fault_in_one_hour
    TC__FM__SoC_reset_actForceUnitAutoReset_false_same_fault_in_one_hour
    [Teardown]    Run Keywords    FM__SoC_reset_actForceUnitAutoReset_false_same_fault_in_one_hour.TC Teardown
    ...    AND    Restore Resource Search Order

[1]FM__US009504_B4_Autonomous_RF_Recovery_Reset_due_to_Tx_Rx_Failure_cell_degraded
 [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}     600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    600
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}       600

    ...    AND    FM__B4_RF_Recovery_Reset_Tx_Rx_Failure_cell_degraded.TC Setup
    ...    AND    Modify Resource Search Order    FM__B4_RF_Recovery_Reset_Tx_Rx_Failure_cell_degraded
    TC__FM__B4_RF_Recovery_Reset_Tx_Rx_Failure_cell_degraded
    [Teardown]    Run Keywords    FM__B4_RF_Recovery_Reset_Tx_Rx_Failure_cell_degraded.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__Site_reset_counter_cleared__manual_site_reset_fid_246
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}     600
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    600
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}       600

    ...    AND    FM__Site_reset_counter_cleared__manual_site_reset_fid_246.TC Setup
    ...    AND    Modify Resource Search Order    FM__Site_reset_counter_cleared__manual_site_reset_fid_246
    TC__FM__Site_reset_counter_cleared__manual_site_reset_fid_246
    [Teardown]    Run Keywords    FM__Site_reset_counter_cleared__manual_site_reset_fid_246.TC Teardown
    ...    AND    Restore Resource Search Order


[1]FM__Site_rst_escalation_to_BTS_power_reset
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BBMOD_SN}    L1210204785
    ...    AND    Set Test Variable    ${BBMOD_TYPE}    ABIN
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    900
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    960
    ...    AND    Set Test Variable    ${PING_TIMEOUT}    420
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    560

    ...    AND    FM__Site_reset_escalation_to_BTS_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__Site_reset_escalation_to_BTS_power_reset
    TC__FM__Site_reset_escalation_to_BTS_power_reset
    [Teardown]    Run Keywords    FM__Site_reset_escalation_to_BTS_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order


*** Keywords ***
Set additional ignored alarms variable
    ${ADDITIONAL_IGNORED_ALARMS}  Catenate
    ...  [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220'], ['faultId', '7300', 'alarmId', '7107'],
    ...  ['faultId', '7319', 'alarmId', '7107'], ['faultId', '6327', 'alarmId', '7107'], ['faultId', '4527', 'alarmId', '7115']]
    Set test variable ${ADDITIONAL_IGNORED_ALARMS}

