*** Settings ***
Documentation
...  Test Suite Author: Lukasz Wystup Marek Gazarkiewicz
...  Test Suite Owner: Bartosz Busz
...  Team: T01

Resource          ../../../test_resources/STATE/STATE__Site_reset.robot
Resource          ../../../../../resources/ca_4G_RRM_carrier_aggregation.robot
Resource          ../../../test_resources/BS-SM/SiSo_PM_Counters_for_QSFP_BBMOD_dynamic_parameters_via_Netact.robot
Resource          ../../../test_resources/BS-RF/BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM__RP000951__Automated.robot
Resource          ../../../test_resources/BS-RF/BS-RF__Embedded_Power_Meter_EEM_real_time_counters_during_RF_lock_unlock__RP000951__Automated.robot



*** Variables ***

${HW_LOCATION_CODE}      Wroclaw
${COMMISSIONING_PATH}    /home/ute/testline_configuration/10_16_UTESRANSISO001/node1/10_16_UTESRANSISO001_25R2.xml
${COLLECT_SNAPSHOT_FLAG}    Never
${TESTLINE_NAME}  10_16_UTESRANSISO001

*** Test Cases ***
[Real_time_counters][1.0] Automated_SiSo_PM_Energy_Efficiency_Monitoring_Real_Time_Measurements_During_RU_Block_Unblock
    [Setup]    Run Keywords    Set Test Variable    ${RMOD_SN}    K9200215155
    ...    AND    Set Test Variable    ${RMODS}    6
    ...    AND    Set Test Variable    ${TIME_TO_WAIT}    7
    ...    AND    Set Test Variable    ${PATH_TO_DOWNLOAD_CSV}    /home/ute/Downloads
    ...    AND    BS-RF__Embedded_Power_Meter_EEM_real_time_counters_during_RF_lock_unlock__RP000951__Automated.TC Setup
    ...    AND    Set Library Search Order    BS-RF__Embedded_Power_Meter_EEM_real_time_counters_during_RF_lock_unlock__RP000951__Automated
    [Timeout]    14400
    TC__BS-RF__Embedded_Power_Meter_EEM_real_time_counters_during_RF_lock_unlock__RP000951__Automated
    [Teardown]    Run Keywords     BS-RF__Embedded_Power_Meter_EEM_real_time_counters_during_RF_lock_unlock__RP000951__Automated.TC Teardown
	...    AND    Run Keyword If Test Failed  ca_4G_RRM_carrier_aggregation.Recovery Action


[Act_deact_webem][1.0] Automated_SiSo_PM_Energy_Efficiency_Monitoring_Act_Deact_SBTS_Counters_And_Power_Voltage_Measurements
    [Setup]    Run Keywords    Set Test Variable    ${INTERVAL}    15
    ...    AND    Set Test Variable    ${RMODS}    6
    ...    AND    BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM__RP000951__Automated.TC Setup
    ...    AND    Set Library Search Order    BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM__RP000951__Automated
    [Timeout]    14400
    TC__BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM__RP000951__Automated
    [Teardown]    Run Keywords     BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM__RP000951__Automated.TC Teardown
	...    AND    Run Keyword If Test Failed  ca_4G_RRM_carrier_aggregation.Recovery Action

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
    ...    AND    Set Library Search Order    netact  SiSo_PM_Counters_for_QSFP_BBMOD_dynamic_parameters_via_Netact
    [Timeout]    14400
    TC__SiSo_PM_Counters_for_QSFP_BBMOD_dynamic_parameters_via_Netact
    [Teardown]    SiSo_PM_Counters_for_QSFP_BBMOD_dynamic_parameters_via_Netact.TC Teardown

