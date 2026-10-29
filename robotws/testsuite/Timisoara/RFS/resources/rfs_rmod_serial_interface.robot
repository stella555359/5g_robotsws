*** Settings ***
Documentation    Keywords for RMOD Serial Interface
Library  taf.hw.rf_diagnostic_card  WITH NAME  rsi

*** Keywords ***
RSI prepare log directory and connections setup
    [Documentation]
    ...  Sets up taf.hw.rf_diagnostic_card library, sets main log directory and passes yaml option file to library
    ...
    ...  *AUTHOR*
    ...  valentin.marian@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter          | Man. | Default | Description                                                                    |
    ...  | main_log_directory | Yes  |         | folder where to save library logs                                              |
    ...  | custom_yaml        | No   | None    | yaml file with custom options for RMODs such as commands to launch after login |
    ...
    ...  *RETURN*
    ...  | Parameter             | Description                                        |
    ...  | rsi_setup_library_status | Setup RMOD status: PASS or FAIL                 |
    ...  | rsi_setup_library_info   | Possible informative output of library setup    |
    ...
    [Arguments]  ${main_log_directory}  ${custom_yaml}=${None}

    ${rsi_setup_library_status}  ${rsi_setup_library_info}=  Run Keyword And Ignore Error
    ...  rsi.Prepare Log Directory And Connection Setup  main_log_directory=${main_log_directory}
    ...  connection_setup=${custom_yaml}

    [Return]  ${rsi_setup_library_status}  ${rsi_setup_library_info}

RSI Setup RMOD Connection
    [Documentation]
    ...  Sets up serial connection to requested RMOD.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter        | Man. | Default | Description                                                        |
    ...  | ru_init_config   | Yes  |         | RU object from init.py file                                        |
    ...  | connection       | Yes  | None    | name which should be given to the new RMOD connection              |
    ...  | log_to_console   | No   | True    | Flag indicating whether library output should be logged to console |
    ...
    ...  *RETURN*
    ...  | Parameter             | Description                     |
    ...  | rsi_setup_rmod_status | Setup RMOD status: PASS or FAIL |
    ...
    [Arguments]  ${ru_init_config}  ${connection}=${None}  ${log_to_console}=${False}
    [Timeout]    600

    ${rsi_setup_rmod_status}  ${rsi_setup_rmod_info}=  Run Keyword And Ignore Error  rsi.Setup Connections
    ...  ru_config=${ru_init_config}  alias=${connection}  log_to_console=${log_to_console}

     ${rsi_setup_rmod_info_is_list}=  Evaluate  "${rsi_setup_rmod_info.__class__.__name__}"=="list"
     ${rsi_setup_rmod_info}=  Run Keyword If  ${rsi_setup_rmod_info_is_list}
     ...  Evaluate  " ".join(@{rsi_setup_rmod_info})
     ...  ELSE  Remove String Using Regexp  ${rsi_setup_rmod_info}  \s  \n  \t

    Run Keyword If  '${rsi_setup_rmod_status}' == 'FAIL'
    ...  Return From Keyword  ${rsi_setup_rmod_status}

    ${rsi_setup_rmod_status}=  Set Variable If  '${connection}' in '${rsi_setup_rmod_info}'
    ...  PASS  FAIL

    [Return]    ${rsi_setup_rmod_status}

RSI Snapshot Collect
    [Documentation]
    ...  For a number of RMODs performs Take Snapshot and returns a dictionary containing for each RMOD, the path on it where the snapshot is located
    ...  it later.
    ...  Through Take Snapshot KW, it attempts to transfer snapshot from RMOD to VM.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter           | Man.  | Default | Description                                                                                    |
    ...  | rsi_folder          | Yes   | None    | Folder on VM where the file containing RMOD snapshot info, is located                          |
    ...  | rmod_sn_list        | No    | None    | List of RMOD SN where the snapshot should not be performed                                     |
    ...  | rsi_rmod_setup_list | No    | None    | List of RMOD SN on which the serial connection is established                                  |
    ...  | target_path_on_vm   | No    | None    | path on VM where Snapshot si transferred from RMOD. By default ${Test Results Dir}/RSILogs     |
    ...  | reset_rmod          | No    | None    | Flag to recover RMOD through command line reboot, if RMOD is not reachable any more by BTS     |
    ...  | stop_and_fix        | No    | None    | Flag indicating that RMOD will not be recovered, if True. It has priority over Reset_Rmod flag |
    ...  | timeout             | No    | 240     | Maximum time to wait for snapshot generation, by default 240 secs                              |
    ...
    ...  *RETURN*
    ...  | Parameter                   | Description                                                      |
    ...  | rsi_rmod_snapshot_path_dict | Dictionary containing rmod_sn as key, and snapshot path as value |

    [Arguments]  ${rsi_folder}  ${rmod_sn_list}=${None}  ${rsi_rmod_setup_list}=${None}
    ...  ${reset_rmod}=${False}  ${stop_and_fix}=${False}  ${timeout}=240

    Log  RSI snapshot collect on RMODs  console=True

    ${rsi_rmod_sn_snapshot_path_dict}=  Create Dictionary

    FOR  ${rmod_sn}  IN  @{rsi_rmod_setup_list}

        Continue For Loop If   not ${rmod_sn_list} or '${rmod_sn}' not in ${rmod_sn_list}

        ${rsi_rmod_snapshot_status}  ${rsi_rmod_snapshot_info}=  RSI Take Snapshot  connection=${rmod_sn}
        ...  reset_rmod=${reset_rmod}  stop_and_fix=${stop_and_fix}  timeout=${timeout}
        Run Keyword If  ${rsi_rmod_snapshot_status}  Run Keywords
        ...  Set To Dictionary  ${rsi_rmod_sn_snapshot_path_dict}  ${rmod_sn}  ${rsi_rmod_snapshot_info}
        ...  AND  RSI Export RMOD Snapshot Info To File
        ...  rsi_rmod_snapshot_info=RMOD ${rmod_sn} - ${rsi_rmod_snapshot_info}  rsi_folder=${rsi_folder}
        ...  ELSE IF  not ${rsi_rmod_snapshot_status}
        ...  Log  - Snapshot collect for RMOD (sn=${rmod_sn}) failed!  console=True

    END

    [Return]  ${rsi_rmod_sn_snapshot_path_dict}

RSI Take Snapshot
    [Documentation]
    ...  Provides dictionary info with key as RMOD serial number and value as path to secured snapshot on RMOD non-volatile memory for user to fetch
    ...  it later.
    ...  If RMOD is unreachable by BTS, attempts to recover the RMOD by reboot.
    ...  Attempts to transfer the Snapshot from RMOD, to VM, in folder ${target_path_on_vm} .
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter         | Man.  | Default | Description                                                                                      |
    ...  | connection        | Yes   | None    | Alias of RMOD wwhere snapshot is being triggered                                                 |
    ...  | target_path_on_vm | No    | None    | path on VM where Snapshot is transferred from RMOD. By default ${Test Results Dir}/RSILogs       |
    ...  | reset_rmod        | No    | None    | Flag to recover RMOD through command line reboot, if RMOD is not reachable any more by BTS       |
    ...  | stop_and_fix      | No    | None    | Flag indicating that RMOD will not be recovered, if True. It has priority over Reset_Rmod flag   |
    ...  | skip_downloading  | No    | True    | Flag indicating if download RMOD snapshot to VM right after snapshot saving,will be skipped      |
    ...  | timeout           | No    | 240     | Maximum time to wait for snapshot generation, by default 240 secs                                |
    ...
    ...  *RETURN*
    ...  | Parameter                | Description                        |
    ...  | rsi_snapshot_status      | RMOD snapshot status: PASS or FAIL |
    ...  | rsi_rmod_snapshot_path   | Path to generated snapshot on RMOD |
    ...
    [Arguments]    ${connection}=${None}  ${target_path_on_vm}=${Test Results Dir}/RSILogs  ${reset_rmod}=${False}
    ...  ${stop_and_fix}=${False}  ${skip_downloading}=${True}  ${timeout}=240

    ${target_path_status}=  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${target_path_on_vm}
    Run Keyword If  not ${target_path_status}  OperatingSystem.Create Directory  ${target_path_on_vm}

    ${timeout}=  Convert To Number  ${timeout}
    ${rsi_snapshot_status}=  Set Variable  ${False}

    ${rsi_snapshot_status}=  rsi.Take Snapshot
    ...  alias=${connection}  target_path_on_vm=${target_path_on_vm}  reset_rmod=${reset_rmod}
    ...  stop_and_fix=${stop_and_fix}  skip_downloading=${skip_downloading}  timeout=${timeout}

    ${rsi_rmod_snapshot_path}=  rsi.Get Rmod Snapshot Path  alias=${connection}

    [Return]  ${rsi_snapshot_status}  ${rsi_rmod_snapshot_path}

RSI Execute Command
    [Documentation]
    ...  Executes command on RMOD and waits for output or timeout (blocking). Output is considered collected when shell prompt is reached.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man. | Default | Description                                                           |
    ...  | cmd                  | Yes  |         | Command to be executed                                                |
    ...  | connection           | Yes  |         | Serial number of RMOD or serial port on which it is connected to host |
    ...  | elevated             | No   | False   | Try to run command with elevated permissions                          |
    ...  | timeout              | No   | 30      | Maximum time to wait for an output, by default 30 secs                |
    ...  | write_output_to_logs | No   | True    | Flag indicating if command output will be written in rsi log file     |
    ...
    ...  *RETURN*
    ...  | Parameter         | Description                              |
    ...  | cmd_output_status | Command output info status: PASS or FAIL |
    ...  | cmd_output_info   | Command output info                      |
    ...
    [Arguments]  ${cmd}  ${connection}=None  ${elevated}=False  ${timeout}=30  ${write_output_to_logs}=${True}
    ...  ${as_rfsw}=${True}

    ${elevated}=  Convert To Boolean  ${elevated}
    ${timeout}=  Convert To Number  ${timeout}

    ${cmd_output_status}  ${cmd_output_info}=  Run Keyword And Ignore Error  rsi.Execute Command  cmd=${cmd}  alias=${connection}
    ...  elevated=${elevated}  wait_time=${timeout}  write_output_to_logs=${write_output_to_logs}  as_rfsw=${as_rfsw}

    [Return]  ${cmd_output_status}  ${cmd_output_info}

RSI Send Command
    [Documentation]
    ...  Executes command on RMOD and returns immediately (non-blocking).
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter  | Man. | Default | Description                                                                                                |
    ...  | cmd        | Yes  |         | Command to be executed                                                                                     |
    ...  | connection | No   | None    | Alias of host on which selected RMOD is connected, by default None means that 'default' alias will be used |
    ...
    ...  *RETURN*
    ...  | Parameter         | Description                              |
    ...  | cmd_output_status | Command output info status: PASS or FAIL |
    ...  | cmd_output_info   | Command output info                      |
    ...
    [Arguments]  ${cmd}  ${connection}=None  ${as_rfsw}=${True}

    ${cmd_output_status}  ${cmd_output_info}=  Run Keyword And Ignore Error  rsi.Send Command
    ...  cmd=${cmd}  alias=${connection}  as_rfsw=${as_rfsw}

    [Return]  ${cmd_output_status}  ${cmd_output_info}

RSI Setup Resources From Init Data
    [Documentation]
    ...  Sets up resources for serial connection to RMOD using data from __init__.py testline configuration file
    ...
    ...  *AUTHOR*
    ...  valentin.marian@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter           | Man. | Default | Description                                                                       |
    ...  | main_log_directory  | No   | /tmp    | Folder to save taf.hw.rf_diagnostic_card and taf.hw.rmod_serial_interface logs to |
    ...  | rmod_sn_list        | No   | Empty   | List of RMOD SNs on which to set up serial connection                             |
    ...

    [Arguments]    ${main_log_directory}=/tmp  ${rmod_sn_list}=@{EMPTY}

    Log  Attempting configuration of RMODs serial interface from init file.   console=True

    ${rsi_rmod_setup_list}=  Create List
    Set Test Variable  ${rsi_rmod_setup_count}  0
    Set Test Variable  ${rsi_rmod_setup_list}

    ${status}  ${info}=  RSI prepare log directory and connections setup  main_log_directory=${main_log_directory}
    ...  custom_yaml=${RF_DIAGNOSTIC_CARD_CUSTOM_YAML}

    Run Keyword If  '${status}'!='PASS'  Run Keywords
    ...  taf.hw.rf_diagnostic_card library preparation failed! - ${info}  console=${True}
    ...  AND  Return From Keyword

    ${modules}=  Get Dictionary Keys  ${INTERFACES}
    FOR  ${module}  IN  @{modules}
        ${module_type}=  Fetch From Left  ${module}  _
        Continue For Loop If  '${module_type}' != 'RMOD'
        ${module_sn}=  Fetch From Right  ${module}  _
        Continue For Loop If  ${rmod_sn_list} and ('${module_sn}' not in ${rmod_sn_list})

        ${lmi_key_present}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${INTERFACES['${module}']}  lmi
        ${lmi_data}=  Run Keyword If  ${lmi_key_present}  Get From Dictionary  ${INTERFACES['${module}']}  lmi
        Run Keyword If  ${lmi_data}
        ...  RSI Setup RMOD from init data  lmi_init_data=${lmi_data}  module_sn=${module_sn}
    END
    [Teardown]  Log  RSI setup RMODs: ${rsi_rmod_setup_list}  console=True

RSI Setup RMOD from init data
    [Arguments]    ${lmi_init_data}  ${module_sn}  ${log_to_console}=${False}

    ${rsi_setup_status}=  RSI Setup Rmod Connection
    ...  ru_init_config=${lmi_init_data}
    ...  connection=${module_sn}  log_to_console=${log_to_console}

    Run Keyword If  '${rsi_setup_status}' != 'PASS'  Run Keywords
    ...  Log  - Setup of ${module_sn} rmod serial interface failed!  console=True
    ...  AND  Return From Keyword

    Append To List  ${rsi_rmod_setup_list}  ${module_sn}
    ${rsi_rmod_setup_count}=  Get Length  ${rsi_rmod_setup_list}

    [Teardown]  Run Keywords
    ...  Set Test Variable  ${rsi_rmod_setup_list}
    ...  AND  Set Test Variable  ${rsi_rmod_setup_count}

RSI Teardown RMODs Connections
    [Documentation]
    ...  Tears down RMOD connections one by one, then shuts everything down including server on host,
    ...  to insure clean test line
    ...
    ...  *AUTHOR*
    ...  valentin.marian@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man. | Default | Description                                                                       |
    ...  | rsi_rmod_setup_list  | Yes  |         | List of RMOD which to teardown serial connection for |
    ...

    [Arguments]  ${rsi_rmod_setup_list}

    ${rsi_rmod_teardown_list}=  Create List

    FOR  ${rmod_sn}  IN  @{rsi_rmod_setup_list}

        ${rsi_rmod_teardown_status}  ${rsi_rmod_teardown_info}=  Run Keyword And Ignore Error  rsi.Disconnect  alias=${rmod_sn}

        Run Keyword If  '${rsi_rmod_teardown_status}' == 'PASS'
        ...  Append To List  ${rsi_rmod_teardown_list}  ${rmod_sn}
        ...  ELSE IF  '${rsi_rmod_teardown_status}' == 'FAIL'
        ...  Log  - Teardown for RMOD (sn=${rmod_sn}) failed!  console=True

    END

    Run Keyword And Return Status  rsi.Disconnect All Rmods And Shutdown

    [Return]  ${rsi_rmod_teardown_list}

RSI Export RMOD Snapshot Info To File
    [Documentation]
    ...  Keyword is used to create a file where RMOD snapshot info will be saved. User may consult this file to find for each RMOD identified by
    ...  serial number the internal path where snapshot is collected.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter              | Man. | Description                                            |
    ...  | rsi_rmod_snapshot_info | Yes  | RSI RMOD snapshot collect info                         |
    ...  | rsi_folder             | Yes  | RSI folder where RMOD snapshot info file will be saved |
    ...
    [Arguments]  ${rsi_rmod_snapshot_info}  ${rsi_folder}

    ${rsi_folder_status}=  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${rsi_folder}
    Run Keyword If  not ${rsi_folder_status}  OperatingSystem.Create Directory  ${rsi_folder}

    ${rsi_rmod_snapshot_path_file}=  Set Variable  ${rsi_folder}/RSI_RMOD_snapshot_info.txt
    ${file_status}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${rsi_rmod_snapshot_path_file}
    Run Keyword If  not ${file_status}  Run Keywords
    ...  Append To File  ${rsi_rmod_snapshot_path_file}  ======================================================
    ...  AND  Append To File  ${rsi_rmod_snapshot_path_file}  \nRMODs snapshot collected info through serial interface\n
    ...  AND  Append To File  ${rsi_rmod_snapshot_path_file}  ======================================================\n

    Append To File  ${rsi_rmod_snapshot_path_file}  \n${rsi_rmod_snapshot_info}\n

Execute and Check Expected RSI Command Output
    [Documentation]
    ...  Keyword is used to run a command on RMOD over RSI and check it's output. KW returns whether the command was sent successfully and whether
    ...  a desired text was found in the command output
    ...
    ...  *AUTHOR*
    ...  traian-alin.bacos@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter              | Man. | Description                                                  |
    ...  | cmd                    | Yes  | Command to be given to RMOD over RSI                         |
    ...  | expected output        | Yes  | String whos presence should be checked in the command output |
    ...  | connection             | No  | alias of RSI RMOD connection |
    ...  | timeout                | No  | timeout for sending the command to RMOD over RSI |
    ...
    ...  *RETURN*
    ...  | Parameter           | Description                                              |
    ...  | cmd_status          | Status of sending command to RMOD over RSI: PASS or FAIL |
    ...  | output_status       | Status of identifying desired text in command output: ${True} or ${False} |

    [Arguments]  ${cmd}  ${expected_output}  ${connection}=default  ${timeout}=3

    ${cmd_status}  ${cmd_output_info}=
    ...  RSI Execute Command  cmd=${cmd}  connection=${connection}  timeout=${timeout}
    ${output_length}=  Get Length  ${cmd_output_info}
    ${cmd_status}=  Set Variable If  ${output_length} > ${0}  ${cmd_status}  FAIL
    ${cmd_output_info}=  Replace String    ${cmd_output_info}  \\n  ${EMPTY}
    ${cmd_output_info}=  Replace String    ${cmd_output_info}  \\r  ${EMPTY}
    ${cmd_output_info}=  Replace String    ${cmd_output_info}  \n  ${EMPTY}
    ${cmd_output_info}=  Replace String    ${cmd_output_info}  \r  ${EMPTY}
    ${cmd_output_info}=  Replace String    ${cmd_output_info}  "  ${EMPTY}
    ${output_status}=  Set Variable If  "${expected_output}" in "${cmd_output_info}"
    ...  ${True}  ${False}

     [Return]  ${cmd_status}  ${output_status}

RSI Transfer RMOD Snapshot To VM
    [Documentation]
    ...  Keyword is used to perform transfer of RMOD snapshot from RMOD permanent memory to VM.
    ...
    ...  *AUTHOR*
    ...  valentin.marian@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter              | Man. | Description                                                  |
    ...  | RMOD_SN                | Yes  | alias of RSI RMOD connections                                |
    ...  | proxy_vm_address       | No   |  Address of the proxy VM to use for Download Snapshot        |
    ...  | target_path_on_vm      | Yes  |  Path on VM where to store the RMOD snapshots                |
    ...
    [Arguments]    ${RMOD_SN}  ${proxy_vm_address}=None  ${target_path_on_vm}=${Test Results Dir}/RSILogs

    ${target_path_status}=  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${target_path_on_vm}

    Run Keyword If  not ${target_path_status}  OperatingSystem.Create Directory  ${target_path_on_vm}

    Run Keyword If  '${proxy_vm_address}'=='None'  Run Keyword And Return Status  rsi.Download Snapshot
    ...  alias=${RMOD_SN}
    ...  target_path_on_vm=${target_path_on_vm}

    Run Keyword If  '${proxy_vm_address}'!='None'  Run Keyword And Return Status  rsi.Download Snapshot
    ...  alias=${RMOD_SN}
    ...  proxy_vm_address=${proxy_vm_address}
    ...  target_path_on_vm=${target_path_on_vm}

RSI Reset RMOD
    [Documentation]
    ...  Keyword is used to perform RMOD reset from RSI serial connection.
    ...  Used command is "reboot || /sbin/reboot"
    ...
    ...  *AUTHOR*
    ...  valentin.marian@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter              | Man. | Description                                                  |
    ...  | connection             | No  | alias of RSI RMOD connection |
    ...  | timeout                | No  | timeout for sending the command to RMOD over RSI |
    ...
    [Arguments]    ${connection}=${None}  ${timeout}=180

    Run Keyword If  '${connection}' == '${None}'
    ...  Run Keywords
    ...  Log  RMOD serial connection is not setup  console=True
    ...  AND  Return From Keyword

    rsi.Reset RMOD  alias=${connection}  wait_time=${timeout}
