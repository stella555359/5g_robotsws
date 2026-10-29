*** Settings ***

Documentation  This suite contains CRT trunk testcases

Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS00  SRAN  CLOUD_SRAN_NLWG_10348_ASIB_3ABIO_ASIA_2ABIA_3AHPMDD_3AHEGHA_3AVQL_ANEGA_FRGY STATE_SKIP_AGENT
Library           XML  use_lxml=True
Resource    ../../FM/test_resources/FM__Site_reset_escalation_to_BTS_power_reset.robot
Resource    ../../FM/test_resources/FM__FHNET_crash_VN_recovery_reset_AS.robot
Resource    ../../FM/test_resources/FM__SC_hot_remove_hot_insert.robot
Resource    ../../FM/test_resources/FM__SC_late_startup_actForceAutoReset_false.robot
Resource    ../../FM/test_resources/FM__SC_reset_actForceAutoReset_false_enabled_cells.robot
Resource    ../../FM/test_resources/FM__SC_reset_actForceAutoReset_true_enabled_cells.robot
Resource    ../../FM/test_resources/FM__Site_reset_recovery_counter_cleared_-_manual_site_reset.robot
Resource    ../../FM/test_resources/FM__VN_CCplane_LTE_reset_counter_exceeded.robot
Resource    ../../FM/test_resources/FM__SC_to_Site_reset_escalation_fid_246.robot
Resource    ../../FM/test_resources/FM__RMOD_reset_to_FSP_power_reset_exceeded_FID1905.robot
Resource    ../../FM/test_resources/FM__RMOD_reset_to_FSP_power_reset_counter_cleared_manual_site_reset_FID1904.robot
Resource    ../../FM/test_resources/FM__FSP_power_reset_counter_exceeded_FID1956_RMOD.robot
Resource    ../../FM/test_resources/FM__RMOD_crash_fault_signature_check.robot
Resource    ../../FM/test_resources/FM__RMOD_crash_FID4590.robot


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

[1]Automated__FM__FHNET_crash_VN_recovery_reset_AS
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    900
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    700
    ...    AND    FM__FHNET_crash_VN_recovery_reset_AS.TC Setup
    ...    AND    Modify Resource Search Order    FM__FHNET_crash_VN_recovery_reset_AS
    TC__FM__FHNET_crash_VN_recovery_reset_AS
    [Teardown]    Run Keywords    FM__FHNET_crash_VN_recovery_reset_AS.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__FM__SC_hot_remove_hot_insert_v2
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${EXPECTED_FAULT}    4590
    ...    AND    FM__SC_hot_remove_hot_insert.TC Setup
    ...    AND    Modify Resource Search Order    FM__SC_hot_remove_hot_insert
    TC__FM__SC_hot_remove_hot_insert
    [Teardown]    Run Keywords    FM__SC_hot_remove_hot_insert.TC Teardown
    ...    AND    Restore Resource Search Order

[1]FM__SC_reset_actForceAutoReset_false_enabled_cell
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    1900
    ...    AND    FM__SC_reset_actForceAutoReset_false_enabled_cells.TC Setup
    ...    AND    Modify Resource Search Order    FM__SC_reset_actForceAutoReset_false_enabled_cells
    TC__FM__SC_reset_actForceAutoReset_false_enabled_cells
    [Teardown]    Run Keywords    FM__SC_reset_actForceAutoReset_false_enabled_cells.TC Teardown
    ...    AND    Restore Resource Search Order

[1]FM__SC_reset_actForceAutoReset_true_enabled_cell
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    1900
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    900
    ...    AND    FM__SC_reset_actForceAutoReset_true_enabled_cells.TC Setup
    ...    AND    Modify Resource Search Order    FM__SC_reset_actForceAutoReset_true_enabled_cells
    TC__FM__SC_reset_actForceAutoReset_true_enabled_cells
    [Teardown]    Run Keywords    FM__SC_reset_actForceAutoReset_true_enabled_cells.TC Teardown
    ...    AND    Restore Resource Search Order

[1]FM__SC_late_startup_actForceAutoReset_false
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RECOVERY_TIMEOUT}    990
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    990
    ...    AND    FM__SC_late_startup_actForceAutoReset_false.TC Setup
    ...    AND    Modify Resource Search Order    FM__SC_late_startup_actForceAutoReset_false
    TC__FM__SC_Late_Startup_actForce_False
    [Teardown]    Run Keywords    FM__SC_late_startup_actForceAutoReset_false.TC Teardown
    ...    AND    Restore Resource Search Order

[1]FM__SC_to_Site_reset_escalation_fid_246
    [Timeout]    14400
    [Setup]  Run Keywords
    ...  No Operation
    ...  AND  Set additional ignored alarms variable
    ...  AND  Set Test Variable  ${STARTUP_TIMEOUT}  900
    ...  AND  Set Test Variable  ${RECOVERY_TIMEOUT}  900
    ...  AND  Set Test Variable  ${ALARM_TIMEOUT}     1200
    ...  AND  Set Test Variable  ${AFFECTED_CELLS_TIMEOUT}     1200
    ...  AND  FM__SC_to_Site_reset_escalation_fid_246.TC Setup
    ...  AND  Modify Resource Search Order  FM__SC_to_Site_reset_escalation_fid_246
    TC__FM__SC_to_Site_reset_escalation_fid_246
    [Teardown]  Run Keywords  FM__SC_to_Site_reset_escalation_fid_246.TC Teardown
	...  AND    Restore Resource Search Order

[1]FM__FSP_power_reset_escalation_FID1956_RMOD
    [Timeout]    14400
    [Setup]  Run Keywords
    ...  No Operation
    ...  AND  Set Test Variable  @{BBMOD_LIST}                                    ABIA
    ...  AND  Set Test Variable  @{ACCEPTED_CELLS_LIST}                           LTE
    ...  AND  Set additional ignored alarms variable
    ...  AND  FM__FSP_power_reset_counter_exceeded_FID1956_RMOD.TC Setup
    ...  AND  Modify Resource Search Order  FM__FSP_power_reset_counter_exceeded_FID1956_RMOD
    TC__FM__FSP_power_reset_counter_exceeded_FID1956_RMOD
    [Teardown]  Run Keywords  FM__FSP_power_reset_counter_exceeded_FID1956_RMOD.TC Teardown
	...  AND    Restore Resource Search Order

[1]FM__RMOD_reset_to_FSP_power_reset_exceeded_FID1905
    [Timeout]    14400
    [Setup]  Run Keywords
    ...  No Operation
    ...  AND  Set Test Variable  @{BBMOD_LIST}                                    ABIA
    ...  AND  Set Test Variable  @{ACCEPTED_CELLS_LIST}                           LTE
    ...  AND  Set additional ignored alarms variable
    ...  AND  FM__RMOD_reset_to_FSP_power_reset_exceeded_FID1905.TC Setup
    ...  AND  Modify Resource Search Order  FM__RMOD_reset_to_FSP_power_reset_exceeded_FID1905
    FM__RMOD_reset_to_FSP_power_reset_exceeded_FID1905.TC__FM__RMOD_reset_to_FSP_power_reset_exceeded_FID1905
    [Teardown]  Run Keywords  FM__RMOD_reset_to_FSP_power_reset_exceeded_FID1905.TC Teardown
	...  AND    Restore Resource Search Order

[1]FM__RMOD_reset_to_FSP_power_reset_counter_cleared_manual_site_reset_FID1904
    [Timeout]    14400
    [Setup]  Run Keywords
    ...  No Operation
    ...  AND  Set additional ignored alarms variable
    ...  AND  Set Test Variable  ${STARTUP_TIMEOUT}                               15m
    ...  AND  Set Test Variable  ${RESTORE_TIMEOUT}                               30m
    ...  AND  Set Test Variable  ${PING_LOSS_TIMEOUT}                             10m
    ...  AND  Set Test Variable  ${PING_REGAIN_TIMEOUT}                           10m
    ...  AND  Set Test Variable  ${ALARM_TIMEOUT}                                 180
    ...  AND  Set Test Variable  @{BBMOD_LIST}                                    ABIA
    ...  AND  Set Test Variable  @{ACCEPTED_CELLS_LIST}                           LTE
    ...  AND  Set Test Variable  ${RMOD_TYPE}                                     OBSAI
    ...  AND  Set Test Variable  ${FAULT_ID_1904}                                 1904
    ...  AND  FM__RMOD_reset_to_FSP_power_reset_counter_cleared_manual_site_reset_FID1904.TC Setup
    ...  AND  Modify Resource Search Order  FM__RMOD_reset_to_FSP_power_reset_counter_cleared_manual_site_reset_FID1904
    TC__FM__RMOD_reset_to_FSP_power_reset_counter_cleared_manual_site_reset_FID1904
    [Teardown]  Run Keywords  FM__RMOD_reset_to_FSP_power_reset_counter_cleared_manual_site_reset_FID1904.TC Teardown
	...  AND    Restore Resource Search Order

[1]FM_RMOD_power_off_on_FID4589
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_TYPE}    ANEGA
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    360
    ...    AND    FM__RMOD_crash_fault_signature_check.TC setup
    ...    AND    Modify Resource Search Order    FM__RMOD_crash_fault_signature_check
    FM__RMOD_crash_fault_signature_check
    [Teardown]    Run Keywords    FM__RMOD_crash_fault_signature_check.TC Teardown
    ...    AND    Restore Resource Search Order

[1]FM_RMOD_crash_FID4590
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${RMOD_TYPE}    ANEGA
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    1500
    ...    AND    Set Test Variable    ${ALARM_TIMEOUT}    600
    ...    AND    FM__RMOD_crash_FID4590.TC Setup
    ...    AND    Modify Resource Search Order    FM__RMOD_crash_FID4590
    TC__FM__RMOD_crash_FID4590
    [Teardown]    Run Keywords    FM__RMOD_crash_FID4590.TC Teardown
    ...    AND    Restore Resource Search Order

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

[1]FM__Site_rst_escalation_to_BTS_power_reset
    [Timeout]    14400
    [Setup]  Run Keywords
    ...  No Operation
    ...  AND  Set additional ignored alarms variable
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
    ...  ['faultId', '7319', 'alarmId', '7107'],
    ...  ['faultId', '7300', 'alarmId', '7107'],
    ...  ['faultId', '7308', 'alarmId', '7107'],
    ...  ['faultId', '4297', 'alarmId', '7115'],
    ...  ['faultId', '6327', 'alarmId', '7107']
    ...  ]
    Set test variable  ${ADDITIONAL_IGNORED_ALARMS}
