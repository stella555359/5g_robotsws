*** Settings ***
Documentation  AiC test cases keywords.
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    Collections
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu
Library    taf.gnb.oam.coam.cu.interface.cu      WITH NAME    cu

Resource    ./vdu_oam_operations.robot
Resource    ./fhgw_operations.robot
Resource    ../../../resources/Robot/scfc.robot

*** Keywords ***
#TEST CASE SECTION
#NOT USED
Check Basic Counters
    [Arguments]  ${scfc_file_path}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword checks the existence of the "miNrEcpriUpFCp" parameter
    ...  and whether the FCP counters have an integer value.
    ...  Parameter "miNrEcpriUpFCp" denotes the measurement interval
    ...  for the NR eCPRI U-Plane&Fast-C-Plane (NECUP) measurements.
    ...  The following counters are checked:
    ...  M55318C00001
    ...  M55318C00003
    ...  M55318C00005
    ...  M55318C00007
    ...  M55318C00009
    ...  Counter M55318C00001 is incremented when RAU receives an eCPRI U-Plane or Fast-C-Plane message.
    ...  Counter M55318C00003 provides the number of eCPRI U-Plane and Fast-C-Plane messages received
    ...  on RAU's side within the reception window.
    ...  Counter M55318C00005 provides the number of eCPRI U-Plane and Fast-C-Plane messages received
    ...  on RAU's side before the reception window starts.
    ...  Counter M55318C00007 provides the number of eCPRI U-Plane and Fast-C-Plane messages received
    ...  on RAU's side after reception window ends.
    ...  Counter M55318C00009 provides the number of eCPRI U-Plane and Fast-C-Plane messages received
    ...  on RAU's side with corrupted or incorrect field value
    ...
    ...  Step 1: Check all cells state
    ...          All cells should be OnAir
    ...          vDU cells expected states: operational_state = enabled
    ...                                     administrative_state = unlocked
    ...                                     availability_status = on_line
    ...  Step 2: Check SCFC parameter
    ...          SCFC parameter "miNrEcpriUpFCp" should exist and be set
    ...  Step 3: Check FCP counters
    ...          Basic cell related counters (M55318C00001, M55318C00003, M55318C00005,
    ...          M55318C00007, M55318C00009) have an integer value.
    ...  No unexpected alarms are visible
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Log  ${start_prefix_green}Test Case: Check Basic Counters  console=${log_to_console}
    vDU Rest Login
    Log  ${dots_prefix_green}Step 1: Check all cells state  console=${log_to_console}
    ${cells_count}=  vDU SCFC Get NRCELL Count  scfc_file_path=${scfc_file_path}
    Wait Until All Cells Are OnAir  cells_count=${cells_count}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 1: Check all cells state  console=${log_to_console}
    Log  ${dots_prefix_green}Step 2: Check SCFC parameter  console=${log_to_console}
    SCFC Parameter Should Exist  scfc_file_path=${scfc_file_path}  parameter_name=miNrEcpriUpFCp
    Log  ${info_prefix}SCFC parameter "miNrEcpriUpFCp" exists and is set  console=${log_to_console}
    Log  ${ok_prefix_green}Step 2: Check SCFC parameter  console=${log_to_console}
    Log  ${dots_prefix_green}Step 3: Check FCP counters  console=${log_to_console}
    ${scfc_dist_name_list}=  SCFC Get Regexp Matches Dist Name  scfc_file_path=${scfc_file_path}
    ...  dist_name=MRBTS-\\d+/NRBTS-\\d+/NRCELL-\\d+
    Sort List  ${scfc_dist_name_list}
    ${mrbts_id}=  vDU Get MRBTS Id  vdu_login=False
    ${scfc_rmod_sn_list}=  vDU SCFC Get RMOD Serial Number List  scfc_file_path=${scfc_file_path}
    Sort List  ${scfc_rmod_sn_list}
    ${rmods_dict}=  vDU RMOD Get Serial Numbers And Given Parameters Value  rmod_param=interface_type
    ${rmod_sn_list}=  Get Dictionary Keys  dictionary=${rmods_dict}
    Sort List  ${rmod_sn_list}
    Lists Should Be Equal  list1=${scfc_rmod_sn_list}  list2=${rmod_sn_list}
    ...  msg=SCFC radio module list and actual radio module list should be the same !  values=False
    ${cell_id_list}=  Create List
    FOR  ${rmod_sn}  IN  @{rmod_sn_list}
      ${interface_type}=  Get From Dictionary  dictionary=${rmods_dict}  key=${rmod_sn}
      Continue For Loop If  '${interface_type}'!='eCPRI'
      ${rmod_cell_id_list}=  RMOD Get Cell Id List  rmod_sn=${rmod_sn}
      Append To List  ${cell_id_list}  @{rmod_cell_id_list}
    END
    Run Keyword If  ${cell_id_list}==@{EMPTY}
    ...  Fail  msg=There are no eCPRI interface type radio modules !
    ${cell_dist_name_list}=  Create List
    FOR  ${cell_id}  IN  @{cell_id_list}
      Append To List  ${cell_dist_name_list}  MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-${cell_id}
    END
    Sort List  ${cell_dist_name_list}
    List Should Contain Sub List  list1=${scfc_dist_name_list}  list2=${cell_dist_name_list}
    ...  msg=SCFC dist name NRCELL list not contain actual dist name NRCELL sub list !  values=False
    vDU Check Pm Counters  dist_name_list=${cell_dist_name_list}
    Log  ${info_prefix}Basic cell related counters have been checked successfully  console=${log_to_console}
    Log  ${ok_prefix_green}Step 3: Check FCP counters  console=${log_to_console}
    Log  ${done_prefix_green}Test Case: Check Basic Counters  console=${log_to_console}
    [Teardown]  Run Keyword And Ignore Error  vDU Rest Logout

TC FHGW Reset Via CLI
    [Arguments]  ${scfc_file_path}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Test case resets FHGW via CLI.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Log  \n\n${start_prefix_green}Test Case: TC FHGW Reset Via CLI  console=${log_to_console}
    vDU Rest Login
    ${cells_count}=  vDU SCFC Get NRCELL Count  scfc_file_path=${scfc_file_path}
    Log  ${dots_prefix_green}Step 1: Initial check  console=${log_to_console}
    vDU Wait For Expected Operational State  vdu_state_value=onAir
    Wait Until All Cells Are OnAir  cells_count=${cells_count}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 1: Initial check  console=${log_to_console}
    Log  ${dots_prefix_green}Step 2: Reset FHGW  console=${log_to_console}
    Reset FHGW
    Log  ${ok_prefix_green}Step 2: Reset FHGW  console=${log_to_console}
    Log  ${dots_prefix_green}Step 3: Postconditions  console=${log_to_console}
    vDU Wait For Expected Operational State  vdu_state_value=onAir
    Wait Until All Cells Are OnAir  cells_count=${cells_count}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 3: Postconditions  console=${log_to_console}
    Log  \n\n${done_prefix_green}Test Case: TC FHGW Reset Via CLI  console=${log_to_console}
    [Teardown]  Run Keyword And Ignore Error  vDU Rest Logout
