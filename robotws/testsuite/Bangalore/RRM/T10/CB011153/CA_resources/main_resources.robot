*** Settings ***
Documentation
...    maintainer:   I_TADEK_DEVS
...    contact:      I_TADEK_DEVS@internal.nsn.com
...    JIRA:         https://jiradc.int.net.nokia.com/projects/CITTA
...    Confluence:   https://confluence.int.net.nokia.com/display/hotrta/House+of+the+rising+test+automation

# Standard libraries
Library    Collections
Library    DateTime
Library    OperatingSystem
Library    Process
Library    String

# TAF libraries
Library    taf.sbts.oam.coam.admin    WITH NAME    admin

# UTE libraries
#Library    ute_admin_infomodel
#Library    ute_pdu
Library    taf.sw.syslog    WITH NAME    taf_syslog
Library    taf.sw.wtssim

# Additional libraries and python files
Library    ./libraries/testline_configuration.py
Library    ./libraries/logs_directory.py
Library    ./libraries/pm_counters.py
Library    ./libraries/swconfig.py
Library    ./libraries/tshark.py
Library    ./libraries/web_connection.py
Library    ./libraries/rmods_query.py

Library    ./libraries/hacking.py

Resource    ./resources/shell/shell.resource
Resource    ./resources/reporting/reporting.resource


*** Variables ***
# UTE Constants; used by some keywords in place of default arguments
# you can overwrite these values in your suite for debug purposes
${__TL_CONFIG_ROOT__}    /home/ute/testline_configuration
${__DEFAULT_VIRTUAL_ENV__}    /home/ute/test_repo
${__DEFAULT_PROXY__}    http://defra1c-proxy.emea.nsn-net.net:8080/

# Set at runtime; values here are just a commentary
${__TL_CURRENT_NODE__}    "testline vm (node) from where test was launched"
${__TL_NODE_LIST__}    "list of all testline vms (nodes)"
${__TL_HAS_CUS__}    "set True if CUS is attached to current node, False otherwise"

# Some rather const variables
${__RUNTIME_BTS_IM_PATH__}    //LNBTS_R-*
${__RUNTIME_RMOD_IM_PATH__}    //RMOD_R-*
${__CELL_IM_PATH__}    //CELL_M-*
${__DSP_IM_PATH__}    //BBU_L-*//DSP_L-*
${__ALARM_IM_PATH__}    //ALARM-*
${__CPLANE_IM_PATH__}    //BTS_L-*//CPLANE-*
${__LOCAL_BTS_IP__}    192.168.255.129
${__ADMIN_BTS_PORT__}    443
${__SYSLOG_IP__}    192.168.255.126
@{__CUS_SYSLOG_IP__}    192.168.200.126    192.168.200.127    192.168.200.128
${__CUS_SYSLOG_PORT__}    51601
${__DEFAULT_SYSLOG_FILE_NAME__}    syslog.log
${__DEFAULT_CUS_SYSLOG_FILE_NAME__}    syslog-cus.log
${__DEFAULT_INFOMODEL_FILE_NAME__}    infomodel.ims2
${__DEFAULT_SNAPSHOT_FILE_NAME__}    snapshot.zip
${__BTS_NOT_COMMISSIONED_STATE__}    NotCommissioned
${__DEFAULT_SCFC__}    SCF from newly reserved TL

# Authentication
&{__BTS_AUTHENTICATOR__}    user=toor4nsn    password=oZPS0POrRieRtu


*** Keywords ***
Run Keyword And Warn On Failure
    [Arguments]    ${name}    @{args}
    [Documentation]    When keyword fails, this passes, but a warning is issued.
    ${state}    ${output}=    Run Keyword And Ignore Error    ${name}    @{args}
    Run Keyword If    '${state}'!='PASS'    Log    Keyword failed: ${name} @{args}${\n}${output}    WARN
    [Return]  ${output}


Prepare Logs Directory Path
    [Arguments]    ${sub_directory}=${NONE}    ${timestamp}=${TRUE}
    [Documentation]    Returns path where logs from current execution level should be placed:
    ...    - If keyword was executed inside ``Suite Setup``, resulting path will be ``${OUTPUT DIR}/Suite_logs/Setup/<timestamp>``.
    ...    - If keyword was executed inside ``Suite Teardown``, resulting path will be ``${OUTPUT DIR}/Suite_logs/Teardown/<timestamp>``.
    ...    - If keyword was executed anywhere inside ``*** Test Cases ***``, resulting path will be ``${OUTPUT DIR}/TC_${TEST NAME}/<timestamp>``.
    ...
    ...    Returned directory structure will be created if it does not exist yet.
    ...
    ...    Note: in output path, spaces are replaced with underscores (_)
    ...    and any other non alphanumeric character is replaced with hyphen (-).
    ...
    ...    Examples for Test Case named "Dummy Case" and ${OUTPUT DIR} set to ``~/logs``:
    ...    | ${dir1}= | Prepare Logs Directory Path |                      |                    |
    ...    | ${dir2}= | Prepare Logs Directory Path | infomodel            |                    |
    ...    | ${dir3}= | Prepare Logs Directory Path | admin_logs/cell_lock |                    |
    ...    | ${dir4}= | Prepare Logs Directory Path | admin_logs/cell_lock | timestamp=${FALSE} |
    ...    | ${dir5}= | Prepare Logs Directory Path | timestamp=${FALSE}   |                    |
    ...    =>
    ...    | ${dir1} = "~/logs/TC_Dummy_Case/<timestamp>"
    ...    | ${dir2} = "~/logs/TC_Dummy_Case/infomodel_<timestamp>"
    ...    | ${dir3} = "~/logs/TC_Dummy_Case/admin_logs/cell_lock_<timestamp>"
    ...    | ${dir4} = "~/logs/TC_Dummy_Case/admin_logs/cell_lock"
    ...    | ${dir5} = "~/logs/TC_Dummy_Case"
    ...
    ...    ``<timestamp>`` is in format: ``YYYYmmdd_HHMMSS``.

    ${logs_path}=    logs_directory.Resolve logs directory path    ${sub_directory}    ${timestamp}
    Create Directory    ${logs_path}
    [Return]    ${logs_path}


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


Reboot BTS
    [Documentation]    Performs BTS (site) reset via Admin
    [Arguments]    ${wait_till_bts_operational}=${TRUE}

    ${connection}=    Set Variable    site_reset
    ${log_path}=    Prepare Logs Directory Path    admin_logs/${connection}
    admin.connect_to    bts_host=${__LOCAL_BTS_IP__}    admin_api_log_dir=${log_path}    name=${connection}
    admin.reset_site    timeout=480    connection=${connection}
    Run keyword If    ${wait_till_bts_operational}    Wait for BTS configured
    [Teardown]    admin.teardown    connection=${connection}


Wait for BTS configured
    [Documentation]    Waits till BTS is at least configured
    ...
    ...    More about BTS state can be found in [http://oam.emea.nsn-net.net/btsom_efs/State_Management.html|OAM documentation].
    [Arguments]    ${im_alias}=default

    ${state_condition}=    Set Variable    operationalState=regex"configured|onAir"
    Query Infomodel    ${__RUNTIME_BTS_IM_PATH__} is [${state_condition}]    timeout=900    alias=${im_alias}


Wait for DSPs configured
    [Documentation]    Waits till //BBU_L-*//DSP_L-*.stateInfo.proceduralState reach SwLoaded|RoutingLoaded state.
    [Arguments]    ${im_alias}=default

    ${state_condition}=    Set Variable    stateInfo.proceduralState=regex"SwLoaded|RoutingLoaded"
    Query Infomodel    every ${__DSP_IM_PATH__} is [${state_condition}]    timeout=480    alias=${im_alias}


Get active BTS alarms
    [Documentation]    Gets all alarm objects from BTS.
    ...    Output is list of dictonaries, each dictionary represents fields from infomodel
    ...
    ...    If `display` argument is `True` then alarms are printed to console as well
    ...    Display format: ALARM [A:<alarm_id>|F:<fault_id>|<severity>] <alarm_name> - <alarm_detail>
    [Arguments]    ${display}=${TRUE}

    ${logs_path}=    Prepare Logs Directory Path    get_active_bts_alarms/admin_logs    ${FALSE}
    Setup infomodel    address=${__LOCAL_BTS_IP__}    port=${__ADMIN_BTS_PORT__}    admin_api_log_dir=${logs_path}
    ...    alias=get_alarms    timeout=90
    Connect infomodel    alias=get_alarms
    ${alarms}=    Query Infomodel    get list ${__ALARM_IM_PATH__}   allow_negative_result=True    alias=get_alarms
    Run keyword If    ${display}    Display Alarms    ${alarms}
    [Return]    ${alarms}
    [Teardown]    Teardown infomodel    alias=get_alarms


Display alarms
    [Documentation]    Takes list of infomodel ALARM objects and for each displays line in console with its info
    ...    Display format: ALARM [A:<alarm_id>|F:<fault_id>|<severity>] <alarm_name> - <alarm_detail>
    [Arguments]    ${alarms}

    FOR    ${a}    IN    @{alarms}
        Log    ALARM [A:${a.alarmNumber}|F:${a.faultId}|${a.alarmSeverity}] ${a.alarmName} - ${a.alarmText.alarmDetail}    level=WARN
    END


Update SW on BTS
    [Arguments]    ${sw_package}    ${bts_ip}=${__LOCAL_BTS_IP__}    ${should_wait_for_configured}=${TRUE}
    [Documentation]    Performs software update
    ...
    ...    ``sw_package`` needs to be a path to BTS build file in zip format.
    ...
    ...    Keyword waits until BTS indicates its readiness for software update,
    ...    then installs and activates the software.
    ...
    ...    After software activation, keyword will wait until BTS reaches configured state.
    ...    Set ``should_wait_for_configured`` to ``False`` to disable this behavior.

    ${connection}=    SET VARIABLE    sw_update
    ${log_path}=    Prepare Logs Directory Path    admin_logs${connection}
    admin.connect_to    bts_host=${bts_ip}    admin_api_log_dir=${log path}    name=${connection}
    admin.wait_sw_update_possible    connection=${connection}
    admin.update_software    ${sw_package}    connection=${connection}    should_reset_radios=${TRUE}    timeout=1200
    RUN KEYWORD IF    ${should_wait_for_configured}    Wait for BTS configured
    [Teardown]    admin.teardown    connection=${connection}


Get Snapshot
    [Documentation]    Collects snapshot from every eNB configured on test line.
    ...    Snapshot(s) will be saved in snapshot_<timestamp> under path resolved by
    ...    ``Resolve Logs Directory Path`` keyword.

    FOR    ${index}    ${node}    IN ENUMERATE    @{__TL_NODE_LIST__}
        ${logs_directory_path}=    Prepare Logs Directory Path    node_${index}/snapshot
        RUN KEYWORD IF    "${index}" == "0"    Get snapshot with admin    ${logs_directory_path}
        ...    ELSE    Get snapshot with admin    ${logs_directory_path}    remote_host=${node.addr}
    END


Get snapshot with admin
    [Arguments]
    ...    ${logs_directory_path}=${NONE}
    ...    ${cells}=${NONE}
    ...    ${remote_host}=${NONE}
    [Documentation]    Collects snapshot from eNB using WebEM CLI.
    ...    Snapshot is saved with default name ``snapshot.zip``.
    ...    If ``logs_directory_path`` was not given, snapshot will be saved in snapshot_<timestamp> folder
    ...    under path resolved by ``Resolve Logs Directory Path`` keyword.
    ...
    ...    It is possible to select specific cells from which snapshot data will be collected
    ...    by providing coma-separated list of cell dist names.
    ...
    ...    Examples:
    ...    | Get snapshot with admin | ${logs_directory_path} | cells=MRBTS-1/LNBTS-1/LNCEL-1                         |
    ...    | Get snapshot with admin | ${logs_directory_path} | cells=MRBTS-1/LNBTS-1/LNCEL-1,MRBTS-1/LNBTS-1/LNCEL-2 |
    ...
    ...    Snapshot path is returned.
    [Teardown]    admin.teardown    connection=get_snapshot

    ${logs_path}=    RUN KEYWORD IF    $logs_directory_path    SET VARIABLE    ${logs_directory_path}
    ...    ELSE    Prepare Logs Directory Path    snapshot

    admin.setup_admin
    ...    bts_host=${__LOCAL_BTS_IP__}
    ...    admin_api_log_dir=${logs_path}/admin_logs
    ...    remote_host=${remote_host}
    ...    name=get_snapshot
    admin.collect_snapshot    ${logs_path}/${__DEFAULT_SNAPSHOT_FILE_NAME__}    cells=${cells}    timeout=30 min    connection=get_snapshot

    [Return]    ${logs_path}/${__DEFAULT_SNAPSHOT_FILE_NAME__}


eNB Commissioning
    [Documentation]    Keyword performs eNB commissioning with given SCF or Delta File.
    ...    Commissioning keyword activates SCF or Delta File and if reset was performed waits until eNB reconects.
    ...
    ...    Variables:
    ...    ``configuration_file_path`` - absolute path to either SCF or Delta File.
    ...
    ...    ``bts_ip`` - by default Infomodel and Admin connection are done at __LOCAL_BTS_IP__. It's possible to provide
    ...    custom eNB IP address.
    ...
    ...    ``node``
    ...    - groups logs under one location when multiple eNB UTE configuration is in use
    ...      e.g.: node_``node``/enb_commissioning.
    ...
    ...    Example:
    ...    | eNB Commissioning | {scfc_path} | - commissioning with SCF (path under ``scfc_path``) via
    ...    192.168.255.129, logs saved in node_0/enb_commissioning directory.
    ...    | eNB Commissioning | {scfc_path} | 10.0.1.2 | - commissioning via 10.0.1.2,
    ...    logs saved in node_0/enb_commissioning directory.
    ...    | eNB Commissioning | {scfc_path} | 10.0.1.2 | 1 | - commissioning via 10.0.1.2,
    ...    logs save in node_1/enb_commissioning directory.
    ...
    ...    | eNB Commissioning | {delta_path} | - commissioning with Delta file via  192.168.255.129,
    ...    logs saved in node_0/enb_commissioning directory.
    [Arguments]
    ...    ${configuration_file_path}
    ...    ${bts_ip}=${__LOCAL_BTS_IP__}
    ...    ${node}=0
    ...    ${commissioning_timeout}=600

    ${connection}=    Set Variable    enb_commissioning
    ${log_path}=    Prepare Logs Directory Path    node_${node}/${connection}
    setup_infomodel    address=${bts_ip}    port=${__ADMIN_BTS_PORT__}    admin_api_log_dir=${log_path}    alias=${connection}
    connect_infomodel    alias=${connection}
    admin.connect_to    bts_host=${bts_ip}    admin_api_log_dir=${log path}    name=${connection}
    Wait for RMODs operational state enabled    alias=${connection}
    ${mrbts_state}=    admin.get_mrbts_state    connection=${connection}
    Run Keyword If    "${mrbts_state}" != "${__BTS_NOT_COMMISSIONED_STATE__}"    Check RNW plan file activation    im_alias=${connection}
    ${bts_info}=    admin.get_bts_info    connection=${connection}
    ${file_name}    ${file_extenstion}=    Split Extension    ${configuration_file_path}
    Run Keyword If    "${file_extenstion}" == "xml"    admin.perform_commissioning
    ...    bts_id=${bts_info}[mrbtsID]
    ...    scf_file=${configuration_file_path}
    ...    skip_parameter_relation_errors=${FALSE}
    ...    timeout=${commissioning_timeout}
    ...    connection=${connection}
    Run Keyword If    "${file_extenstion}" == "json"    admin.perform_delta_recommissioning
    ...    delta_file=${configuration_file_path}
    ...    skip_parameter_relation_errors=${FALSE}
    ...    timeout=${commissioning_timeout}
    ...    connection=${connection}

    [Teardown]    Run Keywords
    ...    admin.teardown    connection=${connection}
    ...    AND    save_infomodel_log    ${log_path}${/}${__DEFAULT_INFOMODEL_FILE_NAME__}    timeout=120    alias=${connection}
    ...    AND    teardown_infomodel    alias=${connection}


Wait for RMODs operational state enabled
    [Documentation]    Waits till radio operational state is enabled.
    ...
    ...    When all RMODs are in enabled state proper commissioning is possible.
    ...
    ...    Variables:
    ...    ``alias`` - Infomodel alias name.
    [Arguments]
    ...    ${alias}=default

    query_infomodel    every //RMOD_R-* is [operationalState=enabled]    timeout=360s    alias=${alias}


Wait for eNB operational state configured or onAir
    [Documentation]    Waits till eNB operational state is configured or onAir.
    ...
    ...    Variables:
    ...    ``alias`` - Infomodel alias name.
    [Arguments]
    ...    ${alias}=default

    query_infomodel    ${__RUNTIME_BTS_IM_PATH__} is [operationalState=regex"configured|integrated to RAN|onAir"]    timeout=480s    alias=${alias}


Wait for RMODs from SCFC operational state enabled
    [Documentation]    Waits till radios operationl state is enabled (radios list is populated based on provided SCF).
    ...
    ...    It's checked if all RFs found in SCF.xml are operationalState=enabled.
    ...    Second check is necessary because in rare cases RMOD_R objects are created with delay. It leads to situation
    ...    where not all RFs are detected but all RMOD_R objects have their operationalState=enabled.
    ...
    ...    Variables:
    ...    ``scfc_path`` - absolute path to SCF with current eNB configuration.
    ...
    ...    ``alias`` - Infomodel alias name.
    [Arguments]
    ...    ${scfc_path}
    ...    ${alias}=default

    ${rmods_number}=    Check RMODs number in SCF    ${scfc_path}
    query_infomodel    count //RMOD_R-* is [operationalState=enabled] = ${rmods_number}    timeout=360s    alias=${alias}


Wait for eNB and RMODs operational state enabled
    [Documentation]    Waits till eNB and RMODs are in operational state enabled (wait until they are or timeout happens).
    ...
    ...    Variables:
    ...    ``scfc_path`` - absolute path to SCF with current eNB configuration.
    ...
    ...    ``alias`` - Infomodel alias name.
    [Arguments]
    ...    ${scfc_path}
    ...    ${alias}=default

    Wait for eNB operational state configured or onAir    alias=${alias}
    Wait for RMODs operational state enabled    alias=${alias}
    Wait for RMODs from SCFC operational state enabled    scfc_path=${scfc_path}    alias=${alias}


Recover configuration if eNB or RMODs not operational state enabled
    [Documentation]    Tries to recover configuration if eNB or RMODs operational state is not enabled after given time.
    ...
    ...    Variables:
    ...    ``scfc_path`` - absolute path to SCF with current eNB configuration.
    ...    ``connection`` - Infomodel and Admin library alias name.
    [Arguments]
    ...    ${scfc_path}
    ...    ${connection}=default

    ${passed}=    Run Keyword And Return Status    Wait for eNB and RMODs operational state enabled    scfc_path=${scfc_path}    alias=${connection}
    Return From Keyword If    ${passed}
    admin.reset_site    timeout=480s    connection=${connection}
    Wait for eNB and RMODs operational state enabled    scfc_path=${scfc_path}    alias=${connection}


Check if eNB is correctly configured
    [Documentation]    Checks if eNB is correctly configured and run recovery actions if it is not.
    ...
    ...    Keyword should be used after eNB configuration changes were made.
    ...    For simple eNB state checking use ``Wait for eNB and RMODs operational state enabled``.
    ...
    ...    Variables:
    ...    ``scfc_path`` - absolute path to SCF with current eNB configuration.
    ...
    ...    ``node``
    ...    - groups logs under one location when multiple eNB UTE configuration is in use
    ...      e.g.: node_``node``/enb_commissioning.
    ...    - node 0 is for master eNB and 1, 2, 3 etc. are slave eNBs. If single eNB testline is in use ``node`` should
    ...      be set to 0.
    ...
    ...    ``configuration_check`` - determines how many recoveries will be performed in case eNB is configured
    ...    incorrectly. There should be at least one configuration check performed.
    ...
    ...    ``bts_ip`` - by default Infomodel and Admin connection are done at __LOCAL_BTS_IP__. It's possible to provide
    ...    custom eNB IP address.
    [Arguments]
    ...    ${scfc_path}
    ...    ${bts_ip}=${__LOCAL_BTS_IP__}
    ...    ${node}=0
    ...    ${configuration_check}=1

    ${connection}=    Set Variable    configuration_check
    ${log_path}=    Prepare Logs Directory Path    node_${node}/${connection}
    setup_infomodel    address=${bts_ip}    port=${__ADMIN_BTS_PORT__}
    ...    admin_api_log_dir=${log_path}    alias=${connection}
    connect_infomodel    alias=${connection}
    admin.connect_to    bts_host=${bts_ip}    admin_api_log_dir=${log path}    name=${connection}    timeout=120

    Wait Until Keyword Succeeds    ${configuration_check} times    5s
    ...    Recover configuration if eNB or RMODs not operational state enabled    ${scfc_path}    ${connection}

    [Teardown]    Run Keywords
    ...    admin.teardown    connection=${connection}
    ...    AND    save_infomodel_log    ${log_path}${/}${__DEFAULT_INFOMODEL_FILE_NAME__}    timeout=120    alias=${connection}
    ...    AND    teardown_infomodel    alias=${connection}


Check RNW plan file activation
    [Documentation]  Checks RNW Plan File activation on BTS with infomodel.
    [Arguments]
    ...    ${im_alias}=default

    ${state_condition}=    Set Variable    stateInfo.proceduralState!=initializing,stateInfo.usageState=Active
    Query Infomodel    ${__CPLANE_IM_PATH__} is [${state_condition}]    timeout=300    alias=${im_alias}


Wait for radios Enabled status
    [Documentation]    Checks if radio operationalStatus is Enabled
    ...                to ensure proper commissioning (no admin ErrorCode:27 Cplane is busy)
    [Arguments]    ${im_alias}=default
    ${state_condition}=    Set Variable    stateInfo.operationalState=Enabled
    Query Infomodel    every //RMOD_L-* is [${state_condition}]    timeout=300    alias=${im_alias}


Add Eth
    [Documentation]    Adds eth interface.
    ...    For UTE WTS it's usually:
    ...     - ip: 10.0.1.21
    ...     - mask: 24
    ...     - interface: eth3
    ...     - label: eth3:sgw
    [Arguments]    ${ip}    ${mask}    ${interface}    ${label}

    ${eth_check_cmd}=    Set Variable    (ip -o a | egrep -e ".*${interface}.*${ip}/${mask}.*" 1> /dev/null) && echo True || echo False
    ${entry_already_exists}=    Run On Localhost    ${eth_check_cmd}
    ${add_eth_cmd}=    Set Variable    sudo ip addr add ${ip}/${mask} dev ${interface} label ${label}
    Run Keyword If    '${entry_already_exists}' == 'False'    Run On Localhost    ${add_eth_cmd}


Start WTS processes
    [Documentation]    Starts WTS processes (uses ute_wtssim in the background)
    [Arguments]    ${lua_file_path}    ${lua_dirs}=@{EMPTY}
    ${ports}=    Create List    10000
    Start WTS Applications    edaemon_ports=${ports}    cfg_file=${lua_file_path}    lua_dirs=${lua_dirs}


Start lua config
    [Documentation]    Starts WTS services and waits for onAir
    [Arguments]    ${wait_for_onAir}=${TRUE}

    Start Wts services    timeout=480
    Run Keyword If    ${wait_for_onAir}    Wait for OnAir


Check OnAir
    [Documentation]    Checks if site is OnAir, which involves BTS being OnAir, cells being OnAir and NotBarred and
    ...    S1 link being available.
    [Arguments]    ${im_alias}=default

    BTS Should be OnAir    im_alias=${im_alias}
    Cells should be OnAir    im_alias=${im_alias}
    Cells should not be barred    im_alias=${im_alias}
    S1 link should be up    im_alias=${im_alias}


Wait for OnAir
    [Documentation]    Waits until site is OnAir, which involves BTS being OnAir, cells being OnAir and NotBarred and
    ...    S1 link to be available.
    [Arguments]    ${timeout}=480    ${im_alias}=default

    ${retry_interval}=    Set variable    15s
    Wait until keyword succeeds    ${timeout}    ${retry_interval}    Check OnAir    ${im_alias}


BTS Should be OnAir
    [Documentation]    Checks if BTS is in OnAir state.
    [Arguments]    ${im_alias}=default

    ${state_condition}=    Set Variable    operationalState="onAir"
    Query Infomodel    ${__RUNTIME_BTS_IM_PATH__} is [${state_condition}]    timeout=10s    alias=${im_alias}


Wait for BTS OnAir
    [Documentation]    Waits until BTS reach OnAir state.
    [Arguments]    ${timeout}=480    ${im_alias}=default

    ${retry_interval}=    Set variable    15s
    Wait until keyword succeeds    ${timeout}    ${retry_interval}    BTS Should be OnAir    ${im_alias}


Cells should be OnAir
    [Documentation]    Checks if all cells are OnAir.
    [Arguments]    ${im_alias}=default

    ${state_condition}=    Set Variable    stateInfo.proceduralState=OnAirDone
    Query Infomodel    every ${__CELL_IM_PATH__} is [${state_condition}]    timeout=10s    alias=${im_alias}


Wait for all cells OnAir
    [Documentation]    Waits until all cells reach OnAir state.
    [Arguments]    ${timeout}=480    ${im_alias}=default

    ${retry_interval}=    Set variable    15s
    Wait until keyword succeeds    ${timeout}    ${retry_interval}    Cells should be OnAir    ${im_alias}


Collect WTS Logs
    [Documentation]    Saves WTS Logs into ``OUTPUT_DIR`` without interrupting its operation
    ${destination}=    Prepare Logs Directory Path    WTS
    ${logs}=    dump_wts_logs_on_runtime    ${destination}
    [Return]    ${logs}


Stop WTS
    [Documentation]    Stops WTS proceses

    ${log_path}=    Prepare Logs Directory Path    WTS
    Stop And Collect Wts Logs    subdirectory=${log_path}
    Collect EPCsim traces    destination=${log_path}


Collect EPCSim traces
    [Arguments]
    ...    ${destination}
    ...    ${sufix}=trace.log
    [Documentation]    Collects EPCSim traces into ``destination`` directory.
    ...    ``destination`` has to exist prior to using this keyword.
    ...    Returns path to resulting archive file, if created. Returns ``None`` otherwise.
    OperatingSystem.DIRECTORY SHOULD EXIST    ${destination}
    ${tarball}=    SET VARIABLE    ${destination}/epcsim_traces.tgz
    OperatingSystem.RUN    cd /opt/iphy/latest ; tar czf ${tarball} *${sufix} --remove-files 2>/dev/null || rm ${tarball} 2>&1
    ${created}=    RUN KEYWORD AND RETURN STATUS    FILE SHOULD EXIST    ${tarball}
    ${output_path}=    SET VARIABLE IF    ${created}    ${tarball}    ${NONE}
    [Return]    ${output_path}


Start infomodel logging
    [Arguments]
    ...    ${logs_directory_path}=${NONE}
    ...    ${alias}=default
    [Documentation]    Starts infomodel logging.
    ...    When no ``logs_directory_path`` is provided admin logs will be saved in folder infomodel_<alias>/admin_logs
    ...    located under path resolved by ``Prepare Logs Directory Path``.
    ...    When ``logs_directory_path`` is provided admin logs will be saved in
    ...    ``logs_directory_path``/infomodel_<alias>/admin_logs

    ${logs_path}=    RUN KEYWORD IF    $logs_directory_path    SET VARIABLE
    ...    ${logs_directory_path}/infomodel_${alias}/admin_logs
    ...    ELSE    Prepare Logs Directory Path    infomodel_${alias}/admin_logs    ${FALSE}

    Setup infomodel    address=${__LOCAL_BTS_IP__}    port=${__ADMIN_BTS_PORT__}    admin_api_log_dir=${logs_path}    alias=${alias}
    Connect infomodel    alias=${alias}


Start infomodel logging on remote host
    [Arguments]
    ...    ${logs_directory_path}
    ...    ${remote_host}
    ...    ${alias}=default
    [Documentation]    Starts infomodel logging on remote host.
    ...    admin logs will be saved in ``logs_directory_path``/infomodel_<alias>/admin_logs
    ...    IP address to ``remote_host`` is required.

    ${logs_path}=    SET VARIABLE    ${logs_directory_path}/infomodel_${alias}/admin_logs
    CREATE DIRECTORY    path=${logs_path}

    admin.setup_admin    bts_host=${__LOCAL_BTS_IP__}    admin_api_log_dir=${logs_path}    remote_host=${remote_host}    timeout=90     name=${alias}


Stop infomodel logging
    [Arguments]
    ...    ${logs_directory_path}=${NONE}
    ...    ${alias}=default
    [Documentation]    Stops infomodel logging and saves ims2 file locally.
    ...    When no ``logs_directory_path`` is provided infomodel will be saved in folder infomodel_<alias>
    ...    located under path resolved by ``Prepare Logs Directory Path``.
    ...    When ``logs_directory_path`` is provided admin logs will be saved in ``logs_directory_path``/infomodel_<alias>

    ${logs_path}=    RUN KEYWORD IF    $logs_directory_path    SET VARIABLE    ${logs_directory_path}/infomodel_${alias}
    ...    ELSE    Prepare Logs Directory Path    infomodel_${alias}    ${FALSE}

    Save Infomodel Log    ${logs_path}${/}${__DEFAULT_INFOMODEL_FILE_NAME__}    timeout=120    alias=${alias}

    [Teardown]    Teardown infomodel    alias=${alias}


Stop infomodel logging on remote host
    [Arguments]
    ...    ${logs_directory_path}=${NONE}
    ...    ${alias}=default
    [Documentation]    Stops infomodel logging on remote host and saves ims2 file locally.
    ...    When no ``logs_directory_path`` is provided infomodel will be saved in folder infomodel_<alias>
    ...    located under path resolved by ``Prepare Logs Directory Path``.
    ...    When ``logs_directory_path`` is provided admin logs will be saved in ``logs_directory_path``/infomodel_<alias>

    ${logs_path}=    RUN KEYWORD IF    $logs_directory_path    SET VARIABLE    ${logs_directory_path}/infomodel_${alias}
    ...    ELSE    Prepare Logs Directory Path    infomodel_${alias}    ${FALSE}

    admin.collect_infomodel_log_from_current_session
    ...    target_file_name=${logs_path}${/}${__DEFAULT_INFOMODEL_FILE_NAME__}
    ...    timeout=120
    ...    connection=${alias}

    [Teardown]    admin.teardown_admin    connection=${alias}


Start syslog logging
    [Arguments]
    ...    ${logs_directory_path}=${NONE}
    ...    ${host_ip}=127.0.0.1
    ...    ${virtualenv_dir}=${NONE}
    ...    ${alias}=default
    [Documentation]    Starts syslog for eNB paried with ``host_ip``.
    ...    When no ``logs_directory_path`` is provided syslog will be saved in folder ``syslog_<alias>``
    ...    located under path resolved by ``Prepare Logs Directory Path``.
    ...    When ``logs_directory_path`` is provided syslog will be saved in ``logs_directory_path``/syslog_<alias>
    ...
    ...    To setup syslog logging on remote host ``host_ip`` and ``virtualenv_dir`` are required.

    ${logs_path}=    RUN KEYWORD IF    $logs_directory_path    SET VARIABLE    ${logs_directory_path}/syslog_${alias}
    ...    ELSE    Prepare Logs Directory Path    syslog_${alias}    ${FALSE}

    taf_syslog.Start Syslog
    ...    log_dir=${logs_path}
    ...    log_name=${__DEFAULT_SYSLOG_FILE_NAME__}
    ...    ip=${__SYSLOG_IP__}
    ...    host_ip=${host_ip}
    ...    virtualenv_dir=${virtualenv_dir}
    ...    alias=${alias}


Start syslog CUS logging
    [Arguments]
    ...    ${logs_directory_path}=${NONE}
    ...    ${ip}=${__CUS_SYSLOG_IP__}[0]
    ...    ${ports}=${__CUS_SYSLOG_PORT__}
    ...    ${host_ip}=127.0.0.1
    ...    ${virtualenv_dir}=${NONE}
    ...    ${alias}=default_cus
    [Documentation]    Starts syslog for CUS parried with ``host_ip``.
    ...    When no ``logs_directory_path`` is provided syslog will be saved in folder ``syslog_cus_<alias>``
    ...    located under path resolved by ``Prepare Logs Directory Path``.
    ...    When ``logs_directory_path`` is provided syslog will be saved in ``logs_directory_path``/syslog_cus_<alias>
    ...
    ...    To setup syslog logging on remote host ``host_ip``, ``virtualenv_dir`` and corresponding CUS IP ``ip`` are required.

    ${logs_path}=    RUN KEYWORD IF    $logs_directory_path    SET VARIABLE    ${logs_directory_path}/syslog_cus_${alias}
    ...    ELSE    Prepare Logs Directory Path    syslog_cus_${alias}    ${FALSE}

    taf_syslog.Start Syslog
    ...    log_dir=${logs_path}
    ...    log_name=${__DEFAULT_CUS_SYSLOG_FILE_NAME__}
    ...    ip=${ip}
    ...    ports=${ports}
    ...    host_ip=${host_ip}
    ...    virtualenv_dir=${virtualenv_dir}
    ...    alias=${alias}


Stop syslog logging
    [Arguments]
    ...    ${alias}=default
    [Documentation]    Stops syslog and download created file to destination provided in ``Start syslog`` keyword.

    taf_syslog.Collect Syslog Results    unzip=false    alias=${alias}


Stop syslog CUS logging
    [Arguments]
    ...    ${alias}=default_cus
    [Documentation]    Stops syslog and download created file to destination provided in ``Start syslog`` keyword.

    taf_syslog.Collect Syslog Results    unzip=false    alias=${alias}


Wait Until Bts Is Offline
    [Arguments]    ${timeout}=3 min
    [Documentation]    Waits for BTS to be offline (no connection).
    ...    Fails if BTS is still reachable after timeout passed.

    ${cooldown}=    Set Variable    5 s
    Wait Until Keyword Succeeds    ${timeout}    ${cooldown}    Host Should Be Down    ${__LOCAL_BTS_IP__}


Wait Until Bts Is Online
    [Arguments]    ${timeout}=3 min
    [Documentation]    Waits for BTS to be online (reachable).
    ...    Fails if BTS is still unreachable after timeout passed.

    ${cooldown}=    Set Variable    5 s
    Wait Until Keyword Succeeds    ${timeout}    ${cooldown}    Host Should Be Up    ${__LOCAL_BTS_IP__}


Host Should Be Down
    [Arguments]    ${address}
    [Documentation]    Fails if host with given IP ``address`` is reachable (responding to ping probe).

    ${no port scan}=    Set Variable    -sn
    ${nmap output}=    Run On Localhost    sudo nmap ${no port scan} ${address}
    Should Contain    ${nmap output}    Host seems down

Host Should Be Up
    [Arguments]    ${address}
    [Documentation]    Fails if host with given IP ``address`` is *not* reachable (does not respond to ping probe).
    ${no port scan}=    Set Variable    -sn
    ${nmap output}=    Run On Localhost    sudo nmap ${no port scan} ${address}
    Should Contain    ${nmap output}    Host is up

Set AaShell Tag
    [Documentation]    Sets given tag's value in AaShell
    [Arguments]    ${tag}    ${value}    ${type}=hex

    ${type_flag}=    Set Variable If    '${type}'=='string'    3    2
    ${aashell_cmd}=    Set Variable    tag -${type_flag}w ${tag} ${value}
    ${cmd_output}=    Run In Aashell    ${aashell_cmd}
    [Return]    ${cmd_output}


Read AaShell Tag
    [Documentation]    Reads given tag's value in AaShell
    [Arguments]    ${tag}    ${type}=hex

    ${type_flag}=    Set Variable If    '${type}'=='string'    3    2
    ${aashell_cmd}=    Set Variable    tag -${type_flag}r ${tag}
    ${cmd_output}=    Run In Aashell    ${aashell_cmd}
    ${full_match}    ${tag_value}=    Should Match Regexp    ${cmd_output}    =\\s*(.*?)(?:\\s+|$)
    [Return]    ${tag_value}


Add flag to swconfig
    [Documentation]    Adds flag to swconfig file
    ...    Parameters:
    ...    `flag` - name of flag, for example: 0x45005a
    ...    `value` - value of flag, for example: 0x100000
    ...    `local_swconfig_path` - path to swconfig file on local machine
    ...    `active` - [bool] - if True - then flag is active, otherwise it's commented out
    ...    `comment` - if set, then given comment will be added above flag
    [Arguments]    ${flag}    ${value}    ${local_swconfig_path}    ${active}=${TRUE}    ${comment}=${NONE}

    swconfig.Add swconfig flag    ${flag}    ${value}    ${local_swconfig_path}    ${active}    ${comment}


Deactivate flag in swconfig
    [Documentation]    Deactivates flag in swconfig file (comments it out)
    ...    Parameters:
    ...    `flag` - name of flag, for example: 0x45005a
    ...    `local_swconfig_path` - path to swconfig file on local machine
    [Arguments]    ${flag}    ${local_swconfig_path}

    swconfig.Deactivate swconfig flag    ${flag}    ${local_swconfig_path}


Download build artifacts with Aria
    [Arguments]
    ...    ${bts_sw_build}
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
        ${file_path}=    Get Build Artifact    ${artifact}    ${fixed_bts_sw_build}    destination=${download_directory}
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
    [Arguments]    ${name}    ${build}    ${destination}
    ${branch}=    Fetch From Left    ${build}    _
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


Turn On Device
    [Documentation]    Turns on power supply for given device using PDU
    ...    Parameters:
    ...    `device_outlet` - port on PDU
    ...    `pdu_info` - dictionary with PDU information, contains keys:
    ...        `ip` - ip address of PDU
    ...        `model` - type of PDU, for example: ATEN
    ...    `snmp_user` - please refer to documentation of ute_pdu for description of snmp_user parameter
    [Arguments]    ${device_outlet}    ${pdu_info}    ${snmp_user}=${NONE}

    Setup Pdu    ${pdu_info}[ip]    ${pdu_info}[model]    snmp_user=${snmp_user}
    Pdu outlet on    ${device_outlet}
    [Teardown]    Teardown Pdu


Turn Off Device
    [Documentation]    Turns off power supply for given device using PDU
    ...    Parameters:
    ...    `device_outlet` - port on PDU
    ...    `pdu_info` - dictionary with PDU information, contains keys:
    ...        `ip` - ip address of PDU
    ...        `model` - type of PDU, for example: ATEN
    ...    `snmp_user` - please refer to documentation of ute_pdu for description of snmp_user parameter
    [Arguments]      ${device_outlet}    ${pdu_info}    ${snmp_user}=${NONE}

    Setup Pdu    ${pdu_info}[ip]    ${pdu_info}[model]    snmp_user=${snmp_user}
    Pdu outlet off    ${device_outlet}
    [Teardown]    Teardown Pdu


Reboot Device
    [Documentation]     Reboots power supply for given device using PDU
    ...    Parameters:
    ...    `device_outlet` - port on PDU
    ...    `pdu_info` - dictionary with PDU information, contains keys:
    ...        `ip` - ip address of PDU
    ...        `model` - type of PDU, for example: ATEN
    ...    `snmp_user` - please refer to documentation of ute_pdu for description of snmp_user parameter
    [Arguments]      ${device_outlet}    ${pdu_info}    ${snmp_user}=${NONE}

    Setup Pdu    ${pdu_info}[ip]    ${pdu_info}[model]    snmp_user=${snmp_user}
    Pdu outlet reset    ${device_outlet}
    [Teardown]    Teardown Pdu


Prepare Testing Environment
    [Documentation]    Gets testline ready for performing test(s).
    Perform Sanity Check
    Gather Testline Configuration


Gather Testline Configuration
    [Documentation]    Parses testline configuration object (``\${tl}``) for valuable data.
    ...
    ...    Keyword sets following _Suite Variables_:
    ...    - ``\${__TL_CURRENT_NODE__}``
    ...    - ``\${__TL_NODE_LIST__}``
    ...
    ...    During automatic regression, ``\${tl}`` object should be already loaded in most cases.
    ...    However, if ``\${tl}`` does not exist in current execution scope, it will be loaded
    ...    from *testline_configuration* repository.
    ...
    ...    During manual testing, *testline_configuration* repository may not be available.
    ...    In such case, you have to provide ``\${tl}`` manually, to make this keyword works.
    ...    There are two possible ways of doing this:
    ...    - by passing ``-V`` flag to robot command, followed by path to to package defining ``\${tl}``
    ...    - by setting ``\${__TL_CONFIG_ROOT__}`` in variable table of your test suite file.
    ...
    ...    Note that the second method can be used during automatic regression as well.
    [Tags]    PRIVATE
    ${variables}=    GET VARIABLES    no_decoration=${TRUE}
    RUN KEYWORD IF    "tl" not in $variables    Load Testline Configuration
    VARIABLE SHOULD EXIST    ${tl}    msg=FAILED TO LOAD TESTLINE CONFIGURATION!
    ${nodes}=    testline_configuration.parse_configuration    ${tl}
    SET SUITE VARIABLE    ${__TL_NODE_LIST__}    ${nodes}

    SET SUITE VARIABLE    ${__TL_CURRENT_NODE__}    ${nodes}[0]
    ${has_cus}=    SET VARIABLE IF    ${__TL_CURRENT_NODE__.cus}    ${TRUE}    ${FALSE}
    SET SUITE VARIABLE    ${__TL_HAS_CUS__}    ${has_cus}


Load Testline Configuration
    [Documentation]    (re)loads testline configuration object
    [Tags]    PRIVATE
    ${tl_name}=   EVALUATE   '%{UTE_CONFIGURATION}'.partition(".")[2] or '%{UTE_CONFIGURATION}'
    IMPORT VARIABLES    ${__TL_CONFIG_ROOT__}/${tl_name}


Perform Sanity Check
    [Documentation]    Checks if testing environment is capable of performing SSH connection to FSM and if there
    ...    is connection to web repositories
    LOG VARIABLES
    OperatingSystem.GET ENVIRONMENT VARIABLES
    Check SSH connection to FSM
    Check connection to main repositories


Check SSH connection to FSM
    [Documentation]    Checks if there is SSH connection to FSM, if there is no connection - display warning

    ${cmd}=    Set Variable    sshpass -p oZPS0POrRieRtu ssh toor4nsn@${__LOCAL_BTS_IP__} -o StrictHostKeyChecking=no -o ConnectTimeout=5 whoami
    ${status}    ${output}=    Run Keyword And Ignore Error    Run On Localhost    ${cmd}
    ${stripped}=    Strip String    ${output}
    Run Keyword If    '${status}' == 'FAIL'    Log    Issue with SSH connection to FSM: ${stripped}    WARN


Check Connection To Main Repositories
    [Documentation]    Checks if there is connection to webpages, if there is no connection - display warning

    ${repositories}=    Create List
    ...    http://files.ute.nsn-rdnet.net/
    ...    http://lterel.es-si-s3-z2.eecloud.nsn-net.net
    ...    http://lterel.es-si-s3-z4.eecloud.nsn-net.net
    ...    https://es-si-s3-z2.eecloud.nsn-net.net
    FOR    ${url}    IN    @{repositories}
        Run Keyword And Warn On Failure    Website Should Be Reachable    ${url}
    END


Turn on mandatory logging
    [Documentation]    Turns on default mandatory logging for test suite.
    ...    Default logging:
    ...    - Syslog on every eNB configured on test line;
    ...    - Syslog on CUS configured on test line (if testline has CUS);
    ...    - Infomodel on every eNB configured on test line.
    ...
    ...    Default alias:
    ...    - eNB syslog - ``default`` for node_0 and ``default_<node_number>`` for every other node
    ...    - CUS syslog - ``default_cus``
    ...    - eNB infomodel - ``default`` for node_0 and ``default_<node_number>`` for every other node
    ...
    ...    Logs directory:
    ...    - eNB syslog - ${OUTPUT DIR}/Suite_logs/Setup/node_<node_number>/syslog_<alias>
    ...    - (optional) CUS syslog - ${OUTPUT DIR}/Suite_logs/Setup/node_<node_number>/syslog_cus_<alias>
    ...    - eNB infomodel - ${OUTPUT DIR}/Suite_logs/Setup/node_<node_number>/infomodel_<alias>
    ...    - eNB infomodel admin logs - ${OUTPUT DIR}/Suite_logs/Setup/node_<node_number>/infomodel_<alias>/admin_logs

    ${logs_directory_path}=    Prepare Logs Directory Path    node_0    ${FALSE}
    Start syslog logging    ${logs_directory_path}
    RUN KEYWORD IF    ${__TL_HAS_CUS__}    Start syslog CUS logging    ${logs_directory_path}
    Start infomodel logging    ${logs_directory_path}

    FOR    ${index}    ${node}    IN ENUMERATE    @{__TL_NODE_LIST__}
        CONTINUE FOR LOOP IF    "${index}" == "0"
        ${logs_directory_path}=    Prepare Logs Directory Path    node_${index}    ${FALSE}
        Start syslog logging    ${logs_directory_path}    ${node.addr}    ${__DEFAULT_VIRTUAL_ENV__}    alias=default_${index}
        Start infomodel logging on remote host    ${logs_directory_path}    ${node.addr}    alias=default_${index}
    END


Turn off mandatory logging
    [Documentation]    Turns off default mandatory logging for test suite.

    Stop syslog logging
    RUN KEYWORD IF    ${__TL_HAS_CUS__}    Stop syslog CUS logging
    Stop infomodel logging    ${OUTPUT DIR}/Suite_logs/Setup/node_0
    FOR    ${index}    ${node}    IN ENUMERATE    @{__TL_NODE_LIST__}
        CONTINUE FOR LOOP IF    "${index}" == "0"
        Stop syslog logging    alias=default_${index}
        Stop infomodel logging on remote host    ${OUTPUT DIR}/Suite_logs/Setup/node_${index}    alias=default_${index}
    END


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


Testing environment cleanup
    [Documentation]    Cleans up testing environment after test suite
    Perform Sanity Check
    Dump execution context


Dump execution context
    OperatingSystem.RUN    mkdir ${OUTPUT DIR}/context && find /opt/ute/ -maxdepth 1 -type f -exec cp -v '{}' ${OUTPUT DIR}/context \\;


Parameter Recommissioning
    [Documentation]    Performs BTS parameter commissioning
    ...    Parameters:
    ...    `path` - path to object
    ...    `parameter` - name of parameter
    ...    `value` - value of parameter
    ...    `operation` - create|delete|update
    [Arguments]    ${path}    ${parameter}    ${value}    ${operation}    ${wait_till_bts_operational}=${TRUE}

    Check RNW plan file activation
    Wait for radios Enabled status
    ${connection}=    SET VARIABLE   ${parameter}
    ${log_path}=    Prepare Logs Directory Path    admin_logs/param_commissioning_${connection}
    admin.connect_to    bts_host=${__LOCAL_BTS_IP__}    admin_api_log_dir=${log path}    name=${connection}
    admin.perform_parameter_recommissioning    dist_name=${path}    parameter=${parameter}    operation=${operation}    value=${value}
    ...    skip_parameter_relation_errors=${FALSE}    connection=${connection}
    Run keyword If    ${wait_till_bts_operational}    Wait For BTS Configured
    [Teardown]    admin.teardown    connection=${connection}


Verify if S1 link and specific cells on BTS are OnAir
    [Arguments]
    ...    ${cells_list}
    ...    ${bts_ip}=${__LOCAL_BTS_IP__}
    ...    ${node}=0
    [Documentation]    S1 link and specific cells state are checked to ensure if EPCsim is running correctly.
    ...
    ...    :param cells_list: Cells ID for which OnAir state will be checked.
    ...    :type cells_list: list
    ...    :param bts_ip: BTS IP for which OnAir will be checked. Deafult value set to 192.168.255.129.
    ...    :type bts_ip: str
    ...    :param node: group logs under one location e.g.: node_``node``/verify_onair_on_bts.
    ...    :type node: str

    ${alias}=    Set Variable    verify_onair_on_bts
    ${log_path}=    Prepare Logs Directory Path    node_${node}/verify_onair_on_bts
    Setup infomodel    address=${bts_ip}    port=${__ADMIN_BTS_PORT__}    admin_api_log_dir=${log_path}    alias=${alias}
    Connect infomodel    alias=${alias}
    Query Infomodel    //LNMME_R-* is [s1LinkStatus=available]    timeout=120s    alias=${alias}
    FOR    ${cell}    IN    @{cells_list}
        Query Infomodel    //CELL_M-${cell} is [stateInfo.proceduralState=OnAirDone]    timeout=30s    alias=${alias}
    END
    [Teardown]    Run keywords    Save Infomodel Log    ${log_path}${/}${__DEFAULT_INFOMODEL_FILE_NAME__}    timeout=120    alias=${alias}
    ...           AND    Teardown infomodel    alias=${alias}


Cells should not be barred
    [Documentation]    Verifies that cells are not barred. User can specify cell ids that will be verified, keyword
    ...    defaults to all cells.
    ...
    ...    Parameters:
    ...    `cell_ids` - list containing ids of cells to be verified, defaults to all cells
    ...    `im_alias` - alias of Infomodel session on which cells will be checked
    [Arguments]    ${cell_ids}=@{EMPTY}    ${im_alias}=default

    ${cell_ids}=    Run keyword if    ${cell_ids} == @{EMPTY}    Set variable    *
    ...    ELSE    Evaluate    "[" + ",".join(str(i) for i in @{cell_ids}) + "]"

    Query infomodel    every //LNCEL_L-${cell_ids} is [stateInfo.barringState=NotBarred]    alias=${im_alias}


S1 link should be up
    [Documentation]    Verifies that S1 link is up.
    ...
    ...    Parameters:
    ...    `mme_ids` - ids of MME to check, defaults to 0 (default ID of first MME)
    ...    `im_alias` - alias of Infomodel session on which cells will be checked
    [Arguments]    ${mme_ids}=@{EMPTY}    ${im_alias}=default

    ${mme_ids}=    Set Variable If    ${mme_ids} == @{EMPTY}    0    ${mme_ids}

    FOR    ${id}    IN    ${mme_ids}
        Run Keyword And Continue On Failure    Query Infomodel    check //LNMME_R-${id} is [s1LinkStatus=available]    alias=${im_alias}
    END


Get Position In Subrack
    [Arguments]    ${bts_ip}=${__LOCAL_BTS_IP__}
    [Documentation]    Returns ``left`` or ``right`` for Airscale, and ``wholeshelfmodule`` for FSMF.
    ${connection}=    SET VARIABLE    smod_position
    ${log_path}=    Prepare Logs Directory Path    ${connection}
    admin.connect_to    bts_host=${bts_ip}    admin_api_log_dir=${log path}    name=${connection}
    ${subrackPosition}=    admin.get_smod_position    connection=${connection}
    [Teardown]    admin.teardown    connection=${connection}
    [Return]    ${subrackPosition.lower()}


Execute Admin Procedure
    [Arguments]
    ...    ${procedure_name}
    ...    ${logs_path}
    ...    ${parameters}=&{EMPTY}
    ...    ${timeout}=60
    ...    ${input_file_name}=${NONE}
    ...    ${output_file_name}=${NONE}
    [Documentation]    Sends Admin API request of type 'procedure'.
    ...    See: https://onion.wroclaw.nsn-rdnet.net/branches/master/cli-docs/procedure.html

    ${admin_connection}=    admin.connect_to    bts_host=${__LOCAL_BTS_IP__}    admin_api_log_dir=${logs_path}/admin_logs   name=${procedure_name}
    ${wait_seconds}=    CONVERT TIME    ${timeout}    # api client wants int, not time string
    CALL METHOD    ${admin_connection._api_client}    execute_procedure
    ...    name=${procedure_name}
    ...    parameters=${parameters}
    ...    timeout=${wait_seconds}
    ...    input_file_name=${input_file_name}
    ...    output_file_name=${output_file_name}
    [Teardown]    admin.teardown    connection=${procedure_name}


Traffic Should Be Started
    [Arguments]
    ...    ${ue_id}
    ...    ${bearer_id}
    ...    ${traffic_direction}
    [Documentation]    Keyword fails if there is no traffic.
    ${bearer_stats}=    Get traffic statistics from bearer    bearer_id=${bearer_id}    ue_id=${ue_id}    traffic_direction=${traffic_direction}
    SHOULD BE TRUE    ${bearer_stats}[average] > 0
    ...    msg=${traffic_direction} traffic did not started for UE${ue_id} bearer ${bearer_id}!


Traffic Should Be Stopped
    [Arguments]
    ...    ${ue_id}
    ...    ${bearer_id}
    ...    ${traffic_direction}
    [Documentation]    Keyword fails if there is traffic.
    ${bearer_stats}=    Get traffic statistics from bearer    bearer_id=${bearer_id}    ue_id=${ue_id}    traffic_direction=${traffic_direction}
    SHOULD BE TRUE    ${bearer_stats}[last_traffic] == 0
    ...    msg=${traffic_direction} traffic did not stopped for UE${ue_id} bearer ${bearer_id}!


Wait To Next Full Minute
    ${now}=    Get Current Date    result_format=datetime
    ${seconds_left}=    Evaluate    60 - $now.second
    Sleep    ${seconds_left}    reason=Make sure our first PM Counter will have data from whole minute.

Extract Files
    [Arguments]    ${zipfile_path}    ${output_directory}
    [Documentation]    Extracts content of given zipfile into specified output directory (overwrites existing files).
    ...    Returns list of filenames, relative to output directory (yes, I known it's weird).
    ${filenames}=    Run On Localhost    zipinfo -1 ${zipfile_path}
    Run On Localhost    unzip -o ${zipfile_path} -d ${output_directory}
    [Return]    ${filenames.splitlines()}
