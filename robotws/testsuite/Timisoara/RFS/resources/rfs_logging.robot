*** Settings ***
Documentation    Keywords for logs saving (Stop and Fix, syslog, other logs)

# Resources
Resource          rfs_rmod_serial_interface.robot

# Libraries
Library           taf.collectors.btslog  WITH NAME  btslog
Library           python_resources/udp_log_capture/udp_log_capture_client.py  WITH NAME  rmod_udp_log
Library           taf.collectors.aashell_cli  WITH NAME  aashell_cli
Library           taf.collectors.aashell_log  WITH NAME  aashell_log
Library           taf.collectors.core  WITH NAME  core

*** Keywords ***
Start Syslog On
    [Arguments]    ${alias}
    [Timeout]    10 min
    Log    Starting Syslog on ${alias}    console=True
    IF    '${alias}' == '${alias_local}'
        Kill Process By Name    btslog
        Write BTSLOG To File    /home/ute/btslog2/btslog.ini
        BTSLOG Start On Local Machine    name=${alias}UDP    bts_log_dir=${Temp Logs Dir}    log_name=SYSLOG_${alias}UDP
        Create Syslog Hardlink Local    alias=${alias}    link_name=${alias}UDP    bts_log_dir=${Temp Logs Dir}    log_name=SYSLOG_${alias}UDP
        Log    Syslog on '${alias}' started    level=TRACE    console=True
        RETURN
    END
    Kill Process By Name    btslog    local=${FALSE}    host_ip=${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]
    ...    ssh_port=${${alias.upper()}}[${alias.upper()}_PC_SSH_PORT]    ssh_username=${${alias.upper()}}[${alias.upper()}_PC_SSH_USERNAME]
    ...    ssh_password=${${alias.upper()}}[${alias.upper()}_PC_SSH_PASSWORD]
    Write BTSLOG To Remote File    remote_path=/home/ute/btslog2/btslog.ini
    ...    remote_ip=${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]
    ...    remote_username=${${alias.upper()}}[${alias.upper()}_PC_SSH_USERNAME]
    ...    remote_password=${${alias.upper()}}[${alias.upper()}_PC_SSH_PASSWORD]
    BTSLOG Start On Remote Machine    name=${alias}UDP    bts_log_dir=${Temp Logs Dir}
    ...    log_name=SYSLOG_${alias}UDP    host_ip=${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]
    ...    ssh_user=${${alias.upper()}}[${alias.upper()}_PC_SSH_USERNAME]
    ...    ssh_password=${${alias.upper()}}[${alias.upper()}_PC_SSH_PASSWORD]
    Create Syslog Hardlink Remote    alias=${alias}    link_name=${alias}UDP    bts_log_dir=${Temp Logs Dir}    log_name=SYSLOG_${alias}UDP
    Log    Syslog on '${alias}' started    level=TRACE    console=True

Create Syslog Hardlink Remote
    [Arguments]  ${alias}  ${link_name}  ${bts_log_dir}  ${log_name}

    ${command}=  Create Long String
    ...  if [ ! -f "${bts_log_dir}/${log_name}" ];
    ...  then sleep 15; fi && ln "${bts_log_dir}/${log_name}" "${bts_log_dir}/${link_name}"

    ${empty_file_command}=  Create Long String
    ...  touch "${bts_log_dir}/${log_name}" && ln "${bts_log_dir}/${log_name}" "${bts_log_dir}/${link_name}"

    ${log_status}=  Execute Remote Command  command=${command}  index_or_alias=remoteUDP
    ...  host_ip=${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]  ssh_port=${${alias.upper()}}[${alias.upper()}_PC_SSH_PORT]
    ...  ssh_username=${${alias.upper()}}[${alias.upper()}_PC_SSH_USERNAME]  ssh_password=${${alias.upper()}}[${alias.upper()}_PC_SSH_PASSWORD]

    Run Keyword If  '${log_status}' == '0'
    ...  Log  Syslog file created successfully for ${alias} BTS  level=INFO  console=True
    ...  ELSE  Run Keywords
    ...  Execute Remote Command  command=${empty_file_command}  index_or_alias=remoteUDP
    ...  host_ip=${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]  ssh_port=${${alias.upper()}}[${alias.upper()}_PC_SSH_PORT]
    ...  ssh_username=${${alias.upper()}}[${alias.upper()}_PC_SSH_USERNAME]  ssh_password=${${alias.upper()}}[${alias.upper()}_PC_SSH_PASSWORD]
    ...  AND
    ...  Log  Syslog file is empty, check ${alias} BTS syslog settings  level=WARN  console=True

Create Syslog Hardlink Local
    [Arguments]  ${alias}  ${link_name}  ${bts_log_dir}  ${log_name}

    ${command}=  Set Variable  ln "${bts_log_dir}/${log_name}" "${bts_log_dir}/${link_name}"
    ${empty_file_command}=  Set Variable  touch "${bts_log_dir}/${log_name}" && ${command}

    ${log_status}=  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  15 sec  3 sec  OperatingSystem.File Should Exist  ${bts_log_dir}/${log_name}

    Run Keyword If  '${log_status}' == 'True'  Run Keywords
    ...  Execute Local Command  command=${command}
    ...  AND
    ...  Log  Syslog file created successfully for ${alias} BTS  level=INFO  console=True
    ...  ELSE  Run Keywords
    ...  Execute Local Command  command=${empty_file_command}
    ...  AND
    ...  Log  Syslog file is empty, check ${alias} BTS syslog settings  level=WARN  console=True

BTSLOG Start On Local Machine
    [Arguments]  ${name}  ${bts_log_dir}  ${log_name}

    ${parameters}=  Create Dictionary  MaxTraceFileSize=1  MaxSysLogFileSize=10000
    ...  SysLogFileTemplate=${Temp Logs Dir}/${log_name}
    ${btslog_configuration}=  Create Dictionary  LOG_CONFIGURATION=${parameters}

    btslog.create_btslog_collector
    ...  name=${name}
    ...  log_dir=${bts_log_dir}
    ...  target_file_name=${log_name}.tar.gz
    ...  btslog_configuration=${btslog_configuration}
    core.setup_collectors  names=${name}
    core.start_collectors  names=${name}
    btslog.set_suite_alias  ${name}

BTSLOG Start On Remote Machine
    [Arguments]   ${name}  ${bts_log_dir}  ${log_name}  ${host_ip}  ${ssh_user}=ute  ${ssh_password}=ute

    ${executor_remote_vm}=  Create Dictionary
    ...  host=${host_ip}
    ...  user=${ssh_user}
    ...  password=${ssh_password}

    ${parameters}=  Create Dictionary  MaxTraceFileSize=1  MaxSysLogFileSize=10000
    ...  SysLogFileTemplate=${Temp Logs Dir}/${log_name}
    ${btslog_configuration}=  Create Dictionary  LOG_CONFIGURATION=${parameters}

    btslog.create_btslog_collector
    ...  name=${name}
    ...  log_dir=${bts_log_dir}
    ...  target_file_name=${log_name}.tar.gz
    ...  executor=${executor_remote_vm}
    ...  btslog_configuration=${btslog_configuration}
    core.setup_collectors  names=${name}
    core.start_collectors  names=${name}
    btslog.set_suite_alias  ${name}

Collect Syslog On
    [Arguments]  ${alias}  ${folder_path}=${UDP Logs}
    ${syslog_status}=  Run Keyword And Return Status  BTSLOG Collect Result  destination=${folder_path}  alias=${alias}UDP
    Run Keyword If  ${syslog_status}
    ...  Log  ${alias} syslog stopped and collected to ${folder_path}/${alias}UDP.tar.gz  level=TRACE  console=True
    ...  ELSE  Log  Syslog could not be successfully collected  level=WARN  console=TRUE
    Write BTSLOG To Remote File  remote_path=/home/ute/btslog2/btslog.ini
    ...  remote_ip=${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]
    ...  remote_username=${${alias.upper()}}[${alias.upper()}_PC_SSH_USERNAME]
    ...  remote_password=${${alias.upper()}}[${alias.upper()}_PC_SSH_PASSWORD]

BTSLOG Collect Result
    [Arguments]  ${destination}  ${alias}
    [Timeout]  15 min
    core.stop_collectors  names=${alias}
    core.collect_collectors  names=${alias}  target_dir=${destination}
    core.teardown_collectors  names=${alias}  force=${True}

    ${command}=  Set Variable  mv "${destination}/${alias}/SYSLOG_${alias}.tar.gz" "${destination}/${alias}/${alias}.tar.gz"
    Execute Local Command  command=${command}

Snapshot collection with timestamp SOAM CBTS
    [Arguments]    ${alias}

    ${yyyy}  ${mm}  ${dd}  ${hh}  ${min}  ${ss}=  Get Time  format=year,month,day,hour,min,sec
    ${snapshot_and_alarms_dir}=  Set Variable  ${Test Results Dir}/Snapshot__${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}
    Set Test Variable  ${${alias}_snapshot_and_alarms_dir}  ${snapshot_and_alarms_dir}

    ${first_passed_run_dict}=  Get Variable Value  ${first_passed_run_dict}  &{EMPTY}
    ${first_passed_run_dict_length}=  Get Length  ${first_passed_run_dict}
    Run Keyword If  ${first_passed_run_dict_length}==0  Set Test Variable  ${first_passed_run_dict}
    ${alias_exists_in_dict}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${first_passed_run_dict}  ${alias}
    Run Keyword If  not ${alias_exists_in_dict}  Set To Dictionary  ${first_passed_run_dict}  ${alias}=False
    ${first_passed_run_alias}=  Get From Dictionary  ${first_passed_run_dict}  ${alias}

    ${snapshot_collect_condition1}=  Set Variable
    ...  ('${SnapshotTriggerEndTest}'=='YES' or '${TEST STATUS}'=='FAIL') and '${SNAPSHOT ON FAILURE}'=='YES'
    ${snapshot_collect_condition2}=  Set Variable
    ...  '${ENABLE_SNAPSHOT_FOR_PASSED_TC}' == 'ONE' and '${TEST STATUS}'=='PASS' and '${first_passed_run_alias}'=='False'
    ${snapshot_collect_condition3}=  Set Variable
    ...  '${ENABLE_SNAPSHOT_FOR_PASSED_TC}' == 'True' and '${TEST STATUS}'=='PASS'

    Run Keyword If  '${TEST STATUS}'=='PASS'  Set To Dictionary  ${first_passed_run_dict}  ${alias}=True

    Return From Keyword If
    ...  not (${snapshot_collect_condition1}) and not (${snapshot_collect_condition2}) and not (${snapshot_collect_condition3})

    ${status}=  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${snapshot_and_alarms_dir}
    Run Keyword If  not ${status}  Create Directory  ${snapshot_and_alarms_dir}

    Log  Final snapshot and alarms location for ${alias}: ${snapshot_and_alarms_dir}   console=True
	Log  Collect BTS ${alias} snapshot info:  console=True

    ${alias_tech}=  Get From Dictionary  ${${alias.upper()}}  ${alias.upper()}_TECH

    Run Keyword If  '${alias_tech}' != 'CBTS'
    ...  Collect BTS Snapshot based on SMODs status  folder_path=${${alias}_snapshot_and_alarms_dir}  alias=${alias}
    Run Keyword If  '${alias_tech}' == 'CBTS'  Run Keywords
    ...  Collect CU Snapshot  folder_path=${${alias}_snapshot_and_alarms_dir}  alias=${alias}
    ...  AND  Collect VDU Snapshot  folder_path=${${alias}_snapshot_and_alarms_dir}  alias=${alias}

Collect BTS Snapshot based on SMODs status
    [Documentation]
    ...  Collect SBTS Snapshot based on SMODs status will follow beneath steps:
    ...  - trigger snapshot collect by admin, then check BTS SMODs status:
    ...  1. BTS single core case:
    ...  - operationalState != enabled -> trigger snapshot collect by aashell
    ...  2. BTS dual core case:
    ...  - primary core operationalState == enabled and secondary core operationalState != enabled -> trigger snapshot collect by aashell on
    ...    secondary core
    ...  - primary core operationalState != enabled and secondary core operationalState != enabled -> trigger snapshot collect by aashell on
    ...    both primary and secondary core
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter   | Man. | Description                                        |
    ...  | folder_path | Yes  | Folder path where SBTS snapshot file will be saved |
    ...  | alias       | Yes  | BTS alias                                          |
    ...
    [Arguments]  ${folder_path}  ${alias}

    Snapshot collection on demand SOAM  folder_path=${folder_path}  alias=${alias}

    ${alias_SMOD_status_dict}=  Get SMODs status info  ${alias}
    ${alias_SMOD_count}=  Get Length  ${alias_SMOD_status_dict}

    ${alias_SMOD_status}=  Get From Dictionary  ${alias_SMOD_status_dict}  ${alias}
    Run Keyword If  ${alias_SMOD_count} == 1 and '${alias_SMOD_status}' != 'enabled'
    ...  Collect BTS snapshot via collectors aashell from all SMODs  alias=${alias}  target_dir=${folder_path}
    Return From Keyword If  ${alias_SMOD_count} == 1

    ${alias_ext_SMOD_status}=  Get From Dictionary  ${alias_SMOD_status_dict}  ${alias}_Ext
    Run Keyword If  '${alias_SMOD_status}' == 'enabled' and '${alias_ext_SMOD_status}' != 'enabled'
    ...  Collect BTS snapshot via collectors aashell from all SMODs  alias_ext=${alias}_Ext  target_dir=${folder_path}
    ...  ELSE IF  '${alias_SMOD_status}' != 'enabled' and '${alias_ext_SMOD_status}' != 'enabled'
    ...  Collect BTS snapshot via collectors aashell from all SMODs  alias=${alias}  alias_ext=${alias}_Ext  target_dir=${folder_path}

Snapshot collection on demand SOAM
    [Documentation]
    ...  Procedure for Snapshot collection as below:
    ...  - Snapshot file is stored at ${folder_path}
    ...  - check BTS Snapshot.zip file at Snapshot ${folder_path} path
    ...
    ...    *AUTHOR*
    ...    dinu.olariu@nokia.com / emanuel.szijj@nokia.com (SOAM)
    ...
    ...    | Parameter      | Man.  | Default | Description                                   |
    ...    | alias          | no    |         | Alias of admin instance                       |
    ...    | folder_path    | no    |         | Folder path for requested Snapshot collection |

    [Timeout]  30 min
    [Arguments]  ${alias}=default  ${folder_path}=/home/ute/btsauto/logs

    ${status}=  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${folder_path}
    Run Keyword If  not ${status}  Create Directory  ${folder_path}
    ${Snapshot_filename}=  Set Variable  ${alias}_snapshot.zip

    coam.Collect Snapshot  alias=${alias}  target_file_name=${folder_path}/${Snapshot_filename}  timeout=1260
    ${status}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${folder_path}/${Snapshot_filename}
    Run Keyword If  ${status}
    ...  Log  Snapshot file ${Snapshot_filename} available at ${folder_path}  level=INFO  console=True
    ...  ELSE  Run Keywords
    ...  Log  Snapshot file ${Snapshot_filename} not available at ${folder_path}  level=ERROR
    ...  AND  Fail  Snapshot file ${Snapshot_filename} not available at ${folder_path}
    [Return]  ${folder_path}  ${Snapshot_filename}

Collect CU Snapshot
    [Documentation]
    ...  Collect CBTS CU Snapshot
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter   | Man. | Description                                      |
    ...  | folder_path | Yes  | Folder path where CU snapshot file will be saved |
    ...  | alias       | Yes  | BTS alias                                        |
    ...
    [Arguments]  ${folder_path}  ${alias}

    ${CU_snapshot_folder_path}=  Set Variable  ${folder_path}/CU
    ${status}=  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${CU_snapshot_folder_path}
    Run Keyword If  not ${status}  Create Directory  ${CU_snapshot_folder_path}

    ${cu_alias}=  Set Variable  ${alias} CU

    ${cu_snapshot_status}=  cu.Check Snapshot Status  connection=${cu_alias}

    Run Keyword If  '${cu_snapshot_status}' != 'idle'  Wait Until Keyword Succeeds  3min  5s
    ...  Cancel CU collect snapshot  cu_alias=${cu_alias}

    ${cu_snapshot_operation_id}=  cu.Trigger Local Snapshot  connection=${cu_alias}
    Sleep  5s
    ${cu_snapshot_status}=  cu.Check Snapshot Status  connection=${cu_alias}
    Should Be Equal As Strings  ${cu_snapshot_status}  local-ongoing

    ${cu_snapshot_info}=  cu.Get Local Snapshot By Id  directory=${CU_snapshot_folder_path}  operation_id=${cu_snapshot_operation_id}
    ...  connection=${cu_alias}

    ${status}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${cu_snapshot_info}
    Run Keyword If  ${status}
    ...  Log  ${cu_alias} snapshot file available at ${cu_snapshot_info}  console=True
    ...  ELSE  Run Keywords
    ...  Log  ${cu_alias} snapshot file not available at ${CU_snapshot_folder_path}  level=ERROR
    ...  AND  Fail  ${cu_alias} snapshot file not available at ${CU_snapshot_folder_path}

Cancel CU collect snapshot
    [Arguments]  ${cu_alias}

    ${cu_snapshot_operation_status}  ${cu_snapshot_operation_info}=  Run Keyword And Ignore Error  cu.Get Snapshot Operations Information
    ...  connection=${cu_alias}
    Run Keyword If  '${cu_snapshot_operation_status}' == 'PASS'
    ...  cu.Cancel Snapshot Operation  operation_id=${cu_snapshot_operation_info}[0][operation_id]  connection=${cu_alias}

    Sleep  5s

    ${cu_snapshot_status}=  cu.Check Snapshot Status  connection=${cu_alias}
    Should Be Equal As Strings  ${cu_snapshot_status}  idle

Collect VDU Snapshot
    [Documentation]
    ...  Collect CBTS VDUs Snapshot
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter   | Man. | Description                 s                      |
    ...  | folder_path | Yes  | Folder path where VDUs snapshot file will be saved |
    ...  | alias       | Yes  | BTS alias           s                              |
    ...
    [Arguments]  ${folder_path}  ${alias}

    ${vdu_list}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_VDU]

    FOR  ${index}  ${vdu_info}  IN ENUMERATE  @{vdu_list}

        ${VDU_snapshot_folder_path}=  Set Variable  ${folder_path}/VDU${index+1}
        ${status}=  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${VDU_snapshot_folder_path}
        Run Keyword If  not ${status}  Create Directory  ${VDU_snapshot_folder_path}

        ${vdu_alias}=  Set Variable  ${alias} VDU${index+1}

        ${vdu_snapshot_status}=  vdu.Check Snapshot Status  vdu_connection=${vdu_alias}
        Run Keyword If  '${vdu_snapshot_status}' != 'idle'  Wait Until Keyword Succeeds  3min  5s
        ...  Cancel VDU collect snapshot  vdu_alias=${vdu_alias}

        ${vdu_snapshot_operation_id}=  vdu.Trigger Local Snapshot  vdu_connection=${vdu_alias}
        Sleep  5s
        ${vdu_snapshot_status}=  vdu.Check Snapshot Status  vdu_connection=${vdu_alias}
        Should Be Equal As Strings  ${vdu_snapshot_status}  local-ongoing

        ${vdu_snapshot_info}=  vdu.Check Local Snapshot Status And Save It  directory=${VDU_snapshot_folder_path}
        ...  operation_id=${vdu_snapshot_operation_id}  compressed_or_not=True  vdu_connection=${vdu_alias}

        ${status}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${vdu_snapshot_info}
        Run Keyword If  ${status}
        ...  Log  ${vdu_alias} snapshot file available at ${vdu_snapshot_info}  console=True
        ...  ELSE  Run Keywords
        ...  Log  ${vdu_alias} snapshot file not available at ${VDU_snapshot_folder_path}  level=ERROR
        ...  AND  Fail  ${vdu_alias} snapshot file not available at ${VDU_snapshot_folder_path}

    END

Cancel VDU collect snapshot
    [Arguments]  ${vdu_alias}

    ${vdu_snapshot_operation_status}  ${vdu_snapshot_operation_info}=  Run Keyword And Ignore Error  vdu.Get Snapshot Operations Information
    ...  vdu_connection=${vdu_alias}
    Run Keyword If  '${vdu_snapshot_operation_status}' == 'PASS'
    ...  vdu.Cancel Snapshot Operation  operation_id=${vdu_snapshot_operation_info}[0][operation_id]  vdu_connection=${vdu_alias}

    Sleep  5s

    ${vdu_snapshot_status}=  vdu.Check Snapshot Status  vdu_connection=${vdu_alias}
    Should Be Equal As Strings  ${vdu_snapshot_status}  idle

Get CBTS CU and VDUs Name Info
    [Documentation]
    ...  Get CBTS CU and VDUs site name info
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter   | Man. | Description |
    ...  | alias       | Yes  | BTS alias   |
    ...
    [Arguments]  ${alias}

    ${cu_alias}=  Set Variable  ${alias} CU

    ${CU_name}=  CU Get Name  connection=${cu_alias}

    Log  Site name - ${cu_alias} = ${CU_name}  console=True
    Set Tags  Site name - ${cu_alias} = ${CU_name}

    ${vdu_list}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_VDU]

    FOR  ${index}  ${vdu_info}  IN ENUMERATE  @{vdu_list}

        ${vdu_alias}=  Set Variable  ${alias} VDU${index+1}

        ${VDU_name}=  VDU Get Name  vdu_connection=${vdu_alias}

        Log  Site name - ${vdu_alias} = ${VDU_name}  console=True
        Set Tags  Site name - ${vdu_alias} = ${VDU_name}

    END

FHGW Snapshot

    ${FHGW_id_list}=  Get configured FHGW id list from init file
    ${FHGW_count}=  Get Length  ${FHGW_id_list}
    Return From Keyword If  ${FHGW_count} == 0

    Run Keyword And Return Status  Run Keyword If
    ...  ('${SnapshotTriggerEndTest}' == 'YES' or '${TEST STATUS}' == 'FAIL') and '${SNAPSHOT ON FAILURE}' == 'YES'
    ...  Save FHGW Snapshot  ${FHGW_id_list}

FHGW Setup Connection
    [Documentation]
    ...  Setup FHGW connection based on FHGW id info from init file.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Description                                         |
    ...  | FHGW_id   | Yes  | FHGW id as configured in init.py                    |
    ...  | prompt    | No   | SSH prompt, it supports regexp string, default is # |
    ...  | timeout   | No   | Timeout for the operation. Default value: 60 secs   |
    ...  | width     | No   | SSH window width, default is ${None}                |
    ...  | alias     | No   | FHGW connection instance alias, default is default  |
    ...
    [Arguments]  ${FHGW_id}  ${prompt}=#  ${timeout}=60  ${width}=${None}  ${alias}=default

    ${FHGW_ip}=  Get From Dictionary  ${INTERFACES['FHGW_${FHGW_id}']}  IP
    ${FHGW_port}=  Get From Dictionary  ${INTERFACES['FHGW_${FHGW_id}']}  PORT
    ${FHGW_username}=  Get From Dictionary  ${INTERFACES['FHGW_${FHGW_id}']}  USERNAME
    ${FHGW_password}=  Get From Dictionary  ${INTERFACES['FHGW_${FHGW_id}']}  PASSWORD

    ${FHGW_setup_status}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  5 min  10 sec
    ...  fhgw.Connect To  ip=${FHGW_ip}  username=${FHGW_username}  password=${FHGW_password}  port=${FHGW_port}  prompt=${prompt}  timeout=${timeout}
    ...  width=${width}  alias=${alias}

    Run Keyword If  ${FHGW_setup_status}
    ...  Log  Setup FHGW_${FHGW_id} (ip=${FHGW_ip}, port=${FHGW_port}) connection successfully performed!  console=True
    ...  ELSE  Run Keywords
    ...  Log  Setup FHGW_${FHGW_id} (ip=${FHGW_ip}, port=${FHGW_port}) connection failed!  level=ERROR
    ...  AND  Fail  Setup FHGW_${FHGW_id} (ip=${FHGW_ip}, port=${FHGW_port}) connection failed!

FHGW Teardown Connection
    [Documentation]
    ...  Teardown FHGW connection.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter | Man. | Description                                        |
    ...  | FHGW_id   | Yes  | FHGW id as configured in init.py                   |
    ...  | alias     | No   | FHGW connection instance alias, default is default |
    ...
    [Arguments]  ${FHGW_id}  ${alias}=default

    fhgw.Disconnect  alias=${alias}
    Log  Teardown FHGW_${FHGW_id} connection successfully performed!  console=True

Save FHGW Snapshot
    [Documentation]
    ...  Collect FHGW snapshot based on FHGW id info from init file.
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  | Parameter    | Man. | Description                              |
    ...  | FHGW_id_list | Yes  | List of FHGW id as configured in init.py |
    ...
    [Arguments]  ${FHGW_id_list}

    FOR  ${FHGW_id}  IN  @{FHGW_id_list}

        ${FHGW_alias}=  Set Variable  FHGW_${FHGW_id}

        FHGW Setup Connection  FHGW_id=${FHGW_id}  alias=${FHGW_alias}

        ${FHGW_snapshot_local_path}=  Set Variable  ${Test Results Dir}/FHGW_Snapshot/${FHGW_alias}/

        ${FHGW_snapshot_status}  ${FHGW_snapshot_info}=  Run Keyword And Ignore Error  fhgw.Fhgw Save Symptomreport  alias=${FHGW_alias}
        ...  download_path=${FHGW_snapshot_local_path}

        FHGW Teardown Connection  FHGW_id=${FHGW_id}  alias=${FHGW_alias}

        ${FHGW_snapshot_remote_path}  ${FHGW_snapshot_remote_file}=  Split Path  ${FHGW_snapshot_info}
        ${FHGW_snapshot_local_path_file}=  Join Path  ${FHGW_snapshot_local_path}  ${FHGW_snapshot_remote_file}
        ${status}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${FHGW_snapshot_local_path_file}
        Run Keyword If  ${status}
        ...  Log  FHGW_${FHGW_id} snapshot file available at ${FHGW_snapshot_local_path_file}  console=True
        ...  ELSE  Run Keywords
        ...  Log  FHGW_${FHGW_id} snapshot file not available at ${FHGW_snapshot_local_path}  level=ERROR
        ...  AND  Fail  FHGW_${FHGW_id} snapshot file not available at ${FHGW_snapshot_local_path}

    END

Get SiteName Info On All Sites SOAM
    [Documentation]
    ...  Helper keyword providing BTS SiteName info based on ADMIN
    ...
    ...  *AUTHOR*
    ...  ana.tugui@nokia.com

    [Arguments]  ${alias}

    Run Keyword If  '${${alias.upper()}}[${alias.upper()}_TECH]' in ['NR', 'LTE', 'SBTS', 'SRAN']  Admin Get BTS siteName information  ${alias}

Write alarms list to file
    [Arguments]  ${alarms_list}  ${alarms_file}
    FOR  ${alarm}  IN  @{alarms_list}
        ${alarm_String}=  Convert to string  ${alarm}
        Append To File  ${alarms_file}  ${alarm_String} \n\n
    END

Save active alarms from ADMIN to file
    [Documentation]
    ...  Keyword is used to get active alarms from ADMIN
    ...
    ...
    ...  *AUTHOR*
    ...  emanuel.szijj@nokia.com

    [Arguments]  ${alias}  ${folder_path}=${snapshot_and_alarms_dir}
    ${active_alarms}=  coam.Get Alarms  alias=${alias}
    ${active_alarms}=  Translate alarm dictionary  ${active_alarms}  ${TRANSLATED_ALARM}

    ${type_active_alarms}=  Evaluate  type($active_alarms).__name__
    ${file_location}=  Set Variable  ${folder_path}/${alias}_${${alias.upper()}}[${alias.upper()}_TECH]_active_alarms.txt

    Create File  ${file_location}
    Log  ${alias} active alarms available at: ${file_location}  console=True

    ${text_type_robot}=  Evaluate  six.text_type.__name__  modules=six

    Run Keyword If  ${type_active_alarms}==${text_type_robot}
    ...  Append To File  ${file_location}  ${active_alarms} \n\n
    ...  ELSE IF  ${type_active_alarms}==list  Write alarms list to file
    ...  ${active_alarms}  ${file_location}

Get BTS Information For Stop And Fix

    Log  Gathering entity module information for usage in Stop And Fix  console=True

    ${all_BTS_controller_role_RMOD_sn_list}=  Get all BTS controller role for configured RMOD from SCF
    ${all_BTS_controller_role_RMOD_sn_list}=  Replace VDU alias with CBTS alias  ${all_BTS_controller_role_RMOD_sn_list}  ${alias_list}
    ${rmod_alias_dict}=  Create all alias RMOD alias dict  ${all_BTS_controller_role_RMOD_sn_list}
    ${empty_fhs_list}=  Create List
    ${empty_bbmod_list}=  Create List
    ${empty_smod_list}=  Create List
    FOR  ${alias}  IN  @{alias_list}

        ${rmod_dict}=  Create one alias RMOD alias dict  ${all_BTS_controller_role_RMOD_sn_list}
        ...  ${rmod_alias_dict}  ${alias}
        ${fhs_dict}=  Run Keyword If  '${${alias.upper()}}[${alias.upper()}_TECH]' != 'CBTS'
        ...  Create one alias FHS alias dict  ${alias}
        ...  ELSE  Create Dictionary  FHS=${empty_fhs_list}
        ${smod_dict}=  Run Keyword If  '${${alias.upper()}}[${alias.upper()}_TECH]' != 'CBTS'
        ...  Create one alias smod dict  ${alias}
        ...  ELSE  Create Dictionary  SMOD=${empty_smod_list}
        ${bbmod_dict}=  Run Keyword If  '${${alias.upper()}}[${alias.upper()}_TECH]' != 'CBTS'
        ...  Create one alias bbmod dict  ${alias}
        ...  ELSE    Create Dictionary  BBMOD=${empty_bbmod_list}
        ${modules}=  Create Dictionary  &{rmod_dict}  &{fhs_dict}  &{smod_dict}  &{bbmod_dict}

        Set Test Variable  ${${alias}_modules}  ${modules}

    END

    FOR  ${alias}  IN  @{alias_list}

        ${status}  ${OAM_IP}=  Run Keyword If  '${${alias.upper()}}[${alias.upper()}_TECH]' != 'CBTS'
        ...  Run Keyword And Ignore Error  Get And Set OAM IP Address  ${alias}

    END

    Log  All entity module information gathered successfully  console=True

Replace VDU alias with CBTS alias
    [Arguments]  ${all_BTS_controller_role_RMOD_sn_list}  ${real_alias_list}

    ${new_BTS_controller_role_RMOD_sn_list}=  Create Dictionary
    ${sbts_vdu_aliases}=  Get Dictionary Keys  ${all_BTS_controller_role_RMOD_sn_list}
    ${sbts_cbts_aliases}=  Create List
    FOR  ${sbts_vdu_alias}  IN  @{sbts_vdu_aliases}
        ${possible_bts_alias_list}=  Split String  ${sbts_vdu_alias}
        ${length_alias_list}=  Get Length  ${possible_bts_alias_list}
        Run Keyword If  '${possible_bts_alias_list[${0}]}' in ${real_alias_list}
        ...  Append To List  ${sbts_cbts_aliases}  ${possible_bts_alias_list[${0}]}
        Set To Dictionary  ${new_BTS_controller_role_RMOD_sn_list}
        ...  ${possible_bts_alias_list[${0}]}=${all_BTS_controller_role_RMOD_sn_list['${sbts_vdu_alias}']}
    END
    [Return]  ${new_BTS_controller_role_RMOD_sn_list}

Create one alias smod dict
    [Arguments]    ${alias}

    ${smod_dict}=  Create Dictionary
    ${empty_smod_list}=  Create List
    ${smod_sn_list}=  Create List
    ${BTS_info}=  Get Bts Info  connection=${alias}
    ${BTS_info_smod_list}=  Get Variable Value  ${BTS_info['systemModules']}  ${empty_smod_list}

    FOR  ${item}  IN  @{BTS_info_smod_list}
        ${serialNumber_info}=  Get Variable Value  ${item['serialNumber']}  NA
        Append To List  ${smod_sn_list}  ${serialNumber_info}
    END
    ${smod_dict}=  Create Dictionary  SMOD=${smod_sn_list}

    [Return]    ${smod_dict}

Create one alias bbmod dict
    [Arguments]    ${alias}

    ${bbmod_dict}=  Create Dictionary
    ${empty_bbmod_list}=  Create List
    ${bbmod_sn_list}=  Create List
    ${BTS_info}=  Get Bts Info  connection=${alias}
    ${BTS_info_bbmod_list}=  Get Variable Value  ${BTS_info['basebandModules']}  ${empty_bbmod_list}

    FOR  ${item}  IN  @{BTS_info_bbmod_list}
        ${serialNumber_info}=  Get Variable Value  ${item['serialNumber']}  NA
        Append To List  ${bbmod_sn_list}  ${serialNumber_info}
    END
    ${bbmod_dict}=  Create Dictionary  BBMOD=${bbmod_sn_list}

    [Return]    ${bbmod_dict}

Create one alias FHS alias dict
    [Arguments]    ${alias}
    ${modules}=  Create Dictionary
    ${BTS_FHS_alias_connection_dict}  ${BTS_shared_FHS_id_sn_dict}  ${BTS_dedicated_FHS_id_sn_dict}  ${BTS_shared_FHS_sn_id_dict}
    ...  ${BTS_dedicated_FHS_sn_id_dict}=
    ...  Admin Get shared and dedicated module info for BTS  FHS  ${alias}

    Set To Dictionary  ${modules}  FHS=${BTS_FHS_alias_connection_dict}
    [Return]    ${modules}

Create one alias RMOD alias dict
    [Arguments]    ${all_BTS_controller_role_RMOD_sn_list}  ${rmod_alias_dict}  ${alias}
    ${rmods}=  Create RMOD List  ${all_BTS_controller_role_RMOD_sn_list}  ${alias}

    ${rmod_dict}=  Create Dictionary
    FOR  ${rmod}  IN  @{rmods}
        Set To Dictionary  ${rmod_dict}  ${rmod}  ${rmod_alias_dict['${rmod}']}
    END

    ${modules}=  Create Dictionary  RMOD=${rmod_dict}
    [Return]    ${modules}

Create RMOD list
    [Arguments]    ${all_BTS_controller_role_RMOD_sn_list}  ${alias}
    ${rmod_list}=  Create List
    ${alias_list_from_dict}=  Get Dictionary Keys  ${all_BTS_controller_role_RMOD_sn_list}
    FOR  ${alias_dict}  IN  @{alias_list_from_dict}
        Run Keyword If  '${alias}' in '${alias_dict}'
        ...  Append To List  ${rmod_list}  @{all_BTS_controller_role_RMOD_sn_list['${alias_dict}']['BTS_primary_controller_RMOD_sn_list']}
        ...  @{all_BTS_controller_role_RMOD_sn_list['${alias_dict}']['BTS_secondary_controller_RMOD_sn_list']}
    END
    [Return]    ${rmod_list}

Create all alias RMOD alias dict
    [Arguments]  ${all_BTS_controller_role_RMOD_sn_list}
    ${result}=  Create Dictionary
    ${aliases}=  Get Dictionary Keys  ${all_BTS_controller_role_RMOD_sn_list}

    FOR  ${alias}  IN  @{aliases}

        ${rmod_sns}=  Create List  @{all_BTS_controller_role_RMOD_sn_list['${alias}']['BTS_primary_controller_RMOD_sn_list']}
        ...  @{all_BTS_controller_role_RMOD_sn_list['${alias}']['BTS_secondary_controller_RMOD_sn_list']}

        ${rmod_dict_for_one_alias}=  Create RMOD Dict For One Alias  ${alias}  ${rmod_sns}
        ${result}=  Add alias info to RMOD dict  ${rmod_dict_for_one_alias}  ${result}

    END
    [Return]  ${result}

Create RMOD dict for one alias
    [Arguments]  ${alias}  ${rmod_list}
    ${result}=  Create Dictionary
    FOR  ${rmod}  IN  @{rmod_list}
        Set To Dictionary  ${result}  ${rmod}=${alias}
    END
    [Return]  ${result}

Add Alias Info To RMOD Dict
    [Arguments]  ${rmod_dict}  ${result}

    ${rmod_list}=  Get Dictionary Keys  ${rmod_dict}
    FOR  ${rmod}  IN  @{rmod_list}
        ${empty_list}=  Create List
        ${rmod_aliases}=  Pop From Dictionary  ${result}  ${rmod}  ${empty_list}
        Append To List  ${rmod_aliases}  ${rmod_dict['${rmod}']}
        Set To Dictionary  ${result}  ${rmod}  ${rmod_aliases}
    END
    [Return]  ${result}

Collect Logs by Stop And Fix Criteria

    ${do_stop_and_fix_checks}=  Check Stop And Fix User Flags

    ${STOP_AND_FIX_conditions_detected}=  Stop And Fix Conditions Checks
    ...  do_stop_and_fix_checks=${do_stop_and_fix_checks}  end_counter=${1}

    Update TC Status Based On Stop And Fix Checks  ${STOP_AND_FIX_conditions_detected}

    Log Stop And Fix Options To Console  ${STOP_AND_FIX_conditions_detected}  ${USER_STOP_AND_FIX_BLOCK_TEST}

    Collect logs  ${STOP_AND_FIX_conditions_detected}

    ${STOP_AND_FIX_conditions_detected}=  Stop And Fix Conditions Checks
    ...  do_stop_and_fix_checks=${do_stop_and_fix_checks}  previous_stop_and_fix_results=${STOP_AND_FIX_conditions_detected}
    ...  start_counter=${1}  end_counter=${7}

    Perform Recovery Of Failed Items  ${STOP_AND_FIX_conditions_detected}  ${alias_list}

    ${RMOD_VM_mapping_dict}=  Create Dictionary

    FOR  ${RMOD_SN}  IN  @{RMOD_SN_list}
        FOR  ${alias}  IN  @{alias_list}
            ${alias_rmodules_keys}=  Get Dictionary Keys  ${${alias}_modules['RMOD']}
            Continue For Loop If  '${RMOD_SN}' not in ${alias_rmodules_keys}

            ${alias_upper}=  Convert to Uppercase  ${alias}
            ${cond1}=  Create Long String  '${RMOD_SN}' not in ${RMOD_VM_mapping_dict}
            ${cond2}=  Create Long String  ('${RMOD_SN}' in ${RMOD_VM_mapping_dict}) and ('${RMOD_SN}' not in
            ...  ${STOP_AND_FIX_conditions_detected['${alias}']['HW_MODULES_NOT_OPERATIONAL_DICT']['RMOD']})

            Run Keyword If  (${cond1} or ${cond2}) and 'MASTER' in '${alias_upper}'
            ...  Set To Dictionary  ${RMOD_VM_mapping_dict}  ${RMOD_SN}=local
            Run Keyword If  (${cond1} or ${cond2}) and 'MASTER' not in '${alias_upper}'
            ...  Set To Dictionary  ${RMOD_VM_mapping_dict}  ${RMOD_SN}=${${alias_upper}}[${alias_upper}_PC_IP_ADDRESS]
        END
    END

    FOR  ${RMOD_SN}  IN  @{RMOD_SN_list}
        Run Keyword If  '${RMOD_VM_mapping_dict['${RMOD_SN}']}'=='local'
        ...  RSI Transfer RMOD Snapshot To VM  ${RMOD_SN}
        ...  ELSE  RSI Transfer RMOD Snapshot To VM  ${RMOD_SN}  ${RMOD_VM_mapping_dict['${RMOD_SN}']}
    END

    Send Stop And Fix Mail  ${STOP_AND_FIX_conditions_detected}

    [Return]  ${STOP_AND_FIX_conditions_detected}

Send Stop And Fix Mail
    [Arguments]    ${STOP_AND_FIX_conditions_detected}
    Run Keyword If  ${STOP_AND_FIX_conditions_detected['STOP_AND_FIX_NEEDED']}  Send Stop and Fix Notification

Stop And Fix Conditions Checks
    [Arguments]  ${do_stop_and_fix_checks}  ${previous_stop_and_fix_results}=${None}  ${start_counter}=${0}  ${end_counter}=${7}

    ${sleep_size}=  Set Variable  5min

    ${previous_stop_and_fix_needed}=  Set Variable If  ${previous_stop_and_fix_results}
    ...  ${previous_stop_and_fix_results['STOP_AND_FIX_NEEDED']}
    ...  ${True}

    ${HW_MODULES_NOT_OPERATIONAL_DICT}=  Create Dictionary
    ...  SMOD=@{Empty}
    ...  BBMOD=@{Empty}
    ...  FHS=@{Empty}
    ...  RMOD=@{Empty}

    ${result_dict}=  Create Dictionary
    ...  LMP_REACHABLE=${True}
    ...  MPLANE_REACHABLE=${True}
    ...  ADMIN_LMP_WORKING=${True}
    ...  ADMIN_MPLANE_WORKING=${True}
    ...  ALARM_NOT_FOUND=${True}
    ...  HW_MODULES_NOT_OPERATIONAL_DICT=${HW_MODULES_NOT_OPERATIONAL_DICT}
    ...  PEER_BTS_LIST=@{EMPTY}

    ${STOP_AND_FIX_conditions_detected}=  Create Dictionary
    ...  STOP_AND_FIX_NEEDED=${False}

    FOR  ${alias}  IN  @{alias_list}
        Set To Dictionary  ${STOP_AND_FIX_conditions_detected}  ${alias}  ${result_dict}
    END

    Return From Keyword If  not (${do_stop_and_fix_checks} and ${previous_stop_and_fix_needed})
    ...  ${STOP_AND_FIX_conditions_detected}

    FOR  ${index}  IN RANGE  ${start_counter}  ${end_counter}
        Log  **********************************************************  console=True
        Log  ***** Detect Stop and Fix conditions: ${index+1} try *****  console=True
        Log  **********************************************************  console=True

        ${STOP_AND_FIX_conditions_detected}=
        ...  Detect Stop and Fix conditions  ${alias_list}  ${STOP_AND_FIX_conditions_detected}

        Exit For Loop If  not ${STOP_AND_FIX_conditions_detected['STOP_AND_FIX_NEEDED']}
        Run Keyword If  ${index} < ${end_counter} - ${1}  Run Keywords
        ...  Log  ***** Stop and Fix condition has been detected. Waiting for 5min before next try *****  console=True
        ...  AND  Sleep  ${sleep_size}
    END

    [Return]    ${STOP_AND_FIX_conditions_detected}

Log Stop And Fix Options To Console
    [Arguments]    ${STOP_AND_FIX_conditions_detected}  ${USER_STOP_AND_FIX_BLOCK_TEST}

    Run Keyword If  ${STOP_AND_FIX_conditions_detected['STOP_AND_FIX_NEEDED']} and ${USER_STOP_AND_FIX_BLOCK_TEST}  Run Keywords
    ...  Log  ===========================================================================================  console=True
    ...  AND  Log  ===== Detect Stop and Fix conditions: TRUE -> Stop and Fix actions will be triggered! =====  console=True
    ...  AND  Log  ===========================================================================================  console=True
    ...  AND  Log  Notification will be sent to RFS Tribe email adress and dedicated Teams channel!  console=True
    ...  ELSE IF  ${STOP_AND_FIX_conditions_detected['STOP_AND_FIX_NEEDED']} and not ${USER_STOP_AND_FIX_BLOCK_TEST}  Run Keywords
    ...  Log  ===========================================================================================  console=True
    ...  AND  Log Long String  ===== Detect Stop and Fix conditions: TRUE -> Stop and Fix actions will be triggered but
    ...  test execution will not be blocked! =====  console=True
    ...  AND  Log  ===========================================================================================  console=True
    ...  AND  Log  Notification will be sent to RFS Tribe email adress and dedicated Teams channel!  console=True
    ...  AND  Log  Collect Stop and Fix logs  console=True
    ...  ELSE  Run Keywords
    ...  Log  ===============================================================================================  console=True
    ...  AND  Log  ===== Detect Stop and Fix conditions: FALSE -> no Stop and Fix actions will be triggered! =====  console=True
    ...  AND  Log  ===============================================================================================  console=True

Check Stop And Fix User Flags

    Log  Stop and Fix flags  console=True

    ${status_setup}=  Get Variable Value  ${COMMON TEST SETUP STATUS}  FAIL
    Run Keyword If  '${status_setup}' == 'FAIL'  Run Keywords
    ...  Log  Stop and Fix procedure skipped due to Common Test Setup execution status ${status_setup}!  console=True
    ...  AND  Set Test Variable  ${USER_STOP_AND_FIX_BLOCK_TEST}  ${FALSE}
    ...  AND  Return From Keyword  ${False}

    Run Keyword If  not ${USER_STOP_AND_FIX}  Run Keywords
    ...  Log  Stop and Fix procedure skipped by user: USER_STOP_AND_FIX = False  console=True
    ...  AND  Set Test Variable  ${USER_STOP_AND_FIX_BLOCK_TEST}  ${FALSE}
    ...  AND  Return From Keyword  ${False}

    [Return]  ${True}

Detect Stop and Fix conditions
    [Arguments]    ${alias_list}  ${STOP_AND_FIX_conditions_detected}

    Set To Dictionary  ${STOP_AND_FIX_Conditions_detected}  STOP_AND_FIX_NEEDED  ${False}

    FOR  ${alias}  IN  @{alias_list}

        Log  ***** Detect Stop and Fix conditions for BTS ${alias} *****  console=True

        ${STOP_AND_FIX_conditions_detected}=
        ...  Run Keyword If  '${${alias.upper()}}[${alias.upper()}_TECH]' == 'CBTS'
        ...  Check Stop And Fix Conditions For CBTS  alias=${alias}  STOP_AND_FIX_conditions_detected=${STOP_AND_FIX_conditions_detected}
        ...  ELSE  Check Stop And Fix Conditions For SBTS  alias=${alias}  STOP_AND_FIX_conditions_detected=${STOP_AND_FIX_conditions_detected}

    END

    [Return]  ${STOP_AND_FIX_conditions_detected}

Check Stop And Fix Conditions For SBTS
    [Arguments]    ${alias}  ${STOP_AND_FIX_conditions_detected}
    ${mplane_admin_alias}=  Set Variable  ${None}

    Log  Check BTS ${alias} LMP IP reachability:  console=True
    ${BTS_LMP_IP_reachable_check}  ${LMP_IP}=  Check BTS LMP IP is reachable  ${alias}

    Log  Check BTS ${alias} MPLANE IP reachability:  console=True
    ${BTS_MPLANE_IP_reachable_check}  ${MPLANE_IP}=  Check BTS MPLANE IP is reachable  ${alias}

    ${mplane_admin_alias}=  Establish mplane session for checks  ${MPLANE_IP}  mplane_alias

    Log  Check BTS ${alias} Admin Response:  console=True
    ${STOP_AND_FIX_admin_lmp_working_check}=
    ...  Check BTS Admin Response  alias=${alias}  ip_valid=${BTS_LMP_IP_reachable_check}

    Log  Check BTS MPLANE ${mplane_admin_alias} Admin Response:  console=True
    ${STOP_AND_FIX_admin_mplane_working_check}=
    ...  Check BTS Admin Response  alias=${mplane_admin_alias}  ip_valid=${BTS_MPLANE_IP_reachable_check}

    ${admin_alias_for_checks}=  Choose alias for checks
    ...  ${STOP_AND_FIX_admin_lmp_working_check}  ${alias}
    ...  ${STOP_AND_FIX_admin_mplane_working_check}  ${mplane_admin_alias}

    Log  Check BTS ${alias} Stop and Fix alarms status:  console=True
    ${status_alarm_check}  ${STOP_AND_FIX_alarm_not_found}=  Run Keyword And Ignore Error
    ...  Check SBTS stop and fix alarms status  alias=${admin_alias_for_checks}
    ...  STOP_AND_FIX_admin_mplane_working_check=${STOP_AND_FIX_admin_mplane_working_check}
    ...  BTS_MPLANE_IP_reachable_check=${BTS_MPLANE_IP_reachable_check}

    Log  Check BTS ${alias} HW modules operational state:  console=True
    ${status_module_state_check}  ${KW_output}=  Run Keyword And Ignore Error
    ...  Check SBTS HW modules operational state  exp_operationalState=${Enabled_}  admin_alias_for_checks=${admin_alias_for_checks}
    ...  current_bts_alias=${alias}  modules_dict=${${alias}_modules}
    ${SMOD_disabled_list}=  Set Variable  ${KW_output[${0}]}
    ${BBMOD_disabled_list}=  Set Variable  ${KW_output[${1}]}
    ${FHS_disabled_list}=  Set Variable  ${KW_output[${2}]}
    ${RMOD_disabled_list}=  Set Variable  ${KW_output[${3}]}
    ${peer_alias_list}=  Set Variable  ${KW_output[${4}]}

    ${status_close_session}=  Run Keyword And Return Status  Close mplane session for checks  alias=${mplane_admin_alias}

    ${HW_MODULES_NOT_OPERATIONAL_DICT}=  Create Dictionary
    ...  SMOD=${SMOD_disabled_list}
    ...  BBMOD=${BBMOD_disabled_list}
    ...  FHS=${FHS_disabled_list}
    ...  RMOD=${RMOD_disabled_list}

    ${result_dict}=  Create Dictionary
    ...  LMP_REACHABLE=${BTS_LMP_IP_reachable_check}
    ...  MPLANE_REACHABLE=${BTS_MPLANE_IP_reachable_check}
    ...  ADMIN_LMP_WORKING=${STOP_AND_FIX_admin_lmp_working_check}
    ...  ADMIN_MPLANE_WORKING=${STOP_AND_FIX_admin_mplane_working_check}
    ...  ALARM_NOT_FOUND=${STOP_AND_FIX_alarm_not_found}
    ...  HW_MODULES_NOT_OPERATIONAL_DICT=${HW_MODULES_NOT_OPERATIONAL_DICT}
    ...  PEER_BTS_LIST=${peer_alias_list}

    ${STOP_AND_FIX_needed}=  Check If Stop And Fix Needed
    ...  ${BTS_LMP_IP_reachable_check}  ${BTS_MPLANE_IP_reachable_check}
    ...  ${STOP_AND_FIX_admin_lmp_working_check}  ${STOP_AND_FIX_admin_mplane_working_check}
    ...  ${STOP_AND_FIX_alarm_not_found}  ${HW_MODULES_NOT_OPERATIONAL_DICT}
    ...  ${STOP_AND_FIX_conditions_detected['STOP_AND_FIX_NEEDED']}

    Set To Dictionary  ${STOP_AND_FIX_conditions_detected}
    ...  ${alias}=${result_dict}
    ...  STOP_AND_FIX_NEEDED=${STOP_AND_FIX_needed}

    [Return]  ${STOP_AND_FIX_conditions_detected}

Check Stop And Fix Conditions For CBTS
    [Arguments]    ${alias}  ${STOP_AND_FIX_conditions_detected}

    Log  Check CBTS ${alias} MPLANE IP reachability:  console=True
    ${reachability_check_result}=  Check CBTS MPLANE IP is reachable  alias=${alias}
    ${BTS_MPLANE_IP_reachable_check}=  Evaluate  all(${reachability_check_result})

    Log  Check CBTS VCU, VDU MPLANE Admin Response:  console=True
    ${STOP_AND_FIX_admin_mplane_working_check}=  Check CBTS Admin Response  alias=${alias}  reachability_check_result=${reachability_check_result}

    Log  Check CBTS ${alias} Stop and Fix alarms status:  console=True
    ${status_alarm_check}  ${STOP_AND_FIX_alarm_not_found}=  Run Keyword And Ignore Error
    ...  Check CBTS stop and fix alarms status  alias=${alias}
    ...  STOP_AND_FIX_admin_mplane_working_check=${STOP_AND_FIX_admin_mplane_working_check}
    ...  BTS_MPLANE_IP_reachable_check=${BTS_MPLANE_IP_reachable_check}

    Log  Check CBTS ${alias} HW modules operational state:  console=True
    ${status_module_state_check}  ${KW_output}=  Run Keyword And Ignore Error
    ...  Check CBTS HW modules operational state  exp_operationalState=${Enabled_}  alias=${alias}  shared_module_peers_dict=${${alias}_modules}
    ${RMOD_disabled_list}=  Set Variable  ${KW_output[${0}]}
    ${peer_alias_list}=  Set Variable  ${KW_output[${1}]}

    ${HW_MODULES_NOT_OPERATIONAL_DICT}=  Create Dictionary
    ...  RMOD=${RMOD_disabled_list}

    ${result_dict}=  Create Dictionary
    ...  MPLANE_REACHABLE=${BTS_MPLANE_IP_reachable_check}
    ...  ADMIN_MPLANE_WORKING=${STOP_AND_FIX_admin_mplane_working_check}
    ...  ALARM_NOT_FOUND=${STOP_AND_FIX_alarm_not_found}
    ...  HW_MODULES_NOT_OPERATIONAL_DICT=${HW_MODULES_NOT_OPERATIONAL_DICT}
    ...  PEER_BTS_LIST=${peer_alias_list}

    ${STOP_AND_FIX_needed}=  Check If Stop And Fix Needed
    ...  ${True}  ${BTS_MPLANE_IP_reachable_check}
    ...  ${True}  ${STOP_AND_FIX_admin_mplane_working_check}
    ...  ${STOP_AND_FIX_alarm_not_found}  ${HW_MODULES_NOT_OPERATIONAL_DICT}
    ...  ${STOP_AND_FIX_conditions_detected['STOP_AND_FIX_NEEDED']}

    Set To Dictionary  ${STOP_AND_FIX_conditions_detected}
    ...  ${alias}=${result_dict}
    ...  STOP_AND_FIX_NEEDED=${STOP_AND_FIX_needed}

    [Return]  ${STOP_AND_FIX_conditions_detected}

Check if stop and fix needed
     [Arguments]  ${BTS_LMP_IP_reachable_check}  ${BTS_MPLANE_IP_reachable_check}
     ...  ${STOP_AND_FIX_admin_lmp_working_check}  ${STOP_AND_FIX_admin_mplane_working_check}
     ...  ${STOP_AND_FIX_alarm_not_found}  ${HW_MODULES_NOT_OPERATIONAL_DICT}  ${previous_stop_and_fix_needed}

     ${hw_modules_found_disabled}=  Evaluate  any ([aliases for aliases in ${HW_MODULES_NOT_OPERATIONAL_DICT}.values()])
     ${result}=  Create Long String
     ...  not (${BTS_LMP_IP_reachable_check} and ${BTS_MPLANE_IP_reachable_check}
     ...  and ${STOP_AND_FIX_admin_lmp_working_check} and ${STOP_AND_FIX_admin_mplane_working_check}
     ...  and ${STOP_AND_FIX_alarm_not_found} and (not ${hw_modules_found_disabled}) and not ${previous_stop_and_fix_needed})
     ${result}=  Evaluate  ${result}

     [Return]  ${result}

Update TC Status Based On Stop And Fix Checks
    [Arguments]    ${STOP_AND_FIX_conditions_detected}

    Run Keyword If  ${STOP_AND_FIX_conditions_detected['STOP_AND_FIX_NEEDED']} and '${TEST STATUS}'=='PASS'
    ...  Run Keywords
    ...  Log  Stop And Fix conditions detected  level=Error
    ...  AND  Set Test Variable  ${SnapshotTriggerEndTest}  YES
    ...  AND  Fail  Stop And Fix conditions detected

Establish mplane session for checks
    [Arguments]  ${MPLANE_IP}  ${mplane_alias}

    Run Keyword If  '${MPLANE_IP}' == '${None}'
    ...  Run Keywords
    ...  Log  Could not start mplane admin for Stop And Fix checks  console=True
    ...  AND  Return From Keyword  ${None}

    Run Keyword And Return Status  coam.Teardown Admin  alias=${mplane_alias}

    ${status}=  Run Keyword And Return Status
    ...  Start ADMIN On External BTS  ${MPLANE_IP}  ${mplane_alias}
    Run Keyword If  ${status}
    ...  Run Keywords
    ...  Log  Started mplane admin for Stop And Fix checks  console=True
    ...  AND  Return From Keyword  ${mplane_alias}
    ...  ELSE  Run Keywords
    ...  Log  Could not start mplane admin for Stop And Fix checks  console=True
    ...  AND  Return From Keyword  ${None}

Close mplane session for checks
     [Arguments]  ${alias}

     Run Keyword If  '${alias}'  Run Keywords
     ...  Teardown admin  alias=${alias}
     ...  AND  Log  Closed mplane admin for Stop And Fix checks  console=True

Choose alias for checks
     [Arguments]  ${STOP_AND_FIX_admin_lmp_response}  ${alias}
     ...  ${STOP_AND_FIX_admin_mplane_response}  ${mplane_admin_alias}

     Run Keyword If  ${STOP_AND_FIX_admin_lmp_response}
     ...  Return From Keyword  ${alias}
     ...  ELSE IF  ${STOP_AND_FIX_admin_mplane_response}
     ...  Return From Keyword  ${mplane_admin_alias}
     ...  ELSE  Return From Keyword  ${None}

Get Peer List
    [Arguments]  ${shared_modules_peer_dict}

    ${peer_list}=  Create List
    ${fhs_dict}=  Get From Dictionary  ${shared_modules_peer_dict}  FHS
    ${rmod_dict}=  Get From Dictionary  ${shared_modules_peer_dict}  RMOD
    ${fhs_peers}=  Get Dictionary Values  ${fhs_dict}
    ${rmod_peers}=  Get Dictionary Values  ${rmod_peers}
    ${peer_list}=  Evaluate
    ...  [item for rmod_peer in ${rmod_peers} for item in rmod_peer] + [item for fhs_peer in ${fhs_peers} for item in fhs_peer]
    ${peer_list}=  Remove Duplicates  ${peer_list}

    [Return]  ${peer_list}

RMODs snapshot trigger through serial interface
    [Arguments]  ${RMOD_SN_list}  ${reset_rmod}=${False}  ${stop_and_fix}=${False}

    Run Keyword If  not ${RMOD_SN_list}  Return From Keyword

    Run Keyword If  not ${USER_RSI_INFO_COLLECT}  Run Keywords
    ...  Log  RMODs serial interface logs collect skipped by user: USER_RSI_INFO_COLLECT = False  console=True
    ...  AND  Return From Keyword

    ${rsi_config_file_check}=  Get Variable Value  ${RSI_config_type}  ${Empty}
    Run Keyword If  '${rsi_config_file_check}' != 'init'  Run Keywords
    ...  Log  RMODs serial interface logs collect skipped due to improper config:  console=True
    ...  AND  Log  missing rsi information in __init__.py !  console=True
    ...  AND  Return From Keyword

    Run Keyword If  not ${rsi_rmod_setup_list}  Run Keywords
    ...  Log  RMODs serial interface logs collect skipped due to improper config:  console=True
    ...  AND  Log  incorrect lmi.uart_mapping info in __init__.py file for all RMODs  console=True
    ...  AND  Return From Keyword

    Run Keyword If  ${rsi_rmod_setup_count} == 0  Run Keywords
    ...  Log  RMODs serial interface logs collect skipped due to failed setup on all RMODs!  console=True
    ...  AND  Return From Keyword

     ${rsi_rmod_sn_snapshot_path_dict}=  Rsi Snapshot Collect  rsi_folder=${Test Results Dir}/RSILogs  rmod_sn_list=${RMOD_SN_list}
     ...  rsi_rmod_setup_list=${rsi_rmod_setup_list}  reset_rmod=${reset_rmod}  stop_and_fix=${stop_and_fix}
     ...  timeout=240

    Log  - RMODs snapshot collected through serial interface: ${rsi_rmod_sn_snapshot_path_dict}  console=True

    [Return]  ${rsi_rmod_sn_snapshot_path_dict}

Collect logs
    [Arguments]    ${STOP_AND_FIX_conditions_detected}

    Collect Rmod Serial Logs For Stop And Fix  STOP_AND_FIX_conditions_detected=${STOP_AND_FIX_conditions_detected}
    ...  alias_list=${alias_list}  stop_and_fix=${USER_STOP_AND_FIX_BLOCK_TEST}

    ${aliases_priority_ordered_list}=  Get priority ordered alias list  ${STOP_AND_FIX_conditions_detected}  ${alias_list}

    FOR  ${alias}  IN  @{aliases_priority_ordered_list}

        Snapshot collection with timestamp SOAM CBTS  alias=${alias}

    END
    FOR  ${alias}  IN  @{alias_list}

        Run Keyword If  '${${alias.upper()}}[${alias.upper()}_TECH]' == 'CBTS'
        ...  Collect Remaining Logs For CBTS  ${alias}  ${${alias}_snapshot_and_alarms_dir}
        ...  ELSE  Collect Remaining Logs For Admin BTS  ${alias}  ${${alias}_snapshot_and_alarms_dir}

    END

Collect Rmod Serial Logs For Stop And Fix
    [Arguments]    ${STOP_AND_FIX_conditions_detected}  ${alias_list}  ${reset_rmod}=${False}  ${stop_and_fix}=${False}

    Set Test Variable  ${rsi_rmod_sn_snapshot_path_dict}  &{Empty}
    ${RMOD_SN_list}=  Create List
    Set Test Variable  ${RMOD_SN_list}
    Return From Keyword If  not ${STOP_AND_FIX_conditions_detected['STOP_AND_FIX_NEEDED']}

    Log  ***** Trigger serial RMOD logs capture *****  console=True
    ${RMOD_SN_list}=  Get Rmod SN For Stop And Fix  ${STOP_AND_FIX_conditions_detected}  ${alias_list}
    ${rsi_rmod_sn_snapshot_path_dict}=  RMODs Snapshot Trigger Through Serial Interface
    ...  RMOD_SN_list=${RMOD_SN_list}  reset_rmod=${reset_rmod}  stop_and_fix=${stop_and_fix}
    Set Test Variable  ${rsi_rmod_sn_snapshot_path_dict}
    Set Test Variable  ${RMOD_SN_list}

Collect Remaining Logs For Admin BTS
    [Arguments]    ${alias}    ${snapshot_and_alarms_dir}

    IF    ('${SnapshotTriggerEndTest}'=='YES' or '${TEST STATUS}'=='FAIL') and '${SNAPSHOT ON FAILURE}'=='YES'
        Log    ***** Collect BTS ${alias} active alarms info: *****    console=True
        Save active alarms from ADMIN to file    alias=${alias}    folder_path=${snapshot_and_alarms_dir}
    END

    IF    ('${SnapshotTriggerEndTest}'=='YES' or '${TEST STATUS}'=='FAIL') and '${SNAPSHOT ON FAILURE}'=='YES'
        Log    ***** Collect BTS ${alias} historic alarms info: *****    console=True
        Get Historic Alarms from Admin    alias=${alias}    folder_path=${snapshot_and_alarms_dir}
    END

    Log    ***** Collect BTS ${alias} ims info: *****    console=True
    coam.Collect Infomodel Log From Current Session    target_file_name=${Test Results Dir}/IMS/${alias}/IM_admin.ims2
    ...    timeout=180    connection=${alias}

    Log    ***** Collect BTS ${alias} udp info: *****    console=True
    Collect Syslog On    ${alias}    folder_path=${UDP Logs}
    IF    '${alias}_Ext' in ${alias_list_complete}
        Collect Syslog On    alias=${alias}_Ext    folder_path=${UDP Logs}
    END

    Log    ***** Collect BTS ${alias} swconfig file, blackbox file: *****    console=True
    ${swconfig_path_file_list}=    Save BTS File    ${alias}    swconfig    /ffs/run/swconfig.txt    BTS_destination_path=${BTSFiles}/${alias}
    Check if BTS File Exists    ${alias}    swconfig    ${swconfig_path_file_list}
    ${blackbox_path_file_list}=    Save BTS File    ${alias}    blackbox blackbox1    /rom/logs/lifetimedata/blackbox /rom/config/lifedata/blackbox
    ...    BTS_destination_path=${BTSFiles}/${alias}
    Check if BTS File Exists    ${alias}    blackbox    ${blackbox_path_file_list}

    Log    ***** Get BTS ${alias} site name: *****    console=True
    Get SiteName Info On All Sites SOAM    ${alias}

Collect Remaining Logs For CBTS
    [Arguments]  ${alias}  ${snapshot_and_alarms_dir}

    Run Keyword If
    ...  ('${SnapshotTriggerEndTest}'=='YES' or '${TEST STATUS}'=='FAIL') and '${SNAPSHOT ON FAILURE}'=='YES'
    ...  Run Keywords
    ...  Get CU Active And Historical Alarms  folder_path=${snapshot_and_alarms_dir}  alias=${alias}
    ...  AND  Get VDU Active And Historical Alarms  folder_path=${snapshot_and_alarms_dir}  alias=${alias}
    Get CBTS CU and VDUs Name Info  ${alias}

Get Rmod SN For Stop And Fix
    [Arguments]  ${STOP_AND_FIX_conditions_detected}  ${all_aliases}
    ${SN_list}=  Create List
    ${aliases}=  Get Dictionary Keys  ${STOP_AND_FIX_conditions_detected}
    ${aliases}=  Evaluate  [x for x in ${aliases} if x in ${all_aliases}]
    FOR  ${alias_item}  IN  @{aliases}
        Append To List  ${SN_list}  @{STOP_AND_FIX_conditions_detected['${alias_item}']['HW_MODULES_NOT_OPERATIONAL_DICT']['RMOD']}
    END
    ${SN_list}=  Remove Duplicates  ${SN_list}
    [Return]  ${SN_list}

Get priority ordered alias list
    [Arguments]  ${STOP_AND_FIX_conditions_detected}  ${all_aliases}
    ${priority_ordered_alias_list}=  Create List
    ${aliases}=  Get Dictionary Keys  ${STOP_AND_FIX_conditions_detected}
    ${aliases}=  Evaluate  [x for x in ${aliases} if x in ${all_aliases}]
    FOR  ${alias_item}  IN  @{aliases}
        Append To List  ${priority_ordered_alias_list}  @{STOP_AND_FIX_conditions_detected['${alias_item}']['PEER_BTS_LIST']}
    END
    Append To List  ${priority_ordered_alias_list}  @{all_aliases}
    ${priority_ordered_alias_list}=  Remove Duplicates  ${priority_ordered_alias_list}
    [Return]    ${priority_ordered_alias_list}

Check BTS LMP IP is reachable
    [Arguments]  ${alias}
    ${Return_Results}=  Create List
    ${BTS_LMP_IP_address}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]
    ${remote_host_ip}=  Set Variable If  '${alias}' == 'Master'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]
    ${BTS_LMP_IP_reachable_check}=  Run Keyword And Return Status
    ...  Wait For Target To Be Reachable TAF  hostname=${BTS_LMP_IP_address}  remote_host=${remote_host_ip}  timeout=30

    Run Keyword If  ${BTS_LMP_IP_reachable_check}  Run Keywords
    ...  Log  - BTS ${alias} LMP IP ${BTS_LMP_IP_address} is reachable  console=True
    ...  AND  Append To List  ${Return_Results}  ${BTS_LMP_IP_reachable_check}  ${BTS_LMP_IP_address}
    ...  ELSE  Run Keywords
    ...  Log  - BTS ${alias} LMP IP ${BTS_LMP_IP_address} is not reachable -> Stop and Fix condition  console=True
    ...  AND  Append To List  ${Return_Results}  ${BTS_LMP_IP_reachable_check}  ${None}

    [Return]  @{Return_Results}

Check BTS MPLANE IP is reachable
    [Arguments]  ${alias}
    ${return_results}=  Create List
    ${oam_address}=  Get Variable Value  ${${alias.upper()}}[${alias.upper()}_OAM_IP_ADDRESS]  ${Empty}

    ${bts_mplane_ip_reachable_check}=  Check IP Reachable  ${oam_address}
    Run Keyword If  ${bts_mplane_ip_reachable_check[${0}]}  Run Keywords
    ...  Log  - BTS ${alias} MPLANE IP ${oam_address} is reachable  console=True
    ...  AND  Append To List  ${return_results}  ${bts_mplane_ip_reachable_check[${0}]}  ${oam_address}
    ...  ELSE  Run Keywords
    ...  Log  - BTS ${alias} MPLANE IP ${oam_address} is not reachable -> Stop and Fix condition  console=True
    ...  AND  Append To List  ${return_results}  ${bts_mplane_ip_reachable_check[${0}]}  ${None}

    [Return]  @{return_results}

Check CBTS MPLANE IP is reachable
    [Arguments]    ${alias}
    ${return_results}=  Create List
    ${cu_address}=  Get Variable Value  ${${alias.upper()}}[${alias.upper()}_CU_IP_ADDRESS]  ${Empty}
    ${bts_cu_ip_reachable_check}=  Check IP Reachable  ${cu_address}
    Run Keyword If  ${bts_cu_ip_reachable_check[${0}]}
    ...  Log  - BTS ${alias} CU IP ${cu_address} is reachable  console=True
    ...  ELSE  Log  - BTS ${alias} CU IP ${cu_address} is not reachable  console=True
    Append To List  ${return_results}  @{bts_cu_ip_reachable_check}

    ${vdu_list_string}=  Set Variable  ${Empty}
    ${vdu_list}=  Get Variable Value  ${${alias.upper()}}[${alias.upper()}_VDU]
    FOR  ${vdu_info}  IN  @{vdu_list}
        ${ip}=  Get Variable Value  ${vdu_info['IP_ADDRESS']}  ${Empty}
        ${vdu_list_string}=  Catenate  ${vdu_list_string}  ${ip}
    END
    ${bts_vdu_ip_reachable_check}=  Run Keyword If  not '${vdu_list_string}'
    ...  Create List  ${False}  ${Empty}
    ...  ELSE  Check IP Reachable  ${vdu_list_string}
    Run Keyword If  all(${bts_vdu_ip_reachable_check})
    ...  Log  - BTS ${alias} VDU IPs are reachable  console=True
    ...  ELSE  Log  - BTS ${alias} some VDU IPs are not reachable  console=True
    Log  - ${bts_vdu_ip_reachable_check}  console=True

    Append To List  ${return_results}  @{bts_vdu_ip_reachable_check}

    [Return]  @{return_results}

Check IP Reachable
    [Arguments]    ${address_or_multiple_addresses}
    ${addresses}=  Split String  ${address_or_multiple_addresses}
    ${result}=  Create List
    FOR  ${address}  IN  @{addresses}
        ${bts_ip_reachable_check}=  Run Keyword If  '${address}'
        ...  Run Keyword And Return Status
        ...  Wait For Target To Be Reachable TAF  hostname=${address}  timeout=30
        ...  ELSE  Set Variable  ${False}
        Append To List  ${result}  ${bts_ip_reachable_check}  ${address}
    END
    [Return]  ${result}

Check SBTS stop and fix alarms status
    [Arguments]  ${alias}  ${STOP_AND_FIX_admin_mplane_working_check}  ${BTS_MPLANE_IP_reachable_check}

    Return From Keyword If  ('${alias}' == '${None}') or not ${STOP_AND_FIX_admin_mplane_working_check} or not ${BTS_MPLANE_IP_reachable_check}
    ...  ${False}

    ${BTS_active_alarm_info}=  coam.Get Active Alarms  connection=${alias}

    ${STOP_AND_FIX_alarm_not_found}=  Check alarm not present in alarm list  alias=${alias}
    ...  BTS_active_alarm_info=${BTS_active_alarm_info}  STOP_AND_FIX_ALARM_LIST=${STOP_AND_FIX_ALARMS_SBTS}  entity_checked=sbts

    Run Keyword If  ${STOP_AND_FIX_alarm_not_found}
    ...  Log  Alarm Check OK  console=True
    ...  ELSE  Log  Alarm Check NOK   console=True

    [Return]  ${STOP_AND_FIX_alarm_not_found}

Check CBTS stop and fix alarms status
    [Arguments]  ${alias}  ${STOP_AND_FIX_admin_mplane_working_check}  ${BTS_MPLANE_IP_reachable_check}


    Return From Keyword If  ('${alias}' == '${None}') or not ${STOP_AND_FIX_admin_mplane_working_check} or not ${BTS_MPLANE_IP_reachable_check}
    ...  ${False}

    ${vcu_alias}=  Set Variable  ${alias} CU
    ${vdu_alias_length}=  Get Length  ${${alias.upper()}}[${alias.upper()}_VDU]

    Return From Keyword If  ${vdu_alias_length}==${0}

    ${VDU_alarms}=  Create Dictionary
    ${STOP_AND_FIX_alarm_not_found}=  Set Variable  ${True}

    FOR  ${index}  IN RANGE  ${vdu_alias_length}

        ${vdu_alias}=  Set Variable  ${alias} VDU${index+1}
        ${BTS_active_alarm_info}=  vdu.Vdu Get Active Alarms  vdu_connection=${vdu_alias}

        ${STOP_AND_FIX_alarm_not_found_vdu}=  Check alarm not present in alarm list  alias=${alias} VDU${index+1}
        ...  BTS_active_alarm_info=${BTS_active_alarm_info['alarms']}  STOP_AND_FIX_ALARM_LIST=${STOP_AND_FIX_ALARMS_VDU}  entity_checked=vdu

        ${STOP_AND_FIX_alarm_not_found}=  Evaluate  ${STOP_AND_FIX_alarm_not_found} and ${STOP_AND_FIX_alarm_not_found_vdu}

    END

    ${BTS_active_alarm_info}=  cu.Get Active Alarms  connection=${vcu_alias}

    ${STOP_AND_FIX_alarm_not_found_vcu}=  Check alarm not present in alarm list  alias=${alias} CU
    ...  BTS_active_alarm_info=${BTS_active_alarm_info['alarms']}  STOP_AND_FIX_ALARM_LIST=${STOP_AND_FIX_ALARMS_VCU}  entity_checked=vcu

    ${STOP_AND_FIX_alarm_not_found}=  Evaluate  ${STOP_AND_FIX_alarm_not_found_vcu} and ${STOP_AND_FIX_alarm_not_found_vdu}

    Run Keyword If  ${STOP_AND_FIX_alarm_not_found}
    ...  Log  Alarm Check OK  console=True
    ...  ELSE  Log  Alarm Check NOK   console=True

    [Return]  ${STOP_AND_FIX_alarm_not_found}

Check alarm not present in alarm list
    [Arguments]  ${alias}  ${BTS_active_alarm_info}  ${STOP_AND_FIX_ALARM_LIST}  ${entity_checked}

    ${entity_alarm_field_dict}=  Create Dictionary  sbts=faultId  vdu=fault_id  vcu=fault_id
    ${STOP_AND_FIX_alarm_not_found}=  Set Variable  ${True}

    FOR  ${alarm}  IN  @{BTS_active_alarm_info}

        ${fid}=  Set Variable  ${alarm['${entity_alarm_field_dict['${entity_checked}']}']}
        Run Keyword If  '${fid}' in ${STOP_AND_FIX_ALARM_LIST}
        ...  Log  - BTS ${alias} active alarm: FID ${fid} -> Stop and Fix condition  console=True
        ...  ELSE
        ...  Log  - BTS ${alias} active alarm: FID ${fid} -> No Stop And Fix  console=True

        ${STOP_AND_FIX_alarm_not_found}=  Set Variable If  '${fid}' in @{STOP_AND_FIX_ALARMS_${entity_checked.upper()}}
        ...  ${False}
        ...  ${STOP_AND_FIX_alarm_not_found}

    END
    [Return]  ${STOP_AND_FIX_alarm_not_found}

Check SBTS HW modules operational state
    [Arguments]  ${exp_operationalState}  ${admin_alias_for_checks}  ${current_bts_alias}  ${modules_dict}

    ${RMOD_dict}=  Get From Dictionary  ${modules_dict}  RMOD
    ${RMOD_disabled_list}=  Get Dictionary Keys  ${modules_dict['RMOD']}
    ${rmod_empty_list}=  Create List

    ${FHS_dict}=  Get From Dictionary  ${modules_dict}  FHS
    ${FHS_disabled_list}=  Get Dictionary Keys  ${modules_dict['FHS']}
    ${fhs_empty_list}=  Create List

    ${SMOD_disabled_list}=  Copy List  ${modules_dict['SMOD']}  deepcopy=${True}
    ${smod_empty_list}=  Create List

    ${BBMOD_disabled_list}=  Copy List  ${modules_dict['BBMOD']}  deepcopy=${True}
    ${bbmod_empty_list}=  Create List

    ${rmod_peer_alias_list}=  Evaluate  [x for alias_list in ${RMOD_dict}.values() for x in alias_list]
    ${fhs_peer_alias_list}=  Evaluate  [x for alias_list in ${FHS_dict}.values() for x in alias_list]
    ${peer_alias_list}=  Create List  @{rmod_peer_alias_list}  @{fhs_peer_alias_list}
    ${peer_alias_list}=  Remove Duplicates  ${peer_alias_list}
    Remove Values From List    ${peer_alias_list}  ${current_bts_alias}

    Return From Keyword If  '${admin_alias_for_checks}' == '${None}'
    ...  ${SMOD_disabled_list}  ${BBMOD_disabled_list}  ${FHS_disabled_list}  ${RMOD_disabled_list}  ${peer_alias_list}

    ${BTS_info}=  Get Bts Info  connection=${admin_alias_for_checks}
    ${BTS_info_system_module_list}=  Get Variable Value  ${BTS_info['systemModules']}  ${smod_empty_list}
    ${BTS_info_bb_module_list}=  Get Variable Value  ${BTS_info['basebandModules']}  ${bbmod_empty_list}
    ${BTS_info_rmod_list}=  Get Variable Value  ${BTS_info['radioModules']['rmod']}  ${rmod_empty_list}
    ${BTS_info_fhs_list}=  Get Variable Value  ${BTS_info['fhs']}  ${fhs_empty_list}

    Log  Check BTS ${current_bts_alias} SMOD(s) status:  console=True
    ${SMOD_count}=  Get Length  ${BTS_info_system_module_list}
    Run Keyword If  ${SMOD_count} == 0
    ...  Log  - No BTS ${current_bts_alias} SMOD(s) configured  console=True
    FOR  ${item}  IN  @{BTS_info_system_module_list}
        ${serialNumber_info}=  Get Variable Value  ${item['serialNumber']}  NA
        Run Keyword If  '${item['status']['operationalState']}' in '${exp_operationalState}'
        ...  Run Keywords
        ...  Remove Values From List  ${SMOD_disabled_list}  ${item['serialNumber']}
        ...  AND  Log Long String
        ...  - BTS ${current_bts_alias} SMOD SN_${serialNumber_info} operationalState: ${item['status']['operationalState']}
        ...  console=True
        ...  ELSE
        ...  Log Long String  - BTS ${current_bts_alias} SMOD SN_${serialNumber_info} operationalState: ${item['status']['operationalState']}
        ...  -> Stop and Fix condition  console=True
    END

    Log  Check BTS ${current_bts_alias} BBMOD(s) status:  console=True
    ${BBMOD_count}=  Get Length  ${BTS_info_bb_module_list}
    Run Keyword If  ${BBMOD_count} == 0
    ...  Log  - No BTS ${current_bts_alias} BBMOD(s) configured  console=True
    FOR  ${item}  IN  @{BTS_info_bb_module_list}
        ${serialNumber_info}=  Get Variable Value  ${item['serialNumber']}  NA
        Run Keyword If  '${item['status']['operationalState']}' in '${exp_operationalState}'
        ...  Run Keywords
        ...  Remove Values From List  ${BBMOD_disabled_list}  ${item['serialNumber']}
        ...  AND  Log Long String
        ...  - BTS ${current_bts_alias} BBMOD SN_${serialNumber_info} operationalState: ${item['status']['operationalState']}
        ...  console=True
        ...  ELSE
        ...  Log Long String  - BTS ${current_bts_alias} BBMOD SN_${serialNumber_info} operationalState: ${item['status']['operationalState']}
        ...  -> Stop and Fix condition  console=True
    END

    Log  Check BTS ${current_bts_alias} RMOD(s) status:  console=True
    ${RMOD_count}=  Get Length  ${BTS_info_rmod_list}
    Run Keyword If  ${RMOD_count} == 0
    ...  Log  - No BTS ${current_bts_alias} RMOD(s) configured  console=True
    FOR  ${item}  IN  @{BTS_info_rmod_list}
        ${serialNumber_info}=  Get Variable Value  ${item['serialNumber']}  NA
        Run Keyword If  '${item['status']['operationalState']}' in '${exp_operationalState}'
        ...  Run Keywords
        ...  Remove Values From List  ${RMOD_disabled_list}  ${serialNumber_info}
        ...  AND  Log  - BTS ${current_bts_alias} RMOD SN_${serialNumber_info} operationalState: ${item["status"]["operationalState"]}
        ...  console=True
        ...  ELSE
        ...  Log Long String
        ...  - BTS ${current_bts_alias} RMOD SN_${serialNumber_info} operationalState: ${item['status']['operationalState']}
        ...  -> Stop and Fix condition  console=True
    END
    ${rmod_peer_alias_list}=  Evaluate  [x for alias_list in ${RMOD_dict}.values() for x in alias_list]

    Log  Check BTS ${current_bts_alias} FHS(s) status:  console=True
    ${FHS_count}=  Get Length  ${BTS_info_fhs_list}
    Run Keyword If  ${FHS_count} == 0
    ...  Log  - No BTS ${current_bts_alias} FHS(s) configured  console=True
    FOR  ${item}  IN  @{BTS_info_fhs_list}
        ${serialNumber_info}=  Get Variable Value  ${item['serialNumber']}  NA
        Run Keyword If  '${item['stateInfo']['operationalState']}' in '${exp_operationalState}'
        ...  Run Keywords
        ...  Remove Values From List  ${FHS_disabled_list}  ${serialNumber_info}
        ...  AND  Log
        ...  - BTS ${current_bts_alias} FHS SN_${serialNumber_info} operationalState: ${item['stateInfo']['operationalState']}
        ...  console=True
        ...  ELSE
        ...  Log Long String
        ...  - BTS ${current_bts_alias} FHS SN_${serialNumber_info} operationalState: ${item['stateInfo']['operationalState']}
        ...  -> Stop and Fix condition  console=True

    END
    ${fhs_peer_alias_list}=  Evaluate  [x for alias_list in ${FHS_dict}.values() for x in alias_list]

    ${peer_alias_list}=  Create List  @{rmod_peer_alias_list}  @{fhs_peer_alias_list}
    ${peer_alias_list}=  Remove Duplicates  ${peer_alias_list}
    Remove Values From List    ${peer_alias_list}  ${current_bts_alias}

    Run Keyword If  ${SMOD_disabled_list} or ${BBMOD_disabled_list} or ${FHS_disabled_list} or ${RMOD_disabled_list}
    ...  Log  HW Modules check NOK  console=True
    ...  ELSE  Log  HW modules check OK   console=True

    [Return]  ${SMOD_disabled_list}  ${BBMOD_disabled_list}  ${FHS_disabled_list}  ${RMOD_disabled_list}  ${peer_alias_list}

Check CBTS HW modules operational state
    [Arguments]  ${exp_operationalState}  ${alias}  ${shared_module_peers_dict}

    ${vdu_alias_length}=  Get Length  ${${alias.upper()}}[${alias.upper()}_VDU]

    ${RMOD_dict}=  Copy Dictionary  ${shared_module_peers_dict['RMOD']}  deepcopy=${True}
    ${RMOD_disabled_list}=  Get Dictionary Keys  ${RMOD_dict}

    ${rmod_peer_alias_list}=  Evaluate  [x for alias_list in ${RMOD_dict}.values() for x in alias_list]
    ${peer_alias_list}=  Create List  @{rmod_peer_alias_list}
    ${peer_alias_list}=  Remove Duplicates  ${peer_alias_list}
    Remove Values From List  ${peer_alias_list}  ${alias}

    Return From Keyword If  '${alias}' == '${None}'
    ...  ${RMOD_disabled_list}  ${peer_alias_list}
    ${peer_alias_list}=  Create List

    FOR  ${index}  IN RANGE  ${vdu_alias_length}
        ${vdu_alias}=  Set Variable  ${alias} VDU${index+1}
        ${RMODS_status}=  vdu.Get Rmods Status  vdu_connection=${vdu_alias}
        ${rmod_status_is_correct}=  Evaluate  "${RMODS_status.__class__.__name__}"=="list"
        ${rmod_status_empty_list}=  Create List
        ${rmod_status_list}=  Set Variable If  ${rmod_status_is_correct}  ${RMODS_status}  ${rmod_status_empty_list}

        Log  Check BTS ${alias} VDU ${vdu_alias} RMOD(s) status:  console=True
        ${RMOD_count}=  Get Length  ${RMODS_status}
        Run Keyword If  ${RMOD_count} == 0
        ...  Log  - No BTS ${vdu_alias} RMOD(s) configured  console=True

        ${RMOD_dict}  ${RMOD_disabled_list}=  Check RMOD status for single VDU
        ...  ${exp_operationalState}  ${vdu_alias}  ${rmod_status_list}
        ...  ${RMOD_disabled_list}  ${RMOD_dict}

        ${rmod_peer_alias_list}=  Evaluate  [x for alias_list in ${RMOD_dict}.values() for x in alias_list]

        ${vdu_peer_alias_list}=  Create List  @{rmod_peer_alias_list}
        Remove Values From List  ${vdu_peer_alias_list}  ${vdu_alias}
        ${vdu_peer_alias_list}=  Remove Duplicates  ${vdu_peer_alias_list}
        Append To List  ${peer_alias_list}  @{vdu_peer_alias_list}

    END

    ${peer_alias_list}=  Remove Duplicates  ${peer_alias_list}

    Run Keyword If  ${RMOD_disabled_list}
    ...  Log  HW Modules check NOK  console=True
    ...  ELSE  Log  HW modules check OK   console=True

    [Return]  ${RMOD_disabled_list}  ${peer_alias_list}

Check RMOD status for single VDU
    [Arguments]    ${exp_operationalState}  ${vdu_alias}  ${RMODS_status}
    ...  ${RMOD_disabled_list}  ${RMOD_dict}

    FOR  ${item}  IN  @{RMODS_status}

        ${serialNumber_info}=  Get Variable Value  ${item['serial_number']}  NA
        Run Keyword If  '${item['operational_state']}' in '${exp_operationalState}'
        ...  Run Keywords
        ...  Remove Values From List  ${RMOD_disabled_list}  ${serialNumber_info}
        ...  AND  Log  - BTS ${vdu_alias} RMOD SN_${serialNumber_info} operationalState: ${item['operational_state']}
        ...  console=True
        ...  ELSE
        ...  Log Long String
        ...  - BTS ${vdu_alias} RMOD SN_${serialNumber_info} operationalState: ${item['operational_state']}
        ...  -> Stop and Fix condition  console=True

    END

    [Return]    ${RMOD_dict}  ${RMOD_disabled_list}

Get Stop and Fix RMOD serial number list

    ${STOP_AND_FIX_RMOD_sn_list}=  Create List

    FOR  ${alias}  IN  @{alias_list}

        ${STOP_AND_FIX_RMOD_sn_list}=  Get Stop and Fix RMOD serial number list on BTS  ${STOP_AND_FIX_RMOD_sn_list}  ${alias}

    END

    ${STOP_AND_FIX_RMOD_sn_list}=  Remove Duplicates  ${STOP_AND_FIX_RMOD_sn_list}

    [Return]  ${STOP_AND_FIX_RMOD_sn_list}

Get Stop and Fix RMOD serial number list on BTS
    [Arguments]  ${STOP_AND_FIX_RMOD_sn_list}  ${alias}

    ${RMOD_info}=  Get Parameters For All  class_name=RMOD  connection=${alias}

    FOR  ${item}  IN  @{RMOD_info}

        Run Keyword If  '${item.operationalState}' in '${Disabled_}'
        ...  Append To List  ${STOP_AND_FIX_RMOD_sn_list}  ${item.serialNumber}

    END

    [Return]  ${STOP_AND_FIX_RMOD_sn_list}

Check BTS Admin Response
    [Arguments]  ${alias}  ${ip_valid}

     Run Keyword If  not ${ip_valid}
     ...  Run Keywords
     ...  Log  M-Plane IP not reachable, aborting check  console=True
     ...  AND  Return From Keyword  ${False}

    ${status}  ${BTS_MPLANE_IP_ADDR}=  Run Keyword And Ignore Error
    ...  Admin Get BTS M-plane IP address  alias=${alias}

    Log  - BTS ${alias} Admin Response: ${status}  console=${True}

    Return From Keyword If  '${status}'!='PASS'  ${False}
    [Return]  ${True}

Check CBTS Admin Response
    [Arguments]  ${alias}  ${reachability_check_result}

    ${admin_response}=  Set Variable  ${True}
    ${admin_response}=  Set Variable If  not all(${reachability_check_result[0:2:]})
    ...  ${False}  ${admin_response}
    Run Keyword If  not all(${reachability_check_result[0:2:]})
    ...  Log  - VCU Admin response check failed because M-Plane IP not reachable  console=True

    ${vcu_mplane_admin_alias}=  Set Variable  ${alias} CU
    ${cu_state}=  Run Keyword And Return Status  cu.Get Cu State  connection=${vcu_mplane_admin_alias}

    ${admin_response}=  Evaluate  ${cu_state} and ${admin_response}
    Log  - BTS ${vcu_mplane_admin_alias} VCU Admin Response: ${cu_state}  console=${True}

    FOR  ${index}  ${vdu_item}  IN ENUMERATE  @{${alias}}[${alias.upper()}_VDU]

        ${admin_response}=  Set Variable If  not all(${reachability_check_result[${index*2+2}:${index*2+4}:]})
        ...  ${False}  ${admin_response}
        Run Keyword If  not all(${reachability_check_result[${index*2+2}:${index*2+4}:]})
        ...  Log  - VDU ${index+1} Admin response check failed because M-Plane IP not reachable  console=True
        ${vdu_mplane_admin_alias}=  Set Variable  ${alias} VDU${index+1}
        ${vdu_state}=  Run Keyword And Return Status  vdu.Get VDU State Data  vdu_connection=${vdu_mplane_admin_alias}

        ${admin_response}=  Evaluate  ${vdu_state} and ${admin_response}
        Log  - BTS ${vdu_mplane_admin_alias} Admin Response: ${vdu_state}  console=${True}

    END

    [Return]  ${admin_response}

Power OFF Testline Equipment
    [Documentation]
    ...  Wrapper KW that checks power off entities based on the supplied parameter. Created to be used in the teardown of test suites.

    [Arguments]  ${equipment_modules}=ALL

    Run Keyword And Return Status  Power OFF Hardware  ${equipment_modules}

Perform Recovery Of Failed Items
    [Arguments]  ${STOP_AND_FIX_conditions_detected}  ${all_aliases}

    Return From Keyword If  not ${STOP_AND_FIX_conditions_detected['STOP_AND_FIX_NEEDED']} or ${USER_STOP_AND_FIX_BLOCK_TEST}

    ${modules}=  Create List

    ${aliases}=  Get Dictionary Keys  ${STOP_AND_FIX_conditions_detected}
    ${aliases}=  Evaluate  [x for x in ${aliases} if x in ${all_aliases}]

    FOR  ${alias_item}  IN  @{aliases}

       ${elements}=  Set Variable  ${STOP_AND_FIX_conditions_detected['${alias_item}']['HW_MODULES_NOT_OPERATIONAL_DICT']}

       ${rmods_from_elements}=  Get Variable Value  ${elements['RMOD']}  ${False}
       ${rmods}=  Run Keyword If  ${rmods_from_elements}  Evaluate  ['RMOD_'+x for x in ${rmods_from_elements}]
       ...  ELSE  Create List
       ${fhs_from_elements}=  Get Variable Value  ${elements['FHS']}  ${False}
       ${fhs}=  Run Keyword If  ${fhs_from_elements}  Evaluate  ['FHS_'+x for x in ${fhs_from_elements}]
       ...  ELSE  Create List

       ${bbmods_from_elements}=  Get Variable Value  ${elements['BBMOD']}  ${False}
       ${lmp_reachable}=  Get Variable Value  ${STOP_AND_FIX_conditions_detected['${alias_item}']['LMP_REACHABLE']}  ${True}
       ${available_smods}=  Get configured SMODs from INTERFACES  ${alias_item}
       ${smods}=  Run Keyword If  ${bbmods_from_elements} or not ${lmp_reachable}
       ...  Copy List  ${available_smods}
       ...  ELSE  Create List

       Append To List  ${modules}  @{rmods}  @{fhs}  @{smods}

    END

    ${modules}=  Remove Duplicates  ${modules}
    Recover Modules By Power Off On  ${modules}

    FOR  ${alias_item}  IN  @{aliases}

        Check BTS State For Recovery  ${alias_item}

    END

Get configured SMODs from INTERFACES
    [Arguments]    ${alias_item}

    ${available_smods}=  Create List  ${alias_item.lower()}_fsm
    ${extension_present}=  Run Keyword And Return Status
    ...  Dictionary Should Contain Key  ${INTERFACES}  '${alias_item.lower()}'_ext_fsm
    Run Keyword If  ${extension_present}
    ...  Append To List  ${available_smods}   ${alias_item.lower()}_ext_fsm
    [Return]    ${available_smods}

Recover Modules By Power Off On
    [Arguments]  ${module_list}=@{Empty}
    Log  ****************************************************************  console=True
    Log  Recovering after Stop And Fix following elements by power off/on  console=True
    Log  ${module_list}  console=True
    Log  ****************************************************************  console=True
    FOR  ${module}  IN  @{module_list}
        Run Keyword And Return Status  PDU BTS Interface Off  ${module}
        ${PDU_port_status}=  Pdu BTS Interface Get Status  ${module}
        Run Keyword If  '${PDU_port_status}'=='off'  Log  Module ${module} successfully powered off  console=True
        ...  ELSE  Log  Module ${module} could not be powered off  console=True
    END
    FOR  ${module}  IN  @{module_list}
        Run Keyword And Return Status  PDU BTS Interface On  ${module}
        ${PDU_port_status}=  Pdu BTS Interface Get Status  ${module}
        Run Keyword If  '${PDU_port_status}'=='on'  Log  Module ${module} successfully powered on  console=True
        ...  ELSE  Log  Module ${module} could not be powered on  console=True
    END
    Log  ******************  console=True
    Log  Recovery completed  console=True
    Log  ******************  console=True

Check BTS State For Recovery
    [Arguments]  ${alias_item}
    Run Keyword And Return Status  Admin Check BTS RAT Procedural State  ${alias_item}  timeout=600
    Run Keyword And Return Status  Check cells availability status online  ${alias_item}  timeout=300

Sleep Mechanism for Stop and Fix
    [Arguments]  ${hours_sleep_time}  ${STOP_AND_FIX_conditions_detected}  ${USER_STOP_AND_FIX_BLOCK_TEST}

    Return From Keyword If  not ${USER_STOP_AND_FIX}

    Log  ===================================================================================================  console=True
    Run Keyword If  not ${STOP_AND_FIX_conditions_detected['STOP_AND_FIX_NEEDED']}
    ...  Run Keywords
    ...  Log  === Stop and Fix conditions: FALSE -> no Stop and Fix conditions are pending!  console=True
    ...  AND  Log  ====================================================================================================  console=True
    ...  AND  Return From Keyword
    ...  ELSE IF  ${STOP_AND_FIX_conditions_detected['STOP_AND_FIX_NEEDED']} and not ${USER_STOP_AND_FIX_BLOCK_TEST}
    ...  Run Keywords
    ...  Log Long String  === Stop and Fix conditions: TRUE -> Stop and Fix conditions are pending but
    ...  test execution will not be blocked!  console=True
    ...  AND  Log  ===========================================================================================  console=True
    ...  AND  Return From Keyword
    ...  ELSE
    ...  Run Keywords
    ...  Log  === Stop and Fix conditions: TRUE -> Stop and Fix conditions are pending! =====  console=True
    ...  AND  Log  ===== Stopping test suite to facilitate investigation =====  console=True
    ...  AND  Log  ===========================================================================================  console=True

    Log  Test execution is frozen for ${hours_sleep_time} by sleep mechanism!  console=True
    ${hours_sleep_time_int}=  Fetch From Left  ${hours_sleep_time}  h
    FOR  ${time}  IN RANGE  ${hours_sleep_time_int}
        ${remained_time}=  Evaluate  ${hours_sleep_time_int} - ${time}
        Log  Remaining sleep time: ${remained_time} hours  console=True
        Sleep  1h
    END

RMOD UDP LOG Preconditions
    Run Keyword If  not ${USER_RMOD_UDP_LOG_COLLECT}  Run Keywords
    ...  Log  RMOD UDP Log collection through LMI is ${USER_RMOD_UDP_LOG_COLLECT}  console=True
    ...  AND  Return From Keyword

    Run Keyword And Ignore Error  rmod_udp_log.Start Udp Traces For Multiple Hosts
    ...  config_yaml_path=${RMOD_UDP_LOG_CONFIG_PATH}
    ...  interfaces_dict=${INTERFACES}
    ...  log_folder=${Test Results Dir}/UDPLogs/

RMOD UDP LOG Postconditions
    Run Keyword If  not ${USER_RMOD_UDP_LOG_COLLECT}  Run Keywords
    ...  Log  RMOD UDP Log collection through LMI is ${USER_RMOD_UDP_LOG_COLLECT}  console=True
    ...  AND  Return From Keyword

    Run Keyword And Ignore Error  rmod_udp_log.Stop Udp Traces

Collect BTS snapshot via collectors aashell
    [Arguments]  ${alias}  ${target_file_name}=None  ${target_dir}=None  ${proxy_use}=False  ${timeout}=480

    ${aashell_cli_name}=  Set Variable  ${alias}_aashell_cli
    ${collector_name}=  Set Variable  ${alias}_log

    ${host_ip}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]
    ${hop_ip}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]
    ${hop_user}=  Get Variable Value  ${${alias.upper()}}[${alias.upper()}_PC_SSH_USERNAME]  ute
    ${hop_password}=  Get Variable Value  ${${alias.upper()}}[${alias.upper()}_PC_SSH_USERNAME]  uteUTE!

    ${hop_dict}=  Create Dictionary  host=${hop_ip}  user=${hop_user}  password=${hop_password}

    ${hops}=  Run Keyword If  '${proxy_use}' == 'False'
    ...  Create Dictionary  host=${host_ip}
    ...  ELSE
    ...  Create Dictionary  host=${host_ip}  proxy=${hop_dict}

    aashell_cli.Create Aashell Cli  name=${aashell_cli_name}  hops=${hops}
    aashell_log.Create Aashell Log Collector  name=${collector_name}  tool=${aashell_cli_name}  timeout=${timeout}
    ...  target_file_name=${target_file_name}

    core.Setup Collectors  names=${collector_name}
    core.Collect Collectors  names=${collector_name}  target_dir=${target_dir}

    ${target_dir_check}=  Set Variable If  '${target_dir}' == 'None'  ${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/${collector_name}
    ...  ${target_dir}/${collector_name}
    ${target_file_name_check}=  Set Variable If  '${target_file_name}' == 'None'  aashell_${collector_name}.zip
    ...  ${target_file_name}

    ${status}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  ${target_dir_check}/${target_file_name_check}
    Run Keyword If  ${status}
    ...  Log  Snapshot file ${target_file_name_check} collected by aashell available in ${target_dir_check} folder  level=INFO  console=True
    ...  ELSE
    ...  Log  Snapshot file ${target_file_name_check} collected by aashell not available in ${target_dir_check} folder  level=WARN

    [Teardown]  Run Keywords  aashell_cli.Teardown Collectors  names=${aashell_cli_name}
    ...  AND  aashell_log.Teardown Collectors  names=${collector_name}
    ...  AND  core.Teardown Collectors  names=${collector_name}

Get SMODs status info
    [Arguments]  ${alias}

    ${alias_ext_status}=  Run Keyword And Return Status  List Should Contain Value  ${alias_list_complete}  ${alias}_Ext

    ${alias_SMOD_status_dict}=  Run Keyword If  ${alias_ext_status}
    ...  Create Dictionary  ${alias}=None  ${alias}_Ext=None
    ...  ELSE
    ...  Create Dictionary  ${alias}=None

    ${KW_status}  ${SMOD_id_list}=  Run Keyword And Ignore Error  Get Ids For All  class_name=SMOD  connection=${alias}

    Return From Keyword If  '${KW_status}' == 'FAIL'  ${alias_SMOD_status_dict}

    FOR  ${SMOD_id}  IN  @{SMOD_id_list}

        ${SMOD_info}=  coam.Get Parameters  dist_name=${SMOD_id}  connection=${alias}
        ${SMOD_operationalState}=  Get From Dictionary  ${SMOD_info}  operationalState
        ${SMOD_activeRole}=  Get From Dictionary  ${SMOD_info}  activeRole

        Run Keyword If  '${SMOD_activeRole}' in ['None', 'Primary']
        ...  Set To Dictionary  ${alias_SMOD_status_dict}  ${alias}  ${SMOD_operationalState}
        ...  ELSE IF  '${SMOD_activeRole}' == 'Secondary'
        ...  Set To Dictionary  ${alias_SMOD_status_dict}  ${alias}_Ext  ${SMOD_operationalState}

    END

    [Return]  ${alias_SMOD_status_dict}

Collect BTS snapshot via collectors aashell from all SMODs
    [Arguments]  ${alias}=None  ${alias_ext}=None  ${target_file_name}=None  ${target_dir}=None  ${timeout}=480

    ${proxy_use}=  Set Variable If  '${alias}' == 'Master'  False  True

    Run Keyword If  '${alias}' != 'None'
    ...  Collect BTS snapshot via collectors aashell  alias=${alias}  target_file_name=${target_file_name}
    ...  target_dir=${target_dir}/Aashell_Snapshot  proxy_use=${proxy_use}  timeout=${timeout}

    Run Keyword If  '${alias_ext}' != 'None'
    ...  Collect BTS snapshot via collectors aashell  alias=${alias_ext}  target_file_name=${target_file_name}
    ...  target_dir=${target_dir}/Aashell_Snapshot  proxy_use=True  timeout=${timeout}
