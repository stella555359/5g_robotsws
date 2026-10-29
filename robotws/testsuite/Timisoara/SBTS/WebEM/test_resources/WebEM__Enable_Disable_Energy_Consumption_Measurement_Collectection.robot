*** Settings ***
Documentation
    ...  This TC is created to check and get BTS counters's values.
    ...  Reset Site is performed to clear all counters.
    ...  Next parameters are changed: actPowerMeter to be false, mtBtsEnergyMonitoring to be 15min,
    ...  mtSBTSRfmEnergyMonitoring to be 15min ,mtSBTSSmEnergyMonitoring to be 15min.
    ...  Check if all counters (M40002C, M40003C and M40004C) are not available.
    ...  actPowerMeter parameter is changed to be true.
    ...  BTS Counters will be collected oncer after 15 minutes cycle.
    ...  Real-time measurements will be collected every 1 minute.
    ...  All these values will be logged.
    ...  Next parameters are changed: actPowerMeter to be false, mtBtsEnergyMonitoring to be 15min,
    ...  mtSBTSRfmEnergyMonitoring to be 60min ,mtSBTSSmEnergyMonitoring to be disabled.
    ...  Reset Site is performed to clear all counters.
    ...  Sleep 15min.
    ...  Check if all counters (M40002C, M40003C and M40004C) are not available.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  1200  # Time for SBTS to recovery
@{LIST_RMODS_WITH_EPM}  AHEGA  AHFIA  # List of RMODS on SBTS with EPM


*** Keywords ***
TC__WebEM__Enable_Disable_Energy_Consumption_Measurement_Collectection
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-22664 - Initial creation
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  14.02.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22664 - Initial creation
    ...  29.08.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23601 - Values are changed for RMODs without EPM
    ...  25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  15.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24316 - Refactor WebEM TCs and resources to use KWs from ca_SBTS_general
    ...  21.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26540 - Adapt TC to CB009480
    ...  05.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26673 - Add suport for branch
    ...  02.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26803 - Ignore incompatible Bbmod with this feature
    ...  16.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26908 - Fix dictionary has no key error
    ...  22.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26992 - Add last step for actPowerMeter to be true
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring
    ...  21.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27174 - Switch step 1 with step 2
    ...  14.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27482 - Add more time before counters check
    ...  28.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30058 - Increase sleep timeout

    Set Tags  CA-WebEM  OWNER-sergiu.verlan@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS22

    Step0: Set Preconditions
    Step1: Modify Parameters For Energy Consumption Measurement In 15min And ActPowerMeter To Be false
    Step2: Reset Site
    Step3: Verify All Counters To Not Be Available
    Step4: Modify ActPowerMeter Parameter
    Step5: Check BTS Counters
    Step6: Get Real-time Measurements
    Step7: Modify Parameters And Reset Site
    Step8: Verify All Counters To Not Be Available
    Step9: Modify Parameters For Energy Consumption Measurement In 15min And ActPowerMeter To Be true


Step0: Set Preconditions
    ${list_of_rmods}  Query Infomodel  get list //MRBTS_A-${BTS_ID}/EQM_A-1/APEQM_A-1/RMOD_A-*
    Set Test Variable  ${LIST_OF_RMODS}
    ${list_of_smods}  Get Ids For All  SMOD  timeout=60
    Set Test Variable  ${LIST_OF_SMODS}


Step${index}: Modify Parameters For Energy Consumption Measurement In 15min And ActPowerMeter To Be ${value}
    Log  \nStep${index}: Modify Parameters for Energy Consumption Measurement in 15min and actPowerMeter to be ${value}  console=true
    Change ActPowerMeter Parameter To Specific Value And Parameters For Energy Consumption Measurement In 15min  ${value}


Step2: Reset Site
    Log  \nStep1: Reset Site  console=true
    Log  Performing a Site Reset to clear the counters  console=true
    coam.Reset Site
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Admin Check All Required State


Step${id}: Verify All Counters To Not Be Available
    Log  \nStep${id}: Verify all counters to not be available  console=true
    ${2_c_counters}  Create List  M40002C0  M40002C1  M40002C2
    ${3_c_counters}  Create List  M40003C0  M40003C1  M40003C2  M40003C3  M40003C4  M40003C5
    ${4_c_counters}  Create List  M40004C0  M40004C1  M40004C2  M40004C3  M40004C4  M40004C5
    ${dist_name}  Set Variable If  '${ENB_BRANCH}'=='SBTS00' or '${ENB_BRANCH}'>='SBTS24R2'  BTS/MRBTS-${BTS_ID}/SBTS_Energy_Consumption
    ...  BTS/BTS/MRBTS-${BTS_ID}/SBTS_Energy_Consumption
    FOR  ${2c_counter_id}  IN  @{2_c_counters}
        Log  \nCheck if counter ${2c_counter_id} is not available...  console=true
        ${value_for_2c}  Run Keyword And Return Status
        ...  Get Counters Info  dist_name=${dist_name}/${2c_counter_id}  timeout=10
        IF  ${value_for_2c}
            Fail  Counter ${2c_counter_id} is available![NOK]
        ELSE
            Log  Counter ${2c_counter_id} is not available![OK]  console=true
        END
    END
    FOR  ${3c_counter_id}  IN  @{3_c_counters}
        Check M40003C Counter To Be Unavailable  ${3c_counter_id}
    END
    FOR  ${4c_counter_id}  IN  @{4_c_counters}
        Check M40004C Counter To Be Unavailable  ${4c_counter_id}
    END


Step4: Modify ActPowerMeter Parameter
    Log  \nStep4: Modify actPowerMeter parameter  console=true
    Change ActPowerMeter Parameter  true
    Sleep  120s  Time for actPowerMeter parameter to be changed


Step5: Check BTS Counters
    Log  \nStep5: Check BTS counters  console=true
    Reset Admin
    Sleep Until New 15 Minutes Cycle
    Sleep  180s  Time for value to appear.
    Check M40002C BTS Counter  M40002C0
    Check M40002C BTS Counter  M40002C1
    Check M40002C BTS Counter  M40002C2
    Check M40003C BTS Counter  M40003C0
    Check M40003C BTS Counter  M40003C1
    Check M40003C BTS Counter  M40003C2
    Check M40003C BTS Counter  M40003C4
    Check M40003C BTS Counter  M40003C5
    Check M40004C BTS Counter  M40004C0
    Check M40004C BTS Counter  M40004C1
    Check M40004C BTS Counter  M40004C2
    Check M40004C BTS Counter  M40004C3
    Check M40004C BTS Counter  M40004C4
    Check M40004C BTS Counter  M40004C5


Step6: Get Real-time Measurements
    Log  \nStep6: Get real-time measurements  console=true
    Repeat Keyword  3 times
    ...  Get Real Time Measurements


Step7: Modify Parameters And Reset Site
    Log  \nStep7: Modify parameters and Reset Site  console=true
    Change ActPowerMeter Parameter  false
    Sleep  120s  Time for actPowerMeter parameter to be changed
    Change Parameters mtBtsEnergyMonitoring, mtSBTSRfmEnergyMonitoring, mtSBTSSmEnergyMonitoring  mtBtsEnergyMonitoring  15min
    Sleep  15s  Time for mtBtsEnergyMonitoring parameter to be changed
    Change Parameters mtBtsEnergyMonitoring, mtSBTSRfmEnergyMonitoring, mtSBTSSmEnergyMonitoring  mtSBTSRfmEnergyMonitoring  60min
    Sleep  15s  Time for mtSBTSRfmEnergyMonitoring parameter to be changed
    Change Parameters mtBtsEnergyMonitoring, mtSBTSRfmEnergyMonitoring, mtSBTSSmEnergyMonitoring  mtSBTSSmEnergyMonitoring  disabled
    Sleep  15s  Time for mtSBTSSmEnergyMonitoring parameter to be changed
    Log  Performing a Site Reset to clear the counters  console=true
    coam.Reset Site
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Admin Check All Required State
    Log  Sleep 15min for counters to be disabled!  console=true
    Sleep  900s  Time for counters to be disabled.
    Reset Admin


Change ActPowerMeter Parameter To Specific Value And Parameters For Energy Consumption Measurement In 15min
    [Arguments]  ${value}

    Change ActPowerMeter Parameter  ${value}
    Sleep  120s  Time for actPowerMeter parameter to be changed
    Change Parameters mtBtsEnergyMonitoring, mtSBTSRfmEnergyMonitoring, mtSBTSSmEnergyMonitoring  mtBtsEnergyMonitoring  15min
    Sleep  120s  Time for mtBtsEnergyMonitoring parameter to be changed
    Change Parameters mtBtsEnergyMonitoring, mtSBTSRfmEnergyMonitoring, mtSBTSSmEnergyMonitoring  mtSBTSRfmEnergyMonitoring  15min
    Sleep  120s  Time for mtSBTSRfmEnergyMonitoring parameter to be changed
    Change Parameters mtBtsEnergyMonitoring, mtSBTSRfmEnergyMonitoring, mtSBTSSmEnergyMonitoring  mtSBTSSmEnergyMonitoring  15min
    Sleep  120s  Time for mtSBTSSmEnergyMonitoring parameter to be changed


Change ActPowerMeter Parameter
    [Documentation]  This KW is changing actPowerMeter parameter to a specific value.
    [Arguments]  ${value}

    ${status}  Run Keyword And Return Status
    ...  Perform Parameter Recommissioning  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...  actPowerMeter
    ...  update
    ...  ${value}
    ...  skip_parameter_relation_errors=True
    IF  ${status}
        Log  Parameter actPowerMeter is set to ${value}![OK]  console=true
    ELSE
        Fail  Parameter actPowerMeter is not set to ${value}![NOK]
    END


Get Real Time Measurements
    ${list_of_measurements}  GetMeasurements
    FOR  ${item}  IN  @{list_of_measurements}
        ${key}  Get Dictionary Keys  ${item}
        ${status}  Run Keyword And Return Status  Should Contain  ${key}[0]  ENERGY_EFFICIENCY
        ${values}  Get Dictionary Values  ${item}
        IF  ${status} and ${values} != ['Not supported']  Get Values Of Measurements  ${item}
    END
    Sleep  60s  Time for another value to appear.


Get Values Of Measurements
    [Arguments]  ${item}

    Log  ${item}  console=true
    ${key}  Get Dictionary Keys  ${item}
    ${values}  Get Dictionary Values  ${item}
    ${list_of_values}  Get Dictionary Values  ${values}[0]
    Log  ${list_of_values}  console=true
    ${status}  Run Keyword And Return Status  Should Contain  ${key}[0]  RMOD
    IF  ${status}
        Get Values Of Measurements For RMODS  ${key}  ${list_of_values}
    ELSE
        Compare Real-time Measurements For SMODS  ${list_of_values}
    END


Get Values Of Measurements For RMODS
    [Arguments]  ${key}  ${list_of_values}

    ${rmod_r_path}  Fetch From Right  @{key}  /RMOD/
    ${list_rmod}  Query Infomodel  get object //${rmod_r_path}
    ${status_contain}  Run Keyword And Return Status
    ...  Should Contain  ${LIST_RMODS_WITH_EPM}  ${list_rmod}[productName]
    IF  ${status_contain}
        Compare Real-time Measurements For RMODS With Embedded Power Meter  ${list_of_values}
    ELSE
        Compare Real-time Measurements For RMODS Without Embedded Power Meter  ${list_of_values}
    END

Compare Real-time Measurements For RMODS With Embedded Power Meter
    [Documentation]  Energy measurement should be greater than 0.
    [Arguments]  ${values}

    FOR  ${energy_measurement}  IN  @{values}
        ${converted_measurement}  Convert To String  ${energy_measurement}
        IF  ${energy_measurement} > 0
            Log  Energy measurement: ${energy_measurement} is ok  console=true
        ELSE
            Fail  Energy measurement: ${energy_measurement} is not ok
        END
    END


Compare Real-time Measurements For RMODS Without Embedded Power Meter
    [Documentation]  Energy measurement should be equal to 0.
    [Arguments]  ${values}

    FOR  ${energy_measurement}  IN  @{values}
        ${converted_measurement}  Convert To String  ${energy_measurement}
        IF  '${energy_measurement}' == '-'
            Log  Energy measurement: ${energy_measurement} is ok  console=true
        ELSE
            Fail  Energy measurement: ${energy_measurement} is not ok
        END
    END


Compare Real-time Measurements For SMODS
    [Documentation]  Energy measurement should be greater than 0.
    [Arguments]  ${values}

    FOR  ${energy_measurement}  IN  @{values}
        ${converted_measurement}  Convert To String  ${energy_measurement}
        IF  '${converted_measurement}'=='Not Supported'  CONTINUE
        IF  ${energy_measurement} > 0
            Log  Energy measurement: ${energy_measurement} is ok  console=true
        ELSE
            Fail  Energy measurement: ${energy_measurement} is not ok
        END
    END


Check M40003C Counter To Be Unavailable
    [Arguments]  ${3c_counter_id}

    Log  \nCheck if counter ${3c_counter_id} for all RMODs is not available...  console=true
    ${dist_name}  Set Variable If  '${ENB_BRANCH}'=='SBTS00' or '${ENB_BRANCH}'>='SBTS24R2'  BTS/MRBTS-${BTS_ID}  BTS/BTS/MRBTS-${BTS_ID}
    FOR  ${rmod}  IN  @{LIST_OF_RMODS}
        ${rmod_number}  Fetch From Right  ${rmod.dist_name}  RMOD_A-
        ${value_for_3c}  Run Keyword And Return Status
        ...  Get Counters Info  dist_name=${dist_name}/RMOD-${rmod_number}/SBTS_RFM_Energy_Monitoring/${3c_counter_id}  timeout=10
        IF  ${value_for_3c}
            Fail  Counter ${3c_counter_id} for RMOD-${rmod_number} is available![NOK]
        ELSE
            Log  Counter ${3c_counter_id} for RMOD-${rmod_number} is not available![OK]  console=true
        END
    END


Check M40004C Counter To Be Unavailable
    [Arguments]  ${4c_counter_id}

    Log  \nCheck if counter ${4c_counter_id} for all SMODs is not available...  console=true
    ${dist_name}  Set Variable If  '${ENB_BRANCH}'=='SBTS00' or '${ENB_BRANCH}'>='SBTS24R2'  SMOD  BTS/SMOD
    FOR  ${smod}  IN  @{LIST_OF_SMODS}
        ${smod_number}  Fetch From Right  ${smod}  SMOD_R-
        ${value_for_4c}  Run Keyword And Return Status
        ...  Get Counters Info  dist_name=${dist_name}/SMOD-${smod_number}/CABINET-1/SBTS_SM_Energy_Monitoring/${4c_counter_id}  timeout=10
        IF  ${value_for_4c}
            Fail  Counter ${4c_counter_id} for SMOD-${smod_number} is available![NOK]
        ELSE
            Log  Counter ${4c_counter_id} for SMOD-${smod_number} is not available![OK]  console=true
        END
    END


Change Parameters mtBtsEnergyMonitoring, mtSBTSRfmEnergyMonitoring, mtSBTSSmEnergyMonitoring
    [Documentation]
    ...  This KW is created to check what value have the given parameter:
    ...  mtBtsEnergyMonitoring, mtSBTSRfmEnergyMonitoring, mtSBTSSmEnergyMonitoring
    [Arguments]  ${parameter_name}  ${value}

    ${status}  Run Keyword And Return Status
    ...  Perform Parameter Recommissioning  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1
    ...  ${parameter_name}
    ...  update
    ...  ${value}
    ...  skip_parameter_relation_errors=true
    IF  ${status}
        Log  Parameter ${parameter_name} is set to ${value}![OK]  console=true
    ELSE
        Fail  Parameter ${parameter_name} is not set to ${value}![NOK]
    END


Check M40002C BTS Counter
    [Arguments]  ${counter_id}

    Log  \nGet ${counter_id} counter's values  console=true
    ${dist_name}  Set Variable If  '${ENB_BRANCH}'=='SBTS00' or '${ENB_BRANCH}'>='SBTS24R2'
    ...  BTS/MRBTS-${BTS_ID}/SBTS_Energy_Consumption/${counter_id}  BTS/BTS/MRBTS-${BTS_ID}/SBTS_Energy_Consumption/${counter_id}
    ${value_2_c}  Run Keyword And Ignore Error
    ...  Get Counters Info  dist_name=${dist_name}  timeout=120
    ${list_value_2_c}  Convert To List  ${value_2_c}
    ${2_c_object}  Get From List  ${list_value_2_c}  1
    ${dict}  Set Variable If  '${ENB_BRANCH}'=='SBTS00' or '${ENB_BRANCH}'>='SBTS24R2'
    ...  ${2_c_object}[BTS][MRBTS-${BTS_ID}][SBTS_Energy_Consumption][${counter_id}]
    ...  ${2_c_object}[BTS][BTS][MRBTS-${BTS_ID}][SBTS_Energy_Consumption][${counter_id}]
    ${counter_value}  Get Dictionary Values  ${dict}
    ${last_value}  Get From List  ${counter_value}  -1
    Log  Last value for counter ${counter_id}: ${last_value}  console=true


Check M40003C BTS Counter
    [Arguments]  ${counter_id}

    Log  \nGet ${counter_id} counter's values for all RMODs  console=true
    FOR  ${rmod}  IN  @{LIST_OF_RMODS}
        ${rmod_number}  Fetch From Right  ${rmod.dist_name}  RMOD_A-
        Log  Get ${counter_id} counter's values for RMOD-${rmod_number}  console=true
        ${dist_name}  Set Variable If  '${ENB_BRANCH}'=='SBTS00' or '${ENB_BRANCH}'>='SBTS24R2'
        ...  BTS/MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${rmod_number}/SBTS_RFM_Energy_Monitoring/${counter_id}
        ...  BTS/BTS/MRBTS-${BTS_ID}/RMOD-${rmod_number}/SBTS_RFM_Energy_Monitoring/${counter_id}
        ${value_3_c}  Run Keyword And Ignore Error
        ...  Get Counters Info  dist_name=${dist_name}  timeout=120
        ${list_value_3_c}  Convert To List  ${value_3_c}
        ${3_c_object}  Get From List  ${list_value_3_c}  1
        ${dict}  Set Variable If  '${ENB_BRANCH}'=='SBTS00' or '${ENB_BRANCH}'>='SBTS24R2'
        ...  ${3_c_object}[BTS][MRBTS-${BTS_ID}][EQM-1][APEQM-1][RMOD-${rmod_number}][SBTS_RFM_Energy_Monitoring][${counter_id}]
        ...  ${3_c_object}[BTS][BTS][MRBTS-${BTS_ID}][RMOD-${rmod_number}][SBTS_RFM_Energy_Monitoring][${counter_id}]
        ${counter_value}  Get Dictionary Values  ${dict}
        ${last_value}  Get From List  ${counter_value}  -1
        Log  Last value for counter ${counter_id}: ${last_value}  console=true
    END


Check M40004C BTS Counter
    [Arguments]  ${counter_id}

    Log  \nGet ${counter_id} counter's values for all SMODs  console=true
    FOR  ${smod}  IN  @{LIST_OF_SMODS}
        ${smod_number}  Fetch From Right  ${smod}  SMOD_R-
        Log  Get ${counter_id} counter's values for SMOD-${smod_number}  console=true
        ${dist_name}  Set Variable If  '${ENB_BRANCH}'=='SBTS00' or '${ENB_BRANCH}'>='SBTS24R2'
        ...  BTS/MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-${smod_number}/SBTS_SM_Energy_Monitoring/${counter_id}
        ...  BTS/SMOD/SMOD-${smod_number}/CABINET-1/SBTS_SM_Energy_Monitoring/${counter_id}
        ${value_4_c}  Run Keyword And Ignore Error
        ...  Get Counters Info  ${dist_name}  timeout=120
        ${list_value_4_c}  Convert To List  ${value_4_c}
        ${4_c_object}  Get From List  ${list_value_4_c}  1
        ${dict}  Set Variable If  '${ENB_BRANCH}'=='SBTS00' or '${ENB_BRANCH}'>='SBTS24R2'
        ...  ${4_c_object}[BTS][MRBTS-${BTS_ID}][EQM-1][APEQM-1][CABINET-1][SMOD-${smod_number}][SBTS_SM_Energy_Monitoring][${counter_id}]
        ...  ${4_c_object}[BTS][SMOD][SMOD-${smod_number}][CABINET-1][SBTS_SM_Energy_Monitoring][${counter_id}]
        ${counter_value}  Get Dictionary Values  ${dict}
        ${last_value}  Get From List  ${counter_value}  -1
        Log  Last value for counter ${counter_id}: ${last_value}  console=true
    END


TC Setup
    Common Test Setup  tc_name=WebEM__Enable_Disable_Energy_Consumption_Measurement


TC Teardown
    Run Keyword If Test Failed
    ...  Change ActPowerMeter Parameter To Specific Value And Parameters For Energy Consumption Measurement In 15min  true
    Common Test Teardown
