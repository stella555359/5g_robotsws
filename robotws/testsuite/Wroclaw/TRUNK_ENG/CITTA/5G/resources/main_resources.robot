*** Settings ***
Documentation    Common testing procedures.

# -- std libs --
Library    OperatingSystem
Library    Process
Library    Collections
Library    DateTime
Library    String
Library    XML

# -- taf/ute libs --
Library    taf.sbts.oam.coam.admin    WITH NAME    admin
Library    taf.transport.ssh    WITH NAME    ssh
Library    ute_admin_infomodel
Library    taf.sw.syslog    WITH NAME    taf_syslog
Library    ute_tshark
Library    ute_wtssim

# -- internals --
Library    ./main.py
Library    ./libraries/swconfig.py
Library    ./libraries/pm_counter.py

# -- custom listeners --

# -- resources --
Resource    ../../resources/shell/shell.resource
Resource    ../../resources/reporting/reporting.resource

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
...    10.0.1.101    10.0.1.102    # sim gnb addrs
...    10.0.1.131    10.0.1.133    10.0.1.134    # sim epc addrs
...    10.0.1.135    10.0.1.136    10.0.1.137    # sim enb addrs
${__EGATE_COMMAND_TIMEOUT___}    10s
@{__QUOSFLOWS_PARAMS__}    add    del    modify

${__SSHPASS_TO_ENB_CMD__}    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129

${DISABLE_SOS_REPORT}    NO

*** Keywords ***
# -- common --
Prepare Logs Directory Path
    [Arguments]    ${subdir}=${EMPTY}    ${with_timestamp}=${TRUE}
    [Documentation]
    ...    Creates directory for storing logs, based on current execution context.
    ...    An absolute path to created directory is returned.
    [Tags]    PUBLIC
    ${logs_dir}=    main.resolve_logs_directory    ${subdir}    ${with_timestamp}
    OperatingSystem.CREATE DIRECTORY    ${logs_dir}
    [Return]    ${logs_dir}

Prepare Testing Environment
    [Documentation]
    ...    Does mundane preparation tasks
    COMMENT    Add stuff here as setup steps become more and more repetitive
    [Tags]    PRIVATE
    NO OPERATION

Cleanup Testing Environment
    [Documentation]
    ...    Does mundane cleanup tasks
    [Tags]    PRIVATE
    COMMENT    Add stuff here as teardown steps become more and more repetitive
    NO OPERATION

Start Mandatory Logging
    [Documentation]
    ...    Starts suite level SysLog and Infomodel sessions
    [Tags]    PRIVATE
    OperatingSystem.CREATE DIRECTORY    ${SUITE LOGS}
    taf_syslog.start_syslog    ${SUITE LOGS}    syslog.log    ip=${__SYSLOG_IP__}    alias=default
    taf_syslog.start_syslog    ${SUITE LOGS}    syslog-iphy.log    ip=${__IPHY_SYSLOG_IP__}    alias=iphy
    ute_admin_infomodel.setup_infomodel    address=${__LOCAL_BTS_IP__}    port=443    admin_api_log_dir=${SUITE LOGS}    alias=default
    ute_admin_infomodel.connect_infomodel    alias=default

Collect Mandatory Logs
    [Documentation]
    ...    Saves suite level SysLogs, Infomodel, Snapshot, and SosReport
    [Tags]    PRIVATE
    # gets snapshot with admin
    ${logs_dir}=    Prepare Logs Directory Path    admin_logs/snapshot
    admin.connect_to    bts_host=${__LOCAL_BTS_IP__}    admin_api_log_dir=${logs_dir}    name=snapshot
    admin.collect_snapshot    ${SUITE LOGS}/${__DEFAULT_SNAPSHOT_FILE_NAME__}    timeout=840    connection=snapshot
    admin.teardown    connection=snapshot

    # saves suite level infomodel
    ute_admin_infomodel.save_infomodel_log    ${SUITE LOGS}/infomodel.ims2    timeout=840    alias=default
    ute_admin_infomodel.teardown_infomodel    alias=default

    # stops writing to syslog files, and compresses them
    taf_syslog.collect_syslog_results    unzip=${FALSE}    alias=default
    taf_syslog.collect_syslog_results    unzip=${FALSE}    alias=iphy

    IF    robot.utils.is_falsy($DISABLE_SOS_REPORT)
        Run Sosreport Script
    END

Run Sosreport Script
    [Documentation]    Collects AirPhone snapshot and other diagnostic logs.
    ${workdir}=    SET VARIABLE    /opt/iphy/latest/sosReport_ASIL
    ${sosreport_dir}=    Prepare Logs Directory Path    SosReport    ${FALSE}
    OperatingSystem.RUN    rm ${workdir}/SosReport*.tgz
    Process.RUN PROCESS    bash ./sosReport_ASIL.sh    shell=${TRUE}    cwd=${workdir}    stdout=${sosreport_dir}/output.txt   stderr=STDOUT
    OperatingSystem.MOVE FILE    ${workdir}/SosReport*.tgz    ${sosreport_dir}

Get Active BTS Alarms
    [Arguments]    ${im_alias}=default
    [Documentation]
    ...    Returns active IMS alarm objects. Logs alarm details as warnings.
    [Tags]    PUBLIC
    ${query}=    SET VARIABLE    get list //ALARM-*
    ${alarms}=    ute_admin_infomodel.query_infomodel    ${query}    allow_negative_result=${TRUE}    alias=${im_alias}
    FOR    ${a}    IN    @{alarms}
        LOG    ALARM [A:${a.alarmNumber}|F:${a.faultId}|${a.alarmSeverity}] ${a.alarmName} - ${a.alarmText.alarmDetail}    level=WARN
    END
    [Return]    ${alarms}

Configure Required IP Addresses
    ${ip_addr_output}=    Run On Localhost    ip addr
    FOR    ${addr}    IN    @{__IP_ADDRESSES__}
        Run Keyword If    $addr not in $ip_addr_output    Add Ip Address    ${addr}
    END

Add IP Address
    [Arguments]    ${ip}
    Run On Localhost    sudo ip addr add ${ip}/24 dev eth3
    ${output}=    Run On Localhost    ip addr
    SHOULD CONTAIN    ${output}    ${ip}

Backup BTS Configuration Files
    [Documentation]    Dumps current BTS configuration data into ``${OUTPUT DIR}``.
    ...    Precise output file paths are resolved by ``Resolve Logs Directory Path`` keyword.
    ...
    ...    Following runtime configuration files are being copied:
    ...    - SCF
    ...    - swconfig
    ...
    ...    Note: for multi-eNB testline setup, only files from first BTS will be backed-up.

    ${scf_path}=    Prepare Logs Directory Path    bts_configuration_files/scf    ${FALSE}
    ${swconfig_path}=    Prepare Logs Directory Path    bts_configuration_files/swconfig    ${FALSE}
    admin.connect_to    bts_host=${__LOCAL_BTS_IP__}    admin_api_log_dir=${scf_path}/admin_logs    name=get_current_scf_file    timeout=90
    admin.get_current_scf_file    local_dir_path=${scf_path}    file_name=scf.xml    timeout=120    connection=get_current_scf_file
    Set Suite Variable    ${__DEFAULT_SCFC__}    ${scf_path}/scf.xml
    Fetch From Smod    /ffs/run/swconfig.txt    ${swconfig_path}
    [Teardown]    admin.teardown    connection=get_current_scf_file

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
    RUN KEYWORD IF    "${nr_mode}"=="NSA"    WAIT UNTIL KEYWORD SUCCEEDS    3x    2s    NSA Setup X2 Link Between ENB and GNB

Start WTS applications and services
    [Arguments]
    ...    ${lua_config}
    ...    ${check_version}=True
    ...    ${timeout}=480
    [Documentation]    Start WTS applications and services.
    ...    WTS is started in two steps. First lua is loaded, next services are started.
    ...    Keyword will wait for ``CHANGE STATE: ACTIVE`` in Egate console output for correct setup verification.
    ...    ``check_version`` should be set to False for AirPhone WTS.

    ute_wtssim.start_wts_applications    edaemon_ports=${__EDAEMON_PORTS__}    cfg_file=${lua_config}
    ute_wtssim.start_wts_services    timeout=${timeout}    check_version=${check_version}

Stop WTS
    [Documentation]    Stops WTS proceses

    ${log_path}=    Prepare Logs Directory Path    WTS
    ute_wtssim.stop_and_collect_wts_logs    subdirectory=${log_path}

Wait for RMODs operational state enabled
    [Arguments]
    ...    ${rmods_number}=2
    ...    ${timeout}=600
    ...    ${alias}=default
    [Documentation]    Waits till radio operational state is enabled.

    ute_admin_infomodel.query_infomodel    count ${__RUNTIME_RMOD_IM_PATH__} is [operationalState=enabled] = ${rmods_number}
    ...    timeout=${timeout}    alias=${alias}

Wait for BTS operational state configured or onAir
    [Arguments]
    ...    ${timeout}=600
    ...    ${alias}=default
    [Documentation]    Waits till BTS operational state is configured or onAir.

    ute_admin_infomodel.query_infomodel    ${__RUNTIME_NRBTS_IM_PATH__} is [operationalState=regex"configured|integrated to RAN|onAir"]
    ...    timeout=${timeout}    alias=${alias}

Check if BTS is correctly configured
    [Arguments]
    ...    ${rmods_number}=2
    ...    ${timeout}=600
    ...    ${alias}=default
    [Documentation]    Checks BTS and RMOD runtime objects to determine if eNB is correctly configured.

    Wait for BTS operational state configured or onAir    ${timeout}    ${alias}
    Wait for RMODs operational state enabled    ${rmods_number}    ${timeout}    ${alias}

Check if cells are operational
    [Arguments]
    ...    ${timeout}=300
    ...    ${alias}=default
    [Documentation]    Checks runtime objects states to determine if cell(s) are in correct state.
    ...    barringStatus for eNB cell should be in unbarred state before any UE procedure.

    ute_admin_infomodel.query_infomodel    every ${__RUNTIME_NRCELL_IM_PATH__} is [operationalState=enabled]    timeout=${timeout}    alias=${alias}
    ute_admin_infomodel.query_infomodel    every ${__RUNTIME_NRCELL_IM_PATH__} is [barringStatus=unbarred]    timeout=${timeout}    alias=${alias}

Check if BTS is operational state OnAir
    [Arguments]
    ...    ${timeout}=600
    ...    ${alias}=default
    [Documentation]    Checks runtime object to determine if BTS is in OnAir operational state.

    ute_admin_infomodel.query_infomodel    ${__RUNTIME_NRBTS_IM_PATH__} is [operationalState=onAir]    timeout=${timeout}    alias=${alias}

Check if NG link is up
    [Arguments]
    ...    ${timeout}=600
    ...    ${alias}=default

    ute_admin_infomodel.query_infomodel    //SERVEDAMF_R-* is [ngLinkStatus=Active]    timeout=${timeout}    alias=${alias}

Check if BTS is OnAir
    [Arguments]
    ...    ${timeout}=600
    ...    ${alias}=default
    [Documentation]    Checks if BTS is OnAir.
    ...    In order to determine if BTS is OnAir following conditions should be true:
    ...    - BTS operational state is OnAir,
    ...    - Cells are operational state and NotBarred,
    ...    - S1 link is available.

    Check if NG link is up    ${timeout}    ${alias}
    Check if BTS is operational state OnAir    ${timeout}    ${alias}
    Check if cells are operational    ${timeout}    ${alias}

Perform Commissioning
    [Arguments]    ${scfc_path}
    Update Vlan Value    ${scfc_path}
    ${connection}=    SET VARIABLE    commissioning
    ${log_path}=    Prepare Logs Directory Path    admin_logs/${connection}
    admin.connect_to    bts_host=${__LOCAL_BTS_IP__}    admin_api_log_dir=${log_path}    name=${connection}
    admin.perform_commissioning    scf_file=${scfc_path}    skip_parameter_relation_errors=True    timeout=900    connection=${connection}
    [Teardown]    admin.teardown    connection=${connection}

Update Vlan Value
    [Arguments]    ${scf_file}
    [Documentation]    Sets vlanId value, based on current testline configuration. Updates ``scf_file`` in place.
    [Tags]    PRIVATE
    ${xpath}=    SET VARIABLE    .//*[@distName='MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1']/p[@name='vlanId']
    ${vlan_id}=    CONVERT TO STRING    ${tl.gnbs[0].cu.s1u.vlan_id}
    ${root}    PARSE XML    ${scf_file}
    SET ELEMENT TEXT    ${root}    ${vlan_id}    xpath=${xpath}
    SAVE XML    ${root}    ${scf_file}

Delta Commissisoning
    [Arguments]    ${path_to_delta}
    ${connection}=    SET VARIABLE    delta_commissioning
    ${log_path}=    Prepare Logs Directory Path    admin_logs/${connection}

    Comment    Make sure we can perform re-commissioning in a first place
    Wait for BTS operational state configured or onAir

    admin.connect_to    bts_host=${__LOCAL_BTS_IP__}    admin_api_log_dir=${log_path}    name=${connection}
    admin.perform_delta_recommissioning    delta_file=${path_to_delta}    skip_parameter_relation_errors=True    connection=${connection}
    [Teardown]    admin.teardown    connection=${connection}

Round Value And Convert To String
    [Documentation]    Returns value without its fraction part (rounding it up) as string
    [Arguments]    ${value}
    ${result}    CONVERT TO NUMBER    ${value}    0
    ${result}    CONVERT TO INTEGER    ${result}
    ${result}    CONVERT TO STRING    ${result}
    [Return]    ${result}

Remove FILES "${pattern}" from SUBDIRECTORY "${subdir}"
    [Documentation]    Remove files matching given pattern from given subdirectory
    ...    Parameters:
    ...    `pattern` - regexp pattern
    ...    `subdir` - subdirectory name or relative path
    ...    Absolute path to subdirectory is resolved by keyword resolve_logs_directory from main.py and
    ...    is depended on current execution context in the same manner as in Prepare Logs Directory Path keyword.
    ${logs_dir}    main.resolve_logs_directory    ${subdir}    ${FALSE}
    ${output}    Run On Localhost    find "${logs_dir}" -name "${pattern}" | xargs rm -r

Return size of SUBDIRECTORY "${subdir}" in bytes
    [Documentation]    Return size of given subdirectory in bytes
    ...    Parameters:
    ...    `subdir` - subdirectory name or relative path
    ...    Absolute path to subdirectory is resolved by keyword resolve_logs_directory from main.py and
    ...    is depended on current execution context in the same manner as in Prepare Logs Directory Path keyword.
    ${logs_dir}    main.resolve_logs_directory    ${subdir}    ${FALSE}
    ${size}    Run On Localhost    du -sb ${logs_dir} | awk '{print $1}'
    [Return]    ${size}

Get Average Value Of PM Counter
    [Arguments]    ${pm_counter_path}    ${interval}
    [Documentation]    Return avg value of given pm counter measurements
    ...    Parameters:
    ...    `pm_counter_path` - path to PM counter e.g.: BTS/BTS/NRBTS-1/NF1UB/M55323C01009
    ...    `interval` - time interval given in rounded number (int) of minutes for which pm counter has been measured.
    ...    Have to be greater than 2. Based on that parameter, number of valid measurements is calculated.
    ${number_of_measurements}    EVALUATE    ${interval} - 2
    ${measurements}    Get PM Counter "${pm_counter_path}" Measurements Untill Success
    ${avg}    pm_counter.get_avg_pm_counter_value    ${measurements}    ${pm_counter_path}    ${number_of_measurements}
    [Return]    ${avg}

Get PM Counter "${pm_counter_path}" Measurements Untill Success
    [Documentation]    Try multiple times to get PM counter measurements using admin
    ...    Parameters:
    ...    `pm_counter_path` - path to PM counter e.g.: BTS/BTS/NRBTS-1/NF1UB/M55323C01009
    ${pm_counters}=    Wait Until Keyword Succeeds    6x    15s    Get PM Counter "${pm_counter_path}" Measurements
    [Return]    ${pm_counters}

Get PM Counter "${pm_counter_path}" Measurements
    [Documentation]    Get PM counter measurements using admin
    ...    Parameters:
    ...    `pm_counter_path` - path to PM counter e.g.: BTS/BTS/NRBTS-1/NF1UB/M55323C01009
    ${connection}=    Set Variable    get_pm_counters
    ${log_path}=    Prepare Logs Directory Path    admin_logs/${connection}
    admin.connect_to    bts_host=${__LOCAL_BTS_IP__}    admin_api_log_dir=${log_path}    name=${connection}
    ${pm_counter_measurements}=    admin.get_counters_info    dist_name=${pm_counter_path}    timeout=60    connection=${connection}
    [Return]    ${pm_counter_measurements}
    [Teardown]    admin.teardown    connection=${connection}

Reboot BTS
    [Documentation]    Performs BTS (site) reset via Admin
    [Arguments]
    ...    ${wait_till_bts_operational}=${TRUE}
    ...    ${rmods_number}=2
    ...    ${timeout_for_bts_operational_check}=600
    ${connection}=    SET VARIABLE    site_reset
    ${log_path}=    Prepare Logs Directory Path    admin_logs/${connection}
    admin.connect_to    bts_host=${__LOCAL_BTS_IP__}    admin_api_log_dir=${log_path}    name=${connection}
    admin.reset_site    timeout=480    connection=${connection}
    RUN KEYWORD IF    ${wait_till_bts_operational}
    ...    Check if BTS is correctly configured    rmods_number=${rmods_number}    timeout=${timeout_for_bts_operational_check}
    [Teardown]    admin.teardown    connection=${connection}

Add Flag To Swconfig
    [Documentation]    Adds flag with given value and comment to swconfig.txt
    ...    Parameters:
    ...    `flag` - name of flag, for example: 0x45005a
    ...    `value` - value of flag, for example: 0x1000000
    ...    `comment` - comment that will be added above flag
    [Arguments]    ${flag}    ${value}    ${comment}
    ${fsm_swconfig_path}    SET VARIABLE    /ffs/run/swconfig.txt
    ${local_swconfig_directory}    Prepare Logs Directory Path    subdir=swconfig    with_timestamp=${FALSE}
    ${local_swconfig_path}    SET VARIABLE    ${local_swconfig_directory}${/}swconfig.txt
    Fetch From Smod    ${fsm_swconfig_path}    ${local_swconfig_path}
    swconfig.add_swconfig_flag    flag=${flag}    value=${value}    swconfig_path=${local_swconfig_path}    comment=${comment}
    Put On Smod    ${local_swconfig_path}    ${fsm_swconfig_path}

Start "${mbps}"mbps "${dir}" Data Traffic For UE"${ue_id}" Bearer"${bearer_id}" Size"${size}"
    [Documentation]    Starts data traffic
    ...    Parameters:
    ...    `mbps` - throughput value in mbps
    ...    `dir` - direction of data traffic: ul|dl
    ...    `ue_id` - id of UE
    ...    `bearer_id` - id of bearer
    ...    `size` - Layer 3 packet size range (size includes all hea ders beginning from IP). Maximum of 1358 for
    ...             NB-IoT UEs. Maximum of 9000 for UEs configured with NR PDCP. Otherwise, maximum is 8188
    ...    NOTE: trf_data_start command parameters 'size' and 'mbps' are related. Keyword might not work as
    ...          expected when `size` is less than 1000.
    LOG TO CONSOLE    \n======= Start "${mbps}" "${dir}" data traffic For UE"${ue_id}" =======
    ${chunks}    main.get_tput_chunks    ${mbps}
    ${trf_id}    SET VARIABLE    ${0}
    FOR    ${chunk}    IN    @{chunks}
        ${trf_id}    EVALUATE    ${trf_id} + ${1}
        ${command}    SET VARIABLE    trf_data_start ue=${ue_id} dir=${dir} mbps=${chunk} id=${bearer_id} trf_id=${trf_id} size=${size}
        ute_wtssim.execute_egate_command_and_wait_for_data
        ...    cmd=${command}
        ...    timeout=${__EGATE_COMMAND_TIMEOUT___}
    END
    SLEEP    2s    # << wait for data traffic to be started
    Verify If Throughput Is Started    ue=${ue_id}    dir=${dir}

Verify If Throughput Is Started
    [Arguments]    ${ue}    ${dir}    ${bearer_id}=2   ${type}=l3
    [Documentation]    Verifies if data traffic has been started by checking if average throughput
    ...                value is greater than 0 using Egate command bearer_stats.
    ...    Parameters:
    ...    `ue` - specified UE ID
    ...    `dir` - traffic direction: ul|dl
    ...    `bearer_id` - id of bearer
    ...    `type` - statistics type
    SLEEP    4s
    ${throughput}    Get Traffic Statistics From Bearer    bearer_id=${bearer_id}    ue_id=${ue}    traffic_direction=${dir}
    ...                                                    extra_params=type=${type}
    ${avg_tput_mbps}=    Evaluate    ${throughput}[average]/1000000
    SHOULD BE TRUE    ${avg_tput_mbps} > ${0}
    ...               msg=Throughput is not started: ${avg_tput_mbps} mbps

Get Traffic Statistics From Bearer
    [Documentation]    [IPHY:EGATE] Gets throughput statistics from bearer
    ...    Parameters:
    ...    `bearer_id` - id of bearer
    ...    `ue_id` - id of UE
    ...    `traffic_direction` - direction of data traffic: ul|dl
    ...    `extra_params` - extra parameters that can be passed to EGATE bearer_stats command
    ...
    ...    Returns dictionary with throughput data from bearer - parsed from output of bearer_stats command
    ...    {'average': <average_througput>,
    ...    'max': <maximal_throughput>,
    ...    'min': <minimal_throughput>,
    ...    'time': <duration_of_throughput>,
    ...    'total_packet_lost': <amount_of_lost_packets>,
    ...    'packets_received': <amount_of_received_packets>,
    ...    'raw_data': <raw_output_of_command>
    ...    }
    [Arguments]    ${bearer_id}    ${ue_id}    ${traffic_direction}    ${extra_params}=${NONE}

    ${operation}=    SET VARIABLE    bearer_stats
    ${pass_regexp}=    SET VARIABLE    Average packet interval    #Last entry of bearer stats output
    ${extra_params}=    SET VARIABLE IF    '${extra_params}'=='${NONE}'    ${SPACE}    ${extra_params}
    ${egate_cmd}=    SET VARIABLE    ${operation} id=${bearer_id} ue=${ue_id} dir=${traffic_direction} ${extra_params}
    ${command_result}    ute_wtssim.execute_egate_command_and_wait_for_data
    ...    cmd=${egate_cmd}
    ...    pass_regexp=${pass_regexp}
    ...    timeout=${__EGATE_COMMAND_TIMEOUT___}
    ${match}    ${avg_traffic}=    SHOULD MATCH REGEXP    ${command_result}    Average data rate\\s*(\\d*)
    ${match}    ${min_traffic}=    SHOULD MATCH REGEXP    ${command_result}    Absolute min data rate\\s*(\\d*)
    ${match}    ${max_traffic}=    SHOULD MATCH REGEXP    ${command_result}    Absolute max data rate\\s*(\\d*)
    ${match}    ${duration}=    SHOULD MATCH REGEXP    ${command_result}    Collection time for receiver stats\\s*(\\d*)
    ${match}    ${total_packets_lost}=    SHOULD MATCH REGEXP    ${command_result}    Total packets lost\\s*(\\d*)
    ${match}    ${packets_received}=    SHOULD MATCH REGEXP    ${command_result}    Total packets received\\s*(\\d*)
    ${throughput_stats}=    CREATE DICTIONARY
    ...    average=${avg_traffic}    max=${max_traffic}    min=${min_traffic}
    ...    time=${duration}    total_packet_lost=${total_packets_lost}    packets_received=${packets_received}
    ...    raw_data=${command_result}
    [Return]    ${throughput_stats}

Add Eth
    [Arguments]    ${ip}    ${mask}    ${interface}    ${label}
    [Documentation]    Adds eth interface
    ...    Parameters:
    ...    'ip' - address ip
    ...    'mask' - subnet mask
    ...    'interface' - eth interface e.g.: eth3, eth4
    ...    'label' - name of label for e.g: eth3:sgw
    ${eth_check_cmd}    SET VARIABLE
    ...    (ip -o a | egrep -e ".*${interface}.*${ip}/${mask}.*" 1> /dev/null) && echo True || echo False
    ${entry_already_exists}    Run On Localhost    ${eth_check_cmd}
    ${add_eth_cmd}    SET VARIABLE    sudo ip addr add ${ip}/${mask} dev ${interface} label ${label}
    RUN KEYWORD IF    '${entry_already_exists}' == 'False'    Run On Localhost    ${add_eth_cmd}

# -- NSA --
NSA Setup X2 Link Between ENB and GNB
    [Arguments]    ${enb_id}=1    ${gnb_id}=2    ${timeout}=30
    ${pass_regexp}    SET VARIABLE    X2AP Link .* is up
    ${command}    SET VARIABLE    enb_x2_link_up enb=${enb_id} target=${gnb_id}
    ute_wtssim.execute_egate_command_and_wait_for_data
    ...    cmd=${command}
    ...    pass_regexp=${pass_regexp}
    ...    timeout=${timeout}

NSA LTE Attach UE
    [Arguments]    ${ue_id}=1
    ${command}    SET VARIABLE    ue_attach id=${ue_id}
    ute_wtssim.execute_egate_command_and_wait_for_data
    ...    cmd=${command}
    ...    timeout=${__EGATE_COMMAND_TIMEOUT___}

NSA Detach UE
    [Arguments]    ${ue_id}=1    ${bearer}=2
    ${dc_release_cmd}    SET VARIABLE    enb_ue_dc_release ue=${ue_id} by=enb cause=off bearer=${bearer}
    ${ue_detach_cmd}    SET VARIABLE    ue_detach id=${ue_id}
    ute_wtssim.execute_egate_command_and_wait_for_data
    ...    cmd=${dc_release_cmd}
    ...    pass_regexp=Successfully reconfigured dual connectivity
    ...    timout=${__EGATE_COMMAND_TIMEOUT___}
    ute_wtssim.execute_egate_command_and_wait_for_data
    ...    cmd=${ue_detach_cmd}
    ...    pass_regexp=detached
    ...    timout=${__EGATE_COMMAND_TIMEOUT___}

NSA SGNB Addition
    [Arguments]    ${ue_id}=1    ${target_gnb}=2    ${target_cells}=1    ${bearer}=2    ${type}=split_scg
    ${command}    SET VARIABLE
    ...    enb_ue_dc_start ue=${ue_id} target_gnb=${target_gnb} target_cells=${target_cells} bearer=${bearer} type=${type}
    ute_wtssim.execute_egate_command_and_wait_for_data
    ...    cmd=${command}
    ...    timeout=${__EGATE_COMMAND_TIMEOUT___}

NSA Attach 5G UE"${ue_id}"
    [Documentation]    Attach UE to 5G NR CELL"1" in NSA mode
    ...    Attach is done in two steps: (1) Attach to LTE Cell and (2) SgNB Addition done by scg split.
    ...    Both actions are done by egate commands. Verification is done based on packets captured by tshark
    ...    which detailed description can be found in used keywords.
    ...    Parameters:
    ...    `ue_id` - ID of UE to attach
    LOG TO CONSOLE    \n======= Attach 5G UE${ue_id} =======
    NSA LTE Attach UE"${ue_id}" To The CELL"1"
    NSA SgNB Addition UE"${ue_id}" To gNB"2" CELL"1" BEARER"2" TYPE"split_scg"

NSA Detach 5G UE"${ue_id}"
    [Documentation]    Detach UE from 5G NR CELL"1" in NSA mode
    ...    This keyword detaches UE from 5G NR CELL"1" in NSA mode using egate. Detach verification is done based on
    ...    RRCConnectionRelease and SgNBReleaseRequestAcknowledge packets captured by tshark.
    ...    Parameters:
    ...    `ue_id` - ID of UE to detach
    LOG TO CONSOLE    \n======= Detach 5G UE${ue_id} =======
    ${tshark_logs}    Prepare Logs Directory Path    tshark/detach_keyword    with_timestamp=${FALSE}
    ute_tshark.setup_tshark    interface=eth3 lo    alias=detach_ue${ue_id}    log_dir=${tshark_logs}    log_name=detach_ue${ue_id}
    ute_tshark.start_capturing    capture_filter=sctp    alias=detach_ue${ue_id}
    SLEEP    2    # << ensure all essential packets has been captured
    NSA Detach UE    ${ue_id}
    SLEEP    2    # << ensure all essential packets has been captured
    ute_tshark.stop_capturing    alias=detach_ue${ue_id}
    ${rrc_connection_release}              ute_tshark.get_packets_count
    ...                                    packet_filter=lte-rrc.releaseCause == 1 && iphy.ue_id == ${ue_id}
    ...                                    alias=detach_ue${ue_id}
    ${sgnb_release_request_acknowledge}    ute_tshark.get_packets_count
    ...                                    packet_filter=x2ap.SgNBReleaseRequestAcknowledge_element
    ...                                    alias=detach_ue${ue_id}
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${rrc_connection_release}==${1}
    ...                                    msg=RRCConnectionRelease msg is missing: UE${ue_id} detach
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${sgnb_release_request_acknowledge}==${1}
    ...                                    msg=SgNBReleaseRequestAcknowledge msg is missing: UE${ue_id} detach
    ute_tshark.teardown_tshark    alias=detach_ue${ue_id}

NSA LTE Attach UE"${ue_id}" To The CELL"${physical_layer_cell_id}"
    [Documentation]    Attach UE to LTE CELL
    ...    This keyword attaches UE to cell using egate. Attach verification is based on S1AP and RRC
    ...    packets captured by tshark. This keyword is meant to be used with default UTE configuration,
    ...    it is not guaranteed that it will work correctly with other configurations.
    ...    Parameters:
    ...    `ue_id` - ID of UE to attach
    ...    `physical_layer_cell_id` - physical layer ID of target cell

    LOG TO CONSOLE    \n------- LTE Attach UE"${ue_id}" To The CELL"${physical_layer_cell_id}" -------
    ${tshark_logs}    Prepare Logs Directory Path    tshark/attach_keyword    with_timestamp=${FALSE}
    ute_tshark.setup_tshark    interface=eth3 lo    alias=attach_ue${ue_id}    log_dir=${tshark_logs}    log_name=attach_ue${ue_id}
    ute_tshark.start_capturing    capture_filter=sctp    alias=attach_ue${ue_id}
    SLEEP    2    # << ensure all essential packets has been captured
    NSA LTE Attach UE    ${ue_id}
    SLEEP    2    # << ensure all essential packets has been captured
    ute_tshark.stop_capturing    alias=attach_ue${ue_id}
    ${s1ap_attach_complete}    ute_tshark.get_packets_count
    ...                        packet_filter=s1ap.S1AP_PDU==0 && nas_eps.nas_msg_emm_type==0x43
    ...                        alias=attach_ue${ue_id}
    ${rrc_attach_to_cell}      ute_tshark.get_packets_count
    ...                        packet_filter=nas_eps.nas_msg_emm_type==0x43 && iphy.cell_id==${physical_layer_cell_id} && iphy.ue_id==${ue_id}
    ...                        alias=attach_ue${ue_id}
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${s1ap_attach_complete}==${1}
    ...                                    msg=S1AP msg is missing: UE${ue_id} attach complete
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${rrc_attach_to_cell}==${1}
    ...                                    msg=RRC msg is missing: UE${ue_id} attach to the CELL${physical_layer_cell_id}
    ute_tshark.teardown_tshark    alias=attach_ue${ue_id}

NSA SgNB Addition UE"${ue_id}" To gNB"${target_gnb}" CELL"${target_cells}" BEARER"${bearer}" TYPE"${type}"
    [Documentation]    UE SgNB Addition
    ...    This keyword attaches UE to SgNB cell by starting dual connectivity using egate. UE with particular id
    ...    must be already attached to LTE cell in order to make SgNB Addition possible. Verification is based on
    ...    S1AP, X2AP and RRC packets captured by tshark. This keyword is meant to be used with default
    ...    UTE configuration, it is not guaranteed that it will work correctly with other configurations.
    ...    Parameters:
    ...    `ue_id` - Specified UE ID
    ...    `target_gnb` - Target GNB ID
    ...    `target_cells` - Target GNB cells
    ...    `bearer` - Bearer ID List
    ...    `type` - Type of dual connectivity

    LOG TO CONSOLE    \n------- SgNB Addition UE${ue_id} -------
    ${tshark_logs}    Prepare Logs Directory Path    tshark/sgnb_addition    with_timestamp=${FALSE}
    ute_tshark.setup_tshark    interface=eth3 lo    alias=sgnb_addition${ue_id}    log_dir=${tshark_logs}    log_name=sgnb_addition${ue_id}
    ute_tshark.start_capturing    capture_filter=sctp    alias=sgnb_addition${ue_id}
    SLEEP    2    # << ensure all essential packets has been captured
    NSA SGNB Addition    ue_id=${ue_id}    target_gnb=${target_gnb}    target_cells=${target_cells}    bearer=${bearer}    type=${type}
    SLEEP    2    # << ensure all essential packets has been captured
    ute_tshark.stop_capturing    alias=sgnb_addition${ue_id}

    ${sgnb_addition_packets_and_filters}    CREATE DICTIONARY
    ...    SgNBAdditionRequest                     x2ap.SgNBAdditionRequest_element
    ...    SgNBAdditionRequestAcknowledge          x2ap.SgNBAdditionRequestAcknowledge_element
    ...    RRCConnectionReconfiguration            lte-rrc.c1 \=\= 4 && lte-rrc.rlc_Config \=\= 0 && !lte-rrc.dedicatedInfoNASList \=\= 1
    ...    RRCConnectionReconfigurationComplete    lte-rrc.c1 \=\= 2 && lte-rrc.scg_ConfigResponseNR_r15 \=\= 00
    ...    SgNBReconfigurationComplete             x2ap.SgNBReconfigurationComplete_element
    ...    E-RABModificationIndication             s1ap.E_RABModificationIndication_element
    ...    E-RABModificationConfirm                s1ap.E_RABModificationConfirm_element
    ...    SNStatusTransfer                        x2ap.SNStatusTransfer_element && ip.src \=\= 10.0.1.137 && ip.dst \=\= 10.0.1.2

    ${packets_and_filters}    GET DICTIONARY ITEMS    ${sgnb_addition_packets_and_filters}
    FOR    ${packet}    ${filter}    IN    @{packets_and_filters}
        ${packets_count}    ute_tshark.get_packets_count    packet_filter=${filter}    alias=sgnb_addition${ue_id}
        RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${packets_count}==${1}    msg=${packet} not visible for UE${ue_id} SgNB Addition
    END

    ute_tshark.teardown_tshark    alias=sgnb_addition${ue_id}

# -- SA --
Commission eNB To SA Mode
    #FIXME: do not assume LO_AP_LO topology
    ${delta_activate_sa_mode}=    Set Variable    ${SHARED_RESOURCES}/deltas/SA_activate-LO_AP_LO.json
    ${rmods_number}=    Set Variable    4
    Delta Commissisoning    ${delta_activate_sa_mode}
    Check if BTS is correctly configured    rmods_number=${rmods_number}

SA 5G Attach UE"${ue_id}"
    [Documentation]    Attach UE to 5G NR CELL"1" in SA mode
    ...    Attach is done using egate command `ue_register`. Attach verification is done based on packets captured
    ...    by tshark which detailed description can be found in used keywords.
    ...    Parameters:
    ...    `ue_id` - ID of UE to attach
    LOG TO CONSOLE    \n------- SA 5G Attach UE"${ue_id}" -------
    ${tshark_logs}    Prepare Logs Directory Path    tshark/attach_keyword    with_timestamp=${FALSE}
    ute_tshark.setup_tshark
    ...    interface=eth3
    ...    alias=attach_ue${ue_id}
    ...    log_dir=${tshark_logs}
    ...    log_name=attach_ue${ue_id}
    ute_tshark.start_capturing    capture_filter=sctp    alias=attach_ue${ue_id}
    SLEEP    2    # << ensure all essential packets has been captured
    ${command}    SET VARIABLE    ue_register id=${ue_id}
    ute_wtssim.execute_egate_command_and_wait_for_data
    ...    cmd=${command}
    ...    timeout=${__EGATE_COMMAND_TIMEOUT___}
    SLEEP    2    # << ensure all essential packets has been captured
    ute_tshark.stop_capturing    alias=attach_ue${ue_id}
    #eth3 5GCN messages
    ${initial_ue_message_regustration}    ute_tshark.get_packets_count
    ...    packet_filter=ngap.InitialUEMessage_element
    ...    alias=attach_ue${ue_id}
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${initial_ue_message_regustration}>=${1}
    ...    msg=Amount of Initial UE Message (${initial_ue_message_regustration}) is not equal to 1
    [Teardown]    ute_tshark.teardown_tshark    alias=attach_ue${ue_id}

SA 5G Detach UE"${ue_id}"
    [Documentation]    Detach UE to 5G NR CELL"1" in SA mode
    ...    Detach is done using egate command `ue_deregister`. Detach verification is done based on packets captured
    ...    by tshark which detailed description can be found in used keywords.
    ...    Parameters:
    ...    `ue_id` - ID of UE to detach
    LOG TO CONSOLE    \n------- SA 5G Detach UE"${ue_id}" -------
    ${tshark_logs}    Prepare Logs Directory Path    tshark/detach_keyword    with_timestamp=${FALSE}
    ute_tshark.setup_tshark
    ...    interface=eth3
    ...    alias=detach_ue${ue_id}
    ...    log_dir=${tshark_logs}
    ...    log_name=detach_ue${ue_id}
    ute_tshark.start_capturing    capture_filter=sctp    alias=detach_ue${ue_id}
    SLEEP    2    # << ensure all essential packets has been captured
    ${command}    SET VARIABLE    ue_deregister id=${ue_id} ue_deregister_type=switch_off
    ${pass_regexp}    SET VARIABLE    UE${ue_id}: detached
    ute_wtssim.execute_egate_command_and_wait_for_data
    ...    cmd=${command}
    ...    timeout=${__EGATE_COMMAND_TIMEOUT___}
    ...    pass_regexp=${pass_regexp}
    SLEEP    2    # << ensure all essential packets has been captured
    ute_tshark.stop_capturing    alias=detach_ue${ue_id}
    #eth3 5GCN messages
    ${ue_context_release_complete}    ute_tshark.get_packets_count
    ...    packet_filter=ngap.UEContextReleaseComplete_element
    ...    alias=detach_ue${ue_id}
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${ue_context_release_complete}==${1}
    ...    msg=Amount of UE Context Release Complete (${ue_context_release_complete}) is not equal to 1
    [Teardown]    ute_tshark.teardown_tshark    alias=detach_ue${ue_id}

SA Setup Primary PDU Session For PDU"${pdu_id}" UE"${ue_id}" GW"${gw_id}" NWSLICE"${nwslice_id}"
    [Documentation]    Triggers UE intiated PDU Session Setup procedure for selected pdu, ue, and gw.
    ...    The PDU Session Setup is verified in pcap
    ...    Parameters:
    ...    `pdu_id` - PDU Session ID
    ...    `ue_id` - ID of UE
    ...    `gw_id` - PDU Gateway ID
    ...    `nwslice_id` - Requested Network Slice for the PDU Session

    LOG TO CONSOLE    \n------- SA 5G Setup Primary PDU"${pdu_id}" Session for UE"${ue_id}" GW"${gw_id}" -------
    ${tshark_logs}    Prepare Logs Directory Path
    ...    subdir=tshark/primary_pdu_setup_${pdu_id}pdu_${ue_id}ue_${gw_id}gw
    ...    with_timestamp=${FALSE}
    ute_tshark.setup_tshark
    ...    interface=eth3
    ...    alias=primary_pdu_setup_${pdu_id}pdu_${ue_id}ue_${gw_id}gw
    ...    log_dir=${tshark_logs}
    ...    log_name=primary_pdu_setup_${pdu_id}pdu_${ue_id}ue_${gw_id}gw.pcap
    ute_tshark.start_capturing    capture_filter=sctp    alias=primary_pdu_setup_${pdu_id}pdu_${ue_id}ue_${gw_id}gw
    SLEEP    3    # << ensure all essential packets has been captured
    ${pass_regexp}    SET VARIABLE    Setup QosFlow
    ${command}    SET VARIABLE    ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} gw=${gw_id} nwslice=${nwslice_id}
    RUN KEYWORD AND CONTINUE ON FAILURE    ute_wtssim.execute_egate_command_and_wait_for_data
    ...    cmd=${command}
    ...    pass_regexp=${pass_regexp}
    ...    timeout=${__EGATE_COMMAND_TIMEOUT___}
    SLEEP    3    # << ensure all essential packets has been captured
    ute_tshark.stop_capturing    alias=primary_pdu_setup_${pdu_id}pdu_${ue_id}ue_${gw_id}gw
    #eth3 5GCN messages
    ${initial_context_setup_request}    ute_tshark.get_packets_count
    ...    packet_filter=ngap.InitialContextSetupRequest_element
    ...    alias=primary_pdu_setup_${pdu_id}pdu_${ue_id}ue_${gw_id}gw
    ${initial_context_setup_response}    ute_tshark.get_packets_count
    ...    packet_filter=ngap.InitialContextSetupResponse_element
    ...    alias=primary_pdu_setup_${pdu_id}pdu_${ue_id}ue_${gw_id}gw
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${initial_context_setup_request}==${1}
    ...    msg=Number of Initial Context Setup Request messages (${initial_context_setup_request}) is not equal to 1
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${initial_context_setup_response}==${1}
    ...    msg=Number of Initial Context Setup Response messages (${initial_context_setup_response}) is not equal to 1
    [Teardown]    ute_tshark.teardown_tshark    alias=primary_pdu_setup_${pdu_id}pdu_${ue_id}ue_${gw_id}gw

SA Setup Additional PDU Session For PDU"${pdu_id}" UE"${ue_id}" GW"${gw_id}" NWSLICE"${nwslice_id}"
    [Documentation]    Triggers UE intiated PDU Session Setup procedure for selected pdu, ue, and gw.
    ...    The PDU Session Setup is verified in pcap
    ...    Parameters:
    ...    `pdu_id` - PDU Session ID
    ...    `ue_id` - ID of UE
    ...    `gw_id` - PDU Gateway ID
    ...    `nwslice_id` - Requested Network Slice for the PDU Session

    LOG TO CONSOLE    \n------- SA 5G Setup Additional PDU"${pdu_id}" Session for UE"${ue_id}" GW"${gw_id}" -------
    ${tshark_logs}    Prepare Logs Directory Path
    ...    subdir=tshark/additional_pdu_setup_${pdu_id}pdu_${ue_id}ue_${gw_id}gw
    ...    with_timestamp=${FALSE}
    ute_tshark.setup_tshark
    ...    interface=eth3
    ...    alias=additional_pdu_setup_${pdu_id}pdu_${ue_id}ue_${gw_id}gw
    ...    log_dir=${tshark_logs}
    ...    log_name=additional_pdu_setup_${pdu_id}pdu_${ue_id}ue_${gw_id}gw.pcap
    ute_tshark.start_capturing    capture_filter=sctp    alias=additional_pdu_setup_${pdu_id}pdu_${ue_id}ue_${gw_id}gw
    SLEEP    3    # << ensure all essential packets has been captured
    ${pass_regexp}    SET VARIABLE    Setup QosFlow
    ${command}    SET VARIABLE    ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} gw=${gw_id} nwslice=${nwslice_id}
    RUN KEYWORD AND CONTINUE ON FAILURE    ute_wtssim.execute_egate_command_and_wait_for_data
    ...    cmd=${command}
    ...    pass_regexp=${pass_regexp}
    ...    timeout=${__EGATE_COMMAND_TIMEOUT___}
    SLEEP    3    # << ensure all essential packets has been captured
    ute_tshark.stop_capturing    alias=additional_pdu_setup_${pdu_id}pdu_${ue_id}ue_${gw_id}gw
    ${pdu_session_resource_setup_request}    ute_tshark.get_packets_count
    ...    packet_filter=ngap.PDUSessionResourceSetupRequest_element
    ...    alias=additional_pdu_setup_${pdu_id}pdu_${ue_id}ue_${gw_id}gw
    ${pdu_session_resource_setup_response}    ute_tshark.get_packets_count
    ...    packet_filter=ngap.PDUSessionResourceSetupResponse_element
    ...    alias=additional_pdu_setup_${pdu_id}pdu_${ue_id}ue_${gw_id}gw
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${pdu_session_resource_setup_request}==${1}
    ...    msg=Number of PDU Session Resource Setup Request messages (${pdu_session_resource_setup_request}) is not equal to 1
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${pdu_session_resource_setup_response}==${1}
    ...    msg=Number of PDU Session Resource Setup Response messages (${pdu_session_resource_setup_response}) is not equal to 1
    [Teardown]    ute_tshark.teardown_tshark    alias=additional_pdu_setup_${pdu_id}pdu_${ue_id}ue_${gw_id}gw

SA Modify PDU Session"${pdu_id}" with UE"${ue_id}" - "${procedure}" QoS Flow"${qosflows_nr}" And Collect PCAP
    [Documentation]    Modify PDU Session by adding/deleting/modifying QoS Flow
    ...    Modification is done with SA Modify PDU Session keyword (using egate command `ue_pdu_session_modify`).
    ...    Procedure verification is done based on egate output
    ...    Parameters:
    ...    `pdu_id` - ID of PDU to add, delete or modify
    ...    `ue_id` - ID of UE to add, delete or modify
    ...    `procedure` - add, delete and modify
    ...    `qosflows_nr` - nr of QoS Flow to add, delete or modify
    LOG TO CONSOLE    \n------- Modify PDU"${pdu_id}" Session for UE"${ue_id}" and QoS Flow"${qosflows_nr}" -------
    ${tshark_logs}    Prepare Logs Directory Path
    ...    subdir=tshark/${procedure}_pdu_session_${pdu_id}pdu_${ue_id}ue_${qosflows_nr}qos
    ...    with_timestamp=${FALSE}
    ute_tshark.setup_tshark
    ...    interface=eth3
    ...    alias=${procedure}_pdu_session_${pdu_id}pdu_${ue_id}ue_${qosflows_nr}qos
    ...    log_dir=${tshark_logs}
    ...    log_name=${procedure}_pdu_session_${pdu_id}pdu_${ue_id}ue_${qosflows_nr}qos.pcap
    ute_tshark.start_capturing    capture_filter=sctp    alias=${procedure}_pdu_session_${pdu_id}pdu_${ue_id}ue_${qosflows_nr}qos
    SLEEP    3    # << ensure all essential packets has been captured
    SHOULD CONTAIN    ${__QUOSFLOWS_PARAMS__}    ${procedure}
    ...    msg=${procedure} not allowed (only add, delete or modify)
    SA Modify PDU Session
    ...    ue_id=${ue_id}
    ...    qosflows_nr=${qosflows_nr}
    ...    pdu_id=${pdu_id}
    ...    procedure=${procedure}
    SLEEP    3    # << ensure all essential packets has been captured
    ute_tshark.stop_capturing    alias=${procedure}_pdu_session_${pdu_id}pdu_${ue_id}ue_${qosflows_nr}qos

SA Modify PDU Session
    [Documentation]    Modify PDU Session by adding/deleting/modifying QoS Flow
    ...    Modification is done using egate command `ue_pdu_session_modify`. Procedure verification is done based on
    ...    egate output
    ...    Arguments:
    ...    `pdu_id` - ID of PDU to add, delete or modify
    ...    `ue_id` - ID of UE to add, delete or modify
    ...    `procedure` - add, delete or modify
    ...    `qosflows_nr` - nr of QoS Flow to add, delete or modify
    [Arguments]    ${ue_id}    ${qosflows_nr}    ${pdu_id}    ${procedure}
    @{pdu}    String.SPLIT STRING    ${pdu_id}    ,
    ${pdu_length}    GET LENGTH    ${pdu}
    ${pass_regexp}    SET VARIABLE    QosFlow with QFI
    ${base_command}    SET VARIABLE
    ...    ue_pdu_session_modify ue=${ue_id} pdu=${pdu[0]} qosflows_to_${procedure}=${qosflows_nr} by=amf validation=on
    ${command}    SET VARIABLE IF
    ...    "${pdu_length}" == "1"
    ...    ${base_command}
    ...    "${pdu_length}" == "2"
    ...    ${base_command} pdu=${pdu[1]} qosflows_to_${procedure}=${qosflows_nr}
    SHOULD CONTAIN    ${__QUOSFLOWS_PARAMS__}    ${procedure}
    ...    msg=${procedure} not allowed (only add, delete or modify)
    ute_wtssim.execute_egate_command_and_wait_for_data
    ...    cmd=${command}
    ...    pass_regexp=${pass_regexp}
    ...    timeout=${__EGATE_COMMAND_TIMEOUT___}

SA Get Traffic Bearer Statistics
    [Arguments]    ${ue_id}    ${pdu_id}    ${qfi_id}    ${traffic_direction}
    ${pass_regexp}=    SET VARIABLE    UE ${ue_id}, pdu ${pdu_id}, qfi ${qfi_id}:
    ${cmd}=    SET VARIABLE    bearer_stats ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=${traffic_direction}
    ${command_result}    ute_wtssim.execute_egate_command_and_wait_for_data
    ...    cmd=${cmd}
    ...    pass_regexp=${pass_regexp}
    ...    timeout=${__EGATE_COMMAND_TIMEOUT___}
    ${match}    ${avg_traffic}=    SHOULD MATCH REGEXP    ${command_result}    Average data rate\\s*(\\d*)
    ${throughput_stats}=    CREATE DICTIONARY
    ...    average_traffic=${avg_traffic}    results=${command_result}
    [Return]    ${throughput_stats}

SA Set Traffic Type For PDU"${pdu_number}" UE"${ue_id}"
    [Documentation]    Sets traffic type for given UEs and PDUSessionId
    ${command}    SET VARIABLE    set_pdu_param ue=${ue_id} pdu=${pdu_number} trf_type=internal
    ute_wtssim.execute_egate_command    cmd=${command}

SA Start Traffic In SA Mode
    [Arguments]    ${ue}    ${pdu}    ${qfi}    ${dir}    ${mbps}    ${trf_id}=1
    ${command}    SET VARIABLE    trf_data_start ue=${ue} pdu=${pdu} qfi=${qfi} dir=${dir} mbps=${mbps} trf_id=${trf_id}
    ute_wtssim.execute_egate_command_and_wait_for_data    cmd=${command}    timeout=${__EGATE_COMMAND_TIMEOUT___}

SA Verify If Throughput Is Started
    [Arguments]    ${ue}    ${pdu}    ${qfi}    ${dir}
    SLEEP    5s
    ${throughput}    SA Get Traffic Bearer Statistics    ue_id=${ue}    pdu_id=${pdu}    qfi_id=${qfi}    traffic_direction=${dir}
    ${avg_tput_mbps}=    Evaluate    ${throughput}[average_traffic]/1000000
    SHOULD BE TRUE    ${avg_tput_mbps} > ${0}
    ...               msg=Throughput is not started: ${avg_tput_mbps} mbps
