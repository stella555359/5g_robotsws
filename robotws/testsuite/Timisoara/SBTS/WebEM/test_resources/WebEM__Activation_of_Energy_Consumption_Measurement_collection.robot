*** Settings ***
Documentation
    ...  This TC is created to check and get BTS counters's values and real-time measurements.
    ...  4 parameters will be changed:
    ...  actPowerMeter, mtBtsEnergyMonitoring, mtSBTSRfmEnergyMonitoring,mtSBTSSmEnergyMonitoring.
    ...  BTS Counters will be collected every 15 minutes cycle.
    ...  Real-time measurements will be collected every 1 minute.
    ...  All these values will be logged.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
@{LIST_RMODS_WITH_EPM}  AHLOA
@{LIST_RMODS_WITHOUT_EPM}  FXDB


*** Keywords ***
TC__WebEM__Activation_of_Energy_Consumption_Measurement_collection
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21286 - Initial creation
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  28.4.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21286 - Initial creation
    ...  25.10.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22104 - Changes on real-time measurements for RMODS
    ...  29.08.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23601 - Values are changed for RMODs without EPM
    ...  25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  21.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26540 - Adapt TC to CB009480
    ...  05.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26673 - Add suport for branch
    ...  26.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26995 - Ignore not supported RMODs

    Set Tags  CA-WebEM  OWNER-nicolae-marcel.caragel@nokia.com  AUTHOR-cosmina.rebenciuc@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS21B

    Step1: Modify Parameters For Energy Consumption Measurement
    Step2: Check BTS Counters
    Step3: Get Real-time Measurements


Step1: Modify Parameters For Energy Consumption Measurement
    Log  Step1: Modify Parameters for Energy Consumption Measurement  console=true
    Change And Get ActPowerMeter Parameter Value
    Sleep  120s
    Change And Get Parameter Value  mtBtsEnergyMonitoring
    Sleep  15s
    Change And Get Parameter Value  mtSBTSRfmEnergyMonitoring
    Sleep  15s
    Change And Get Parameter Value  mtSBTSSmEnergyMonitoring
    Sleep  15s


Step2: Check BTS Counters
    Log  Step2: Check BTS counters  console=true
    Repeat Keyword  3 times
    ...  Get BTS Counters Values


Step3: Get Real-time Measurements
    Log  Step3: Get real-time measurements  console=true
    Repeat Keyword  3 times
    ...  Get Real Time Measurements


Change And Get ActPowerMeter Parameter Value
    Log  Change parameter actPowerMeter  console=true
    ${initial_value}  Get ActPowerMeter Value From Infomodel  actPowerMeter
    Log  actPowerMeter value is ${initial_value}  console=true
    ${status}  Run Keyword And Return Status
    ...  Change Parameter ActPowerMeter  true  actPowerMeter
    ${parameter_after_change}  Get ActPowerMeter Value From Infomodel  actPowerMeter
    Log  Parameter after change: ${parameter_after_change}  console=true
    Run Keyword If  ${status}
    ...  Should Be Equal  ${parameter_after_change}  true


Change And Get Parameter Value
    [Arguments]  ${parameter_name}

    Log  Change parameter ${parameter_name}  console=true
    ${initial_value}  Get Parameter Value From Infomodel  ${parameter_name}
    Log  Initial value is ${initial_value}  console=true
    ${status}  Run Keyword And Return Status
    ...  Change Parameter  15min  ${parameter_name}
    ${parameter_after_change}  Get Parameter Value From Infomodel  ${parameter_name}
    Log  Parameter after change: ${parameter_after_change}  console=true
    Run Keyword If  ${status}
    ...  Should Be Equal  ${parameter_after_change}  15min


Get ActPowerMeter Value From Infomodel
    [Documentation]
    ...  This KW is created to check what value has parameter actPowerMeter.
    [Arguments]  ${im_parameter}

    ${parametr_name}  Convert To String  ${im_parameter}
    ${parameter_object}  Query Infomodel  get object /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/MNL_CONF_M-1/MNLENT_CONF_M-1/FEATCADM_CONF_M-1
    ${parameter_object_value_string}  Convert To String  ${parameter_object.${parametr_name}}
    ${parameter_object_lower}  Convert To Lowercase  ${parameter_object_value_string}

    [Return]  ${parameter_object_lower}


Change Parameter ActPowerMeter
    [Arguments]  ${value}  ${parameter_name}

    ${dist_name_bts_id}  Set Variable  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ${get_parameter_value}  Get ActPowerMeter Value From Infomodel  ${parameter_name}
    Run Keyword If  '${get_parameter_value}'!='${value}'
    ...  Run Keywords
    ...  Perform Parameter Recommissioning  ${dist_name_bts_id}
    ...  ${parameter_name}
    ...  update
    ...  ${value}
    ...  skip_parameter_relation_errors=true
    ...  should_activate=true
    ...  timeout=300
    ...  AND
    ...  Log  ${parameter_name} will be changed to ${value}  console=true


Get Parameter Value From Infomodel
    [Documentation]
    ...  This KW is created to check what value have the given parameter:
    ...  mtBtsEnergyMonitoring, mtSBTSRfmEnergyMonitoring, mtSBTSSmEnergyMonitoring
    [Arguments]  ${im_parameter}

    ${parametr_name}  Convert To String  ${im_parameter}
    ${parameter_object}  Query Infomodel  get object //MRBTS_A-${BTS_ID}/MNL_A-1/MNLENT_A-1/PMMNL_A-1
    ${parameter_object_value_string}  Convert To String  ${parameter_object.${parametr_name}}
    ${parameter_object_lower}  Convert To Lowercase  ${parameter_object_value_string}

    [Return]  ${parameter_object_lower}


Change Parameter
    [Documentation]
    ...  This KW is created to check what value have the given parameter:
    ...  mtBtsEnergyMonitoring, mtSBTSRfmEnergyMonitoring, mtSBTSSmEnergyMonitoring
    [Arguments]  ${value}  ${parameter_name}

    ${dist_name_bts_id}  Set Variable  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1
    ${get_parameter_value}  Get Parameter Value From Infomodel  ${parameter_name}
    Run Keyword If  '${get_parameter_value}'!='${value}'
    ...  Run Keywords
    ...  Perform Parameter Recommissioning  ${dist_name_bts_id}
    ...  ${parameter_name}
    ...  update
    ...  ${value}
    ...  skip_parameter_relation_errors=true
    ...  should_activate=true
    ...  timeout=300
    ...  AND
    ...  Log  ${parameter_name} will be changed to ${value}  console=true


Get BTS Counters Values
    Sleep Until New 15 Minutes Cycle
    Sleep  60s
    Check BTS Counter  M40002C0
    Check BTS Counter  M40002C1
    Check BTS Counter  M40002C2


Check BTS Counter
    [Arguments]  ${counter_id}

    Log  Get ${counter_id} counter's values  console=true
    ${dist_name}  Set Variable If  '${ENB_BRANCH}'=='SBTS00' or '${ENB_BRANCH}'>='SBTS24R2'
    ...  BTS/MRBTS-${BTS_ID}/SBTS_Energy_Consumption/${counter_id}  BTS/BTS/MRBTS-${BTS_ID}/SBTS_Energy_Consumption/${counter_id}
    ${value_2_c}  Run Keyword And Ignore Error
    ...  Get_counters_info  dist_name=${dist_name}  timeout=120
    ${list_value_2_c}  Convert To List  ${value_2_c}
    ${2_c_object}  Get From List  ${list_value_2_c}  1
    ${dict}  Set Variable If  '${ENB_BRANCH}'=='SBTS00' or '${ENB_BRANCH}'>='SBTS24R2'
    ...  ${2_c_object}[BTS][MRBTS-${BTS_ID}][SBTS_Energy_Consumption][${counter_id}]
    ...  ${2_c_object}[BTS][BTS][MRBTS-${BTS_ID}][SBTS_Energy_Consumption][${counter_id}]
    ${counter_value}  Get Dictionary Values  ${dict}
    ${last_value}  Get From List  ${counter_value}  -1
    Log  Last value for counter ${counter_id}: ${last_value}  console=true


Get Real Time Measurements
    ${list_of_measurements}  GetMeasurements  connection=default
    FOR  ${item}  IN  @{list_of_measurements}
        ${key}  Get Dictionary Keys  ${item}
        ${status}  Run Keyword And Return Status
        ...  Should Contain  ${key}[0]  ENERGY_EFFICIENCY
        Run Keyword If  ${status}
        ...  Get Values Of Measurements  ${item}
    END
    Sleep  60s


Get Values Of Measurements
    [Arguments]  ${item}

    Log  ${item}  console=true
    ${key}  Get Dictionary Keys  ${item}
    ${values}  Get Dictionary Values  ${item}
    Run Keyword If  ${values} == ['Not supported']
    ...  Return From Keyword
    ${list_of_values}  Get Dictionary Values  ${values}[0]
    Log  ${list_of_values}  console=true
    ${status}  Run Keyword And Return Status
    ...  Should Contain  ${key}[0]  RMOD
    Run Keyword If  ${status}
    ...  Get Values Of Measurements For RMODS  ${key}  ${list_of_values}
    ...  ELSE
    ...  Compare Real-time Measurements For SMODS  ${list_of_values}


Get Values Of Measurements For RMODS
    [Arguments]  ${key}  ${list_of_values}

    ${rmod_r_path}  Fetch From Right  @{key}  /RMOD/
    ${list_rmod}  Query Infomodel  get object //${rmod_r_path}
    ${status_contain}  Run Keyword And Return Status
    ...  Should Contain  ${LIST_RMODS_WITH_EPM}  ${list_rmod}[productName]
    Run Keyword If  ${status_contain}
    ...  Compare Real-time Measurements For RMODS With Embedded Power Meter  ${list_of_values}
    ...  ELSE
    ...  Compare Real-time Measurements For RMODS Without Embedded Power Meter  ${list_of_values}


Compare Real-time Measurements For RMODS With Embedded Power Meter
    [Documentation]  Energy measurement should be greater than 0.
    [Arguments]  ${values}

    FOR  ${energy_measurement}  IN  @{values}
        ${converted_measurement}  Convert To String  ${energy_measurement}
        Run Keyword If  ${energy_measurement} > 0
        ...  Log  Energy measurement: ${energy_measurement} is ok  console=true
        ...  ELSE
        ...  Set Test Failed  Energy measurement: ${energy_measurement} is not ok
    END


Compare Real-time Measurements For RMODS Without Embedded Power Meter
    [Documentation]  Energy measurement should be equal to 0.
    [Arguments]  ${values}

    FOR  ${energy_measurement}  IN  @{values}
        ${converted_measurement}  Convert To String  ${energy_measurement}
        Run Keyword If  '${energy_measurement}' == '-'
        ...  Log  Energy measurement: ${energy_measurement} is ok  console=true
        ...  ELSE
        ...  Set Test Failed  Energy measurement: ${energy_measurement} is not ok
    END


Compare Real-time Measurements For SMODS
    [Documentation]  Energy measurement should be greater than 0.
    [Arguments]  ${values}

    FOR  ${energy_measurement}  IN  @{values}
        ${converted_measurement}  Convert To String  ${energy_measurement}
        Run Keyword If  '${converted_measurement}'=='Not Supported'
        ...  Continue For Loop
        Run Keyword If  ${energy_measurement} > 0
        ...  Log  Energy measurement: ${energy_measurement} is ok  console=true
        ...  ELSE
        ...  Set Test Failed  Energy measurement: ${energy_measurement} is not ok
    END


TC Setup
    Common Test Setup


TC Teardown
    Common Test Teardown
