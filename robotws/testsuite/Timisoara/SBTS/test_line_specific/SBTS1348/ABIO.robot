*** Settings ***
Documentation  FM suite
Force Tags  QCD_MN_RAN  QCP_RAN_VRF  SBTS00  SRAN  CLOUD_SRAN_NLWG_10348_ASIB_3ABIO_ASIA_2ABIA_3AHPMDD_3AHEGHA_3AVQL_ANEGA_FRGY STATE_SKIP_AGENT
Library           XML  use_lxml=True

Resource    ../../FM/test_resources/FM__Site_reset_escalation_to_BTS_power_reset.robot

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

[1]Automated__FM__Site_reset_escalation_to_BTS_power_reset
    [Timeout]    14400
    [Setup]  Run Keywords
    ...  No Operation
    ...  AND  Set additional ignored alarms variable
    ...  AND  Set Test Variable  ${BBMOD_SN}  L1204101519
    ...  AND  Set Test Variable  ${STARTUP_TIMEOUT}  900
    ...  AND  Set Test Variable  ${RECOVERY_TIMEOUT}  960
    ...  AND  Set Test Variable  ${ALARM_TIMEOUT}     580
    ...    AND    Set Test Variable    ${PING_TIMEOUT}    420
    ...    AND    Set Test Variable    ${NETACT_TIMEOUT}    540
    ...    AND    FM__Site_reset_escalation_to_BTS_power_reset.TC Setup
    ...    AND    Modify Resource Search Order    FM__Site_reset_escalation_to_BTS_power_reset
    TC__FM__Site_reset_escalation_to_BTS_power_reset
    [Teardown]    Run Keywords    FM__Site_reset_escalation_to_BTS_power_reset.TC Teardown
    ...    AND    Restore Resource Search Order

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
