*** Settings ***
Documentation  This suite contains KWs used for Setup an Teardown
# product-specfic settings:
Library  hran_file_operations
Library  ute_admin_infomodel
Library  taf.sbts.oam.coam.admin  WITH NAME  coam
Library  taf.transport.ssh  WITH NAME  ssh
Library  taf.sw.scout
Library  python_resources/tc_alarms/set_tc_alarms.py
Library  taf.ul.alarms_watchdog  WITH NAME  watchdog
# common settings:
Resource  sbts_general.robot
Resource  sbts_infomodel.robot
Resource  sbts_admin.robot
Resource  sbts_netact.robot
Resource  sbts_onap.robot
Resource  syslog_resource.robot
# Sleeping cell resource
Resource  taf/rfrl/common_resources/common_step/interface.robot
Resource  mumin_resource.robot
Variables  python_resources/hidden_alarms_list.py


*** Variables ***
# all needed variables should be given using '--variablefile CONFIG_FILE' or '-V CONFIG_FILE'
@{UDP_PORTS}  51000  51001  51003  50011
${ENABLED}  regex"Enabled|enabled"
${DISABLED}  regex"Disabled|disabled"
${ONLINE}  regex"Online|None"  # None is not used, maybe will be removed
${OFFLINE}  regex"Offline|off line"
${DEGRADED}  regex"Degraded|degraded"
${NOT_INSTALLED}  regex"NotInstalled|not installed"
${FAILED}  regex"Failed|failed"
${UNLOCKED}  regex"Unlocked|unlocked"
${LOCKED}  regex"Locked|locked"
${SHUTTING_DOWN}  regex"ShuttingDown|Shutting Down"
${DEPENDENCY}  regex"Dependency|dependency"
${POWEROFF}  regex"PowerOff|power off"
${TESTING}  regex"Testing|testing"
${INITIALIZING}  regex"Initializing|initializing"
${COMMISSIONED}  regex"Commissioned|commissioned"
${NOT_COMMISSIONED}  regex"NotCommissioned|notCommissioned"
${INTEGRATED_TO_RAN}  regex"IntegratedToRan|integrated to RAN"
${ON_AIR}  regex"OnAir|onAir"
${TEST}  regex"Test|test"
${CONFIGURED}  regex"Configured|configured"
${BLOCKED}  Blocked
${UNBLOCKED}  Unblocked
${BLOCKING}  Blocking
${UNBLOCKING}  Unblocking
${IDLE}  Idle
${ACTIVE}  Active
${BUSY}  Busy
${ON_AIR_DONE}  OnAirDone
${VALIDATED}  Validated
${ROUTING_LOADED}  regex"RoutingLoaded|None"
${RMOD_EXPECTED_STATES}  administrativeState=${UNLOCKED}, operationalState=${ENABLED}
${SMOD_EXPECTED_STATES}  administrativeState=${UNLOCKED}, operationalState=${ENABLED}
${ALD_EXPECTED_STATES}  operationalState=${ENABLED}, availabilityStatus=${ONLINE}
${CELLS_LTE_EXPECTED_STATES}  administrativeState=${UNLOCKED}, operationalState=${ENABLED}, blockingState=${UNBLOCKED}
${CELLS_WCDMA_EXPECTED_STATES}  operationalState=${ENABLED}, blockingState=${UNBLOCKED}, usageState=${ACTIVE}
${DIST_GSM_CELL_RUNTIME_VIEW}  /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/GNBTS_R-*/GNBCF_R-*/GNCEL_R-*
${CELLS_GSM_EXPECTED_STATES}  administrativeState=${UNLOCKED}, operationalState=${ENABLED}, blockingState=${UNBLOCKED}, usageState=${ACTIVE}
${CELLS_NR_EXPECTED_STATES}  administrativeState=${UNLOCKED}, operationalState=${ENABLED}, blockingState=${UNBLOCKED}
${COLLECT_SNAPSHOT_FLAG}  failed_verdict
${COLLECT_SYSLOG_FLAG}  ${TRUE}
${DSC}  ${FALSE}
@{REMOTE_TESTLINES_LIST}  @{EMPTY}  # list of aliases of remote testlines; to be defined using REMOTE_TESTLINES dictionary
# in testline configuration file or json
${REQUEST_SCF_SCOUT}  ${FALSE}
${ALLOW_RECOVERY}  ${FALSE}
${SKIP_RU_POWER_CHECK}  ${FALSE}
${COLLECT_SWCONFIGS}  ${FALSE}

${HW_LOCATION_CODE}  ${EMPTY}
${TESTLINE_NAME}  ${EMPTY}

${MOVE_LOGS_ON_ROTTA}  ${FALSE}  # If set ${TRUE}, then log files from current TC will be saved on rotta
${MOVE_LOGS_ON_KPICRTSHARE1}  ${FALSE}  # If set ${TRUE}, then log files from current TC will be saved on kpicrtshare1
${TIM_DIRECTORY_PATH_ON_ROTTA}  ${EMPTY}  # Mandatory, it should have a value like: SBTS1Vrf/OAM_KPI/CRT.
# /media/rotta/HetRAN_2/mnranpztim/ is the first part of the path to rotta server
${COPY_LOGS_ON_KPI_SHARE1}  ${FALSE}
${ENABLE_COPY_LOGS_ON_KPI_SHARE1}  ${FALSE}

${COMMON_USER}  slogs
${COMMON_PASSWORD}  AUTO_TrAnsf3rLo9
${KPISHARE1_USER}  kpismbuser
${KPISHARE1_PASSWORD}  Aikon_123456&

${OAM_BTS_IP}  192.168.255.129
${OAM_SC_IP}  192.168.255.119  #can be used also as ${SMOD2}[IP]
${OAM_BTS_USER}  Nemuadmin
${OAM_BTS_PASSWORD}  nemuuser
${OAM_BTS_PORT}  443
${SSH_BTS_USER}  toor4nsn  #can be used also as ${SMOD1}[USERNAME]
${SSH_BTS_PASSWORD}  oZPS0POrRieRtu  #can be used also as ${SMOD1}[PASSWORD]

${DISABLE_WATCHDOG}  ${FALSE}


*** Keywords ***
TAF Config Adapter
    [Documentation]  This keyword is used for TAF config adapter.

    @{configuration}  Split String  ${CONFIGURATION}  .
    @{tl_params}  Split String  ${configuration}[1]  _
    Set Suite Variable  ${HW_LOCATION_CODE}  ${configuration}[0]
    Set Suite Variable  ${TESTLINE_NAME}  ${tl_params}[0]_${tl_params}[1]_${tl_params}[2]
    Set Suite Variable  ${TEMP_LOGS_DIR}  /home/ute/btsauto/logs
    Import Library  hran_testline_configuration  ${HW_LOCATION_CODE}  ${TESTLINE_NAME}
    hran_testline_configuration.Set Taf Config Variables


Common Test Setup
    [Documentation]
    ...  Set of actions which will be launched before each SBTS SOAM test (starting from SBTS17).
    ...  List of actions:
    ...  -> Creates log directories
    ...  -> Deletes content of /tmp and /home/ute/btsauto/logs in order to free up space, to ensure Robot test can run
    ...  -> Starts Admin connection
    ...  -> Starts Syslogs collecting
    ...  -> Starts infomodel on LTE site
    ...  -> Starts BTSSM on all sites
    ...  -> Gets and displays SW versions
    ...  -> Checks cells and modules state and active alarms
    ...
    ...  | Parameter            | Default         | Description                                                         |
    ...  | admin_launch         | TRUE            | Whether to initialise/or not Admin connection |
    ...  | syslog_launch        | TRUE            | Whether to collect/or not syslog during TC execution |
    ...  | infomodel_launch     | TRUE            | Whether to initialise/or not InfoModel connection |
    ...  | btssm_launch         | TRUE            | Whether to initialise/or not btssm library |
    ...  | bts_host             | ${OAM_BTS_IP} | IP address to connect with BTS |
    ...  | modules_check        | TRUE            | Flag for enabling/disabling modules precheck |
    ...  | cells_check          | TRUE            | Flag for enabling/disabling cells precheck |
    ...  | alarms_check         | TRUE            | Flag for enabling/disabling alarms precheck |
    ...  | expected_bts_status  | OnAir           | Expected BTS status|
    ...  | scf_check            | TRUE            | Whether to initialise/or not SCF parrser, and checking with SCF |
    ...  | expected_alarms      | empty           | List of expected alarms regex patterns, one for each expected alarm |
    ...  | ignored_alarms       | empty           | List of ignored alarms regex patterns, will be used multiply  |
    ...  | critical_alarms      | empty           | List of critical alarms regex patterns, will be used multiply  |
    ...
    ...  | To run setup for DSC, variable ${DSC}=${True} should be visible in env_config or test parameters in json
    ...  | To run setup for remote testlines, dictionary REMOTE_TESTLINES has to be added to env_config, example entry:
    ...  | REMOTE_TESTLINES:
    ...  |   TESTLINE1:
    ...  |     PC_IP1: <ip_address_of_msm_host>
    ...  |     PC_IP2: <ip_address_of_esm_host>
    ...  |
    ...  | User can import global variables from file in common test setup; ${ADDITIONAL_VARIABLES_PATH} need to be included in json file
    [Arguments]
    ...  ${admin_launch}=${TRUE}
    ...  ${syslog_launch}=${COLLECT_SYSLOG_FLAG}
    ...  ${infomodel_launch}=${TRUE}
    ...  ${modules_check}=${TRUE}
    ...  ${cells_check}=${TRUE}
    ...  ${alarms_check}=${TRUE}
    ...  ${expected_bts_status}=OnAir
    ...  ${scf_check}=${TRUE}
    ...  ${expected_alarms}=@{EMPTY}
    ...  ${ignored_alarms}=@{EMPTY}
    ...  ${critical_alarms}=@{EMPTY}
    ...  ${tc_name}=${EMPTY}
    [Timeout]  40 minutes

    Set Test Variable  ${SCF_CHECK}  ${scf_check}
    Set Test Variable  ${BTSSM_STARTED}  ${FALSE}
    Set Test Variable  ${INFOMODEL_STARTED}  ${FALSE}
    Set Test Variable  ${PC_FLAG_EXISTS}  ${FALSE}
    Set Test Variable  ${SC_FLAG_EXISTS}  ${FALSE}
    Set Test Variable  ${UNIFIED_SYSLOGS}  ${FALSE}
    Set Test Variable  ${ALL_SYSLOGS_STARTED}  ${FALSE}
    Set Test Variable  ${PC_SYSLOGS_STARTED}  ${FALSE}
    Set Test Variable  ${SC_SYSLOGS_STARTED}  ${FALSE}
    Set Test Variable  ${ADMIN_STARTED}  ${FALSE}
    Set Test Variable  ${SCF_PARSER_STARTED}  ${FALSE}
    Set Test Variable  ${BTS_VERIFICATION_STATUS}  norun

    Set Test Verdic Variables

    ${additional_variables_exist}  Run Keyword And Return Status  Variable Should Exist  ${ADDITIONAL_VARIABLES_PATH}
    IF  ${additional_variables_exist}  Run Keyword And Ignore Error  Import Variables  ${ADDITIONAL_VARIABLES_PATH}

    ${taf_config_model}  Run Keyword And Return Status  Variable Should Exist  ${TL}
    Set Test Variable  ${TAF_CONFIG_MODEL}  ${taf_config_model}
    IF  ${TAF_CONFIG_MODEL}
      Taf Config Adapter
    ELSE
      Import Library  hran_testline_configuration  ${HW_LOCATION_CODE}  ${TESTLINE_NAME}
      hran_testline_configuration.Set Config Variables  @{TESTLINE_CONFIG_VARIABLES}
    END
    IF  ${TAF_CONFIG_MODEL} == ${FALSE}  Clean VM Disk Space  Master
    There Should Be At Least 2048 MB Of Disk Space Available In /home/ute

    Log  \nCommon Test Setup  level=INFO  console=true
    Create Dirs For Logs

    Log  TC executed with configuration files of ${HW_LOCATION_CODE}\\${TESTLINE_NAME}  level=INFO  console=true
    Set Tags  ${HW_LOCATION_CODE}\\${TESTLINE_NAME}

    Setup Alarms
    IF  '${tc_name}'!='${EMPTY}'  Set Tc Specific Alarms  ${tc_name}
    Start Watchdog  ${tc_name}
    Set Additional Ignored Alarms

    Set Raw Alarm History Connection Parameters
    Log Variables  level=INFO
    IF  ${admin_launch}  Run Keyword And Continue On Failure  Start Admin  bts_host=${SMOD1['TRS_IP']}
    IF  ${infomodel_launch}  Run Keyword And Continue On Failure  Start Infomodel

    Setup SMOD2  ${ADMIN_STARTED}  ${INFOMODEL_STARTED}
    IF  ${syslog_launch}  Run Keyword And Ignore Error  Start All Syslogs Collection
    Setup Mumin
    IF  ${admin_launch}  Admin Get BTS ID
    IF  ${ADMIN_STARTED}  Run Keyword And Ignore Error  Print Active And Passive SW Version
    IF  ${ADMIN_STARTED} and ${SCF_CHECK}  Run Keyword And Continue On Failure  Start Scf Parser  UNIVERSAL

    IF  ${ADMIN_STARTED}
      ${sbts_state}  ${output}  Run Keyword And Ignore Error  Verify BTS States  ${expected_bts_status}  ${modules_check}
      ...  ${cells_check}  ${alarms_check}  ${expected_alarms}  ${ignored_alarms}  ${critical_alarms}
    ELSE
      ${sbts_state}  Set Variable  PASS
      Set Test Variable  ${BTS_VERIFICATION_STATUS}  passed
    END
    IF  "${sbts_state}"=="FAIL" and "${ALLOW_RECOVERY}"=="${FALSE}"
      Set Test Blocked  TC is stopped due to sbts state failure and sbts recovery is not performed.
    END

    IF  ${DSC}  Run Keyword And Continue On Failure  Remote Test Line Setup  remote_host=${PC_IP2}  alias=DSC

    ${remote_testlines_configured}  ${remote_testlines_tmp}  Run Keyword And Ignore Error  Get Dictionary Keys  ${REMOTE_TESTLINES}
    IF  '${remote_testlines_configured}'=='PASS'
      ${remote_testlines_list}  Set Variable  ${remote_testlines_tmp}
    ELSE
      ${remote_testlines_list}  Create List
    END
    Set Test Variable  ${REMOTE_TESTLINES_LIST}
    FOR  ${remote_alias}  IN  @{REMOTE_TESTLINES_LIST}
        Verify Configuration And Set Up Remote Test Line  ${modules_check}  ${cells_check}  ${alarms_check}  ${remote_alias}
    END

    IF  ${ADMIN_STARTED} and "${BTS_VERIFICATION_STATUS}"=="norun" and ${ALLOW_RECOVERY} and ${TAF_CONFIG_MODEL}
      TRY
        Recover SBTS  ${expected_bts_status}  ${modules_check}  ${cells_check}  ${alarms_check}  ${expected_alarms}  ${ignored_alarms}
        ...  ${critical_alarms}
      EXCEPT
        Fatal Error  BTS recover error. Stop execution.
      END
    ELSE
      Set Preconditions Passed
    END

    IF  not ${ENABLE_COPY_LOGS_ON_KPI_SHARE1}
      IF  ${COPY_LOGS_ON_KPI_SHARE1}  Copy logs on kpi share1
    ELSE
        Log  Copy logs to KPISHARE1 is enabled.  console=true
    END

    IF  ${TAF_CONFIG_MODEL} and ${REQUEST_SCF_SCOUT}  Run Keyword And Ignore Error  Scout Request SCF
    Log  End of Common Test Setup  level=INFO  console=true


Setup Alarms
    [Documentation]  This keyword is used to setup alarms.

    ${ignored_alarms_61524}  Create Dictionary  faultId=61524  faultName=SSH enabled
    ${ignored_alarms_61652}  Create Dictionary  faultId=61652  faultName=R&D Service Port enabled
    ${ignored_alarms_61649}  Create Dictionary  faultId=61649  faultName=LMP access via port 443
    ${ignored_alarms_6450}  Create Dictionary  faultId=6450  faultName=Diagnostic Files collected
    ${ignored_alarms_6450_new_nidd_from_25r1}  Create Dictionary  faultId=6450  faultName=Diagnostic files collected
    ${ignored_alarms_4655}  Create Dictionary  faultId=4655  faultName=Service account root access is enabled
    ${ignored_alarms_4654}  Create Dictionary  faultId=4654  faultName=Ethernet port security is disabled
    ${ignored_alarms_4681_sanity_err}  Create Dictionary  faultId=4681  faultName=Sanity Check Error
    ${ignored_alarms_4681_diagnostic_err}  Create Dictionary  faultId=4681  faultName=Diagnostic Check Error
    ${ignored_alarms_4592}  Create Dictionary  faultId=4592  faultName=BTS Reset Cause
    ${ignored_alarms_8000}  Create Dictionary  faultId=8000  faultName=Failure in connection between BTS and 3rd party tool
    ${ignored_alarms_61675}  Create Dictionary  faultId=61675  faultName=WiFi Configuration Issue
    ${globally_ignored_alarms}  Create List  ${ignored_alarms_61524}  ${ignored_alarms_61652}  ${ignored_alarms_61649}  ${ignored_alarms_6450}
    ...  ${ignored_alarms_4655}  ${ignored_alarms_4654}  ${ignored_alarms_4681_sanity_err}  ${ignored_alarms_4681_diagnostic_err}
    ...  ${ignored_alarms_4592}  ${ignored_alarms_8000}  ${ignored_alarms_61675}  ${ignored_alarms_6450_new_nidd_from_25r1}
    Set Test Variable  ${GLOBALLY_IGNORED_ALARMS}


Start Watchdog
    [Documentation]  This keyword is used to start watchdog.
    [Arguments]  ${tc_name}

    Return From Keyword If  ${DISABLE_WATCHDOG}
    Log  TC is starting alarms monitoring.  console=true
    watchdog.Disallow All Alarms
    Add Globally Ignored Alarms For Watchdog
    Run Keyword If  '${tc_name}'!='${EMPTY}'
    ...  Add Tc Specific Alarms For Watchdog
    set_tc_alarms.Set Connection Parameters For Alarm Watchdog
    watchdog.Watch Alarms  reconnection=${True}  bts_config=${CONN_PARAM_ALARM_WATCHDOG}


Add Globally Ignored Alarms For Watchdog
    [Documentation]  This keyword is used to add globally ignored alarms for watchdog.

    FOR  ${alarm}  IN  @{GLOBALLY_IGNORED_ALARMS}
        ${keys}  Get Dictionary Keys  ${alarm}
        watchdog.Allow Alarm  fault_id=${alarm}[faultId]  fault_name=${alarm}[faultName]
    END


Add Tc Specific Alarms For Watchdog
    [Documentation]  This keyword is used to add tc specific alarms for watchdog.

    FOR  ${fault_id}  IN  @{TC_SPECIFIC_ALARMS}
        ${alarm}  Copy Dictionary  ${TC_SPECIFIC_ALARMS}[${fault_id}]
        Remove From Dictionary  ${alarm}  alarm_name
        watchdog.Allow Alarm  &{alarm}
    END


Stop Watchdog
    [Documentation]  This keyword is used to stop watchdog.

    Return From Keyword If  ${DISABLE_WATCHDOG}
    ${unexpected_alarms}  watchdog.Get Detected Alarms
    ${unexpected_alarms_are_active}  watchdog.Has Detected Alarms
    watchdog.Stop Watching Alarms
    Check If Alarms Should Be Hidden  ${unexpected_alarms}
    Run Keyword If  ${unexpected_alarms_are_active}
    ...  Fail  Unexpected alarms were detected during TC execution: ${unexpected_alarms}.
    ...  ELSE
    ...  Log  \nAlarms monitoring stopped. No unexpected fault was detected.  console=true

    [Return]  ${unexpected_alarms_are_active}


Recover SBTS
    [Documentation]  This keyword is used to recover SBTS.
    [Arguments]  ${expected_bts_status}  ${modules_check}  ${cells_check}  ${alarms_check}  ${expected_alarms}  ${ignored_alarms}  ${critical_alarms}

    Log  SBTS status not ok. Power reset will be performed.  console=true
    Power SBTS  off
    ${ping_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}  timeout=60
    Run Keyword If  ${ping_status}
    ...  Log  SBTS power off.
    ...  ELSE
    ...  Fail  Unable to power off SBTS.
    Sleep  10
    Power SBTS  on
    ${ping_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}  timeout=300
    Run Keyword If  ${ping_status}
    ...  Log  SBTS online.
    ...  ELSE
    ...  Fail  Unable to power on SBTS.
    ${verification_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  60m  1m
    ...  Verify BTS States  ${expected_bts_status}
    ...  ${modules_check}
    ...  ${cells_check}
    ...  ${alarms_check}
    ...  ${expected_alarms}
    ...  ${ignored_alarms}
    ...  ${critical_alarms}
    Run Keyword If  ${verification_status} == ${FALSE}
    ...  Fatal Error  SBTS recovery didn't pass. Tests execution will be stopped.
    Set Preconditions Passed


Power SBTS
    [Documentation]  This keyword is used to power SBTS.
    [Arguments]  ${action}

    FOR  ${unit}  IN  @{INTERFACES}
        Run Keyword If  '${action}'=='on'
        ...  Pdu BTS Interface On  ${unit}
        ...  ELSE
        ...  Pdu BTS Interface Off  ${unit}
        Log  Interface ${unit} turned ${action}  console=True
    END


Setup SMOD2
    [Documentation]  This keyword is used to setup SMOD2.
    [Arguments]  ${admin_started}  ${infomodel_started}

    ${smod2_variable_exists}  Run Keyword And Return Status
    ...  Variable Should Exist  ${SMOD2}
    ${pc_ip2_variable_exists}  Run Keyword And Return Status
    ...  Variable Should Exist  ${PC_IP2}
    Run Keyword If  '${smod2_variable_exists}'=='${False}' or '${pc_ip2_variable_exists}'=='${False}'
    ...  Run Keywords
    ...  Log  One SMOD or none PC_IP2 was declared in config  console=true
    ...  AND
    ...  Set Test Variable  ${SMOD2_EXISTS}  ${FALSE}
    ...  AND
    ...  Return From Keyword
    Run Keyword If  ${admin_started} and ${infomodel_started}
    ...  Check SMOD2 In Admin
    ...  ELSE
    ...  Run Keywords
    ...  Log  Skip checking SMOD2 in Admin  console=true
    ...  AND
    ...  Set Test Variable  ${SMOD2_EXISTS}  ${TRUE}

    Run Keyword If  ${TAF_CONFIG_MODEL} == ${FALSE}
    ...  Run Keyword If  ${SMOD2_EXISTS}
    ...  Clean VM Disk Space  Extension  host_ip=${PC_IP2}  ssh_port=${22}  ssh_username=ute  ssh_password=ute
    Run Keyword If  ${TAF_CONFIG_MODEL} == ${FALSE}
    ...  Run Keyword If  ${SMOD2_EXISTS}
    ...  Check If Remote Host Directory Has Enough Space  /home/ute  2048  ${PC_IP2}  ${22}  ute  ute


Common Test Teardown
    [Documentation]
    ...  Set of actions which will be launched after each SBTS SOAM test ends (starting from SBTS17).
    ...  List of actions:
    ...  -> Triggers snapshot depends on selected option and test_verdict
    ...  -> Gets and displays siteName information from siteconf.xml for Master and Slave SM (if slave_tech is not GSM)
    ...  -> Collects BTSSM files and stops BTSSM session
    ...  -> Collects Infomodel files and stops Infomodel session
    ...  -> Collects Syslog files ands stops logging
    ...  -> Collects Admin files and stops Admin session
    ...
    ...  | Parameter        | Default        | Description                                |
    ...  | collect_snapshot | failed_verdict | Flag for enabling/disabling snapshot trace |
    ...
    ...  | Possible collect_snapshot values | Description
    ...  | always                           | Snapshot is collected unless the test verdict is norun |
    ...  | failed_verdict                   | Snapshot is collected if the test verdict is failed or blocked |
    ...  | passed_with_restriction          | Snapshot is collected if the test verdict is failed, blocked or passed_with_restriction |
    ...  | never                            | Snapshot is not collected |
    ...
    [Arguments]  ${collect_snapshot}=${COLLECT_SNAPSHOT_FLAG}

    # this is to allow one to override `collect_snapshot` by providing it in a command line / JSON,
    # even if it is set in a TC (as in `Common Test Teardown  collect_snapshot=never`)
    ${collect_snapshot}  Set Variable If  '${COLLECT_SNAPSHOT_FLAG}' != 'failed_verdict'  ${COLLECT_SNAPSHOT_FLAG}  ${collect_snapshot}

    Log  Common Test Teardown  level=INFO  console=true

    Log  Running Common step trigger to check sleeping cells.  console=true
    Run Keyword And Ignore Error  interface.Common Step Trigger  pass_ru_power_check=${SKIP_RU_POWER_CHECK}

    IF  '${BTS_VERIFICATION_STATUS}'=='norun' and ${ADMIN_STARTED}==${TRUE}
      Set Test Blocked  Initial verification of BTS states was not completed due to timeout, or some unit indicates a faulty state.
    END
    ${snapshot_fail_watchdog}  Stop Watchdog
    Log Verdict Messages
    ${test_verdict}  Get Test Verdict
    ${collect_snapshot_condition_1}  Set Variable  '${collect_snapshot}'=='always' and '${test_verdict}'!='norun'
    ${collect_snapshot_condition_2}  Set Variable
    ...  '${collect_snapshot}'=='failed_verdict' and ('${test_verdict}'=='failed' or '${test_verdict}'=='blocked')
    ${collect_snapshot_condition_3}  Catenate
    ...  '${collect_snapshot}'=='passed_with_restriction' and ('${test_verdict}'=='failed' or '${test_verdict}'=='blocked' or
    ...  '${test_verdict}'=='passed_with_restriction')
    IF  ${collect_snapshot_condition_1} or ${collect_snapshot_condition_2} or ${collect_snapshot_condition_3} or ${snapshot_fail_watchdog}
      Admin Get Snapshot
      IF  ${SMOD2_EXISTS}  Admin Get Snapshot For ESM
      Collect Extended TRS Logs
      Collect Snapshot From Remote Test Lines
    END
    Collect Mumin Logs
    Teardown Mumin
    IF  ${DSC}  Remote Test Line Teardown  alias=DSC  verify_states_stability=${True}
    FOR  ${remote_line_alias}  IN  @{REMOTE_TESTLINES_LIST}
        Remote Test Line Teardown  alias=${remote_line_alias}
    END
    Teardown Infomodel Connections
    IF  ${ADMIN_STARTED}
      Admin Print Active Alarms TAF  output_file=${TEST_RESULTS_DIR}/teardown_active_alarms.json
      Collect Infomodel Log From Current Session  target_file_name=${BTS_FILES}/IM/InfoModel_log.ims2  timeout=300  leave_disconnect_logs=True
    END
    Teardown All Aliases For Admin

    Run Keyword And Ignore Error  Collect All Syslogs
    IF  ${SCF_PARSER_STARTED}  Teardown Scf Parser
    IF  ${COLLECT_SWCONFIGS}  Collect Swconfigs
    Collect RawAlarmHistory

    Log  End of Common Test Teardown  level=INFO  console=true

    Align Verdicts
    IF  'STOPONFAIL' in @{TEST_TAGS} and '${TEST_STATUS}' == 'FAIL'  Fatal Error  Execution stopped because critical TC '${TEST_NAME}' failed.

    IF  ${ENABLE_COPY_LOGS_ON_KPI_SHARE1}  Copy Logs To KPISHARE1
    ssh.Reset Cache  #This is added to make sure all open ssh sessions(made with taf.transport.ssh) are closed.


Clean VM Disk Space
    [Documentation]
    ...  Wrapper function for KW used for VM cleaning. Cleaning will be perfomrmed on /tmp and ${Temp Logs Dir}. Also
    ...  processes remaining after files deletion would be killed.
    [Arguments]  ${alias}  &{configuration}

    Run Keyword If  '${alias}'=='local' or '${alias}'=='Master'
    ...  Run Keywords
    ...  Clean Up Directory  /tmp  720  ${alias}
    ...  AND
    ...  Clean Up Directory  /home/ute/btsauto/logs  240  ${alias}
    ...  AND
    ...  sbts_general.Kill Processes Remained After Files Deletion On VMs /home Partition  ${alias}
    ...  ELSE
    ...  Run Keywords
    ...  Clean Up Directory  /tmp
    ...  720
    ...  ${alias}
    ...  host_ip=${configuration["host_ip"]}
    ...  ssh_port=${configuration["ssh_port"]}
    ...  ssh_username=${configuration["ssh_username"]}
    ...  ssh_password=${configuration["ssh_password"]}
    ...  AND
    ...  Clean Up Directory  /home/ute/btsauto/logs
    ...  240
    ...  ${alias}
    ...  host_ip=${configuration["host_ip"]}
    ...  ssh_port=${configuration["ssh_port"]}
    ...  ssh_username=${configuration["ssh_username"]}
    ...  ssh_password=${configuration["ssh_password"]}
    ...  AND
    ...  sbts_general.Kill Processes Remained After Files Deletion On VMs /home Partition  ${alias}
    ...  host_ip=${configuration["host_ip"]}
    ...  ssh_port=${configuration["ssh_port"]}
    ...  ssh_username=${configuration["ssh_username"]}
    ...  ssh_password=${configuration["ssh_password"]}


Start All Syslogs Collection
    [Documentation]  This keyword starts syslog collection on PC, SC or BTS.

    Verify swconfig.Txt File And Flag On PC
    Run Keyword If  ${SMOD2_EXISTS}
    ...  Verify swconfig.Txt File And Flag On SC
    Run Keyword If  ${UNIFIED_SYSLOGS} and ${PC_FLAG_EXISTS}
    ...  Start Syslog Collection On BTS
    Run Keyword If  ${UNIFIED_SYSLOGS} == ${FALSE} and ${PC_FLAG_EXISTS}
    ...  Start Syslog Collection On PC
    Run Keyword If  ${UNIFIED_SYSLOGS} == ${FALSE} and ${SC_FLAG_EXISTS}
    ...  Start SC Syslog Collection


Collect All Syslogs
    [Documentation]  This keyword collects syslogs from PC, SC or BTS.

    Run Keyword If  ${ALL_SYSLOGS_STARTED}
    ...  Run Keywords
    ...  syslog.Collect Syslog Results  destination=${UDP_LOGS}/SYSLOG_BTS_UDP.tar.gz  unzip=False  alias=SYSLOG_BTS_UDP
    ...  AND
    ...  Log  BTS syslogs successfully collected to ${UDP_LOGS} directory.  console=true
    Run Keyword If  ${PC_SYSLOGS_STARTED}
    ...  Run Keywords
    ...  syslog.Collect Syslog Results  destination=${UDP_LOGS}/SYSLOG_PC_UDP.tar.gz  unzip=False  alias=SYSLOG_PC_UDP
    ...  AND
    ...  Log  PC syslogs successfully collected to ${UDP_LOGS} directory.  console=true
    Run Keyword If  ${SC_SYSLOGS_STARTED}
    ...  Run Keywords
    ...  syslog.Collect Syslog Results  destination=${UDP_LOGS}/SYSLOG_SC_UDP.tar.gz  unzip=False  alias=SYSLOG_SC_UDP
    ...  AND
    ...  Log  SC syslogs successfully collected to ${UDP_LOGS} directory.  console=true

    [Teardown]  Run Keyword And Ignore Error  Teardown aliases and kill syslog processes  after_collection_ssh


Ensure That SMOD2 Is Detected Inside ADMIN
    [Documentation]  This keyword is used to ensure that SMOD2 is detected inside ADMIN.

    ${smods}  Get Ids For All  SMOD
    Run Keyword If  len(${smods}) != 2
    ...  Fail  SMOD2 wasn't detected inside ADMIN

    [Return]  ${TRUE}


Start Remote Syslog
    [Documentation]  This keyword is used to start remote syslog.
    [Arguments]  ${remote_host}  ${udp_ip}  ${alias}

    Run Keyword And Ignore Error
    ...  Kill Process By Name  btslog  local=${FALSE}  host_ip=${remote_host}  ssh_port=22  ssh_username=ute  ssh_password=ute
    Run Keyword And Ignore Error
    ...  Stop Syslog  alias=${alias}
    ${file_limit}  Get Variable Value  ${MAX_UDP_SIZE}  0
    ${syslog_started}  Run Keyword And Return Status
    ...  Start Syslog  alias=${alias}
    ...  log_dir=${TEMP_LOGS_DIR}
    ...  log_name=${alias}_UDP
    ...  ip=${udp_ip}
    ...  ports=@{UDP_PORTS}
    ...  host_ip=${remote_host}
    ...  file_limit=${file_limit}
    Set Test Variable  ${${alias}_syslog_started}  ${syslog_started}


Collect Syslog From ${alias}
    [Documentation]  This keyword is used to collect syslog.

    Log  ${alias} syslog will be terminated  level=INFO  console=true
    ${syslog_collected}  Run Keyword And Return Status
    ...  Collect Syslog Results  alias=${alias}  destination=${UDP_LOGS}/${alias}_UDP.tar.gz  unzip=false
    Run Keyword If  ${syslog_collected}
    ...  Log  ${alias} syslog collected to 'UDP Logs'  level=INFO  console=true
    ...  ELSE
    ...  Log  ${alias} syslog collection failed  level=INFO  console=true


Start Infomodel
    [Documentation]  This keyword is used to start infomodel.
    [Arguments]  ${bts_host}=${OAM_BTS_IP}

    Log  Trying to setup and connect to infomodel (max 5 min)  level=INFO  console=true
    ${infomodel_started}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  5 min  15 sec
    ...  _Single Attempt To Start Infomodel  bts_host=${bts_host}
    Set Test Variable  ${INFOMODEL_STARTED}
    Run Keyword If  ${INFOMODEL_STARTED} == ${FALSE}
    ...  Set Test Blocked  Infomodel connection did not start
    Log  Connection to infomodel successfully established!  level=INFO  console=true


_Single Attempt To Start Infomodel
    [Documentation]  This keyword is used to single attempt to Start Infomodel.
    [Arguments]  ${bts_host}=${OAM_BTS_IP}

    Log  Trying to setup infomodel  level=INFO  console=true
    Setup Infomodel  address=${bts_host}  port=443  timeout=90  use_ssl=True  admin_api_log_dir=${BTS_FILES}/
    Log  Trying to connect to infomodel  level=INFO  console=true
    ${infomodel_started}  Run Keyword And Return Status
    ...  Connect Infomodel  timeout=90
    Run Keyword If  ${infomodel_started} == ${FALSE}
    ...  Run Keywords
    ...  Teardown Infomodel
    ...  AND
    ...  Fail  Failed to start Infomodel


Teardown Infomodel Connections
    [Documentation]  This keyword is used to teardown infomodel connections.

    Log  Connection to infomodel will be terminated  level=INFO  console=true
    Teardown All Aliases For Infomodel  imstimeout=180
    Log  Connection to infomodel terminated  level=INFO  console=true


Start Admin
    [Documentation]  This keyword is used to start admin.
    [Arguments]  ${bts_host}=${OAM_BTS_IP}  ${bts_port}=443  ${use_ssl}=TRUE  ${alias}=default

    Log  Trying to connect to admin (max 5 min)  level=INFO  console=true
    Set Software Release Name  ${bts_host}  ${bts_port}  ${use_ssl}  alias=get_sw_release
    ${release}  Run Keyword If  '9999' in '${SW_VERSION}'
    ...  Set Variable  ${None}
    ...  ELSE
    ...  Set Variable  ${ENB_BRANCH}
    Open Admin Connection  ${bts_host}  ${bts_port}  ${use_ssl}  ${alias}  release_name=${release}


Set Software Release Name
    [Documentation]  This keyword is used to set software release name.
    [Arguments]  ${bts_host}  ${bts_port}  ${use_ssl}  ${alias}

    ${admin_started}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  5 min  15 sec
    ...  Setup Admin  bts_host=${bts_host}  bts_port=${bts_port}  use_ssl=${use_ssl}  alias=${alias}  update_interval=1000
    Run Keyword If  ${admin_started} == ${FALSE}
    ...  Set Test Blocked  Admin connection did not start to get SW release name
    ${enb_branch}  Get Sw Release Name  connection=${alias}  timeout=5m
    ${sw_version}  Get Sw Version  connection=${alias}  timeout=5m
    Set Test Variable  ${ENB_BRANCH}
    Set Test Variable  ${SW_VERSION}
    Teardown Admin  connection=${alias}


Open Admin Connection
    [Documentation]  This keyword is used to open admin connection.
    [Arguments]  ${bts_host}  ${bts_port}  ${use_ssl}  ${alias}  ${release_name}

    ${admin_started}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  5 min  15 sec
    ...  Setup Admin  admin_api_log_dir=${BTS_FILES}
    ...  bts_host=${bts_host}
    ...  bts_port=${bts_port}
    ...  use_ssl=${use_ssl}
    ...  alias=${alias}
    ...  update_interval=500
    ...  release=${release_name}
    ...  timeout=5m
    Run Keyword If  ${admin_started} == ${FALSE}
    ...  Set Test Blocked  Admin connection did not start
    Set Test Variable  ${ADMIN_STARTED}
    Log  Connection to admin successfully established!  level=INFO  console=true


Start SCF Parser
    [Documentation]
    ...  Start SCFC Parser from library hran_file_operations with given parser technology.
    ...  | Parameter    | Man. | Description                                          |
    ...  | parser_tech  | No   | Parser technology (UNIVERSAL, SBTS, WCDMA, LTE, GSM) |
    [Arguments]  ${parser_tech}=SBTS

    _Set SW_TYPE
    _Set COMMISSIONING_PATH
    Log  SCF which will be used to verify BTS (${COMMISSIONING_PATH})  console=true
    ${scf_parser_started}  hran_file_operations.Setup SCFC Parser  ${COMMISSIONING_PATH}  parser_technology=${parser_tech}
    Set Test Variable  ${SCF_PARSER_STARTED}
    Run Keyword If  ${SCF_PARSER_STARTED}
    ...  Log  SCF Parser started!
    ...  ELSE
    ...  Set Test Blocked  SCF Parser did not start


_Set SW_TYPE
    [Documentation]  This keyword is used to set SW_TYPE.

    ${regex}  Set Variable  (?i)(wn\\d+_fl\\d+_gf\\d+_)?(?P<product>(SBTS|5G|FL|WN|WBTS|FDSW|TL)[0-9]*)(?P<postfix>[a-zA-Z0-9\.]*)
    ${result}  Get Regexp Matches  ${ACTIVE_SW_VERSION}  ${regex}  product  postfix
    ${product}  ${postfix}  Set Variable  ${result[0]}
    ${product}  Convert To Uppercase  ${product}
    ${postfix}  Convert To Uppercase  ${postfix}
    Set Test Variable  ${SW_TYPE}  ${product}${postfix}


_Set COMMISSIONING_PATH
    [Documentation]  This keyword is used to set COMMISSIONING_PATH.

    ${custom_scf_path}  Get Variable Value  ${COMMISSIONING_PATH}  ${EMPTY}
    Return From Keyword If  '${custom_scf_path}'!=''
    ${is_qt_testline}  Run Keyword And Return Status
    ...  Should Match Regexp  ${TESTLINE_NAME}  QT-
    Run Keyword If  ${is_qt_testline}
    ...  Find QTs SCF File In Robotlte Configs
    ...  ELSE IF  ${TAF_CONFIG_MODEL}
    ...  Find SCF File In UTE Configs
    ...  ELSE
    ...  Find SCF File


Teardown SCF Parser
    [Documentation]  This keyword is used to teardown SCF Parser.

    Log  Teardown scf Parser  level=INFO  console=true
    hran_file_operations.Teardown SCFC Parser


Set Raw Alarm History Connection Parameters
    [Documentation]  This keyword is used to set Raw Alarm History Connection Parameters.

    Log  Set Raw Alarm History Connection Parameters  level=INFO  console=true
    hran_file_operations.Rah Set Connection Parameters  target_path=/tmp/RawAlarmHistory.txt  target_ip=${SMOD1['IP']}
    ...  target_username=${SMOD1['USERNAME']}  target_password=${SMOD1['PASSWORD']}  destination_directory=${BTS_FILES}/


Find SCF File
    [Documentation]  This keyword is used to find SCF file.

    Log  Find SCF file  console=true
    ${commissioning_path}  Get Commissioning Path  ${ACTIVE_SW_VERSION}
    Set Test Variable  ${COMMISSIONING_PATH}


Find QTs SCF File In Robotlte Configs
    [Documentation]  This keyword is used to find QTs SCF file in robotlte configs.

    Log  Find SCF file in robotlte configs in QT way  console=true
    ${soft_version}  Set Variable If  "${SBTS_VERSION}"=="SBTS17"  SBTS17  SBTS00
    ${commissionings_directory}  Set Variable  /home/ute/robotlte/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/node1
    ${files_list}  Get All Files From Dir  ${commissionings_directory}
    ${commissioning_file}  Filter Files List  ${files_list}  BTS_CLOUD_.*_${soft_version}.*xml
    Set Test Variable  ${COMMISSIONING_PATH}  ${commissionings_directory}/${commissioning_file[0]}


Find SCF File In UTE Configs
    [Documentation]  This keyword is used to find SCF file in UTE configs.

    Log  Find SCF file in UTE configs  console=true
    ${path_status}  Run Keyword And Return Status
    ...  OperatingSystem.Directory Should Exist  /home/ute/testline_configuration/${TESTLINE_NAME}
    ${config_path}  Set Variable If  ${path_status}  /home/ute/testline_configuration/${TESTLINE_NAME}
    ...  /home/ute/robotlte/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}
    ${commissionings_directory}  Set Variable  ${config_path}/node1
    @{enb_build_split}  Split String  ${ENB_BRANCH}  _
    Set Test Variable  ${COMMISSIONING_PATH}  ${commissionings_directory}/BTS_${TL.tl_cloud_topology}_${enb_build_split}[0].xml


Verify BTS States
    [Documentation]  This keyword is used to verify BTS states.
    [Arguments]
    ...  ${expected_bts_status}=OnAir
    ...  ${modules_check}=${TRUE}
    ...  ${cells_check}=${TRUE}
    ...  ${alarms_check}=${TRUE}
    ...  ${expected_alarms}=@{EMPTY}
    ...  ${ignored_alarms}=@{EMPTY}
    ...  ${critical_alarms}=@{EMPTY}
    ...  ${bts_state_is_correct}=${FALSE}
    ...  ${system_modules_working}=${FALSE}
    ...  ${radio_modules_working}=${FALSE}
    ...  ${cells_gsm_onair}=${FALSE}
    ...  ${cells_wcdma_onair}=${FALSE}
    ...  ${cells_lte_onair}=${FALSE}
    ...  ${cells_nr_onair}=${FALSE}
    ...  ${alarms_status}=FAIL

    ${bts_state_is_correct}  ${bts_current_status}  Verify BTS ProceduralState  ${expected_bts_status}
    ${system_modules_working}  Run Keyword If  ${modules_check}
    ...  Verify System Modules States
    ...  ELSE
    ...  Set Variable  ${TRUE}
    ${radio_modules_working}  Run Keyword If  ${modules_check}
    ...  Verify Radio Modules States
    ...  ELSE
    ...  Set Variable  ${TRUE}
    ${alds_working}  Run Keyword If  ${modules_check}
    ...  Verify Ald States
    ...  ELSE
    ...  Set Variable  ${TRUE}
    ${cells_gsm_onair}  Run Keyword If  ${cells_check}
    ...  Verify GSM Cells States
    ...  ELSE
    ...  Set Variable  ${TRUE}
    ${cells_wcdma_onair}  Run Keyword If  ${cells_check}
    ...  Verify WCDMA Cells States
    ...  ELSE
    ...  Set Variable  ${TRUE}
    ${cells_lte_onair}  Run Keyword If  ${cells_check}
    ...  Verify LTE Cells States
    ...  ELSE
    ...  Set Variable  ${TRUE}
    ${cells_nr_onair}  Run Keyword If  ${cells_check}
    ...  Verify NR Cells States
    ...  ELSE
    ...  Set Variable  ${TRUE}
    ${all_available_cells}  Admin Get Ids For All Cells TAF
    Set Test Variable  ${ALL_AVAILABLE_CELLS}

    ${alarms_status}  ${alarms_msg}  Run Keyword If  ${alarms_check}
    ...  Run Keyword And Ignore Error
    ...  Admin Check Active Alarms TAF  expected_patterns=${expected_alarms}  ignored_patterns=${ignored_alarms}  critical_patterns=${critical_alarms}
    Run Keyword If  '${alarms_status}'=='FAIL'
    ...  Log  Critical fail while checking alarms: ${alarms_msg}  console=true
    ...  ELSE IF  ${alarms_msg}
    ...  Set Test Restriction  Unexpected alarms are present: ${alarms_msg}

    ${statuses_dictionary}  Create Dictionary  BTS_state_is_correct=${bts_state_is_correct}  system_modules_working=${system_modules_working}
    ...  radio_modules_working=${radio_modules_working}  alds_working=${alds_working}  cells_GSM_onair=${cells_gsm_onair}
    ...  cells_WCDMA_onair=${cells_wcdma_onair}  cells_LTE_onair=${cells_lte_onair}  cells_NR_onair=${cells_nr_onair}  alarms_status=${alarms_status}
    ${pretty_statuses}  Evaluate  pprint.pformat(${statuses_dictionary}, indent=4)  modules=pprint

    ${cells_count_status}  Run Keyword And Return Status
    ...  Should Be Empty  ${ALL_AVAILABLE_CELLS}
    Run Keyword If  '${bts_current_status}' == 'NotCommissioned' and ${cells_count_status} and ${bts_state_is_correct} == ${FALSE}
    ...  Fail  Test blocked due to BTS status: NotCommissioned. There are 0 configred cells.\nSkip to teardown!
    ${sbts_is_enabled}  Catenate  ${bts_state_is_correct} and ${system_modules_working} and ${radio_modules_working}
    ...  and ${alds_working} and ${cells_gsm_onair} and ${cells_wcdma_onair} and ${cells_lte_onair} and ${cells_nr_onair}
    ...  and '${alarms_status}'!='FAIL'
    Run Keyword If  ${sbts_is_enabled}
    ...  Set Test Variable  ${BTS_VERIFICATION_STATUS}  passed
    ...  ELSE
    ...  Fail  Test blocked due to failure of BTS initial check:\n${pretty_statuses}.\nSkip to teardown!


Verify BTS ProceduralState
    [Documentation]  Verifies that the BTS procedural state matches the expected value.
    ...  Returns a tuple of (status_match, current_status).
    ...
    ...  Arguments:
    ...  - expected_bts_status: Expected procedural state regexp (e.g. COMMISSIONED)
    ...
    ...  Returns: (True/False, current_state_string)
    [Arguments]  ${expected_bts_status}

    Log  Start BTS commissioning verification  console=true
    ${current_status}  coam.Get Mrbts State
    ${bts_in_expected_status}  Run Keyword And Return Status
    ...  Should Match Regexp  ${current_status}  ${expected_bts_status}
    Run Keyword If  ${bts_in_expected_status}
    ...  Log  BTS is in expected status (${current_status})!  console=true
    ...  ELSE
    ...  Log  BTS has state other than expected.  console=true

    [Return]  ${bts_in_expected_status}  ${current_status}


Verify System Modules States
    [Documentation]
    ...  Wrapper KW for checking SMOD product numbers against SCF and comparing SMOD states with states defined in
    ...  ${SMOD_EXPECTED_STATES} variable

    Log  Start system modules verification  console=true
    Run Keyword If  ${SCF_PARSER_STARTED}
    ...  Set SCF System Modules Count And Verify Product Numbers
    Run Keyword And Return
    ...  Verify Modules TAF  SMOD  scf_check=${SCF_PARSER_STARTED}


Verify Radio Modules States
    [Documentation]
    ...  Wrapper KW for checking RMOD product numbers against SCF and comparing RMOD states with states defined in
    ...  ${RMOD_EXPECTED_STATES} variable

    Log  Start radio modules verification  console=true
    Run Keyword If  ${SCF_PARSER_STARTED}
    ...  Set SCF Radio Modules Count And Verify Product Numbers
    Run Keyword And Return
    ...  Verify Modules TAF  RMOD  scf_check=${SCF_PARSER_STARTED}


Verify Ald States
    [Documentation]
    ...  Wrapper KW for comparing ALD states with states defined in ${ALD_EXPECTED_STATES} variable. Because of ticket
    ...  https://jiradc.int.net.nokia.com/browse/URW-5861, productCode checking is now omitted

    Log  Start ALD verification  console=true
    Run Keyword And Return
    ...  Verify Modules TAF  ALD  scf_check=${FALSE}


Verify ${technology} Cells States
    [Documentation]
    ...  Wrapper KW for checking all RATs cells count against SCF and comparing cells states with states defined in
    ...  ${CELLS_LTE_EXPECTED_STATES}, ${CELLS_WCDMA_EXPECTED_STATES} and ${CELLS_GSM_EXPECTED_STATES} variables

    Log  Start ${technology} cells verification  console=true
    Run Keyword If  ${SCF_PARSER_STARTED}
    ...  Set Cells Count  ${technology}
    Run Keyword And Return
    ...  Verify Cells TAF  ${technology}  scf_check=${SCF_PARSER_STARTED}


Print Active And Passive SW Version
    [Documentation]  This keyword is used to print active and passive SW version.

    ${bts_info}  coam.Get Parameters For All  BTS
    Set Test Variable  ${ACTIVE_SW_VERSION}  ${bts_info}[0][activeSoftwareVersion]
    Set Test Variable  ${PASSIVE_SW_VERSION}  ${bts_info}[0][passiveSoftwareVersion]
    ${expected_sw_release}  Set Variable  [A-Z]+[0-9]{2}(?=[0-9A-Z]{0,2}?_[A-Z3-4]+_\\d{4}_\\d{6}_\\d{6})
    ${status}  ${sbts_version}  Run Keyword And Ignore Error  Should Match Regexp  ${ACTIVE_SW_VERSION}  ${expected_sw_release}

    Log  Active SW version: ${ACTIVE_SW_VERSION}  console=true
    Set Tags  SW_active-${ACTIVE_SW_VERSION}
    Log  Passive SW version: ${PASSIVE_SW_VERSION}  console=true
    Set Tags  SW_passive-${PASSIVE_SW_VERSION}

    IF  '${status}'!='PASS'  Set Test Norun  Software is not compatible with this frame (expected ${expected_sw_release})

    Set Test Variable  ${SBTS_VERSION}


Collect Extended TRS Logs
    [Documentation]  This keyword is used to collect extended TRS logs.

    Log  Collecting extended TRS logs  console=true
    ${command}  Set Variable  /opt/trs/etc/collect_tech_logs.sh --filename=/ffs/run/logs/TRSExtendedLogs.tar.xz
    ${trs_logs_collected}  Run Keyword And Return Status
    ...  Run Keywords
    ...  Connect To SMOD  ${SMOD1['IP']}
    ...  AND
    ...  ssh.Execute  ${command}  timeout=60m  # This is added just to prevent command stuck.
    ...  AND
    ...  Get File From System Module  source_path=/ffs/run/logs/TRSExtendedLogs.tar.xz  destination_path=${BTS_FILES}/
    Run Keyword If  ${trs_logs_collected}
    ...  Run Keywords
    ...  Log  Extended TRS logs collected  console=true
    ...  AND
    ...  Return From Keyword
    Log  Extended TRS logs not collected!  console=true


Collect Swconfigs
    [Documentation]  This keyword is used to collect Swconfigs.

    ${status}  ${result}  Run Keyword And Ignore Error
    ...  Get File From System Module  target_ip=${OAM_BTS_IP}  source_path=/ffs/run/swconfig.txt  destination_path=${BTS_FILES}/
    Run Keyword If  '${status}'=='PASS'
    ...  Log  swconfig.txt from System module collected  console=true
    ...  ELSE
    ...  Run Keyword
    ...  Log  swconfig.txt could not be retrieved from System Module! Error: ${result}  console=true
    Run Keyword If  ${SMOD2_EXISTS}
    ...  Get Swconfig From Extension


Get Swconfig From Extension
    [Documentation]  This keyword is used to get Swconfig from extension.

    ${status}  ${result}  Run Keyword And Ignore Error
    ...  Get File From System Module  target_ip="${OAM_SC_IP}"  source_path=/ffs/run/swconfig.txt  destination_path=${BTS_FILES}/  via_ip=${PC_IP2}
    Run Keyword If  '${status}'=='PASS'
    ...  Run Keywords
    ...  Log  swconfig.txt from Extension module collected  console=true
    ...  AND
    ...  Return From Keyword
    ${status}  ${result}  Run Keyword And Ignore Error
    ...  Get File From System Module  target_ip="${OAM_BTS_IP}"  source_path=/ffs/run/swconfig.txt  destination_path=${BTS_FILES}/  via_ip=${PC_IP2}
    Run Keyword If  '${status}'=='PASS'
    ...  Run Keyword
    ...  Log  swconfig.txt from Extension module collected  console=true
    ...  ELSE
    ...  Run Keyword
    ...  Log  swconfig.txt could not be retrieved from Extension Module!  console=true


Collect RawAlarmHistory
    [Documentation]  This keyword is used to collect RawAlarmHistory.

    ${status}  ${result}  Run Keyword And Ignore Error
    ...  Get File From System Module  source_path=/tmp/RawAlarmHistory.txt  destination_path=${BTS_FILES}/
    Run Keyword If  '${status}'=='PASS'
    ...  Log  RawAlarmHistory.txt from System module collected  console=true
    ...  ELSE
    ...  Run Keyword
    ...  Log  RawAlarmHistory.txt could not be retrieved from System Module! Error: ${result}  console=true


Set Additional Ignored Alarms
    [Documentation]
    ...  Keyword Adds Alarms definied as ADDITIONAL_IGNORED_ALARMS to GLOBALLY_IGNORED_ALARMS
    ...  https://jira3.int.net.nokia.com/browse/TAT-12375, Ignored alarms from Common Test Setup can be set in json
    ...  ADDITIONAL_IGNORED_ALARMS can be defined in job.json test parameters as list of lists
    ...  eg. "ADDITIONAL_IGNORED_ALARMS": [["faultId", "23", "Severity", "Major"],[ "faultId", "4082", "alarmId", "7651"]]

    ${var_exists}  Run Keyword And Return Status
    ...  Variable Should Exist  ${ADDITIONAL_IGNORED_ALARMS}
    Return From Keyword If  not ${var_exists}
    Log  Setting Additional Ignored Alarms:${ADDITIONAL_IGNORED_ALARMS}  console=true
    ${additional_ignored_alarms}  Evaluate  ${ADDITIONAL_IGNORED_ALARMS}
    FOR  ${alarm}  IN  @{additional_ignored_alarms}
        ${ignored_alarm}  Create Dictionary
        Set To Dictionary  ${ignored_alarm}  @{alarm}
        Append To List  ${GLOBALLY_IGNORED_ALARMS}  ${ignored_alarm}
    END


Check SMOD2 In Admin
    [Documentation]
    ...  Ensure that SMOD2 exists in Admin and set ${SMOD2_EXISTS} variable to True
    ...
    ...  | **Full description:**
    ...  | Keyword ensures existence SMOD2 in Admin and sets True in ${SMOD2_EXISTS} variable.
    ...  | In case SMOD2 does not exists and 'block_test_on_fiasco' variable equals True, TC verdict is set to BLOCKED,
    ...  | or FAILED in other cases
    ...  +-----------------------+------+------------------------------------------------------------------+
    ...  | Parameter name        | Man. | Description                                                      |
    ...  +=======================+======+==================================================================+
    ...  | block_test_on_fiasco  | yes  | If True, test verdict set to BLOCKED, FAILED in other cases      |
    ...  +-----------------------+------+------------------------------------------------------------------+
    [Arguments]  ${block_test_on_fiasco}=${TRUE}

    ${im_status}  ${im_sync_objects_tmp}  Run Keyword And Ignore Error
    ...  Query Infomodel  get list //IM_SYNC_L-1
    ${im_sync_objects}  Run Keyword If  '${im_status}'=='PASS'
    ...  Set Variable  ${im_sync_objects_tmp}
    ...  ELSE
    ...  Query Infomodel  get list /MRBTS-1/EQM-1/SMOD-*/IM_SYNC-1

    ${connection_state}  Infomodel Get Object Connection Status  ${im_sync_objects}[0][dist_name]

    ${smod2_detected}  Run Keyword And Return Status
    ...  Run Keyword If  '${connection_state}'=='Connected'
    ...  Ensure That SMOD2 Is Detected Inside ADMIN
    ...  ELSE
    ...  Run Keywords
    ...  Synchronize SMODs TAF
    ...  AND
    ...  Ensure That SMOD2 Is Detected Inside ADMIN
    Run Keyword If  ${smod2_detected}
    ...  Run Keywords
    ...  Log  Two SMODs were detected  console=true
    ...  AND
    ...  Set Test Variable  ${SMOD2_EXISTS}  ${TRUE}
    ...  ELSE IF  ${block_test_on_fiasco}
    ...  Set Test Blocked  Extension System Module not detected despite declared in config file.
    ...  ELSE
    ...  Fail  Extension System Module not detected despite being declared in config file.


Remote Test Line Setup
    [Documentation]
    ...  Setup verification for remote test line
    ...  | **Full description:**
    ...
    ...  | **Input Parameters:**
    ...
    ...  +------------------+------+------------------------+
    ...  | Parameter name   | Man. | Description            |
    ...  +==================+======+========================+
    ...  | alias            | no   | ute alias              |
    ...  +------------------+------+------------------------+
    ...  | remote_host      | no   | IP to remote_host      |
    ...  +------------------+------+------------------------+
    [Arguments]
    ...  ${remote_host}
    ...  ${udp_ip1}=192.168.255.126
    ...  ${remote_host2}=${EMPTY}
    ...  ${udp_ip2}=192.168.255.126
    ...  ${alias}=remote
    ...  ${modules_check}=${TRUE}
    ...  ${cells_check}=${TRUE}
    ...  ${alarms_check}=${TRUE}

    Log  Remote Test Line Setup (alias: ${alias})  console=true
    Set Test Variable  ${${alias}_VERIFICATION_STATUS}  failed
    Set Test Variable  ${${alias}_ADMIN_STARTED}  ${False}
    Set Test Variable  ${${alias}_INFOMODEL_STARTED}  ${False}
    Set Test Variable  ${${alias}_SYSLOG_STARTED}  ${False}
    Set Test Variable  ${${alias}_SMOD2_EXISTS}  ${False}
    Set Test Variable  ${${alias}_SMOD2_SYSLOG_STARTED}  ${False}
    ${modules_working}  Set Variable  ${False}
    ${lte_working}  Set Variable  ${False}
    ${wcdma_working}  Set Variable  ${False}
    ${gsm_working}  Set Variable  ${False}
    ${nr_working}  Set Variable  ${False}
    ${alarms_status}  Set Variable  FAIL

    ${smod2_exists}  Set Variable If  '${remote_host2}'!=''  ${True}  ${False}
    Set Test Variable  ${${alias}_smod2_exists}  ${smod2_exists}

    Start Remote Syslog  remote_host=${remote_host}  udp_ip=${udp_ip1}  alias=${alias}
    Run Keyword If  ${${alias}_smod2_exists}
    ...  Start Remote Syslog  remote_host=${remote_host2}  udp_ip=${udp_ip2}  alias=${alias}_SMOD2
    Start Remote Admin  remote_host=${remote_host}  alias=${alias}

    ${smod_expected_states}  Get Modules Expected States  SMOD  alias=${alias}
    ${rmod_expected_states}  Get Modules Expected States  RMOD  alias=${alias}
    ${sm_state}  Run Keyword If  ${modules_check}
    ...  Verify Modules TAF  SMOD  alias=${alias}  scf_check=${FALSE}  expected_states=${smod_expected_states}
    ...  ELSE
    ...  Set Variable  ${TRUE}
    ${rf_state}  Run Keyword If  ${modules_check}
    ...  Verify Modules TAF  RMOD  alias=${alias}  scf_check=${FALSE}  expected_states=${rmod_expected_states}
    ...  ELSE
    ...  Set Variable  ${TRUE}
    ${modules_working}  Evaluate  ${sm_state} and ${rf_state}
    ${lte_expected_states}  Get Cells Expected States  LTE  alias=${alias}
    ${wcdma_expected_states}  Get Cells Expected States  WCDMA  alias=${alias}
    ${gsm_expected_states}  Get Cells Expected States  GSM  alias=${alias}
    ${nr_expected_states}  Get Cells Expected States  NR  alias=${alias}
    ${lte_working}  Run Keyword If  ${cells_check}
    ...  Verify Cells TAF  LTE  scf_check=${False}  alias=${alias}  expected_states=${lte_expected_states}
    ...  ELSE
    ...  Set Variable  ${TRUE}
    ${wcdma_working}  Run Keyword If  ${cells_check}
    ...  Verify Cells TAF  WCDMA  scf_check=${False}  alias=${alias}  expected_states=${wcdma_expected_states}
    ...  ELSE
    ...  Set Variable  ${TRUE}
    ${gsm_working}  Run Keyword If  ${cells_check}
    ...  Verify Cells TAF  GSM  scf_check=${False}  alias=${alias}  expected_states=${gsm_expected_states}
    ...  ELSE
    ...  Set Variable  ${TRUE}
    ${nr_working}  Run Keyword If  ${cells_check}
    ...  Verify Cells TAF  NR  scf_check=${False}  alias=${alias}  expected_states=${nr_expected_states}
    ...  ELSE
    ...  Set Variable  ${TRUE}
    ${alarms_status}  ${alarms_msg}  Run Keyword If  ${alarms_check}
    ...  Run Keyword And Ignore Error
    ...  Admin Check Active Alarms TAF  alias=${alias}
    ${statuses_dictionary}  Create Dictionary  modules_working=${modules_working}  LTE_working=${lte_working}  WCDMA_working=${wcdma_working}
    ...  GSM_working=${gsm_working}  NR_working=${nr_working}  alarms_status=${alarms_status}
    ${pretty_statuses}  Evaluate  pprint.pformat(${statuses_dictionary}, indent=4)  modules=pprint
    Run Keyword If  '${alarms_status}'=='FAIL'
    ...  Log  Critical fail while checking alarms: ${alarms_msg}  console=true
    ...  ELSE IF  ${alarms_msg}
    ...  Set Test Restriction  Unexpected alarms are present on remote BTS (alias: ${alias}): ${alarms_msg}

    Start Remote Infomodel  remote_host=${remote_host}  bts_host=${OAM_BTS_IP}  alias=${alias}

    ${sbts_is_enabled}  Catenate  ${modules_working} and ${lte_working} and ${wcdma_working} and ${gsm_working}
    ...  and ${nr_working} and '${alarms_status}'!='FAIL'

    [Teardown]  Run Keyword If  ${sbts_is_enabled}
    ...  Set Test Variable  ${${alias}_VERIFICATION_STATUS}  passed
    ...  ELSE
    ...  Set Test Blocked  Test blocked due to failure of ${alias} initial check:\n${pretty_statuses}.\nSkip to teardown!


Start Remote Admin
    [Documentation]  This keyword is used to start remote admin.
    [Arguments]  ${remote_host}  ${alias}

    ${remote_admin_started}  Run Keyword And Return Status
    ...  Setup Admin  admin_api_log_dir=${BTS_FILES}
    ...  remote_host=${remote_host}
    ...  bts_host=${OAM_BTS_IP}
    ...  bts_port=443
    ...  use_ssl=TRUE
    ...  update_interval=1000
    ...  alias=${alias}
    Set Test Variable  ${${alias}_ADMIN_STARTED}  ${remote_admin_started}


Start Remote Infomodel
    [Documentation]  This keyword is used to start remote Infomodel.
    [Arguments]  ${remote_host}  ${bts_host}  ${alias}

    Setup Infomodel  alias=${alias}  remote_host=${remote_host}  address=${bts_host}  port=443  use_ssl=True  admin_api_log_dir=${BTS_FILES}/
    ${remote_infomodel_started}  Run Keyword And Return Status
    ...  Connect Infomodel  alias=${alias}
    Set Test Variable  ${${alias}_INFOMODEL_STARTED}  ${remote_infomodel_started}


Remote Test Line Teardown
    [Documentation]  This keyword is used to remote testline teardown.
    [Arguments]  ${alias}  ${verify_states_stability}=${False}

    Log  Remote Test Line Teardown (alias: ${alias})  console=true
    ${ims_path}  Set Variable  ${BTS_FILES}/IM/${alias}.ims2
    Run Keyword If  ${${alias}_INFOMODEL_STARTED}
    ...  Save Infomodel Log  filename=${ims_path}  timeout=300  alias=${alias}
    Run Keyword If  ${${alias}_INFOMODEL_STARTED} and ${verify_states_stability} and '${${alias}_VERIFICATION_STATUS}'=='passed'
    ...  Verify Remote BTS States After Test Case  ims_path=${ims_path}  alias=${alias}
    Run Keyword If  ${${alias}_INFOMODEL_STARTED}
    ...  Teardown Infomodel  alias=${alias}
    Run Keyword If  ${${alias}_SMOD2_SYSLOG_STARTED}
    ...  Collect Syslog From ${alias}_SMOD2
    Run Keyword If  ${${alias}_SYSLOG_STARTED}
    ...  Collect Syslog From ${alias}


Verify Remote BTS States After Test Case
    [Documentation]  This keyword is used to verify remote BTS states after test case.
    [Arguments]  ${ims_path}  ${alias}

    Log  Verify remote BTS states after test case (alias: ${alias})  console=true

    ${alarms_status}  ${alarms_msg}  Run Keyword And Ignore Error
    ...  Admin Check Active Alarms TAF  alias=${alias}
    Run Keyword If  '${alarms_status}'=='FAIL'
    ...  Set Test Failed  Critical fail while checking alarms: ${alarms_msg}  console=true
    ...  ELSE IF  ${alarms_msg}
    ...  Set Test Restriction  Unexpected alarms are present on remote BTS (alias: ${alias}): ${alarms_msg}

    ${remote_smods}  Get Ids For All  SMOD  alias=${alias}
    ${remote_rmods}  Get Ids For All  RMOD  alias=${alias}
    ${remote_cells_l}  Get Ids For All  LNCEL  alias=${alias}
    ${remote_cells_w}  Get Ids For All  WNCEL  alias=${alias}
    ${remote_cells_g}  Get Ids For All  GNCEL  alias=${alias}

    Initialize Ims2 Validator  ${ims_path}  alias=${alias}
    FOR  ${smod}  IN  @{remote_smods}
        Log  ${smod}
        Fail If Ims2 Object Change  ${smod}  administrativeState  ${UNLOCKED}
        Fail If Ims2 Object Change  ${smod}  operationalState  ${ENABLED}
    END
    FOR  ${rmod}  IN  @{remote_rmods}
        Log  ${rmod}
        Fail If Ims2 Object Change  ${rmod}  administrativeState  ${UNLOCKED}
        Fail If Ims2 Object Change  ${rmod}  operationalState  ${ENABLED}
        Fail If Ims2 Object Change  ${rmod}  blockingState  ${UNBLOCKED}  # Should be removed ?
    END
    FOR  ${cell}  IN  @{remote_cells_l}
        Log  ${cell}
        Fail If Ims2 Object Change  ${cell}  administrativeState  ${UNLOCKED}
        Fail If Ims2 Object Change  ${cell}  operationalState  ${ENABLED}
        Fail If Ims2 Object Change  ${cell}  blockingState  ${UNBLOCKED}
    END
    FOR  ${cell}  IN  @{remote_cells_w}
        Fail If Ims2 Object Change  ${cell}  operationalState  ${ENABLED}
        Fail If Ims2 Object Change  ${cell}  blockingState  ${UNBLOCKED}
        Fail If Ims2 Object Change  ${cell}  usageState  ${ACTIVE}
    END
    FOR  ${cell}  IN  @{remote_cells_g}
        Fail If Ims2 Object Change  ${cell}  administrativeState  ${UNLOCKED}
        Fail If Ims2 Object Change  ${cell}  operationalState  ${ENABLED}
        Fail If Ims2 Object Change  ${cell}  blockingState  ${UNBLOCKED}
        Fail If Ims2 Object Change  ${cell}  usageState  ${ACTIVE}
    END
    Fail If Ims2 Event Occur  event=reset  alias=${alias}
    Fail If Ims2 Event Occur  event=create /MRBTS-*/RAT-*/FRI-*/ALARM-* [alarmSeverity=Critical]  alias=${alias}


Verify Configuration And Set Up Remote Test Line
    [Documentation]
    ...  Helper for KW Remote Test Line Setup which checks if selected test line is well configured
    ...  (exists in given dictionary and has the key "PC_IP1") and if it is, it starts setup
    [Arguments]  ${modules_check}  ${cells_check}  ${alarms_check}  ${alias}

    ${smod_1_configured}  ${pc_ip1}  Run Keyword And Ignore Error
    ...  Get From Dictionary  ${REMOTE_TESTLINES['${alias}']}  PC_IP1
    Run Keyword If  '${smod_1_configured}'!='PASS'
    ...  Run Keywords
    ...  Log  There is no PC_IP1 defined for ${alias} in REMOTE TESTLINES dict  console=true
    ...  AND
    ...  Return From Keyword

    ${udp_ip1_configured}  ${udp_ip1}  Run Keyword And Ignore Error
    ...  Get From Dictionary  ${REMOTE_TESTLINES['${alias}']}  UDP_IP1
    ${udp_ip1}  Set Variable If  '${udp_ip1_configured}'=='PASS'  ${udp_ip1}  192.168.255.126

    ${smod_2_configured}  ${pc_ip2}  Run Keyword And Ignore Error
    ...  Get From Dictionary  ${REMOTE_TESTLINES['${alias}']}  PC_IP2
    ${pc_ip2}  Set Variable If  '${smod_2_configured}'=='PASS'  ${pc_ip2}  ${EMPTY}

    ${udp_ip2_configured}  ${udp_ip2}  Run Keyword And Ignore Error
    ...  Get From Dictionary  ${REMOTE_TESTLINES['${alias}']}  UDP_IP2
    ${udp_ip2}  Set Variable If  '${udp_ip2_configured}'=='PASS'  ${udp_ip2}  192.168.255.126

    Remote Test Line Setup  modules_check=${modules_check}  cells_check=${cells_check}  alarms_check=${alarms_check}  remote_host=${pc_ip1}
    ...  udp_ip1=${udp_ip1}  remote_host2=${pc_ip2}  udp_ip2=${udp_ip2}  alias=${alias}


Collect Snapshot From Remote Test Lines
    [Documentation]  This keyword is used to collect Snapshot From Remote Test Lines.

    FOR  ${remote_line_alias}  IN  @{REMOTE_TESTLINES_LIST}
        Verify Configuration And Get Snapshot From Remote Test Line  ${remote_line_alias}
    END


Verify Configuration And Get Snapshot From Remote Test Line
    [Documentation]
    ...  Helper for KW Remote Testline Snapshot which checks if selected test line is well configured
    ...  (exists in given dictionary and has the key "PC_IP1") and if it is, it starts this KW
    [Arguments]  ${alias}

    ${smod_1_configured}  ${pc_ip1}  Run Keyword And Ignore Error
    ...  Get From Dictionary  ${REMOTE_TESTLINES['${alias}']}  PC_IP1
    Run Keyword If  '${smod_1_configured}'!='PASS'
    ...  Return From Keyword
    Admin Get Snapshot Remotely Via Admin API  bts_host=${OAM_BTS_IP}  remote_host=${pc_ip1}  snapshot_timeout=${ADMIN_SNAPSHOT_TIMEOUT_ESM}
    ...  alias=${alias}
    ${smod_2_configured}  ${pc_ip2}  Run Keyword And Ignore Error
    ...  Get From Dictionary  ${REMOTE_TESTLINES['${alias}']}  PC_IP2
    Run Keyword If  '${smod_2_configured}'!='PASS'
    ...  Return From Keyword
    Admin Get Snapshot Remotely Via Admin API  bts_host=${OAM_SC_IP}  remote_host=${pc_ip2}  snapshot_timeout=${ADMIN_SNAPSHOT_TIMEOUT_ESM}
    ...  alias=${alias}_SMOD2


Get Cells Expected States
    [Documentation]
    ...  Get cells expected states in particular technology for remote host
    ...  | **Full description:**
    ...  | Keyword added for DSC and carrier aggregation feature. In case if remote host
    ...  | (one or more) has different expected state than tested one, there is a need to
    ...  | declare new variables. According to alias for remote host ('DSC' for DSC feature)
    ...  | variables in .json file should look like:
    ...  | {{{ "test": "LOGS_Snapshot",
    ...  |     "timeout": 14400,
    ...  |     "runs": 1,
    ...  |     "DSC": true,
    ...  |     "filename": "/home/ute/btsauto/hran_ta/testsuite/SBTS/LOGS/LOGS_Snapshot.robot",
    ...  |     "parameters":{ "cells_LTE_expected_states": "administrativeState = Unlocked, operationalState = Enabled,
    ...                                             availabilityStatus = Degraded, blockingState = Unblocked",
    ...  |                    "cells_NR_expected_states":  "administrativeState=Unlocked, operationalState=Enabled,
    ...                                             availabilityStatus=Online, blockingState=Unblocked",
    ...  |                    "cells_WCDMA_expected_states": "operationalState = Enabled, availabilityStatus = Degraded,
    ...                                               blockingState = Unblocked, usageState = Active",
    ...  |                    "cells_GSM_expected_states": "administrativeState=Unlocked, operationalState=Enabled,
    ...                                             availabilityStatus=Degraded, blockingState=Unblocked, usageState=Active",
    ...  |                    "DSC_cells_LTE_expected_states": "administrativeState = Unlocked, operationalState = Enabled,
    ...                                                 availabilityStatus = Online, blockingState = Unblocked",
    ...  |                    "DSC_cells_WCDMA_expected_states": "operationalState = Enabled, availabilityStatus = Online,
    ...                                                   blockingState = Unblocked, usageState = Active",
    ...  |                    "DSC_cells_GSM_expected_states": "administrativeState=Unlocked, operationalState=Enabled,
    ...                                                 availabilityStatus=Online, blockingState=Unblocked, usageState=Active"
    ...  |  }}}
    ...
    ...  | **Input Parameters:**
    ...
    ...  +------------------+------+-------------------------------------+
    ...  | Parameter name   | Man. | Description                         |
    ...  +==================+======+=====================================+
    ...  | technology       | yes  | Cells technology to be checked      |
    ...  +------------------+------+-------------------------------------+
    ...  | alias            | no   | remote host alias, default DSC      |
    ...  +------------------+------+-------------------------------------+
    ...
    [Arguments]  ${technology}  ${alias}=DSC

    ${variable_exist}  Run Keyword And Return Status
    ...  Variable Should Exist  ${${alias}CELLS_${technology}_EXPECTED_STATES}
    Run Keyword If  ${variable_exist}
    ...  Return From Keyword  ${${alias}CELLS_${technology}_EXPECTED_STATES}
    ...  ELSE
    ...  Return From Keyword  ${CELLS_${technology}_EXPECTED_STATES}


Get Modules Expected States
    [Documentation]
    ...  Get modules expected states for remote host
    ...  | **Full description:**
    ...  | Keyword added for DSC and carrier aggregation feature. In case if remote host
    ...  | (one or more) has different expected state than tested one, there is a need to
    ...  | declare new variables. According to alias for remote host ('DSC' for DSC feature)
    ...  | variables in .json file should look like:
    ...  | {{{ "test": "LOGS_Snapshot",
    ...  |     "timeout": 14400,
    ...  |     "runs": 1,
    ...  |     "DSC": true,
    ...  |     "filename": "/home/ute/btsauto/hran_ta/testsuite/SBTS/LOGS/LOGS_Snapshot.robot",
    ...  |     "parameters":{ "cells_LTE_expected_states": "administrativeState = Unlocked, operationalState = Enabled,
    ...                                             availabilityStatus = Degraded, blockingState = Unblocked",
    ...  |                    "cells_NR_expected_states":  "administrativeState=Unlocked, operationalState=Enabled,
    ...                                             availabilityStatus=Online, blockingState=Unblocked",
    ...  |                    "cells_WCDMA_expected_states": "operationalState = Enabled, availabilityStatus = Degraded,
    ...                                               blockingState = Unblocked, usageState = Active",
    ...  |                    "cells_GSM_expected_states": "administrativeState=Unlocked, operationalState=Enabled,
    ...                                             availabilityStatus=Degraded, blockingState=Unblocked, usageState=Active",
    ...  |                    "DSC_SMOD_expected_states": "administrativeState=Unlocked, operationalState=Enabled,
    ...                                            availabilityStatus=Online, blockingState=Unblocked, usageState=Active"
    ...  |  }}}
    ...
    ...  | **Input Parameters:**
    ...
    ...  +------------------+------+-------------------------------------+
    ...  | Parameter name   | Man. | Description                         |
    ...  +==================+======+=====================================+
    ...  | class_name       | yes  | BTS module class name SMOD or RMOD  |
    ...  +------------------+------+-------------------------------------+
    ...  | alias            | no   | remote host alias, default DSC      |
    ...  +------------------+------+-------------------------------------+
    ...
    [Arguments]  ${class_name}  ${alias}=DSC

    ${variable_exist}  Run Keyword And Return Status
    ...  Variable Should Exist  ${${alias}_${class_name}_EXPECTED_STATES}
    Run Keyword If  ${variable_exist}
    ...  Return From Keyword  ${${alias}_${class_name}_EXPECTED_STATES}
    ...  ELSE
    ...  Return From Keyword  ${${class_name}_EXPECTED_STATES}


Verify Cells TAF
    [Documentation]
    ...  Verify cells states
    ...  Expected states in default are setted from variables section in hran_frame_sbts
    ...  If scf_check==True, cells count will be verified with scf
    ...
    ...  | Parameter       | Mandatory | Description                                                                            |
    ...  | technology      | Yes       | Cell ID for which states should be checked [SMOD, RMOD]                              |
    ...  | expected_states | No        | Expected states as string ex. "administrativeState=Unlocked, operationalState=Enabled" |
    ...
    ...  Return
    ...  False if at least one cell has state other than expected, or cells count in scf is not equal runtime cells
    ...
    [Arguments]  ${technology}  ${expected_states}=${cells_${technology}_expected_states}  ${alias}=default  ${scf_check}=${TRUE}

    ${technology_sign}  Run Keyword If  '${technology}'=='NR'
    ...  Set Variable  NR
    ...  ELSE
    ...  Set Variable  ${technology[0]}N
    ${check_status}  ${runtime_cells}  ${all_cells}  Get Objects With Expected States TAF  ${expected_states}  ${technology_sign}CEL  alias=${alias}

    Run Keyword If  '${check_status}'=='FAIL'
    ...  Run Keywords
    ...  Log  At least one ${technology} cell has state other than expected.  console=true
    ...  AND
    ...  Return From Keyword  ${FALSE}

    ${count_status}  Run Keyword If  ${scf_check}
    ...  Check SCF Count  ${technology}  ${all_cells}
    ...  ELSE
    ...  Set Variable  ${TRUE}

    Run Keyword If  ${count_status}
    ...  Log  All ${technology} cells are in expected state.  console=true
    ...  ELSE
    ...  Log  All ${technology} cells are in expected state but the number of cells defined in SCF differs from reported by Admin API.  console=true

    [Return]  ${count_status}


Get Objects With Expected States TAF
    [Documentation]
    ...  Get objects from ADMIN and ensure their states
    ...  | **Full description**
    ...  | All objects from given class (BTS, SMOD, BBU, RMOD, ALD, LNCEL, GNCEL or WNCEL) are fetched from BTS via
    ...  | ADMIN interface and their runtime states are compared to states passed in ${expected_states} variable.
    ...  | KW returns three variables - ${status} of whole KW (PASS, FAIL), ${matching_objects} - list of objects which
    ...  | matches expected states and ${class_ids} - a list of all dist names for given class fetched via ADMIN
    ...
    ...  **Input parameters**
    ...
    ...  +-----------------+------+--------------------------------------------------------------------------------------------------------+
    ...  | Parameter name  | Man. | Description                                                                                            |
    ...  +=================+======+========================================================================================================+
    ...  | expected states | yes  | Comma separated states with their valies (i.e administrativeState=Unlocked, operationalState=Enabled)  |
    ...  +-----------------+------+--------------------------------------------------------------------------------------------------------+
    ...  | class_name      | yes  | ADMIN object class name (BTS, SMOD, BBU, RMOD, ALD, LNCEL, GNCEL or WNCEL)                             |
    ...  +-----------------+------+--------------------------------------------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...   ${check_status}  ${RUNTIME_MODS}  ${ALL_MODS}  Get objects with expected states  operationalState=Enabled, availabilityStatus=Online  ALD
    [Arguments]  ${expected_states}  ${class_name}  ${alias}=default

    ${class_ids}  Get Ids For All  ${class_name}  alias=${alias}
    ${matching_objects}  Create List
    ${matching_statuses}  Create List
    FOR  ${item_id}  IN  @{class_ids}
        ${status}  ${item_parameters}  Run Keyword And Ignore Error
        ...  Check Object Expected States  ${class_name}  ${item_id}  ${expected_states}  timeout=20  alias=${alias}
        Run Keyword If  '${status}'=='PASS'
        ...  Run Keywords
        ...  Append To List  ${matching_objects}  ${item_parameters}
        ...  AND
        ...  Append To List  ${matching_statuses}  PASS
        ${iot_cell}  Run Keyword And Return Status
        ...  Should Match Regexp  ${item_id}  .*BTS_CONF.*SCF.*LNCEL
        Run Keyword If  "${status}"=="FAIL" and ${iot_cell}
        ...  Append To List  ${matching_statuses}  PASS
        ${status}  ${item_parameters}  Run Keyword If  "${status}"=="FAIL" and not ${iot_cell}
        ...  Run Keyword And Ignore Error
        ...  Assert  ${class_name}  ${item_id}  availabilityStatus=${NOT_INSTALLED}  timeout=20
        ...  ELSE
        ...  Create List  PASS  NONE
        Run Keyword If  "${status}"=="FAIL" and not ${iot_cell}
        ...  Append To List  ${matching_statuses}  FAIL
    END
    ${status}  Evaluate  "FAIL" if len(${class_ids})!=0 and "FAIL" in "${matching_statuses}" else "PASS"

    [Return]  ${status}  ${matching_objects}  ${class_ids}


Check Object Expected States
    [Documentation]  This keyword is used to check object expected states.
    [Arguments]  ${class_name}  ${item_id}  ${expected_states}  ${timeout}=20  ${alias}=default

    ${expected_states}  Split String  ${expected_states}  ,${SPACE}
    ${parameters}  Get Parameters For  ${class_name}  ${item_id}  timeout=${timeout}  alias=${alias}
    FOR  ${state}  IN  @{expected_states}
        ${state_name}  ${state_value}  Split String  ${state}  =
        ${no_state_in_parameters}  Run Keyword And Return Status
        ...  Dictionary Should Not Contain Key  ${parameters}  ${state_name}
        ${is_online}  Run Keyword And Return Status
        ...  Should Contain  ${state_value}  nline
        Continue For Loop If  ${no_state_in_parameters} and '${state_name}'=='availabilityStatus' and ${is_online}
        IF  ${no_state_in_parameters}
        ...  Fail  'Parameter "${state_name}" not present. Please check parameter name.'
        ${assert_status}  ${assert_output}  Run Keyword And Ignore Error
        ...  Assert  ${class_name}  ${item_id}  ${state}  timeout=${timeout}  alias=${alias}
        IF  '${assert_status}'=='FAIL'
            IF  '${state_name}'=='operationalState'
                ${energy_saving_state}  Set Variable  ${parameters}[energySavingState]
                IF  '${energy_saving_state}'=='energySaving' or '${energy_saving_state}'=='reducedEnergySaving'
                    Log  OperationalState is disabled due to energy saving state. Cell is OK\n  console=true
                ELSE
                    Fail  Energy Saving state is not the reason for operationalState not being as expected
                END
            ELSE
                Fail  ${assert_output}
            END
        END
    END

    [Return]  ${parameters}


Verify Modules TAF
    [Documentation]
    ...  Verify modules states
    ...  Default expected states are defined in the Variables section in hran_frame_sbts.
    ...  If `scf_check` is set to True, the number of modules will be compared with the number of respective objects in SCF.
    ...
    ...  | Parameter       | Mandatory | Description                                                                            |
    ...  | class_name       | Yes       | Class name for which states should be checked [SMOD, RMOD]                              |
    ...  | expected_states | No        | Expected states as string, e.g., "administrativeState=Unlocked, operationalState=Enabled" |
    [Arguments]  ${class_name}  ${expected_states}=${${class_name}_expected_states}  ${alias}=default  ${scf_check}=${TRUE}

    ${check_status}  ${runtime_mods}  ${all_mods}  Get Objects With Expected States TAF  ${expected_states}  ${class_name}  alias=${alias}

    Run Keyword If  '${check_status}'=='FAIL'
    ...  Run Keywords
    ...  Log  At least one ${class_name} module has state other than expected.  console=true
    ...  AND
    ...  Return From Keyword  ${FALSE}

    ${count_status}  Run Keyword If  ${scf_check}
    ...  Check SCF Count  ${class_name}  ${runtime_mods}
    ...  ELSE
    ...  Set Variable  ${TRUE}

    Run Keyword If  ${count_status}
    ...  Log  All states of ${class_name} modules are as expected.  console=true
    ...  ELSE
    ...  Log  At least one ${class_name} module has state other than expected.  console=true

    [Return]  ${count_status}


Assert Parameters For Any
    [Documentation]  This keyword is used to assert parameters for any.
    [Arguments]  ${class_name}  ${expected_states}  ${alias}=default

    Should Not Be Empty  ${expected_states}
    ${item_ids}  Get Ids For All  ${class_name}
    FOR  ${item_id}  IN  @{item_ids}
        ${check_status}  Run Keyword And Return Status
        ...  Check Object Expected States  ${class_name}  ${item_id}  ${expected_states}  alias=${alias}
        Return From Keyword If  ${check_status}
    END
    Fail  No one item has expected states!


Assert Parameters For Every
    [Documentation]  This keyword is used to assert parameters for every.
    [Arguments]  ${class_name}  ${expected_states}  ${alias}=default

    Should Not Be Empty  ${expected_states}
    ${item_ids}  Get Ids For All  ${class_name}
    FOR  ${item_id}  IN  @{item_ids}
        ${check_status}  Run Keyword And Return Status
        ...  Check Object Expected States  ${class_name}  ${item_id}  ${expected_states}  alias=${alias}
        Run Keyword If  not ${check_status}
        ...  Fail  At least one item has states other than expected!
    END


Assert Parameters For No
    [Documentation]  This keyword is used to assert parameters for no.
    [Arguments]  ${class_name}  ${expected_states}  ${alias}=default

    Should Not Be Empty  ${expected_states}
    ${item_ids}  Get Ids For All  ${class_name}
    FOR  ${item_id}  IN  @{item_ids}
        ${check_status}  Run Keyword And Return Status
        ...  Check Object Expected States  ${class_name}  ${item_id}  ${expected_states}  alias=${alias}
        Run Keyword If  ${check_status}
        ...  Fail  At least one item has expected states!
    END


Scout Request SCF
    [Documentation]  This keyword is used to scout request SCF.

    Log  Starting request SCF from Scout.  console=true
    ${tl_name}  Fetch From Right  ${CONFIGURATION}  .
    ${sbts_id}  Get Substring  ${tl_name}  -3
    ${scout_name_exists}  Run Keyword And Return Status
    ...  Variable Should Exist  ${SCOUT_TL_NAME}
    Run Keyword If  ${scout_name_exists}
    ...  Setup Scout  ${SCOUT_TL_NAME}
    ...  ELSE
    ...  Setup Scout  MRBTS-10${sbts_id}
    Request SCF  use_scout_internal_id=False
    Teardown Scout API


Set Test Verdic Variables
    [Documentation]  This KW is used in Common Test Setup to create test variables
    ...  Variables will be used in setting the test verdict.

    @{warnings}  Create List  # List of warnings from Set Test Restriction KW
    @{errors}  Create List  # List of errors from Set Test Failed KW
    ${test_verdict}  Create List
    @{pass_type}  Create List  passed  passed_with_restriction
    Set Test Variable  ${WARNINGS}
    Set Test Variable  ${ERRORS}
    Set Test Variable  ${TEST_VERDICT}
    Set Test Variable  ${PASS_TYPE}


Set Test Blocked
    [Documentation]  This keyword is used to set test blocked.
    [Arguments]  ${message}=${EMPTY}

    Log  Test ${TEST_NAME} blocked. ${message}  ERROR  HTML
    Fail  ${message}


Align Verdicts
    [Documentation]  This keyword is used to align verdicts.

    ${test_verdict}  Get Test Verdict
    ${verdict}  Run Keyword And Return Status
    ...  Should Contain  ${PASS_TYPE}  ${test_verdict}  ignore_case=${True}
    ${errors_status}  Run Keyword And Return Status
    ...  Should Be Empty  ${ERRORS}
    FOR  ${index}  ${error}  IN ENUMERATE  @{ERRORS}
        Run Keyword If  '''${error}'''=='''${EMPTY}'''
        ...  Run Keywords
        ...  Remove From List  ${ERRORS}  ${index}
        ...  AND
        ...  Insert Into List  ${ERRORS}  ${index}  Error could not be detected.
    END
    ${fail_message}  Catenate  SEPARATOR=${\n}***${SPACE}  Fail cause:  ${TEST_MESSAGE}  @{ERRORS}
    Run Keyword If  ${verdict}==False or ${errors_status}==False
    ...  Fail  ${fail_message}


Get Test Verdict
    [Documentation]  This keyword is used to Get Test Verdict.

    ${verdict}  Set Variable If  '${TEST_STATUS}'=='FAIL'  failed  ${TEST_VERDICT}

    [Return]  ${verdict}


Set Preconditions Passed
    [Documentation]  This keyword is used to set Preconditions Passed.

    Set Test Variable  ${TEST_VERDICT}  passed


Set Test Norun
    [Documentation]  This keyword is used to set test norun.
    [Arguments]  ${message}=${EMPTY}  ${fail_fast}=${True}

    Set Test Variable  ${TEST_VERDICT}  norun
    Run Keyword If  ${fail_fast}
    ...  Set Test Failed  message=${message}  fail_fast=${fail_fast}


Set Test Failed
    [Documentation]  This keyword is used to set test failed.
    [Arguments]  ${message}=${EMPTY}  ${fail_fast}=${False}

    Append To List  ${ERRORS}  ${message}
    Set Test Variable  ${TEST_VERDICT}  failed
    Run Keyword If  ${fail_fast}
    ...  Fail  ${message}
    ...  ELSE
    ...  Log  Test ${TEST_NAME} failed.  ERROR  HTML


Set Test Restriction
    [Documentation]  This keyword is used to set test restriction.
    [Arguments]  ${message}=${EMPTY}

    Set Test Variable  ${TEST_VERDICT}  passed_with_restriction
    Append To List  ${WARNINGS}  ${message}
    Log  ${message}  WARN  HTML


Log Verdict Messages
    [Documentation]  This keyword is used to log verdict messages.
    Log Many  @{WARNINGS}
    Log Many  @{ERRORS}


Move Logs On Rotta Server DEPRECATED
    [Documentation]  This keyword is used to move logs on rotta server.

    ${ref_config_id_exists}  Run Keyword And Return Status
    ...  Variable Should Exist  ${REFERENCE_CONFIGURATION_ID}
    ${sbts_identifier}  Set Variable If  ${ref_config_id_exists}  ${REFERENCE_CONFIGURATION_ID}  ${TESTLINE_NAME}
    ${current_test_directory_path}  Fetch From Left  ${BTS_FILES}  /BTSFiles
    Run  zip -r '${current_test_directory_path}.zip' '${current_test_directory_path}'

    ${path_to_rotta}  Catenate  SEPARATOR=  /media/rotta/HetRAN_2/mnranpztim/${TIM_DIRECTORY_PATH_ON_ROTTA}/
    ...  ${ENB_BRANCH}/${sbts_identifier}/${ENB_BUILD}
    ${enb_build_directory_exists}  Run Keyword And Return Status
    ...  OperatingSystem.Directory Should Exist  ${path_to_rotta}
    Run Keyword If  not ${enb_build_directory_exists}
    ...  OperatingSystem.Run  sudo mkdir -p ${path_to_rotta}
    Run  sudo mv '${current_test_directory_path}.zip' '${path_to_rotta}'
    Log  ${current_test_directory_path}.zip is saved on rotta server under: ${path_to_rotta}.  console=true
    Run  sudo rm -f '${current_test_directory_path}.zip'


Map Rotta Server
    [Documentation]  DEPRECATED. Maps the KPI CRT share server (kpicrtshare1). Use Map KPI Share1 Server instead.

    Log  THIS KEYWORD "Map Rotta Server" IS DEPRECATED.  level=WARN  console=true
    Log  Mounting "kpicrtshare1"...  console=true
    Map KPI Share1 Server  kpishare_partition=kpicrtshare1


Map Rotta Server DEPRECATED
    [Documentation]  This keyword is used to map rotta server using kerberos login.
    [Arguments]  ${rotta_map_path}=/media/rotta
    Run  sudo mkdir -p ${rotta_map_path}
    Run  sudo echo ${COMMON_PASSWORD} | sudo kinit ${COMMON_USER}
    ${rotta_server_line}  Catenate  sudo mount -t cifs -o username=${COMMON_USER},password=${COMMON_PASSWORD},domain=NSN-INTRA,sec=krb5
    ...  //eseefsn50.emea.nsn-net.net/rotta4internal/  ${rotta_map_path}
    ${mount_output}  Run  ${rotta_server_line}
    IF  'error' in '''${mount_output}'''
      Set Suite Variable  ${MOVE_LOGS_ON_ROTTA}  ${FALSE}
      Log  Unable to mount //eseefsn50.emea.nsn-net.net/rotta4internal/ error: \n${mount_output}  level=ERROR  console=true
      Log  Moving logs to rotta is disabled !  level=WARN  console=true
    ELSE
      Log  Rotta server mounted successfully.  console=true
    END


Map KPI Share1 Server
    [Documentation]  This keyword is used to map KPI Share1 storage server using standard login.
    [Arguments]  ${kpishare_partition}

    ${kpishare1_path}  Set Variable  /media/${kpishare_partition}
    Run  sudo mkdir -p ${kpishare1_path}
    ${kpi_server_line}  Catenate  sudo sh -c "echo //10.5.23.71/${kpishare_partition} ${kpishare1_path}
    ...  cifs _netdev,noperm,nosuid,noexec,'username=${KPISHARE1_USER},password=${KPISHARE1_PASSWORD}' 0 0 >>/etc/fstab"
    Run  ${kpi_server_line}
    ${mount_output}  Run  sudo mount -a
    IF  'error' in '''${mount_output}'''
      Log  Unable to mount //10.5.23.71/${kpishare_partition} - error: \n${mount_output}  level=ERROR  console=true
      RETURN  ${FALSE}
    ELSE
      Log  KPI Share1 storage server mounted successfully at ${kpishare1_path}.  console=true
      RETURN  ${TRUE}
    END


Map BuildShare
    [Documentation]  This keyword is used to map BuildShare.

    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sh_command}  Catenate  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/
    ...  cifs _netdev,noperm,username=userbuild,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sh_command}
    Run  sudo mount -a


Map Shares
    [Documentation]  This keyword maps shares logs1-test, logs1-automation, BuildShareTimi01 and share-1-mnt.
    ...  *AUTHOR*: andreea.burtic@nokia.com

    Log  Mapping shares is performing  console=true
    Run  scp ute@10.5.21.7:/home/ute/tools_utils/vem_rfs_custom/shares_mapping.sh /home/ute/
    OperatingSystem.Wait Until Created  /home/ute/shares_mapping.sh  timeout=30s
    TRY
        Run  sudo /home/ute/shares_mapping.sh
        ${share1_directory_exists}  Run Keyword And Return Status  OperatingSystem.Wait Until Created  /media/share1-mnt/users
        ${logs1_directory_exists}  Run Keyword And Return Status  OperatingSystem.Wait Until Created  /media/logs1-test/VRF_TSR_T01
        ${logs1_automation_exists}  Run Keyword And Return Status  OperatingSystem.Wait Until Created  /media/logs1-automation/TA_Code_Review
        ${buildshare_directory_exists}  Run Keyword And Return Status  OperatingSystem.Wait Until Created  /media/BuildShareTimi01/SBTS
        IF  ${share1_directory_exists} and ${logs1_directory_exists} and ${logs1_automation_exists} and ${buildshare_directory_exists}
            Log  share1-mnt, logs1-test, logs1-automation and BuildShareTimi01 storage server mounted successfully!  console=true
        ELSE
            Fail  Unable to mount shares!
        END
    FINALLY
        Run  rm -f /home/ute/shares_mapping.sh
    END


Check If Alarms Should Be Hidden
    [Documentation]  Keyword to check CNI-127210.
    ...  Checks alarms with alarm id 7115 or 7102 that were detected during test execution and not ignored.
    ...  Alarms must be obtained from from watchdog.Get detected alarms
    [Arguments]  ${detected_alarm_list}
    ${active_sw_version_exists}  Run Keyword And Return Status
    ...  Variable Should Exist  ${ACTIVE_SW_VERSION}
    Run Keyword If  ${active_sw_version_exists}==${FALSE}
    ...  Return from keyword
    Return from keyword if
    ...  '${ACTIVE_SW_VERSION}' < 'SBTS24R3_ENB_0000_000242_000000' or '0425_' in '${ACTIVE_SW_VERSION}'
    FOR  ${alarm}  IN  @{detected_alarm_list}
        Check If Alarm Should Be In Hidden Alarms  ${alarm}
    END


Check If Alarm Should Be In Hidden Alarms
    [Documentation]  Verifies if given alarm is not seen in active alarms. CNI-127210
    [Arguments]  ${alarm}

    ${alarm}  Convert To String  ${alarm}
    ${alarm_id}  Get Regexp Matches  ${alarm}  alarm_id:${SPACE}(7115|7102|61641|61647)
    Return From Keyword If  not ${alarm_id}
    ${severity}  Get Regexp Matches  ${alarm}  severity:${SPACE}(Warning|Minor)
    Return From Keyword If  not ${severity}
    ${severity}  Fetch From Right  ${severity}[0]  ${SPACE}
    ${fault_id}  Get Regexp Matches  ${alarm}  fault_id:${SPACE}\\d*
    ${fault_id}  Fetch From Right  ${fault_id}[0]  ${SPACE}

    ${fail_msg}  Set Variable If  '${fault_id}'=='10'
    ...  Checking Fault Id 10, please be aware that this fault should appear on BBMOD. It should be failed only for RF/FHGW/ALD.
    ...  ${fault_id} is seen with ${severity} level.

    ${status}  ${fault}  Run Keyword And Ignore Error
    ...  Get From Dictionary  ${HIDDEN_ALARMS}  ${fault_id}
    Return From Keyword If  '${status}'=='FAIL'

    ${status}  ${msg}  Run Keyword And Ignore Error
    ...  Run Keyword If  '${fault}[hide_rule]'=='hide minor alarm 7102'
    ...  Should Not Be Equal As Strings  ${severity}  Minor  msg=${fault_id} appeared with Minor level.
    ...  ELSE IF  '${fault}[hide_rule]'=='hide minor 61647 alarm'
    ...  Should Not Be Equal As Strings  ${severity}  Minor  msg=${fault_id} appeared with Minor level.
    ...  ELSE IF  '${fault}[hide_rule]'=='hide minor 61641 alarm'
    ...  Should Not Be Equal As Strings  ${severity}  Minor  msg=${fault_id} appeared with Minor level.
    ...  ELSE IF  '${fault}[hide_rule]'=='hide warning 7115 alarm'
    ...  Should Not Be Equal As Strings  ${severity}  Warning  msg=${fault_id} appeared with Warning level.
    ...  ELSE
    ...  Should Not Contain  Warning Minor  ${severity}  msg=${fail_msg}
    Run Keyword If  'CA-KPI' in ${TEST_TAGS} and '${status}'=='FAIL'
    ...  Log  Alarm check not ok: \n ${msg}  level=ERROR
    ...  ELSE IF  '${status}'=='FAIL'
    ...  Fail  ${msg}


Common Test Setup Simulators
    [Tags]  robot:no-dry-run
    [Documentation]
    ...  Set of actions which will be launched before each SBTS SOAM test.
    ...  List of actions:
    ...  -> Creates log directories
    ...  -> Deletes content of /tmp and /home/ute/btsauto/logs in order to free up space, to ensure Robot test can run
    ...  -> Starts Admin connection
    ...  -> Starts Syslogs collecting
    ...  -> Starts infomodel on LTE site
    ...  -> Gets and displays SW versions
    ...  -> Checks cells and modules state and active alarms
    ...
    ...  | Parameter            | Default         | Description                                                         |
    ...  | admin_launch         | TRUE            | Whether to initialise/or not Admin connection |
    ...  | syslog_launch        | TRUE            | Whether to collect/or not syslog during TC execution |
    ...  | infomodel_launch     | TRUE            | Whether to initialise/or not InfoModel connection |
    ...  | btssm_launch         | TRUE            | Whether to initialise/or not btssm library |
    ...  | bts_host             | ${OAM_BTS_IP} | IP address to connect with BTS |
    ...  | modules_check        | TRUE            | Flag for enabling/disabling modules precheck |
    ...  | cells_check          | TRUE            | Flag for enabling/disabling cells precheck |
    ...  | expected_bts_status  | OnAir           | Expected BTS status|

    [Arguments]
    ...  ${admin_launch}=${TRUE}
    ...  ${syslog_launch}=${COLLECT_SYSLOG_FLAG}
    ...  ${infomodel_launch}=${TRUE}
    #...  ${modules_check}=${TRUE}
    #...  ${cells_check}=${TRUE}
    #...  ${alarms_check}=${TRUE}   #ignored
    #...  ${expected_bts_status}=Configured
    #...  ${scf_check}=${TRUE}    #ignored
    #...  ${expected_alarms}=@{EMPTY}    #ignored
    #...  ${ignored_alarms}=@{EMPTY}    #ignored
    #...  ${critical_alarms}=@{EMPTY}    #ignored
    ...  ${tc_name}=${EMPTY}
    [Timeout]  20 minutes

    Set Test Variable  ${INFOMODEL_STARTED}  ${FALSE}
    Set Test Variable  ${ALL_SYSLOGS_STARTED}  ${FALSE}
    Set Test Variable  ${ADMIN_STARTED}  ${FALSE}
    Set Test Variable  ${BTS_VERIFICATION_STATUS}  norun

    Set Test Verdic Variables
    Set TL Parameters
    There Should Be At Least 2048 MB Of Disk Space Available In /home/ute
    Log  Common Test Setup  level=INFO  console=true
    Create Dirs For Logs

    Setup Alarms
    Run Keyword If  '${tc_name}'!='${EMPTY}'
    ...  Set Tc Specific Alarms  ${tc_name}
    Start Watchdog  ${tc_name}

    Set Test Variable  ${OAM_BTS_IP}  192.168.255.129
    Run Keyword If  ${admin_launch}
    ...  Run Keyword And Continue On Failure
    ...  Start Admin  bts_host=${OAM_BTS_IP}
    Set Variables For System Modules
    ${mplane_ip}  Admin Get MPLANE IP
    Set Test Variable  ${MPLANE_IP}
    Set Test Variable  ${TAF_CONFIG_MODEL}  ${TRUE}

    Run Keyword If  ${infomodel_launch}
    ...  Run Keyword And Continue On Failure
    ...  Start Infomodel

    Run Keyword If  ${syslog_launch}
    ...  Run Keyword And Ignore Error
    ...  Start Simulator Syslog Collection
    Run Keyword If  ${admin_launch}
    ...  Admin Get BTS ID
    Run Keyword If  ${INFOMODEL_STARTED}
    ...  Run Keyword And Continue On Failure
    ...  Print Active And Passive SW Version
#    ${sbts_state}  ${output}  Run Keyword If  ${ADMIN_STARTED}
#    ...  Run Keyword And Ignore Error
#    ...  Check Modules And Cells States  ${expected_bts_status}    #${modules_check}  ${cells_check}
#    ...  ELSE
#    ...  Set Test Variable  ${BTS_VERIFICATION_STATUS}  passed
    Log Variables  level=DEBUG
#    Run Keyword If  "${sbts_state}"=="FAIL"
#    ...  Set Test Blocked  TC is stopped due to sbts state failure and sbts recovery is not performed.

    Set Preconditions Passed
    Log  End of Common Test Setup  level=INFO  console=true


Set TL Parameters
    [Documentation]  Parses the CONFIGURATION suite variable (format: HW_LOCATION_CODE.TESTLINE_NAME)
    ...  and sets the suite variables HW_LOCATION_CODE, TESTLINE_NAME and TEMP_LOGS_DIR.
    ...  Also adds an informational tag with the resolved configuration values.

    @{configuration}  Split String  ${CONFIGURATION}  .
    Set Suite Variable  ${HW_LOCATION_CODE}  ${configuration}[0]
    Set Suite Variable  ${TESTLINE_NAME}  ${configuration}[1]
    Set Suite Variable  ${TEMP_LOGS_DIR}  /home/ute/btsauto/logs
    Log  TC executed with configuration files of ${HW_LOCATION_CODE}\\${TESTLINE_NAME}  level=INFO  console=true
    Set Tags  ${HW_LOCATION_CODE}\\${TESTLINE_NAME}


Set Variables For System Modules
    [Documentation]  Initializes SMOD1 and SMOD2 test variables with connection parameters (IP, USERNAME, PASSWORD, HW_TYPE).
    ...  SMOD1 is always the Active or Single module, SMOD2 is the Standby module (if present).
    ...  Sets SMOD2_EXISTS to True only if a second system module is found.

    ${SMOD1}  Create Dictionary  IP=${OAM_BTS_IP}  PASSWORD=oZPS0POrRieRtu  USERNAME=toor4nsn  TRS_IP=${OAM_BTS_IP}  UDP_IP=192.168.255.126
    Set Test Variable  ${SMOD1}
    Set Test Variable  ${SMOD2_EXISTS}  ${FALSE}
    ${SMOD2}  Create Dictionary
    Set Test Variable  ${SMOD2}
    ${smod_ids}  Get Ids For All  SMOD
    FOR  ${id}  IN  @{smod_ids}
        ${smod_params}  coam.Get Parameters  ${id}
        ${stored_role}  Get Stored Role Starting From SMOD_R  ${id}
        ${product_name}  Fetch From Left  ${smod_params}[productName]  ${SPACE}
        IF  '${stored_role}' in ['Active', 'Single']
          Set To Dictionary  ${SMOD1}  HW_TYPE=${product_name}
        ELSE
          Set To Dictionary  ${SMOD2}
          ...                IP=${OAM_SC_IP}
          ...                PASSWORD=oZPS0POrRieRtu
          ...                USERNAME=toor4nsn
          ...                TRS_IP=${OAM_SC_IP}
          ...                UDP_IP=${UDP_IP}
          ...                HW_TYPE=${product_name}
          Set Test Variable  ${SMOD2_EXISTS}  ${TRUE}
        END
    END


Get Stored Role Starting From SMOD_R
    [Documentation]  Returns the storedRole of the BTS_L object associated with the given SMOD_R distName.
    ...  Navigates from SMOD_R → REF-1 → BTS_L to retrieve the storedRole parameter.
    ...
    ...  Arguments:
    ...  - smod_r_id: distName of the SMOD_R object (e.g. MRBTS-1/ABIA-1/SMOD_R-1)
    ...
    ...  Returns: storedRole string (e.g. Active, Standby, Single)
    [Arguments]  ${smod_r_id}

    ${ref_params}  coam.Get Parameters  ${smod_r_id}/REF-1
    ${bts_l_dn}  Fetch From Left  ${ref_params}[distName]  /EQM_L
    ${bts_l_params}  coam.Get Parameters  ${bts_l_dn}

    [Return]  ${bts_l_params}[storedRole]


Check Modules And Cells States
    [Documentation]  Verifies that the BTS procedural state matches expected_bts_status and asserts that
    ...  all cells (GSM/WCDMA/LTE/NR) and all hardware modules (SMOD, BBMOD, RMOD) are operationalState=ENABLED
    ...  with no availabilityStatus=DEGRADED. Also sets SCF_COUNT_<type> suite variables per cell technology.
    ...
    ...  Arguments:
    ...  - expected_bts_status: Expected BTS procedural state string (e.g. COMMISSIONED)
    [Arguments]  ${expected_bts_status}    #${cells_check}  ${modules_check}

    ${bts_states}  Get Bts Statuses
    Should Be Equal As Strings  ${bts_states}[proceduralState]  ${expected_bts_status}
    ...  BTS procedural state is different than ${expected_bts_status}.
    ${cell_types}  Create Dictionary  GNCEL=GSM  WNCEL=WCDMA  LNCEL=LTE  NRCEL=NR
    FOR  ${cell_type}  IN  @{cell_types}
        ${ids}  Get Ids For All  ${cell_type}
        ${cell_number}  Get Length  ${ids}
        Continue For Loop If  ${cell_number}==0
        Assert Every  ${cell_type}  operationalState=${ENABLED}
        Assert No  ${cell_type}  availabilityStatus=${DEGRADED}
        ${type}  Set Variable  ${cell_types}[${cell_type}]
        Set Test Variable  ${SCF_COUNT_${type}}  ${cell_number}
    END
    Assert Every  SMOD  operationalState=${ENABLED}
    Assert Every  BBMOD  operationalState=${ENABLED}
    Assert Every  RMOD  operationalState=${ENABLED}
    Set Test Variable  ${BTS_VERIFICATION_STATUS}  passed


Common Test Teardown Simulators
    [Tags]  robot:no-dry-run
    [Documentation]
    ...  Set of actions which will be launched after each SBTS SOAM test ends.
    ...  List of actions:
    ...  -> Triggers snapshot depends on selected option and test_verdict
    ...  -> Collects Infomodel files and stops Infomodel session
    ...  -> Collects Syslog files ands stops logging
    ...  -> Collects Admin files and stops Admin session
    ...
    ...  | Parameter        | Default        | Description                                |
    ...  | collect_snapshot | failed_verdict | Flag for enabling/disabling snapshot trace |
    ...
    ...  | Possible collect_snapshot values | Description
    ...  | always                           | Snapshot is collected unless the test verdict is norun |
    ...  | failed_verdict                   | Snapshot is collected if the test verdict is failed or blocked |
    ...  | passed_with_restriction          | Snapshot is collected if the test verdict is failed, blocked or passed_with_restriction |
    ...  | never                            | Snapshot is not collected |
    ...
    [Arguments]  ${collect_snapshot}=${COLLECT_SNAPSHOT_FLAG}

    ${collect_snapshot}  Set Variable If  '${COLLECT_SNAPSHOT_FLAG}' != 'failed_verdict'  ${COLLECT_SNAPSHOT_FLAG}  ${collect_snapshot}
    Log  Common Test Teardown  level=INFO  console=true
#    Run Keyword If  '${BTS_VERIFICATION_STATUS}'=='norun' and ${ADMIN_STARTED}==${TRUE}
#    ...  Set Test Blocked  Initial verification of BTS states was not completed due to timeout, or some unit indicates a faulty state

    ${snapshot_fail_watchdog}  Run Keyword and Return Status  Stop Watchdog
    Log Verdict Messages
    ${test_verdict}  Get Test Verdict
    ${collect_snapshot_condition_1}  Set Variable  '${collect_snapshot}'=='always' and '${test_verdict}'!='norun'
    ${collect_snapshot_condition_2}  Set Variable
    ...  '${collect_snapshot}'=='failed_verdict' and ('${test_verdict}'=='failed' or '${test_verdict}'=='blocked')
    ${collect_snapshot_condition_3}  Catenate
    ...  '${collect_snapshot}'=='passed_with_restriction' and ('${test_verdict}'=='failed' or '${test_verdict}'=='blocked' or
    ...  '${test_verdict}'=='passed_with_restriction')
    Run Keyword If  ${collect_snapshot_condition_1} or ${collect_snapshot_condition_2} or ${collect_snapshot_condition_3} or ${snapshot_fail_watchdog}
    ...  Run Keywords
    ...  Admin Get Snapshot
    ...  AND
    ...  Run Keyword If  ${SMOD2_EXISTS}
    ...  Admin Get Snapshot For ESM
    Teardown Infomodel Connections

    Run Keyword If  ${ADMIN_STARTED}
    ...  Collect Infomodel Log From Current Session  target_file_name=${BTS_FILES}/IM/InfoModel_log.ims2  timeout=300  leave_disconnect_logs=True
    Teardown All Aliases For Admin

    Run Keyword And Ignore Error
    ...  Collect Simulator Syslogs

    Log  End of Common Test Teardown  level=INFO  console=true
    Align Verdicts
    Run Keyword If  'STOPONFAIL' in @{TEST_TAGS} and '${TEST_STATUS}' == 'FAIL'
    ...  Fatal Error  Execution stopped because critical TC '${TEST_NAME}' failed


Start Simulator Syslog Collection
    [Documentation]
    ...  This keyword starts syslog collection on Simulator
    ...  If syslog collection is started on Simulator ${ALL_SYSLOGS_STARTED} is set on ${TRUE}.
    ...  *AUTHOR*: anna.benzar@nokia.com

    Log  Trying to Start Simulator Syslog Collection...  console=True
    Run Keyword And Ignore Error  Teardown aliases and kill syslog processes  before_collection_ssh
    ${output}  OperatingSystem.Run  pyenv global
    ${output}  Get Regexp Matches  ${output}  [0-9]+\.[0-9]+\.[0-9]+
    ${python_version}  Set Variable  ${output}[0]
    ${syslog_started}  Run Keyword And Return Status  Wait Until Keyword Succeeds  2 min  10 sec
    ...  syslog.Start Syslog  log_dir=${UDP_LOGS}
    ...                       log_name=SYSLOG_SIMULATOR_UDP
    ...                       host_ip=192.168.255.126
    ...                       add_line_number=True
    ...                       virtualenv_dir=/home/ute/.pyenv/versions/${python_version}/envs/test_repo
    ...                       alias=SYSLOG_SIMULATOR_UDP
    Run Keyword If  ${syslog_started}
    ...  Run Keywords
    ...  Log  Syslog collection started on Simulator...  console=True
    ...  AND
    ...  Set Test Variable  ${ALL_SYSLOGS_STARTED}  ${syslog_started}
    ...  ELSE
    ...  Set Test Restriction  Simulator syslog collection did not start and will not be collected during TC execution.


Collect Simulator Syslogs
    [Documentation]  This keyword collects syslogs from Simulator.

    Run Keyword If  ${ALL_SYSLOGS_STARTED}
    ...  Run Keywords
    ...  syslog.Collect Syslog Results  destination=${UDP_LOGS}/SYSLOG_SIMULATOR_UDP.tar.gz  unzip=False  alias=SYSLOG_SIMULATOR_UDP
    ...  AND
    ...  Log  Simulator syslogs successfully collected to ${UDP_LOGS} directory.  console=true

    [Teardown]  Run Keyword And Ignore Error  Teardown aliases and kill syslog processes  after_collection_ssh


Copy logs on kpi share1
    [Documentation]  DEPRECATED. Maps kpishare1 if not already mounted and enables suite-level log copying to KPI Share1.
    ...  Sets ENABLE_COPY_LOGS_ON_KPI_SHARE1 and KPI_SHARE1_LOGS_PATH suite variables.
    ...  Use KPI Suite Setup instead.

    Log  Check if KPI SHARE1 is mapped.  level=INFO  console=true
    Log  This method is deprecated. Please use 'KPI Suite Setup'.  level=WARN  console=true

    ${output}  OperatingSystem.Run  df -h
    ${kpishare1_server}  Set Variable If  'kpishare1' in '''${output}'''  ${TRUE}  ${FALSE}
    ${mapping_status}  IF  not ${kpishare1_server}  Map KPI Share1 Server  kpishare_partition=kpishare1
    IF  ${kpishare1_server} or ${mapping_status}
      Set Suite Variable  ${KPI_SHARE1_LOGS_PATH}  /media/kpishare1/${ENB_BRANCH}/${TESTLINE_NAME}/${ENB_BUILD}/
      OperatingSystem.Run  sudo mkdir -p ${KPI_SHARE1_LOGS_PATH}
      Log  Copy logs to KPI SHARE1 enabled.  level=INFO  console=true
      Set Suite Variable  ${ENABLE_COPY_LOGS_ON_KPI_SHARE1}  ${TRUE}
    ELSE
      Set Test Variable  ${ENABLE_COPY_LOGS_ON_KPI_SHARE1}  ${FALSE}
      Log  Cannot create KPI SHARE1 storage location, copy logs is disabled.  console=true  level=WARN
    END


KPI Suite Setup  # All this KW should be moved on KPI resource after drop of ute_infomodel.
    [Documentation]  Suite-level setup for KPI tests. Maps BuildShare and both KPI share servers
    ...  (kpicrtshare1 and kpishare1). Sets ENABLE_COPY_LOGS_ON_KPI_SHARE1 and KPI_SHARE1_LOGS_PATH
    ...  suite variables based on mount success. Logs deprecation warnings for legacy variables.

    Log  KPI Suite Setup started.  console=true

    IF  ${MOVE_LOGS_ON_ROTTA}  Log  Variable 'MOVE_LOGS_ON_ROTTA' is deprecated.  level=WARN  console=true
    IF  '${TIM_DIRECTORY_PATH_ON_ROTTA}'  Log  Variable 'TIM_DIRECTORY_PATH_ON_ROTTA' is deprecated.  level=WARN  console=true
    IF  ${COPY_LOGS_ON_KPI_SHARE1}  Log  Variable 'COPY_LOGS_ON_KPI_SHARE1' is deprecated.  level=WARN  console=true

    Check Netboot variable
    Map BuildShare
    Map KPI Share1 Server  kpishare_partition=kpicrtshare1
    ${kpi_server_mounted}  Map KPI Share1 Server  kpishare_partition=kpishare1
    Set Suite Variable  ${ENABLE_COPY_LOGS_ON_KPI_SHARE1}  ${kpi_server_mounted}
    IF  ${ENABLE_COPY_LOGS_ON_KPI_SHARE1}
        ${testline_name}  Fetch From Right  ${CONFIGURATION}  .
        Set Suite Variable  ${KPI_SHARE1_LOGS_PATH}  /media/kpishare1/${ENB_BRANCH}/${testline_name}/${ENB_BUILD}/
        OperatingSystem.Run  sudo mkdir -p ${KPI_SHARE1_LOGS_PATH}
    ELSE
        Log  Unable to mount KPISHARE1. Logs will not be transfered.  level=ERROR  console=true
    END
    Log  KPI Suite Setup completed.  console=true


Copy Logs To KPISHARE1
    [Documentation]  Copies the test results directory recursively to the KPI Share1 network path.
    ...  Requires KPI_SHARE1_LOGS_PATH and TEST_RESULTS_DIR to be set (e.g. by KPI Suite Setup).
    ...  Logs an error if the copy fails due to a missing path.

    ${result}  OperatingSystem.Run  sudo cp --recursive '${TEST_RESULTS_DIR}' ${KPI_SHARE1_LOGS_PATH}
    IF  'No such file or directory' in '${result}'
        Log  ${result}  level=ERROR  console=true
    ELSE
        Log  Logs saved at: ${KPI_SHARE1_LOGS_PATH}  console=true
    END
