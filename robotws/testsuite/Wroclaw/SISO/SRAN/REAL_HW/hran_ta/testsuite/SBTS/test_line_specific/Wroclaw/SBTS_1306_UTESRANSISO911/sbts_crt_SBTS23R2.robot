*** Settings ***
Documentation
...   Test Suite Author: Przemyslaw Kempa
...   Test Suite Owner: Przemyslaw Kempa

Force Tags        QCD_MN_RAN    QCP_RAN_ST    CRT    CLOUD_SRAN_LWG_1ASIB_2ABIA_1ASIA_1ABIA_2FXDB_1FXED_1FRIE_1FHFB_1FHDB    SBTS23R2
Library           XML    use_lxml=True


Resource          ../../../../../resources/ca_4G_RRM_carrier_aggregation.robot

Resource          ../../../test_resources/STATE/STATE__Radio_module_reset_from_admin.robot
Resource          ../../../test_resources/STATE/STATE__Site_power_reset.robot
Resource          ../../../test_resources/STATE/STATE__Site_reset.robot
Resource          ../../../test_resources/STATE/STATE__WCDMA_RAT_reset_from_ADMIN.robot




*** Variables ***
${HW_LOCATION_CODE}    Wroclaw
${SCF_ID}              01
${COMMISSIONING_PATH}
...  /home/ute/testline_configuration/10_16_UTESRANSISO911/node1/BTS_CLOUD_SRAN_LWG_1ASIB_2ABIA_1ASIA_1ABIA_2FXDB_1FXED_1FRIE_1FHFB_1FHDB_SBTS23R2.xml

*** Test Cases ***

[1]Automated__STATE__Radio_module_reset_from_Admin
    [Setup]    Run Keywords    Set Test Variable    ${RMOD_SERIAL_NUMBER}
    ...    AND    Set Test Variable    ${RESET_TIMEOUT}    180
    ...    AND    Set Test Variable    ${RESETTYPE}    Warm
    ...    AND    Set Test Variable    ${BCF_VERIFICATION_TIMEOUT}    5 minutes
    ...    AND    Set Library Search Order    STATE__Radio_module_reset_from_admin
    ...    AND    STATE__Radio_module_reset_from_admin.TC Setup
    [Timeout]    14400
    TC__STATE__Radio_module_reset_from_admin
    [Teardown]    Run Keywords    STATE__Radio_module_reset_from_admin.TC Teardown
	...    AND    Run Keyword If Test Failed  ca_4G_RRM_carrier_aggregation.Recovery Action



[1]Automated__STATE__WCDMA_RAT_reset_from_ADMIN
    [Setup]    Run Keywords    Set Test Variable    ${WCDMA_RAT_RESET_TIMEOUT}    180
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Library Search Order    STATE__WCDMA_RAT_reset_from_ADMIN
    ...    AND    STATE__WCDMA_RAT_reset_from_ADMIN.TC Setup
    [Timeout]    14400
    TC__STATE__WCDMA_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    STATE__WCDMA_RAT_reset_from_ADMIN.TC Teardown
	...    AND    Run Keyword If Test Failed  ca_4G_RRM_carrier_aggregation.Recovery Action


[1]Automated__STATE_SBTS Site reset from ADMIN
    [Setup]    Run Keywords    Set Test Variable    ${RESTORE_TIMEOUT}    10
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Library Search Order    STATE__Site_reset
    ...    AND    STATE__Site_reset.TC Setup
    [Timeout]    14400
    TC__STATE__Site_reset
    [Teardown]    Run Keywords    STATE__Site_reset.TC Teardown
	...    AND    Run Keyword If Test Failed  ca_4G_RRM_carrier_aggregation.Recovery Action


[1]Automated__STATE__Site_Power_Reset
    [Setup]    Run Keywords    Set Test Variable    ${RESTORE_TIMEOUT}    10
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    Set Library Search Order    STATE__Site_power_reset
    ...    AND    STATE__Site_power_reset.TC Setup
    [Timeout]    14400
    TC__STATE__Site_power_reset
    [Teardown]    Run Keywords    STATE__Site_power_reset.TC Teardown
	...    AND    Run Keyword If Test Failed  ca_4G_RRM_carrier_aggregation.Recovery Action






