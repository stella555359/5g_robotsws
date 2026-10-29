*** Settings ***
Documentation
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu
Library    taf.gnb.oam.coam.cu.interface.cu      WITH NAME    cu

Resource    ../../resources/Robot/vcu_oam_operations.robot
Resource    ../../../resources/Robot/scfc.robot
Resource    ../../resources/variables.robot

*** Variables ***
@{VDU_COMMISSIONING_ALLOWED_HIST_ALARMS}=  faultId=7504, severity=critical
@{VCU_COMMISSIONING_ALLOWED_HIST_ALARMS}=  faultId=7104, severity=critical

*** Keywords ***
TC__Cloud_CM_vDU_vCU_Commissioning
    [Arguments]  ${vcu_scfc_file_path}  ${vdu_scfc_file_path}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword performs vCU full commissioning.
    ...
    ...  Step 1: Check all cells state
    ...          All cells should be OnAir
    ...          vCU side:
    ...          Cells expected states: operational_state = enabled
    ...                                 administrative_state = unlocked
    ...          vDU side:
    ...          Cells expected states: operational_state = enabled
    ...                                 administrative_state = unlocked
    ...                                 availability_status = on_line
    ...  Step 2: Check vCU and vDU states
    ...          vCU side:
    ...          vCU expected states: operational_state = enabled
    ...          vDU expected states: administrative_state = unlocked
    ...          vDU side:
    ...          vDU expected states: operational_state = onAir
    ...  Step 3: Perform vCU full commissioning operation
    ...          vCU upload plan operation is successful
    ...          vCU validate plan operation is successful
    ...          vCU activate plan operation is successful
    ...  Step 4: Perform vDU full commissioning operation
    ...          vDU upload plan operation is successful
    ...          vDU validate plan operation is successful
    ...          vDU activate plan operation is successful
    ...  Step 5: Check vCU and vDU states
    ...          vCU expected states: operational_state = enabled
    ...          vDU expected states: administrative_state = unlocked
    ...  Step 6: Check vCU VNFCs states
    ...          vCU VHFCs expected states: operational_state = enabled
    ...                                     availability_status = on line
    ...  Step 7: Check NG and F1 links states
    ...          vCU side:
    ...          All NG links are active
    ...          All F1 links are available
    ...          vDU side:
    ...          F1-C expected link status: available
    ...  Step 8: Check vDU operational state
    ...          vDU expected states: operational_state = onAir
    ...  Step 9: Check all cells state
    ...          All cells should be OnAir
    ...          vCU side:
    ...          Cells expected states: operational_state = enabled
    ...                                 administrative_state = unlocked
    ...          vDU side:
    ...          Cells expected states: operational_state = enabled
    ...                                 administrative_state = unlocked
    ...                                 availability_status = on_line
    ...  No unexpected alarm is visible
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vcu_scfc_file_path     | Yes  | Path to the vCU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_scfc_file_path     | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Log  ${start_prefix_green}Test Case: vCU_vDU Full Commissioning  console=${log_to_console}
    Append To List  ${VDU_HISTORICAL_ALLOWED_ALARMS}  @{VDU_COMMISSIONING_ALLOWED_HIST_ALARMS}
    Append To List  ${VCU_HISTORICAL_ALLOWED_ALARMS}  @{VCU_COMMISSIONING_ALLOWED_HIST_ALARMS}
    vCU Rest Login
    vDU Rest Login
    ${vcu_cells_count}=  vCU SCFC Get NRCELL Count  scfc_file_path=${vcu_scfc_file_path}
    ${vdu_cells_count}=  vDU SCFC Get NRCELL Count  scfc_file_path=${vdu_scfc_file_path}
    Log  ${dots_prefix_green}Step 1: Check all cells state  console=${log_to_console}
    vCU Wait Until All Cells Are OnAir  cells_count=${vcu_cells_count}
    Wait Until All Cells Are OnAir  cells_count=${vdu_cells_count}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 1: Check all cells state  console=${log_to_console}
    Log  ${dots_prefix_green}Step 2: Check vCU and vDU states  console=${log_to_console}
    vCU Wait For Expected Operational State  vcu_state_value=enabled
    Log  ${info_prefix}vCU operational state is enabled now  console=${log_to_console}
    vCU Wait For Expected vDUs Administrative States  vdu_state_value=unlocked
    Log  ${info_prefix}vDU administrative state is unlocked now  console=${log_to_console}
    vDU Wait For Expected Operational State  vdu_state_value=onAir  timeout=60
    Log  ${info_prefix}vDU operational state is onAir now  console=${log_to_console}
    Log  ${ok_prefix_green}Step 2: Check vCU and vDU states  console=${log_to_console}
    Log  ${dots_prefix_green}Step 3: Perform vCU full commissioning operation  console=${log_to_console}
    Log  ${info_prefix}vCU full commissioning has been started  console=${log_to_console}
    cu.Perform Commissioning  scf_file=${vcu_scfc_file_path}  timeout=${ACTIVATE_PLAN_TIMEOUT}
    ...  wait_for_completion=True  should_activate=True
    Log  ${info_prefix}vCU full commissioning has been completed successfully  console=${log_to_console}
    Log  ${ok_prefix_green}Step 3: Perform vCU full commissioning operation  console=${log_to_console}
    Log  ${dots_prefix_green}Step 4: Perform vDU full commissioning operation  console=${log_to_console}
    Log  ${info_prefix}vDU full commissioning has been started  console=${log_to_console}
    vdu.Perform Commissioning  scf_file=${vdu_scfc_file_path}  timeout=${ACTIVATE_PLAN_TIMEOUT}
    ...  wait_for_completion=True  should_activate=True
    Log  ${info_prefix}vDU full commissioning has been completed successfully  console=${log_to_console}
    Log  ${ok_prefix_green}Step 4: Perform vDU full commissioning operation  console=${log_to_console}
    Log  ${dots_prefix_green}Step 5: Check vCU and vDU states  console=${log_to_console}
    vCU Wait For Expected Operational State  vcu_state_value=enabled
    Log  ${info_prefix}vCU operational state is enabled now  console=${log_to_console}
    vCU Wait For Expected vDUs Administrative States  vdu_state_value=unlocked
    Log  ${info_prefix}vDU administrative state is unlocked now  console=${log_to_console}
    Log  ${ok_prefix_green}Step 5: Check vCU and vDU states  console=${log_to_console}
    Log  ${dots_prefix_green}Step 6: Check vCU VNFCs states  console=${log_to_console}
    vCU Wait For Expected Vnfcs States  vcu_vnfcs_availability_status=on line
    ...  vcu_vnfcs_operational_state=enabled
    Log  ${info_prefix}All VHFCs states are enabled now  console=${log_to_console}
    Log  ${ok_prefix_green}Step 6: Check vCU VNFCs states  console=${log_to_console}
    Log  ${dots_prefix_green}Step 7: Check NG and F1 links states  console=${log_to_console}
    Log  ${info_prefix}}Wait for all NG links to be activated ...  console=${log_to_console}
    vCU Wait For Expected Ng Links Status  vcu_ng_link_status=Active
    Log  ${info_prefix}All NG links are active now  console=${log_to_console}
    Log  ${info_prefix}Wait for all F1 links to be activated ...  console=${log_to_console}
    vCU Wait For Expected F1 Links Status  vcu_f1_link_status=available
    Log  ${info_prefix}All F1 links are available now  console=${log_to_console}
    Log  ${info_prefix}Wait for F1-C link to activate...  console=${log_to_console}
    vDU Wait For Expected F1 Link Status  f1_link_status_value=available
    Log  ${info_prefix}F1-C link is available now  console=${log_to_console}
    Log  ${ok_prefix_green}Step 7: Check NG and F1 links states  console=${log_to_console}
    Log  ${dots_prefix_green}Step 8: Check vDU operational state  console=${log_to_console}
    vDU Wait For Expected Operational State  vdu_state_value=onAir  timeout=60s
    Log  ${info_prefix}vDU operational state is onAir now  console=${log_to_console}
    Log  ${ok_prefix_green}Step 8: Check vDU operational state  console=${log_to_console}
    Log  ${dots_prefix_green}Step 9: Check all cells state  console=${log_to_console}
    vCU Wait Until All Cells Are OnAir  cells_count=${vcu_cells_count}
    Wait Until All Cells Are OnAir  cells_count=${vdu_cells_count}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 9: Check all cells state  console=${log_to_console}
    Log  ${done_prefix_green}Test Case: vCU_vDU Full Commissioning  console=${log_to_console}
    [Teardown]  Run Keyword And Ignore Error  Run Keywords
    ...  vDU Rest Logout  AND  vCU Rest Logout
