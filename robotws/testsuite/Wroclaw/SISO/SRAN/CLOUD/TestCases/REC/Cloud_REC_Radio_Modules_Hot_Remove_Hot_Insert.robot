*** Settings ***
Documentation
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu

Resource    ../../resources/Robot/vdu_oam_operations.robot
Resource    ../../../resources/Robot/scfc.robot
Resource    ../../resources/Robot/setup_teardown.robot
Resource    ../../resources/Robot/optical_switch.robot

*** Variables ***
@{VDU_HOT_REMOVE_HOT_INSERT_ALLOWED_HIST_ALARMS}=  faultId=10, severity=critical
...                        faultId=4589, severity=warning
...                        faultId=4523, severity=warning
@{VCU_HOT_REMOVE_HOT_INSERT_ALLOWED_HIST_ALARMS}=  faultId=7104, severity=critical

*** Keywords ***
TC__Cloud_REC_Radio_Modules_Hot_Remove_Hot_Insert
    [Arguments]  ${scfc_file_path}  ${switch_settings_off}  ${switch_settings_on}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword performs hot remove and hot insert process on switch with given settings
    ...  for given radio module serial number.
    ...  Example:
    ...  @{L1181111027_OFF}     4  1  1  1  1  1
    ...  @{K9190632580_OFF}     1  4  1  1  1  1
    ...  @{L1181111027_ON}      1  1  1  1  1  1
    ...  @{K9190632580_ON}      1  1  1  1  1  1
    ...
    ...  &{SWITCH_OFF_ALL_DICT}  L1181111027=@{L1181111027_OFF}  K9190632580=@{K9190632580_OFF}
    ...  &{SWITCH_ON_ALL_DICT}   L1181111027=@{L1181111027_ON}   K9190632580=@{K9190632580_ON}
    ...
    ...
    ...  Step 1: All cells are OnAir
    ...  Cells expected states: operational_state = enabled
    ...                         administrative_state = unlocked
    ...                         availability_status = on_line
    ...  Step 2: Hot remove - change optical switch to OFF position
    ...  Step 3: Wait for radio module expected states
    ...  Radio module expected states: operational_state = disabled
    ...                                administrative_state = Unlocked
    ...                                availability_status = not installed
    ...  Step 4: Alarm with fault id 10 is active
    ...  Step 5: Hot insert - change optical swtich to ON position
    ...  Step 6: Wait for radio module expected states
    ...  Radio module expected states: operational_state = enabled
    ...                                administrative_state = Unlocked
    ...                                availability_status = on line
    ...  Step 7: Alarm with fault id 10 is inactive
    ...  Step 8: vDU operation state is OnAir (operational_state=OnAir)
    ...  No unexpected alarm is visible
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | switch_settings_off    | Yes  | Switch OFF settings.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | switch_settings_on     | Yes  | Switch ON settings.                                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Usage:
    ...  RMODs Hot Remove Hot Insert  scfc_file_path=${VDU_SCF_PATH}
    ...  switch_settings_off=${SWITCH_OFF_ALL_DICT}  switch_settings_on=${SWITCH_ON_ALL_DICT}
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Log  ${start_prefix_green}Test Case: RMODs Hot Remove Hot Insert  console=${log_to_console}
    Append To List  ${VDU_HISTORICAL_ALLOWED_ALARMS}  @{VDU_HOT_REMOVE_HOT_INSERT_ALLOWED_HIST_ALARMS}
    Append To List  ${VCU_HISTORICAL_ALLOWED_ALARMS}  @{VCU_HOT_REMOVE_HOT_INSERT_ALLOWED_HIST_ALARMS}
    vDU Rest Login
    ${cells_count}=  vDU SCFC Get NRCELL Count  scfc_file_path=${scfc_file_path}
    ${rmod_sn_list}=  vDU SCFC Get RMOD Serial Number List  scfc_file_path=${scfc_file_path}
    ${sn_list}=  Get Dictionary Keys  dictionary=${switch_settings_off}
    Wait Until All Cells Are OnAir  cells_count=${cells_count}
    Log  ${ok_prefix_green}All cells are OnAir  console=${log_to_console}
    FOR  ${rmod_sn}  IN  @{sn_list}
      List Should Contain Value  ${rmod_sn_list}  ${rmod_sn}
      ${channel_setup_off}=  Get From Dictionary  dictionary=${switch_settings_off}  key=${rmod_sn}
      Set Optical Switch  channel_setup=${channel_setup_off}  log_prefix=${info_prefix}
      Log  ${ok_prefix_green}Radio module (sn: ${rmod_sn}) has been disconnected  console=${log_to_console}
      RMOD Wait For Offline  rmod_sn=${rmod_sn}
      Log  ${info_prefix}Radio module (sn: ${rmod_sn}) is offline now  console=${log_to_console}
      Log  ${dots_prefix_green}Waiting for Fault 10 ...  console=${log_to_console}
      vDU Assert Alarm Active  fault_id=10  vdu_login=False  timeout=10min
      Log  ${ok_prefix_green}Fault 10 has been detected  console=${log_to_console}
      ${channel_setup_on}=  Get From Dictionary  dictionary=${switch_settings_on}  key=${rmod_sn}
      Set Optical Switch  channel_setup=${channel_setup_on}  log_prefix=${info_prefix}
      Log  ${ok_prefix_green}Radio module (sn: ${rmod_sn}) has been connected  console=${log_to_console}
      RMOD Wait For Online  rmod_sn=${rmod_sn}
      Log  ${info_prefix}Radio module (sn: ${rmod_sn}) is online now  console=${log_to_console}
      vDU Assert Alarm Inactive  fault_id=10  vdu_login=False  timeout=10min
      Wait Until All Cells Are OnAir  cells_count=${cells_count}
      Log  ${ok_prefix_green}All cells are OnAir  console=${log_to_console}
    END
    Log  ${done_prefix_green}Test Case: RMODs Hot Remove Hot Insert  console=${log_to_console}
    [Teardown]  Run Keyword And Ignore Error  vDU Rest Logout
