*** Settings ***
Documentation
...    Responsible tester: grzegorz.oklinski@nokia.com

Resource    ../../../../../resources/ca_4G_RRM_carrier_aggregation.robot
Resource    ../../../test_resources/BS-RF/BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM__RP000951__Automated.robot
Resource    ../../../test_resources/BS-RF/BS-RF__Embedded_Power_Meter_EEM_real_time_counters_during_RF_lock_unlock__RP000951__Automated.robot
Resource    ../../../test_resources/BS-RF/SiSo_PM_of_Cell_Availability_monitoring_with_Energy_Efficiency_Enhancement.robot

*** Variables ***

#=======================================hran_part=======================================
${COMMISSIONING_PATH}  		 /home/ute/testline_init_results/execution/configs/topology_configs/node_1/CLOUD_10_16_UTESRANSISO027_SBTS00.xml
${HW_LOCATION_CODE}          Wroclaw
${COLLECT_SNAPSHOT_FLAG}     failed_verdict
${TESTLINE_NAME}             10_16_UTESRANSISO027
${ENABLE_TRUCK_ROLL_FLAG}    ${False}

*** Test Cases ***
[AWHQN][1.0] Automated_SiSo_PM_Energy_Efficiency_Monitoring_Act_Deact_SBTS_Counters_And_Power_Voltage_Measurements
    [Setup]    Run Keywords    Set Test Variable    ${INTERVAL}    15
    ...    AND    Set Test Variable    ${RMODS}    1
    ...    AND    BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM__RP000951__Automated.TC Setup
    ...    AND    Set Library Search Order    BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM__RP000951__Automated
    [Timeout]    14400
    TC__BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM__RP000951__Automated
    [Teardown]    Run Keywords     BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM__RP000951__Automated.TC Teardown
    ...    AND    Run Keyword If Test Failed  ca_4G_RRM_carrier_aggregation.Recovery Action

[AWHQN][2.0] Automated_SiSo_PM_of_Cell_Availability_monitoring_with_Energy_Efficiency_Enhancement
    [Setup]  Run Keywords  Set Test Variable  ${COMMISSIONING_PATH}
    ...  AND  Set Test Variable  ${RMOD_SN}   AH242903796
    ...  AND  Set Test Variable  ${SKIP_LTE}   ${TRUE}
    ...  AND  Set Test Variable  @{RADIOS_NOT_SUPPORTING_DEEPSLEEP_SN_LIST}   AH242903796
    ...  AND  SiSo_PM_of_Cell_Availability_monitoring_with_Energy_Efficiency_Enhancement.TC Setup
    ...  AND  Set Library Search Order    SiSo_PM_of_Cell_Availability_monitoring_with_Energy_Efficiency_Enhancement
    [Timeout]  14400
    TC__SiSo_PM_of_Cell_Availability_monitoring_with_Energy_Efficiency_Enhancement
    [Teardown]  SiSo_PM_of_Cell_Availability_monitoring_with_Energy_Efficiency_Enhancement.TC Teardown

[AWHQN][1.0] Automated_SiSo_PM_Energy_Efficiency_Monitoring_Real_Time_Measurements_During_RU_Block_Unblock
    [Setup]    Run Keywords    Set Test Variable    ${RMOD_SN}    AH242903796
    ...    AND    Set Test Variable    ${RMODS}    1	#How many RMODs in configuration support Embedded Power Meter feature
    ...    AND    Set Test Variable    ${TIME_TO_WAIT}    7	#Waiting time in mimutes between CSV file export
    ...    AND    Set Test Variable    ${PATH_TO_DOWNLOAD_CSV}    /home/ute/Downloads
    ...    AND    BS-RF__Embedded_Power_Meter_EEM_real_time_counters_during_RF_lock_unlock__RP000951__Automated.TC Setup
    ...    AND    Set Library Search Order    BS-RF__Embedded_Power_Meter_EEM_real_time_counters_during_RF_lock_unlock__RP000951__Automated
    [Timeout]    14400
    TC__BS-RF__Embedded_Power_Meter_EEM_real_time_counters_during_RF_lock_unlock__RP000951__Automated
    [Teardown]    Run Keywords     BS-RF__Embedded_Power_Meter_EEM_real_time_counters_during_RF_lock_unlock__RP000951__Automated.TC Teardown
	...    AND    Run Keyword If Test Failed  ca_4G_RRM_carrier_aggregation.Recovery Action
