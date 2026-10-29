*** Settings ***
Documentation  Call execution keywords.
...  Author: daniel.bartkowiak@nokia.com
...  Maintainer: daniel.bartkowiak@nokia.com

Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu
Resource   ./../../resources/Robot/L3_call.robot

*** Keywords ***
TC__Cloud_CALL_NR_Data_Transfer
    [Arguments]  ${scfc_file_path}  ${cells_yaml_path}  ${cell_ids}=@{EMPTY}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword that test call on 5G in CloudRan.
    ...  Step 1: Cloud L3 Call Pre/Post Conditions
    ...  a) All cells are OnAir
    ...     Cells expected states: operational_state = enabled
    ...                            administrative_state = unlocked
    ...                            availability_status = -
    ...  b) radio states are onair:
    ...                            operational_state = enabled
    ...                            administrative_state = unlocked
    ...                            availability_status = -

    ...  Step 2: Make NR Data Transfer
    ...  a) Prepare Ues
    ...  b) Reject cells for call
    ...  c) Make call
    ...  d) Accept cells for call
    ...  Step 3: Cloud L3 Call Pre/Post Conditions
    ...  a) All cells are OnAir
    ...     Cells expected states: operational_state = enabled
    ...                         administrative_state = unlocked
    ...                         availability_status = on_line
    ...  b) radio states are onair:
    ...                            operational_state = enabled
    ...                            administrative_state = unlocked
    ...                            availability_status = -

    ...  No unexpected alarms are visible
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cells_input            | Yes  | list of cells ids for call NR->nr_cell_identity LTE->eutranCellId          |
    ...  |                        |      | If @{EMPTY} set, it means all cells will be called                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cells_yaml_path        | Yes  | path to reference yaml file with cells parameters                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | scfc_file_path         | Yes  | path to actual scf file                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    Set Test Variable  ${scfc_file_path}
    Set Test Variable  ${cells_yaml_path}
    Set Test Variable  ${cell_ids}
    Set Test Variable  ${log_to_console}
    Log  ${start_prefix_green}Test Case: TC__Cloud_CALL_NR_Data_Transfer  console=${log_to_console}
    vDU Rest Login
    Step 1: Cloud L3 Call Pre/Post Conditions
    Step 2: Cloud L3 Call Make NR Data Transfer
    Step 3: Cloud L3 Call Pre/Post Conditions
    Log  ${done_prefix_green}Test Case: TC__Cloud_CALL_NR_Data_Transfer  console=${log_to_console}
    [Teardown]  Run Keyword And Ignore Error  vDU Rest Logout

Step 2: Cloud L3 Call Make NR Data Transfer
    Log  ${start_prefix_green}Step 2: Cloud L3 Call Make NR Data Transfer  console=${log_to_console}
    Cloud L3 Call  scfc_file_path=${scfc_file_path}  cells_yaml_path=${cells_yaml_path}  cells_input=${cell_ids}
    Log  ${done_prefix_green}Step 2: Cloud L3 Call Make NR Data Transfer  console=${log_to_console}

Step ${index}: Cloud L3 Call Pre/Post Conditions
    Log  ${start_prefix_green}Step ${index}: Cloud L3 Call Pre/Post Conditions  console=${log_to_console}
    ${cells_count}=  vDU SCFC Get NRCELL Count  scfc_file_path=${scfc_file_path}
    vDU Wait For Expected Operational State  vdu_state_value=onAir
    Wait Until All Cells Are OnAir  cells_count=${cells_count}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
    ${rmods_sn_list}=  vDU SCFC Get RMOD Serial Number List  scfc_file_path=${scfc_file_path}
    FOR  ${ru_sn}  IN  @{rmods_sn_list}
      RMOD Wait For Online  rmod_sn=${ru_sn}
    END
    Log  ${info_prefix}All radio units online  console=${log_to_console}
    Log  ${done_prefix_green}Step ${index}: Cloud L3 Call Pre/Post Conditions  console=${log_to_console}
