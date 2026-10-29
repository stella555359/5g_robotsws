*** Settings ***
Documentation  TC for call on LTE in CloudRan
...  Author: daniel.bartkowiak@nokia.com
...  Maintainer: daniel.bartkowiak@nokia.com

Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu
Resource   ./../../resources/Robot/L3_call.robot
Resource   ../../../resources/reporting.robot

*** Keywords ***
TC__Cloud_CALL_LTE_Data_Transfer
    [Arguments]  ${lte_scfc_file_path}  ${cells_yaml_path}  ${cell_ids}=@{EMPTY}  ${log_to_console}=${TRUE}
    [Documentation]
    ...  Description:
    ...  Keyword that test call on LTE in CloudRan.
    ...  Step 1: Cloud L3 Call Pre Conditions
    ...  a) All cells are OnAir
    ...     Cells expected states: operational_state = enabled
    ...                            administrative_state = unlocked
    ...                            availability_status = -
    ...  b) radio states are onair:
    ...                            operational_state = enabled
    ...                            administrative_state = unlocked
    ...                            availability_status = -
    ...  Step 2: Make LTE Data Transfer
    ...  a) Prepare Ues
    ...  b) Reject cells for call
    ...  c) Make call
    ...  d) Accept cells for call
    ...  Step 3: Cloud L3 Call Post Conditions
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
    ...  | lte_scfc_file_path     | Yes  | path to actual scf file                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com
    Set Test Variable  ${lte_scfc_file_path}
    Set Test Variable  ${cells_yaml_path}
    Set Test Variable  ${cell_ids}
    Set Test Variable  ${log_to_console}
    Set Test Variable  ${LTE_CALL}  ${TRUE}
    Log  ${start_prefix_green}Test Case: TC__Cloud_CALL_LTE_Data_Transfer  console=${log_to_console}
    Step 1: Cloud L3 Call Pre Conditions
    Step 2: Cloud L3 Call Make LTE Data Transfer
    Step 3: Cloud L3 Call Post Conditions
    Log  ${done_prefix_green}Test Case: TC__Cloud_CALL_LTE_Data_Transfer  console=${log_to_console}
    [Teardown]  Run Keyword And Ignore Error  LTEvDU Rest Logout  lte_vdu_connection=lte_l3_call

Step 1: Cloud L3 Call Pre Conditions
    Log  ${dots_prefix_green}Step 1: Cloud L3 Call Pre Conditions  console=${log_to_console}
    Append To List  ${LTE_VDU_HISTORICAL_ALLOWED_ALARMS}  @{VDU_RESET_LTE_VDU_ALLOWED_HIST_ALARMS}
    LTEvDU Rest Login  lte_vdu_connection=lte_l3_call
#Wait Until all radio modules are on line
    ${rmods_count}=  vDU SCFC Get RMODs Count  scfc_file_path=${lte_scfc_file_path}
    Wait Until All Radio Modules Are Online  lte_rmods_count=${rmods_count}
    ...  timeout=30s  lte_vdu_connection=lte_l3_call
    Log  ${info_prefix}All radio modules are on line  console=${log_to_console}
#Wait until all cells are OnAir
    ${lcells_count}=  vDU SCFC Get LCELL Count  scfc_file_path=${lte_scfc_file_path}
    Set Test Variable  ${lcells_count}
    Wait Until All Cells Are OnAir  lcells_count=${lcells_count}
    ...  timeout=30s  lte_vdu_connection=lte_l3_call
    Log  ${info_prefix}All LTE cells are OnAir  console=${log_to_console}
#Check vDU operational state
    vDU Wait For Expected Operational State  vdu_state_value=onAir
    ...  vdu_check=${False}  lte_vdu_check=${True}
    ...  lte_vdu_connection=lte_l3_call
    Log  ${info_prefix}LTE vDU operational state is onAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 1: Cloud L3 Call Pre Conditions  console=${log_to_console}

Step 2: Cloud L3 Call Make LTE Data Transfer
    Log  ${start_prefix_green}Step 2: Cloud L3 Call Make LTE Data Transfer  console=${TRUE}
    Cloud L3 Call  scfc_file_path=${lte_scfc_file_path}  cells_yaml_path=${cells_yaml_path}  cells_input=${cell_ids}
    Log  ${done_prefix_green}Step 2: Cloud L3 Call Make LTE Data Transfer  console=${log_to_console}

Step 3: Cloud L3 Call Post Conditions
    Log  ${dots_prefix_green}Step 3: Cloud L3 Call Post Conditions  console=${log_to_console}
#Wait Until all radio modules are on line
    ${rmods_count}=  vDU SCFC Get RMODs Count  scfc_file_path=${lte_scfc_file_path}
    Wait Until All Radio Modules Are Online  lte_rmods_count=${rmods_count}
    ...  timeout=300s  lte_vdu_connection=lte_l3_call
    Log  ${info_prefix}All radio modules are on line  console=${log_to_console}
#Wait until all cells are OnAir
    ${lcells_count}=  vDU SCFC Get LCELL Count  scfc_file_path=${lte_scfc_file_path}
    Set Test Variable  ${lcells_count}
    Wait Until All Cells Are OnAir  lcells_count=${lcells_count}
    ...  timeout=180s  lte_vdu_connection=lte_l3_call
    Log  ${info_prefix}All LTE cells are OnAir  console=${log_to_console}
    #Check vDU operational state
    vDU Wait For Expected Operational State  vdu_state_value=onAir  timeout=120s
    ...  vdu_check=${False}  lte_vdu_check=${True}
    ...  lte_vdu_connection=lte_l3_call
    Log  ${info_prefix}LTE vDU operational state is onAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 3: Cloud L3 Call Post Conditions  console=${log_to_console}
