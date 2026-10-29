*** Settings ***
Documentation
...   contact: Monika Ceglarek

Library    taf.sw.dcap.rd
Library    testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.dcap.dcap_manager.DCAPManager  WITH NAME  utf_manager


*** Keywords ***
Start Collecting Logs With UTF
    [Documentation]
    ...  Starts collecting logs with UTF.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | This KW starts collecting logs with UTF. Logs collected on HO TL depend on 'target_rat'.
    ...  | For NR: bts_custom_profiles=ipCapture, gnb_custom_profile=cp_5g, monitoring_profiles=5g-full-call-scenarios.
    ...  | For LTE: bts_custom_profiles=ipCapture, enb_custom_profile=cp_4g, monitoring_profiles=lte-full-call-scenarios.
    ...  | For main TL logs are always the same: bts_custom_profiles=ipCapture, gnb_custom_profile=cp_5g,
    ...  | monitoring_profiles=5g-full-call-scenarios.
    ...  | This KW requires following test variables to be created before running it:
    ...  | -${TARGET_SMOD_SERIAL_NUMBER} - Serial number of target SMOD.
    ...  | -${MAX_UTF_LOGS_DELAY} - Max time in seconds needed for change of UTF logs collecting status to 'running'.
    ...  | -${DCAP_HOST} - Dictionary with data for connecting to UTF. It should contain following keys:
    ...  |  ip, port, login, password.
    ...  | This KW creates or sets following test variables:
    ...  | -${MAIN_TRACE_ID} - ID of traces started on main TL.
    ...  | -${HO_TRACE_ID} - ID of traces started on HO TL
    ...  | -${UTF_STARTED} - boolean value indicating that UTF logs collection is started. Can be used for conditional
    ...  |  stopping in teardown.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------------+------+----------------------------------------------------------------------+
    ...  | Parameter            | Man. | Description                                                          |
    ...  +======================+======+======================================================================+
    ...  | source_cell_id       | Yes  | ID of source cell.                                                   |
    ...  +----------------------+------+----------------------------------------------------------------------+
    ...  | target_cell_id       | Yes  | ID of target cell.                                                   |
    ...  +----------------------+------+----------------------------------------------------------------------+
    ...  | target_rat           | Yes  | Target RAT. Possible values: 'NR', 'LTE'.                            |
    ...  +----------------------+------+----------------------------------------------------------------------+
    ...  | source_bts_id        | Yes  | BTS ID of source BTS.                                                |
    ...  +----------------------+------+----------------------------------------------------------------------+
    ...  | target_bts_id        | Yes  | BTS ID of target BTS.                                                |
    ...  +----------------------+------+----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Multiple BTS Test Setup
    ...     Start Collecting Logs With UTF  source_cell_id=12345
    ...     ...  target_cell_id=67890  target_rat=NR  source_bts_id=11111  target_bts_id=22222
    ...     Sleep    300s
    ...     Stop UTF Traces and Download Logs
    ...     ...  main_trace_id=${MAIN_TRACE_ID}  ho_trace_id=${HO_TRACE_ID}  source_bts_id=11111  target_bts_id=22222
    ...     Multiple BTS Test Teardown

    [Arguments]  ${source_cell_id}  ${target_cell_id}  ${target_rat}  ${source_bts_id}  ${target_bts_id}

    ${bts_log_profile} =  Create List  ipCapture

    ${nr_cell_list} =  Create List  ${source_cell_id}
    ${nr_log_profile} =  Create List  cp_5g
    ${main_profiles_dictionary} =  Create Dictionary  bts_custom_profile=${bts_log_profile}  gnb_custom_profile=${nr_log_profile}
    ...  monitoring_profiles=5g-full-call-scenarios

    ${target_cell_list} =  Create List  ${target_cell_id}
    ${target_log_profile} =  Run Keyword If  '${target_rat}' == 'NR'  Create List  cp_5g
    ...  ELSE IF                             '${target_rat}' == 'LTE'  Create List  cp_4g
    ${ho_profiles_dictionary} =  Run Keyword If  '${target_rat}' == 'NR'
    ...  Create Dictionary  bts_custom_profile=${bts_log_profile}  gnb_custom_profile=${target_log_profile}
    ...  monitoring_profiles=5g-full-call-scenarios
    ...  ELSE IF                                 '${target_rat}' == 'LTE'
    ...  Create Dictionary  bts_custom_profile=${bts_log_profile}  enb_custom_profile=${target_log_profile}
    ...  monitoring_profiles=lte-full-call-scenarios

    Add Allowed Alarms For IP Capturing

    _start utf helper  ${nr_cell_list}  ${target_cell_list}  ${main_profiles_dictionary}
    ...  ${ho_profiles_dictionary}  ${target_rat}
    Log  Waiting for traces to change status to 'Running'  console=True
    Wait Until Keyword Succeeds  ${MAX_UTF_LOGS_DELAY}  5s  Check If Traces Are Running  ${MAIN_TRACE_ID}  ${HO_TRACE_ID}

    [Teardown]  Run Keyword If  '${KEYWORD_STATUS}' == 'FAIL'  Run Keywords
    ...  Log  Start UTF failed. Please check logs for details.  console=True  level=WARN
    ...  AND  Run Keyword If  ${UTF_STARTED}  Stop UTF Traces and Download Logs  main_trace_id=${MAIN_TRACE_ID}
    ...  ho_trace_id=${HO_TRACE_ID}  source_bts_id=${source_bts_id}  target_bts_id=${target_bts_id}


_start utf helper
    [Arguments]  ${nr_cell_list}  ${target_cell_list}  ${main_profiles_dictionary}  ${ho_profiles_dictionary}  ${target_rat}
    ...  ${user}=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...  ${password}=${tl.gnbs[0].cu.oam_http_connection_details.password}

    Log  Connecting to UTF server IP=${DCAP_HOST['ip']} on port=${DCAP_HOST['port']}  console=True
    utf_manager.Connect To  host=${DCAP_HOST['ip']}  port=${DCAP_HOST['port']}
    ...  user=${DCAP_HOST['login']}  passwd=${DCAP_HOST['password']}

    ${main_mplane} =  Set Variable  ${main_bts['mplane_ip']}
    Log  Using profiles:\n${main_profiles_dictionary}.\nStarting new trace for IP ${main_mplane}...  console=True
    Set Test Variable  ${UTF_STARTED}  True

    ${trace_id} =  utf_manager.Start New Trace  mplane=${main_mplane}  user=${user}  passwd=${password}
    ...  port=443  nr_cells=${nr_cell_list}  log_profile=${main_profiles_dictionary}
    Set Test Variable  ${MAIN_TRACE_ID}  ${trace_id}


    ${ho_target_mplane} =  Set Variable  ${all_bts_data['${TARGET_SMOD_SERIAL_NUMBER}']['mplane_ip']}
    Log  Using profiles:\n${ho_profiles_dictionary}.\nStarting new trace for IP ${ho_target_mplane}...  console=True

    ${trace_id} =  Run Keyword If  '${target_rat}' == 'NR'  utf_manager.Start New Trace
    ...  mplane=${ho_target_mplane}  user=${user}  passwd=${password}  port=443  nr_cells=${target_cell_list}
    ...  log_profile=${ho_profiles_dictionary}
    ...  ELSE IF                   '${target_rat}' == 'LTE'  utf_manager.Start New Trace
    ...  mplane=${ho_target_mplane}  user=${user}  passwd=${password}  port=443  lte_cells=${target_cell_list}
    ...  log_profile=${ho_profiles_dictionary}

    Set Test Variable  ${HO_TRACE_ID}  ${trace_id}

    [Teardown]  Run Keyword If  '${KEYWORD_STATUS}' == 'FAIL'  Run Keywords
    ...  utf_manager.Stop Trace  trace=${MAIN_TRACE_ID}
    ...  AND  utf_manager.Stop Trace  trace=${HO_TRACE_ID}
    ...  AND  utf_manager.Teardown
    ...  AND  Set Test Variable  ${UTF_STARTED}  False


Check If Traces Are Running
    [Documentation]
    ...  Checks if traces started with UTF are running for both main and HO TLs.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | Checks if traces started with UTF are running for both main and HO TLs.
    ...  | This KW will pass if traces status is 'running' or 'runningWithWarnings'.
    ...  | In case of status 'runningWithWarnings' warning will be printed.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------------+------+----------------------------------------------------------------------+
    ...  | Parameter            | Man. | Description                                                          |
    ...  +======================+======+======================================================================+
    ...  | main_trace_id        | Yes  | ID of traces started with UTF on source (main) TL.                   |
    ...  +----------------------+------+----------------------------------------------------------------------+
    ...  | ho_trace_id          | Yes  | ID of traces started with UTF on target (HO) TL.                     |
    ...  +----------------------+------+----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Multiple BTS Test Setup
    ...     Start Collecting Logs With UTF  source_cell_id=12345
    ...     ...  target_cell_id=67890  target_rat=NR  source_bts_id=11111  target_bts_id=22222
    ...     Check If Traces Are Running  ${MAIN_TRACE_ID}  ${HO_TRACE_ID}
    ...     Stop UTF Traces and Download Logs
    ...     ...  main_trace_id=${MAIN_TRACE_ID}  ho_trace_id=${HO_TRACE_ID}  source_bts_id=11111  target_bts_id=22222
    ...     Multiple BTS Test Teardown

    [Arguments]  ${main_trace_id}  ${ho_trace_id}

    ${main_trace_status} =  Get Trace Info By ID  trace_id=${main_trace_id}  connection=dcap_collector
    ${ho_trace_status} =  Get Trace Info By ID  trace_id=${ho_trace_id}  connection=dcap_collector
    ${main_status} =  Set Variable  ${main_trace_status['status']}
    ${ho_status} =  Set Variable  ${ho_trace_status['status']}
    ${msg} =  Catenate  Some logs were started with warnings and may not be collected.
    ...                 Please check UTF logs for more information.\n
    ...                 Main TL traces status: ${main_status}\n
    ...                 HO TL traces status: ${ho_status}

    Run Keyword If  '${main_status}' == 'runningWithWarnings' or '${ho_status}' == 'runningWithWarnings'
    ...  Log  ${msg}  console=True  level=WARN
    Should Be True  '${main_status}' == 'running' or '${main_status}' == 'runningWithWarnings'
    ...  msg=Main TL trace status is ${main_status}. Should be: 'running' or 'runningWithWarnings'.
    Log  Main trace status ${main_status}. Checking HO TL trace status...  console=True

    Should Be True  '${ho_status}' == 'running' or '${ho_status}' == 'runningWithWarnings'
    ...  msg=Main trace status is ${ho_status}. Should be: 'running' or 'runningWithWarnings'.
    Log  HO TL trace status ${ho_status}.  console=True


Add Allowed Alarms For IP Capturing
    Add Allowed Alarm  faultId=61641  alias=main
    Add Allowed Alarm  faultId=61641  alias=${TARGET_SMOD_SERIAL_NUMBER}
    alarms_watchdog_main.Allow Alarm  fault_id=61641
    alarms_watchdog_ho.Allow Alarm  fault_id=61641


Disallow Alarms For Watchdog
    alarms_watchdog_main.Disallow Alarm  fault_id=61641
    alarms_watchdog_ho.Disallow Alarm  fault_id=61641


Stop UTF Traces and Download Logs
    [Documentation]
    ...  Stops and downloads logs collected with UTF.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | This KW stops and downloads logs collected with UTF. Download directory for main TL is
    ...  | ${LOG_PATH}/utf_logs/BTS_${source_bts_id} and for HO TL ${LOG_PATH}/utf_logs/BTS_${target_bts_id}.
    ...  | Downloaded logs will be in zip archive similarly to when one collects them manually with UTF.
    ...  | This KW also checks trace status after stopping and downloadind in case either main or HO TL's
    ...  | trace status is different than 'ready' a warning will be printed.
    ...  | In case IP capturing fails to stop it should be stopped by '_ip capturing recovery helper'.
    ...  | In such case logs from IP capturing will be downloaded as
    ...  | ${LOG_PATH}/utf_logs/recovery_BTS_${source_bts_id}.pcap for main TL and as
    ...  | ${LOG_PATH}/utf_logs/recovery_BTS_${target_bts_id}.pcap for HO TL.
    ...  | This KW requires following test variables to be created before running it:
    ...  | -${LOG_PATH} - Path to logs created in 'Multiple BTS Test Setup' KW.
    ...  | -${TARGET_SMOD_SERIAL_NUMBER} - Serial number of target SMOD.
    ...  | This KW creates or sets following test variable:
    ...  | -${UTF_STARTED} - boolean value indicating that UTF logs collection is started. Can be used for conditional
    ...  |  stopping in teardown.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------------+------+----------------------------------------------------------------------+
    ...  | Parameter            | Man. | Description                                                          |
    ...  +======================+======+======================================================================+
    ...  | main_trace_id        | Yes  | ID of traces started with UTF on source (main) TL.                   |
    ...  +----------------------+------+----------------------------------------------------------------------+
    ...  | ho_trace_id          | Yes  | ID of traces started with UTF on target (HO) TL.                     |
    ...  +----------------------+------+----------------------------------------------------------------------+
    ...  | source_bts_id        | Yes  | BTS ID of source BTS.                                                |
    ...  +----------------------+------+----------------------------------------------------------------------+
    ...  | target_bts_id        | Yes  | BTS ID of target BTS.                                                |
    ...  +----------------------+------+----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Multiple BTS Test Setup
    ...     Start Collecting Logs With UTF  source_cell_id=12345
    ...     ...  target_cell_id=67890  target_rat=NR  source_bts_id=11111  target_bts_id=22222
    ...     Sleep    300s
    ...     Stop UTF Traces and Download Logs
    ...     ...  main_trace_id=${MAIN_TRACE_ID}  ho_trace_id=${HO_TRACE_ID}  source_bts_id=11111  target_bts_id=22222
    ...     Multiple BTS Test Teardown

    [Timeout]  30 min
    [Arguments]  ${main_trace_id}  ${ho_trace_id}  ${source_bts_id}  ${target_bts_id}

    Log  Stopping UTF traces...  console=True
    utf_manager.Stop Trace  trace=${main_trace_id}
    utf_manager.Stop Trace  trace=${ho_trace_id}
    Set Test Variable  ${UTF_STARTED}  False
    Log  Downloading logs...  console=True
    ${utf_logs_path} =  utf_manager.Download Logs  trace=${main_trace_id}  target_dir=${LOG_PATH}/utf_logs/BTS_${source_bts_id}
    Log  Logs from main BTS downloaded to ${utf_logs_path}.  console=True
    ${utf_logs_path} =  utf_manager.Download Logs  trace=${ho_trace_id}  target_dir=${LOG_PATH}/utf_logs/BTS_${target_bts_id}
    Log  Logs from HO BTS downloaded to ${utf_logs_path}.  console=True
    _check trace end status helper  ${main_trace_id}  ${ho_trace_id}
    utf_manager.Teardown
    _ip capturing recovery helper  bts_id=${source_bts_id}  connection=main
    _ip capturing recovery helper  bts_id=${target_bts_id}  connection=${TARGET_SMOD_SERIAL_NUMBER}
    Disallow Alarms For Watchdog
    [Teardown]  Run Keyword If  '${KEYWORD_STATUS}' == 'FAIL'
    ...  Log  Stop UTF failed. Please check logs for details.  console=True  level=WARN


_check trace end status helper
    [Arguments]  ${main_trace_id}  ${ho_trace_id}
    ${main_trace_status} =  Get Trace Info By ID  trace_id=${main_trace_id}  connection=dcap_collector
    ${ho_trace_status} =  Get Trace Info By ID  trace_id=${ho_trace_id}  connection=dcap_collector
    Run Keyword If  '${main_trace_status['status']}' != 'ready'
    ...  Log  Not all logs may be collected. End status for main TL traces: '${main_trace_status['status']}'   console=True  level=WARN
    Run Keyword If  '${ho_trace_status['status']}' != 'ready'
    ...  Log  Not all logs may be collected. End status for HO TL traces: '${ho_trace_status['status']}'   console=True  level=WARN


_ip capturing recovery helper
    [Arguments]  ${bts_id}  ${connection}
    Run Keyword And Ignore Error  Stop IP Capture File  connection=${connection}
    Run Keyword And Ignore Error  Generate IP Capture File  connection=${connection}
    Run Keyword And Ignore Error  Download IP Capture File
    ...  target_file_name=${LOG_PATH}/utf_logs/recovery_BTS_${bts_id}.pcap  connection=${connection}
