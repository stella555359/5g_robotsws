*** Settings ***
Documentation
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    Collections
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu
Library     ../../../resources/radio_operations/RadioOperations.py  WITH NAME  radio

Resource    ../../resources/Robot/vdu_oam_operations.robot
Resource    ../../resources/Robot/common_resources.robot
Resource    ../../../resources/Robot/scfc.robot
Resource    ../../../resources/common_kw.robot
Resource    ../../resources/variables.robot

*** Variables ***
${MEASUREMENT_INTERVAL}=  15

*** Keywords ***
TC__Cloud_PM_Radio_Module_Thermal_Counters_Monitoring
    [Arguments]  ${scfc_file_path}  ${rmod_sn_list}=@{EMPTY}  ${rmod_sn_count}=0
    ...  ${measurement_tolerance}=1  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-44215
    ...  Feature: CB008967-A - Radio module faults/alarms, configurable thresholds, counters
    ...  Feature CB008967 (Fan Speed and Ambient Temperature Monitoring feature)
    ...  enhances current faults and alarms, counters, and configuration
    ...  settings to supervise the thermal condition of:
    ...  radio modules, system modules, BTS cabinets (sub-racks).
    ...  CB008967 feature extends the existing thermal state monitoring options by introducing additional functions
    ...  (faults, alarms, counters, and configuration options).
    ...
    ...  "mtSBTSRMODTemperature" parameter defines the measurement interval for SBTS
    ...  RMOD Thermal Monitoring measurement in minutes.
    ...  Counters related to the feature (only CLOUDRAN):
    ...  M40008C1: SBTS_RM_MAX_TEMPERATURE - provides the maximum temperature of the radio unit expressed in degrees Celsius.
    ...  The counter is updated over the measurement period.
    ...  The value of the counter is the maximum value of all temperature data reported by the temperature sensor(s).
    ...
    ...  Tester should provide a list of only NAKHA radio modules in the test case.
    ...  Test case checks temperature measurement every minute and compares them with the counter value
    ...  collected in time interval that is defined in the test case variable ${MEASUREMENT_INTERVAL}.
    ...  Finally, test case disables the counter collection and checks if the counters have actually not been collected.
    ...
    ...  Step 1: Initial Check Thermal Counters Monitoring
    ...  a) vDU operation state is OnAir (operational_state=OnAir)
    ...  b) All cells are OnAir
    ...     Cells expected states: operational_state = enabled
    ...                            administrative_state = unlocked
    ...                            availability_status = on_line
    ...  Step 2: Activate Measurement Interval For Radio Module Temperature Monitoring
    ...  a) Set parameter "mtSBTSRMODTemperature" to "15min"
    ...  Step 3: Get Temperature From Radio Modules
    ...  Step 4: Get And Verify Counters
    ...  a) Counter M40008C1 is collected and checked
    ...  Step 5: Verify Radio Module Log Temperature Measurement And Counters
    ...  a) The default difference in results between radio module log measurement
    ...     and counter is defined as 1C and can be defined by the tester.
    ...  Step 6: Deactivate Measurement Interval For Radio Module Temperature Monitoring
    ...  a) Set parameter  mtSBTSRMODTemperature to "disabled"
    ...  Step 7: Verify Counters When Temperature Monitoring Disabled
    ...  a) Counters values are not collected.
    ...  Step 8: Postconditions Thermal Counters Monitoring
    ...  a) All cells are OnAir
    ...     Cells expected states: operational_state = enabled
    ...                            administrative_state = unlocked
    ...                            availability_status = on_line
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_sn_list           |      | List of serial number of the tested radio modules.                         |
    ...  |                        |  No  | @{EMPTY} value means that no list was given,                               |
    ...  |                        |      | so all radio modules defined in the SCFC file will be used.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_sn_count          |  No  | Number of randomly selected radio modules serial numbers based on          |
    ...  |                        |      | the list obtained from the SCFC file.                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | measurement_tolerance  |  No  | The difference between radio module logs measurements and counters.        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Set Test Variable  ${scfc_file_path}
    Set Test Variable  ${rmod_sn_list}
    Set Test Variable  ${rmod_sn_count}
    Set Test Variable  ${measurement_tolerance}
    Set Test Variable  ${log_to_console}
    Log  ${start_prefix_green}Test Case: Radio_Module_Thermal_Counters_Monitoring  console=${log_to_console}
    Step 1: Initial Check Thermal Counters Monitoring
    Step 2: Activate Measurement Interval For Radio Module Temperature Monitoring
    Step 3: Get Temperature From Radio Modules
    Step 4: Get And Verify Counters
    Step 5: Verify Radio Module Log Temperature Measurement And Counters
    Step 6: Deactivate Measurement Interval For Radio Module Temperature Monitoring
    Step 7: Verify Counters When Temperature Monitoring Disabled
    Step 8: Postconditions Thermal Counters Monitoring
    Log  ${done_prefix_green}Test Case: Radio_Module_Thermal_Counters_Monitoring  console=${log_to_console}
    [Teardown]  Radio Module Thermal Counters Monitoring Teardown  tc_status=${KEYWORD_STATUS}

Step 1: Initial Check Thermal Counters Monitoring
    Log  ${dots_prefix_green}Step 1: Initial check thermal counters monitoring  console=${log_to_console}
    vDU Rest Login
    ${rmod_serial_number_list}=  Get Radio Modules Serial Numbers List  scfc_file_path=${scfc_file_path}
    ...  rmod_sn_list=${rmod_sn_list}  rmod_sn_count=${rmod_sn_count}
    Set Test Variable  ${rmod_serial_number_list}
    ${cells_count}=  vDU SCFC Get NRCELL Count  scfc_file_path=${scfc_file_path}
    Set Test Variable  ${cells_count}
    vDU Wait For Expected Operational State  vdu_state_value=onAir
    ${current_vdu_state}=  vDU Get Current State  vdu_state=operational_state
    Log  ${info_prefix}vDU operational state is OnAir  console=${log_to_console}
    Wait Until All Cells Are OnAir  cells_count=${cells_count}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
    ${mrbts_id}=  vDU Get MRBTS Id  vdu_login=False
    Set Test Variable  ${mrbts_id}
    ${rmod_dn_dict}=  Create Dictionary
    Set Test Variable  ${rmod_dn_dict}
    ${prev_counters_time_dict}=  Create Dictionary
    Set Test Variable  ${prev_counters_time_dict}
    ${rmod_log_temperature_dict}=  Create Dictionary
    Set Test Variable  ${rmod_log_temperature_dict}
    FOR  ${rmod_sn}  IN  @{rmod_serial_number_list}
      ${rmod_dn}  ${rmod_runtime_dn}=  vDU RMOD Get Dist Names Based On Serial Number  rmod_sn=${rmod_sn}
      Set To Dictionary  ${rmod_dn_dict}  ${rmod_sn}=${rmod_dn}
      ${last_counter_time}=  Get Counter Start Time  counter_id=M40008C1  dist_name=${rmod_dn}
      Set To Dictionary  ${prev_counters_time_dict}  ${rmod_sn}=${last_counter_time}
      Set To Dictionary  ${rmod_log_temperature_dict}  ${rmod_sn}=@{EMPTY}
    END
    Log  ${ok_prefix_green}Step 1: Initial check thermal counters monitoring  console=${log_to_console}

Step 2: Activate Measurement Interval For Radio Module Temperature Monitoring
    Log  ${dots_prefix_green}Step 2: Activate measurement interval for radio module temperature monitoring  console=${log_to_console}
    Log  ${info_prefix}Measurement interval for radio module temperature monitoring setting  console=${log_to_console}
    Log  ${below_info_prefix}mtSBTSRMODTemperature=${MEASUREMENT_INTERVAL}min  console=${log_to_console}
    ${mtsbtsrmodtemperature_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/MNL-1/MNLENT-1/PMMNL-1
    ${updated_params_dict}=  Create Dictionary  mtSBTSRMODTemperature=15min
    ${updated_params_oper_dict}=  Create Dictionary  update=${updated_params_dict}
    ${mtsbtsrmodtemperature_json}=  Create Single Dist Name Json String  mo_dn=${mtsbtsrmodtemperature_mo_dn}
    ...  updated_params_dict=${updated_params_oper_dict}  distname_operation=update
    vdu.Perform Delta Recommissioning  delta_file=${mtsbtsrmodtemperature_json[0]}
    ...  wait_for_completion=True  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    Log  ${info_prefix}Measurement interval for radio module temperature monitoring has been activated  console=${log_to_console}
    Log  ${ok_prefix_green}Step 2: Activate measurement interval for radio module temperature monitoring  console=${log_to_console}

Step 3: Get Temperature From Radio Modules
    Log  ${dots_prefix_green}Step 3: Get temperature from radio modules  console=${log_to_console}
    ${time_to_sleep}  ${time_to_verdict}=  Time To Sleep  interval=${MEASUREMENT_INTERVAL}  additional_offset=${-2}
    Log  ${info_prefix}The measurements and counters will start being collected at ${time_to_verdict}  console=${log_to_console}
    Log  ${info_prefix}Wait ${time_to_sleep} minutes for measurements and counters to start collecting ...  console=${log_to_console}
    Sleep  ${time_to_sleep}min
    ${vdu_k8s_connection_params}=  Get vDU K8s Master Node Connection Parameters From Init File
    ${ip_addr}=  Set Variable  ${vdu_k8s_connection_params['ip_addr']}
    Log  ${info_prefix}Temperature from radio modules logs is read. Please wait a ${MEASUREMENT_INTERVAL} minutes ...
    ...  console=${log_to_console}
    ${time_period}=  Convert To Integer  item=${MEASUREMENT_INTERVAL}
    FOR  ${minute}  IN RANGE  1  ${time_period+1}
      FOR  ${rmod_sn}  IN  @{rmod_serial_number_list}
        ${all_sensors_temperature_dict}  radio.Get Sensors Temperature From RF Logs
        ...  ru_serial_number=${rmod_sn}  cloud_server_ip=${ip_addr}
        ${rmod_log_temperature}=  Get From Dictionary  dictionary=${all_sensors_temperature_dict}  key=MODULE
        ${rmod_log_temperature_list}=  Get From Dictionary  dictionary=${rmod_log_temperature_dict}  key=${rmod_sn}
        Append To List  ${rmod_log_temperature_list}  ${rmod_log_temperature}
        Set To Dictionary  ${rmod_log_temperature_dict}  ${rmod_sn}=${rmod_log_temperature_list}
      END
      Sleep  60s
    END
    Log  ${ok_prefix_green}Step 3: Get temperature from radio modules  console=${log_to_console}

Step 4: Get And Verify Counters
    Log  ${dots_prefix_green}Step 4: Get and verify counters  console=${log_to_console}
    Log  ${info_prefix}Counters from radio modules are collecting ...
    ${counters_temperature_dict}=  Create Dictionary
    Set Test Variable  ${counters_temperature_dict}
    ${counters_start_time_dict}=  Create Dictionary
    Set Test Variable  ${counters_start_time_dict}
    FOR  ${rmod_sn}  IN  @{rmod_serial_number_list}
      ${rmod_dn}=  Get From Dictionary  dictionary=${rmod_dn_dict}  key=${rmod_sn}
      ${counter_temperature}  ${counter_start_time}=  Get Counter And Check If Collected  counter_id=M40008C1
      ...  dist_name=${rmod_dn}  prev_counter_time=${prev_counters_time_dict['${rmod_sn}']}
      Set To Dictionary  ${counters_temperature_dict}  ${rmod_sn}=${counter_temperature}
      Set To Dictionary  ${counters_start_time_dict}  ${rmod_sn}=${counter_start_time}
    END
    Log  ${info_prefix}All temperature counters has been verified
    Log  ${ok_prefix_green}Step 4: Get and verify counters  console=${log_to_console}

Step 5: Verify Radio Module Log Temperature Measurement And Counters
    Log  ${dots_prefix_green}Step 5: Verify radio module log temperature measurement and counters  console=${log_to_console}
    Log  ${info_prefix}Maximum radio modules temperature measurements and counter are verifying ...
      ...  console=${log_to_console}
    FOR  ${rmod_sn}  IN  @{rmod_serial_number_list}
      ${rmod_dn}=  Get From Dictionary  dictionary=${rmod_dn_dict}  key=${rmod_sn}
      ${counter_max_temperature}=  Get From Dictionary  dictionary=${counters_temperature_dict}  key=${rmod_sn}
      Log  ${below_info_prefix}Maximum temperature counter for radio module ${rmod_sn}: ${counter_max_temperature} \u00b0C
      ...  console=${log_to_console}
      ${rmod_log_temperature_list}=  Get From Dictionary  dictionary=${rmod_log_temperature_dict}  key=${rmod_sn}
      ${rmod_log_max_temperature}=  Evaluate  expression=max(${rmod_log_temperature_list})
      Log  ${below_info_prefix}Maximum temperature read from radio module (sn: ${rmod_sn}) logs: ${rmod_log_max_temperature} \u00b0C
      ...  console=${log_to_console}
      Verify Radio Module Logs Measurement And Counter Value  rmod_log_temperature=${rmod_log_max_temperature}
      ...  counter_temperature=${counter_max_temperature}  rmod_sn=${rmod_sn}
    END
    Log  ${ok_prefix_green}Step 5: Verify radio module log temperature measurement and counters  console=${log_to_console}

Step 6: Deactivate Measurement Interval For Radio Module Temperature Monitoring
    Log  ${dots_prefix_green}Step 6: Deactivate measurement interval for radio module temperature monitoring  console=${log_to_console}
    Log  ${info_prefix}Deactivate measurement interval for radio module temperature monitoring setting ...  console=${log_to_console}
    ${mtsbtsrmodtemperature_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/MNL-1/MNLENT-1/PMMNL-1
    ${updated_params_dict}=  Create Dictionary  mtSBTSRMODTemperature=disabled
    ${updated_params_oper_dict}=  Create Dictionary  update=${updated_params_dict}
    ${mtsbtsrmodtemperature_json}=  Create Single Dist Name Json String  mo_dn=${mtsbtsrmodtemperature_mo_dn}
    ...  updated_params_dict=${updated_params_oper_dict}  distname_operation=update
    vdu.Perform Delta Recommissioning  delta_file=${mtsbtsrmodtemperature_json[0]}
    ...  wait_for_completion=True  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    Log  ${info_prefix}Measurement interval for radio module temperature monitoring has been deactivated  console=${log_to_console}
    Log  ${ok_prefix_green}Step 6: Deactivate measurement interval for radio module temperature monitoring  console=${log_to_console}

Step 7: Verify Counters When Temperature Monitoring Disabled
    Log  ${dots_prefix_green}Step 7: Verify counters when temperature monitoring disabled  console=${log_to_console}
    ${time_to_sleep}  ${time_to_verdict}=  Time To Sleep  interval=${MEASUREMENT_INTERVAL}
    Log  ${info_prefix}The counters will not be collected at ${time_to_verdict}  console=${log_to_console}
    Log  ${info_prefix}Wait ${time_to_sleep} minutes for counters to be collected ...  console=${log_to_console}
    Sleep  ${time_to_sleep} min
    Log  ${info_prefix}Verification of counter deactivation for radio modules ...  console=${log_to_console}
    FOR  ${rmod_sn}  IN  @{rmod_serial_number_list}
      ${rmod_dn}=  Get From Dictionary  dictionary=${rmod_dn_dict}  key=${rmod_sn}
      ${counter_prev_start_time}=  Get From Dictionary  dictionary=${counters_start_time_dict}  key=${rmod_sn}
      Log  ${below_info_prefix}Verification of counter deactivation for radio module (sn: ${rmod_sn})  console=${log_to_console}
      Counter Should Be Deactivated  counter_id=M40008C1  dist_name=${rmod_dn}  prev_counter_time=${counter_prev_start_time}
    END
    Log  ${info_prefix}All counters have been deactivated  console=${log_to_console}
    Log  ${ok_prefix_green}Step 7: Verify counters when temperature monitoring disabled  console=${log_to_console}

Step 8: Postconditions Thermal Counters Monitoring
    Log  ${dots_prefix_green}Step 8: Postconditions thermal counters monitoring  console=${log_to_console}
    Wait Until All Cells Are OnAir  cells_count=${cells_count}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 8: Postconditions thermal counters monitoring  console=${log_to_console}

#INTERNAL TEST CASE KEYWORDS
Verify Radio Module Logs Measurement And Counter Value
    [Arguments]  ${rmod_log_temperature}  ${counter_temperature}  ${rmod_sn}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword checks whether the value of the radio module logs measurement and counter are correct.
    ...  The difference between radio module log measurement and counter is defined by user.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | rmod_log_temperature   | Yes  | Temperature measurement from radio module logs during                      |
    ...  |                        |      | the counter time interval.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | counter_temperature    | Yes  | Temperature counter value for a specific time interval.                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_sn                | Yes  | Serial number of radio module.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${diff_result}=  Evaluate  expression=abs(${rmod_log_temperature}-${counter_temperature})<=${measurement_tolerance}
    Run Keyword If  ${diff_result}
    ...  Log  ${below_info_prefix}Counter M40008C1 for radio module (sn: ${rmod_sn}) and max measurement of the temperature is correct
    ...  console=${log_to_console}
    ...  ELSE
    ...  Run Keyword And Continue On Failure
    ...  Fail  msg=Counter M40008C1 for radio module (sn: ${rmod_sn}) and max measurement of the temperature is not correct !

Radio Module Thermal Counters Monitoring Teardown
    [Arguments]  ${tc_status}
    [Documentation]
    ...  Description:
    ...  Keyword performs tasks that clean up or restore initial values after the test is performed (PASS or FAIL).
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | tc_status              | Yes  | The status of the current test case (keyword), either PASS or FAIL.        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Run Keyword If  '${tc_status}'=='PASS'  Run Keyword And Ignore Error  vDU Rest Logout
    Return From Keyword If  '${tc_status}'=='PASS'
    ${mtsbtsrmodtemperature_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/MNL-1/MNLENT-1/PMMNL-1
    ${updated_params_dict}=  Create Dictionary  mtSBTSRMODTemperature=disabled
    ${updated_params_oper_dict}=  Create Dictionary  update=${updated_params_dict}
    ${mtsbtsrmodtemperature_json}=  Create Single Dist Name Json String  mo_dn=${mtsbtsrmodtemperature_mo_dn}
    ...  updated_params_dict=${updated_params_oper_dict}  distname_operation=update
    vdu.Perform Delta Recommissioning  delta_file=${mtsbtsrmodtemperature_json[0]}
    ...  wait_for_completion=True  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    Run Keyword And Ignore Error  vDU Rest Logout
