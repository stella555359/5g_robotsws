*** Settings ***
Documentation  FM suite
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS25R2  SRAN  CLOUD_SRAN_NLWG_10348_ASIB_ABIN_2ABIO_ASIA_2ABIA_2AHFIB_FXDB_FZHN_AZNA_FRGY STATE_SKIP_AGENT
Library           XML  use_lxml=True
Resource    ../../FM/test_resources/FM__Site_reset_escalation_to_BTS_power_reset.robot
Resource    ../../FM/test_resources/FM__5G_fault_tolerant_setup_degraded_cell.robot
Resource    ../../FM/test_resources/FM__RAT_recovery_reset_counter_cleared_manual_site_reset.robot
Resource    ../../FM/test_resources/FM__VN_CCplane_LTE_reset_counter_exceeded.robot
Resource    ../../FM/test_resources/FM__RMOD_reset_to_FSP_power_reset_exceeded_FID1905.robot
Resource    ../../FM/test_resources/FM__RMOD_reset_to_FSP_power_reset_counter_cleared_manual_site_reset_FID1904.robot
Resource    ../../FM/test_resources/FM__FSP_power_reset_counter_exceeded_FID1956_RMOD.robot

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
@{GSMVlan}            ${251}  ${252}
${WCDMAVlan}          ${454}
${LTEVlan}            ${451}
${Switch_IP}          10.255.10.234
${Switch_type}        Nokia_Nuage
${INTERFACE_TYPE}     GigabitEthernet
${INTERFACE_ID}       24
${Switch_USER}        AutoUser
${Switch_PASSWORD}    AutoPass123$
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1348

*** Test Cases ***

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

[1]FM__5G_fault_tolerant_setup_degraded_cell
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set additional ignored alarms variable
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    800
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    860
    ...    AND    FM__5G_fault_tolerant_setup_degraded_cell.TC Setup
    ...    AND    Modify Resource Search Order    FM__5G_fault_tolerant_setup_degraded_cell
    FM__5G_fault_tolerant_setup_degraded_cell
    [Teardown]    Run Keywords    FM__5G_fault_tolerant_setup_degraded_cell.TC Teardown
    ...    AND    Restore Resource Search Order

[1]FM__FSP_power_reset_escalation_FID1956_RMOD
    [Timeout]    14400
    [Setup]  Run Keywords
    ...  No Operation
    ...  AND  Set additional ignored alarms variable
    ...  AND  FM__FSP_power_reset_counter_exceeded_FID1956_RMOD.TC Setup
    ...  AND  Modify Resource Search Order  FM__FSP_power_reset_counter_exceeded_FID1956_RMOD
    TC__FM__FSP_power_reset_counter_exceeded_FID1956_RMOD
    [Teardown]  Run Keywords  FM__FSP_power_reset_counter_exceeded_FID1956_RMOD.TC Teardown
	...  AND    Restore Resource Search Order

[1]FM__RMOD_reset_to_FSP_power_reset_exceeded_FID1905
    [Timeout]    14400
    [Setup]  Run Keywords
    ...  No Operation
    ...  AND  Set additional ignored alarms variable
    ...  AND  FM__RMOD_reset_to_FSP_power_reset_exceeded_FID1905.TC Setup
    ...  AND  Modify Resource Search Order  FM__RMOD_reset_to_FSP_power_reset_exceeded_FID1905
    FM__RMOD_reset_to_FSP_power_reset_exceeded_FID1905.TC__FM__RMOD_reset_to_FSP_power_reset_exceeded_FID1905
    [Teardown]  Run Keywords  FM__RMOD_reset_to_FSP_power_reset_exceeded_FID1905.TC Teardown
	...  AND    Restore Resource Search Order

[1]FM__RMOD_reset_to_FSP_power_reset_counter_cleared_manual_site_reset_FID1904
    [Timeout]    14400
    [Setup]  Run Keywords
    ...  No Operation
    ...  AND  Set additional ignored alarms variable
    ...  AND  Set Test Variable  ${STARTUP_TIMEOUT}                               15m
    ...  AND  Set Test Variable  ${RESTORE_TIMEOUT}                               30m
    ...  AND  Set Test Variable  ${PING_LOSS_TIMEOUT}                             10m
    ...  AND  Set Test Variable  ${PING_REGAIN_TIMEOUT}                           10m
    ...  AND  Set Test Variable  ${ALARM_TIMEOUT}                                 180
    ...  AND  Set Test Variable  @{BBMOD_LIST}                                    ABIA  ABIN  ABIO
    ...  AND  Set Test Variable  @{ACCEPTED_CELLS_LIST}                           NR  LTE
    ...  AND  Set Test Variable  ${RMOD_TYPE}                                     OBSAI
    ...  AND  Set Test Variable  ${FAULT_ID_1904}                                 1904
    ...  AND  FM__RMOD_reset_to_FSP_power_reset_counter_cleared_manual_site_reset_FID1904.TC Setup
    ...  AND  Modify Resource Search Order  FM__RMOD_reset_to_FSP_power_reset_counter_cleared_manual_site_reset_FID1904
    TC__FM__RMOD_reset_to_FSP_power_reset_counter_cleared_manual_site_reset_FID1904
    [Teardown]  Run Keywords  FM__RMOD_reset_to_FSP_power_reset_counter_cleared_manual_site_reset_FID1904.TC Teardown
	...  AND    Restore Resource Search Order

[1]Automated__FM__VN_CCplane_LTE_reset_counter_exceeded
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    800
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    300
    ...    AND    FM__VN_CCplane_LTE_reset_counter_exceeded.TC Setup
    ...    AND    Modify Resource Search Order    FM__VN_CCplane_LTE_reset_counter_exceeded
    TC__FM_VN_CCplane_LTE_reset_counter_exceeded
    [Teardown]    Run Keywords    FM__VN_CCplane_LTE_reset_counter_exceeded.TC Teardown
    ...    AND    Restore Resource Search Order


[1]Automated__FM__Site_reset_escalation_to_BTS_power_reset
    [Timeout]    14400
    [Setup]  Run Keywords
    ...  No Operation
    ...  AND  Set additional ignored alarms variable
    ...  AND  Set Test Variable  ${BBMOD_SN}  L1204706785
    ...  AND  Set Test Variable  ${STARTUP_TIMEOUT}  900
    ...  AND  Set Test Variable  ${RECOVERY_TIMEOUT}  960
    ...  AND  Set Test Variable  ${ALARM_TIMEOUT}     580
    ...  AND  Set Test Variable  ${PING_TIMEOUT}    420
    ...  AND  Set Test Variable  ${NETACT_TIMEOUT}    560
    ...  AND  FM__Site_reset_escalation_to_BTS_power_reset.TC Setup
    ...  AND  Modify Resource Search Order    FM__Site_reset_escalation_to_BTS_power_reset
    TC__FM__Site_reset_escalation_to_BTS_power_reset
    [Teardown]  Run Keywords  FM__Site_reset_escalation_to_BTS_power_reset.TC Teardown
    ...  AND  Restore Resource Search Order

*** Keywords ***
Set additional ignored alarms variable
    ${ADDITIONAL_IGNORED_ALARMS}  Catenate  SEPARATOR=
    ...  [
    ...  ['faultId', '7107', 'alarmId', '7114'],
    ...  ['faultId', '6327', 'alarmId', '7107']
    ...  ]
    Set test variable  ${ADDITIONAL_IGNORED_ALARMS}
