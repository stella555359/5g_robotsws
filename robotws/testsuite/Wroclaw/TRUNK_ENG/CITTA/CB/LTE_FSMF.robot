*** Settings ***
Documentation    LTE FSMF Robustness Testing Suite
...    Test suite for verifying BTS behavior under high memory utilization conditions
...
...    This suite performs:
...    - Data traffic generation with multiple UEs
...    - BTS system monitoring during test excution
...    - Cell lock/unlock operations during high memory usage
...    - Snapshot collection during high memory usage
...    - System used memory KPIs reporting

Metadata    branch    ${ENB_BRANCH}
Metadata    build    ${ENB_BUILD}
Metadata    topology    CLOUD_FCC_CUS
Metadata    variant    PRIVATE_CPRI_FDD_CONF_KT

Force Tags    OPTION_RELATED_ARTIFACTS_4G    TOOLS_PROFILE_CUS_WTS    PY310    RF50

Resource    ./resources/main_resources.robot
# -- extra resources --
Library    ${CURDIR}/resources/monitor_parser.py
Library    ${CURDIR}/resources/aashell_sysinfo.py
Library    ta_emss
Library    ta_uexgate    compress_logs=True
Library    taf.ue.cus
Library    taf.ccs.aashell    WITH NAME    aashell_cli

# -- setup/teardown --
Suite Setup    RUN KEYWORDS    Prepare Testing Environment
...    AND    Start Mandatory Logging
...    AND    Get Active BTS Alarms

Suite Teardown  RUN KEYWORDS
...    Get Active BTS Alarms    AND
...    Collect Mandatory Logs    AND
...    Cleanup Testing Environment


*** Variables ***
${RESOURCES}    ${CURDIR}/LTE_FSMF.resources

# -- test scenario variables --
${WTS_SETUP_FILE}    ${RESOURCES}/wts_setup.cfg
${DELTA_LOCK_CELLS}    ${RESOURCES}/lock_cells.json
${DELTA_UNLOCK_CELLS}    ${RESOURCES}/unlock_cells.json

${ENV_MONITOR_SCRIPT}    ${CURDIR}/resources/monitor.sh
${ENV_MONITOR_OUTPUT_DIR}    /tmp/env_monitor/

@{SIM_GNB_MME_IP_ADDRESSES}    10.0.1.5    10.0.1.6    10.0.1.7    10.0.1.8
...    10.0.1.129    10.0.1.130
...    10.0.1.131    10.0.1.132    10.0.1.133    10.0.1.134
...    10.0.1.135    10.0.1.136    10.0.1.137    10.0.1.138
...    10.0.1.139    10.0.1.140    10.0.1.141    10.0.1.142
...    10.0.1.143    10.0.1.144    10.0.1.145

@{ALARMS_WHITELIST}    LMP access via port 443
...    Service account root access is enabled
...    Ethernet port security is disabled
...    SSH enabled
...    R&D Service Port enabled
...    BTS Reset Cause
...    Diagnostic Check Error
...    Transport layer connection failure in S1 interface
...    S1 interface setup failure
...    Setup of X2 connectivity to gNB failed
...    Failure in internal BTS connection or connection to 3rd party tool

${RMODS_NUMBER}    ${8}
${CELLS_NUMBER}    ${12}
${UE_AMOUNT}    ${100}
${UE_TRAFFIC_MBPS}    ${1}
${DATA_TRAFFIC_TIME_MINUTES}    ${240}
${LOCK_UNLOCK_TIME_MINUTES}    ${120}
${MONITORING_INTERVAL_MINUTES}    5
@{CELLS_CALL_CAPABLE}    1    2    3    4    5    10    11    12    14
@{BTS_SYSTEM_INFORMATIONS}


*** Test Cases ***
4G_FSMF_robustness_testing
    [Documentation]    Executes robustness testing for 4G FSMF configuration.
    ...
    ...    Test Sequence:
    ...    1. Setup test environment:
    ...       - Update BTS software
    ...       - Configure WTS and X2 simulation
    ...    2. Execute traffic scenario:
    ...       - Start ${UE_AMOUNT} UE data traffic sessions
    ...       - Monitor system for ${DATA_TRAFFIC_TIME_MINUTES} minutes
    ...    3. Perform cell operations:
    ...       - Lock/unlock cells for ${LOCK_UNLOCK_TIME_MINUTES} minutes
    ...       - Collect system snapshots
    ...    4. Verify and report:
    ...       - Check for unexpected alarms
    ...       - Report memory utilization KPIs
    ...
    ...    Test runs with ${RMODS_NUMBER} RMODs and ${CELLS_NUMBER} cells.
    [Tags]    CLOUD_FCC_CUS
    [Setup]    [PRE]4G_FSMF_robustness_testing
    [Teardown]    [POST]4G_FSMF_robustness_testing

    Start Data Traffic
    Perform Data Traffic
    Lock Unlock Cells When The Bts Memory Utilization Is High
    Get Snapshot When The Bts Memory Utilization Is High
    Verify Bts behavior During Test Case Execution
    Report System Used Memory Kpis


*** Keywords ***
[PRE]4G_FSMF_robustness_testing
    [Documentation]    Prepares test environment for robustness testing execution.
    ...
    ...    Setup Steps:
    ...    1. Software Update
    ...    2. TGR Configuration:
    ...       - Resets TGR remotely via CUS executor
    ...    3. Network Setup:
    ...       - Configures MME IP addresses for WTS operation
    ...    4. WTS Initialization
    ...    5. X2 Links Setup:
    ...       - Configures 250 simulated X2 links
    ...       - IP range: 10.0.201.1-250/24
    ...       - Verifies connectivity
    ...    6. Monitoring:
    ...       - Starts system metrics collection

    ${start_time}=    Get Current Date    result_format=epoch    exclude_millis=yes
    Set Suite Variable    ${TEST_SUITE_START_TIME}    ${start_time}

    Check Bts Disc Usage
    Update Gnb Software    update_sw_with_activation=${False}
    Check Bts Disc Usage
    Activate Gnb Software
    Check If Bts Is Correctly Configured    rmods_number=${RMODS_NUMBER}
    taf.ue.cus.Execute Command    command=config remote update tgr
    Configure Required IP Addresses    ip_addresses=${SIM_GNB_MME_IP_ADDRESSES}

    Start Wts    lua_config=${WTS_SETUP_FILE}    check_version=True    timeout=600
    Check If Bts Is Onair    cells_number=${CELLS_NUMBER}    skip_iot=${True}

    Start X2 Links Simulation
    Start Test Environment Monitoring

[POST]4G_FSMF_robustness_testing
    [Documentation]    Performs cleanup and data collection after test execution.
    ...
    ...    Execution Steps:
    ...    1. Snapshot Collection:
    ...       - Gathers BTS snapshot if test failed
    ...    2. Environment Data:
    ...       - Stops system monitoring
    ...       - Collects CPU and memory statistics
    ...    3. Traffic Cleanup:
    ...       - Stops all UE data traffic
    ...       - Detaches UEs
    ...    4. Connection Cleanup:
    ...       - Stops WTS
    ...       - Terminates X2 links simulation
    ...       - Closes monitoring processes

    Run Keyword If Test Failed    Get Snapshot With Admin
    Stop Test Environment Monitoring
    Get Cpu And Memory Usage During Test
    Stop Data Traffic And Detach Ues
    Stop Wts
    Stop X2 Links Simulation

# -- test steps --
Start Data Traffic
    [Documentation]    Initiates data traffic for all configured UEs
    ...    Distributes UEs across available cells and starts UDP traffic

    ${cell_pci}=    Set Variable    ${1}
    ${cells_call_capable_amount}=    Get Length    ${CELLS_CALL_CAPABLE}

    FOR    ${i}    IN RANGE    ${UE_AMOUNT}
        ${ue_id}=    Evaluate    ${i} + 1
        Run Uex Command    ue_attach
        ...    id=${ue_id}
        ...    cell=${CELLS_CALL_CAPABLE}[${${cell_pci} - 1}]

        Sleep    500ms    reason=Wait for all msg send after attach ue

        Run Uex Command    trf_data_start
        ...    ue=${ue_id}
        ...    dir=dl_and_ul
        ...    protocol=udp
        ...    Mbps=${UE_TRAFFIC_MBPS}
        ...    trf_id=1

        ${cell_pci}=    Evaluate    (${cell_pci} % ${cells_call_capable_amount}) + 1
    END

Perform Data Traffic
    [Documentation]    Collects BTS system metrics during ongoing traffic for ${DATA_TRAFFIC_TIME_MINUTES} minutes.
    ...
    ...    Periodically (every 5 minutes):
    ...    1. Collects BTS system information
    ...    2. Reports system memory usage
    ...
    ...    Note: This keyword only collects metrics.
    ...    It does not control or maintain the traffic itself.

    Repeat Keyword    ${DATA_TRAFFIC_TIME_MINUTES} minutes    Monitor Bts Usage And Wait 5 Minutes

Lock Unlock Cells When The Bts Memory Utilization Is High
    [Documentation]    Performs cell lock/unlock operations during high memory utilization period.
    ...
    ...    Executes for ${LOCK_UNLOCK_TIME_MINUTES} minutes:
    ...    - Alternates between locking and unlocking cells
    ...    - Collects BTS system information at each operation
    ...    - Reports memory usage during operations
    ...
    ...    See 'Lock Unlock Cells Every 6 Minutes' for detailed implementation.

    Repeat Keyword    ${LOCK_UNLOCK_TIME_MINUTES} minutes    Lock Unlock Cells Every 6 Minutes

Get Snapshot When The Bts Memory Utilization Is High
    [Documentation]    Collects BTS snapshot during high memory utilization.
    ...
    ...    Actions:
    ...    1. Collects BTS system information
    ...    2. Reports current memory usage
    ...    3. Gathers BTS snapshot

    ${bts_system_information}=    Run Keyword And Continue On Failure    Get Bts System Information    alias=get_snapshot
    Log System Used Memory    ${bts_system_information}    get_snapshot
    Get Snapshot With Admin

Verify Bts behavior During Test Case Execution
    [Documentation]    Verifies BTS behavior at the end of test execution.
    ...
    ...    Actions:
    ...    1. Collects BTS system information
    ...    2. Reports final memory usage statistics
    ...    3. Verifies no unexpected alarms occurred
    ...       - Checks active alarms
    ...       - Checks alarms reported during test
    ...       - Excludes whitelisted alarms
    ...
    ...    Note: Alarm verification uses ${TEST_SUITE_START_TIME} as reference point.
    ...    See 'Check If Unexpected Alarm Occurred' for detailed alarm analysis.

    ${bts_system_information}=    Run Keyword And Continue On Failure    Get Bts System Information    alias=test_end
    Log System Used Memory    ${bts_system_information}    test_end
    Check If Unexpected Alarm Occurred

Report System Used Memory Kpis
    [Documentation]    Reports memory utilization KPIs for different test phases.
    ...
    ...    Reports memory statistics for three test phases:
    ...    1. Traffic generation phase (perform_traffic)
    ...       - Calculates KPIs based on last 12 measurements
    ...    2. Cell lock/unlock operations (lock_unlock_cells)
    ...    3. Snapshot collection (get_snapshot)
    ...
    ...    Each phase reports "System used memory" parameter ratio
    ...    to reporting portal for analysis.

    Run Keyword And Continue On Failure    Report Parameter Summary To Reporting Portal
    ...    System used memory
    ...    ratio
    ...    perform_traffic
    ...    ${12}
    Run Keyword And Continue On Failure    Report Parameter Summary To Reporting Portal
    ...    System used memory
    ...    ratio
    ...    lock_unlock_cells
    Run Keyword And Continue On Failure    Report Parameter Summary To Reporting Portal
    ...    System used memory
    ...    ratio
    ...    get_snapshot

# -- internals --
Start X2 Links Simulation
    [Documentation]    Initializes X2 links simulation to create test environment with virtual neighboring BTSes.
    ...
    ...    Purpose:
    ...    Creates virtual environment of 250 neighboring BTSes required for proper test execution.
    ...    Without simulated X2 neighbors, the test scenario would not reflect real network conditions
    ...    where BTS operates with multiple peer connections.
    ...
    ...    Critical Steps:
    ...    1. Initializes X2 simulation environment
    ...    2. Starts X2AP simulation
    ...    3. Verifies all 250 X2 connections are established
    ...    4. Activates simulation scenario
    ...
    ...    Note: Test execution will fail if required number of X2 links (250)
    ...    is not established after 5 minutes (10 retries × 30 seconds).

    Initialize Emssim Logs Directory
    ${served_cells}=    Evaluate    [{"CELL_ID": i + 1, "PCI": i + 1} for i in range(10)]
    ${gu_group_id_list}=    Evaluate    [{"MCC": "450", "MNC": f"{i + 1}", "MME_GROUP_ID": i + 1} for i in range(16)]
    ${broadcast_plmns}=    Evaluate    [{"MCC": "450", "MNC": f"{i + 1}"} for i in range(5)]
    ta_emss.Xterm Setup
    ...    bts_ip_addr=10.0.1.2
    ...    enbsim_ip_addr_begin=10.0.201.1
    ...    enbsim_ip_addr_end=10.0.201.250
    ...    enbsim_ip_addr_mask=${24}
    ...    enbsim_eth_if=eth3
    ...    init_enb_pci_max=${503}
    ...    init_enb_enb_id=${4001}
    ...    init_enb_mcc=440
    ...    init_enb_mnc=08
    ...    init_enb_tac=${1}
    ...    init_enb_dl_earfcn=${4900}
    ...    init_enb_dl_bandwidth=${10}
    ...    init_enb_served_cells=${served_cells}
    ...    init_enb_gu_group_id_list=${gu_group_id_list}
    ...    init_enb_broadcast_plmns=${broadcast_plmns}
    ...    x2ap_setup_period=${15}
    ...    x2ap_setup_retries=${3}
    ...    x2ap_reset_period=${15}
    ...    x2ap_reset_retries=${3}
    ...    enb_configuration_update_min=${60}
    ...    enb_configuration_update_max=${300}
    ...    x2_reset_min=${300}
    ...    x2_reset_max=${360}
    ...    verbose=True
    ...    debug=False
    ta_emss.Xterm Start    x2ap=${TRUE}
    FOR    ${i}    IN RANGE    10
        Sleep    30 seconds    reason=Wait for X2 links status connected
        ${init}    ${connected}    ${closed}=    ta_emss.Xterm Status Get    x2ap=${TRUE}
        IF    '${connected}' == '250'
            ta_emss.Xterm Start    scenario=${TRUE}
            BREAK
        END
    END
    IF    '${connected}' != '250'    Fail    msg=Only ${connected} X2 links connected

Initialize Emssim Logs Directory
    [Documentation]    Sets up logging directory for X2 simulation.
    ...
    ...    Actions:
    ...    1. Removes old emssim logs if present
    ...    2. Creates symbolic link from /var/log/emssim to test logs directory
    ...
    ...    Usage:
    ...    This keyword should be called before starting X2 simulation
    ...    to ensure proper log collection.

    ${logs_dir}=    Prepare Logs Directory Path    emssim
    OperatingSystem.Run    sudo rm -rf /var/log/emssim
    OperatingSystem.Run    sudo ln -s ${logs_dir} /var/log/emssim

Start Test Environment Monitoring
    [Documentation]    Initiates system resource monitoring for test execution.
    ...
    ...    Monitors:
    ...    - CPU usage (mpstat -P ALL -o JSON 3 1)
    ...    - RAM usage (free -h)
    ...
    ...    Data collected every 60 seconds and stored in ${ENV_MONITOR_OUTPUT_DIR}.
    ...    Used later for performance analysis and troubleshooting.

    ${logs_dir}=    Prepare Logs Directory Path    test_env_monitoring

    ${env_monitor}=    Process.Start Process
    ...    bash ${ENV_MONITOR_SCRIPT}
    ...    shell=True
    ...    stdout=${logs_dir}/output.txt
    ...    stderr=STDOUT

    Set Suite Variable    ${ENV_MONITOR_PROCESS}    ${env_monitor}

Get Snapshot With Admin
    [Teardown]    admin.Teardown    connection=snapshot

    ${logs_dir}=    Prepare Logs Directory Path    snapshot
    admin.Connect To    bts_host=${__LOCAL_BTS_IP__}    admin_api_log_dir=${logs_dir}    name=snapshot
    admin.Collect Snapshot    ${logs_dir}/${__DEFAULT_SNAPSHOT_FILE_NAME__}    timeout=840    connection=snapshot

Stop Test Environment Monitoring
    Process.Terminate Process    ${ENV_MONITOR_PROCESS}

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

Stop Data Traffic And Detach Ues
    Run Uex Command    trf_data_stop    ue=1..${UE_AMOUNT}    execution_rate=10
    Run Uex Command    ue_detach    all    rate=10

Stop X2 Links Simulation
    ta_emss.Xterm Stop    x2ap=${TRUE}
    ta_emss.Xterm Teardown

Monitor Bts Usage And Wait 5 Minutes
    [Documentation]    Monitors BTS system information and logs memory usage
    ...    Waits for specified interval between monitoring actions

    ${bts_system_information}=    Run Keyword And Continue On Failure
    ...    Get Bts System Information
    ...    alias=perform_traffic

    Log System Used Memory    ${bts_system_information}    perform_traffic

    Sleep    ${MONITORING_INTERVAL_MINUTES} minutes    reason=Wait before next monitoring action

Get Bts System Information
    [Documentation]    Retrieves and parses BTS system information using aashell CLI.
    ...
    ...    Actions:
    ...    1. Executes 'sysinfo -s' command on BTS via taf.ccs.aashell
    ...    2. Parses command output using Parse Aashell Sysinfo Command Output
    ...    3. Stores results in ${BTS_SYSTEM_INFORMATIONS} for later analysis
    ...
    ...    Arguments:
    ...    - alias: Identifier for the collected information (default=default)
    ...
    ...    Returns:
    ...    - Parsed system information dictionary from last request
    [Arguments]    ${alias}=default
    [Return]    ${parsed_bts_system_information}
    [Teardown]    aashell_cli.Teardown    alias=sysinfo    force=True

    aashell_cli.Create Aashell Cli    name=sysinfo
    aashell_cli.Setup    alias=sysinfo
    ${bts_system_information}=    aashell_cli.Execute Aashell Command    name=sysinfo    command=sysinfo -s
    ${parsed_bts_system_information}=    Parse Aashell Sysinfo Command Output    ${bts_system_information}    ${alias}
    Append To List    ${BTS_SYSTEM_INFORMATIONS}    ${parsed_bts_system_information}

Log System Used Memory
    [Documentation]    Reports system memory usage statistics at WARN level.
    ...
    ...    Logs message containing:
    ...    - Timestamp of measurement
    ...    - Current system used memory value
    ...    - Memory usage ratio (used/total)
    ...    - Operation alias for context
    ...
    ...    Arguments:
    ...    - bts_system_information: Dictionary with system metrics
    ...    - alias: Context identifier (default=default)
    [Arguments]    ${bts_system_information}    ${alias}=default

    ${output}=    Catenate    SEPARATOR=,${SPACE}
    ...    timestamp: ${bts_system_information}[timestamp]
    ...    Current used memory : ${bts_system_information}[System used memory][current]
    ...    Used memory ratio: ${bts_system_information}[System used memory][ratio]
    ...    Alias: ${alias}
    Log    ${output}    level=WARN

Lock Unlock Cells Every 6 Minutes
    [Documentation]    Performs cell lock/unlock operations and monitors system
    ...    Executes delta commissioning for lock/unlock operations

    ${bts_system_information}=    Run Keyword And Continue On Failure
    ...    Get Bts System Information
    ...    alias=lock_unlock_cells

    Log System Used Memory    ${bts_system_information}    lock_unlock_cells
    Perform Delta Commissioning    ${DELTA_LOCK_CELLS}
    Sleep    6 minutes    reason=Wait before unlocking cells

    ${bts_system_information}=    Run Keyword And Continue On Failure
    ...    Get Bts System Information
    ...    alias=lock_unlock_cells

    Log System Used Memory    ${bts_system_information}    lock_unlock_cells
    Perform Delta Commissioning    ${DELTA_UNLOCK_CELLS}
    Sleep    6 minutes    reason=Wait before locking cells

Perform Delta Commissioning
    [Arguments]    ${path_to_delta}
    [Teardown]    admin.Teardown    connection=delta_commissioning

    ${logs_dir}=    Prepare Logs Directory Path    admin_logs/delta_commissioning
    admin.Connect To    bts_host=${__LOCAL_BTS_IP__}    admin_api_log_dir=${logs_dir}    name=delta_commissioning

    admin.Perform Delta Recommissioning
    ...    delta_file=${path_to_delta}
    ...    skip_parameter_relation_errors=True
    ...    connection=delta_commissioning

Check If Unexpected Alarm Occurred
    [Documentation]    Verifies if any unexpected alarms occurred during test execution.
    ...
    ...    Alarm Analysis:
    ...    1. Gets active and historical alarms
    ...    2. Filters out whitelisted alarms
    ...
    ...    Time-based Filtering:
    ...    Reports non-whitelisted alarms that:
    ...    - Are currently active during test execution
    ...    - Were reported during test execution and are still active
    ...    - Were reported and cleared during test execution
    ...
    ...    Note: ${TEST_SUITE_START_TIME} is used as reference point.
    ...    Any alarm cleared before test start is ignored.
    ...
    ...    Fails test case if any unexpected alarm is detected.

    ${unexpected_alarms}    Get Historic And Active Alarms    alarms_whitelist=${ALARMS_WHITELIST}
    FOR    ${a}    IN    @{unexpected_alarms}
        ${cleared_time}=    Evaluate    $a.get('clearedTime', '')
        IF    $cleared_time
            ${cleared_time_converted}=    Convert Date    ${cleared_time}    epoch    exclude_millis=yes
        ELSE
            ${cleared_time_converted}=    Set Variable
        END
        Continue For Loop If
        ...    '${TEST_SUITE_START_TIME}' > '${cleared_time_converted}' and '${cleared_time_converted}' != ''
        Run Keyword And Continue On Failure    Fail    msg=Unexpected alarm detected: ${a.alarmDetail}
    END

Report Parameter Summary To Reporting Portal
    [Documentation]    Reports BTS parameter statistics to the reporting portal.
    ...
    ...    Arguments:
    ...    - parameter_name: Name of the parameter to report (e.g., "System used memory")
    ...    - value_type: Type of value to analyze (e.g., "ratio")
    ...    - alias: Context identifier for the measurement
    ...    - last_n: Optional, number of last measurements to analyze
    ...
    ...    Reports calculated statistics as KPIs to the reporting portal:
    ...    - Target value: 0
    ...    - Category: Bts resources utilization
    ...    - Description: 4G FSMF robustness testing
    [Arguments]    ${parameter_name}    ${value_type}    ${alias}    ${last_n}=${NONE}

    ${parameter_summary}=    Analyze Parameter History
    ...    ${BTS_SYSTEM_INFORMATIONS}
    ...    ${parameter_name}
    ...    ${value_type}
    ...    ${alias}
    ...    ${last_n}

    IF    not $parameter_summary    Fail    Parameter ${parameter_name} summary is empty

    ${unit}=    Pop From Dictionary    ${parameter_summary}    unit    ${None}

    FOR    ${calculation}    ${value}    IN    &{parameter_summary}
        taf_reporting_portal.Report Kpi Results
        ...    target=0
        ...    name=Parameter ${parameter_name} (${value_type}), alias ${alias}, calculation ${calculation}
        ...    visible_to_db=True
        ...    value=${value}
        ...    kpi_type=int
        ...    description=4G FSMF robustness testing
        ...    category=Bts resources utilization
        ...    unit=${unit}
        ...    comparison_operator=>
    END

Check Bts Disc Usage

    ${logs_dir}=    Prepare Logs Directory Path    space_usage
    ${smod_tmp_dir}=    Set Variable    /tmp/space_usage
    ${output_file_path}=    Set Variable    /tmp/space_usage.tar.gz
    ${cmds}=    Create List
    ...    rm -rf ${smod_tmp_dir}*
    ...    mkdir --parents ${smod_tmp_dir}
    ...    df -h >> ${smod_tmp_dir}/file_system.txt 2>/dev/null
    ...    du -ah /ffs/stb/ >> ${smod_tmp_dir}/stb_files.txt 2>/dev/null
    ...    du -sh /ffs/stb/ >> ${smod_tmp_dir}/stb_folder.txt 2>/dev/null
    ...    du -ah /ffs/run/ >> ${smod_tmp_dir}/run_files.txt 2>/dev/null
    ...    du -sh /ffs/run/config/ >> ${smod_tmp_dir}/run_config_folder.txt 2>/dev/null
    ...    tree / >> ${smod_tmp_dir}/tree_root.txt 2>/dev/null
    ...    tar -czf ${output_file_path} ${smod_tmp_dir}

    FOR    ${cmd}    IN    @{cmds}
        Run On Smod   ${cmd}
    END

    Fetch From Smod    ${output_file_path}    ${logs_dir}

Activate Gnb Software
    IF    robot.utils.is_truthy($__DISABLE_BTS_SW_UPDATE__)    RETURN    ${FALSE}
    Activate Planned Sw

Activate Planned Sw
    [Teardown]    admin.teardown    connection=activate_planned_sw

    ${logs_dir}=    Prepare Logs Directory Path    activate_planned_sw
    admin.Connect To    bts_host=${__LOCAL_BTS_IP__}    admin_api_log_dir=${logs_dir}    name=activate_planned_sw
    ${output}=    admin.Get Software Info    timeout=30    connection=activate_planned_sw

    IF    '${output}[Planned SW version]'!='${None}'
        admin.Do Sw Activate
        ...    target_bd=TargetBD_${output}[Planned SW version].xml
        ...    timeout=2160
        ...    connection=activate_planned_sw
        Sleep    3 minutes    reason=Wait for BTS reset after software update
    END
