*** Settings ***
Documentation
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    DateTime
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu

Resource    ../../resources/Robot/vdu_oam_operations.robot
Resource    ../../../resources/Robot/scfc.robot
Resource    ../../resources/Robot/setup_teardown.robot
Resource    ../../resources/Robot/common_resources.robot

*** Variables ***
${CELL_BLOCK_UNBLOCK_VDU_CELLS_ONAIR_TIMEOUT}=  30s
# Maximum waiting time for cell to be blocked
${CELL_BLOCK_MAX_WAIT_TIME}=    200s
# Maximum waiting time for cell to be unblocked
${CELL_UNBLOCK_MAX_WAIT_TIME}=  200s
# Allowed test case historical alarms
@{VDU_BLOCK_UNBLOCK_ALLOWED_HIST_ALARMS}=  faultId=49, severity=critical
@{VCU_BLOCK_UNBLOCK_ALLOWED_HIST_ALARMS}=  faultId=7104, severity=critical

*** Keywords ***
TC__Cloud_SM_Cell_Block_Unblock
    [Arguments]  ${vdu_scfc_file_path}  ${cbts_cells_id_list}=@{EMPTY}  ${get_kpi}=${False}
    ...  ${vdu_connection}=${VDU_CONNECTION_DEFAULT}  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case blocks and unblocks cell based on cell id
    ...  given from scfc file or specified by the cell id list.
    ...  If the list of the cells id is empty then all cells are blocked/unblocked.
    ...
    ...  Step 1: CBTS Preconditions Cell Block Unblock
    ...  a) Wait Until all radio modules are on line
    ...  b) Wait until all cells are OnAir
    ...  c) Check vDU operational state
    ...  Step 2: CBTS Cell Block
    ...  a) Block CBTS cell
    ...  b) Check blocked CBTS cell expected state
    ...  c) Check blocked CBTS cell other states
    ...  d) Check if alarm (fault id=49) is active
    ...  e) Check if not blocked CBTS cells are OnAir
    ...  Step 3: CBTS Cell Unblock
    ...  a) Unblock CBTS cell
    ...  b) Check unblocked CBTS cell expected state
    ...  c) Check unblocked CBTS cell other states
    ...  d) Check if alarm (fault id=49) is inactive
    ...  e) Wait until all cells are OnAir
    ...  f) Get KPI values
    ...  Step 4: CBTS Postconditions Cell Block Unblock
    ...  a) The same values as in Step 1
    ...  No unexpected alarms are visible
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_scfc_file_path     | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cbts_cells_id_list     |  No  | (optional) List of cell id to be blocked/unblocked.                        |
    ...  |                        |      | If the list is empty then all cells are blocked/unblocked.                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_kpi                |  No  | Get kpi17a/kpi17b or not.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Set Test Variable  ${vdu_scfc_file_path}
    Set Test Variable  ${cbts_cells_id_list}
    Set Test Variable  ${get_kpi}
    Set Test Variable  ${vdu_connection}
    Set Test Variable  ${log_to_console}
    Log  ${start_prefix_green}Test Case: CBTS_Cell_Block_Unblock  console=${log_to_console}
    Step 1: CBTS Preconditions Cell Block Unblock
    FOR  ${cbts_blocked_cell_id}  IN  @{cbts_blocked_cells_id_list}
       Set Test Variable  ${cbts_blocked_cell_id}
       Step 2: CBTS Cell Block
       Step 3: CBTS Cell Unblock
    END
    Step 4: CBTS Postconditions Cell Block Unblock
    Log  ${done_prefix_green}Test Case: CBTS_Cell_Block_Unblock  console=${log_to_console}
    [Teardown]  Run Keyword And Ignore Error  vDU Rest Logout  vdu_connection=${vdu_connection}

Step 1: CBTS Preconditions Cell Block Unblock
    Log  ${dots_prefix_green}Step 1: CBTS preconditions cell block unblock  console=${log_to_console}
    Append To List  ${VDU_HISTORICAL_ALLOWED_ALARMS}  @{VDU_BLOCK_UNBLOCK_ALLOWED_HIST_ALARMS}
    Append To List  ${VCU_HISTORICAL_ALLOWED_ALARMS}  @{VCU_BLOCK_UNBLOCK_ALLOWED_HIST_ALARMS}
    vDU Rest Login  vdu_connection=${vdu_connection}
# KPI preconditions
    IF  ${get_kpi}
      ${kpi_dict_17a}=  Create Dictionary
      Set Test Variable  ${kpi_dict_17a}
      ${kpi_dict_17b}=  Create Dictionary
      Set Test Variable  ${kpi_dict_17b}
      Set Test Variable  ${kpi_result_file_path}  ${TC_RUN_LOGS_DIR_PATH}/KPI_results.txt
    END
# Wait Until all radio modules are on line
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
    ${vdu_cells_id_dist_name_dict}=  vDU Cells Get Ids And Given Parameters Value
    ...  cell_param=dist_names
    ...  cell_sub_param=config
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${vdu_cells_id_dist_name_dict}
    ${vdu_cells_id_identity_dict}=  vDU Cells Get Identity And Id
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${vdu_cells_id_identity_dict}
    ${vdu_scfc_nrcell_id_list}=  vDU SCFC Get NRCELL Id List  scfc_file_path=${vdu_scfc_file_path}
    Set Test Variable  ${vdu_scfc_nrcell_id_list}
    ${cbts_blocked_cells_id_list}=  Set Variable If  ${cbts_cells_id_list}==@{EMPTY}
    ...  ${vdu_scfc_nrcell_id_list}  ${cbts_cells_id_list}
    Set Test Variable  ${cbts_blocked_cells_id_list}
    ${cbts_blocked_cell_state_dict}=  Create Dictionary  availabilityStatus=off line
    ...  operationalState=disabled  administrativeState=Unlocked  blockingState=Blocked
    Set Test Variable  ${cbts_blocked_cell_state_dict}
    ${cbts_unblocked_cell_state_dict}=  Create Dictionary  availabilityStatus=on line
    ...  operationalState=enabled  administrativeState=Unlocked  blockingState=Unblocked
    Set Test Variable  ${cbts_unblocked_cell_state_dict}
    Log  ${ok_prefix_green}Step 1: CBTS preconditions cell block unblock  console=${log_to_console}

Step 2: CBTS Cell Block
    Log  ${dots_prefix_green}Step 2: CBTS cell (NRCELL-${cbts_blocked_cell_id}) block  console=${log_to_console}
# Block CBTS cell
    ${time_vdu_block_cell_start}=  Get Current Date
    vDU Block Cell And Check
    ...  cell_id=${cbts_blocked_cell_id}
    ...  timeout=${CELL_BLOCK_MAX_WAIT_TIME}
    ...  time_interval=1s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}Block cell (NR cell identity: ${vdu_cells_id_identity_dict['${cbts_blocked_cell_id}']}) operation succeeded
    ...  console=${log_to_console}
# Check blocked CBTS cell expected state
    Cell Wait For Expected State
    ...  cell_id=${cbts_blocked_cell_id}
    ...  cell_state=blocking_state
    ...  cell_state_value=Blocked
    ...  timeout=${CELL_BLOCK_MAX_WAIT_TIME}
    ...  vdu_connection=${vdu_connection}
    ${time_vdu_block_cell_end}=  Get Current Date
    Log  ${info_prefix}Cell (NR cell identity: ${vdu_cells_id_identity_dict['${cbts_blocked_cell_id}']}) is blocked
    ...  console=${log_to_console}
# Check blocked CBTS cell other states
    Cell Wait For Expected States Or Statuses
    ...  cell_id=${cbts_blocked_cell_id}
    ...  state_status_dict=${cbts_blocked_cell_state_dict}
    ...  timeout=${CELL_BLOCK_MAX_WAIT_TIME}
    ...  time_interval=5s
    ...  vdu_connection=${vdu_connection}
# Check if alarm (fault id=49) is active
    ${alarm_severity_list}=  Create List  Critical
    Set Test Variable  ${alarm_severity_list}
    ${cbts_blocked_cell_config_dist_name}=  Get From Dictionary
    ...  dictionary=${vdu_cells_id_dist_name_dict}  key=${cbts_blocked_cell_id}
    ${alarming_object_list}=  Create List  ${cbts_blocked_cell_config_dist_name}
    Set Test Variable  ${alarming_object_list}
    vDU Assert Alarm Active
    ...  fault_id=49
    ...  alarming_object_list=${alarming_object_list}
    ...  alarm_severity_list=${alarm_severity_list}
    ...  timeout=30s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}Alarm (faultId:49) on cell (NR cell identity: ${vdu_cells_id_identity_dict['${cbts_blocked_cell_id}']}) is active
    ...  console=${log_to_console}
# Check if not blocked CBTS cells are OnAir
    Sleep  5s  reason=Waiting time before check no impact on other cells
    ${unblocked_cell_id_list}=  Copy List  ${vdu_scfc_nrcell_id_list}
    Remove Values From List  ${unblocked_cell_id_list}  ${cbts_blocked_cell_id}
    FOR  ${unblocked_cell_id}  IN  @{unblocked_cell_id_list}
      Cell Wait For Expected States Or Statuses
      ...  cell_id=${unblocked_cell_id}
      ...  state_status_dict=${cbts_unblocked_cell_state_dict}
      ...  timeout=10s
      ...  vdu_connection=${vdu_connection}
    END
    Log  ${info_prefix}Not blocked cells are OnAir  console=${log_to_console}
    ${vdu_cell_kpi_17a}=  Subtract Date From Date  date1=${time_vdu_block_cell_end}  date2=${time_vdu_block_cell_start}
    Set Test Variable  ${vdu_cell_kpi_17a}
    Log  ${ok_prefix_green}Step 2: CBTS cell (NRCELL-${cbts_blocked_cell_id}) block  console=${log_to_console}

Step 3: CBTS Cell Unblock
    Log  ${dots_prefix_green}Step 3: CBTS cell (NRCELL-${cbts_blocked_cell_id}) unblock  console=${log_to_console}
# Unblock CBTS cell
    Log  ${info_prefix}Wait a while for cell unblock ...  console=${log_to_console}
    Sleep  5s  reason=Waiting time before unlock cell
    ${time_vdu_unblock_cell_start}=  Get Current Date
    vDU Unblock Cell And Check
    ...  cell_id=${cbts_blocked_cell_id}
    ...  timeout=${CELL_UNBLOCK_MAX_WAIT_TIME}
    ...  time_interval=1s
    ...  vdu_connection=${vdu_connection}
# Check unblocked CBTS cell expected state
    Cell Wait For Expected State
    ...  cell_id=${cbts_blocked_cell_id}
    ...  cell_state=blocking_state
    ...  cell_state_value=Unblocked
    ...  timeout=${CELL_UNBLOCK_MAX_WAIT_TIME}
    ...  time_interval=1s
    ...  vdu_connection=${vdu_connection}
    ${time_vdu_unblock_cell_end}=  Get Current Date
    Log  ${info_prefix}Unblock cell (NR cell identity: ${vdu_cells_id_identity_dict['${cbts_blocked_cell_id}']}) operation succeeded
    ...  console=${log_to_console}
# Check unblocked CBTS cell other states
    Cell Wait For Expected States Or Statuses
    ...  cell_id=${cbts_blocked_cell_id}
    ...  state_status_dict=${cbts_unblocked_cell_state_dict}
    ...  timeout=${CELL_UNBLOCK_MAX_WAIT_TIME}
    ...  time_interval=5s
    ...  vdu_connection=${vdu_connection}
# Check if alarm (fault id=49) is inactive
    vDU Assert Alarm Inactive
    ...  fault_id=49
    ...  alarming_object_list=${alarming_object_list}
    ...  alarm_severity_list=${alarm_severity_list}
    ...  timeout=30s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}Alarm (faultId:49) on cell (NR cell identity: ${vdu_cells_id_identity_dict['${cbts_blocked_cell_id}']}) is inactive
    ...  console=${log_to_console}
# Wait until all cells are OnAir
    Wait Until All Cells Are OnAir
    ...  cells_count=${vdu_scfc_nrcells_count}
    ...  timeout=${CELL_BLOCK_UNBLOCK_VDU_CELLS_ONAIR_TIMEOUT}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
# Get KPI values
    IF  ${get_kpi}
      ${vdu_cell_kpi_17b}=  Subtract Date From Date  date1=${time_vdu_unblock_cell_end}  date2=${time_vdu_unblock_cell_start}
      Log  ${info_prefix}KPI values for cell (NR cell identity: ${vdu_cells_id_identity_dict['${cbts_blocked_cell_id}']}):
      ...  console=${log_to_console}
      Log  ${below_info_prefix}KPI 17a: ${vdu_cell_kpi_17a}  console=${log_to_console}
      Log  ${below_info_prefix}KPI 17b: ${vdu_cell_kpi_17b}  console=${log_to_console}
      Set To Dictionary  ${kpi_dict_17a}  ${vdu_cells_id_identity_dict['${cbts_blocked_cell_id}']}=${vdu_cell_kpi_17a}
      Set To Dictionary  ${kpi_dict_17b}  ${vdu_cells_id_identity_dict['${cbts_blocked_cell_id}']}=${vdu_cell_kpi_17b}
    END
    Log  ${ok_prefix_green}Step 3: CBTS cell (NRCELL-${cbts_blocked_cell_id}) unlock  console=${log_to_console}

Step 4: CBTS Postconditions Cell Block Unblock
    Log  ${dots_prefix_green}Step 4: CBTS postconditions cell block unblock  console=${log_to_console}
# KPI postconditions
    IF  ${get_kpi}
      Create Kpi Results File
      ...  kpi_name=17a
      ...  kpi_result_file_path=${kpi_result_file_path}
      ...  kpi_dict=${kpi_dict_17a}
      ...  target_kpi_value=20
      Create Kpi Results File
      ...  kpi_name=17b
      ...  kpi_result_file_path=${kpi_result_file_path}
      ...  kpi_dict=${kpi_dict_17b}
      ...  target_kpi_value=20
    END
# Wait Until all radio modules are on line
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
    Log  ${ok_prefix_green}Step 4: CBTS postconditions cell block unblock  console=${log_to_console}
