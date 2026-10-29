*** Settings ***
Documentation
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu

Resource    ../../resources/Robot/vdu_oam_operations.robot
Resource    ../../../resources/Robot/scfc.robot
Resource    ../../resources/Robot/setup_teardown.robot

*** Variables ***
# Maximum time to wait for complete reset RMOD operation
${RMOD_RESET_MAX_WAIT_TIME}=    300s
# Allowed test case historical alarms
@{VCU_RMOD_RESET_ALLOWED_HIST_ALARMS}=  faultId=7104, severity=critical

*** Keywords ***
TC__Cloud_SM_Radio_Modules_Reset
    [Arguments]  ${vdu_scfc_file_path}  ${cbts_rmod_sn_list}=@{EMPTY}   ${cbts_rmod_sn_count}=0
    ...  ${get_kpi}=${False}  ${vdu_connection}=default  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Test case performs a CBTS radio module reset.
    ...
    ...  Step 1: CBTS Preconditions Radio Modules Reset
    ...  a) All radio modules should be on line
    ...  b) All cells should be OnAir
    ...  c) vDU operational state should be onAir
    ...  Step 2: CBTS Radio Module Reset
    ...  a) CBTS radio module reset
    ...  b) Check reset CBTS radio module first NR cells state
    ...  c) Check until reset CBTS radio module is off line
    ...  d) Check reset CBTS radio module NR cells states
    ...  e) Check CBTS radio module reset operation status
    ...  Step 3: CBTS Radio Module Reset Check States
    ...  a) Check if not reset CBTS radio modules are on line
    ...  b) Check not reset CBTS radio modules NR cells states
    ...  c) Check if reset CBTS radio module is on line
    ...  d) Check if all CBTS radio modules are on line
    ...  e) Check if all CBTS cells are OnAir
    ...  f) Get KPI values
    ...  Step 4: CBTS Postconditions Radio Modules Reset
    ...  a) The same values as in Step 1
    ...  No unexpected alarms are visible
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_scfc_file_path     |  Yes | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cbts_rmod_sn_list      |      | List of serial number of the tested radio modules.                         |
    ...  |                        |  No  | @{EMPTY} value means that no list was given,                               |
    ...  |                        |      | so all radio modules defined in the SCFC file will be used.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cbts_rmod_sn_count     |  No  | Number of randomly selected radio modules serial numbers based on          |
    ...  |                        |      | the list obtained from the SCFC file.                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_kpi                |  No  | Get kpi51a or not.                                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Set Test Variable  ${vdu_scfc_file_path}
    Set Test Variable  ${cbts_rmod_sn_list}
    Set Test Variable  ${cbts_rmod_sn_count}
    Set Test Variable  ${get_kpi}
    Set Test Variable  ${vdu_connection}
    Set Test Variable  ${log_to_console}
    Log  ${start_prefix_green}Test Case: CBTS_Radio_Modules_Reset  console=${log_to_console}
    Step 1: CBTS Preconditions Radio Modules Reset
    FOR  ${cbts_reset_rmod_sn}  IN  @{cbts_reset_rmod_sn_list}
      Set Test Variable  ${cbts_reset_rmod_sn}
      Step 2: CBTS Radio Module Reset
      Step 3: CBTS Radio Module Reset Check States
    END
    Step 4: CBTS Postconditions Radio Modules Reset
    Log  ${done_prefix_green}Test Case: CBTS_Radio_Modules_Reset  console=${log_to_console}
    [Teardown]  Run Keyword And Ignore Error  vDU Rest Logout  vdu_connection=${vdu_connection}

Step 1: CBTS Preconditions Radio Modules Reset
    Log  ${dots_prefix_green}Step 1: CBTS preconditions radio modules reset console=${log_to_console}
    Append To List  ${VCU_HISTORICAL_ALLOWED_ALARMS}  @{VCU_RMOD_RESET_ALLOWED_HIST_ALARMS}
    vDU Rest Login  vdu_connection=${vdu_connection}
# KPI preconditions
    IF  ${get_kpi}
      ${kpi_dict_51a}=  Create Dictionary
      Set Test Variable  ${kpi_dict_51a}
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
    Log  ${ok_prefix_green}All cells are OnAir  console=${log_to_console}
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
    ${vdu_scfc_rmod_sn_list}=  vDU SCFC Get RMOD Serial Number List  scfc_file_path=${vdu_scfc_file_path}
    ${cbts_rmod_sn_cells_id_dict}=  vDU RMOD Get Serial Numbers And Given Parameters Value
    ...  rmod_param=cell_ids
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${cbts_rmod_sn_cells_id_dict}
    ${vdu_scfc_rmod_sn_list}=  vDU SCFC Get RMOD Serial Number List  scfc_file_path=${vdu_scfc_file_path}
# Set reset radio module list
    ${cbts_reset_rmod_sn_list}=  Get Radio Modules Serial Numbers List  scfc_file_path=${vdu_scfc_file_path}
    ...  rmod_sn_list=${cbts_rmod_sn_list}  rmod_sn_count=${cbts_rmod_sn_count}
    Set Test Variable  ${cbts_reset_rmod_sn_list}
# Set cells states
    ${cbts_impacted_cell_state_dict}=  Create Dictionary  availabilityStatus=failed
    ...  operationalState=disabled  administrativeState=Unlocked  blockingState=Unblocked
    Set Test Variable  ${cbts_impacted_cell_state_dict}
    ${cbts_unimpacted_cell_state_dict}=  Create Dictionary  availabilityStatus=on line
    ...  operationalState=enabled  administrativeState=Unlocked  blockingState=Unblocked
    Set Test Variable  ${cbts_unimpacted_cell_state_dict}
    Log  ${ok_prefix_green}Step 1: CBTS preconditions radio modules reset  console=${log_to_console}

Step 2: CBTS Radio Module Reset
    Log  ${dots_prefix_green}Step 2: CBTS radio module reset  console=${log_to_console}
    Log  ${info_prefix}Radio module (sn: ${cbts_reset_rmod_sn}) has been reset  console=${log_to_console}
    ${cbts_reset_rmods_id_dict}=  vDU RMOD Get Serial Numbers And Given Parameters Value  rmod_param=id
    ${cbts_reset_rmod_id}=  Get From Dictionary  dictionary=${cbts_reset_rmods_id_dict}  key=${cbts_reset_rmod_sn}
    ${cbts_reset_rmod_id_list}=  Create List  ${cbts_reset_rmod_id}
# CBTS radio module reset
    ${cbts_rmod_impacted_cells_id_list}=  Get From Dictionary  dictionary=${cbts_rmod_sn_cells_id_dict}  key=${cbts_reset_rmod_sn}
    ${reset_result}=  vdu.Reset Rmods
    ...  rmods_list=${cbts_reset_rmod_id_list}
    ...  timeout=30s
    ...  vdu_connection=${vdu_connection}
# Check reset CBTS radio module first NR cells state
    vDU Any Cell Wait For Expected States Or Statuses
    ...  cell_id_list=${cbts_rmod_impacted_cells_id_list}
    ...  state_status_dict=${cbts_impacted_cell_state_dict}
    ...  timeout=60s
    ...  time_interval=1s
    ...  vdu_connection=${vdu_connection}
    ${time_vdu_rmod_reset_start}=  Get Current Date
    Set Test Variable  ${time_vdu_rmod_reset_start}
# Check until reset CBTS radio module is off line
    RMOD Wait For Offline
    ...  rmod_sn=${cbts_reset_rmod_sn}
    ...  timeout=60s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}Radio module (sn: ${cbts_reset_rmod_sn}) is off line now  console=${log_to_console}
# Check reset CBTS radio module NR cells states
    FOR  ${cbts_rmod_impacted_cell_id}  IN  @{cbts_rmod_impacted_cells_id_list}
      Cell Wait For Expected States Or Statuses
      ...  cell_id=${cbts_rmod_impacted_cell_id}
      ...  state_status_dict=${cbts_impacted_cell_state_dict}
      ...  timeout=10s
      ...  vdu_connection=${vdu_connection}
    END
    Log  ${info_prefix}Reset radio module (sn: ${cbts_reset_rmod_sn}) cells status is OK  console=${log_to_console}
# Check CBTS radio module reset operation status
    Log  ${info_prefix}Wait a while for the radio module (sn: ${cbts_reset_rmod_sn}) to reset ...  console=${log_to_console}
    RMOD Reset Wait For Expected Status
    ...  operation_id=${reset_result["operation_id"]}
    ...  expected_status=success
    ...  timeout=${RMOD_RESET_MAX_WAIT_TIME}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}Radio module reset operation (sn: ${cbts_reset_rmod_sn}) succeeded  console=${log_to_console}
    Log  ${ok_prefix_green}Step 2: CBTS radio module reset  console=${log_to_console}

Step 3: CBTS Radio Module Reset Check States
    Log  ${dots_prefix_green}Step 3: CBTS radio module reset check states  console=${log_to_console}
# Check if not reset CBTS radio modules are on line
    ${cbts_online_rmod_sn_list}=  Copy List  ${cbts_reset_rmod_sn_list}
    Remove Values From List  ${cbts_online_rmod_sn_list}  ${cbts_reset_rmod_sn}
    FOR  ${cbts_online_rmod_sn}  IN  @{cbts_online_rmod_sn_list}
      RMOD Wait For Online
      ...  rmod_sn=${cbts_online_rmod_sn}
      ...  timeout=10s
      ...  vdu_connection=${vdu_connection}
    END
    Log  ${info_prefix}Not reset radio modules are on line  console=${log_to_console}
# Check not reset CBTS radio modules NR cells states
    ${cbts_rmod_impacted_cells_id_list}=  Get From Dictionary  dictionary=${cbts_rmod_sn_cells_id_dict}  key=${cbts_reset_rmod_sn}
    ${unimpacted_cbts_cell_id_list}=  Copy List  ${vdu_scfc_cell_id_list}
    Remove Values From List  ${unimpacted_cbts_cell_id_list}  @{cbts_rmod_impacted_cells_id_list}
    FOR  ${unimpacted_cbts_cell_id}  IN  @{unimpacted_cbts_cell_id_list}
      Cell Wait For Expected States Or Statuses
      ...  cell_id=${unimpacted_cbts_cell_id}
      ...  state_status_dict=${cbts_unimpacted_cell_state_dict}
      ...  timeout=10s
      ...  vdu_connection=${vdu_connection}
    END
    Log  ${info_prefix}Not reset radio modules cells are OnAir  console=${log_to_console}
# Check if reset CBTS radio module is on line
    RMOD Wait For Online
    ...  rmod_sn=${cbts_reset_rmod_sn}
    ...  timeout=300s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}Reset radio module (serial number: ${cbts_reset_rmod_sn}) is online  console=${log_to_console}
# Check if reset CBTS radio module NR cells are OnAir
    FOR  ${cbts_rmod_impacted_cells_id}  IN  @{cbts_rmod_impacted_cells_id_list}
      Cell Wait For Expected States Or Statuses
      ...  cell_id=${cbts_rmod_impacted_cells_id}
      ...  state_status_dict=${cbts_unimpacted_cell_state_dict}
      ...  timeout=60s
      ...  time_interval=1s
      ...  vdu_connection=${vdu_connection}
    END
    Log  ${info_prefix}Reset radio modules cells are OnAir  console=${log_to_console}
    ${time_vdu_rmod_reset_end}=  Get Current Date
# Check if all CBTS radio modules are on line
    Wait Until All Radio Modules Are Online
    ...  rmods_count=${vdu_scfc_rmods_count}
    ...  timeout=30s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All radio modules are on line  console=${log_to_console}
# Check if all CBTS cells are OnAir
    Wait Until All Cells Are OnAir
    ...  cells_count=${vdu_scfc_nrcells_count}
    ...  timeout=30s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
# Get KPI values
    IF  ${get_kpi}
      ${vdu_rmod_reset_kpi_51a}=  Subtract Date From Date  date1=${time_vdu_rmod_reset_end}  date2=${time_vdu_rmod_reset_start}
      Log  ${info_prefix}KPI values for radio module (serial number: ${cbts_reset_rmod_sn}):  console=${log_to_console}
      Log  ${below_info_prefix}KPI 51a: ${vdu_rmod_reset_kpi_51a}  console=${log_to_console}
      Set To Dictionary  ${kpi_dict_51a}  ${cbts_reset_rmod_sn}=${vdu_rmod_reset_kpi_51a}
    END
    Log  ${ok_prefix_green}Step 3: CBTS radio module reset check states  console=${log_to_console}

Step 4: CBTS Postconditions Radio Modules Reset
    Log  ${dots_prefix_green}Step 4: CBTS postconditions radio modules reset  console=${log_to_console}
# KPI postconditions
    IF  ${get_kpi}
      Create Kpi Results File
      ...  kpi_name=51a
      ...  kpi_result_file_path=${kpi_result_file_path}
      ...  kpi_dict=${kpi_dict_51a}
      ...  target_kpi_value=240
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
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
# Check vDU operational state
    vDU Wait For Expected Operational State
    ...  vdu_state_value=onAir
    ...  timeout=30s
    ...  vdu_check=${True}
    ...  lte_vdu_check=${False}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}vDU operational state is onAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 4: CBTS postconditions radio modules reset  console=${log_to_console}
