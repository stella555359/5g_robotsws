*** Settings ***
Documentation    Keywords for Marvin reporting
...
...    Default analyze templates are stored under:
...      - marvin/default_analyze_templates
...
...    How to use:
...      - Add `Start Marvin Reporting` in Test Case Setup section:
...        Initializes Marvin, starts test run, creates test case, and disables BTS syslog.
...        It is required to provide reference test run and test case Ids. For that use
...        variables $MARVIN_REF_RUN_ID and $MARVIN_REF_CASE_ID. Those should be configured
...        in Test Suite Variable section.
...        When first time reporting $EMPTY value should be provided for both.
...        Variables value can be changed in QC via Automation Options.
...      - Add `Stop Marvin Reporting` in Test Case Teardon section:
...        Ends test case and test run, sends suite verdict to Marvin.
...      - `Get Bts Snapshot And Send To Marvin`:
...        Captures BTS snapshot and uploads to Marvin for analysis.
...        It returns True if snapshot fetching was successfull.
...      - `Change Mrbts Id In Bts`: Updates BTS MRBTS Id when required.

Library    taf.ul.marvin    WITH NAME    Marvin
Library    common.py
Resource    ../main_resources.robot


*** Variables ***
# Default values, do not change
${DEFAULT_TEMPLATES}    ${CURDIR}/default_analyze_templates
${DUMMY_MRBTS_ID}    654329
${TEST_RUN_TYPE}    CBT
${ORGANIZATION}    CITCRT_02
${MARVIN_STARTED}    ${FALSE}


*** Keywords ***
Change Mrbts Id In Bts
    [Documentation]    Changes MRBTS Id in BTS via full commissioning.
    ...
    ...    Change the MRBTS ID if the BTS ID differs from the one in the test line configuration file.
    ...    Get SCF from running BTS, replace MRBTS Id and perform full commissioning.
    ...    Wait for BTS reaches configured state.

    IF    robot.utils.is_truthy($__DISABLE_MARVIN__)    RETURN    ${FALSE}
    ${mrbts_id_new}=    Get Mrbts Id From Testline Configuration
    ${mrbts_id_old}=    Get Bts Mrbts Id
    IF    '${mrbts_id_new}' != '${mrbts_id_old}'
        ${scf_updated}=    Get Bts Scf And Change Mrbts Id    ${mrbts_id_new}    ${mrbts_id_old}
        ${rmods_number}=    Get Rmods Number
        Perform Full Commissioning    ${scf_updated}
        Check If Bts Is Correctly Configured    rmods_number=${rmods_number}
    END

Start Marvin Reporting
    [Documentation]    Prepares BTS and starts Marvin reporting.
    ...
    ...    Marvin usage is disabled by default. It can turned on by disabling flag __DISABLE_MARVIN__.
    ...    BTS SCF is updated with unique, per test line, MRBTS ID.
    ...    First Marvin test run level reporting is started, then test case level.
    ...    Test run and test case results comparision is requested.
    ...
    ...    Args:
    ...      - ref_run_id: Reference run identifier
    ...      - ref_case_id: Reference test case identifier
    ...      - analyze_templates: Optional custom templates path. When left empty, templates from
    ...        taf.ul.marvin will be used.
    ...
    ...    Returns:
    ...      - False if Marvin reporting is disabled via flag __DISABLE_MARVIN__
    [Arguments]    ${ref_run_id}    ${ref_case_id}    ${analyze_templates}=${EMPTY}

    IF    robot.utils.is_truthy($__DISABLE_MARVIN__)    RETURN    ${FALSE}

    ${MARVIN_STARTED}=    Prepare Marvin And Start Test Run
    ...    ref_run_id=${ref_run_id}
    ...    organization=${ORGANIZATION}
    ...    analyze_templates=${analyze_templates}
    Set Suite Variable    ${MARVIN_STARTED}
    IF    $MARVIN_STARTED
        Create And Start Test Case In Marvin
        ...    testcase_name=${TEST_NAME}
        ...    ref_case_id=${ref_case_id}
        Stop Jcsl Bts Syslog
    END

Stop Marvin Reporting
    [Documentation]    Stop test case and test run level Marvin reporting.
    ...
    ...    First test case level reporting is stoped, then test run.
    ...    In both cases as a test execution verdict is set by TEST_STATUS
    ...
    ...    Returns:
    ...      - False if Marvin reporting is disabled via flag __DISABLE_MARVIN__
    ...        or Marvin reporting was not started

    IF    robot.utils.is_truthy($__DISABLE_MARVIN__) or not $MARVIN_STARTED    RETURN    ${FALSE}
    ${verdict}=    Set Variable If    '${TEST_STATUS}'=='PASS'    Passed    Failed
    Stop Marvin Test Case    ${TEST_NAME}    ${verdict}
    Stop Marvin Test Run    ${verdict}

Get Bts Snapshot And Send To Marvin
    [Documentation]    Fetches BTS snapshot and sends to Marvin for analysis.
    ...
    ...    Returns:
    ...      - False if Marvin reporting is disabled via flag __DISABLE_MARVIN__
    ...        or Marvin reporting was not started or there was problem fetching snapshot

    IF    robot.utils.is_truthy($__DISABLE_MARVIN__) or not $MARVIN_STARTED    RETURN    ${FALSE}
    TRY
        Marvin.Fetch Snapshot
        RETURN    ${TRUE}
    EXCEPT    AS    ${error}
        Log    Error fetching snapshot: ${error}    level=WARN
        RETURN    ${FALSE}
    END

Get Mrbts Id From Testline Configuration
    [Documentation]    Retrieves MRBTS ID from test line configuration or returns dummy ID.
    ...
    ...    Returns:
    ...      - MRBTS ID from config or ${DUMMY_MRBTS_ID} if not found
    [Return]    ${mrbts_id}

    ${variables}=    Get Variables    no_decoration=${TRUE}
    ${mrbts_id}=    Set Variable If    "tl" in $variables    ${tl.gnbs[0].instance_id}    ${DUMMY_MRBTS_ID}

Get Bts Mrbts Id
    [Documentation]    Gets current MRBTS ID from BTS system.
    ...
    ...    Returns:
    ...      - Current BTS MRBTS ID
    [Teardown]    admin.Teardown    connection=get_bts_mbrts_id
    [Return]    ${bts_info}[mrbtsID]

    ${logs_dir}=    Prepare Logs Directory Path    get_bts_mbrts_id
    admin.Connect To    admin_api_log_dir=${logs_dir}    name=get_bts_mbrts_id    timeout=60
    ${bts_info}=    admin.Get Bts Info    timeout=60    connection=get_bts_mbrts_id

Get Bts Scf And Change Mrbts Id
    [Documentation]    Gets BTS SCF file and replaces MRBTS ID.
    ...
    ...    Args:
    ...      - id_new: target MRBTS ID
    ...      - id_old: current MRBTS ID
    ...
    ...    Process:
    ...      - Get SCF from running BTS
    ...      - Get new MRBTS ID from testline config. Parameter `instance_id`
    ...      - Get current BTS MRBTS ID
    ...      - Replace old ID with new ID using sed
    ...
    ...    Returns:
    ...      - Path to modified SCF file
    [Arguments]    ${id_new}    ${id_old}
    [Return]    ${scf_path}
    ${scf_path}=    Get Bts Configuration File
    ${replace_command}=    Catenate
    ...    sed
    ...    -i.bak
    ...    \'s\/MRBTS-${id_old}\/MRBTS-${id_new}\/g\'
    ...    ${scf_path}
    OperatingSystem.Run    ${replace_command}

Get Bts Configuration File
    [Documentation]    Downloads BTS SCF configuration file.
    ...
    ...    Returns:
    ...      - Path to downloaded SCF file, scf. xml
    [Teardown]    admin.Teardown    connection=get_bts_scf
    [Return]    ${scf_path}/scf.xml

    ${scf_path}=    Prepare Logs Directory Path    get_bts_scf/scf
    admin.Connect To    admin_api_log_dir=${scf_path}/admin_logs    name=get_bts_scf    timeout=60
    admin.Get Current Scf File
    ...    local_dir_path=${scf_path}
    ...    file_name=scf.xml
    ...    timeout=60
    ...    connection=get_bts_scf

Prepare Marvin And Start Test Run
    [Documentation]    Prepares Marvin environment and starts test run.
    ...
    ...    Args:
    ...    - ref_run_id: Reference run identifier
    ...    - organization: Organization name
    ...    - analyze_templates: analyze_templates templates path
    ...
    ...    Returns:
    ...    - True if Marvin started successfully, False otherwise
    [Arguments]    ${ref_run_id}    ${organization}    ${analyze_templates}

    ${data_collector_status}=    Stop And Remove Data Collector Container
    IF    not $data_collector_status    RETURN    ${FALSE}

    ${marvin_dir}=    Prepare Logs Directory Path    marvin_scripts

    TRY
        Marvin.Prepare And Start Marvin
        ...    ref_run_id=${ref_run_id}
        ...    only_test_run=${TRUE}
        ...    marvin_folder=${marvin_dir}
        ...    common_templates=${analyze_templates}
        ...    organization=${organization}
        ...    marvin_side=${__MARVIN_SIDE__}
        ...    print_marvin_link=${TRUE}
        ...    install_marvin_from_rsp_pypi=${TRUE}
        ...    test_run_type=${TEST_RUN_TYPE}

        ${marvin_running}=    Is Marvin Running
        RETURN    ${marvin_running}
    EXCEPT    AS    ${error}
        Log    Marvin could not be started: ${error}    level=WARN
    END

Stop And Remove Data Collector Container
    [Documentation]    Stops and removes data_collector Docker container.
    ...
    ...    Returns:
    ...    - True if container stopped/removed or doesn't exist, False if Docker not running

    ${docker_running}=    Is Docker Running
    IF    not $docker_running
        Log    Docker application is not running.    level=WARN
        RETURN    ${FALSE}
    END

    Comment    List containters configured in environment.
    ${containers}=    List Containers

    ${data_collector_exists}=    Container Exists    data_collector
    IF    $data_collector_exists
        ${data_collector_running}=    Is Container Running    data_collector
        IF    $data_collector_running
            Stop Container    data_collector
        END
        Remove Container    data_collector
    END
    RETURN    ${TRUE}

Is Marvin Running
    [Documentation]    Checks if Marvin is fully operational, data collector + interface running.
    ...
    ...    Returns:
    ...    - True if both components running, False otherwise

    ${data_collector_running}=    Is Container Running    data_collector
    ${marvin_interface_running}=    Is Marvin Interface Running
    IF    $data_collector_running and $marvin_interface_running
        RETURN    ${TRUE}
    ELSE
        RETURN    ${FALSE}
    END

Is Marvin Interface Running
    [Documentation]    Checks if Marvin interface is running.
    ...
    ...    Returns:
    ...    - True if interface is running, False otherwise

    ${marvin_instance}=    Get Library Instance    Marvin
    RETURN    ${marvin_instance.run_marvin}

Create And Start Test Case In Marvin
    [Documentation]    Creates and starts a test case in Marvin.
    ...
    ...    Args:
    ...    - testcase_name: Name of the test case
    ...    - ref_case_id: Reference case identifier
    ...
    ...    Returns:
    ...    - False if Marvin not running, otherwise attempts creation
    [Arguments]    ${testcase_name}    ${ref_case_id}
    ${data_collector_running}=    Is Marvin Running
    IF    not ${data_collector_running}    RETURN    ${FALSE}
    TRY
        Marvin.Create Test Case And Start
        ...    test_case_name=${testcase_name}
        ...    ref_case_id=${ref_case_id}
    EXCEPT    AS    ${error}
        Log    Marvin could not create test case and start: ${error}    level=WARN
    END

Stop Jcsl Bts Syslog
    ${bts_syslog_process_name}=    Set Variable    jcsl
    ${syslog_running}=    Get Variable Value    ${JCSL_HANDLERS}    ${FALSE}
    IF    $syslog_running
        ${bts_syslog_started}=    Evaluate    "${bts_syslog_process_name}" in $JCSL_HANDLERS
        IF    $bts_syslog_started    Process.Terminate Process    ${bts_syslog_process_name}
    END

Stop Marvin Test Case
    [Documentation]    Stops specific test case in Marvin with verdict.
    ...
    ...    Args:
    ...      - testcase_name: Name of test case to stop
    ...      - verdict: Test case verdict, Passed/Failed
    ...
    ...    Returns:
    ...      - False if Marvin not running
    [Arguments]    ${testcase_name}    ${verdict}

    ${data_collector_running}=    Is Marvin Running
    IF    not ${data_collector_running}    RETURN    ${FALSE}
    TRY
        Marvin.Stop Test Case    test_case_name=${testcase_name}    verdict=${verdict}
    EXCEPT    AS    ${error}
        Log    Marvin could not stop test case: ${error}    level=WARN
    END

Stop Marvin Test Run
    [Documentation]    Stops Marvin test run with specified verdict.
    ...
    ...    Args:
    ...    - verdict: Test run verdict, Passed/Failed
    [Arguments]    ${verdict}

    TRY
        Marvin.Stop Marvin
        ...    only_test_run=${TRUE}
        ...    verdict=${verdict}
        ...    wait_after_run=${FALSE}
    EXCEPT    AS    ${error}
        Log    Marvin could not be stopped: ${error}    level=WARN
    END
