*** Settings ***
Documentation
...  Test Suite Author: Mateusz Chryplewicz
...  Test Suite Owner: Mateusz Chryplewicz
...  Team: T01


Resource          ../../../../../resources/ca_4G_RRM_carrier_aggregation.robot
Resource          ../../../test_resources/BS-RF/BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM__RP000951__Automated.robot
Resource          ../../../test_resources/BS-RF/BS-RF__Embedded_Power_Meter_EEM_real_time_counters_during_RF_lock_unlock__RP000951__Automated.robot



*** Variables ***
${HW_LOCATION_CODE}      Wroclaw
${TESTLINE_NAME}    10_16_UTESRANSISO136
${COLLECT_SNAPSHOT_FLAG}    failed_verdict
${COMMISSIONING_PATH}   /home/ute/testline_init_results/execution/configs/topology_configs/node_1/10_16_UTESRANSISO136_DEFAULT.xml

*** Test Cases ***
[1][1.0] Automated_SiSo_PM_Energy_Efficiency_Monitoring_Real_Time_Measurements_During_RU_Block_Unblock
    [Setup]    Run Keywords    Set Test Variable    ${RMOD_SN}    AH250400463
    ...    AND    Set Test Variable    ${RMODS}    9
    ...    AND    Set Test Variable    ${TIME_TO_WAIT}    7
    ...    AND    Set Test Variable    ${PATH_TO_DOWNLOAD_CSV}    /home/ute/Downloads
    ...    AND    BS-RF__Embedded_Power_Meter_EEM_real_time_counters_during_RF_lock_unlock__RP000951__Automated.TC Setup
    ...    AND    Set Library Search Order    BS-RF__Embedded_Power_Meter_EEM_real_time_counters_during_RF_lock_unlock__RP000951__Automated
    [Timeout]    14400
    TC__BS-RF__Embedded_Power_Meter_EEM_real_time_counters_during_RF_lock_unlock__RP000951__Automated
    [Teardown]    Run Keywords     BS-RF__Embedded_Power_Meter_EEM_real_time_counters_during_RF_lock_unlock__RP000951__Automated.TC Teardown
	...    AND    Run Keyword If Test Failed  ca_4G_RRM_carrier_aggregation.Recovery Action


[1][1.0] Automated_SiSo_PM_Energy_Efficiency_Monitoring_Act_Deact_SBTS_Counters_And_Power_Voltage_Measurements
    [Setup]    Run Keywords    Set Test Variable    ${INTERVAL}    15
    ...    AND    Set Test Variable    ${RMODS}    9
    ...    AND    BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM__RP000951__Automated.TC Setup
    ...    AND    Set Library Search Order    BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM__RP000951__Automated
    [Timeout]    14400
    TC__BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM__RP000951__Automated
    [Teardown]    Run Keywords     BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM__RP000951__Automated.TC Teardown
	...    AND    Run Keyword If Test Failed  ca_4G_RRM_carrier_aggregation.Recovery Action
