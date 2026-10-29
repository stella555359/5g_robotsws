*** Settings ***
Documentation  TODO
...  Author: szymon.przybylak@nokia.com
...  Maintainer: szymon.przybylak@nokia.com

Library    ../../../resources/radio_operations/RadioOperations.py  WITH NAME  radio
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu
Library    taf.ul.vdu.helm.interface.helm   WITH NAME    helm
Library    taf.transport.ssh  WITH NAME  tafssh

*** Keywords ***
Reset Radio Module And Wait For OnAir
  [Arguments]  ${ru_serial_number}  ${cloud_server_ip}  ${cells_count}
  [Documentation]
  ...  Reboots radio module and waits for all cells to be back on air
  ...
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | ru_serial_number       | Yes  | RM serial number                                                           |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | cloud_server_ip        | Yes  | IP of the cloud server                                                     |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | cells_count            | Yes  | number of cells in the configuration                                       |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: dawid.bak@nokia.com
  ...  Maintainer: dawid.bak@nokia.com

  radio.Reboot Radio Module And Wait For Ping  ru_serial_number=${ru_serial_number}
  ...  reconnect_timeout=240
  ...  ping_down_timeout=60
  ...  cloud_server_ip=${cloud_server_ip}
  Wait Until All Cells Are OnAir  cells_count=${cells_count}

Enable Fail Safe Mode On RM
  [Arguments]  ${ru_serial_number}  ${cloud_server_ip}  ${cells_count}
  [Documentation]
  ...  Enables fail safe mode on RM on cloudran
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | ru_serial_number       | Yes  | RM serial number                                                           |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | cloud_server_ip        | Yes  | IP of the cloud server                                                     |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: dawid.bak@nokia.com
  ...  Maintainer: dawid.bak@nokia.com

  Log  ${start_prefix_blue}Starting enableing failsafe mode on RM  console=${log_to_console}
  radio.Enable Radio Module Fail Safe Mode  ru_serial_number=${ru_serial_number}
  ...  radio_reset=False
  ...  cloud_server_ip=${cloud_server_ip}
  Log  ${info_prefix}Waiting for radio failsafe mode statuses  console=${log_to_console}
  radio.Reboot Radio Module And Wait For Ping  ru_serial_number=${ru_serial_number}
  ...  reconnect_timeout=240
  ...  ping_down_timeout=60
  ...  cloud_server_ip=${cloud_server_ip}
#  Wait Until Keyword Succeeds  10 min  1 sec
#  ...  Wait For Radio Status  ru_serial_number=${ru_serial_number}
#        ...  expected_availability_status=failed
#        ...  expected_operational_state=disabled
#        ...  expected_procedural_status=${None}
#  Log  ${info_prefix}Waiting for autonomous reboot in failsafe mode  console=${log_to_console}
#  Wait Until Keyword Succeeds  10 min  1 sec
#  ...  Wait For Radio Status  ru_serial_number=${ru_serial_number}
#        ...  expected_availability_status=not installed
#        ...  expected_operational_state=disabled
#        ...  expected_procedural_status=not initialized
  Log  ${info_prefix}Waiting for final radio failsafe mode statuses  console=${log_to_console}
  Wait Until Keyword Succeeds  10 min  1 sec
  ...  Wait For Radio Status  ru_serial_number=${ru_serial_number}
        ...  expected_availability_status=failed
        ...  expected_operational_state=disabled
        ...  expected_procedural_status=${None}
  Log  ${done_prefix_blue}Done enableing failsafe mode on RM  console=${log_to_console}

Disable Fail Safe Mode On RM
  [Arguments]  ${ru_serial_number}  ${cloud_server_ip}  ${cells_count}
  [Documentation]
  ...  Disables fail safe mode on RM on cloudran
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | ru_serial_number       | Yes  | RM serial number                                                           |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | cloud_server_ip        | Yes  | IP of the cloud server                                                     |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | cells_count            | Yes   | Number of cells in the configuration                                      |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: dawid.bak@nokia.com
  ...  Maintainer: dawid.bak@nokia.com

  Log  ${start_prefix_blue}Starting disableing failsafe mode on RM  console=${log_to_console}
  radio.Disable Radio Module Fail Safe Mode  ru_serial_number=${ru_serial_number}
  ...  radio_reset=False
  ...  cloud_server_ip=${cloud_server_ip}
  radio.Reboot Radio Module And Wait For Ping  ru_serial_number=${ru_serial_number}
  ...  reconnect_timeout=240
  ...  ping_down_timeout=60
  ...  cloud_server_ip=${cloud_server_ip}
  Log  ${info_prefix}Waiting for all cells onAir  console=${log_to_console}
  Wait Until All Cells Are OnAir  cells_count=${cells_count}
  Log  ${done_prefix_blue}Done disableing failsafe mode on RM  console=${log_to_console}

Wait For Radio Status
  [Arguments]  ${ru_serial_number}  ${expected_availability_status}  ${expected_operational_state}
  ...          ${expected_procedural_status}

  ${rmod_status}=  vdu.Get Rmods Status
  FOR  ${rmod}  IN  @{rmod_status}
    ${serial_number}=  Get From Dictionary  dictionary=${rmod}  key=serial_number
    Continue For Loop If  '${serial_number}'!='${ru_serial_number}'
    ${availability_status}=  Get From Dictionary  dictionary=${rmod}  key=availability_status
    ${operational_state}=  Get From Dictionary  dictionary=${rmod}  key=operational_state
    ${procedural_status}=  Get From Dictionary  dictionary=${rmod}  key=procedural_status
    Exit For Loop
  END
  Should Be Equal As Strings  ${availability_status}  ${expected_availability_status}
  Should Be Equal As Strings  ${operational_state}  ${expected_operational_state}
  Should Be Equal As Strings  ${procedural_status}  ${expected_procedural_status}

Get Pod Name
  [Arguments]  ${namespace}  ${pod_name}

  ${matching_pod_names_list}=  Create List
  ${pods_info_list}=  vdu.Get Pods Info
  FOR  ${pod}  IN  @{pods_info_list}
    ${pod_full_name}=  Get From Dictionary  dictionary=${pod}
    ...  key=name
    ${status}=  Run Keyword And Return Status  Should Match Regexp  string=${pod_full_name}
    ...  pattern=\\w+-${namespace}-${pod_name}
    Run Keyword If  ${status}
    ...  Append To List  ${matching_pod_names_list}  ${pod_full_name}
  END
  Length Should Be  item=${matching_pod_names_list}
  ...  length=1
  ...  msg=Found none or more than one matching pod
  [Return]  ${matching_pod_names_list}[0]
