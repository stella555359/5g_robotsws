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
${RMOD_LOCK_UNLOCK_VDU_CELLS_ONAIR_TIMEOUT}=  60s
# Maximum time to wait for complete lock RMOD operation
${RMOD_LOCK_MAX_WAIT_TIME}=    300
# Maximum time to wait for complete unlock RMOD operation
${RMOD_UNLOCK_MAX_WAIT_TIME}=  300
# Allowed test case historical alarms
@{VCU_LOCK_UNLOCK_ALLOWED_HIST_ALARMS}=  faultId=7104, severity=critical

*** Keywords ***
TC__Cloud_SM_Radio_Modules_Lock_Unlock
    [Arguments]  ${vdu_scfc_file_path}  ${cbts_rmods_sn}=@{EMPTY}  ${vdu_connection}=default  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Test case locks and unlocks radio module based on rmod serial number.
    ...  If the list of the radio modules serial numbers is empty then all radio modules are locked/unlocked.
    ...
    ...  Step 1: CBTS Preconditions Radio Modules Lock Unlock
    ...  a) All radio modules should be on line
    ...  b) All cells should be OnAir
    ...  c) vDU operational state should be onAir
    ...  Step 2: CBTS Lock Radio Module
    ...  a) Radio module lock operation is successful
    ...  b) Radio module expected state: administrative_state = Locked
    ...  c) Impacted radio module cells have correct states
    ...  d) Not impacted radio modules are on line
    ...  e) Not impacted cells are OnAir
    ...  Step 3: CBTS Unlock Radio Module
    ...  a) Radio module unlock operation is successful
    ...  b) Radio module expected state: administrative_state = Unlocked
    ...  c) All cells should be OnAir
    ...  Step 4: CBTS Postconditions Radio Modules Lock Unlock
    ...  a) The same values as in Step 1
    ...  No unexpected alarms are visible
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_scfc_file_path     | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cbts_rmods_sn          |  No  | List of radio module serial numbers to locked/unlocked.                    |
    ...  |                        |      | If the list is empty then all radio modules are locked/unlocked.           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Set Test Variable  ${vdu_scfc_file_path}
    Set Test Variable  ${cbts_rmods_sn}
    Set Test Variable  ${vdu_connection}
    Set Test Variable  ${log_to_console}
    Log  ${start_prefix_green}Test Case: CBTS_Radio_Modules_Lock_Unlock  console=${log_to_console}
    Step 1: CBTS Preconditions Radio Modules Lock Unlock
    FOR  ${cbts_locked_rmod_sn}  IN  @{cbts_locked_rmod_sn_list}
      Set Test Variable  ${cbts_locked_rmod_sn}
      Step 2: CBTS Lock Radio Module
      Step 3: CBTS Unlock Radio Module
    END
    Step 4: CBTS Postconditions Radio Modules Lock Unlock
    Log  ${done_prefix_green}Test Case: CBTS_Radio_Modules_Lock_Unlock  console=${log_to_console}
    [Teardown]  Run Keyword And Ignore Error  vDU Rest Logout  vdu_connection=${vdu_connection}

Step 1: CBTS Preconditions Radio Modules Lock Unlock
    Log  ${dots_prefix_green}Step 1: CBTS preconditions radio modules lock unlock  console=${log_to_console}
    Append To List  ${VCU_HISTORICAL_ALLOWED_ALARMS}  @{VCU_LOCK_UNLOCK_ALLOWED_HIST_ALARMS}
    vDU Rest Login  vdu_connection=${vdu_connection}
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
    ${vdu_scfc_rmod_sn_list}=  vDU SCFC Get RMOD Serial Number List  scfc_file_path=${vdu_scfc_file_path}
    ${cbts_rmod_sn_conf_id_dict}=  vDU RMOD Get Serial Numbers And Given Parameters Value
    ...  rmod_param=configuration_id
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${cbts_rmod_sn_conf_id_dict}
    ${vdu_rmod_sn_list}=  Get Dictionary Keys  dictionary=${cbts_rmod_sn_conf_id_dict}
    Sort List  ${vdu_scfc_rmod_sn_list}
    Sort List  ${vdu_rmod_sn_list}
    Lists Should Be Equal  list1=${vdu_scfc_rmod_sn_list}  list2=${vdu_rmod_sn_list}
    ...  msg=SCFC radio module list and actual radio module list should be the same !
    ${cbts_locked_rmod_sn_list}=  Set Variable If  ${cbts_rmods_sn}==@{EMPTY}
    ...  ${vdu_scfc_rmod_sn_list}  ${cbts_rmods_sn}
    Set Test Variable  ${cbts_locked_rmod_sn_list}
    ${cbts_rmod_sn_cells_id_dict}=  vDU RMOD Get Serial Numbers And Given Parameters Value
    ...  rmod_param=cell_ids
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${cbts_rmod_sn_cells_id_dict}
    ${cbts_impacted_cell_state_dict}=  Create Dictionary  availabilityStatus=dependency
    ...  operationalState=disabled  administrativeState=Unlocked  blockingState=Unblocked
    Set Test Variable  ${cbts_impacted_cell_state_dict}
    ${cbts_unimpacted_cell_state_dict}=  Create Dictionary  availabilityStatus=on line
    ...  operationalState=enabled  administrativeState=Unlocked  blockingState=Unblocked
    Set Test Variable  ${cbts_unimpacted_cell_state_dict}
    Log  ${ok_prefix_green}Step 1: CBTS preconditions radio modules lock unlock  console=${log_to_console}

Step 2: CBTS Lock Radio Module
    Log  ${dots_prefix_green}Step 2: CBTS lock radio module (sn: ${cbts_locked_rmod_sn})  console=${log_to_console}
# Lock radio module
    ${cbts_rmod_conf_id}=  Get From Dictionary  dictionary=${cbts_rmod_sn_conf_id_dict}  key=${cbts_locked_rmod_sn}
    ${cbts_rmod_conf_id}=  Convert To String  item=${cbts_rmod_conf_id}
    ${cbts_block_rmods_conf_id_list}=  Create List  ${cbts_rmod_conf_id}
    Set Test Variable  ${cbts_block_rmods_conf_id_list}
    ${lock_result}=  vdu.Lock Rmods
    ...  rmod_id_list=${cbts_block_rmods_conf_id_list}
    ...  vdu_connection=${vdu_connection}
# Wait for radio module lock expected status
    RMOD Lock Wait For Expected Status
    ...  operation_id=${lock_result["id"]}
    ...  expected_status=success
    ...  timeout=${RMOD_LOCK_MAX_WAIT_TIME}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}Lock radio module (sn: ${cbts_locked_rmod_sn}) succeeded  console=${log_to_console}
# Wait for radio module expected state
    RMOD Wait For Expected State
    ...  rmod_sn=${cbts_locked_rmod_sn}
    ...  rmod_state=administrative_state
    ...  rmod_state_value=Locked
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}Radio module (sn: ${cbts_locked_rmod_sn}) is Locked  console=${log_to_console}
# Check radio module impacted cells states
    ${cbts_rmod_impacted_cells_id_list}=  Get From Dictionary  dictionary=${cbts_rmod_sn_cells_id_dict}  key=${cbts_locked_rmod_sn}
    FOR  ${cbts_rmod_impacted_cell_id}  IN  @{cbts_rmod_impacted_cells_id_list}
      Cell Wait For Expected States Or Statuses
      ...  cell_id=${cbts_rmod_impacted_cell_id}
      ...  state_status_dict=${cbts_impacted_cell_state_dict}
      ...  timeout=10s
      ...  vdu_connection=${vdu_connection}
    END
    Log  ${info_prefix}Impacted radio module (sn: ${cbts_locked_rmod_sn}) cells status is OK  console=${log_to_console}
# Check if not impacted radio modules are on line
    Sleep  10s  reason=Waiting time before check no impact on other radio modules
    ${cbts_unlocked_rmod_sn_list}=  Copy List  ${cbts_locked_rmod_sn_list}
    Remove Values From List  ${cbts_unlocked_rmod_sn_list}  ${cbts_locked_rmod_sn}
    FOR  ${cbts_unlocked_rmod_sn}  IN  @{cbts_unlocked_rmod_sn_list}
      RMOD Wait For Online
      ...  rmod_sn=${cbts_unlocked_rmod_sn}
      ...  timeout=30s
      ...  vdu_connection=${vdu_connection}
    END
    Log  ${info_prefix}Not impacted radio modules are on line  console=${log_to_console}
# Check radio modules not impacted cells states
    ${unimpacted_cbts_cell_id_list}=  Copy List  ${vdu_scfc_cell_id_list}
    Remove Values From List  ${unimpacted_cbts_cell_id_list}  @{cbts_rmod_impacted_cells_id_list}
    FOR  ${unimpacted_cbts_cell_id}  IN  @{unimpacted_cbts_cell_id_list}
      Cell Wait For Expected States Or Statuses
      ...  cell_id=${unimpacted_cbts_cell_id}
      ...  state_status_dict=${cbts_unimpacted_cell_state_dict}
      ...  timeout=10s
      ...  vdu_connection=${vdu_connection}
    END
    Log  ${info_prefix}Not impacted cells are OnAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 2: CBTS lock radio module (sn: ${cbts_locked_rmod_sn})  console=${log_to_console}

Step 3: CBTS Unlock Radio Module
    Log  ${dots_prefix_green}Step 3: CBTS unlock radio module (sn: ${cbts_locked_rmod_sn})  console=${log_to_console}
# Unlock radio module
    Log  ${info_prefix}Wait a while for radio module (sn: ${cbts_locked_rmod_sn}) unlock ...  console=${log_to_console}
    Sleep  10s  reason=Waiting time before unlock radio module
    ${unlock_result}=  vdu.Unlock Rmods
    ...  rmod_id_list=${cbts_block_rmods_conf_id_list}
    ...  vdu_connection=${vdu_connection}
# Wait for radio module lock expected status
    RMOD Unlock Wait For Expected Status
    ...  operation_id=${unlock_result["id"]}
    ...  expected_status=success
    ...  timeout=${RMOD_UNLOCK_MAX_WAIT_TIME}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}Unlock radio module (sn: ${cbts_locked_rmod_sn}) succeeded  console=${log_to_console}
# Wait for radio module expected state (administrative_state=Unlocked)
    RMOD Wait For Expected State
    ...  rmod_sn=${cbts_locked_rmod_sn}
    ...  rmod_state=administrative_state
    ...  rmod_state_value=Unlocked
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}Radio module (sn: ${cbts_locked_rmod_sn}) is Unlocked  console=${log_to_console}
# Wait until all cells are OnAir
    Wait Until All Cells Are OnAir
    ...  cells_count=${vdu_scfc_nrcells_count}
    ...  timeout=${RMOD_LOCK_UNLOCK_VDU_CELLS_ONAIR_TIMEOUT}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 3: CBTS unlock radio module (sn: ${cbts_locked_rmod_sn})  console=${log_to_console}

Step 4: CBTS Postconditions Radio Modules Lock Unlock
    Log  ${dots_prefix_green}Step 4: CBTS postconditions radio modules lock unlock  console=${log_to_console}
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
    Log  ${ok_prefix_green}Step 4: CBTS postconditions radio modules lock unlock  console=${log_to_console}
