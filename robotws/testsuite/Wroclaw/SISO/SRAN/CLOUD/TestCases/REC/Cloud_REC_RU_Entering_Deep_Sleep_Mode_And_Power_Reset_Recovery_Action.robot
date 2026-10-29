*** Settings ***
Documentation
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    Collections
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu

Resource    ../../resources/Robot/vdu_oam_operations.robot
Resource    ../../resources/Robot/setup_teardown.robot
Resource    ../../../resources/Robot/pdu.robot
Resource    ./Cloud_REC_RU_Entering_Deep_Sleep_Mode_And_Returning_By_One_Cell_Unblock.robot

*** Variables ***
@{VDU_RESET_RECOVERY_ALLOWED_HIST_ALARMS}=  faultId=49, severity=critical
...                        faultId=10, severity=critical
...                        faultId=4589, severity=warning
...                        faultId=4523, severity=warning
@{VCU_RESET_RECOVERY_ALLOWED_HIST_ALARMS}=  faultId=7104, severity=critical

*** Keywords ***
TC__Cloud_REC_RU_Entering_Deep_Sleep_Mode_And_Power_Reset_Recovery_Action
    [Arguments]  ${scfc_file_path}  ${rmod_sn_list}  ${rmod_sn_count}=0  ${grace_period}=10min  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_VRF_SISO-3180
    ...  Test case for CB007065-CR-E parity feature.
    ...  The feature CB007065 provides energy saving functionalities on Cloud-based gNB
    ...  as originally introduced by legacy features with Classical gNB solution.
    ...
    ...  The purpose of this test case is to place the radio module into sleep mode
    ...  and perform recovery action by radio module reset.
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
    ...  Power reset of the radio module is performed while the radio module is in deep sleep mode.
    ...  After power reset radio module starts up in normal mode (power_state=AWAKE).
    ...  Radio module waits for a given grace period before it enters back into the deep sleep mode.
    ...  Exiting deep sleep mode in this test occurs after unlocking all cells on the radio module.
    ...
    ...  Step 1: Initial Check Deep Sleep
    ...  a) vDU operation state is OnAir (operational_state=OnAir)
    ...  b) All cells are OnAir
    ...     Cells expected states: operational_state = enabled
    ...                            administrative_state = unlocked
    ...                            availability_status = on_line
    ...  Step 2: Activate Energy Saving On Radio Module
    ...  a) Radio module power state: power_state = AWAKE
    ...  b) Set parameter "energySavingMode" to "DEEPSLEEP".
    ...  c) Radio module power state: power_state = AWAKE
    ...  Step 3: Block All Cells On Radio Module
    ...  a) All cells block operation is successful
    ...  b) Cells expected states: blocking_state = Blocked
    ...                            operational_state = disabled
    ...  c) Alarm (fault id=49) on all cells is active
    ...  Step 4: Check Radio Module Power State When All Cells Are Blocked
    ...  a) After grace period radio module have expected state:
    ...     Radio module power state: power_state = SLEEP
    ...  Step 5: Power Reset Radio Module
    ...  a) Radio module turned off via PDU.
    ...     Radio module expected power state:
    ...                                administrative_state = Unlocked
     ...                               operational_state = disabled
     ...                               availability_status = not installed
    ...                                power_state = SLEEP
    ...  b) Alarm (fault id=10) is active.
    ...  c) Radio module turned on via PDU.
    ...     Radio module expected power state:
    ...                                administrative_state = Unlocked
    ...                                operational_state = enabled
    ...                                availability_status = on line
    ...                                power_state = AWAKE
    ...  d) Alarm (fault id=10) is inactive.
    ...  Step 6: Check Radio Module Power State After Power Reset
    ...  a) After grace period radio module have expected state
    ...     Radio module power state: power_state = SLEEP
    ...  Step 7: Unblock All Cells On Radio Module
    ...  a) Cells unblock operation is successful
    ...  b) Cells expected states: blocking_state = Unblocked
    ...                            operational_state = disabled
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
    Append To List  ${VDU_HISTORICAL_ALLOWED_ALARMS}  @{VDU_RESET_RECOVERY_ALLOWED_HIST_ALARMS}
    Append To List  ${VCU_HISTORICAL_ALLOWED_ALARMS}  @{VCU_RESET_RECOVERY_ALLOWED_HIST_ALARMS}
    Log  ${start_prefix_green}Test Case: RU Entering Deep Sleep Mode And Power Reset Recovery Action  console=${log_to_console}
    Step 1: Initial Check Deep Sleep
    FOR  ${rmod_sn}  IN  @{rmod_serial_number_list}
      Set Test Variable  ${rmod_sn}
      Step 2: Activate Energy Saving On Radio Module
      Step 3: Block All Cells On Radio Module
      Step 4: Check Radio Module Power State When All Cells Are Blocked
      Step 5: Power Reset Radio Module
      Step 6: Check Radio Module Power State After Power Reset
      Step 7: Unblock All Cells On Radio Module
      Step 8: Check Radio Module Power State After All Cells Unblocked
      Step 9: Deactivate Energy Saving On Radio Module
    END
      Step 10: Postconditions Deep Sleep
    Log  ${done_prefix_green}Test Case: RU Entering Deep Sleep Mode And Power Reset Recovery Action  console=${log_to_console}
    [Teardown]  Radio Module Deep Sleep Mode Teardown  tc_status=${KEYWORD_STATUS}

Step 5: Power Reset Radio Module
    Log  ${dots_prefix_green}Step 5: Power reset radio module  console=${log_to_console}
    Log  ${info_prefix}Radio module (sn: ${rmod_sn}) has been powered off  console=${log_to_console}
    Log  ${info_prefix}Waiting for radio module (sn: ${rmod_sn}) offline status ...  console=${log_to_console}
    Wait Until Keyword Succeeds  60s  20s
    ...  PDU Turn Off Radio Module  rmod_sn=${rmod_sn}
    RMOD Wait For Offline  rmod_sn=${rmod_sn}
    RMOD Wait For Expected State  rmod_sn=${rmod_sn}  rmod_state=power_state  rmod_state_value=SLEEP  timeout=5s
    Log  ${info_prefix}Radio module (sn: ${rmod_sn}) is offline now  console=${log_to_console}
    Log  ${info_prefix}Waiting for alarm activation (fault id=10) ...  console=${log_to_console}
    ${alarm_severity_list}=  Create List  Critical
    vDU Assert Alarm Active  fault_id=10  alarm_severity_list=${alarm_severity_list}
    ...  vdu_login=False  timeout=10min
    Log  ${info_prefix}Alarm (fault id=10) is active now  console=${log_to_console}
    Wait Until Keyword Succeeds  60s  20s
    ...  PDU Turn On Radio Module  rmod_sn=${rmod_sn}
    Log  ${info_prefix}Radio module (sn: ${rmod_sn}) has been powered on  console=${log_to_console}
    Log  ${info_prefix}Waiting for alarm deactivation (fault id=10) ...  console=${log_to_console}
    vDU Assert Alarm Inactive  fault_id=10  alarm_severity_list=${alarm_severity_list}
    ...  vdu_login=False  timeout=10min
    Log  ${info_prefix}Alarm (fault id=10) is inactive now  console=${log_to_console}
    ${rmod_hardware_release}=  vDU RMOD Get Parameter Value Based On Serial Number
    ...  rmod_sn=${rmod_sn}  rmod_param=hardware_release
    Log  ${info_prefix}Radio module (sn: ${rmod_sn}) hardware release: ${rmod_hardware_release}
    ...  console=${log_to_console}
#    ${rmod_hardware_release}=  Get Regexp Matches  string=${rmod_hardware_release}  pattern=\\d.\\d
#    Run Keyword If  ${rmod_hardware_release}==@{EMPTY}
#    ...  Run Keyword And Continue On Failure
#    ...  Fail  msg=Radio module (sn: ${rmod_sn}) has no number hardware release. Please contact with TA Team !
#    ...  ELSE
#    ...  Run Keyword If  ${rmod_hardware_release[0]}>=5.1
#    ...  vDU Check Unit Power Reset Alarm  log_prefix=${info_prefix}  log_to_console=${log_to_console}
    vDU Check Unit Power Reset Alarm  log_prefix=${info_prefix}  log_to_console=${log_to_console}
    Log  ${info_prefix}Waiting for radio module (sn: ${rmod_sn}) online status ...  console=${log_to_console}
    RMOD Wait For Online  rmod_sn=${rmod_sn}
    Log  ${info_prefix}Radio module (sn: ${rmod_sn}) is online now  console=${log_to_console}
    RMOD Wait For Expected State  rmod_sn=${rmod_sn}  rmod_state=power_state  rmod_state_value=AWAKE  timeout=5s
    ${rmod_power_state}=  RMOD Get Current State  rmod_sn=${rmod_sn}  rmod_state=power_state
    Log  ${info_prefix}Radio module (sn: ${rmod_sn}) power state is now: ${rmod_power_state}  console=${log_to_console}
    Log  ${ok_prefix_green}Step 5: Power reset radio module  console=${log_to_console}

Step 6: Check Radio Module Power State After Power Reset
    Log  ${dots_prefix_green}Step 6: Check radio module Power State after power reset  console=${log_to_console}
    Log  ${info_prefix}Waiting for radio module power state (SLEEP). Please wait grace period (${grace_period}) ...
    ...  console=${log_to_console}
    RMOD Wait For Expected State  rmod_sn=${rmod_sn}  rmod_state=power_state  rmod_state_value=SLEEP  timeout=${grace_period}
    ${rmod_power_state}=  RMOD Get Current State  rmod_sn=${rmod_sn}  rmod_state=power_state
    Log  ${info_prefix}Radio module (sn: ${rmod_sn}) power state is now: ${rmod_power_state}  console=${log_to_console}
    Log  ${ok_prefix_green}Step 4: Check radio module Power State after power reset  console=${log_to_console}

Step 7: Unblock All Cells On Radio Module
    Log  ${dots_prefix_green}Step 7: Unblock all cells on radio module  console=${log_to_console}
    FOR  ${cell_id}  IN  @{cell_id_list}
      vDU Unblock Cell And Check  cell_id=${cell_id}
      Cell Wait For Expected State  cell_id=${cell_id}  cell_state=blocking_state  cell_state_value=Unblocked
      Cell Wait For Expected State  cell_id=${cell_id}  cell_state=operational_state  cell_state_value=disabled
      ${alarming_object_list}=  Create List  MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-${cell_id}
      ${alarm_severity_list}=  Create List  Critical
      vDU Assert Alarm Inactive  fault_id=49  alarming_object_list=${alarming_object_list}
      ...  alarm_severity_list=${alarm_severity_list}  vdu_login=False
      Log  ${ok_prefix_green}Unblock cell (cell identity: ${vdu_cells_dict['${cell_id}']}) operation succeeded
      ...  console=${log_to_console}
      Log  ${info_prefix}Alarm (faultId:49) on cell ${vdu_cells_dict['${cell_id}']} is inactive  console=${log_to_console}
      Sleep  2s
    END
    Log  ${info_prefix}All cells are unblocked  console=${log_to_console}
    Log  ${ok_prefix_green}Step 7: Unblock all cells on radio module  console=${log_to_console}
