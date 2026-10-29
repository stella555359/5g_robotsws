*** Settings ***
Documentation    Common testing procedures.
...
...    Flags for turning on or off functionalities in test automation.
...    ===============================================================
...    KEEP ALL FLAGS IN ONE PLACE (THIS FILE).
...    ===============================================================
...    Those are `Options` and can be safely changed from command line or set in QC "Automation Options" field.
...    To use it in test script, import file as `Variables` in `Settings` section.
...
...    Available flags:
...    __MARVIN_SIDE__ - Defines where marvin logs are sent. By default, dev (development).
...        Other option, prod (production).
...    __DISABLE_MARVIN__ - Disables marvin logging. By default, NO (logging enabled).
...    __DISABLE_IPHY_SYSLOG__ - Disables AP/IPHY syslog collection from 192.168.200.126 interface.
...        By default, NO (logging enabled).
...    __DISABLE_SYSLOG_COMPRESSION__ - Disables BTS and AP/IPHY syslog output compression.
...        By default both are compressed.
...    __DISABLE_SOS_REPORT__ - Disables SosReport gathering at the end of test execution.
...        By default, NO (SosReport is gathered).
...    __KNIFE_TESTING__ - Forces test script to download BTS SW build from provided URL (artifactory URL).
...        By default, EMPTY (BTS SW build from ENB_BUILD will be downloaded).
...    __DISABLE_BTS_SW_UPDATE__ - Disables BTS SW update in test.
...        Test execution will be done on BTS SW build from TL reservation. By default, NO (run BTS SW update).
...    __ENABLE_EMIL__ - Enables Emil logging via DCAP/UTF. By default, NO (disabled).
...    __ENABLE_WTS_BIP__ - Enables WTS BIP logging.  By default, NO (disabled).
...    __ENABLE_L2_TTI__ - Enables BTS L2PS TTI traces logging. By default, NO (disabled).
...
...    ===============================================================
...    BTS SW UPDATE
...    ===============================================================
...
...    Disabling:
...    BTS SW update and SW package download can be disabled using flag __DISABLE_BTS_SW_UPDATE__ set to YES.
...    Flag can be provided either via QC automation options or CLI parameters when executed manually.
...
...    Default usage:
...    BTS SW is updated with SW version from CLI parameter ENB_BUILD on ENB_BRANCH. It is provided in
...    regression and can be used manually. ENB_BUILD BTS SW is downloaded in preconditions.
...
...    SW package download from url:
...    BTS SW can be updated using SW package downloaded from url. User can provide URLs using parameter __KNIFE_TESTING__.
...    In case of multi source download, URLs should be separated with semicolons. Providing SW package using url does not
...    change build version reported to Reporting Portal, see custom SW version reporting.
...
...    SW package in any WFT state:
...    It is possible to test SW package regardless on it's WFT released state. Functionality can be used also to test more
...    complex SW update paths.
...    After making reservation with BUILD_X or BUILD_X+SM_BUILD user can provide target build with parameter ENB_BUILD_CUSTOM.
...    ENB_BUILD_CUSTOM build branch needs to be provided with parameter ENB_BRANCH_CUSTOM if it differs from BUILD_X branch.
...    Providing ENB_BUILD_CUSTOM by default changes SW version reported to Reporting Portal. It can be disabled by setting
...    flag __CHANGE_REPORTED_SW_BUILD__ to NO.
...
...    Custom SW version reporting:
...    If flag __CHANGE_REPORTED_SW_BUILD__ is set to YES, build reported to Reporting Portal will be acquired from global
...    variable ENB_TEST_BUILD_PATH set in keyword Prepare Tested Build.

# -- std libs --
Library    OperatingSystem
Library    Process
Library    DateTime
Library    String
Library    Collections

# -- taf/ute libs --
Library    taf.sbts.oam.coam.admin    WITH NAME    admin
Library    ute_wtssim    WITH NAME    wtssim
Library    taf.sw.reporting_portal    WITH NAME    taf_reporting_portal

# -- internals --
Library    ./main.py

# -- custom listeners --

# -- resources --
Resource    ../../resources/shell/shell.resource
Resource    ./dcap/keywords.robot

*** Variables ***
${SHARED_RESOURCES}    ${CURDIR}    # so path to *this* directory is expanded correctly
${SUITE LOGS}    ${OUTPUT DIR}/Suite_logs

${__RUNTIME_NRBTS_IM_PATH__}    //NRBTS_R-*
${__RUNTIME_NRCELL_IM_PATH__}    //NRCELL_R-*
${__RUNTIME_RMOD_IM_PATH__}    //RMOD_R-*
${__LOCAL_BTS_IP__}    192.168.255.129
${__SYSLOG_IP__}    192.168.255.126
${__IPHY_SYSLOG_IP__}    192.168.200.126
${__DEFAULT_SNAPSHOT_FILE_NAME__}    snapshot.zip
@{__EDAEMON_PORTS__}    10000    30000
@{__IP_ADDRESSES__}
...    10.0.1.131    10.0.1.133    10.0.1.134
...    10.0.1.135    10.0.1.136    10.0.1.137
${__EGATE_COMMAND_TIMEOUT___}    10s
@{__QUOSFLOWS_PARAMS__}    add    del    modify

${__SSHPASS_TO_ENB_CMD__}    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129

# Set custom size for single SysLog file, in MiB. Value must be between 0 and 65535:
${SYSLOG_SIZE_LIMIT}    1024

# Those are `Options` and can be safely changed from command line or set in QC "Automation Options" field:
## Marvin
${__MARVIN_SIDE__}    dev
${__DISABLE_MARVIN__}    NO
## Syslog
${__DISABLE_IPHY_SYSLOG__}    NO
${__DISABLE_SYSLOG_COMPRESSION__}    NO
## SosReport
${__DISABLE_SOS_REPORT__}    NO
## BTS SW update
${__KNIFE_TESTING__}    ${EMPTY}
${__ENB_BUILD_CUSTOM__}    ${EMPTY}
${__ENB_BRANCH_CUSTOM__}    ${EMPTY}
${__DISABLE_BTS_SW_UPDATE__}    NO
${__CHANGE_REPORTED_SW_BUILD__}    NO
## Extended logging
${__ENABLE_EMIL__}    NO
${__ENABLE_WTS_BIP__}    NO
${__ENABLE_L2_TTI__}    NO

*** Keywords ***
# -- common --
Prepare Testing Environment
    [Documentation]
    ...    Does mundane preparation tasks
    COMMENT    Add stuff here as setup steps become more and more repetitive
    [Tags]    PRIVATE
    Install Jcsl
    Prepare Tested Build

Prepare Tested Build
    [Documentation]    Download tested SW build. Change reporting build if needed.

    IF    robot.utils.is_truthy($__DISABLE_BTS_SW_UPDATE__)    RETURN    ${FALSE}
    ${enb_test_build_path}=    Download Tested Build    /home/ute/Downloads
    Set Global Variable    ${ENB_TEST_BUILD_PATH}
    IF    robot.utils.is_truthy($__CHANGE_REPORTED_SW_BUILD__)
        ${tested_build}=    Get Regexp Matches
        ...    ${ENB_TEST_BUILD_PATH}
        ...    SBTS[0-9A-Z]+_(ENB|FSM3)_\\d{4}_\\d{6}_\\d{6}
        taf_reporting_portal.Set Sw Build    sw_build=${tested_build}[0]
    END

Download Tested Build
    [Documentation]    Download BTS SW build to requested location.
    ...
    ...    Args:
    ...      - output_dir: destination folder for downloaded SW build package
    ...
    ...    Testing SW knife builds:
    ...      - In QC Automation Options add CLI parameter __KNIFE_TESTING__
    ...      - Provide complete url to requested knife build
    ...      - If there is more than one url where build is stored, separate urls with semicolon
    ...
    ...    Testing custom builds:
    ...      - CLI parameters __ENB_BUILD_CUSTOM__ and __ENB_BRANCH_CUSTOM__ can be used to select
    ...        custom build. It needs to be available on artifactory.
    ...        __ENB_BRANCH_CUSTOM__ needs to be provided if it differs from ENB_BRANCH.
    ...
    ...    Returns:
    ...      - complete path to downloaded BTS SW build
    [Arguments]    ${output_dir}

    IF    $__KNIFE_TESTING__
        @{knife_uris}=    Split String    ${__KNIFE_TESTING__}    separator=;
        ${build_path}=    Download From Many    ${output_dir}    @{knife_uris}
        RETURN    ${build_path}
    ELSE IF    $__ENB_BUILD_CUSTOM__
        IF    $__ENB_BRANCH_CUSTOM__
            ${branch}=    Set Variable    ${__ENB_BRANCH_CUSTOM__}
        ELSE
            ${branch}=    Set Variable    ${ENB_BRANCH}
        END
        ${artifacts}=    Download Build Artifacts With Aria
        ...    ${__ENB_BUILD_CUSTOM__}
        ...    ${branch}
        ...    ${output_dir}
        ...    base
        Set Global Variable    ${__CHANGE_REPORTED_SW_BUILD__}    YES
        RETURN    ${artifacts}[base]
    ELSE
        ${artifacts}=    Download Build Artifacts With Aria
        ...    ${ENB_BUILD}
        ...    ${ENB_BRANCH}
        ...    ${output_dir}
        ...    base
        RETURN    ${artifacts}[base]
    END

Start Mandatory Logging
    [Documentation]    Starts suite level SysLog and setups default Admin session
    [Tags]    PRIVATE
    OperatingSystem.CREATE DIRECTORY    ${SUITE LOGS}/syslog
    Start Collecting Syslog    ${SUITE_LOGS}/syslog
    admin.Setup Admin    bts_host=${__LOCAL_BTS_IP__}    bts_port=443    admin_api_log_dir=${SUITE LOGS}    alias=default

Get Active Bts Alarms
    [Teardown]    admin.Teardown    connection=get_active_alarms
    [Documentation]    Logs active alarms details as warnings.

    ${logs_dir}=    Prepare Logs Directory Path    admin_logs/get_active_alarms
    admin.Connect To    bts_host=${__LOCAL_BTS_IP__}    admin_api_log_dir=${logs_dir}    name=get_active_alarms
    ${alarms}=    admin.Get Active Alarms    timeout=120    connection=get_active_alarms
    FOR    ${a}    IN    @{alarms}
        LOG    ALARM [A:${a.alarmId}|F:${a.faultId}|${a.severity}] ${a.alarmName} - ${a.alarmDetail}
    END

Get Historic And Active Alarms
    [Arguments]    ${alarms_whitelist}
    [Teardown]    admin.teardown    connection=get_hist_active_alarms

    ${unexpected_alarms}=    Create List
    ${logs_dir}=    Prepare Logs Directory Path    admin_logs/get_hist_active_alarms
    admin.connect_to    bts_host=${__LOCAL_BTS_IP__}    admin_api_log_dir=${logs_dir}    name=get_hist_active_alarms
    ${alarms}=    admin.get_historic_alarms    load_history=True    timeout=120    connection=get_hist_active_alarms
    ${alarms_active}=    admin.get_active_alarms    timeout=120    connection=get_hist_active_alarms
    Append To List    ${alarms}    @{alarms_active}
    ${body}=    Set Variable
    FOR    ${a}    IN    @{alarms}
        ${fault_severity}=    Set Variable If
        ...    '${a.severity}' == 'Minor'    <td style="background-color: yellow">${a.severity}</td>
        ...    '${a.severity}' == 'Warning'    <td style="background-color: blue">${a.severity}</td>
        ...    '${a.severity}' == 'Major'    <td style="background-color: orange">${a.severity}</td>
        ...    '${a.severity}' == 'Critical'    <td style="background-color: red">${a.severity}</td>
        ...    <td>${a.severity}</td
        IF    '${a.alarmDetail}' not in ${alarms_whitelist}
            ${alarm_detail}=    Set Variable    <td style="background-color: red">${a.alarmDetail}</td>
            Append To List    ${unexpected_alarms}    ${a}
        ELSE
            ${alarm_detail}=    Set Variable    <td>${a.alarmDetail}</td>
        END
        ${cleared_time}=    Evaluate    $a.get('clearedTime', '')
        IF    $cleared_time
            ${cleared_time}=    Convert Date    ${cleared_time}    result_format=datetime    date_format=%Y%m%d%H%M%S.%f%z
            ${a.clearedTime}=    Set Variable    ${cleared_time}
        END
        ${a.btsObservationTime}=    Convert Date    ${a.btsObservationTime}    result_format=datetime    date_format=%Y%m%d%H%M%S.%f%z
        ${body}=    Catenate    SEPARATOR=
        ...    ${body}<tr>
        ...    <td>${a.btsObservationTime}</td>
        ...    <td>${cleared_time}</td>
        ...    ${fault_severity}
        ...    <td>${a.alarmId}</td>
        ...    <td>${a.faultId}</td>
        ...    <td>${a.alarmName}</td>
        ...    ${alarm_detail}</tr>
    END
    ${log_output}=    Catenate    SEPARATOR=
    ...    <table border="1">
    ...    <th>Observation time</th>
    ...    <th>Clearing time</th>
    ...    <th>Fault severity</th>
    ...    <th>Alarm Id</th>
    ...    <th>Fault Id</th>
    ...    <th>Alarm name</th>
    ...    <th>Alarm detail</th>
    ...    ${body}</table>
    Log    ${log_output}    level=WARN    html=True
    [Return]    ${unexpected_alarms}

Collect Mandatory Logs
    [Documentation]    Saves suite level SysLogs, default infomodel ims2, Snapshot, and SosReport
    [Tags]    PRIVATE
    # saves suite level infomodel
    admin.Collect Infomodel Log From Current Session    ${SUITE LOGS}/infomodel_default.ims2    timeout=240    connection=default
    admin.Teardown Admin    connection=default

    # stops writing to syslog files, and compresses them
    Stop Collecting Syslog
    IF    robot.utils.is_falsy($__DISABLE_SYSLOG_COMPRESSION__)
        OperatingSystem.Run    find ${SUITE LOGS}/syslog -type f ! -name "*.zst" -exec zstd --rm '{}' \\;
    END

    IF    robot.utils.is_falsy($__DISABLE_SOS_REPORT__)
        Run Sosreport Script
    END

Run Sosreport Script
    [Documentation]    Collects AirPhone snapshot and other diagnostic logs. Does nothig if NR RAT is not configured.
    ${is_lte_rat}    ${is_nr_rat}=    Get Configured Rats
    IF    $is_nr_rat
        ${workdir}=    Set Variable    /opt/iphy/latest/sosReport_ASIL
        ${sosreport_dir}=    Prepare Logs Directory Path    SosReport    ${FALSE}
        Change Sosreport Temporary Directory
        Disable Bip Logging In Sosreport
        OperatingSystem.Run    rm ${workdir}/SosReport*.tgz
        Process.Run Process    bash ./sosReport_ASIL.sh -nc    shell=${TRUE}    cwd=${workdir}    stdout=${sosreport_dir}/output.txt    stderr=STDOUT
        OperatingSystem.Move File    ${workdir}/SosReport*.tgz    ${sosreport_dir}
    END

Turn On Extended Logging
    [Documentation]    Turns on extended BTS and AP logging for debugging.
    ...
    ...    Run `Turn Off Extended Logging` to stop and gather started logs.
    ...
    ...    If __ENABLE_EMIL__ set to YES - L3 Cplane logs will be gathered.
    ...    If __ENABLE_WTS_BIP__ set to YES - BIP WTS logs will be gathered.
    ...    If __ENABLE_L2_TTI__ set to YES - BTS L2PS TTU logs will be gathered.

    IF    robot.utils.is_truthy($__ENABLE_EMIL__)
        Setup Dcap
        Start Emil Trace
    END

    IF    robot.utils.is_truthy($__ENABLE_WTS_BIP__)
        Start Wts Test Script For Mirroring And Tcpdump
    END

    IF    robot.utils.is_truthy($__ENABLE_L2_TTI__)
        ${tmp_logs_dir_name}=    Evaluate    str(uuid.uuid4())    modules=uuid
        ${tmp_logs_path}=    Set Variable    /home/ute/logs/${tmp_logs_dir_name}
        OperatingSystem.Create Directory    ${tmp_logs_path}
        Start L2 Ps Tti Traces    ${tmp_logs_path}
    END

Turn Off Extended Logging
    [Documentation]    Turns off extended BTS and AP logging for debugging.

    IF    robot.utils.is_truthy($__ENABLE_WTS_BIP__)
        Stop Wts Test Script For Mirroring And Tcpdump
    END

    IF    robot.utils.is_truthy($__ENABLE_L2_TTI__)
        ${tmp_l2_logs_path}=    Stop L2 Ps Tti Traces
        IF    $tmp_l2_logs_path
            ${l2_logs_path}=    Prepare Logs Directory Path    tcpdumps    with_timestamp=${False}
            OperatingSystem.Move Directory    source=${tmp_l2_logs_path}    destination=${l2_logs_path}
        END
    END

    IF    robot.utils.is_truthy($__ENABLE_EMIL__)
        ${emil_logs_path}=    Prepare Logs Directory Path    emil_trace    with_timestamp=${False}
        Stop Emil Trace And Get Results    logs_dir=${emil_logs_path}
        Stop Dcap Controller
    END

Start Wts Test Script For Mirroring And Tcpdump
    [Documentation]    Starts gNB/AP mirroring and tcpdump.
    ${is_lte_rat}    ${is_nr_rat}=    Get Configured Rats
    IF    $is_nr_rat
        ${workdir}=    Set Variable    /opt/iphy/latest
        ${output_logs}=    Prepare Logs Directory Path    wts_test_script_start
        Enable Bip Logging In Sosreport
        TRY
            ${result}=    Process.Run Process    bash ./startTest.sh
            ...    shell=${TRUE}
            ...    cwd=${workdir}
            ...    stdout=${output_logs}/output.txt
            ...    stderr=STDOUT
            Log    WTS test script start return code: ${result.rc}
        EXCEPT
            Log    It was not possible to start gathering BIP logs
        END
    END

Stop Wts Test Script For Mirroring And Tcpdump
    [Documentation]    Stops gNB/AP mirroring and tcpdump. Collects sosReports with gathered logs.
    ${is_lte_rat}    ${is_nr_rat}=    Get Configured Rats
    IF    $is_nr_rat
        ${workdir}=    Set Variable    /opt/iphy/latest
        ${output_logs}=    Prepare Logs Directory Path    wts_test_script_stop
        OperatingSystem.Run    rm ${workdir}/SosReport*.tgz
        TRY
            ${result}=    Process.Run Process    bash ./stopTest.sh
            ...    shell=${TRUE}
            ...    cwd=${workdir}
            ...    stdout=${output_logs}/output.txt
            ...    stderr=STDOUT
            Log    WTS test script stop return code: ${result.rc}
            OperatingSystem.Move File    ${workdir}/SosReport*.tgz    ${output_logs}
        EXCEPT
            Log    It was not possible to gather SosReport with BIP logs
        END
    END

Start L2 Ps Tti Traces
    [Arguments]    ${logs_output_dir}=${None}
    [Documentation]    Starts L2 PS TTI traces gathering.
    ...
    ...    Traces gathering is started in two steps. First, Uplane L2 Trace is started
    ...    using TAF WebEM library. If starting succeed, tcpdump on eth3 interface is started.
    ...    Flag L2_PS_TTI_TRACES_STARTED indicates if tracing started correctly

    ${status}=    Start Uplane L2 Ps Traces
    IF    '${status}' == 'Succeeded'
        IF    not $logs_output_dir
            ${logs_output_dir}=    Prepare Logs Directory Path    tcpdump_l2_ps
        END
        Process.Run Process    chmod    -R    777    ${logs_output_dir}
        Start Tcpdump For L2 Ps Tti Traces    ${logs_output_dir}
        Set Suite Variable    ${TCPDUMP_L2_PS_OUTPUT_DIR}    ${logs_output_dir}
        Set Suite Variable    ${L2_PS_TTI_TRACES_STARTED}    ${True}
    ELSE
        Set Suite Variable    ${L2_PS_TTI_TRACES_STARTED}    ${False}
    END

Stop L2 Ps Tti Traces
    [Documentation]    Stops L2 PS TTI traces gathering and packs gathered logs.

    IF    $L2_PS_TTI_TRACES_STARTED
        ${status}=    Stop Uplane L2 Ps Traces
        Stop Tcpdump For L2 Ps Tti Traces    ${TCPDUMP_L2_PS_OUTPUT_DIR}
        RETURN    ${TCPDUMP_L2_PS_OUTPUT_DIR}
    END
    RETURN    ${None}

Start Uplane L2 Ps Traces
    [Return]    ${process_status}
    [Teardown]    admin.Teardown    connection=start_l2_ps_traces

    ${source_ip}=    Set Variable    10.0.1.2
    ${dscp}=    Set Variable    10
    ${vm_host_ip}=    Run    echo $(hostname -i)
    ${vm_host port}=    Set Variable    1024
    ${l2_data_flow}=    Set Variable    L2Ps

    ${logs_dir}=    Prepare Logs Directory Path    admin_logs/start_l2_ps_traces
    admin.Connect To    bts_host=${__LOCAL_BTS_IP__}    admin_api_log_dir=${logs_dir}    name=start_l2_ps_traces
    TRY
        ${process_status}=    admin.Start Uplane L2 Trace
        ...    source_ip=${source_ip}
        ...    dscp=${dscp}
        ...    destination_ip=${vm_host_ip}
        ...    destination_port=${vm_host port}
        ...    up_sw=${l2_data_flow}
        ...    timeout=120
        ...    connection=start_l2_ps_traces
    EXCEPT
        Log    Starting L2 PS Uplane traces failed with status: ${process_status}.
    END

Start Tcpdump For L2 Ps Tti Traces
    [Arguments]    ${logs_output_dir}
    [Documentation]
    ...    -s0 - snapshot length set to 0. Cature the entire packet, no truncation.
    ...    -n - do not do DNS or service name resolution.
    ...    -vvv - very high verbosity level for packet decoding, more protocol details.

    ${eth_interface}=    Set Variable    eth3
    ${output_file_size_mb}=    Set Variable    500
    ${rotate_files_after}=    Set Variable    100
    ${tcpdump_filter}=    Set Variable    udp port 1024

    Process.Start Process    sudo    tcpdump
    ...    -i    ${eth_interface}
    ...    -s0    -n    -vvv
    ...    -C    ${output_file_size_mb}
    ...    -W    ${rotate_files_after}
    ...    ${tcpdump_filter}
    ...    -w    ${logs_output_dir}/tcpdump_l2_ps.pcap
    ...    alias=tcpdump_l2_ps
    Sleep    5 seconds    msg=Wait for tcpdump to start.
    ${process_status}=    Process.Is Process Running    handle=tcpdump_l2_ps
    IF    not $process_status
        Log    Starting tcpdump for L2 PS failed with status: ${process_status}.
    END

Stop Uplane L2 Ps Traces
    [Return]    ${process_status}
    [Teardown]    admin.Teardown    connection=stop_l2_ps_traces

    ${l2_data_flow}=    Set Variable    L2Ps

    ${logs_dir}=    Prepare Logs Directory Path    admin_logs/stop_l2_ps_traces
    admin.Connect To    bts_host=${__LOCAL_BTS_IP__}    admin_api_log_dir=${logs_dir}    name=stop_l2_ps_traces
    TRY
        ${process_status}=    admin.Stop Uplane L2 Trace
        ...    up_sw=${l2_data_flow}
        ...    trace_type=Component
        ...    timeout=120
        ...    connection=stop_l2_ps_traces
    EXCEPT
        Log    Stopping L2 PS Uplane traces failed with status: ${process_status}.
    END

Stop Tcpdump For L2 Ps Tti Traces
    [Arguments]    ${logs_output_dir}

    ${process_status}=    Process.Is Process Running    handle=tcpdump_l2_ps
    IF    $process_status
        Process.Terminate Process    handle=tcpdump_l2_ps
    ELSE
        Log    Tcpdump for L2 PS is not running.
    END
    OperatingSystem.Run    zstd --rm -q ${logs_output_dir}/*

Change Sosreport Temporary Directory
    [Documentation]    Changes sosReport temporary directory modifying sosReport configuration file.
    ...
    ...    Script sosReport_ASIL.sh uses /tmp directory as default temporary path for AP logs collection.
    ...    When extended AP/EPCsim logging is enabled it is not possible to save all logs in /tmp directory.
    ${tmp_dir_var}=    Set Variable    SOSREPORT_VM_DIR
    ${tmp_dir_new_path}=    Set Variable    /home/ute/sosReport
    OperatingSystem.Remove Directory    ${tmp_dir_new_path}    recursive=${True}
    Change Sosreport Config Variable Value
    ...    conf_variable=${tmp_dir_var}
    ...    conf_variable_value=${tmp_dir_new_path}

Enable Bip Logging In Sosreport
    [Documentation]    Modifies ENABLE_BIP_LOG in sosReport configuration file to enable BIP logging.
    ${bip_logging_var}=    Set Variable    ENABLE_BIP_LOG
    ${bip_logging_enable}=    Set Variable    1
    Change Sosreport Config Variable Value
    ...    conf_variable=${bip_logging_var}
    ...    conf_variable_value=${bip_logging_enable}

Disable Bip Logging In Sosreport
    [Documentation]    Modifies ENABLE_BIP_LOG in sosReport configuration file to disable BIP logging.
    ${bip_logging_var}=    Set Variable    ENABLE_BIP_LOG
    ${bip_logging_enable}=    Set Variable    0
    Change Sosreport Config Variable Value
    ...    conf_variable=${bip_logging_var}
    ...    conf_variable_value=${bip_logging_enable}

Change Sosreport Config Variable Value
    [Arguments]    ${conf_variable}    ${conf_variable_value}

    ${sos_report_cfg}=    Set Variable    /opt/iphy/latest/sosReport.cfg
    ${sos_report_cfg_exists}=    Evaluate    os.path.exists($sos_report_cfg)    modules=os
    IF    $sos_report_cfg_exists
        ${value_before}=    OperatingSystem.Run    sed -nE 's/^${conf_variable}=(.*)$/\\1/p' ${sos_report_cfg}
        Log    ${value_before}
        ${cmd}=    Catenate
        ...    sed -i.bak
        ...    's|^${conf_variable}=.*$|${conf_variable}=${conf_variable_value}|'
        ...    ${sos_report_cfg}
        OperatingSystem.Run    ${cmd}
        ${value_after}=    OperatingSystem.Run    sed -nE 's/^${conf_variable}=(.*)$/\\1/p' ${sos_report_cfg}
        Log    ${value_after}
    END

Prepare Logs Directory Path
    [Arguments]    ${subdir}=${EMPTY}    ${with_timestamp}=${TRUE}
    [Documentation]
    ...    Creates directory for storing logs, based on current execution context.
    ...    An absolute path to created directory is returned.
    [Tags]    PUBLIC
    ${logs_dir}=    main.resolve_logs_directory    ${subdir}    ${with_timestamp}
    OperatingSystem.CREATE DIRECTORY    ${logs_dir}
    [Return]    ${logs_dir}

Cleanup Testing Environment
    [Documentation]
    ...    Does mundane cleanup tasks
    [Tags]    PRIVATE
    COMMENT    Add stuff here as teardown steps become more and more repetitive
    Process.Terminate All Processes

Verify Mrbts State
    [Documentation]    The keyword fails if Mrbts state is not on searched states list
    [Arguments]    @{searched_states}
    [Teardown]    admin.Teardown    connection=verify_mrbts_state

    ${logs_dir}=    Prepare Logs Directory Path    verify_mrbts_state/attempt
    admin.Connect To    admin_api_log_dir=${logs_dir}    name=verify_mrbts_state
    ${mrbts_state}=    admin.Get Mrbts State    timeout=30    connection=verify_mrbts_state
    List Should Contain Value    ${searched_states}    ${mrbts_state}

Verify All Radio Operational State
    [Documentation]    The keyword fails if the number of rmods in the requested states does not matches the actual rmods found by the script
    [Arguments]    ${rmods_number}    @{searched_states}
    [Teardown]    admin.Teardown    connection=verify_radio_state

    ${logs_dir}=    Prepare Logs Directory Path    verify_radio_state/attempt
    admin.Connect To    admin_api_log_dir=${logs_dir}    name=verify_radio_state
    ${radios}=    admin.Get Parameters For All    class_name=RMOD    timeout=30    connection=verify_radio_state
    ${radios_status}=    Evaluate    [(radio["productName"], radio["operationalState"]) for radio in $radios]
    ${radios_correct_state}=    Evaluate    len([radio for radio in $radios_status if radio[1] in "${searched_states}"])
    IF    ${radios_correct_state} != ${rmods_number}    Fail    Not all radios reached required state

Check If Bts Is Correctly Configured
    [Arguments]    ${rmods_number}=2
    [Documentation]    Checks BTS and RMOD runtime objects to determine if eNB is correctly configured

    Wait Until Keyword Succeeds    18 minute    30 seconds    Verify All Radio Operational State    ${rmods_number}    enabled
    Wait Until Keyword Succeeds    10 minute    30 seconds    Verify Mrbts State    Configured    OnAir

Add IP Address
    [Arguments]    ${ip}
    Run On Localhost    sudo ip addr add ${ip}/24 dev eth3
    ${output}=    Run On Localhost    ip addr
    SHOULD CONTAIN    ${output}    ${ip}

Configure Required IP Addresses
    [Arguments]    ${ip_addresses}=${__IP_ADDRESSES__}
    ${ip_addr_output}=    Run On Localhost    ip addr
    FOR    ${addr}    IN    @{ip_addresses}
        Run Keyword If    $addr not in $ip_addr_output    Add Ip Address    ${addr}
    END

Start WTS applications and services
    [Arguments]
    ...    ${lua_config}
    ...    ${check_version}=True
    ...    ${timeout}=480
    [Documentation]    Start WTS applications and services.
    ...    WTS is started in two steps. First lua is loaded, next services are started.
    ...    Keyword will wait for ``CHANGE STATE: ACTIVE`` in Egate console output for correct setup verification.
    ...    ``check_version`` should be set to False for AirPhone WTS.

    wtssim.start_wts_applications    edaemon_ports=${__EDAEMON_PORTS__}    cfg_file=${lua_config}
    wtssim.start_wts_services    timeout=${timeout}    check_version=${check_version}

NSA Setup X2 Link Between ENB and GNB
    [Arguments]    ${enb_id}=1    ${gnb_id}=2    ${timeout}=60
    ${pass_regexp}    SET VARIABLE    X2AP Link .* is up
    ${command}    SET VARIABLE    enb_x2_link_up enb=${enb_id} target=${gnb_id}
    wtssim.execute_egate_command_and_wait_for_data
    ...    cmd=${command}
    ...    pass_regexp=${pass_regexp}
    ...    timeout=${timeout}

Start WTS
    [Arguments]
    ...    ${lua_config}
    ...    ${nr_mode}=SA
    ...    ${check_version}=True
    ...    ${timeout}=480
    [Documentation]    Starts WTS for NR SA or NR NSA mode.
    ...    ``check_version`` should be set to False for AirPhone WTS.
    RUN KEYWORD IF    "${nr_mode}"=="NSA"    Configure Required IP Addresses
    Start WTS applications and services    ${lua_config}    ${check_version}    ${timeout}
    IF    "${nr_mode}"=="NSA"
        Sleep    60 seconds    reason=Wait for full configuration before running X2 link setup
        WAIT UNTIL KEYWORD SUCCEEDS    3x    2s    NSA Setup X2 Link Between ENB and GNB
    END

Get Configured Rats
    [Documentation]    Returns information about configured RATs.
    ...    Two values are returned. One for 4G and one for 5G.
    ...    If RAT is found it's distname is returned, otherwise empty list is provided.
    [Teardown]    admin.Teardown    connection=get_configured_rat

    ${logs_dir}=    Prepare Logs Directory Path    get_configured_rat/attempt
    admin.Connect To    admin_api_log_dir=${logs_dir}    name=get_configured_rat
    ${lte_rat}=    admin.Get Id For Current    class_name=LNBTS    timeout=30    connection=get_configured_rat
    ${nr_rat}=    admin.Get Id For Current    class_name=NRBTS    timeout=30    connection=get_configured_rat
    [Return]    ${lte_rat}    ${nr_rat}

Verify If All S1 Links Are Up
    [Documentation]    The keyword fails if any of configured S1 links is not 'available'
    [Teardown]    admin.Teardown    connection=verify_s1_link_status

    ${logs_dir}=    Prepare Logs Directory Path    verify_s1_link_status/attempt
    admin.Connect To    admin_api_log_dir=${logs_dir}    name=verify_s1_link_status
    ${s1_links}=    admin.Get Parameters For All    class_name=LNMME    timeout=30    connection=verify_s1_link_status
    ${s1_links_unavailable}=    Evaluate    [m for m in $s1_links if m["s1LinkStatus"] != "available"]
    IF    ${s1_links_unavailable}    Fail    msg=Not all MMEs have their S1 link activated

Verify If Lte Cells Are Operational
    [Documentation]    The keyword fails if the number of cells with opertional state 'enabled' is not equal to cells_number
    ...    If skip_iot is True, NB IoT cells are ignored
    [Arguments]    ${cells_number}    ${skip_iot}
    [Teardown]    admin.Teardown    connection=verify_lte_cells_operational

    ${logs_dir}=    Prepare Logs Directory Path    verify_lte_cells_operational/attempt
    admin.Connect To    admin_api_log_dir=${logs_dir}    name=verify_lte_cells_operational
    ${cells}=    admin.Get Cell List    timeout=30    connection=verify_lte_cells_operational
    IF    $skip_iot
        ${cells_status}=
        ...    Evaluate
        ...    [(c["globalCellId"], c["status"]["operationalState"]) for c in $cells["cells"]["lte"] if not (c["technology"] == "NB-IoT-FDD")]
    ELSE
        ${cells_status}=    Evaluate    [(c["globalCellId"], c["status"]["operationalState"]) for c in $cells["cells"]["lte"]]
    END
    ${cells_operational}=    Evaluate    len([c for c in $cells_status if c[1] == "enabled"])
    IF    ${cells_operational} != ${cells_number}    Fail    msg=Not all Lte cells are operational

Verify If Lte Cells Are Not Barred
    [Documentation]    The keyword fails if the number of cells with barring state 'not barred' is not equal to cells_number
    ...    If skip_iot is True, NB IoT cells are ignored
    [Arguments]    ${cells_number}    ${skip_iot}
    [Teardown]    admin.Teardown    connection=verify_lte_cells_not_barred

    ${logs_dir}=    Prepare Logs Directory Path    verify_lte_cells_not_barred/attempt
    admin.Connect To    admin_api_log_dir=${logs_dir}    name=verify_lte_cells_not_barred
    ${cells}=    admin.Get Managed Objects    class_name=LNCEL_L    timeout=30    connection=verify_lte_cells_not_barred
    ${cells}=    Evaluate    [c["parameters"] for c in $cells]
    IF    $skip_iot
        ${cells_status}=
        ...    Evaluate
        ...    [(c["lnCelId"], c["stateInfo"]["barringState"]) for c in $cells if not (c["technology"] == "nbIotFdd")]
    ELSE
        ${cells_status}=    Evaluate    [(c["lnCelId"], c["stateInfo"]["barringState"]) for c in $cells]
    END
    ${cells_not_barred}=    Evaluate    len([c for c in $cells_status if c[1] == "NotBarred"])
    IF    ${cells_not_barred} != ${cells_number}    Fail    msg=Not all Lte cells are not barred

Verify If All Ng Links Are Up
    [Documentation]    The keyword fails if any of configured Ng links is not 'active'
    [Teardown]    admin.Teardown    connection=verify_ng_link_status

    ${logs_dir}=    Prepare Logs Directory Path    verify_ng_link_status/attempt
    admin.Connect To    admin_api_log_dir=${logs_dir}    name=verify_ng_link_status
    ${ng_links}=    admin.Get Managed Objects    class_name=SERVEDAMF_L    timeout=30    connection=verify_ng_link_status
    ${ng_links_status}=    Evaluate    [(s["distName"], s["parameters"]["ngLinkStatus"]) for s in $ng_links]
    ${ng_links_not_active}=    Evaluate    [s for s in $ng_links_status if s[1] != "Active"]
    IF    ${ng_links_not_active}    Fail    msg=Not all AMFs have their Ng link activated

Verify If All Nr Cells Are Operational
    [Documentation]    The keyword fails if the number of cells with opertional state 'enabled' is not equal to cells_number
    [Arguments]    ${cells_number}
    [Teardown]    admin.Teardown    connection=verify_nr_cells_operational

    ${logs_dir}=    Prepare Logs Directory Path    verify_nr_cells_operational/attempt
    admin.Connect To    admin_api_log_dir=${logs_dir}    name=verify_nr_cells_operational
    ${cells}=    admin.Get Cells Info    cell_type=nr    timeout=30    connection=verify_nr_cells_operational
    ${cells_status}=    Evaluate    [(c["globalCellId"], c["status"]["operationalState"]) for c in $cells]
    ${cells_operational}=    Evaluate    len([c for c in $cells_status if c[1] == "enabled"])
    IF    ${cells_operational} != ${cells_number}    Fail    msg=Not all Nr cells are operational

Verify If Nr Cells Are Not Barred
    [Documentation]    The keyword fails if the number of cells with barring state 'unbarred' is not equal to cells_number
    [Arguments]    ${cells_number}
    [Teardown]    admin.Teardown    connection=verify_nr_cells_not_barred

    ${logs_dir}=    Prepare Logs Directory Path    verify_nr_cells_not_barred/attempt
    admin.Connect To    admin_api_log_dir=${logs_dir}    name=verify_nr_cells_not_barred
    ${cells}=    admin.Get Cells Info    cell_type=nr    timeout=30    connection=verify_nr_cells_not_barred
    ${cells_status}=    Evaluate    [(c["globalCellId"], c["status"]["barringStatus"]) for c in $cells]
    ${cells_not_barred}=    Evaluate    len([c for c in $cells_status if c[1] == "unbarred"])
    IF    ${cells_not_barred} != ${cells_number}    Fail    msg=Not all Nr cells are not barred

Check If Bts Is Onair
    [Arguments]    ${cells_number}    ${skip_iot}=${False}
    [Documentation]    Checks if BTS is OnAir. 4G and 5G RATs are supported
    ...    In order to determine if BTS is OnAir following conditions should be true:
    ...    - Mrbts state is OnAir
    ...    - S1 link is available / Ng link is available
    ...    - Cells are operational state enabled
    ...    - Cells are not barred / unbarred

    ${is_lte_rat}    ${is_nr_rat}=    Get Configured Rats
    Wait Until Keyword Succeeds    10 minute    30 seconds    Verify Mrbts State    OnAir
    IF    $is_lte_rat
        Wait Until Keyword Succeeds    10 minute    30 seconds    Verify If All S1 Links Are Up
        Wait Until Keyword Succeeds    10 minute    30 seconds    Verify If Lte Cells Are Operational    ${cells_number}    ${skip_iot}
        Wait Until Keyword Succeeds    10 minute    30 seconds    Verify If Lte Cells Are Not Barred    ${cells_number}    ${skip_iot}
    ELSE IF    $is_nr_rat
        Wait Until Keyword Succeeds    10 minute    30 seconds    Verify If All Ng Links Are Up
        Wait Until Keyword Succeeds    10 minute    30 seconds    Verify If All Nr Cells Are Operational    ${cells_number}
        Wait Until Keyword Succeeds    10 minute    30 seconds    Verify If Nr Cells Are Not Barred    ${cells_number}
    END

Stop WTS
    [Documentation]    Stops WTS proceses

    ${log_path}=    Prepare Logs Directory Path    WTS
    wtssim.stop_and_collect_wts_logs    subdirectory=${log_path}

Translate build to trunk notation if needed
    [Documentation]    Keyword checks if given build is from trunk branch and if that condition is met then its
    ...    build prefix (i.e. FL18A) is changed to its trunk equivalent (so the prefix will be FL00 or SBTS00)
    [Arguments]    ${bts_sw_build}

    ${translated_build}=    Run Keyword If    '_9999_' in '${bts_sw_build}'    Translate Build To Trunk Notation    ${bts_sw_build}
    ${resolved_build}=    Set Variable If    '${translated_build}' != '${NONE}'    ${translated_build}    ${bts_sw_build}
    [Return]    ${resolved_build}

Translate build to trunk notation
    [Documentation]    Keyword replaces FLxx|SBTSxx to FL00|SBTS00 in build name
    [Arguments]    ${bts_sw_build}

    ${translated_bts_sw_build}=    Replace String Using Regexp    ${bts_sw_build}    (?P<release>FL|SBTS).*?_    \\g<release>00_
    [Return]    ${translated_bts_sw_build}

Download build artifacts with Aria
    [Arguments]
    ...    ${bts_sw_build}
    ...    ${bts_sw_branch}
    ...    ${download_directory}
    ...    @{artifacts}
    [Documentation]    Downloads multiple artifacts for given software build.
    ...
    ...    Possible artifact values:
    ...    - base - base build package
    ...    - t1 - t1 build test package
    ...    - t2 - t2 build test package
    ...    - ida - IDA sack with SysCom message definitions
    ...    - snap_doc - snapshot documentation
    ...
    ...    Returns dictionary with pairs '<artifact>': '<path_to_downloaded_file>'

    &{build_artifacts}=    CREATE DICTIONARY
    ${fixed_bts_sw_build}=    Translate build to trunk notation if needed    ${bts_sw_build}

    FOR    ${artifact}    IN    @{artifacts}
        ${file_path}=    Get Build Artifact
        ...    ${artifact}
        ...    ${fixed_bts_sw_build}
        ...    ${bts_sw_branch}
        ...    destination=${download_directory}
        SET TO DICTIONARY    ${build_artifacts}    ${artifact}=${file_path}
    END
    [Return]    ${build_artifacts}

Get Build Artifact
    [Documentation]    Downloads artifact for given sw ``build`` into ``destination`` directory.
    ...
    ...    Allowed values for artifact ``name`` are:
    ...    - ``base``, ``t1``, and ``t2`` for realease and test packages
    ...    - ``ida`` for SysCom message definitions package
    ...    - ``snap_doc`` for Snapshot Documentation
    ...
    ...    Path to retrieved artifact is returned.
    [Arguments]    ${name}    ${build}    ${branch}    ${destination}

    ${package}=    Create Dictionary
    ...    base=${build}_release_BTSSM_downloadable_A54.zip
    ...    t1=${build}_release_BTSSM_downloadable_testpackage_T1_A54.zip
    ...    t2=${build}_release_BTSSM_downloadable_testpackage_T2_A54.zip
    ...    ida=${build}_ida.zip
    ...    snap_doc=${build}_snapshot_documentation.tgz
    ${base_urls}=    Create List
    ...    https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build/${branch}/${build}/
    ...    https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/${branch}/${build}/
    ...    https://artifactory-espoo2.ute.nsn-rdnet.net/artifactory/mn-cosi-sran-central-public-local/build/${branch}/${build}/
    ...    https://artifactory-hz1.ute.nsn-rdnet.net/artifactory/mn-cosi-sran-central-public-remote/build/${branch}/${build}/
    @{uris}=    Create List
    FOR    ${base}    IN    @{base_urls}
        ${uri}=    CATENATE    SEPARATOR=${EMPTY}    ${base}    ${package}[${name}]
        Append To List    ${uris}    ${uri}
    END
    ${local_path}=    Download From Many    ${destination}    @{uris}
    [Return]    ${local_path}

Download From Many
    [Documentation]    Downloads single file from many URIs.
    ...
    ...    File is saved into ``destination`` directory (will be created if does not exist).
    ...
    ...    Returns path to downloaded file on local filesystem.
    [Arguments]    ${destination}    @{URIs}
    # get basename from first URI
    ${parse_path}=    Evaluate    urllib.parse.urlparse('${URIs}[0]').path    modules=urllib, urllib.parse
    ${filename}=    Evaluate   os.path.basename($parse_path)    modules=os
    Should Not Be Empty    ${filename}    msg=Provided URI (${URIs}[0]) seems to be invalid. Download aborted.

    ${log_dir}=    Prepare Logs Directory Path    downloads
    @{options}=    Create List
    ...    --dir=${destination}
    ...    --out=${filename}
    ...    --log=${log_dir}/aria.log
    ...    --log-level=info
    ...    --summary-interval=0
    ...    --allow-overwrite=true
    ...    --auto-file-renaming=false
    ...    --file-allocation=falloc
    ...    --retry-wait=5
    ...    --max-connection-per-server=4
    ...    --uri-selector=inorder
    ...    --check-certificate=false
    ...    --http-no-cache=true

    # FIXME: read token only when needed
    ${token_file_content}=    Get File    /etc/token/ca_ute_artifactory_readonly
    ${access_token}=    Strip String    ${token_file_content}
    Run Keyword If    $URIs[0].startswith("https://artifactory")    Append To List    ${options}    --header=Authorization: Bearer ${access_token}

    ${result}=    Process.Run Process    aria2c    @{options}    @{URIs}
    Log Many    Output: ${result.stdout}    Error output: ${result.stderr}    Exit code: ${result.rc}
    Run Keyword If    ${result.rc} != 0
    ...    Fail    Download failed with exit status: ${result.rc}. See ${log_dir}/aria.log for details.
    [Return]    ${destination}${/}${filename}

Update Gnb Software
    [Arguments]    ${update_sw_with_activation}=${TRUE}    ${cleanup}=${TRUE}
    [Documentation]    Updates BTS software via WebEM using SW package set in `ENB_TEST_BUILD_PATH` variable.
    ...
    ...    Update procedure can be disabled with flag __DISABLE_BTS_SW_UPDATE__.
    ...    By default, keyword removes the SW package after successful software update. You can change that
    ...    by setting `cleanup` argument to `False`.

    IF    robot.utils.is_truthy($__DISABLE_BTS_SW_UPDATE__)    RETURN    ${FALSE}
    Variable Should Exist    ${ENB_TEST_BUILD_PATH}
    Update Gnb    update_sw_with_activation=${update_sw_with_activation}
    IF    robot.utils.is_truthy($cleanup)
        OperatingSystem.Remove File    ${ENB_TEST_BUILD_PATH}
    END

Update Gnb
    [Arguments]    ${update_sw_with_activation}=${TRUE}
    [Teardown]    admin.teardown    connection=update_gnb

    admin.connect_to    bts_host=${__LOCAL_BTS_IP__}    name=update_gnb
    admin.Update Software
    ...    sw_package=${ENB_TEST_BUILD_PATH}
    ...    should_activate=${update_sw_with_activation}
    ...    timeout=2160    connection=update_gnb
    IF    ${update_sw_with_activation}
        Sleep    3 minutes    reason=Wait for BTS reset after software update
    END

Start Collecting Syslog
    [Documentation]    Starts collecting syslog from BTS and iPHY.
    ...    You can disable iPHY syslog collection by setting global variable `__DISABLE_IPHY_SYSLOG__` to any truthy value.
    ...
    ...    By default, logs are being "zstd" compressed *on the fly*. You can change this behaviour by setting global
    ...    variable `__DISABLE_SYSLOG_COMPRESSION__` to any truthy value.
    [Arguments]    ${logs_dir}
    @{jcsl_handlers}    Create List    jcsl
    Set Suite Variable    $JCSL_HANDLERS
    Process.Start Process    jcsl    -a    ${SYSLOG_IP}    -s    ${SYSLOG_SIZE_LIMIT}    ${logs_dir}/syslog.log    alias=jcsl
    IF    robot.utils.is_falsy($__DISABLE_IPHY_SYSLOG__)
           Process.Start Process    jcsl    -a    ${IPHY_SYSLOG_IP}    -s    ${SYSLOG_SIZE_LIMIT}    ${logs_dir}/iphy-syslog.log    alias=jcsl-iphy
           Collections.Append To List    ${jcsl_handlers}    jcsl-iphy
    END
    IF    robot.utils.is_falsy($__DISABLE_SYSLOG_COMPRESSION__)
        ${bg_compress_cmd}    Set Variable    ${SHARED_RESOURCES}/compress.sh ${logs_dir} 5 >${SUITE LOGS}/compress.log 2>&1
        Process.Start Process    ${bg_compress_cmd}    shell=${TRUE}    alias=jcsl-compress-in-background
        Collections.Append To List    ${jcsl_handlers}    jcsl-compress-in-background
    END

Stop Collecting Syslog
    [Documentation]    Stops Syslog collector(s).
    FOR    ${handler}    IN    @{JCSL_HANDLERS}
        Process.Terminate Process    ${handler}
    END

Install Jcsl
    ${download_command}    Catenate
    ...    curl -f -L -o /tmp/jcsl
    ...    -x http://defra1c-proxy.emea.nsn-net.net:8080/
    ...    https://es-si-s3-z2.eecloud.nsn-net.net/citta.public/jcsl/latest
    OperatingSystem.Run    ${download_command}
    OperatingSystem.Run    sudo install /tmp/jcsl /usr/bin
    # log version for debug purposes:
    ${result}    Process.Run Process    jcsl    --version    stderr=STDOUT
    Log    ${result.stdout}

Perform Full Commissioning
    [Arguments]    ${path_to_scf}
    [Teardown]    admin.Teardown    connection=full_commissioning

    ${logs_dir}=    Prepare Logs Directory Path    admin_logs/full_commissioning
    admin.Connect To    bts_host=${__LOCAL_BTS_IP__}    admin_api_log_dir=${logs_dir}    name=full_commissioning

    admin.Perform Commissioning
    ...    scf_file=${path_to_scf}
    ...    timeout=360
    ...    connection=full_commissioning

Delta Commissisoning
    [Arguments]    ${path_to_delta}
    [Teardown]    admin.Teardown    connection=delta_commissioning

    ${log_dir}=    Prepare Logs Directory Path    admin_logs/delta_commissioning
    admin.Connect To    bts_host=${__LOCAL_BTS_IP__}    admin_api_log_dir=${log_dir}    name=delta_commissioning

    admin.Perform Delta Recommissioning
    ...    delta_file=${path_to_delta}
    ...    skip_parameter_relation_errors=True
    ...    connection=delta_commissioning

Get Rmods Number
    [Return]    ${rmods_number}
    [Teardown]    admin.Teardown    connection=get_rmods_number

    ${logs_dir}=    Prepare Logs Directory Path    admin_logs/get_rmods_number
    admin.Connect To    bts_host=${__LOCAL_BTS_IP__}    admin_api_log_dir=${logs_dir}    name=get_rmods_number

    ${radio_list}=    admin.Get Radio List    connection=get_rmods_number
    ${rmods_number}=    Get Length    ${radio_list}[radioModules][rmod]

Move Epcsim Directory
    [Documentation]    Moves EPCsim directory and updates symbolic link.
    ...
    ...    Copy esimmode directory to home path. Overwrite symbolic link /opt/wts/latest to point
    ...    at new directory.
    ...    If keyword will be executed more than once logs from new directory will be deleted.
    ...
    ...    EPCsim is deployed in directory with limited resources. When enhanced logging is enabled,
    ...    it is crucial to ensure sufficient disk space to prevent log loss.

    ${esimmode_sym_link}=    Set Variable    /opt/wts/latest
    ${esimmode_path_new}=    Set Variable    /home/ute/esimmode
    ${esimmode_path_old}=    OperatingSystem.Run    sudo readlink -f ${esimmode_sym_link}
    IF    '${esimmode_path_old}' == '${esimmode_path_new}'
        OperatingSystem.Run    sudo rm ${esimmode_path_new}/*.log*
        RETURN
    END
    OperatingSystem.Remove Directory    ${esimmode_path_new}    recursive=${True}
    OperatingSystem.Copy Directory    ${esimmode_path_old}    ${esimmode_path_new}
    OperatingSystem.Run    sudo ln -sfn ${esimmode_path_new} ${esimmode_sym_link}
    ${esimmode_path_after}=    OperatingSystem.Run    sudo readlink -f ${esimmode_sym_link}
    Log    ${esimmode_path_after}

Pack Wts Logs
    [Documentation]    Compresses all logs files from default Wts directory.
    ...
    ...    All files matching *.log* regexp are compressed.

    ${opt_iphy_sym_link}=    Set Variable    /opt/iphy/latest
    ${logs_path}=    Prepare Logs Directory Path    wts_logs
    ${cmd}=    Catenate    SEPARATOR=${SPACE}&&${SPACE}
    ...    find ${opt_iphy_sym_link}/ -maxdepth 1 -type f -name "*.log*" -exec cp -t ${logs_path} {} +
    ...    zstd --rm -q ${logs_path}/*
    OperatingSystem.Run    ${cmd}
    ${packed_wts_logs}=    OperatingSystem.List Files In Directory    ${logs_path}
    Log Many    ${packed_wts_logs}

Teardown Admin Connection
    [Arguments]    ${connection}

    ${admin_instance}=    Get Library Instance    admin
    ${admin_instance_exists}=    Evaluate   "${connection}" in [item[0] for item in $admin_instance.store.all]
    IF    ${admin_instance_exists}    admin.Teardown    connection=${connection}
