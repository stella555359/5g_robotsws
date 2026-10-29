*** Settings ***
Documentation  vDU commissioning
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu

Resource    ../../resources/Robot/vdu_oam_operations.robot
Resource    ../../resources/Robot/setup_teardown.robot
Resource    ../../../resources/Robot/scfc.robot
Resource    ../../resources/variables.robot

*** Variables ***
${VDU_COMMISSIONING_VDU_CELLS_ONAIR_TIMEOUT}=  60s
@{VDU_COMMISSIONING_VDU_ALLOWED_HIST_ALARMS}=  faultId=4592, severity=warning
...                                            faultId=4592, severity=minor
@{VCU_COMMISSIONING_VDU_ALLOWED_HIST_ALARMS}=  faultId=7104, severity=critical

*** Keywords ***
TC__Cloud_CM_vDU_Commissioning
    [Arguments]  ${scfc_file_path}  ${vdu_connection}=default  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Test case performs vDU commissioning.
    ...
    ...  Step 1: Preconditions vDU Commissioning
    ...  a) All radio modules should be on line
    ...  b) All cells should be OnAir
    ...  c) vDU operational state should be onAir
    ...  Step 2: Perform vDU Commissioning
    ...  a) vDU activate plan operation is successful
    ...  b) vDU check BTS Reset Cause alarm
    ...  Step 3: Check Site States After vDU Commissioning
    ...  a) F1-C expected link status: available
    ...  b) Wait until all radio modules are on line
    ...  c) Wait until all cells are OnAir
    ...  Step 4: Postconditions vDU Commissioning
    ...  The same values as in Step 1
    ...  No unexpected alarm is visible
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Set Test Variable  ${scfc_file_path}
    Set Test Variable  ${vdu_connection}
    Set Test Variable  ${log_to_console}
    Log  ${start_prefix_green}Test Case: vDU_Commissioning  console=${log_to_console}
    Step 1: Preconditions vDU Commissioning
    Step 2: Perform vDU Commissioning
    Step 3: Check Site States After vDU Commissioning
    Step 4: Postconditions vDU Commissioning
    Log  ${done_prefix_green}Test Case: vDU_Commissioning  console=${log_to_console}
    [Teardown]  Run Keyword And Ignore Error  vDU Rest Logout  vdu_connection=${vdu_connection}

Step 1: Preconditions vDU Commissioning
    Log  ${dots_prefix_green}Step 1: Preconditions vDU commissioning  console=${log_to_console}
    Append To List  ${VDU_HISTORICAL_ALLOWED_ALARMS}  @{VDU_COMMISSIONING_VDU_ALLOWED_HIST_ALARMS}
    Append To List  ${VCU_HISTORICAL_ALLOWED_ALARMS}  @{VCU_COMMISSIONING_VDU_ALLOWED_HIST_ALARMS}
    vDU Rest Login  vdu_connection=${vdu_connection}
# Wait until all radio modules are on line
    ${vdu_scfc_rmods_count}=  vDU SCFC Get RMODs Count
    ...  scfc_file_path=${scfc_file_path}
    Set Test Variable  ${vdu_scfc_rmods_count}
    Wait Until All Radio Modules Are Online
    ...  rmods_count=${vdu_scfc_rmods_count}
    ...  timeout=30s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All radio modules are on line  console=${log_to_console}
# Wait until all cells are OnAir
    ${vdu_scfc_nrcells_count}=  vDU SCFC Get NRCELL Count
    ...  scfc_file_path=${scfc_file_path}
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
    ${mrbts_id}=  vDU Get MRBTS Id
    ...  vdu_connection=${vdu_connection}
    ${timer_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FMCADM-1
    ${cancellation_timer}=  vdu.Search Parameter Of Current Plan
    ...  mo_dn=${timer_mo_dn}
    ...  para_name=fault4592CancellationTimer
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${cancellation_timer}
    Log  ${ok_prefix_green}Step 1: Preconditions vDU commissioning  console=${log_to_console}

Step 2: Perform vDU Commissioning
    Log  ${dots_prefix_green}Step 2: Perform vDU commissioning  console=${log_to_console}
# Perform Commissioning
    Log  ${info_prefix}vDU commissioning is being performed. Please wait ...  console=${log_to_console}
    ${commissioning_result}=  vdu.Perform Commissioning
    ...  scf_file=${scfc_file_path}
    ...  timeout=${ACTIVATE_PLAN_TIMEOUT}
    ...  wait_for_completion=${True}
    ...  should_activate=${True}
    ...  vdu_connection=${vdu_connection}
    Log  ${below_info_prefix}vDU commissioning activation has been completed successfully  console=${log_to_console}
    Log  ${below_info_prefix}vDU commissioning operation status: ${commissioning_result['status']}  console=${log_to_console}
    vDU Rest Logout  vdu_connection=${vdu_connection}
    ${oam_http_connection}=  Get vDU Oam Http Connection Parameters From Init File
    ${ip_addr}=  Set Variable  ${oam_http_connection["ip_addr"]}
# Check if vDU OAM IP address is unavailable
    Ip Address Is Unavailable  ip_addr=${ip_addr}
    Log  ${info_prefix}vDU is unavailable. Wait for vDU availability ...  console=${log_to_console}
# Check if vDU OAM IP address is available
    Ip Address Is Available  ip_addr=${ip_addr}
    Log  ${below_info_prefix}vDU is available  console=${log_to_console}
# Check if API connection is established
    Log  ${info_prefix}Waiting for API connection to be established ...  console=${log_to_console}
    Wait Until Keyword Succeeds  30  2
    ...  vDU Rest Login  vdu_connection=${vdu_connection}
    Log  ${below_info_prefix}API connection has been established  console=${log_to_console}
# Check BTS Reset Cause Alarm
    vDU Check BTS Reset Cause Alarm
    ...  activation_timeout=120s
    ...  cancellation_timeout=${cancellation_timer}
    ...  info_pattern=*due to reconfiguration change*
    ...  vdu_connection=${vdu_connection}
    ...  log_prefix=${info_prefix}
    Log  ${ok_prefix_green}Step 2: Perform vDU commissioning  console=${log_to_console}

Step 3: Check Site States After vDU Commissioning
    Log  ${dots_prefix_green}Step 3: Check site states after vDU commissioning  console=${log_to_console}
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
# Wait until all cells are OnAir
    Wait Until All Cells Are OnAir
    ...  cells_count=${vdu_scfc_nrcells_count}
    ...  timeout=${VDU_COMMISSIONING_VDU_CELLS_ONAIR_TIMEOUT}
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${vdu_scfc_nrcells_count}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 3: Check site states after vDU commissioning  console=${log_to_console}

Step 4: Postconditions vDU Commissioning
    Log  ${dots_prefix_green}Step 4: Postconditions vDU commissioning  console=${log_to_console}
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
    Log  ${ok_prefix_green}Step 4: Postconditions vDU commissioning  console=${log_to_console}
