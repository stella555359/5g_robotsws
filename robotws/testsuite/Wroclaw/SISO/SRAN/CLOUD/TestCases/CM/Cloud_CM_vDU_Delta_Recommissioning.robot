*** Settings ***
Documentation  vDU delta recommissioning
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu

Resource    ../../resources/Robot/vdu_oam_operations.robot
Resource    ../../../resources/Robot/scfc.robot
Resource    ../../resources/variables.robot

*** Variables ***
@{VCU_RECOMMISSIONING_VDU_ALLOWED_HIST_ALARMS}=  faultId=7104, severity=critical

*** Keywords ***
TC__Cloud_vDU_Delta_Recommissioning
    [Arguments]  ${scfc_file_path}  ${delta_file_path}  ${vdu_connection}=default  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword performs delta commissioning.
    ...
    ...  Step 1: vDU operation state is OnAir (operational_state=OnAir)
    ...  Step 2:  All cells are OnAir
    ...  Cells expected states: operational_state = enabled
    ...                         administrative_state = unlocked
    ...                         availability_status = on_line
    ...  Step 3: vDU delta recommissioning
    ...  Step 4: vDU operation state is OnAir (operational_state=OnAir)
    ...  Step 5: All cells are OnAir
    ...  Cells expected states: operational_state = enabled
    ...                         administrative_state = unlocked
    ...                         availability_status = on_line
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | delta_file_path        | Yes  | Path to the vDU delta json file.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Log  ${start_prefix_green}Test Case: vDU Delta Recommissioning  console=${log_to_console}
#Step 1: vDU operation state is OnAir
    Log  ${dots_prefix_green}Step 1: vDU operation state is OnAir  console=${log_to_console}
    Append To List  ${VCU_HISTORICAL_ALLOWED_ALARMS}  @{VCU_RECOMMISSIONING_VDU_ALLOWED_HIST_ALARMS}
    vDU Rest Login  vdu_connection=${vdu_connection}
    ${cells_count}=  vDU SCFC Get NRCELL Count  scfc_file_path=${scfc_file_path}
    vDU Wait For Expected Operational State  vdu_state_value=onAir  vdu_connection=${vdu_connection}
    Log  ${ok_prefix_green}Step 1: vDU operation state is OnAir  console=${log_to_console}
#Step 2: All cells are OnAir
    Log  ${dots_prefix_green}Step 2: All cells are OnAir  console=${log_to_console}
    Wait Until All Cells Are OnAir  cells_count=${cells_count}  vdu_connection=${vdu_connection}
    Log  ${ok_prefix_green}All cells are OnAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 2: All cells are OnAir  console=${log_to_console}
#Step 3: vDU delta recommissioning
    Log  ${dots_prefix_green}Step 3: vDU delta recommissioning  console=${log_to_console}
    vdu.Perform Delta Recommissioning  delta_file=${delta_file_path}  wait_for_completion=True
    ...  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}  vdu_connection=${vdu_connection}
    Log  ${ok_prefix_green}vDU commissioning delta plan has been completed successfully  console=${log_to_console}
    Log  ${ok_prefix_green}Step 3: vDU delta recommissioning  console=${log_to_console}
#Step 4: vDU operation state is OnAir
    Log  ${dots_prefix_green}Step 4: vDU operation state is OnAir  console=${log_to_console}
    ${scfc_delta_file_path}=  vdu.Get Current Plan File  local_dir_path=${OUTPUT_DIR}
    ...  filename='vDU_SCF_delta_updated.xml'  vdu_connection=${vdu_connection}
    ${cells_count}=  vDU SCFC Get NRCELL Count  scfc_file_path=${scfc_delta_file_path}
    vDU Wait For Expected Operational State  vdu_state_value=onAir  vdu_connection=${vdu_connection}
#Step 5: All cells are OnAir
    Log  ${dots_prefix_green}Step 5: All cells are OnAir  console=${log_to_console}
    Wait Until All Cells Are OnAir  cells_count=${cells_count}  vdu_connection=${vdu_connection}
    Log  ${ok_prefix_green}All cells are OnAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 5: All cells are OnAir  console=${log_to_console}
    Log  ${done_prefix_green}Test Case: vDU Delta Recommissioning  console=${log_to_console}
    [Teardown]  Run Keyword And Ignore Error  vDU Rest Logout  vdu_connection=${vdu_connection}
