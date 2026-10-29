*** Settings ***
Documentation
...    N/A

Metadata    branch    ${ENB_BRANCH}
Metadata    build    ${ENB_BUILD}
Metadata    topology    CLOUD_5G_O_E_AP_LOOO
Metadata    variant    SA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO_5_1

Force Tags    OPTION_RELATED_ARTIFACTS_5G    TOOLS_PROFILE_AP_WTS    PY310    RF50

Resource    ./resources/main_resources.robot
# -- extra resources --
Variables    ${RESOURCES}/kpi_config.py
Library    ${CURDIR}/resources/kpi/kpi.py
Library    ${CURDIR}/resources/monitor_parser.py

# -- setup/teardown --
Suite Setup    RUN KEYWORDS    Prepare Testing Environment
...    AND    Start Mandatory Logging
...    AND    Get Active BTS Alarms

Suite Teardown  RUN KEYWORDS
...    Get Active BTS Alarms    AND
...    Collect Mandatory Logs    AND
...    Cleanup Testing Environment


*** Variables ***
${RESOURCES}    ${CURDIR}/NR_ASOE.resources

# -- test scenario variables --
${WTS_SETUP_FILE}    wts_setup.lua
${WTS_TEST_SCENARIO_FILE}    wts_test_scenario.lua
${DELTA}    ${RESOURCES}/delta.json
${ENV_MONITOR_SCRIPT}    ${CURDIR}/resources/monitor.sh
${ENV_MONITOR_OUTPUT_DIR}    /tmp/env_monitor/
${WTS_SCRIPTS}    ${RESOURCES}/test
${RMODS_NUMBER}    5
${CELLS_NUMBER}    6
${DATA_TRAFFIC_TIME_MINUTES}    90
${PM_COUNTERS_INTERVAL}    300
@{ALARMS_WHITELIST}    LMP access via port 443
...    Service account root access is enabled
...    Ethernet port security is disabled
...    SSH enabled
...    BTS Reset Cause
...    Diagnostic Check Error
...    Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
...    NG SCTP setup fail
...    NG SCTP endpoint broken
...    Cell Activation timeout at gNB-DU
...    R&D Service Port enabled
...    No X2 link available
...    Cell problem due to unavailability of associated links
...    User Account has Default Password
...    Failure in connection between BTS and 3rd party tool
${BSR_FILE_NAME}    BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001
${BSR_PACKAGE_NAME}    BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip


*** Test Cases ***
5G_SA_mix_traffic
    [Documentation]
    ...    N/A
    [Tags]    CLOUD_5G_O_E_AP_LOOO
    [Setup]    [PRE]5G_SA_mix_traffic
    [Teardown]    [POST]5G_SA_mix_traffic

    Start Mix Traffic And Mobility Events
    Get Snapshot Every 30 Minutes
    Stop Mix Traffic And Mobility Events
    Verify Kpi
    Verify Gnb Behaviour During Test Case Execution


*** Keywords ***
[PRE]5G_SA_mix_traffic
    [Documentation]    Prepares test environment for test execution
    ...    WTS test scripts and configuration files are copied to WTS native directory to solve relation errors
    ...    Before starting WTS gNB and RMODs states are checked
    ...    After WTS is started gNB, NR cells and NG link states are checked. It is mandatory to wait for all NG link active state
    ...    Update gNB to tested SBTS build

    ${start_time}=    Get Current Date    result_format=epoch    exclude_millis=yes
    Set Suite Variable    ${TEST_SUITE_START_TIME}    ${start_time}
    OperatingSystem.Copy Files    ${WTS_SCRIPTS}/*    /opt/iphy/latest
    Move Epcsim Directory
    Check If Bts Is Correctly Configured    rmods_number=${RMODS_NUMBER}
    Update Gnb Software
    Check If Bts Is Correctly Configured    rmods_number=${RMODS_NUMBER}
    Install Bsr Package
    Check If Bts Is Correctly Configured    rmods_number=${RMODS_NUMBER}
    Delta Commissisoning    ${DELTA}
    Check If Bts Is Correctly Configured    rmods_number=${RMODS_NUMBER}
    Start Wts    lua_config=${WTS_SETUP_FILE}    nr_mode=SA    check_version=False    timeout=600
    Check If Bts Is Onair    cells_number=${CELLS_NUMBER}
    Sleep    10 minutes    reason=Wait for AP full activation
    Start Test Environment Monitoring

[POST]5G_SA_mix_traffic
    Run Keyword If Test Failed    Get Snapshot With Admin
    Stop Test Environment Monitoring
    Get Cpu And Memory Usage During Test
    Pack Wts Logs
    Stop Wts

# -- test steps --
Start Mix Traffic And Mobility Events
    ${start_test_script_cmd}=    Set Variable    script file=${WTS_TEST_SCENARIO_FILE} entry=start_traffic
    ${cmd_output}=    wtssim.execute_egate_command    cmd=${start_test_script_cmd}    return_output=True    timeout=120
    Sleep    5 minutes    reason=dunno traffic ramp up or smth
    ${cmd_output}=    wtssim.execute_egate_command    cmd=sim_log_set flush    return_output=True
    ${start_time}=    Get Current Date    result_format=datetime    exclude_millis=yes
    Turn Off Extended Logging
    Set Suite Variable    ${DATA_TRAFFIC_START}    ${start_time}

Get Snapshot Every 30 Minutes
    Repeat Keyword    ${DATA_TRAFFIC_TIME_MINUTES} minutes    Wait 30 Minutes And Get Snapshot

Stop Mix Traffic And Mobility Events
    ${stop_test_script_cmd}=    Set Variable    script file=${WTS_TEST_SCENARIO_FILE} entry=stop_traffic
    ${cmd_output}=    wtssim.execute_egate_command    cmd=${stop_test_script_cmd}    return_output=True
    ${stop_time}=    Get Current Date    result_format=epoch    exclude_millis=yes
    ${stop_time}=    Evaluate    $stop_time - $stop_time % ${PM_COUNTERS_INTERVAL}
    ${stop_time}=    Convert Date    ${stop_time}    result_format=datetime
    Set Suite Variable    ${DATA_TRAFFIC_STOP}    ${stop_time}
    Sleep    5 minutes    reason=Wait for last PM counter to be generated

Verify Kpi
    [Teardown]    admin.teardown    connection=verify_kpi
    ${logs_dir}=    Prepare Logs Directory Path    verify_kpi
    admin.connect_to    bts_host=${__LOCAL_BTS_IP__}    admin_api_log_dir=${logs_dir}    name=verify_kpi
    admin.get_pm_files    ${logs_dir}/pm_files.txt    timeout=360    connection=verify_kpi
    ${counters_data}=    kpi.Get Counters Data    ${logs_dir}/pm_files.txt    ${logs_dir}

    ${failed_kpi_calculations}=    kpi.Verify Kpis    ${DATA_TRAFFIC_START}    ${DATA_TRAFFIC_STOP}
    ...    ${KPIS_CONFIG_DATA}    ${counters_data}    ${logs_dir}
    FOR    ${kpi_calculation}    IN    @{failed_kpi_calculations}
        Call Method    ${kpi_calculation}    report_verdict_failed
    END
    Run Keyword And Continue On Failure    Should Be Empty    ${failed_kpi_calculations}    msg=Some KPI targets where not reached!

Verify Gnb Behaviour During Test Case Execution
    Check If Unexpected Alarm Occurred

# -- internals --
Wait 30 Minutes And Get Snapshot
    Sleep    30 minutes    reason=Wait before gathering snapshot
    Get Snapshot With Admin

Get Snapshot With Admin
    [Teardown]    admin.teardown    connection=snapshot

    ${logs_dir}=    Prepare Logs Directory Path    snapshot
    admin.connect_to    bts_host=${__LOCAL_BTS_IP__}    admin_api_log_dir=${logs_dir}    name=snapshot
    admin.collect_snapshot    ${logs_dir}/${__DEFAULT_SNAPSHOT_FILE_NAME__}    timeout=840    connection=snapshot

Get Cpu And Memory Usage During Test
    [Documentation]    Collects CPU and memory usage statistics during test execution.
    ...    Monitoring scripts run in the background at 60-second intervals.
    ...
    ...    CPU usage is measured using the command:
    ...    `mpstat -P ALL -o JSON 3 1`
    ...    The reported CPU usage is the average over the last 3 seconds.
    ...    Interpreting mpstat output:
    ...    - High %usr + low %idle, high application demand
    ...    - High %sys + low %idle, kernel or I/O driver pressure
    ...    - High %iowait, disk or network latency
    ...    - High %steal, overcommitted virtual CPU (in VMs)
    ...    - Low %idle (near 0%),  CPU saturation
    ...
    ...    Memory usage is measured using:
    ...    `free -h`

    ${cpu_stats}=    monitor_parser.Get Cpu Statistics    ${ENV_MONITOR_OUTPUT_DIR}
    Log    ${cpu_stats}    html=True
    ${mem_stats}=    monitor_parser.Get Mem Statistics    ${ENV_MONITOR_OUTPUT_DIR}
    Log    ${mem_stats}    html=True

Check If Unexpected Alarm Occurred
    ${unexpected_alarms}    Get Historic And Active Alarms    alarms_whitelist=${ALARMS_WHITELIST}
    FOR    ${a}    IN    @{unexpected_alarms}
        ${cleared_time}=    Evaluate    $a.get('clearedTime', '')
        IF    $cleared_time
            ${cleared_time_converted}=    Convert Date    ${cleared_time}    epoch    exclude_millis=yes
        ELSE
            ${cleared_time_converted}=    Set Variable
        END
        Continue For Loop If    '${TEST_SUITE_START_TIME}' > '${cleared_time_converted}' and '${cleared_time_converted}' != ''
        Run Keyword And Continue On Failure    Fail    msg=Unexpected alarm detected: ${a.alarmDetail}
    END

Start Test Environment Monitoring
    ${logs_dir}=    Prepare Logs Directory Path    test_env_monitoring
    ${env_monitor}=    Process.Start Process    bash ${ENV_MONITOR_SCRIPT}    shell=True    stdout=${logs_dir}/output.txt    stderr=STDOUT
    Set Suite Variable    ${ENV_MONITOR_PROCESS}    ${env_monitor}

Stop Test Environment Monitoring
    Process.Terminate Process    ${ENV_MONITOR_PROCESS}

Install Bsr Package
    [Teardown]    Teardown Admin Connection    connection=install_bsr_package
    ${install_bsr_package}=    Check If Bsr Package Install Is Required
    IF    '${install_bsr_package}' == '${BSR_FILE_NAME}'
        Verify Bsr Package Was Installed
        RETURN    ${None}
    END
    ${bsr_package_path}=    Download Bsr Package
    File Should Exist    ${bsr_package_path}    msg=BSR package is missing.
    ${logs_dir}=    Prepare Logs Directory Path    install_bsr_package
    admin.Connect To    bts_host=${__LOCAL_BTS_IP__}    admin_api_log_dir=${logs_dir}    name=install_bsr_package
    admin.Update Software    sw_package=${bsr_package_path}    connection=install_bsr_package
    Check If Bts Is Correctly Configured    rmods_number=${RMODS_NUMBER}
    Verify Bsr Package Was Installed

Check If Bsr Package Install Is Required
    [Teardown]    Teardown Admin Connection    connection=bsr_package_required
    ${logs_dir}=    Prepare Logs Directory Path    bsr_package_required
    admin.Connect To    bts_host=${__LOCAL_BTS_IP__}    admin_api_log_dir=${logs_dir}    name=bsr_package_required
    ${bsr_files}=    admin.Get Bsr Files    connection=bsr_package_required
    ${bsr_files_inused}=    Get From Dictionary    ${bsr_files}    bsrFileInused
    IF    ${bsr_files_inused}
        RETURN    ${bsr_files_inused}[0][filename]
    ELSE
        RETURN    ${False}
    END

Download Bsr Package
    [Return]    ${bsr_package_path}
    ${base_bsr_package_uris}=    Create List
    ...    https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnpute-rotta-local/BSR/
    ...    https://artifactory-espoo1.int.net.nokia.com/artifactory/mnpute-rotta-local/BSR/
    @{bsr_package_uris}=    Create List
    FOR    ${base}    IN    @{base_bsr_package_uris}
        ${uri}=    CATENATE    SEPARATOR=${EMPTY}    ${base}    ${BSR_PACKAGE_NAME}
        Append To List    ${bsr_package_uris}    ${uri}
    END
    ${output_dir}=    Prepare Logs Directory Path    bsr_package
    ${bsr_package_path}=    Download From Many    ${output_dir}    @{bsr_package_uris}

Verify Bsr Package Was Installed
    [Teardown]    Teardown Admin Connection    connection=verify_bsr_package_installed
    ${logs_dir}=    Prepare Logs Directory Path    verify_bsr_package_installed
    ${alarm_parameters}=    Set Variable    faultName=regex"BSR package missing", faultId=4613
    admin.Connect To    admin_api_log_dir=${logs_dir}    name=verify_bsr_package_installed
    admin.Assert Alarm Inactive    ${alarm_parameters}    timeout=120    connection=verify_bsr_package_installed
