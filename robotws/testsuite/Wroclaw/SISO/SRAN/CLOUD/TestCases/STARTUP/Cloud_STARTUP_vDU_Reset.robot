*** Settings ***
Documentation
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu

Resource    ../../resources/Robot/vdu_oam_operations.robot
Resource    ../../../resources/Robot/scfc.robot
Resource    ../../../resources/Robot/common_kw.robot
Resource    ../../resources/Robot/setup_teardown.robot

*** Variables ***
${VDU_RESET_VDU_CELLS_ONAIR_TIMEOUT}=  60s
@{VDU_RESET_VDU_ALLOWED_HIST_ALARMS}=  faultId=4592, severity=warning
...                                    faultId=4592, severity=minor
@{VCU_RESET_VDU_ALLOWED_HIST_ALARMS}=  faultId=7104, severity=critical

*** Keywords ***
TC__Cloud_STARTUP_vDU_Reset
    [Arguments]  ${vdu_scfc_file_path}  ${get_kpi}=${False}  ${expected_kpi52a_value}=300
    ...  ${expected_kpi52b_value}=270  ${vdu_connection}=default  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Keyword performs vDU reset.
    ...
    ...  Step 1: Preconditions vDU Reset
    ...  a) All radio modules should be on line
    ...  b) All cells should be OnAir
    ...  c) vDU operational state should be onAir
    ...  Step 2: Perform vDU Reset
    ...  a) Check BTS Reset Cause Alarm
    ...  Step 3: Check Site States After vDU Reset
    ...  a) F1-C expected link status: available
    ...  b) Wait until all radio modules are on line
    ...  c) Wait until all cells are OnAir
    ...  Step 4: Postconditions vDU Reset
    ...  a) The same values as in Step 1
    ...  No unexpected alarms are visible
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_scfc_file_path     | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_kpi                |  No  | Get kpi52a/kpi52b or not.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | expected_kpi52a_value  |  No  | Expected kpi52a value defined by user (in seconds).                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | expected_kpi52b_value  |  No  | Expected kpi52b value defined by user (in seconds).                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Set Test Variable  ${vdu_scfc_file_path}
    Set Test Variable  ${get_kpi}
    Set Test Variable  ${expected_kpi52a_value}
    Set Test Variable  ${expected_kpi52b_value}
    Set Test Variable  ${vdu_connection}
    Set Test Variable  ${log_to_console}
    Log  ${start_prefix_green}Test Case: vDU_Reset  console=${log_to_console}
    Step 1: Preconditions vDU Reset
    Step 2: Perform vDU Reset
    Step 3: Check Site States After vDU Reset
    Step 4: Postconditions vDU Reset
    Log  ${done_prefix_green}Test Case: vDU_Reset  console=${log_to_console}
    [Teardown]  Run Keyword And Ignore Error  vDU Rest Logout  vdu_connection=${vdu_connection}

Step 1: Preconditions vDU Reset
    Log  ${dots_prefix_green}Step 1: Preconditions vDU reset  console=${log_to_console}
    Append To List  ${VDU_HISTORICAL_ALLOWED_ALARMS}  @{VDU_RESET_VDU_ALLOWED_HIST_ALARMS}
    Append To List  ${VCU_HISTORICAL_ALLOWED_ALARMS}  @{VCU_RESET_VDU_ALLOWED_HIST_ALARMS}
    vDU Rest Login  vdu_connection=${vdu_connection}
# KPI preconditions
    IF  ${get_kpi}
      ${kpi_dict_52a}=  Create Dictionary
      Set Test Variable  ${kpi_dict_52a}
      ${kpi_dict_52b}=  Create Dictionary
      Set Test Variable  ${kpi_dict_52b}
      Set Test Variable  ${kpi_result_file_path}  ${TC_RUN_LOGS_DIR_PATH}/KPI_results.txt
    END
# Wait until all radio modules are on line
    ${vdu_scfc_rmods_count}=  vDU SCFC Get RMODs Count  scfc_file_path=${vdu_scfc_file_path}
    Set Test Variable  ${vdu_scfc_rmods_count}
    Wait Until All Radio Modules Are Online
    ...  rmods_count=${vdu_scfc_rmods_count}
    ...  timeout=30s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All radio modules are on line  console=${log_to_console}
# Wait until all cells are OnAir
    ${vdu_scfc_nrcells_count}=  vDU SCFC Get NRCELL Count  scfc_file_path=${vdu_scfc_file_path}
    Wait Until All Cells Are OnAir
    ...  cells_count=${vdu_scfc_nrcells_count}
    ...  timeout=30s
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${vdu_scfc_nrcells_count}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
# Check vDU operational state
    vDU Wait For Expected Operational State
    ...  vdu_state_value=onAir
    ...  timeout=30s
    ...  vdu_check=${True}
    ...  lte_vdu_check=${False}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}vDU operational state is onAir  console=${log_to_console}
# Get and set variables
    ${vdu_scfc_cell_id_list}=  vDU SCFC Get NRCELL Id List  scfc_file_path=${vdu_scfc_file_path}
    Set Test Variable  ${vdu_scfc_cell_id_list}
# Get fault 4592 cancellation timer
    ${mrbts_id}=  vDU Get MRBTS Id
    ...  vdu_connection=${vdu_connection}
    ${timer_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FMCADM-1
    ${cancellation_timer}=  vdu.Search Parameter Of Current Plan
    ...  mo_dn=${timer_mo_dn}
    ...  para_name=fault4592CancellationTimer
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${cancellation_timer}
# Set VDU instance id
    ${vdu_params}=  vdu.Get Vdu State Data
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${vdu_id}  ${vdu_params['id']}
# Set cells states
    ${cbts_online_cell_state_dict}=  Create Dictionary  availabilityStatus=on line
    ...  operationalState=enabled  administrativeState=Unlocked  blockingState=Unblocked
    Set Test Variable  ${cbts_online_cell_state_dict}
    Log  ${ok_prefix_green}Step 1: Preconditions vDU reset  console=${log_to_console}

Step 2: Perform vDU Reset
    Log  ${dots_prefix_green}Step 2: Perform vDU reset  console=${log_to_console}
    Log  ${info_prefix}vDU reset is being performed. Wait for vDU reset ...  console=${log_to_console}
    ${reset_result}=  vdu.Reset Vdu
    ...  vdu_connection=${vdu_connection}
    Log  ${below_info_prefix}vDU reset operation status: ${reset_result['status']}  console=${log_to_console}
    ${time_reset_vdu_start}=  Get Current Date
    Set Test Variable  ${time_reset_vdu_start}
# Check if vDU OAM IP address is unavailable
    ${oam_http_connection}=  Get vDU Oam Http Connection Parameters From Init File
    ${ip_addr}=  Set Variable  ${oam_http_connection["ip_addr"]}
    Ip Address Is Unavailable  ip_addr=${ip_addr}
    Log  ${info_prefix}vDU is unavailable now. Wait for vDU availability ...  console=${log_to_console}
# Check if vDU OAM IP address is available
    Ip Address Is Available  ip_addr=${ip_addr}
    Log  ${below_info_prefix}vDU is available now  console=${log_to_console}
# Check if API connection is established
    Log  ${info_prefix}Waiting for API connection to be established ...  console=${log_to_console}
    Wait Until Keyword Succeeds  30  2
    ...  vDU Get Operational State  vdu_connection=${vdu_connection}
    Log  ${below_info_prefix}API connection established  console=${log_to_console}
    vDU Check BTS Reset Cause Alarm
    ...  activation_timeout=40s
    ...  cancellation_timeout=${cancellation_timer}
    ...  info_pattern=*due to user request*
    ...  vdu_connection=${vdu_connection}
    ...  log_prefix=${info_prefix}
    Log  ${ok_prefix_green}Step 2: Perform vDU reset  console=${log_to_console}

Step 3: Check Site States After vDU Reset
    Log  ${dots_prefix_green}Step 3: Check site state after vDU reset  console=${log_to_console}
# Check F1-C link status
    Log  ${info_prefix}Wait for F1-C link to activate...  console=${log_to_console}
    vDU Wait For Expected F1 Link Status
    ...  f1_link_status_value=available
    ...  timeout=600s
    ...  vdu_connection=${vdu_connection}
    Log  ${below_info_prefix}F1-C link is available  console=${log_to_console}
# Wait until all radio modules are on line
    Wait Until All Radio Modules Are Online
    ...  rmods_count=${vdu_scfc_rmods_count}
    ...  timeout=60s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All radio modules are on line  console=${log_to_console}
# Check if first NR cell up
    vDU Any Cell Wait For Expected States Or Statuses
    ...  cell_id_list=${vdu_scfc_cell_id_list}
    ...  state_status_dict=${cbts_online_cell_state_dict}
    ...  timeout=${VDU_RESET_VDU_CELLS_ONAIR_TIMEOUT}
    ...  time_interval=1s
    ...  vdu_connection=${vdu_connection}
    ${time_first_cell_up}=  Get Current Date
    Log  ${info_prefix}First cell is up  console=${log_to_console}
# Wait until all cells are OnAir
    Wait Until All Cells Are OnAir
    ...  cells_count=${vdu_scfc_nrcells_count}
    ...  time_interval=1s
    ...  timeout=${VDU_RESET_VDU_CELLS_ONAIR_TIMEOUT}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
    ${time_last_cell_up}=  Get Current Date
# Get KPI values
    IF  ${get_kpi}
      ${reset_vdu_kpi_52a}=  Subtract Date From Date  date1=${time_last_cell_up}  date2=${time_reset_vdu_start}
      ${reset_vdu_kpi_52b}=  Subtract Date From Date  date1=${time_first_cell_up}  date2=${time_reset_vdu_start}
      Log  ${info_prefix}KPI values for vdu_${vdu_id}:  console=${log_to_console}
      Log  ${below_info_prefix}KPI 52a: ${reset_vdu_kpi_52a}  console=${log_to_console}
      Log  ${below_info_prefix}KPI 52b: ${reset_vdu_kpi_52b}  console=${log_to_console}
      Set To Dictionary  ${kpi_dict_52a}  vdu_${vdu_id}=${reset_vdu_kpi_52a}
      Set To Dictionary  ${kpi_dict_52b}  vdu_${vdu_id}=${reset_vdu_kpi_52b}
    END
    Log  ${ok_prefix_green}Step 3: Check site state after vDU reset  console=${log_to_console}

Step 4: Postconditions vDU Reset
    Log  ${dots_prefix_green}Step 4: Postconditions vDU reset  console=${log_to_console}
# KPI postconditions
    IF  ${get_kpi}
      Create Kpi Results File
      ...  kpi_name=52a
      ...  kpi_result_file_path=${kpi_result_file_path}
      ...  kpi_dict=${kpi_dict_52a}
      ...  target_kpi_value=${expected_kpi52a_value}
      Create Kpi Results File
      ...  kpi_name=52b
      ...  kpi_result_file_path=${kpi_result_file_path}
      ...  kpi_dict=${kpi_dict_52b}
      ...  target_kpi_value=${expected_kpi52b_value}
    END
# Wait until all radio modules are on line
    Wait Until All Radio Modules Are Online
    ...  rmods_count=${vdu_scfc_rmods_count}
    ...  timeout=30s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All radio modules are on line  console=${log_to_console}
# Wait until all cells are OnAir
    Wait Until All Cells Are OnAir
    ...  cells_count=${vdu_scfc_nrcells_count}
    ...  timeout=30s
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${vdu_scfc_nrcells_count}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
# Check vDU operational state
    vDU Wait For Expected Operational State
    ...  vdu_state_value=onAir
    ...  timeout=30s
    ...  vdu_check=${True}
    ...  lte_vdu_check=${False}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}vDU operational state is onAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 4: Postconditions vDU reset  console=${log_to_console}
