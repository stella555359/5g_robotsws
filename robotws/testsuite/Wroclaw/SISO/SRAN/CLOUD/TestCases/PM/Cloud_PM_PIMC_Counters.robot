*** Settings ***
Documentation
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    Collections
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu

Resource    ../../resources/Robot/vdu_oam_operations.robot
Resource    ../../../resources/Robot/scfc.robot
Resource    ../../resources/variables.robot
Resource    ../../../resources/common_kw.robot

*** Variables ***
${VDU_PIMC_COUNTERS_CELLS_ONAIR_TIMEOUT}=  300s

*** Keywords ***
TC__Cloud_PM_PIMC_Counters
    [Arguments]  ${scfc_file_path}  ${rmod_sn}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-28307
    ...  Feature: CB010412-CR-E-B1 SiSo parity feature,5GC001240 Adaption
    ...  Feature: 5GC001240-B-SyVe- PIM Cancellation - PM Counters
    ...  Test case for CB010412-CR-E-B1 SiSo parity feature (5GC001240 Adaption).
    ...
    ...  Test case gets and checks PIM Cancellation - PM Counters.
    ...  The purpose of this test case is to ensure that with feature 5GC001240 (PIM Cancellation) enabled
    ...  values of Passive Intermodulation (PIM) related PM counters are correctly reported.
    ...  Test case verifies that all counters for feature are correctly gathered.
    ...  The counters RX1...RX8 depend on the number of Radio Antenna Ports, these can vary between 4, 6 and 8 RX Antenna Ports.
    ...  The structure is given by the L3 SM-RM Interface spec. MIN, MAX, SUM, NUM to request the measurement reports.
    ...  Minimum PIM measurement for RRH : M55303C2400x (x=1...8)
    ...  Maximum PIM measurement for RRH : M55303C2500x (x=1...8)
    ...  Sum of PIM measurements for RRH : M55303C2600x (x=1...8)
    ...  Number of PIM measurements for RRH : M55303C2700x (x=1...8)
    ...
    ...  Step 1: Initial check
    ...  a) vDU operation state is OnAir (operational_state=OnAir)
    ...  b) All cells are OnAir
    ...     Cells expected states: operational_state = enabled
    ...                            administrative_state = unlocked
    ...                            availability_status = on_line
    ...  c) Check if radio module serial number is in configuration
    ...  d) Check if PIM Cancellation feature is disabled
    ...  e) Create lists with PIM counters
    ...  Step 2: Check counters when PIM Cancellation is enabled
    ...  a) Enable PIM Cancellation (actPimCancellation=true, pimCancellingEnabled=true)
    ...  b) All cells are OnAir
    ...     Cells expected states: operational_state = enabled
    ...                            administrative_state = unlocked
    ...                            availability_status = on_line
    ...  c) Waiting for PIM counters to be collected
    ...  d) Verifying that all PIM counters have been collected
    ...  Step 3: Check counters when PIM Cancellation is disabled
    ...  a) Disable PIM Cancellation (actPimCancellation=false, pimCancellingEnabled=false)
    ...  b) All cells are OnAir
    ...     Cells expected states: operational_state = enabled
    ...                            administrative_state = unlocked
    ...                            availability_status = on_line
    ...  c) Waiting for PIM counters to be collected
    ...  d) Verifying that all PIM counters have been collected
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_sn                | Yes  | Serial number of the tested radio module.                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

#step1: Initial check
    Log  ${start_prefix_green}Test Case: Get_And_Check_PIMC_Counters  console=${log_to_console}
    vDU Rest Login
    Log  ${dots_prefix_green}Step 1: Initial check  console=${log_to_console}
    ${cells_count}=  vDU SCFC Get NRCELL Count  scfc_file_path=${scfc_file_path}
    vDU Wait For Expected Operational State  vdu_state_value=onAir
    Wait Until All Cells Are OnAir  cells_count=${cells_count}
    Log  ${ok_prefix_green}All cells are OnAir  console=${log_to_console}
    ${mrbts_id}=  vDU Get MRBTS Id  vdu_login=False
    ${all_rmods_params}=  vdu.Get Rmods Status
    FOR  ${rmod_params}  IN  @{all_rmods_params}
      ${rmod_sn_value}=  Set Variable  ${rmod_params['serial_number']}
      ${rmod_id}=  Set Variable  ${rmod_params['configuration_id']}
      ${rmod_ant_ports}=  Set Variable  ${rmod_params['ant_ports']}
      Exit For Loop If  '${rmod_sn_value}'=='${rmod_sn}'
    END
    Run Keyword If  '${rmod_sn_value}'!='${rmod_sn}'
    ...  Fail  Radio module serial number ${rmod_sn} not found in current configuration !
    Log  ${info_prefix}Checking and setting PIM Cancellation parameters (actPimCancellation, pimCancellingEnabled)  console=${log_to_console}
    Log  ${info_prefix}Disable PIM Cancellation feature (actPimCancellation=false pimCancellingEnabled=false)  console=${log_to_console}
    ${pimc_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-${rmod_id}
    Set Test Variable  ${pimc_mo_dn}
    ${act_pim_cancellation_value}=  vdu.Search Parameter Of Current Plan  mo_dn=${pimc_mo_dn}  para_name=actPimCancellation
    ${pim_cancelling_enabled_value}=  vdu.Search Parameter Of Current Plan  mo_dn=${pimc_mo_dn}  para_name=pimCancellingEnabled
    ${updated_params_dict}=  Create Dictionary  actPimCancellation=false  pimCancellingEnabled=false
    ${updated_params_oper_dict}=  Create Dictionary  update=${updated_params_dict}
    ${json_parameters_update}=  Create Single Dist Name Json String  mo_dn=${pimc_mo_dn}
    ...  updated_params_dict=${updated_params_oper_dict}  distname_operation=update
    Run Keyword If  '${act_pim_cancellation_value}'=='true' or '${pim_cancelling_enabled_value}'=='true'
    ...  Run Keywords
    ...  Log  ${below_info_prefix}Recommissioning PIM Cancellation parameters  console=${log_to_console}
    ...  AND
    ...  vdu.Perform Delta Recommissioning  delta_file=${json_parameters_update[0]}
    ...  wait_for_completion=True  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    ${act_pim_cancellation_value}=  vdu.Search Parameter Of Current Plan  mo_dn=${pimc_mo_dn}  para_name=actPimCancellation
    ${pim_cancelling_enabled_value}=  vdu.Search Parameter Of Current Plan  mo_dn=${pimc_mo_dn}  para_name=pimCancellingEnabled
    Log  ${below_info_prefix}actPimCancellation parameter value: ${act_pim_cancellation_value}  console=${log_to_console}
    Log  ${below_info_prefix}pimCancellingEnabled parameter value: ${pim_cancelling_enabled_value}  console=${log_to_console}
    Log  ${info_prefix}Radio module antenna lines checking to determinate number of counters  console=${log_to_console}
    ${ant_port_count}=  Get Length  item=${rmod_ant_ports}
    Log  ${below_info_prefix}Found ${ant_port_count} RX ports for radio module ${rmod_sn}  console=${log_to_console}
    @{min_nr_pim_rx}=  Create List
    @{max_nr_pim_rx}=  Create List
    @{sum_nr_pim_rx}=  Create List
    @{num_nr_pim_rx}=  Create List
    FOR  ${ant_port}  IN RANGE  1  ${ant_port_count+1}
      ${min_name}=  Evaluate  'M55303C2400'+'${ant_port}'
      ${max_name}=  Evaluate  'M55303C2500'+'${ant_port}'
      ${sum_name}=  Evaluate  'M55303C2600'+'${ant_port}'
      ${num_name}=  Evaluate  'M55303C2700'+'${ant_port}'
      Append To list  ${min_nr_pim_rx}  ${min_name}
      Append To list  ${max_nr_pim_rx}  ${max_name}
      Append To list  ${sum_nr_pim_rx}  ${sum_name}
      Append To list  ${num_nr_pim_rx}  ${num_name}
    END
    Log  ${below_info_prefix}The following counters will be checked:  console=${log_to_console}
    ${min_nr_pim_rx_list}  Evaluate  ', '.join(${min_nr_pim_rx})
    ${max_nr_pim__list}  Evaluate  ', '.join(${max_nr_pim_rx})
    ${sum_nr_pim_list}  Evaluate  ', '.join(${sum_nr_pim_rx})
    ${num_nr_pim_list}  Evaluate  ', '.join(${num_nr_pim_rx})
    Log  ${below_info_prefix}Minimum PIM measurement for RRH: ${min_nr_pim_rx_list}  console=${log_to_console}
    Log  ${below_info_prefix}Maximum PIM measurement for RRH: ${max_nr_pim__list}  console=${log_to_console}
    Log  ${below_info_prefix}Sum of PIM measurements for RRH: ${sum_nr_pim_list}  console=${log_to_console}
    Log  ${below_info_prefix}Number of PIM measurements for RRH: ${num_nr_pim_list}  console=${log_to_console}
    ${cell_id_list}=  RMOD Get Cell Id List  rmod_sn=${rmod_sn}
    ${cell_dist_name_list}=  Create List
    FOR  ${cell_id_}  IN  @{cell_id_list}
      Append To List  ${cell_dist_name_list}  MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-${cell_id}
    END
    Log  ${done_prefix_green}Step 1: Initial check  console=${log_to_console}
#step2: Check PIM Counters When Enabled
    Log  ${dots_prefix_green}Step 2: Check counters when PIM Cancellation is enabled  console=${log_to_console}
    Log  ${info_prefix}Enable PIM Cancellation feature (actPimCancellation=true pimCancellingEnabled=true)  console=${log_to_console}
    ${updated_params_dict}=  Create Dictionary  actPimCancellation=true  pimCancellingEnabled=true
    ${updated_params_oper_dict}=  Create Dictionary  update=${updated_params_dict}
    ${json_parameters_update}=  Create Single Dist Name Json String  mo_dn=${pimc_mo_dn}
    ...  updated_params_dict=${updated_params_oper_dict}  distname_operation=update
    vdu.Perform Delta Recommissioning  delta_file=${json_parameters_update[0]}
    ...  wait_for_completion=True  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    ${act_pim_cancellation_value}=  vdu.Search Parameter Of Current Plan  mo_dn=${pimc_mo_dn}  para_name=actPimCancellation
    ${pim_cancelling_enabled_value}=  vdu.Search Parameter Of Current Plan  mo_dn=${pimc_mo_dn}  para_name=pimCancellingEnabled
    Log  ${below_info_prefix}actPimCancellation parameter value: ${act_pim_cancellation_value}  console=${log_to_console}
    Log  ${below_info_prefix}pimCancellingEnabled parameter value: ${pim_cancelling_enabled_value}  console=${log_to_console}
    vDU Wait For Expected Operational State  vdu_state_value=onAir
    Wait Until All Cells Are OnAir
    ...  cells_count=${cells_count}
    ...  timeout=${VDU_PIMC_COUNTERS_CELLS_ONAIR_TIMEOUT}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
    ${time_to_sleep}  ${time_to_verdict}=  Time To Sleep  interval=15  additional_offset=${15}
    Log  ${info_prefix}PIM counters collecting  console=${log_to_console}
    Log  ${below_info_prefix}PIM counters will be collected at ${time_to_verdict}  console=${log_to_console}
    Log  ${below_info_prefix}Wait ${time_to_sleep} minutes for PIM counters to be collected ...  console=${log_to_console}
#    vDU Rest Logout
    Sleep  ${time_to_sleep} minutes
#    vDU Rest Login
    Log  ${below_info_prefix}PIM counters have been collected  console=${log_to_console}
    Log  ${info_prefix}Verifying that all PIM counters have been collected  console=${log_to_console}
    ${min_pim_enabled}=  Set Variable  0
    FOR  ${dist_name}  IN  @{cell_dist_name_list}
      ${counter_length}=  Get And Verify PIM Counters And Return Length
      ...  dist_name=${dist_name}  counter_id_list=${min_nr_pim_rx}
      ${min_pim_enabled}=  Evaluate  expression=${min_pim_enabled}+${counter_length}
    END
    ${max_pim_enabled}=  Set Variable  0
    FOR  ${dist_name}  IN  @{cell_dist_name_list}
      ${counter_length}=  Get And Verify PIM Counters And Return Length
      ...  dist_name=${dist_name}  counter_id_list=${max_nr_pim_rx}
      ${max_pim_enabled}=  Evaluate  expression=${max_pim_enabled}+${counter_length}
    END
    ${sum_pim_enabled}=  Set Variable  0
    FOR  ${dist_name}  IN  @{cell_dist_name_list}
      ${counter_length}=  Get And Verify PIM Counters And Return Length
      ...  dist_name=${dist_name}  counter_id_list=${sum_nr_pim_rx}
      ${sum_pim_enabled}=  Evaluate  expression=${sum_pim_enabled}+${counter_length}
    END
    ${num_pim_enabled}=  Set Variable  0
    FOR  ${dist_name}  IN  @{cell_dist_name_list}
      ${counter_length}=  Get And Verify PIM Counters And Return Length
      ...  dist_name=${dist_name}  counter_id_list=${num_nr_pim_rx}
      ${num_pim_enabled}=  Evaluate  expression=${num_pim_enabled}+${counter_length}
    END
    ${equal}=  Evaluate  ${min_pim_enabled}==${max_pim_enabled}==${sum_pim_enabled}==${num_pim_enabled}
    Run Keyword If  ${equal}
    ...  Log  ${below_info_prefix}All PIM counters return the same number of measurements  console=${log_to_console}
    ...  ELSE
    ...  Run Keyword And Continue On Failure
    ...  Fail  One of counters return wrong number of measurements rows !
    Log  ${done_prefix_green}Step 2: Check counters when PIM Cancellation is enabled  console=${log_to_console}
#step3: Check PIM Counters When Disabled
    Log  ${dots_prefix_green}Step 3: Check counters when PIM Cancellation is disabled  console=${log_to_console}
    Log  ${info_prefix}Disable PIM Cancellation feature (actPimCancellation=false pimCancellingEnabled=false)  console=${log_to_console}
    ${updated_params_dict}=  Create Dictionary  actPimCancellation=false  pimCancellingEnabled=false
    ${updated_params_oper_dict}=  Create Dictionary  update=${updated_params_dict}
    ${json_parameters_update}=  Create Single Dist Name Json String  mo_dn=${pimc_mo_dn}
    ...  updated_params_dict=${updated_params_oper_dict}  distname_operation=update
    vdu.Perform Delta Recommissioning  delta_file=${json_parameters_update[0]}
    ...  wait_for_completion=True  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    ${act_pim_cancellation_value}=  vdu.Search Parameter Of Current Plan  mo_dn=${pimc_mo_dn}  para_name=actPimCancellation
    ${pim_cancelling_enabled_value}=  vdu.Search Parameter Of Current Plan  mo_dn=${pimc_mo_dn}  para_name=pimCancellingEnabled
    Log  ${below_info_prefix}actPimCancellation parameter value: ${act_pim_cancellation_value}  console=${log_to_console}
    Log  ${below_info_prefix}pimCancellingEnabled parameter value: ${pim_cancelling_enabled_value}  console=${log_to_console}
    vDU Wait For Expected Operational State  vdu_state_value=onAir
    Wait Until All Cells Are OnAir
    ...  cells_count=${cells_count}
    ...  timeout=${VDU_PIMC_COUNTERS_CELLS_ONAIR_TIMEOUT}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
    ${time_to_sleep}  ${time_to_verdict}=  Time To Sleep  interval=15  additional_offset=${15}
    Log  ${info_prefix}PIM counters should not be collected  console=${log_to_console}
    Log  ${below_info_prefix}Verdict will be released at ${time_to_verdict}  console=${log_to_console}
    Log  ${below_info_prefix}Wait ${time_to_sleep} minutes ...  console=${log_to_console}
#    vDU Rest Logout
    Sleep  ${time_to_sleep} minutes
#    vDU Rest Login
    Log  ${below_info_prefix}PIM counters have been collected  console=${log_to_console}
    Log  ${info_prefix}Verifying that PIM Cancellation feature is disabled  console=${log_to_console}
    ${min_pim_disabled}=  Set Variable  0
    FOR  ${dist_name}  IN  @{cell_dist_name_list}
      ${counter_length}=  Get And Verify PIM Counters And Return Length
      ...  dist_name=${dist_name}  counter_id_list=${min_nr_pim_rx}  verify_counters=False
      ${min_pim_disabled}=  Evaluate  expression=${min_pim_disabled}+${counter_length}
    END
    ${max_pim_disabled}=  Set Variable  0
    FOR  ${dist_name}  IN  @{cell_dist_name_list}
      ${counter_length}=  Get And Verify PIM Counters And Return Length
      ...  dist_name=${dist_name}  counter_id_list=${max_nr_pim_rx}  verify_counters=False
      ${max_pim_disabled}=  Evaluate  expression=${max_pim_disabled}+${counter_length}
    END
    ${sum_pim_disabled}=  Set Variable  0
    FOR  ${dist_name}  IN  @{cell_dist_name_list}
      ${counter_length}=  Get And Verify PIM Counters And Return Length
      ...  dist_name=${dist_name}  counter_id_list=${sum_nr_pim_rx}  verify_counters=False
      ${sum_pim_disabled}=  Evaluate  expression=${sum_pim_disabled}+${counter_length}
    END
    ${num_pim_disabled}=  Set Variable  0
    FOR  ${dist_name}  IN  @{cell_dist_name_list}
      ${counter_length}=  Get And Verify PIM Counters And Return Length
      ...  dist_name=${dist_name}  counter_id_list=${num_nr_pim_rx}  verify_counters=False
      ${num_pim_disabled}=  Evaluate  expression=${num_pim_disabled}+${counter_length}
    END
    ${min_counter_verdict}=  Evaluate  ${min_pim_enabled} <= ${min_pim_disabled} <= ${min_pim_enabled+(${ant_port_count}*${cells_count})}
    ${max_counter_verdict}=  Evaluate  ${max_pim_enabled} <= ${max_pim_disabled} <= ${max_pim_enabled+(${ant_port_count}*${cells_count})}
    ${sum_counter_verdict}=  Evaluate  ${sum_pim_enabled} <= ${sum_pim_disabled} <= ${sum_pim_enabled+(${ant_port_count}*${cells_count})}
    ${num_counter_verdict}=  Evaluate  ${num_pim_enabled} <= ${num_pim_disabled} <= ${num_pim_enabled+(${ant_port_count}*${cells_count})}
    ${fail_msg1}=  Set Variable  PIM Cancellation feature deactivation wasn't successfull !\n
    ${fail_msg2}=  Set Variable  The number of counters changed after disable PIM Cancellation feature !
    Run Keyword If  (${min_counter_verdict} and ${max_counter_verdict} and ${sum_counter_verdict} and ${num_counter_verdict})==True
    ...  Log  ${below_info_prefix}PIM Cancellation feature deactivation was successfull  console=${log_to_console}
    ...  ELSE  Fail  ${fail_msg1}${fail_msg2}
    Log  ${done_prefix_green}Step 3: Check counters when PIM Cancellation is disabled  console=${log_to_console}
    Log  ${done_prefix_green}Test Case: Get_And_Check_PIMC_Counters  console=${log_to_console}
    [Teardown]  PIMC Counters Teardown  tc_status=${KEYWORD_STATUS}

#INTERNAL TEST CASE KEYWORDS
PIMC Counters Teardown
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

    Run Keyword If  '${tc_status}'=='PASS'
    ...  Run Keyword And Ignore Error  vDU Rest Logout
    Return From Keyword If  '${tc_status}'=='PASS'
    ${updated_params_dict}=  Create Dictionary  actPimCancellation=false  pimCancellingEnabled=false
    vDU Verify And Update Parameter Of Delta Plan
    ...  mo_dn=${pimc_mo_dn}  updated_params_dict=${updated_params_dict}
    Run Keyword And Ignore Error  vDU Rest Logout
