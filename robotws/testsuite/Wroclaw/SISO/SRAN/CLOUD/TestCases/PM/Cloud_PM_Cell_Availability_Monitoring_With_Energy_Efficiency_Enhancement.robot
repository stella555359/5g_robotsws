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

*** Variables ***
@{VCU_ENERGY_EFFICIENCY_ALLOWED_HIST_ALARMS}=  faultId=7104, severity=critical

*** Keywords ***
TC__Cloud_PM_Cell_Availability_Monitoring_With_Energy_Efficiency_Enhancement
    [Arguments]  ${scfc_file_path}  ${rmod_sn_list}  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_VRF_SISO-5810
    ...  Feature: CB013240 - Energy saving mode PM counters enhancements
    ...  CB013240 feature introduces the NR counter M55601C00503 (Number of NR cell state changes to available).
    ...  The purpose of this test case is verification influence Energy Saving Mode on 5G cells
    ...  and checking the correctness of collecting counters.
    ...  The following features are enabled by test:
    ...  - 5GC000431 Cell switch-off (component carrier) for Energy Efficiency (actNrLBPowerSaving = True)
    ...  - CB007511 Deep Sleep mode for Reefshark 6602 mMIMO products (EnergySavingMode = DeepSleep)
    ...
    ...  5G Counters:
    ...  SAMPLES_NR_CELL_POWER_SAVING (M55601C00501) - this counter indicates the number of samples
    ...  when the NR cell is in the "power saving mode" state.
    ...  This counter is incremented by 1 approximately every second when the NR cell "operationalState" parameter
    ...  is set to "disabled", and the NR cell "energySavingState" parameter is set to "energySaving".
    ...  NR_CELL_PLAN_UNAVAIL_SAMPLES (M55601C01001) - this counter provides the number of samples
    ...  when the NR cell is unavailable (doesn't provide any service) due to any operator-planned event.
    ...  NR_CELL_AVAIL_CHNG_TO (M55601C00503) - this counter indicates the number of cell state changes to available.
    ...  This counter is incremented immediately when a new state is reached (the transitional state belongs to the previous period).
    ...  M55601C00501 and M55601C01001 should be similar (the permissible difference between them is a maximum of 2).
    ...  NR_CELL_AVAIL_CHNG_TO (M55601C00503) should be equal to the number of cell status changes to 'available'.
    ...
    ...  During test execution the following parameters will be updated:
    ...  actNrLBPowerSaving=True
    ...  EnergySavingMode=DeepSleep
    ...  miNrCellAvailability=30min
    ...  Objects NRPGRP-x must be created with all mandatory parameters needed to perform switch-off cells,
    ...  need also contain all testing cells (lbpsPeriodList). One object NRPGRP corresponds to one radio module.
    ...  Objects NRPGRP-x should be numbered sequentially started from 1: NRPGRP-1, NRPGRP-2, NRPGRP-3 and so on.
    ...
    ...  During test execution the following parameters in objects NRPGRP will be updated:
    ...  lbpsDayOfWeek, lbpsStartTimeHour, lbpsStartTimeMinute.
    ...
    ...  Step 1: Initial Check And Settings
    ...  a) vDU operation state is OnAir (operational_state=OnAir)
    ...  b) All cells are OnAir
    ...     Cells expected states: operational_state = enabled
    ...                            administrative_state = unlocked
    ...                            availability_status = on_line
    ...  c) Radio module power state: power_state = AWAKE
    ...  Step 2: Activate Initial Features And Parameters
    ...  a) Set parameter "energySavingMode" to "DEEPSLEEP"
    ...  b) Set parameter "actNrLBPowerSaving" to "true"
    ...  c) Set parameter "miNrCellAvailability" to "30min"
    ...  Step 3: Set Power Saving Period
    ...  a) Set parameters lbpsDayOfWeek, lbpsStartTimeHour and lbpsStartTimeMinute
    ...  Step 4: Check Cells And Radio Modules States
    ...  a) Cells expected states: availabilityStatus = off line
    ...                            operationalState = disabled
    ...                            energySavingState = energySaving
    ...  b) Radio module power state: power_state = SLEEP
    ...  Step 5: Get And Verify Counters
    ...  a) Verify counters: M55601C00501, M55601C01001, M55601C00503
    ...  Step 6: Deactivate Initial Features And Parameters
    ...  a) Set parameter "energySavingMode" to "NORMAL"
    ...  b) Set parameter "actNrLBPowerSaving" to "false"
    ...  Step 7: Postconditions
    ...  b) Radio module power state: power_state = SLEEP
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
    ...  | rmod_sn_list           | Yes  | Serial number list of the tested radio module.                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Set Test Variable  ${scfc_file_path}
    Set Test Variable  ${rmod_sn_list}
    Set Test Variable  ${log_to_console}
    Log  ${start_prefix_green}Test Case: Cell Availability Monitoring With Energy Efficiency Enhancement  console=${log_to_console}
    Step 1: Initial Check
    Step 2: Activate Initial Features And Parameters
    Step 3: Set Power Saving Period
    Step 4: Check Cells And Radio Modules States
    Step 5: Get And Verify Counters
    Step 6: Deactivate Initial Features And Parameters
    Step 7: Postconditions
    Log  ${done_prefix_green}Test Case: Cell Availability Monitoring With Energy Efficiency Enhancement  console=${log_to_console}
    [Teardown]  Cell Availability Monitoring With Energy Efficiency Enhancement Teardown  tc_status=${KEYWORD_STATUS}

Step 1: Initial Check
    Log  ${dots_prefix_green}Step 1: Initial Check  console=${log_to_console}
    Append To List  ${VCU_HISTORICAL_ALLOWED_ALARMS}  @{VCU_ENERGY_EFFICIENCY_ALLOWED_HIST_ALARMS}
    vDU Rest Login
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
    Log  ${ok_prefix_green}Step 1: Initial check  console=${log_to_console}

Step 2: Activate Initial Features And Parameters
    Log  ${dots_prefix_green}Step 2: Activate initial features and parameters  console=${log_to_console}
    Log  ${info_prefix}Parameter settings on radio module:  console=${log_to_console}
    Log  ${below_info_prefix}energySavingMode=DEEPSLEEP  console=${log_to_console}
    Log  ${below_info_prefix}actNrLBPowerSaving=true  console=${log_to_console}
    Log  ${below_info_prefix}miNrCellAvailability=30min  console=${log_to_console}
#Activate EnergySaving On Radio Module
    ${energysavingmode_json_list}=  Create List
    FOR  ${rmod_sn}  IN  @{rmod_sn_list}
      ${rmod_conf_id}=  vDU RMOD Get Parameter Value Based On Serial Number  rmod_sn=${rmod_sn}  rmod_param=configuration_id
      ${energysavingmode_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-${rmod_conf_id}
      ${updated_params_dict}=  Create Dictionary  energySavingMode=DEEPSLEEP
      ${updated_params_oper_dict}=  Create Dictionary  update=${updated_params_dict}
      ${energysavingmode_json}=  Create Single Dist Name Json String  mo_dn=${energysavingmode_mo_dn}
      ...  updated_params_dict=${updated_params_oper_dict}  distname_operation=update
      Append To List  ${energysavingmode_json_list}  ${energysavingmode_json[1]}
    END
#Activate NR load-based power saving feature on radio module
    ${powersaving_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/NRBTS-${mrbts_id}
    ${updated_params_dict}=  Create Dictionary  actNrLBPowerSaving=true
    ${updated_params_oper_dict}=  Create Dictionary  update=${updated_params_dict}
    ${powersaving_json}=  Create Single Dist Name Json String  mo_dn=${powersaving_mo_dn}
    ...  updated_params_dict=${updated_params_oper_dict}  distname_operation=update
#Activate Measurement Interval For The NR Cell Availability (NCAV)
    ${cellavailability_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRPMRNL-1
    ${updated_params_dict}=  Create Dictionary  miNrCellAvailability=30min
    ${updated_params_oper_dict}=  Create Dictionary  update=${updated_params_dict}
    ${cellavailability_json}=  Create Single Dist Name Json String  mo_dn=${cellavailability_mo_dn}
    ...  updated_params_dict=${updated_params_oper_dict}  distname_operation=update
    ${all_json_list}=  Create List  @{energysavingmode_json_list}  ${powersaving_json[1]}  ${cellavailability_json[1]}
    ${json_parameters}=  Create Json String  distnames_json_elements=${all_json_list}
    vdu.Perform Delta Recommissioning  delta_file=${json_parameters}
    ...  wait_for_completion=True  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    Log  ${ok_prefix_green}Step 2: Activate initial features and parameters  console=${log_to_console}

Step 3: Set Power Saving Period
    Log  ${dots_prefix_green}Step 3: Set power saving period  console=${log_to_console}
    ${hour}  ${minutes}  ${week_day}  ${final_time}=  Set Power Saving Time Components
    ${minutes_left}=  Calculate Minutes To Wait  time=${final_time}
    Set Test Variable  ${minutes_left}
    Set Test Variable  ${final_time}
    Log  ${info_prefix}Activate power saving period setting  console=${log_to_console}
    Log  ${info_prefix}Power saving period parameters:  console=${log_to_console}
    Log  ${below_info_prefix}lbpsDayOfWeek=${week_day}  console=${log_to_console}
    Log  ${below_info_prefix}lbpsStartTimeHour=${hour}  console=${log_to_console}
    Log  ${below_info_prefix}lbpsStartTimeMinute=${minutes}  console=${log_to_console}
    ${lbps_period_json_list}=  Create List
    ${rmod_sn_count}=  Get Length  ${rmod_sn_list}
    FOR  ${number}  IN RANGE  1  ${rmod_sn_count+1}
      ${lbps_period_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRPGRP-${number}
      ${lbps_period_params}=  Create Dictionary  lbpsDayOfWeek=${week_day}  lbpsDuration=30  lbpsStartTimeHour=${hour}
      ...  lbpsStartTimeMinute=${minutes}  lbpsSuspended=notSuspended
      ${lbps_period_list}=  Create List  ${lbps_period_params}
      ${updated_params_dict}=  Create Dictionary  lbpsPeriodList=${lbps_period_list}
      ${updated_params_oper_dict}=  Create Dictionary  update=${updated_params_dict}
      ${lbps_period_json}=  Create Single Dist Name Json String  mo_dn=${lbps_period_mo_dn}
      ...  updated_params_dict=${updated_params_oper_dict}  distname_operation=update
      Append To List  ${lbps_period_json_list}  ${lbps_period_json[1]}
    END
    ${json_parameters}=  Create Json String  distnames_json_elements=${lbps_period_json_list}
    vdu.Perform Delta Recommissioning  delta_file=${json_parameters}
    ...  wait_for_completion=True  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    Log  ${info_prefix}Power saving period activated  console=${log_to_console}
    Log  ${ok_prefix_green}Step 3: Set power saving period  console=${log_to_console}

Step 4: Check Cells And Radio Modules States
    Log  ${dots_prefix_green}Step 4: Check Cells And Radio Modules States  console=${log_to_console}
    ${grace_period}=  Set Variable  5min
    Set Test Variable  ${grace_period}
    Log  ${info_prefix}The cells will start entering the "energySaving" state at ${final_time}  console=${log_to_console}
    Log  ${info_prefix}Waiting ${minutes_left} minutes for cells to start entering the "energySaving" state ...  console=${log_to_console}
    Sleep  ${minutes_left} min
    Log  ${info_prefix}Waiting few minutes (5-6min) for cells to switch-off ...  console=${log_to_console}
    ${cell_state_dict}=  Create Dictionary  availabilityStatus=off line  operationalState=disabled  energySavingState=energySaving
    FOR  ${affected_cell_id}  IN  @{affected_cells_id_list}
      Cell Wait For Expected States Or Statuses  cell_id=${affected_cell_id}  state_status_dict=${cell_state_dict}  timeout=420s
    END
    Log  ${info_prefix}All affected cells are in power saving mode  console=${log_to_console}
      ...  console=${log_to_console}
    Log  ${info_prefix}Waiting for radio modules power state (SLEEP). Please wait grace period (${grace_period}) ...
    FOR  ${rmod_sn}  IN  @{rmod_sn_list}
      RMOD Wait For Expected State  rmod_sn=${rmod_sn}  rmod_state=power_state  rmod_state_value=SLEEP  timeout=${grace_period}
      ${rmod_power_state}=  RMOD Get Current State  rmod_sn=${rmod_sn}  rmod_state=power_state
    END
    Log  ${info_prefix}All affected radio modules are in deep sleep mode  console=${log_to_console}
    Log  ${ok_prefix_green}Step 4: Check Cells And Radio Modules States  console=${log_to_console}

Step 5: Get And Verify Counters
    Log  ${dots_prefix_green}Step 5: Get and verify counters  console=${log_to_console}
    ${time_to_sleep}  ${time_to_verdict}=  Time To Sleep  interval=30  additional_offset=30
    Log  ${info_prefix}The counters will be collected at ${time_to_verdict}  console=${log_to_console}
    Log  ${info_prefix}Wait ${time_to_sleep} minutes for counters to be collected ...  console=${log_to_console}
    Sleep  ${time_to_sleep} min
    FOR  ${affected_cell_dist_name}  IN  @{affected_cells_dist_name_list}
      ${M55601C00501_counters}=  vdu.Get Counter Values  counter_id=M55601C00501  dimension_dn=${affected_cell_dist_name}
      ${M55601C01001_counters}=  vdu.Get Counter Values  counter_id=M55601C01001  dimension_dn=${affected_cell_dist_name}
      ${M55601C00503_counters}=  vdu.Get Counter Values  counter_id=M55601C00503  dimension_dn=${affected_cell_dist_name}
      Log  ${info_prefix}Checking the counter M55601C00501 value  console=${log_to_console}
      Run Keyword If  ${M55601C00501_counters[-1]['value']}>0
      ...  Log  ${below_info_prefix}Counter M55601C00501 value on ${affected_cell_dist_name} is correct  console=${log_to_console}
      ...  ELSE
      ...  Run Keyword And Continue On Failure
      ...  Fail  msg=Counter M55601C00501 value on ${affected_cell_dist_name} is not correct, should be 0 !
      Run Keyword If  ${M55601C01001_counters[-1]['value']}>0
      ...  Log  ${below_info_prefix}Counter M55601C01001 value on ${affected_cell_dist_name} is correct  console=${log_to_console}
      ...  ELSE
      ...  Run Keyword And Continue On Failure
      ...  Fail  msg=Counter M55601C01001 value on ${affected_cell_dist_name} is not correct, should be 0 !
      Run Keyword If  ${M55601C00503_counters[-1]['value']}==1
      ...  Log  ${below_info_prefix}Counter M55601C00503 value on ${affected_cell_dist_name} is correct  console=${log_to_console}
      ...  ELSE
      ...  Run Keyword And Continue On Failure
      ...  Fail  msg=Counter M55601C00503 value on ${affected_cell_dist_name} is not correct, should be 1 !
      Log  ${info_prefix}Checking the counter values (M55601C00501 and M55601C01001)  console=${log_to_console}
      ${diff_result}=  Evaluate  abs(${M55601C00501_counters[-1]['value']}-${M55601C01001_counters[-1]['value']})<=2
      Run Keyword If  ${diff_result}
      ...  Log  ${below_info_prefix}Value between counter M55601C00501 and M55601C01001 on ${affected_cell_dist_name} is within the assumed range
      ...  console=${log_to_console}
      ...  ELSE
      ...  Run Keyword And Continue On Failure
      ...  Fail  msg=The value between counters M55601C00501 and M55601C01001 on ${affected_cell_dist_name} are out of range !
    END
    Log  ${ok_prefix_green}Step 5: Get and verify counters  console=${log_to_console}

Step 6: Deactivate Initial Features And Parameters
    Log  ${dots_prefix_green}Step 6: Deactivate initial features and parameters  console=${log_to_console}
    Log  ${info_prefix}Parameters settings on radio module:  console=${log_to_console}
    Log  ${below_info_prefix}energySavingMode=Normal  console=${log_to_console}
    Log  ${below_info_prefix}actNrLBPowerSaving=false  console=${log_to_console}
#Deactivate EnergySaving On Radio Module
    ${energysavingmode_json_list}=  Create List
    FOR  ${rmod_sn}  IN  @{rmod_sn_list}
      ${rmod_conf_id}=  vDU RMOD Get Parameter Value Based On Serial Number  rmod_sn=${rmod_sn}  rmod_param=configuration_id
      ${energysavingmode_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-${rmod_conf_id}
      ${updated_params_dict}=  Create Dictionary  energySavingMode=NORMAL
      ${updated_params_oper_dict}=  Create Dictionary  update=${updated_params_dict}
      ${energysavingmode_json}=  Create Single Dist Name Json String  mo_dn=${energysavingmode_mo_dn}
      ...  updated_params_dict=${updated_params_oper_dict}  distname_operation=update
      Append To List  ${energysavingmode_json_list}  ${energysavingmode_json[1]}
    END
#Deactivate NR load-based power saving feature on radio module
    ${powersaving_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/NRBTS-${mrbts_id}
    ${updated_params_dict}=  Create Dictionary  actNrLBPowerSaving=false
    ${updated_params_oper_dict}=  Create Dictionary  update=${updated_params_dict}
    ${powersaving_json}=  Create Single Dist Name Json String  mo_dn=${powersaving_mo_dn}
    ...  updated_params_dict=${updated_params_oper_dict}  distname_operation=update
    ${all_json_list}=  Create List  @{energysavingmode_json_list}  ${powersaving_json[1]}
    ${json_parameters}=  Create Json String  distnames_json_elements=${all_json_list}
    vdu.Perform Delta Recommissioning  delta_file=${json_parameters}
    ...  wait_for_completion=True  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    Log  ${ok_prefix_green}Step 6: Deactivate initial features and parameters  console=${log_to_console}

Step 7: Postconditions
    Log  ${dots_prefix_green}Step 7: Postconditions  console=${log_to_console}
    Log  ${info_prefix}Checking for radio modules power state (AWAKE)
    FOR  ${rmod_sn}  IN  @{rmod_sn_list}
      RMOD Wait For Expected State  rmod_sn=${rmod_sn}  rmod_state=power_state  rmod_state_value=AWAKE  timeout=${grace_period}
    END
    Log  ${info_prefix}All radio modules power state is AWAKE  console=${log_to_console}
    Wait Until All Cells Are OnAir  cells_count=${cells_count}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 7: Postconditions  console=${log_to_console}

#INTERNAL TEST CASE KEYWORDS
Set Power Saving Time Components
    [Documentation]
    ...  Description:
    ...  Keyword sets power saving time components.
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${time_increment}=  Set Variable  ${-1}
    ${current_date_time}=  Get Current Date  increment=${time_increment} hours
    ${next_day}=  Add Time To Date  date=${current_date_time}  time=1 days  result_format=%A
    ${current_time}=  Get Current Date  result_format=%H:%M  increment=${time_increment} hours
    ${current_day}=  Get Current Date  result_format=%A  increment=${time_increment} hours
    ${hour}=  Convert To Integer  item=${current_time.split(':')[0]}
    ${minutes}=  Convert To Integer  item=${current_time.split(':')[1]}
    ${hour}  ${minutes}=  Run Keyword If  ${minutes}>=0 and ${minutes}<20
    ...  Set Variable  ${hour}  31
    ...  ELSE IF  ${minutes}>=20 and ${minutes}<50
    ...  Set Variable  ${hour+1}  1
    ...  ELSE IF  ${minutes}>=50
    ...  Set Variable  ${hour+1}  31
    ${hour}=  Evaluate  expression=${hour}%24
    ${hour}=  Convert To String  item=${hour}
    ${minutes}=  Convert To String  item=${minutes}
    ${new_time}  Set Variable If  '${minutes}'=='1'  ${hour}:0${minutes}  ${hour}:${minutes}
    ${short_day}=  Set Variable If  ${hour}==0  ${next_day[:3]}  ${current_day[:3]}
    [Return]  ${hour}  ${minutes}  ${short_day}  ${new_time}

Calculate Minutes To Wait
    [Arguments]  ${time}
    [Documentation]
    ...  Description:
    ...  Keyword calculates the difference between the current time and the given time.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | time                  | Yes  | Time when cells will start entering to the "energySaving" state.            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${time_increment}=  Set Variable  ${-1}
    ${current_time}=  Get Current Date  result_format=%H:%M  increment=${time_increment} hours
    ${minutes}=  Subtract Time From Time  time1=${time}  time2=${current_time}
    ${minutes}  Convert To Integer  item=${minutes}
    ${minutes}=  Set Variable If  ${minutes}<0  ${minutes+1440}  ${minutes}
    [Return]  ${minutes}

Cell Availability Monitoring With Energy Efficiency Enhancement Teardown
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
#Deactivate EnergySaving On Radio Module
    ${energysavingmode_json_list}=  Create List
    FOR  ${rmod_sn}  IN  @{rmod_sn_list}
      ${rmod_conf_id}=  vDU RMOD Get Parameter Value Based On Serial Number  rmod_sn=${rmod_sn}  rmod_param=configuration_id
      ${energysavingmode_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-${rmod_conf_id}
      ${updated_params_dict}=  Create Dictionary  energySavingMode=NORMAL
      ${updated_params_oper_dict}=  Create Dictionary  update=${updated_params_dict}
      ${energysavingmode_json}=  Create Single Dist Name Json String  mo_dn=${energysavingmode_mo_dn}
      ...  updated_params_dict=${updated_params_oper_dict}  distname_operation=update
      Append To List  ${energysavingmode_json_list}  ${energysavingmode_json[1]}
    END
#Deactivate NR load-based power saving feature on radio module
    ${powersaving_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/NRBTS-${mrbts_id}
    ${updated_params_dict}=  Create Dictionary  actNrLBPowerSaving=false
    ${updated_params_oper_dict}=  Create Dictionary  update=${updated_params_dict}
    ${powersaving_json}=  Create Single Dist Name Json String  mo_dn=${powersaving_mo_dn}
    ...  updated_params_dict=${updated_params_oper_dict}  distname_operation=update
    ${all_json_list}=  Create List  @{energysavingmode_json_list}  ${powersaving_json[1]}
    ${json_parameters}=  Create Json String  distnames_json_elements=${all_json_list}
    vdu.Perform Delta Recommissioning  delta_file=${json_parameters}
    ...  wait_for_completion=True  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    Run Keyword And Ignore Error  vDU Rest Logout
