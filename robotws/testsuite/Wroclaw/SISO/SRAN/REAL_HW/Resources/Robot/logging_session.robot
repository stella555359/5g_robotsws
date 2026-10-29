*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS
...  Library with basic keywords responsible for creating admin and syslog session

Library  ute_admin_infomodel  WITH NAME  admin_im
Library  taf.collectors.core  WITH NAME  core
Library  taf.collectors.btslog  WITH NAME  btslog
Library  taf.sbts.oam.coam.admin  WITH NAME  admin
Library  taf.sw.syslog  WITH NAME  taf_syslog

Resource  FM_Faults.robot


*** Variables ***
&{LOG_NODE_INDEX}=
${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=  Failed
${CUSTOM_SYSLOG_LAUNCH}=  ${True}
# ${CUSTOM_TEMP_DIR}=  /home/ute/test_tmp
${TOOLS_TO_SETUP}=  syslog_IM_ADMIN
${CUSTOM_BTSLOG_TERMINATE}=    ${False}
${SYSLOG_FILE_LIMIT}=    500000000


*** Keywords ***
Logging Session Start
  [Arguments]
  ...  ${logs_dir_path}
  ...  ${bts_host}=192.168.255.129
  ...  ${host_ip}=${EMPTY}
  ...  ${tools_to_setup}=syslog_IM_ADMIN
  ...  ${timeout}=120
  ...  ${connection}=default
  ...  ${bts_id}=1
  [Documentation]
  ...  Description:
  ...  Keyword prepares logging session for specific hostname.
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | logs_dir_path          | Yes  | Path to directory for session logging                              |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | host_ip                | No   | IP address in case of remote session.                              |
  ...  |                        |      | For local LMP session parameter is not provided.                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | tools_to_setup         | No   | Type of session which has to be established.                       |
  ...  |                        |      | Standard session contains syslog, IM and Admin.                    |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | timeout                | No   | Timeout value for all keywords                                     |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | bts_host               | No   | bts IP address to admin api session, needed only in case           |
  ...  |                        |      | there is mplane connection                                         |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | connection             | No   | admin api connection identifier,  BTS_ID                           |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | bts_id                 | No   | BTS ID number, used mainly in identification and folder definition |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  Set Test Variable  ${TOOLS_TO_SETUP}  ${TOOLS_TO_SETUP}
  ${log_tools}=  Run Keyword And Ignore Error
  ...  Replace String  ${tools_to_setup}  _  ,
  Logging With Timestamp
  ...  message=Logging session activation for BTS_ID ${bts_id} started.
  IF  "syslog" in "${tools_to_setup}" and ${CUSTOM_SYSLOG_LAUNCH}
    Start Taf Syslog Session  name=${connection}  bts_id=${connection}  target_file_name=${connection}    logs_dir_path=${logs_dir_path}
  END
  IF  "DCAP" in "${tools_to_setup}"
    Log  todo ..
  END
  IF  "IM" in "${tools_to_setup}" and "${host_ip}"=="${EMPTY}"
    admin_im.Setup Infomodel
    ...  address=${bts_host}
    ...  admin_api_log_dir=${logs_dir_path}/Admin_API/${bts_id}/
    ...  port=443
    ...  timeout=${timeout}
    ...  alias=${connection}
    admin_im.Connect Infomodel  alias=${connection}  timeout=${timeout}
  ELSE IF  "IM" in "${tools_to_setup}" and "${host_ip}"!="${EMPTY}"
    admin_im.Setup Infomodel
    ...  remote_host=${host_ip}
    ...  address=${bts_host}
    ...  admin_api_log_dir=${logs_dir_path}/Admin_API/${bts_id}/
    ...  port=443
    ...  timeout=${timeout}
    ...  alias=${connection}
    admin_im.Connect Infomodel  alias=${connection}  timeout=${timeout}
  END
  IF  "ADMIN" in "${tools_to_setup}" and "${host_ip}"=="${EMPTY}"
    admin.Setup Admin
    ...  bts_host=${bts_host}
    ...  bts_port=443
    ...  admin_api_log_dir=${logs_dir_path}/Admin_API/${bts_id}/
    ...  update_interval=500
    ...  timeout=${timeout}
    ...  name=${connection}
  ELSE IF  "ADMIN" in "${tools_to_setup}" and "${host_ip}"!="${EMPTY}"
    admin.Setup Admin
    ...  bts_host=${bts_host}
    ...  bts_port=443
    ...  admin_api_log_dir=${logs_dir_path}/Admin_API/${bts_id}/
    ...  remote_host=${host_ip}
    ...  update_interval=500
    ...  timeout=${timeout}
    ...  name=${connection}
  END
  [Teardown]  Logging With Timestamp
  ...  message=Logging session activation for BTS_ID ${bts_id} finished. Used tools: ${log_tools}[1]

Logging Session Stop
  [Arguments]  ${logs_dir_path}  ${status}=PASS  ${snapshot}=Failed  ${connection}=default
  [Documentation]
  ...  Description:
  ...  Keyword stop gathering logs for specific hostname define by connection parameter.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | logs_dir_path          | Yes  | Path to directory for session logging                                      |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | status                 | No   | KW status passed as argument - FAIL, PASS.                                 |
  ...  |                        |      | Use to gather snapshot in case of failure mode - snapshot=Failed           |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | snapshot               | No   | CUSTOM_SWITCH_PERFORM_SNAPSHOT - user provided switch, it tell when to     |
  ...  |                        |      | gather snapshot, it case of failed testcase, ALways or Never               |
  ...  |                        |      | possible values: Failed, ALways, None                                      |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | connection             | No   | admin api connection identifier, usually it is BTS_ID                      |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  Logging With Timestamp
  ...  message=Closing logging session for BTS_ID ${connection} started.
  IF  ("${status}"=="FAIL" and "${snapshot}"=="Failed") or "${snapshot}"=="Always"
    Run Keyword And Continue On Failure
    ...  Logging Session Save Snapshot  logs_dir_path=${logs_dir_path}/BTSFiles/${connection}/  connection=${connection}
  END
  ${active_syslog}=  Set Variable If  ${CUSTOM_SYSLOG_LAUNCH} and "syslog" in "${TOOLS_TO_SETUP}"
  ...  ${True}
  ...  ${False}
  IF  '${CFG.configuration_setup_type}'!='mplane' and ${active_syslog}
    Run Keyword And Continue On Failure
    ...  Run Keywords
    ...  Stop Taf Syslog Session  ${connection}  ${connection}  ${logs_dir_path}
    ...  AND
    ...  Logging With Timestamp  message=Syslog saved under this path: ${logs_dir_path}/UDPlog/${connection}/
  END
  # IF  "syslog" in "${tools_to_setup}"
  #   ${secondary_core_status}=  Run Keyword And Ignore Error
  #   ...  Dictionary Should Contain Key  ${CFG.NODES['${connection}']}  secondary_sm_vm_ip_LMP_address
  # ELSE
  #   ${secondary_core_status}=  Set Variable  ${None}
  # END
  Run Keyword And Continue On Failure
  ...  admin.Collect Infomodel Log From Current Session  target_file_name=${logs_dir_path}/BTSFiles/${connection}/${connection}_infomodel.ims2
  ...  timeout=120
  ...  connection=${connection}
  ...  leave_disconnect_logs=True
  Logging With Timestamp
  ...  message=Infomodel saved under this path: ${logs_dir_path}/BTSFiles/${connection}/
  admin.Teardown  connection=${connection}
  Run Keyword And Ignore Error  admin_im.Teardown Infomodel  ${connection}
  Logging With Timestamp
  ...  message=Closing logging session for BTS_ID ${connection} finished.

Logging Session Save Snapshot
  [Arguments]  ${logs_dir_path}  ${connection}=default
  [Documentation]
  ...  Description:
  ...  Gather snapshot for specific BTS defined by name.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | logs_dir_path          | Yes  | Path to directory for session logging                                      |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | connection             | No   | admin api connection identifier, usually it is BTS_ID                      |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  Logging With Timestamp
  ...  message=Snapshot Procedure for BTS_ID = ${connection} started.
  ${snapshot_succeeded}=  Run Keyword And Continue On Failure
  ...  admin.Collect Snapshot  target_file_name=${logs_dir_path}/Snapshot_${connection}.zip  timeout=1200  connection=${connection}
  IF  not 'successfully' in '${snapshot_succeeded}'
    Logging With Timestamp  message=Snapshot for BTS_ID = ${connection} could not be saved!  style=ERROR
  END
  Logging With Timestamp
  ...  message=Snapshot Procedure for BTS_ID = ${connection} finished, path to file: ${logs_dir_path}/Snapshot_${connection}.zip.

Create And Start Local Btslog Collector
  [Arguments]  ${timeout}  ${name}  ${target_file_name}
  [Documentation]
  ...  Description:
  ...  Keyword start local LMP syslog logging.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | timeout                | No   | Timeout value for all keywords                                             |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | name                   | Yes  | btslog_collector connection identifier, usually it is BTS_ID               |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | target_file_name       | Yes  | name of syslog file                                                        |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  ${timeout}=  Convert To Integer  ${timeout}
  btslog.Create Btslog Collector
  ...  name=${name}
  ...  btslog_path=/opt/btslog/btslog
  ...  btslog_launcher_path=/opt/btslog/btslog_launcher
  ...  target_file_name=${target_file_name}
  ...  start_timeout=${timeout}
  core.Setup Collectors  names=${name}
  core.Start Collectors  names=${name}
  btslog.Set Test Alias  ${name}
  [Return]  ${name}

Create And Start Remote Btslog Collector
  [Arguments]  ${host_ip}  ${timeout}  ${name}  ${target_file_name}
  [Documentation]   Keyword start logging syslog using TAF method collectors on remote node.
  ...  Description:
  ...  Keyword start remote LMP syslog logging.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | host_ip                | No   | IP address in case of remote session.                                      |
  ...  |                        |      | For local LMP session parameter is empty.                                  |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | timeout                | No   | Timeout value for all keywords                                             |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | name                   | No   | btslog_collector connection identifier, usually it is BTS_ID               |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | target_file_name       | Yes  | name of syslog file                                                        |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${timeout}=  Convert To Integer  ${timeout}
  ${executor_test_vm}=  Create Dictionary
  ...  host=${host_ip}
  ...  user=ute
  ...  password=ute
  btslog.Create Btslog Collector
  ...  name=${name}
  ...  btslog_path=/opt/btslog/btslog
  ...  btslog_launcher_path=/opt/btslog/btslog_launcher
  ...  executor=${executor_test_vm}
  ...  target_file_name=${target_file_name}
  ...  start_timeout=${timeout}
  core.Setup Collectors  names=${name}
  core.Start Collectors  names=${name}
  btslog.Set Test Alias  ${name}

Stop Btslog Collector
  [Arguments]  ${logs_dir_path}  ${name}
  [Documentation]
  ...  Description:
  ...  Keyword stop logging syslog and save its files using TAF method collectors.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | logs_dir_path          | Yes  | Path to directory for session logging                                       |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | name                   | Yes  | btslog_collector connection identifier, usually it is BTS_ID               |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  core.Stop Collectors  names=${name}
  Run Keyword And Ignore Error
  ...  core.Collect Collectors  names=${name}  target_dir=${logs_dir_path}/
  core.Teardown Collectors  names=${name}  force=${True}

Cleanup Robot Environment
  [Documentation]
  ...  Description:
  ...  Keyword stop any admin or infomodel session.
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  Logging With Timestamp
  ...  message=Cleanup Robot Environment
  Run Keyword And Ignore Error
  ...  admin_im.Teardown All Aliases For Infomodel  imstimeout=300s
  Run Keyword And Ignore Error
  ...  admin.Teardown All Aliases For Admin
  Run Keyword And Ignore Error
  ...  taf_syslog.Teardown All Aliases For Syslog
  IF  ${CUSTOM_BTSLOG_TERMINATE}
    Run Keyword And Ignore Error
    ...  Run And Return Rc And Output    killall -9 cli_syslog
  END

Logging Multinode Start
  [Arguments]  ${logs_dir}  ${timeout}=240  ${tools_to_setup}=syslog_IM_ADMIN
  [Documentation]
  ...  Description:
  ...  Keyword start logging session for each active node. Using atrubutes from node description:
  ...  bts_alias_type and bts_ip_address, seesion is activated via local or remote VM or directly on MPLANE.
  ...  In case of MPLANE only ADMIN and DCAP session ca be activated
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | logs_dir               | Yes  | Path to directory for session logging                                      |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | timeout                | No   | Timeout value for all keywords                                             |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | tools_to_setup         | No   | Type of session which has to be established.                               |
  ...  |                        |      | Standard session contains syslog, IM and Admin.                            |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  FOR  ${bts_id}  IN  @{CFG.active_bts_list}
    Logging With Timestamp
    ...  message=Logging Start for BTS_ID: ${bts_id}
    ${bts_alias_type}=  Get From Dictionary  ${CFG.NODES['${bts_id}']}  bts_alias_type
    ${bts_ip_address}=  Get From Dictionary  ${CFG.NODES['${bts_id}']}  bts_ip_address
    IF  not '${bts_ip_address}'=='${EMPTY}'
      ${tools_to_setup}=  Remove String Using Regexp  ${tools_to_setup}  syslog_IM_
    ELSE
      ${tools_to_setup}=  Set Variable  ${tools_to_setup}
    END
    IF  '${bts_alias_type}' == 'localhost'
      Logging Session Start  logs_dir_path=${logs_dir}  timeout=${timeout}  connection=${bts_id}  tools_to_setup=${tools_to_setup}  bts_id=${bts_id}
    ELSE IF  '${bts_ip_address}'=='${EMPTY}'
      Logging Session Start
      ...  logs_dir_path=${logs_dir}
      ...  host_ip=${CFG.NODES['${bts_id}']['vm_ip_LMP_address']}
      ...  timeout=${timeout}
      ...  connection=${bts_id}
      ...  tools_to_setup=${tools_to_setup}
      ...  bts_id=${bts_id}
    ELSE
      Logging Session Start
      ...  logs_dir_path=${logs_dir}
      ...  bts_host=${bts_ip_address}
      ...  timeout=${timeout}
      ...  connection=${bts_id}
      ...  tools_to_setup=${tools_to_setup}
      ...  bts_id=${bts_id}
    END
  END

Logging Multinode Stop
  [Arguments]  ${logs_dir}  ${status}=PASS
  [Documentation]
  ...  Description:
  ...  Keyword stop logging session for each active node.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | logs_dir               | Yes  | Path to directory for session logging                                      |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | status                 | No   | status of current testcase, used for snapshot gathering                    |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  FOR  ${bts_id}  IN  @{CFG.active_bts_list}
    Logging With Timestamp
    ...  message=Logging Stop for BTS_ID: ${bts_id}
    ${bts_alias_type}=  Get From Dictionary  ${CFG.NODES['${bts_id}']}  bts_alias_type
    IF  '${bts_alias_type}' == 'localhost'
      Logging Session Stop  logs_dir_path=${logs_dir}  status=${status}  connection=${bts_id}  snapshot=${CUSTOM_SWITCH_PERFORM_SNAPSHOT}
    ELSE
      Logging Session Stop  logs_dir_path=${logs_dir}  status=${status}  connection=${bts_id}  snapshot=${CUSTOM_SWITCH_PERFORM_SNAPSHOT}
    END
  END

Setup Logging Session Multinode Restart
  [Arguments]  ${logs_path}
  [Documentation]
  ...  Description:
  ...  Procedure restarts logging session for each node in setup. KW is limited only for setup use.
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | logs_path              | Yes  | Path to log directory                                              |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: daniel.bartkowiak@nokia.com
  ...  Maintainer: daniel.bartkowiak@nokia.com
  FOR  ${bts_id}  IN  @{CFG.active_bts_list}
    ${tmp_index}=  Evaluate  ${LOG_NODE_INDEX['${bts_id}']}+1
    Set To Dictionary  ${LOG_NODE_INDEX}  ${bts_id}=${tmp_index}
    Run Keyword And Continue On Failure
    ...  admin.Collect Infomodel Log From Current Session  target_file_name=${logs_path}/${LOG_NODE_INDEX['${bts_id}']}_${bts_id}_infomodel.ims2
    ...  timeout=120
    ...  connection=${bts_id}
    ...  leave_disconnect_logs=True
    operatingsystem.Wait Until Created  path=${logs_path}/${LOG_NODE_INDEX['${bts_id}']}_${bts_id}_infomodel.ims2
    ${fault_unexpected_status}  ${msg_current}=  Run Keyword And Ignore Error
    ...  admin.Assert No Unexpected Active Alarms  connection=${bts_id}
    IF  "${fault_unexpected_status}" == "FAIL"
      ${msg_history}=  Remove String Using Regexp  ${msg_current}  .*?alarms:
    ELSE
      ${msg_history}=  Set Variable  ${None}
    END
    ${pretty_active_faults}=  Evaluate  pprint.pformat("""${msg_history}""", indent=4)  modules=pprint
    IF  "${fault_unexpected_status}"=="FAIL"
      Logging With Timestamp  message=List of unexpected faults detected:${\n}${pretty_active_faults}  logs_dir=${CFG.suite_logs_path}  style=WARN
    END
    ${historical_faults_status}  ${msg_history}=  Run Keyword And Ignore Error
    ...  admin.Assert No Unexpected Historical Alarms  connection=${bts_id}
    IF  "${historical_faults_status}" == "FAIL"
      ${msg_history}=  Remove String Using Regexp  ${msg_history}  .*?alarms:
    ELSE
      ${msg_history}=  Set Variable  ${None}
    END
    ${pretty_active_faults}=  Evaluate  pprint.pformat("""${msg_history}""", indent=4)  modules=pprint
    IF  "${historical_faults_status}"=="FAIL"
      Logging With Timestamp
      ...  message=List of unexpected historical faults detected:${\n}${pretty_active_faults}
      ...  logs_dir=${CFG.suite_logs_path}
      ...  style=WARN
    END
    Wait Until Keyword Succeeds  5 minutes  125 sec
    ...  admin.Reset Admin  connection=${bts_id}
    Logging With Timestamp
    ...  message=Admin session was successfuly restarted on BTS-${bts_id}
    ...  logs_dir=${CFG.suite_logs_path}
  END

Logging Session Multinode Restart
  [Arguments]  ${logs_path}  ${delay}=60  ${admin_timeout}=300  ${check_faults}=${True}
  [Documentation]  KW is mandatory to use always if admin session needs to be restarted. KW can be used everywhere outside setup
  ...  Variable LOG_NODE_INDEX is set at the beggining of testsuite and available within whole testsuite.
  ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
  ...    | Argument           | Man.  | Description                                                                                   |
  ...    +====================+=======+===============================================================================================+
  ...    | logs_path          | Yes   | directory for logs                                                                            |
  ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
  ...    | delay              | No    | User can set delay time for BTS stabilization before faults check                             |
  ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
  ...    | admin_timeout      | No    | User can set timeout for admin session restart, default is 300s                               |
  ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
  ...    | check_faults       | No    | User can set False to skip faults check                                                       |
  ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
  ...  Author: daniel.bartkowiak@nokia.com
  ...  Maintainer: daniel.bartkowiak@nokia.com

  FOR  ${bts_id}  IN  @{CFG.active_bts_list}
    ${tmp_index}=  Evaluate  ${LOG_NODE_INDEX['${bts_id}']}+1
    Set To Dictionary  ${LOG_NODE_INDEX}  ${bts_id}=${tmp_index}
    Run Keyword And Continue On Failure
    ...  admin.Collect Infomodel Log From Current Session
    ...  target_file_name=${logs_path}/${bts_id}/${LOG_NODE_INDEX['${bts_id}']}_${bts_id}_infomodel.ims2
    ...  timeout=120
    ...  connection=${bts_id}
    ...  leave_disconnect_logs=True
    operatingsystem.Wait Until Created  path=${logs_path}/${bts_id}/${LOG_NODE_INDEX['${bts_id}']}_${bts_id}_infomodel.ims2
    IF  ${check_faults}
      FM Check Unexpected And Historical Faults  node_id=${bts_id}  delay=${delay}
    END
    Wait Until Keyword Succeeds  ${admin_timeout} sec  125 sec
    ...  admin.Reset Admin  connection=${bts_id}
    ${bts_alias_type}=  Get From Dictionary  ${CFG.NODES['${bts_id}']}  bts_alias_type
    ${bts_ip_address}=  Get From Dictionary  ${CFG.NODES['${bts_id}']}  bts_ip_address
    IF  '${bts_alias_type}' == 'localhost'
      Reset Ute_infomodel Session  logs_dir_path=${logs_path}  connection=${bts_id}  timeout=${admin_timeout}
    ELSE IF  '${bts_ip_address}'=='${EMPTY}'
      Reset Ute_infomodel Session  logs_dir_path=${logs_path}  host_ip=${CFG.NODES['${bts_id}']['vm_ip_LMP_address']}  connection=${bts_id}
      ...  timeout=${admin_timeout}
    ELSE
      Reset Ute_infomodel Session  logs_dir_path=${logs_path}  host_ip=${bts_ip_address}  connection=${bts_id}  timeout=${admin_timeout}
    END
    Logging With Timestamp
    ...  message=Admin session was successfuly restarted on BTS-${bts_id}
    ...  logs_dir=${CFG.suite_logs_path}
  END

Logging Session Save Snapshot For All Nodes
  [Arguments]  ${logs_dir_path}
  [Documentation]
  ...  Description:
  ...  Gather snapshot for all BTSes.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | logs_dir_path          | Yes  | Path to directory for session logging                                      |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: daniel.bartkowiak@nokia.com
  ...  Maintainer: daniel.bartkowiak@nokia.com
  Logging With Timestamp
  ...  message=Snapshot procedure on all nodes will be executed.
  FOR  ${bts_id}  IN  @{CFG['active_bts_list']}
    Logging Session Save Snapshot  logs_dir_path=${logs_dir_path}/${bts_id}  connection=${bts_id}
  END

Logging Session Save Syslog For All Nodes
  [Arguments]  ${logs_dir_path}
  [Documentation]
  ...  Description:
  ...  Gather snapshot for all BTSes.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | logs_dir_path          | Yes  | Path to directory for session logging                                      |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: daniel.bartkowiak@nokia.com
  ...  Maintainer: daniel.bartkowiak@nokia.com
  FOR  ${bts_id}  IN  @{CFG['active_bts_list']}
    IF  '${CFG.configuration_setup_type}'!='mplane' and ${CUSTOM_SYSLOG_LAUNCH}
      Run Keyword And Continue On Failure
      ...  Run Keywords
      ...  Stop Btslog Collector  ${logs_dir_path}/UDPlog/${bts_id}  ${bts_id}_primary
      ...  AND
      ...  Logging With Timestamp  message=Syslog saved under this path: ${logs_dir_path}/UDPlog/${bts_id}/
    END
    IF  '${CFG.configuration_setup_type}'!='mplane' and ${CUSTOM_SYSLOG_LAUNCH}
      ${secondary_core_status}=  Run Keyword And Ignore Error
      ...  Dictionary Should Contain Key  ${CFG.NODES['${bts_id}']}  secondary_sm_vm_ip_LMP_address
      ${secondary_sm_vm_ip_LMP_address}=  Set Variable If  '${secondary_core_status[0]}'=='FAIL'
      ...  ${EMPTY}
      ...  ${CFG.NODES['${bts_id}']['secondary_sm_vm_ip_LMP_address']}
    ELSE
      ${secondary_sm_vm_ip_LMP_address}=  Set Variable  ${EMPTY}
    END
#  ${secondary_sm_vm_ip_LMP_address}=  Get From Dictionary  ${CFG.NODES['${bts_id}']}  secondary_sm_vm_ip_LMP_address
#  ${secondary_sm_vm_ip_LMP_address}=  Run Keyword And Return Status  Should Not Be Empty  ${secondary_sm_vm_ip_LMP_address}
    IF  '${CFG.configuration_setup_type}'!='mplane' and ${CUSTOM_SYSLOG_LAUNCH} and '${secondary_sm_vm_ip_LMP_address}'!='${EMPTY}'
      Run Keyword And Continue On Failure
      ...  Run Keywords
      ...  Stop Btslog Collector  ${logs_dir_path}/UDPlog/${bts_id}  ${bts_id}_secondary
      ...  AND
      ...  Logging With Timestamp  message=Syslog saved under this path: ${logs_dir_path}/UDPlog/${bts_id}/
    END
  END

Logging Additional Admin Session Start
  [Arguments]
  ...  ${logs_dir_path}
  ...  ${bts_host}=192.168.255.129
  ...  ${host_ip}=${EMPTY}
  ...  ${timeout}=120
  ...  ${connection}=default
  ...  ${bts_id}=1
  [Documentation]
  ...  Description:
  ...  Keyword prepares logging session for specific hostname.
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | logs_dir_path          | Yes  | Path to directory for session logging                              |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | host_ip                | No   | IP address in case of remote session.                              |
  ...  |                        |      | For local LMP session parameter is not provided.                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | timeout                | No   | Timeout value for all keywords                                     |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | bts_host               | No   | bts IP address to admin api session, needed only in case           |
  ...  |                        |      | there is mplane connection                                         |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | connection             | No   | admin api connection identifier,  BTS_ID                           |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | bts_id                 | No   | BTS ID number, used mainly in identification and folder definition |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  Logging With Timestamp
  ...  message=Logging additional session activation for BTS_ID ${bts_id} started.
  IF  "${host_ip}"=="${EMPTY}"
    admin.Setup Admin
    ...  bts_host=${bts_host}
    ...  bts_port=443
    ...  admin_api_log_dir=${logs_dir_path}/Admin_API/${bts_id}/
    ...  update_interval=100
    ...  timeout=${timeout}
    ...  name=${connection}
  ELSE IF  "${host_ip}"!="${EMPTY}"
    admin.Setup Admin
    ...  bts_host=${bts_host}
    ...  bts_port=443
    ...  admin_api_log_dir=${logs_dir_path}/Admin_API/${bts_id}/
    ...  remote_host=${host_ip}
    ...  update_interval=100
    ...  timeout=${timeout}
    ...  name=${connection}
  END
  [Teardown]  Logging With Timestamp
  ...  message=Logging session activation for BTS_ID ${bts_id} finished.

Start Taf Syslog Session
  [Arguments]  ${bts_id}  ${name}  ${target_file_name}  ${logs_dir_path}=${TEST_LOGS_PATH}
  [Documentation]   Keyword start logging syslog using TAF syslog on remote node.
  ...  Description:
  ...  Keyword start remote LMP syslog logging.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | name                   | No   | name of connection alias                                                   |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | bts_id                 | No   | btslog_collector connection identifier, usually it is BTS_ID               |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | target_file_name       | Yes  | name of syslog file                                                        |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  Logging With Timestamp
  ...  message=Taf.sw Syslog logging session activation for BTS_ID ${bts_id} started.
  ${bts_alias_type}=  Get From Dictionary  ${CFG.NODES['${bts_id}']}  bts_alias_type
  ${bts_ip_address}=  Get From Dictionary  ${CFG.NODES['${bts_id}']}  bts_ip_address
#   ${secondary_sm_vm_ip_LMP_address}=  Get From Dictionary  ${CFG.NODES['${bts_id}']}  secondary_sm_vm_ip_LMP_address
  # ${secondary_sm_vm_ip_LMP_address}=  Run Keyword And Return Status  Should Not Be Empty  ${secondary_sm_vm_ip_LMP_address}
#   ${secondary_sm_vm_ip_LMP_address}=  Set Variable If  '${secondary_sm_vm_ip_LMP_address}'=='${EMPTY}'
#   ...  ${EMPTY}
#   ...  ${secondary_sm_vm_ip_LMP_address}

  IF  '${bts_alias_type}' == 'localhost'
    taf_syslog.Start Syslog
    ...  log_dir=${logs_dir_path}/UDPlog/${bts_id}
    ...  log_name=${target_file_name}_primary.log
    ...  ip=192.168.255.126
    ...  alias=${name}_primary
    ...  file_limit=${SYSLOG_FILE_LIMIT}
    ...  temp_dir=${CUSTOM_TEMP_DIR}
  ELSE IF  '${bts_ip_address}'=='${EMPTY}'
    taf_syslog.Start Syslog
    ...  log_dir=${logs_dir_path}/UDPlog/${bts_id}
    ...  log_name=${target_file_name}_primary.log
    ...  ip=192.168.255.126
    ...  host_ip=${CFG.NODES['${bts_id}']['vm_ip_LMP_address']}
    ...  alias=${name}_primary
    ...  file_limit=${SYSLOG_FILE_LIMIT}
    ...  temp_dir=${CUSTOM_TEMP_DIR}
  END
#   ${secondary_core_status}=  Run Keyword And Ignore Error  Should Not Be Empty  ${secondary_sm_vm_ip_LMP_address}
  # ${secondary_core_status}=  Run Keyword And Ignore Error
  # ...  Dictionary Should Contain Key  ${CFG.NODES['${bts_id}']}  secondary_sm_vm_ip_LMP_address
  # IF  '${secondary_core_status[0]}'!='FAIL'
  #   ${secondary_sm_vm_ip_LMP_address}=  Get From Dictionary  ${CFG.NODES['${bts_id}']}  secondary_sm_vm_ip_LMP_address
  # ELSE
  #   ${secondary_sm_vm_ip_LMP_address}=  Set Variable  ${None}
  # END
  IF  ${CFG.NODES['${bts_id}']['dualcore']}
    taf_syslog.Start Syslog
    ...  log_dir=${logs_dir_path}/UDPlog/${bts_id}
    ...  log_name=${target_file_name}_secondary.log
    ...  ip=192.168.255.126
    ...  host_ip=${CFG.NODES['${bts_id}']['secondary_sm_vm_ip_LMP_address']}
    ...  alias=${name}_secondary
    ...  file_limit=${SYSLOG_FILE_LIMIT}
    ...  temp_dir=${CUSTOM_TEMP_DIR}
  END

  [Teardown]  Logging With Timestamp
  ...  message=Taf.sw Syslog logging session activation for BTS_ID ${bts_id} finished.

Stop Taf Syslog Session
  [Arguments]  ${bts_id}  ${name}    ${logs_dir_path}=${TEST_LOGS_PATH}
  [Documentation]
  ...  Description:
  ...  Keyword stop logging syslog and save its files using TAF syslog.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | logs_dir_path          | Yes  | Path to directory for session logging                                      |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | name                   | Yes  | btslog_collector connection identifier, usually it is BTS_ID               |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  Logging With Timestamp
  ...  message=Closing taf.sw syslog logging session for name session:${name} started.
  Run Keyword And Continue On Failure
  ...  taf_syslog.Collect Syslog Results  unzip=False  alias=${name}_primary
  ...  destination=${logs_dir_path}/UDPlog/${bts_id}/${bts_id}_primary.log.tar.gz
#   taf_syslog.stop syslog  alias=${name}_primary
#   ${secondary_sm_vm_ip_LMP_address}=  Get From Dictionary  ${CFG.NODES['${bts_id}']}  secondary_sm_vm_ip_LMP_address
  # ${secondary_sm_vm_ip_LMP_address}=  Run Keyword And Return Status  Should Not Be Empty  ${secondary_sm_vm_ip_LMP_address}
#   ${secondary_sm_vm_ip_LMP_address}=  Set Variable If  '${secondary_sm_vm_ip_LMP_address}'=='${EMPTY}'
#   ...  ${EMPTY}
#   ...  ${secondary_sm_vm_ip_LMP_address}
  # ${secondary_core_status}=  Run Keyword And Ignore Error
  # ...  Dictionary Should Contain Key  ${CFG.NODES['${bts_id}']}  secondary_sm_vm_ip_LMP_address
#   ${secondary_core_status}=  Run Keyword And Ignore Error  Should Not Be Empty  ${secondary_sm_vm_ip_LMP_address}
  IF  ${CFG.NODES['${bts_id}']['dualcore']}
    Run Keyword And Continue On Failure
    ...  taf_syslog.Collect Syslog Results
    ...  unzip=False
    ...  alias=${name}_secondary
    ...  destination=${logs_dir_path}/UDPlog/${bts_id}/${bts_id}_secondary.log.tar.gz
    # taf_syslog.stop syslog  alias=${name}_secondary
  ELSE
    ${secondary_sm_vm_ip_LMP_address}=  Set Variable  ${None}
  END


  Logging With Timestamp
  ...  message=Syslog saved under this path: ${TEST_LOGS_PATH}/UDPlog/${bts_id}/
  [Teardown]  Logging With Timestamp  message=Closing taf.sw syslog logging session for name session:${name} finished.


Reset Ute_infomodel Session
  [Arguments]  ${logs_dir_path}  ${bts_host}=192.168.255.129  ${host_ip}=${EMPTY}  ${connection}=default
  [Documentation]
  ...  Description:
  ...  Keyword for resetting ute_infomodel session
  ...  Arguments:
  ...  +========================+======+====================================================================+
  ...  | Argument               | Man. | Description                                                        |
  ...  +========================+======+====================================================================+
  ...  | logs_dir_path          | Yes  | Path to directory for session logging                              |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | bts_host               | No   | bts IP address to admin api session, needed only in case           |
  ...  |                        |      | there is mplane connection                                         |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | host_ip                | No   | IP address in case of remote session.                              |
  ...  |                        |      | For local LMP session parameter is not provided.                   |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...  | connection             | No   | admin api connection identifier,  BTS_ID                           |
  ...  +------------------------+------+--------------------------------------------------------------------+
  ...
  ...  Author: daniel.bartkowiak@nokia.com
  ...  Maintainer: daniel.bartkowiak@nokia.com

  admin_im.Teardown Infomodel  ${connection}
  IF  "IM" in "${TOOLS_TO_SETUP}" and "${host_ip}"=="${EMPTY}"
    admin_im.Setup Infomodel
    ...  address=${bts_host}
    ...  admin_api_log_dir=${logs_dir_path}/Admin_API/${connection}/
    ...  port=443
    ...  timeout=${timeout}
    ...  alias=${connection}
    admin_im.Connect Infomodel  alias=${connection}  timeout=${timeout}
  ELSE IF  "IM" in "${TOOLS_TO_SETUP}" and "${host_ip}"!="${EMPTY}"
    admin_im.Setup Infomodel
    ...  remote_host=${host_ip}
    ...  address=${bts_host}
    ...  admin_api_log_dir=${logs_dir_path}/Admin_API/${connection}/
    ...  port=443
    ...  timeout=${timeout}
    ...  alias=${connection}
    admin_im.Connect Infomodel  alias=${connection}  timeout=${timeout}
  END
