*** Settings ***
Documentation
...   common keywords
# -- std libs --
Library    OperatingSystem
Library    Process
Library    Collections
Library    DateTime
Library    String

# -- taf/ute libs --
Library    taf.gnb.oam.coam.admin    WITH NAME    coam
Library    taf.transport.ssh    WITH NAME    ssh
#Library    ute_admin
Library      taf.sbts.oam.coam.admin
#Library    ute_admin_infomodel
Library      taf.collectors.infomodel.interface
#Library    ute_syslog
Library    ute_reporting_portal
#Library    ute_tshark
Library      taf.collectors.tshark/taf.collectors.tcpdump
#Library    ute_wtssim
Library    taf.converters.sherpa    WITH NAME    sherpa_converters
Library    taf.analyzer.sherpa    WITH NAME    sherpa_analyzer

# -- internals --
Library    ./main.py
Library    ./libraries/swconfig.py
Library    ./libraries/pm_counter.py

# -- custom listeners --
Library    ./listeners/FailListener.py    token=3e49117019e6d0eae27d7836a2a042bbe08498b6

*** Variables ***
${SUITE LOGS}    ${OUTPUT DIR}/Suite_logs

${__RUNTIME_BTS_IM_PATH__}    //NRBTS_M-*
${__LOCAL_BTS_IP__}    192.168.255.129
${__SYSLOG_IP__}    192.168.255.126
${__IPHY_SYSLOG_IP__}    192.168.200.126
${__HOSTNAME__}    127.0.0.1
${__USER__}    ute
${__WTS_ALIAS__}    WTS
${__WTS_DIRECTORY__}    /opt/iphy/latest
${__EGATE_PORT__}    20000
@{__EDAEMON_PORTS__}    10000    30000
${__EGATE_IP__}    0.0.0.0
@{__IP_ADDRESSES__}    10.0.1.121    10.0.1.131    10.0.1.132    10.0.1.133    10.0.1.134    10.0.1.135    10.0.1.136
${__IPHY_CONFIGURATIONS_PATH__}    /rom/simmode/
${__EGATE_COMMAND_TIMEOUT___}    10s
${__TIME_FOR_NSA_LUA_SETUP__}    3s
@{__QUOSFLOWS_PARAMS__}    add    del    modify
${SHERPA_SRC_IP}    10.0.1.2
${SHERPA_VLAN}    ${1}
${SHERPA_DSCP}    ${0}
${SHERPA_DEST_IP}    10.0.1.1
${SHERPA_DEST_PORT}    ${5678}
@{SHERPA_CELL_DNS_LEFT}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1
@{SHERPA_CELL_DNS_RIGHT}    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-1/NRCELL_R-1

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
    ute_syslog.start_syslog    ${SUITE LOGS}    syslog.log    ip=${__SYSLOG_IP__}    alias=default
    ute_syslog.start_syslog    ${SUITE LOGS}    syslog-iphy.log    ip=${__IPHY_SYSLOG_IP__}    alias=iphy
    ute_admin_infomodel.setup_infomodel    port=443    admin_api_log_dir=${SUITE LOGS}    alias=default
    ute_admin_infomodel.connect_infomodel    alias=default

Collect Mandatory Logs
    [Documentation]
    ...    Saves suite level SysLogs, Infomodel, Snapshot, and SosReport
    [Tags]    PRIVATE
    # gets snapshot with admin
    ${logs_dir}=    Prepare Logs Directory Path    admin_logs/snapshot
    ute_admin.setup_admin    bts_host=${__LOCAL_BTS_IP__}    admin_api_log_dir=${logs_dir}    alias=snapshot
    ute_admin.collect_snapshot    ${SUITE LOGS}/snapshot.zip    timeout=10 min    alias=snapshot
    ute_admin.teardown_admin    alias=snapshot

    # saves suite level infomodel
    ute_admin_infomodel.save_infomodel_log    ${SUITE LOGS}/infomodel.ims2    timeout=120    alias=default
    ute_admin_infomodel.teardown_infomodel    alias=default

    # stops writing to syslog files, and compresses them
    ute_syslog.collect_syslog_results    unzip=${FALSE}    alias=default
    ute_syslog.collect_syslog_results    unzip=${FALSE}    alias=iphy

    # runs SosReport script
    OperatingSystem.RUN    rm /opt/iphy/latest/SosReport*.tgz
    ${sosreport}=    Process.RUN PROCESS    ./sosReport_ASIK_ASIL.sh -c -s    shell=${TRUE}    cwd=/opt/iphy/latest
    OperatingSystem.COPY FILE    /opt/iphy/latest/SosReport*.tgz    ${SUITE LOGS}/SosReport.tgz

Get Active BTS Alarms
    [Arguments]    ${im_alias}=default    ${display}=${TRUE}
    [Documentation]
    ...    Fetch alarm objects from BTS
    ...    By default, alarms are logged as warnings. You can disable logging using `display=False` argument.
    [Tags]    PUBLIC
    ${query}=    SET VARIABLE    get list //ALARM-*
    ${alarms}=    ute_admin_infomodel.query_infomodel    ${query}    allow_negative_result=${TRUE}    alias=${im_alias}
    RUN KEYWORD IF    ${display}    Display BTS Alarms    ${alarms}
    [Return]    ${alarms}

Display BTS Alarms
    [Arguments]    ${alarms}
    [Documentation]
    ...    Logs passed ``alarms`` as warnings, in format:
    ...    ``ALARM [A:<alarm_id>|F:<fault_id>|<severity>] <alarm_name> - <alarm_detail>``
    [Tags]    PRIVATE
    FOR    ${a}    IN    @{alarms}
        LOG    ALARM [A:${a.alarmNumber}|F:${a.faultId}|${a.alarmSeverity}] ${a.alarmName} - ${a.alarmText.alarmDetail}    level=WARN
    END

Configure Required IP Addresses
    FOR    ${ip}    IN    @{__IP_ADDRESSES__}
        ${result}    Is Ip Added    ${ip}
        RUN KEYWORD UNLESS    ${result}    Add IP Address    ${ip}
    END
Is Ip Added
    [Arguments]    ${ip}
    ${output}    main.execute_command_in_console    local    ip addr
    ${result}    RUN KEYWORD AND RETURN STATUS    SHOULD CONTAIN    ${output}    ${ip}
    [Return]    ${result}

Add IP Address
    [Arguments]    ${ip}
    main.execute_command_in_console    local    sudo ip addr add ${ip}/24 dev eth3
    ${output}=    main.execute_command_in_console    local    ip addr
    SHOULD CONTAIN    ${output}    ${ip}

Stop WTS
    [Documentation]    Stops WTS proceses

    ${log_path}=    Prepare Logs Directory Path    WTS
    ute_wtssim.stop_and_collect_wts_logs    subdirectory=${log_path}

Wait for OnAir
    [Arguments]    ${timeout}=480
    [Documentation]    Wait given number of seconds for CELL to be onAir
    ...    Verification of onAir is done by checking proceduralState of CELL with usage of
    ...    query_infomodel keyword from ute_admin_infomodel library
    ...    Parameters:
    ...    `timeout` - timeout in seconds
    Check Airphone Cell Setup    cell_id=.*    timeout=${timeout}
    ute_admin_infomodel.query_infomodel
    ...    every /MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-1/MRBTS_M-1/NRBTS_M-1/CELL_M-* is [stateInfo.proceduralState=OnAirDone]
    ...    timeout=${timeout}

Wait "${timeout}"s Until "${dist_name}" Is "${availabilityStatus}"
    [Documentation]    Waits until infomodel object reaches given status
    ...    Parameters:
    ...    `timeout` - timeout after which test fails if object(s) (dist_name) does not match given predicates
    ...    `dist_name` - IM object dist_name, for example: //RMOD_L-*
    ...    `availabilityStatus` - IM parameter 'stateInfo.availabilityStatus', for example: Online
    ute_admin_infomodel.query_infomodel    ${dist_name} is [stateInfo.availabilityStatus=${availabilityStatus}]    timeout=${timeout}

Wait "${timeout}"s for CELL"${physical_layer_cell_id}" OnAir
    [Documentation]    Wait given number of seconds for CELL to be onAir
    ...    Verification of onAir is done by checking proceduralState of CELL with usage of
    ...    query_infomodel keyword from ute_admin_infomodel library
    ...    Parameters:
    ...    `timeout` - timeout in seconds
    ...    `physical_layer_cell_id` - physical layer ID of cell
    ute_admin_infomodel.query_infomodel
    ...    query=/MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-1/MRBTS_M-1/NRBTS_M-1/CELL_M-${physical_layer_cell_id} is [stateInfo.proceduralState=OnAirDone]
    ...    timeout=${timeout}

Check If Cell"${physical_layer_cell_id}" Is OnAir
    [Documentation]    Check If Cell Is OnAir
    ...    This is a wrapper for keyword Wait "timeout"s for CELL"physical_layer_cell_id" OnAir.
    ...    It was made in order to emphasize the purpose of performed action in a test's flow.
    ...    Parameters:
    ...    `physical_layer_cell_id` - physical layer ID of cell
    Wait "5"s for CELL"${physical_layer_cell_id}" OnAir

Update Iphy Configuration
    [Arguments]    ${path_to_custom_iphy}    ${radio_name}    ${gscn_value}=1
    main.update_iphy_xml    radio_name=${radio_name}    custom_iphy=${path_to_custom_iphy}    gscn_value=${gscn_value}
    main.copy_file    ${path_to_custom_iphy}    iphy://${__IPHY_CONFIGURATIONS_PATH__}
    ${custom_iphy_xml_name}=    SHOULD MATCH REGEXP    ${path_to_custom_iphy}    [^/\\s]+\\.xml$
    ${link_custom_iphy_xml_cmd}=    SET VARIABLE
    ...    ln -sf ${__IPHY_CONFIGURATIONS_PATH__}${custom_iphy_xml_name} ${__IPHY_CONFIGURATIONS_PATH__}iphy.xml
    main.execute_command_in_console    iphy    ${link_custom_iphy_xml_cmd}

Perform Commissioning
    [Arguments]    ${scfc_path}
    main.update_vlan_value    full_scfc=${scfc_path}
    coam.connect_to
    coam.perform_commissioning    scf_file=${scfc_path}    skip_parameter_relation_errors=True    timeout=900
    [Teardown]    coam.teardown_admin

Delta Commissisoning
    [Arguments]    ${path_to_delta}
    coam.connect_to
    coam.perform_delta_recommissioning    delta_file=${path_to_delta}    skip_parameter_relation_errors=True
    [Teardown]    coam.teardown_admin

Check Airphone Cell Setup
    [Documentation]    Check in APL3.log that cell setup was completed
    [Arguments]    ${cell_id}    ${timeout}=240    ${retry_interval}=20s
    WAIT UNTIL KEYWORD SUCCEEDS    ${timeout}    ${retry_interval}    Grep APL3 File For Cell Setup    ${cell_id}

Check Airphone Cell Setup And Download APL3 Log
    [Documentation]    Check in APL3.log that cell setup was completed and downloads APL3.log file
    [Arguments]    ${cell_id}    ${timeout}=180    ${retry_interval}=20s
    WAIT UNTIL KEYWORD SUCCEEDS    ${timeout}    ${retry_interval}    Grep APL3 File For Cell Setup    ${cell_id}
    [Teardown]    Download APL3 File    cell${cell_id}_setup_APL3.log

Grep APL3 File For Cell Setup
    [Arguments]    ${cell_id}
    ${cell_setup_message}=    SET VARIABLE    grep "Cell Setup completed for \\[CELL_ID:${cell_id}\\]" /tmp/APL3.log
    main.execute_command_in_console    iphy    ${cell_setup_message}

Download APL3 File
    [Arguments]    ${filename}
    ${APL3_logs}    Prepare Logs Directory Path    APL3    with_timestamp=${FALSE}
    ${timestamp}    GET CURRENT DATE
    ${timestamp}    REPLACE STRING    ${timestamp}    ${SPACE}    _
    ${scp}    SET VARIABLE    sshpass -p oZPS0POrRieRtu scp -oUserKnownHostsFile="/dev/null" -P 22 -oStrictHostKeyChecking="no" -oLogLevel="QUIET"
    ${src}    SET VARIABLE    toor4nsn@192.168.200.1:/tmp/APL3.log
    ${dst}    SET VARIABLE    ${APL3_logs}/${timestamp}_${filename}
    RUN    ${scp} ${src} ${dst}

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
    ${output}    main.execute_command_in_console    local    find "${logs_dir}" -name "${pattern}" | xargs rm -r

Return size of SUBDIRECTORY "${subdir}" in bytes
    [Documentation]    Return size of given subdirectory in bytes
    ...    Parameters:
    ...    `subdir` - subdirectory name or relative path
    ...    Absolute path to subdirectory is resolved by keyword resolve_logs_directory from main.py and
    ...    is depended on current execution context in the same manner as in Prepare Logs Directory Path keyword.
    ${logs_dir}    main.resolve_logs_directory    ${subdir}    ${FALSE}
    ${size}    main.execute_command_in_console    local    du -sb ${logs_dir} | awk '{print $1}'
    [Return]    ${size}

Get Average Value Of PM Counter
    [Arguments]    ${pm_counter_path}    ${interval}
    [Documentation]    Return avg value of given pm counter measurements
    ...    Parameters:
    ...    `pm_counter_path` - path to PM counter e.g.: BTS/BTS/NRBTS-1/NF1UB/M55323C01009
    ...    `interval` - time interval given in rounded number (int) of minutes for which pm counter has been measured.
    ...    Have to be greater than 2. Based on that parameter, number of valid measurements is calculated.
    ${number_of_measurements}    EVALUATE    ${interval} - 2
    ${measurements}    Get PM Counter "${pm_counter_path}" Measurements
    ${avg}    pm_counter.get_avg_pm_counter_value    ${measurements}    ${pm_counter_path}    ${number_of_measurements}
    [Return]    ${avg}

Get PM Counter "${pm_counter_path}" Measurements Untill Success
    [Documentation]    Try multiple times to get PM counter measurements using taf.gnb.oam.coam.admin
    ...    Parameters:
    ...    `pm_counter_path` - path to PM counter e.g.: BTS/BTS/NRBTS-1/NF1UB/M55323C01009
    ${pm_counters}=    Wait Until Keyword Succeeds    6x    15s    Get PM Counter "${pm_counter_path}" Measurements
    [Return]    ${pm_counters}

Get PM Counter "${pm_counter_path}" Measurements
    [Documentation]    Get PM counter measurements using taf.gnb.oam.coam.admin
    ...    Parameters:
    ...    `pm_counter_path` - path to PM counter e.g.: BTS/BTS/NRBTS-1/NF1UB/M55323C01009
    [Teardown]    coam.teardown_admin
    coam.setup_admin
    ${pm_counter_measurements}    coam.get_pm_counters_by_dist_name    dist_name=${pm_counter_path}    timeout=60
    [Return]    ${pm_counter_measurements}

Reboot BTS
    [Documentation]    Performs BTS (site) reset via Admin
    [Arguments]    ${wait_till_bts_operational}=${TRUE}
    ${admin_alias}=    SET VARIABLE    admin_logs/site_reset
    ${log_path}=    Prepare Logs Directory Path    ${admin_alias}
    coam.setup_admin
    coam.reset_site    timeout=480
    RUN KEYWORD IF    ${wait_till_bts_operational}    Wait for BTS configured
    [Teardown]    coam.teardown_admin

Wait For BTS Configured
    [Documentation]    Waits till BTS is at least configured
    ...    References:
    ...    - https://oam.emea.nsn-net.net/include/btsom_efs/state_management/Common/BtsVsRatState.html
    [Arguments]    ${im_alias}=default
    ${state_condition}=    SET VARIABLE    stateInfo.proceduralState=regex"Configured|OnAir"
    ute_admin_infomodel.query_infomodel    ${__RUNTIME_BTS_IM_PATH__} is [${state_condition}]    timeout=900    alias=${im_alias}

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
    main.copy_file    fsm://${fsm_swconfig_path}    ${local_swconfig_path}
    swconfig.add_swconfig_flag    flag=${flag}    value=${value}    swconfig_path=${local_swconfig_path}    comment=${comment}
    main.copy_file    ${local_swconfig_path}    fsm://${fsm_swconfig_path}

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
    ${avg_tput_mbps}    EVALUATE    float(&{throughput}[average])/float(1000000)
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
    ${pass_regexp}=    SET VARIABLE    UE ${ue_id}, bearer ${bearer_id}:
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
    ${entry_already_exists}    main.execute_command_in_console    local    ${eth_check_cmd}
    ${add_eth_cmd}    SET VARIABLE    sudo ip addr add ${ip}/${mask} dev ${interface} label ${label}
    RUN KEYWORD IF    '${entry_already_exists}' == 'False'    main.execute_command_in_console    local    ${add_eth_cmd}

Start Tshark Packet Capturing For "${alias}"
    [Documentation]    Starts Tshark packet capturing for `any` interface and given alias.
    ...    Parameters:
    ...    alias: alias used to define tshark session
    ${tshark_logs}    Prepare Logs Directory Path    tshark/${alias}   with_timestamp=${FALSE}
    ute_tshark.setup_tshark
    ...    interface=any
    ...    alias=${alias}
    ...    log_dir=${tshark_logs}
    ...    log_name=${alias}
    ute_tshark.start_capturing    alias=${alias}

Stop Tshark Packet Capturing For "${alias}"
    [Documentation]    Stops Tshark packet capturing for given alias.
    ...    Parameters:
    ...    alias: alias used to define tshark session
    ute_tshark.stop_capturing    alias=${alias}

# -- NSA --
NSA Start WTS
    [Arguments]    ${lua_path}
    Configure Required IP Addresses
    ute_wtssim.start_wts_applications    edaemon_ports=${__EDAEMON_PORTS__}    cfg_file=${lua_path}
    SLEEP    ${__TIME_FOR_NSA_LUA_SETUP__}
    WAIT UNTIL KEYWORD SUCCEEDS    3x    2s    NSA Setup X2 Link Between ENB and GNB

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
    [Arguments]    ${ue_id}=1
    ${command}    SET VARIABLE    ue_detach id=${ue_id}
    ute_wtssim.execute_egate_command_and_wait_for_data
    ...    cmd=${command}
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
    ute_tshark.setup_tshark    interface=any    alias=any_detach_ue${ue_id}    log_dir=${tshark_logs}    log_name=any_detach_ue${ue_id}
    ute_tshark.start_capturing    alias=any_detach_ue${ue_id}
    SLEEP    2    # << ensure all essential packets has been captured
    NSA Detach UE    ${ue_id}
    SLEEP    2    # << ensure all essential packets has been captured
    ute_tshark.stop_capturing    alias=any_detach_ue${ue_id}
    ${rrc_connection_release}              ute_tshark.get_packets_count
    ...                                    packet_filter=lte-rrc.releaseCause == 1 && iphy.ue_id == ${ue_id}
    ...                                    alias=any_detach_ue${ue_id}
    ${sgnb_release_request_acknowledge}    ute_tshark.get_packets_count
    ...                                    packet_filter=x2ap.SgNBReleaseRequestAcknowledge_element
    ...                                    alias=any_detach_ue${ue_id}
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${rrc_connection_release}==${1}
    ...                                    msg=RRCConnectionRelease msg is missing: UE${ue_id} detach
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${sgnb_release_request_acknowledge}==${1}
    ...                                    msg=SgNBReleaseRequestAcknowledge msg is missing: UE${ue_id} detach
    ute_tshark.teardown_tshark    alias=any_detach_ue${ue_id}

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
    ute_tshark.setup_tshark    interface=any    alias=any_attach_ue${ue_id}    log_dir=${tshark_logs}    log_name=any_attach_ue${ue_id}
    ute_tshark.start_capturing    alias=any_attach_ue${ue_id}
    SLEEP    2    # << ensure all essential packets has been captured
    NSA LTE Attach UE    ${ue_id}
    SLEEP    2    # << ensure all essential packets has been captured
    ute_tshark.stop_capturing    alias=any_attach_ue${ue_id}
    ${s1ap_attach_complete}    ute_tshark.get_packets_count
    ...                        packet_filter=s1ap.S1AP_PDU==0 && nas_eps.nas_msg_emm_type==0x43
    ...                        alias=any_attach_ue${ue_id}
    ${rrc_attach_to_cell}      ute_tshark.get_packets_count
    ...                        packet_filter=nas_eps.nas_msg_emm_type==0x43 && iphy.cell_id==${physical_layer_cell_id} && iphy.ue_id==${ue_id}
    ...                        alias=any_attach_ue${ue_id}
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${s1ap_attach_complete}==${1}
    ...                                    msg=S1AP msg is missing: UE${ue_id} attach complete
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${rrc_attach_to_cell}==${1}
    ...                                    msg=RRC msg is missing: UE${ue_id} attach to the CELL${physical_layer_cell_id}
    ute_tshark.teardown_tshark    alias=any_attach_ue${ue_id}

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
    ute_tshark.setup_tshark    interface=any    alias=sgnb_addition${ue_id}    log_dir=${tshark_logs}    log_name=sgnb_addition${ue_id}
    ute_tshark.start_capturing    alias=sgnb_addition${ue_id}
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
    ...    SNStatusTransfer                        x2ap.SNStatusTransfer_element && ip.src \=\= 10.0.1.121 && ip.dst \=\= 10.0.1.2

    ${packets_and_filters}    GET DICTIONARY ITEMS    ${sgnb_addition_packets_and_filters}
    FOR    ${packet}    ${filter}    IN    @{packets_and_filters}
        ${packets_count}    ute_tshark.get_packets_count    packet_filter=${filter}    alias=sgnb_addition${ue_id}
        RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${packets_count}==${1}    msg=${packet} not visible for UE${ue_id} SgNB Addition
    END
    ute_tshark.teardown_tshark    alias=sgnb_addition${ue_id}

# -- SA --
SA Start WTS
    [Arguments]    ${lua_path}    ${wait_for_onAir}=${TRUE}
    ute_wtssim.start_wts_applications    edaemon_ports=${__EDAEMON_PORTS__}    cfg_file=${lua_path}
    Run Keyword If    ${wait_for_onAir}    Wait for OnAir

SA 5G Attach UE"${ue_id}"
    [Documentation]    Attach UE to 5G NR CELL"1" in SA mode
    ...    Attach is done using egate command `ue_register`. Attach verification is done based on packets captured
    ...    by tshark which detailed description can be found in used keywords.
    ...    Parameters:
    ...    `ue_id` - ID of UE to attach
    LOG TO CONSOLE    \n------- SA 5G Attach UE"${ue_id}" -------
    ${tshark_logs}    Prepare Logs Directory Path    tshark/attach_keyword    with_timestamp=${FALSE}
    ute_tshark.setup_tshark
    ...    interface=any
    ...    alias=any_attach_ue${ue_id}
    ...    log_dir=${tshark_logs}
    ...    log_name=any_attach_ue${ue_id}
    ute_tshark.start_capturing    alias=any_attach_ue${ue_id}
    SLEEP    2    # << ensure all essential packets has been captured
    ${command}    SET VARIABLE    ue_register id=${ue_id}
    ute_wtssim.execute_egate_command_and_wait_for_data
    ...    cmd=${command}
    ...    timeout=${__EGATE_COMMAND_TIMEOUT___}
    SLEEP    2    # << ensure all essential packets has been captured
    ute_tshark.stop_capturing    alias=any_attach_ue${ue_id}
    ${rrc_setup}    ute_tshark.get_packets_count
    ...    packet_filter=nr-rrc.criticalExtensions == 0 && nr-rrc.c1 == 1 && iphy.ue_id == ${ue_id}
    ...    alias=any_attach_ue${ue_id}
    ${initial_ue_message_regustration}    ute_tshark.get_packets_count
    ...    packet_filter=ngap.InitialUEMessage_element
    ...    alias=any_attach_ue${ue_id}
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${rrc_setup}>=${1}
    ...    msg=Amount of RRC Setup (${rrc_setup}) is not equal to 1
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${initial_ue_message_regustration}>=${1}
    ...    msg=Amount of Initial UE Message (${initial_ue_message_regustration}) is not equal to 1
    [Teardown]    ute_tshark.teardown_tshark    alias=any_attach_ue${ue_id}

SA 5G Detach UE"${ue_id}"
    [Documentation]    Detach UE to 5G NR CELL"1" in SA mode
    ...    Detach is done using egate command `ue_deregister`. Detach verification is done based on packets captured
    ...    by tshark which detailed description can be found in used keywords.
    ...    Parameters:
    ...    `ue_id` - ID of UE to detach
    LOG TO CONSOLE    \n------- SA 5G Detach UE"${ue_id}" -------
    ${tshark_logs}    Prepare Logs Directory Path    tshark/detach_keyword    with_timestamp=${FALSE}
    ute_tshark.setup_tshark
    ...    interface=any
    ...    alias=any_detach_ue${ue_id}
    ...    log_dir=${tshark_logs}
    ...    log_name=any_detach_ue${ue_id}
    ute_tshark.start_capturing    alias=any_detach_ue${ue_id}
    SLEEP    2    # << ensure all essential packets has been captured
    ${command}    SET VARIABLE    ue_deregister id=${ue_id} ue_deregister_type=switch_off
    ${pass_regexp}    SET VARIABLE    UE${ue_id}: detached
    ute_wtssim.execute_egate_command_and_wait_for_data
    ...    cmd=${command}
    ...    timeout=${__EGATE_COMMAND_TIMEOUT___}
    ...    pass_regexp=${pass_regexp}
    SLEEP    2    # << ensure all essential packets has been captured
    ute_tshark.stop_capturing    alias=any_detach_ue${ue_id}
    ${ue_context_release_complete}    ute_tshark.get_packets_count
    ...    packet_filter=ngap.UEContextReleaseComplete_element
    ...    alias=any_detach_ue${ue_id}
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${ue_context_release_complete}==${1}
    ...    msg=Amount of UE Context Release Complete (${ue_context_release_complete}) is not equal to 1
    [Teardown]    ute_tshark.teardown_tshark    alias=any_detach_ue${ue_id}

SA Setup Primary PDU Session For PDU"${pdu_id}" UE"${ue_id}" GW"${gw_id}" NWSLICE"${nwslice_id}"
    [Documentation]    Triggers UE intiated PDU Session Setup procedure for selected pdu, ue, and gw.
    ...    The PDU Session Setup is verified in pcap
    ...    Parameters:
    ...    `pdu_id` - PDU Session ID
    ...    `ue_id` - ID of UE
    ...    `gw_id` - PDU Gateway ID
    ...    `nwslice_id` - Requested Network Slice for the PDU Session

    LOG TO CONSOLE    \n------- SA 5G Setup Primary PDU"${pdu_id}" Session for UE"${ue_id} GW"${gw_id}" -------
    ${tshark_logs}    Prepare Logs Directory Path
    ...    subdir=tshark/primary_pdu_setup_${pdu_id}pdu_${ue_id}ue_${gw_id}gw
    ...    with_timestamp=${FALSE}
    ute_tshark.setup_tshark
    ...    interface=any
    ...    alias=primary_pdu_setup_${pdu_id}pdu_${ue_id}ue_${gw_id}gw
    ...    log_dir=${tshark_logs}
    ...    log_name=primary_pdu_setup_${pdu_id}pdu_${ue_id}ue_${gw_id}gw.pcap
    ute_tshark.start_capturing    alias=primary_pdu_setup_${pdu_id}pdu_${ue_id}ue_${gw_id}gw
    SLEEP    3    # << ensure all essential packets has been captured
    ${pass_regexp}    SET VARIABLE    Setup QosFlow
    ${command}    SET VARIABLE    ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} gw=${gw_id} nwslice=${nwslice_id}
    RUN KEYWORD AND CONTINUE ON FAILURE    ute_wtssim.execute_egate_command_and_wait_for_data
    ...    cmd=${command}
    ...    pass_regexp=${pass_regexp}
    ...    timeout=${__EGATE_COMMAND_TIMEOUT___}
    SLEEP    3    # << ensure all essential packets has been captured
    ute_tshark.stop_capturing    alias=primary_pdu_setup_${pdu_id}pdu_${ue_id}ue_${gw_id}gw
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

    LOG TO CONSOLE    \n------- SA 5G Setup Additional PDU"${pdu_id}" Session for UE"${ue_id} GW"${gw_id}" -------
    ${tshark_logs}    Prepare Logs Directory Path
    ...    subdir=tshark/additional_pdu_setup_${pdu_id}pdu_${ue_id}ue_${gw_id}gw
    ...    with_timestamp=${FALSE}
    ute_tshark.setup_tshark
    ...    interface=any
    ...    alias=additional_pdu_setup_${pdu_id}pdu_${ue_id}ue_${gw_id}gw
    ...    log_dir=${tshark_logs}
    ...    log_name=additional_pdu_setup_${pdu_id}pdu_${ue_id}ue_${gw_id}gw.pcap
    ute_tshark.start_capturing    alias=additional_pdu_setup_${pdu_id}pdu_${ue_id}ue_${gw_id}gw
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
    ...    interface=any
    ...    alias=${procedure}_pdu_session_${pdu_id}pdu_${ue_id}ue_${qosflows_nr}qos
    ...    log_dir=${tshark_logs}
    ...    log_name=${procedure}_pdu_session_${pdu_id}pdu_${ue_id}ue_${qosflows_nr}qos.pcap
    ute_tshark.start_capturing    alias=${procedure}_pdu_session_${pdu_id}pdu_${ue_id}ue_${qosflows_nr}qos
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
    [Arguments]    ${ue}    ${pdu}    ${qfi}    ${dir}    ${mbps}
    ${command}    SET VARIABLE    trf_data_start ue=${ue} pdu=${pdu} qfi=${qfi} dir=${dir} mbps=${mbps}
    ute_wtssim.execute_egate_command_and_wait_for_data    cmd=${command}    timeout=${__EGATE_COMMAND_TIMEOUT___}

SA Verify If Throughput Is Started
    [Arguments]    ${ue}    ${pdu}    ${qfi}    ${dir}
    SLEEP    5s
    ${throughput}    SA Get Traffic Bearer Statistics    ue_id=${ue}    pdu_id=${pdu}    qfi_id=${qfi}    traffic_direction=${dir}
    ${avg_tput_mbps}    EVALUATE    float(&{throughput}[average_traffic])/float(1000000)
    SHOULD BE TRUE    ${avg_tput_mbps} > ${0}
    ...               msg=Throughput is not started: ${avg_tput_mbps} mbps

# --Sherpa--
Setup Sherpa Traces Via WebEM
    [Documentation]    Start streaming Sherpa traces: L2Ps, L2Lo, L2HiPdcp, L2HiRlc
    ${logs_dir}=    Prepare Logs Directory Path    admin_logs/sherpa
    coam.setup_admin    bts_host=${__LOCAL_BTS_IP__}    admin_api_log_dir=${logs_dir}    alias=sherpa
    ${smod_position}=    coam.get_smod_position    alias=sherpa
    @{cell_path}=    SET VARIABLE IF    '${smod_position}'=='right'
    ...    ${SHERPA_CELL_DNS_RIGHT}
    ...    ${SHERPA_CELL_DNS_LEFT}
    coam.start_uplane_l2_trace    source_ip=${SHERPA_SRC_IP}    vlan=${SHERPA_VLAN}    dscp=${SHERPA_DSCP}
    ...    destination_ip=${SHERPA_DEST_IP}    destination_port=${SHERPA_DEST_PORT}
    ...    nr_cell_dns=${cell_path}    trace_type=Sherpa    up_sw=L2Ps    connection=sherpa
    coam.start_uplane_l2_trace    source_ip=${SHERPA_SRC_IP}    vlan=${SHERPA_VLAN}    dscp=${SHERPA_DSCP}
    ...    destination_ip=${SHERPA_DEST_IP}    destination_port=${SHERPA_DEST_PORT}
    ...    nr_cell_dns=${cell_path}    trace_type=Sherpa    up_sw=L2Lo    connection=sherpa
    coam.start_uplane_l2_trace    source_ip=${SHERPA_SRC_IP}    vlan=${SHERPA_VLAN}    dscp=${SHERPA_DSCP}
    ...    destination_ip=${SHERPA_DEST_IP}    destination_port=${SHERPA_DEST_PORT}
    ...    nr_cell_dns=${cell_path}    trace_type=Sherpa    up_sw=L2HiRlc    connection=sherpa
    coam.start_uplane_l2_trace    source_ip=${SHERPA_SRC_IP}    vlan=${SHERPA_VLAN}    dscp=${SHERPA_DSCP}
    ...    destination_ip=${SHERPA_DEST_IP}    destination_port=${SHERPA_DEST_PORT}
    ...    nr_cell_dns=${cell_path}    trace_type=Sherpa    up_sw=L2HiPdcp    connection=sherpa
    [Teardown]    coam.teardown_admin    alias=sherpa

Collect Sherpa Traces
    [Tags]    DESIGNSTEP
    Start Collecting Sherpa Traces
    SLEEP    4    # << Sherpa Traces collection period
    Stop Collecting Sherpa Traces
    Teardown Sherpa Traces Via WebEM

Teardown Sherpa Traces Via WebEM
    ${logs_dir}=    Prepare Logs Directory Path    admin_logs/sherpa_stop
    coam.setup_admin    bts_host=${__LOCAL_BTS_IP__}    admin_api_log_dir=${logs_dir}    alias=sherpa
    coam.stop_uplane_l2_trace    up_sw=L2Ps     trace_type=Sherpa    connection=sherpa
    coam.stop_uplane_l2_trace    up_sw=L2Lo    trace_type=Sherpa    connection=sherpa
    coam.stop_uplane_l2_trace    up_sw=L2HiRlc    trace_type=Sherpa    connection=sherpa
    coam.stop_uplane_l2_trace    up_sw=L2HiPdcp    trace_type=Sherpa    connection=sherpa
    [Teardown]    coam.teardown_admin    alias=sherpa

Start Collecting Sherpa Traces
    ${logs_dir}=    Prepare Logs Directory Path    Sherpa/
    SET SUITE VARIABLE    ${TCPDUMP_FILE_NAME}    sherpa.pcap
    SET SUITE VARIABLE    ${TCPDUMP_FILE_PATH_ON_VM}    ${logs_dir}/${TCPDUMP_FILE_NAME}
    ${cmd}=    SET VARIABLE    sudo tcpdump -i eth3 udp -w ${TCPDUMP_FILE_PATH_ON_VM}
    START PROCESS    ${cmd}    shell=yes

Stop Collecting Sherpa Traces
    ${kill_tcpdump_proces}=    SET VARIABLE
    ...    ps -ef | grep ${TCPDUMP_FILE_NAME} | grep -v grep | awk '{print $2}' | sudo xargs kill -s SIGTERM
    SLEEP    3
    main.execute_command_in_console    local    ${kill_tcpdump_proces}

Verify '${dir}' Throughput Based On Sherpa Traces
    Convert Pcap File Into Sherpa Csv File    ${TCPDUMP_FILE_PATH_ON_VM}
    Verify Average Throughput From Sherpa CSV File    macro__${dir}Stat.csv    ${EXPECTED_TPUT_MBPS}

Convert Pcap File Into Sherpa Csv File
    [Arguments]    ${pcap_path}
    ${Sherpa_csv}    Prepare Logs Directory Path    Sherpa_CSV
    SET SUITE VARIABLE    ${SHERPA_CSV_DIRECTORY_NAME}    ${Sherpa_csv}
    sherpa_converters.create_sherpa_converter    name=sherpaconverter
    ...                                          file_path_pattern=${pcap_path}
    ...                                          output_path=${SHERPA_CSV_DIRECTORY_NAME}
    sherpa_converters.setup    sherpaconverter
    sherpa_converters.convert    sherpaconverter
    sherpa_converters.teardown    sherpaconverter
    REMOVE FILE    path=${SHERPA_CSV_DIRECTORY_NAME}/sherpa/${TCPDUMP_FILE_NAME}    #delete redundant sherpa.pcap file

Verify Average Throughput From Sherpa CSV File
    [Arguments]    ${csv_file}    ${expected_tput}
    LOG TO CONSOLE    \n------- Check Throughput Using Sherpa Traces -------
    sherpa_analyzer.setup_reader    file_path=${SHERPA_CSV_DIRECTORY_NAME}/sherpa/${csv_file}
    @{tput_values_list}=    sherpa_analyzer.get_values_for_column    TP(kb/s)
    Remove Values From List    ${tput_values_list}    ${empty}
    ${length_list}=    GET LENGTH    ${tput_values_list}
    ${sum}=    EVALUATE     reduce(lambda a, b: int(a) + int(b), ${tput_values_list})    modules=functools
    ${average_tput}=    EVALUATE    float(${sum}/${length_list}/1000)
    SHOULD BE TRUE    ${average_tput} >= ${expected_tput}
    ...    msg=Throughput less than expected ${expected_tput} mbps: ${average_tput} mbps
