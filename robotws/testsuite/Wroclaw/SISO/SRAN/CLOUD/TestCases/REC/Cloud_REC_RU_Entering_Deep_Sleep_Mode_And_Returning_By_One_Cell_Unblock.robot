*** Settings ***
Documentation
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu

Resource    ../../resources/Robot/vdu_oam_operations.robot
Resource    ../../resources/Robot/setup_teardown.robot
Resource    ../../../resources/Robot/scfc.robot

*** Variables ***
@{VDU_ONE_CELL_UNBLOCK_RECOVERY_ALLOWED_HIST_ALARMS}=  faultId=49, severity=critical
@{VCU_ONE_CELL_UNBLOCK_RECOVERY_ALLOWED_HIST_ALARMS}=  faultId=7104, severity=critical

*** Keywords ***
TC__Cloud_REC_RU_Entering_Deep_Sleep_Mode_And_Returning_By_One_Cell_Unblock
    [Arguments]  ${scfc_file_path}  ${rmod_sn_list}  ${rmod_sn_count}=0  ${grace_period}=10min  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_VRF_SISO-3180
    ...  Test case for CB007065-CR-E parity feature.
    ...  The feature CB007065 provides energy saving functionalities on Cloud-based gNB
    ...  as originally introduced by legacy features with Classical gNB solution.
    ...
    ...  The purpose of this test case is to place the radio module into sleep mode
    ...  and exit that mode to normal operation.
    ...  Test case enable/disable "energySavingMode" parameter on radio module.
    ...  This parameter allows to activate or deactivate various energy saving function in radio module:
    ...  - NORMAL - radio module is working in normal mode and without deep sleep mode activation
    ...  - DEEPSLEEP - deep sleep mode is activated on radio module.
    ...  Entering deep sleep mode occurs after all cells are blocked on the radio module.
    ...  Depending on SCF configuration gNB-vDU activates deep sleep function on the radio
    ...  and after the grace period enters again into deep sleep.
    ...  Grace period will be counted when "energySavingMode" parameter is configured to DEEPSLEEP
    ...  and all carriers are disabled.
    ...  Radio module change power state from AWAKE to SLEEP. This operation can take 5-7 minutes.
    ...  Exiting deep sleep mode in this test occurs after unlocking one random cell on the radio module.
    ...
    ...  Step 1: Initial Check Deep Sleep
    ...  a) vDU operation state is OnAir (operational_state=OnAir)
    ...  b) All cells are OnAir
    ...     Cells expected states: operational_state = enabled
    ...                            administrative_state = unlocked
    ...                            availability_status = on_line
    ...  c) Radio module power state: power_state = AWAKE
    ...  Step 2: Activate Energy Saving On Radio Module
    ...  a) Set parameter "energySavingMode" to "DEEPSLEEP".
    ...  b) Radio module power state: power_state = AWAKE
    ...  Step 3: Block All Cells On Radio Module
    ...  a) All cells block operation is successful
    ...  b) Cells expected states: blocking_state = Blocked
    ...                            operational_state = disabled
    ...  c) Alarm (fault id=49) on all cells is active
    ...  Step 4: Check Radio Module Power State When All Cells Are Blocked
    ...  a) After grace period radio module have expected state:
    ...     Radio module power state: power_state = SLEEP
    ...  Step 5: Unblock One Random Cell On Radio Module
    ...  a) Cell unblock operation is successful
    ...  b) Cell expected state: blocking_state = Unblocked
    ...                          operational_state = disabled
    ...  c) Alarm (fault id=49) is inactive.
    ...  Step 6: Check Radio Module Power State After One Cell Unblocked
    ...  a) After grace period radio module have expected state
    ...     Radio module power state: AWAKE
    ...  Step 7: Unblock All Blocked Cells On Radio Module
    ...  a) Cells unblock operation is successful
    ...  b) Cells expected states: blocking_state = Unblocked
    ...                            operational_state = enabled
    ...  c) Alarm (fault id=49) on all cells is inactive.
    ...  Step 8: Check Radio Module Power State After All Cells Unblocked
    ...  a) After grace period radio module have expected state
    ...     Radio module power state: power_state = AWAKE
    ...  Step 9: Deactivate Energy Saving On Radio Module
    ...  a) Set parameter "energySavingMode" to "NORMAL".
    ...  b) Radio module power state: power_state = AWAKE
    ...  c) All cells are OnAir
    ...     Cells expected states: operational_state = enabled
    ...                            administrative_state = unlocked
    ...                            availability_status = on_line
    ...  Step 10: Postconditions Deep Sleep
    ...  a) vDU operation state is OnAir (operational_state=OnAir)
    ...  b) All cells are OnAir
    ...     Cells expected states: operational_state = enabled
    ...                            administrative_state = unlocked
    ...                            availability_status = on_line
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_sn_list           |      | List of serial number of the tested radio modules.                         |
    ...  |                        |  No  | @{EMPTY} value means that no list was given,                               |
    ...  |                        |      | so all radio modules defined in the SCFC file will be used.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_sn_count          |  No  | Number of randomly selected radio modules serial numbers based on          |
    ...  |                        |      | the list obtained from the SCFC file.                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | grace_period           |  No  | Time to enter (exit from) deep sleep mode.                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Set Test Variable  ${scfc_file_path}
    Set Test Variable  ${rmod_sn_list}
    Set Test Variable  ${rmod_sn_count}
    Set Test Variable  ${grace_period}
    Set Test Variable  ${log_to_console}
    Append To List  ${VDU_HISTORICAL_ALLOWED_ALARMS}  @{VDU_ONE_CELL_UNBLOCK_RECOVERY_ALLOWED_HIST_ALARMS}
    Append To List  ${VCU_HISTORICAL_ALLOWED_ALARMS}  @{VCU_ONE_CELL_UNBLOCK_RECOVERY_ALLOWED_HIST_ALARMS}
    Log  ${start_prefix_green}Test Case: RU Entering Deep Sleep Mode And Returning By One Cell Unblock  console=${log_to_console}
    Step 1: Initial Check Deep Sleep
    FOR  ${rmod_sn}  IN  @{rmod_serial_number_list}
      Set Test Variable  ${rmod_sn}
      Step 2: Activate Energy Saving On Radio Module
      Step 3: Block All Cells On Radio Module
      Step 4: Check Radio Module Power State When All Cells Are Blocked
      Step 5: Unblock One Random Cell On Radio Module
      Step 6: Check Radio Module Power State After One Cell Unblocked
      Step 7: Unblock All Blocked Cells On Radio Module
      Step 8: Check Radio Module Power State After All Cells Unblocked
      Step 9: Deactivate Energy Saving On Radio Module
    END
      Step 10: Postconditions Deep Sleep
    Log  ${done_prefix_green}Test Case: RU Entering Deep Sleep Mode And Returning By One Cell Unblock  console=${log_to_console}
    [Teardown]  Radio Module Deep Sleep Mode Teardown  tc_status=${KEYWORD_STATUS}

Step 1: Initial Check Deep Sleep
    Log  ${dots_prefix_green}Step 1: Initial check  console=${log_to_console}
    vDU Rest Login
    ${rmod_serial_number_list}=  Get Radio Modules Serial Numbers List  scfc_file_path=${scfc_file_path}
    ...  rmod_sn_list=${rmod_sn_list}  rmod_sn_count=${rmod_sn_count}
    Set Test Variable  ${rmod_serial_number_list}
    vDU Wait For Expected Operational State  vdu_state_value=onAir
    ${current_vdu_state}=  vDU Get Current State  vdu_state=operational_state
    Log  ${info_prefix}vDU operational state is OnAir  console=${log_to_console}
    ${cells_count}=  vDU SCFC Get NRCELL Count  scfc_file_path=${scfc_file_path}
    Set Test Variable  ${cells_count}
    Wait Until All Cells Are OnAir  cells_count=${cells_count}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
    ${mrbts_id}=  vDU Get MRBTS Id  vdu_login=False
    Set Test Variable  ${mrbts_id}
    Log  ${ok_prefix_green}Step 1: Initial check  console=${log_to_console}

Step 2: Activate Energy Saving On Radio Module
    Log  ${dots_prefix_green}Step 2: Activate energy saving on radio module  console=${log_to_console}
    ${rmod_power_state}=  RMOD Get Current State  rmod_sn=${rmod_sn}  rmod_state=power_state
    Log  ${info_prefix}Radio module (sn: ${rmod_sn}) power state is now: ${rmod_power_state}  console=${log_to_console}
    ${rmod_conf_id}=  vDU RMOD Get Parameter Value Based On Serial Number  rmod_sn=${rmod_sn}  rmod_param=configuration_id
    ${energysavingmode_mo_dn}=  Set Variable  MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-${rmod_conf_id}
    Set Test Variable  ${energysavingmode_mo_dn}
    Log  ${info_prefix}Energy saving parameter (energySavingMode) setting  console=${log_to_console}
    ${energysavingmode_value}=  vdu.Search Parameter Of Current Plan  mo_dn=${energysavingmode_mo_dn}  para_name=energySavingMode
    ${updated_params_dict}=  Create Dictionary  energySavingMode=DEEPSLEEP
    ${updated_params_oper_dict}=  Create Dictionary  update=${updated_params_dict}
    ${json_parameters_update}=  Create Single Dist Name Json String  mo_dn=${energysavingmode_mo_dn}
    ...  updated_params_dict=${updated_params_oper_dict}  distname_operation=update
    Run Keyword If  '${energysavingmode_value}'=='NORMAL'  Run Keywords
    ...  Log  ${below_info_prefix}Recommissioning to activate deep sleep mode on radio module (energySavingMode=DEEPSLEEP) ...
    ...  console=${log_to_console}
    ...  AND
    ...  vdu.Perform Delta Recommissioning  delta_file=${json_parameters_update[0]}
    ...  wait_for_completion=True  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    ${energysavingmode_value}=  vdu.Search Parameter Of Current Plan  mo_dn=${energysavingmode_mo_dn}  para_name=energySavingMode
    Log  ${below_info_prefix}Parameter "energySavingMode" is now set to "${energysavingmode_value}"  console=${log_to_console}
    ${rmod_power_state}=  RMOD Get Current State  rmod_sn=${rmod_sn}  rmod_state=power_state
    Log  ${info_prefix}Radio module (sn: ${rmod_sn}) power state is now: ${rmod_power_state}  console=${log_to_console}
    Log  ${ok_prefix_green}Step 2: Activate energy saving on radio module  console=${log_to_console}

Step 3: Block All Cells On Radio Module
    Log  ${dots_prefix_green}Step 3: Block all cells on radio module  console=${log_to_console}
    ${cell_id_list}=  RMOD Get Cell Id List  rmod_sn=${rmod_sn}
    Set Test Variable  ${cell_id_list}
    ${vdu_cells_dict}=  vDU Cells Get Identity And Id
    Set Test Variable  ${vdu_cells_dict}
    ${alarm_severity_list}=  Create List  Critical
    Set Test Variable  ${alarm_severity_list}
    FOR  ${cell_id}  IN  @{cell_id_list}
      vDU Block Cell And Check  cell_id=${cell_id}
      Cell Wait For Expected State  cell_id=${cell_id}  cell_state=blocking_state  cell_state_value=Blocked
      Cell Wait For Expected State  cell_id=${cell_id}  cell_state=operational_state  cell_state_value=disabled
      ${alarming_object_list}=  Create List  MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-${cell_id}
      vDU Assert Alarm Active  fault_id=49  alarming_object_list=${alarming_object_list}
      ...  alarm_severity_list=${alarm_severity_list}  vdu_login=False
      Log  ${ok_prefix_green}Block cell (cell identity: ${vdu_cells_dict['${cell_id}']}) operation succeeded
      ...  console=${log_to_console}
      Log  ${info_prefix}Alarm (faultId:49) on cell ${vdu_cells_dict['${cell_id}']} is active  console=${log_to_console}
      Sleep  2s
    END
    Log  ${ok_prefix_green}Step 3: Block all cells on radio module  console=${log_to_console}

Step 4: Check Radio Module Power State When All Cells Are Blocked
    Log  ${dots_prefix_green}Step 4: Check radio module Power State (all cells blocked)  console=${log_to_console}
    Log  ${info_prefix}Waiting for radio module power state (SLEEP). Please wait grace period (${grace_period})...
    ...  console=${log_to_console}
    RMOD Wait For Expected State  rmod_sn=${rmod_sn}  rmod_state=power_state  rmod_state_value=SLEEP  timeout=${grace_period}
    ${rmod_power_state}=  RMOD Get Current State  rmod_sn=${rmod_sn}  rmod_state=power_state
    Log  ${info_prefix}Radio module (sn: ${rmod_sn}) power state is now: ${rmod_power_state}  console=${log_to_console}
    Log  ${ok_prefix_green}Step 4: Check radio module Power State (all cells blocked)  console=${log_to_console}

Step 5: Unblock One Random Cell On Radio Module
    Log  ${dots_prefix_green}Step 5: Unblock one random cell on radio module  console=${log_to_console}
    ${random_cell_id}=  Evaluate  random.choice($cell_id_list)  random
    Set Test Variable  ${random_cell_id}
    vDU Unblock Cell And Check  cell_id=${random_cell_id}
    Cell Wait For Expected State  cell_id=${random_cell_id}  cell_state=blocking_state  cell_state_value=Unblocked
    Cell Wait For Expected State  cell_id=${random_cell_id}  cell_state=operational_state  cell_state_value=disabled
    ${alarming_object_list}=  Create List  MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-${random_cell_id}
    vDU Assert Alarm Inactive  fault_id=49  alarming_object_list=${alarming_object_list}
    ...  alarm_severity_list=${alarm_severity_list}  vdu_login=False
    Log  ${ok_prefix_green}Unblock cell (cell identity: ${vdu_cells_dict['${random_cell_id}']}) operation succeeded
    ...  console=${log_to_console}
    Log  ${info_prefix}Alarm (faultId:49) on cell ${vdu_cells_dict['${random_cell_id}']} is inactive  console=${log_to_console}
    Log  ${ok_prefix_green}Step 5: Unblock one random cell on radio module  console=${log_to_console}

Step 6: Check Radio Module Power State After One Cell Unblocked
    Log  ${dots_prefix_green}Step 6: Check radio module Power State after one cell unblocked  console=${log_to_console}
    Log  ${info_prefix}Waiting for radio module power state (AWAKE). Please wait grace period (${grace_period}) ...
    ...  console=${log_to_console}
    RMOD Wait For Expected State  rmod_sn=${rmod_sn}  rmod_state=power_state  rmod_state_value=AWAKE  timeout=${grace_period}
    ${rmod_power_state}=  RMOD Get Current State  rmod_sn=${rmod_sn}  rmod_state=power_state
    Log  ${info_prefix}Radio module (sn: ${rmod_sn}) power state is now: ${rmod_power_state}  console=${log_to_console}
    Log  ${ok_prefix_green}Step 6: Check radio module Power State after one cell unblocked  console=${log_to_console}

Step 7: Unblock All Blocked Cells On Radio Module
    Log  ${dots_prefix_green}Step 7: Unblock all blocked cells on radio module  console=${log_to_console}
    Remove Values From List  ${cell_id_list}  ${random_cell_id}
    FOR  ${cell_id}  IN  @{cell_id_list}
      vDU Unblock Cell And Check  cell_id=${cell_id}
      Cell Wait For Expected State  cell_id=${cell_id}  cell_state=blocking_state  cell_state_value=Unblocked
      Cell Wait For Expected State  cell_id=${cell_id}  cell_state=operational_state
      ...  cell_state_value=enabled  timeout=120s
      ${alarming_object_list}=  Create List  MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-${cell_id}
      vDU Assert Alarm Inactive  fault_id=49  alarming_object_list=${alarming_object_list}
      ...  alarm_severity_list=${alarm_severity_list}  vdu_login=False
      Log  ${ok_prefix_green}Unblock cell (cell identity: ${vdu_cells_dict['${cell_id}']}) operation succeeded
      ...  console=${log_to_console}
      Log  ${info_prefix}Alarm (faultId:49) on cell ${vdu_cells_dict['${cell_id}']} is inactive  console=${log_to_console}
      Sleep  2s
    END
    Log  ${info_prefix}All cells are unblocked  console=${log_to_console}
    Log  ${ok_prefix_green}Step 7: Unblock all blocked cells on radio module  console=${log_to_console}

Step 8: Check Radio Module Power State After All Cells Unblocked
    Log  ${dots_prefix_green}Step 8: Check radio module Power State after all cells unblocked  console=${log_to_console}
    Log  ${info_prefix}Waiting for radio module power state (AWAKE). Please wait grace period (${grace_period}) ...  console=${log_to_console}
    RMOD Wait For Expected State  rmod_sn=${rmod_sn}  rmod_state=power_state  rmod_state_value=AWAKE  timeout=${grace_period}
    ${rmod_power_state}=  RMOD Get Current State  rmod_sn=${rmod_sn}  rmod_state=power_state
    Log  ${info_prefix}Radio module (sn: ${rmod_sn}) power state is now: ${rmod_power_state}  console=${log_to_console}
    Log  ${ok_prefix_green}Step 8: Check radio module Power State after all cells unblocked  console=${log_to_console}

Step 9: Deactivate Energy Saving On Radio Module
    Log  ${dots_prefix_green}Step 9: Deactivate energy saving on radio module  console=${log_to_console}
    Log  ${info_prefix}Energy saving parameter (energySavingMode) setting  console=${log_to_console}
    ${energysavingmode_value}=  vdu.Search Parameter Of Current Plan  mo_dn=${energysavingmode_mo_dn}  para_name=energySavingMode
    ${updated_params_dict}=  Create Dictionary  energySavingMode=NORMAL
    ${updated_params_oper_dict}=  Create Dictionary  update=${updated_params_dict}
    ${json_parameters_update}=  Create Single Dist Name Json String  mo_dn=${energysavingmode_mo_dn}
    ...  updated_params_dict=${updated_params_oper_dict}  distname_operation=update
    Run Keyword If  '${energysavingmode_value}'=='DEEPSLEEP'  Run Keywords
    ...  Log  ${below_info_prefix}Recommissioning to deactivate deep sleep mode on radio module (energySavingMode=NORMAL) ...
    ...  console=${log_to_console}
    ...  AND
    ...  vdu.Perform Delta Recommissioning  delta_file=${json_parameters_update[0]}
    ...  wait_for_completion=True  timeout=${ACTIVATE_DELTA_PLAN_TIMEOUT}
    ${energysavingmode_value}=  vdu.Search Parameter Of Current Plan  mo_dn=${energysavingmode_mo_dn}  para_name=energySavingMode
    Log  ${below_info_prefix}Parameter "energySavingMode" is now set to "${energysavingmode_value}"  console=${log_to_console}
    ${rmod_power_state}=  RMOD Get Current State  rmod_sn=${rmod_sn}  rmod_state=power_state
    Log  ${info_prefix}Radio module (sn: ${rmod_sn}) power state is now: ${rmod_power_state}  console=${log_to_console}
    Wait Until All Cells Are OnAir  cells_count=${cells_count}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 9: Deactivate energy saving on radio module  console=${log_to_console}

Step 10: Postconditions Deep Sleep
    Log  ${dots_prefix_green}Step 9: Postconditions  console=${log_to_console}
    Wait Until All Cells Are OnAir  cells_count=${cells_count}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 9: Postconditions  console=${log_to_console}

#INTERNAL TEST CASE KEYWORDS
Radio Module Deep Sleep Mode Teardown
    [Arguments]  ${tc_status}
    [Documentation]
    ...  Description:
    ...  Keyword performs tasks that clean up or restore initial values after the test is performed (PASS or FAIL).
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | tc_status              | Yes  | The status of the current test case (keyword), either PASS or FAIL.        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Run Keyword If  '${tc_status}'=='PASS'
    ...  Run Keyword And Ignore Error  vDU Rest Logout
    Return From Keyword If  '${tc_status}'=='PASS'
    ${updated_params_dict}=  Create Dictionary  energySavingMode=NORMAL
    vDU Verify And Update Parameter Of Delta Plan
    ...  mo_dn=${energysavingmode_mo_dn}  updated_params_dict=${updated_params_dict}
    Run Keyword And Ignore Error  vDU Rest Logout
