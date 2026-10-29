*** Settings ***
Documentation    Author: xiaping.zhang@nokia-sbell.com
...              \n Please do not edit the existing keywords in this file without testing.
...              \n list of available keywords in CORE.
...              \n https://docs.taf.nsn-rdnet.net/taf.collectors.core/2.0.10/1/robot.collector_keywords/

*** Variables ***
${LOG_COLLECTOR_PATH}    /home/ute/Auto5G/testsuite/QTPH1/AirPhone/resources/Sh/log_collector.Sh

*** Keywords ***
Start Logs
    [Arguments]    ${log_name_list}    ${log_dir}=${TEST_LOG_DIRECTORY}
    [Documentation]    This keyword is to start to capture logs.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_name_list} | Yes | log type list, right now  |
    ...
    ...    | *** Variables *** |
    ...    | @{LOG_NAME_LIST} | btslog | snapshot | tcpdump | tshark | pmcounter |
    ...    Examples:
    ...    | Start Logs | ${log_name_list} |
    Setup Connections
    Set Suite Variable    ${FLAG_CATCH_SUITE_LOG}    ${True}
    FOR    ${log}    IN    @{log_name_list}
        ${log}    String.Convert To Lowercase    ${log}
        Run Keyword If    '${log}'=='btslog'    Start GNB AP Syslog    ${log_dir}
        Run Keyword If    '${log}'=='tcpdump'    Start Tcpdump
        Run Keyword If    '${log}'=='tshark'    Start TSharklog
        Run Keyword If    '${log}'=='x2pcap'    Start X2 Pcap Log
        Run Keyword If    '${log}'=='apl3l1'    Start AP L3L1 Pcap Log
        Run Keyword If    '${log}'=='cellsetup'    Start Gnb Cell Setup Log
        Run Keyword If    '${log}'=='bip'    Start Gnb BIP Log
        Run Keyword If    '${log}'=='apbip'    Start AP Bip Log
        Run Keyword If    '${log}'=='ttitrace'    Start GNB TTI Trace
        Run Keyword If    '${log}'=='sherpa'    Start Sherpa L2stream Log    ${L2STREAM_CONFIG}
    END

Stop Logs
    [Arguments]    ${log_name_list}    ${log_dir}=${TEST_LOG_DIRECTORY}
    [Documentation]    This keyword is to stop logs.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | @{log_name_list} | Yes | log type list, right now  |
    ...
    ...    | *** Variables *** |
    ...    | @{LOG_NAME_LIST} | btslog | snapshot | tcpdump | tshark | pmcounter |
    ...    Examples:
    ...    | Stop Logs | @{log_name_list} |
    Setup Connections
    Set Suite Variable    ${FLAG_CATCH_SUITE_LOG}    ${False}
    FOR    ${log}    IN    @{log_name_list}
        ${log}    String.Convert To Lowercase    ${log}
        Run Keyword If    '${log}'=='btslog'    Run Keyword And Ignore Error    Stop And Collect Syslog    log_dir=${log_dir}
        Run Keyword If    '${log}'=='tcpdump'    Run Keyword And Ignore Error    Stop Tcpdump    log_dir=${log_dir}
        Run Keyword If    '${log}'=='tshark'    Run Keyword And Ignore Error    Stop TSharklog    log_dir=${log_dir}
        Run Keyword If    '${log}'=='snapshot'    Run Keyword And Ignore Error    Collect GNB AP SnapShot Via Aashell    log_dir=${log_dir}
        Run Keyword If    '${log}'=='pmcounter'    Run Keyword And Ignore Error    Collect PM Counters    log_dir=${log_dir}
        Run Keyword If    '${log}'=='x2pcap'    Run Keyword And Ignore Error    Stop X2 Pcap Log    log_dir=${log_dir}
        Run Keyword If    '${log}'=='apl3l1'    Run Keyword And Ignore Error    Stop AP L3L1 Pcap Log    log_dir=${log_dir}
        Run Keyword If    '${log}'=='sosreport'    Run Keyword And Ignore Error    Collect UTE SosReport    log_dir=${log_dir}
        Run Keyword If    '${log}'=='cellsetup'    Run Keyword And Ignore Error    Stop Gnb Cell Setup Log    log_dir=${log_dir}
        Run Keyword If    '${log}'=='bip'    Run Keyword And Ignore Error    Stop Gnb BIP Log    log_dir=${log_dir}
        Run Keyword If    '${log}'=='apbip'    Run Keyword And Ignore Error    Stop AP Bip Log    log_dir=${log_dir}
        Run Keyword If    '${log}'=='ttitrace'    Run Keyword And Ignore Error    Stop And Decode GNB TTI Trace    log_dir=${log_dir}
        Run Keyword If    '${log}'=='sherpa'    Run Keyword And Ignore Error    Stop Sherpa L2stream Log    ${log_dir}
        Run Keyword If    '${log}'=='utefiles'    Run Keyword And Ignore Error    Collect UTE Files    log_dir=${log_dir}
        Run Keyword If    '${log}'=='egatelog'    Run Keyword And Ignore Error    Collect Edaemon Egate Log
    END

Start BTSlog
    [Arguments]    ${name}=btslog    ${btslog_path}=/opt/btslog/btslog
    ...    ${btslog_launcher_path}=/opt/btslog/btslog_launcher    ${log_dir}=/tmp/btslog2
    [Documentation]    This keyword is to create btslog log collector on testvm.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${name} | No | log name. e.g. btslog |
    ...    | ${btslog_path} | No | path of the ?btslog? executable default value:?/opt/btslog/btslog? |
    ...    | ${btslog_launcher_path} | No | path of ?btslog_launcher? |
    ...    |  |  | executable default value:?/opt/btslog/btslog_launcher? |
    ...    | ${log_dir} | No | path from where to get btslog files default value: ?/tmp/btslog2? |
    ...
    ...    Examples:
    ...    | Start BTSlog | log_dir=${TEST_LOG_DIRECTORY} |  |
    Run Keyword And Ignore Error    OperatingSystem.Run    pkill btslog
    btslog.Create Btslog Collector    name=${name}    btslog_path=${btslog_path}
    ...    btslog_launcher_path=${btslog_launcher_path}
    ...    log_dir=${log_dir}
    CORE.Setup Collectors    names=${name}
    CORE.Start Collectors    names=${name}
    btslog.Set Suite Alias    ${name}

Stop BTSlog
    [Arguments]    ${collector_name}=btslog    ${log_dir}=${TEST_LOG_DIRECTORY}
    CORE.Stop Collectors    names=${collector_name}
    CORE.Collect Collectors    names=${collector_name}    target_dir=${log_dir}
    CORE.Teardown Collectors    names=${collector_name}

Start Tcpdump
    [Arguments]    ${name}=testVM_Tcpdump    ${options}=-v -i eth3    ${sudo_password}=None
    [Documentation]    create tcpdump log collector on local testvm.
    ...    name: name of the collector. Ex: oamTcpdump
    ...    options: (optional) tcpdump options (except for ?-w?), default: empty string
    ...    sudo_password: password for sudo
    Log    ${sudo_password}
    tcpdump.Create Tcpdump Collector    name=${name}    options=${options}
    tcpdump.Set Suite Alias    ${name}
    CORE.Setup Collectors    names=${name}
    CORE.Start Collectors    names=${name}

Stop Tcpdump
    [Arguments]    ${log_dir}=${test_log_directory}
    CORE.Collect Collectors    names=testVM_Tcpdump    target_dir=${log_dir}
    CORE.Teardown Collectors    names=testVM_Tcpdump

Start TSharklog
    [Arguments]    ${name}=oamTShark    ${options}=-i internal    ${sudo_password}=None
    [Documentation]    create tShark log collector on local testvm.
    ...    name: name of the collector. Ex: oamTShark
    ...    options: (optional) Path of tShark path executable, default value is ?tShark?
    ...    To Collect Prisma Logs Value Is ?prisma?
    ...    sudo_password: password for sudo
    Run Keyword And Ignore Error    OperatingSystem.Run    pkill tShark
    tShark.Create TShark Collector    name=${name}    options=${options}    sudo_password=${sudo_password}
    tShark.Set Suite Alias    ${name}
    CORE.Setup Collectors    names=${name}
    CORE.Start Collectors    names=${name}

Stop TSharklog
    [Arguments]    ${log_dir}=${test_log_directory}
    CORE.Collect Collectors    names=oamTShark    target_dir=${log_dir}
    CORE.Teardown Collectors    names=oamTShark

Collect PM Counters
    [Arguments]    ${gnb_id}=0    ${name}=gnb_pm_counters
    [Documentation]    Collects the pm counters files to the default path.
    ...    gnb_id: gnb_id default value:0
    ...    name: name of the collector. Ex: gnb_pm_counters
    &{webservice}=    Create Dictionary    host=${GNB_ASIK.ip}
    ...    user=${GNB_ASIK.username}
    ...    password=${GNB_ASIK.password}
    ...    port=443
    Log to console  ${gnb_id}
    Create PM Collector    name=${name}    webservice=${webservice}
    CORE.Setup Collectors    names=${name}
    CORE.Collect Collectors    names=${name}    target_dir=${TEST_LOG_DIRECTORY}
    CORE.Teardown Collectors    names=${name}

Collect Coam SnapShot
    [Arguments]    ${gnb_id}=0    ${name}=gnb_coam_snapShot    ${coverage}=Full    ${force}=0    ${timeout}=480
    [Documentation]    Collects the snapShot files to the default path.
    ...    gnb_id: gnb_id default value:0
    ...    name: name of the collector. Ex: gnb_coam_snapShot
    &{webservice}=    Create Dictionary    host=${GNB_ASIK.ip}
    ...    user=${GNB_ASIK.username}
    ...    password=${GNB_ASIK.password}
    ...    port=443
    Log to console  ${gnb_id}
    Create Sbts SnapShot Collector    name=${name}    webservice=${webservice}    coverage=${coverage}
    ...    force=${force}    timeout=${timeout}
    CORE.Setup Collectors    names=${name}
    CORE.Collect Collectors    names=${name}    target_dir=${test_log_directory}
    CORE.Teardown Collectors    names=${name}

Save Coam SnapShot
    [Arguments]    ${log_dir}=${test_log_directory}
    ${coam_connection}    coam.Connect To    bts_host=${GNB_ASIK.ip}
    coam.Get SnapShot    target_file_name=${log_dir}/snapShot.zip    coverage=Full    force=True    connection=${coam_connection}
    [Teardown]    coam.Teardown    ${coam_connection}

Get Today
    ${time}    DateTime.Get Current Date    result_format=datetime
    ${date} =    Convert Date    ${time}    exclude_millis=yes    date_format=%m.%d.%Y
    ${date}    String.Split String    ${date}    ${space}
    [Return]    ${date[0]}

Start GNB AP Syslog
    [Arguments]    ${log_dir}
    Run Keyword And Ignore Error    Stop Syslog    alias=${GNB_SYSLOG.alias}
    Run Keyword And Ignore Error    Stop Syslog    alias=${AP_SYSLOG.alias}
    Start Syslog    file_limit=${GNB_SYSLOG.file_limit}    log_dir=${log_dir}
    ...    log_name=${GNB_SYSLOG.log_name}    ip=${GNB_SYSLOG.ip}    alias=${GNB_SYSLOG.alias}
    Start Syslog    file_limit=${AP_SYSLOG.file_limit}    log_dir=${log_dir}
    ...    log_name=${AP_SYSLOG.log_name}    ip=${AP_SYSLOG.ip}    alias=${AP_SYSLOG.alias}

Stop And Collect Syslog
    [Arguments]    ${log_dir}
    Log to console    ${log_dir}
    Collect Syslog Results    alias=${GNB_SYSLOG.alias}    unzip=False    destination=${log_dir}/Gnb_syslog.tar.gz
    Collect Syslog Results    alias=${AP_SYSLOG.alias}    unzip=False    destination=${log_dir}/AP_syslog.tar.gz

Collect GNB AP SnapShot Via Aashell
    [Arguments]    ${log_dir}
    Collect GNB SnapShot Via AaShell    ${log_dir}
    Collect AP SnapShot Via AaShell    ${log_dir}

Collect GNB SnapShot Via AaShell
    [Arguments]    ${log_dir}    ${log_name}=snapShot_gnb.zip
    [Documentation]    collect GNB snapshot
    ...    Examples:
    ...    | Collect GNB SnapShot Via AaShell | /tmp |
    SSH.Connect_to          hostname=${GNB_ASIK.ip}
    ...                     username=${GNB_ASIK.username}
    ...                     password=${GNB_ASIK.password}
    ...                     alias=connection_gnb_snapshot
    ${prompt}               Set variable      AaShell>
    SSH.Send command           telnet localhost 15007             connection=connection_gnb_snapshot
    SSH.Read output until      ${prompt}       timeout=60         connection=connection_gnb_snapshot
    SSH.Write input            log -c full -a -z ${log_name}\n    connection=connection_gnb_snapshot
    SSH.Read output until      ${prompt}       timeout=300        connection=connection_gnb_snapshot
    SSH.Write input            quit\n                             connection=connection_gnb_snapshot
    SSH.Await execution end                                       connection=connection_gnb_snapshot
    ${cp_cmd}=    Set Variable    scp ${GNB_ASIK.username}@${GNB_ASIK.ip}:${/}tmp${/}${log_name} ${log_dir}/${log_name}
    OperatingSystem.Run    sshpass -p ${GNB_ASIK.password} ${cp_cmd}
    SSH.Disconnect         connection=connection_gnb_snapshot

Collect AP SnapShot Via AaShell
    [Arguments]    ${log_dir}
    Telnet.Open Connection    host=${AP_ASIK.ip}    port=15007
    Telnet.Set Prompt    AaShell>
    Telnet.Set Timeout    300 seconds
    Telnet.Write    log -c full -a -z snapShot_ap.zip
    Telnet.Read Until    AaSysComUserDeregister succeed!
    Telnet.Close Connection
    OperatingSystem.Run    sshpass -p ${AP_ASIK.password} scp toor4nsn@${AP_ASIK.ip}:/tmp/snapShot_ap.zip ${log_dir}/snapShot_ap.zip

Collect UTE Logs
    [Arguments]    ${log_dir}
    Log To Console    Collecting configs...
    Collect UTE Files    ${log_dir}
    Log To Console    Collecting logs...
    Collect UTE SosReport    ${log_dir}
    Collect all logs via log_collector.Sh    ${log_dir}

Collect UTE Files
    [Arguments]    ${log_dir}
    Run Keyword And Ignore Error    OperatingSystem.Copy Files    ${wts_dir}/${wts_cfg}    ${wts_dir}/${wts_ap_xml}
    ...    ${tl_init_dir}/DEBUG_log.txt    ${tl_init_dir}/INFO_log.txt    ${log_dir}/
    SSH.Connect To    ${AP_ASIK.ip}    ${AP_ASIK.username}    ${AP_ASIK.password}
    ...    alias=${AP_ASIK.connection}
    SSH.Connect To    ${GNB_ASIK.ip}    ${GNB_ASIK.username}    ${GNB_ASIK.password}
    ...    alias=${GNB_ASIK.connection}
    @{configs}    Create List    /ffs/run/swconfig.txt    /rom/simmode/iphy.xml
    SSH.Download File    ${configs}    ${log_dir}/    ${AP_ASIK.connection}
    SSH.Download File    /ffs/run/swconfig.txt    ${log_dir}/swconfig_gnb.txt
    ...    ${GNB_ASIK.connection}

Collect UTE SosReport
    [Arguments]    ${log_dir}
    ${result}    Execute Egate Command    sim_log_set flush
    ${command}    Catenate    sed -i \'s@LOG_DIR_ON_DEVICE=.*@LOG_DIR_ON_DEVICE="/tmp/sosreport"@g\'
    ...    ${wts_dir}/sosReport.cfg
    OperatingSystem.Run    ${command}
    OperatingSystem.Run    cd ${log_dir}/ && ${wts_dir}/sosReport.sh -nr -c -s > /dev/null 2>\&1
    OperatingSystem.Run    ls ${log_dir}/SosReport*.tgz

Collect all logs via log_collector.Sh
    [Arguments]    ${log_dir}
    Run And Return Rc And Output    chmod +x ${LOG_COLLECTOR_PATH}
    Run And Return Rc And Output    cd ${log_dir} && ${LOG_COLLECTOR_PATH}

Verify Bip Log Exist
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${GNB_ASIK.ip} ls -al /tmp/5GBipL2L1_filtering_off.pcap*
    Should Be True    "${rc}"=="0"

Copy BIP Files And Return Count
    [Arguments]    ${path}
    Log To Console    copy bip files to ${path}...
    Wait Until Keyword Succeeds    10 s    2 s    Verify Bip Log Exist
    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu scp ${AP_ASIK.username}@${GNB_ASIK.ip}:/tmp/5GBipL2L1_filtering_off.pcap* ${path}
    ${count}    OperatingSystem.Count Items In Directory    ${path}    pattern=5GBipL2L1_filtering_off.pcap*
    [Return]    ${count}

Download And Unzip Lua File
    [Arguments]    ${sw}
    Run Keyword If    "${ENB_BUILD}"=="SBTS"    Download And Unzip Lua File On Common Package    ${sw}
    ...    ELSE    Download And Unzip Lua File On 5G Package    ${sw}

Download And Unzip Lua File On Common Package
    [Arguments]    ${sw}
    Log To Console    download and unzip lua file...
    OperatingSystem.Run    rm ${output_dir}/luashark-*.zip
    ${lua_url}    Set Variable
    ...    ${PACKAGE_FTP_URL}/${sw}/${sw}_luashark.zip
    OperatingSystem.Run    wget ${lua_url} -P ${output_dir}
    ${res}    Run Keyword And Return Status    OperatingSystem.Should Exist    ${output_dir}/${sw}_luashark.zip
    Run Keyword If    '${res}'=='False'    Download Previous Lua File    ${sw}
    OperatingSystem.Run    rm -rf ${output_dir}/generated_luashark
    OperatingSystem.Run    unzip ${output_dir}/*_luashark.zip -d ${output_dir}
    ${lua_script_path}    Set Variable    ${output_dir}/generated_luashark/luashark.lua
    [Return]    ${lua_script_path}

Download And Unzip Lua File On 5G Package
    [Arguments]    ${sw}
    Log To Console    download and unzip lua file...
    OperatingSystem.Run    rm ${output_dir}/luashark-*.zip
    ${lua_url}    Set Variable
    ...    https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/${sw}/luashark-${sw}.zip
    OperatingSystem.Run    wget ${lua_url} -P ${output_dir}
    ${res}    Run Keyword And Return Status    OperatingSystem.Should Exist    ${output_dir}/luashark-${sw}.zip
    Run Keyword If    '${res}'=='False'    Download Previous Lua File    ${sw}
    OperatingSystem.Run    rm -rf ${output_dir}/generated_luashark
    OperatingSystem.Run    unzip ${output_dir}/luashark-*.zip -d ${output_dir}
    ${lua_script_path}    Set Variable    ${output_dir}/generated_luashark/luashark.lua
    [Return]    ${lua_script_path}

Download Previous Lua File
    [Arguments]    ${sw}
    [Documentation]    This keyword is to download lua file before given sw version
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${sw} | Yes | soft vesion, such as 0.800.1593, 9.1800.1132 |
    ...
    ...    Examples:
    ...    | Download Previous Lua File | 0.800.1593 |
    ...
    ${url}    Set Variable
    ...    https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/
    OperatingSystem.Run    wget ${url} -P ${output_dir}
    OperatingSystem.File Should Exist    ${output_dir}/index.html
    @{values}    String.Split String    ${sw}    .
    ${branch}    Catenate    SEPARATOR=.    ${values[0]}    ${values[1]}
    ${content}    OperatingSystem.Get File    path=${output_dir}/index.html
    @{matches}    String.Get Regexp Matches    ${content}    <a href="[0-9\.]+/">(${branch}\.[0-9]+)/</a>    1
    ${index}    Collections.Get Index From List    ${matches}    ${sw}
    @{previous_versions}    Collections.Get Slice From List    ${matches}    start=0    end=${index}
    FOR    ${ver}    IN    @{previous_versions[::-1]}
        Log    ${ver}
        ${lua_url}    Set Variable
        ...    https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/${ver}/luashark-${ver}.zip
        OperatingSystem.Run    wget ${lua_url} -P ${output_dir}
        ${res}    Run Keyword And Return Status    OperatingSystem.Should Exist    ${output_dir}/luashark-${ver}.zip
        Exit For Loop If    '${res}'=='True'
    END

Get Field Values From BIP Files
    [Arguments]    ${expression}    ${count}
    Log To Console    get field values from bip files...
    ${all_values}    Create List    ${EMPTY}
    FOR    ${index}    IN RANGE    ${count}
        ${pdml_entries}    PCAP.Load Pcap File
        ...    pcap_file=${output_dir}/5GBipL2L1_filtering_off.pcap${index}
        ...    luashark_path=${output_dir}/generated_luashark/luashark.lua
        ${filter_packets}    PCAP.Filter Packets By Expression    pdml_list=${pdml_entries}    filter_expression=${expression}
        ${field_values}    PCAP.Get Field Value By Name    pdml_list=${filter_packets}    field_name=${expression}
        ${all_values}    Collections.Combine Lists    ${all_values}    ${field_values}
        PCAP.Teardown
    END
    [Return]    ${all_values}

Check Field Values Contain Slots
    [Arguments]    ${field_values}    ${slots_list}
    Log To Console    check field values contain slots: ${slots_list}...
    FOR    ${slot}    IN    @{slots_list}
        Should Contain    ${field_values}    ${slot}
    END

Check Field Values Not Contain Slots
    [Arguments]    ${field_values}    ${slots_list}
    Log To Console    check field values not contain slots: ${slots_list}...
    Should Not Contain Any    ${field_values}    @{slots_list}

Start Sos Report
    [Arguments]    ${loner_version}=D    ${phoner_version}=PH7    ${l1_mode}=fullstack
    [Documentation]    This keyword is to use script 'AP_Classical_Fullstack_startTestwithSosReport.sh'
    ...    to start capture Airphone SosReport log.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${loner_version} | No | define in sosReport.cfg. The default value is D |
    ...    | ${phoner_version} | No | define in sosReport.cfg. The default value is PH7 |
    ...    | ${l1_mode} | No | define in sosReport.cfg. The default value is fullstack |
    ...
    ...    Examples:
    ...    | Start Sos Report |  |
    ...    | Start Sos Report | l1_mode=l1bypass |
    Log To Console    Start Sosreport...
    OperatingSystem.Remove File    ${wts_dir}${/}SosReport*_iphy1.tgz
    ${start_sosreport_cmd}    Set Variable
    ...    .${/}AP_Classical_Fullstack_startTestwithSosReport.sh -nr -c -s -m\=${loner_version} -a\=${phoner_version} -l1\=${l1_mode}
    ${result}    Process.Start Process    ${start_sosreport_cmd}    shell=True    cwd=${wts_dir}
    ...    stdout=${TEMPDIR}/start_stdout.txt
    ${success_msg}    Set Variable    You can now start your tests in egate
    Wait Until Keyword Succeeds    1min    5s    Check Suscess Msg Exist    ${TEMPDIR}${/}start_stdout.txt    ${success_msg}

Stop Sos Report
    [Arguments]    ${log_dir}
    [Documentation]    This keyword is to use script 'AP_Classical_Fullstack_stopTestwithSosReport.sh' to stop Sosreport
    ...     and copy the log to the specified directory.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_dir} | Yes | the log path to restore sosreport log. |
    ...
    ...    Examples:
    ...    | Stop Sos Report | ${TEST_LOG_DIRECTORY} |
    Log To Console    Stop Sosreport...
    Sleep    10s    reason=make sure the error log captured
    ${stop_sosreport_cmd}    Set Variable    .${/}AP_Classical_Fullstack_stopTestwithSosReport.sh
    ${result}    Process.Start Process    ${stop_sosreport_cmd}    shell=True    cwd=${wts_dir}
    ...    stdout=${TEMPDIR}/stop_stdout.txt
    ${success_msg}    Set Variable    _iphy1.tgz created
    Wait Until Keyword Succeeds    ${MAX_WAITTIME_SOSREPORT}    10s    Check Suscess Msg Exist    ${TEMPDIR}${/}stop_stdout.txt    ${success_msg}
    OperatingSystem.Copy Files    ${wts_dir}${/}SosReport*_iphy1.tgz    ${log_dir}

Check Suscess Msg Exist
    [Arguments]    ${file_path}    ${success_msg}
    [Documentation]    This keyword is to check a msg exsit in a file
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${file_path} | Yes | the file path need to check |
    ...    | ${success_msg} | Yes | the message need to check |
    ...
    ...    Examples:
    ...    | Check Suscess Msg Exist | ${TEMPDIR}${/}stop_stdout.txt | You can now start your tests in egate |
    ...    | Check Suscess Msg Exist | ${TEMPDIR}${/}start_stdout.txt | _iphy1.tgz created |
    ${ret}    OperatingSystem.Grep File    ${file_path}    ${success_msg}
    Should Not Be Empty    ${ret}

Start Sherpa L2stream Log
    [Arguments]    ${l2stream_config}=${L2STREAM_CONFIG}    ${names}=l2stream3_sherpa
    [Documentation]    This keyword is to start capture L2Stream log.
    ...    Please see the detail of keywords in https://confluence.ext.net.nokia.com/display/CV/L2stream3_Collectors+Example
    ...    | Input Parameters | Man. | Description |
    ...    | ${l2stream_config_list} | Yes | sherpa log config list?defined in Common_setup_teardown.robot |
    ...
    ...    Examples:
    ...    | Start Sherpa L2stream Log | ${l2stream_config} |
    ${bb_type}    Get Base Band Board Type
    ${web_card}    ${dest_ip}=    Get EIF Info Of Control PC
    Log To Console    Start L2Stream log...
    OperatingSystem.Run    sudo usermod -a -G sherpa ute
    Process.Start Process    sudo cap_net_raw,cap_net_admin\=eip ./Sherpa    shell=True    cwd=/opt/Nokia/Sherpa_5G_18/
    ${executor}=  Create Dictionary
    ...    host=192.168.255.1
    ...    user=Nemuadmin
    ...    password=nemuuser
    ...    port=443
    TCPDUMP.Create Tcpdump Collector
    ...    name=tcpdump_sherpa
    ...    options=-i ${web_card} udp and dst ${dest_ip} and dst port 5678
    ...    sudo_password=ute
    L2STREAM3.Create Sbts L2stream Collector
    ...    name=${names}
    ...    webservice=${executor}
    ...    destination_ip_addr=${dest_ip}
    ...    collector=tcpdump_sherpa
    ...    l2_stream_configuration=${l2stream_config}
    CORE.Setup Collectors    names=${names}
    CORE.Start Collectors    names=${names}
    L2STREAM3.Set Suite Alias    ${names}

Stop Sherpa L2stream Log
    [Arguments]    ${log_dir}=${TEST_LOG_DIRECTORY}    ${names}=l2stream3_sherpa
    Log To Console    Stop L2Stream log...
    CORE.Stop Collectors    names=${names}
    CORE.Collect Collectors    names=${names}    target_dir=${log_dir}
    CORE.Teardown Collectors    names=${names}

Setup Connections
    ${GNB_ASIK_CONNECTION}    SSH.Connect To    hostname=${GNB_ASIK.ip}    username=${GNB_ASIK.username}
    ...    password=${GNB_ASIK.password}    alias=${GNB_ASIK.connection}
    ${AP_ASIK_CONNECTION}    SSH.Connect To    hostname=${AP_ASIK.ip}    username=${AP_ASIK.username}
    ...    password=${AP_ASIK.password}    alias=${AP_ASIK.connection}
    Set Suite Variable    ${GNB_ASIK_CONNECTION}
    Set Suite Variable    ${AP_ASIK_CONNECTION}

Teardown All Connections
    SSH.Disconnect    connection=${GNB_ASIK_CONNECTION}
    SSH.Disconnect    connection=${AP_ASIK_CONNECTION}

Judge Process Existed
    [Arguments]    ${part_proc_msg}    ${process_msg}    ${connection}
    [Documentation]    This keyword is to kill the process with the ${process_msg} if it exist.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${process_msg} | Yes | the msg to filter the related process |
    ...    | ${connection} | Yes | the SSH connection to kill process |
    ...
    ...    Examples:
    ...    | ${cmd} | Set Variable | tcpdump -i etha01 -C 50 -W 2 -w /tmp/5GBipL2L1_filtering_off.pcap |
    ...    | Kill Process If Existed | 5GBipL2L1_filtering_off.pcap || ${cmd} | ${GNB_ASIK_CONNECTION} |
    ...
    ${process}    SSH.Execute    command=ps aux|grep '${part_proc_msg}'    connection=${connection}
    ${check_status}    Run Keyword And Return Status     Should Contain    ${process_msg}    \\
    Run Keyword If    '${check_status}'=='${true}'    Should Match Regexp    ${process}    ${process_msg}
    ...    ELSE    Should Contain    ${process}    ${process_msg}

Kill Process If Existed
    [Arguments]    ${part_proc_msg}    ${process_msg}    ${connection}
    [Documentation]    This keyword is to kill the process with the ${process_msg} if it exist.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${process_msg} | Yes | the msg to filter the related process |
    ...    | ${connection} | Yes | the SSH connection to kill process |
    ...
    ...    Examples:
    ...    | ${cmd} | Set Variable | tcpdump -i etha01 -C 50 -W 2 -w /tmp/5GBipL2L1_filtering_off.pcap |
    ...    | Kill Process If Existed | 5GBipL2L1_filtering_off.pcap || ${cmd} | ${GNB_ASIK_CONNECTION} |
    ...
    ${status}    Run Keyword And Return Status    Judge Process Existed    ${part_proc_msg}    ${process_msg}    ${connection}
    Run Keyword If    '${status}'=='${true}'    SSH.Execute
    ...    command=ps aux|grep '${part_proc_msg}'|awk '{print $2}'|xargs kill -2    connection=${connection}

Verify Process Start Success
    [Arguments]    ${part_proc_msg}    ${process_msg}    ${connection}
    [Documentation]    This keyword is to verify if log process start success
    ...    Notice: just available in keywords:Start X2 Pcap Log; Start Gnb BIP Log
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${process_msg} | Yes | A string for the whole command |
    ...    | ${connection} | Yes | the connection to execute the command |
    ...
    ...    Examples:
    ...    | ${cmd} | Set Variable | tcpdump -i etha01 -C 50 -W 2 -w /tmp/5GBipL2L1_filtering_off.pcap |
    ...    | Verify BIP Start Success | 5GBipL2L1_filtering_off.pcap || ${cmd} | ${GNB_ASIK_CONNECTION} |
    ...
    Judge Process Existed    ${part_proc_msg}    ${process_msg}    ${connection}

Kill And Verify Process Stop Success
    [Arguments]    ${part_proc_msg}    ${process_msg}    ${connection}
    [Documentation]    This keyword is to verify if log capture process end success
    ...    Notice: just available in keywords: Stop X2 Pcap Log; Stop Gnb BIP Log
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${process_msg} | Yes | A string for the whole command |
    ...    | ${connection} | Yes | the connection to execute the command |
    ...
    ...    Examples:
    ...    | ${cmd} | Set Variable | tcpdump -i etha01 -C 50 -W 2 -w /tmp/5GBipL2L1_filtering_off.pcap |
    ...    | Kill And Verify Process Stop Success | 5GBipL2L1_filtering_off.pcap || ${cmd} | ${GNB_ASIK_CONNECTION} |
    ...
    Kill Process If Existed    ${part_proc_msg}    ${process_msg}    ${connection}
    ${process}    SSH.Execute    command=ps aux|grep '${part_proc_msg}'    connection=${connection}
    ${check_status}    Run Keyword And Return Status     Should Contain    ${process_msg}    \\
    Run Keyword If    '${check_status}'=='${true}'    Should Not Match Regexp    ${process}    ${process_msg}
    ...    ELSE    Should Not Contain    ${process}    ${process_msg}

Get Gnb Domain Id
    [Documentation]    This keyword is to get gnb domain id to judge the position of gnb is in right side or left side
    ...
    ${cmd}=    Set Variable    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 ddal -s ddal_sysinfo_module_get_domain_id 0 2>/dev/null
    ${ret}    ${output}=    OperatingSystem.Run And Return Rc And Output    ${cmd}
    ${dmid_regexp}    Set Variable    dmid=(?P<domain_id>\\d)
    @{matches}    String.Get Regexp Matches    ${output}    ${dmid_regexp}    domain_id
    [Return]    ${matches[0]}

Get GNB Position
    [Documentation]    This keyword is to judge the position of gnb is in right side or left side
    ...
    ${gnb_domain_id}    Get Gnb Domain Id
    ${gnb_pos}    Set Variable If    ${gnb_domain_id}==2    right_side    left_side
    [Return]    ${gnb_pos}

Set Gnb Side SEI1 Port
    [Documentation]    This keyword is to set gnb side SEI1 port
    ...    Refer to https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1085125821
    ...
    # enable Marvell  ports2
    Execute Cmd On Fct    echo 1 > /var/run/cpss/ports/2/enable
    #set eths2 up
    Execute Cmd On Fct    ifconfig eths2 up
    #Enable interface and monitor ports 4 &6 to port 2.
    Execute Cmd On Fct     ncp_portmirror -d netdriver -p xgmac97
    Execute Cmd On Fct     echo 2 both > /var/run/cpss/ports/4/mirroring_port
    Execute Cmd On Fct    echo 2 both > /var/run/cpss/ports/6/mirroring_port
    Execute Cmd On Fct    ncp_l2 -p XGMAC97 -I -senableSwitching.false
    Execute Cmd On Fct    ncp_l2 -p XGMAC97 -i -sdiscardInvalidVlanidPackets.false
    Execute Cmd On Fct    ncp_l2 -p XGMAC97 -i -sdiscardBadLengthPackets.false

Execute Cmd On Fct
    [Arguments]    ${cmd}
    ${cmd_1}=    Set Variable    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 "${cmd}"
    ${ret}    ${output}=    OperatingSystem.Run And Return Rc And Output    ${cmd_1}
    Should Be True    "${ret}"=="0"

Modify BIP Script File For ABIO
    ${gnb_hostname}=    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 hostname 2>/dev/null
    ${slot_id}=    Set Variable If    '${gnb_hostname}'=='fct-4a'    5    1
    Run Keyword If     '${slot_id}'=='5'    Modify BB Slot

Modify BB Slot
    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh    BB_SLOT_1='true'    BB_SLOT_1='false'
    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh    BB_SLOT_5='false'    BB_SLOT_5='true'

Start Gnb BIP Log
    [Arguments]    ${duration}=infinite
    [Documentation]    This keyword is to start gnb bip log capture process on different testline types.
    Download GNB Mirroring Tool
    Get Base Band Board Type
    Get Control Board Type
    Run Keyword If    '${FCT_BOARD_TYPE}'=='ASIK' or '${FCT_BOARD_TYPE}'=='ASIB'    Start BIP Log On ASIK ASIB    ${duration}
    Run Keyword If    '${FCT_BOARD_TYPE}'=='ASIL'    Start BIP Log On ASIL

Start BIP Log On ASIK ASIB
    [Arguments]    ${duration}=infinite
    Clear The BIP File Dir In Gnb
    Log To Console    INFO:Start GNB BIP log On ASIK or ASIB...
    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh    CAPTURING_TIME_SECONDS=[0-9]+    CAPTURING_TIME_SECONDS=${duration}
    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroring.sh    tcpdump_L2L1_bip    5GBipL2L1
    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh    NUMBER_OF_FILES=10    NUMBER_OF_FILES=2
    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh    FILE_SIZE_MBYTES=100    FILE_SIZE_MBYTES=50
    Modify File Parameter    ${SCRIPT_PATH}/shell/ABIO_BIP_mirroring.sh    tcpdumpL2L1    5GBipL2L1
    Modify File Parameter    ${SCRIPT_PATH}/shell/ABIO_BIP_mirroring.sh    -C 100    -C 50
    Modify File Parameter    ${SCRIPT_PATH}/shell/ABIO_BIP_mirroring.sh    -W 20    -W 2
    Run Keyword If    '${ASP_BOARD_TYPE}'=='ABIO'    Modify BIP Script File For ABIO
#    Run Keyword If    '${ASP_BOARD_TYPE}'=='ABIO'    Set Gnb Side SEI1 Port
    OperatingSystem.Run    sshpass -p ${GNB.password} scp ${SCRIPT_PATH}/BIP/* ${GNB.username}@${GNB.ip}:/ffs/run/config/scripts/
    OperatingSystem.Run
    ...    sshpass -p ${GNB.password} scp ${SCRIPT_PATH}/shell/ABIO_BIP_mirroring.sh ${GNB.username}@${GNB.ip}:/ffs/run/config/scripts/
    ${gnb_hostname}=    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 hostname 2>/dev/null
    ${slot_id}=    Set Variable If    '${gnb_hostname}'=='fct-4a'    5    1
    ${exec_script}    Set Variable If    '${ASP_BOARD_TYPE}'=='ABIO'    ABIO_BIP_mirroring.sh ${slot_id}    gnbMirroring.sh
    #${exec_script}    Set Variable    gnbMirroring.sh
    OperatingSystem.Run    sshpass -p ${GNB.password} ssh ${GNB.username}@${GNB.ip} chmod +x /ffs/run/config/scripts/${exec_script}
    SSH.Connect To    ${GNB.ip}    ${GNB.username}    ${GNB.password}    alias=BIP_ASIK_Start
    SSH.Send Command    command=sh /ffs/run/config/scripts/${exec_script} 1>/dev/null 2>&1 &    connection=BIP_ASIK_Start
    #Set Suite Variable    ${BIP_CMD}    tcpdump -i \\w+ -C 50 -W 2 -w /tmp/5GBipL2L1_filtering_off\\.pcap
    Set Suite Variable    ${BIP_CMD}           tcpdump -i
    Wait Until Keyword Succeeds    1min    2s    Verify Process Start Success    5GBipL2L1_filtering_off    ${BIP_CMD}    BIP_ASIK_Start
    Log To Console   INFO:bip start success...

Start BIP Log On ASIL
    Log To Console    Start bip log on ASIL...
    Process.Start Process    sshpass -p ${GNB.password} ssh ${GNB.username}@${GNB.ip} <${SCRIPT_PATH}/shell/bip_ASIL_ABIO.sh    shell=True
    ${cmd}    Set Variable    tcpdump -i nac_eth2 -w /tmp/5GBipL2L1_filtering_off.pcap
    Wait Until Keyword Succeeds    20s    2s    Verify Process Is Running On Gnb    5GBipL2L1_filtering_off    ${cmd}

Stop Gnb BIP Log
    [Arguments]    ${log_dir}
    [Documentation]    This keyword is to stop bip log capture process started by keyword Start Gnb BIP Log
    ...    when durarion=infinite(necessory). It also will copy bip log files to given log_dir and this keyword
    ...    will return the numer of bip files.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_dir} | Yes | Directory where to put the bip logs in |
    ...
    ...    Examples:
    ...    | Start Gnb BIP Log | duration=infinite |
    ...    | ${bip_counts} | Stop Gnb BIP Log | ${output_dir} |
    ...
    Run Keyword If    '${FCT_BOARD_TYPE}'=='ASIK' or '${FCT_BOARD_TYPE}'=='ASIB'    Stop BIP Log On ASIK ASIB    ${log_dir}
    Run Keyword If    '${FCT_BOARD_TYPE}'=='ASIL'    Stop BIP Log On ASIL    ${log_dir}

Stop BIP Log On ASIK ASIB
    [Arguments]    ${log_dir}
    Log To Console    INFO:Stop GNB BIP log...
    Wait Until Keyword Succeeds    6s    2s    Kill And Verify Process Stop Success    5GBipL2L1_filtering_off    ${BIP_CMD}    BIP_ASIK_Start
    Run Keyword If    '${log_dir}'!='${SUITE_LOG_DIRECTORY}' or '${log_dir}'!='${TEST_LOG_DIRECTORY}'    Create Directory    ${log_dir}
    ${bip_counts}    Copy BIP Files And Return Count    ${log_dir}
    Log To Console   INFO:bip end success...
    [Return]    ${bip_counts}

Stop BIP Log On ASIL
    [Arguments]    ${log_dir}
    Log To Console    INFO:Stop GNB BIP log...
    ${cmd}    Set Variable    tcpdump -i nac_eth2 -w /tmp/5GBipL2L1_filtering_off.pcap
    Wait Until Keyword Succeeds    6s    2s    Kill Process On Gnb    5GBipL2L1_filtering_off    ${cmd}
    Run Keyword If    '${log_dir}'!='${SUITE_LOG_DIRECTORY}' or '${log_dir}'!='${TEST_LOG_DIRECTORY}'    Create Directory    ${log_dir}
    ${bip_counts}    Copy BIP Files And Return Count    ${log_dir}
    Log To Console   INFO:bip end success...
    [Return]    ${bip_counts}

Download GNB Mirroring Tool
    [Arguments]    ${local_save_path}=${CURDIR}/GNB_mirroring_repo
    [Documentation]     This keyword will download GNB mirroring tool to replace existed.
    ...    Examples:
    ...    | Download GNB Mirroring Tool |
    OperatingSystem.Run    rm -rf ${local_save_path}
    OperatingSystem.Run    git clone ${GNB_MIRRORING_TOOL_LINK} ${local_save_path}
    OperatingSystem.Run    cp ${local_save_path}/gnbMirroring/gnbMirroringConfig.sh ${CURDIR}/scripts/BIP/
    OperatingSystem.Run    cp ${local_save_path}/gnbMirroring/gnbMirroring.sh ${CURDIR}/scripts/BIP/

Kill Process On Gnb
    [Arguments]    ${part_proc_msg}    ${process_msg}
    ${pids}    OperatingSystem.Run
    ...    sshpass -p ${GNB.password} ssh ${GNB.username}@${GNB.ip} ps aux|grep ${part_proc_msg}|awk '{print $2}'
    OperatingSystem.Run    sshpass -p ${GNB.password} ssh ${GNB.username}@${GNB.ip} kill -2 ${pids}
    Verify Process Is Not Running On Gnb    ${part_proc_msg}    ${process_msg}

Clear The BIP File Dir In Gnb
    [Documentation]    This keyword is to clear bip files in gnb /ffs/run/config/scripts if exists.
    ...    As well as the log files /tmp/5GBipL2L1_filtering_off*
    ...    Notice: just available in keyword Start Gnb BIP Log
    ...
    ...    Examples:
    ...    | Clear The BIP File Dir In Gnb |
    ...
    OperatingSystem.Run    sshpass -p ${GNB.password} ssh ${GNB.username}@${GNB.ip} rm /tmp/5GBipL2L1_filtering_off*
    OperatingSystem.Run    sshpass -p ${GNB.password} ssh ${GNB.username}@${GNB.ip} rm -rf /ffs/run/config/scripts
    OperatingSystem.Run    sshpass -p ${GNB.password} ssh ${GNB.username}@${GNB.ip} mkdir /ffs/run/config/scripts
    Log To Console    clear default bip scripts done...

Verify Process Is Running On Gnb
    [Arguments]    ${part_proc_msg}    ${process_msg}
    ${process}    OperatingSystem.Run    sshpass -p ${GNB.password} ssh ${GNB.username}@${GNB.ip} 'ps aux | grep ${part_proc_msg}'
    ${check_status}    Run Keyword And Return Status     Should Contain    ${process_msg}    \\
    Run Keyword If    '${check_status}'=='${True}'    Should Match Regexp    ${process}    ${process_msg}
    ...    ELSE    Should Contain    ${process}    ${process_msg}

Verify Process Is Not Running On Gnb
    [Arguments]    ${part_proc_msg}    ${process_msg}
    ${process}    OperatingSystem.Run    sshpass -p ${GNB.password} ssh ${GNB.username}@${GNB.ip} 'ps aux | grep ${part_proc_msg}'
    ${check_status}    Run Keyword And Return Status     Should Contain    ${process_msg}    \\
    Run Keyword If    '${check_status}'=='${True}'    Should Not Match Regexp    ${process}    ${process_msg}
    ...    ELSE    Should Not Contain    ${process}    ${process_msg}

Catch Ttitrace Log
    [Arguments]    ${wait_time}=5
    [Documentation]    This keyword is to start gnb ttitrace.
    ...    Examples:
    ...    | Catch Ttitrace Log | wait_time=5s |
    Log To Console    INFO:start tti trace on asp...
    ${cpu_id}=    Set Variable If    "${ASP_BOARD_TYPE}"=="ABIO"    0    1
    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 bsh 1:${cpu_id} rm -rf /var/eventsTrace/*
    ${cmd}=    Catenate    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1
    ...    bsh 1:${cpu_id} ls -l /tmp/ 2>/dev/null|grep -e ".*ram.*L2RT20"|awk -F "node_" '{print $2}'|awk -F " " '{print $1}'
    ${ret}    ${output}=    OperatingSystem.Run And Return Rc And Output    ${cmd}
    ${container_id}=    Set Variable    ${output}
    ${ttitrace_cmd}=    Set Variable    sh /opt/tools/ttiTrace/eventsCollect.sh
    ${cmd}=    Catenate    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1
    ...    bsh 1:${cpu_id} timeout ${wait_time} lxc-attach -n ${container_id} ${ttitrace_cmd}
    OperatingSystem.Run    ${cmd}
    Show Ttitrace Log On ASP

Show Ttitrace Log On ASP
    ${cpu_id}=    Set Variable If    "${ASP_BOARD_TYPE}"=="ABIO"    0    1
    ${ttitrace_bin_log}=    Catenate    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1
    ...    bsh 1:${cpu_id} ls -lrt /var/eventsTrace/
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    ${ttitrace_bin_log}
    Log To Console    INFO:ttitrace log list:${output}

Start GNB TTI Trace
    [Documentation]    This keyword is to start gnb ttitrace.
    ...
    ...    Examples:
    ...    | Start GNB TTI Trace | wait_time=5s |
    ...
    Log To Console    INFO:start tti trace on asp...
    ${cpu_id}=    Set Variable If    "${ASP_BOARD_TYPE}"=="ABIO"    0    1
    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 bsh 1:${cpu_id} rm -rf /var/eventsTrace/*
    ${cmd}=    Catenate    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1
    ...    bsh 1:${cpu_id} ls -l /tmp/ 2>/dev/null|grep -e ".*ram.*L2RT20"|awk -F "node_" '{print $2}'|awk -F " " '{print $1}'
    ${ret}    ${output}=    OperatingSystem.Run And Return Rc And Output    ${cmd}
    ${container_id}=    Set Variable    ${output}
    Set Suite Variable    ${TTITRACE_START_CMD}    sh /opt/tools/ttiTrace/eventsCollect.sh
    ${ssh_connect}=    Set Variable    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1
    ${cmd}=    Set Variable     ${ssh_connect} bsh 1:${cpu_id} lxc-attach -n ${container_id} ${TTITRACE_START_CMD}
    ${TTITRACE_HANDLE}=    Process.Start Process    ${cmd}    shell=True
    Set Suite Variable    ${TTITRACE_HANDLE}


Stop And Decode GNB TTI Trace
    [Arguments]    ${log_dir}=${TEST_LOG_DIRECTORY}
    Stop GNB TTI Trace
    Decode TTI Trace And Send To Control PC One By One    ${log_dir}

Stop GNB TTI Trace
    [Documentation]    This keyword is to stop gnb ttitrace.
    ...
    ...    Examples:
    ...    | Stop GNB TTI Trace |
    ...
    ${result}=    Process.Terminate Process    ${TTITRACE_HANDLE}
    Log To Console    INFO:TTI trace end success...
    Kill Ttitrace Process On ASP
    Show Ttitrace Log On ASP

Show Ttitrace Process On Control PC
    OperatingSystem.Run    ps -ef|grep eventsCollect.sh

Show Ttitrace Process On ASP
    ${cpu_id}=    Set Variable If    "${ASP_BOARD_TYPE}"=="ABIO"    0    1
    ${ssh_cmd}=    Set Variable    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    ${ssh_cmd} bsh 1:${cpu_id} ps aux|grep eventsCollect.sh

Kill Ttitrace Process On ASP
    ${cpu_id}=    Set Variable If    "${ASP_BOARD_TYPE}"=="ABIO"    0    1
    ${ssh_cmd}=    Set Variable    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    ${ssh_cmd} bsh 1:${cpu_id} ps aux|grep eventsCollect.sh
    ${rc}    ${pids}=    OperatingSystem.Run And Return Rc And Output    ${ssh_cmd} bsh 1:${cpu_id} ps aux|grep eventsCollect.sh|awk '{print $2}'
    Log    ${pids}
    @{lines}=    String.Split To Lines    ${pids}
    FOR   ${pid}    IN    @{lines}
        ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    ${ssh_cmd} bsh 1:${cpu_id} kill -2 ${pid}
    END
    Show Ttitrace Process On Control PC
    Show Ttitrace Process On ASP

Decode TTI Trace And Send To Control PC One By One
    [Arguments]    ${log_dir}=${TEST_LOG_DIRECTORY}
    [Documentation]    This keyword is to decode tti trace logs collected by keyword Start GNB TTI Trace
    ...    and put the result csv files in to ${log_dir}. In this process, one .sh script is used.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_dir} | No | default value is ${TEST_LOG_DIRECTORY} |
    ...
    ...    Examples:
    ...    | Decode TTI Trace And Send To Control PC One By One | log_dir=/home/ute/logs/ |
    ...
    Log To Console    INFO:start to decode tti .bin logs to csv
    OperatingSystem.Run And Return Rc And Output    sh ${CURDIR}/scripts/shell/decode_ttitrace_on_PC.sh ${log_dir}
    Log To Console    INFO:finish to decode tti .bin logs to csv

Convert String List To Integer List
    [Arguments]    ${string_list}
    ${integer_list}=    Create List
    FOR    ${value}    IN    @{string_list}
        ${value_i}=    Evaluate    int($value)
        Collections.Append To List    ${integer_list}    ${value_i}
    END
    [Return]     ${integer_list}

Start Ttitrace With Streaming Mode
    [Arguments]    ${pysical_cell_ids}=50    ${names}=l2stream3_ttitrace
    [Documentation]    This keyword is used to start ttitrace with streaming mode.
    ...    examples 1: catch 1 cell
    ...    Start Ttitrace With Streaming Mode
    ...    examples 2: catch 2 cells
    ...    Start Ttitrace With Streaming Mode    50,51
    ${executor}=  Create Dictionary
    ...  host=192.168.255.1
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
    Log to console   ${pysical_cell_ids}
    ${nr_phy_cell_ids}=    Get PhysCellId Of GNB
    ${localIpAddr}=    Get localIpAddr Of GNB    #10.0.1.2 for ute
    ${web_card}    ${dest_ip}=    Get EIF Info Of Control PC
    ${l2_stream_config_1}=  Create Dictionary
    ...  nr_phy_cell_ids=${nr_phy_cell_ids}
    @{l2_stream_configuration}=  Create List  ${l2_stream_config_1}
    TCPDUMP.create tcpdump collector
    ...  name=tcpdump_ttitrace
    ...  options=-i ${web_card} udp and dst ${dest_ip} and dst port 5678
    ...  sudo_password=ute
    L2STREAM3.create sbts l2stream collector
    ...  name=${names}
    ...  destination_ip_addr=${dest_ip}
    ...  collector=tcpdump_ttitrace
    ...  l2_stream_configuration=${l2_stream_configuration}
    ...  webservice=${executor}
    L2STREAM3.Set Suite Alias
    ...  alias=${names}
    CORE.setup_collectors
    ...  names=${names}
    CORE.start_collectors
    ...  names=${names}

Start Ttitrace With Streaming Mode_2
    [Arguments]    ${pysical_cell_ids}=50    ${names}=l2stream3_ttitrace
    [Documentation]    This keyword is used to start ttitrace with streaming mode.
    ...    examples 1: catch 1 cell
    ...    Start Ttitrace With Streaming Mode
    ...    examples 2: catch 2 cells
    ...    Start Ttitrace With Streaming Mode    50,51
    ${executor}=  Create Dictionary
    ...  host=192.168.255.1
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
    Log to console   ${pysical_cell_ids}
    ${nr_phy_cell_ids}=    Get PhysCellId Of GNB Runtime
    ${localIpAddr}=    Get localIpAddr Of GNB    #10.0.1.2 for ute
    ${web_card}    ${dest_ip}=    Get EIF Info Of Control PC
    ${l2_stream_config_1}=  Create Dictionary
    ...  nr_phy_cell_ids=${nr_phy_cell_ids}
    @{l2_stream_configuration}=  Create List  ${l2_stream_config_1}
    TCPDUMP.create tcpdump collector
    ...  name=tcpdump_ttitrace
    ...  options=-i ${web_card} udp and dst ${dest_ip} and dst port 5678
    ...  sudo_password=ute
    L2STREAM3.create sbts l2stream collector
    ...  name=${names}
    ...  destination_ip_addr=${dest_ip}
    ...  collector=tcpdump_ttitrace
    ...  l2_stream_configuration=${l2_stream_configuration}
    ...  webservice=${executor}
    L2STREAM3.Set Suite Alias
    ...  alias=${names}
    CORE.setup_collectors
    ...  names=${names}
    CORE.start_collectors
    ...  names=${names}
Stop Ttitrace
    [Arguments]    ${names}=l2stream3_ttitrace
    CORE.stop_collectors
    ...  names=${names}
    CORE.collect_collectors
    ...  names=${names}
    CORE.teardown_collectors
    ...  names=${names}

Set CP Debug Log
    [Documentation]    This keyword is to set CP debug log on GNB_ASIK with the cmd
    ...     echo -e "[control]\nLoggingSeverity=trace" > /ffs/run/cp_runtime.ini
    ${cmd_open_cp_debug}    Set Variable    echo -e "[control]\nLoggingSeverity=trace" > /ffs/run/cp_runtime.ini
    ${connection_gnb}    SSH.Connect To    ${GNB_ASIK.ip}    ${GNB_ASIK.username}    ${GNB_ASIK.password}
    SSH.Execute    ${cmd_open_cp_debug}

Clear The AP Bip Log On Bord
    [Documentation]    This keyword is to 'rm -rf /tmp/*.pcap' on AP_ASIK and AP_ABIL bord.
    ${apbip_asik_connection}=    SSH.Connect To    ${AP_ASIK.ip}    ${AP_ASIK.username}    ${AP_ASIK.password}    alias=ClearAPBip_ASIK
    Set Suite Variable    ${apbip_asik_connection}
    ${apbip_asp_connection}=    SSH.Connect To    ${AP_ABIL.ip}    ${AP_ABIL.username}    ${AP_ABIL.password}
    ...    proxy=${apbip_asik_connection}    alias=APBIP_ASP
    Set Suite Variable    ${apbip_asp_connection}
    SSH.Execute    rm -rf /tmp/*.pcap    connection=${apbip_asik_connection}
    SSH.Execute    ls /tmp    connection=${apbip_asik_connection}
    SSH.Execute    rm -rf /tmp/*.pcap    connection=${apbip_asp_connection}
    SSH.Execute    ls /tmp    connection=${apbip_asp_connection}

Start AP Bip Log
    [Documentation]    This keyword is to start AP BIP log and save in /tmp/apL1L2.pcap on AP_ABIL bord.
    ...    ${APBIP_CMD}    tcpdump -i ethbp1 -s 65535 -w /tmp/apL1L2.pcap
    Run Keyword And Ignore Error    Clear The AP Bip Log On Bord
    SSH.Connect To    ${AP_ABIL.ip}    ${AP_ABIL.username}    ${AP_ABIL.password}
    ...    proxy=${apbip_asik_connection}    alias=APBIP_ASP_END
    Log To Console    start AP bip logs...
    Kill Process If Existed    apL1L2.pcap    ${APBIP_CMD}    APBIP_ASP
    SSH.Execute    command=bsh 1:2 fpga_rw wa 0xDF1D0398 0x3002000C    connection=${apbip_asik_connection}
    SSH.Execute    command=bsh 1:2 fpga_rw wa 0xDF1D0394 0x3001000C    connection=${apbip_asik_connection}
    SSH.Execute    command=dbgrrc mirror sport 22 dport 21 e b    connection=${apbip_asik_connection}
    SSH.Execute    command=dbgrrc mirror sport 23 dport 21 e b    connection=${apbip_asik_connection}
    SSH.Execute    command=dbgrrc mirror sport 25 dport 21 e b    connection=${apbip_asik_connection}
    SSH.Send Command    command=${APBIP_CMD}    connection=${apbip_asp_connection}
    Wait Until Keyword Succeeds    10s    2s    Verify Process Start Success    apL1L2.pcap    ${APBIP_CMD}    APBIP_ASP_END
    Log To Console    BIP ongoing

Stop AP Bip Log
    [Arguments]    ${log_dir}=${TEST_LOG_DIRECTORY}
    [Documentation]    This keyword is to stop AP BIP log and copy log to ${log_dir},
    ...     the default value is ${TEST_LOG_DIRECTORY}
    Log To Console    stop Bip by pkill
    Wait Until Keyword Succeeds    6s    2s    Kill And Verify Process Stop Success    apL1L2.pcap    ${APBIP_CMD}    ${apbip_asp_connection}
    SSH.Execute    bget 1:1 /tmp/apL1L2.pcap /tmp    connection=${apbip_asik_connection}
    SSH.Execute    ls -l /tmp    connection=${apbip_asp_connection}
    Log To Console    BIP stoped
    ${count}    Copy AP BIP Files And Return Count    ${log_dir}
    SSH.Execute    rm -rf /tmp/*.pcap    connection=${apbip_asik_connection}
    SSH.Execute    rm -rf /tmp/*.pcap    connection=${apbip_asp_connection}

Copy AP BIP Files And Return Count
    [Arguments]    ${log_dir}
    [Documentation]    This keyword is to copy AP BIP log to ${log_dir}
    Log To Console    copy bip files to ${log_dir}...
    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu scp ${AP_ASIK.username}@${AP_ASIK.ip}:/tmp/*.pcap* ${log_dir}
    ${count}    OperatingSystem.Count Items In Directory    ${log_dir}    pattern=*.pcap*
    [Return]    ${count}

Clear The AP L3L1 Log
    [Documentation]    This keyword is to 'rm -rf /tmp/apL3.pcap' on AP_ASIK.
    ${apl3l1_asik_connection}=    SSH.Connect To    ${AP_ASIK.ip}    ${AP_ASIK.username}    ${AP_ASIK.password}    alias=ClearAPl3l1_ASIK
    Set Suite Variable    ${apl3l1_asik_connection}
    SSH.Execute    rm -rf /tmp/apL3L1.pcap    connection=${apl3l1_asik_connection}
    SSH.Execute    ls /tmp    connection=${apl3l1_asik_connection}

Start AP L3L1 Pcap Log
    [Documentation]    This keyword is to start AP l3l1 log and save in /tmp/apL3L1.pcap on AP_ASIK bord.
    ...     ${APL3L1_CMD} = tcpdump -i etha01 -s 65535 -w /tmp/apL3L1.pcap
    ...    Examples:
    ...    | Start AP L3L1 Pcap Log |
    ...
    Clear The AP L3l1 Log
    Log To Console    start AP l3l1 logs...
    SSH.Send Command    command=${APL3L1_CMD}    connection=ClearAPl3l1_ASIK
    Log To Console    AP l3l1 log ongoing

Stop AP L3L1 Pcap Log
    [Arguments]    ${log_dir}=${TEST_LOG_DIRECTORY}
    [Documentation]    This keyword is to stop AP l3l1 log and copy log to ${log_dir},
    ...    the default value is ${TEST_LOG_DIRECTORY}
    ...
    ...    Examples:
    ...    | Stop AP L3L1 Pcap Log    ${output_dir} |
    ...
    Log To Console    stop AP l3l1 by pkill
    SSH.Connect To    ${AP_ASIK.ip}    ${AP_ASIK.username}    ${AP_ASIK.password}    alias=Stop_APl3l1
    Kill Process If Existed    apL3L1.pcap    ${APL3L1_CMD}    Stop_APl3l1
    Log To Console    l3l1 capture stoped
    ${res}    Copy AP L3l1 Files And Return Count    ${log_dir}
    Run Keyword If    '${res}'=='False'    Log To Console    'Seems apL3L1.pcap not existed'

Copy AP L3L1 Files And Return Count
    [Arguments]    ${log_dir}
    [Documentation]    This keyword is to copy AP L3L1 log to ${log_dir}
    Log To Console    copy AP l3l1 files to ${log_dir}...
    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu scp ${AP_ASIK.username}@${AP_ASIK.ip}:/tmp/apL3L1.pcap ${log_dir}
    ${res}    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${log_dir}/apL3L1.pcap
    [Return]    ${res}

Start X2 Pcap Log
    [Documentation]    This keyword is to start x2 pcap log and save in /ffs/run/logs/x2.pcap on GNB ASIK.
    ...    ${X2AP_CMD} = tcpdump -i any -s 2000 -w /ffs/run/logs/x2.pcap
    ...
    ...    Examples:
    ...    | Start X2 Pcap Log |
    ...
    Log To Console    Clear The X2 Pcap Log
    SSH.Connect To    ${GNB_ASIK.ip}    ${GNB_ASIK.username}    ${GNB_ASIK.password}    alias=X2PCAP_START
    SSH.Connect To    ${GNB_ASIK.ip}    ${GNB_ASIK.username}    ${GNB_ASIK.password}    alias=X2PCAP_STOP
    Run Keyword And Ignore Error    SSH.Execute    rm -rf /ffs/run/logs/x2.pcap    connection=X2PCAP_START
    SSH.Execute    ls /tmp    connection=X2PCAP_START
    Kill Process If Existed    x2.pcap     ${X2AP_CMD}    X2PCAP_START
    Log To Console    start x2 pcap logs...
    SSH.Send Command    command=${X2AP_CMD}    connection=X2PCAP_START
    Wait Until Keyword Succeeds    1min    2s    Verify Process Start Success    x2.pcap    ${X2AP_CMD}    X2PCAP_STOP
    Log To Console    x2 log ongoing

Stop X2 Pcap Log
    [Arguments]    ${log_dir}=${TEST_LOG_DIRECTORY}
    [Documentation]    This keyword is to stop x2 pcap log and copy log to ${log_dir},
    ...    the default value is ${TEST_LOG_DIRECTORY}
    ...
    ...    Examples:
    ...    | Stop X2 Pcap Log    ${output_dir} |
    ...
    Log To Console    stop x2 pcap log by pkill
    Wait Until Keyword Succeeds    6s    2s    Kill And Verify Process Stop Success    x2.pcap    ${X2AP_CMD}    X2PCAP_STOP
    Log To Console    x2 pcap log capture stoped
    ${res}    Copy X2 Pcap Files And Return Count    ${log_dir}
    Run Keyword If    '${res}'!='True'    Log To Console    'seems x2.pcap not existed'

Copy X2 Pcap Files And Return Count
    [Arguments]    ${log_dir}
    [Documentation]    This keyword is to copy x2 pcap log to ${log_dir}
    Log To Console    copy x2 pcap files to ${log_dir}...
    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu scp ${GNB_ASIK.username}@${GNB_ASIK.ip}:/ffs/run/logs/x2.pcap ${log_dir}
    ${res}    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${log_dir}/x2.pcap
    [Return]    ${res}

Start Gnb Cell Setup Log
    [Documentation]    This keyword is to start gnb Cell Setup Log and save in /ffs/run/logs/cellsetup_gnb.pcap on GNB ASIK.
    ...    ${GNBCELLSETUP_CMD}    tcpdump -i any -w /ffs/run/logs/cellsetup_gnb.pcap
    ...
    ...    Examples:
    ...    | Start Gnb Cell Setup Log |
    ...
    Log To Console    Clear The Gnb Cell Setup Log
    SSH.Connect To    ${GNB_ASIK.ip}    ${GNB_ASIK.username}    ${GNB_ASIK.password}    alias=ClearCell_ASIK
    SSH.Execute    rm -rf /ffs/run/logs/cellsetup_gnb.pcap    connection=ClearCell_ASIK
    SSH.Execute    ls /tmp    connection=ClearCell_ASIK
    Log To Console    start gnb Cell Setup Logs...
    SSH.Connect To    ${GNB_ASIK_SLAVE.ip}    ${GNB_ASIK_SLAVE.username}    ${GNB_ASIK_SLAVE.password}
    ...    proxy=ClearCell_ASIK    alias=ASIK_SLAVE
    SSH.Send Command    command=lxc-attach -n 0x1520    connection=ASIK_SLAVE
    SSH.Send Command    command=${GNBCELLSETUP_CMD}    connection=ASIK_SLAVE
    Log To Console    gnb Cell Setup log ongoing

Stop Gnb Cell Setup Log
    [Arguments]    ${log_dir}=${TEST_LOG_DIRECTORY}
    [Documentation]    This keyword is to stop gnb Cell Setup Log and copy log to ${log_dir},
    ...    the default value is ${test_log_directory}
    ...
    ...    Examples:
    ...    | Stop Gnb Cell Setup Log    ${output_dir} |
    ...
    Log To Console    stop gnb Cell Setup Log by pkill
    Kill Process If Existed    cellsetup_gnb.pcap    ${GNBCELLSETUP_CMD}    ASIK_SLAVE
    Log To Console    gnb Cell Setup Log capture stoped
    ${res}    Copy Cell Setup Pcap Files And Return Count    ${log_dir}
    Run Keyword If    '${res}'!='True'    Log To Console    'seems cellsetup_gnb.pcap not existed'

Copy Cell Setup Pcap Files And Return Count
    [Arguments]    ${log_dir}
    [Documentation]    This keyword is to copy gnb Cell Setup Log to ${log_dir}
    Log To Console    copy Cell Setup pcap files to ${log_dir}...
    ${cmd}=    Catenate    sshpass -p oZPS0POrRieRtu scp ${GNB_ASIK_SLAVE.username}@${GNB_ASIK_SLAVE.ip}:/ffs/run/logs/cellsetup_gnb.pcap
    ...    /ffs/run/logs/cellsetup_gnb.pcap
    OperatingSystem.Run    ${cmd}
    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu scp ${GNB_ASIK.username}@${GNB_ASIK.ip}:/ffs/run/logs/cellsetup_gnb.pcap ${log_dir}
    ${res}    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${log_dir}/cellsetup_gnb.pcap
    [Return]    ${res}

Collect Edaemon Egate Log
    ute_wtssim.Collect Edaemon Log Files
    ute_wtssim.Collect Egate Log Files
