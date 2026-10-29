*** Settings ***
Documentation
...   contact: Monika Ceglarek

Library     taf.ul.alarms_watchdog    WITH NAME    watchdog_vcu
Library     taf.ul.alarms_watchdog    WITH NAME    watchdog_vdu
Library     resources/create_init_file.py
Resource    ../../resources/ca_IWK.robot
Resource    ../../resources/cloud_bts.robot


*** Keywords ***
VDU Reset Test

    Set Tags    CA-RRM    AUTHOR-monika.ceglarek@nokia.com    MAINTAINER-monika.ceglarek@nokia.com
    ...         GROUP_IN_CHARGE-VRF_2_WRO_2

    Perfom Test In A Loop


Perfom Test In A Loop
    [Tags]  robot:continue-on-failure
    FOR  ${loop_index}  IN RANGE  1  ${ITERATIONS_NUMBER}+1
        Execute Test Loop  ${loop_index}
    END
    [Teardown]  Log Loops Summary


Execute Test Loop
    [Arguments]  ${loop_index}
    Log  \n=== LOOP ${loop_index} ===\n  console=True
    Set Test Variable  ${LOOP_INDEX}  ${loop_index}
    Set Test Variable  ${CURRENT_LOGS_PATH}  ${LOG_PATH}/Iteration_${LOOP_INDEX}
    VDU Reset Procedure
    [Teardown]  Verify Loop Result


VDU Reset Procedure
    Preconditions
    Perform VDU Reset
    Check BTS State After VDU Reset
    Wait For Unexpected Alarms
    [Teardown]  VDU Reset Teardown


Log Loops Summary
    ${pretty_statuses}=  Evaluate  pprint.pformat(${LOOP_RESULTS}, indent=4)  modules=pprint
    Log  ${pretty_statuses}


Verify Loop Result
    Remove Excessive Passing Logs
    Failed Loops Logging
    Update Consecutive Fails Counter


Failed Loops Logging
    Set To Dictionary  ${LOOP_RESULTS}  ${LOOP_INDEX}  ${KEYWORD_STATUS}
    IF  '${KEYWORD_STATUS}' == 'FAIL'  Log  ${KEYWORD_MESSAGE}  console=True  level=ERROR
    Log  \n====== ITERATION ${LOOP_INDEX} RESULT: ${KEYWORD_STATUS} ======\n  console=True


Remove Excessive Passing Logs
    IF  '${KEYWORD_STATUS}' == 'PASS' and ${PASS_LOGS_COLLECTED}  Remove Current Iteration Logs
    IF  '${KEYWORD_STATUS}' == 'PASS' and not ${PASS_LOGS_COLLECTED}  Set Test Variable  ${PASS_LOGS_COLLECTED}  True


Update Consecutive Fails Counter
    IF  '${KEYWORD_STATUS}' == 'PASS'
        Set Test Variable  ${FAIL_COUNTER}  ${0}
    ELSE
        ${fail_counter} =  Evaluate  ${FAIL_COUNTER} + 1
        Set Test Variable  ${FAIL_COUNTER}  ${fail_counter}
    END
    IF  ${FAIL_COUNTER} >=3 and ${STOP_AFTER_CONSECUTIVE_FAILS}
        Fatal Error  msg=Multiple consecutive failures during execution.
    END


Remove Current Iteration Logs
    OperatingSystem.Remove Directory  ${CURRENT_LOGS_PATH}  recursive=True


Preconditions
    Log  \n--- Preconditions ---  console=True

    Create Directory  ${CURRENT_LOGS_PATH}
    Start Default Syslog For ENb And Iphy AIC  logs_dirpath=${CURRENT_LOGS_PATH}/Syslog
    Check BTS Sate Outside Of Test
    Preapare Alarms


Preapare Alarms
    Log  Start watching alarms.  console=True

    Start Watching Alarms
    Add Alarms Expected During Vdu Reset


Perform VDU Reset
    Log  \n--- Perform VDU Reset ---  console=True

    Connect To VDU
    Log  Performing vDU reset...  console=True
    Reset VDU  graceful_cell_shutdown=${CELL_GRACEFUL_SHUTDOWN}
    Log  vDU reset finished.  console=True


Check BTS State After VDU Reset
    Log  \n--- Check BTS State After VDU Reset ---  console=True

    Wait For VDU To Lose Connection
    Log  Waiting for ${REACH_ONAIR_TIMEOUT}s for BTS to go on air...  console=True
    Wait Until Keyword Succeeds  ${REACH_ONAIR_TIMEOUT}  10s
    ...  Check If BTS Is On Air  ${ALLOWED_ALARMS_VCU}  ${ALLOWED_ALARMS_VDU}
    Log  BTS state check finished.  console=True


VDU Reset Teardown
    Run Keyword And Ignore Error  vdu.Disconnect
    Run Keyword If  ${ADDITIONAL_ALARMS}  Remove Alarms Expected During Vdu Reset
    IF  not (${ALARMS_WATCHED_VCU} and ${ALARMS_WATCHED_VDU})  Set Test Variable  ${CRITICAL_ALARMS_DETECTED}  False
    Stop Watching VCU Alarms
    Stop Watching VDU Alarms
    Collect Logs
    Run Keyword If  ${CRITICAL_ALARMS_DETECTED}  Fatal Error  msg=Critical alarm(s) detected.


Add Alarms Expected During Vdu Reset
    Set Test Variable  ${ADDITIONAL_ALARMS}  True
    watchdog_vcu.Allow Alarm  alarm_id=7114  fault_id=7104
    watchdog_vdu.Allow Alarm  alarm_id=7115  fault_id=4592


Wait For VDU To Lose Connection
    Log  Waiting for vDU to lose connection...  console=True
    Wait Until Keyword Succeeds  ${LOSE_OF_CONNECTION_TIMEOUT}s  1s  Ping  False


Check If BTS Is On Air
    [Arguments]  ${allowed_alarms_vcu}  ${allowed_alarms_vdu}
    Ping  True
    Verify BTS States For Cloud BTS  ${allowed_alarms_vcu}  ${allowed_alarms_vdu}


Ping
    [Arguments]  ${connection_active}
    ${result} =  Run Process  ping -c 1 ${VDU_OAM_CONNECTION.addr}  shell=True
    IF  ${connection_active}
        Should Contain  ${result.stdout}  64 bytes from ${VDU_OAM_CONNECTION.addr}
    ELSE
        Should Not Contain  ${result.stdout}  64 bytes from ${VDU_OAM_CONNECTION.addr}
    END


Remove Alarms Expected During Vdu Reset
    watchdog_vcu.Disallow Alarm  alarm_id=7114  fault_id=7104
    watchdog_vdu.Disallow Alarm  alarm_id=7115  fault_id=4592
    Set Test Variable  ${ADDITIONAL_ALARMS}  False


Wait For Unexpected Alarms
    Log  \n--- Wait For Unexpected Alarms ---  console=True

    Remove Alarms Expected During Vdu Reset
    Log  Waiting for ${ALARM_TIMEOUT}s for unexpected alarms.  console=True
    Sleep  ${ALARM_TIMEOUT}s  reason=Waiting for unexpecetd alarms.


Collect Logs
    Log  \n--- Collect Logs ---  console=True

    Create Snapshot Directories
    Log  Collecting snapshot for vCU...  console=True
    Connect To VCU
    vcu.Get Local Snapshot  directory=${CURRENT_LOGS_PATH}/snapshot/vCU  operation_timeout=1500.0
    Log  Collecting snapshot for vDU...  console=True
    Connect To VDU
    vdu.Get Local Snapshot  directory=${CURRENT_LOGS_PATH}/snapshot/vDU  compressed_or_not=True
    ...  operation_timeout=1500.0

    Log  Collecting syslog...  console=True
    Stop Default Syslog For ENb And Iphy AIC  logs_dirpath=${CURRENT_LOGS_PATH}/Syslog

    [Teardown]  Run Keywords  Run Keyword And Ignore Error  vcu.Disconnect
    ...  AND  Run Keyword And Ignore Error  vdu.Disconnect


Create Main Log Directory
    ${timestamp}  OperatingSystem.Run  date +%F_%H-%M-%S
    ${LOG_PATH}   OperatingSystem.Join Path  ${OUTPUT DIR}  ${timestamp}_${TEST NAME}
    Create Directory  ${LOG_PATH}
    Set Test Variable  ${LOG_PATH}


Create Snapshot Directories
    Create Directory  ${CURRENT_LOGS_PATH}/snapshot
    Create Directory  ${CURRENT_LOGS_PATH}/snapshot/vCU
    Create Directory  ${CURRENT_LOGS_PATH}/snapshot/vDU


Check BTS State Outside Of Test And Collect Logs
    Log  \nCheck BTS state and collect logs.  console=True

    Start Default Syslog For ENb And Iphy AIC  logs_dirpath=${CURRENT_LOGS_PATH}/Syslog
    Check BTS Sate Outside Of Test
    [Teardown]  Collect Logs


Check BTS Sate Outside Of Test
    Start Watching Alarms
    Log  Checking BTS state...  console=True
    Verify BTS States For Cloud BTS  ${ALLOWED_ALARMS_VCU}  ${ALLOWED_ALARMS_VDU}
    [Teardown]  Run Keywords  Stop Watching VCU Alarms
    ...  AND  Stop Watching VDU Alarms
    ...  AND  Run Keyword If  ${CRITICAL_ALARMS_DETECTED}  Fatal Error  msg=Critical alarm(s) detected.


Prepare Allowed Alarms
    ${allowed_alarms_vcu_list} =  _prepare alarms helper  ${ALLOWED_ALARMS_VCU}
    ${allowed_alarms_vdu_list} =  _prepare alarms helper  ${ALLOWED_ALARMS_VDU}
    Set Test Variable  ${ALLOWED_ALARMS_VCU}  ${allowed_alarms_vcu_list}
    Set Test Variable  ${ALLOWED_ALARMS_VDU}  ${allowed_alarms_vdu_list}
    ${watchdog_vcu_alarms_list} =  _prepare allowed alarms for watchdog helper  ${ALLOWED_ALARMS_VCU}  vcu
    ${watchdog_vdu_alarms_list} =  _prepare allowed alarms for watchdog helper  ${ALLOWED_ALARMS_VDU}  vdu
    Set Test Variable  ${WATCHDOG_VCU_ALARMS_LIST}  ${watchdog_vcu_alarms_list}
    Set Test Variable  ${WATCHDOG_VDU_ALARMS_LIST}  ${watchdog_vdu_alarms_list}


_prepare alarms helper
    [Arguments]  ${alarms}
    ${empty_list} =  Run Keyword And Return Status  Should Be Empty  ${alarms}
    Return From Keyword If  ${empty_list}  ${alarms}
    IF  type(${alarms[0]}) is not dict
        ${alarms_list} =  Create List
        FOR  ${alarm}  IN  @{alarms}
            &{alarm_dict} =  Create Dictionary  fault_id=${alarm}
            Append To List  ${alarms_list}  ${alarm_dict}
        END
    ELSE
        ${alarms_list} =  Set Variable  ${alarms}
    END
    [Return]  ${alarms_list}


_prepare allowed alarms for watchdog helper
    [Arguments]  ${alarm_list}  ${element}
    ${watchdog_alarms_list} =  Create List
    FOR  ${alarm}  IN  @{alarm_list}
        IF  '${element}' == 'vcu'
            ${alarm} =  watchdog_vcu.Create Alarm  &{alarm}
        ELSE
            ${alarm} =  watchdog_vdu.Create Alarm  &{alarm}
        END
        Append To List  ${watchdog_alarms_list}  ${alarm}
    END
    [Return]  ${watchdog_alarms_list}


Prepare Critical Alarms
    ${critical_alarms_vcu_list} =  _prepare alarms helper  ${CRITICAL_ALARMS_VCU}
    ${critical_alarms_vdu_list} =  _prepare alarms helper  ${CRITICAL_ALARMS_VDU}
    Set Test Variable  ${CRITICAL_ALARMS_VCU}  ${critical_alarms_vcu_list}
    Set Test Variable  ${CRITICAL_ALARMS_VDU}  ${critical_alarms_vdu_list}
    _prepare critical alarms for watchdog helper  ${CRITICAL_ALARMS_VCU}  vcu
    _prepare critical alarms for watchdog helper  ${CRITICAL_ALARMS_VDU}  vdu


_prepare critical alarms for watchdog helper
    [Arguments]  ${alarm_list}  ${element}
    FOR  ${alarm}  IN  @{alarm_list}
        IF  '${element}' == 'vcu'
            watchdog_vcu.Disallow Alarm  &{alarm}
        ELSE
            watchdog_vdu.Disallow Alarm  &{alarm}
        END
    END


Start Watching Alarms
    Create Directory  ${CURRENT_LOGS_PATH}/watchdog
    Create Directory  ${CURRENT_LOGS_PATH}/watchdog/vcu
    Create Directory  ${CURRENT_LOGS_PATH}/watchdog/vdu
    Set Test Variable  ${CRITICAL_ALARMS_DETECTED}  False
    Set Test Variable  ${ALARMS_WATCHED_VCU}  True
    watchdog_vcu.Watch Alarms  allowed_alarms=${WATCHDOG_VCU_ALARMS_LIST}  log_dir=${CURRENT_LOGS_PATH}/watchdog/vcu
    ...  bts_config=${tl.gnbs[0]}  cu_id=${0}
    Set Test Variable  ${ALARMS_WATCHED_VDU}  True
    watchdog_vdu.Watch Alarms  allowed_alarms=${WATCHDOG_VDU_ALARMS_LIST}  log_dir=${CURRENT_LOGS_PATH}/watchdog/vdu
    ...  bts_config=${tl.gnbs[0]}  du_id=${0}


Stop Watching VCU Alarms
    Return From Keyword If  not ${ALARMS_WATCHED_VCU}
    Check If Critical Alarms Appeared  ${CRITICAL_ALARMS_VCU}  vcu
    watchdog_vcu.Check Detected Alarms
    watchdog_vcu.Stop Watching Alarms
    Set Test Variable  ${ALARMS_WATCHED_VCU}  False
    Log  vCU alarms check finished.  console=True


Stop Watching VDU Alarms
    Return From Keyword If  not ${ALARMS_WATCHED_VDU}
    Check If Critical Alarms Appeared  ${CRITICAL_ALARMS_VDU}  vdu
    watchdog_vdu.Check Detected Alarms
    watchdog_vdu.Stop Watching Alarms
    Set Test Variable  ${ALARMS_WATCHED_VDU}  False
    Log  vDU alarms check finished.  console=True


Check If Critical Alarms Appeared
    [Arguments]  ${alarm_list}  ${element}
    ${any_alarm_detected} =  Set Variable  False
    ${detected_alarms} =  Create List
    FOR  ${alarm}  IN    @{alarm_list}
        IF  '${element}' == 'vcu'
            ${alarm_detected} =  watchdog_vcu.Was Alarm Detected  &{alarm}
        ELSE
            ${alarm_detected} =  watchdog_vdu.Was Alarm Detected  &{alarm}
        END
        Run Keyword And Return If  ${alarm_detected}  Set Test Variable  ${CRITICAL_ALARMS_DETECTED}  True
    END


Create Global Variables
    [Arguments]  ${iterations_number}  ${allowed_alarms_vcu}  ${allowed_alarms_vdu}  ${critical_alarms_vcu}
    ...  ${critical_alarms_vdu}  ${cu_oam_version_vcu}  ${cu_oam_version_vdu}  ${reach_onair_timeout}
    ...  ${alarm_timeout}  ${lose_of_connection_timeout}  ${stop_after_consecutive_fails}  ${cell_graceful_shutdown}

    Set Test Variable  ${PASS_LOGS_COLLECTED}  False
    Set Test Variable  ${ADDITIONAL_ALARMS}  False
    Set Test Variable  ${ALARMS_WATCHED_VCU}  False
    Set Test Variable  ${ALARMS_WATCHED_VDU}  False
    Set Test Variable  ${CRITICAL_ALARMS_DETECTED}  False
    Set Test Variable  ${ITERATIONS_NUMBER}  ${iterations_number}
    Set Test Variable  ${VCU_OAM_CONNECTION}  ${tl.gnbs[0].cu.oam_http_connection_details}
    Set Test Variable  ${VDU_OAM_CONNECTION}  ${tl.gnbs[0].dus[0].oam_http_connection_details}
    Set Test Variable  ${ALLOWED_ALARMS_VCU}  ${allowed_alarms_vcu}
    Set Test Variable  ${ALLOWED_ALARMS_VDU}  ${allowed_alarms_vdu}
    Set Test Variable  ${CRITICAL_ALARMS_VCU}  ${critical_alarms_vcu}
    Set Test Variable  ${CRITICAL_ALARMS_VDU}  ${critical_alarms_vdu}
    Set Test Variable  ${CU_OAM_VERSION_VCU}  ${cu_oam_version_vcu}
    Set Test Variable  ${CU_OAM_VERSION_VDU}  ${cu_oam_version_vdu}
    Set Test Variable  ${REACH_ONAIR_TIMEOUT}  ${reach_onair_timeout}
    Set Test Variable  ${ALARM_TIMEOUT}  ${alarm_timeout}
    Set Test Variable  ${LOSE_OF_CONNECTION_TIMEOUT}  ${lose_of_connection_timeout}
    Set Test Variable  ${STOP_AFTER_CONSECUTIVE_FAILS}  ${stop_after_consecutive_fails}
    Set Test Variable  ${CELL_GRACEFUL_SHUTDOWN}  ${cell_graceful_shutdown}
    Set Test Variable  ${FAIL_COUNTER}  ${0}
    ${loops_results} =  Create Dictionary
    Set Test Variable  ${LOOP_RESULTS}  ${loops_results}


TC Setup
    [Documentation]
    ...  This KW should be used to setup 'VDU Reset Test'.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  **Full Description:**
    ...
    ...  This KW should be used to setup 'VDU Reset Test'. It creates global test variables, prepares allowed
    ...  and critical alarms, creates main logs directory  and sets path for it in ${CURRENT_LOGS_PATH} test variable,
    ...  gets and prints vDU SW version, checks BTS state and alarms before test. Path to logs for checking BTS state
    ...  for 'TC Setup' keyword ${LOG_PATH}/Test_Setup.
    ...  List of test variables set inside this KW:
    ...    - ${PASS_LOGS_COLLECTED} - Boolean value defining if pass logs should be collected, it is used to only collect
    ...      logs from first passed and failed executions (set by test).
    ...    - ${ADDITIONAL_ALARMS} - Boolean value defining if additional alarms set during test to be allowed
    ...      during vDU reset operation are currently added to allowed alarms list (set by test).
    ...    - ${ALARMS_WATCHED_VCU} - Boolean value defining if alarms on vCU are currently being watched (set by test).
    ...      during vDU reset operation are currently added to allowed alarms list (set by test).
    ...    - ${ALARMS_WATCHED_VDU} - Boolean value defining if alarms on vDU are currently being watched (set by test).
    ...    - ${CRITICAL_ALARMS_DETECTED} - Boolean value defining if any critical alarms were detected (set by test).
    ...    - ${ITERATIONS_NUMBER} - Integer value defining number of iterations for test (set by user).
    ...    - ${VCU_OAM_CONNECTION} - vCU HTTP connection details of gnbs object. Vaule is taken form __init__.py
    ...      ${tl.gnbs[0].cu.oam_http_connection_details} (set by test).
    ...    - ${VDU_OAM_CONNECTION} - vDU HTTP connection details of gnbs object. Vaule is taken form __init__.py
    ...      ${tl.gnbs[0].dus[0].oam_http_connection_details} (set by test).
    ...    - ${ALLOWED_ALARMS_VCU} - List of integers (fault IDs) or dictionary (defined in taf.ul.alarms_watchdog library
    ...      for 'Create Alarm' keyword). Variable contains allowed alarm data for vCU (set by user).
    ...    - ${ALLOWED_ALARMS_VDU} - List of integers (fault IDs) or dictionary (defined in taf.ul.alarms_watchdog library
    ...      for 'Create Alarm' keyword). Variable contains allowed alarm data for vDU (set by user).
    ...    - ${CRITICAL_ALARMS_VCU} - List of integers (fault IDs) or dictionary (defined in taf.ul.alarms_watchdog library
    ...      for 'Create Alarm' keyword). Variable contains critical alarm data for vCU (set by user).
    ...    - ${CRITICAL_ALARMS_VDU} - List of integers (fault IDs) or dictionary (defined in taf.ul.alarms_watchdog library
    ...      for 'Create Alarm' keyword). Variable contains critical alarm data for vDU (set by user).
    ...    - ${CU_OAM_VERSION_VCU} - String containing vCU version. As described in 'Connect To' KW from taf.gnb.oam.coam.vdu.
    ...    - ${CU_OAM_VERSION_VDU} - String containing vDU version. As described in 'Connect To' KW from taf.gnb.oam.coam.cu.
    ...    - ${REACH_ONAIR_TIMEOUT} - Integer value defining time in seconds for waiting for BTS to go on air after
    ...      vDU reset (set by user).
    ...    - ${ALARM_TIMEOUT} - Integer value defining time in seconds for waiting for unexpected alarms after
    ...      vDU reset and reaching onAir (set by user).
    ...    - ${LOSE_OF_CONNECTION_TIMEOUT} - Integer value defining time in seconds for waiting for BTS to lose
    ...       connection after vDU reset (set by user).
    ...    - ${STOP_AFTER_CONSECUTIVE_FAILS} - Boolean value defining if execution should be stopped in case of
    ...      consecutive fails.
    ...    - ${FAIL_COUNTER} - Integer value used for counting failed loops (set by test).
    ...    - ${LOOP_RESULTS} - Dictionary containing iteration numbers as keys and iteration results as values (set by test).
    ...    - ${CURRENT_LOGS_PATH} - String value containing current path to logs directory (set by test).
    ...      Set as ${LOG_PATH}/Test_Setup by this KW (path changes during iterations to ${LOG_PATH}/Iteration_${LOOP_INDEX},
    ...      where ${LOOP_INDEX} is number of current iteration set by 'Execute Test' KW, and during teardown
    ...      to ${LOG_PATH}/Test_Teardown).
    ...    - ${LOG_PATH} - String value containing absolute path to main log directory (set by test). Value is created
    ...      as ${OUTPUT DIR}/${timestamp}_${TEST NAME}, where timestamp is date in +%F_%H-%M-%S format.
    ...
    ...  **Input Parameters:**
    ...
    ...  +-------------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter                     | Man. | Description                                                           |
    ...  +===============================+======+=======================================================================+
    ...  | iterations_number             | Yes  | Number of iterations.                                                 |
    ...  +-------------------------------+------+-----------------------------------------------------------------------+
    ...  | allowed_alarms_vcu            | Yes  | List of allowed alarms for vCU.                                       |
    ...  +-------------------------------+------+-----------------------------------------------------------------------+
    ...  | allowed_alarms_vdu            | Yes  | List of allowed alarms for vDU.                                       |
    ...  +-------------------------------+------+-----------------------------------------------------------------------+
    ...  | critical_alarms_vcu           | Yes  | List of disallowed alarms for vCU.                                    |
    ...  +-------------------------------+------+-----------------------------------------------------------------------+
    ...  | critical_alarms_vdu           | Yes  | List of disallowed alarms for vDU.                                    |
    ...  +-------------------------------+------+-----------------------------------------------------------------------+
    ...  | cu_oam_version_vcu            | Yes  | vCU version.                                                          |
    ...  +-------------------------------+------+-----------------------------------------------------------------------+
    ...  | cu_oam_version_vdu            | Yes  | vDU version.                                                          |
    ...  +-------------------------------+------+-----------------------------------------------------------------------+
    ...  | reach_onair_timeout           | No   | Time in seconds for waiting for BTS to go on air after                |
    ...  |                               |      | vDU reset. Default value: 900.                                        |
    ...  +-------------------------------+------+-----------------------------------------------------------------------+
    ...  | alarm_timeout                 | No   | Time in seconds for waiting for unexpected alarms after               |
    ...  |                               |      | vDU reset and reaching onAir. Default value: 120.                     |
    ...  +-------------------------------+------+-----------------------------------------------------------------------+
    ...  | lose_of_connection_timeout    | No   | Time in seconds for waiting for BTS to lose connection after          |
    ...  |                               |      | vDU reset. Default value: 150.                                        |
    ...  +-------------------------------+------+-----------------------------------------------------------------------+
    ...  | stop_after_consecutive_fails  | No   | Stops execution after 3 consecutive fails. The counter                |
    ...  |                               |      | goes back to 0 if iteration passes. Default value: False.             |
    ...  +-------------------------------+------+-----------------------------------------------------------------------+
    ...  | cell_graceful_shutdown        | No   | Boolean value defining if graceful cell shutdown will be performed    |
    ...  |                               |      | during vDU reset (True) or not (False). Default value: False.         |
    ...  +-------------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     VDU Reset Test
    ...     [Timeout]  100h
    ...     [Setup]  TC Setup
    ...     ...  iterations_number=100
    ...     ...  allowed_alarms_vcu=@{EMPTY}
    ...     ...  allowed_alarms_vdu=@{EMPTY}
    ...     ...  critical_alarms_vcu=@{EMPTY}
    ...     ...  critical_alarms_vdu=@{EMPTY}
    ...     ...  cu_oam_version_vcu=cuoam_25r1
    ...     ...  cu_oam_version_vdu=cuoam_25r1
    ...     ...  reach_onair_timeout=300
    ...     ...  alarm_timeout=200
    ...     ...  lose_of_connection_timeout=100
    ...     ...  stop_after_consecutive_fails=True
    ...     VDU Reset Test
    ...     [Teardown]  TC Teardown

    [Arguments]  ${iterations_number}  ${allowed_alarms_vcu}  ${allowed_alarms_vdu}  ${critical_alarms_vcu}
    ...  ${critical_alarms_vdu}  ${cu_oam_version_vcu}  ${cu_oam_version_vdu}  ${reach_onair_timeout}=900
    ...  ${alarm_timeout}=120  ${lose_of_connection_timeout}=150  ${stop_after_consecutive_fails}=False
    ...  ${cell_graceful_shutdown}=False

    Create Global Variables  ${iterations_number}  ${allowed_alarms_vcu}  ${allowed_alarms_vdu}  ${critical_alarms_vcu}
    ...  ${critical_alarms_vdu}  ${cu_oam_version_vcu}  ${cu_oam_version_vdu}  ${reach_onair_timeout}
    ...  ${alarm_timeout}  ${lose_of_connection_timeout}  ${stop_after_consecutive_fails}  ${cell_graceful_shutdown}
    Prepare Allowed Alarms
    Prepare Critical Alarms
    Create Main Log Directory
    Set Test Variable  ${CURRENT_LOGS_PATH}  ${LOG_PATH}/Test_Setup
    Get VDU Software Version
    Check BTS State Outside Of Test And Collect Logs


TC Teardown
    [Timeout]  60 min
    Log  \n === TC Teardown ===   console=True

    Set Test Variable  ${CURRENT_LOGS_PATH}  ${LOG_PATH}/Test_Teardown
    Check BTS State Outside Of Test And Collect Logs
