*** Settings ***
Documentation  Radio module reset from GUI
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    Collections
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu
Library    taf.selenium.gnb.oam.coam.vdu    WITH NAME    svdu

Resource    ../../resources/Robot/vdu_oam_operations.robot
Resource    ../../resources/Robot/svdu_operations.robot
Resource    ../../../resources/Robot/scfc.robot
Resource    ../../resources/variables.robot

*** Variables ***
${RMOD_GUI_RESET_VDU_CELLS_ONAIR_TIMEOUT}=  120s
@{VCU_GUI_RESET_ALLOWED_HIST_ALARMS}=  faultId=7104, severity=critical

*** Keywords ***
TC__Cloud_SM_Radio_Modules_Reset_Via_GUI
    [Arguments]  ${vdu_scfc_file_path}  ${cbts_rmod_sn_list}=@{EMPTY}  ${cbts_rmod_sn_count}=0
    ...  ${reset_timeout}=400  ${jwt_expiration_time}=120
    ...  ${vdu_connection}=default  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Test case performs a CBTS radio module reset via WebEM (GUI).
    ...
    ...  Step 1: Preconditions Radio Modules GUI Reset
    ...  a) All radio modules should be on line
    ...  b) All cells should be OnAir
    ...  c) vDU operational state should be onAir
    ...  d) Set session expiration time (jwtExpirationTime)
    ...  Step 2: CBTS Radio Module GUI Reset
    ...  Step 3: CBTS GUI Reset Radio Module Check States
    ...  a) Check reset CBTS radio module NR cells states
    ...  b) Wait until reset CBTS radio module is on line
    ...  c) Wait until all cells are OnAir
    ...  d) Wait until vDU operational state is OnAir
    ...  Step 4: CBTS Postconditions Radio Modules GUI Reset
    ...  a) The same values as in Step 1
    ...  No unexpected alarms are visible
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_scfc_file_path     | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cbts_rmod_sn_list      |      | List of serial number of the tested radio modules.                         |
    ...  |                        |  No  | @{EMPTY} value means that no list was given,                               |
    ...  |                        |      | so all radio modules defined in the SCFC file will be used.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cbts_rmod_sn_count     |  No  | Number of randomly selected radio modules serial numbers based on          |
    ...  |                        |      | the list obtained from the SCFC file.                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | reset_timeout          |  No  | Timeout for waiting for positive reset procedure result.                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | jwt_expiration_time    |  No  | Expiration time on or after which the JSON Web Token                       |
    ...  |                        |      | must not be accepted for processing (minutes).                             |
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
    Set Test Variable  ${reset_timeout}
    Set Test Variable  ${jwt_expiration_time}
    Set Test Variable  ${vdu_connection}
    Set Test Variable  ${log_to_console}
    Log  ${start_prefix_green}Test Case: CBTS_Radio_Modules_GUI_Reset  console=${log_to_console}
    Step 1: Preconditions Radio Modules GUI Reset
    FOR  ${cbts_reset_rmod_sn}  IN  @{cbts_reset_rmod_sn_list}
      Set Test Variable  ${cbts_reset_rmod_sn}
      Step 2: CBTS Radio Module GUI Reset
      Step 3: CBTS GUI Reset Radio Module Check States
    END
    Step 4: CBTS Postconditions Radio Modules GUI Reset
    Log  ${done_prefix_green}Test Case: CBTS_Radio_Modules_GUI_Reset  console=${log_to_console}
    [Teardown]  Run Keywords  Run Keyword And Ignore Error  vDU WebEM Logout
    ...  AND  Run Keyword And Ignore Error  vDU Rest Logout  vdu_connection=${vdu_connection}

Step 1: Preconditions Radio Modules GUI Reset
    Log  ${dots_prefix_green}Step 1: Preconditions radio modules GUI reset  console=${log_to_console}
    Append To List  ${VCU_HISTORICAL_ALLOWED_ALARMS}  @{VCU_GUI_RESET_ALLOWED_HIST_ALARMS}
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
    ${cbts_rmod_sn_cells_id_dict}=  vDU RMOD Get Serial Numbers And Given Parameters Value
    ...  rmod_param=cell_ids
    ...  vdu_connection=${vdu_connection}
    Set Test Variable  ${cbts_rmod_sn_cells_id_dict}
    ${rmods_conf_id_dict}=  vDU RMOD Get Serial Numbers And Given Parameters Value  rmod_param=configuration_id
    Set Test Variable  ${rmods_conf_id_dict}
# Check SCFC radio module list and actual radio module
    ${vdu_rmod_sn_list}=  Get Dictionary Keys  dictionary=${rmods_conf_id_dict}
    ${vdu_scfc_rmod_sn_list}=  vDU SCFC Get RMOD Serial Number List  scfc_file_path=${vdu_scfc_file_path}
    Sort List  ${vdu_scfc_rmod_sn_list}
    Sort List  ${vdu_rmod_sn_list}
    Lists Should Be Equal  list1=${vdu_scfc_rmod_sn_list}  list2=${vdu_rmod_sn_list}
    ...  msg=SCFC radio module list and actual radio module list should be the same !
# Set reset radio module list
    ${cbts_reset_rmod_sn_list}=  Get Radio Modules Serial Numbers List  scfc_file_path=${vdu_scfc_file_path}
    ...  rmod_sn_list=${cbts_rmod_sn_list}  rmod_sn_count=${cbts_rmod_sn_count}
    Set Test Variable  ${cbts_reset_rmod_sn_list}
# Set session expiration time
    ${mrbts_id}=  vDU Get MRBTS Id
    ...  vdu_connection=${vdu_connection}
    ${jwtexpirationtime_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/MNL-1/AMGR-1/LUAC-1
    Log  ${info_prefix}Session expiration time parameter (jwtExpirationTime) setting ...  console=${log_to_console}
    ${jwtexpirationtime_value}=  vdu.Search Parameter Of Current Plan
    ...  mo_dn=${jwtexpirationtime_mo_dn}
    ...  para_name=jwtExpirationTime
    ...  vdu_connection=${vdu_connection}
    IF  ${jwtexpirationtime_value}!=${jwt_expiration_time}
      Log  ${below_info_prefix}Parameter "jwtExpirationTime" will be set to ${jwt_expiration_time} ...  console=${log_to_console}
      Log  ${below_info_prefix}Parameter recommissioning is performed ...  console=${log_to_console}
      vdu.Perform Parameter Recommissioning
      ...  dist_name=${jwtexpirationtime_mo_dn}
      ...  parameter=jwtExpirationTime
      ...  operation=update
      ...  value=${jwt_expiration_time}
      ...  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
      ...  vdu_connection=${vdu_connection}
    END
    ${jwtexpirationtime_value}=  vdu.Search Parameter Of Current Plan
    ...  mo_dn=${jwtexpirationtime_mo_dn}
    ...  para_name=jwtExpirationTime
    ...  vdu_connection=${vdu_connection}
    Log  ${below_info_prefix}Parameter "jwtExpirationTime" is now set to ${jwtexpirationtime_value} minutes  console=${log_to_console}
# Set cells states
    ${cbts_impacted_cell_state_dict}=  Create Dictionary  availabilityStatus=failed|off line
    ...  operationalState=disabled  administrativeState=Unlocked  blockingState=Unblocked
    Set Test Variable  ${cbts_impacted_cell_state_dict}
    vDU WebEM Login
    Log  ${ok_prefix_green}Step 1: Preconditions radio modules GUI reset  console=${log_to_console}

Step 2: CBTS Radio Module GUI Reset
    Log  ${dots_prefix_green}Step 2: CBTS radio module GUI reset  console=${log_to_console}
    ${rmod_conf_id}=  Get From Dictionary  dictionary=${rmods_conf_id_dict}  key=${cbts_reset_rmod_sn}
    ${rmod_name}=  Set Variable  RMOD-${rmod_conf_id}
# CBTS radio module reset
    Log  ${dots_prefix_green}Radio module ${rmod_name} (sn: ${cbts_reset_rmod_sn}) is resetting
    ...  console=${log_to_console}
    Log  ${info_prefix}Wait a while for the radio module ${rmod_name} (sn: ${cbts_reset_rmod_sn}) to reset ...
    ...  console=${log_to_console}
    ${reset_status}=  svdu.Reset Radio
    ...  object_name=${rmod_name}
    ...  graceful_cell_shutdown=${False}
    ...  timeout=${reset_timeout}
    Log  ${below_info_prefix}${reset_status}  console=${log_to_console}
    Log  ${ok_prefix_green}Step 2: CBTS radio module GUI reset  console=${log_to_console}

Step 3: CBTS GUI Reset Radio Module Check States
    Log  ${dots_prefix_green}Step 3: CBTS radio module GUI reset check states  console=${log_to_console}
# Check reset CBTS radio module NR cells states
    ${cbts_rmod_impacted_cells_id_list}=  Get From Dictionary
    ...  dictionary=${cbts_rmod_sn_cells_id_dict}
    ...  key=${cbts_reset_rmod_sn}
    FOR  ${cbts_rmod_impacted_cell_id}  IN  @{cbts_rmod_impacted_cells_id_list}
      Cell Wait For Expected States Or Statuses
      ...  cell_id=${cbts_rmod_impacted_cell_id}
      ...  state_status_dict=${cbts_impacted_cell_state_dict}
      ...  timeout=10s
      ...  vdu_connection=${vdu_connection}
    END
    Log  ${info_prefix}Reset radio module (sn: ${cbts_reset_rmod_sn}) cells status is OK  console=${log_to_console}
# Wait until reset CBTS radio module is on line
    RMOD Wait For Online
    ...  rmod_sn=${cbts_reset_rmod_sn}
    ...  timeout=120s
    ...  vdu_connection=${vdu_connection}
    Log  ${ok_prefix_green}Radio module (serial number: ${cbts_reset_rmod_sn}) is online  console=${log_to_console}
# Wait until all cells are OnAir
    Wait Until All Cells Are OnAir
    ...  cells_count=${vdu_scfc_nrcells_count}
    ...  timeout=${RMOD_GUI_RESET_VDU_CELLS_ONAIR_TIMEOUT}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
# Wait until vDU operational state is OnAir
    vDU Wait For Expected Operational State
    ...  vdu_state_value=onAir
    ...  timeout=30s
    ...  vdu_check=${True}
    ...  lte_vdu_check=${False}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}vDU operational state is onAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 3: CBTS radio module GUI reset check states  console=${log_to_console}

Step 4: CBTS Postconditions Radio Modules GUI Reset
    Log  ${dots_prefix_green}Step 4: CBTS postconditions radio modules GUI reset  console=${log_to_console}
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
    Log  ${ok_prefix_green}Step 4: CBTS postconditions radio modules GUI reset  console=${log_to_console}
