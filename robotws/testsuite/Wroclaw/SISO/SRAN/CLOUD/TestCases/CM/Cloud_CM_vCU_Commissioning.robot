*** Settings ***
Documentation
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    taf.gnb.oam.coam.cu.interface.cu      WITH NAME    cu
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu

Resource    ../../resources/Robot/vdu_oam_operations.robot
Resource    ../../resources/Robot/vcu_oam_operations.robot
Resource    ../../../resources/Robot/scfc.robot
Resource    ../../resources/variables.robot

*** Variables ***
@{VDU_COMMISSIONING_VCU_ALLOWED_HIST_ALARMS}=  faultId=7504, severity=critical
@{VCU_COMMISSIONING_VCU_ALLOWED_HIST_ALARMS}=  faultId=7104, severity=critical
...                                            faultId=4592, severity=warning
...                                            faultId=4592, severity=minor

*** Keywords ***
TC__Cloud_CM_vCU_Commissioning
    [Arguments]  ${vdu_scfc_file_path}  ${vcu_scfc_file_path}  ${vdu_connection}=default
    ...  ${vcu_connection}=default  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case performs vCU commissioning.
    ...
    ...  Step 1: Preconditions vCU Commissioning
    ...  a) All vDU radio modules should be on line
    ...  b) All vDU cells should be OnAir
    ...  c) vDU operational state should be onAir
    ...  d) All vCU cells should be OnAir
    ...  e) Wait for expected vCU operational state
    ...     vCU expected states: operational_state = enabled
    ...  f) Wait for expected vDUs administrative states
    ...     vDU expected states: administrative_state = unlocked
    ...  Step 2: Perform vCU Commissioning
    ...  a) vCU activate plan operation is successfully
    ...  Step 3: Check Site States After vCU Commissioning
    ...  a) Wait for expected vCU operational state
    ...     vCU expected states: operational_state = enabled
    ...  b) Wait for expected vDUs administrative states
    ...     vDU expected states: administrative_state = unlocked
    ...  c) Check vCU VNFCs states
    ...     vCU VHFCs expected states: operational_state = enabled
    ...                                availability_status = on line
    ...  d) Wait for expected NG links activate status
    ...  e) Wait for expected F1 links available status
    ...  f) Wait until all vCU cells are OnAir
    ...  Step 4: Postconditions vCU Commissioning
    ...  a) All vDU radio modules should be on line
    ...  b) All vDU cells should be OnAir
    ...  c) vDU operational state should be onAir
    ...  No unexpected alarm is visible
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_scfc_file_path     | Yes  | Path to the vCU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vcu_scfc_file_path     | Yes  | Path to the vCU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vcu_connection         |  No  | vCU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Set Test Variable  ${vdu_scfc_file_path}
    Set Test Variable  ${vcu_scfc_file_path}
    Set Test Variable  ${vdu_connection}
    Set Test Variable  ${vcu_connection}
    Set Test Variable  ${log_to_console}
    Log  ${start_prefix_green}Test Case: vCU_Commissioning  console=${log_to_console}
    Step 1: Preconditions vCU Commissioning
    Step 2: Perform vCU Commissioning
    Step 3: Check Site States After vCU Commissioning
    Step 4: Postconditions vCU Commissioning
    Log  ${done_prefix_green}Test Case: vCU_Commissioning  console=${log_to_console}
    [Teardown]  Run Keywords  Run Keyword And Ignore Error
    ...  vCU Rest Logout  vcu_connection=${vcu_connection}
    ...  AND  Run Keyword And Ignore Error
    ...  vDU Rest Logout  vdu_connection=${vdu_connection}

Step 1: Preconditions vCU Commissioning
    Log  ${dots_prefix_green}Step 1: Preconditions vCU commissioning  console=${log_to_console}
    vCU Rest Login  vcu_connection=${vcu_connection}
    vDU Rest Login  vdu_connection=${vdu_connection}
    Append To List  ${VDU_HISTORICAL_ALLOWED_ALARMS}  @{VDU_COMMISSIONING_VCU_ALLOWED_HIST_ALARMS}
    Append To List  ${VCU_HISTORICAL_ALLOWED_ALARMS}  @{VCU_COMMISSIONING_VCU_ALLOWED_HIST_ALARMS}
# Wait until all vDU radio modules are on line
    ${vdu_scfc_rmods_count}=  vDU SCFC Get RMODs Count
    ...  scfc_file_path=${vdu_scfc_file_path}
    Set Test Variable  ${vdu_scfc_rmods_count}
    Wait Until All Radio Modules Are Online
    ...  rmods_count=${vdu_scfc_rmods_count}
    ...  timeout=30s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All vDU radio modules are on line  console=${log_to_console}
# Wait until all vDU cells are OnAir
    ${vdu_scfc_nrcells_count}=  vDU SCFC Get NRCELL Count
    ...  scfc_file_path=${vdu_scfc_file_path}
    Set Test Variable  ${vdu_scfc_nrcells_count}
    Wait Until All Cells Are OnAir
    ...  cells_count=${vdu_scfc_nrcells_count}
    ...  timeout=30s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All vDU cells are OnAir  console=${log_to_console}
# Check vDU operational state
    vDU Wait For Expected Operational State
    ...  vdu_state_value=onAir
    ...  timeout=30s
    ...  vdu_check=${True}
    ...  lte_vdu_check=${False}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}vDU operational state is onAir  console=${log_to_console}
    ${vcu_cells_count}=  vCU SCFC Get NRCELL Count  scfc_file_path=${vcu_scfc_file_path}
    Set Test Variable  ${vcu_cells_count}
# Wait until all vCU cells are OnAir
    vCU Wait Until All Cells Are OnAir
    ...  cells_count=${vcu_cells_count}
    ...  timeout=30s
    ...  vcu_connection=${vcu_connection}
    Log  ${info_prefix}All vCU cells are OnAir  console=${log_to_console}
# Wait for expected vCU enabled operational state
    vCU Wait For Expected Operational State
    ...  vcu_state_value=enabled
    ...  timeout=30s
    ...  vcu_connection=${vcu_connection}
    Log  ${info_prefix}vCU operational state is enabled  console=${log_to_console}
# Wait for expected vDUs unlocked administrative states
    vCU Wait For Expected vDUs Administrative States
    ...  vdu_state_value=unlocked
    ...  timeout=30s
    ...  vcu_connection=${vcu_connection}
    Log  ${info_prefix}vDU administrative state is unlocked  console=${log_to_console}
    Log  ${ok_prefix_green}Step 1: Preconditions vCU commissioning  console=${log_to_console}

Step 2: Perform vCU Commissioning
    Log  ${dots_prefix_green}Step 2: Perform vCU commissioning  console=${log_to_console}
# Perform Commissioning
    Log  ${info_prefix}vCU commissioning is being performed. Please wait ...  console=${log_to_console}
    ${commissioning_result}=  cu.Perform Commissioning
    ...  scf_file=${vcu_scfc_file_path}
    ...  timeout=${ACTIVATE_PLAN_TIMEOUT}
    ...  wait_for_completion=${True}
    ...  should_activate=${True}
    ...  connection=${vcu_connection}
    Log  ${below_info_prefix}vCU commissioning activation has been completed successfully  console=${log_to_console}
    Log  ${below_info_prefix}vCU commissioning operation status: ${commissioning_result['status']}  console=${log_to_console}
    Log  ${ok_prefix_green}Step 2: Perform vCU commissioning  console=${log_to_console}

Step 3: Check Site States After vCU Commissioning
    Log  ${dots_prefix_green}Step 3: Check site states after vCU commissioning  console=${log_to_console}
# Wait for expected vCU operational state
    vCU Wait For Expected Operational State
    ...  vcu_state_value=enabled
    ...  timeout=180s
    ...  vcu_connection=${vcu_connection}
    Log  ${info_prefix}vCU operational state is enabled  console=${log_to_console}
# Wait for expected vDUs administrative states
    vCU Wait For Expected vDUs Administrative States
    ...  vdu_state_value=unlocked
    ...  timeout=30s
    ...  vcu_connection=${vcu_connection}
    Log  ${info_prefix}vDU administrative state is unlocked  console=${log_to_console}
# Check vCU VNFCs states
    vCU Wait For Expected Vnfcs States
    ...  vcu_vnfcs_availability_status=on line
    ...  vcu_vnfcs_operational_state=enabled
    ...  timeout=30s
    ...  vcu_connection=${vcu_connection}
    Log  ${info_prefix}All VHFCs states are enabled  console=${log_to_console}
# Wait for expected NG links activate status
    Log  ${info_prefix}Wait for all NG links to be activated ...  console=${log_to_console}
    vCU Wait For Expected Ng Links Status
    ...  vcu_ng_link_status=Active
    ...  timeout=600s
    ...  vcu_connection=${vcu_connection}
    Log  ${below_info_prefix}All NG links are active  console=${log_to_console}
# Wait for expected F1 links available status
    vCU Wait For Expected F1 Links Status
    ...  vcu_f1_link_status=available
    ...  timeout=30s
    ...  vcu_connection=${vcu_connection}
    Log  ${info_prefix}All F1 links are available  console=${log_to_console}
# Wait until all vCU cells are OnAir
    vCU Wait Until All Cells Are OnAir
    ...  cells_count=${vcu_cells_count}
    ...  timeout=60s
    ...  vcu_connection=${vcu_connection}
    Log  ${info_prefix}All vCU cells are OnAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 3: Check site states after vCU commissioning  console=${log_to_console}

Step 4: Postconditions vCU Commissioning
    Log  ${dots_prefix_green}Step 4: Postconditions vCU commissioning  console=${log_to_console}
# Wait until all radio modules are on line
    Wait Until All Radio Modules Are Online
    ...  rmods_count=${vdu_scfc_rmods_count}
    ...  timeout=30s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All vDU radio modules are on line  console=${log_to_console}
# Wait until all cells are OnAir
    Wait Until All Cells Are OnAir
    ...  cells_count=${vdu_scfc_nrcells_count}
    ...  timeout=30s
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${vdu_scfc_nrcells_count}
    Log  ${info_prefix}All vDU cells are OnAir  console=${log_to_console}
# Check vDU operational state
    vDU Wait For Expected Operational State
    ...  vdu_state_value=onAir
    ...  timeout=30s
    ...  vdu_check=${True}
    ...  lte_vdu_check=${False}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}vDU operational state is onAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 4: Postconditions vCU commissioning  console=${log_to_console}
