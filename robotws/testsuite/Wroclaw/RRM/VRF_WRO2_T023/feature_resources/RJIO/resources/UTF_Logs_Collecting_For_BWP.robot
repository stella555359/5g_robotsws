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
    ...  | This KW starts collecting logs with UTF.
    ...  | For NR: bts_custom_profile=ipCapture, gnb_custom_profile=cp_5g, L2Ps_Component, bip_interface_mirroring,
    ...  | l1IqTracer,
    ...  | monitoring_profiles=5g-full-call-scenarios, bip_mirroring_interface=L1-L2, bip_mirroring_time=30,
    ...  | gnb_l1iq_direction=DL.
    ...  | This KW requires following test variables to be created before running it:
    ...  | -${MAX_UTF_LOGS_DELAY} - Max time in seconds needed for change of UTF logs collecting status to 'running'.
    ...  | -${DCAP_HOST} - Dictionary with data for connecting to UTF. It should contain following keys:
    ...  |  ip, port, login, password.
    ...  | This KW creates or sets following test variables:
    ...  | -${TRACE_ID} - ID of traces started on TL.
    ...  | -${UTF_STARTED} - boolean value indicating that UTF logs collection is started. Can be used for conditional
    ...  |  stopping in teardown.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------------+------+----------------------------------------------------------------------+
    ...  | Parameter            | Man. | Description                                                          |
    ...  +======================+======+======================================================================+
    ...  | cell_id              | Yes  | ID of cell.                                                          |
    ...  +----------------------+------+----------------------------------------------------------------------+
    ...  | bts_id               | Yes  | BTS ID of BTS.                                                       |
    ...  +----------------------+------+----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Multiple BTS Test Setup
    ...     Start Collecting Logs With UTF  cell_id=12345
    ...     ...  bts_id=11111
    ...     Sleep    300s
    ...     Stop UTF Traces and Download Logs
    ...     ...  trace_id=${TRACE_ID}  bts_id=11111
    ...     Multiple BTS Test Teardown

    [Arguments]  ${cell_id}  ${bts_id}

    ${bts_log_profile} =  Create List  ipCapture

    ${nr_cell_list} =  Create List  ${cell_id}
    ${nr_log_profile} =  Create List  cp_5g  L2Ps_Component  bip_interface_mirroring  l1IqTracer
    ${profiles_dictionary} =  Create Dictionary  bts_custom_profile=${bts_log_profile}  gnb_custom_profile=${nr_log_profile}
    ...  monitoring_profiles=5g-full-call-scenarios  bip_mirroring_interface=L1-L2  bip_mirroring_time=30
    ...  gnb_l1iq_direction=DL

    Add Allowed Alarm  faultId=61641  alias=gNB


    _start utf helper  ${nr_cell_list}  ${profiles_dictionary}
    Log  Waiting for traces to change status to 'Running'  console=True
    Wait Until Keyword Succeeds  ${MAX_UTF_LOGS_DELAY}  5s  Check If Traces Are Running  ${TRACE_ID}

    [Teardown]  Run Keyword If  '${KEYWORD_STATUS}' == 'FAIL'  Run Keywords
    ...  Log  Start UTF failed. Please check logs for details.  console=True  level=WARN
    ...  AND  Run Keyword If  ${UTF_STARTED}  Stop UTF Traces and Download Logs  trace_id=${TRACE_ID}
    ...  bts_id=${bts_id}


_start utf helper
    [Arguments]  ${nr_cell_list}  ${profiles_dictionary}
    ...  ${user}=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...  ${password}=${tl.gnbs[0].cu.oam_http_connection_details.password}

    Log  Connecting to UTF server IP=${DCAP_HOST['ip']} on port=${DCAP_HOST['port']}  console=True
    utf_manager.Connect To  host=${DCAP_HOST['ip']}  port=${DCAP_HOST['port']}
    ...  user=${DCAP_HOST['login']}  passwd=${DCAP_HOST['password']}

    Log  Using profiles:\n${profiles_dictionary}.\nStarting new trace for IP ${MPLANE}...  console=True
    Set Test Variable  ${UTF_STARTED}  True

    ${trace_id} =  utf_manager.Start New Trace  mplane=${MPLANE}  user=${user}  passwd=${password}
    ...  port=443  nr_cells=${nr_cell_list}  log_profile=${profiles_dictionary}
    Set Test Variable  ${TRACE_ID}  ${trace_id}


    [Teardown]  Run Keyword If  '${KEYWORD_STATUS}' == 'FAIL'  Run Keywords
    ...  utf_manager.Stop Trace  trace=${TRACE_ID}
    ...  AND  utf_manager.Teardown
    ...  AND  Set Test Variable  ${UTF_STARTED}  False


Check If Traces Are Running
    [Documentation]
    ...  Checks if traces started with UTF are running for TL.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | Checks if traces started with UTF are running for TL.
    ...  | This KW will pass if traces status is 'running' or 'runningWithWarnings'.
    ...  | In case of status 'runningWithWarnings' warning will be printed.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------------+------+----------------------------------------------------------------------+
    ...  | Parameter            | Man. | Description                                                          |
    ...  +======================+======+======================================================================+
    ...  | trace_id             | Yes  | ID of traces started with UTF on TL.                                 |
    ...  +----------------------+------+----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Multiple BTS Test Setup
    ...     Start Collecting Logs With UTF  cell_id=12345
    ...     ...  bts_id=11111
    ...     Check If Traces Are Running  ${TRACE_ID}
    ...     Stop UTF Traces and Download Logs
    ...     ...  trace_id=${TRACE_ID}  bts_id=11111
    ...     Multiple BTS Test Teardown

    [Arguments]  ${trace_id}

    ${trace_status} =  Get Trace Info By ID  trace_id=${trace_id}  connection=dcap_collector
    ${status} =  Set Variable  ${trace_status['status']}
    ${msg} =  Catenate  Some logs were started with warnings and may not be collected.
    ...                 Please check UTF logs for more information.\n
    ...                 TL traces status: ${status}

    Run Keyword If  '${status}' == 'runningWithWarnings'
    ...  Log  ${msg}  console=True  level=WARN
    Should Be True  '${status}' == 'running' or '${status}' == 'runningWithWarnings'
    ...  msg=TL trace status is ${status}. Should be: 'running' or 'runningWithWarnings'.
    Log  Trace status ${status}.  console=True


Stop UTF Traces and Download Logs
    [Documentation]
    ...  Stops and downloads logs collected with UTF.
    ...
    ...  | **Author:** monika.ceglarek@nokia.com
    ...
    ...  | This KW stops and downloads logs collected with UTF. Download directory for TL is
    ...  | ${LOG_PATH}/utf_logs/BTS_${bts_id}.
    ...  | Downloaded logs will be in zip archive similarly to when one collects them manually with UTF.
    ...  | This KW also checks trace status after stopping and downloadind in case when TL
    ...  | trace status is different than 'ready' a warning will be printed.
    ...  | In case IP capturing fails to stop it should be stopped by '_ip capturing recovery helper'.
    ...  | In such case logs from IP capturing will be downloaded as
    ...  | ${LOG_PATH}/utf_logs/recovery_BTS_${bts_id}.pcap for TL and as
    ...  | This KW requires following test variables to be created before running it:
    ...  | -${LOG_PATH} - Path to logs created in 'Multiple BTS Test Setup' KW.
    ...  | This KW creates or sets following test variable:
    ...  | -${UTF_STARTED} - boolean value indicating that UTF logs collection is started. Can be used for conditional
    ...  |  stopping in teardown.
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------------+------+----------------------------------------------------------------------+
    ...  | Parameter            | Man. | Description                                                          |
    ...  +======================+======+======================================================================+
    ...  | trace_id             | Yes  | ID of traces started with UTF on TL.                                 |
    ...  +----------------------+------+----------------------------------------------------------------------+
    ...  | bts_id               | Yes  | BTS ID of BTS.                                                       |
    ...  +----------------------+------+----------------------------------------------------------------------+
    ...  | loop                 | Yes  | Loop number for the test iteration..                                 |
    ...  +----------------------+------+----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Multiple BTS Test Setup
    ...     Start Collecting Logs With UTF  cell_id=12345
    ...     ...    bts_id=11111
    ...     Sleep    300s
    ...     Stop UTF Traces and Download Logs
    ...     ...  trace_id=${TRACE_ID}  bts_id=11111
    ...     Multiple BTS Test Teardown

    [Timeout]  30 min
    [Arguments]  ${trace_id}  ${bts_id}  ${loop}

    Log  Stopping UTF traces...  console=True
    utf_manager.Stop Trace  trace=${trace_id}
    Set Test Variable  ${UTF_STARTED}  False
    Log  Downloading logs...  console=True
    ${utf_logs_path} =  utf_manager.Download Logs  trace=${trace_id}
    ...  target_dir=${LOG_PATH}/utf_logs/BTS_${bts_id}/loop_${loop}
    Log  Logs from BTS downloaded to ${utf_logs_path}.  console=True

    _check trace end status helper  ${trace_id}
    utf_manager.Teardown
    _ip capturing recovery helper  bts_id=${bts_id}  connection=ip_capturing_recovery
    [Teardown]  Run Keyword If  '${KEYWORD_STATUS}' == 'FAIL'
    ...  Log  Stop UTF failed. Please check logs for details.  console=True  level=WARN


_check trace end status helper
    [Arguments]  ${trace_id}
    ${trace_status} =  Get Trace Info By ID  trace_id=${trace_id}  connection=dcap_collector
    Run Keyword If  '${trace_status['status']}' != 'ready'
    ...  Log  Not all logs may be collected. End status for TL traces: '${trace_status['status']}'   console=True  level=WARN


_ip capturing recovery helper
    [Arguments]  ${bts_id}  ${connection}
    Run Keyword And Ignore Error  Stop IP Capture File  connection=${connection}
    Run Keyword And Ignore Error  Generate IP Capture File  connection=${connection}
    Run Keyword And Ignore Error  Download IP Capture File
    ...  target_file_name=${LOG_PATH}/utf_logs/recovery_BTS_${bts_id}.pcap  connection=${connection}
