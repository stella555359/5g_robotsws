*** Settings ***
Documentation
...  Test Suite Author: Lukasz Wystup Marek Gazarkiewicz
...  Test Suite Owner: Bartosz Busz
...  Team: T01

Resource          ../../../test_resources/STATE/STATE__Site_reset.robot
Resource          ../../../../../resources/ca_4G_RRM_carrier_aggregation.robot
Resource          ../../../test_resources/BS-SM/SiSo_PM_Counters_for_QSFP_BBMOD_dynamic_parameters_via_Netact.robot



*** Variables ***

${HW_LOCATION_CODE}      Wroclaw
${COMMISSIONING_PATH}    /home/ute/testline_configuration/10_16_UTESRANSISO001/node1/10_16_UTESRANSISO001_25R1.xml
${COLLECT_SNAPSHOT_FLAG}    Never
${TESTLINE_NAME}  10_16_UTESRANSISO001

*** Test Cases ***


[AUTO][4.0] Automated_SiSo_BTS_Startup_Multiple_Site_Reset
    [Setup]    Run Keywords  Set Test Variable    ${RESTORE_TIMEOUT}    20
    ...    AND    Set Test Variable    ${COMMISSIONING_PATH}
    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
    ...    AND    STATE__Site_reset.TC Setup
    ...    AND    Set Library Search Order    STATE__Site_reset
    [Timeout]    14400
    TC__STATE__Site_reset
    [Teardown]     STATE__Site_reset.TC Teardown


[AUTO][1.0] Automated__SiSo_PM_Counters_for_QSFP_dynamic_parameters
    [Setup]    Run Keywords
    ...    SiSo_PM_Counters_for_QSFP_BBMOD_dynamic_parameters_via_Netact.TC Setup
    ...    AND    Set Library Search Order    netact
    [Timeout]    14400
    TC__SiSo_PM_Counters_for_QSFP_BBMOD_dynamic_parameters_via_Netact
    [Teardown]    SiSo_PM_Counters_for_QSFP_BBMOD_dynamic_parameters_via_Netact.TC Teardown

