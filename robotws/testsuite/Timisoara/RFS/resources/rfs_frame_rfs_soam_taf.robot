*** Settings ***
Documentation    Keywords for SOAM TAF
# Resources
Resource          rfs_frame_rfs_common.robot

# Variables
Variables         python_resources/parameters_dictionaries.py
Variables         python_resources/hardware_variables.py

# Libraries
Library           ute_admin_infomodel
Library           taf.sbts.oam.coam.admin  WITH NAME  coam
Library           taf.transport.ssh  WITH NAME  ssh
Library           taf.collectors.core  WITH NAME  core
Library           taf.gnb.oam.coam.cu  WITH NAME  cu
Library           taf.gnb.oam.coam.vdu  WITH NAME  vdu
Library           taf.hw.fhgw.cli  WITH NAME  fhgw
Library           taf.transport.bmc  WITH NAME  bmc
Library           taf.nms.netact  WITH NAME  netact
Library           taf.fdsw.rc  WITH NAME  rc
Library           python_resources/SyslogAnalyzer.py

*** Variables ***
# Stop and Fix info
@{STOP_AND_FIX_ALARMS_SBTS}=  10  1806  4341  4352  4383
@{STOP_AND_FIX_ALARMS_VCU}=  10  1806  4383
@{STOP_AND_FIX_ALARMS_VDU}=  10  1806  4383
${STOP_AND_FIX_SLEEP_TIME}=  72h

# UDP ports info
@{UDP ports}=  51000  51001  51003  50011

# Alarms info
&{SIMPLIFIED_ALARM}=  alarmId=${NONE}  faultId=${NONE}  faultName=${NONE}
&{TRANSLATED_ALARM}=  alarmNumber=alarmId  alarmDetail=faultName  alarmSeverity=severity
&{CBTS_CU_SIMPLIFIED_ALARM}=  alarm_id=${NONE}  alarm_name=${NONE}  fault_id=${NONE}  fault_name=${NONE}
&{CBTS_VDU_SIMPLIFIED_ALARM}=  alarm_id=${NONE}  alarm_name=${NONE}  fault_id=${NONE}  fault_name=${NONE}
&{fault_signature_dict}=  category=${NONE}
&{SBTS_HISTORICAL_SIMPLIFIED_ALARM}=  alarmId=${NONE}  faultId=${NONE}  faultName=${NONE}
...  faultSignature=${fault_signature_dict}
@{KEYS_FOR_REMOVE_DUPLICATE_ALARM_REAL_TIME}=  alarmId  alarmingObjectIds  faultId  id  observationTime

@{USER_ALARM_LIST_NAME_SUFFIXES}=  USER_IGNORED_ALARMS  USER_EXPECTED_ALARMS  USER_CRITICAL_ALARMS

# States info
${Enabled_}  regex"Enabled|enabled"
${Disabled_}  regex"Disabled|disabled"
${Online_}  regex"Online|None"
${Offline_}  regex"Offline|off line"
${Degraded_}  regex"Degraded|degraded"
${Online_Degraded_}  regex"Online|None|Degraded|degraded"
${NotInstalled_}  regex"NotInstalled|not installed"
${NotInstalled_Offline_}  regex"NotInstalled|not installed|Offline|off line"
${Failed_}  regex"Failed|failed"
${Failed_Offline_}  regex"Failed|failed|Offline|off line"
${Unlocked_}  regex"Unlocked|unlocked"
${Locked_}  regex"Locked|locked"
${ShuttingDown_}  regex"ShuttingDown|Shutting Down"
${Dependency_}  regex"Dependency|dependency"
${PowerOff_}  regex"PowerOff|power off"
${Testing_}  regex"Testing|testing"
${Initializing_}  regex"Initializing|initializing"
${Commissioned_}  regex"Commissioned|commissioned"
${NotCommissioned_}  regex"NotCommissioned|notCommissioned"
${IntegratedToRan_}  regex"IntegratedToRan|integrated to RAN"
${OnAir_}  regex"OnAir|onAir"
${OnAirDone_}  regex"OnAirDone|onAirDone"
${Test_}  regex"Test|test"
${Configured_}  regex"Configured|configured"
${IntegratedToRan_Configured_}  regex"IntegratedToRan|integrated to RAN|Configured|configured"
${Blocked_}  Blocked
${Unblocked_}  Unblocked
${Blocking_}  Blocking
${Unblocking_}  Unblocking
${Idle_}  Idle
${Active_}  Active
${Busy_}  Busy
${IntegratedToRan|Commissioned_}  regex"integrated to RAN|commissioned|IntegratedToRan|Commissioned"
${Disabled_Enabled_}  regex"Disabled|disabled|Enabled|enabled"

# CBTS states info
${CBTS_Enabled_}  regex"Enabled|enabled"
${CBTS_Disabled_}  regex"Disabled|disabled"
${CBTS_Enabled_Disabled_}  regex"Enabled|enabled|Disabled|disabled"

${CBTS_OnAir_}  regex"OnAir|onAir"
${CBTS_Online_}  regex"on line"
${CBTS_Degraded_}  regex"Degraded|degraded"
${CBTS_Failed_}  regex"Failed|failed"
${CBTS_Offline_}  regex"Offline|off line"
${CBTS_Failed_Offline_}  regex"Failed|failed|Offline|off line"
${CBTS_NotInstalled_}  regex"NotInstalled|not installed"
${CBTS_NotInstalled_Offline_}  regex"NotInstalled|not installed|Offline|off line"
${CBTS_Dependency_}  regex"Dependency|dependency"

${CBTS_Blocked_}  regex"Blocked"
${CBTS_Unblocked_}  regex"Unblocked"

${CBTS_Unlocked_}  regex"Unlocked"
${CBTS_Locked_}  regex"Locked"

${CBTS_Configured_}  regex"configured"

#Feature flag dictionary
&{Feature_flag_dictionary}
...  HISTORICAL_ALARMS_CHECK=${True}
...  CNI_127210_ENABLED=${False}
...  USER_STOP_AND_FIX=${True}
...  USER_STOP_AND_FIX_BLOCK_TEST=${False}
...  USER_RSI_INFO_COLLECT=${True}
...  USER_RMOD_UDP_LOG_COLLECT=${True}
...  RMOD_UDP_LOG_CONFIG_PATH=${None}
...  RF_DIAGNOSTIC_CARD_CUSTOM_YAML=${None}
...  NETACT_CHECK=${True}
...  SYSLOG_CHECK=${True}
...  ENABLE_SNAPSHOT_FOR_PASSED_TC=${False}

*** Keywords ***
Common Test Setup
    [Documentation]
    ...  This is a set of actions which will be launched before each RFS test.
    ...  List of actions:
    ...  - Load TL configuration files
    ...  - Set framework preconditions and prepare alias list based on configuration files
    ...  - Iterates over every alias where the following will be executed:
    ...      > Entity preparation
    ...      > VM preparation based on VM type
    ...      > Services initialization based on technology
    ...      > Preconditions preparations based on technology
    ...
    ...  *AUTHOR*
    ...  alexandru.stamp@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter        | Mandatory | Description                                                                        |
    ...  | PrecheckConf     | No        | Flag for enabling BTS configuration precheck, result used for TcVerdict evaluation |
    ...  | PrecheckCells    | No        | Flag for enabling/disabling cells precheck, result used for TcVerdict evaluation   |
    ...  | PrecheckModules  | No        | Flag for enabling radio modules precheck, result used for TcVerdict evaluation     |
    ...  | PrecheckSCF      | No        | Flag for enabling SCF validation precheck, result used for TcVerdict evaluation    |
    ...  | RTWP_check       | No        | Flag for enabling RTWP precheck                                                    |
    ...  | RTWP_min         | No        | Min value for RTWP, default -108                                                   |
    ...  | RTWP_max         | No        | Max value for RTWP, default -90                                                    |
    ...  | connection_type  | No        | ADMIN connection type. Can be ssh_tunnel, oam_ip, admin_forwarder                  |
    ...  | infomodelSetup   | No        | Flag for enabling ADMIN_INFOMODEL setup connection                                 |

    [Arguments]  ${PrecheckConf}=${TRUE}  ${PrecheckCells}=${TRUE}  ${PrecheckModules}=${TRUE}  ${PrecheckSCF}=${TRUE}
    ...  ${RTWP_check}=${TRUE}  ${RTWP_min}=-108  ${RTWP_max}=-90  ${connection_type}=default  ${preset_techs}=@{EMPTY}
    ...  ${common_sbts}=${FALSE}  ${infomodelSetup}=${TRUE}  ${GetModuleInformation}=${TRUE}  ${newAlarmsFormat}=${FALSE}

    Log  \n##############################################################################################  console=True
    Log  Start test: ${TEST NAME}  console=True
    Log  \##############################################################################################\n  console=True
    Log  Common Test Setup  level=TRACE  console=True

    Set Test Variable  ${infomodelSetup}
    Configuration Loader
    Prepare Alias

    Update TL Variables  ${preset_techs}  ${common_sbts}  ${newAlarmsFormat}
    Log Variables  level=TRACE
    Framework Preconditions
    Get Linux Info  Start Of Common Test Setup

    FOR  ${alias}  IN  @{alias_list}

        Entity Preparation  alias=${alias}

        ${alias_tech}=  Get From Dictionary  ${${alias.upper()}}  ${alias.upper()}_TECH

        Run Keyword If  '${alias_tech}' in ['NR', 'LTE', 'SBTS', 'SRAN']  Run Keywords
        ...  Prepare Linux VM  ${alias}
        ...  AND  Initialize SOAM Services  ${alias}  ${connection_type}  ${infomodelSetup}
        Run Keyword If  '${alias_tech}' == 'CBTS'  Run Keywords
        ...  Prepare Linux VM  ${alias}
        ...  AND  Initialize CBTS Services  ${alias}

        Entity Preconditions  ${alias}

    END

    FOR  ${alias}  IN  @{alias_list}

        ${alias_tech}=  Get From Dictionary  ${${alias.upper()}}  ${alias.upper()}_TECH

        Run Keyword If  '${alias_tech}' in ['NR', 'LTE', 'SBTS', 'SRAN']
        ...  SBTS Preconditions  ${alias}
        Run Keyword If  '${alias_tech}' == 'CBTS'
        ...  CBTS Preconditions  ${alias}

    END

    Run Keyword if  '${newAlarmsFormat}' == '${FALSE}'  Set Alarms List

    Inject user alarms into test case alarm lists  ${USER_ALARM_LIST_NAME_SUFFIXES}  ${alias_list}

    Testline Preconditions
    ...  ${PrecheckConf}  ${PrecheckCells}  ${PrecheckModules}  ${PrecheckSCF}
    ...  ${RTWP_check}  ${RTWP_min}  ${RTWP_max}  ${GetModuleInformation}

    Start Additional Tools Services

    Log Variables  level=TRACE

    Get Linux Info  End Of Common Test Setup

    FOR  ${alias}  IN  @{alias_list}

        ${alias_tech}=  Get From Dictionary  ${${alias.upper()}}  ${alias.upper()}_TECH

        Run Keyword If  '${alias_tech}' in ['NR', 'LTE', 'SBTS', 'SRAN']
        ...  Get Initial test SBTS historical alarms  ${alias}

    END

    Log  End of Common Test Setup  level=TRACE  console=True

    [Teardown]  Set Test Variable  ${COMMON TEST SETUP STATUS}  ${KEYWORD STATUS}

Common Test Teardown
    [Documentation]
    ...  This is a set of actions which will be launched after each RFS test ends.
    ...  List of actions:
    ...  - Iterates over every alias where the following will be executed:
    ...      > Preconditions teardown based on technology
    ...      > Services teardown based on technology
    ...      > Entity Teardown
    ...
    ...  *AUTHOR*
    ...  alexandru.stamp@nokia.com
    ...
    ...  | Parameter             | Mandatory | Description                                                                 |
    ...  | SNAPSHOT ON FAILURE   | No        | Flag for enabling/disabling snapshot trace in case of Test case failure     |

    [Arguments]  ${SNAPSHOT ON FAILURE}=YES

    Log  Common Test Teardown  level=TRACE  console=True

    Get Linux Info  Start of Common Test Teardown

    Teardown Preconditions  ${SNAPSHOT ON FAILURE}

    ${STOP_AND_FIX_conditions_detected}=  Collect Logs By Stop And Fix Criteria

    FOR  ${alias}  IN  @{alias_list}

        ${alias_tech}=  Get From Dictionary  ${${alias.upper()}}  ${alias.upper()}_TECH

        Run Keyword If  '${alias_tech}' != 'CBTS'
        ...  Teardown SOAM Services  ${alias}
        Run Keyword If  '${alias_tech}' == 'CBTS'
        ...  Teardown CBTS Services  ${alias}

        Entity Teardown  ${alias}

    END

    Stop Additional Tools Services

    Sleep Mechanism for Stop and Fix  ${STOP_AND_FIX_SLEEP_TIME}  ${STOP_AND_FIX_conditions_detected}  ${USER_STOP_AND_FIX_BLOCK_TEST}

    FHGW Snapshot

    Framework Postconditions

    Get Linux Info  End of Common Test Teardown

    Current Run Summary
    Stop Execution If Stop on Fail occurred
    Test Run Summary

Framework Preconditions
    [Documentation]
    ...  This keyword will execute the framework preconditions at the start of the tests such as
    ...  create logs folders, set global variables, etc
    ...
    ...  *AUTHOR*
    ...  alexandru.stamp@nokia.com

    [Timeout]  20 minutes

    HRAN_TA Preconditions

    Set Test Variable  ${SnapshotTriggerEndTest}  NO
    Set Test Variable  ${SkipCellsAndRmsNumberCheck}  False
    Set Test Variable  ${OAM_architecture}  SOAM
    ${IOT_check_var}=  Run Keyword And Return Status  Variable Should Exist  ${IOT_MIMO_alarm_check}
    ${IOT_MIMO_alarm_check}=  Set Variable If  ${IOT_check_var}  ${IOT_MIMO_alarm_check}  True
    Set Test Variable  ${IOT_MIMO_alarm_check}

    Set Test Variable  ${NR_count}  0
    Set Test Variable  ${LTE_count}  0
    Set Test Variable  ${SBTS_count}  0

    Set Test Variable  ${CBTS_count}  0

    Load Listener for reporting to RFS Test Reporter
    Turn on all Testline HW when running from Cloud Environment

    ${config_exist}=  Run Keyword And Return Status  OperatingSystem.File Should Exist  /home/ute/testline_configuration/${TESTLINE_NAME}/__init__.py
    Run Keyword If  ${config_exist}  Copy File  /home/ute/testline_configuration/${TESTLINE_NAME}/__init__.py  ${Test Results Dir}

Framework Postconditions
    [Documentation]
    ...  This keyword will execute framework postconditions at the end of the tests
    ...  *AUTHOR*
    ...  alexandru.stamp@nokia.com

    [Timeout]  10 minutes

    #additional ssh connection close
    SSHLibrary.Close All Connections

    Hran_ta Postconditions

Entity Preconditions
    [Arguments]  ${alias}

    ${alias_tech}=  Get From Dictionary  ${${alias.upper()}}  ${alias.upper()}_TECH
    Run Keyword If  '${alias_tech}'=='SRAN'  Set ENB technology  ${alias}
    User Set BTS Tech  alias=${alias}
    Calculate Entity Count  alias=${alias}

Prepare Linux VM
    [Documentation]
    ...  This keyword will prepare Linux VMs based on alias. Will do the following actions
    ...  - Clean Linux VM of old files that are located in predefined locations
    ...  - Check free space on Linux VM after the VM was cleaned
    ...
    ...  *AUTHOR*
    ...  alexandru.stamp@nokia.com
    [Arguments]  ${alias}
    [Timeout]  20 minutes
    Clear processes  ${alias}
    Clean Linux VM Disk Space  ${alias}
    Check Linux VM Disk Space  ${alias}
    Set Linux VM Python Path   ${alias}

Entity Preparation
    [Arguments]  ${alias}
    [Timeout]  20 minutes
    [Documentation]
    ...  This keyword will do general preparation of the entity supplied in the form of alias. Will execute
    ...  actions that apply to multiple technologies such as creating SSH connections or set the exact type of technology
    ...  of an alias
    ...
    ...  *AUTHOR*
    ...  alexandru.stamp@nokia.com

    ${alias_tech}=  Get From Dictionary  ${${alias.upper()}}  ${alias.upper()}_TECH
    Run Keyword If  '${alias}' != '${alias_local}' and '${alias_tech}' in ['NR', 'LTE', 'SBTS', 'SRAN']
    ...  Create SSH Connection to VM  ${alias}

Teardown Preconditions
    [Arguments]  ${SNAPSHOT ON FAILURE}
    Set Test Variable  ${SNAPSHOT ON FAILURE}
    Run Keyword If  not ${alias_list_count} == 1  Add second SW to test data

Entity Teardown
    [Documentation]
    ...  This keyword will do general teardown of the entity supplied in the form of alias. Will execute
    ...  actions that apply to multiple technologies such as closing SSH connections
    ...
    ...  *AUTHOR*
    ...  alexandru.stamp@nokia.com
    [Arguments]  ${alias}
    ${alias_tech}=  Get From Dictionary  ${${alias.upper()}}  ${alias.upper()}_TECH
    Run Keyword If  '${alias}' != '${alias_local}' and '${alias_tech}' in ['NR', 'LTE', 'SBTS', 'SRAN']
    ...  Close SSH Connection to VM  ${alias}

Set Local Alias
    [Documentation]
    ...  This keyword will set as global variable (alas_local) the alias of the VM where the tests are executed based on the
    ...  supplied alias list
    ...
    ...  *AUTHOR*
    ...  alexandru.stamp@nokia.com

    [Arguments]  ${alias_list}
    [Timeout]  20 minutes

    FOR  ${entry}  IN  @{alias_list}
      ${status_alias}=  Determine Local Alias  ${entry}
      Run Keyword If  ${status_alias}  Run Keywords
      ...  Set Test Variable  ${alias_local}  ${entry}
      ...  AND  Return From Keyword
    END

    Fail  No Local Alias Found

Determine Local Alias
    [Documentation]
    ...  This keyword will determine if the supplied alias is the alias of the VM where the tests are executed.
    ...  Will return True or False based on IP check
    ...
    ...  *AUTHOR*
    ...  alexandru.stamp@nokia.com

    [Arguments]  ${alias}

    ${local_ip}=  OperatingSystem.Run  ip a s eth0 | egrep -o 'inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d' ' -f2
    ${alias_ip}=  Get From Dictionary  ${${alias.upper()}}  ${alias.upper()}_PC_IP_ADDRESS
    Run Keyword If  '${local_ip}' == '${alias_ip}'
    ...  Return From Keyword  ${True}
    ...  ELSE  Return From Keyword  ${False}

Initialize SOAM Services
    [Documentation]
    ...  This keyword will initialize SOAM services such as ADMIN, ADMIN_INFOMODEL, SYSLOG based on the supplied alias, connection type and
    ...  infomodelSetup. ADMIN_INFOMODEL setup connection is performed only if ${infomodelSetup} is set on True.
    ...
    ...  *AUTHOR*
    ...  alexandru.stamp@nokia.com

    [Arguments]    ${alias}    ${connection_type}    ${infomodelSetup}
    [Timeout]    40 minutes

    ${connection_type}=    Set Services Connection Type    ${connection_type}    ${alias}
    Set Test Variable    ${connection_type_${alias}}    ${connection_type}

    Start ADMIN On    alias=${alias}    connection_type=${connection_type}

    IF    '${infomodelSetup}' == '${TRUE}'
        Start ADMIN_INFOMODEL On    alias=${alias}    connection_type=${connection_type}
    ELSE
        Log    ADMIN_INFOMODEL Setup on '${alias}' will be skipped!    console=True
    END

    Start Syslog On    alias=${alias}
    IF    '${alias}_Ext' in ${alias_list_complete}
        Start Syslog On    alias=${alias}_Ext
    END

    Log    Finished SOAM Services Initialisation on ${alias}    console=True

SBTS Preconditions
    [Arguments]  ${alias}

    Get SW Version  ${alias}
    Set Subrack Position  ${alias}
    Set BTS system account permissions enable feature parameter  systemAcctPermEnable=false  alias=${alias}
    Set Ethernet port security enabled feature parameter  ethernetPortSecurityEnabled=false  alias=${alias}
    Select generic alarms lists based on flag  Alarm_flag_name=CNI_127210_ENABLED  Container_alarm_list_name1=${alias.upper()}_ALARMS_CNI_127210
    ...  Container_alarm_list_name2=${alias.upper()}_ALARMS_NO_CNI_127210  alias=${alias}

Teardown SOAM Services
    [Arguments]  ${alias}

    Collect ADMIN On '${alias}'
    ${infomodelSetup}=  Get Variable Value  ${infomodelSetup}  ${TRUE}
    Run Keyword If  '${infomodelSetup}' == '${TRUE}'  Collect ADMIN_INFOMODEL On '${alias}'

Prepare Alias
    [Tags]  robot:no-dry-run

    Set Local Alias  ${alias_list}

Prepare Alias HRAN
    [Tags]  robot:no-dry-run

    ${final_list}=  Create List  ${EMPTY}

    FOR  ${entry}  IN  @{TESTLINE_CONFIG_VARIABLES}
        ${pre}  ${post}=  Split String  ${entry}  =
        ${status_master}=  Run Keyword And Return Status  Should Contain  ${pre}  MASTER
        ${status_slave}=  Run Keyword And Return Status  Should Contain  ${pre}  SLAVE
        Run Keyword If  ${status_master} or ${status_slave}  Append To List  ${final_list}  ${pre.title()}
    END

    Return From Keyword  ${final_list}

Prepare Alias Cloud
    ${final_list}=  Create List  ${EMPTY}
    ${variable_list}=  Get Variables
    ${key_list}=  Collections.Get Dictionary Keys  ${variable_list}
    FOR  ${entry}  IN  @{key_list}
        ${string_entry}=  Convert To String  ${entry}
        ${match_value}=  Get Regexp Matches  ${entry}  \\&\{(MASTER|SLAVE\\d*)\\}  1
        ${status_value}=  Run Keyword And Return Status  Should Not Be Empty  ${match_value}
        Run Keyword If  ${status_value}  Append To List  ${final_list}  ${match_value[0].title()}
    END

    Return From Keyword  ${final_list}

Calculate Entity Count
    [Arguments]  ${alias}
    ${alias_tech}=  Get From Dictionary  ${${alias.upper()}}  ${alias.upper()}_TECH
    ${calculated_var}=  Evaluate  ${${alias_tech}_count} + 1
    Set Test Variable  ${${alias_tech}_count}  ${calculated_var}

RFS Test Case Final Checks

    [Arguments]  ${wait_timer}=5 min  ${RTWP_check}=${TRUE}  ${RTWP_min}=-108  ${RTWP_max}=-90  ${entity_scf_dict}=&{EMPTY}
    ...  ${rtwp_wait_timer}=20 sec

    ${errors}=  Get Variable Value  ${error_message_count}  0
    Wait Until Keyword Succeeds  ${wait_timer}  10 sec  Entity Final Checks  ${entity_scf_dict}
    Final Checks RTWP  RTWP_check=${RTWP_check}  RTWP_min=${RTWP_min}  RTWP_max=${RTWP_max}  rtwp_wait_timer=${rtwp_wait_timer}
    Run Keyword If  '${HISTORICAL_ALARMS_CHECK}' == '${TRUE}'  RFS Test Historical Alarms Check
    Run Keyword If  ${SYSLOG_CHECK}
    ...  RFS Test Syslog Analyzer Check
    ...  ELSE
    ...  Log  Syslog check skipped by user: SYSLOG_CHECK = ${SYSLOG_CHECK}  console=True

    ${errors_after}=  Get Variable Value  ${error_message_count}  0
    ${errors_final}=  Evaluate  ${errors_after} - ${errors}
    Run Keyword If  ${errors_final} > 0
    ...  Log  Snapshot will be taken because ERRORs appeared during RFS final checks!  level=WARN

RFS Test Syslog Analyzer Check

    ${last_check_time}=  Get Variable Value  ${SYSLOG_LAST_CHECK_TIME}  ${None}

    FOR  ${alias}  IN  @{alias_list}

        ${alias_tech}=  Get From Dictionary  ${${alias.upper()}}  ${alias.upper()}_TECH

        IF  '${alias_tech}' == 'CBTS'  CONTINUE

        ${SYSLOG_CHECK_BTS}=  Get Variable Value  ${SYSLOG_CHECK_${alias}}  ${SYSLOG_CHECK}
        IF  not ${SYSLOG_CHECK_BTS}
            Log  Syslog check on BTS ${alias} skipped by user: SYSLOG_CHECK_\${alias} = ${SYSLOG_CHECK_${alias}}  console=True
            CONTINUE
        END

        Log  Analyzing syslog for BTS ${alias}:  console=True

        ${command}=  Set Variable
        ...  if [ -s "${Temp Logs Dir}/${alias}UDP" ]; then (exit 0); else (exit 1); fi

        ${file_existence_check}=  Execute on Linux VM  ${command}  ${alias}

        IF  '${file_existence_check}' != '0'
            Log  Syslog file ${Temp Logs Dir}/${alias}UDP doesn't exists or is empty for BTS ${alias}. Skipping syslog analysis!  level=WARN
            CONTINUE
        END

        ${SYSLOG_CONTINUE_ON_FAIL_BTS}=  Get Variable Value  ${SYSLOG_CONTINUE_ON_FAIL_${alias}}  ${True}
        ${SYSLOG_ADDITIONAL_PATTERNS_BTS}=  Get Variable Value  ${SYSLOG_ADDITIONAL_PATTERNS_${alias}}  ${None}
        ${SYSLOG_IGNORED_PATTERNS_BTS}=  Get Variable Value  ${SYSLOG_IGNORED_PATTERNS_${alias}}  ${None}

        Setup Analyzer
        ...  hostname=${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]
        ...  username=${${alias.upper()}}[${alias.upper()}_PC_SSH_USERNAME]
        ...  password=${${alias.upper()}}[${alias.upper()}_PC_SSH_PASSWORD]
        ...  syslog_file=${Temp Logs Dir}/${alias}UDP
        ...  work_dir=${Temp Logs Dir}
        ...  start_time=${last_check_time}
        ...  additional_patterns=${SYSLOG_ADDITIONAL_PATTERNS_BTS}
        ...  ignored_patterns=${SYSLOG_IGNORED_PATTERNS_BTS}

        ${all_matches}  ${unique_matches}=  Analyze
        ${all_matches_count}=  Get Length  ${all_matches}
        ${unique_matches_count}=  Get Length  ${unique_matches}

        IF  ${all_matches_count} > 0
            Log  Found ${all_matches_count} critical errors in syslog for BTS ${alias}:  level=WARN
            Log Many  @{all_matches}  level=DEBUG
            Log  \nPrinting the unique only (${unique_matches_count} critical errors) for user readability:  console=True
        END

        FOR  ${error}  IN  @{unique_matches}
            Log  ${error}  console=True
        END

        IF  ${all_matches_count} > 0 and ${SYSLOG_CONTINUE_ON_FAIL_BTS}
            Run Keyword And Continue On Failure  Fail  Critical errors found in syslog for BTS ${alias}
        ELSE IF  ${all_matches_count} > 0 and not ${SYSLOG_CONTINUE_ON_FAIL_BTS}
            Fail  Critical errors found in syslog for BTS ${alias}. Stopping test execution.
        END

    END

    ${current_time}=  Get Time  time_=UTC  format=%Y-%m-%d %H:%M:%S
    Set Test Variable  ${SYSLOG_LAST_CHECK_TIME}  ${current_time}

RFS Test Historical Alarms Check

    FOR  ${alias}  IN  @{alias_list}
        Log  Check Historical Critical Alarms ${alias}  console=True

        ${alias_tech}=  Get From Dictionary  ${${alias.upper()}}  ${alias.upper()}_TECH
        ${HISTORICAL_IGNORED_ALARMS}=  Get Variable Value
        ...  ${test_alarms_list["${alias.upper()}_HISTORICAL_IGNORED_ALARMS"]}  ${ADMIN_COMMON_IGNORED_ALARMS}

        Run Keyword If  '${alias_tech}'!='CBTS'  Run Keywords
        ...  rfs_frame_rfs_common.Eval Historic Alarms  connection=${alias}  expected_alarms=@{EMPTY}
        ...  ignored_alarms=${HISTORICAL_IGNORED_ALARMS}  critical_alarms=${ADMIN_HISTORICAL_CRITICAL_ALARMS}
        ...  ignore_unexpected=True
        ...  AND  Continue For Loop

        RFS Test CBTS Historical Alarms Check  ${alias}
    END

RFS Test CBTS Historical Alarms Check
    [Arguments]    ${alias}

    ${cu_alias}=  Set Variable  ${alias} CU

    rfs_frame_rfs_common.Eval Historic Alarms  connection=${cu_alias}  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${CBTS_CU_COMMON_IGNORED_ALARMS}  critical_alarms=${CBTS_CU_HISTORICAL_CRITICAL_ALARMS}  ignore_unexpected=True
    ...  BTS_architecture=CBTS

    ${vdu_list}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_VDU]
    FOR  ${index}  ${vdu_info}  IN ENUMERATE  @{vdu_list}
         ${vdu_alias}=  Set Variable  ${alias} VDU${index+1}
         rfs_frame_rfs_common.Eval Historic Alarms  connection=${vdu_alias}  expected_alarms=@{EMPTY}
         ...  ignored_alarms=${CBTS_VDU_COMMON_IGNORED_ALARMS}  critical_alarms=${CBTS_VDU_HISTORICAL_CRITICAL_ALARMS}  ignore_unexpected=True
         ...  BTS_architecture=CBTS
    END

Entity Final Checks
    [Documentation]
    ...  KW for entity final checks. SCF for final checks can be provided in entity_scf_dict as input argument:
    ...  - as a dictionary with BTS entity alias as key and BTS entity scf path as value
    ...  - if scf path is not provided for BTS entity alias, initial SCF from Common Test Setup is used.
    ...
    ...  | Parameter          | Man. | Description                                                                            |
    ...  | ${entity_scf_dict} | No   | Dict with BTS entity alias as key and BTS entity scf path as value;
    ...                                - for classical BTS, key refers to BTS entity (ex. 'Master')
    ...                                - for cloud BTS, key refers to BTS CU and VDUs entities (ex 'Master CU', 'Master VDU1' |
    ...
    [Arguments]  ${entity_scf_dict}=&{EMPTY}

    FOR  ${alias}  IN  @{alias_list}

        ${alias_tech}=  Get From Dictionary  ${${alias.upper()}}  ${alias.upper()}_TECH

        Run Keyword If  '${alias_tech}' in ['NR', 'LTE', 'SBTS', 'SRAN']
        ...  Entity Final Checks BTS  ${alias}  ${entity_scf_dict}
        ...  ELSE IF  '${alias_tech}' == 'CBTS'
        ...  Entity Final Checks CBTS  ${alias}  ${entity_scf_dict}

    END

Customizable Preconditions
    [Arguments]  ${CheckConf}  ${CheckCells}  ${CheckModules}  ${GetModuleInformation}  ${executed}=${False}

    Log  ***** Customizable Preconditions checks started *****  level=TRACE  console=True

    Run Keyword If  '${SBTS_count}' >= '2'  Set Test Variable  ${single_bts}  ${False}
    ...  ELSE  Set Test Variable  ${single_bts}  ${True}

    FOR  ${alias}  IN  @{alias_list}

        ${alias_tech}=  Get From Dictionary  ${${alias.upper()}}  ${alias.upper()}_TECH

        Run Keyword If  '${alias_tech}' in ['NR', 'LTE', 'SBTS', 'SRAN']
        ...  Customizable Preconditions BTS
        ...  ${CheckConf}  ${CheckCells}  ${CheckModules}  ${alias}  ${executed}
        ...  ELSE IF  '${alias_tech}' == 'CBTS'
        ...  Customizable Preconditions CBTS  ${CheckConf}  ${CheckCells}  ${CheckModules}  ${alias}

    END

    Run Keyword If  ${GetModuleInformation}
    ...  Get BTS Information for Stop And Fix

Execute Command on SM via SSH TAF
    [Documentation]
    ...  KW used to execute commands on SM via SSH
    ...
    ...  *INPUT*
    ...  | Parameter       | Mandatory | Description                                                                                         |
    ...  | command         | Yes       | Commands to be executed on SM                                                                       |
    ...  | target_ip       | No        | SM ip address. By default 192.168.255.1                                                             |
    ...  | target_username | No        | Used only if remote VM is requested. By default toor4nsn                                            |
    ...  | target_password | No        | Used only if remote VM is requested. By default oZPS0POrRieRtu                                      |
    ...  | via_ip          | No        | None if SM ssh connection is perform from local VM, otherwise remote VM ip address. By default None |
    ...  | via_username    | No        | Used only if remote VM is requested. By default ute                                                 |
    ...  | via_password    | No        | Used only if remote VM is requested. By default ute                                                 |
    ...  | target_ip       | No        | SM ip address. By default 192.168.255.1                                                             |
    ...  | key_path        | No        | Key location for ssh connection. By default None                                                    |
    ...  | alias           | No        | Alias info. By default None                                                                         |
    ...  | port            | No        | Port info. By default None                                                                          |
    ...  | proxy           | No        | Proxy info. By default None                                                                         |
    ...  | timeout         | No        | Timeout in seconds for request, default value: 30                                                   |
    ...
    [Arguments]  ${command}  ${target_ip}=192.168.255.1  ${target_username}=toor4nsn  ${target_password}=oZPS0POrRieRtu  ${via_ip}=None
    ...  ${via_username}=ute  ${via_password}=ute  ${key_path}=None  ${alias}=None  ${port}=None  ${proxy}=None  ${timeout}=30

    Run Keyword If  '${via_ip}' != 'None'  Run Keywords
    ...  ssh.Connect To  hostname=${via_ip}  username=${via_username}  password=${via_password}  key_path=${key_path}  port=${port}  proxy=${proxy}
    ...  alias=${alias}  timeout=${timeout}
    ...  AND  ssh.Connect To  hostname=${target_ip}  username=${target_username}  password=${target_password}  alias=sm_ssh  proxy=${alias}
    ...  timeout=30
    ...  ELSE
    ...  ssh.Connect To  hostname=${target_ip}  username=${target_username}  password=${target_password}  alias=sm_ssh  timeout=30

    ${command_return}=  ssh.Execute  ${command}  connection=sm_ssh

    [Return]  ${command_return}

    [Teardown]  Run Keywords  ssh.Disconnect  connection=sm_ssh  AND  Run Keyword If  '${via_ip}' != '${None}'  ssh.Disconnect  connection=${alias}

Send Command on SM via SSH TAF
    [Documentation]
    ...  KW used to send commands on SM via SSH
    ...
    ...  *INPUT*
    ...  | Parameter       | Mandatory | Description                                                                                         |
    ...  | command         | Yes       | Commands to be executed on SM                                                                       |
    ...  | target_ip       | No        | SM ip address. By default 192.168.255.1                                                             |
    ...  | target_username | No        | Used only if remote VM is requested. By default toor4nsn                                            |
    ...  | target_password | No        | Used only if remote VM is requested. By default oZPS0POrRieRtu                                      |
    ...  | via_ip          | No        | None if SM ssh connection is perform from local VM, otherwise remote VM ip address. By default None |
    ...  | via_username    | No        | Used only if remote VM is requested. By default ute                                                 |
    ...  | via_password    | No        | Used only if remote VM is requested. By default ute                                                 |
    ...  | target_ip       | No        | SM ip address. By default 192.168.255.1                                                             |
    ...  | key_path        | No        | Key location for ssh connection. By default None                                                    |
    ...  | alias           | No        | Alias info. By default None                                                                         |
    ...  | port            | No        | Port info. By default None                                                                          |
    ...  | proxy           | No        | Proxy info. By default None                                                                         |
    ...  | timeout         | No        | Timeout in seconds for request, default value: 30                                                   |
    ...
    [Arguments]  ${command}  ${target_ip}=192.168.255.1  ${target_username}=toor4nsn  ${target_password}=oZPS0POrRieRtu  ${via_ip}=None
    ...  ${via_username}=ute  ${via_password}=ute  ${key_path}=None  ${alias}=None  ${port}=None  ${proxy}=None  ${timeout}=30

    Run Keyword If  '${via_ip}' != 'None'  Run Keywords
    ...  ssh.Connect To  hostname=${via_ip}  username=${via_username}  password=${via_password}  key_path=${key_path}  port=${port}  proxy=${proxy}
    ...  alias=${alias}  timeout=${timeout}
    ...  AND  ssh.Connect To  hostname=${target_ip}  username=${target_username}  password=${target_password}  alias=sm_ssh  proxy=${alias}
    ...  timeout=30
    ...  ELSE
    ...  ssh.Connect To  hostname=${target_ip}  username=${target_username}  password=${target_password}  alias=sm_ssh  timeout=30

    ssh.Send Command  command=${command}  connection=sm_ssh

    [Teardown]  Run Keywords  ssh.Disconnect  connection=sm_ssh  AND  Run Keyword If  '${via_ip}' != '${None}'  ssh.Disconnect  connection=${alias}

Recovery Test Executor TAF
    [Arguments]  ${CheckConf}  ${CheckCells}  ${CheckModules}  ${executed}=${False}
    [Tags]  robot:no-dry-run

    Run Keyword If  ${executed}
    ...  Fail  Recovery actions did not work. Test will fail.

    Log  Testline not ready due to cells status failed check, triggering TAF recovery...  console=True

    Import Resource  ${CURDIR}/rfs_recovery_soam.robot

    Trigger Recovery Action RFS SOAM  UNLOCK_POTENTIALLY_LOCKED_ELEMENTS

    Customizable Preconditions  ${CheckConf}  ${CheckCells}  ${CheckModules}  ${True}

Customizable Preconditions RTWP
    [Arguments]  ${RTWP_check}  ${RTWP_min}  ${RTWP_max}

    ${USER_RTWP_CHECK}=  Get Variable Value  ${USER_RTWP_CHECK}  ${TRUE}
    Run Keyword If  not ${USER_RTWP_CHECK}  Run Keywords
    ...  Log  RTWP info check skipped by user: USER_RTWP_CHECK = False  console=True
    ...  AND  Return From Keyword

    Run Keyword If  not ${RTWP_check}  Run Keywords
    ...  Log  RTWP info check will be skipped!  console=True
    ...  AND  Return From Keyword

    Log  ***** Customizable Preconditions RTWP checks started *****  level=TRACE  console=True

    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check RTWP info on BTS ${alias} *****  console=True

        ${alias_tech}=  Get From Dictionary  ${${alias.upper()}}  ${alias.upper()}_TECH

        Run Keyword If  '${alias_tech}' == 'CBTS'  Run Keywords
        ...  Log  RTWP info check will be skipped! Procedure not implemented for Cloud BTS architecture  console=True
        ...  AND  Continue For Loop

        ${USER_RTWP_CHECK_BTS}=  Get Variable Value  ${USER_RTWP_CHECK_${alias}}  ${TRUE}
        Run Keyword If  not ${USER_RTWP_CHECK_BTS}  Run Keywords
        ...  Log  RTWP info check skipped by user: USER_RTWP_CHECK_${alias} = False  console=True
        ...  AND  Continue For Loop

        ${BTS_CB014646_feature_dict}=  Get BTS CB014646 feature parameters  alias=${alias}
        ${BTS_redundancyRole}=  Get From Dictionary  ${BTS_CB014646_feature_dict}  redundancyRole
        Run Keyword If  '${BTS_redundancyRole}' == 'standby'  Run Keywords
        ...  Log  RTWP info check will be skipped! BTS ${alias} (redundancyRole=${BTS_redundancyRole}) with all cells disabled  console=True
        ...  AND  Continue For Loop

        ${RMOD_L3Protocol_dict}=  Admin Get RMOD L3 Protocol Info  ${alias}
        ${RMOD_L3Protocol_values}=  Get Dictionary Values  ${RMOD_L3Protocol_dict}
        ${RMOD_L3Protocol_values}=  Remove Duplicates  ${RMOD_L3Protocol_values}
        ${RMOD_L3Protocol_count}=  Get Length  ${RMOD_L3Protocol_values}

        ${NRCEL_id_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
        ${LNCEL_id_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
        ${WNCEL_id_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
        Set Test Variable  ${${alias}_NRCEL_id_list}  ${NRCEL_id_list}
        Set Test Variable  ${${alias}_LNCEL_id_list}  ${LNCEL_id_list}
        Set Test Variable  ${${alias}_WNCEL_id_list}  ${WNCEL_id_list}
        ${RAT_list}=  Create List
        Run Keyword If  ${${alias}_NRCEL_id_list}  Append To List  ${RAT_list}  NR
        Run Keyword If  ${${alias}_LNCEL_id_list}  Append To List  ${RAT_list}  LTE
        Run Keyword If  ${${alias}_WNCEL_id_list}  Append To List  ${RAT_list}  WCDMA
        Set Test Variable  ${${alias}_RAT_list}  ${RAT_list}

        Run Keyword If  ${${alias}_LNCEL_id_list}  Get LTE mMIMO globalCellId list  ${alias}
        ${LTE_cell_count}=  Run Keyword If  ${${alias}_LNCEL_id_list}  Get Length  ${${alias}_LNCEL_id_list}
        ${LTE_mMIMO_cell_count}=  Run Keyword If  ${${alias}_LNCEL_id_list}  Get Length  ${${alias}_LTE_mMIMO_globalCellId_list}
        Run Keyword If  ${${alias}_LNCEL_id_list} and ${LTE_mMIMO_cell_count} == ${LTE_cell_count}
        ...  Set Test Variable  ${${alias}_ALL_LNCEL_mMIMO_check}  ${TRUE}
        ...  ELSE IF  ${${alias}_LNCEL_id_list} and ${LTE_mMIMO_cell_count} != ${LTE_cell_count}
        ...  Set Test Variable  ${${alias}_ALL_LNCEL_mMIMO_check}  ${FALSE}

        Run Keyword If  ${${alias}_LNCEL_id_list}  Get LTE HOST and IOT globalCellId list  ${alias}

        ${BTS_RAT_RTWP_status_dict}=  Check RTWP status  ${RTWP_min}  ${RTWP_max}  ${alias}
        Set Test Variable  ${${alias}_BTS_RAT_RTWP_status_dict_initial}  ${BTS_RAT_RTWP_status_dict}
        Run Keyword If  ${${alias}_NRCEL_id_list}
        ...  Set Test Variable  ${${alias}_NR_CELL_ANT_RTWP_status_dict_initial}  ${NR_CELL_ANT_RTWP_status_dict}
        Run Keyword If  ${${alias}_LNCEL_id_list}
        ...  Set Test Variable  ${${alias}_LTE_CELL_ANT_RTWP_status_dict_initial}  ${LTE_CELL_ANT_RTWP_status_dict}
        Run Keyword If  ${${alias}_WNCEL_id_list}
        ...  Set Test Variable  ${${alias}_WCDMA_CELL_ANT_RTWP_status_dict_initial}  ${WCDMA_CELL_ANT_RTWP_status_dict}

        ${NR_RTWP_status}=  Run Keyword If  ${${alias}_NRCEL_id_list}  Get From Dictionary  ${${alias}_BTS_RAT_RTWP_status_dict_initial}  NR
        ${LTE_RTWP_status}=  Run Keyword If  ${${alias}_LNCEL_id_list}  Get From Dictionary  ${${alias}_BTS_RAT_RTWP_status_dict_initial}  LTE
        ${WCDMA_RTWP_status}=  Run Keyword If  ${${alias}_WNCEL_id_list}  Get From Dictionary  ${${alias}_BTS_RAT_RTWP_status_dict_initial}  WCDMA
        ${BTS_RTWP_status}=  Set Variable If
        ...  ('${NR_RTWP_status}' == 'None' and '${LTE_RTWP_status}' == 'None' and '${WCDMA_RTWP_status}' == 'None')  None
        ...  ('${NR_RTWP_status}' == 'False' or '${LTE_RTWP_status}' == 'False' or '${WCDMA_RTWP_status}' == 'False')  False  True
        Set Test Variable  ${${alias}_BTS_RTWP_status_initial}  ${BTS_RTWP_status}
        Run Keyword If  '${BTS_RTWP_status}' == 'None'
        ...  Log  No RAT RTWP info available on BTS ${alias} -> status ${BTS_RTWP_status}  console=True
        ...  ELSE IF  '${BTS_RTWP_status}' == 'True'
        ...  Log  All configured RAT RTWP info on BTS ${alias} in range [${RTWP_min} ${RTWP_max}] -> status ${BTS_RTWP_status}  console=True
        ...  ELSE IF  '${BTS_RTWP_status}' == 'False'
        ...  Log  Not all configured RAT RTWP info on BTS ${alias} in range [${RTWP_min} ${RTWP_max}] -> status ${BTS_RTWP_status}  console=True
    END

Final Checks RTWP
    [Arguments]  ${RTWP_check}  ${RTWP_min}  ${RTWP_max}  ${rtwp_wait_timer}

    ${USER_RTWP_CHECK}=  Get Variable Value  ${USER_RTWP_CHECK}  ${TRUE}
    Run Keyword If  not ${USER_RTWP_CHECK}  Run Keywords
    ...  Log  RTWP info check skipped by user: USER_RTWP_CHECK = False  console=True
    ...  AND  Return From Keyword

    Run Keyword If  not ${RTWP_check}  Run Keywords
    ...  Log  RTWP info check will be skipped!  console=True
    ...  AND  Return From Keyword

    Log  ***** Final Checks RTWP checks started *****  level=TRACE  console=True
    Sleep  ${rtwp_wait_timer}  reason=Wait ${rtwp_wait_timer} before RTWP read

    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check RTWP info on BTS ${alias} *****  console=True

        ${alias_tech}=  Get From Dictionary  ${${alias.upper()}}  ${alias.upper()}_TECH

        Run Keyword If  '${alias_tech}' == 'CBTS'  Run Keywords
        ...  Log  RTWP info check will be skipped! Procedure not implemented for Cloud BTS architecture  console=True
        ...  AND  Continue For Loop

        ${USER_RTWP_CHECK_BTS}=  Get Variable Value  ${USER_RTWP_CHECK_${alias}}  ${TRUE}
        Run Keyword If  not ${USER_RTWP_CHECK_BTS}  Run Keywords
        ...  Log  RTWP info check skipped by user: USER_RTWP_CHECK_${alias} = False  console=True
        ...  AND  Continue For Loop

        ${BTS_CB014646_feature_dict}=  Get BTS CB014646 feature parameters  alias=${alias}
        ${BTS_redundancyRole}=  Get From Dictionary  ${BTS_CB014646_feature_dict}  redundancyRole
        Run Keyword If  '${BTS_redundancyRole}' == 'standby'  Run Keywords
        ...  Log  RTWP info check will be skipped! BTS ${alias} (redundancyRole=${BTS_redundancyRole}) with all cells disabled  console=True
        ...  AND  Continue For Loop

        ${BTS_RAT_RTWP_status_dict}=  Check RTWP status  ${RTWP_min}  ${RTWP_max}  ${alias}
        Set Test Variable  ${${alias}_BTS_RAT_RTWP_status_dict_final}  ${BTS_RAT_RTWP_status_dict}
        Run Keyword If  ${${alias}_NRCEL_id_list}
        ...  Set Test Variable  ${${alias}_NR_CELL_ANT_RTWP_status_dict_final}  ${NR_CELL_ANT_RTWP_status_dict}
        Run Keyword If  ${${alias}_LNCEL_id_list}
        ...  Set Test Variable  ${${alias}_LTE_CELL_ANT_RTWP_status_dict_final}  ${LTE_CELL_ANT_RTWP_status_dict}
        Run Keyword If  ${${alias}_WNCEL_id_list}
        ...  Set Test Variable  ${${alias}_WCDMA_CELL_ANT_RTWP_status_dict_final}  ${WCDMA_CELL_ANT_RTWP_status_dict}

        ${NR_RTWP_status}=  Run Keyword If  ${${alias}_NRCEL_id_list}  Get From Dictionary  ${${alias}_BTS_RAT_RTWP_status_dict_final}  NR
        ${LTE_RTWP_status}=  Run Keyword If  ${${alias}_LNCEL_id_list}  Get From Dictionary  ${${alias}_BTS_RAT_RTWP_status_dict_final}  LTE
        ${WCDMA_RTWP_status}=  Run Keyword If  ${${alias}_WNCEL_id_list}  Get From Dictionary  ${${alias}_BTS_RAT_RTWP_status_dict_final}  WCDMA
        ${BTS_RTWP_status}=  Set Variable If
        ...  ('${NR_RTWP_status}' == 'None' and '${LTE_RTWP_status}' == 'None' and '${WCDMA_RTWP_status}' == 'None')  None
        ...  ('${NR_RTWP_status}' == 'False' or '${LTE_RTWP_status}' == 'False' or '${WCDMA_RTWP_status}' == 'False')  False  True
        Set Test Variable  ${${alias}_BTS_RTWP_status_final}  ${BTS_RTWP_status}
        Run Keyword If  '${BTS_RTWP_status}' == 'None'
        ...  Log  No RAT RTWP info available on BTS ${alias} -> status ${BTS_RTWP_status}  console=True
        ...  ELSE IF  '${BTS_RTWP_status}' == 'True'
        ...  Log  All configured RAT RTWP info on BTS ${alias} in range [${RTWP_min} ${RTWP_max}] -> status ${BTS_RTWP_status}  console=True
        ...  ELSE IF  '${BTS_RTWP_status}' == 'False'
        ...  Log  Not all configured RAT RTWP info on BTS ${alias} in range [${RTWP_min} ${RTWP_max}] -> status ${BTS_RTWP_status}  console=True
    END
    Set Test Verdict based on RAT RTWP info

Check RTWP status
    [Arguments]  ${RTWP_min}  ${RTWP_max}  ${alias}
    Log  ***** Launch RTWP info collect procedure *****  console=True
    Log  RTWP info check will be skipped for following cases (if present):  console=True
    Log  - LTE mMIMO cells  console=True
    Log  - LTE IOT cells  console=True
    Log  - NR cells if legacy Antenna Line Online Monitoring feature is running  console=True
    Log  - ECPRI radio modules  console=True
    ${RAT_RTWP_status_dict}=  Collect and check RAT RTWP info  ${RTWP_min}  ${RTWP_max}  ${alias}
    ${RAT_list}=  Get Dictionary Keys  ${RAT_RTWP_status_dict}  False
    FOR  ${RAT}  IN  @{RAT_list}
        ${RAT_RTWP_status}=  Get From Dictionary  ${RAT_RTWP_status_dict}  ${RAT}
        Run Keyword If  '${RAT_RTWP_status}' == 'True'
        ...  Log  ${RAT} RTWP info in range [${RTWP_min} ${RTWP_max}] -> status True   console=True
        ...  ELSE IF  '${RAT_RTWP_status}' == 'False'
        ...  Log  ${RAT} RTWP info out of range [${RTWP_min} ${RTWP_max}] -> status False  console=True
        ...  ELSE IF  '${RAT_RTWP_status}' == 'None' and '${RAT}' == 'NR'
        ...  Log Long String  ${RAT} RTWP info check will be skipped! Procedure not applicable for NR cells if legacy Antenna Line Online Monitoring
        ...  feature is running on BTS ${alias}  console=True
        ...  ELSE IF  '${RAT_RTWP_status}' == 'None' and '${RAT}' == 'LTE'
        ...  Log  ${RAT} RTWP info check will be skipped! Procedure not applicable for LTE mMIMO cells on BTS ${alias}  console=True
    END

    [Return]  ${RAT_RTWP_status_dict}

Set Test Verdict based on RAT RTWP info

    ${level}=  Set Variable If  '${fail_if_unexpected_rtwp}'=='True'  ERROR  WARN
    ${verdict}=  Set Variable If  '${fail_if_unexpected_rtwp}'=='True'  failed  passed

    FOR  ${alias}  IN  @{alias_list}

        Log  Set Test Verdict based on initial and final RAT RTWP info on BTS ${alias}  console=True

        ${alias_tech}=  Get From Dictionary  ${${alias.upper()}}  ${alias.upper()}_TECH

        Run Keyword If  '${alias_tech}' == 'CBTS'  Run Keywords
        ...  Log  RTWP info check will be skipped! Procedure not implemented for Cloud BTS architecture  console=True
        ...  AND  Continue For Loop

        ${USER_RTWP_CHECK_BTS}=  Get Variable Value  ${USER_RTWP_CHECK_${alias}}  ${TRUE}
        Run Keyword If  not ${USER_RTWP_CHECK_BTS}  Run Keywords
        ...  Log  Test Verdict based on RTWP info status on BTS ${alias} will be skipped  console=True
        ...  AND  Continue For Loop

        ${BTS_CB014646_feature_dict}=  Get BTS CB014646 feature parameters  alias=${alias}
        ${BTS_redundancyRole}=  Get From Dictionary  ${BTS_CB014646_feature_dict}  redundancyRole
        Run Keyword If  '${BTS_redundancyRole}' == 'standby'  Run Keywords
        ...  Log  RTWP info check will be skipped! BTS ${alias} (redundancyRole=${BTS_redundancyRole}) with all cells disabled  console=True
        ...  AND  Continue For Loop

        Log  Initial RTWP info status on BTS ${alias}: ${${alias}_BTS_RTWP_status_initial}  console=True
        Log  Final RTWP info status on BTS ${alias}: ${${alias}_BTS_RTWP_status_final}  console=True

        Run Keyword If  '${${alias}_BTS_RTWP_status_initial}' == 'None' and '${${alias}_BTS_RTWP_status_final}' == 'None'  Run Keywords
        ...  Log  Test Verdict based on RTWP info status on BTS ${alias} will be skipped  console=True
        ...  AND  Continue For Loop

        ${NR_RTWP_no_change}=  Run Keyword If  ${${alias}_NRCEL_id_list}  Run Keyword And Return Status  Dictionaries Should Be Equal
        ...  ${${alias}_NR_CELL_ANT_RTWP_status_dict_initial}  ${${alias}_NR_CELL_ANT_RTWP_status_dict_final}
        ${LTE_RTWP_no_change}=  Run Keyword If  ${${alias}_LNCEL_id_list}  Run Keyword And Return Status  Dictionaries Should Be Equal
        ...  ${${alias}_LTE_CELL_ANT_RTWP_status_dict_initial}  ${${alias}_LTE_CELL_ANT_RTWP_status_dict_final}
        ${WCDMA_RTWP_no_change}=  Run Keyword If  ${${alias}_WNCEL_id_list}  Run Keyword And Return Status  Dictionaries Should Be Equal
        ...  ${${alias}_WCDMA_CELL_ANT_RTWP_status_dict_initial}  ${${alias}_WCDMA_CELL_ANT_RTWP_status_dict_final}
        ${cond}=  Create Long String  '${NR_RTWP_no_change}' in ['True','None'] and '${LTE_RTWP_no_change}' in ['True','None'] and
        ...  '${WCDMA_RTWP_no_change}' in ['True','None']
        ${change}=  Set Variable If  ${cond}  False  True

        Run Keyword If  '${${alias}_BTS_RTWP_status_initial}' == 'True' and '${${alias}_BTS_RTWP_status_final}' == 'True'
        ...  Log  RTWP info in range before and after test: verdict passed  console=True
        ...  ELSE IF  '${${alias}_BTS_RTWP_status_initial}' == 'False' and '${${alias}_BTS_RTWP_status_final}' == 'False' and '${change}' == 'False'
        ...  Log  RTWP info out of range before and after test (RTWP status not changed on same cell RX): verdict passed  console=True
        ...  ELSE IF  '${${alias}_BTS_RTWP_status_initial}' == 'False' and '${${alias}_BTS_RTWP_status_final}' == 'False' and '${change}' == 'True'
        ...  Log  RTWP info out of range before and after test (RTWP status changed on same cell RX): verdict ${verdict}  level=${level}
        ...  ELSE IF  '${${alias}_BTS_RTWP_status_initial}' == 'True' and '${${alias}_BTS_RTWP_status_final}' == 'False'
        ...  Log  RTWP info in range before test - RTWP info out of range after test: verdict ${verdict}  level=${level}
        ...  ELSE IF  '${${alias}_BTS_RTWP_status_initial}' == 'False' and '${${alias}_BTS_RTWP_status_final}' == 'True'
        ...  Log  RTWP info out of range before test - RTWP info in range after test: verdict ${verdict}  level=${level}
        Log  Initial RAT RTWP info dict on BTS ${alias}: ${${alias}_BTS_RAT_RTWP_status_dict_initial}  console=True
        Log  Final RAT RTWP info dict on BTS ${alias}: ${${alias}_BTS_RAT_RTWP_status_dict_final}  console=True

        ${RX_fail_condition}=  Create Long String  '${level}' == 'ERROR' and '${${alias}_BTS_RTWP_status_initial}' == 'False' and
        ...  '${${alias}_BTS_RTWP_status_final}'=='False' and '${change}' == 'True'

        Run Keyword If  ${RX_fail_condition}
        ...  Run Keyword And Continue on Failure  Fail  RTWP info out of range before and after test (RTWP status changed on same cell RX)
        ...  ELSE IF  '${level}' == 'ERROR' and '${${alias}_BTS_RTWP_status_initial}' == 'True' and '${${alias}_BTS_RTWP_status_final}' == 'False'
        ...  Run Keyword And Continue on Failure  Fail  RTWP info in range before test - RTWP info out of range after test
        ...  ELSE IF  '${level}' == 'ERROR' and '${${alias}_BTS_RTWP_status_initial}' == 'False' and '${${alias}_BTS_RTWP_status_final}' == 'True'
        ...  Run Keyword And Continue on Failure  Fail  RTWP info out of range before test - RTWP info in range after test
    END

Get File From System Module TAF
    [Arguments]  ${source_path}  ${destination_path}  ${via_username}=None  ${via_ip}=None  ${target_ip}=192.168.255.1  ${via_password}=None
    ...  ${key_path}=None  ${alias}=via_conn  ${port}=None  ${proxy}=None  ${timeout}=30

    Run Keyword If  '${via_ip}' != '${None}'  Run Keywords
    ...  ssh.connect to  hostname=${via_ip}  username=${via_username}  password=${via_password}  key_path=${key_path}  port=${port}  proxy=${proxy}
    ...  alias=${alias}  timeout=${timeout}
    ...  AND  ssh.connect to    ${target_ip}  toor4nsn  oZPS0POrRieRtu  alias=sm_ssh  proxy=${alias}  timeout=30
    ...  ELSE  ssh.connect to    ${target_ip}  toor4nsn  oZPS0POrRieRtu  alias=sm_ssh  timeout=30

    ${file_exists}=  ssh.File Exists  remote_path=${source_path}  connection=sm_ssh
    Run Keyword If   ${file_exists}
    ...  ssh.download file  remote_path=${source_path}  local_path=${destination_path}  connection=sm_ssh

    [Return]  ${destination_path}
    [Teardown]  Run Keywords  ssh.disconnect  connection=sm_ssh  AND  Run Keyword If  '${via_ip}' != '${None}'  ssh.disconnect  connection=${alias}

DCAP Preconditions

    ${USER_DCAP_TRACE_COLLECT}=  Get Variable Value  ${USER_DCAP_TRACE_COLLECT}  ${FALSE}
    Run Keyword If  not ${USER_DCAP_TRACE_COLLECT}  Run Keywords
    ...  Log  DCAP tool trace collect skipped by user: USER_DCAP_TRACE_COLLECT = False  console=True
    ...  AND  Return From Keyword

    ${BTS_DCAP_TRACE_COLLECT}=  Check request for specific BTS DCAP trace collection
    Set Test Variable  ${BTS_DCAP_TRACE_COLLECT}
    Run Keyword If  not ${BTS_DCAP_TRACE_COLLECT}  Run Keywords
    ...  Log  DCAP tool trace collect skipped by user: all BTS flags USER_DCAP_TRACE_COLLECT_\${alias} = False  console=True
    ...  AND  Return From Keyword

    ${DCAP_profiles_file_check}=  Run Keyword And Return Status  Variable Should Exist  ${DCAP_PROFILES_CONFIG_PATH}
    Set Test Variable  ${DCAP_profiles_file_check}
    Run Keyword If  not ${DCAP_profiles_file_check}  Run Keywords
    ...  Log  DCAP tool trace collect skipped due to improper config: missing dcap_profiles.yaml file!  console=True
    ...  AND  Return From Keyword

    ${DCAP_usage_tool_info}=  Get DCAP tool usage info
    Set Test Variable  ${DCAP_usage_tool_info}
    Run Keyword If  '${DCAP_usage_tool_info}' == 'mixed'  Run Keywords
    ...  Log Long String  DCAP tool trace collect skipped due to improper mixed DCAP tool usage found, please set init.py info related to DCAP tool
    ...  specific for external or internal DCAP tool usage.  console=True
    ...  AND  Return From Keyword

    Run Keyword And Continue On Failure  Prepare DCAP tool on UTE VM  DCAP_tool_start=${TRUE}  DCAP_tool_stop=${FALSE}  DCAP_tool_update=${TRUE}
    Run Keyword If  '${DCAP_usage_tool_info}' == 'internal'
    ...  Run Keyword If  '${DCAP_start_tool_status}' == 'False'  Run Keywords
    ...  Log  DCAP tool not running due to failed startup.  console=True
    ...  AND  Return From Keyword

    Run Keyword And Continue On Failure  Start Trace by DCAP tool

DCAP Teardown

    ${USER_DCAP_TRACE_COLLECT}=  Get Variable Value  ${USER_DCAP_TRACE_COLLECT}  ${FALSE}
    Run Keyword If  not ${USER_DCAP_TRACE_COLLECT}  Run Keywords
    ...  Log  DCAP tool trace collect skipped by user: USER_DCAP_TRACE_COLLECT = False  console=True
    ...  AND  Return From Keyword

    Run Keyword If  not ${BTS_DCAP_TRACE_COLLECT}  Run Keywords
    ...  Log  DCAP tool trace collect skipped by user: all BTS flags USER_DCAP_TRACE_COLLECT_\${alias} = False  console=True
    ...  AND  Return From Keyword

    Run Keyword If  not ${DCAP_profiles_file_check}  Run Keywords
    ...  Log  DCAP tool trace collect skipped due to improper config: missing dcap_profiles.yaml file!  console=True
    ...  AND  Return From Keyword

    Run Keyword If  '${DCAP_usage_tool_info}' == 'mixed'  Run Keywords
    ...  Log Long String  DCAP tool trace collect skipped due to improper mixed DCAP tool usage found, please set init.py info related to DCAP tool
    ...  specific for external or internal DCAP tool usage.  console=True
    ...  AND  Return From Keyword

    Run Keyword If  '${DCAP_usage_tool_info}' == 'internal'
    ...  Run Keyword If  '${DCAP_start_tool_status}' == 'False'  Run Keywords
    ...  Log  DCAP tool not running due to failed startup.  console=True
    ...  AND  Return From Keyword

    Run Keyword And Continue On Failure  Stop Trace by DCAP tool

    Run Keyword And Continue On Failure  Collect Trace by DCAP tool

    Run Keyword And Continue On Failure  Check DCAP tool hanging resources

    Run Keyword And Continue On Failure  Prepare DCAP tool on UTE VM  DCAP_tool_start=${FALSE}  DCAP_tool_stop=${TRUE}  DCAP_tool_update=${FALSE}

Testline Preconditions
    [Documentation]
    ...  This keyword will execute the testline preconditions at the start of the tests for:
    ...  - check BTS configuration SCF/runtime view
    ...  - check cell(s) status
    ...  - check RM(s) status
    ...  - check SCF validation
    ...  - check RTWP info
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    [Arguments]  ${PrecheckConf}  ${PrecheckCells}  ${PrecheckModules}  ${PrecheckSCF}
    ...  ${RTWP_check}  ${RTWP_min}  ${RTWP_max}  ${GetModuleInformation}

    Customizable Preconditions
    ...  CheckConf=${PrecheckConf}  CheckCells=${PrecheckCells}  CheckModules=${PrecheckModules}
    ...  GetModuleInformation=${GetModuleInformation}
    Customizable Preconditions SCF  PrecheckSCF=${PrecheckSCF}
    Customizable Preconditions RTWP  RTWP_check=${RTWP_check}  RTWP_min=${RTWP_min}  RTWP_max=${RTWP_max}

Start Additional Tools Services
    [Documentation]
    ...  This keyword will execute start of additional tools sevices (if requested) for:
    ...  - collect DCAP traces
    ...  - Scout SCF id reporting
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    DCAP Preconditions
    Scout SCF id reporting
    RSI Preconditions
    RMOD UDP LOG Preconditions
    NetAct Preconditions

Stop Additional Tools Services
    [Documentation]
    ...  This keyword will execute stop of additional tools services (if requested) for:
    ...  - collect DCAP traces
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    DCAP Teardown
    RSI Postconditions
    RMOD UDP LOG Postconditions
    NetAct Postconditions

Scout SCF id reporting

    Log  Reporting Scout SCF id  console=True

    Run Keyword If  not ('${TESTLINE_NAME}' != '${EMPTY}' and '${CLOUD_ENV}' == '${TRUE}')  Run Keywords
    ...  Log  Scout SCF id reporting will be skipped!  console=True
    ...  AND  Return From Keyword

    ${SCOUT_TL_NAME}=  Get Variable Value  ${SCOUT_TL_NAME}  ${NONE}
    Run Keyword If  '${SCOUT_TL_NAME}' == '${NONE}'
    ...  Get Scout TL name based on TL configuration

    ${Scout_SCF_id}=  Get Scout SCF id  ${SCOUT_TL_NAME}
    Run Keyword If  '${Scout_SCF_id}' != '${NONE}'
    ...  Log  - Scout Testline Name: ${SCOUT_TL_NAME}\n- Scout SCF id: ${Scout_SCF_id}  console=True

Get Linux Info
    [Arguments]  ${moment_of_print}
    Log  Saving Environment Information in ${Test Results Dir}/Environment_Information.txt  console=True

    ${cmd1}=  Set Variable  date +"%d.%m.%Y %H:%M:%S"
    ${cmd2}=  Set Variable  df -h
    ${cmd3}=  Set Variable  free -h -w
    ${cmd4}=  Set Variable  pip freeze --all
    ${cmd5}=  Set Variable  sudo ps -eaf
    ${cmd6}=  Set Variable  sudo ps -aux
    ${cmd7}=  Set Variable  netstat -nap

    ${to_file} =  Set Variable  | tee -a "${Test Results Dir}/Environment_Information.txt"
    ${header_cmd}=  Set Variable  echo ============================== ${moment_of_print} ==============================
    ${delimiter_cmd}=  Set Variable
    ...  echo ===================================================================================================================== ${to_file}

    OperatingSystem.Run  ${header_cmd} ${to_file}

    FOR  ${cmd_idx}  IN RANGE  1  8
        ${linux_cmd}=  Set Variable  ${cmd${cmd_idx}} ${to_file}
        OperatingSystem.Run  ${delimiter_cmd}
        OperatingSystem.Run  ${linux_cmd}
        OperatingSystem.Run  ${delimiter_cmd}
    END

RSI Preconditions

    Run Keyword If  not ${USER_RSI_INFO_COLLECT}  Run Keywords
    ...  Log  RMODs serial interface logs collect skipped by user: USER_RSI_INFO_COLLECT = False  console=True
    ...  AND  Return From Keyword

    Set Test Variable  ${rsi_rmod_setup_count}  ${0}
    Set Test Variable  @{rsi_rmod_setup_list}  @{Empty}

    ${rsi_config_check}=  Check RSI config type
    Run Keyword If  '${rsi_config_check}'=='init'
    ...  RSI Setup Resources From Init Data  main_log_directory=${Test Results Dir}/RSILogs
    ...  ELSE
    ...  Log  Rmod serial interface setup skipped. No lmi data in __init__.py file found.   console=True

    Set Test Variable  ${RSI_config_type}  ${rsi_config_check}
    Return From Keyword If  ${rsi_rmod_setup_count} == ${0}

Check RSI config type

    ${module_data_dicts}=  Get Dictionary Values  ${INTERFACES}
    ${lmi_info}=  Set Variable  ${Empty}

    FOR  ${module_data_dict}  IN  @{module_data_dicts}

       ${lmi_info_present}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${module_data_dict}  lmi
       ${lmi_info}=  Set Variable If  ${lmi_info_present}
       ...  init  ${lmi_info}
       Exit For Loop If  '${lmi_info}'

    END

    [Return]  ${lmi_info}

RSI Postconditions

    Run Keyword If  not ${USER_RSI_INFO_COLLECT}  Run Keywords
    ...  Log  RMODs serial interface logs collect skipped by user: USER_RSI_INFO_COLLECT = False  console=True
    ...  AND  Return From Keyword

    ${rsi_config_file_check}=  Get Variable Value  ${RSI_config_type}  ${Empty}
    Run Keyword If  '${rsi_config_file_check}' != 'init'  Run Keywords
    ...  Log  RMODs serial interface logs collect skipped due to improper config:
    ...  AND  Log  missing rsi information in __init__.py !  console=True
    ...  AND  Return From Keyword

    Run Keyword If  not (${rsi_rmod_setup_list})  Run Keywords
    ...  Log  RMODs serial interface logs collect skipped due to improper config:  console=True
    ...  AND  Log  incorrect lmi.uart_mapping info in __init__.py file for all RMOD  console=True
    ...  AND  Return From Keyword

    Run Keyword And Continue On Failure  RSI Teardown RMODs Connections  rsi_rmod_setup_list=${rsi_rmod_setup_list}

Initialize CBTS Services
    [Documentation]
    ...  This keyword will initialize CBTS services for CU and VDUs based on the supplied alias
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com

    [Arguments]  ${alias}

    Common CU Setup  alias=${alias}
    Common VDU Setup  alias=${alias}

    Log  Finished CBTS Services Initialisation on ${alias}  console=True

CBTS Preconditions
    [Arguments]  ${alias}

    Get SW Version  ${alias}
    Get Initial test CBTS historical alarms  ${alias}

Customizable Preconditions BTS
    [Arguments]  ${CheckConf}  ${CheckCells}  ${CheckModules}  ${alias}  ${executed}

    Run Keyword If  ${CheckConf}  Get BTS Current Plan Info  ${alias}

    Log  ***** Check ${alias} configuration and runtime info alignment *****  console=True
    ${PreconditionBTSConf_check}=  Run Keyword If  ${CheckConf}
    ...  Check Entity BTS Configuration  ${alias}
    Run Keyword If  ${CheckConf} and ${PreconditionBTSConf_check}
    ...  Log  ${alias} configuration and runtime info alignment check is passed!  console=True
    ...  ELSE IF  ${CheckConf} and not ${PreconditionBTSConf_check}  Run Keywords
    ...  Log  ${alias} configuration and runtime info alignment check is failed!  level=ERROR
    ...  AND  Run Keyword If  not ${TAF_CONFIG_MODEL}
    ...  Fail  Testline not ready due to ${alias} configuration and runtime info misalignment, triggering recovery...  BLOCKED-TESTS
    ...  AND  Run Keyword If  ${TAF_CONFIG_MODEL}
    ...  Recovery Test Executor TAF  ${CheckConf}  ${CheckCells}  ${CheckModules}  ${executed}

    Log  ***** Check ${alias} cells status *****  console=True
    ${PreconditionCells_check}  ${BTS_redundancyRole}=  Run Keyword If  ${CheckCells}
    ...  Check Entity Cells State  ${alias}
    Run Keyword If  ${CheckCells} and ${PreconditionCells_check} and '${BTS_redundancyRole}' not in ['active','standby']
    ...  Log  ${alias} cells status check is passed!  console=True
    ...  ELSE IF  ${CheckCells} and ${PreconditionCells_check} and '${BTS_redundancyRole}' in ['active','standby']
    ...  Log  ${alias} (redundancyRole=${BTS_redundancyRole}) cells status check is passed!  console=True
    ...  ELSE IF  ${CheckCells} and not ${PreconditionCells_check}  Run Keywords
    ...  Log  ${alias} cells status check is failed!  level=ERROR
    ...  AND  Run Keyword If  not ${TAF_CONFIG_MODEL}
    ...  Fail  Testline not ready due to ${alias} cells status failed check, triggering recovery...  BLOCKED-TESTS
    ...  AND  Run Keyword If  ${TAF_CONFIG_MODEL}
    ...  Recovery Test Executor TAF  ${CheckConf}  ${CheckCells}  ${CheckModules}  ${executed}

    Log  ***** Check ${alias} RMs status *****  console=True
    ${PreconditionModules_check}=  Run Keyword If  ${CheckModules}
    ...  Check Entity RMs State  ${alias}
    Run keyword If  ${CheckModules} and ${PreconditionModules_check}
    ...  Log  ${alias} RMs status check is passed!  console=True
    ...  ELSE IF  ${CheckModules} and not ${PreconditionModules_check}  Run Keywords
    ...  Log  ${alias} RMs status check is failed!  level=ERROR
    ...  AND  Run Keyword If  ${TAF_CONFIG_MODEL}
    ...  Recovery Test Executor TAF  ${CheckConf}  ${CheckCells}  ${CheckModules}  ${executed}

    ${alias_tech}=  Get From Dictionary  ${${alias.upper()}}  ${alias.upper()}_TECH

    Log  ${alias} ${alias_tech} entity customisable preconditions passed  console=True

Customizable Preconditions CBTS
    [Arguments]  ${CheckConf}  ${CheckCells}  ${CheckModules}  ${alias}

    Run Keyword If  ${CheckConf}  Get CBTS CU and VDUs Current Plan Info  ${alias}

    Log  ***** Check ${alias} configuration and runtime info alignment *****  console=True
    ${PreconditionBTSConf_check}=  Run Keyword If  ${CheckConf}
    ...  Check CBTS Configuration  ${alias}
    Run Keyword If  ${CheckConf} and ${PreconditionBTSConf_check}
    ...  Log  ${alias} configuration and runtime info alignment check is passed!  console=True
    ...  ELSE IF  ${CheckConf} and not ${PreconditionBTSConf_check}  Run Keywords
    ...  Log  ${alias} configuration and runtime info alignment check is failed!  level=ERROR
    ...  AND  Fail  ${alias} configuration and runtime info alignment check is failed!

    Log  ***** Check ${alias} cells status *****  console=True
    ${PreconditionCells_check}=  Run Keyword If  ${CheckCells}
    ...  Check CBTS Cells State  ${alias}
    Run Keyword If  ${CheckCells} and ${PreconditionCells_check}
    ...  Log  ${alias} cells status check is passed!  console=True
    ...  ELSE IF  ${CheckCells} and not ${PreconditionCells_check}  Run Keywords
    ...  Log  ${alias} cells status check is failed!  level=ERROR
    ...  AND  Fail  ${alias} cells status check is failed!

    Log  ***** Check ${alias} RMs status *****  console=True
    ${PreconditionModules_check}=  Run Keyword If  ${CheckModules}
    ...  Check CBTS RMODs State  ${alias}
    Run keyword If  ${CheckModules} and ${PreconditionModules_check}
    ...  Log  ${alias} RMs status check is passed!  console=True
    ...  ELSE IF  ${CheckModules} and not ${PreconditionModules_check}  Run Keywords
    ...  Log  ${alias} RMs status check is failed!  level=ERROR
    ...  AND  Fail  ${alias} RMODs status not as expected!

    ${alias_tech}=  Get From Dictionary  ${${alias.upper()}}  ${alias.upper()}_TECH

    Log  ${alias} ${alias_tech} entity customisable preconditions passed  console=True

Teardown CBTS Services
    [Arguments]  ${alias}

    Common CU Teardown  alias=${alias}
    Common VDU Teardown  alias=${alias}

    Log  Finished CBTS Services Teardown on ${alias}  console=True

Customizable Preconditions SCF
    [Arguments]  ${PrecheckSCF}

    ${USER_SCF_VALIDATION_CHECK}=  Get Variable Value  ${USER_SCF_VALIDATION_CHECK}  ${TRUE}
    Run Keyword If  not ${USER_SCF_VALIDATION_CHECK}  Run Keywords
    ...  Log  SCF validation check skipped by user: USER_SCF_VALIDATION_CHECK = False  console=True
    ...  AND  Return From Keyword

    Run Keyword If  not ${PrecheckSCF}  Run Keywords
    ...  Log  SCF validation check will be skipped!  console=True
    ...  AND  Return From Keyword

    Log  ***** Customizable Preconditions SCF validation checks started *****  level=TRACE  console=True

    FOR  ${alias}  IN  @{alias_list}

        ${alias_tech}=  Get From Dictionary  ${${alias.upper()}}  ${alias.upper()}_TECH

        Continue For Loop If  '${alias_tech}' in ['CBTS']

        ${PreconditionSCFvalidation}  ${SCF_validation_result}=  Check BTS SCF Validation  scf_validation_log_dir=${BTSFiles}/${alias}/SCF_Validation
        ...  alias=${alias}
        Run Keyword If  '${PreconditionSCFvalidation}' == '${False}'  Run Keywords
        ...  Log  ${alias} BTS SCF validation operation failed, please check related files from ${BTSFiles}/${alias}/SCF_Validation  level=ERROR
        ...  AND  Fail  ${alias} BTS SCF validation operation failed

        Log  ${alias} BTS SCF validation customisable preconditions passed  console=True

    END

Entity Final Checks BTS
    [Documentation]
    ...  KW for entity final checks on clasical BTS. SCF for final checks can be provided in entity_scf_dict as input argument:
    ...  - as a dictionary with BTS entity alias as key and BTS entity scf path as value. For classical BTS, entity refers to BTS (ex. 'Master')
    ...  - if scf path is not provided for alias, initial SCF from Common Test Setup is used.
    ...
    ...  | Parameter          | Man. | Description                                                 |
    ...  | alias              | Yes  | BTS alias                                                   |
    ...  | ${entity_scf_dict} | No   | Dict containing structure: {'alias': 'entity_scf_path_file'}|
    ...
    [Arguments]  ${alias}  ${entity_scf_dict}=&{EMPTY}

    Log  ***** Check ${alias} configuration and runtime info alignment *****  console=True
    ${PostconditionBTSConf_check}=  Check Entity BTS Configuration  ${alias}  ${entity_scf_dict}
    Run Keyword If  ${PostconditionBTSConf_check}
    ...  Log  ${alias} configuration and runtime info alignment check is passed!  console=True
    ...  ELSE  Run Keywords
    ...  Log  ${alias} configuration and runtime info alignment is failed!  level=ERROR
    ...  AND  Fail  ${alias} configuration and runtime info alignment is failed!

    Log  ***** Check ${alias} cells status *****  console=True
    ${PostconditionCells_check}  ${BTS_redundancyRole}=  Check Entity Cells State  ${alias}
    Run Keyword If  ${PostconditionCells_check} and '${BTS_redundancyRole}' not in ['active','standby']
    ...  Log  ${alias} cells status check is passed!  console=True
    ...  ELSE IF  ${PostconditionCells_check} and '${BTS_redundancyRole}' in ['active','standby']
    ...  Log  ${alias} (redundancyRole=${BTS_redundancyRole}) cells status check is passed!  console=True
    ...  ELSE  Run Keywords
    ...  Log  ${alias} cells status check is failed!  level=ERROR
    ...  AND  Fail  ${alias} cells status check is failed!

    Log  ***** Check ${alias} RMs status *****  console=True
    ${PostconditionModules_check}=  Run Keyword  Check Entity RMs State  ${alias}
    Run Keyword If  ${PostconditionModules_check}
    ...  Log  ${alias} RMs status check is passed!  console=True
    ...  ELSE  Run Keywords
    ...  Log  ${alias} RMs status check is failed!  level=ERROR
    ...  AND  Fail  ${alias} RMs status check is failed!

Entity Final Checks CBTS
    [Documentation]
    ...  KW for entity final checks on cloud BTS. SCF for final checks can be provided in entity_scf_dict as input argument:
    ...  - as a dictionary with BTS entity alias as key and BTS entity scf path as value. For cloud BTS, entity refers to BTS CU and VDUs
    ...  (ex. 'Master CU', Master  VDU1)
    ...  - if scf path is not provided for alias, initial SCF from Common Test Setup is used.
    ...
    ...  | Parameter          | Man. | Description                                                 |
    ...  | alias              | Yes  | BTS alias                                                   |
    ...  | ${entity_scf_dict} | No   | Dict containing structure: {'alias': 'entity_scf_path_file'}|
    ...
    [Arguments]  ${alias}  ${entity_scf_dict}=&{EMPTY}

    Log  ***** Check ${alias} configuration and runtime info alignment *****  console=True
    ${PostconditionBTSConf}=  Check CBTS Configuration  ${alias}  ${entity_scf_dict}
    Run Keyword If  ${PostconditionBTSConf}
    ...  Log  ${alias} configuration and runtime info alignment check is passed!  console=True
    ...  ELSE  Run Keywords
    ...  Log  ${alias} configuration and runtime info alignment is failed!  level=ERROR
    ...  AND  Fail  ${alias} configuration and runtime info alignment is failed!

    Log  ***** Check ${alias} cells status *****  console=True
    ${PostconditionCells_check}=  Check CBTS Cells State  ${alias}
    Run Keyword If  ${PostconditionCells_check}
    ...  Log  ${alias} cells status check is passed!  console=True
    ...  ELSE  Run Keywords
    ...  Log  ${alias} cells status check is failed!  level=ERROR
    ...  AND  Fail  ${alias} cells status check is failed!

    Log  ***** Check ${alias} RMs status *****  console=True
    ${PostconditionModules_check}=  Run Keyword  Check CBTS RMODs State  ${alias}
    Run keyword If  ${PostconditionModules_check}
    ...  Log  ${alias} RMs status check is passed!  console=True
    ...  ELSE  Run Keywords
    ...  Log  ${alias} RMs status check is failed!  level=ERROR
    ...  AND  Fail  ${alias} RMs status check is failed!

Stop Execution If Stop on Fail occurred
    [Documentation]
    ...  KW stops execution if current test is FAIL and STOPONFAIL Tag is set, by raising Fatal error.
    ...  In that case, all subsequent tests will be set as failed
    ${msg1}=  Set Variable  Suite execution ended due to current test status FAIL and STOPONFAIL tag set in test-case.
    ${msg2}=  Set Variable  Following tests from suite will not be executed and marked as FAIL in robot report.
    ${exit_msg}=  Catenate  ${msg1}  ${msg2}
    Run Keyword If    '${TEST STATUS}'=='FAIL' and ('STOPONFAIL' in ${TEST TAGS})    Run Keywords
    ...  Log  ${exit_msg}  level=ERROR
    ...  AND  Fatal Error    Since STOPONFAIL tag is set and test is failed, will end test suite execution!

Get Initial test SBTS historical alarms
    [Arguments]  ${alias}

    Log  Getting Initial SBTS historical alarms for BTS ${alias}  console=True

    ${historic_alarms}=  coam.Get Historic Alarms  connection=${alias}  load_history=False  timeout=120
    Set Test Variable  @{previous_historic_alarms_list_${alias}}  @{EMPTY}
    Update Historic Alarms List  ${previous_historic_alarms_list_${alias}}  ${historic_alarms}
    Set Test Variable  ${previous_historic_alarms_list_${alias}}  ${historic_alarms}

Get Initial test CBTS historical alarms
    [Arguments]  ${alias}

    ${cu_alias}=  Set Variable  ${alias} CU

    Log  Getting Initial CBTS historical alarms for ${cu_alias}  console=True

    ${historic_alarms}=  cu.Get Historical Alarms  raw=True  connection=${cu_alias}
    ${historic_alarms}=  Get From Dictionary  ${historic_alarms}  alarms
    Set Test Variable  @{previous_historic_alarms_list_${cu_alias}}  @{EMPTY}
    Update Historic Alarms List  ${previous_historic_alarms_list_${cu_alias}}  ${historic_alarms}
    Set Test Variable  ${previous_historic_alarms_list_${cu_alias}}  ${historic_alarms}

    ${vdu_list}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_VDU]

    FOR  ${index}  ${vdu_info}  IN ENUMERATE  @{vdu_list}

        ${vdu_alias}=  Set Variable  ${alias} VDU${index+1}

        Log  Getting Initial CBTS historical alarms for ${vdu_alias}  console=True

        ${historic_alarms}=  Vdu Get Historical Alarms  raw=True  vdu_connection=${vdu_alias}
        ${historic_alarms}=  Get From Dictionary  ${historic_alarms}  alarms
        Set Test Variable  @{previous_historic_alarms_list_${vdu_alias}}  @{EMPTY}
        Update Historic Alarms List  ${previous_historic_alarms_list_${vdu_alias}}  ${historic_alarms}
        Set Test Variable  ${previous_historic_alarms_list_${vdu_alias}}  ${historic_alarms}

    END

NetAct Preconditions
    Run Keyword If  not ${NETACT_CHECK}  Run Keywords
    ...  Log  NetAct check skipped by user: NETACT_CHECK = False  console=True
    ...  AND  Return From Keyword

    ${netact_config_check}=  Run Keyword And Return Status  Variable Should Exist  ${NETACT}
    ${NETACK_keys}=  Run Keyword If  ${netact_config_check}
    ...  Get Dictionary Keys  ${NETACT}
    ...  ELSE  Create List

    Run Keyword If  ${NETACK_keys} == @{EMPTY}  Run Keywords
    ...  Log  NetAct preconditions skipped due to improper config: NetAct is not defined in __init__.py!  console=True
    ...  AND  Return From Keyword

    netact.Add Web URL  web_url=${NETACT['URL']}  username=${NETACT['HTTP_USERNAME']}  password=${NETACT['HTTP_PASSWORD']}  alias=Netact_node
    netact.Add Node  service_name=cmwas  hostname=${NETACT['IP']}  username=${NETACT['SSH_USERNAME']}  password=${NETACT['SSH_PASSWORD']}
    ...  alias=Netact_node

NetAct Postconditions
    Run Keyword If  not ${NETACT_CHECK}  Run Keywords
    ...  Log  NetAct check skipped by user: NETACT_CHECK = False  console=True
    ...  AND  Return From Keyword

    ${netact_config_check}=  Run Keyword And Return Status  Variable Should Exist  ${NETACT}
    ${NETACK_keys}=  Run Keyword If  ${netact_config_check}
    ...  Get Dictionary Keys  ${NETACT}
    ...  ELSE  Create List

    Run Keyword If  ${NETACK_keys} == @{EMPTY}  Run Keywords
    ...  Log  NetAct postconditions skipped due to improper config: NetAct is not defined in __init__.py!  console=True
    ...  AND  Return From Keyword

    netact.Delete Node  service_name=cmwas  alias=Netact_node
