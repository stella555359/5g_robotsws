*** Settings ***
Documentation
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    Collections
Library    DateTime
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu

Resource    ../../resources/Robot/vdu_oam_operations.robot
Resource    ../../resources/Robot/common_resources.robot
Resource    ../../../resources/Robot/scfc.robot
Resource    ../../../resources/common_kw.robot
Resource    ../../resources/variables.robot

*** Variables ***
@{MEASUREMENT_INTERVAL_LIST}=  5  15
@{FAN_SPEED_COUNTERS_LIST}=  M40030C0  M40030C1  M40030C2

*** Keywords ***
TC__Cloud_PM_Radio_Module_Fan_Speed_Counters_Monitoring
    [Arguments]  ${scfc_file_path}  ${rmod_sn_list}=@{EMPTY}  ${measurement_tolerance}=3  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-44215
    ...  Feature: CB008967-I - Radio module fan-speed monitoring
    ...  Feature CB008967 (Fan Speed and Ambient Temperature Monitoring feature)
    ...  enhances current faults and alarms, counters, and configuration
    ...  settings to supervise the thermal condition of:
    ...  radio modules, system modules, BTS cabinets (sub-racks).
    ...  CB008967 feature extends the existing thermal state monitoring options by introducing additional functions
    ...  (faults, alarms, counters, and configuration options).
    ...
    ...  "mtSBTSRMODFan" parameter enables the collection of fan speed counters for radio modules within
    ...  a specified measurement time interval. The counters are incremented using the minimum, maximum,
    ...  or average value of fan speed expressed as a percentage of the maximum speed.
    ...  Counters related to the feature:
    ...  M40030C0: SBTS_RMOD_MIN_FANSPEED - the minimum fan speed of the radio unit expressed in the percentage
    ...  of max speed reported during a configured measurement period
    ...  M40030C1: SBTS_RMOD_MAX_FANSPEED - the maximum fan speed of the radio unit in the percentage of max speed
    ...  M40030C2: SBTS_RMOD_AVG_FANSPEED - the average fan speed of the radio unit in the percentage of max speed
    ...
    ...  Test case checks the real measurements for the fans every minute and compares them with the counter values
    ...  collected in different time intervals that are defined in the list.
    ...  Tester should provide a list of radio modules that have fans.
    ...  Finally, test case disables the counter collection and checks if the counters have actually not been collected.
    ...
    ...  Step 1: Initial Check Fan Speed Counters Monitoring
    ...  a) vDU operation state is OnAir (operational_state=OnAir)
    ...  b) All cells are OnAir
    ...     Cells expected states: operational_state = enabled
    ...                            administrative_state = unlocked
    ...                            availability_status = on_line
    ...  Step 2: Activate Initial Parameters
    ...  a) Set parameter "actPowerMeter" to "true"
    ...  Steps 3 and 4 are performed in a loop for "mtSBTSRMODFan" parameter values "5min" and "15min"
    ...  Step 3: Activate Measurement Interval For Radio Module Fan Monitoring
    ...  Loop1:
    ...  a) Set parameter  mtSBTSRMODFan to "5min"
    ...  Loop2:
    ...  a) Set parameter  mtSBTSRMODFan to "15min"
    ...  Step 4: Get And Verify Measurements And Counters
    ...  Loop 1 and 2:
    ...  a) The default difference in results between real measurements
    ...     and counters is defined as 3% and can be defined by the tester.
    ...  Step 5: Deactivate Measurement Interval
    ...  a) Set parameter  mtSBTSRMODFan to "disabled"
    ...  Step 6: Verify Counters When Fan Monitoring Disabled
    ...  a) Counters values are not collected.
    ...  Step 7: Postconditions Fan Speed Counters Monitoring
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
    ...  | rmod_sn_list           | Yes  | Serial number list of the tested radio modules with fans.                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | measurement_tolerance  |  No  | The difference between real measurements and counters.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Set Test Variable  ${scfc_file_path}
    Set Test Variable  ${rmod_sn_list}
    Set Test Variable  ${measurement_tolerance}
    Set Test Variable  ${log_to_console}
    Log  ${start_prefix_green}Test Case: Radio_Module_Fan_Speed_Counters_Monitoring  console=${log_to_console}
    Step 1: Initial Check Fan Speed Counters Monitoring
    Step 2: Activate Initial Parameters
    FOR  ${measurement_interval}  IN  @{MEASUREMENT_INTERVAL_LIST}
      Set Test Variable  ${measurement_interval}
      Step 3: Activate Measurement Interval For Radio Module Fan Monitoring
      Step 4: Get And Verify Measurements And Counters
    END
    Step 5: Deactivate Measurement Interval For Radio Module Fan Monitoring
    Step 6: Verify Counters When Fan Monitoring Disabled
    Step 7: Postconditions Fan Speed Counters Monitoring
    Log  ${done_prefix_green}Test Case: Radio_Module_Fan_Speed_Counters_Monitoring  console=${log_to_console}
    [Teardown]  Radio Module Fan Speed Counters Monitoring Teardown  tc_status=${KEYWORD_STATUS}

Step 1: Initial Check Fan Speed Counters Monitoring
    Log  ${dots_prefix_green}Step 1: Initial check fan speed counters monitoring  console=${log_to_console}
    vDU Rest Login
    ${rmod_serial_number_list}=  Get Radio Modules Serial Numbers List
    ...  scfc_file_path=${scfc_file_path}  rmod_sn_list=${rmod_sn_list}
    Set Test Variable  ${rmod_serial_number_list}
    ${cells_count}=  vDU SCFC Get NRCELL Count  scfc_file_path=${scfc_file_path}
    Set Test Variable  ${cells_count}
    vDU Wait For Expected Operational State  vdu_state_value=onAir
    ${current_vdu_state}=  vDU Get Current State  vdu_state=operational_state
    Log  ${info_prefix}vDU operational state is OnAir  console=${log_to_console}
    Wait Until All Cells Are OnAir  cells_count=${cells_count}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
    ${affected_cells_id_list}=  Create List
    Set Test Variable  ${affected_cells_id_list}
    FOR  ${rmod_sn}  IN  @{rmod_sn_list}
      ${cells_id_list}=  RMOD Get Cell Id List  rmod_sn=${rmod_sn}
      Append To List  ${affected_cells_id_list}  @{cells_id_list}
    END
    ${affected_cells_dist_name_list}=  vDU Cells Get Dist Names Based On Ids  cell_id_list=${affected_cells_id_list}
    Set Test Variable  ${affected_cells_dist_name_list}
    ${mrbts_id}=  vDU Get MRBTS Id  vdu_login=False
    Set Test Variable  ${mrbts_id}
    Log  ${ok_prefix_green}Step 1: Initial check fan speed counters monitoring  console=${log_to_console}

Step 2: Activate Initial Parameters
    Log  ${dots_prefix_green}Step 2: Activate initial parameters  console=${log_to_console}
    Log  ${info_prefix}Parameter settings on radio module:  console=${log_to_console}
    Log  ${below_info_prefix}actPowerMeter=true  console=${log_to_console}
    ${actpowermeter_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ${updated_params_dict}=  Create Dictionary  actPowerMeter=true
    ${updated_params_oper_dict}=  Create Dictionary  update=${updated_params_dict}
    ${actpowermeter_mo_dn_json}=  Create Single Dist Name Json String  mo_dn=${actpowermeter_mo_dn}
    ...  updated_params_dict=${updated_params_oper_dict}  distname_operation=update
    vdu.Perform Delta Recommissioning  delta_file=${actpowermeter_mo_dn_json[0]}
    ...  wait_for_completion=True  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    Log  ${ok_prefix_green}Step 2: Activate initial parameters  console=${log_to_console}

Step 3: Activate Measurement Interval For Radio Module Fan Monitoring
    Log  ${dots_prefix_green}Step 3: Activate measurement interval for radio module fan monitoring  console=${log_to_console}
    Log  ${info_prefix}Measurement interval for radio module fan monitoring setting  console=${log_to_console}
    Log  ${below_info_prefix}mtSBTSRMODFan=${measurement_interval}min  console=${log_to_console}
    ${mtsbtsrmodfan_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/MNL-1/MNLENT-1/PMMNL-1
    ${updated_params_dict}=  Create Dictionary  mtSBTSRMODFan=${measurement_interval}min
    ${updated_params_oper_dict}=  Create Dictionary  update=${updated_params_dict}
    ${mtsbtsrmodfan_json}=  Create Single Dist Name Json String  mo_dn=${mtsbtsrmodfan_mo_dn}
    ...  updated_params_dict=${updated_params_oper_dict}  distname_operation=update
    vdu.Perform Delta Recommissioning  delta_file=${mtsbtsrmodfan_json[0]}
    ...  wait_for_completion=True  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    Log  ${ok_prefix_green}Step 3: Activate measurement interval for radio module fan monitoring  console=${log_to_console}

Step 4: Get And Verify Measurements And Counters
    Log  ${dots_prefix_green}Step 4: Get and verify measurements and counters  console=${log_to_console}
    ${measurement_interval}=  Convert To Integer  ${measurement_interval}
    ${slice_start_index}=  Evaluate  expression=-2-${measurement_interval}
    ${time_to_sleep}  ${time_to_verdict}=  Time To Sleep  interval=${measurement_interval}  additional_offset=${measurement_interval}
    Log  ${info_prefix}The measurements and counters will be collected at ${time_to_verdict}  console=${log_to_console}
    Log  ${info_prefix}Wait ${time_to_sleep} minutes for measurements and counters to be collected ...  console=${log_to_console}
    Sleep  ${time_to_sleep} min
    ${real_time_measurements}=  vdu.Get Real Time Measurements
    ${real_time_measurements}=  Json.Loads  ${real_time_measurements}
    FOR  ${rmod_sn}  IN  @{rmod_serial_number_list}
      Log  ${info_prefix}Measurements and counters for radio module (sn: ${rmod_sn})  console=${log_to_console}
      ${rmod_dn}  ${rmod_runtime_dn}=  vDU RMOD Get Dist Names Based On Serial Number  rmod_sn=${rmod_sn}
      ${fan_runtime_distname_list}=  vDU RMOD Get Fans Realtime Dist Names  rmod_runtime_dn=${rmod_runtime_dn}
      ${fan_distname_list}=  Create List
      FOR  ${fan_runtime_distname}  IN  @{fan_runtime_distname_list}
        ${fan_number}=  Fetch From Right  string=${fan_runtime_distname}  marker=-
        ${fan_distname}=  Set Variable  ${rmod_dn}/FAN-${fan_number}
        Append To List  ${fan_distname_list}  ${fan_distname}
      END
      Set Test Variable  ${fan_distname_list}
      FOR  ${fan_runtime_distname}  ${fan_distname}  IN ZIP  ${fan_runtime_distname_list}  ${fan_distname_list}
        ${fan_number}=  Fetch From Right  string=${fan_distname}  marker=/
        ${fan_measurements}=  Get From Dictionary  dictionary=${real_time_measurements}  key=${fan_runtime_distname}
        ${fan_last_measurements}=  Get Slice From List  ${fan_measurements}  ${slice_start_index}  -2
        Log  ${info_prefix}Last time measurements for ${fan_number}: ${fan_last_measurements[-1]['startTime']}  console=${log_to_console}
        ${fan_speeds_list}=  Get Real Time Fan Measurements  fan_measurements=${fan_last_measurements}
        ...  number_of_measurements=${measurement_interval}
        ${fan_counters_list}  ${fan_counters_start_time}=  Get And Check Fan Counters  fan_distname=${fan_distname}
        Log  ${info_prefix}Counter time for ${fan_number}: ${fan_counters_start_time}  console=${log_to_console}
        Log  ${info_prefix}Verification measurements and counters for ${fan_number}  console=${log_to_console}
        Verify Real Time And Counters Values  fan_speeds=${fan_speeds_list}  fan_counters=${fan_counters_list}
        ...  fan_distname=${fan_distname}
      END
    END
    Set Test Variable  ${fan_counters_start_time}
    Log  ${ok_prefix_green}Step 4: Get and verify measurements and counters  console=${log_to_console}

Step 5: Deactivate Measurement Interval For Radio Module Fan Monitoring
    Log  ${dots_prefix_green}Step 5: Deactivate measurement interval for radio module fan monitoring  console=${log_to_console}
    Log  ${info_prefix}Measurement interval for radio module fan monitoring setting  console=${log_to_console}
    Log  ${below_info_prefix}mtSBTSRMODFan=disabled  console=${log_to_console}
    ${mtsbtsrmodfan_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/MNL-1/MNLENT-1/PMMNL-1
    ${updated_params_dict}=  Create Dictionary  mtSBTSRMODFan=disabled
    ${updated_params_oper_dict}=  Create Dictionary  update=${updated_params_dict}
    ${mtsbtsrmodfan_json}=  Create Single Dist Name Json String  mo_dn=${mtsbtsrmodfan_mo_dn}
    ...  updated_params_dict=${updated_params_oper_dict}  distname_operation=update
    vdu.Perform Delta Recommissioning  delta_file=${mtsbtsrmodfan_json[0]}
    ...  wait_for_completion=True  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    Log  ${ok_prefix_green}Step 5: Deactivate measurement interval for radio module fan monitoring  console=${log_to_console}

Step 6: Verify Counters When Fan Monitoring Disabled
    Log  ${dots_prefix_green}Step 6: Verify counters when fan monitoring disabled  console=${log_to_console}
    ${time_to_sleep}  ${time_to_verdict}=  Time To Sleep  interval=${measurement_interval}  additional_offset=${2}
    Log  ${info_prefix}The counters will not be collected at ${time_to_verdict}  console=${log_to_console}
    Log  ${info_prefix}Wait ${time_to_sleep} minutes for counters to be collected ...  console=${log_to_console}
    Sleep  ${time_to_sleep} min
    FOR  ${rmod_sn}  IN  @{rmod_serial_number_list}
      Log  ${info_prefix}Counters for radio module (sn: ${rmod_sn})  console=${log_to_console}
      FOR  ${fan_distname}  IN  @{fan_distname_list}
        ${fan_number}=  Fetch From Right  string=${fan_distname}  marker=/
        Log  ${info_prefix}Verification counters for ${fan_number}  console=${log_to_console}
        Counters Should Be Deactivated  fan_distname=${fan_distname}  fan_counters_start_time=${fan_counters_start_time}
      END
      Log  ${info_prefix}All counters have been deactivated  console=${log_to_console}
    END
    Log  ${ok_prefix_green}Step 6: Verify counters when fan monitoring disabled  console=${log_to_console}

Step 7: Postconditions Fan Speed Counters Monitoring
    Log  ${dots_prefix_green}Step 7: Postconditions fan speed counters monitoring  console=${log_to_console}
    Wait Until All Cells Are OnAir  cells_count=${cells_count}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 7: Postconditions fan speed counters monitoring  console=${log_to_console}

#INTERNAL TEST CASE KEYWORDS
Get Real Time Fan Measurements
    [Arguments]  ${fan_measurements}  ${number_of_measurements}
    [Documentation]
    ...  Description:
    ...  Keyword returns the minimum, maximum, and average values of the number
    ...  of actual measurements collected in a time interval for counters.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | fan_measurements       | Yes  | Number of actual measurements collected in a time interval for counters.   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | number_of_measurements | Yes  | Number of measurements.                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${fan_speeds_list}=  Create List
    ${sum_speed}=  Evaluate  expression=0
    FOR  ${fan_measurement}  IN  @{fan_measurements}
      ${fan_speed}=  Convert To Integer  item=${fan_measurement['fanSpeed']}
      ${sum_speed}=  Evaluate  expression=${sum_speed}+${fan_speed}
      Append To List  ${fan_speeds_list}  ${fan_speed}
    END
    ${fan_min_speed}=  Evaluate  expression=min(${fan_speeds_list})
    ${fan_max_speed}=  Evaluate  expression=max(${fan_speeds_list})
    ${fan_avg_speed}=  Evaluate  expression=int(${sum_speed}/${number_of_measurements})
    ${fan_speeds}=  Create List  ${fan_min_speed}  ${fan_max_speed}  ${fan_avg_speed}
    [Return]  ${fan_speeds}

Get And Check Fan Counters
    [Arguments]  ${fan_distname}
    [Documentation]
    ...  Description:
    ...  Keyword returns the start time and the value of counters M40030C0, M40030C1 and M40030C2
    ...  for the fan configuration Distinguished Name (DN).
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | fan_distname           | Yes  | Fan configuration Distinguished Name (DN).                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${M40030C0_counters}=  vdu.Get Counter Values  counter_id=M40030C0  dimension_dn=${fan_distname}
    ${M40030C0_time}=  Set Variable  ${M40030C0_counters[-1]['start_time']}
    ${M40030C0_counter}=  Set Variable  ${M40030C0_counters[-1]['value']}
    ${M40030C1_counters}=  vdu.Get Counter Values  counter_id=M40030C1  dimension_dn=${fan_distname}
    ${M40030C1_time}=  Set Variable  ${M40030C1_counters[-1]['start_time']}
    ${M40030C1_counter}=  Set Variable  ${M40030C1_counters[-1]['value']}
    Should Be Equal  first=${M40030C0_time}  second=${M40030C1_time}
    ${M40030C2_counters}=  vdu.Get Counter Values  counter_id=M40030C2  dimension_dn=${fan_distname}
    ${M40030C2_time}=  Set Variable  ${M40030C2_counters[-1]['start_time']}
    ${M40030C2_counter}=  Set Variable  ${M40030C2_counters[-1]['value']}
    Should Be Equal  first=${M40030C0_time}  second=${M40030C2_time}
    ${fan_counters}=  Create List  ${M40030C0_counter}  ${M40030C1_counter}  ${M40030C2_counter}
    ${fan_counters_start_time}=  Set Variable  ${M40030C0_time}
    [Return]  ${fan_counters}  ${fan_counters_start_time}

Verify Real Time And Counters Values
    [Arguments]  ${fan_speeds}  ${fan_counters}  ${fan_distname}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword checks whether the counters have the correct value and whether the values
    ...  of the real measurements and counters match.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | fan_speeds             | Yes  | List of real measurements from fans collected                              |
    ...  |                        |      | during the counter time interval.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | fan_counters           | Yes  | List of counter values for a specific time interval.                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | fan_distname           | Yes  | Fan configuration Distinguished Name (DN).                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${index}=  Evaluate  0
    FOR  ${fun_speed_counter_id}  IN  @{FAN_SPEED_COUNTERS_LIST}
      ${diff_result}=  Evaluate  expression=abs(${fan_speeds[${index}]}-${fan_counters[${index}]})<=${measurement_tolerance}
      Run Keyword If  ${diff_result}
      ...  Log  ${below_info_prefix}Counter ${fun_speed_counter_id} for ${fan_distname} is correct  console=${log_to_console}
      ...  ELSE
      ...  Run Keyword And Continue On Failure
      ...  Fail  msg=Counter ${fun_speed_counter_id} for ${fan_distname} and min measurement of the fan is not correct !
      ${index}=  Evaluate  expression=${index}+1
    END

Counters Should Be Deactivated
    [Arguments]  ${fan_distname}  ${fan_counters_start_time}
    [Documentation]
    ...  Description:
    ...  Keyword checks whether counters collection is stopped after it has been disabled.
    ...
    ...  Arguments:
    ...  +=========================+======+===========================================================================+
    ...  | Argument                | Man. | Description                                                               |
    ...  +=========================+======+===========================================================================+
    ...  | fan_distname            | Yes  | Fan configuration Distinguished Name (DN).                                |
    ...  +-------------------------+------+---------------------------------------------------------------------------+
    ...  | fan_counters_start_time | Yes  | Last time the counters were collected.                                    |
    ...  +-------------------------+------+---------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    FOR  ${fun_speed_counter_id}  IN  @{FAN_SPEED_COUNTERS_LIST}
      Counter Should Be Deactivated  counter_id=${fun_speed_counter_id}
      ...  dist_name=${fan_distname}  prev_counter_time=${fan_counters_start_time}
    END

Radio Module Fan Speed Counters Monitoring Teardown
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
    ${actpowermeter_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ${updated_params_dict}=  Create Dictionary  actPowerMeter=true
    ${updated_params_oper_dict}=  Create Dictionary  update=${updated_params_dict}
    ${actpowermeter_mo_dn_json}=  Create Single Dist Name Json String  mo_dn=${actpowermeter_mo_dn}
    ...  updated_params_dict=${updated_params_oper_dict}  distname_operation=update
    ${mtsbtsrmodfan_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/MNL-1/MNLENT-1/PMMNL-1
    ${updated_params_dict}=  Create Dictionary  mtSBTSRMODFan=disabled
    ${updated_params_oper_dict}=  Create Dictionary  update=${updated_params_dict}
    ${mtsbtsrmodfan_json}=  Create Single Dist Name Json String  mo_dn=${mtsbtsrmodfan_mo_dn}
    ...  updated_params_dict=${updated_params_oper_dict}  distname_operation=update
    ${all_json_list}=  Create List  ${actpowermeter_mo_dn_json[1]}  ${mtsbtsrmodfan_json[1]}
    ${json_parameters}=  Create Json String  distnames_json_elements=${all_json_list}
    vdu.Perform Delta Recommissioning  delta_file=${json_parameters}
    ...  wait_for_completion=True  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    Run Keyword And Ignore Error  vDU Rest Logout
