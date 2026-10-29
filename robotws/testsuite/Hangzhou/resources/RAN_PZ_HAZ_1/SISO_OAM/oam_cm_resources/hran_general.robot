*** Settings ***
Documentation
...    Maintainer: I_NSB_MN_RAN_RD_VRF_HAZ1_8@internal.nsn.com
...    Common KWs related to hran general.
...    ******************
...    History of changes
...    ******************

Library     Collections
Library     DateTime
Library     OperatingSystem
Library     Process
Library     String
Library     SSHLibrary
#Library     FtpLibrary
Library     XML
Library     Telnet
Resource    hran_infomodel.robot
Resource    hran_admin.robot

*** Variables ***
@{no alarms}
${DF LOG PATH}=  ${OUTPUT DIR}/df.log

*** Keywords ***
Prepare expected alarms list
    [Documentation]
    ...  Keyword for creating list of alarms multiplicated by multiplication number
    ...
    ...  *AUTHOR* patryk.furman@nokia.com
    ...
    ...  | Parameter             | Man. | Description                                    |
    ...  | exp_alarms_list       | Yes  | List with alarms prepared for multiplication   |
    ...  | multiplication_number | Yes  | Number by which alarms should be multiplicated |
    ...
    ...  *RETURN*
    ...  | Parameter              | Description               |
    ...  | multiplicated_exp_list | List of lists with alarms |
    ...
    ...  *EXAMPLE*
    ...  | ${WCDMA_exp_alarms_multiplicated}= | Prepare expected alarms list | [['7665', 'Core']] | 5 |

    [Arguments]  ${exp_alarms_list}  ${multiplication_number}
    ${multiplicated_exp_list}=  create list
    FOR  ${index}  IN RANGE  ${multiplication_number}
        Append to list  ${multiplicated_exp_list}  @{exp_alarms_list}
    END
    [Return]  ${multiplicated_exp_list}

Get BTS state
    [Documentation]
    ...  Keyword providing WCDMA or LTE BTS state information from siteconf.xml.
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Description                                        |
    ...  | alias     | Yes  | Master or Slave |
    ...  | path to siteconf     | No  | it can be explicitly as ${path_to_siteconf[0]}
    ...    from previous Upload siteconf bts file or EMPTY |
    ...
    ...  *RETURN*
    ...  BTS info: [bsId, blockingState, operationalStatus]
    [Arguments]  ${alias}  ${path_to_siteconf}=${EMPTY}
    Run keyword if  '${path_to_siteconf}' == ''  Get siteconf.xml from SM  ${alias}
    ${BTS_bsId}=  Get elements texts  ${path_to_siteconf}  .//BS/_bsId
    ${BTS_blockingState}=  Get elements texts  ${path_to_siteconf}  .//BS/_blockingState
    ${BTS_operationalStatus}=  Get elements texts  ${path_to_siteconf}  .//BS/_operationalStatus
    ${BTS_state_list}=  create list  @{EMPTY}
    FOR  ${bsId}  ${blockingState}  ${operationalStatus}  IN ZIP  ${BTS_bsId}  ${BTS_blockingState}
        ...  ${BTS_operationalStatus}
        @{temp}=  create list  ${bsId}  ${blockingState}  ${operationalStatus}
        append to list  ${BTS_state_list}  ${temp}
    END
    sort list  ${BTS_state_list}
    Log  BTS info state from siteconf.xml: ${BTS_state_list}
    [Return]  ${BTS_state_list}

Get SM state
    [Documentation]
    ...  Keyword providing WCDMA or LTE SM state information from siteconf.xml.
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Description                                        |
    ...  | alias     | Yes  | Master or Slave |
    ...  | path to siteconf     | No  | it can be explicitly as ${path_to_siteconf[0]}
    ...    from previous Upload siteconf bts file or EMPTY |
    ...
    ...  *RETURN*
    ...  SM info as list of items
    ...  item info: [unitName, unitNumber, workingState, blockingState, operationalState]
    [Arguments]  ${alias}  ${path_to_siteconf}=${EMPTY}
    Run keyword if  '${path_to_siteconf}' == ''  Get siteconf.xml from SM  ${alias}
    ${SM_unitName}=  Get elements texts  ${path_to_siteconf}  .//Unit[FSM.Mode]/_unitName
    ${SM_unitNumber}=  Get elements texts  ${path_to_siteconf}  .//Unit[FSM.Mode]/_unitNumber
    ${SM_workingState}=  Get elements texts  ${path_to_siteconf}  .//Unit[FSM.Mode]/_state
    ${SM_blockingState}=  Get elements texts  ${path_to_siteconf}  .//Unit[FSM.Mode]/_blockingState
    ${SM_operationalState}=  Get elements texts  ${path_to_siteconf}  .//Unit[FSM.Mode]/_operationalState
    ${SM_state_list}=  create list  @{EMPTY}
    FOR  ${unitName}  ${unitNumber}  ${workingState}  ${blockingState}  ${operationalState}  IN ZIP
        ...  ${SM_unitName}  ${SM_unitNumber}  ${SM_workingState}  ${SM_blockingState}  ${SM_operationalState}
        @{temp}=  create list  ${unitName}  ${unitNumber}  ${workingState}  ${blockingState}  ${operationalState}
        append to list  ${SM_state_list}  ${temp}
    END
    sort list  ${SM_state_list}
    Log  SM info state from siteconf.xml: ${SM_state_list}
    [Return]  ${SM_state_list}

Get RM state
    [Documentation]
    ...  Keyword providing WCDMA or LTE RM state information from siteconf.xml.
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Description                                        |
    ...  | alias     | Yes  | Master or Slave |
    ...  | path to siteconf     | No  | it can be explicitly as ${path_to_siteconf[0]}
    ...    from previous Upload siteconf bts file or EMPTY |
    ...
    ...  *RETURN*
    ...  RM info as list of items
    ...  item info: [unitName, connectionList, workingState, blockingState, operationalState]
    [Arguments]  ${alias}  ${path_to_siteconf}=${EMPTY}
    Run keyword if  '${path_to_siteconf}' == ''  Get siteconf.xml from SM  ${alias}
    ${RM_id}=  Get Elements Texts  ${path_to_siteconf}  .//Unit[RadioConnections]/_id
    ${RM_unitName}=  Check RM Unit Name According To Its Id  ${RM_id}  ${path_to_siteconf}
    ${RM_connectionList}=  Get elements texts  ${path_to_siteconf}  .//Unit[RadioConnections]/connectionList
    ${RM_workingState}=  Get elements texts  ${path_to_siteconf}  .//Unit[RadioConnections]/_state
    ${RM_blockingState}=  Get elements texts  ${path_to_siteconf}  .//Unit[RadioConnections]/_blockingState
    ${RM_operationalState}=  Get elements texts  ${path_to_siteconf}  .//Unit[RadioConnections]/_operationalState
    ${RM_state_list}=  create list  @{EMPTY}
    FOR  ${unitName}  ${connectionList}  ${workingState}  ${blockingState}  ${operationalState}  IN ZIP
        ...  ${RM_unitName}  ${RM_connectionList}  ${RM_workingState}  ${RM_blockingState}  ${RM_operationalState}
        ${connectionList}=  remove string using regexp  ${connectionList}  ;.*
        ${connectionList}=  replace string using regexp  ${connectionList}  ,  .
        @{temp}=  create list  ${unitName}  ${connectionList}  ${workingState}  ${blockingState}  ${operationalState}
        append to list  ${RM_state_list}  ${temp}
    END
    sort list  ${RM_state_list}
    Log  RM info state from siteconf.xml: ${RM_state_list}
    [Return]  ${RM_state_list}

Get CELL state
    [Documentation]
    ...  Keyword providing WCDMA or LTE CELL state information from siteconf.xml.
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter            | Man. | Description                                                                                   |
    ...  | alias                | Yes  | Master or Slave                                                                               |
    ...  | path to siteconf     | No  | it can be explicitly as ${path_to_siteconf[0]}
    ...    from previous Upload siteconf bts file or EMPTY |
    ...
    ...  *RETURN*
    ...  CELL info as list of items
    ...  item info: [globalCellId, workingState, blockingState, operationalState, cellAvailability]
    [Arguments]  ${alias}  ${path_to_siteconf}=${EMPTY}
    Run keyword if  '${path_to_siteconf}' == ''  Get siteconf.xml from SM  ${alias}
    ${CELL_globalCellId}=  Get elements texts  ${path_to_siteconf}  .//Cell/_id
    ${CELL_workingState}=  Get elements texts  ${path_to_siteconf}  .//Cell/_state
    ${CELL_blockingState}=  Get elements texts  ${path_to_siteconf}  .//Cell/_blockingState
    ${CELL_operationalState}=  Get elements texts  ${path_to_siteconf}  .//Cell/_operationalState
    ${CELL_cellAvailability}=  Get elements texts  ${path_to_siteconf}  .//Cell/_cellAvailability
    ${CELL_state_list}=  create list  @{EMPTY}
    FOR  ${globalCellId}  ${workingState}  ${blockingState}  ${operationalState}  ${cellAvailability}  IN ZIP
        ...   ${CELL_globalCellId}  ${CELL_workingState}  ${CELL_blockingState}  ${CELL_operationalState}
        ...   ${CELL_cellAvailability}
        @{temp}=  create list  ${globalCellId}  ${workingState}  ${blockingState}  ${operationalState}  ${cellAvailability}
        append to list  ${CELL_state_list}  ${temp}
    END
    sort list  ${CELL_state_list}
    Log  CELL info state from siteconf.xml: ${CELL_state_list}
    [Return]  ${CELL_state_list}

Get siteconf.xml from SM
    [Documentation]
    ...  Keyword providing WCDMA or LTE siteconf.xml.
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Description     |
    ...  | alias     | Yes  | Master or Slave |
	...
    [Arguments]  ${alias}
    ${path_to_siteconf}=  Upload siteconf bts file  filename=siteconf_${alias}  alias=${alias}
    Set Test Variable  ${path_to_siteconf}  ${path_to_siteconf[0]}
    [Return]  ${path_to_siteconf}

Download siteconf.xml with timestamp
    [Documentation]
    ...  KW for downloading siteconf.xml from BTS to destination directory. Siteconf.xml gets name in form 'siteconf_time'
    ...  where time is the current time.
    ...
    ...  *AUTHOR* patryk.furman@nokia.com
    ...
    ...  | Parameter   | Man. | Description                                                    |
    ...  | alias       | Yes  | Alias used via ute_btssm library (Slave or Master)             |
    ...  | dir_to_copy | Yes  | Absolute path to directory where siteconf.xml should be placed |
    ...
    ...  *RETURN*
    ...  | Parameter     | Description                     |
    ...  | siteconf_path | Path to downloaded siteconf.xml |
    ...
    ...  *EXAMPLE*
    ...  | ${siteconf_file}= | Download siteconf.xml with timestamp | Master | /home/ute/btsauto/logs

    [Arguments]  ${alias}  ${dir_to_copy}
    ${yyyy}  ${mm}  ${dd}  ${hh}  ${min}  ${ss}=  Get Time  format=year,month,day,hour,min,sec
    ${files_list}=  Upload siteconf bts file  siteconf_${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}  alias=${alias}
    Copy file  ${files_list[0]}  ${dir_to_copy}/
    [Return]  ${files_list[0]}

Create 'Test Results Dir' and Set Test Variable
    ${testtimestamp}=    OperatingSystem.Run    date +%F_%H-%M-%S
    ${testresultspath}=    OperatingSystem.Join Path    ${OUTPUT DIR}    ${testtimestamp}_TEST-${TEST NAME}
    Create Directory    ${testresultspath}
    Set Test Variable    ${Test Results Dir}    ${testresultspath}
    Log  'Test Results Dir' created: ${Test Results Dir}  level=DEBUG  console=${TRUE}

Create '${dirname}' in '${rootdir}' And Set Test Variable
    ${dirpath}=    OperatingSystem.Join Path    ${rootdir}    ${dirname}
    Create Directory    ${dirpath}
    Set Test Variable    ${${dirname}}    ${dirpath}
    Log  '${dirname}' created: ${dirpath}  level=DEBUG

Kill process by name
    [Arguments]  ${process_name}  ${local}=${TRUE}  &{configuration}
    [Documentation]
    ...  Keyword killing group of process specified by name (case insensitive).
    ...
    ...  *AUTHOR* tomasz.1.filipek@nokia.com
    ...
    ...  | Parameter   | Man. | Description                                                    |
    ...  | process_name       | Yes  | string       |
    ...  | local | Yes  | boolean |
    ...  | configuration | Yes  | if local==false host_ip=<remote_host_ip>, ssh_port=<port>, ssh_username=<usenrame>,
    ...    ssh_passsword=<password> |
    ${kill_cmd}=  Set Variable  kill -KILL $(ps -ef | grep -i ${process_name} | awk '{print $2}')
    Run Keyword If  ${local}  Process.Run process  ${kill_cmd}  shell=${TRUE}
    ...  ELSE  Run Keywords
    ...  SSHLibrary.Open Connection  host=${configuration["host_ip"]}  port=${configuration["ssh_port"]}
    ...  AND  _SSHLibrary_Login_multiway  ${configuration["ssh_username"]}  ${configuration["ssh_password"]}
    ...  AND  SSHLibrary.Execute Command  ${kill_cmd}  return_stdout=${FALSE}
    ...  AND  SSHLibrary.Close Connection
    [Return]  ${TRUE}

Get Workspace Version
    ${hran_legacy_path}=  Set variable  /home/ute/btsauto/hran_ta
    ${hran_taf_path}=  Set Variable  /home/ute/MN/UTE/hran_ta

    ${USE_GIT}=  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${hran_legacy_path}/.git

    ${hran_path}=  Set Variable If  '${USE_GIT}' == '${False}'  ${hran_taf_path}  ${hran_legacy_path}

    Log  Default repository path is: ${hran_path}  level=INFO
    Run keyword if  ${USE_GIT}  Run keyword
    ...  Find workspace version and set tags
    ...  git --git-dir=/home/ute/btsauto/hran_ta/.git/ describe --always --tags | awk -F '[/|-g]' '{print $NF}' | cut -c 1-8
    ...  ELSE
    ...  Find workspace version and set tags
    ...  git --git-dir=/home/ute/MN/UTE/hran_ta/.git/ describe --always --tags | awk -F '[/|-g]' '{print $NF}' | cut -c 1-8

Find workspace version and set tags
    [Arguments]  ${command}
    ${workspace_version} =  OperatingSystem.run  ${command}
    Log  Online workspace version is ${workspace_version}  level=DEBUG  console=${TRUE}
    Set tags  Online workspace version = ${workspace_version}
    [Return]  ${workspace_version}

Kill processes remained after files deletion on VMs /home partition
    [Documentation]
    ...  Get all processes which are listed in Linux command
    ...  'lsof | grep -P '/home(?!.*(chrome|remote-stderr|remote-stdout)).*deleted'' and kill them.
    ...  Command can be run locally or remotely (after giving configuration details).
    ...  Command ommits Chrome processes to let the browser remain untouched, and also processes related to
    ...   RemoteSwingLibrary.
    ...  Looping is used to provide introspection into which process caused the problem (ps stdout is logged).
    ...
    ...  *AUTHOR* patryk.furman@nokia.com
    ...
    ...  | Parameter     | Man. | Description                                                                    |
    ...  | alias         | No   | Alias (Master or local in case of local machine or other in case of remote one |
    ...  | configuration | No   | KW arguments consisting with host_ip, ssh_port, ssh_username and ssh_password  |
    ...
    ...  *EXAMPLE*
    ...  | Kill processes remained after files deletion on VMs /home partition | Master |
    ...  | Kill processes remained after files deletion on VMs /home partition | Extension | host_ip=10.42.35.151 |
    ...    ssh_port=22 | ssh_username=ute | ssh_password=ute |

    [Arguments]  ${alias}=local  &{configuration}
    Log  Kill processes remained after files deletion on /home partition  console=${TRUE}
    ${pids_cmd}=  Set Variable
    ...    lsof | grep -P '/home(?!.*(chrome|remote-stderr|remote-stdout)).*deleted' | awk '!seen[$2]++ {print $2}'
    ${pids_str}=  Run Keyword If  '${alias}'=='local' or '${alias}'=='Master'
    ...  Execute Local Command And Return Output  ${pids_cmd}  ELSE
    ...  Execute Remote Command And Return Output  ${pids_cmd}  ${alias}  &{configuration}
    @{pids}=  Split String  ${pids_str}
    ${looped_ps_cmd}=  Create Dictionary  cmd=ps -o comm= -p  args=@{pids}
    Run Keyword If  '${alias}'=='local' or '${alias}'=='Master'
    ...  Execute Local Command In Loop  ${looped_ps_cmd}  ELSE
    ...  Execute Remote Command In Loop  ${looped_ps_cmd}  ${alias}  &{configuration}
    ${looped_kill_cmd}=  Create Dictionary  cmd=kill -9  args=@{pids}
    ${rc}=  Run Keyword If  '${alias}'=='local' or '${alias}'=='Master'
    ...  Execute Local Command In Loop  ${looped_kill_cmd}  ELSE
    ...  Execute Remote Command In Loop  ${looped_kill_cmd}  ${alias}  &{configuration}
    Run keyword if  ${rc}==${0}
    ...  Log  All processes remained after files deletion have been killed  console=${TRUE}  ELSE
    ...  Log  Failed to kill processes remained after files deletion        console=${TRUE}

Clean up directory
    [Arguments]  ${clean_directory}  ${older_than_min}  ${alias}=local  &{configuration}
    Log  Removing files older than ${older_than_min} min from "${clean_directory}" on ${alias}
    ...    level=INFO  console=${TRUE}
    ${command1}  Set Variable    if [ "$(ls -A ${clean_directory})" ]; then find ${clean_directory}/*
    ${command2}  Set Variable    -maxdepth 0 -mmin +${older_than_min} -exec rm -rf {} \\; ; fi
    ${command}   Set Variable   ${command1} ${command2}
    ${cleaning_rc}=  Run Keyword If  '${alias}'=='local' or '${alias}'=='Master'
    ...  Execute Local Command  ${command}  ELSE
    ...  Execute Remote Command  ${command}  ${alias}  &{configuration}
    ${result}=  Run Keyword And Return Status  Should Be Equal
    ...  ${cleaning_rc}  ${0}  msg=RC of operation clean "${clean_directory}" on ${alias} is not equal 0
    run keyword if  ${result}
    ...   Log  "${clean_directory}" on ${alias} cleaned  level=INFO  console=${TRUE}
    ...   ELSE   Log   Failed to clean "${clean_directory}" on ${alias}  level=INFO  console=${TRUE}
    [Return]  ${result}

Clean up directory windows
    [Arguments]  ${clean_directory}  ${older_than_min}  ${alias}=local  &{configuration}
    Log  Removing files older than ${older_than_min} min from "${clean_directory}" on ${alias}
    ...    level=INFO  console=${TRUE}
    ${cmd1}    Set Variable    if [ "$(ls -A ${clean_directory})" ]; then /bin/find ${clean_directory}/*
    ${cmd2}    Set Variable    -maxdepth 0 -mmin +${older_than_min} -exec rm -rf {} \\; ; fi
    ${command}   Set Variable    ${cmd1} ${cmd2}
    ${cleaning_rc}=  Run Keyword If  '${alias}'=='local' or '${alias}'=='Master'
    ...  Execute Local Command  ${command}  ELSE
    ...  Execute Remote Command  ${command}  ${alias}  &{configuration}
    ${result}=  Run Keyword And Return Status  Should Be Equal
    ...  ${cleaning_rc}  ${0}  msg=RC of operation clean "${clean_directory}" on ${alias} is not equal 0
    run keyword if  ${result}
    ...  Log  "${clean_directory}" on ${alias} cleaned  level=INFO  console=${TRUE}
    ...    ELSE    Log  Failed to clean "${clean_directory}" on ${alias}, probably it's already cleaned!
    ...    level=INFO  console=${TRUE}
    [Return]  ${result}

Execute Local Command
    [Arguments]  ${command}
    ${command_rc}=  Run And Return Rc  ${command}
    [Return]  ${command_rc}

Execute Local Command And Return Output
    [Arguments]  ${command}
    ${command_stdout}=  Run  ${command}
    [Return]  ${command_stdout}

Execute Local Command In Loop
    [Arguments]  ${looped_command}
    ${terminal_command_rc}=  _Execute Command In Loop Via  Run And Return Output And Rc  ${looped_command}
    [Return]  ${terminal_command_rc}

Run And Return Output And Rc
    [Arguments]  ${command}
    ${rc}  ${rv}=  Run Keyword  Run And Return Rc And Output  ${command}
    [Return]  ${rv}  ${rc}

Execute Remote Command
    [Arguments]  ${command}  ${index_or_alias}  &{configuration}
    _Remote Command Setup  ${index_or_alias}  &{configuration}
    ${command_rc}=  SSHLibrary.Execute Command  ${command}  return_stdout=False  return_rc=True
    [Teardown]  _Remote Command Teardown
    [Return]  ${command_rc}

Execute Remote Command And Return Output
    [Arguments]  ${command}  ${index_or_alias}  &{configuration}
    _Remote Command Setup  ${index_or_alias}  &{configuration}
    ${command_stdout}=  SSHLibrary.Execute Command  ${command}  return_stdout=True  return_rc=False
    [Teardown]  _Remote Command Teardown
    [Return]  ${command_stdout}

Execute Remote Command In Loop
    [Arguments]  ${looped_command}  ${index_or_alias}  &{configuration}
    _Remote Command Setup  ${index_or_alias}  &{configuration}
    ${terminal_command_rc}=  _Execute Command In Loop Via  SSHLibrary.Execute Command
    ...    ${looped_command}  return_stdout=True  return_rc=True
    [Teardown]  _Remote Command Teardown
    [Return]  ${terminal_command_rc}

_Remote Command Setup
    [Arguments]  ${index_or_alias}  &{configuration}
    ${check_connection}=  SSHLibrary.Get Connection  ${index_or_alias}
    Run Keyword If  ${check_connection.index}
    ...  SSHLibrary.Switch Connection  ${index_or_alias}  ELSE
    ...  SSHLibrary.Open Connection  host=${configuration["host_ip"]}  port=${configuration["ssh_port"]}
    _SSHLibrary_Login_multiway  ${configuration["ssh_username"]}  ${configuration["ssh_password"]}

_SSHLibrary_Login_multiway
    [Arguments]  ${username}  ${password}
    ${status}=  Run keyword and return status  SSHLibrary.Login  ${username}  ${password}
    Return from keyword if  ${status}
    ${status}=  Run keyword and return status  SSHLibrary.Login with public key  ${username}
    ...  /home/${username}/.ssh/id_rsa
    Run keyword unless  ${status}  Fail  Remote connection unavailable

_Remote Command Teardown
    SSHLibrary.Close Connection

_Execute Command In Loop Via
    [Arguments]  ${keyword}  ${looped_command}  @{keyword_args}  &{keyword_kwargs}
    ${terminal_command_rc}=  Set Variable  0
    FOR  ${arg}  IN  @{looped_command["args"]}
        ${command}=  Catenate  ${looped_command["cmd"]}  ${arg}
        ${command_stdout}  ${command_rc}=  Run Keyword  ${keyword}  ${command}  @{keyword_args}  &{keyword_kwargs}
        Log  ${command_stdout}
        ${terminal_command_rc}=  Set Variable If  ${command_rc} != 0  ${command_rc}  ${terminal_command_rc}
    END
    [Return]  ${terminal_command_rc}

Create dirs for logs
    [Documentation]
    ...  *AUTHOR* sebastian.burniak@nokia.com
    Create 'Test Results Dir' and Set Test Variable
    Create 'BTSFiles' in '${Test Results Dir}' And Set Test Variable
    Create 'TestFiles' in '${Test Results Dir}' And Set Test Variable
    Create 'UDPLogs' in '${Test Results Dir}' And Set Test Variable
    Create Temp Logs Dir And Set Test Variable

Create Temp Logs Dir And Set Test Variable
    ${test_timestamp}=  OperatingSystem.Run  date +%F_%H-%M-%S
    ${TEST NAME WITHOUT BRACKETS}=  Replace String  ${TEST NAME}  [1]  _1_
    ${joined_path}=  OperatingSystem.Join Path  ${TEMP_LOGS_DIR}  ${test_timestamp}_TEST-${TEST NAME WITHOUT BRACKETS}
    Set Test Variable  ${TEMP_LOGS_DIR}  ${joined_path}
    Log  Temp logs Dir created: ${TEMP_LOGS_DIR}  level=DEBUG

Open session to BSC
    [Documentation]
    ...  Connect and login to BSC
    ...
    ...  | **Author:** patryk.furman@nokia.com
    ...  | **Maintainer:** patryk.furman@nokia.com
    ...
    ...  | **Full description:**
    ...  | KW for connecting to BSC. It sets keepalive function on with value of 5 minutes and sets 10 seconds timeout
    ...  | for Telnet feedbacks. In default it uses IP and credentials from config file.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------+------+----------------------------+---------------------------------------------+
    ...  | Parameter name | Man. | Default                    | Description                                 |
    ...  +================+======+============================+=============================================+
    ...  | bsc_ip         | no   | ${BSC['ip']}           | BSC IP address                                  |
    ...  +----------------+------+----------------------------+---------------------------------------------+
    ...  | bsc_username   | no   | ${BSC['user']}         | BSC username used for logging in                |
    ...  +----------------+------+----------------------------+---------------------------------------------+
    ...  | bsc_password   | no   | ${BSC['password']}     | BSC password used for logging in |
    ...  +----------------+------+----------------------------+---------------------------------------------+
    ...  | connection_type | no  | telnet                 | connection type used, possible values telnet/ssh|
    ...  +----------------+------+----------------------------+---------------------------------------------+

    [Arguments]  ${bsc_ip}=${BSC['ip']}  ${bsc_username}=${BSC['user']}  ${bsc_password}=${BSC['password']}
    ...    ${connection_type}=telnet
    Run Keyword If  '${connection_type}'=='telnet'  Run Keywords  hran_bsc.Bsc Connection  ${bsc_ip}
    ...  AND  hran_bsc.Bsc Login  ${bsc_username}  ${bsc_password}
    ...  ELSE  hran_bsc.Bsc Ssh Connection  host=${bsc_ip}  username=${bsc_username}  password=${bsc_password}
    hran_bsc.Set Keepalive
    hran_bsc.Set Timeout  10 seconds
    Log  Session to ${bsc_ip} started  console=${TRUE}

Close all BSC sessions
    [Documentation]
    ...  Close all connections to BSC and clear connection cache
    ...
    ...  | **Author:** patryk.furman@nokia.com
    ...  | **Maintainer:** patryk.furman@nokia.com

    hran_bsc.Close All Connections
    Log  All sessions to BSC closed  console=${TRUE}

Get path to SCFC as variable
    @{scf_file_name}    OperatingSystem.List Files In Directory
    ...    ${CURDIR}/../config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/commissioning   SCF_01_*.xml
    [Return]  ${CURDIR}/../config/${HW_LOCATION_CODE }/${TESTLINE_NAME}/commissioning/@{scf_file_name}[0]

Hran_ta Preconditions
    Log  Common Test Setup  level=INFO  console=${TRUE}
    Get Workspace Version
    Create Dirs For Logs
    Set TC Verdict Variables

Hran_ta Postconditions
    Log  End of Common Test Teardown  level=INFO  console=${TRUE}

Check RM Unit Name According To Its Id
    [Arguments]  ${RF_ids_list}  ${siteconf_path}
    ${RF_unitNames_list}=  create list  @{EMPTY}
    FOR  ${RF_id}  IN  @{RF_ids_list}
        ${temp}=  Get Elements Texts  ${siteconf_path}  .//Unit[_id="${RF_id}"]_unitName
        ${temp}=  Remove Duplicates  ${temp}
        Append To List  ${RF_unitNames_list}  @{temp}
    END
    [Return]  ${RF_unitNames_list}

Check if all cells are unblocked
    [Documentation]
    ...  Function which checks if all cells from siteconf.xml are unblocked. If cell is blocked, it unblocks it and wait
    ...  some time for establishment.
    ...
    ...  *AUTHOR* patryk.furman@nokia.com
    ...
    ...  | Parameter | Man. | Description                                        |
    ...  | alias     | Yes  | Alias used via ute_btssm library (Slave or Master) |
    ...
    ...  *EXAMPLE*
    ...  | Check if all cells are unblocked | Master |

    [Arguments]  ${alias}
    ${cell_details_list}=  Get CELL State  ${alias}

    FOR  ${cell}  IN  @{cell_details_list}
        Run keyword if  '${cell[2]}' == 'blocked'  Run keywords
        ...      ute_btssm.Unblock Cell  ${cell[0]}  alias=${alias}  AND
        ...      Sleep  30s  Wait for ${cell[0]} establish  AND
        ...      Log  Cell ${cell[0]} unblock indicated  console=True
    END

Set TC Verdict Variables
    [Documentation]
    ...  Initialize all variables used to determine TC verdict at the end of TC execution
    ...  *AUTHOR* radu.andronache@nokia.com
    Set Test Variable  ${PreconditionMandatoryParametersDefined}  ${TRUE}
    Set Test Variable  ${PreconditionBTSConf}  ${TRUE}
    Set Test Variable  ${PreconditionCellsOnAir}  ${TRUE}
    Set Test Variable  ${PreconditionModulesWorking}  ${TRUE}
    Set Test Variable  ${PreconditionNoActiveAlarms}  ${TRUE}
    Set Test Variable  ${TcPreconditionPassed}  ${TRUE}

Check All RMs State
    [Documentation]
    ...  Keyword used to determine RMs states for WCDMA/LTE
    ...  *AUTHOR* radu.andronache@nokia.com
    ...  *AUTHOR* catalin.chiorean@nokia.com
    [Arguments]  ${set_slave_tech}  ${master_siteconf}=${EMPTY}  ${slave_siteconf}=${EMPTY}
    [Timeout]  200 sec
    ${Master_RM_Working}  Set Variable  ${TRUE}
    ${Slave_RM_Working}  Set Variable  ${TRUE}
    ${Master_RM_State_List}  Get RM State  Master  ${master_siteconf}
    ${Master_RM_Working}  Calculate RMs Working State From ${Master_RM_State_List}
    ${Slave_RM_Working}  Run Keyword  Check Slave ${set_slave_tech} RM State  ${slave_siteconf}
    ${All_RM_Working}  Set Variable If  ${Master_RM_Working} is ${TRUE} and ${Slave_RM_Working} is ${TRUE}
    ...    ${TRUE}  ${FALSE}
    Log  Master RM enabled: ${Master_RM_Working}, Slave RM enabled: ${Slave_RM_Working}, level=TRACE  console=${TRUE}
    Log    All RMs are working: ${All_RM_Working}    level=TRACE  console=${TRUE}
    [Return]  ${All_RM_Working}

Check All RMs State SOAM
    [Documentation]
    ...  Keyword used to determine RMs states for WCDMA/LTE
    ...  *AUTHOR* serban.hamza@nokia.com
    [Arguments]  ${master_siteconf}=${EMPTY}
    [Timeout]  200 sec
    ${Master_RM_Operational_Working}=  Set Variable  ${TRUE}
    ${Slave_RM_Operational}=  Set Variable  ${TRUE}
    ${Master_RM_State_List}=  Run Keyword If  '${MASTER['MASTER_TECH']}'=='WCDMA'
    ...  Get RM State  Master  ${master_siteconf}
    ...  ELSE IF  '${MASTER['MASTER_TECH']}' in ['NR','LTE','SBTS']
    ...  Admin Get RMOD state info  Master
    ${Master_RM_Operational_Working}=  Run Keyword  Check Master ${MASTER['MASTER_TECH']} RM State SOAM
    ${Slave_RM_Operational}=  Run Keyword If  '${SLAVE['SLAVE_TECH']}' in ['NR','LTE','SBTS']
    ...  Check Slave ${SLAVE['SLAVE_TECH']} RM State SOAM
    ...  ELSE IF  '${SLAVE['SLAVE_TECH']}'=='GSM'
    ...  Check Slave GSM RM State
    ${All_RM_Working}=  Set Variable If  ${Master_RM_Operational_Working} and ${Slave_RM_Operational}  ${TRUE}  ${FALSE}
    Log  Master RM enabled: ${Master_RM_Operational_Working}, Slave RM enabled: ${Slave_RM_Operational},
    ...    level=TRACE  console=${TRUE}
    Log    All RMs are working: ${All_RM_Working}    level=TRACE  console=${TRUE}
    [Return]  ${All_RM_Working}

Check Master WCDMA RM State SOAM
    ${Master_RM_State_List}=  Get RM State  Master
    ${Master_RM_Working}=  Calculate RMs Working State From ${Master_RM_State_List}
    [Return]  ${Master_RM_Working}

Check Master LTE RM State SOAM
    ${Master_RM_State_List}=  Admin Get LTE RMOD state info  Master
    ${Master_RM_Operational}=  Calculate RMs Operational State SOAM From ${Master_RM_State_List}
    [Return]  ${Master_RM_Operational}

Check Master NR RM State SOAM
    ${Master_RM_State_List}=  Admin Get RMOD state info  Master
    ${Master_RM_Operational}=  Calculate RMs Operational State SOAM From ${Master_RM_State_List}
    [Return]  ${Master_RM_Operational}

Check Slave LTE RM State
    [Arguments]  ${slave_siteconf}
    ${Slave_RM_State_List}=  Get RM State  Slave  ${slave_siteconf}
    ${Slave_RM_Working}=  Calculate RMs Working State From ${Slave_RM_State_List}
    [Return]  ${Slave_RM_Working}

Check Slave NR RM State SOAM
    ${Slave_RM_State_List}=  Admin Get RMOD state info  Slave
    ${Slave_RM_Operational}=  Calculate RMs Operational State SOAM From ${Slave_RM_State_List}
    [Return]  ${Slave_RM_Operational}

Check Slave LTE RM State SOAM
    ${Slave_RM_State_List}=  Admin Get LTE RMOD state info  Slave
    ${Slave_RM_Operational}=  Calculate RMs Operational State SOAM From ${Slave_RM_State_List}
    [Return]  ${Slave_RM_Operational}

Check Slave GSM RM State
    ${RM_OpState_dict}  ${log}=  All Rf Unit Op State
    ${RM_OpState_keys}=  Get Dictionary Keys  ${RM_OpState_dict}
    ${RM_OpState_values}=  Get Dictionary Values  ${RM_OpState_dict}
    ${Slave_RM_Operational}=  Set Variable  ${TRUE}
    FOR  ${key}  ${value}  IN ZIP  ${RM_OpState_keys}  ${RM_OpState_values}
        Log  RmId: ${key}, RM_operationalState: ${value}  level=DEBUG  console=${TRUE}
        ${Slave_RM_Operational}=  Set Variable If  '${value}' != 'FrmEnabled'  ${FALSE}  ${Slave_RM_Operational}
        Run Keyword Unless  ${Slave_RM_Operational}  Log  RM is in ${value} state  level=WARN
    END
    [Return]  ${Slave_RM_Operational}

Calculate RMs Working State From ${RM_states_list}
    ${RM_Working}=  Set Variable  ${TRUE}
    FOR  ${rm_items}  IN  @{RM_states_list}
        Log  RmId: ${rm_items[1]}, RM_workingState: ${rm_items[2]}  level=DEBUG  console=${TRUE}
        ${RM_Working}=  Set Variable If  '${rm_items[2]}' != 'working'  ${FALSE}  ${RM_Working}
        Run Keyword Unless  ${RM_Working}  Log  RM is in ${rm_items[2]} state  level=WARN
    END
    [Return]  ${RM_Working}

Calculate RMs Operational State SOAM From ${RM_states_list}
    ${RM_Operational}=  Set Variable  ${TRUE}
    FOR  ${rm_items}  IN  @{RM_states_list}
        Log  RmId: ${rm_items[0]}, RM_operationalState: ${rm_items[3]}  level=DEBUG  console=${TRUE}
        ${RM_Operational}=  Set Variable If  '${rm_items[3]}' != 'Enabled'  ${FALSE}  ${RM_Operational}
        Run Keyword Unless  ${RM_Operational}  Log  RM is in ${rm_items[3]} state  level=WARN
    END
    [Return]  ${RM_Operational}

Check All Cells State
    [Documentation]
    ...  Keyword used to determine cells states for all technologies. For GSM, TRXs will be checked.
    ...  *AUTHOR* radu.andronache@nokia.com
    ...  *AUTHOR* catalin.chiorean@nokia.com
    [Timeout]  200 sec
    [Arguments]  ${set_slave_tech}  ${master_siteconf}=${EMPTY}  ${slave_siteconf_or_bcf_id}=${EMPTY}
    ${MasterCellsAreOnAir}=  Set Variable  ${TRUE}
    ${SlaveCellsAreOnAir}=  Set Variable  ${TRUE}
    ${MasterCellStateList}=  Get CELL state  Master  ${master_siteconf}
    ${MasterCellsAreOnAir}=  Calculate Cells Working State From ${MasterCellStateList}
    ${SlaveCellsAreOnAir}=  Run Keyword  Check Slave ${set_slave_tech} All Cells  ${slave_siteconf_or_bcf_id}
    ${CellsAreOnAir}=  Set Variable If  ${MasterCellsAreOnAir} and ${SlaveCellsAreOnAir}  ${TRUE}  ${FALSE}
    Log  Master Cells enabled: ${MasterCellsAreOnAir}, Slave Cells enabled: ${SlaveCellsAreOnAir},
    ...  level=TRACE  console=${TRUE}
    Log    All Cells are onAir: ${CellsAreOnAir}    level=TRACE  console=${TRUE}
    Run Keyword Unless  ${MasterCellsAreOnAir}  Log  Master Cells are not operational!  level=ERROR  console=${TRUE}
    Run Keyword Unless  ${SlaveCellsAreOnAir}  Log  Slave Cells are not operational!  level=ERROR  console=${TRUE}
    [Return]  ${CellsAreOnAir}

Check All Cells State SOAM
    [Documentation]
    ...  Keyword used to determine cells states for all technologies. For GSM, TRXs will be checked.
    ...  *AUTHOR* serban.hamza@nokia.com
    [Timeout]  200 sec
    ${MasterCellsAreOnAir}=  Set Variable  ${TRUE}
    ${SlaveCellsAreOnAir}=  Set Variable  ${TRUE}
    ${MasterCellsAreOnAir}=  Run Keyword  Check Master ${MASTER['MASTER_TECH']} All Cells SOAM
    ${SlaveCellsAreOnAir}=  Run Keyword If  '${SLAVE['SLAVE_TECH']}'=='LTE'
    ...  Check Slave LTE All Cells SOAM
    ...  ELSE IF  '${SLAVE['SLAVE_TECH']}'=='SBTS'
    ...  Check Slave SBTS All Cells SOAM
    ...  ELSE IF  '${SLAVE['SLAVE_TECH']}'=='GSM'
    ...  Check Slave GSM All Cells  ${SLAVE['BCF_ID']}
    ...  ELSE IF  '${SLAVE['SLAVE_TECH']}'=='NR'
    ...  Check Slave NR All Cells SOAM
    ${CellsAreOnAir}=  Set Variable If  ${MasterCellsAreOnAir} and ${SlaveCellsAreOnAir}  ${TRUE}  ${FALSE}
    Log  Master Cells enabled: ${MasterCellsAreOnAir}, Slave Cells enabled: ${SlaveCellsAreOnAir},
    ...  level=TRACE  console=${TRUE}
    Log    All Cells are onAir: ${CellsAreOnAir}    level=TRACE  console=${TRUE}
    Run Keyword Unless  ${MasterCellsAreOnAir}  Log  Master Cells are not operational!  level=ERROR  console=${TRUE}
    Run Keyword Unless  ${SlaveCellsAreOnAir}  Log  Slave Cells are not operational!  level=ERROR  console=${TRUE}
    [Return]  ${CellsAreOnAir}

Check Master WCDMA All Cells SOAM
    [Arguments]  ${master_siteconf}=${EMPTY}
    ${MasterCellStateList}=  Get CELL state  Master  ${master_siteconf}
    ${MasterCellsAreOnAir}=  Calculate Cells Working State From ${MasterCellStateList}
    [Return]  ${MasterCellsAreOnAir}

Check Master LTE All Cells SOAM
    ${MasterCellStateList}=  Admin Get LTE CELL state info  Master
    ${MasterCellsAreOnAir}=  Calculate Cells Working State SOAM From ${MasterCellStateList}
    [Return]  ${MasterCellsAreOnAir}

Check Master NR All Cells SOAM
    ${MasterCellStateList}=  Admin Get NR CELL state info  Master
    ${MasterCellsAreOnAir}=  Calculate NR Cells Working State SOAM From ${MasterCellStateList}
    [Return]  ${MasterCellsAreOnAir}

Check Slave LTE All Cells
    [Arguments]  ${slave_siteconf}=${EMPTY}
    ${SlaveCellStateList}=  Get CELL state  Slave  ${slave_siteconf}
    ${SlaveCellsAreOnAir}=  Calculate Cells Working State From ${SlaveCellStateList}
    [Return]  ${SlaveCellsAreOnAir}

Check Slave LTE All Cells SOAM
    ${SlaveCellStateList}=  Admin Get LTE CELL state info  Slave
    ${SlaveCellsAreOnAir}=  Calculate Cells Working State SOAM From ${SlaveCellStateList}
    [Return]  ${SlaveCellsAreOnAir}

Check Slave NR All Cells SOAM
    ${SlaveCellStateList}=  Admin Get NR CELL state info  Slave
    ${SlaveCellsAreOnAir}=  Calculate NR Cells Working State SOAM From ${SlaveCellStateList}
    [Return]  ${SlaveCellsAreOnAir}

Check Slave GSM All Cells
    [Arguments]  ${set_bcf_id}=${EMPTY}
    ${SlaveCellsAreOnAir}=  Parse bcf trxs status  ${set_bcf_id}  WO  U  allow_negative_result=${TRUE}
    [Return]  ${SlaveCellsAreOnAir}

Calculate Cells Working State From ${states_list}
    [Documentation]
    ...  Keyword used to iterate through cells list and determine working state. Works for WCDMA/LTE
    ...  *AUTHOR* radu.andronache@nokia.com
    ${CellsAreOnAir}=  Set Variable  ${TRUE}
    FOR    ${cell_items}    IN    @{states_list}
        Log  CellId: ${cell_items[0]}, CELL_operationalState: ${cell_items[3]}  level=DEBUG  console=${TRUE}
        ${CellsAreOnAir}=  Set Variable If  '${cell_items[3]}' != 'enabled'  ${FALSE}  ${CellsAreOnAir}
    END
    [Return]  ${CellsAreOnAir}

Calculate Cells Working State SOAM From ${states_list}
    [Documentation]
    ...  Keyword used to iterate through cells list and determine working state. Works for WCDMA/LTE
    ...  *AUTHOR* serban.hamza@nokia.com
    ${CellsAreOnAir}=  Set Variable  ${TRUE}
    FOR    ${cell_items}    IN    @{states_list}
        Log  CellId: ${cell_items[0]}, CELL_operationalState: ${cell_items[2]}  level=DEBUG  console=${TRUE}
        ${CellsAreOnAir}=  Set Variable If  '${cell_items[6]}' != 'OnAirDone'  ${FALSE}  ${CellsAreOnAir}
    END
    [Return]  ${CellsAreOnAir}

Calculate NR Cells Working State SOAM From ${states_list}
    [Documentation]
    ...  Keyword used to iterate through cells list and determine working state. Works for NR
    ...  *AUTHOR* dinu.olariu@nokia.com
    ${CellsAreOnAir}=  Set Variable  ${TRUE}
    FOR    ${cell_items}    IN    @{states_list}
        Log  CellId: ${cell_items[0]}, CELL_operationalState: ${cell_items[2]}, CELL_availabilityStatus: ${cell_items[4]}
        ...   level=DEBUG     console=${TRUE}
        ${CellsAreOnAir}=  Set Variable If  '${cell_items[2]}' != 'Enabled' or '${cell_items[4]}' != 'Online'
        ...    ${FALSE}  ${CellsAreOnAir}
    END
    [Return]  ${CellsAreOnAir}

Check if RMs are unblocked
    [Documentation]
    ...  Function which checks if all RM modules are unblocked. If any of it is blocked, function unblocks it and wait
    ...  some time for establishment.
    ...
    ...  *AUTHOR* patryk.furman@nokia.com
    ...
    ...  | Parameter | Man. | Description                                        |
    ...  | alias     | Yes  | Alias used via ute_btssm library (Slave or Master) |
    ...  | tech      | Yes  | RAT type (LTE or WCDMA)                            |
    ...
    ...  *EXAMPLE*
    ...  | Check if RMs are unblocked | Master | LTE |

    [Arguments]  ${alias}  ${tech}
    ${RM_shared_list}  ${RM_dedicated_list}=  Run keyword if  '${tech}' == 'WCDMA'
    ...  Siteconf Get RM modules type and connection number list from WCDMA
    ...  ELSE IF  '${tech}' == 'LTE'    Siteconf Get LTE RM Types and Connection Number  ${alias}
    ...  ELSE  Fail  Tech is not a WCDMA or LTE. Break test!

    ${RM_full_list}=  Combine Lists  ${RM_shared_list}  ${RM_dedicated_list}

    FOR  ${RM_obj}  IN  @{RM_full_list}
        Run Keyword If  '${RM_obj[3]}' == 'blocked'  RM Unblock Procedure  ${RM_obj[0]}  ${RM_obj[1]}  ${alias}
    END

RM Unblock Procedure
    [Documentation]
    ...  RM unblock procedure with some time for RM establishment and log message.
    ...
    ...  *AUTHOR* patryk.furman@nokia.com
    ...
    ...  | Parameter     | Man. | Description                                        |
    ...  | rm_connection | Yes  | RM optical connection number (i.e. 1.1.1, 1.0.2.1) |
    ...  | rm_name       | Yes  | RM name (i.e. FXDB, FRGP)                          |
    ...  | alias         | Yes  | Alias used via ute_btssm library (Slave or Master) |

    [Arguments]  ${rm_connection}  ${rm_name}  ${alias}
    Unblock Unit  ${rm_name}  ${rm_connection}  alias=${alias}
    Log  RM ${rm_name} ${rm_connection} unblock indicated  console=True
    Sleep  60s  Wait for ${rm_name} ${rm_connection} establish

Check version of running linux OS
    [Documentation]
     ...  Check linux version, log will be visible on debug level.
     ...
     ...  *AUTHOR* jaroslaw.piszczala@nokia.com
    ${output}=  Run process  lsb_release  -a
    Run keyword if  ${output.rc}==0  Log  ${output.stdout}  level=DEBUG
    ...  ELSE  Log  Linux OS version couldn't be checked due to error: ${output.stderr}  level=DEBUG

Get siteName information from siteconf.xml
    [Documentation]
    ...  Keyword providing WCDMA and LTE siteName information from siteconf.xml
    ...  *AUTHOR* ana.tugui@nokia.com
    ...
    ...  | Input Parameters | Man. | Description         |
    ...  | alias               | No   | alias info: Master or Slave  |
    ...
    ...  *RETURN VALUE*
    ...  siteName info
    [Arguments]  ${alias}
    Get siteconf.xml from SM  ${alias}
    ${siteName}=  Get elements texts  ${path_to_siteconf}  .//BS/_siteName
    set tags  Site name - ${alias} = ${siteName[0]}
    Log  Site name - ${alias} = ${siteName[0]}  level=INFO  console=${TRUE}
    [Return]  ${siteName[0]}

Get Blackbox From BTS
    [Arguments]  ${timeout}=5  ${alias}=default
    [Documentation]
    ...  *AUTHOR* tomasz.1.filipek@nokia.com
    ...
    ...  | Input Parameters | Man. | Description         |
    ...  | timeout               | No   | integer, timeout in minutes for blackbox upload operation  |
    ...  | alias               | No   | string  |
    ...  *RETURN VALUE*
    ...  path to downloaded blackbox file
    ${timestamp}=  Get Current Date  result_format=%Y-%m-%d_%H-%M-%S
    ${upload}  ${uploaded_files}=  Run Keyword And Ignore Error
    ...   Upload File From Bts  alias=${alias}  filepath=/rom/config/lifedata/blackbox
    ...  filename=${timestamp}  timeout=${timeout}min
    Return From Keyword If  '${upload}' == 'FAIL'  ${EMPTY}
    Collect BTSSM files  alias=${alias}  unzip=True  subdirectory=${BTSFiles}/${alias}
    ...  add_files=${uploaded_files[0]}
    ${blackbox_path}  ${blackbox_file}=  Split Path  ${uploaded_files[0]}
    ${blackbox_path}=  Set Variable  ${BTSFiles}/${alias}/${blackbox_file}
    [Return]  ${blackbox_path}

Get Reset Reason List
    [Arguments]  ${timeout}=5  ${alias}=default
    [Documentation]
    ...  *AUTHOR* tomasz.1.filipek@nokia.com
    ...
    ...  | Input Parameters | Man. | Description         |
    ...  | timeout               | No   | integer, timeout in minutes for blackbox upload operation  |
    ...  | alias               | No   | string  |
    ...  *RETURN VALUE*
    ...  list of all reset reasons from blackbox file
    ${blackbox_path}=  Get Blackbox From BTS  timeout=${timeout}  alias=${alias}
    ${blackbox_found}=  Run Keyword And Return Status  File Should Not Be Empty  ${blackbox_path}
    Return From Keyword If  not ${blackbox_found} or '${blackbox_found}' == 'FAIL'  ${EMPTY}
    ${reset_counter}  ${reset_reason_list}=  Get Reset Info From File  ${blackbox_path}
    Log  Last reset reason: ${reset_reason_list[-1]}  level=INFO
    [Return]  ${reset_reason_list}

Get New Resets Number and Reasons
    [Arguments]  ${old_reset_reason_list}  ${timeout}  ${alias}=default
    [Documentation]
    ...  *AUTHOR* tomasz.1.filipek@nokia.com
    ...
    ...  | Input Parameters | Man. | Description         |
    ...  | old_reset_reason_list               | No   | list received from KW Get Reset Reason List  |
    ...  | timeout               | No   | integer, timeout in minutes for blackbox upload operation  |
    ...  | alias               | No   | string  |
    ...
    ...  *RETURN VALUE*
    ...  number of all new reset in current blackbox file and list of their reasons
    ${current_reset_reason_list}=  Get Reset Reason List  ${timeout}  ${alias}
    ${reset_reason_differences}=  List Diff  ${current_reset_reason_list}  ${old_reset_reason_list}
    ${reset_counter}=  Get Length  ${reset_reason_differences}
    [Return]  ${reset_counter}  ${reset_reason_differences}

Wait For Reset
    [Arguments]  ${old_reset_reason_list}  ${timeout}  ${alias}=default
    [Documentation]
    ...  *AUTHOR* tomasz.1.filipek@nokia.com
    ...
    ...  | Input Parameters | Man. | Description         |
    ...  | old_reset_reason_list  | No   | list received from KW Get Reset Reason List  |
    ...  | timeout               | No   | integer, timeout in minutes for waiting for reset  |
    ...  | alias               | No   | string  |
    ...
    ...  *RETURN VALUE*
    ...  boolean, true if reset occurred in given timeout
    ${time_start}=  BuiltIn.Get Time
    FOR    ${index}    IN RANGE    ${timeout}*60
        ${time_acctual}=  BuiltIn.Get Time
        ${time_elapsed}=  DateTime.Subtract Date From Date  ${time_acctual}  ${time_start}  number
        ${time_remained}=  BuiltIn.Evaluate  ${timeout}*60-${time_elapsed}
        Exit For Loop If  ${time_remained} <= 0
        ${reset_counter}  ${resets_reasons}=  Get New Resets Number and Reasons  ${old_reset_reason_list}  ${timeout}  ${alias}
        Exit For Loop If  ${reset_counter} > 0
    END
    Run Keyword If  ${reset_counter} == 0  Log  No reset occurred  level=INFO
    ...  ELSE IF  ${reset_counter} == 1  Log  Reset occurred  level=INFO
    ...  ELSE IF  ${reset_counter} > 1  Log  Occurred more than one resets  level=INFO
    Return From Keyword If  ${reset_counter} > 0  ${TRUE}  ${resets_reasons}
    [Return]  ${FALSE}  ${EMPTY}

Check Presence Of Active Alarms Via SEM CLI
    [Documentation]
    ...  KW for launching SEM CLI command 'GetActiveAlarms' and checking if any alarms will be visible (which will appear
    ...  in result file as 'Not OK' state). File content is logged to report. In file active alarms are visible.
    ...
    ...  *AUTHOR* patryk.furman@nokia.com
    ...
    ...  | Input Parameters | Man. | Description  |
    ...  | alias      | Yes  | BTSSM alias |
    ...
    ...  *RETURN*
    ...  - TRUE - if state in file is different than 'Not OK'
    ...  - FALSE - if state in file is 'Not OK'
    ...
    ...  *EXAMPLE*
    ...  | Check Presence Of Active Alarms Via SEM CLI | MSM |

    [Arguments]  ${alias}
    ${result_files}=  ute_btssm.Get active alarms  alias=${alias}
    Copy file  ${result_files[-1]}  ${Test Files}/
    ${alarm_file}=  OperatingSystem.Get file  ${result_files[-1]}
    Log  ${alarm_file}  console=True
    ${matches}=  Get Regexp Matches  ${alarm_file}  Not OK
    Return From Keyword If  ${matches}  ${FALSE}
    [Return]  ${TRUE}

#Upload Licenses Via FTP To BTS
#    [Documentation]
#    ...  KW for uploading license file from directory located in testline config to destination BTS directory.
#    ...
#    ...  *AUTHOR* patryk.furman@nokia.com
#    ...
#    ...  | Input Parameters      | Man. | Description                                                               |
#    ...  | destination_dir | Yes  | Directory on SM to which licenses should be uploaded                           |
#    ...  | testline_name   | No   | Testline name from env_config.yaml (default value of ${TESTLINE_NAME} variable |
#    ...  | sm_ip           | No   | SM IP (default 192.168.255.129)                                                  |
#    ...  | sm_username     | No   | SM username used for log in via FTP (default toor4nsn)                         |
#    ...  | sm_password     | No   | SM password used for log in via FTP (default oZPS0POrRieRtu)                   |
#    ...
#    ...  *EXAMPLE*
#    ...  | Upload licenses via FTP to BTS | /ffs/run/config/PersDataFiles/licenses |
#
#    [Arguments]  ${destination_dir}  ${testline_name}=${TESTLINE_NAME}  ${sm_ip}=192.168.255.129  ${sm_username}=toor4nsn
#    ...          ${sm_password}=oZPS0POrRieRtu
#    FTP CONNECT  ${sm_ip}  ${sm_username}  ${sm_password}
#    Cwd  ${destination_dir}
#    ${items_in_dir}=  OperatingSystem.List directory
#    ...    /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${testline_name}/licenses
#    FOR  ${item}  IN  @{items_in_dir}
#    ${status}=  Upload file  /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${testline_name}/licenses/${item}
#    Run keyword if  '${status}' != '226 Transfer complete.'
#    ...    Log  Uploading file ${item} ended with wrong status: ${status}  level=WARN
#    END
#    [Teardown]  FTP CLOSE

Check if BTS is unblocked
    [Documentation]
    ...  Function which checks if BTS unblocked. If it is blocked, function unblocks it and wait
    ...  some time for establishment.
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Input Parameter | Man. | Description                                        |
    ...  | alias     | Yes  | Alias used via ute_btssm library (Slave or Master) |
    ...
    ...  *EXAMPLE*
    ...  | Check if BTS is unblocked | Master |

    [Arguments]  ${alias}
    ${bts_details_list}=  Get BTS State  ${alias}
    FOR  ${bts}  IN  @{bts_details_list}
        Run Keyword If  '${bts[1]}' == 'blocked'  Run Keywords
        ...  Unblock BTS  alias=${alias}  AND
        ...  Sleep  180s  Wait for BTS ${bts[0]} establish  AND
        ...  Log  BTS ${bts[0]} unblock indicated  console=True
    END

#Get file from BTS
#    [Documentation]
#    ...    Download file from BTS using FTP
#    ...
#    ...    *AUTHOR* sebastian.burniak@nokia.com
#    ...
#    ...    | Input Parameter            | Man. | Description                                  |
#    ...    | path to bts file     | Yes  | path to directory on BTS where file is located     |
#    ...    | filename             | Yes  | Name of file                                       |
#    ...    | ip_address           | No   | IP address to SM, default 192.168.255.129            |
#    ...    | destination          | No   | Place where file should be saved, default /tmp     |
#    ...
#    ...    *RETURN*
#    ...    path to file where file is saved
#    ...
#    ...    *EXAMPLE*
#    ...    | Get file from BTS | /rom/config/lifedata/ | blackbox |
#    [Arguments]  ${path_to_bts_file}  ${filename}  ${ip_address}=192.168.255.129  ${destination}=/tmp/
#    Ftp connect    ${ip_address}    toor4nsn   oZPS0POrRieRtu
#    Cwd   ${path_to_bts_file}
#    ${path}=  Download file   ${filename}    ${destination}
#    ${file_path}=  Set variable  ${destination}${filename}
#    [Teardown]  Ftp Close
#    [Return]    ${file_path}

Get Reset Counter from Blackbox file
    [Arguments]  ${timeout}=2  ${alias}=default
    [Documentation]
    ...    *AUTHOR* dinu.olariu@nokia.com
    ...
    ...    | Input Parameter     | Man. | Description                                  |
    ...    | timeout             | No  | integer, timeout in minutes for blackbox upload operation    |
    ...    | alias               | No  | string                                       |
    ...
    ...    *RETURN VALUE*
    ...    Reset Counter value from Blackbox file
    ...
    ${blackbox_path}=  Get Blackbox From BTS  timeout=${timeout}  alias=${alias}
    ${blackbox_found}=  Run Keyword And Return Status  File Should Not Be Empty  ${blackbox_path}
    Run Keyword If  not ${blackbox_found} or '${blackbox_found}' == 'FAIL'  Fail  No Blackbox file collected!
    ${reset_counter}  ${reset_reason_list}=  Get Reset Info From File  ${blackbox_path}
    Log  RESET COUNTER:: ${reset_counter}  level=INFO
    [Return]  ${reset_counter}

Get BTS state SOAM
    [Documentation]
    ...  Helper keyword providing BTS states info for WCDMA or LTE. KW is returning a list of BTS info packed into it
    ...  as below:
    ...  WCDMA: bsId, blockingState, operationalStatus
    ...  LTE: distName, btsId, operationalState, administrativeState, availabilityStatus, blockingState, proceduralState
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter        | Man. | Default | Description                       |
    ...  | alias            | No   | default | alias of admin instance           |
    ...  | path_to_siteconf | No   | empty   | path to siteconf (only for WCDMA) |
    ...
    ...  *RETURN*
    ...  | Parameter            | Description |
    ...  | BTS_STATE_LIST       | List of BTS states |

    [Arguments]  ${alias}=default  ${path_to_siteconf}=${EMPTY}
    Run Keyword And Return If  '${MASTER['MASTER_TECH']}' == 'WCDMA' and '${alias}' == 'Master'
    ...  Get BTS state  ${alias}  ${path_to_siteconf}
    Run Keyword And Return If  '${MASTER['MASTER_TECH']}' == 'LTE' and '${alias}' == 'Master'
    ...  Admin Get LTE BTS state info  ${alias}
    Run Keyword And Return If  '${SLAVE['SLAVE_TECH']}' == 'LTE' and '${alias}' == 'Slave'
    ...  Admin Get LTE BTS state info  ${alias}
    [Return]  ${BTS_STATE_LIST}

Get SM state SOAM
    [Documentation]
    ...  Helper keyword providing system module states info for WCDMA or LTE. KW is returning a list of system module
    ...  info packed into it as below:
    ...  WCDMA: unitName, unitNumber, workingState, blockingState, operationalState
    ...  LTE: distName, SMODName, productName, operationalState, administrativeState, availabilityStatus, proceduralState
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter        | Man. | Default | Description                       |
    ...  | alias            | No   | default | alias of admin instance           |
    ...  | path_to_siteconf | No   | empty   | path to siteconf (only for WCDMA) |
    ...
    ...  *RETURN*
    ...  | Parameter            | Description |
    ...  | SM_STATE_LIST        | List of system module states |

    [Arguments]  ${alias}=default  ${path_to_siteconf}=${EMPTY}
    Run Keyword And Return If  '${MASTER['MASTER_TECH']}' == 'WCDMA' and '${alias}' == 'Master'
    ...  Get SM state  ${alias}  ${path_to_siteconf}
    Run Keyword And Return If  '${MASTER['MASTER_TECH']}' == 'LTE' and '${alias}' == 'Master'
    ...  Admin Get LTE SM state info  ${alias}
    Run Keyword And Return If  '${SLAVE['SLAVE_TECH']}' == 'LTE' and '${alias}' == 'Slave'
    ...  Admin Get LTE SM state info  ${alias}
    [Return]  ${SM_STATE_LIST}

Get RM state SOAM
    [Documentation]
    ...  Helper keyword providing radio modules states info for WCDMA or LTE. KW is returning a list of lists with
    ...  radio module info packed into it as below:
    ...  WCDMA: unitName, unitNumber, workingState, blockingState, operationalState
    ...  LTE: distName, RMODName, productName, operationalState, administrativeState, availabilityStatus
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter        | Man. | Default | Description                       |
    ...  | alias            | No   | default | alias of admin instance           |
    ...  | path_to_siteconf | No   | empty   | path to siteconf (only for WCDMA) |
    ...
    ...  *RETURN*
    ...  | Parameter            | Description |
    ...  | RM_STATE_LIST      | List of radio module states |

    [Arguments]  ${alias}=default  ${path_to_siteconf}=${EMPTY}
    Run Keyword And Return If  '${MASTER['MASTER_TECH']}' == 'WCDMA' and '${alias}' == 'Master'
    ...  Get RM state  ${alias}  ${path_to_siteconf}
    Run Keyword And Return If  '${MASTER['MASTER_TECH']}' == 'LTE' and '${alias}' == 'Master'
    ...  Admin Get LTE RM state info  ${alias}
    Run Keyword And Return If  '${SLAVE['SLAVE_TECH']}' == 'LTE' and '${alias}' == 'Slave'
    ...  Admin Get LTE RM state info  ${alias}
    [Return]  ${RM_STATE_LIST}

Get CELL state SOAM
    [Documentation]
    ...  Helper keyword providing cells states info for WCDMA or LTE. KW is returning a list of lists with cells info
    ...  packed into it as below:
    ...  WCDMA: globalCellId, workingState, blockingState, operationalState, cellAvailability
    ...  LTE: distName, LNCELName, operationalState, administrativeState, availabilityStatus, blockingState,
    ...  proceduralState
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter        | Man. | Default | Description                       |
    ...  | alias            | No   | default | alias of admin instance           |
    ...  | path_to_siteconf | No   | empty   | path to siteconf (only for WCDMA) |
    ...
    ...  *RETURN*
    ...  | Parameter            | Description |
    ...  | CELL_STATE_LIST      | List of cell states |

    [Arguments]  ${alias}=default  ${path_to_siteconf}=${EMPTY}
    Run Keyword And Return If  '${MASTER['MASTER_TECH']}' == 'WCDMA' and '${alias}' == 'Master'
    ...  Get CELL state  ${alias}  ${path_to_siteconf}
    Run Keyword And Return If  '${MASTER['MASTER_TECH']}' == 'LTE' and '${alias}' == 'Master'
    ...  Admin Get LTE CELL state info  ${alias}
    Run Keyword And Return If  '${SLAVE['SLAVE_TECH']}' == 'LTE' and '${alias}' == 'Slave'
    ...  Admin Get LTE CELL state info  ${alias}
    [Return]  ${CELL_STATE_LIST}

Check All Cell State SOAM
    [Documentation]
    ...  Helper keyword to check operational state of cells (WCDMA and LTE) or sectors (GSM).
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man.  | Default | Description |
    ...  | WCDMA_siteconf       | No    | empty   | path to siteconf (only for WCDMA) |
    ...  | GSM_BCF_ID           | No    | empty   | BCF id (only for GSM) |
    ...
    ...  *RETURN*
    ...  | Parameter            | Description |
    ...  | AllCell_Verdict      | True (all cells/sectors are enabled) or False (at least one is not enabled) |

    [Timeout]  200 sec
    [Arguments]  ${WCDMA_siteconf}=${EMPTY}  ${GSM_BCF_ID}=${EMPTY}
    ${MasterCell_Verdict}=  Set Variable  ${TRUE}
    ${SlaveCell_Verdict}=  Set Variable  ${TRUE}
    ${MasterCell_State}=  Get Master Cell State SOAM  ${WCDMA_siteconf}
    ${MasterCell_Verdict}=  Check Master Cell State SOAM  ${MasterCell_State}
    ${SlaveCell_State}=  Get Slave Cell State SOAM  ${GSM_BCF_ID}
    ${SlaveCell_Verdict}=  Check Slave Cell State SOAM  ${SlaveCell_State}  ${GSM_BCF_ID}
    ${AllCell_Verdict}=  Set Variable If  ${MasterCell_Verdict} and ${SlaveCell_Verdict}  ${TRUE}  ${FALSE}
    Run Keyword If  '${SLAVE['SLAVE_TECH']}'!='GSM'  Run Keywords
    ...  Log  ${MASTER['MASTER_TECH']} Cells enabled on 'Master': ${MasterCell_Verdict}  level=TRACE  console=${TRUE}  AND
    ...  LOG  ${SLAVE['SLAVE_TECH']} Cells enabled on 'Slave': ${SlaveCell_Verdict}  level=TRACE  console=${TRUE}
    ...  ELSE  Run Keywords
    ...  Log  ${MASTER['MASTER_TECH']} Cells enabled on 'Master': ${MasterCell_Verdict}  level=TRACE  console=${TRUE}  AND
    ...  Log  ${SLAVE['SLAVE_TECH']} BTSs enabled on 'Slave': ${SlaveCell_Verdict}  level=TRACE  console=${TRUE}
    [Return]  ${AllCell_Verdict}

Get Master Cell State SOAM
    [Arguments]  ${WCDMA_siteconf}=${EMPTY}
    Run Keyword And Return If  '${MASTER['MASTER_TECH']}'=='WCDMA'  Get CELL state SOAM  Master  ${WCDMA_siteconf}
    Run Keyword And Return If  '${MASTER['MASTER_TECH']}'=='LTE'  Get CELL state SOAM  Master
    [Return]  ${MasterCell_State}

Get Slave Cell State SOAM
    [Arguments]  ${GSM_BCF_ID}=${EMPTY}
    Run Keyword And Return If  '${SLAVE['SLAVE_TECH']}'=='LTE'  Get CELL state SOAM  Slave
    Run Keyword And Return If  '${SLAVE['SLAVE_TECH']}'=='GSM'  Get sectors ids  ${GSM_BCF_ID}
    [Return]  ${SlaveCell_State}

Check Master Cell State SOAM
    [Arguments]  ${MasterCell_State}=${EMPTY}
    Run Keyword And Return If  '${MASTER['MASTER_TECH']}'=='WCDMA'
    ...    Check WCDMA Cell Operational State SOAM  ${MasterCell_State}
    Run Keyword And Return If  '${MASTER['MASTER_TECH']}'=='LTE'
    ...    Check LTE Cell Operational State SOAM  ${MasterCell_State}
    [Return]  ${MasterCell_Verdict}

Check Slave Cell State SOAM
    [Arguments]  ${SlaveCell_State}=${EMPTY}  ${GSM_BCF_ID}=${EMPTY}
    Run Keyword And Return If  '${SLAVE['SLAVE_TECH']}'=='LTE'  Check LTE Cell Operational State SOAM  ${SlaveCell_State}
    Run Keyword And Return If  '${SLAVE['SLAVE_TECH']}'=='GSM'  Check GSM Bts Operational State SOAM  ${GSM_BCF_ID}
    [Return]  ${SlaveCell_Verdict}

Check WCDMA Cell Operational State SOAM
    [Arguments]  ${Cell_State}
    ${WCDMACell_Verdict}=  Set Variable  ${TRUE}
    FOR  ${item}  IN  @{Cell_State}
        Log  WCDMA CELL ${item[0]} - Operational State: ${item[3]}  level=DEBUG  console=${TRUE}
        ${WCDMACell_Verdict}=  Set Variable If  '${item[3]}' != 'enabled'  ${FALSE}  ${WCDMACell_Verdict}
    END
    [Return]  ${WCDMACell_Verdict}

Check LTE Cell Operational State SOAM
    [Arguments]  ${Cell_State}
    ${LTECell_Verdict}=  Set Variable  ${TRUE}
    FOR  ${item}  IN  @{Cell_State}
        Log  LTE CELL ${item[1]} - Operational State: ${item[2]}  level=DEBUG  console=${TRUE}
        ${LTECell_Verdict}=  Set Variable If  '${item[2]}' != 'Enabled'  ${FALSE}  ${LTECell_Verdict}
    END
    [Return]  ${LTECell_Verdict}

Check GSM Bts Operational State SOAM
    [Arguments]  ${GSM_BCF_ID}
    ${GSMBts_Verdict}=  Set Variable  ${TRUE}
    ${GSMBts_status}=  Get sectors status  ${GSM_BCF_ID}
    FOR  ${item}  IN  @{GSMBts_status}
        Log  GSM ${item[0]} - Operational State: ${item[2]}  level=DEBUG  console=${TRUE}
        ${GSMBts_Verdict}=  Set Variable If  '${item[2]}' != 'WO'  ${FALSE}  ${GSMBts_Verdict}
    END
    [Return]  ${GSMBts_Verdict}

Check All RM State SOAM
    [Documentation]
    ...  Helper keyword to check operational state of radio modules (WCDMA and LTE) or TRXs (GSM).
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man.  | Default | Description |
    ...  | WCDMA_siteconf       | No    | empty   | path to siteconf (only for WCDMA) |
    ...  | GSM_BCF_ID           | No    | empty   | BCF id (only for GSM) |
    ...
    ...  *RETURN*
    ...  | Parameter            | Description |
    ...  | AllRM_Verdict        | True (all radio modules/TRXs are enabled) or False (at least one is not enabled) |

    [Timeout]  200 sec
    [Arguments]  ${WCDMA_siteconf}=${EMPTY}  ${GSM_BCF_ID}=${EMPTY}
    ${MasterRM_Verdict}=  Set Variable  ${TRUE}
    ${SlaveRM_Verdict}=  Set Variable  ${TRUE}
    ${MasterRM_State}=  Get Master RM State SOAM  ${WCDMA_siteconf}
    ${MasterRM_Verdict}=  Check Master RM State SOAM  ${MasterRM_State}
    ${SlaveRM_State}=  Get Slave RM State SOAM  ${GSM_BCF_ID}
    ${SlaveRM_Verdict}=  Check Slave RM State SOAM  ${SlaveRM_State}  ${GSM_BCF_ID}
    ${AllRM_Verdict}=  Set Variable If  ${MasterRM_Verdict} and ${SlaveRM_Verdict}  ${TRUE}  ${FALSE}
    Run Keyword If  '${SLAVE['SLAVE_TECH']}'!='GSM'  Run Keywords
    ...  Log  ${MASTER['MASTER_TECH']} RMs enabled on 'Master': ${MasterRM_Verdict}  level=TRACE  console=${TRUE}  AND
    ...  Log  ${SLAVE['SLAVE_TECH']} RMs enabled on 'Slave': ${SlaveRM_Verdict}  level=TRACE  console=${TRUE}
    ...  ELSE  Run Keywords
    ...  Log  ${MASTER['MASTER_TECH']} RMs enabled on 'Master': ${MasterRM_Verdict}  level=TRACE  console=${TRUE}  AND
    ...  Log  ${SLAVE['SLAVE_TECH']} TRXs enabled on 'Slave': ${SlaveRM_Verdict}  level=TRACE  console=${TRUE}
    [Return]  ${AllRM_Verdict}

Get Master RM State SOAM
    [Arguments]  ${WCDMA_siteconf}=${EMPTY}
    Run Keyword And Return If  '${MASTER['MASTER_TECH']}'=='WCDMA'  Get RM state SOAM  Master  ${WCDMA_siteconf}
    Run Keyword And Return If  '${MASTER['MASTER_TECH']}'=='LTE'  Get RM state SOAM  Master
    [Return]  ${MasterRM_State}

Get Slave RM State SOAM
    [Arguments]  ${GSM_BCF_ID}=${EMPTY}
    Run Keyword And Return If  '${SLAVE['SLAVE_TECH']}'=='LTE'  Get RM state SOAM  Slave
    Run Keyword And Return If  '${SLAVE['SLAVE_TECH']}'=='GSM'  Get trxs ids  ${GSM_BCF_ID}
    [Return]  ${SlaveRM_State}

Check Master RM State SOAM
    [Arguments]  ${MasterRM_State}=${EMPTY}
    Run Keyword And Return If  '${MASTER['MASTER_TECH']}'=='WCDMA'  Check WCDMA RM Operational State SOAM  ${MasterRM_State}
    Run Keyword And Return If  '${MASTER['MASTER_TECH']}'=='LTE'  Check LTE RM Operational State SOAM  ${MasterRM_State}
    [Return]  ${MasterRM_Verdict}

Check Slave RM State SOAM
    [Arguments]  ${SlaveRM_State}=${EMPTY}  ${GSM_BCF_ID}=${EMPTY}
    Run Keyword And Return If  '${SLAVE['SLAVE_TECH']}'=='LTE'  Check LTE RM Operational State SOAM  ${SlaveRM_State}
    Run Keyword And Return If  '${SLAVE['SLAVE_TECH']}'=='GSM'  Check GSM Trx Operational State SOAM  ${GSM_BCF_ID}
    [Return]  ${SlaveRM_Verdict}

Check WCDMA RM Operational State SOAM
    [Arguments]  ${RM_State}
    ${WCDMARM_Verdict}=  Set Variable  ${TRUE}
    FOR  ${item}  IN  @{RM_State}
        Log  WCDMA RM ${item[0]} ${item[1]} - Operational State: ${item[4]}  level=DEBUG  console=${TRUE}
        ${WCDMARM_Verdict}=  Set Variable If  '${item[4]}' != 'enabled'  ${FALSE}  ${WCDMARM_Verdict}
    END
    [Return]  ${WCDMARM_Verdict}

Check LTE RM Operational State SOAM
    [Arguments]  ${RM_State}
    ${LTERM_Verdict}=  Set Variable  ${TRUE}
    FOR  ${item}  IN  @{RM_State}
        Log  LTE RM ${item[1]} ${item[2]} - Operational State: ${item[3]}  level=DEBUG  console=${TRUE}
        ${LTERM_Verdict}=  Set Variable If  '${item[3]}' != 'Enabled'  ${FALSE}  ${LTERM_Verdict}
    END
    [Return]  ${LTERM_Verdict}

Check GSM Trx Operational State SOAM
    [Arguments]  ${GSM_BCF_ID}
    ${GSMTrx_Verdict}=  Set Variable  ${TRUE}
    ${GSMTrx_status}=  Get trxs status  ${GSM_BCF_ID}
    FOR  ${item}  IN  @{GSMTrx_status}
        Log  GSM ${item[0]} - Operational State: ${item[2]}  level=DEBUG  console=${TRUE}
        ${GSMTrx_Verdict}=  Set Variable If  '${item[2]}' != 'WO'  ${FALSE}  ${GSMTrx_Verdict}
    END
    [Return]  ${GSMTrx_Verdict}

Check if all cells are unblocked SOAM
    [Documentation]
    ...  Function which checks if all cells are unblocked. If cell is blocked, it unblocks it and wait
    ...  some time for establishment.
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  | Parameter | Man. | Default | Description             |
    ...  | alias     | No   | default | alias of admin instance |
    ...
    ...  *RETURN*
    ...  Fails if not all cells are unblocked at end of execution
    ...
    ...  *EXAMPLE*
    ...  | Check if all cells are unblocked  SOAM | Master |

    [Arguments]  ${alias}=default
    Run Keyword If  '${MASTER['MASTER_TECH']}' == 'WCDMA' and '${alias}' == 'Master'
    ...  Check if all cells are unblocked  ${alias}
    Run Keyword If  '${MASTER['MASTER_TECH']}' == 'LTE' and '${alias}' == 'Master'
    ...  Admin Check if all cells are unblocked  ${alias}
    Run Keyword If  '${SLAVE['SLAVE_TECH']}' == 'LTE' and '${alias}' == 'Slave'
    ...  Admin Check if all cells are unblocked  ${alias}

Check if BTS is unblocked SOAM
    [Documentation]
    ...  Function which checks if BTS is unblocked. If BTS is blocked, it unblocks it and waits
    ...  some time for establishment.
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  | Parameter | Man. | Default | Description             |
    ...  | alias     | No   | default | alias of admin instance |
    ...
    ...  *RETURN*
    ...  Fails if BTS is not unblocked at end of execution
    ...
    ...  *EXAMPLE*
    ...  | Check if BTS is unblocked SOAM | Master |

    [Arguments]  ${alias}=default
    Run Keyword If  '${MASTER['MASTER_TECH']}' == 'WCDMA' and '${alias}' == 'Master'
    ...  Check if BTS is unblocked  ${alias}
    Run Keyword If  '${MASTER['MASTER_TECH']}' == 'LTE' and '${alias}' == 'Master'
    ...  Admin Check if BTS is unblocked  ${alias}
    Run Keyword If  '${SLAVE['SLAVE_TECH']}' == 'LTE' and '${alias}' == 'Slave'
    ...  Admin Check if BTS is unblocked  ${alias}


Get RESET info from blackbox file
    [Documentation]
    ...  Get RESET timestamp and reason info from blackbox file (only for WCDMA or LTE)

    [Timeout]  5 min
    [Arguments]  ${alias}  ${when}
    ${reset_reason}=  Get Reset Reason Info  alias=${alias}
    Set Test Variable  ${${alias}_reset_reason_${when}}  ${reset_reason}
    Log  ${${alias.upper()}\['${alias.upper()}_TECH']} ${alias} RESET timestamp and reason:   console=True
    Log    ${${alias}_reset_reason_${when}}[-1]  console=True

Check Blackbox reset behavior
    [Documentation]
    ...  Final RESET info are compared with initial RESET info (only for WCDMA or LTE)

    [Timeout]  5 min
    [Arguments]  ${reset_reason_initial}  ${reset_reason_final}  ${expected_reset_number}
    ${reset_reason_diff}=  List Diff  ${reset_reason_final}  ${reset_reason_initial}
    ${reset_number}=  Get Length  ${reset_reason_diff}
    Set Test Variable  ${blackbox_reset_number}  ${reset_number}
    Should Be Equal As Integers  ${expected_reset_number}  ${reset_number}

Check techno reset behavior
    [Timeout]  15 min
    [Arguments]  ${tech}  ${alias}  ${expected_reset_number}  ${log_level}=ERROR

    ${is_SWM}=  Run Keyword And Return Status  Should Contain  ${TEST_NAME}  SWM
    Run Keyword If  '${alias}' == 'Slave' and ${is_SWM}
    ...    Get file from another virtual machine  source_path=${Temp Logs Dir}/SlaveUDP
    ...  destination_path=${Temp Logs Dir}/SlaveUDP  ip=${SLAVE['SLAVE_PC_IP_ADDRESS']}
    ...   username=${SLAVE['SLAVE_PC_SSH_USERNAME']}
    ...   password=${SLAVE['SLAVE_PC_SSH_PASSWORD']}

    ${blackbox_reset_verdict}  Run Keyword And Return Status
    ...  Check Blackbox reset behavior  ${${alias}_reset_reason_initial}  ${${alias}_reset_reason_final}
    ...    ${expected_reset_number}

    Run Keyword If  ${blackbox_reset_verdict}    Run Keywords
    ...    Log  ${tech} ${alias} reset behavior as expected (expected/found reset number:   console=True
    ...    AND    Log    ${expected_reset_number}/${blackbox_reset_number})!  console=True
    ...    ELSE  Run Keyword If  '${log_level}'=='WARN'    Run Keywords
    ...    Log  ${tech} ${alias} reset behavior not as expected (expected/found reset number:     level=WARN
    ...    AND Log    ${expected_reset_number}/${blackbox_reset_number})!    level=WARN
    ...    ELSE  Run Keyword If  '${log_level}'=='ERROR'  Run Keywords
    ...    Log  ${tech} ${alias} reset behavior not as expected (expected/found reset number:
    ...    AND   Log     ${expected_reset_number}/${blackbox_reset_number})!   evel=ERROR
    ...    AND   Log  ${tech} ${alias} reset behavior not as expected
    ...    AND    Fail    (expected/found reset number: ${expected_reset_number}/${blackbox_reset_number})!

Check TRX reset behavior
    [Documentation]
    ...  TRXs status are compared with BL-BCF or BL-RST or BL-RSL values.

    [Timeout]  5 min
    [Arguments]  ${expected_reset_verdict}
    ${bl_bcf}=  Run Keyword And Return Status  Parse bcf trxs status  ${SLAVE['BCF_ID']}  BL-BCF  U
    ${bl_rst}=  Run Keyword And Return Status  Parse bcf trxs status  ${SLAVE['BCF_ID']}  BL-RST  U
    ${bl_rsl}=  Run Keyword And Return Status  Parse bcf trxs status  ${SLAVE['BCF_ID']}  BL-RSL  U
    ${reset_verdict}=  Set Variable If  ${bl_bcf} is True or ${bl_rst} is True or ${bl_rsl} is True  True  False
    Should Be Equal  ${expected_reset_verdict}  ${reset_verdict}

Check TRX reset behavior with TSM
    [Documentation]
    ...  TRXs status are compared with BL-BTS or BL-TRX or WO values, depending on case if TRX is on shared RM or
    ...  standalone RM
    ...
    ...  | Parameter                | Man.  | Default | Description                                 |
    ...  | expected_reset_verdict   | Yes   |         | indicates if a TRX reset is expected or not |
    ...
    ...  *RETURN*
    ...  Detects if a TRX reset has taken place according to expeted TRX states, and passes / fails according to
    ...  the expected event indicated in the argument

    [Timeout]  5 min
    [Arguments]  ${expected_reset_verdict}
    ${rf_units_sharing_info}  ${log}=  hran_elementmanager2g.rf units sharing state
    ${trxs_statuses}=  hran_bsc.get trxs status  ${SLAVE['BCF_ID']}
    ${new_trxs_statuses}=  Create List
    ${trx_statuses_during_reset}=  Create List  BL-BTS  BL-TRX
    FOR  ${trx_info}  IN  @{trxs_statuses}
        ${trx_number}=  Get Regexp Matches  ${trx_info[0]}  TRX-0*([1-9]+[0-9]*)  1
        ${newkey}=  Set Variable  TRX-${trx_number[0]}
        ${new_trx_status_item}=  Create List
        Append to list  ${new_trx_status_item}  ${newkey}  ${trx_info[1]}  ${trx_info[2]}
        Append to list  ${new_trxs_statuses}  ${new_trx_status_item}
    END
    ${not_shared}=  Create List
    FOR  ${radio_unit}  IN  @{rf_units_sharing_info.keys()}
        ${trx_list}  ${log}=  hran_elementmanager2g.get related trxs  ${radio_unit}
        Run Keyword If  '${rf_units_sharing_info[\'${radio_unit}\']}'=='NotShared'
        ...  Append To List  ${not_shared}  @{trx_list}
    END

    FOR  ${trx_values}  IN  @{new_trxs_statuses}
        ${reset_verdict}=  Run Keyword And Return Status
        ...  Run Keyword If  \'${trx_values[0]}\' in @{not_shared}
        ...  Run Keywords
        ...  Should Be Equal  ${trx_values[1]}  U
        ...  AND
        ...  Should Be Equal  ${trx_values[2]}  WO
        ...  ELSE
        ...  Run Keywords
        ...  Should Be Equal  ${trx_values[1]}  U
        ...  AND
        ...  List Should Contain Value  ${trx_statuses_during_reset}  ${trx_values[2]}
    END
    Should Be Equal  '${expected_reset_verdict}'  '${reset_verdict}'

Check TSM activation
    [Documentation]
    ...  scf file will be downloaded to VM1, then in the SCF.xml the activation of Temp Sync Master will be checked
    ...
    ...    *RETURN*
    ...    | Parameter        | Description                                                                      |
    ...    | tsm_activated    | boolean value which is True if temproary ync Master is activated, false otherwise|

    [Timeout]  15 min
    ${xpath_expression}=  Set Variable
    ...  .//*[local-name()=\'p\'][(@name=\'tempSyncMasterRecovTime\') or (@name=\'tempSyncMasterTriggerTime\')][text()=255]
    ${logs_folder}=  Get Variable Value  ${BTSFiles}
    ${folder_not_present}=  Run Keyword And Return Status  OperatingSystem.Directory Should Not Exist  ${BTSFiles}/Slave
    Run Keyword If  ${folder_not_present}  Create Directory  ${BTSFiles}/Slave
    ${result}  ${logs}=  Get Scf Parameter  ${xpath_expression}  xpath  ${BTSFiles}/Slave
    ${nbr}=  Get Length  ${result}
    ${tsm_activated}=  Set Variable If  ${nbr}!=0  False  True
    Log  ===== TSM activated: ${tsm_activated}  console=True  level=INFO

    [Return]  ${tsm_activated}

Check Slave Sync Master
    [Documentation]
    ...  checks if Slave SM clock is syncMaster by infomodel methods
    ...  returns true or false depending on read value
    ...
    ...    *RETURN*
    ...    | Parameter | Description                                                |
    ...    | value     | True or False: syncMaster under CLOCK_FDD_A-1 or CLOCK_A-1 |

    ${CLOCK_FDD_A-1_found}=  Check Infomodel Object  dist_name=//CLOCK_FDD_A-1  alias=Slave
    ${CLOCK_A-1_found}=  Check Infomodel Object  dist_name=//CLOCK_A-1  alias=Slave
    ${value}=  Run Keyword If  ${CLOCK_FDD_A-1_found}  Query Infomodel  query=get object //CLOCK_FDD_A-1  alias=Slave
    ...  ELSE IF  ${CLOCK_A-1_found}  Query Infomodel  query=get object //CLOCK_A-1  alias=Slave
    Log  Slave CLOCK as syncMaster enabled: ${value.syncMaster}  console=True  level=INFO
    [Return]  ${value.syncMaster}

Check if GSM BTS are unblocked
    [Documentation]
    ...  Function which checks if all GSM BTS are unblocked. If any of it is blocked, function unblocks it and wait
    ...  some time for establishment.
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...

    ${bts_state}  ${log}=  Get Current States Of All Bts
    ${bts_state_keys}=  Get Dictionary Keys  ${bts_state}
    ${bts_state_values}=  Get Dictionary Values  ${bts_state}
    FOR  ${key}  ${value}  IN ZIP  ${bts_state_keys}  ${bts_state_values}
        Run Keyword If  '${value}' == 'Blocked'  Run Keywords
        ...  Unblock Bts By Id  ${key}
        ...  AND  Sleep  5s  Wait for ${key} establish
        ...  AND  Log  GSM BTS ${key} unblock indicated  console=True
    END

Check if GSM BCF is unblocked
    [Documentation]
    ...  Function which checks if GSM BCF is unblocked. If it is blocked,
    ...    function unblocks it and wait some time for establishment.
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...

    ${bcf_state}  ${log}=  Get Bcf Object State
    Run Keyword If  '${bcf_state}' == 'Blocked'  Run Keywords
    ...  Unblock Bcf
    ...  AND  Sleep  5s  Wait for GSM BCF establish
    ...  AND  Log  GSM BCF unblock indicated  console=True

SCF backup on demand
    [Documentation]
    ...  Procedure for SCF backup as below:
    ...  - upload BTS SCF.xml file from BTS to VM as below:
    ...    - for GSM, save BTS SCF.xml file at SCF backup ${folder_path} path
    ...    - for WCDMA or LTE, BTS SCF.xml file is saved in specific path of KW Upload Bts Scfc File
    ...  - for WCDMA or LTE move BTS SCF.xml file on VM at SCF backup ${folder_path} path
    ...  - check BTS SCF.xml availability at at SCF backup ${folder_path} path
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com
    ...
    ...    | Parameter      | Man.  | Default | Description                                     |
    ...    | alias          | no    |         | alias of ute_btssm instance                     |
    ...    | tech           | yes   |         | technology for requested SCF backup             |
    ...    | folder_path    | no    |         | folder path for requested SCF backup file store |

    [Timeout]  20 min
    [Arguments]  ${alias}=default  ${tech}=${EMPTY}  ${folder_path}=/home/ute/btsauto/logs

    ${status}=  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${folder_path}
    Run Keyword Unless  ${status}  Create Directory  ${folder_path}

    Set Test Variable  ${SCF_backup_file}  ${alias}_${tech}_scf.xml

    Run Keyword If  '${tech}' == 'GSM'  Run Keywords
    ...  Save Scf File  ${folder_path}/${alias}_${tech}_scf.bz2
    ...  AND  OperatingSystem.Remove File  ${folder_path}/${alias}_${tech}_scf.bz2
    ...  ELSE IF  '${tech}' == 'WCDMA' or '${tech}' =='LTE'  Run Keywords
    ...  BTSSM Upload Bts Scfc File  alias=${alias}
    ...  AND  Move File  ${SCF_PATH}/${SCF_FILE}  ${folder_path}/${SCF_backup_file}
    ...  ELSE  Run Keywords
    ...  Log  Wrong Technology for SCF backup!  level=ERROR  console=True
    ...  AND  Fail  Wrong Technology for SCF backup!

    ${status}=  Run Keyword And Return Status
    ...  OperatingSystem.File Should Exist  ${folder_path}/${SCF_backup_file}
    Run Keyword If  ${status}
    ...  Log  SCF file ${SCF_backup_file} available at ${folder_path}  level=INFO  console=True
    ...  ELSE  Run Keywords
    ...  Log  SCF file ${SCF_backup_file} not available at ${folder_path}  level=ERROR  console=True
    ...  AND  Fail  SCF file ${SCF_backup_file} not available at ${folder_path}
    [Return]  ${folder_path}  ${SCF_backup_file}


Get LTE release
    [Documentation]
    ...  KW for obtaining LTE release (FL with number) from BTS (TargetBD file) via SSH connection. Fails if no TargetBD
    ...  is found.
    ...
    ...  *AUTHOR*
    ...  patryk.furman@nokia.com

    sshLibrary.Open Connection  ${SMOD1['IP']}
    sshLibrary.Login  ${SMOD1['USERNAME']}  ${SMOD1['PASSWORD']}
    ${target_bd}=  sshLibrary.List Files In Directory  /ffs/run  TargetBD*.xml
    Should not be empty  ${target_bd}  TargetBD not found under /ffs/run!
    ${release}=  Get regexp matches  ${target_bd[0]}  FL\\d{2}A?
    [Return]  ${release[0]}
    [Teardown]  sshLibrary.Close Connection

Get full name of file with pattern
    [Documentation]    Finds file with pattern in given directory and retruns full name
    ...
    ...  *AUTHOR*
    ...  sebastian.burniak@nokia.com
    ...
    ...  | Parameter               | Man. | Description                                    |
    ...  | pattern                 | Yes  | Pattern to find                                |
    ...  | dir_path                | Yes  | Path to directory where file should be search  |
    ...
    ...  *EXAMPLE*
    ...  Get path to file with pattern | .zip | /home/ute/btsauto/TARGET_DIR |
    [Arguments]    ${pattern}    ${dir_path}
    @{all_files}=    OperatingSystem.List directory    ${dir_path}
    FOR    ${file}    IN    @{all_files}
        ${found_file}=     Set variable if    '${pattern}' in '${file}'    ${file}    ${EMPTY}
        Return from keyword if    '${found_file}'!=''    ${found_file}
    END
    Run keyword if    '${found_file}'==''    Fail    Not found file in ${dir_path} match to given pattern ${pattern}

Check All Cells and RMs Number
    [Documentation]
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  Keyword used to check if all configured cells and radio modules are properly mapped on BTS running view.
    ...  The check is performed on both Master and Slave technologies, except of GSM.
    ...
    ...  *RETURN VALUE*
    ...  Verdict info as beneath:
    ...  True  - Configured cells and radio modules in SCF are properly mapping on BTS running view
    ...  False - Configured cells and radio modules in SCF are not properly mapping on BTS running view
    ...
    [Arguments]  ${master_siteconf}=${EMPTY}  ${slave_siteconf}=${EMPTY}  ${master_scf}=${EMPTY}  ${slave_scf}=${EMPTY}

    ${Master_BTSConf}=  Check BTS Configuration  Master  ${master_siteconf}  ${master_scf}
    ${Slave_BTSConf}=  Run Keyword If
    ...  '${SLAVE['SLAVE_TECH']}'!='GSM'  Check BTS Configuration  Slave  ${slave_siteconf}  ${slave_scf}
    ...  ELSE
    ...  Set Variable  ${TRUE}

    ${All_BTSConf}=  Run Keyword If  '${SLAVE['SLAVE_TECH']}'!='GSM'
    ...  Set Variable If  ${Master_BTSConf} and ${Slave_BTSConf}  ${TRUE}  ${FALSE}
    ...  ELSE
    ...  Set Variable  ${Master_BTSConf}

    Run Keyword If  '${SLAVE['SLAVE_TECH']}'!='GSM' and ${All_BTSConf}
    ...  Log  Properly BTS configuration on Master and Slave!  console=True
    ...  ELSE IF  '${SLAVE['SLAVE_TECH']}'=='GSM' and ${All_BTSConf}
    ...  Log  Properly BTS configuration on Master!  console=True

    Run Keyword Unless  ${Master_BTSConf}  Log  Wrong Master BTS configuration!  level=ERROR
    Run Keyword If  '${SLAVE['SLAVE_TECH']}'!='GSM'
    ...  Run Keyword Unless  ${Slave_BTSConf}  Log  Wrong Slave BTS configuration!  level=ERROR

    [Return]  ${All_BTSConf}

Check All Cells and RMs Number SOAM
    [Documentation]
    ...  *AUTHOR* serban.hamza@nokia.com
    ...
    ...  Keyword used to check if all configured cells and radio modules are properly mapped on BTS running view.
    ...  The check is performed on both Master and Slave technologies, except of GSM.
    ...
    ...  *RETURN VALUE*
    ...  Verdict info as beneath:
    ...  True  - Configured cells and radio modules in SCF are properly mapping on BTS running view
    ...  False - Configured cells and radio modules in SCF are not properly mapping on BTS running view
    ...
    [Arguments]  ${master_siteconf}=${EMPTY}  ${master_scf}=${EMPTY}  ${slave_scf}=${EMPTY}

    ${Master_BTSConf}=  Run Keyword If  '${MASTER['MASTER_TECH']}'=='WCDMA'
    ...  Check BTS Configuration  Master  siteconf_file=${master_siteconf}  scf_file=${master_scf}
    ...  ELSE IF  '${MASTER['MASTER_TECH']}' in ['NR','LTE']
    ...  Check BTS Configuration SOAM  Master  scf_file=${master_scf}
    ...  ELSE IF  '${MASTER['MASTER_TECH']}'=='SBTS'
    ...  Check BTS Configuration SBTS  Master  scf_file=${master_scf}

    ${Slave_BTSConf}=  Run Keyword If  '${SLAVE['SLAVE_TECH']}' in ['NR','LTE']
    ...  Check BTS Configuration SOAM  Slave  scf_file=${slave_scf}
    ...  ELSE IF  '${SLAVE['SLAVE_TECH']}'=='SBTS'
    ...  Check BTS Configuration SBTS  Slave  scf_file=${slave_scf}
    ...  ELSE
    ...  Set Variable  ${TRUE}

    ${All_BTSConf}=  Run Keyword If  '${SLAVE['SLAVE_TECH']}'!='GSM'
    ...  Set Variable If  ${Master_BTSConf} and ${Slave_BTSConf}  ${TRUE}  ${FALSE}
    ...  ELSE
    ...  Set Variable  ${Master_BTSConf}

    Run Keyword If  '${SLAVE['SLAVE_TECH']}'!='GSM' and ${All_BTSConf}
    ...  Log  Properly BTS configuration on Master and Slave!  console=True
    ...  ELSE IF  '${SLAVE['SLAVE_TECH']}'=='GSM' and ${All_BTSConf}
    ...  Log  Properly BTS configuration on Master!  console=True

    Run Keyword Unless  ${Master_BTSConf}  Log  Wrong Master BTS configuration!  level=ERROR
    Run Keyword If  '${SLAVE['SLAVE_TECH']}'!='GSM'
    ...  Run Keyword Unless  ${Slave_BTSConf}  Log  Wrong Slave BTS configuration!  level=ERROR

    [Return]  ${All_BTSConf}

Check BTS Configuration
    [Documentation]
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...
    ...  *RETURN VALUE*
    ...  None
    [Arguments]  ${alias}  ${siteconf_file}=${EMPTY}  ${scf_file}=${EMPTY}

    ${Siteconf_cell_number}  ${Siteconf_rm_number}=  Get Siteconf Cells And RMs Number  ${alias}  ${siteconf_file}
    ${SCF_cell_number}  ${SCF_rm_number}=  Get SCF Cells And RMs Number  ${alias}  ${scf_file}

    ${CELLConf}=  Run Keyword And Return Status   Should be equal  ${Siteconf_cell_number}  ${SCF_cell_number}
    ${RMConf}=  Run Keyword And Return Status   Should be equal  ${Siteconf_rm_number}  ${SCF_rm_number}
    ${BTSConf}=  Set Variable If  ${CELLConf} and ${RMConf}  ${TRUE}  ${FALSE}
    Log  ${alias} BTS configuration - configured/running cells number: ${SCF_cell_number}/${Siteconf_cell_number}
    ...   console=True
    Log  ${alias} BTS configuration - configured/running radio modules number: ${SCF_rm_number}/${Siteconf_rm_number}
    ...   console=True
    [Return]  ${BTSConf}

Check BTS Configuration SOAM
    [Documentation]
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...  *AUTHOR* serban.hamza@nokia.com
    ...
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...
    ...  *RETURN VALUE*
    ...  | Parameter | Description                        |
    ...  | BTSConf   | Check status for BTS configuration |
    ...
    [Arguments]  ${alias}  ${scf_file}=${EMPTY}

    ${Runtime_cell_number}  ${Runtime_IOT_cell_number}  ${Runtime_rm_number}=  Get Admin Cells And RMs Number  ${alias}
    ${SCF_cell_number}  ${SCF_IOT_cell_number}  ${SCF_rm_number}=  Get SCF Cells And RMs Number SOAM  ${alias}  ${scf_file}

    ${CELLConf}=  Run Keyword And Return Status   Should be equal  ${Runtime_cell_number}  ${SCF_cell_number}
    ${IOTConf}=  Run Keyword And Return Status   Should be equal  ${Runtime_IOT_cell_number}  ${SCF_IOT_cell_number}
    ${RMConf}=  Run Keyword And Return Status   Should be equal  ${Runtime_rm_number}  ${SCF_rm_number}
    ${BTSConf}=  Set Variable If  ${CELLConf} and ${IOTConf} and ${RMConf}  ${TRUE}  ${FALSE}
    Log  ${alias} BTS configuration - configured/running cells number: ${SCF_cell_number}/${Runtime_cell_number}
    ...    console=True
    Log  ${alias} BTS configuration - configured/running IOT cells number: ${SCF_IOT_cell_number}/${Runtime_IOT_cell_number}
    ...    console=True
    Log  ${alias} BTS configuration - configured/running radio modules number: ${SCF_rm_number}/${Runtime_rm_number}
    ...   console=True
    [Return]  ${BTSConf}

Get Admin Cells And RMs Number
    [Documentation]
    ...  Helper keyword providing number of NR or LTE cells and radio modules from WebEM running view.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *RETURN*
    ...  | Parameter               | Description                             |
    ...  | runtime_cell_number     | WebEM runtime view cells number         |
    ...  | IOT_runtime_cell_number | WebEM runtime view IOT cells number     |
    ...  | runtime_rmod_number     | WebEM runtime view radio modules number |
    ...
    [Arguments]  ${alias}
    ${alias_upper}=  Convert to Uppercase  ${alias}
    ${cell_ids}  ${IOT_cell_ids}=  Admin Get CELL Ids list  ${alias}
    Set Test Variable  ${${${alias_upper}\['${alias_upper}_TECH']}_cell_ids}  ${cell_ids}
    Set Test Variable  ${${${alias_upper}\['${alias_upper}_TECH']}_IOT_cell_ids}  ${IOT_cell_ids}
    ${runtime_cell_number}=  Get Length  ${cell_ids}
    ${IOT_runtime_cell_number}=  Get Length  ${IOT_cell_ids}

    ${rmod_ids}=  coam.Get Ids For All  RMOD  alias=${alias}
    Set Test Variable  ${${${alias_upper}\['${alias_upper}_TECH']}_rmod_ids}  ${rmod_ids}
    ${Runtime_rmod_number}=  Get Length  ${rmod_ids}

    [Return]  ${runtime_cell_number}  ${IOT_runtime_cell_number}  ${runtime_rmod_number}

Download scf.xml with timestamp
    [Documentation]
    ...  KW for downloading scf.xml from BTS to destination directory. Scf.xml gets name in form 'scf_time'
    ...  where time is the current time.
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter   | Man. | Description                                                    |
    ...  | alias       | Yes  | Alias used via ute_btssm library (Slave or Master)             |
    ...  | dir_to_copy | Yes  | Absolute path to directory where siteconf.xml should be placed |
    ...
    ...  *RETURN*
    ...  | Parameter     | Description                     |
    ...  | scf_path      | Path to downloaded scf.xml      |
    ...
    ...  *EXAMPLE*
    ...  | ${scf_file}= | Download siteconf.xml with timestamp | Master | /home/ute/btsauto/logs

    [Arguments]  ${alias}  ${dir_to_copy}
    ${time}=  Get time
    ${files_list}=  ute_btssm.Upload Bts Scfc File  scf_${time}  alias=${alias}
    Copy file  ${files_list[0]}  ${dir_to_copy}/
    [Return]  ${files_list[0]}

Get Siteconf Cells And RMs Number
    [Documentation]
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  Get Siteconf cells and radio modules number. Available for WCDMA and LTE technologies.
    ...
    ...  | Parameter     | Man. | Description                                                    |
    ...  | alias         | Yes  | Alias used via ute_btssm library (Slave or Master)             |
    ...  | siteconf_file | Yes  | Siteconf file from Slave or Master technology                  |
    ...
    ...  *RETURN VALUE*
    ...  Siteconf cells and radio modules number from WCDMA or LTE technologies.
    [Arguments]  ${alias}  ${siteconf_file}

    ${alias_upper}=  Convert to Uppercase  ${alias}

    ${Siteconf_cell_state}=  Get CELL state  ${alias}  ${siteconf_file}
    ${Siteconf_cell_number}=  Get Length  ${Siteconf_cell_state}
    ${Siteconf_rm_state}=  Get RM state  ${alias}  ${siteconf_file}
    ${Siteconf_rm_number}=  Get Length  ${Siteconf_rm_state}

    [Return]  ${Siteconf_cell_number}  ${Siteconf_rm_number}

Get SCF Cells And RMs Number
    [Documentation]
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  Get SCF cells and radio modules number. Available for WCDMA and LTE technologies.
    ...
    ...  | Parameter     | Man. | Description                                                    |
    ...  | alias         | Yes  | Alias used via ute_btssm library (Slave or Master)             |
    ...  | scf_file      | Yes  | SCF file from Slave or Master technology                       |
    ...
    ...  *RETURN VALUE*
    ...  SCF cells and radio modules number from WCDMA or LTE technologies.
    [Arguments]  ${alias}  ${scf_file}

    hran_file_operations.Setup Scfc Parser  scfc=${scf_file}  parser_technology=UNIVERSAL  alias=${alias}

    ${SCF_cell_number}=  hran_file_operations.Get Cells Count  alias=${alias}
    ${SCF_rm_number}=  hran_file_operations.Get Radios Count  alias=${alias}

    hran_file_operations.Teardown Scfc Parser  alias=${alias}

    [Return]  ${SCF_cell_number}  ${SCF_rm_number}

Get SCF Cells And RMs Number SOAM
    [Documentation]
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  Get NR or LTE cells, IOT cells and radio modules number from SCF.
    ...
    ...  | Parameter     | Man. | Description                  |
    ...  | alias         | Yes  | Alias may be Master or Slave |
    ...  | scf_file      | Yes  | LTE SCF file full path       |
    ...
    ...  *RETURN*
    ...  | Parameter               | Description                             |
    ...  | SCF_cell_number     | SCF configured LTE cells number         |
    ...  | SCF_IOT_cell_number | SCF configured LTE IOT cells number     |
    ...  | SCF_rm_number     | SCF configured LTE radio modules number |
    ...
    [Arguments]  ${alias}  ${scf_file}

    hran_file_operations.Setup Scfc Parser  scfc=${scf_file}  parser_technology=SBTS  alias=${alias}

    ${SCF_cell_number}=  hran_file_operations.Get Cells Count  alias=${alias}
    ${SCF_IOT_cell_number}=  hran_file_operations.Get IOT Cells Count  alias=${alias}
    ${SCF_rm_number}=  hran_file_operations.Get Radios Count  alias=${alias}

    hran_file_operations.Teardown Scfc Parser  alias=${alias}

    [Return]  ${SCF_cell_number}  ${SCF_IOT_cell_number}  ${SCF_rm_number}

Download Siteconf Files From All BTS
    ${master_siteconf}=  Download siteconf.xml with timestamp  Master  ${BTSFiles}/Master
    ${slave_siteconf}=  Run Keyword If  '${SLAVE['SLAVE_TECH']}'!='GSM'
    ...  Download siteconf.xml with timestamp  Slave  ${BTSFiles}/Slave

    [Return]  ${master_siteconf}  ${slave_siteconf}

Download SCF Files From All BTS
    ${master_scf}=  Download scf.xml with timestamp  Master  ${BTSFiles}/Master
    ${slave_scf}=  Run Keyword If  '${SLAVE['SLAVE_TECH']}'!='GSM'
    ...  Download scf.xml with timestamp  Slave  ${BTSFiles}/Slave

    [Return]  ${master_scf}  ${slave_scf}

Download SCF Files From All BTS SOAM
    ${master_scf}=  Run Keyword If  '${MASTER['MASTER_TECH']}'=='WCDMA'
    ...  Download scf.xml with timestamp  Master  ${BTSFiles}/Master
    ...  ELSE IF  '${MASTER['MASTER_TECH']}'in ['NR','LTE','SBTS']
    ...  Admin Collect scf.xml with timestamp TAF  alias=Master  folder_path=${BTSFiles}/Master
    ${slave_scf}=  Run Keyword If  '${SLAVE['SLAVE_TECH']}'!='GSM'
    ...  Admin Collect scf.xml with timestamp TAF  alias=Slave  folder_path=${BTSFiles}/Slave

    [Return]  ${master_scf}  ${slave_scf}

Get Master Shared RM IpAddress list
    [Documentation]
    ...  KW used to get all Master shared RM IP address list.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter        | Man. | Description                                |
    ...  | path_to_siteconf | No   | Path to siteconf file (use only for WCDMA) |
    ...
    ...  *RETURN*
    ...  | Parameter                 | Description                             |
    ...  | Shared_RM_IpAddress       | List of all Master shared RM IP address |
    ...
    [Arguments]  ${path_to_siteconf}=${EMPTY}
    ${Shared_RM_IpAddress}=  Run Keyword If  '${MASTER['MASTER_TECH']}' == 'WCDMA'
    ...  Siteconf Get Shared RM IpAddress list  Master  ${path_to_siteconf}
    ...  ELSE IF  '${MASTER['MASTER_TECH']}' == 'LTE'
    ...  Infomodel Get Shared RM IpAddress list  Master
    [Return]  ${Shared_RM_IpAddress}

PM collection on demand
    [Documentation]
    ...  Procedure for PM collection as below:
    ...  - create ${folder_path} if it doesn't exist
    ...  - collect PM archive from BTS to VM in specific path of KW Upload Pm Counters Bts Files
    ...  - move PM  archive at ${folder_path}
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com
    ...
    ...    | Parameter      | Man.  | Default | Description                   |
    ...    | alias          | no    |         | alias of ute_btssm instance   |
    ...    | folder_path    | no    |         | folder path for PM collection |

    [Timeout]  10 min
    [Arguments]  ${alias}=default  ${folder_path}=${Test Results Dir}/PMFiles

    ${status}=  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${folder_path}
    Run Keyword Unless  ${status}  Create Directory  ${folder_path}

    ${status}=  Run Keyword And Return Status  BTSSM Upload Pm Counters Bts Files  alias=${alias}
    Run Keyword If  ${status}
    ...  Move File  ${PM_PATH}/${${alias}_PM_ARCHIVE}  ${folder_path}/${${alias}_PM_ARCHIVE}
    ...  ELSE  Run Keywords
    ...  Set Test Variable  ${PM_collect}  ${False}
    ...  AND  Log  ${alias} PM archive collection failed!  level=WARN

    Run Keyword If  ${PM_collect}  Check PM archive transfer  ${alias}  ${folder_path}/${${alias}_PM_ARCHIVE}

Check PM archive transfer
    [Arguments]  ${alias}  ${folder_path}
    ${status}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${folder_path}
    Run Keyword If  ${status}
    ...  Log  ${alias} PM archive ${${alias}_PM_ARCHIVE} available at ${folder_path}  level=INFO  console=True
    ...  ELSE  Run Keywords
    ...  Set Test Variable  ${PM_collect}  ${False}
    ...  AND  Log  ${alias} PM archive ${${alias}_PM_ARCHIVE} not available at ${folder_path}  level=WARN

Check PM files on VM
    [Documentation]
    ...  KW used to check PM files info on VM.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter          | Man. | Description                                |
    ...  | PM_folder_archive  | Yes  | Absolute path for PM archive storage on VM |
    ...  | alias              | Yes  | Master or Slave                            |
    ...
    [Arguments]  ${PM_folder_archive}  ${alias}

    ${PM_file_name}=  OperatingSystem.Run  unzip -Z1 "${PM_folder_archive}" PM.BTS-*.${VM_UTC_date}*
    Log  PM files generated on ${alias} during last hour:  console=True
    ${PM_file_name}=  Replace String  ${PM_file_name}  \n  ${SPACE}
    Run Keyword If  '${PM_file_name}' != ''  Log  ${PM_file_name}  console=True
    ...  ELSE  Run Keywords
    ...  Set Test Variable  ${PM_check}  ${False}
    ...  AND  Log  No PM files generated on ${alias} during last hour!  level=WARN

    ${PM_archive_size}=  OperatingSystem.Run  du -k "${PM_folder_archive}" | cut -f1
    ${PM_archive_size}=  Convert To Integer  ${PM_archive_size}
    Run Keyword If  ${PM_archive_size} > 0  Log  PM archive size (K) for ${alias}: ${PM_archive_size}  console=True
    ...  ELSE  Run Keywords
    ...  Set Test Variable  ${PM_check}  ${False}
    ...  AND  Log  PM archive size (K) for ${alias} is empty!  level=WARN

    ${PM_file_count}=  OperatingSystem.Run  unzip -Z1 "${PM_folder_archive}" | wc -l
    Run Keyword If  ${PM_file_count} > 0  Log  Number of PM files inside PM archive for ${alias}: ${PM_file_count}
    ...   console=True
    ...  ELSE  Run Keywords
    ...  Set Test Variable  ${PM_check}  ${False}
    ...  AND  Log  No PM files inside PM archive for ${alias}!  level=WARN

Set SCF cells count
    [Documentation]
    ...  type: LTE GSM WCDMA
    ...
    ...  *AUTHOR*
    ...  jaroslaw.piszczala@nokia.com
    [Arguments]  ${type}
    ${has_correction}=  _Check if active software has correction for IoT cells
    Run Keyword And Return If    '${type}'=='LTE' and not ${has_correction}  Set test variable  ${SCF_COUNT_${type}}  -1
    ${scf_xml}=    XML.Parse Xml    ${BTS_scf_initial}
    ${NRBTS_scf_cell_number}   XML.Get Element Count    ${scf_xml}  .//managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]
    ${LTE_scf_cell_number}    XML.Get Element Count    ${scf_xml}   .//managedObject[@class="NOKLTE:LNCEL"]
    ${WCDMA_scf_cell_number}   XML.Get Element Count    ${scf_xml}   .//managedObject[@class="com.nokia.srbts.wcdma:WNCEL"]
    ${GSM_scf_cell_number}   XML.Get Element Count    ${scf_xml}   .//managedObject[@class="com.nokia.srbts.gsm:GNCEL"]
    ${scf_cells_count}=    Set Variable If    '${type}'=='GSM'    ${GSM_scf_cell_number}
    ...    '${type}'=='WCDMA'    ${WCDMA_scf_cell_number}
    ...    '${type}'=='LTE'    ${LTE_scf_cell_number}
    ...    '${type}'=='NR'    ${NRBTS_scf_cell_number}
    Set test variable  ${SCF_COUNT_${type}}  ${scf_cells_count}

_Check if active software has correction for IoT cells
    Run Keyword And Return If  '${SW_TYPE}'=='SBTS17A'
    ...    Check if ${active SW version} is newer than SBTS17A_ENB_2000_000879_000000
    Run Keyword And Return If  '${SW_TYPE}'=='SBTS18A'
    ...    Check if ${active SW version} is newer than SBTS18A_ENB_0000_000422_000034
    Run Keyword And Return If  '${SW_TYPE}'=='SBTS18SP'
    ...   Check if ${active SW version} is newer than SBTS18SP_ENB_0000_000027_000000
    Return From Keyword If     '${SW_TYPE}'=='SBTS18'    ${False}
    [Return]  ${True}

Check if ${software} is newer than ${given_software}
    ${software}=        _Get software version number  ${software}
    ${given_software}=  _Get software version number  ${given_software}
    ${is_newer}=  Evaluate  '${software}'>'${given_software}'
    [Return]    ${is_newer}

_Get software version number
    [Arguments]  ${software}
    ${version_number}=  Evaluate  '${software}'.split('_', 2).pop()
    [Return]  ${version_number}


Set SCF system modules count and verify product numbers
    [Documentation]
    ...  Keyword for checking system modules amount and validating its runtime product numbers against these in SCF
    ...
    ...  | **Author:** jaroslaw.piszczala@nokia.com
    ...  | **Maintainer:** jaroslaw.piszczala@nokia.com
    ...  | **Released with version:** ---
    ${scf_xml}    XML.Parse Xml    ${BTS_scf_initial}
    ${scf_smods}    XML.Get Elements    ${scf_xml}    .//managedObject[@class="com.nokia.srbts.eqm:SMOD"]
    ${SCF_COUNT_sMOD}    Get Length    ${scf_smods}
    Set test variable  ${SCF_COUNT_SMOD}
    Set test variable  ${scf_smods}
    ${check_status}  ${RUNTIME_MODS}  ${ALL_MODS}=  Get objects with expected states  ${SMOD_expected_states}  SMOD
    Run keyword if  '${check_status}'=='PASS'
    ...  Validate Runtime Modules Product Numbers Against scf  ${RUNTIME_MODS}  ${scf_smods}

Set SCF radio modules count and verify product numbers
    [Documentation]
    ...  Keyword for checking radio modules amount and validating its runtime product numbers against these in SCF
    ...
    ...  | **Author:** jaroslaw.piszczala@nokia.com
    ...  | **Maintainer:** jaroslaw.piszczala@nokia.com
    ...  | **Released with version:** ---
    ${scf_xml}    XML.Parse Xml    ${BTS_scf_initial}
    ${scf_rmods}    XML.Get Elements    ${scf_xml}    .//managedObject[@class="com.nokia.srbts.eqm:RMOD"]
    ${SCF_COUNT_RMOD}    Get Length    ${scf_rmods}
    Set test variable  ${SCF_COUNT_RMOD}
    Set test variable  ${scf_rmods}
    ${check_status}  ${RUNTIME_MODS}  ${ALL_MODS}=  Get objects with expected states  ${RMOD_expected_states}  RMOD
    Run keyword if  '${check_status}'=='PASS'
    ...  Validate Runtime Modules Product Numbers Against scf  ${RUNTIME_MODS}  ${scf_rmods}

Set SCF ald modules count and verify product numbers
    [Documentation]
    ...  Keyword for checking ALD modules amount and validating its runtime product numbers against these in SCF
    ...
    ...  | **Author:** patryk.furman@nokia.com
    ...  | **Maintainer:** patryk.furman@nokia.com
    ...  | **Released with version:** 50.3

    ${scf_alds}=  hran_file_operations.Get ALDs
    ${SCF_COUNT_ALD}=  Get length  ${scf_alds}
    Set test variable  ${SCF_COUNT_ALD}

    ${check_status}  ${RUNTIME_MODS}  ${ALL_MODS}=  Get objects with expected states  ${ALD_expected_states}  ALD
    Run keyword if  '${check_status}'=='PASS'
    ...  Validate Runtime Modules Product Numbers Against scf  ${RUNTIME_MODS}  ${scf_alds}

Check SCF count
    [Documentation]
    ...
    ...  | Parameter       | Mandatory | Description                    |
    ...  | class_name      | Yes       | [LTE, WCDMA, GSM, SMOD, RMOD]  |
    ...  | runtime_objects | Yes       | List of runtime objects        |
    ...
    ...  *AUTHOR*
    ...  jaroslaw.piszczala@nokia.com
    [Arguments]  ${class_name}  ${runtime_objects}
    Run keyword if  ${SCF_COUNT_${class_name}}==0  Run keywords
    ...  Log  ${class_name} not found in SCF  console=${True}
    ...  AND  Return from keyword  ${True}

    Run keyword if  ${SCF_COUNT_${class_name}}==-1  Run keywords
    ...  Log  ${class_name} will be ignored for active software  console=${True}
    ...  AND  Return from keyword  ${True}

    ${final_status}=  Evaluate  ${SCF_COUNT_${class_name}}==len(${runtime_objects})
    [Return]  ${final_status}

Validate Runtime Modules Product Numbers Against scf
    [Documentation]
    ...
    ...
    ...
    ...  *AUTHOR*
    ...  jaroslaw.piszczala@nokia.com
    [Arguments]  ${runtime modules}  ${scf modules}

    ${runtime mods mapping}=  _Extract Modules Product Codes  ${runtime modules}  productCode  id
    ${scf mods mapping}=  Create Dictionary

    FOR  ${mod}  IN  @{scf modules}
        ${product code}  XML.Get Element Text    ${mod}    ./p[@name="prodCodePlanned"]
        ${dist name}   XML.Get Element Attribute    ${mod}    distName
        Set To Dictionary  ${scf mods mapping}  ${dist name}  ${product code}
    END
    ${runtime mods product codes}=  Get Dictionary Values  ${runtime mods mapping}
    ${scf mods product codes}=  Get Dictionary Values  ${scf mods mapping}
    Sort List  ${runtime mods product codes}
    Sort List  ${scf mods product codes}

    ${status}=  Run keyword and return status
    ...    Lists Should Be Equal  ${runtime mods product codes}  ${scf mods product codes}
    Run keyword unless  ${status}
    ...   Log  Modules product codes differs between runtime(${runtime mods mapping}) and scf(${scf mods mapping})
    ...   console=${True}
    [Return]  ${status}

_Extract Modules Product Codes
    [Arguments]  ${modules_obj_list}  ${product code key}  ${dist name key}

    ${mods mapping} =  Create Dictionary

    FOR  ${mod}  IN  @{modules_obj_list}
        ${raw product code}  Get From Dictionary  ${mod}  ${product code key}
        ${stripped product code}=  Strip String  ${raw product code}
        @{product code}=  Split String  ${stripped product code}  .
        ${stripped product code}=  Get From List  ${product code}  0
        ${dist name}=  Get From Dictionary  ${mod}  ${dist name key}
        Set To Dictionary  ${mods mapping}  ${dist name}  ${stripped product code}
    END
    [Return]  ${mods mapping}

Execute Remote VM Command
    [Arguments]  ${command}
    SSHLibrary.Open Connection  host=${SLAVE['SLAVE_PC_IP_ADDRESS']}  port=${SLAVE['SLAVE_PC_SSH_PORT']}
    _SSHLibrary_Login_multiway  ${SLAVE['SLAVE_PC_SSH_USERNAME']}  ${SLAVE['SLAVE_PC_SSH_PASSWORD']}
    ${command_output}=  SSHLibrary.Execute Command  ${command}
    SSHLibrary.Close Connection
    [Return]  ${command_output}

There should be at least ${this much} MB of disk space available in ${directory}
    [Documentation]
    ...  Checks if there is a minimal required available disk space in given directory, sets test as norun if not
    ...  and skips to test teardown. Also dumps `df` output as log from test for future reference.
    ...
    ...  *AUTHOR*  dariusz.suszczewicz@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter        | Mandatory | Description                                   |
    ...  | this much        | Yes       | Minimum expected free space in MB             |
    ...  | directory        | Yes       | Directory (or file) path to verify            |
    ...
    ...  *RETURN*  None

    Run  echo "[$(date -u)] - ${TEST NAME} \n $(df -h) \n" >> ${DF LOG PATH}
    ${exists}  ${message}=  Run Keyword And Ignore Error  Should Exist  ${directory}
    Run Keyword If  "${exists}" == "FAIL"  Run Keywords  Log  ${message}  level=WARN  AND  Return From Keyword
    ${available space}=  Run  df -BM --output=avail ${directory} | sed 1d | sed -e 's/M//'
    Run Keyword If  ${available space} < ${this much}
    ...    Fail    ${available space}MB available in ${directory} is less than required ${this much}MB

Check if remote host directory has enough space
    [Documentation]
    ...  Copy of KW 'There should be at least ${this much} MB of disk space available in ${directory}' adapted to run on
    ...  remote machine via SSH protocol.
    ...
    ...  *AUTHOR*  patryk.furman@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter     | Mandatory | Description                         |
    ...  | space_amount  | Yes       | Minimum expected free space in MB   |
    ...  | dir_path      | Yes       | Directory (or file) path to verify  |
    ...  | host_ip       | Yes       | IP address of host machine          |
    ...  | ssh_port      | Yes       | Port for SSH connection             |
    ...  | ssh_username  | Yes       | Username for log in to host via SSH |
    ...  | ssh_password  | Yes       | Password for log in to host via SSH |

    [Arguments]  ${dir_path}  ${space_amount}  ${host_ip}  ${ssh_port}  ${ssh_username}  ${ssh_password}
    SSHLibrary.Open Connection  host=${host_ip}  port=${ssh_port}
    _SSHLibrary_Login_multiway  ${ssh_username}  ${ssh_password}
    SSHLibrary.Execute Command  echo "[$(date -u)] - ${TEST NAME} \n $(df -h) \n" >> ${DF LOG PATH}
    ...   return_stdout=False  return_rc=True
    ${exists}  ${message}=  Run Keyword And Ignore Error  SSHLibrary.Directory Should Exist  ${dir_path}
    Run Keyword If  "${exists}" == "FAIL"  Run Keywords  Log  ${message}  level=WARN  AND  Return From Keyword
    ${available space}=  SSHLibrary.Execute Command  df -BM --output=avail ${dir_path} | sed 1d | sed -e 's/M//'
    Run Keyword If  ${available space} < ${space_amount}
    ...    Fail     ${available space}MB available in ${dir_path} is less than required ${space_amount}MB
    [Teardown]  SSHLibrary.Close Connection

Get commissioning path
    [Documentation]
    ...
    ...  Find commissioning in testline configuration directory which match given sw_version
    ...  You can set your own COMMISSIONING_PATH to ommit searching commissioning in config directory
    ...  You can set your own SCF_ID to find scf for technology with exact scf_id value
    ...
    ...  *Example*
    ...  For sw_version=WN18_FL18_GF18_SBTS18SP_ENB_1000_000609_000000 KW will try to find
    ...  SCF_01_SBTS18SP or SCF_01_SBTS18 or SCF_01_TRUNK
    ...
    ...  For sw_version=WN18_FL18_GF18_SBTS17A_ENB_1000_000609_000000 and SCF_ID=02 KW will try to find
    ...  SCF_02_SBTS18SP or SCF_02_SBTS18 or SCF_02_TRUNK
    ...
    ...  *Author*  jaroslaw.piszczala@nokia.com
    ...
    [Arguments]  ${sw_version}

    ${regex}=  Set variable
    ...   (?i)(wn\\d+_fl\\d+_gf\\d+_)?(?P<product>(SBTS|FL|WN|WBTS|FDSW|TL)[0-9]*)(?P<postfix>[a-zA-Z0-9\.]*)
    ${result}=  Get Regexp Matches  ${sw_version}  ${regex}  product  postfix
    ${PRODUCT}  ${POSTFIX}=  Set variable  ${result[0]}
    ${PRODUCT}=  Convert To Uppercase  ${PRODUCT}
    ${POSTFIX}=  Convert To Uppercase  ${POSTFIX}
    Set test variable  ${SW_TYPE}  ${PRODUCT}${POSTFIX}

    ${scf_id}=  Get Variable Value  ${SCF_ID}  01

    ${product_list}=  Create list  ${PRODUCT}${POSTFIX}  ${PRODUCT}  TRUNK
    FOR  ${product}  IN  @{product_list}
        ${filename}=  Set variable  SCF_${scf_id}_${product}
        Log to console     Trying to find scf for ${product} (${filename})
        ${commissioning}=  Find commissioning with filename  ${filename}
        ${is_not_empty}=   Run keyword and return status  Should Not Be Empty  ${commissioning}
        Run keyword if  ${is_not_empty}  Return from keyword  ${commissioning}
    END
    [Return]  ${None}

Find commissioning with filename
    [Documentation]
    ...
    ...  Find commissioning in testline configuration directory
    ...  HW_LOCATION_CODE and TESTLINE_NAME will be provided by hran_frame_sbts
    ...
    ...  *Author*  jaroslaw.piszczala@nokia.com
    ...
    [Arguments]  ${filename}  ${root}=/home/ute/btsauto/hran_ta/config  ${scf_dir}=commissioning
    ${path}=  Set variable  ${root}/${HW_LOCATION_CODE}/${TESTLINE_NAME}/${scf_dir}/${filename}.xml
    ${is_existing}=  Run keyword and return status  Should Exist  ${path}
    Return from keyword if  ${is_existing}  ${path}
    [Return]  ${None}

Get SCF IoT cells count
    [Documentation]
    ...  Return the number of IoT cells for LTE technology
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    [Arguments]  ${lte_scf}  ${alias}=default
    hran_file_operations.Setup Scfc Parser  scfc=${lte_scf}  parser_technology=UNIVERSAL  alias=${alias}
    ${scf_IoT_cells_count}=  hran_file_operations.Get Iot Cells Count  alias=${alias}
    hran_file_operations.Teardown Scfc Parser  alias=${alias}
    [Return]  ${scf_IoT_cells_count}

Set Service Access Configuration BTS
    [Documentation]
    ...  Set Service Access Configuration feature for BTS: accepted values False or True
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    [Arguments]  ${value}=False  ${alias}=Master  ${techno}=SOAM
    ${alias_connection}=  Convert to Uppercase  ${alias}
    ${FEATCADM_object_found}=  Check Infomodel Object  dist_name=//FEATCADM_CONF_M-1  alias=${alias}
    Run Keyword Unless  ${FEATCADM_object_found}  Run Keywords
    ...  Log  Feature BTS LINUX System account permissions is not available on running SW!  console=True
    ...  AND  Return From Keyword
    ${BTS_eq}=  Run Keyword If  '${techno}' == 'SOAM'  coam.Get Parameters For All  BTS  alias=${alias}
    ${SCF_dn}=  Run Keyword If  '${techno}' == 'SOAM'  Set Variable  MRBTS-${BTS_eq[0].btsId}/MNL-1/MNLENT-1/FEATCADM-1
    ${IM_dn}=  Set Variable If  '${${alias_connection}\['${alias_connection}_MODULE_TYPE']}'!='ASIA'  //FEATCADM_CONF_M-1
    ...    //RUNTIME_VIEW-${${alias_connection}\['${alias_connection}_SUBRACK']}//FEATCADM_CONF_M-1
    ${Feature_status}=  Query infomodel  query=get object ${IM_dn}  alias=${alias}
    ${systemAcctPermEnable_found}=  Run Keyword And Return Status
    ...    Variable Should Exist  ${Feature_status.systemAcctPermEnable}
    Run Keyword If  ${systemAcctPermEnable_found} and '${techno}' == 'Legacy'
    ...  Run Keyword If  '${Feature_status.systemAcctPermEnable}'!='${value}'  Run Keywords
    ...  Log Long String  ${alias} BTS system account permissions enable: ${Feature_status.systemAcctPermEnable},
    ...    need commissioning to ${value}!
    ...    console=True
    ...  AND  Perform Parameter Commissioning  parameter=systemAcctPermEnable:${value.lower()}  alias=${alias}
    ...  AND  Log  ${alias} BTS system account permissions enable: ${value}, successfully commissioned!  console=True
    Run Keyword If  ${systemAcctPermEnable_found} and '${techno}' == 'SOAM'
    ...  Run Keyword If  '${Feature_status.systemAcctPermEnable}'!='${value}'  Run Keywords
    ...  Log Long String    ${alias} BTS system account permissions enable: ${Feature_status.systemAcctPermEnable},
    ...    need commissioning to ${value}!
    ...    console=True
    ...  AND  coam.Perform Parameter Recommissioning  dist_name=${SCF_dn}  parameter=systemAcctPermEnable  operation=update
    ...    value=${value.lower()}  skip_parameter_relation_errors=True  should_activate=True  alias=${alias}
    ...  AND  Log  ${alias} BTS system account permissions enable: ${value}, successfully commissioned!  console=True
    Run Keyword If  ${systemAcctPermEnable_found}  Run Keyword If  '${Feature_status.systemAcctPermEnable}'=='${value}'
    ...  Log Long String     ${alias} BTS system account permissions enable: ${Feature_status.systemAcctPermEnable},
    ...    commissioning not needed!
    ...    console=True
    Run Keyword Unless  ${systemAcctPermEnable_found}
    ...  Log  Feature BTS LINUX System account permissions is not available on running SW!  console=True

Find path to SW package
    ${Target SW path}  Get SW file for SWDL  ${Target SW dir}  ${Target SW name}
    Run Keyword If  '${Target SW path}'== ${None}   Fail   msg=
    Set test variable  ${Target SW path}
    Log  Chosen software package is: ${Target SW path}  console=${True}

Install IPSec certificates
    [Documentation]
    ...  KW for IPSec certificates installation. In default certificates should be stored under
    ...  /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/certificates
    ...  For now only .p12 and .pem files extensions are supported
    ...
    ...  *AUTHOR*
    ...  patryk.furman@nokia.com
    ...
    ...  | Parameter | Mandatory | Description |
    ...  | cert_path | No        | BTS IP      |

    [Arguments]  ${cert_path}=/home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/certificates
    Log  Install IPSec certificates from ${cert_path}     console=${TRUE}
    @{p12_files}=  OperatingSystem.List files in directory  ${cert_path}  pattern=*.p12  absolute=${TRUE}
    FOR  ${p12_cert}  IN  @{p12_files}
        Install certificate  ${p12_cert}  BtsTrustChain  P12  Cwirhau
        Log  Certificate ${p12_cert} installed  console=${TRUE}
    END
    @{pem_files}=  OperatingSystem.List files in directory  ${cert_path}  pattern=*.pem  absolute=${TRUE}
    FOR  ${pem_cert}  IN  @{pem_files}
        Install certificate  ${pem_cert}  AdditionalCa  PEM  Cwirhau
        Log  Certificate ${pem_cert} installed  console=${TRUE}
    END

Copy File to Remote Host via SSH
    [Documentation]
    ...  KW for copying files from a machine to another
    ...  can be any host, VM , system module, RFM.
    ...
    ...  *AUTHOR*
    ...  emanuel.szijj@nokia.com
    [Arguments]  ${ip}=${SLAVE['SLAVE_PC_IP_ADDRESS']}  ${user}=ute  ${pass}=ute  ${local_file_path}=/tmp/FileDirectory.xml
    ...  ${remote_file_path}=/tmp/FileDirectory.xml
    SSHLibrary.Open Connection  ${ip}
    _SSHLibrary_Login_multiway  ${user}  ${pass}
    SSHLibrary.Put File  ${local_file_path}  ${remote_file_path}
    SSHLibrary.Close Connection

__Set order for IM_Library
    [Documentation]
    ...  KW for Setting further library
    ...  DRY RUN does not run on this KW
    ...
    ...  *AUTHOR*
    ...  emanuel.szijj@nokia.com
    [Tags]  robot:no-dry-run
    Set Library search order  ute_admin_infomodel  XML

Get BCF IPs from SCF
    [Documentation]
    ...  Gather BCF IPs from downloaded SCF
    ...
    ...  | **Author:** michal.kwasniewicz@nokia.com
	...  | **Maintainer:** michal.kwasniewicz@nokia.com
	...  | **Released with version:** 49.3
	...
	...  | **Full description:**
	...  | KW for obtaining all IPs connected to GSM RAT from SCF. It returns list of all IPs connected to distName from
    ...  | under 'mPlaneLocalIpAddressDN'. SCF file is downloaded inside this KW.

    coam.Collect Scf  ${Test Files}/SCF_for_BCF_IPs_check.xml
    ${scf_xml}=  Parse xml  ${Test Files}/SCF_for_BCF_IPs_check.xml
    ${bcf_mplane_dist_name}=  Get element text  ${scf_xml}  .//*[@name='mPlaneLocalIpAddressDN']
    ${common_dist}=  Fetch from left  ${bcf_mplane_dist_name}  IPADDRESSV4
    ${bcf_ips}=  Get elements texts  ${scf_xml}  .//*[contains(@distName, "${common_dist}")]/*[@name='localIpAddr']
    [Return]  ${bcf_ips}

Get SCF count of RMODs
    [Documentation]
    ...  Counts number of Radio Modules in SCFC and saves this value to test variable 'SCF_COUNT_RMOD'
    ...
    ...  *AUTHOR*
    ...  sebastian.burniak@nokia.com
    ...
    ...  | Parameter    | Man. | Description                                        |
	...
	...  *RETURN*
    ...  None
    ${scf_RMODS}=  hran_file_operations.Get Radios
    ${scf_rmods_count}=  Get length  ${scf_RMODS}
    Set test variable  ${SCF_COUNT_RMOD}    ${scf_rmods_count}

Set Ethernet Port Security
    [Documentation]
    ...  Set Ethernet port security. Accepted values: False (status: Disabled) or True (status: Enabled)
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Description                                                       |
    ...  | value     | No   | Value for Ethernet port security: False or True, by default False |
    ...  | alias     | No   | ADMIN/BTSSM instancename, by default default                      |
    ...  | BTS       | No   | BTS object, by default SBTS (SyVe)                                |
    ...
    [Arguments]  ${value}=False  ${alias}=default  ${BTS}=SBTS

    Set Test Variable  ${value}  ${value.lower()}
    Run Keyword If  '${value}' != 'false' and '${value}' != 'true'
    ...  Fail  No valid value for Ethernet port security set (False or True)!  level=ERROR
    ${BTS_scf}=  Admin Collect scf.xml with timestamp  alias=${alias}
    ${BTS_scf_xml}=  XML.Parse xml  ${BTS_scf}
    ${ethernetPortSecurity_exist}=  Run Keyword And Return Status  XML.Element Should Exist  ${BTS_scf_xml}
    ...  .//managedObject[@class="com.nokia.srbts.mnl:SECADM"]/p[@name="ethernetPortSecurityEnabled"]
    Run Keyword Unless  ${ethernetPortSecurity_exist}  Run Keywords
    ...  Log  Feature Ethernet Port Security is not available on running SW!  console=True
    ...  AND  Return From Keyword
    ${ethernetPortSecurity_value}=  XML.Get Element Text  ${BTS_scf_xml}
    ...  .//managedObject[@class="com.nokia.srbts.mnl:SECADM"]/p[@name="ethernetPortSecurityEnabled"]
    ${ethernetPortSecurity_status}=  Set Variable If  '${ethernetPortSecurity_value}' == 'false'  Disabled  Enabled
    ${MO_items}=  XML.Get Element Attributes  ${BTS_scf_xml}  .//*managedObject[@class="com.nokia.srbts.mnl:SECADM"]
    ${SCF_dn}=  Set Variable  ${MO_items['distName']}
    Run Keyword If  '${ethernetPortSecurity_value}'!='${value}'  Run Keywords
    ...  Log  ${alias} ${BTS} Ethernet port security status: ${ethernetPortSecurity_status}, need commissioning!
    ...    console=True
    ...  AND  coam.Perform Parameter Recommissioning  dist_name=${SCF_dn}  parameter=ethernetPortSecurityEnabled  operation=update
    ...  value=${value.lower()}  skip_parameter_relation_errors=True  should_activate=True  alias=${alias}
    ...  AND  Log  Parameter ethernetPortSecurityEnabled=${value} successfully commissioned!  console=True
    ...  ELSE  Log  ${alias} ${BTS} Ethernet port security status: ${ethernetPortSecurity_status}, commissioning not needed!
    ...    console=True
    [Teardown]  OperatingSystem.Remove File  ${BTS_scf}

Set Ethernet Port Security TAF
    [Documentation]
    ...  Set Ethernet port security. Accepted values: False (status: Disabled) or True (status: Enabled)
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Description                                                       |
    ...  | value     | No   | Value for Ethernet port security: False or True, by default False |
    ...  | alias     | No   | ADMIN/BTSSM instancename, by default default                      |
    ...  | BTS       | No   | BTS object, by default SBTS (SyVe)                                |
    ...
    [Arguments]  ${value}=False  ${alias}=default  ${BTS}=SBTS

    Set Test Variable  ${value}  ${value.lower()}
    Run Keyword If  '${value}' != 'false' and '${value}' != 'true'
    ...  Fail  No valid value for Ethernet port security set (False or True)!  level=ERROR
    ${BTS_scf}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${BTS_scf_xml}=  Parse xml  ${BTS_scf}
    ${ethernetPortSecurity_exist}=  Run Keyword And Return Status  Element Should Exist  ${BTS_scf_xml}
    ...  .//managedObject[@class="com.nokia.srbts.mnl:SECADM"]/p[@name="ethernetPortSecurityEnabled"]
    Run Keyword Unless  ${ethernetPortSecurity_exist}  Run Keywords
    ...  Log  Feature Ethernet Port Security is not available on running SW!  console=True
    ...  AND  Return From Keyword
    ${ethernetPortSecurity_value}=  Get Element Text  ${BTS_scf_xml}
    ...  .//managedObject[@class="com.nokia.srbts.mnl:SECADM"]/p[@name="ethernetPortSecurityEnabled"]
    ${ethernetPortSecurity_status}=  Set Variable If  '${ethernetPortSecurity_value}' == 'false'  Disabled  Enabled
    ${MO_items}=  Get Element Attributes  ${BTS_scf_xml}  .//*managedObject[@class="com.nokia.srbts.mnl:SECADM"]
    ${SCF_dn}=  Set Variable  ${MO_items['distName']}
    Run Keyword If  '${ethernetPortSecurity_value}'!='${value}'  Run Keywords
    ...  Log  ${alias} ${BTS} Ethernet port security status: ${ethernetPortSecurity_status}, need commissioning!
    ...    console=True
    ...  AND  coam.Perform Parameter Recommissioning  dist_name=${SCF_dn}  parameter=ethernetPortSecurityEnabled  operation=update
    ...  value=${value.lower()}  skip_parameter_relation_errors=True  should_activate=True  alias=${alias}
    ...  AND  Log  Parameter ethernetPortSecurityEnabled=${value} successfully commissioned!  console=True
    ...  ELSE  Log  ${alias} ${BTS} Ethernet port security status: ${ethernetPortSecurity_status}, commissioning not needed!
    ...    console=True
    [Teardown]  OperatingSystem.Remove File  ${BTS_scf}

Get KPI related test line variables
    [Documentation]
    ...  Get Testline variables for KPI purpose
    ...
    ...  | **Author:** jaroslaw.piszczala@nokia.com
    ...  | **Maintainer:** mnich@nokia.com
    ...  | **Released with version:** 60.0
    ...
    Set test variable     ${KPI_TEST_LINE_VARIABLES}  ${False}
    ${tl_configuration}=  Get Test Line Parameter Value  CONFIGURATION
    ${tl_sync}=           Get Test Line Parameter Value  HW_ID
    ${tl_platform}=       Get Test Line Parameter Value  PLATFORM

    Run keyword if  "${False}" in ["${tl_configuration}", "${tl_sync}", "${tl_platform}"]
    ...  Run keywords
    ...  Log  There are missing variables in test line configuration, KPIs will not be registered in database
    ...    console=${True}
    ...  AND  Log  CONFIGURATION=${tl_configuration}, SYNC=${tl_sync}, PLATFORM=${tl_platform}  console=${True}
    ...  ELSE
    ...  Set test variable  ${KPI_TEST_LINE_VARIABLES}  ${True}
    [Return]  ${KPI_TEST_LINE_VARIABLES}  ${tl_configuration}  ${tl_sync}  ${tl_platform}

Get PDU Optical Interface Info
    [Documentation]
    ...  Helper KW providing PDU item based on devices connected on its ports
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Description                |
    ...  | port_1    | Yes  | Device connected on port 1 |
    ...  | port_2    | Yes  | Device connected on port 2 |
	...
	...  *RETURN*
    ...  | PDU_item  | PDU item |
    [Arguments]  ${port_1}  ${port_2}
    ${keys}=  Get Dictionary Keys  ${INTERFACES}
    ${values}=  Get Dictionary Values  ${INTERFACES}
    FOR  ${PDU_item}  ${PDU_info}  IN ZIP  ${keys}  ${values}
        ${var1}=  Run Keyword And Return Status  Variable Should Exist  ${PDU_info['PORT_1']}
        ${var2}=  Run Keyword And Return Status  Variable Should Exist  ${PDU_info['PORT_2']}
        Run Keyword If  ${var1} and ${var2}
        ...  Run Keyword If  '${port_1}' in '${PDU_info['PORT_1']}' and '${port_2}' in '${PDU_info['PORT_2']}'
        ...  Return From Keyword  ${PDU_item}
    END
    ${PDU_item}=  Set Variable  None
    [Return]  ${PDU_item}

Get PDU Optical Interface Info List
    [Documentation]
    ...  Helper KW providing list of PDU items based on devices connected on its ports
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  | Parameter | Man. | Description                |
    ...  | port_1    | Yes  | Device connected on port 1 |
    ...  | port_2    | Yes  | Device connected on port 2 |
    ...
    ...  *RETURN*
    ...  | PDU_items  | PDU items |
    [Arguments]  ${port_1}  ${port_2}
    ${keys}=  Get Dictionary Keys  ${INTERFACES}
    ${values}=  Get Dictionary Values  ${INTERFACES}
    ${PDU_items}=  Create List  @{EMPTY}
    FOR  ${PDU_item}  ${PDU_info}  IN ZIP  ${keys}  ${values}
        ${var1}=  Run Keyword And Return Status  Variable Should Exist  ${PDU_info['PORT_1']}
        ${var2}=  Run Keyword And Return Status  Variable Should Exist  ${PDU_info['PORT_2']}
        Run Keyword If  ${var1} and ${var2}
        ...  Run Keyword If  '${port_1}' in '${PDU_info['PORT_1']}' and '${port_2}' in '${PDU_info['PORT_2']}'
        ...  Append to List  ${PDU_items}  ${PDU_item}
    END
    [Return]  ${PDU_items}

Get Cell Measurements Dict
    [Documentation]
    ...  Wrapper keyword to hran_files_operations Get Cell Measurements
    ...  At each keyword call last line parsed is updated so that at next
    ...    call the parsing is performed starting from that line
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter   | Mandatory | Description                                   |
    ...  | path        | Yes       | Full local path to UDP Log to be parsed       |
    ...  | alias       | Yes       | admin instance alias                          |
    ...  | tech        | No        | Technology, Default value: LTE_ASIA           |
    ...
    ...  *RETURN VALUE*
    ...  | cells_power_dict | Dictionary containing Cellids as keys and Rx measurments as values  |
    [Arguments]  ${path}  ${alias}  ${tech}=LTE_ASIA
    [Timeout]  15 min
    ${parsed_before}=  Run Keyword And Return Status  Variable Should Exist  ${${alias}_parsed_until_line}
    ${first_line_int}=  Convert To Integer  0
    Run Keyword Unless  ${parsed_before}  Set Test Variable  ${${alias}_parsed_until_line}  ${first_line_int}
    ${cells_power_dict}  ${parsed_line}=  Get Cell Measurements  syslog_file_path=${path}  tech=${tech}
    ...  start_with_line=${${alias}_parsed_until_line}
    Set Test Variable   ${${alias}_parsed_until_line}  ${parsed_line}
    [Return]  ${cells_power_dict}

Check fault from SysLog file
    [Documentation]
    ...  Check if specified LTE or WCDMA Fault was detected
    ...  Can be applied for other technologies too
    ...  as long as syslog trace and fault pattern
    ...  are known
    ...
    ...  *AUTHOR*
    ...  valentin.marian@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter     | Mandatory | Description                              |
    ...  | dirpath       | No        | SYSLOG path                              |
    ...  | files_regex   | No        | Regex for SYSLOG files                   |
    ...  | fault_pattern | Yes       | Text that will be searched in Syslog     |
    ...
    ...  *RETURN VALUE*
    ...  | fault_found | Return true if fault found, otherwise false |

    [Timeout]  15 min
    [Arguments]  ${dirpath}=${Temp Logs Dir}  ${files_regex}=SlaveUDP
    ...  ${fault_number}=1932
    ${fault_found}=  Set Variable  ${False}
    Get file from another virtual machine  source_path=${Temp Logs Dir}/SlaveUDP
    ...  destination_path=${Temp Logs Dir}/SlaveUDP  ip=${SLAVE['SLAVE_PC_IP_ADDRESS']}
    ...  username=${SLAVE['SLAVE_PC_SSH_USERNAME']}  password=${SLAVE['SLAVE_PC_SSH_PASSWORD']}
    @{syslog_dir_path}=  OperatingSystem.List Files In Directory  ${dirpath}  ${files_regex}  True
    FOR  ${syslog_file}  IN  @{syslog_dir_path}
         ${content}=  OperatingSystem.Grep File  ${syslog_file}  [Detector ${fault_number} \* active
         ...  encoding_errors=ignore
         ${fault_found}=  Set Variable If  """${content}"""!=""""""  ${True}  ${False}
         Exit For Loop If  ${fault_found}
    END
    [Return]  ${fault_found}

Get Activate Temporary Radio Master Role From Slave BTS
    [Documentation]
    ...  Get Activate Temporary Radio Master Role value on slave BTS. Possible outputs: true, false or None
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Description                            |
    ...  | BTS_scf   | No   | BTS SCF file full path                 |
    ...  | alias     | No   | admin instance alias, by default Slave |
    ...
    ...  *RETURN VALUE*
    ...  | BTS_actTempRadioMaster         | true, false or None |

    [Arguments]  ${BTS_scf}=${EMPTY}  ${alias}=Slave
    ${BTS_scf}=  Run Keyword If  '${BTS_scf}'==''  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ...  ELSE  Set Variable  ${BTS_scf}
    ${BTS_scf_xml}=  Parse xml  ${BTS_scf}
    ${actTempRadioMaster_exists}=  Run Keyword And Return Status
    ...  Element Should Exist  ${BTS_scf_xml}
    ...    .//managedObject[@class="com.nokia.srbts.mnl:FEATCADM"]/p[@name="actTempRadioMaster"]
    Return From Keyword If  not ${actTempRadioMaster_exists}  ${None}
    ${BTS_actTempRadioMaster}=  Get Element Text  ${BTS_scf_xml}
    ...  .//managedObject[@class="com.nokia.srbts.mnl:FEATCADM"]/p[@name="actTempRadioMaster"]
    [Return]  ${BTS_actTempRadioMaster}

Check BTS Configuration SBTS
    [Documentation]
    ...  Helper keyword checking if number of configured cells and radio modules in SCF are properly mapped on
    ...  WebEM running view.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Mandatory | Description            |
    ...  | scf_file  | Yes       | BTS SCF file full path |
    ...  | alias     | Yes       | Admin instance         |
    ...
    ...  *RETURN*
    ...  | Parameter | Description   |
    ...  | BTSConf   | True or False |

    [Arguments]  ${alias}  ${scf_file}=${EMPTY}

    ${NR_runtime_cell_number}  ${LTE_runtime_cell_number}  ${LTE_IOT_runtime_cell_number}  ${WCDMA_runtime_cell_number}
    ...    ${GSM_runtime_cell_number}  ${BTS_runtime_rmod_number}
    ...    Get Admin Cells And RMs Number From SBTS  ${alias}  ${single_bts}
    ${NR_scf_cell_number}  ${LTE_scf_cell_number}  ${LTE_IOT_scf_cell_number}  ${WCDMA_scf_cell_number}
    ...    ${GSM_scf_cell_number}  ${BTS_scf_rmod_number}    Get SCF Cells And RMs Number From SBTS  ${scf_file}

    ${NR_cell_conf}=  Run Keyword And Return Status   Should be equal  ${NR_runtime_cell_number}  ${NR_scf_cell_number}
    ${LTE_cell_conf}=  Run Keyword And Return Status   Should be equal  ${LTE_runtime_cell_number}  ${LTE_scf_cell_number}
    ${LTE_IOT_cell_conf}=  Run Keyword And Return Status
    ...    Should be equal  ${LTE_IOT_runtime_cell_number}  ${LTE_IOT_scf_cell_number}
    ${WCDMA_cell_conf}=  Run Keyword And Return Status
    ...    Should be equal  ${WCDMA_runtime_cell_number}  ${WCDMA_scf_cell_number}
    ${GSM_cell_conf}=  Run Keyword And Return Status   Should be equal  ${GSM_runtime_cell_number}  ${GSM_scf_cell_number}
    ${BTS_rmod_conf}=  Run Keyword And Return Status   Should be equal  ${BTS_runtime_rmod_number}  ${BTS_scf_rmod_number}
    ${BTSConf}=  Set Variable If
    ...    ${LTE_cell_conf} and ${LTE_IOT_cell_conf} and ${WCDMA_cell_conf} and ${GSM_cell_conf} and ${BTS_rmod_conf}
    ...    ${TRUE}  ${FALSE}

    Log    ${alias} BTS configuration-NR configured/running cells number: ${NR_scf_cell_number}/${NR_runtime_cell_number}
    ...    console=True
    Log    ${alias} BTS configuration-LTE configured/running cells number: ${LTE_scf_cell_number}/${LTE_runtime_cell_number}
    ...    console=True
    Log    ${alias} BTS configuration-LTE IOT configured/running cells number:      console=True
    Log    ${LTE_IOT_scf_cell_number}/${LTE_IOT_runtime_cell_number}    console=True
    Log    ${alias} BTS configuration-WCDMA configured/running cells number:     console=True
    Log    ${WCDMA_scf_cell_number}/${WCDMA_runtime_cell_number}     console=True
    Log    ${alias} BTS configuration-GSM configured/running cells number: ${GSM_scf_cell_number}/${GSM_runtime_cell_number}
    ...    console=True
    Log    ${alias} BTS configuration-BTS configured/running radio modules number:     console=True
    Log    ${BTS_scf_rmod_number}/${BTS_runtime_rmod_number}    console=True

    [Return]  ${BTSConf}

Get Admin Cells And RMs Number From SBTS
    [Documentation]
    ...  Helper keyword providing number of cells and radio modules from WebEM running view.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter  | Mandatory | Description                                                          |
    ...  | alias      | Yes       | Admin instance, Master or Slave                                      |
    ...  | single_BTS | No        | Possible values: True (1 SBTS), False (2 SBTS). Default value: True  |
    ...
    ...  *RETURN*
    ...  | Parameter                   | Description                                 |
    ...  | NR_runtime_cell_number      | WebEM runtime view NR cells number          |
    ...  | LTE_runtime_cell_number     | WebEM runtime view LTE cells number         |
    ...  | LTE_IOT_runtime_cell_number | WebEM runtime view LTE IOT cells number     |
    ...  | WCDMA_runtime_cell_number   | WebEM runtime view WCDMA cells number       |
    ...  | GSM_runtime_cell_number     | WebEM runtime view GSM cells number         |
    ...  | BTS_runtime_rmod_number     | WebEM runtime view BTS radio modules number |

    [Arguments]  ${alias}  ${single_BTS}=True
    ${NR_cell_ids}=  coam.Get Ids For All  class_name=NRCEL  connection=${alias}
    Run Keyword If   '${single_BTS}' == 'True'
    ...  Set Test Variable  ${${${alias.upper()}\['${alias.upper()}_TECH']}_NR_cell_ids}  ${NR_cell_ids}
    ...  ELSE
    ...  Set Test Variable  ${${${alias.upper()}\['${alias.upper()}_TECH']}_${alias}_NR_cell_ids}  ${NR_cell_ids}
    ${NR_runtime_cell_number}=  Get Length  ${NR_cell_ids}

    ${LTE_cell_ids}  ${LTE_IOT_cell_ids}=  Admin Get LTE CELL Ids list  ${alias}
    Run Keyword If   '${single_BTS}' == 'True'  Run Keywords
    ...  Set Test Variable  ${${${alias.upper()}\['${alias.upper()}_TECH']}_LTE_cell_ids}  ${LTE_cell_ids}
    ...  AND  Set Test Variable  ${${${alias.upper()}\['${alias.upper()}_TECH']}_LTE_IOT_cell_ids}  ${LTE_IOT_cell_ids}
    ...  ELSE  Run Keywords
    ...  Set Test Variable  ${${${alias.upper()}\['${alias.upper()}_TECH']}_${alias}_LTE_cell_ids}  ${LTE_cell_ids}
    ...  AND  Set Test Variable
    ...    ${${${alias.upper()}\['${alias.upper()}_TECH']}_${alias}_LTE_IOT_cell_ids}  ${LTE_IOT_cell_ids}
    ${LTE_runtime_cell_number}=  Get Length  ${LTE_cell_ids}
    ${LTE_IOT_runtime_cell_number}=  Get Length  ${LTE_IOT_cell_ids}

    ${WCDMA_cell_ids}=  coam.Get Ids For All  class_name=WNCEL  connection=${alias}
    Run Keyword If   '${single_BTS}' == 'True'
    ...  Set Test Variable  ${${${alias.upper()}\['${alias.upper()}_TECH']}_WCDMA_cell_ids}  ${WCDMA_cell_ids}
    ...  ELSE
    ...  Set Test Variable  ${${${alias.upper()}\['${alias.upper()}_TECH']}_${alias}_WCDMA_cell_ids}  ${WCDMA_cell_ids}
    ${WCDMA_runtime_cell_number}=  Get Length  ${WCDMA_cell_ids}

    ${GSM_cell_ids}=  coam.Get Ids For All  class_name=GNCEL  connection=${alias}
    Run Keyword If   '${single_BTS}' == 'True'
    ...  Set Test Variable  ${${${alias.upper()}\['${alias.upper()}_TECH']}_GSM_cell_ids}  ${GSM_cell_ids}
    ...  ELSE
    ...  Set Test Variable  ${${${alias.upper()}\['${alias.upper()}_TECH']}_${alias}_GSM_cell_ids}  ${GSM_cell_ids}
    ${GSM_runtime_cell_number}=  Get Length  ${GSM_cell_ids}

    ${BTS_rmod_ids}=  coam.Get Ids For All  RMOD  alias=${alias}
    Run Keyword If   '${single_BTS}' == 'True'
    ...  Set Test Variable  ${${${alias.upper()}\['${alias.upper()}_TECH']}_rmod_ids}  ${BTS_rmod_ids}
    ...  ELSE
    ...  Set Test Variable  ${${${alias.upper()}\['${alias.upper()}_TECH']}_${alias}_rmod_ids}  ${BTS_rmod_ids}
    ${BTS_runtime_rmod_number}=  Get Length  ${BTS_rmod_ids}

    [Return]  ${NR_runtime_cell_number}    ${LTE_runtime_cell_number}    ${LTE_IOT_runtime_cell_number}
    ...    ${WCDMA_runtime_cell_number}    ${GSM_runtime_cell_number}    ${BTS_runtime_rmod_number}

Get SCF Cells And RMs Number From SBTS
    [Documentation]
    ...  Helper keyword providing number of cells and radio modules configured in SCF
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Mandatory | Description            |
    ...  | BTS_scf   | Yes       | BTS SCF file full path |
    ...
    ...  *RETURN*
    ...  | Parameter               | Description                             |
    ...  | NR_scf_cell_number      | SCF configured NR cells number          |
    ...  | LTE_scf_cell_number     | SCF configured LTE cells number         |
    ...  | LTE_IOT_scf_cell_number | SCF configured LTE IOT cells number     |
    ...  | WCDMA_scf_cell_number   | SCF configured WCDMA cells number       |
    ...  | GSM_scf_cell_number     | SCF configured GSM cells number         |
    ...  | BTS_scf_rmod_number     | SCF configured BTS radio modules number |

    [Arguments]  ${BTS_scf}

    hran_file_operations.Setup Scfc Parser  scfc=${BTS_scf}  parser_technology=SBTS

    ${NR_scf_cell_number}=  hran_file_operations.Get Cells Count  NR
    ${LTE_scf_cell_number}=  hran_file_operations.Get Cells Count  LTE
    ${LTE_IOT_scf_cell_number}=  hran_file_operations.Get IOT Cells Count
    ${WCDMA_scf_cell_number}=  hran_file_operations.Get Cells Count  WCDMA
    ${GSM_scf_cell_number}=  hran_file_operations.Get Cells Count  GSM
    ${BTS_scf_rmod_number}=  hran_file_operations.Get Radios Count

    hran_file_operations.Teardown Scfc Parser

    [Return]  ${NR_scf_cell_number}  ${LTE_scf_cell_number}  ${LTE_IOT_scf_cell_number}  ${WCDMA_scf_cell_number}
    ...    ${GSM_scf_cell_number}     ${BTS_scf_rmod_number}

Check ${alias} SBTS All Cells SOAM
    [Documentation]
    ...  Helper keyword checking states of all BTS cells: operationalState=Enabled
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *RETURN*
    ...  | Parameter             | Description   |
    ...  | BTS_cells_operational | True or False |
    ...
    ${LTE_cells_list}=  Set Variable If  '${single_BTS}' == 'True'
    ...    ${${${alias.upper()}\['${alias.upper()}_TECH']}_LTE_cell_ids}
    ...  ${${${alias.upper()}\['${alias.upper()}_TECH']}_${alias}_LTE_cell_ids}
    ${LTE_cells_operational}=  Run Keyword If  ${LTE_cells_list}
    ...  Run Keyword And Return Status  coam.Assert Every  LNCEL  operationalState=${Enabled_}  alias=${alias}
    ...  ELSE  Set Variable  ${TRUE}

    ${WCDMA_cells_list}=  Set Variable If  '${single_BTS}' == 'True'
    ...    ${${${alias.upper()}\['${alias.upper()}_TECH']}_WCDMA_cell_ids}
    ...    ${${${alias.upper()}\['${alias.upper()}_TECH']}_${alias}_WCDMA_cell_ids}
    ${WCDMA_cells_operational}=  Run Keyword If  ${WCDMA_cells_list}
    ...  Run Keyword And Return Status  coam.Assert Every  WNCEL  operationalState=${Enabled_}  alias=${alias}
    ...  ELSE  Set Variable  ${TRUE}

    ${GSM_cells_list}=  Set Variable If  '${single_BTS}' == 'True'
    ...    ${${${alias.upper()}\['${alias.upper()}_TECH']}_GSM_cell_ids}
    ...    ${${${alias.upper()}\['${alias.upper()}_TECH']}_${alias}_GSM_cell_ids}
    ${GSM_cells_operational}=  Run Keyword If  ${GSM_cells_list}
    ...  Run Keyword And Return Status  coam.Assert Every  GNCEL  operationalState=${Enabled_}  alias=${alias}
    ...  ELSE  Set Variable  ${TRUE}

    Run Keyword If  ${LTE_cells_list}  Run Keyword If  ${LTE_cells_operational}
    ...  Log  ${alias} BTS LTE cells: operationalState=Enabled  level=INFO  console=True
    Run Keyword If  ${LTE_cells_list}  Run Keyword Unless  ${LTE_cells_operational}
    ...  Log  At least one LTE cell is not operational!  level=INFO  console=True

    Run Keyword If  ${WCDMA_cells_list}  Run Keyword If  ${WCDMA_cells_operational}
    ...  Log  ${alias} BTS WCDMA cells: operationalState=Enabled  level=INFO  console=True
    Run Keyword If  ${WCDMA_cells_list}  Run Keyword Unless  ${WCDMA_cells_operational}
    ...  Log  At least one WCDMA cell is not operational!  level=INFO  console=True

    Run Keyword If  ${GSM_cells_list}  Run Keyword If  ${GSM_cells_operational}
    ...  Log  ${alias} BTS GSM cells: operationalState=Enabled  level=INFO  console=True
    Run Keyword If  ${GSM_cells_list}  Run Keyword Unless  ${GSM_cells_operational}
    ...  Log  At least one GSM cell is not operational!  level=INFO  console=True

    ${BTS_cells_operational}=  Set Variable If
    ...    ${LTE_cells_operational} and ${WCDMA_cells_operational} and ${GSM_cells_operational}
    ...    ${TRUE}  ${FALSE}

    [Return]  ${BTS_cells_operational}

Check ${alias} SBTS RM State SOAM
    [Documentation]
    ...  Helper keyword checking states of all BTS RMODs: operationalState=Enabled
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *RETURN*
    ...  | Parameter             | Description   |
    ...  | BTS_rmods_operational | True or False |

    ${BTS_rmods_list}=  Set Variable If  '${single_BTS}' == 'True'  ${${${alias.upper()}\['${alias.upper()}_TECH']}_rmod_ids}
    ...  ${${${alias.upper()}\['${alias.upper()}_TECH']}_${alias}_rmod_ids}
    ${BTS_rmods_operational}=  Run Keyword If  ${BTS_rmods_list}  Run Keyword And Return Status
    ...  coam.Assert Every  RMOD  operationalState=${Enabled_}  alias=${alias}

    Run Keyword If  ${BTS_rmods_list}  Run Keyword If  ${BTS_rmods_operational}
    ...  Log  ${alias} BTS radio modules: operationalState=Enabled  level=INFO  console=True
    Run Keyword If  ${BTS_rmods_list}  Run Keyword Unless  ${BTS_rmods_operational}
    ...  Log  At least one BTS radio module is not operational!  level=INFO  console=True

    [Return]  ${BTS_rmods_operational}

Count SBTS alarms number
    [Arguments]  ${RM_id}  ${SBTS_RM_CELL_list}  ${LTE_CELL_RM_list}  ${LTE_CELL_IOT_dict}  ${WCDMA_CELL_RM_list}
    ...    ${alias}=default
    FOR  ${RM_CELL_details}  IN  @{SBTS_RM_CELL_list}
        Run Keyword If  '${RM_CELL_details[0]}' == '${RM_id}'  Run Keywords
        ...  Get SBTS cells alarms number  ${RM_CELL_details[1]}  ${LTE_CELL_IOT_dict}
        ...  AND  Get LTE mimo cells alarms number  ${RM_CELL_details[0]}  ${RM_CELL_details[1]}  ${LTE_CELL_RM_list}
        ...    ${LTE_CELL_IOT_dict}    alias=${alias}
        ...  AND  Get SBTS-WCDMA mimo cells alarms number  ${RM_CELL_details[0]}  ${RM_CELL_details[1]}  ${WCDMA_CELL_RM_list}
    END

Get SBTS cells alarms number
    [Arguments]  ${RM_CELL}  ${CELL_IOT_dict}
    ${RM_cells_count_alarms}  Get Length  ${RM_CELL}
    FOR  ${CELL_globalCellId}  IN  @{RM_CELL}
        ${status}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${CELL_IOT_dict}  ${CELL_globalCellId}
        ${value}=  Run Keyword If  ${status} and ${IOT_MIMO_alarm_check}
        ...    Get From Dictionary  ${CELL_IOT_dict}  ${CELL_globalCellId}
        ...    ELSE  Set Variable  None
        ${RM_cells_count_alarms}=  Run Keyword If  '${value}' != 'None'  Evaluate  ${RM_cells_count_alarms} + 1
        ...  ELSE  Evaluate  ${RM_cells_count_alarms} + 0
    END
    Set Test Variable  ${RM_cells_count_alarms}  ${RM_cells_count_alarms}

Modify Resource Search Order
    [Arguments]    ${resource_name}
    [Documentation]  Adjust Robot's library search order for the Robot-based (as opposed to JSON-based)
    ...    test sets. The KW adds a new entry at the end of the search order list (to retain search order defined
    ...    in TC Setup). To be used in [Setup] section as follows (presented here in a convenient tabular form):
    ...
    ...    [Setup] | Run Keywords | res_name.TC Setup | AND | Modify Resource Search Order | res_name
    ...
    ...    in pair with `Restore Resource Search Order` in [Teardown]:
    ...
    ...    [Teardown] | Run Keywords | res_name.TC Teardown | AND | Restore Resource Search Order
    ...
    ...    Non-existing resurces (`dummy_resource_name`) are ignored.
    [Tags]  robot:no-dry-run
    ${dummy_search_order}=    Create List    dummy_resource_name
    ${search_order}=   Set Library Search Order
    ${ORIGINAL_SEARCH_ORDER}=    Set Variable If    len(${search_order})    ${search_order}    ${dummy_search_order}
    Set Test Variable    ${ORIGINAL_SEARCH_ORDER}
    Set Library Search Order    ${resource_name}    @{search_order}

Restore Resource Search Order
    [Documentation]    To be used in pair with `Modify Resource Search Order`
    [Tags]  robot:no-dry-run
    ${search_order}=    Create List    @{ORIGINAL_SEARCH_ORDER}
    Remove Values From List    ${search_order}    dummy_resource_name
    Set Library Search Order   @{search_order}

Get linkModeSynchronization parameter
    [Documentation]
    ...  KW used to get linkModeSynchronization parameter on NR, LTE or SBTS
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter    | Man. | Default | Description                    |
    ...  | alias_master | No   | Master  | alias of master admin instance |
    ...  | alias_slave  | No   | Slave   | alias of slave admin instance  |
    ...
    ...  *RETURN VALUE*
    ...  | Master_linkModeSync_dict | Dictionary with key Master RMOD_id and value true or false |
    ...  | Slave_linkModeSync_dict  | Dictionary with key Slave RMOD_id and value true or false  |

    [Arguments]  ${alias_master}=Master  ${alias_slave}=Slave
    ${Master_shared_RMOD_list}  ${Slave_shared_RMOD_list}  ${Master_dedicated_RMOD_list}  ${Slave_dedicated_RMOD_list}=
    ...  Admin Get Shared And Dedicated RM List for Master and Slave  Master  Slave
    ${Master_linkModeSync_dict}=  Create Dictionary
    ${Slave_linkModeSync_dict}=  Create Dictionary
    FOR  ${item1}  ${item2}  IN ZIP  ${Master_shared_RMOD_list}  ${Slave_shared_RMOD_list}
        ${Master_linkModeSync}=  Get linkModeSynchronization parameter from CABLINK info  ${item1}  ${alias_master}
        ${Slave_linkModeSync}=  Get linkModeSynchronization parameter from CABLINK info  ${item2}  ${alias_slave}
        Set To Dictionary  ${Master_linkModeSync_dict}  ${item1}  ${Master_linkModeSync}
        Set To Dictionary  ${Slave_linkModeSync_dict}  ${item2}  ${Slave_linkModeSync}
    END
    [Return]  ${Master_linkModeSync_dict}  ${Slave_linkModeSync_dict}

Get linkModeSynchronization parameter from CABLINK info
    [Arguments]  ${RMOD_id}  ${alias}
    ${CABLINK_list}=  coam.Get Parameters For All  CABLINK  alias=${alias}
    FOR  ${item}  IN  @{CABLINK_list}
        ${CABLINK_id}=  Get From Dictionary  ${item}  id
        ${CABLINK_info}=  Query Infomodel  query=get object ${CABLINK_id}  alias=${alias}
        ${firstEndpointDN_BBMOD_R}=  Run Keyword And Return Status  Should Contain  ${item.firstEndpointDN}  BBMOD_R
        ${firstEndpointDN_SMOD_R}=  Run Keyword And Return Status  Should Contain  ${item.firstEndpointDN}  SMOD_R
        Return From Keyword If
        ...    (${firstEndpointDN_BBMOD_R} or ${firstEndpointDN_SMOD_R}) and '${item.secondEndpointDN}' == '${RMOD_id}'
        ...    ${CABLINK_info.linkModeSynchronization}
    END

Log Long String
    [Arguments]  @{what_to_log}  ${level}=INFO  ${console}=True

    ${to_log}=  Set Variable  ${EMPTY}
    FOR  ${part}  IN  @{what_to_log}
        ${to_log}=  Catenate  ${to_log}  ${part}
    END
    Log  ${to_log[1:]}  level=${level}  console=${console}

Create Long String
    [Arguments]  @{what_to_create}

    ${to_create}=  Set Variable  ${EMPTY}
    FOR  ${part}  IN  @{what_to_create}
        ${to_create}=  Catenate  ${to_create}  ${part}
    END

    [Return]  ${to_create[1:]}

Get TargetBD File From SW Package
    [Documentation]
    ...  Keyword providing TargetBD xml file from SW Package
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter       | Man. | Description                               |
    ...  | SW_package_path | Yes  | path to directory with target SW zip file |
    ...
    ...  *RETURN*
    ...  | Parameter    | Description            |
    ...  | TargetBD_xml | TargetBD xml file info |

    [Arguments]  ${SW_package_path}
    ${file_list}=  Zip File List  ${SW_package_path}
    FOR  ${item}  IN  @{file_list}
        ${status}=  Run Keyword And Return Status  Should Match Regexp  ${item}  (?i).*TargetBD.*
        ${TargetBD_file}=  Set Variable If  ${status}  ${item}
        Exit For Loop If  ${status}
    END
    ${TargetBD_xml}=  Zip Open File  ${SW_package_path}  ${TargetBD_file}
    [Return]  ${TargetBD_xml}

Get BTS MODULE LANE info dict
    [Documentation]
    ...  KW used to get BTS info dict for shared modules (RMOD or FHS) LANE and CONNECTOR.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter   | Man. | Default | Description     |
    ...  | module_type | Yes  |         | RMOD or FHS     |
    ...  | alias       | Yes  |         | Master or Slave |
    ...
    [Arguments]  ${module_type}  ${alias}

    ${SFP_SMOD_list}=  Get SFP list from BTS module  SMOD  ${alias}
    ${SFP_BBMOD_list}=  Get SFP list from BTS module  BBMOD  ${alias}
    ${BTS_SFP_SMOD_BBMOD_list}=  Combine Lists  ${SFP_SMOD_list}  ${SFP_BBMOD_list}
    Set Test Variable  ${BTS_SFP_SMOD_BBMOD_list}

    ${CONNECTOR_LANE_dict}=  Get CONNECTOR LANE info dict  ${BTS_SFP_SMOD_BBMOD_list}  ${alias}
    Set Test Variable  ${CONNECTOR_LANE_dict}

    ${MODULE_CONNECTOR_dict}=  Get MODULE CONNECTOR info dict  ${module_type}  ${alias}
    Set Test Variable  ${MODULE_CONNECTOR_dict}

    ${MODULE_LANE_dict}=  Get MODULE LANE info dict
    Set Test Variable  ${MODULE_LANE_dict}

Get SFP list from BTS module
    [Arguments]  ${module_type}  ${alias}
    ${module_list}=  coam.Get Ids For All  class_name=${module_type}  connection=${alias}
    ${SFP_list}=  Create List
    FOR  ${item}  IN  @{module_list}
        ${SFP_param_list}=  Query Infomodel  get list ${item}/SFP_R-*  timeout=3  allow_negative_result=True  alias=${alias}
        ${SFP_module_list}=  Get SFP list  ${SFP_param_list}
        Append To List  ${SFP_list}  @{SFP_module_list}
    END
    [Return]  ${SFP_list}

Download SCF From BTS
    [Arguments]  ${alias}

    ${current_scf}=  Run Keyword If  '${${alias.upper()}\['${alias.upper()}_TECH']}' in ['NR', 'LTE', 'SBTS']
    ...  Admin Collect scf.xml with timestamp TAF  alias=${alias}  folder_path=${BTSFiles}/${alias}
    ...  ELSE IF  '${${alias.upper()}\['${alias.upper()}_TECH']}' == 'WCDMA'
    ...  Download scf.xml with timestamp  ${alias}  ${BTSFiles}/${alias}
    ...  ELSE IF  '${${alias.upper()}\['${alias.upper()}_TECH']}' == 'GSM'
    ...  Set Variable  ${None}
    ...  ELSE  Set Variable  ${None}

    [Return]  ${current_scf}

Check Entity BTS Configuration
    [Arguments]  ${alias}  ${alias_scf}=${EMPTY}  ${alias_siteconf}=${EMPTY}

    ${bts_states}=  Run Keyword If  '${${alias.upper()}\['${alias.upper()}_TECH']}' in ['NR', 'LTE']
    ...  Check BTS Configuration SOAM  ${alias}  scf_file=${alias_scf}
    ...  ELSE IF  '${${alias.upper()}\['${alias.upper()}_TECH']}' == 'SBTS'
    ...  Check BTS Configuration SBTS  ${alias}  scf_file=${alias_scf}
    ...  ELSE IF  '${${alias.upper()}\['${alias.upper()}_TECH']}' == 'WCDMA'
    ...  Check BTS Configuration  ${alias}  siteconf_file=${alias_siteconf}  scf_file=${alias_scf}
    ...  ELSE IF  '${${alias.upper()}\['${alias.upper()}_TECH']}' == 'GSM'
    ...  Set Variable  ${True}
    ...  ELSE  ${False}

    ${final_state}=  Set Variable If  ${bts_states}  ${True}  ${False}
    Run Keyword If  ${final_state}
    ...  Log  Properly BTS configuration on ${alias}!  console=True
    ...  ELSE  Log  ${alias} BTS is not properly configured!  level=ERROR  console=True

    [Return]  ${final_state}

Infomodel Get baseband pool allocation mode info
    [Documentation]
    ...  Helper keyword providing baseband pool allocation mode info.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Default | Description                       |
    ...  | alias     | Yes  |         | alias of admin_infomodel instance |
    ...

    [Arguments]  ${alias}
    ${LTE_cell_ids}  ${LTE_IOT_cell_ids}=  Admin Get LTE CELL Ids list  ${alias}
    FOR  ${item}  IN  @{LTE_cell_ids}
        ${CONF_REF_obj}=  Query Infomodel  get object ${item}/CONF_REF-1  alias=${alias}
        ${BBPOOLALLOC_A_param}=  Query Infomodel  query=get object ${CONF_REF_obj.distName}/BBPOOLALLOC_A-*  alias=${alias}
        ${bbPoolAllocMode_found}=  Run Keyword And Return Status  Variable Should Exist  ${BBPOOLALLOC_A_param.bbPoolAllocMode}
        Run Keyword If  ${bbPoolAllocMode_found}
        ...  Log  LNCEL ${item} bbPoolAllocMode: ${BBPOOLALLOC_A_param.bbPoolAllocMode}  console=True
        ...  ELSE
        ...  Log  LNCEL ${item} bbPoolAllocMode: No info available  console=True
    END

Get BBMOD CELL mapping based on BBPOOL info
    [Arguments]  ${alias}
    ${CELL_info_list}=  coam.Get Cell List  connection=${alias}
    Set Test Variable  ${CELL_info_list}
    Get LCRID-NRCEL info dict  ${alias}
    Get LCRID-LNCEL info dict  ${alias}
    Get LCRID-WNCEL info dict  ${alias}
    Get LCRID-GNCEL info dict  ${alias}
    ${BBMOD_CELL_dict}=  Get BBMOD CELL info dict  ${alias}
    [Return]  ${BBMOD_CELL_dict}

Get LCRID-NRCEL info dict
    [Arguments]  ${alias}
    ${LCRID_NRCEL_dict}=  Create Dictionary
    FOR  ${item}  IN  @{CELL_info_list['cells']['nr']}
        ${NRCEL_L_param}=  Query Infomodel  query=get object //NRCELL_L-${item['globalCellId']}  alias=${alias}
        Set To Dictionary  ${LCRID_NRCEL_dict}  ${NRCEL_L_param['lcrId']}  ${item['id']['internal']}
    END
    Set Test Variable  ${LCRID_NRCEL_dict}

Get LCRID-LNCEL info dict
    [Arguments]  ${alias}
    ${LCRID_LNCEL_dict}=  Create Dictionary
    FOR  ${item}  IN  @{CELL_info_list['cells']['lte']}
        ${LNCEL_L_param}=  Query Infomodel  query=get object //LNCEL_L-${item['globalCellId']}  alias=${alias}
        Set To Dictionary  ${LCRID_LNCEL_dict}  ${LNCEL_L_param['lcrId']}  ${item['id']['internal']}
    END
    Set Test Variable  ${LCRID_LNCEL_dict}

Get LCRID-WNCEL info dict
    [Arguments]  ${alias}
    ${LCRID_WNCEL_dict}=  Create Dictionary
    FOR  ${item}  IN  @{CELL_info_list['cells']['wcdma']}
        ${WNCEL_L_param}=  Query Infomodel  query=get object //WNCEL_L-${item['cellId']}  alias=${alias}
        Set To Dictionary  ${LCRID_WNCEL_dict}  ${WNCEL_L_param['lcrId']}  ${item['id']['internal']}
    END
    Set Test Variable  ${LCRID_WNCEL_dict}

Get LCRID-GNCEL info dict
    [Arguments]  ${alias}
    ${LCRID_GNCEL_dict}=  Create Dictionary
    FOR  ${item}  IN  @{CELL_info_list['cells']['gsm']}
        ${GNCEL_L_param}=  Query Infomodel  query=get object //GNCEL_L-* is [btsObjId=${item['gsmSectorID']}]  alias=${alias}
        Set To Dictionary  ${LCRID_GNCEL_dict}  ${GNCEL_L_param['lcrId']}  ${item['id']['internal']}
    END
    Set Test Variable  ${LCRID_GNCEL_dict}

Get BBMOD CELL info dict
    [Arguments]  ${alias}
    ${BBMOD_CELL_dict}=  Create Dictionary
    Set Test Variable  ${BBMOD_CELL_dict}
    ${BBMOD_list}=  coam.Get Ids For All  class_name=BBMOD  connection=${alias}
    Sort List  ${BBMOD_list}
    FOR  ${item}  IN  @{BBMOD_list}
        ${BBMOD_CELL_list}=  Get BBMOD CELL mapping list  ${item}  ${alias}
        ${BBMOD_CELL_list} =  Remove Duplicates  ${BBMOD_CELL_list}
        Set To Dictionary  ${BBMOD_CELL_dict}  ${item}  ${BBMOD_CELL_list}
    END
    [Return]  ${BBMOD_CELL_dict}

Get BBMOD CELL mapping list
    [Arguments]  ${BBMOD_id}  ${alias}
    ${BBADM_obj}=  Query Infomodel  query=get object //BBADM_R-*  alias=${alias}
    ${BBPOOL_obj}=  Query Infomodel  query=get list ${BBADM_obj.dist_name}/BBPOOL_R-*  alias=${alias}
    ${BBMOD_CELL_list}=  Create List
    FOR  ${item}  IN  @{BBPOOL_obj}
        ${BBMOD_id_list}=  Get BBMOD info from bbPwrGroupDNList  ${item.bbPwrGroupDNList}
        ${CELL_Id_list}=  Conversion LCRID to CELLID  ${item.bbPoolCellsList}  ${item.bbPoolTech}
        Run Keyword If  '${BBMOD_id}' in ${BBMOD_id_list}
        ...  Append To List  ${BBMOD_CELL_list}  @{CELL_Id_list}
    END
    [Return]  ${BBMOD_CELL_list}

Get BBMOD info from bbPwrGroupDNList
    [Arguments]  ${bbPwrGroupDNList}
    ${BBMOD_id_list}=  Create List
    FOR  ${item}  IN  @{bbPwrGroupDNList}
        ${BBMOD_id}=  Fetch From Left  ${item}  /POWERGROUP_R
        Append To List  ${BBMOD_id_list}  ${BBMOD_id}
    END
    ${BBMOD_id_list} =  Remove Duplicates  ${BBMOD_id_list}
    [Return]  ${BBMOD_id_list}

Conversion LCRID to CELLID
    [Arguments]  ${LCRID_lists}  ${bbPoolTech}
    ${CELL_Id_list}=  Create List
    ${LCRID_CEL_dict}=  Set Variable If
    ...  '${bbPoolTech}' == '5G'  ${LCRID_NRCEL_dict}
    ...  '${bbPoolTech}' == 'LTE'  ${LCRID_LNCEL_dict}
    ...  '${bbPoolTech}' == 'WCDMA'  ${LCRID_WNCEL_dict}
    ...  '${bbPoolTech}' == 'GSM'  ${LCRID_GNCEL_dict}
    FOR  ${item}  IN  @{LCRID_lists}
        ${CELL_Id}=  Get From Dictionary  ${LCRID_CEL_dict}  ${item}
        Append To List  ${CELL_Id_list}  ${CELL_Id}
    END
    [Return]  ${CELL_Id_list}

Check LTE state and alarm number
    [Arguments]  ${RM_connectionList}  ${RM_CELL_list}   ${CELL_IOT_dict}  ${alias}=default
    FOR  ${RM_CELL_details}  IN  @{RM_CELL_list}
        Continue For Loop If  '${RM_CELL_details[0]}' != '${RM_connectionList}'
        Get LTE cells alarms number  ${RM_CELL_details[1]}  ${CELL_IOT_dict}
        Check LTE cells state and MIMO alarm  alias=${alias}
        Set Test Variable  ${RM_cells_count_alarms_mimo}  ${ALARM_COUNT_MIMO}
        Exit For Loop
    END

Get TargetBD RMOD SW info dict
    [Documentation]
    ...  Keyword providing RMOD SW info dict from TargetBD xml file
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter    | Man. | Description            |
    ...  | TargetBD_xml | Yes  | TargetBD xml file info |
    ...  | productName  | Yes  | RMOD product name      |
    ...
    ...  *RETURN*
    ...  | Parameter                               | Description                          |
    ...  | resourceBuildKey_resourceSWVersion_dict | TargetBD RMOD resourceSWVersion dict |
    ...  | resourceBuildKey_buildTimestamp_dict    | TargetBD RMOD buildTimestamp dict    |

    [Arguments]  ${TargetBD_xml}  ${productName}
    ${resourceBuildKey_list}=  Create List  LTX_${productName}  LTX_${productName}_C1  LTX_${productName}_E1
    ...   LTX_${productName}_N1    LTX_${productName}_S1
    ${resourceBuildKey_resourceSWVersion_dict}=  Create Dictionary
    ${resourceBuildKey_buildTimestamp_dict}=  Create Dictionary

    ${TargetBD_xml_decoded}=  Decode Bytes To String  ${TargetBD_xml}  UTF-8
    ${TargetBD_xml_parsed}=  Parse xml  ${TargetBD_xml_decoded}
    FOR  ${item}  IN  @{resourceBuildKey_list}
        ${resourceBuildKey_status}=  Run Keyword And Return Status
        ...  Element Should Exist  ${TargetBD_xml_parsed}  .//hwResource[@resourceBuildKey="${item}"]
        Continue For Loop If  '${resourceBuildKey_status}' == 'False'
        ${info}=  Get Element Attributes  ${TargetBD_xml_parsed}  .//hwResource[@resourceBuildKey="${item}"]
        Set To Dictionary  ${resourceBuildKey_resourceSWVersion_dict}  ${item}  ${info['resourceSWVersion']}
        ${buildTimestamp_status}=  Run Keyword And Return Status
        ...  Variable Should Exist  ${info['buildTimestamp']}
        ${buildTimestamp_value}=  Set Variable If  ${buildTimestamp_status}  ${info['buildTimestamp']}  None
        Set To Dictionary  ${resourceBuildKey_buildTimestamp_dict}  ${item}  ${buildTimestamp_value}
    END
    [Return]  ${resourceBuildKey_resourceSWVersion_dict}  ${resourceBuildKey_buildTimestamp_dict}

Get BTS Running RMOD SW info dict
    [Documentation]
    ...  Keyword providing RMOD SW info dict from BTS
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Description             |
    ...  | alias     | Yes  | alias of admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter                       | Description                           |
    ...  | productName_buildVersion_dict   | RMOD product name buildVersion dict   |
    ...  | productName_buildTimestamp_dict | RMOD product name buildTimestamp dict |

    [Arguments]  ${alias}
    ${productName_buildVersion_dict}=  Create Dictionary
    ${productName_buildTimestamp_dict}=  Create Dictionary
    ${productName_l3Protocol_dict}=  Create Dictionary
    ${RMOD_list}=  coam.Get Ids For All  class_name=RMOD  connection=${alias}
    Sort List  ${RMOD_list}
    FOR  ${item}  IN  @{RMOD_list}
        ${RMOD_param}=  coam.Get Parameters For  class_name=RMOD  id_num=${item}  connection=${alias}
        ${productName_status}=  Run Keyword And Return Status
        ...  Dictionary Should Contain Key  ${productName_buildVersion_dict}  ${RMOD_param.productName}
        Continue For Loop If  ${productName_status}
        Set To Dictionary  ${productName_buildVersion_dict}  ${RMOD_param.productName}  ${RMOD_param.buildVersion}
        Set To Dictionary  ${productName_l3Protocol_dict}  ${RMOD_param.productName}  ${RMOD_param.l3Protocol}
        ${REF_obj} =  Query Infomodel  get object ${item}/REF-*  alias=${alias}
        ${RMOD_L_obj}=  Set Variable  ${REF_obj.distName}
        ${BUILD_DATA_param}=  Query Infomodel  get object ${RMOD_L_obj}/RU_L-1/STORAGE_L-1/FILE_SYSTEM_L-1/BUILD_DATA_L-1
        ...    alias=${alias}
        ${bldTimestamp_status}=  Run Keyword And Return Status
        ...  Variable Should Exist  ${BUILD_DATA_param['bldTimestamp']}
        ${bldTimestamp_value}=  Set Variable If  ${bldTimestamp_status}  ${BUILD_DATA_param['bldTimestamp']}  None
        Set To Dictionary  ${productName_buildTimestamp_dict}  ${RMOD_param.productName}  ${bldTimestamp_value}
    END
    [Return]  ${productName_buildVersion_dict}  ${productName_buildTimestamp_dict}  ${productName_l3Protocol_dict}


Check Optical Switch definition info
    [Documentation]
    ...  Check Optical Switch definition info for optical connector (BTS module side) and optical switch port (CALIENT side)
    ...  in optical_switch_ports.yaml

    [Arguments]  ${MODULE_type}  ${MODULE_sn}  ${MODULE_connector_name}

    ${OPTICAL_SWITCH_PORTS_keys}=  Get Dictionary Keys  ${OPTICAL_SWITCH_PORTS}
    ${OPTICAL_SWITCH_PORTS_values}=  Get Dictionary Values  ${OPTICAL_SWITCH_PORTS}

    ${MODULE_label}=  Catenate  SEPARATOR=_  ${MODULE_type}  ${MODULE_sn}

    Log  Check Optical Switch definition info for ${MODULE_label} item:  console=True
    Run Keyword If  '${MODULE_label}' in ${OPTICAL_SWITCH_PORTS_keys}
    ...  Log  - ${MODULE_label} item defined in optical_switch_ports.yaml!  console=True
    ...  ELSE  Run Keywords
    ...  Log  - ${MODULE_label} item not defined in optical_switch_ports.yaml!  level=ERROR
    ...  AND  Fail  Execution ended

    Log  Check Optical Switch definition info for ${MODULE_connector_name} item:  console=True
    FOR  ${item_key}  ${item_value}  IN ZIP  ${OPTICAL_SWITCH_PORTS_keys}  ${OPTICAL_SWITCH_PORTS_values}
        Continue For Loop If  '${item_key}' != '${MODULE_label}'
        ${status}=  Run Keyword And Return Status  Variable Should Exist  ${item_value['${MODULE_connector_name}']}
        Run Keyword If  ${status}
        ...     Log
        ...    ${MODULE_connector_name} : ${item_value['${MODULE_connector_name}']} item defined in optical_switch_ports.yaml!
        ...     console=True
        ...     ELSE  Run Keywords
        ...     Log   ${MODULE_connector_name} item not defined in optical_switch_ports.yaml!  level=ERROR
        ...     AND  Fail  Execution ended
        Set Test Variable  ${${MODULE_type}_${MODULE_sn}_${MODULE_connector_name}_cross_connection}
        ...    ${item_value['${MODULE_connector_name}']}
        Exit For Loop If  ${status}
    END

Get actSharedRUIndControl parameter value
    [Documentation]
    ...  Get feature CB007878 info related to actSharedRUIndControl parameter value.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Description             |
    ...  | RMOD_id   | Yes  | RMOD id runtime view    |
    ...  | alias     | Yes  | alias of admin instance |
    ...
    ...  *RETURN VALUE*
    ...  | Parameter             | Description                                |
    ...  | actSharedRUIndControl | actSharedRUIndControl value: True or False |

    [Arguments]  ${RMOD_id}  ${alias}
    ${obj_A_id}=  Get BTS object configuration info related to object runtime info  ${RMOD_id}  ${alias}
    ${obj_A_param}=  Query Infomodel  query=get object ${obj_A_id}  alias=${alias}
    [Return]  ${obj_A_param.actSharedRUIndControl}

Get BTS object configuration info related to object runtime info
    [Documentation]
    ...  Get BTS object configuration info related to object runtime info
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Description                       |
    ...  | obj_R_id  | Yes  | Object runtime view id            |
    ...  | alias     | Yes  | alias of admin_infomodel instance |
    ...
    ...  *RETURN VALUE*
    ...  | Parameter | Description             |
    ...  | obj_A_id  | Object configuration id |

    [Arguments]  ${obj_R_id}  ${alias}
    ${obj_R_param}=  Query Infomodel  get object ${obj_R_id}  alias=${alias}
    ${configDN_status}=  Run Keyword And Return Status  Variable Should Exist  ${obj_R_param.configDN}
    Return From Keyword If  ${configDN_status}  ${obj_R_param.configDN}
    ${CONF_REF_obj}=  Query Infomodel  get object ${obj_R_id}/CONF_REF-1  alias=${alias}
    [Return]  ${CONF_REF_obj.distName}


Get RMOD SCF distinguished name
    [Documentation]
    ...  KW used to get RMOD SCF distinguished name

    [Arguments]  ${RMOD_R_id}  ${alias}
    ${BTS_info}=  coam.Get Bts Info  connection=${alias}
    FOR  ${item}  IN  @{BTS_info['radioModules']['rmod']}
        Exit For Loop If  '${item['id']['internal']}' == '${RMOD_R_id}'
    END
    [Return]  ${item['id']['configuration']}

Get peerBtsActSharedRUIndControl parameter value
    [Documentation]
    ...  Get feature CB007878 info related to peerBtsActSharedRUIndControl parameter value.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Description             |
    ...  | RMOD_id   | Yes  | RMOD id runtime view    |
    ...  | alias     | Yes  | alias of admin instance |
    ...
    ...  *RETURN VALUE*
    ...  | Parameter                    | Description                                       |
    ...  | peerBtsActSharedRUIndControl | peerBtsActSharedRUIndControl value: True or False |

    [Arguments]  ${RMOD_id}  ${alias}
    ${RMOD_param}=  Query Infomodel  query=get object ${RMOD_id}  alias=${alias}
    [Return]  ${RMOD_param.peerBtsActSharedRUIndControl}

Get actIndSwUpgradeForSharedRU parameter value
    [Documentation]
    ...  Get feature CB006028 info related to actIndSwUpgradeForSharedRU parameter value.
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Description             |
    ...  | RMOD_id   | Yes  | RMOD id runtime view    |
    ...  | alias     | Yes  | alias of admin instance |
    ...
    ...  *RETURN VALUE*
    ...  | Parameter                  | Description                                     |
    ...  | actIndSwUpgradeForSharedRU | actIndSwUpgradeForSharedRU value: True or False |

    [Arguments]  ${RMOD_id}  ${alias}
    ${obj_A_id}=  Get BTS object configuration info related to object runtime info  ${RMOD_id}  ${alias}
    ${obj_A_param}=  Query Infomodel  query=get object ${obj_A_id}  alias=${alias}
    [Return]  ${obj_A_param.actIndSwUpgradeForSharedRU}

Get SFP SCF distinguished name
    [Documentation]
    ...  KW used to get SFP SCF distinguished name

    [Arguments]  ${SFP_R_id}  ${alias}
    ${BTS_info}=  coam.Get Bts Info  connection=${alias}
    FOR  ${item}  IN  @{BTS_info['basebandModules']}
        ${SFP_distName}  ${SFP_check}=  Parse SFP info  ${item['ports']}  ${SFP_R_id}  ${alias}
        Exit For Loop If  ${SFP_check}
    END
    [Return]  ${SFP_distName}

Parse SFP info
    [Arguments]  ${SFP_info}  ${SFP_R_id}
    ${SFP_distName}=  Set Variable  None
    ${SFP_check}=  Set Variable  False
    FOR  ${item}  IN  @{SFP_info}
        Continue For Loop If  '${item['id']['internal']}' != '${SFP_R_id}'
        ${SFP_distName_exists}=  Run Keyword And Return Status  Variable Should Exist  ${item['id']['configuration']}
        ${SFP_distName}=  Set Variable If  ${SFP_distName_exists}  ${item['id']['configuration']}  None
        ${SFP_check}=  Set Variable  True
        Exit For Loop
    END
    [Return]  ${SFP_distName}  ${SFP_check}


Get BTS SCF parameter info
    [Arguments]  ${BTS_scf}  ${BTS_scf_class}  ${BTS_scf_param_name}
    ${BTS_scf_xml}=  Parse xml  ${BTS_scf}
    ${param_exists}=  Run Keyword And Return Status  Element Should Exist
    ...  ${BTS_scf_xml}  .//managedObject[@class="com.nokia.srbts.mnl:${BTS_scf_class}"]/p[@name="${BTS_scf_param_name}"]
    Return From Keyword If  not ${param_exists}  ${None}
    ${BTS_scf_param_value}=  Get Element Text
    ...  ${BTS_scf_xml}  .//managedObject[@class="com.nokia.srbts.mnl:${BTS_scf_class}"]/p[@name="${BTS_scf_param_name}"]
    [Return]  ${BTS_scf_param_value}

List Diff
    [Documentation]
    ...  Collect Snapshot Via SSH
    ...
    ...  *AUTHOR*
    ...  lixin.kang@nokia.com
    ...
    ...  *HISTORY*
    ...   2022.9.29  Add for hran_ta merge to robotws. To replace hran_tools.List Diff
    ...
    [Arguments]    ${final_list}    ${initial_list}
    Remove Values From List    ${final_list}   @{initial_list}
    ${diff}    Set Variable   ${final_list}
    [Return]     ${diff}