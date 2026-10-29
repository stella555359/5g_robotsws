*** Settings ***
Documentation
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu

Resource    ../../resources/Robot/vdu_oam_operations.robot
Resource    ../../../resources/Robot/scfc.robot
Resource    ../../resources/Robot/setup_teardown.robot
Resource    ../../../resources/Robot/pdu.robot

*** Variables ***
${RMOD_POWER_RESET_VDU_CELLS_ONAIR_TIMEOUT}=  300s
@{VDU_POWER_RESET_ALLOWED_HIST_ALARMS}=  faultId=10, severity=critical
...                        faultId=4589, severity=warning
...                        faultId=4523, severity=warning
@{VCU_POWER_RESET_ALLOWED_HIST_ALARMS}=  faultId=7104, severity=critical

*** Keywords ***
TC__Cloud_STARTUP_Radio_Modules_Power_Reset
    [Arguments]  ${vdu_scfc_file_path}  ${rmod_sn_list}=@{EMPTY}  ${rmod_sn_count}=0
    ...  ${vdu_connection}=default  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Test case performs a power reset of the radio modules.
    ...
    ...  Step 1: Initial Check Radio Modules Power Reset
    ...  a) All radio modules should be on line
    ...  b) All cells should be OnAir
    ...  c) vDU operational state should be onAir
    ...  Step 2: Turn Off Radio Module
    ...          Radio module turn off operation is successful
    ...  Step 3: Step 3: Check Radio Module State And Alarms After Turning Off
    ...          Radio module expected states: operational_state = disabled
    ...                                        administrative_state = Unlocked
    ...                                        availability_status = not installed
    ...          Alarm with fault id 10 is active
    ...  Step 4: Turn On Radio Module
    ...          Radio module turn on operation is successful
    ...  Step 5: Check Radio Module State And Alarms After Turning On
    ...          Radio module expected states: operational_state = enabled
    ...                                        administrative_state = Unlocked
    ...                                        availability_status = on line
    ...          Alarm with fault id 10 is inactive
    ...          For radio modules hardware release >=5.1:
    ...          Alarm with fault id 4589 is active
    ...          Alarm with fault id 4589 is inactive
    ...  Step 6: Postconditions Radio Modules Power Reset
    ...  a) The same values as in Step 1
    ...  No unexpected alarms are visible
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_scfc_file_path     |  Yes | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_sn_list           |      | List of serial number of the tested radio modules.                         |
    ...  |                        |  No  | @{EMPTY} value means that no list was given,                               |
    ...  |                        |      | so all radio modules defined in the SCFC file will be used.                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_sn_count          |  No  | Number of randomly selected radio modules serial numbers based on          |
    ...  |                        |      | the list obtained from the SCFC file.                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Set Test Variable  ${vdu_scfc_file_path}
    Set Test Variable  ${rmod_sn_list}
    Set Test Variable  ${rmod_sn_count}
    Set Test Variable  ${vdu_connection}
    Set Test Variable  ${log_to_console}
    Log  ${start_prefix_green}Test Case: Radio_Modules_Power_Reset  console=${log_to_console}
    Step 1: Initial Check Radio Modules Power Reset
    FOR  ${rmod_sn}  IN  @{rmod_serial_number_list}
      Set Test Variable  ${rmod_sn}
      Step 2: Turn Off Radio Module
      Step 3: Check Radio Module State And Alarms After Turning Off
      Step 4: Turn On Radio Module
      Step 5: Check Radio Module State And Alarms After Turning On
    END
    Step 6: Postconditions Radio Modules Power Reset
    Log  ${done_prefix_green}Test Case: Radio_Modules_Power_Reset console=${log_to_console}
    [Teardown]  Run Keyword And Ignore Error  vDU Rest Logout  vdu_connection=${vdu_connection}

Step 1: Initial Check Radio Modules Power Reset
    Log  ${dots_prefix_green}Step 1: Initial check radio modules power reset  console=${log_to_console}
    Append To List  ${VDU_HISTORICAL_ALLOWED_ALARMS}  @{VDU_POWER_RESET_ALLOWED_HIST_ALARMS}
    Append To List  ${VCU_HISTORICAL_ALLOWED_ALARMS}  @{VCU_POWER_RESET_ALLOWED_HIST_ALARMS}
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
    ${rmod_serial_number_list}=  Get Radio Modules Serial Numbers List
    ...  scfc_file_path=${vdu_scfc_file_path}
    ...  rmod_sn_list=${rmod_sn_list}
    ...  rmod_sn_count=${rmod_sn_count}
    Set Test Variable  ${rmod_serial_number_list}
    Log  ${ok_prefix_green}Step 1: Initial check radio modules power reset  console=${log_to_console}

Step 2: Turn Off Radio Module
    Log  ${dots_prefix_green}Step 2: Turn off radio module  console=${log_to_console}
    Log  ${info_prefix}Radio module (sn: ${rmod_sn}) has been powered off  console=${log_to_console}
    PDU Turn Off Radio Module
    ...  rmod_sn=${rmod_sn}
    Log  ${ok_prefix_green}Step 2: Turn off radio module  console=${log_to_console}

Step 3: Check Radio Module State And Alarms After Turning Off
    Log  ${dots_prefix_green}Step 3: Check radio module state and alarms after turning off  console=${log_to_console}
    RMOD Wait For Offline
    ...  rmod_sn=${rmod_sn}
    ...  timeout=300s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}Radio module (sn: ${rmod_sn}) is offline now  console=${log_to_console}
    Log  ${info_prefix}Waiting for alarm activation (fault id=10) ...  console=${log_to_console}
    ${alarm_severity_list}=  Create List  critical
    vDU Assert Alarm Active
    ...  fault_id=10
    ...  alarm_severity_list=${alarm_severity_list}
    ...  timeout=10min
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}Alarm (fault id=10) is active now  console=${log_to_console}
    Log  ${info_prefix}Waiting for radio module (sn: ${rmod_sn}) offline status ...  console=${log_to_console}
    RMOD Wait For Offline
    ...  rmod_sn=${rmod_sn}
    ...  timeout=120s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}Radio module (sn: ${rmod_sn}) is offline now  console=${log_to_console}
    Log  ${ok_prefix_green}Step 3: Check radio module state and alarms after turning off  console=${log_to_console}

Step 4: Turn On Radio Module
    Log  ${dots_prefix_green}Step 4: Turn on radio module  console=${log_to_console}
    PDU Turn On Radio Module
    ...  rmod_sn=${rmod_sn}
    Log  ${info_prefix}Radio module (sn: ${rmod_sn}) has been powered on  console=${log_to_console}
    Log  ${ok_prefix_green}Step 4: Turn on radio module  console=${log_to_console}

Step 5: Check Radio Module State And Alarms After Turning On
    Log  ${dots_prefix_green}Step 5: Check radio module state and alarms after turning on  console=${log_to_console}
    Log  ${info_prefix}Waiting for alarm deactivation (fault id=10) ...  console=${log_to_console}
    ${alarm_severity_list}=  Create List  critical
    vDU Assert Alarm Inactive
    ...  fault_id=10
    ...  alarm_severity_list=${alarm_severity_list}
    ...  timeout=10min
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}Alarm (fault id=10) is inactive now  console=${log_to_console}
    ${rmod_hardware_release}=  vDU RMOD Get Parameter Value Based On Serial Number
    ...  rmod_sn=${rmod_sn}
    ...  rmod_param=hardware_release
    Log  ${info_prefix}Radio module (sn: ${rmod_sn}) hardware release: ${rmod_hardware_release}
    ...  console=${log_to_console}
    vDU Check Unit Power Reset Alarm
    ...  log_prefix=${info_prefix}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}Waiting for radio module (sn: ${rmod_sn}) online status ...  console=${log_to_console}
    RMOD Wait For Online
    ...  rmod_sn=${rmod_sn}
    ...  timeout=300s
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}Radio module (sn: ${rmod_sn}) is online now  console=${log_to_console}
# Wait until all cells are OnAir
    Wait Until All Cells Are OnAir
    ...  cells_count=${vdu_scfc_nrcells_count}
    ...  timeout=${RMOD_POWER_RESET_VDU_CELLS_ONAIR_TIMEOUT}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 5: Check radio module state and alarms after turning on  console=${log_to_console}

Step 6: Postconditions Radio Modules Power Reset
    Log  ${dots_prefix_green}Step 6: Postconditions radio modules power reset  console=${log_to_console}
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
    Log  ${ok_prefix_green}Step 6: Postconditions radio modules power reset  console=${log_to_console}
