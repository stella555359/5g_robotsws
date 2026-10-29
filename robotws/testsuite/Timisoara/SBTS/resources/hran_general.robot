*** Settings ***
Documentation     [PURPOSE] SWM General keywords from HZ
...               CA-SWM/COMPA
Library     Collections
Library     DateTime
Library     lib/tool_ping.py
Library     OperatingSystem
Library     Process
Library     String
Library     SSHLibrary
#Library     FtpLibrary
Library     Telnet
Resource    hran_infomodel.robot
Resource    hran_admin.robot
Library           lib/SSHExecutor.py
Library           SSHExecutor.SSHSystemModuleOperations


*** Variables ***
@{no alarms}
${DF LOG PATH}=  ${OUTPUT DIR}/df.log


*** Keywords ***
Restore login by json removal from BTS
    [Documentation]
    ...    Removes content of /ffs/run/config/users.json on BTS and performes reset
    Log    Restore login will be done by removal /ffs/run/config/users.json file    console=${TRUE}
    Run keyword and ignore error      Execute command on SM via SSH   192.168.255.1    rm -rf /ffs/run/config/users.json
    Run keyword and ignore error            Execute command on SM via SSH   192.168.255.1    reboot
    Wait for target to be not reachable     hostname=192.168.255.1      timeout=30
    Check if Target is stable               ip=192.168.255.1            min_uptime=180

Check variable '${variable name}' exist
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${variable name}: <description>
    ${var exist}  Run Keyword and return status  Variable should exist  ${${variable name}}
    Run Keyword if  ${var exist} is not True  Fatal Error  Variable ${variable name} is not defined
    ...  ELSE  Log  Variable ${variable name} is equal to ${${variable name}}

Get RM productName and ipAddress from IM
    [Documentation]
    ...  Query infomodel for RMOD objects and create list of list containing product names and IP addresses
    ...  of radio modules in form [ipAddress, productName]. Work only for radio modules connected do SM
    ...  (list is sorted according to IP address). Works only for LTE on master or slave.
    ...
    ...  *AUTHOR* patryk.furman@nokia.com
    ...
    ...  *RETURN*
    ...  | Parameter | Description                                                                            |
    ...  | rm_list   | List of lists where each one is containing field with RM IP address and RM productName |
    ...
    ...  *EXAMPLE*
    ...  | ${rm_list} | Get RM productName and ipAddress from IM |

    ${rm_list}=  Create list  @{EMPTY}
    @{rm_details}=  Run keyword if  '${MASTER['MASTER_TECH']}' is 'LTE'
    ...                 Query infomodel  alias=Master  query=get list //EQM_L-1/RMOD_L-*  timeout=90
    ...             ELSE IF  '${SLAVE['SLAVE_TECH']}' is 'LTE'
    ...                 Query infomodel  alias=Slave  query=get list //EQM_L-1/RMOD_L-*  timeout=90
    ...             ELSE
    ...                 Log  WCDMA is not supported yet! Sorry!
    FOR  ${rm_object}  IN  @{rm_details}
        @{temp}=  Create list  ${rm_object.ipAddress}  ${rm_object.productName}
        Append to list  ${rm_list}  ${temp}
    END
    sort list  ${rm_list}
    [Return]  ${rm_list}

Get file from SM
    [Documentation]
    ...  Download file from SM under given IP address. Returns path, where file was downloaded to.
    ...
    ...  *AUTHOR* patryk.furman@nokia.com
    ...
    ...  | Parameter   | Man. | Description                                           |
    ...  | ip_address  | Yes  | IP address of SM from which file should be downloaded |
    ...  | remote_path | Yes  | Absolute path on SM from which file should be taken   |
    ...  | local_path  | Yes  | Absolute path to which file should be saved           |
    ...
    ...  *RETURN*
    ...  | Parameter  | Description                           |
    ...  | local_path | Absolute path to which file was saved |
    ...
    ...  *EXAMPLE*
    ...  | ${local_path}= | Get file from SM | 192.168.255.1 | /flash/config/lifedata/blackbox | /home/ute/btsauto |

    [Arguments]  ${ip_address}  ${remote_path}  ${local_path}
    SSHLibrary.open connection  ${ip_address}
    SSHLibrary.login  toor4nsn  oZPS0POrRieRtu
    SSHLibrary.get file  ${remote_path}  ${local_path}
    [Return]  ${local_path}
    [Teardown]  SSHLibrary.close connection

SW update
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${Target SW dir}: <description>
    [Arguments]    ${Target SW dir}
    Log  ${\n} step3: SW update  console=True
    Log  Will now perform software update  console=True
    taf.sbts.oam.coam.admin.Update Software  ${Target SW dir}  True  3000

Get SW file for SWDL
    [Documentation]
    ...  Verify given directory and return a path to the SW file (with given name or the newest in directory)
    ...
    ...	 *AUTHOR* tomasz.1.filipek@nokia.com
    [Arguments]  ${SW dir}  ${SW name}
    OperatingSystem.Directory should exist  ${SW dir}
    OperatingSystem.Directory should not be empty  ${SW dir}
    Run keyword and return if  '${SW name}'=='None'  get newest file from directory  ${SW dir}  *.zip
    ${SW path}=  Join Path 	${SW dir}  ${SW name}.zip
    OperatingSystem.File should exist  ${SW path}
    [Return]  ${SW path}

Check if SW already exists on BTS
    [Documentation]
    ...  pass_if_exists=False or omitted: Fail if given SW already exists on BTS (active)
    ...  pass_if_exists=True: Immediately ends the test as passed if given SW already exists on BTS (active)
    ...
    ...  *AUTHOR* tomasz.1.filipek@nokia.com
    [Arguments]  ${target SW}  ${active SW}  ${passive SW}  ${pass_if_exists}=${False}
    ${target is passive}=
    ...  run keyword and return status  Should Match Regexp  ${target SW}  (?i).*${passive SW}(?!T[12]).*
    run keyword if  ${target is passive}  log  Target SW is the same as the passive
    ${target is active}=
    ...  run keyword and return status  Should Match Regexp  ${target SW}  (?i).*${active SW}(?!T[12]).*
    run keyword if  ${target is active} and ${pass_if_exists}  pass execution  Target SW is the same as the active
    run keyword if  ${target is active}  fail  Target SW is the same as the active

Check if both technologies will begin reset
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${ping lost timeout}: <description>
    ...        ${ping recovery timeout}: <description>
    ...        ${master ip}: <description>
    ...        ${slave ip}: <description>
    ...
    ...    Returns:
    ...        ${ping lost}: <description>
    ...        ${ping recover}: <description>
    [Arguments]  ${ping lost timeout}  ${ping recovery timeout}  ${master ip}  ${slave ip}
    ${ping lost}=
    ...  Run keyword and return status  Wait Until Keyword Succeeds   ${ping lost timeout}  0 sec
    ...  Both technologies are unreachable  ${master ip}  ${slave ip}
    ${ping recover}=  Run keyword and return status
    ...  Wait Until Keyword Succeeds  ${ping recovery timeout}  0 sec
    ...  Both technologies are reachable  ${master ip}  ${slave ip}
    [Return]  ${ping lost}  ${ping recover}

Check if only slave will begin reset
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${ping lost timeout}: <description>
    ...        ${ping recovery timeout}: <description>
    ...        ${master ip}: <description>
    ...        ${slave ip}: <description>
    ...
    ...    Returns:
    ...        ${master reachable}: <description>
    ...        ${slave ping lost}: <description>
    ...        ${slave ping recover}: <description>
    [Arguments]  ${ping lost timeout}  ${ping recovery timeout}  ${master ip}  ${slave ip}
    ${slave ping lost}=  Run keyword and return status  Wait Until Keyword Succeeds   ${ping lost timeout}  0 sec
    ...  Wait for target to be not reachable  hostname=${slave ip}  timeout=1  remote_host=${PC_IP2}
        ...  remote_host_username=ute  remote_host_password=ute  remote_host_port=${22}
    ${master reachable}=  Run keyword and return status  Wait for target to be reachable  ${master ip}  timeout=5
    ${slave ping recover}=  Run keyword and return status  Wait Until Keyword Succeeds  ${ping recovery timeout}  0 sec
    ...  Wait for target to be reachable  hostname=${slave ip}  timeout=1  remote_host=${PC_IP2}
        ...  remote_host_username=ute  remote_host_password=ute  remote_host_port=${22}
    [Return]  ${master reachable}  ${slave ping lost}  ${slave ping recover}

Both technologies are unreachable
    [Documentation]
    ...  *AUTHOR* tomasz.1.filipek@nokia.com
    [Arguments]  ${master ip}  ${slave ip}
    ${master ping}=  Run keyword and return status
    ...  Wait for target to be not reachable  hostname=${master ip}  timeout=1
    ${slave ping}=  Run keyword and return status
    ...  Wait for target to be not reachable  hostname=${slave ip}  timeout=1
    ...  remote_host=${SLAVE['SLAVE_PC_IP_ADDRESS']}  remote_host_username=${SLAVE['SLAVE_PC_SSH_USERNAME']}
    ...  remote_host_password=${SLAVE['SLAVE_PC_SSH_PASSWORD']}  remote_host_port=${SLAVE['SLAVE_PC_SSH_PORT']}
    run keyword if
    ...  not ${master ping} or not ${slave ping}  Fail  At least one of the technology didnt stopped to be reachable

Both technologies are reachable
    [Documentation]
    ...  *AUTHOR* tomasz.1.filipek@nokia.com
    [Arguments]  ${master ip}  ${slave ip}
    ${master ping}=  Run keyword and return status  Wait for target to be reachable  hostname=${master ip}  timeout=1
    ${slave ping}=  Run keyword and return status
    ...  Wait for target to be reachable  hostname=${slave ip}  timeout=1  remote_host=${SLAVE['SLAVE_PC_IP_ADDRESS']}
    ...  remote_host_username=${SLAVE['SLAVE_PC_SSH_USERNAME']}  remote_host_password=${SLAVE['SLAVE_PC_SSH_PASSWORD']}
    ...  remote_host_port=${SLAVE['SLAVE_PC_SSH_PORT']}
    run keyword if
    ...  not ${master ping} or not ${slave ping}  Fail  At least one of the technology didnt started to be reachable

Check WCDMA and LTE alarms
    [Documentation]
    ...  Wrapper for KW which checks WCDMA and LTE active alarms. As an input it takes lists of
    ...  expected and ignored alarms
    ...  from both RATs.
    ...
    ...  *AUTHOR* patryk.furman@nokia.com
    ...
    ...  | Parameter        | Man. | Description                   |
    ...  | wcdma_exp_alarms | No   | List of WCDMA expected alarms |
    ...  | wcdma_ign_alarms | No   | List of WCDMA ignored alarms  |
    ...  | lte_exp_alarms   | No   | List of LTE expected alarms   |
    ...  | lte_ign_alarms   | No   | List of LTE ignored alarms    |
    ...
    ...  *EXAMPLE*
    ...  | Check WCDMA and LTE alarms | [['7665', 'Core']] | [['7655', '4003'], ['7654', '4003']] |

    [Arguments]  ${wcdma_exp_alarms}=@{EMPTY}  ${wcdma_ign_alarms}=@{EMPTY}  ${lte_exp_alarms}=@{EMPTY}
    ...          ${lte_ign_alarms}=@{EMPTY}
    Check WCDMA Active Alarms  ${wcdma_exp_alarms}  ${wcdma_ign_alarms}
    Infomodel Check Active Alarms  Slave  ${lte_exp_alarms}  ${lte_ign_alarms}

Check WCDMA and GSM
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${WCDMA exp operational status}: <description>
    ...        ${WCDMA exp operational state}: <description>
    ...        ${WCDMA exp blocking state}: <description>
    ...        ${WCDMA exp alarms}: <description>
    ...        ${WCDMA ign alarms}: <description>
    ...        ${GSM exp operational state}: <description>
    ...        ${GSM exp administrative state}: <description>
    ...        ${GSM exp alarms}: <description>
    ...        ${GSM ign alarms}: <description>
    ...        ${GSM crit alarms}: <description>
    ...        ${GSM allow negative result}: <description>
    [Arguments]  ${WCDMA exp operational status}=OnAir  ${WCDMA exp operational state}=enabled
    ...          ${WCDMA exp blocking state}=${Empty}
    ...          ${WCDMA exp alarms}=@{EMPTY}  ${WCDMA ign alarms}=@{EMPTY}
    ...          ${GSM exp operational state}=WO  ${GSM exp administrative state}=U
    ...          ${GSM exp alarms}=${no alarms}  ${GSM ign alarms}=${no alarms}
    ...          ${GSM crit alarms}=${no alarms}  ${GSM allow negative result}=${False}
    hran_wcdma.Check WCDMA
    ...          ${WCDMA exp operational status}  ${WCDMA exp operational state}  ${WCDMA exp blocking state}
    ...          ${WCDMA exp alarms}  ${WCDMA ign alarms}
    Parse bcf trxs status  ${SLAVE['BCF_ID']}
    ...          expected_operational_state=${GSM exp operational state}
    ...        expected_administrative_state=${GSM exp administrative state}
    ...          allow_negative_result=${GSM allow negative result}
    Check bcf alarms  ${SLAVE['BCF_ID']}  5min  expected_alarms=${GSM exp alarms}  ignored_alarms=${GSM ign alarms}
    ...  critical_alarms=${GSM crit alarms}

Execute command on SM via SSH
    [Documentation]
    ...  Keyword opens connection to host machine via SSH. execute the given command and checks its return code. Command
    ...  can be executed from localhost and from remote host.
    ...
    ...  *AUTHOR* patryk.furman@nokia.com
    ...
    ...  | Parameter            | Man. | Description                                            |
    ...  | ip_address           | Yes  | IP address of host on which command should be executed |
    ...  | command              | Yes  | Command to execute                                     |
    ...  | remote_host          | No   | Remote host IP address (None as default)               |
    ...  | remote_host_username | No   | Remote host username (None as default)                 |
    ...  | remote_host_password | No   | Remote host password  (None as default)                |
    ...
    ...  *RETURN*
    ...  | Parameters | Description    |
    ...  | output     | Command output |
    ...
    ...  *EXAMPLE*
    ...  | Execute command on SM via SSH | 192.168.255.1 | rm -rf /flash/config/PersDataFiles/SCFC_* |
    ...
    ...  | ${output}= | Execute command on SM via SSH | 192.168.255.5 | ls -la / | 10.42.35.166 | ute | ute |

    [Arguments]  ${ip_address}  ${command}  ${remote_host}=${EMPTY}
    ...  ${remote_host_username}=${EMPTY}  ${remote_host_password}=${EMPTY}
    Set Connection Parameters  ${ip_address}  via_ip=${remote_host}  via_user=${remote_host_username}
    ...  via_password=${remote_host_password}
    ${output}  ${rc}=  Run Command  ${command}
    Should Be Equal  ${rc}  ${0}  msg=${command} operation RC is not equal 0
    [Return]  ${output}

Execute command on SM via Telnet
    [Documentation]
    ...  Keyword opens connection to host machine via Telnet. execute the given command and checks its return code.
    ...  Command should be suitable to host OS.
    ...
    ...  *AUTHOR* patryk.furman@nokia.com
    ...
    ...  | Parameter  | Man. | Description                                            |
    ...  | ip_address | Yes  | IP address of host on which command should be executed |
    ...  | command    | Yes  | Command to execute                                     |
    ...
    ...  *EXAMPLE*
    ...  | Execute command on SM via Telnet | 192.168.255.1 | rm -rf /flash/config/PersDataFiles/SCFC_* |

    [Arguments]  ${ip_address}  ${command}
    Telnet.open connection  ${ip_address}  prompt=root@FCMD:~ >
    Telnet.login  toor4nsn  oZPS0POrRieRtu
    Telnet.execute command  ${command}
    ${rc}=  Telnet.execute command  echo $?  strip_prompt=True
    Should Be Equal As Integers  ${rc}  ${0}  msg=Operation RC is not equal 0
    [Teardown]  Telnet.close connection

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

Get Module Operational Status
    [Documentation]
    ...  Keyword for obtaining operationalStatus value from BTS siteconf.xml.
    ...
    ...  *AUTHOR* patryk.furman@nokia.com
    ...
    ...  | Parameter | Man. | Description                                        |
    ...  | alias     | Yes  | Alias used via ute_btssm library (Slave or Master) |
    ...
    ...  *RETURN*
    ...  | Parameter         | Description                                           |
    ...  | operationalStatus | operationalStatus value fetched from BTS siteconf.xml |
    ...
    ...  *EXAMPLE*
    ...  | ${module_state}= | Get Module Operational Status | Master |

    [Arguments]  ${alias}
    ${files_list}=  Upload siteconf bts file  alias=${alias}
    Copy file  ${files_list[0]}  ${Test Files}/
    ${operationalStatus}=  Get element text  ${files_list[0]}  .//_operationalStatus
    [Return]  ${operationalStatus}

Get BTS state
    [Documentation]
    ...  Keyword providing WCDMA or LTE BTS state information from siteconf.xml.
    ...
    ...  *AUTHOR* dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Description                                        |
    ...  | alias     | Yes  | Master or Slave |
    ...  | path to siteconf     | No  | it can be explicitly as ${path_to_siteconf[0]}
    ...                                 from previous Upload siteconf bts file or EMPTY |
    ...
    ...  *RETURN*
    ...  BTS info: [bsId, blockingState, operationalStatus]
    [Arguments]  ${alias}  ${path_to_siteconf}=${EMPTY}
    Run keyword if  '${path_to_siteconf}' == ''  Get siteconf.xml from SM  ${alias}
    ${BTS_bsId}=  Get elements texts  ${path_to_siteconf}  .//BS/_bsId
    ${BTS_blockingState}=  Get elements texts  ${path_to_siteconf}  .//BS/_blockingState
    ${BTS_operationalStatus}=  Get elements texts  ${path_to_siteconf}  .//BS/_operationalStatus
    ${BTS_state_list}=  create list  @{EMPTY}
    FOR  ${bsId}  ${blockingState}  ${operationalStatus}
    ...   IN ZIP  ${BTS_bsId}  ${BTS_blockingState}  ${BTS_operationalStatus}
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
    ...  from previous Upload siteconf bts file or EMPTY |
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
    FOR  ${unitName}  ${unitNumber}  ${workingState}  ${blockingState}  ${operationalState}
    ...  IN ZIP  ${SM_unitName}  ${SM_unitNumber}  ${SM_workingState}  ${SM_blockingState}  ${SM_operationalState}
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
    ...  | path to siteconf     | No  | it can be explicitly as ${path_to_siteconf[0]} from previous Upload siteconf bts file or EMPTY |
	...from previous Upload siteconf bts file or EMPTY |
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
    FOR  ${unitName}  ${connectionList}  ${workingState}  ${blockingState}  ${operationalState}
    ...  IN ZIP  ${RM_unitName}  ${RM_connectionList}  ${RM_workingState}  ${RM_blockingState}  ${RM_operationalState}
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
    ...  | Parameter | Man. | Description                                        |
    ...  | alias     | Yes  | Master or Slave |
    ...  | path to siteconf     | No  | it can be explicitly as
    ...  ${path_to_siteconf[0]} from previous Upload siteconf bts file or EMPTY |
	...
	...  *RETURN*
    ...  CELL info as list of items
    ...  item info: [globalCellId, workingState, blockingState, operationalState, cellAvailability]
    [Arguments]  ${alias}  ${path_to_siteconf}=${EMPTY}
    Run keyword if  '${path_to_siteconf}' == ''  Get siteconf.xml from SM  ${alias}
    ${CELL_globalCellId}=  Get elements texts  ${path_to_siteconf}  .//Cell/_globalCellId
    ${CELL_workingState}=  Get elements texts  ${path_to_siteconf}  .//Cell/_state
    ${CELL_blockingState}=  Get elements texts  ${path_to_siteconf}  .//Cell/_blockingState
    ${CELL_operationalState}=  Get elements texts  ${path_to_siteconf}  .//Cell/_operationalState
    ${CELL_cellAvailability}=  Get elements texts  ${path_to_siteconf}  .//Cell/_cellAvailability
    ${CELL_state_list}=  create list  @{EMPTY}
    FOR  ${globalCellId}  ${workingState}  ${blockingState}  ${operationalState}  ${cellAvailability}
    ...  IN ZIP  ${CELL_globalCellId}  ${CELL_workingState}  ${CELL_blockingState}  ${CELL_operationalState}
    ...  ${CELL_cellAvailability}
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
    ...  KW for downloading siteconf.xml from BTS to destination directory.Siteconf.xml gets name in form'siteconf_time'
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
    [Documentation]    Short description.
    ${testtimestamp}=    OperatingSystem.Run    date +%F_%H-%M-%S
    ${testresultspath_TMP}=    OperatingSystem.Join Path    ${OUTPUT DIR}    ${testtimestamp}_TEST-${TEST NAME}
    ${testresultspath}=	      Replace String     ${testresultspath_TMP}    	 ${SPACE} 	    _
    Create Directory    ${testresultspath}
    Set Test Variable    ${Test Results Dir}    ${testresultspath}
    Log  'Test Results Dir' created: ${Test Results Dir}  level=DEBUG  console=${TRUE}

Create '${dirname}' in '${rootdir}' And Set Test Variable
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${dirname}: <description>
    ...        ${rootdir}: <description>
    ${testtimestamp}=    OperatingSystem.Run    date +%F_%H-%M-%S
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
    ...  | configuration | Yes  | if local==false host_ip=<remote_host_ip>,
    ...  ssh_port=<port>, ssh_username=<usenrame>, ssh_passsword=<password> |
    ${kill_cmd}=  Set Variable  kill -KILL $(ps -ef | grep -i ${process_name} | awk '{print $2}')
    Run Keyword If  ${local}  Process.Run process  ${kill_cmd}  shell=${TRUE}
    ...  ELSE  Run Keywords
    ...  SSHLibrary.Open Connection  host=${configuration["host_ip"]}  port=${configuration["ssh_port"]}
    ...  AND  _SSHLibrary_Login_multiway  ${configuration["ssh_username"]}  ${configuration["ssh_password"]}
    ...  AND  SSHLibrary.Execute Command  ${kill_cmd}  return_stdout=${FALSE}
    ...  AND  SSHLibrary.Close Connection
    [Return]  ${TRUE}

Get Workspace Version
    [Documentation]    Short description.
    ${hran_path}=  Set variable  /home/ute/btsauto/hran_ta
    ${USE_GIT}=  Set variable  True
    Log  Default repository path is: ${hran_path}  level=INFO
    Run keyword if  ${USE_GIT}  Run keyword
    ...  Find workspace version and set tags  git --git-dir=${hran_path}/.git/ describe --all | awk -F '/' '{print $NF}'
    ...  ELSE
    ...  Find workspace version and set tags  svn info ${hran_path} | grep ^URL | awk -F '/' '{print $NF}'

Find workspace version and set tags
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${command}: <description>
    ...
    ...    Returns:
    ...        ${workspace_version}: <description>
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
    ...  RemoteSwingLibrary.
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
    ...  | Kill processes remained after files deletion on VMs /home partition | Extension
    ...  | host_ip=10.42.35.151 | ssh_port=22 | ssh_username=ute | ssh_password=ute |

    [Arguments]  ${alias}=local  &{configuration}
    Log  Kill processes remained after files deletion on /home partition  console=${TRUE}
    ${pids_cmd}=  Set Variable
    ...  lsof | grep -P '/home(?!.*(chrome|remote-stderr|remote-stdout)).*deleted' | awk '!seen[$2]++ {print $2}'
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
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${clean_directory}: <description>
    ...        ${older_than_min}: <description>
    ...        ${alias}: <description>
    ...        &{configuration}: <description>
    ...
    ...    Returns:
    ...        ${result}: <description>
    [Arguments]  ${clean_directory}  ${older_than_min}  ${alias}=local  &{configuration}
    Log  Removing files older than ${older_than_min} min from "${clean_directory}" on ${alias}
    ...  level=INFO  console=${TRUE}
    ${str1} =   Catenate    if [ "$(ls -A ${clean_directory})" ];
    ...  then find ${clean_directory}/* -maxdepth 0 -mmin +${older_than_min} -exec rm -rf {} \\; ; fi
    ${command}=  Set Variable  ${str1}
    ${cleaning_rc}=  Run Keyword If  '${alias}'=='local' or '${alias}'=='Master'
    ...  Execute Local Command  ${command}  ELSE
    ...  Execute Remote Command  ${command}  ${alias}  &{configuration}
    ${result}=  Run Keyword And Return Status
    ...  Should Be Equal  ${cleaning_rc}  ${0}
    ...  msg=RC of operation clean "${clean_directory}" on ${alias} is not equal 0
    run keyword if  ${result}
    ...  Log  "${clean_directory}" on ${alias} cleaned  level=INFO  console=${TRUE}  ELSE
    ...  Log   Failed to clean "${clean_directory}" on ${alias}  level=INFO  console=${TRUE}
    [Return]  ${result}

Clean up directory windows
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${clean_directory}: <description>
    ...        ${older_than_min}: <description>
    ...        ${alias}: <description>
    ...        &{configuration}: <description>
    ...
    ...    Returns:
    ...        ${result}: <description>
    [Arguments]  ${clean_directory}  ${older_than_min}  ${alias}=local  &{configuration}
    Log  Removing files older than ${older_than_min} min from "${clean_directory}" on ${alias}  level=INFO
    ...  console=${TRUE}
    ${str1} =   Catenate    if [ "$(ls -A ${clean_directory})" ]
    ...  then /bin/find ${clean_directory}/* -maxdepth 0 -mmin +${older_than_min} -exec rm -rf {} \\; ; fi
    ${command}=  Set Variable   ${str1}
    ${cleaning_rc}=  Run Keyword If  '${alias}'=='local' or '${alias}'=='Master'
    ...  Execute Local Command  ${command}  ELSE
    ...  Execute Remote Command  ${command}  ${alias}  &{configuration}
    ${result}=  Run Keyword And Return Status  Should Be Equal
    ...  ${cleaning_rc}  ${0}  msg=RC of operation clean "${clean_directory}" on ${alias} is not equal 0
    run keyword if  ${result}
    ...  Log  "${clean_directory}" on ${alias} cleaned  level=INFO  console=${TRUE}  ELSE
    ...  Log  Failed to clean "${clean_directory}" on ${alias}, probably it's already cleaned!  level=INFO  console=${TRUE}
    [Return]  ${result}

Execute Local Command
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${command}: <description>
    ...
    ...    Returns:
    ...        ${command_rc}: <description>
    [Arguments]  ${command}
    ${command_rc}=  Run And Return Rc  ${command}
    [Return]  ${command_rc}

Execute Local Command And Return Output
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${command}: <description>
    ...
    ...    Returns:
    ...        ${command_stdout}: <description>
    [Arguments]  ${command}
    ${command_stdout}=  Run  ${command}
    [Return]  ${command_stdout}

Execute Local Command In Loop
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${looped_command}: <description>
    ...
    ...    Returns:
    ...        ${terminal_command_rc}: <description>
    [Arguments]  ${looped_command}
    ${terminal_command_rc}=  _Execute Command In Loop Via  Run And Return Output And Rc  ${looped_command}
    [Return]  ${terminal_command_rc}

Run And Return Output And Rc
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${command}: <description>
    ...
    ...    Returns:
    ...        ${rv}: <description>
    ...        ${rc}: <description>
    [Arguments]  ${command}
    ${rc}  ${rv}=  Run Keyword  Run And Return Rc And Output  ${command}
    [Return]  ${rv}  ${rc}

Execute Remote Command
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${command}: <description>
    ...        ${index_or_alias}: <description>
    ...        &{configuration}: <description>
    ...
    ...    Returns:
    ...        ${command_rc}: <description>
    [Arguments]  ${command}  ${index_or_alias}  &{configuration}
    _Remote Command Setup  ${index_or_alias}  &{configuration}
    ${command_rc}=  SSHLibrary.Execute Command  ${command}  return_stdout=False  return_rc=True
    [Teardown]  _Remote Command Teardown
    [Return]  ${command_rc}

Execute Remote Command And Return Output
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${command}: <description>
    ...        ${index_or_alias}: <description>
    ...        &{configuration}: <description>
    ...
    ...    Returns:
    ...        ${command_stdout}: <description>
    [Arguments]  ${command}  ${index_or_alias}  &{configuration}
    _Remote Command Setup  ${index_or_alias}  &{configuration}
    ${command_stdout}=  SSHLibrary.Execute Command  ${command}  return_stdout=True  return_rc=False
    [Teardown]  _Remote Command Teardown
    [Return]  ${command_stdout}

Execute Remote Command In Loop
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${looped_command}: <description>
    ...        ${index_or_alias}: <description>
    ...        &{configuration}: <description>
    ...
    ...    Returns:
    ...        ${terminal_command_rc}: <description>
    [Arguments]  ${looped_command}  ${index_or_alias}  &{configuration}
    _Remote Command Setup  ${index_or_alias}  &{configuration}
    ${terminal_command_rc}=  _Execute Command In Loop Via
    ...  SSHLibrary.Execute Command  ${looped_command}  return_stdout=True  return_rc=True
    [Teardown]  _Remote Command Teardown
    [Return]  ${terminal_command_rc}

_Remote Command Setup
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index_or_alias}: <description>
    ...        &{configuration}: <description>
    [Arguments]  ${index_or_alias}  &{configuration}
    ${check_connection}=  SSHLibrary.Get Connection  ${index_or_alias}
    Run Keyword If  ${check_connection.index}
    ...  SSHLibrary.Switch Connection  ${index_or_alias}  ELSE
    ...  SSHLibrary.Open Connection  host=${configuration["host_ip"]}  port=${configuration["ssh_port"]}
    _SSHLibrary_Login_multiway  ${configuration["ssh_username"]}  ${configuration["ssh_password"]}

_SSHLibrary_Login_multiway
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${username}: <description>
    ...        ${password}: <description>
    [Arguments]  ${username}  ${password}
    ${status}=  Run keyword and return status  SSHLibrary.Login  ${username}  ${password}
    Return from keyword if  ${status}
    ${status}=  Run keyword and return status  SSHLibrary.Login with public key  ${username}
    ...  /home/${username}/.ssh/id_rsa
    Run keyword if    not ${status}  Fail  Remote connection unavailable

_Remote Command Teardown
    [Documentation]    Short description.
    SSHLibrary.Close Connection

_Execute Command In Loop Via
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${keyword}: <description>
    ...        ${looped_command}: <description>
    ...        @{keyword_args}: <description>
    ...        &{keyword_kwargs}: <description>
    ...
    ...    Returns:
    ...        ${terminal_command_rc}: <description>
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
    Create 'Snapshot' in '${Test Results Dir}' And Set Test Variable
    Create Temp Logs Dir And Set Test Variable

Create Temp Logs Dir And Set Test Variable
    [Documentation]    Short description.
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
    ...  ${connection_type}=telnet
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
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${CURDIR}/../config/${HW_LOCATION_CODE }/${TESTLINE_NAME}/commissioning/@{scf_file_name}[0]: <description>
    @{scf_file_name}=
    ...  OperatingSystem.List Files In Directory
    ...  ${CURDIR}/../config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/commissioning  SCF_01_*.xml
    [Return]  ${CURDIR}/../config/${HW_LOCATION_CODE }/${TESTLINE_NAME}/commissioning/@{scf_file_name}[0]

Hran_ta Preconditions
    [Documentation]    Short description.
    Log  Common Test Setup  level=INFO  console=${TRUE}
    Get Workspace Version
    Create Dirs For Logs
    Set TC Verdict Variables

Hran_ta Postconditions
    [Documentation]    Short description.
    Log  End of Common Test Teardown  level=INFO  console=${TRUE}

Check RM Unit Name According To Its Id
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${RF_ids_list}: <description>
    ...        ${siteconf_path}: <description>
    ...
    ...    Returns:
    ...        ${RF_unitNames_list}: <description>
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
        ...      Unblock Cell  ${cell[0]}  alias=${alias}  AND
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
    ${Master_RM_Working}=  Set Variable  ${TRUE}
    ${Slave_RM_Working}=  Set Variable  ${TRUE}
    ${Master_RM_State_List}=  Get RM State  Master  ${master_siteconf}
    ${Master_RM_Working}=  Calculate RMs Working State From ${Master_RM_State_List}
    ${Slave_RM_Working}=  Run Keyword  Check Slave ${set_slave_tech} RM State  ${slave_siteconf}
    ${All_RM_Working}=  Set Variable If  ${Master_RM_Working} is ${TRUE} and ${Slave_RM_Working} is ${TRUE}  ${TRUE}  ${FALSE}
    ${str1} =	Catenate     SEPARATOR=,
    ...  Master RM enabled: ${Master_RM_Working}
    ...  Slave RM enabled: ${Slave_RM_Working}
    ...  All RMs are working: ${All_RM_Working}
    Log  ${str1}    level=TRACE  console=${TRUE}
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
    ...  Get RM State  Master  ${master_siteconf}  ELSE IF  '${MASTER['MASTER_TECH']}' in ['NR','LTE','SBTS']
    ...  Admin Get RMOD state info  Master
    ${Master_RM_Operational_Working}=  Run Keyword  Check Master ${MASTER['MASTER_TECH']} RM State SOAM
    ${Slave_RM_Operational}=  Run Keyword If  '${SLAVE['SLAVE_TECH']}' in ['LTE','SBTS']  Check Slave LTE RM State SOAM
    ...  ELSE IF  '${SLAVE['SLAVE_TECH']}'=='GSM'  Check Slave GSM RM State
    ${All_RM_Working}=  Set Variable If  ${Master_RM_Operational_Working} and ${Slave_RM_Operational}  ${TRUE}  ${FALSE}
    ${str1} =	Catenate     SEPARATOR=,
    ...  Master RM enabled: ${Master_RM_Operational_Working}
    ...  Slave RM enabled: ${Slave_RM_Operational}
    ...  All RMs are working: ${All_RM_Working}
    Log   ${str1}    level=TRACE  console=${TRUE}
    [Return]  ${All_RM_Working}

Check Master WCDMA RM State SOAM
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${Master_RM_Working}: <description>
    ${Master_RM_State_List}=  Get RM State  Master
    ${Master_RM_Working}=  Calculate RMs Working State From ${Master_RM_State_List}
    [Return]  ${Master_RM_Working}

Check Master LTE RM State SOAM
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${Master_RM_Operational}: <description>
    ${Master_RM_State_List}=  Admin Get LTE RMOD state info  Master
    ${Master_RM_Operational}=  Calculate RMs Operational State SOAM From ${Master_RM_State_List}
    [Return]  ${Master_RM_Operational}

Check Master NR RM State SOAM
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${Master_RM_Operational}: <description>
    ${Master_RM_State_List}=  Admin Get RMOD state info  Master
    ${Master_RM_Operational}=  Calculate RMs Operational State SOAM From ${Master_RM_State_List}
    [Return]  ${Master_RM_Operational}

Check Slave LTE RM State
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${slave_siteconf}: <description>
    ...
    ...    Returns:
    ...        ${Slave_RM_Working}: <description>
    [Arguments]  ${slave_siteconf}
    ${Slave_RM_State_List}=  Get RM State  Slave  ${slave_siteconf}
    ${Slave_RM_Working}=  Calculate RMs Working State From ${Slave_RM_State_List}
    [Return]  ${Slave_RM_Working}

Check Slave LTE RM State SOAM
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${Slave_RM_Operational}: <description>
    ${Slave_RM_State_List}=  Admin Get LTE RMOD state info  Slave
    ${Slave_RM_Operational}=  Calculate RMs Operational State SOAM From ${Slave_RM_State_List}
    [Return]  ${Slave_RM_Operational}

Check Slave GSM RM State
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${dummy}: <description>
    ...
    ...    Returns:
    ...        ${Slave_RM_Operational}: <description>
    [Arguments]  ${dummy}=${EMPTY}
    Log    ${dummy}
    ${RM_OpState_dict}  ${log}=  All Rf Unit Op State
    ${RM_OpState_keys}=  Get Dictionary Keys  ${RM_OpState_dict}
    ${RM_OpState_values}=  Get Dictionary Values  ${RM_OpState_dict}
    ${Slave_RM_Operational}=  Set Variable  ${TRUE}
    FOR  ${key}  ${value}  IN ZIP  ${RM_OpState_keys}  ${RM_OpState_values}
        Log  RmId: ${key}, RM_operationalState: ${value}  level=DEBUG  console=${TRUE}
        ${Slave_RM_Operational}=  Set Variable If  '${value}' != 'FrmEnabled'  ${FALSE}  ${Slave_RM_Operational}
        Run keyword if    not ${Slave_RM_Operational}  Log  RM is in ${value} state  level=WARN
    END
    [Return]  ${Slave_RM_Operational}

Calculate RMs Working State From ${RM_states_list}
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${RM_states_list}: <description>
    ...
    ...    Returns:
    ...        ${RM_Working}: <description>
    ${RM_Working}=  Set Variable  ${TRUE}
    FOR  ${rm_items}  IN  @{RM_states_list}
        Log  RmId: ${rm_items[1]}, RM_workingState: ${rm_items[2]}  level=DEBUG  console=${TRUE}
        ${RM_Working}=  Set Variable If  '${rm_items[2]}' != 'working'  ${FALSE}  ${RM_Working}
        Run keyword if    not ${RM_Working}  Log  RM is in ${rm_items[2]} state  level=WARN
    END
    [Return]  ${RM_Working}

Calculate RMs Operational State SOAM From ${RM_states_list}
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${RM_states_list}: <description>
    ...
    ...    Returns:
    ...        ${RM_Operational}: <description>
    ${RM_Operational}=  Set Variable  ${TRUE}
    FOR  ${rm_items}  IN  @{RM_states_list}
        Log  RmId: ${rm_items[0]}, RM_operationalState: ${rm_items[3]}  level=DEBUG  console=${TRUE}
        ${RM_Operational}=  Set Variable If  '${rm_items[3]}' != 'Enabled'  ${FALSE}  ${RM_Operational}
        Run keyword if    not ${RM_Operational}  Log  RM is in ${rm_items[3]} state  level=WARN
    END
    [Return]  ${RM_Operational}

Check All Cells State
    [Documentation]
    ...  Keyword used to determine cells states for all technologies. For GSM, TRXs will be checked.
    ...  *AUTHOR* radu.andronache@nokia.com
    ...  *AUTHOR* catalin.chiorean@nokia.com
    [Timeout]  200 sec
    [Arguments]  ${set_slave_tech}  ${master_siteconf}=${EMPTY}  ${slave_siteconf_or_bcf_id}=${EMPTY}
    Log    ${master_siteconf}
    ${MasterCellsAreOnAir}=  Set Variable  ${TRUE}
    ${SlaveCellsAreOnAir}=  Set Variable  ${TRUE}
    ${MasterCellStateList}=  Get CELL state  Master  ${master_siteconf}
    ${MasterCellsAreOnAir}=  Calculate Cells Working State From ${MasterCellStateList}
    ${SlaveCellsAreOnAir}=  Run Keyword  Check Slave ${set_slave_tech} All Cells  ${slave_siteconf_or_bcf_id}
    ${CellsAreOnAir}=  Set Variable If  ${MasterCellsAreOnAir} and ${SlaveCellsAreOnAir}  ${TRUE}  ${FALSE}
    ${str1} =	Catenate     SEPARATOR=,
    ...  Master Cells enabled: ${MasterCellsAreOnAir}
    ...  Slave Cells enabled: ${SlaveCellsAreOnAir}
    ...  All Cells are onAir: ${CellsAreOnAir}
    Log    ${str1}   level=TRACE  console=${TRUE}
    Run keyword if    not ${MasterCellsAreOnAir}  Log  Master Cells are not operational!  level=ERROR  console=${TRUE}
    Run keyword if    not ${SlaveCellsAreOnAir}  Log  Slave Cells are not operational!  level=ERROR  console=${TRUE}
    [Return]  ${CellsAreOnAir}

Check All Cells State SOAM
    [Documentation]
    ...  Keyword used to determine cells states for all technologies. For GSM, TRXs will be checked.
    ...  *AUTHOR* serban.hamza@nokia.com
    [Timeout]  200 sec
#    [Arguments]  ${master_siteconf}=${EMPTY}
    ${MasterCellsAreOnAir}=  Set Variable  ${TRUE}
    ${SlaveCellsAreOnAir}=  Set Variable  ${TRUE}
    ${MasterCellsAreOnAir}=  Run Keyword  Check Master ${MASTER['MASTER_TECH']} All Cells SOAM
    ${SlaveCellsAreOnAir}=  Run Keyword If  '${SLAVE['SLAVE_TECH']}'=='LTE'
    ...  Check Slave LTE All Cells SOAM
    ...  ELSE IF  '${SLAVE['SLAVE_TECH']}'=='SBTS'
    ...  Check Slave SBTS All Cells SOAM
    ...  ELSE IF  '${SLAVE['SLAVE_TECH']}'=='GSM'
    ...  Check Slave GSM All Cells  ${SLAVE['BCF_ID']}
    ${CellsAreOnAir}=  Set Variable If  ${MasterCellsAreOnAir} and ${SlaveCellsAreOnAir}  ${TRUE}  ${FALSE}
    ${str1} =	Catenate     SEPARATOR=,
    ...  Master Cells enabled: ${MasterCellsAreOnAir}
    ...   Slave Cells enabled: ${SlaveCellsAreOnAir}
    ...  All Cells are onAir: ${CellsAreOnAir}
    Log  ${str1}    level=TRACE  console=${TRUE}
    Run keyword if    not ${MasterCellsAreOnAir}  Log  Master Cells are not operational!  level=ERROR  console=${TRUE}
    Run keyword if    not ${SlaveCellsAreOnAir}  Log  Slave Cells are not operational!  level=ERROR  console=${TRUE}
    [Return]  ${CellsAreOnAir}

Check Master WCDMA All Cells SOAM
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${master_siteconf}: <description>
    ...
    ...    Returns:
    ...        ${MasterCellsAreOnAir}: <description>
    [Arguments]  ${master_siteconf}=${EMPTY}
    ${MasterCellStateList}=  Get CELL state  Master  ${master_siteconf}
    ${MasterCellsAreOnAir}=  Calculate Cells Working State From ${MasterCellStateList}
    [Return]  ${MasterCellsAreOnAir}

Check Master LTE All Cells SOAM
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${MasterCellsAreOnAir}: <description>
    ${MasterCellStateList}=  Admin Get LTE CELL state info  Master
    ${MasterCellsAreOnAir}=  Calculate Cells Working State SOAM From ${MasterCellStateList}
    [Return]  ${MasterCellsAreOnAir}

Check Master NR All Cells SOAM
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${MasterCellsAreOnAir}: <description>
    ${MasterCellStateList}=  Admin Get NR CELL state info  Master
    ${MasterCellsAreOnAir}=  Calculate NR Cells Working State SOAM From ${MasterCellStateList}
    [Return]  ${MasterCellsAreOnAir}

Check Slave LTE All Cells
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${slave_siteconf}: <description>
    ...
    ...    Returns:
    ...        ${SlaveCellsAreOnAir}: <description>
    [Arguments]  ${slave_siteconf}=${EMPTY}
    ${SlaveCellStateList}=  Get CELL state  Slave  ${slave_siteconf}
    ${SlaveCellsAreOnAir}=  Calculate Cells Working State From ${SlaveCellStateList}
    [Return]  ${SlaveCellsAreOnAir}

Check Slave LTE All Cells SOAM
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${SlaveCellsAreOnAir}: <description>
    ${SlaveCellStateList}=  Admin Get LTE CELL state info  Slave
    ${SlaveCellsAreOnAir}=  Calculate Cells Working State SOAM From ${SlaveCellStateList}
    [Return]  ${SlaveCellsAreOnAir}

Check Slave GSM All Cells
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${set_bcf_id}: <description>
    ...
    ...    Returns:
    ...        ${SlaveCellsAreOnAir}: <description>
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
        Log  CellId: ${cell_items[0]},CELL_operationalState: ${cell_items[2]}, CELL_availabilityStatus: ${cell_items[4]}
        ...  level=DEBUG  console=${TRUE}
        ${CellsAreOnAir}=  Set Variable If
        ...  '${cell_items[2]}' != 'Enabled' or '${cell_items[4]}' != 'Online'  ${FALSE}  ${CellsAreOnAir}
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
    ...  ELSE IF         '${tech}' == 'LTE'    Siteconf Get LTE RM Types and Connection Number  ${alias}
    ...  ELSE    Fail  Tech is not a WCDMA or LTE. Break test!

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
        ${reset_counter}  ${resets_reasons}=
        ...  Get New Resets Number and Reasons  ${old_reset_reason_list}  ${timeout}  ${alias}
        Exit For Loop If  ${reset_counter} > 0
    END
    Run Keyword If  ${reset_counter} == 0  Log  No reset occurred  level=INFO
    ...  ELSE IF  ${reset_counter} == 1  Log  Reset occurred  level=INFO
    ...  ELSE IF  ${reset_counter} > 1  Log  Occurred more than one resets  level=INFO
    Return From Keyword If  ${reset_counter} > 0  ${TRUE}  ${resets_reasons}
    [Return]  ${FALSE}  ${EMPTY}

Check Presence Of Active Alarms Via SEM CLI
    [Documentation]
    ...  KW for launching SEM CLI command 'GetActiveAlarms' and checking if any alarms will be visible (which willappear
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

Get file from BTS
    [Documentation]
    ...    Download file from BTS using FTP
    ...
    ...    *AUTHOR* sebastian.burniak@nokia.com
    ...
    ...    | Input Parameter            | Man. | Description                                  |
    ...    | path to bts file     | Yes  | path to directory on BTS where file is located     |
    ...    | filename             | Yes  | Name of file                                       |
    ...    | ip_address           | No   | IP address to SM, default 192.168.255.1            |
    ...    | destination          | No   | Place where file should be saved, default /tmp     |
    ...
    ...    *RETURN*
    ...    path to file where file is saved
    ...
    ...    *EXAMPLE*
    ...    | Get file from BTS | /rom/config/lifedata/ | blackbox |
    [Arguments]  ${path_to_bts_file}  ${filename}  ${ip_address}=192.168.255.1  ${destination}=/tmp/
    #Ftp connect    ${ip_address}    toor4nsn   oZPS0POrRieRtu
    SSHLibrary.open connection  ${ip_address}
    sshLibrary.Login      toor4nsn   oZPS0POrRieRtu
    #Cwd   ${path_to_bts_file}
    #log   ${filename}
    sshLibrary.Get File  ${path_to_bts_file}/${filename}   ${destination}
    #${path}=  Download file   ${filename}   ${destination}
    ${file_path}=  Set variable  ${destination}${filename}
    [Teardown]  sshLibrary.Close Connection
    [Return]    ${file_path}

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
    ...  | Parameter            | Man.  | Default | Description |
    ...  | alias                | No    | default | alias of taf.sbts.oam.coam.admin instance |
    ...  | path_to_siteconf     | No    | empty   | path to siteconf (only for WCDMA) |
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
    ...  LTE: distName, SMODName, productName, operationalState, administrativeState, availabilityStatus,proceduralState
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man.  | Default | Description |
    ...  | alias                | No    | default | alias of taf.sbts.oam.coam.admin instance |
    ...  | path_to_siteconf     | No    | empty   | path to siteconf (only for WCDMA) |
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
    ...  | Parameter            | Man.  | Default | Description |
    ...  | alias                | No    | default | alias of taf.sbts.oam.coam.admin instance |
    ...  | path_to_siteconf     | No    | empty   | path to siteconf (only for WCDMA) |
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
    ...  | Parameter            | Man.  | Default | Description |
    ...  | alias                | No    | default | alias of taf.sbts.oam.coam.admin instance |
    ...  | WCDMA_siteconf       | No    | empty   | path to siteconf (only for WCDMA) |
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
    ...  Log  ${MASTER['MASTER_TECH']} Cells enabled on 'Master': ${MasterCell_Verdict}  level=TRACE  console=${TRUE}
    ...  AND
    ...  LOG  ${SLAVE['SLAVE_TECH']} Cells enabled on 'Slave': ${SlaveCell_Verdict}  level=TRACE  console=${TRUE}
    ...  ELSE  Run Keywords
    ...  Log  ${MASTER['MASTER_TECH']} Cells enabled on 'Master': ${MasterCell_Verdict}  level=TRACE  console=${TRUE}
    ...  AND
    ...  Log  ${SLAVE['SLAVE_TECH']} BTSs enabled on 'Slave': ${SlaveCell_Verdict}  level=TRACE  console=${TRUE}
    [Return]  ${AllCell_Verdict}

Get Master Cell State SOAM
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${WCDMA_siteconf}: <description>
    ...
    ...    Returns:
    ...        ${MasterCell_State}: <description>
    [Arguments]  ${WCDMA_siteconf}=${EMPTY}
    Run Keyword And Return If  '${MASTER['MASTER_TECH']}'=='WCDMA'  Get CELL state SOAM  Master  ${WCDMA_siteconf}
    Run Keyword And Return If  '${MASTER['MASTER_TECH']}'=='LTE'  Get CELL state SOAM  Master
    [Return]  ${MasterCell_State}

Get Slave Cell State SOAM
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${GSM_BCF_ID}: <description>
    ...
    ...    Returns:
    ...        ${SlaveCell_State}: <description>
    [Arguments]  ${GSM_BCF_ID}=${EMPTY}
    Run Keyword And Return If  '${SLAVE['SLAVE_TECH']}'=='LTE'  Get CELL state SOAM  Slave
    Run Keyword And Return If  '${SLAVE['SLAVE_TECH']}'=='GSM'  Get sectors ids  ${GSM_BCF_ID}
    [Return]  ${SlaveCell_State}

Check Master Cell State SOAM
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${MasterCell_State}: <description>
    ...
    ...    Returns:
    ...        ${MasterCell_Verdict}: <description>
    [Arguments]  ${MasterCell_State}=${EMPTY}
    Run Keyword And Return If  '${MASTER['MASTER_TECH']}'=='WCDMA'
    ...  Check WCDMA Cell Operational State SOAM  ${MasterCell_State}
    Run Keyword And Return If  '${MASTER['MASTER_TECH']}'=='LTE'
    ...  Check LTE Cell Operational State SOAM  ${MasterCell_State}
    [Return]  ${MasterCell_Verdict}

Check Slave Cell State SOAM
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${SlaveCell_State}: <description>
    ...        ${GSM_BCF_ID}: <description>
    ...
    ...    Returns:
    ...        ${SlaveCell_Verdict}: <description>
    [Arguments]  ${SlaveCell_State}=${EMPTY}  ${GSM_BCF_ID}=${EMPTY}
    Run Keyword And Return If
    ...  '${SLAVE['SLAVE_TECH']}'=='LTE'  Check LTE Cell Operational State SOAM  ${SlaveCell_State}
    Run Keyword And Return If  '${SLAVE['SLAVE_TECH']}'=='GSM'  Check GSM Bts Operational State SOAM  ${GSM_BCF_ID}
    [Return]  ${SlaveCell_Verdict}

Check WCDMA Cell Operational State SOAM
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${Cell_State}: <description>
    ...
    ...    Returns:
    ...        ${WCDMACell_Verdict}: <description>
    [Arguments]  ${Cell_State}
    ${WCDMACell_Verdict}=  Set Variable  ${TRUE}
    FOR  ${item}  IN  @{Cell_State}
        Log  WCDMA CELL ${item[0]} - Operational State: ${item[3]}  level=DEBUG  console=${TRUE}
        ${WCDMACell_Verdict}=  Set Variable If  '${item[3]}' != 'enabled'  ${FALSE}  ${WCDMACell_Verdict}
    END
    [Return]  ${WCDMACell_Verdict}

Check LTE Cell Operational State SOAM
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${Cell_State}: <description>
    ...
    ...    Returns:
    ...        ${LTECell_Verdict}: <description>
    [Arguments]  ${Cell_State}
    ${LTECell_Verdict}=  Set Variable  ${TRUE}
    FOR  ${item}  IN  @{Cell_State}
        Log  LTE CELL ${item[1]} - Operational State: ${item[2]}  level=DEBUG  console=${TRUE}
        ${LTECell_Verdict}=  Set Variable If  '${item[2]}' != 'Enabled'  ${FALSE}  ${LTECell_Verdict}
    END
    [Return]  ${LTECell_Verdict}

Check GSM Bts Operational State SOAM
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${GSM_BCF_ID}: <description>
    ...
    ...    Returns:
    ...        ${GSMBts_Verdict}: <description>
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
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${WCDMA_siteconf}: <description>
    ...
    ...    Returns:
    ...        ${MasterRM_State}: <description>
    [Arguments]  ${WCDMA_siteconf}=${EMPTY}
    Run Keyword And Return If  '${MASTER['MASTER_TECH']}'=='WCDMA'  Get RM state SOAM  Master  ${WCDMA_siteconf}
    Run Keyword And Return If  '${MASTER['MASTER_TECH']}'=='LTE'  Get RM state SOAM  Master
    [Return]  ${MasterRM_State}

Get Slave RM State SOAM
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${GSM_BCF_ID}: <description>
    ...
    ...    Returns:
    ...        ${SlaveRM_State}: <description>
    [Arguments]  ${GSM_BCF_ID}=${EMPTY}
    Run Keyword And Return If  '${SLAVE['SLAVE_TECH']}'=='LTE'  Get RM state SOAM  Slave
    Run Keyword And Return If  '${SLAVE['SLAVE_TECH']}'=='GSM'  Get trxs ids  ${GSM_BCF_ID}
    [Return]  ${SlaveRM_State}

Check Master RM State SOAM
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${MasterRM_State}: <description>
    ...
    ...    Returns:
    ...        ${MasterRM_Verdict}: <description>
    [Arguments]  ${MasterRM_State}=${EMPTY}
    Run Keyword And Return If  '${MASTER['MASTER_TECH']}'=='WCDMA'
    ...  Check WCDMA RM Operational State SOAM  ${MasterRM_State}
    Run Keyword And Return If  '${MASTER['MASTER_TECH']}'=='LTE'
    ...  Check LTE RM Operational State SOAM  ${MasterRM_State}
    [Return]  ${MasterRM_Verdict}

Check Slave RM State SOAM
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${SlaveRM_State}: <description>
    ...        ${GSM_BCF_ID}: <description>
    ...
    ...    Returns:
    ...        ${SlaveRM_Verdict}: <description>
    [Arguments]  ${SlaveRM_State}=${EMPTY}  ${GSM_BCF_ID}=${EMPTY}
    Run Keyword And Return If  '${SLAVE['SLAVE_TECH']}'=='LTE'  Check LTE RM Operational State SOAM  ${SlaveRM_State}
    Run Keyword And Return If  '${SLAVE['SLAVE_TECH']}'=='GSM'  Check GSM Trx Operational State SOAM  ${GSM_BCF_ID}
    [Return]  ${SlaveRM_Verdict}

Check WCDMA RM Operational State SOAM
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${RM_State}: <description>
    ...
    ...    Returns:
    ...        ${WCDMARM_Verdict}: <description>
    [Arguments]  ${RM_State}
    ${WCDMARM_Verdict}=  Set Variable  ${TRUE}
    FOR  ${item}  IN  @{RM_State}
        Log  WCDMA RM ${item[0]} ${item[1]} - Operational State: ${item[4]}  level=DEBUG  console=${TRUE}
        ${WCDMARM_Verdict}=  Set Variable If  '${item[4]}' != 'enabled'  ${FALSE}  ${WCDMARM_Verdict}
    END
    [Return]  ${WCDMARM_Verdict}

Check LTE RM Operational State SOAM
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${RM_State}: <description>
    ...
    ...    Returns:
    ...        ${LTERM_Verdict}: <description>
    [Arguments]  ${RM_State}
    ${LTERM_Verdict}=  Set Variable  ${TRUE}
    FOR  ${item}  IN  @{RM_State}
        Log  LTE RM ${item[1]} ${item[2]} - Operational State: ${item[3]}  level=DEBUG  console=${TRUE}
        ${LTERM_Verdict}=  Set Variable If  '${item[3]}' != 'Enabled'  ${FALSE}  ${LTERM_Verdict}
    END
    [Return]  ${LTERM_Verdict}

Check GSM Trx Operational State SOAM
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${GSM_BCF_ID}: <description>
    ...
    ...    Returns:
    ...        ${GSMTrx_Verdict}: <description>
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
    ...  | Parameter            | Man.  | Default | Description |
    ...  | alias                | No    | default | alias of taf.sbts.oam.coam.admin instance |
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
    ...  | Parameter            | Man.  | Default | Description |
    ...  | alias                | No    | default | alias of taf.sbts.oam.coam.admin instance |
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

Get SW Versions
    [Arguments]    ${btssm_alias}=default
    [Documentation]
    ...    Wrapper method that attempts to get software versions from active and passive partitions.
    ...    Three candidate methods are used:
    ...    1. hran_infomodel.Infomodel Get SW Versions
    ...    2. hran_btssm.BTSSM Get SW Versions
    ...    3. `rest_get_sw_versions` form hran_rest library
    ...
    ...    *AUTHOR*
    ...    andrzej.cichon@nokia.com
    ...
    ...    | Parameter            | Man.  | Default | Description                       |
    ...    | btssm_alias          | No    | default | alias of active ute_btssm session |
    ...
    ...    *RETURN*
    ...    | Parameter        | Description                                       |
    ...    | active_sw        | string with software version on active partition  |
    ...    | passive_sw       | string with software version on passive partition |

    ${verdict}    ${sw_versions}=
    ...  Run Keyword And Ignore Error    Infomodel Get SW Versions    log_to_console=${False}
    Return From Keyword If    '${verdict}'=='PASS'    ${sw_versions[0].upper()}    ${sw_versions[1].upper()}

    ${verdict}    ${sw_versions}=    Run Keyword And Ignore Error    BTSSM Get SW Versions    alias=${btssm_alias}
    Return From Keyword If    '${verdict}'=='PASS'    ${sw_versions[0].upper()}    ${sw_versions[1].upper()}

    ${verdict}    ${session}=    Run Keyword And Ignore Error    hran_rest.REST Log In    ${SMOD1['TRS_IP']}
    Return From Keyword If    '${verdict}'=='FAIL'    UNDETERMINED    UNDETERMINED
    ${verdict}    ${sw_versions}=    Run Keyword And Ignore Error    hran_rest.REST Get SW Versions
    hran_rest.REST Log Out
    Return From Keyword If    '${verdict}'=='PASS'    ${sw_versions[0].upper()}    ${sw_versions[1].upper()}

    Return From Keyword    UNDETERMINED    UNDETERMINED

Get RESET info from blackbox file
    [Documentation]
    ...  Get RESET timestamp and reason info from blackbox file (only for WCDMA or LTE)

    [Timeout]  5 min
    [Arguments]  ${alias}  ${when}
    ${reset_reason}=  Get Reset Reason Info  alias=${alias}
    Set Test Variable  ${${alias}_reset_reason_${when}}  ${reset_reason}
    Run Keyword If  '${MASTER['MASTER_TECH']}' == 'WCDMA' and '${alias}' == 'Master'
    ...  Log  ${MASTER['MASTER_TECH']} ${alias} RESET timestamp and reason: ${${alias}_reset_reason_${when}}[-1]
    ...  console=True
    Run Keyword If  ('${MASTER['MASTER_TECH']}' in ['NR','LTE','SBTS']) and '${alias}' == 'Master'
    ...  Log  ${MASTER['MASTER_TECH']} ${alias} RESET timestamp and reason: ${${alias}_reset_reason_${when}}[-1]
    ...  console=True
    Run Keyword If  ('${SLAVE['SLAVE_TECH']}' in ['LTE','SBTS']) and '${alias}' == 'Slave'
    ...  Log  ${SLAVE['SLAVE_TECH']} ${alias} RESET timestamp and reason: ${${alias}_reset_reason_${when}}[-1]
    ...  console=True

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
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${tech}: <description>
    ...        ${alias}: <description>
    ...        ${expected_reset_number}: <description>
    [Timeout]  15 min
    [Arguments]  ${tech}  ${alias}  ${expected_reset_number}

    ${is_SWM}=  Run Keyword And Return Status  Should Contain  ${TEST_NAME}  SWM
    Run Keyword If  '${alias}' == 'Slave' and ${is_SWM}
    ...  Get file from another virtual machine  source_path=${Temp Logs Dir}/SlaveUDP
    ...  destination_path=${Temp Logs Dir}/SlaveUDP  ip=${SLAVE['SLAVE_PC_IP_ADDRESS']}
    ...  username=${SLAVE['SLAVE_PC_SSH_USERNAME']}  password=${SLAVE['SLAVE_PC_SSH_PASSWORD']}
    ${fpga_update_found}=  Run Keyword If  '${tech}' == 'LTE' and ${is_SWM}  Check FPGA Update info from SysLog file
    ...  files_regex=*UDP  dirpath=${Temp Logs Dir}
    ...  ELSE  Set Variable  ${FALSE}
    ${expected_reset_number}=  Run Keyword If  ${fpga_update_found}
    ...  Evaluate  ${expected_reset_number} + 1
    ...  ELSE  Set Variable  ${expected_reset_number}
    Run Keyword If  ${fpga_update_found}  Log  FPGA Update Found  console=True

    ${blackbox_reset_verdict}  Run Keyword And Return Status
    ...  Check Blackbox reset behavior  ${${alias}_reset_reason_initial}  ${${alias}_reset_reason_final}
    ...  ${expected_reset_number}
    ${str1} =	Catenate	${tech} ${alias} reset behavior as expected (expected/found reset number:
    ...  ${expected_reset_number}/${blackbox_reset_number})!
    ${str2} = 	Catenate    ${tech} ${alias} reset behavior not as expected (expected/found reset number:
    ...  ${expected_reset_number}/${blackbox_reset_number})!
    ${str3} = 	Catenate    ${tech} ${alias} reset behavior not as expected (expected/found reset number:
    ...  ${expected_reset_number}/${blackbox_reset_number})!
    Run Keyword If  ${blackbox_reset_verdict}
    ...  Log     ${str1}    console=True
    ...  ELSE  Run Keywords
    ...  Log  ${str2}    level=ERROR  console=True
    ...  AND  Fail     ${str3}

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
    ...    | Parameter        | Description                                                                         |
    ...    | value            | boolean value which is True if CLOCK_FDD_A-1 - syncMaster true and false otherwise  |

    ${value}=  Query Infomodel  alias=Slave  query=//CLOCK_FDD_A-1 is [syncMaster=true]
    ...  allow_negative_result=True
    Log  == slave CLOCK_FDD as syncMaster enabled: ${value}  console=True  level=INFO
    [Return]  ${value}

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
    ...  function unblocks it and wait some time for establishment.
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
    Run keyword if    not ${status}  Create Directory  ${folder_path}

    Set Test Variable  ${SCF_backup_file}  ${alias}_${tech}_scf.xml

    Run Keyword If  '${tech}' == 'GSM'  Run Keywords
    ...  Save Scf File  ${folder_path}/${alias}_${tech}_scf.bz2
    ...  AND  Remove File  ${folder_path}/${alias}_${tech}_scf.bz2
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

SCF backup on demand SOAM
    [Documentation]
    ...  Procedure for SCF backup as below:
    ...  - upload BTS SCF.xml file from BTS to VM as below:
    ...    - for GSM, save BTS SCF.xml file at SCF backup ${folder_path} path
    ...    - for WCDMA, BTS SCF.xml file is saved in specific path of KW Upload Bts Scfc File
    ...    - for LTE/SBTS, BTS SCF.xml file is saved in specific path of KW Collect Scf
    ...  - for WCDMA or LTE/SBTS move BTS SCF.xml file on VM at SCF backup ${folder_path} path
    ...  - check BTS SCF.xml availability at at SCF backup ${folder_path} path
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com
    ...    serban.hamza@nokia.com
    ...
    ...    | Parameter      | Man.  | Default | Description                                     |
    ...    | alias          | no    |         | alias of ute_btssm instance                     |
    ...    | tech           | yes   |         | technology for requested SCF backup             |
    ...    | folder_path    | no    |         | folder path for requested SCF backup file store |

    [Timeout]  20 min
    [Arguments]  ${alias}=default  ${tech}=${EMPTY}  ${folder_path}=/home/ute/btsauto/logs

    ${status}=  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${folder_path}
    Run keyword if    not ${status}  Create Directory  ${folder_path}

    Set Test Variable  ${SCF_backup_file}  ${alias}_${tech}_scf.xml

    Run Keyword If  '${tech}' == 'GSM'  Run Keywords
    ...  Save Scf File  ${folder_path}/${alias}_${tech}_scf.bz2
    ...  AND  Remove File  ${folder_path}/${alias}_${tech}_scf.bz2
    ...  ELSE IF  '${tech}' == 'WCDMA'  Run Keywords
    ...  BTSSM Upload Bts Scfc File  alias=${alias}
    ...  AND  Move File  ${SCF_PATH}/${SCF_FILE}  ${folder_path}/${SCF_backup_file}
    ...  ELSE IF  '${tech}' =='LTE' or '${tech}' =='SBTS'  Run Keywords
    ...  Admin Collect scf.xml with timestamp  ${alias}  ${BTSFiles}/${alias}  configurationAndRuntimeObjects
    ...  AND  Copy File  ${scf_path}  ${folder_path}/${SCF_backup_file}
    ...  ELSE  Run Keywords
    ...  Log  Wrong Technology for SCF backup!  level=ERROR
    ...  AND  Fail  Wrong Technology for SCF backup!

    ${status}=  Run Keyword And Return Status
    ...  OperatingSystem.File Should Exist  ${folder_path}/${SCF_backup_file}
    Run Keyword If  ${status}
    ...  Log  SCF file ${SCF_backup_file} available at ${folder_path}  level=INFO  console=True
    ...  ELSE  Run Keywords
    ...  Log  SCF file ${SCF_backup_file} not available at ${folder_path}  level=ERROR
    ...  AND  Fail  SCF file ${SCF_backup_file} not available at ${folder_path}
    [Return]  ${folder_path}  ${SCF_backup_file}

Snapshot collection on demand
    [Documentation]
    ...  Procedure for Snapshot collection as below:
    ...  - Snapshot file is stored at ${folder_path}
    ...  - Collect Snapshot file from BTS to VM as below:
    ...    - for GSM, save BTS Snapshot.zip file at Snapshot ${folder_path} path
    ...    - for WCDMA or LTE-FSME, BTS Snapshot.zip file is saved in specific path of KW Upload Fullcoverage Bts File
    ...    - for LTE-FSMF or LTE-ASIA, BTS Snapshot.zip file is saved in specific path of KW Save Snapshot
    ...  - for WCDMA or LTE move BTS Snapshot.zip file at Snapshot ${folder_path} path
    ...  - check BTS Snapshot.zip file at Snapshot ${folder_path} path
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com
    ...
    ...    | Parameter      | Man.  | Default | Description                                   |
    ...    | alias          | no    |         | alias of ute_btssm instance                   |
    ...    | tech           | yes   |         | technology for requested Snapshot collection  |
    ...    | folder_path    | no    |         | folder path for requested Snapshot collection |

    [Timeout]  20 min
    [Arguments]  ${alias}=default  ${tech}=${EMPTY}  ${folder_path}=/home/ute/btsauto/logs

    ${status}=  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${folder_path}
    ${alias_connection}=  Convert to Uppercase  ${alias}
    Run keyword if    not ${status}  Create Directory  ${folder_path}

    Set Test Variable  ${Snapshot_filename}  ${alias}_${tech}_snapshot.zip
    ${bool_1} =   Convert To Boolean
    ...  '${tech}' == 'LTE' and '${${alias_connection}\['${alias_connection}_MODULE_TYPE']}' == 'FSME'
    ${bool_2} =   Convert To Boolean
    ...  '${tech}' =='LTE' and '${${alias_connection}\['${alias_connection}_MODULE_TYPE']}' == 'FSMF'
    ${bool_3} =   Convert To Boolean    '${${alias_connection}\['${alias_connection}_MODULE_TYPE']}' == 'ASIA'
    Run Keyword If  '${tech}' == 'GSM'
    ...  Create Snapshot File  ${folder_path}/${Snapshot_filename}
    ...  ELSE IF  '${tech}' == 'WCDMA' or  ${bool_1}
    ...  Run Keywords     BTSSM Upload Fullcoverage Bts File  alias=${alias}
    ...  AND  Move File  ${SNAPSHOT_PATH}/${SNAPSHOT_FILE}  ${folder_path}/${Snapshot_filename}
    ...  ELSE IF  ( ${bool_2} or ${bool_3} ) and '${alias}' == 'Master'
    ...  ute_btssm.Save Snapshot  alias=${alias}  snapshotfilename=${folder_path}/${Snapshot_filename}
    ...  ELSE IF  (${bool_2} or ${bool_3}) and '${alias}' == 'Slave'  Run Keywords
    ...  ute_btssm.Save Snapshot  alias=${alias}  snapshotfilename=${TEMP_LOGS_DIR}/${alias}_${tech}_snapshot.zip
    ...  AND  Get file from another virtual machine  source_path=${TEMP_LOGS_DIR}/${alias}_${tech}_snapshot.zip
    ...  destination_path=${folder_path}/${Snapshot_filename}   ip=${SLAVE['SLAVE_PC_IP_ADDRESS']}
    ...  username=${SLAVE['SLAVE_PC_SSH_USERNAME']}  password=${SLAVE['SLAVE_PC_SSH_PASSWORD']}
    ...  ELSE  Run Keywords
    ...  Log  Wrong Technology for Snapshot collection!  level=ERROR  console=True
    ...  AND  Fail  Wrong Technology for Snapshot collection!
    ${status}=  Run Keyword And Return Status
    ...  OperatingSystem.File Should Exist  ${folder_path}/${Snapshot_filename}
    Run Keyword If  ${status}
    ...  Log  Snapshot file ${Snapshot_filename} available at ${folder_path}  level=INFO  console=True
    ...  ELSE  Run Keywords
    ...  Log  Snapshot file ${Snapshot_filename} not available at ${folder_path}  level=ERROR  console=True
    ...  AND  Fail  Snapshot file ${Snapshot_filename} not available at ${folder_path}
    [Return]  ${folder_path}  ${Snapshot_filename}

Get and Check LTE Alarms
    [Documentation]  KW used to get and check LTE critical, expected or unexpected alarms.
    ...  It fails if any of below exception case is present:
    ...  - critical alarms are present
    ...  - not all expected alarms are present
    ...  - unexpected alarms are present
    ...  Report errors/warnings for failed cases or report that alarm status is ok.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter            | Man. | Description                                                                   |
    ...  | alias                | No   | alias of ute_infomodel instance (Master/Slave)                                |
    ...  | time                 | No   | How much time to wait for alarms to reach stable state                        |
    ...  | poll_interval        | No   | Poll interval of alarms queries                                               |
    ...  | wait_for_alarm_clear | No   | How much time to wait for unexpected alarms to be cleared                     |
    ...  | expected_alarms      | No   | Alarms which need to be present.Error raised if any of these is missing       |
    ...  | ignored_alarms       | No   | Alarms which can be ignored if present                                        |
    ...  | critical_alarms      | No   | Alarms which must not be present.Error raised if any of these is found        |
    ...  | timeout              | No   | Time to wait for possitive query result                                       |
    ...
    ...  *EXAMPLE*
    ...  Get and Check LTE Alarms  | Master | 10 min | 10 sec | 2 min | expected_alarms=${LTE_EXPECTED_ALARMS} |
    ...  ignored_alarms=${LTE_IGNORED_ALARMS} | critical_alarms=${LTE_CRITICAL_ALARMS}

    [Arguments]  ${alias}=default  ${time}=5 min  ${poll_interval}=30 sec  ${wait_for_alarm_clear}=5 min
    ...  ${expected_alarms}=@{EMPTY}  ${ignored_alarms}=@{EMPTY}  ${critical_alarms}=@{EMPTY}  ${timeout}=30 sec

    Set Test Variable  ${detected critical alarms}  ${FALSE}

    Run Keyword And Return Status  Wait Until Keyword Succeeds  ${time}  ${poll_interval}
    ...  Eval Current LTE Alarms  alias=${alias}  expected_alarms=${expected_alarms}  ignored_alarms=${ignored_alarms}
    ...  critical_alarms=${critical_alarms}  timeout=${timeout}

    Run Keyword If  ${found unexpected alarms}  Run Keyword And Return Status  Wait Until Keyword Succeeds
    ...  ${wait_for_alarm_clear}  ${poll_interval}
    ...  Eval Unexpected LTE Alarms  alias=${alias}  expected_alarms=${expected_alarms}
    ...  ignored_alarms=${ignored_alarms}
    ...  critical_alarms=${critical_alarms}  wait_for_alarm_clear=${wait_for_alarm_clear}  timeout=${timeout}

    Run Keyword If  ${detected critical alarms}  Run Keywords
    ...  Log  Critical alarms present:  level=ERROR  console=True
    ...  AND  AlarmAnalysis.Print Alarms  critical_alarms=${detected critical alarms}
    ...  ELSE IF  ${not found expected alarms}  Run Keywords
    ...  Log  Missing expected alarms:  level=ERROR  console=True
    ...  AND  AlarmAnalysis.Print Alarms  missing_alarms_patterns=${not found expected alarms}
    ...  ELSE IF  ${found unexpected alarms}  Run Keywords
    ...  Log  Unexpected alarms present AFTER alarm clear interval of ${wait_for_alarm_clear}:  level=WARN  console=True
    ...  AND  AlarmAnalysis.Print Alarms  warnings=${found unexpected alarms}
    ...  AND  Log  Snapshot will be triggered at the end of test  console=True
    ...  AND  Set Test Variable  ${SnapshotTriggerEndTest}  YES
    ...  ELSE
    ...  Log  Alarm status is OK.  level=INFO  console=True

    Run Keyword If  ${detected critical alarms} or ${not found expected alarms}
    ...  Fail  Critical alarms present and/or missing expected alarms!

Eval Current LTE Alarms
    [Documentation]    KW used to get and check LTE critical or expected alarms.
    ...  It fails if any of below exception case is present:
    ...  - critical alarms are present
    ...  - not all expected alarms are present
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter            | Man. | Description                                                             |
    ...  | alias                | No   | alias of ute_infomodel instance (Master/Slave)                          |
    ...  | expected_alarms      | No   | Alarms which need to be present.Error raised if any of these is missing |
    ...  | ignored_alarms       | No   | Alarms which can be ignored if present                                  |
    ...  | critical_alarms      | No   | Alarms which must not be present.Error raised if any of these is found  |
    ...  | timeout              | No   | Time to wait for possitive query result                                 |
    ...
    ...  *EXAMPLE*
    ...  Eval Current LTE Alarms  | Master | expected_alarms=${LTE_EXPECTED_ALARMS} |
    ...  ignored_alarms=${LTE_IGNORED_ALARMS} |
    ...  critical_alarms=${LTE_CRITICAL_ALARMS}

    [Arguments]  ${alias}=default  ${expected_alarms}=@{EMPTY}  ${ignored_alarms}=@{EMPTY}  ${critical_alarms}=@{EMPTY}
    ...  ${timeout}=30 sec

    Wait until keyword succeeds  ${timeout}  200 ms  Infomodel Check Connection  ${alias}
    ${active_alarms}=  Infomodel Get All Active Alarms  ${alias}  timeout=${timeout}
    ${found expected alarms}  ${not found expected alarms}  ${found critical alarms}
    ...  ${found ignored alarms}  ${found unexpected alarms}=
    ...  AlarmAnalysis.Get Filtered Alarms  ${active_alarms}  ${expected_alarms}  ${ignored_alarms}  ${critical_alarms}

    Set Test Variable  ${found critical alarms}  ${found critical alarms}
    Set Test Variable  ${not found expected alarms}  ${not found expected alarms}
    Set Test Variable  ${found unexpected alarms}  ${found unexpected alarms}

    Run Keyword If  ${found critical alarms}  Run Keywords
    ...  Log  Critical alarms present:  level=ERROR  console=True
    ...  AND  AlarmAnalysis.Print Alarms  critical_alarms=${found critical alarms}
    ...  AND  Set Test Variable  ${detected critical alarms}  ${found critical alarms}

    Run Keyword If  ${found critical alarms}
    ...  Fail  Critical alarms present. Attempting a new check..
    ...  ELSE IF  ${not found expected alarms}
    ...  Fail  Missing expected alarms. Attempting a new check..

Eval Unexpected LTE Alarms
    [Documentation]    KW used to get and check LTE critical or unexpected alarms.
    ...  It fails if any of below exception case is present:
    ...  - critical alarms are present
    ...  - unexpected alarms are present
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter            | Man. | Description                                                             |
    ...  | alias                | No   | alias of ute_infomodel instance (Master/Slave)                          |
    ...  | expected_alarms      | No   | Alarms which need to be present.Error raised if any of these is missing |
    ...  | ignored_alarms       | No   | Alarms which can be ignored if present                                  |
    ...  | critical_alarms      | No   | Alarms which must not be present.Error raised if any of these is found  |
    ...  | wait_for_alarm_clear | No   | How much time to wait for unexpected alarms to be cleared               |
    ...  | timeout              | No   | Time to wait for possitive query result                                 |
    ...
    ...  *EXAMPLE*
    ...  Eval Unexpected LTE Alarms  | Master | expected_alarms=${LTE_EXPECTED_ALARMS}
    ...  | ignored_alarms=${LTE_IGNORED_ALARMS} |
    ...  critical_alarms=${LTE_CRITICAL_ALARMS}

    [Arguments]  ${alias}=default  ${expected_alarms}=@{EMPTY}  ${ignored_alarms}=@{EMPTY}  ${critical_alarms}=@{EMPTY}
    ...  ${wait_for_alarm_clear}=5 min  ${timeout}=30 sec

    Wait until keyword succeeds  ${timeout}  200 ms  Infomodel Check Connection  ${alias}
    ${active_alarms}=  Infomodel Get All Active Alarms  ${alias}  timeout=${timeout}
    ${found expected alarms}  ${not found expected alarms}  ${found critical alarms}
    ...  ${found ignored alarms}  ${found unexpected alarms}=
    ...  AlarmAnalysis.Get Filtered Alarms  ${active_alarms}  ${expected_alarms}  ${ignored_alarms}  ${critical_alarms}

    Set Test Variable  ${found critical alarms}  ${found critical alarms}
    Set Test Variable  ${found unexpected alarms}  ${found unexpected alarms}

    Run Keyword If  ${found critical alarms}  Run Keywords
    ...  Log  Critical alarms present:  level=ERROR  console=True
    ...  AND  AlarmAnalysis.Print Alarms  critical_alarms=${found critical alarms}
    ...  AND  Set Test Variable  ${detected critical alarms}  ${found critical alarms}

    Run Keyword If  ${found unexpected alarms}  Run Keywords
    ...  Log  Unexpected alarms present DURING alarm clear interval of ${wait_for_alarm_clear}:
    ...  level=WARN  console=True
    ...  AND  AlarmAnalysis.Print Alarms  warnings=${found unexpected alarms}

    Run Keyword If  ${found critical alarms}
    ...  Fail  Critical alarms present. Attempting a new check..
    ...  ELSE IF  ${found unexpected alarms}
    ...  Fail  Unexpected alarms present. Attempting a new check..

Check WCDMA reset behavior when LTE Airscale configuration
    [Documentation]    KW used to check WCDMA reset behavior when LTE Airscale configuration.
    ...  The following behavior should occur:
    ...  If WCDMA is not able to enter holdover, WCDMA should reset.
    ...  If WCDMA is able to enter holdover,
    ...  whether WCDMA would reset depends on the phase error that WCDMA has when LTE is unblocked.
    ...  If phase error on WCDMA side is greater than 200us* after LTE unblock, then WCDMA should reset.
    ...  If phase error on WCDMA side is less than 200us*, WCDMA should not reset.
    ...  As for the moment, the WCDMA reset behavior can not be predicted (phase error on WCDMA side), the KW return is:
    ...  - expected/found reset number if reset behavior number fullfills arguments values
    ...  - fail if reset behavior number doesn't fullfill arguments values
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter               | Man. | Description                                    |
    ...  | expected_reset_number_1 | Yes  | Expected reset number if no WCDMA reset occurs |
    ...  | expected_reset_number_2 | Yes  | Expected reset number if WCDMA reset occurs    |
    ...
    ...  *EXAMPLE*
    ...  Check WCDMA reset behavior when LTE Airscale configuration|expected_reset_number_1=0|expected_reset_number_2=1|

    [Timeout]  10 min
    [Arguments]  ${expected_reset_number_1}  ${expected_reset_number_2}

    ${reset_reason_diff}=  List Diff  ${Master_reset_reason_final}  ${Master_reset_reason_initial}
    ${blackbox_reset_number}=  Get Length  ${reset_reason_diff}
    ${str}= WCDMA Master reset behavior as expected (expected/found reset number:
    Run Keyword If
    ...  ${blackbox_reset_number} == ${expected_reset_number_1} or ${blackbox_reset_number} ==${expected_reset_number_2}
    ...  Log   ${str} ${expected_reset_number_1} or ${expected_reset_number_2}/${blackbox_reset_number})!  console=True
    ...  ELSE  Run Keywords
    ...  Log  ${str} ${expected_reset_number_1} or ${expected_reset_number_2}/${blackbox_reset_number})!
    ...  level=ERROR  console=True
    ...  AND  Fail  ${str} ${expected_reset_number_1} or ${expected_reset_number_2}/${blackbox_reset_number})!

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

    Run keyword if    not ${Master_BTSConf}  Log  Wrong Master BTS configuration!  level=ERROR
    Run Keyword If  '${SLAVE['SLAVE_TECH']}'!='GSM'
    ...  Run keyword if    not ${Slave_BTSConf}  Log  Wrong Slave BTS configuration!  level=ERROR

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

    ${Slave_BTSConf}=  Run Keyword If  '${SLAVE['SLAVE_TECH']}'=='LTE'
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

    Run keyword if    not ${Master_BTSConf}  Log  Wrong Master BTS configuration!  level=ERROR
    Run Keyword If  '${SLAVE['SLAVE_TECH']}'!='GSM'
    ...  Run keyword if    not ${Slave_BTSConf}  Log  Wrong Slave BTS configuration!  level=ERROR

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
    ...  console=True
    Log  ${alias} BTS configuration - configured/running radio modules number: ${SCF_rm_number}/${Siteconf_rm_number}
    ...  console=True
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
    ${SCF_cell_number}  ${SCF_IOT_cell_number}  ${SCF_rm_number}=
    ...  Get SCF Cells And RMs Number SOAM  ${alias}  ${scf_file}

    ${CELLConf}=  Run Keyword And Return Status   Should be equal  ${Runtime_cell_number}  ${SCF_cell_number}
    ${IOTConf}=  Run Keyword And Return Status   Should be equal  ${Runtime_IOT_cell_number}  ${SCF_IOT_cell_number}
    ${RMConf}=  Run Keyword And Return Status   Should be equal  ${Runtime_rm_number}  ${SCF_rm_number}
    ${BTSConf}=  Set Variable If  ${CELLConf} and ${IOTConf} and ${RMConf}  ${TRUE}  ${FALSE}
    Log  ${alias} BTS configuration - configured/running cells number: ${SCF_cell_number}/${Runtime_cell_number}
    ...  console=True
    Log  ${alias} BTS configuration-configured/running  cells number: ${SCF_IOT_cell_number}/${Runtime_IOT_cell_number}
    ...  console=True
    Log  ${alias} BTS configuration - configured/running radio modules number: ${SCF_rm_number}/${Runtime_rm_number}
    ...  console=True
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

    ${rmod_ids}=  taf.sbts.oam.coam.admin.Get Ids For All  RMOD  alias=${alias}
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

    Setup Scfc Parser  scfc=${scf_file}  parser_technology=UNIVERSAL  alias=${alias}

    ${SCF_cell_number}=  Get Cells Count  alias=${alias}
    ${SCF_rm_number}=  Get Radios Count  alias=${alias}

    Teardown Scfc Parser  alias=${alias}

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

    Setup Scfc Parser  scfc=${scf_file}  parser_technology=SBTS  alias=${alias}

    ${SCF_cell_number}=  Get Cells Count  alias=${alias}
    ${SCF_IOT_cell_number}=  Get IOT Cells Count  alias=${alias}
    ${SCF_rm_number}=  Get Radios Count  alias=${alias}

    Teardown Scfc Parser  alias=${alias}

    [Return]  ${SCF_cell_number}  ${SCF_IOT_cell_number}  ${SCF_rm_number}

Download Siteconf Files From All BTS
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${master_siteconf}: <description>
    ...        ${slave_siteconf}: <description>
    ${master_siteconf}=  Download siteconf.xml with timestamp  Master  ${BTSFiles}/Master
    ${slave_siteconf}=  Run Keyword If  '${SLAVE['SLAVE_TECH']}'!='GSM'
    ...  Download siteconf.xml with timestamp  Slave  ${BTSFiles}/Slave

    [Return]  ${master_siteconf}  ${slave_siteconf}

Download SCF Files From All BTS
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${master_scf}: <description>
    ...        ${slave_scf}: <description>
    ${master_scf}=  Download scf.xml with timestamp  Master  ${BTSFiles}/Master
    ${slave_scf}=  Run Keyword If  '${SLAVE['SLAVE_TECH']}'!='GSM'
    ...  Download scf.xml with timestamp  Slave  ${BTSFiles}/Slave

    [Return]  ${master_scf}  ${slave_scf}

Download SCF Files From All BTS SOAM
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${master_scf}: <description>
    ...        ${slave_scf}: <description>
    ${master_scf}=  Run Keyword If  '${MASTER['MASTER_TECH']}'=='WCDMA'
    ...  Download scf.xml with timestamp  Master  ${BTSFiles}/Master
    ...  ELSE IF  '${MASTER['MASTER_TECH']}'in ['NR','LTE','SBTS']
    ...  Admin Collect scf.xml with timestamp  alias=Master  folder_path=${BTSFiles}/Master
    ${slave_scf}=  Run Keyword If  '${SLAVE['SLAVE_TECH']}'!='GSM'
    ...  Admin Collect scf.xml with timestamp  alias=Slave  folder_path=${BTSFiles}/Slave

    [Return]  ${master_scf}  ${slave_scf}

Collect Shared RM log via SM
    [Documentation]
    ...  KW used to collect all RM logs. The logs archives from RM are transferred on Master SM, then on Master VM in
    ...  pre-defined path ${Test Results Dir}/RM_Logs.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter        | Man. | Description                                |
    ...  | path_to_siteconf | No   | Path to siteconf file (use only for WCDMA) |
    ...  | folder_path      | No   | Folder path for RM logs storage            |
    ...
    [Arguments]  ${path_to_siteconf}=${EMPTY}  ${folder_path}=${Test Results Dir}/RM_Logs
    ${status}=  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${folder_path}
    Run keyword if    not ${status}  Create Directory  ${folder_path}

    ${RM_IP_Address_list}=  Get Master Shared RM IpAddress list  ${path_to_siteconf}

    Run Keyword If
    ...  '${MASTER['MASTER_MODULE_TYPE']}' == 'FSME'
    ...  Collect Shared RM log via telnet SM  ${RM_IP_Address_list}  ${folder_path}
    ...  ELSE  Collect Shared RM log via ssh SM  ${RM_IP_Address_list}  ${folder_path}

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
    Run keyword if    not ${status}  Create Directory  ${folder_path}

    ${status}=  Run Keyword And Return Status  BTSSM Upload Pm Counters Bts Files  alias=${alias}
    Run Keyword If  ${status}
    ...  Move File  ${PM_PATH}/${${alias}_PM_ARCHIVE}  ${folder_path}/${${alias}_PM_ARCHIVE}
    ...  ELSE  Run Keywords
    ...  Set Test Variable  ${PM_collect}  ${False}
    ...  AND  Log  ${alias} PM archive collection failed!  level=WARN

    Run Keyword If  ${PM_collect}  Check PM archive transfer  ${alias}  ${folder_path}/${${alias}_PM_ARCHIVE}

Check PM archive transfer
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${alias}: <description>
    ...        ${folder_path}: <description>
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

    ${PM_file_name}=  OperatingSystem.Run  unzip -Z1 ${PM_folder_archive} PM.BTS-*.${VM_UTC_date}*
    Log  PM files generated on ${alias} during last hour:  console=True
    ${PM_file_name}=  Replace String  ${PM_file_name}  \n  ${SPACE}
    Run Keyword If  '${PM_file_name}' != ''  Log  ${PM_file_name}  console=True
    ...  ELSE  Run Keywords
    ...  Set Test Variable  ${PM_check}  ${False}
    ...  AND  Log  No PM files generated on ${alias} during last hour!  level=WARN

    ${PM_archive_size}=  OperatingSystem.Run  du -k ${PM_folder_archive} | cut -f1
    ${PM_archive_size}=  Convert To Integer  ${PM_archive_size}
    Run Keyword If  ${PM_archive_size} > 0  Log  PM archive size (K) for ${alias}: ${PM_archive_size}  console=True
    ...  ELSE  Run Keywords
    ...  Set Test Variable  ${PM_check}  ${False}
    ...  AND  Log  PM archive size (K) for ${alias} is empty!  level=WARN

    ${PM_file_count}=  OperatingSystem.Run  unzip -Z1 ${PM_folder_archive} | wc -l
    Run Keyword If  ${PM_file_count} > 0  Log  Number of PM files inside PM archive for ${alias}: ${PM_file_count}
    ...  console=True
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
    Run Keyword And Return If    '${type}'=='LTE' and not ${has_correction}
    ...  Set test variable  ${SCF_COUNT_${type}}  -1
    ${scf_cells_count}=  Get Cells Count  technology=${type}
    Set test variable  ${SCF_COUNT_${type}}  ${scf_cells_count}

_Check if active software has correction for IoT cells
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${True}: <description>
    Run Keyword And Return If  '${SW_TYPE}'=='SBTS17A'
    ...  Check if ${active SW version} is newer than SBTS17A_ENB_2000_000879_000000
    Run Keyword And Return If  '${SW_TYPE}'=='SBTS18A'
    ...  Check if ${active SW version} is newer than SBTS18A_ENB_0000_000422_000034
    Run Keyword And Return If  '${SW_TYPE}'=='SBTS18SP'
    ...  Check if ${active SW version} is newer than SBTS18SP_ENB_0000_000027_000000
    Return From Keyword If     '${SW_TYPE}'=='SBTS18'    ${False}
    [Return]  ${True}

Check if ${software} is newer than ${given_software}
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${software}: <description>
    ...        ${given_software}: <description>
    ...
    ...    Returns:
    ...        ${is_newer}: <description>
    ${software}=        _Get software version number  ${software}
    ${given_software}=  _Get software version number  ${given_software}
    ${is_newer}=  Evaluate  '${software}'>'${given_software}'
    [Return]    ${is_newer}

_Get software version number
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${software}: <description>
    ...
    ...    Returns:
    ...        ${version_number}: <description>
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

    ${scf_smods}=  Get System Modules
    ${SCF_COUNT_SMOD}=  Get length  ${scf_smods}
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

    ${scf_rmods}=  Get Radios
    ${SCF_COUNT_RMOD}=  Get length  ${scf_rmods}
    Set test variable  ${SCF_COUNT_RMOD}

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

    ${scf_alds}=  Get ALDs
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
    ${scf mods mapping} =  _Extract Modules Product Codes  ${scf modules}  prodCodePlanned  distName

    ${runtime mods product codes}=  Get Dictionary Values  ${runtime mods mapping}
    ${scf mods product codes}=  Get Dictionary Values  ${scf mods mapping}
    Sort List  ${runtime mods product codes}
    Sort List  ${scf mods product codes}

    ${status}=  Run keyword and return status
    ...  Lists Should Be Equal  ${runtime mods product codes}  ${scf mods product codes}
    Run keyword if    not ${status}
    ...   Log  Modules product codes differs between runtime(${runtime mods mapping}) and scf(${scf mods mapping})
    ...  console=${True}
    [Return]  ${status}

_Extract Modules Product Codes
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${modules_obj_list}: <description>
    ...        ${product code key}: <description>
    ...        ${dist name key}: <description>
    ...
    ...    Returns:
    ...        ${mods mapping}: <description>
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
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${command}: <description>
    ...
    ...    Returns:
    ...        ${command_output}: <description>
    [Arguments]  ${command}
    SSHLibrary.Open Connection  host=${SLAVE['SLAVE_PC_IP_ADDRESS']}  port=${SLAVE['SLAVE_PC_SSH_PORT']}
    SSHLibrary.Login  ${SLAVE['SLAVE_PC_SSH_USERNAME']}  ${SLAVE['SLAVE_PC_SSH_PASSWORD']}
    ${command_output}=  SSHLibrary.Execute Command  ${command}
    SSHLibrary.Close Connection
    [Return]  ${command_output}

Reset configuration by config removal from BTS
    [Documentation]
    ...    Removes content of /ffs/run/config/ directory content on BTS and performes reset
    ...    *AUTHOR* sebastian.burniak@nokia.com

    Log    Configuration reset will be done by removal /ffs/run/config directory content    console=${TRUE}
    Run keyword and ignore error            Execute command on SM via SSH   192.168.255.1     rm -rf /ffs/run/config/*
    Run keyword and ignore error            Execute command on SM via SSH   192.168.255.1     reboot
    Wait for target to be not reachable     hostname=192.168.255.1      timeout=30
    Check if Target is stable               ip=192.168.255.1            min_uptime=180

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
    ...             Set Test Norun  ${available space}MB available in ${directory} is less than required ${this much}MB

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
    SSHLibrary.Execute Command
    ...  echo "[$(date -u)] - ${TEST NAME} \n $(df -h) \n" >> ${DF LOG PATH}  return_stdout=False  return_rc=True
    ${exists}  ${message}=  Run Keyword And Ignore Error  SSHLibrary.Directory Should Exist  ${dir_path}
    Run Keyword If  "${exists}" == "FAIL"  Run Keywords  Log  ${message}  level=WARN  AND  Return From Keyword
    ${available space}=  SSHLibrary.Execute Command  df -BM --output=avail ${dir_path} | sed 1d | sed -e 's/M//'
    Run Keyword If  ${available space} < ${space_amount}
    ...  Set Test Norun  ${available space}MB available in ${dir_path} is less than required ${space_amount}MB
    [Teardown]  SSHLibrary.Close Connection

Test case deprecation warning
    [Documentation]
    ...  Log warning about test case deprecation, and add restriction to test.
    ...
    ...  *AUTHOR*  jaroslaw.piszczala@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter    | Mandatory | Description                                           |
    ...  | new_tc_name  | Yes       | Name of new test case                                 |
    ...  | last_tag     | Yes       | Hran version, where this test case will be removed    |
    ...
    ...  *EXAMPLE*
    ...  | Test case deprecation warning | SWM__SBTS_SOAM_rollback_to_SBTS_SOAM  | 33.0  |
    ...  [ WARN ] *TC DEPRECATED!* Please use SWM__SBTS_SOAM_rollback_to_SBTS_SOAM instead of
    ...  SWM__SBTS17_rollback_to_SBTS17.
    ...          Test case will be removed in hran_33.0
    ...
    [Arguments]  ${new_tc_name}  ${last_tag}
    Set Test Restriction
    ...  *TC DEPRECATED!* Please use ${new_tc_name} instead of ${TEST_NAME}. This will be removed in hran_${last_tag}

Variable deprecation warning
    [Documentation]
    ...  Log warning about variable deprecation, and add restriction to test.
    ...
    ...  *AUTHOR*  jaroslaw.piszczala@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Mandatory | Description                                        |
    ...  | old_var   | Yes       | Name of new variable                               |
    ...  | new_var   | Yes       | Name of new test case                              |
    ...  | last_tag  | Yes       | Hran version, where this variable will be removed  |
    ...
    ...  *EXAMPLE*
    ...  | Test case deprecation warning | SCF_ID | COMMISSIONING_PATH | 34.0  |
    ...  [ WARN ] *VARIABLE DEPRECATED!* Please use COMMISSIONING_PATH variable instead of SCF_ID.
    ...           This variable will be removed in hran_34.0
    ...
    [Arguments]  ${old_var}  ${new_var}  ${last_tag}
    Set Test Restriction
    ...  *VARIABLE DEPRECATED!*  use ${new_var} variable than ${old_var}.  variable will removed in hran_${last_tag}

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
    ...  (?i)(wn\\d+_fl\\d+_gf\\d+_)?(?P<product>(SBTS|FL|WN|WBTS|FDSW|TL)[0-9]*)(?P<postfix>[a-zA-Z0-9\.]*)
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
    Setup Scfc Parser  scfc=${lte_scf}  parser_technology=UNIVERSAL  alias=${alias}
    ${scf_IoT_cells_count}=  Get Iot Cells Count  alias=${alias}
    Teardown Scfc Parser  alias=${alias}
    [Return]  ${scf_IoT_cells_count}

Set Service Access Configuration LTE
    [Documentation]
    ...  Set Service Access Configuration feature for LTE: accepted values False or True
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    [Arguments]  ${value}=False  ${alias}=Master  ${techno}=SOAM
    ${alias_connection}=  Convert to Uppercase  ${alias}
    ${FEATCADM_object_found}=  Check Infomodel Object  dist_name=//FEATCADM_CONF_M-1  alias=${alias}
    Run keyword if    not ${FEATCADM_object_found}  Run Keywords
    ...  Log  Feature LTE2647 BTS LINUX System account permissions is not available on running SW!  console=True
    ...  AND  Return From Keyword
    ${BTS_eq}=  Run Keyword If  '${techno}' == 'SOAM'  taf.sbts.oam.coam.admin.Get parameters for all  BTS  alias=${alias}
    ${SCF_dn}=  Run Keyword If  '${techno}' == 'SOAM'  Set Variable  MRBTS-${BTS_eq[0].btsId}/MNL-1/MNLENT-1/FEATCADM-1
    ${IM_dn}=  Set Variable If
    ...  '${${alias_connection}\['${alias_connection}_MODULE_TYPE']}'!='ASIA'
    ...  //FEATCADM_CONF_M-1
    ...  //RUNTIME_VIEW-${${alias_connection}\['${alias_connection}_SUBRACK']}//FEATCADM_CONF_M-1
    ${Feature_status}=  Query infomodel  query=get object ${IM_dn}  alias=${alias}
    ${systemAcctPermEnable_found}=  Run Keyword And Return Status
    ...  Variable Should Exist  ${Feature_status.systemAcctPermEnable}
    Run Keyword If  ${systemAcctPermEnable_found} and '${techno}' == 'Legacy'
    ...  Run Keyword If  '${Feature_status.systemAcctPermEnable}'!='${value}'  Run Keywords
    ...  Log  ${alias} LTE BTS permissions enable: ${Feature_status.systemAcctPermEnable}, need commissioning  ${value}!
    ...  console=True
    ...  AND  Perform Parameter Commissioning  parameter=systemAcctPermEnable:${value.lower()}  alias=${alias}
    ...  AND  Log  ${alias} LTE BTS system account permissions enable: ${value}, successfully commissioned!
    ...  console=True
    Run Keyword If  ${systemAcctPermEnable_found} and '${techno}' == 'SOAM'
    ...  Run Keyword If  '${Feature_status.systemAcctPermEnable}'!='${value}'  Run Keywords
    ...  Log  ${alias} LTE BTS permissions enable: ${Feature_status.systemAcctPermEnable}, commissioning to ${value}!
    ...  console=True
    ...  AND  taf.sbts.oam.coam.admin.Perform Parameter Recommissioning
    ...  dist_name=${SCF_dn}  parameter=systemAcctPermEnable  operation=update  value=${value.lower()}
    ...  skip_parameter_relation_errors=True  should_activate=True  alias=${alias}
    ...  AND  Log  ${alias} LTE BTS system account permissions enable: ${value}, successfully commissioned!  console=True
    Run Keyword If  ${systemAcctPermEnable_found}  Run Keyword If  '${Feature_status.systemAcctPermEnable}'=='${value}'
    ...  Log  ${alias} LTE BTS permissions enable: ${Feature_status.systemAcctPermEnable}, commissioning not needed!
    ...  console=True
    Run keyword if    not ${systemAcctPermEnable_found}
    ...  Log  Feature LTE2647 BTS LINUX System account permissions is not available on running SW!  console=True

Set Service Access Configuration BTS
    [Documentation]
    ...  Set Service Access Configuration feature for BTS: accepted values False or True
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    [Arguments]  ${value}=False  ${alias}=Master  ${techno}=SOAM
    ${alias_connection}=  Convert to Uppercase  ${alias}
    ${FEATCADM_object_found}=  Check Infomodel Object  dist_name=//FEATCADM_CONF_M-1  alias=${alias}
    Run keyword if    not ${FEATCADM_object_found}  Run Keywords
    ...  Log  Feature BTS LINUX System account permissions is not available on running SW!  console=True
    ...  AND  Return From Keyword
    ${BTS_eq}=  Run Keyword If  '${techno}' == 'SOAM'  taf.sbts.oam.coam.admin.Get parameters for all  BTS  alias=${alias}
    ${SCF_dn}=  Run Keyword If  '${techno}' == 'SOAM'  Set Variable  MRBTS-${BTS_eq[0].btsId}/MNL-1/MNLENT-1/FEATCADM-1
    ${IM_dn}=  Set Variable If  '${${alias_connection}\['${alias_connection}_MODULE_TYPE']}'!='ASIA'
    ...  //FEATCADM_CONF_M-1  //RUNTIME_VIEW-${${alias_connection}\['${alias_connection}_SUBRACK']}//FEATCADM_CONF_M-1
    ${Feature_status}=  Query infomodel  query=get object ${IM_dn}  alias=${alias}
    ${systemAcctPermEnable_found}=  Run Keyword And Return Status
    ...  Variable Should Exist  ${Feature_status.systemAcctPermEnable}
    Run Keyword If  ${systemAcctPermEnable_found} and '${techno}' == 'Legacy'
    ...  Run Keyword If  '${Feature_status.systemAcctPermEnable}'!='${value}'  Run Keywords
    ...  Log  ${alias}system account permissions enable:${Feature_status.systemAcctPermEnable}plz commissioning ${value}
    ...  console=True
    ...  AND  Perform Parameter Commissioning  parameter=systemAcctPermEnable:${value.lower()}  alias=${alias}
    ...  AND  Log  ${alias} BTS system account permissions enable: ${value}, successfully commissioned!  console=True
    Run Keyword If  ${systemAcctPermEnable_found} and '${techno}' == 'SOAM'
    ...  Run Keyword If  '${Feature_status.systemAcctPermEnable}'!='${value}'  Run Keywords
    ...  Log  ${alias}system account permissions enable:${Feature_status.systemAcctPermEnable},commissioning to ${value}
    ...  console=True
    ...  AND  taf.sbts.oam.coam.admin.Perform Parameter Recommissioning  dist_name=${SCF_dn}
    ...    parameter=systemAcctPermEnable  operation=update
    ...  value=${value.lower()}  skip_parameter_relation_errors=True  should_activate=True  alias=${alias}
    ...  AND  Log  ${alias} BTS system account permissions enable: ${value}, successfully commissioned!  console=True
    Run Keyword If  ${systemAcctPermEnable_found}  Run Keyword If  '${Feature_status.systemAcctPermEnable}'=='${value}'
    ...  Log
    ...  ${alias}system account permissions enable: ${Feature_status.systemAcctPermEnable}, commissioning not needed!
    ...  console=True
    Run keyword if    not ${systemAcctPermEnable_found}
    ...  Log  Feature BTS LINUX System account permissions is not available on running SW!  console=True

Find path to SW package
    [Documentation]    Short description.
    ${Target SW path}  Get SW file for SWDL  ${Target SW dir}  ${Target SW name}
    Run Keyword If  '${Target SW path}'== ${None}   Fail   msg=
    Set test variable  ${Target SW path}
    Log  Chosen software package is: ${Target SW path}  console=${True}

Collect And Transfer Shared RM logs on Master VM
    [Documentation]
    ...  Collect and transfer RM logs on Master VM when Master SM is not ASIA as below:
    ...  1) directly connection from Master VM to RM: VM <-> RM
    ...  2) via SM connection from Master VM to RM: VM <-> SM <-> RM; this procedure is launched only if first procedure
    ...     is failed
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    Run Keyword If  '${MASTER['MASTER_MODULE_TYPE']}' == 'ASIA'  Run Keywords
    ...  Log  No RM logs collection when Master SM is ASIA!  console=True
    ...  AND  Return From Keyword
    Log  Collect and transfer shared RM logs based on connection VM <-> RM  console=True
    ${collect_RM_status}=  Run Keyword And Return Status  Collect Shared RM log
    ${str1} =	Catenate	Collect and transfer RM logs based on connection VM <-> RM failed,
    ...  try again based on connection VM <-> SM <-> RM
    Run keyword if    not ${collect_RM_status}  Run Keywords
    ...  Log  ${str1}    console=True
    ...  AND  Run Keyword And Return Status  Collect Shared RM log via SM

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

Enable SSH in Independent Execution Context on SBTS SOAM
    [Documentation]
    ...  Check parameters systemAcctPermEnable and actServiceAccountSsh to enable ssh connection
    ...  via default credentials
    ...
    ...  *AUTHOR* jaroslaw.piszczala@nokia.com
    ...
    [Arguments]  ${bts_host}=192.168.255.129  ${bts_port}=443  ${use_ssl}=${TRUE}  ${alias}=ssh

    ${admin_status}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  3 times  5 sec
    ...  taf.sbts.oam.coam.admin.Setup Admin  admin_api_log_dir=${BTS Files}  bts_host=${bts_host}  bts_port=${bts_port}  use_ssl=${use_ssl}
    ...  alias=${alias}
    Run keyword if    not ${admin_status}  Return from keyword  ${False}

    Run keyword and ignore error  taf.sbts.oam.coam.admin.Enable ssh access  alias=${alias}
    ${is_ssh_enabled}=  Check if SSH is enabled
    Return from keyword if  ${is_ssh_enabled}  ${True}

    ${bts_state}=  taf.sbts.oam.coam.admin.Get Mrbts State  timeout=30  alias=${alias}
    Run keyword if  '${bts_state}'=='NotCommissioned'  Return from keyword  ${False}
    Setup Infomodel  address=${bts_host}  port=${bts_port}  use_ssl=${use_ssl}
    ...  admin_api_log_dir=${BTS Files}/  timeout=300  alias=${alias}
    ${infomodel_status}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  3 min  15 sec  Connect Infomodel
    ...  alias=${alias}
    Run keyword if    not ${infomodel_status}  Return from keyword  ${False}

    Run keyword and ignore error  __check systemAcctPermEnable parameter and recommissioning if needed  ${alias}
    Run keyword and ignore error  __check actServiceAccountSsh parameter and recommissioning if needed  ${alias}

    ${is_ssh_enabled}=  Check if SSH is enabled
    Return from keyword if  ${is_ssh_enabled}  ${True}
    [Return]  ${False}
    [Teardown]  Run keywords  taf.sbts.oam.coam.admin.Teardown Admin      alias=${alias}  AND  Teardown Infomodel  alias=${alias}

__check systemAcctPermEnable parameter and recommissioning if needed
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${alias}: <description>
    [Arguments]  ${alias}=ssh
    ${FEATCADM}=  Query infomodel     get object //MNL_A-*/MNLENT_A-*/FEATCADM_A-*  alias=${alias}
    ${object_dist_name}=  Evaluate  "${FEATCADM["dist_name"]}".rsplit('MRBTS_A-')[1].replace('_A','')
    Run keyword if  "${FEATCADM["systemAcctPermEnable"]}"=="True"
    ...  Run keywords
    ...  Log  Parameter systemAcctPermEnable==True, perform recommissioning  console=${True}
    ...  AND
    ...  taf.sbts.oam.coam.admin.Perform Parameter Recommissioning  MRBTS-${object_dist_name}
    ...    systemAcctPermEnable  update  false
    ...  skip_parameter_relation_errors=${True}  alias=${alias}

__check actServiceAccountSsh parameter and recommissioning if needed
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${alias}: <description>
    [Arguments]  ${alias}=ssh
    ${SECADM}=  Query infomodel     get object //MNL_A-*/MNLENT_A-*/SECADM_A-*  alias=${alias}
    ${object_dist_name}=  Evaluate  "${SECADM["dist_name"]}".rsplit('MRBTS_A-')[1].replace('_A','')
    Run keyword if  "${SECADM["actServiceAccountSsh"]}"=="False"
    ...  Run keywords
    ...  Log  Parameter actServiceAccountSsh==False, perform recommissioning  console=${True}
    ...  AND
    ...  taf.sbts.oam.coam.admin.Perform Parameter Recommissioning  MRBTS-${object_dist_name}
    ...    actServiceAccountSsh  update  true
    ...  skip_parameter_relation_errors=${True}  alias=${alias}

Copy File to Remote Host via SSH
    [Documentation]
    ...  KW for copying files from a machine to another
    ...  can be any host, VM , system module, RFM.
    ...
    ...  *AUTHOR*
    ...  emanuel.szijj@nokia.com
    [Arguments]  ${ip}=${SLAVE['SLAVE_PC_IP_ADDRESS']}  ${user}=ute  ${pass}=ute
    ...  ${local_file_path}=/tmp/FileDirectory.xml  ${remote_file_path}=/tmp/FileDirectory.xml
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
    ${IM_status_exists}=  Run Keyword And Return Status  Variable Should Exist  ${IM_library}
    Run Keyword If  ${IM_status_exists}
    ...  Set Library search order  ${IM_library}  XML
    ...  ELSE  Set Library search order  XML

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

    taf.sbts.oam.coam.admin.Collect SCF  ${Test Files}/SCF_for_BCF_IPs_check.xml
    ${scf_xml}=  Parse xml  ${Test Files}/SCF_for_BCF_IPs_check.xml
    ${bcf_mplane_dist_name}=  Get element text  ${scf_xml}  .//*[@name='mPlaneLocalIpAddressDN']
    ${common_dist}=  Fetch from left  ${bcf_mplane_dist_name}  IPADDRESSV4
    ${bcf_ips}=  Get elements texts  ${scf_xml}  .//*[contains(@distName, "${common_dist}")]/*[@name='localIpAddr']
    [Return]  ${bcf_ips}

Get Service Access Configuration WCDMA
    [Documentation]
    ...  Get Service Access Configuration status on WCDMA. Possible outputs: true, false, None
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  | Parameter    | Man. | Description                                        |
    ...  | scf_file     | Yes  | path to BTS scf file |
	...
	...  *RETURN*
    ...  true, false or None
    [Arguments]    ${scf_file}
    ${scf_file_parsed}=  Parse xml  ${scf_file}
    ${sysActPermEnable_exists}=  Run Keyword And Return Status
    ...  Element Should Exist     ${scf_file_parsed}    .//managedObject[@class="MRBTS"]/p[@name="systemAcctPermEnable"]
    Return From Keyword If  not ${sysActPermEnable_exists}  ${None}
    ${wcdma_sysActPermEnable}=    Get Element Text
    ...  ${scf_file_parsed}    .//managedObject[@class="MRBTS"]/p[@name="systemAcctPermEnable"]
    [Return]    ${wcdma_sysActPermEnable}

Set Service Access Configuration WCDMA
    [Documentation]
    ...  Set Service Access Configuration feature for WCDMA: accepted values false or true
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    [Arguments]  ${value}=false  ${scf_file}=None
    ${wcdma_sysActPermEnableValue}=  Get Service Access Configuration WCDMA  scf_file=${scf_file}
    ${str1} =	Catenate	Feature RAN3459: WCDMA Parameter systemAcctPermEnable not present in
    ...  curently installed SW! No action will be taken!
    Run Keyword If  '${wcdma_sysActPermEnableValue}' == '${None}'  Run Keywords
    ...  Log    ${str1}   console=True
    ...  AND  Return From Keyword
    ${wcdma_sysActPermEnableValue}=   Convert To Lowercase   ${wcdma_sysActPermEnableValue}
    ${value}=  Convert To Lowercase   ${value}
    Run Keyword If  '${wcdma_sysActPermEnableValue}' != '${value}'  Run Keywords
    ...  ute_btssm.Perform Parameter Commissioning  parameter=systemAcctPermEnable:${value}  alias=Master
    ...  AND  Log
    ...  Feature RAN3459:WCDMA Parameter systemAcctPermEnable changed from ${wcdma_sysActPermEnableValue} to ${value}!
    ...  console=True

Count WCDMA alarms number
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${RM_connectionList}: <description>
    ...        ${RM_CELL_list}: <description>
    ...        ${CELL_RM_list}: <description>
    [Arguments]  ${RM_connectionList}  ${RM_CELL_list}  ${CELL_RM_list}
    FOR  ${RM_CELL_details}  IN  @{RM_CELL_list}
        Run Keyword If  '${RM_CELL_details[0]}' == '${RM_connectionList}'
        ...  Get WCDMA cells alarms number  ${RM_CELL_details[1]}
        Run Keyword If  '${RM_CELL_details[0]}' == '${RM_connectionList}'
        ...  Get WCDMA mimo cells alarms number  ${RM_CELL_details[1]}  ${CELL_RM_list}
    END

Get WCDMA cells alarms number
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${RM_CELL}: <description>
    [Arguments]  ${RM_CELL}
    ${RM_cells_count_alarms}  Get Length  ${RM_CELL}
    Set Test Variable  ${RM_cells_count_alarms}  ${RM_cells_count_alarms}

Get WCDMA mimo cells alarms number
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${RM_CELL}: <description>
    ...        ${CELL_RM_list}: <description>
    [Arguments]  ${RM_CELL}  ${CELL_RM_list}
    FOR  ${CELL_RM_details}  IN  @{CELL_RM_list}
        ${map}=  Run Keyword And Return Status  List Should Contain Value  ${RM_CELL}  ${CELL_RM_details[0]}
        Run Keyword If  '${map}' == 'True' and '${CELL_RM_details[1]}' != 'SingleTX' and len(@{CELL_RM_details[2]}) > 1
        ...  Add mimo cells alarms to list  ${RM_cells_count_alarms_mimo}  1
        ...  ELSE
        ...  Add mimo cells alarms to list  ${RM_cells_count_alarms_mimo}  0
    END
    Set Test Variable  ${RM_cells_count_alarms_mimo}  ${RM_cells_count_alarms_mimo}

Count LTE alarms number
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${RM_connectionList}: <description>
    ...        ${RM_CELL_list}: <description>
    ...        ${CELL_RM_list}: <description>
    ...        ${CELL_IOT_dict}: <description>
    ...        ${alias}: <description>
    [Arguments]  ${RM_connectionList}  ${RM_CELL_list}  ${CELL_RM_list}  ${CELL_IOT_dict}  ${alias}=default
    FOR  ${RM_CELL_details}  IN  @{RM_CELL_list}
        Run Keyword If  '${RM_CELL_details[0]}' == '${RM_connectionList}'
        ...  Get LTE cells alarms number  ${RM_CELL_details[1]}  ${CELL_IOT_dict}
        Run Keyword If  '${RM_CELL_details[0]}' == '${RM_connectionList}'
        ...  Get LTE mimo cells alarms number
        ...  ${RM_CELL_details[0]}  ${RM_CELL_details[1]}  ${CELL_RM_list}  ${CELL_IOT_dict}  ${alias}
    END

Get LTE cells alarms number
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${RM_CELL}: <description>
    ...        ${CELL_IOT_dict}: <description>
    [Arguments]  ${RM_CELL}  ${CELL_IOT_dict}
    ${RM_cells_count_alarms}  Get Length  ${RM_CELL}
    FOR  ${CELL_globalCellId}  IN  @{RM_CELL}
        ${status}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${CELL_IOT_dict}  ${CELL_globalCellId}
        ${value}=  Run Keyword If
        ...  ${status} and ${IOT_MIMO_alarm_check}  Get From Dictionary  ${CELL_IOT_dict}  ${CELL_globalCellId}
        ...  ELSE  Set Variable  None
        ${RM_cells_count_alarms}=  Run Keyword If  '${value}' != 'None'  Evaluate  ${RM_cells_count_alarms} + 1
        ...  ELSE  Evaluate  ${RM_cells_count_alarms} + 0
    END
    Set Test Variable  ${RM_cells_count_alarms}  ${RM_cells_count_alarms}

Get LTE mimo cells alarms number
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${RM_DN}: <description>
    ...        ${RM_CELL}: <description>
    ...        ${CELL_RM_list}: <description>
    ...        ${CELL_IOT_dict}: <description>
    ...        ${alias}: <description>
    [Arguments]  ${RM_DN}  ${RM_CELL}  ${CELL_RM_list}  ${CELL_IOT_dict}  ${alias}=default
    FOR  ${CELL_RM_details}  IN  @{CELL_RM_list}
        ${Cell_Tx_count}  ${Cell_Rx_count}=  Count Cell Tx Rx Total Number  ${CELL_RM_details[0]}  ${CELL_RM_list}
        ${Cell_RM_Tx_count}  ${Cell_RM_Rx_count}=  Count Cell-RM Tx Rx Number
        ...  ${CELL_RM_details[0]}  ${RM_DN}  ${CELL_RM_list}
        ${Cell_Tx_active_count}=  Evaluate  ${Cell_Tx_count} - ${Cell_RM_Tx_count}
        ${Cell_Rx_active_count}=  Evaluate  ${Cell_Rx_count} - ${Cell_RM_Rx_count}
        ${map}=  Run Keyword And Return Status  List Should Contain Value  ${RM_CELL}  ${CELL_RM_details[0]}
        ${status}=  Run Keyword And Return Status
        ...  Dictionary Should Contain Key  ${CELL_IOT_dict}  ${CELL_RM_details[0]}
        ${value}=  Run Keyword If  ${status}  Get From Dictionary  ${CELL_IOT_dict}  ${CELL_RM_details[0]}
        ...  ELSE  Set Variable  None
        ${value}=  Set Variable If  ${IOT_MIMO_alarm_check}  ${value}  None
        ${Cell_label}=  Fetch From Right  ${CELL_RM_details[0]}  /
        ${alias}=  Run Keyword If  '${alias}'=='default'  Set Variable If
        ...  '${MASTER['MASTER_TECH']}' in ['LTE','SBTS']  Master  Slave
        ...  ELSE  Set Variable  ${alias}
        ${Cell_states}=  Run Keyword If  '${map}' == 'True'
        ...  taf.sbts.oam.coam.admin.Get Parameters For  LNCEL  ${CELL_RM_details[0]}  alias=${alias}
        Run Keyword If  '${map}' == 'True'
        ...  Log  ${Cell_label} availabilityStatus: ${Cell_states['availabilityStatus']}  console=True
        Run Keyword If  '${map}' == 'True' and '${value}' != 'None'  Run Keywords
        ...  Calculate MIMO Cells Alarms
        ...  ${Cell_Tx_active_count}  ${Cell_Rx_active_count}  ${Cell_Tx_count}  ${Cell_Rx_count}
        ...  ${CELL_RM_details[1]}  ${CELL_RM_details[2]}  ${CELL_RM_details[3]}  ${CELL_RM_details[4]}
        ...  ${CELL_RM_details[0]}  ${Cell_states['availabilityStatus']}  ${alias}
        ...  AND  Add mimo cells alarms to list  ${RM_cells_count_alarms_mimo}  ${RM_Cell_count_alarm_mimo}
        ...  AND  Add mimo cells alarms to list  ${RM_cells_count_alarms_mimo}  ${RM_Cell_count_alarm_mimo}
        ...  ELSE IF  '${map}' == 'True' and '${value}' == 'None'  Run Keywords
        ...  Calculate MIMO Cells Alarms  ${Cell_Tx_active_count}  ${Cell_Rx_active_count}  ${Cell_Tx_count}
        ...  ${Cell_Rx_count}  ${CELL_RM_details[1]}  ${CELL_RM_details[2]}  ${CELL_RM_details[3]}
        ...  ${CELL_RM_details[4]}  ${CELL_RM_details[0]}  ${Cell_states['availabilityStatus']}  ${alias}
        ...  AND  Add mimo cells alarms to list  ${RM_cells_count_alarms_mimo}  ${RM_Cell_count_alarm_mimo}
    END
    Set Test Variable  ${RM_cells_count_alarms_mimo}  ${RM_cells_count_alarms_mimo}

Count Cell Tx Rx Total Number
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${Cell_DN}: <description>
    ...        ${CELL_RM_list}: <description>
    ...
    ...    Returns:
    ...        ${Cell_Tx_count}: <description>
    ...        ${Cell_Rx_count}: <description>
    [Arguments]  ${Cell_DN}  ${CELL_RM_list}
    FOR  ${item}  IN  @{CELL_RM_list}
        ${Cell_Tx_count}  ${Cell_Rx_count}=  Run Keyword If  '${item[0]}' == '${Cell_DN}'
        ...  Count RM Tx Rx Total Number  ${item[5]}
        Exit For Loop If  '${item[0]}' == '${Cell_DN}'
    END
    [Return]  ${Cell_Tx_count}  ${Cell_Rx_count}

Count RM Tx Rx Total Number
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${RM_list}: <description>
    ...
    ...    Returns:
    ...        ${Cell_Tx_count}: <description>
    ...        ${Cell_Rx_count}: <description>
    [Arguments]  ${RM_list}
    Set Test Variable  ${Cell_Tx_count}  0
    Set Test Variable  ${Cell_Rx_count}  0
    FOR  ${item}  IN  @{RM_list}
        ${Tx_count}=  Get Count  ${item[1]}  TX
        ${Rx_count}=  Get Count  ${item[1]}  RX
        ${Cell_Tx_count}=  Evaluate  ${Cell_Tx_count} + ${Tx_count}
        ${Cell_Rx_count}=  Evaluate  ${Cell_Rx_count} + ${Rx_count}
    END
    [Return]  ${Cell_Tx_count}  ${Cell_Rx_count}

Count Cell-RM Tx Rx Number
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${Cell_DN}: <description>
    ...        ${RM_DN}: <description>
    ...        ${CELL_RM_list}: <description>
    ...
    ...    Returns:
    ...        ${Cell_RM_Tx_count}: <description>
    ...        ${Cell_RM_Rx_count}: <description>
    [Arguments]  ${Cell_DN}  ${RM_DN}  ${CELL_RM_list}
    FOR  ${item}  IN  @{CELL_RM_list}
        ${Cell_RM_Tx_count}  ${Cell_RM_Rx_count}=  Run Keyword If  '${item[0]}' == '${Cell_DN}'
        ...  Count RM Tx Rx Number  ${RM_DN}  ${item[5]}
        Exit For Loop If  '${item[0]}' == '${Cell_DN}'
    END
    [Return]  ${Cell_RM_Tx_count}  ${Cell_RM_Rx_count}

Count RM Tx Rx Number
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${RM_DN}: <description>
    ...        ${RM_list}: <description>
    ...
    ...    Returns:
    ...        ${Cell_RM_Tx_count}: <description>
    ...        ${Cell_RM_Rx_count}: <description>
    [Arguments]  ${RM_DN}  ${RM_list}
    FOR  ${item}  IN  @{RM_list}
        Set Test Variable  ${Cell_RM_Tx_count}  0
        Set Test Variable  ${Cell_RM_Rx_count}  0
        ${Tx_count}=  Run Keyword If  '${item[0]}' == '${RM_DN}'  Get Count  ${item[1]}  TX
        ${Tx_is_none}=	Run Keyword And Return Status	Should Be Equal	${Tx_count}	 ${None}
		${Tx_count}=  Set Variable If  '${Tx_is_none}' == 'True'  0  ${Tx_count}
        ${Rx_count}=  Run Keyword If  '${item[0]}' == '${RM_DN}'  Get Count  ${item[1]}  RX
        ${Rx_is_none}=	Run Keyword And Return Status	Should Be Equal	${Rx_count}	 ${None}
		${Rx_count}=  Set Variable If  '${Rx_is_none}' == 'True'  0  ${Rx_count}
        ${Cell_RM_Tx_count}=  Run Keyword If  '${item[0]}' == '${RM_DN}'  Evaluate  ${Cell_RM_Tx_count} + ${Tx_count}
		${Cell_RM_Tx_is_none}=	Run Keyword And Return Status	Should Be Equal	${Cell_RM_Tx_count}	 ${None}
		${Cell_RM_Tx_count}=  Set Variable If  '${Cell_RM_Tx_is_none}' == 'True'  0  ${Cell_RM_Tx_count}
        ${Cell_RM_Rx_count}=  Run Keyword If  '${item[0]}' == '${RM_DN}'  Evaluate  ${Cell_RM_Rx_count} + ${Rx_count}
        ${Cell_RM_Rx_is_none}=	Run Keyword And Return Status	Should Be Equal	${Cell_RM_Rx_count}	 ${None}
		${Cell_RM_Rx_count}=  Set Variable If  '${Cell_RM_Rx_is_none}' == 'True'  0  ${Cell_RM_Rx_count}
        Exit For Loop If  '${item[0]}' == '${RM_DN}'
    END
    [Return]  ${Cell_RM_Tx_count}  ${Cell_RM_Rx_count}

Calculate MIMO Cells Alarms
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${Cell_Tx_active_count}: <description>
    ...        ${Cell_Rx_active_count}: <description>
    ...        ${Cell_Tx_count}: <description>
    ...        ${Cell_Rx_count}: <description>
    ...        ${dlMimoMode}: <description>
    ...        ${syncSigTxMod}: <description>
    ...        ${actOtdoa}: <description>
    ...        ${actPrsTxDiv}: <description>
    ...        ${Cell_DN}: <description>
    ...        ${Cell_availabilityStatus}: <description>
    ...        ${alias}: <description>
    [Arguments]  ${Cell_Tx_active_count}  ${Cell_Rx_active_count}  ${Cell_Tx_count}  ${Cell_Rx_count}  ${dlMimoMode}
    ...  ${syncSigTxMod}  ${actOtdoa}  ${actPrsTxDiv}  ${Cell_DN}  ${Cell_availabilityStatus}  ${alias}
    ${bool_1}=  Convert To Boolean    ${Cell_Tx_active_count} == ${Cell_Tx_count}
    ${bool_2}=  Convert To Boolean    ${Cell_Rx_active_count} != ${Cell_Rx_count}
    ${bool_3}=  Convert To Boolean    ${Cell_Rx_active_count} >= 1
    ${bool_4}=  Convert To Boolean    '${dlMimoMode}' != 'SingleTX'
    ${bool_5}=  Convert To Boolean    ${Cell_Tx_count} != 8
    ${bool_6}=  Convert To Boolean    ${Cell_Tx_count} != 4
    ${bool_7}=  Convert To Boolean    ${Cell_Tx_active_count} != ${Cell_Tx_count}
    ${bool_8}=  Convert To Boolean    ${Cell_Tx_active_count} >= 1
    ${bool_9}=  Convert To Boolean    '${txPathFailureMode}' == 'keepCellInService'
    ${bool_10}=  Convert To Boolean    '${syncSigTxMod}' == 'TxDiv'
    ${bool_11}=  Convert To Boolean    '${actOtdoa}' == 'True'
    ${bool_12}=  Convert To Boolean    '${actPrsTxDiv}' == 'True'
     ${bool_13}=  Convert To Boolean
    ...  ${bool_5} and  ${bool_6} and ${bool_7} and ${bool_8}and ${bool_3} and ${bool_4} and ${bool_9}
    ${bool_14}=  Convert To Boolean
    ...  ${bool_10} and ${bool_11} and ${bool_12}
    ${bool_15}=  Convert To Boolean     ${Cell_Tx_active_count} >= 3
    ${bool_16}=  Convert To Boolean    ${Cell_Tx_count} == 4
    ${bool_17}=  Convert To Boolean
    ...   ${bool_16} and ${bool_7}  and ${bool_4} and ${bool_9}
    ${bool_18}=  Convert To Boolean    '${actPrsTxDiv}' == 'False'
    ${bool_19}=  Convert To Boolean
    ...   ${bool_6} and ${bool_7}  and ${bool_8} and ${bool_9} and ${bool_3}

    Run Keyword If
    ...   ${bool_1} and ${bool_2} and  ${bool_3} and  ${bool_4}
    ...  Run Keywords  Set Test Variable  ${RM_Cell_count_alarm_mimo}  1
    ...  AND  taf.sbts.oam.coam.admin.Assert  LNCEL  ${Cell_DN}  availabilityStatus=Degraded  alias=${alias}

    Run Keyword If  ${bool_1} and ${bool_2} and ${bool_3} and '${dlMimoMode}' == 'SingleTX'
    ...  Run Keywords  Set Test Variable  ${RM_Cell_count_alarm_mimo}  0
    ...  AND  taf.sbts.oam.coam.admin.Assert  LNCEL  ${Cell_DN}  availabilityStatus=Degraded  alias=${alias}

    Run Keyword If  ${Cell_Tx_count} == 8 and ${Cell_Tx_active_count} != ${Cell_Tx_count}
    ...  Run Keywords  Set Test Variable  ${RM_Cell_count_alarm_mimo}  0
    ...  AND  taf.sbts.oam.coam.admin.Assert  LNCEL  ${Cell_DN}  availabilityStatus=Failed  alias=${alias}
    Run Keyword If   ${bool_13}  and  ${bool_14}
    ...  Run Keywords  Set Test Variable  ${RM_Cell_count_alarm_mimo}  1
    ...  AND  taf.sbts.oam.coam.admin.Assert  LNCEL  ${Cell_DN}  availabilityStatus=Degraded  alias=${alias}
    Run Keyword If  ${bool_13} and ${bool_10} and ${bool_11} and not ${bool_12}
    ...  Run Keywords  Set Test Variable  ${RM_Cell_count_alarm_mimo}  0
    ...  AND  taf.sbts.oam.coam.admin.Assert  LNCEL  ${Cell_DN}  availabilityStatus=Failed  alias=${alias}
    Run Keyword If  ${bool_13} and ${bool_10} and '${actOtdoa}' == 'False'
    ...  Run Keywords  Set Test Variable  ${RM_Cell_count_alarm_mimo}  1
    ...  AND  taf.sbts.oam.coam.admin.Assert  LNCEL  ${Cell_DN}  availabilityStatus=Degraded  alias=${alias}
    Run Keyword If
    ...  ${bool_17} and ${bool_15}  and ${bool_10} and ${bool_11} and ${bool_12}
    ...  Run Keywords  Set Test Variable  ${RM_Cell_count_alarm_mimo}  1
    ...  AND  taf.sbts.oam.coam.admin.Assert  LNCEL  ${Cell_DN}  availabilityStatus=Degraded  alias=${alias}
    Run Keyword If
    ...  ${bool_17}  and ${bool_15} and ${bool_3} and ${bool_10} and ${bool_11} and ${bool_18}
    ...  Run Keywords  Set Test Variable  ${RM_Cell_count_alarm_mimo}  0
    ...  AND  taf.sbts.oam.coam.admin.Assert  LNCEL  ${Cell_DN}  availabilityStatus=Failed  alias=alias=${alias}

    Run Keyword If  ${bool_17}  and ${bool_15} and ${bool_3} and ${bool_10} and '${actOtdoa}' == 'False'
    ...  Run Keywords  Set Test Variable  ${RM_Cell_count_alarm_mimo}  1
    ...  AND  taf.sbts.oam.coam.admin.Assert  LNCEL  ${Cell_DN}  availabilityStatus=Degraded  alias=${alias}

    Run Keyword If ${bool_17} and ${Cell_Tx_active_count} < 3 and ${bool_3}
    ...  Run Keywords  Set Test Variable  ${RM_Cell_count_alarm_mimo}  0
    ...  AND  taf.sbts.oam.coam.admin.Assert  LNCEL  ${Cell_DN}  availabilityStatus=Failed  alias=${alias}

    Run Keyword If  ${bool_17} and ${bool_15} and ${bool_3} and '${syncSigTxMod}' == 'SingleTX'
    ...  Run Keyword If  '${Cell_availabilityStatus}' == 'Degraded'  Set Test Variable  ${RM_Cell_count_alarm_mimo}  1
    Run Keyword If  ${bool_17} and ${bool_15} and ${bool_3} and '${syncSigTxMod}' == 'SingleTX'
    ...  Run Keyword If  '${Cell_availabilityStatus}' == 'Failed'  Set Test Variable  ${RM_Cell_count_alarm_mimo}  0

    Run Keyword If  ${Cell_Tx_count} != 8 and ${bool_19} and '${dlMimoMode}' == 'SingleTX'
    ...  Run Keyword If  '${Cell_availabilityStatus}' == 'Degraded'  Set Test Variable  ${RM_Cell_count_alarm_mimo}  1
    Run Keyword If  ${Cell_Tx_count} != 8 and ${bool_19}  and '${dlMimoMode}' == 'SingleTX'
    ...  Run Keyword If  '${Cell_availabilityStatus}' == 'Failed'  Set Test Variable  ${RM_Cell_count_alarm_mimo}  0

    Run Keyword If  ${bool_7} and ${Cell_Tx_active_count} >= 1 and ${bool_3} and '${txPathFailureMode}' == 'disableCell'
    ...  Run Keywords  Set Test Variable  ${RM_Cell_count_alarm_mimo}  1
    ...  AND  taf.sbts.oam.coam.admin.Assert  LNCEL  ${Cell_DN}  availabilityStatus=Degraded  alias=${alias}

    Run Keyword If  ${Cell_Rx_active_count} == 0  Run Keywords  Set Test Variable  ${RM_Cell_count_alarm_mimo}  0
    ...  AND  taf.sbts.oam.coam.admin.Assert  LNCEL  ${Cell_DN}  availabilityStatus=Failed  alias=${alias}

    Run Keyword If  ${Cell_Tx_active_count} == 0  Run Keywords  Set Test Variable  ${RM_Cell_count_alarm_mimo}  0
    ...  AND  taf.sbts.oam.coam.admin.Assert  LNCEL  ${Cell_DN}  availabilityStatus=Failed  alias=${alias}

Add mimo cells alarms to list
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${RM_cells_count_alarms_mimo}: <description>
    ...        ${value}: <description>
    [Arguments]  ${RM_cells_count_alarms_mimo}  ${value}
    ${RM_cells_count_alarms_mimo}=  Evaluate  ${RM_cells_count_alarms_mimo} + ${value}
    Set Test Variable  ${RM_cells_count_alarms_mimo}

Create Tunnel and Admin connection
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${REMOTE_ENB_IP_ADDRESS}: <description>
    ...        ${REMOTE_ENB_ADMIN_PORT}: <description>
    ...        ${REMOTE_VM_IP_ADDRESS}: <description>
    ...        ${REMOTE_VM_SSH_USERNAME}: <description>
    ...        ${REMOTE_VM_SSH_PASSWORD}: <description>
    ...        ${LOCAL_BIND_IP_ADDRESS}: <description>
    ...        ${LOCAL_BIND_PORT}: <description>
    ...        ${adminalias}: <description>
    ...        ${tunnelalias}: <description>
    [Arguments]  ${REMOTE_ENB_IP_ADDRESS}=${SLAVE['SLAVE_IM_IP_ADDRESS']}  ${REMOTE_ENB_ADMIN_PORT}=443
    ...  ${REMOTE_VM_IP_ADDRESS}=${SLAVE['SLAVE_PC_IP_ADDRESS']}
    ...  ${REMOTE_VM_SSH_USERNAME}=${SLAVE['SLAVE_PC_SSH_USERNAME']}
    ...  ${REMOTE_VM_SSH_PASSWORD}=${SLAVE['SLAVE_PC_SSH_PASSWORD']}
    ...  ${LOCAL_BIND_IP_ADDRESS}=${MASTER['MASTER_UDP_IP_ADDRESS']}  ${LOCAL_BIND_PORT}=8787
    ...  ${adminalias}=RemoteReset
    ...  ${tunnelalias}=SshTunnel
    Log    ${tunnelalias}
    Log  Creating ssh tunnel using alias=${adminalias}  console=True
    SSHlibrary.Open Connection  ${REMOTE_VM_IP_ADDRESS}
    SSHLibrary.Login  ${REMOTE_VM_SSH_USERNAME}  ${REMOTE_VM_SSH_PASSWORD}
    SSHLibrary.Create local SSH tunnel  local_port=${LOCAL_BIND_PORT}  remote_host=${REMOTE_ENB_IP_ADDRESS}
    ...  remote_port=${REMOTE_ENB_ADMIN_PORT}  bind_address=${LOCAL_BIND_IP_ADDRESS}
    Log  Setup and connect admin via SSH tunnel using alias=${adminalias}  console=True
    Setup ADMIN  alias=${adminalias}  bts_host=${LOCAL_BIND_IP_ADDRESS}  bts_port=${LOCAL_BIND_PORT}  timeout=60s

Close Admin connection and Tunnel
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${adminalias}: <description>
    ...        ${tunnelalias}: <description>
    [Arguments]  ${adminalias}=RemoteReset  ${tunnelalias}=SshTunnel
    Log  Close admin using alias=${adminalias}  console=True
    Run keyword and return status  taf.sbts.oam.coam.admin.Teardown Admin  alias=${adminalias}
    Log  Closing ssh tunnel using alias=${tunnelalias}  console=True
    SSHLibrary.Close Connection

Check if all RMs detected
    [Documentation]
    ...  Check if all Radio Modules are detected.
    ...  Please be aware that in case of two System Modules configuration (3+3, 4+4, 4+3)
    ...  there is a need to SMs be synchronized
    ...
    ...  *AUTHOR*
    ...  sebastian.burniak@nokia.com
    ...
    ...  | Parameter      | Man. | Default value | Description                                        |
	...
	...  *RETURN*
    ...  None
    Get SCF count of RMODs

    ${modules_status}=    Verify modules    RMOD
    Run keyword if    not ${modules_status}    Fail

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
    ${scf_RMODS}=  Get Radios
    ${scf_rmods_count}=  Get length  ${scf_RMODS}
    Set test variable  ${SCF_COUNT_RMOD}    ${scf_rmods_count}

Remove and send new SSH key
    [Documentation]
    ...  *AUTHOR* wojciech.sikora@nokia.com
    Log  Remove SSH key  console=${TRUE}
    ${status}  ${msg}  Run Keyword And Ignore Error
    ...  Run  ssh-keygen -f "/home/ute/.ssh/known_hosts" -R ${SMOD1['TRS_IP']}
    Log  Send new SSH key  console=${TRUE}
    ${status}  ${msg}  Run Keyword And Ignore Error
    ...  Run  sshpass -p ${SMOD1['PASSWORD']} ssh-copy-id -i ~/.ssh/toor4nsn/id_rsa.pub toor4nsn@${SMOD1['TRS_IP']}

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
    ...  | BTS       | No   | BTS object, by default SBTS (SyVe)                                 |
    ...
    [Arguments]  ${value}=False  ${alias}=default  ${BTS}=SBTS

    Set Test Variable  ${value}  ${value.lower()}
    Run Keyword If  '${value}' != 'false' and '${value}' != 'true'
    ...  Fail  No valid value for Ethernet port security set (False or True)!  level=ERROR
    ${BTS_scf}=  Admin Collect scf.xml with timestamp  alias=${alias}
    ${BTS_scf_xml}=  Parse xml  ${BTS_scf}
    ${ethernetPortSecurity_exist}=  Run Keyword And Return Status
    ...  Element Should Exist  ${BTS_scf_xml}
    ...  .//managedObject[@class="com.nokia.srbts.mnl:SECADM"]/p[@name="ethernetPortSecurityEnabled"]
    Run keyword if    not ${ethernetPortSecurity_exist}  Run Keywords
    ...  Log  Feature Ethernet Port Security is not available on running SW!  console=True
    ...  AND  Return From Keyword
    ${ethernetPortSecurity_value}=  Get Element Text  ${BTS_scf_xml}
    ...  .//managedObject[@class="com.nokia.srbts.mnl:SECADM"]/p[@name="ethernetPortSecurityEnabled"]
    ${ethernetPortSecurity_status}=  Set Variable If  '${ethernetPortSecurity_value}' == 'false'  Disabled  Enabled
    ${MO_items}=  Get Element Attributes  ${BTS_scf_xml}  .//*managedObject[@class="com.nokia.srbts.mnl:SECADM"]
    ${SCF_dn}=  Set Variable  ${MO_items['distName']}
    Run Keyword If  '${ethernetPortSecurity_value}'!='${value}'  Run Keywords
    ...  Log  ${alias} ${BTS} Ethernet port security status: ${ethernetPortSecurity_status}, need commissioning!
    ...  console=True
    ...  AND  taf.sbts.oam.coam.admin.Perform Parameter Recommissioning  dist_name=${SCF_dn}
    ...    parameter=ethernetPortSecurityEnabled
    ...  operation=update  value=${value.lower()}  skip_parameter_relation_errors=True  should_activate=True
    ...  alias=${alias}
    ...  AND  Log  Parameter ethernetPortSecurityEnabled=${value} successfully commissioned!  console=True
    ...  ELSE  Log
    ...  ${alias} ${BTS} Ethernet port security status: ${ethernetPortSecurity_status}, commissioning not needed!
    ...  console=True
    [Teardown]  Remove File  ${BTS_scf}

Get KPI related test line variables
    [Documentation]
    ...  Get Testline variables for KPI purpose
    ...
    ...  | **Author:** jaroslaw.piszczala@nokia.com
    ...  | **Maintainer:** mnich@nokia.com
    ...  | **Released with version:** 60.0
    ...
    Set test variable     ${KPI_TEST_LINE_VARIABLES}  ${False}
#    ${tl_configuration}=  Get Test Line Parameter Value  CONFIGURATION
#    ${tl_sync}=           Get Test Line Parameter Value  HW_ID
#    ${tl_platform}=       Get Test Line Parameter Value  PLATFORM
    ${tl_configuration}    set variable        ${tl.tl_cloud_topology}
    ${tl_sync}    set variable     ${SMOD1.HW_TYPE}
    ${tl_platform}    set variable    ${SMOD1.HW_TYPE}

    Run keyword if  "${False}" in ["${tl_configuration}", "${tl_sync}", "${tl_platform}"]
    ...  Run keywords
    ...  Log  There are missing variables in test line configuration, KPIs will not be registered in database
    ...  console=${True}
    ...  AND  Log  CONFIGURATION=${tl_configuration}, SYNC=${tl_sync}, PLATFORM=${tl_platform}  console=${True}
    ...  ELSE
    ...  Set test variable  ${KPI_TEST_LINE_VARIABLES}  ${True}
    [Return]  ${KPI_TEST_LINE_VARIABLES}  ${tl_configuration}  ${tl_sync}  ${tl_platform}

Get Test Line Parameter Value
    [Documentation]
    ...  Get testline parameter value
    ...
    ...  | **Author:** mnich@nokia.com
    ...  | **Maintainer:** mnich@nokia.com
    ...  | **Released with version:** 65.0
    ...
    ...  | **Full description:**
    ...  | If TL parameter_name value is string it is returned,
    ...  | If it is dictionary, it is resolved by _Get Test Line Parameter Value From Dict
    [Arguments]  ${parameter_name}
    ${parameter_exists}  ${parameter_value}  Run Keyword And Ignore Error
    ...  Get Variable Value  ${QC_PARAMETERS['${parameter_name}']}  ${False}
    Return From Keyword If  '${parameter_exists}'=='FAIL'  ${False}
    ${is_dict}=  Run keyword and return status  Evaluate  ${parameter_value}.keys()
    Return From Keyword If  '${is_dict}'=='${False}'  ${parameter_value}
    ${parameter_value}  _Get Test Line Parameter Value From Dict  ${parameter_name}
    [Return]   ${parameter_value}

_Get Test Line Parameter Value From Dict
    [Documentation]
    ...  Get testline parameter string from dictionary
    ...
    ...  | **Author:** mnich@nokia.com
    ...  | **Maintainer:** mnich@nokia.com
    ...  | **Released with version:** 65.0
    ...
    ...  | **Full description:**
    ...  | If TL parameter value is dict eg.
    ...  |   CONFIGURATION:
    ...  |    LWG: 2L3_1.1.1_1.1.2_FRGP.A_2x3G_1.1.3_1.2.1_FRGP.B_2x3G_H_111
    ...  |    L: 2L3_1.1.1_1.1.2_FRGP.A_2x3G_H_111
    ...  | there should be passed key to proper value from additional_parameters eg. {'QC':{'CONFIGURATION':'LWG'}}
#    [Arguments]  ${parameter_name}
    ${parameters_exist}  ${qc_argument_parameters}  Run Keyword And Ignore Error  Evaluate  ${QC}
    Return From Keyword If  '${parameters_exist}'=='FAIL'  ${False}
    ${key_exists}  ${key}  Run Keyword And Ignore Error
    ...  Get Variable Value  ${qc_argument_parameters['${parameter_name}']}  ${False}
    Return From Keyword If  '${key}'=='${False}'  ${False}
    ${key_works}  ${parameter_value}  Run Keyword And Ignore Error
    ...  Get Variable Value  ${QC_PARAMETERS['${parameter_name}']['${key}']}  ${False}
    [Return]  ${parameter_value}

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

Check FPGA Update info from SysLog file
    [Documentation]
    ...  Check if a FPGA Update occured
    ...
    ...  *AUTHOR*
    ...  alexandru.stamp@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter    | Mandatory | Description            |
    ...  | tech         | No        | Technology             |
    ...  | dirpath      | No        | SYSLOG path            |
    ...  | files_regex  | No        | Regex for SYSLOG files |
    ...
    ...  *RETURN VALUE*
    ...  | fpga_update_found | Return true if a FPGA update occured, otherwise false |

    [Timeout]  15 min
    [Arguments]  ${tech}=sbts  ${dirpath}=${Test Results Dir}/UDPLogs  ${files_regex}=SMOD1_UDP_*
    @{syslog_dir_path}=  OperatingSystem.List Files In Directory  ${dirpath}  ${files_regex}  True
    FOR  ${syslog_file}  IN  @{syslog_dir_path}
         ${fpga_update_found}=  Get FPGA Update Status  syslog_file_path=${syslog_file}  tech=${tech}
         Exit For Loop If  ${fpga_update_found}
    END
    [Return]  ${fpga_update_found}

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

Get RMOD CPRI Status
    [Documentation]
    ...  KW used to get shared RMOD CPRI status on NR and LTE
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter          | Man. | Description       |
    ...  | BTS_login          | No   | BTS username      |
    ...  | BTS_pwd            | No   | BTS password      |
    ...  | interface          | No   | RMOD IP interface |
    ...
    ...  *RETURN VALUE*
    ...  | NR_CPRI_dict  | Dictionary with key NR RMOD_id and value Primary or Secondary  |
    ...  | LTE_CPRI_dict | Dictionary with key LTE RMOD_id and value Primary or Secondary |

    [Arguments]  ${BTS_login}=${BTS_USERNAME}  ${BTS_pwd}=${BTS_PASSWORD}  ${interface}=eth0.295

    ${NR_shared_RMOD_list}  ${LTE_shared_RMOD_list}  ${NR_dedicated_RMOD_list}  ${LTE_dedicated_RMOD_list}=
    ...  Admin Get Shared And Dedicated RM List
    SSHLibrary.Open Connection  host=${MASTER['MASTER_TECH_IP_ADDRESS']}  timeout=10s  prompt=>
    SSHLibrary.Login  ${BTS_login}  ${BTS_pwd}
    Sleep  3
    ${NR_CPRI_dict}=  Create Dictionary
    ${LTE_CPRI_dict}=  Create Dictionary
    FOR  ${NR_RMOD_id}  ${LTE_RMOD_id}  IN ZIP  ${NR_shared_RMOD_list}  ${LTE_shared_RMOD_list}
        ${NR_RMOD_param}=  taf.sbts.oam.coam.admin.Get Parameters For  RMOD  ${NR_RMOD_id}  alias=Master
        ${LTE_RMOD_param}=  taf.sbts.oam.coam.admin.Get Parameters For  RMOD  ${LTE_RMOD_id}  alias=Slave
        SSHLibrary.Set Client Configuration  prompt=#
        SSHLibrary.Write  ssh -o StrictHostKeyChecking=no ${NR_RMOD_param.ipAddress}
        SSHLibrary.Read Until Prompt
        Sleep  1
        SSHLibrary.Write  ifconfig ${interface} | awk '/t addr:/{gsub(/.*:/,"",$2);print$2}'
        Sleep  1
        ${output}=  SSHLibrary.Read Until Prompt
        Sleep  1
        SSHLibrary.Write  exit
        ${line_list}=  Split String  ${output}  separator=\r\n
        ${NR_CPRI_status}=  Run Keyword If  '${line_list[-2]}' == '${NR_RMOD_param.ipAddress}'  Set Variable  Primary
        ...  ELSE IF  '${line_list[-2]}' == '${LTE_RMOD_param.ipAddress}'  Set Variable  Secondary
        Set To Dictionary  ${NR_CPRI_dict}  ${NR_RMOD_id}  ${NR_CPRI_status}
        ${LTE_CPRI_status}=  Run Keyword If  '${line_list[-2]}' == '${LTE_RMOD_param.ipAddress}'  Set Variable  Primary
        ...  ELSE IF  '${line_list[-2]}' == '${NR_RMOD_param.ipAddress}'  Set Variable  Secondary
        Set To Dictionary  ${LTE_CPRI_dict}  ${LTE_RMOD_id}  ${LTE_CPRI_status}
    END
    [Return]  ${NR_CPRI_dict}  ${LTE_CPRI_dict}
    [Teardown]  SSHLibrary.Close Connection

Set RMOD CPRI Primary Status
    [Documentation]
    ...  KW used to set RMOD CPRI status as Primary on NR or LTE BTS.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter          | Man. | Description                            |
    ...  | tech               | No   | NR or LTE, by default NR               |
    ...  | interface          | No   | RMOD IP interface, by default eth0.295 |
    ...  | spectrum           | No   | FDD or TDD, by default FDD             |
    ...  | address            | No   | devmem address, by default 0xa1602308  |
    ...

    [Arguments]  ${tech}=NR  ${interface}=eth0.295  ${spectrum}=FDD  ${address}=0xa1602308

    ${NR_CPRI_dict}  ${LTE_CPRI_dict}=  Run Keyword If  '${spectrum}' == 'FDD'  Get RMOD CPRI Status
    ...  interface=${interface}
    ...  ELSE IF  '${spectrum}' == 'TDD'  Get TDD RMOD CPRI Status  address=${address}
    ${NR_keys}=  Get Dictionary Keys  ${NR_CPRI_dict}
    ${NR_values}=  Get Dictionary Values  ${NR_CPRI_dict}
    ${LTE_keys}=  Get Dictionary Keys  ${LTE_CPRI_dict}
    ${LTE_values}=  Get Dictionary Values  ${LTE_CPRI_dict}
    Set Test Variable  ${CPRI_status}  ${True}
    FOR  ${NR_key}  ${NR_value}  ${LTE_key}  ${LTE_value}  IN ZIP  ${NR_keys}  ${NR_values}  ${LTE_keys}  ${LTE_values}
        Log  CPRI status on NR ${NR_key}: ${NR_value}  console=True
        Log  CPRI status on LTE ${LTE_key}: ${LTE_value}  console=True
        ${CPRI_status}=  Set Variable If
        ...  ('${tech}' == 'NR' and '${NR_value}' == 'Primary') or ('${tech}' == 'LTE' and '${LTE_value}' == 'Primary')
        ...  ${CPRI_status}  ${False}
    END
    Run Keyword If  ${CPRI_status}  Run Keywords
    ...  Log  All CPRI status on ${tech} BTS already set as Primary, no action needed!  console=True
    ...  AND  Return From Keyword
    FOR  ${NR_key}  ${NR_value}  ${LTE_key}  ${LTE_value}  IN ZIP  ${NR_keys}  ${NR_values}  ${LTE_keys}  ${LTE_values}
        Run Keyword If  '${tech}' == 'NR' and '${NR_value}' != 'Primary'   Run Keywords
        ...  Log  LTE Reset Site will be performed in order to set CPRI status on NR BTS as Primary!  console=True
        ...  AND  taf.sbts.oam.coam.admin.Reset Site  alias=Slave
        ...  AND  Exit For Loop
        ...  ELSE IF  '${tech}' == 'LTE' and '${LTE_value}' != 'Primary'   Run Keywords
        ...  Log  NR Reset Site will be performed in order to set CPRI status on LTE BTS as Primary!  console=True
        ...  AND  taf.sbts.oam.coam.admin.Reset Site  alias=Master
        ...  AND  Exit For Loop
    END
    Sleep  120s
    taf.sbts.oam.coam.admin.Assert Every  NRCEL  administrativeState=${_Unlocked},   operationalState=${_Enabled}  timeout=600  alias=Master
    taf.sbts.oam.coam.admin.Assert Every  LNCEL  administrativeState=${_Unlocked},   operationalState=${_Enabled}  timeout=600  alias=Slave

    ${NR_CPRI_dict}  ${LTE_CPRI_dict}=  Run Keyword If  '${spectrum}' == 'FDD'
    ...  Get RMOD CPRI Status  interface=${interface}
    ...  ELSE IF  '${spectrum}' == 'TDD'  Get TDD RMOD CPRI Status  address=${address}
    ${NR_keys}=  Get Dictionary Keys  ${NR_CPRI_dict}
    ${NR_values}=  Get Dictionary Values  ${NR_CPRI_dict}
    ${LTE_keys}=  Get Dictionary Keys  ${LTE_CPRI_dict}
    ${LTE_values}=  Get Dictionary Values  ${LTE_CPRI_dict}
    Set Test Variable  ${CPRI_status}  ${True}
    FOR  ${NR_key}  ${NR_value}  ${LTE_key}  ${LTE_value}  IN ZIP  ${NR_keys}  ${NR_values}  ${LTE_keys}  ${LTE_values}
        Log  CPRI status on NR ${NR_key}: ${NR_value}  console=True
        Log  CPRI status on LTE ${LTE_key}: ${LTE_value}  console=True
        ${CPRI_status}=  Set Variable If
        ...  ('${tech}' == 'NR' and '${NR_value}' == 'Primary') or ('${tech}' == 'LTE' and '${LTE_value}' == 'Primary')
        ...  ${CPRI_status}  ${False}
    END
    Run Keyword If  ${CPRI_status}  Run Keywords
    ...  Log  All CPRI status on ${tech} BTS properly set as Primary, due to peer BTS reset!  console=True
    ...  AND  Return From Keyword
    ...  ELSE
    ...  Log  Not all CPRI status on ${tech} BTS set as Primary due to peer BTS reset, try peer BTS power off/on!
    ...  console=True
    FOR  ${NR_key}  ${NR_value}  ${LTE_key}  ${LTE_value}  IN ZIP  ${NR_keys}  ${NR_values}  ${LTE_keys}  ${LTE_values}
        Run Keyword If  '${tech}' == 'NR' and '${NR_value}' != 'Primary'   Run Keywords
        ...  Log  LTE Power off/on will be performed in order to set CPRI status on NR BTS as Primary!  console=True
        ...  AND  Pdu BTS Interface Off  slave_fsm
        ...  AND  Sleep  120s
        ...  AND  Pdu BTS Interface On  slave_fsm
        ...  AND  Exit For Loop
        ...  ELSE IF  '${tech}' == 'LTE' and '${LTE_value}' != 'Primary'   Run Keywords
        ...  Log  NR Power off/on will be performed in order to set CPRI status on LTE BTS as Primary!  console=True
        ...  AND  Pdu BTS Interface Off  master_fsm
        ...  AND  Sleep  120s
        ...  AND  Pdu BTS Interface On  master_fsm
        ...  AND  Exit For Loop
    END
    Sleep  180s
    taf.sbts.oam.coam.admin.Assert Every  NRCEL  administrativeState=${_Unlocked},   operationalState=${_Enabled}  timeout=600  alias=Master
    taf.sbts.oam.coam.admin.Assert Every  LNCEL  administrativeState=${_Unlocked},   operationalState=${_Enabled}  timeout=600  alias=Slave

    ${NR_CPRI_dict}  ${LTE_CPRI_dict}=  Run Keyword If
    ...  '${spectrum}' == 'FDD'  Get RMOD CPRI Status  interface=${interface}
    ...  ELSE IF  '${spectrum}' == 'TDD'  Get TDD RMOD CPRI Status  address=${address}
    ${NR_keys}=  Get Dictionary Keys  ${NR_CPRI_dict}
    ${NR_values}=  Get Dictionary Values  ${NR_CPRI_dict}
    ${LTE_keys}=  Get Dictionary Keys  ${LTE_CPRI_dict}
    ${LTE_values}=  Get Dictionary Values  ${LTE_CPRI_dict}
    Set Test Variable  ${CPRI_status}  ${True}
    FOR  ${NR_key}  ${NR_value}  ${LTE_key}  ${LTE_value}  IN ZIP  ${NR_keys}  ${NR_values}  ${LTE_keys}  ${LTE_values}
        Log  CPRI status on NR ${NR_key}: ${NR_value}  console=True
        Log  CPRI status on LTE ${LTE_key}: ${LTE_value}  console=True
        ${CPRI_status}=  Set Variable If
        ...  ('${tech}' == 'NR' and '${NR_value}' == 'Primary') or ('${tech}' == 'LTE' and '${LTE_value}' == 'Primary')
        ...  ${CPRI_status}  ${False}
    END
    Run Keyword If  ${CPRI_status}
    ...  Log  All CPRI status on ${tech} BTS properly set as Primary, due to peer BTS power off/on!  console=True
    ...  ELSE  Run Keywords
    ...  Log  Not all CPRI status on ${tech} BTS set as Primary, failed!  level=ERROR
    ...  AND  Fail  Not all CPRI status on ${tech} BTS set as Primary, failed!

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
    ${BTS_scf}=  Run Keyword If  '${BTS_scf}'==''  Admin Collect scf.xml with timestamp  alias=${alias}
    ...  ELSE  Set Variable  ${BTS_scf}
    ${BTS_scf_xml}=  Parse xml  ${BTS_scf}
    ${actTempRadioMaster_exists}=  Run Keyword And Return Status
    ...  Element Should Exist  ${BTS_scf_xml}
    ...  .//managedObject[@class="com.nokia.srbts.mnl:FEATCADM"]/p[@name="actTempRadioMaster"]
    Return From Keyword If  not ${actTempRadioMaster_exists}  ${None}
    ${BTS_actTempRadioMaster}=  Get Element Text  ${BTS_scf_xml}
    ...  .//managedObject[@class="com.nokia.srbts.mnl:FEATCADM"]/p[@name="actTempRadioMaster"]
    [Return]  ${BTS_actTempRadioMaster}

Get Activate Temporary Radio Master Timers From Slave BTS
    [Documentation]
    ...  Get Activate Temporary Radio Master Timers tempRadioMasterRecovTime and tempRadioMasterTriggerTime values
    ...  on slave BTS. Outputs: 2 integer values (minutes)
    ...
    ...  *AUTHOR*
    ...  gabriel.stanculescu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Description                            |
    ...  | BTS_scf   | No   | BTS SCF file full path                 |
    ...  | alias     | No   | admin instance alias, by default Slave |
    ...
    ...  *RETURN VALUE*
    ...  | BTS_tempRadioMasterRecovTime   BTS_tempRadioMasterTriggerTime        | 2 integer values |

    [Arguments]  ${BTS_scf}=${EMPTY}  ${alias}=Slave
    ${BTS_scf}=  Run Keyword If  '${BTS_scf}'==''  Admin Collect scf.xml with timestamp  alias=${alias}
    ...  ELSE  Set Variable  ${BTS_scf}
    ${BTS_scf_xml}=  Parse xml  ${BTS_scf}
    ${tempRadioMasterRecovTime_exists}=  Run Keyword And Return Status
    ...  Element Should Exist  ${BTS_scf_xml}
    ...  .//managedObject[@class="com.nokia.srbts.mnl:FEATCADM"]/p[@name="tempRadioMasterRecovTime"]
    ${tempRadioMasterTriggerTime_exists}=  Run Keyword And Return Status
    ...  Element Should Exist  ${BTS_scf_xml}
    ...  .//managedObject[@class="com.nokia.srbts.mnl:FEATCADM"]/p[@name="tempRadioMasterTriggerTime"]
    Run Keyword If  not ${tempRadioMasterRecovTime_exists}  Log  tempRadioMasterRecovTime not found in scf!
    ...  console=True
    Run Keyword If  not ${tempRadioMasterTriggerTime_exists}  Log  tempRadioMasterTriggerTime not found in scf!
    ...  console=True
    Return From Keyword If  not ${tempRadioMasterRecovTime_exists}  ${None}
    Return From Keyword If  not ${tempRadioMasterTriggerTime_exists}  ${None}
    ${BTS_tempRadioMasterRecovTime}=  Get Element Text  ${BTS_scf_xml}
    ...  .//managedObject[@class="com.nokia.srbts.mnl:FEATCADM"]/p[@name="tempRadioMasterRecovTime"]
    ${BTS_tempRadioMasterTriggerTime}=  Get Element Text  ${BTS_scf_xml}
    ...  .//managedObject[@class="com.nokia.srbts.mnl:FEATCADM"]/p[@name="tempRadioMasterTriggerTime"]

    [Return]  ${BTS_tempRadioMasterRecovTime}  ${BTS_tempRadioMasterTriggerTime}

Set Activate Temporary Radio Master Role From Slave BTS
    [Documentation]
    ...  Set Activate Temporary Radio Master Role value on slave BTS. Possible values: true, false
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter                  | Man. | Description                            |
    ...  | BTS_scf                    | No   | BTS SCF file full path                 |
    ...  | actTempRadioMaster         | No   | param value                            |
    ...  | alias                      | No   | admin instance alias, by default Slave |
	...

	[Arguments]  ${BTS_scf}=${EMPTY}  ${actTempRadioMaster}=${EMPTY}  ${alias}=Slave
	${BTS_scf}=  Run Keyword If  '${BTS_scf}'==''  Admin Collect scf.xml with timestamp  alias=${alias}
    ...  ELSE  Set Variable  ${BTS_scf}
    ${BTS_scf_xml}=  Parse xml  ${BTS_scf}
    ${BTS_actTempRadioMaster}=  Get Activate Temporary Radio Master Role From Slave BTS  ${BTS_scf}  ${alias}
    Run Keyword If  '${actTempRadioMaster}'=='' or '${actTempRadioMaster}'=='${BTS_actTempRadioMaster}'  Run Keywords
    ...  Log  Parameter actTempRadioMaster already on BTS Slave: ${BTS_actTempRadioMaster}, commissioning not needed!
    ...  console=True
    ...  AND  Set Test Variable  ${BTS_actTempRadioMaster}
    ...  AND  Return From Keyword
    ${MO_items}=  Get Element Attributes  ${BTS_scf_xml}  .//*managedObject[@class="com.nokia.srbts.mnl:FEATCADM"]
    ${SCF_dn}=  Set Variable  ${MO_items['distName']}
    taf.sbts.oam.coam.admin.Perform Parameter Recommissioning  dist_name=${SCF_dn}
    ...    parameter=actTempRadioMaster  operation=update
    ...  value=${actTempRadioMaster.lower()}  skip_parameter_relation_errors=True  should_activate=True  alias=${alias}
    ${BTS_scf}=  Admin Collect scf.xml with timestamp  alias=${alias}
    ${BTS_actTempRadioMaster}=  Get Activate Temporary Radio Master Role From Slave BTS  ${BTS_scf}  ${alias}
    Run Keyword If  '${BTS_actTempRadioMaster}'=='${actTempRadioMaster.lower()}'  Run Keywords
    ...  Log  Parameter actTempRadioMaster set on BTS Slave: ${BTS_actTempRadioMaster}, successfully commissioned!
    ...  console=True
    ...  AND  Set Test Variable  ${BTS_actTempRadioMaster}

Set Activate Temporary Radio Master Timers On Slave BTS
    [Documentation]
    ...  Set Activate Temporary Radio Master Timers values on slave BTS. Possible values: 2 integers values (minutes)
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter                  | Man. | Description                            |
    ...  | BTS_scf                    | No   | BTS SCF file full path                 |
    ...  | tempRadioMasterRecovTime   | No   | param value (minutes)                  |
    ...  | tempRadioMasterTriggerTime | No   | param value (minutes)                  |
    ...  | alias                      | No   | admin instance alias, by default Slave |
	...

	[Arguments]  ${BTS_scf}=${EMPTY}  ${tempRadioMasterRecovTime}=${EMPTY}  ${tempRadioMasterTriggerTime}=${EMPTY}
	...  ${alias}=Slave
	${BTS_scf}=  Run Keyword If  '${BTS_scf}'==''  Admin Collect scf.xml with timestamp  alias=${alias}
    ...  ELSE  Set Variable  ${BTS_scf}
    ${BTS_scf_xml}=  Parse xml  ${BTS_scf}
    ${BTS_tempRadioMasterRecovTime}  ${BTS_tempRadioMasterTriggerTime}=
    ...  Get Activate Temporary Radio Master Timers From Slave BTS  ${BTS_scf}  ${alias}
    ${MO_items}=  Get Element Attributes  ${BTS_scf_xml}  .//*managedObject[@class="com.nokia.srbts.mnl:FEATCADM"]
    ${SCF_dn}=  Set Variable  ${MO_items['distName']}
    Run Keyword If
    ...  '${tempRadioMasterRecovTime}'=='' or '${tempRadioMasterRecovTime}'=='${BTS_tempRadioMasterRecovTime}'
    ...  Run Keywords
    ...  Log
    ...  tempRadioMasterRecovTime already set on BTS Slave: ${BTS_tempRadioMasterRecovTime}, commissioning not needed!
    ...  console=True
    ...  AND  Set Test Variable  ${BTS_tempRadioMasterRecovTime}
    ...  ELSE  Run Keywords
    ...  Log  Parameter tempRadioMasterRecovTime will be set to ${tempRadioMasterRecovTime} on BTS Slave  console=True
    ...  AND  taf.sbts.oam.coam.admin.Perform Parameter Recommissioning  dist_name=${SCF_dn}
    ...    parameter=tempRadioMasterRecovTime
    ...  operation=update  value=${tempRadioMasterRecovTime}  skip_parameter_relation_errors=True  should_activate=True
    ...  alias=${alias}
    ...  AND  Set Test Variable  ${BTS_tempRadioMasterRecovTime}
    Run Keyword If
    ...  '${tempRadioMasterTriggerTime}'=='' or '${tempRadioMasterTriggerTime}'=='${BTS_tempRadioMasterTriggerTime}'
    ...  Run Keywords    Log
    ...  tempRadioMasterTriggerTime already set BTS Slave: ${BTS_tempRadioMasterTriggerTime},commissioning not needed!
    ...  console=True
    ...  AND  Set Test Variable  ${BTS_tempRadioMasterTriggerTime}
    ...  ELSE  Run Keywords
    ...  Log  Parameter tempRadioMasterTriggerTime will be set to ${tempRadioMasterTriggerTime} on BTS Slave
    ...  console=True
    ...  AND  taf.sbts.oam.coam.admin.Perform Parameter Recommissioning  dist_name=${SCF_dn}
    ...    parameter=tempRadioMasterTriggerTime
    ...  operation=update  value=${tempRadioMasterTriggerTime}  skip_parameter_relation_errors=True
    ...  should_activate=True  alias=${alias}
    ...  AND  Set Test Variable  ${BTS_tempRadioMasterTriggerTime}

Primary CPRI TC Parameter Check
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${PRIMARY_CPRI_TECH}: <description>
    [Arguments]  ${PRIMARY_CPRI_TECH}
    Run Keyword If  '${PRIMARY_CPRI_TECH.upper()}' == 'NR'  Run Keywords
    ...  Log  =================================================================  console=True
    ...  AND  Log  ***** Test action will be performed with primary CPRI on NR *****  console=True
    ...  AND  Log  =================================================================  console=True
    ...  ELSE IF  '${PRIMARY_CPRI_TECH.upper()}' == 'LTE'  Run Keywords
    ...  Log  ==================================================================  console=True
    ...  AND  Log  ***** Test action will be performed with primary CPRI on LTE *****  console=True
    ...  AND  Log  ==================================================================  console=True
    ...  ELSE  Run Keywords
    ...  Log  ====================================================================  console=True
    ...  AND  Log  ***** Test action will be performed with existing primary CPRI *****  console=True
    ...  AND  Log  ====================================================================  console=True

Set PM Reporting Interval
    [Documentation]
    ...  Set PM reporting interval. Works for Admin sOAM or cOAM technology.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Description                                                  |
    ...  | value     | No   | Value for PM reporting interval in minutes, by default 15min |
    ...  | alias     | No   | ADMIN instance name, by default default                      |
    ...
    [Arguments]  ${value}=15min  ${alias}=default

    ${BTS_scf}=  Admin Collect scf.xml with timestamp  alias=${alias}
    ${BTS_scf_xml}=  Parse xml  ${BTS_scf}
    ${reportingIntervalPm_value}=  Get Element Text  ${BTS_scf_xml}
    ...  .//managedObject[@class="com.nokia.srbts.mnl:PMCADM"]/p[@name="reportingIntervalPm"]
    ${MO_items}=  Get Element Attributes  ${BTS_scf_xml}  .//*managedObject[@class="com.nokia.srbts.mnl:PMCADM"]
    ${SCF_dn}=  Set Variable  ${MO_items['distName']}
    Run Keyword If  '${reportingIntervalPm_value}' != '${value}'  Run Keywords
    ...  Log  BTS PM reporting interval: ${reportingIntervalPm_value}, need commissioning!  console=True
    ...  AND  taf.sbts.oam.coam.admin.Perform Parameter Recommissioning  dist_name=${SCF_dn}
    ...    parameter=reportingIntervalPm  operation=update
    ...  value=${value}  skip_parameter_relation_errors=True  should_activate=True  alias=${alias}
    ...  AND  Log  Parameter reportingIntervalPm=${value} successfully commissioned!  console=True
    ...  ELSE  Log  BTS PM reporting interval: ${reportingIntervalPm_value}, commissioning not needed!  console=True

Get TDD RMOD CPRI Status
    [Documentation]
    ...  KW used to get shared TDD RMOD CPRI status on NR and LTE by using devmem command
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter          | Man. | Description       |
    ...  | BTS_login          | No   | BTS username      |
    ...  | BTS_pwd            | No   | BTS password      |
    ...  | address            | No   | devmem address    |
    ...
    ...  *RETURN VALUE*
    ...  | NR_CPRI_dict  | Dictionary with key NR RMOD_id and value Primary or Secondary  |
    ...  | LTE_CPRI_dict | Dictionary with key LTE RMOD_id and value Primary or Secondary |

    [Arguments]  ${BTS_login}=${BTS_USERNAME}  ${BTS_pwd}=${BTS_PASSWORD}  ${address}=0xa1602308

    ${NR_shared_RMOD_list}  ${LTE_shared_RMOD_list}  ${NR_dedicated_RMOD_list}  ${LTE_dedicated_RMOD_list}=
    ...  Admin Get Shared And Dedicated RM List
    SSHLibrary.Open Connection  host=${MASTER['MASTER_TECH_IP_ADDRESS']}  timeout=10s  prompt=>
    SSHLibrary.Login  ${BTS_login}  ${BTS_pwd}
    Sleep  3
    ${NR_CPRI_dict}=  Create Dictionary
    ${LTE_CPRI_dict}=  Create Dictionary
    FOR  ${NR_RMOD_id}  ${LTE_RMOD_id}  IN ZIP  ${NR_shared_RMOD_list}  ${LTE_shared_RMOD_list}
        ${NR_RMOD_param}=  taf.sbts.oam.coam.admin.Get Parameters For  RMOD  ${NR_RMOD_id}  alias=Master
        ${LTE_RMOD_param}=  taf.sbts.oam.coam.admin.Get Parameters For  RMOD  ${LTE_RMOD_id}  alias=Slave
        SSHLibrary.Set Client Configuration  prompt=$
        SSHLibrary.Write  ssh -o StrictHostKeyChecking=no ${NR_RMOD_param.ipAddress}
        SSHLibrary.Read Until Prompt
        Sleep  1
        SSHLibrary.Write  devmem ${address}
        Sleep  1
        ${output}=  SSHLibrary.Read Until Prompt
        Sleep  1
        SSHLibrary.Write  exit
        ${line_list}=  Split String  ${output}  separator=\r\n
        ${value}=  Get Substring  ${line_list[0]}  7  8
        ${NR_CPRI_status}=  Run Keyword If  '${value}' == '0'  Set Variable  Primary
        ...  ELSE IF  '${value}' == '1'  Set Variable  Secondary
        Set To Dictionary  ${NR_CPRI_dict}  ${NR_RMOD_id}  ${NR_CPRI_status}
        ${LTE_CPRI_status}=  Run Keyword If  '${value}' == '1'  Set Variable  Primary
        ...  ELSE IF  '${value}' == '0'  Set Variable  Secondary
        Set To Dictionary  ${LTE_CPRI_dict}  ${LTE_RMOD_id}  ${LTE_CPRI_status}
    END
    [Return]  ${NR_CPRI_dict}  ${LTE_CPRI_dict}
    [Teardown]  SSHLibrary.Close Connection

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

    ${LTE_runtime_cell_number}  ${LTE_IOT_runtime_cell_number}  ${WCDMA_runtime_cell_number}
    ...  ${GSM_runtime_cell_number}  ${BTS_runtime_rmod_number}=  Get Admin Cells And RMs Number From SBTS  ${alias}
    ${LTE_scf_cell_number}  ${LTE_IOT_scf_cell_number}  ${WCDMA_scf_cell_number}  ${GSM_scf_cell_number}
    ...  ${BTS_scf_rmod_number}=  Get SCF Cells And RMs Number From SBTS  ${scf_file}

    ${LTE_cell_conf}=  Run Keyword And Return Status
    ...  Should be equal  ${LTE_runtime_cell_number}  ${LTE_scf_cell_number}
    ${LTE_IOT_cell_conf}=  Run Keyword And Return Status
    ...  Should be equal  ${LTE_IOT_runtime_cell_number}  ${LTE_IOT_scf_cell_number}
    ${WCDMA_cell_conf}=  Run Keyword And Return Status
    ...  Should be equal  ${WCDMA_runtime_cell_number}  ${WCDMA_scf_cell_number}
    ${GSM_cell_conf}=  Run Keyword And Return Status
    ...  Should be equal  ${GSM_runtime_cell_number}  ${GSM_scf_cell_number}
    ${BTS_rmod_conf}=  Run Keyword And Return Status
    ...  Should be equal  ${BTS_runtime_rmod_number}  ${BTS_scf_rmod_number}
    ${BTSConf}=  Set Variable If
    ...  ${LTE_cell_conf} and ${LTE_IOT_cell_conf} and ${WCDMA_cell_conf} and ${GSM_cell_conf} and ${BTS_rmod_conf}
    ...  ${TRUE}  ${FALSE}
    ${str_1}=  Set Variable    configured/running cell number:
    ${str_2}= Catenate   ${alias}   BTS configuration-LTE   ${str_1}
    ...  ${LTE_scf_cell_number}/${LTE_runtime_cell_number}
    ${str_3}= Catenate   ${alias}   BTS configuration-LTE IOT   ${str_1}
    ...  ${LTE_IOT_scf_cell_number}/${LTE_IOT_runtime_cell_number}
    ${str_4}= Catenate   ${alias}   BTS configuration-WCDMA  ${str_1}
    ...  ${WCDMA_scf_cell_number}/${WCDMA_runtime_cell_number}
    ${str_5}= Catenate   ${alias}   BTS configuration-GSM  ${str_1}    ${GSM_scf_cell_number}/${GSM_runtime_cell_number}
    ${str_6}= Catenate   ${alias}   BTS configuration-BTS  ${str_1}    ${BTS_scf_rmod_number}/${BTS_runtime_rmod_number}
    Log   ${str_2}   console=True
    Log   ${str_3}   console=True
    Log   ${str_4}    console=True
    Log   ${str_5}   console=True
    Log   ${str_6}    console=True

    [Return]  ${BTSConf}

Get Admin Cells And RMs Number From SBTS
    [Documentation]
    ...  Helper keyword providing number of cells and radio modules from WebEM running view.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Mandatory | Description                     |
    ...  | alias     | Yes       | Admin instance, Master or Slave |
    ...
    ...  *RETURN*
    ...  | Parameter                   | Description                                 |
    ...  | LTE_runtime_cell_number     | WebEM runtime view LTE cells number         |
    ...  | LTE_IOT_runtime_cell_number | WebEM runtime view LTE IOT cells number     |
    ...  | WCDMA_runtime_cell_number   | WebEM runtime view WCDMA cells number       |
    ...  | GSM_runtime_cell_number     | WebEM runtime view GSM cells number         |
    ...  | BTS_runtime_rmod_number     | WebEM runtime view BTS radio modules number |

    [Arguments]  ${alias}
    ${LTE_cell_ids}  ${LTE_IOT_cell_ids}=  Admin Get LTE CELL Ids list  ${alias}
    Set Test Variable  ${${${alias.upper()}\['${alias.upper()}_TECH']}_LTE_cell_ids}  ${LTE_cell_ids}
    Set Test Variable  ${${${alias.upper()}\['${alias.upper()}_TECH']}_LTE_IOT_cell_ids}  ${LTE_IOT_cell_ids}
    ${LTE_runtime_cell_number}=  Get Length  ${LTE_cell_ids}
    ${LTE_IOT_runtime_cell_number}=  Get Length  ${LTE_IOT_cell_ids}

    ${WCDMA_cell_ids}=  taf.sbts.oam.coam.admin.Get Ids For All  WNCEL  alias=${alias}
    Set Test Variable  ${${${alias.upper()}\['${alias.upper()}_TECH']}_WCDMA_cell_ids}  ${WCDMA_cell_ids}
    ${WCDMA_runtime_cell_number}=  Get Length  ${WCDMA_cell_ids}

    ${GSM_cell_ids}=  taf.sbts.oam.coam.admin.Get Ids For All  GNCEL  alias=${alias}
    Set Test Variable  ${${${alias.upper()}\['${alias.upper()}_TECH']}_GSM_cell_ids}  ${GSM_cell_ids}
    ${GSM_runtime_cell_number}=  Get Length  ${GSM_cell_ids}

    ${BTS_rmod_ids}=  taf.sbts.oam.coam.admin.Get Ids For All  RMOD  alias=${alias}
    Set Test Variable  ${${${alias.upper()}\['${alias.upper()}_TECH']}_rmod_ids}  ${BTS_rmod_ids}
    ${BTS_runtime_rmod_number}=  Get Length  ${BTS_rmod_ids}

    [Return]  ${LTE_runtime_cell_number}  ${LTE_IOT_runtime_cell_number}  ${WCDMA_runtime_cell_number}
    ...  ${GSM_runtime_cell_number}  ${BTS_runtime_rmod_number}

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
    ...  | LTE_scf_cell_number     | SCF configured LTE cells number         |
    ...  | LTE_IOT_scf_cell_number | SCF configured LTE IOT cells number     |
    ...  | WCDMA_scf_cell_number   | SCF configured WCDMA cells number       |
    ...  | GSM_scf_cell_number     | SCF configured GSM cells number         |
    ...  | BTS_scf_rmod_number     | SCF configured BTS radio modules number |

    [Arguments]  ${BTS_scf}

    Setup Scfc Parser  scfc=${BTS_scf}  parser_technology=SBTS

    ${LTE_scf_cell_number}=  Get Cells Count  LTE
    ${LTE_IOT_scf_cell_number}=  Get IOT Cells Count
    ${WCDMA_scf_cell_number}=  Get Cells Count  WCDMA
    ${GSM_scf_cell_number}=  Get Cells Count  GSM
    ${BTS_scf_rmod_number}=  Get Radios Count

    Teardown Scfc Parser

    [Return]  ${LTE_scf_cell_number}  ${LTE_IOT_scf_cell_number}  ${WCDMA_scf_cell_number}
    ...  ${GSM_scf_cell_number}  ${BTS_scf_rmod_number}

Check ${alias} SBTS All Cells SOAM
    [Documentation]
    ...  Helper keyword checking states of all BTS cells: operationalState=${_Enabled},
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *RETURN*
    ...  | Parameter             | Description   |
    ...  | BTS_cells_operational | True or False |

    ${LTE_cells_operational}=  Run Keyword If  ${${${alias.upper()}\['${alias.upper()}_TECH']}_LTE_cell_ids}
    ...  Run Keyword And Return Status  taf.sbts.oam.coam.admin.Assert Every  LNCEL  operationalState=${_Enabled},    alias=${alias}
    ...  ELSE  Set Variable  ${TRUE}
    ${WCDMA_cells_operational}=  Run Keyword If  ${${${alias.upper()}\['${alias.upper()}_TECH']}_WCDMA_cell_ids}
    ...  Run Keyword And Return Status  taf.sbts.oam.coam.admin.Assert Every  WNCEL  operationalState=${_Enabled},    alias=${alias}
    ...  ELSE  Set Variable  ${TRUE}
    ${GSM_cells_operational}=  Run Keyword If  ${${${alias.upper()}\['${alias.upper()}_TECH']}_GSM_cell_ids}
    ...  Run Keyword And Return Status  taf.sbts.oam.coam.admin.Assert Every  GNCEL  operationalState=${_Enabled},    alias=${alias}
    ...  ELSE  Set Variable  ${TRUE}

    Run Keyword If  ${${${alias.upper()}\['${alias.upper()}_TECH']}_LTE_cell_ids}
    ..  Run Keyword If  ${LTE_cells_operational}
    ...  Log  ${alias} BTS LTE cells: operationalState=${_Enabled},    level=INFO  console=True
    Run Keyword If  ${${${alias.upper()}\['${alias.upper()}_TECH']}_LTE_cell_ids}
    ...  Run keyword if    not ${LTE_cells_operational}
    ...  Log  At least one LTE cell is not operational!  level=INFO  console=True

    Run Keyword If  ${${${alias.upper()}\['${alias.upper()}_TECH']}_WCDMA_cell_ids}
    ...  Run Keyword If  ${WCDMA_cells_operational}
    ...  Log  ${alias} BTS WCDMA cells: operationalState=${_Enabled},    level=INFO  console=True
    Run Keyword If  ${${${alias.upper()}\['${alias.upper()}_TECH']}_WCDMA_cell_ids}
    ...  Run keyword if    not ${WCDMA_cells_operational}
    ...  Log  At least one WCDMA cell is not operational!  level=INFO  console=True

    Run Keyword If  ${${${alias.upper()}\['${alias.upper()}_TECH']}_GSM_cell_ids}
    ...  Run Keyword If  ${GSM_cells_operational}
    ...  Log  ${alias} BTS GSM cells: operationalState=${_Enabled},    level=INFO  console=True
    Run Keyword If  ${${${alias.upper()}\['${alias.upper()}_TECH']}_GSM_cell_ids}
    ...  Run keyword if    not ${GSM_cells_operational}
    ...  Log  At least one GSM cell is not operational!  level=INFO  console=True

    ${BTS_cells_operational}=  Set Variable If
    ...  ${LTE_cells_operational} and ${WCDMA_cells_operational} and ${GSM_cells_operational}  ${TRUE}  ${FALSE}

    [Return]  ${BTS_cells_operational}

Check ${alias} SBTS RM State SOAM
    [Documentation]
    ...  Helper keyword checking states of all BTS RMODs: operationalState=${_Enabled},
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *RETURN*
    ...  | Parameter             | Description   |
    ...  | BTS_rmods_operational | True or False |

    ${BTS_rmods_operational}=  Run Keyword If  ${${${alias.upper()}\['${alias.upper()}_TECH']}_rmod_ids}
    ...  Run Keyword And Return Status
    ...  taf.sbts.oam.coam.admin.Assert Every  RMOD  operationalState=${_Enabled},    alias=${alias}

    Run Keyword If  ${${${alias.upper()}\['${alias.upper()}_TECH']}_rmod_ids}  Run Keyword If  ${BTS_rmods_operational}
    ...  Log  ${alias} BTS radio modules: operationalState=${_Enabled},    level=INFO  console=True
    Run Keyword If  ${${${alias.upper()}\['${alias.upper()}_TECH']}_rmod_ids}
    ...  Run keyword if    not ${BTS_rmods_operational}
    ...  Log  At least one BTS radio module is not operational!  level=INFO  console=True

    [Return]  ${BTS_rmods_operational}

Count SBTS alarms number
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${RM_id}: <description>
    ...        ${SBTS_RM_CELL_list}: <description>
    ...        ${LTE_CELL_RM_list}: <description>
    ...        ${LTE_CELL_IOT_dict}: <description>
    ...        ${WCDMA_CELL_RM_list}: <description>
    [Arguments]  ${RM_id}  ${SBTS_RM_CELL_list}  ${LTE_CELL_RM_list}  ${LTE_CELL_IOT_dict}  ${WCDMA_CELL_RM_list}
    FOR  ${RM_CELL_details}  IN  @{SBTS_RM_CELL_list}
        Run Keyword If  '${RM_CELL_details[0]}' == '${RM_id}'  Run Keywords
        ...  Get SBTS cells alarms number  ${RM_CELL_details[1]}  ${LTE_CELL_IOT_dict}
        ...  AND  Get LTE mimo cells alarms number
        ...  ${RM_CELL_details[0]}  ${RM_CELL_details[1]}  ${LTE_CELL_RM_list}  ${LTE_CELL_IOT_dict}
        ...  AND  Get SBTS-WCDMA mimo cells alarms number
        ...  ${RM_CELL_details[0]}  ${RM_CELL_details[1]}  ${WCDMA_CELL_RM_list}
    END

Get SBTS cells alarms number
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${RM_CELL}: <description>
    ...        ${CELL_IOT_dict}: <description>
    [Arguments]  ${RM_CELL}  ${CELL_IOT_dict}
    ${RM_cells_count_alarms}  Get Length  ${RM_CELL}
    FOR  ${CELL_globalCellId}  IN  @{RM_CELL}
        ${status}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${CELL_IOT_dict}  ${CELL_globalCellId}
        ${value}=  Run Keyword If  ${status} and ${IOT_MIMO_alarm_check}  Get From Dictionary  ${CELL_IOT_dict}
        ...  ${CELL_globalCellId}
        ...  ELSE  Set Variable  None
        ${RM_cells_count_alarms}=  Run Keyword If  '${value}' != 'None'  Evaluate  ${RM_cells_count_alarms} + 1
        ...  ELSE  Evaluate  ${RM_cells_count_alarms} + 0
    END
    Set Test Variable  ${RM_cells_count_alarms}  ${RM_cells_count_alarms}

Get SBTS-WCDMA mimo cells alarms number
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${RM_DN}: <description>
    ...        ${RM_CELL}: <description>
    ...        ${CELL_RM_list}: <description>
    [Arguments]  ${RM_DN}  ${RM_CELL}  ${CELL_RM_list}
    FOR  ${CELL_RM_details}  IN  @{CELL_RM_list}
        ${Cell_Tx_count}  ${Cell_Rx_count}=  Count SBTS-WCDMA Cell Tx Rx Total Number
        ...  ${CELL_RM_details[0]}  ${CELL_RM_list}
        ${Cell_RM_Tx_count}  ${Cell_RM_Rx_count}=  Count SBTS-WCDMA Cell-RM Tx Rx Number
        ...  ${CELL_RM_details[0]}  ${RM_DN}  ${CELL_RM_list}
        ${Cell_Tx_active_count}=  Evaluate  ${Cell_Tx_count} - ${Cell_RM_Tx_count}
        ${Cell_Rx_active_count}=  Evaluate  ${Cell_Rx_count} - ${Cell_RM_Rx_count}
        ${map}=  Run Keyword And Return Status  List Should Contain Value  ${RM_CELL}  ${CELL_RM_details[0]}
        ${Cell_label}=  Fetch From Right  ${CELL_RM_details[0]}  /
        ${alias}=  Set Variable If  '${MASTER['MASTER_TECH']}' == 'SBTS'  Master  Slave
        ${Cell_states}=  Run Keyword If  '${map}' == 'True'
        ...  taf.sbts.oam.coam.admin.Get Parameters For  WNCEL  ${CELL_RM_details[0]}  alias=${alias}
        Run Keyword If  '${map}' == 'True'
        ...  Log  ${Cell_label} availabilityStatus: ${Cell_states['availabilityStatus']}  console=True
        Run Keyword If  '${map}' == 'True'  Run Keywords
        ...  Calculate SBTS-WCDMA MIMO Cells Alarms
        ...  ${Cell_Tx_active_count}  ${Cell_Rx_active_count}  ${Cell_Tx_count}
        ...  ${Cell_Rx_count}  ${CELL_RM_details[0]}  ${alias}
        ...  AND  Add mimo cells alarms to list  ${RM_cells_count_alarms_mimo}  ${RM_Cell_count_alarm_mimo}
    END
    Set Test Variable  ${RM_cells_count_alarms_mimo}  ${RM_cells_count_alarms_mimo}

Count SBTS-WCDMA Cell Tx Rx Total Number
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${Cell_DN}: <description>
    ...        ${CELL_RM_list}: <description>
    ...
    ...    Returns:
    ...        ${Cell_Tx_count}: <description>
    ...        ${Cell_Rx_count}: <description>
    [Arguments]  ${Cell_DN}  ${CELL_RM_list}
    FOR  ${item}  IN  @{CELL_RM_list}
        ${Cell_Tx_count}  ${Cell_Rx_count}=  Run Keyword If  '${item[0]}' == '${Cell_DN}'
        ...  Count RM Tx Rx Total Number  ${item[3]}
        Exit For Loop If  '${item[0]}' == '${Cell_DN}'
    END
    [Return]  ${Cell_Tx_count}  ${Cell_Rx_count}

Count SBTS-WCDMA Cell-RM Tx Rx Number
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${Cell_DN}: <description>
    ...        ${RM_DN}: <description>
    ...        ${CELL_RM_list}: <description>
    ...
    ...    Returns:
    ...        ${Cell_RM_Tx_count}: <description>
    ...        ${Cell_RM_Rx_count}: <description>
    [Arguments]  ${Cell_DN}  ${RM_DN}  ${CELL_RM_list}
    FOR  ${item}  IN  @{CELL_RM_list}
        ${Cell_RM_Tx_count}  ${Cell_RM_Rx_count}=  Run Keyword If  '${item[0]}' == '${Cell_DN}'
        ...  Count RM Tx Rx Number  ${RM_DN}  ${item[3]}
        Exit For Loop If  '${item[0]}' == '${Cell_DN}'
    END
    [Return]  ${Cell_RM_Tx_count}  ${Cell_RM_Rx_count}

Calculate SBTS-WCDMA MIMO Cells Alarms
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${Cell_Tx_active_count}: <description>
    ...        ${Cell_Rx_active_count}: <description>
    ...        ${Cell_Tx_count}: <description>
    ...        ${Cell_Rx_count}: <description>
    ...        ${Cell_DN}: <description>
    ...        ${alias}: <description>
    [Arguments]  ${Cell_Tx_active_count}  ${Cell_Rx_active_count}  ${Cell_Tx_count}
    ...  ${Cell_Rx_count}  ${Cell_DN}  ${alias}
    ${bool_1} = Convert To Boolean    ${Cell_Tx_active_count} == ${Cell_Tx_count}
    ${bool_2} = Convert To Boolean    ${Cell_Tx_active_count} != ${Cell_Tx_count}
    Run Keyword If
    ...  ${bool_1} and ${Cell_Rx_active_count} != ${Cell_Rx_count} and ${Cell_Rx_active_count} >= 1
    ...  Run Keywords  Set Test Variable  ${RM_Cell_count_alarm_mimo}  0
    ...  AND  taf.sbts.oam.coam.admin.Assert  WNCEL  ${Cell_DN}  availabilityStatus=Degraded  alias=${alias}

    Run Keyword If
    ...  ${bool_2} and ${Cell_Tx_active_count} >= 1 and ${Cell_Rx_active_count} >= 1
    ...  Run Keywords  Set Test Variable  ${RM_Cell_count_alarm_mimo}  0
    ...  AND  taf.sbts.oam.coam.admin.Assert  WNCEL  ${Cell_DN}  availabilityStatus=Degraded  alias=${alias}

    Run Keyword If  ${Cell_Tx_active_count} == 0 or ${Cell_Rx_active_count} == 0
    ...  Run Keywords  Set Test Variable  ${RM_Cell_count_alarm_mimo}  0
    ...  AND  taf.sbts.oam.coam.admin.Assert  WNCEL  ${Cell_DN}  availabilityStatus=Failed  alias=${alias}

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
    ${dummy_search_order}=    Create List    dummy_resource_name
    ${search_order}=   Set Library Search Order
    ${ORIGINAL_SEARCH_ORDER}=    Set Variable If    len(${search_order})    ${search_order}    ${dummy_search_order}
    Set Test Variable    ${ORIGINAL_SEARCH_ORDER}
    Set Library Search Order    @{search_order}    ${resource_name}

Restore Resource Search Order
    [Documentation]    To be used in pair with `Modify Resource Search Order`
    ${search_order}=    Create List    @{ORIGINAL_SEARCH_ORDER}
    Remove Values From List    ${search_order}    dummy_resource_name
    Set Library Search Order   @{search_order}
