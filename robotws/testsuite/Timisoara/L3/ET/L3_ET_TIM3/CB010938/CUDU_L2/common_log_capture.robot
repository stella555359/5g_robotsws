*** Settings ***
Documentation    Author: xiaping.zhang@nokia-sbell.com
...              \n Please do not edit the existing keywords in this file without testing.
...              \n list of available keywords in CORE.
...              \n https://taf-collectors-core.docs.taf.ute.nsn-rdnet.net/en/latest/interfaces/interface.html

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
    ${is_airphone}=    Check AP Exist
    Setup Connections    ${is_airphone}
    Set Suite Variable    ${FLAG_CATCH_SUITE_LOG}    ${True}
    FOR    ${log}    IN    @{log_name_list}
        ${log}    String.Convert To Lowercase    ${log}
        Run Keyword If    '${log}'=='btslog' and "${is_airphone}"=="${True}"    Start GNB AP Syslog    ${log_dir}
        Run Keyword If    '${log}'=='btslog' and "${is_airphone}"=="${False}"    Start GNB Syslog    ${log_dir}
        Run Keyword If    '${log}'=='emil'    Start Emil Log
        Run Keyword If    '${log}'=='tcpdump'    Start Tcpdump
        Run Keyword If    '${log}'=='tshark'    Start TSharklog
        Run Keyword If    '${log}'=='x2pcap'    Start X2 Pcap Log
        Run Keyword If    '${log}'=='apl3l1'    Start AP L3L1 Pcap Log
        Run Keyword If    '${log}'=='cellsetup'    Start Gnb Cell Setup Log
        Run Keyword If    '${log}'=='bip'    Start Gnb BIP Log
        Run Keyword If    '${log}'=='apbip'    Start AP Bip Log
        Run Keyword If    '${log}'=='ttitrace'    Start Ttitrace With Streaming Mode
        Run Keyword If    '${log}'=='sherpa'    Start Sherpa L2stream Log    ${L2STREAM_CONFIG}
    END

Check AP Exist
    ${mplane_ip}=    Get Mplane IP Of GNB
    ${is_airphone}=    Set Variable If    "${mplane_ip}"=="10.0.1.2"    ${True}    ${False}
    [Return]    ${is_airphone}

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
    #Setup Connections
    ${is_airphone}=    Check AP Exist
    Set Suite Variable    ${FLAG_CATCH_SUITE_LOG}    ${False}
    FOR    ${log}    IN    @{log_name_list}
        ${log}    String.Convert To Lowercase    ${log}
        Run Keyword If    '${log}'=='btslog' and "${is_airphone}"=="${True}"
        ...    Run Keyword And Ignore Error    Stop And Collect Syslog    log_dir=${log_dir}
        Run Keyword If    '${log}'=='btslog' and "${is_airphone}"=="${False}"
        ...    Run Keyword And Ignore Error    Stop And Collect GNB Syslog    log_dir=${log_dir}
        Run Keyword If    '${log}'=='emil'    Run Keyword And Ignore Error    Stop And Collect Emil Log    #log_dir=${log_dir}
        Run Keyword If    '${log}'=='tcpdump'    Run Keyword And Ignore Error    Stop Tcpdump    log_dir=${log_dir}
        Run Keyword If    '${log}'=='tshark'    Run Keyword And Ignore Error    Stop TSharklog    log_dir=${log_dir}
        Run Keyword If    '${log}'=='snapshot'    Run Keyword And Ignore Error    Save Coam SnapShot    log_dir=${log_dir}
        Run Keyword If    '${log}'=='pmcounter'    Run Keyword And Ignore Error    Collect PM Counters    log_dir=${log_dir}
        Run Keyword If    '${log}'=='x2pcap'    Run Keyword And Ignore Error    Stop X2 Pcap Log    log_dir=${log_dir}
        Run Keyword If    '${log}'=='apl3l1'    Run Keyword And Ignore Error    Stop AP L3L1 Pcap Log    log_dir=${log_dir}
        Run Keyword If    '${log}'=='sosreport'    Run Keyword And Ignore Error    Collect UTE SosReport    log_dir=${log_dir}
        Run Keyword If    '${log}'=='cellsetup'    Run Keyword And Ignore Error    Stop Gnb Cell Setup Log    log_dir=${log_dir}
        Run Keyword If    '${log}'=='bip'    Run Keyword And Ignore Error    Stop Gnb BIP Log    log_dir=${log_dir}
        Run Keyword If    '${log}'=='apbip'    Run Keyword And Ignore Error    Stop AP Bip Log    log_dir=${log_dir}
        Run Keyword If    '${log}'=='ttitrace'    Run Keyword And Ignore Error    Stop Ttitrace    log_dir=${log_dir}
        Run Keyword If    '${log}'=='sherpa'    Run Keyword And Ignore Error    Stop Sherpa L2stream Log    log_dir=${log_dir}
        Run Keyword If    '${log}'=='utefiles'    Run Keyword And Ignore Error    Collect UTE Files    log_dir=${log_dir}
        Run Keyword If    '${log}'=='egatelog'    Run Keyword And Ignore Error    Save Egate Log    ${log_dir}
        Run Keyword If    '${log}'=='resource'    Run Keyword And Ignore Error    Save CPRT Info Log    resource_usage    ${log_dir}
    END

Decode Logs
    [Arguments]    ${log_name_list}    ${log_dir}=${TEST_LOG_DIRECTORY}
    [Documentation]    This keyword is to stop logs.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | @{log_name_list} | Yes | log type list, right now  |
    ...
    ...    | *** Variables *** |
    ...    | @{LOG_NAME_LIST} | btslog | snapshot | tcpdump | tshark | pmcounter |
    ...    Examples:
    ...    | Decode Logs | @{log_name_list} |
    FOR    ${log}    IN    @{log_name_list}
        ${log}    String.Convert To Lowercase    ${log}
        Run Keyword If    '${log}'=='ttitrace'    Run Keyword And Ignore Error    Decode Ttitrace Log    log_dir=${log_dir}
        Run Keyword If    '${log}'=='sherpa'    Run Keyword And Ignore Error    Convert Pcap To Sherpa Csv    ${log_dir}
    END

Start BTSlog
    [Arguments]    ${name}=btslog    ${btslog_path}=/opt/btslog/btslog
    ...    ${btslog_launcher_path}=/opt/btslog/btslog_launcher    ${log_dir}=/tmp/btslog2
    [Documentation]    This keyword is to create btslog log collector on testvm.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${name} | No | log name. e.g. btslog |
    ...    | ${btslog_path} | No | path of the ‘btslog’ executable default value:”/opt/btslog/btslog” |
    ...    | ${btslog_launcher_path} | No | path of ‘btslog_launcher’ |
    ...    |  |  | executable default value:”/opt/btslog/btslog_launcher” |
    ...    | ${log_dir} | No | path from where to get btslog files default value: “/tmp/btslog2” |
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
    [Arguments]    ${name}=testVM_Tcpdump    ${options}=-v -i eth3
    [Documentation]    create tcpdump log collector on local testvm.
    ...    name: name of the collector. Ex: oamTcpdump
    ...    options: (optional) tcpdump options (except for “-w”), default: empty string
    ...    sudo_password: password for sudo
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
    ...    options: (optional) Path of tShark path executable, default value is “tShark”
    ...    To Collect Prisma Logs Value Is “prisma”
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
    [Arguments]    ${name}=gnb_pm_counters
    [Documentation]    Collects the pm counters files to the default path.
    ...    gnb_id: gnb_id default value:0
    ...    name: name of the collector. Ex: gnb_pm_counters
    &{webservice}=    Create Dictionary    host=${GNB_ASIK.ip}
    ...    user=${GNB_ASIK.username}
    ...    password=${GNB_ASIK.password}
    ...    port=443
    Create PM Collector    name=${name}    webservice=${webservice}
    CORE.Setup Collectors    names=${name}
    CORE.Collect Collectors    names=${name}    target_dir=${TEST_LOG_DIRECTORY}
    CORE.Teardown Collectors    names=${name}

Collect Coam SnapShot
    [Arguments]    ${name}=gnb_coam_snapShot
#   ...    ${coverage}=Full    ${force}=0    ${timeout}=480
    [Documentation]    Collects the snapShot files to the default path.
    ...    gnb_id: gnb_id default value:0
    ...    name: name of the collector. Ex: gnb_coam_snapShot
    &{webservice}=    Create Dictionary    host=${GNB_ASIK.ip}
    ...    user=${GNB_ASIK.username}
    ...    password=${GNB_ASIK.password}
    ...    port=443
#    Create Coam SnapShot Collector    name=${name}    webservice=${webservice}    coverage=${coverage}
#    ...    force=${force}    timeout=${timeout}
    CORE.Setup Collectors    names=${name}
    CORE.Collect Collectors    names=${name}    target_dir=${test_log_directory}
    CORE.Teardown Collectors    names=${name}

Save Coam SnapShot
    [Arguments]    ${log_dir}=${test_log_directory}    ${bts_host}=${GNB_ASIK.ip}
    ${coam_connection}    coam.Connect To    bts_host=${bts_host}
    coam.Get SnapShot    target_file_name=${log_dir}/snapShot.zip    coverage=Full    force=True    connection=${coam_connection}
    [Teardown]    coam.Teardown    ${coam_connection}

Get Today
    ${time}    DateTime.Get Current Date    result_format=datetime
    ${date} =    Convert Date    ${time}    exclude_millis=yes    date_format=%m.%d.%Y
    ${date}    String.Split String    ${date}    ${space}
    [Return]    ${date[0]}

Start GNB AP Syslog
    [Arguments]    ${log_dir}
    Run Keyword And Ignore Error    ute_syslog.Stop Syslog    alias=${GNB_SYSLOG.alias}
    Run Keyword And Ignore Error    ute_syslog.Stop Syslog    alias=${AP_SYSLOG.alias}
    Run Keyword And Ignore Error    ute_syslog.Start Syslog    file_limit=${GNB_SYSLOG.file_limit}    log_dir=${log_dir}
    ...    log_name=${GNB_SYSLOG.log_name}    ip=${GNB_SYSLOG.ip}    alias=${GNB_SYSLOG.alias}
    Run Keyword And Ignore Error    ute_syslog.Start Syslog    file_limit=${AP_SYSLOG.file_limit}    log_dir=${log_dir}
    ...    log_name=${AP_SYSLOG.log_name}    ip=${AP_SYSLOG.ip}    alias=${AP_SYSLOG.alias}

Stop And Collect Syslog
    [Arguments]    ${log_dir}
    ute_syslog.Collect Syslog Results    alias=${GNB_SYSLOG.alias}    unzip=False    destination=${log_dir}/Gnb_syslog.tar.gz
    ute_syslog.Collect Syslog Results    alias=${AP_SYSLOG.alias}    unzip=False    destination=${log_dir}/AP_syslog.tar.gz

Start GNB Syslog
    [Arguments]    ${log_dir}
    Run Keyword And Ignore Error    ute_syslog.Stop Syslog    alias=${GNB_SYSLOG.alias}
    ute_syslog.Start Syslog    file_limit=${GNB_SYSLOG.file_limit}    log_dir=${log_dir}
    ...    log_name=${GNB_SYSLOG.log_name}    ip=${GNB_SYSLOG.ip}    alias=${GNB_SYSLOG.alias}

Stop And Collect GNB Syslog
    [Arguments]    ${log_dir}
    Log To Console    Stop GNB Syslog...
    ute_syslog.Collect Syslog Results    alias=${GNB_SYSLOG.alias}    unzip=true    destination=${log_dir}/GNB_syslog
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    ls -t ${log_dir}/GNB_syslog | head -n 1
    Log To Console    ${log_dir}/GNB_syslog/${output}
    [Return]    ${log_dir}/GNB_syslog/${output}

Collect GNB AP SnapShot Via Aashell
    [Arguments]    ${log_dir}
    Collect GNB SnapShot Via AaShell    ${log_dir}
    Collect AP SnapShot Via AaShell    ${log_dir}

Collect GNB SnapShot Via AaShell
    [Arguments]    ${log_dir}    ${log_name}=snapShot_gnb.zip
    [Documentation]    collect GNB snapshot
    ...    Examples:
    ...    | Collect GNB SnapShot Via AaShell | /tmp |
    SSH.Connect_to          hostname=${GNB.ip}
    ...                     username=${GNB.username}
    ...                     password=${GNB.password}
    ...                     alias=connection_gnb_snapshot
    ${prompt}               Set variable      AaShell>
    SSH.Send command           telnet localhost 15007             connection=connection_gnb_snapshot
    SSH.Read output until      ${prompt}       timeout=60         connection=connection_gnb_snapshot
    SSH.Write input            log -c full -a -z ${log_name}\n    connection=connection_gnb_snapshot
    SSH.Read output until      ${prompt}       timeout=300        connection=connection_gnb_snapshot
    SSH.Write input            quit\n                             connection=connection_gnb_snapshot
    SSH.Await execution end                                       connection=connection_gnb_snapshot
    Run    mkdir -p ${log_dir}
    ${cp_cmd}=    Set Variable    scp ${GNB.username}@${GNB.ip}:${/}tmp${/}${log_name} ${log_dir}/${log_name}
    OperatingSystem.Run    sshpass -p ${GNB.password} ${cp_cmd}
    SSH.Disconnect         connection=connection_gnb_snapshot

Collect AP SnapShot Via AaShell
    [Arguments]    ${log_dir}
    Telnet.Open Connection    host=${AP.ip}    port=15007
    Telnet.Set Prompt    AaShell>
    Telnet.Set Timeout    300 seconds
    Telnet.Write    log -c full -a -z snapShot_ap.zip
    Telnet.Read Until    AaSysComUserDeregister succeed!
    Telnet.Close Connection
    OperatingSystem.Run    sshpass -p ${AP.password} scp toor4nsn@${AP.ip}:/tmp/snapShot_ap.zip ${log_dir}/snapShot_ap.zip

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
    [Documentation]    This keyword is to collect sosreport log
    ...    related link: https://confluence.ext.net.nokia.com/display/AirPhoneWTS
    ...    /AirPhone+Classical+-+Tools#AirPhoneClassicalTools-CollectinglogsandcapturetrafficwithsosReport.sh
    ...
    Run Keyword And Ignore Error    Execute Egate Command    sim_log_set flush
    ${command}    Catenate    sed -i \'s@LOG_DIR_ON_DEVICE=.*@LOG_DIR_ON_DEVICE="/tmp/sosreport"@g\'
    ...    ${wts_dir}/sosReport.cfg
    ${rc}    OperatingSystem.Run And Return Rc    ${command}
    Should Be Equal As Integers    ${rc}    0
    ${rc}    OperatingSystem.Run And Return Rc    rm -rf ${wts_dir}/SosReport*.tgz
    Should Be Equal As Integers    ${rc}    0
    ${rc}    OperatingSystem.Run And Return Rc
    ...    cd ${wts_dir}/ && bash -x ${wts_dir}/sosReport_ASIK_ASIL.sh > /dev/null 2>\&1
    ${rc}    ${output}    OperatingSystem.Run And Return Rc And Output    cp ${wts_dir}/SosReport*.tgz ${log_dir}/
    Should Be Equal As Integers    ${rc}    0
    ${rc}    ${output}    OperatingSystem.Run And Return Rc And Output    ls ${log_dir}/SosReport*.tgz
    Log To Console    sosReport log : ${output}

Collect all logs via log_collector.Sh
    [Arguments]    ${log_dir}
    Run And Return Rc And Output    chmod +x ${LOG_COLLECTOR_PATH}
    Run And Return Rc And Output    cd ${log_dir} && ${LOG_COLLECTOR_PATH}

Verify BIP Log Exist
    [Arguments]    ${ip}=${GNB.ip}
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${GNB.password} ssh ${GNB.username}@${ip} "ls -al /tmp/5GBipL2L1_filtering_off.pcap*"
    Should Be True    "${rc}"=="0"

Copy BIP Files And Return Count
    [Arguments]    ${path}    ${ip}=${GNB.ip}
    Log To Console    copy bip files to ${path}...
    Wait Until Keyword Succeeds    30 s    2 s    Verify Bip Log Exist    ${ip}
    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu scp ${GNB.username}@${ip}:/tmp/5GBipL2L1_filtering_off.pcap* ${path}
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
    ...    | ${l2stream_config_list} | Yes | sherpa log config list，defined in Common_setup_teardown.robot |
    ...
    ...    Examples:
    ...    | Start Sherpa L2stream Log | ${l2stream_config} |
    Run Keyword If    '${SW_BRANCH}'=='${EMPTY}'    Get Software Version
    ${gnb_eif_eth_num_on_control_pc}    ${gnb_eif_ip_addr_on_control_pc}=    Get ETH Info For GNB EIF Interface On Control PC
    Log To Console    Start L2Stream log...
    OperatingSystem.Run    sudo usermod -a -G sherpa ute
    Process.Start Process    sudo cap_net_raw,cap_net_admin\=eip ./Sherpa    shell=True    cwd=/opt/Nokia/Sherpa_5G_18/
    ${executor}=  Create Dictionary
    ...    host=192.168.255.1
    ...    user=Nemuadmin
    ...    password=nemuuser
    ...    port=443
    ...    release=${SW_BRANCH}
    TCPDUMP.Create Tcpdump Collector
    ...    name=tcpdump_sherpa
    ...    options=-i ${gnb_eif_eth_num_on_control_pc} udp and dst ${gnb_eif_ip_addr_on_control_pc} and dst port 5678
    ...    sudo_password=ute
    #L2STREAM3.Create Coam L2stream Collector
    L2STREAM3.Create Sbts L2stream Collector
    ...    name=${names}
    ...    webservice=${executor}
#    ...    vlan=1
    ...    destination_ip_addr=${gnb_eif_ip_addr_on_control_pc}
    ...    collector=tcpdump_sherpa
    ...    l2_stream_configuration=${l2stream_config}
    ...    dscp=10
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
    [Arguments]    ${is_airphone}=${True}
    Setup GNB Connection
    Run Keyword If    '${is_airphone}'=='${True}'    Setup AP Connection

Setup GNB Connection
    ${GNB_ASIK_CONNECTION}    SSH.Connect To    hostname=${GNB_ASIK.ip}    username=${GNB_ASIK.username}
    ...    password=${GNB_ASIK.password}    alias=${GNB_ASIK.connection}
    Set Suite Variable    ${GNB_ASIK_CONNECTION}

Setup AP Connection
    ${AP_ASIK_CONNECTION}    SSH.Connect To    hostname=${AP_ASIK.ip}    username=${AP_ASIK.username}
    ...    password=${AP_ASIK.password}    alias=${AP_ASIK.connection}
    Set Suite Variable    ${AP_ASIK_CONNECTION}

Teardown All Connections
    [Arguments]    ${is_airphone}=${True}
    SSH.Disconnect    connection=${GNB_ASIK_CONNECTION}
    Run Keyword If    '${is_airphone}'=='${True}'    SSH.Disconnect    connection=${AP_ASIK_CONNECTION}

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
    [Arguments]    ${part_proc_msg}    ${process_msg}    ${connection}    ${kill_para}=2
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
    ...    command=ps aux|grep '${part_proc_msg}'|awk '{print $2}'|xargs kill -${kill_para}    connection=${connection}

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
    [Arguments]    ${part_proc_msg}    ${process_msg}    ${connection}    ${kill_para}=2
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
    Kill Process If Existed    ${part_proc_msg}    ${process_msg}    ${connection}    ${kill_para}
    ${process}    SSH.Execute    command=ps aux|grep '${part_proc_msg}'    connection=${connection}
    ${check_status}    Run Keyword And Return Status     Should Contain    ${process_msg}    \\
    Run Keyword If    '${check_status}'=='${true}'    Should Not Match Regexp    ${process}    ${process_msg}
    ...    ELSE    Should Not Contain    ${process}    ${process_msg}

Kill And Verify Process Stop Success On ASOE asc-0b
    [Arguments]    ${process_msg}    ${connection}
    [Documentation]    This keyword is to verify if log capture process end success on ASOE asc-0b
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
    ${process}    SSH.Execute    command=bsh 1 "pkill -2 tcpdump"    connection=${connection}
    ${check_status}    Run Keyword And Return Status     Should Contain    ${process_msg}    \\
    Run Keyword If    '${check_status}'=='${true}'    Should Not Match Regexp    ${process}    ${process_msg}
    ...    ELSE    Should Not Contain    ${process}    ${process_msg}
    SSH.Execute    command=bsh 1 "mv /tmp/5GBipL2L1_filtering_off.pcap /ffs/run/logs"    connection=${connection}
    SSH.Execute    command=mv /ffs/run/logs/5GBipL2L1_filtering_off.pcap /tmp/  connection=${connection}

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
    Set Suite Variable    ${GNB_FRAME}    ${gnb_pos}
    [Return]    ${gnb_pos}

Execute Cmd On Fct
    [Arguments]    ${cmd}
    ${cmd_1}=    Set Variable    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 "${cmd}"
    ${ret}    ${output}=    OperatingSystem.Run And Return Rc And Output    ${cmd_1}
    Should Be True    "${ret}"=="0"

Modify BIP Script File To Adapt Frame
    [Arguments]    ${ip}=192.168.255.1
    ${gnb_hostname}=    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@${ip} hostname 2>/dev/null
    Run Keyword If    '${gnb_hostname}'=='fct-4a'    Modify BB Slot To Right
    Run Keyword If    '${gnb_hostname}'=='fct-0a'    Modify BB Slot To Left

Modify BB Slot To Right
    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh    BB_SLOT_1='true'    BB_SLOT_1='false'
    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh    BB_SLOT_5='false'    BB_SLOT_5='true'

Modify BB Slot To Left
    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh    BB_SLOT_1='false'    BB_SLOT_1='true'
    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh    BB_SLOT_5='true'    BB_SLOT_5='false'

Start Gnb And Airphone BIP Log On AP Loki Testline
    #Start GNB BIP Log By gnbMirroring
    Start GNB BIP By Admin Method
    Start Airphone BIP Log By gnbMirroring

Stop Gnb And Airphone BIP Log On AP Loki Testline
    [Arguments]   ${log_path}
    Stop Gnb BIP Log    ${log_path}/gnb_bip/
    Stop Airphone BIP Log    ${log_path}/ap_bip/

Start Gnb BIP Log
    [Arguments]    ${duration}=600
    Run Keyword If    "${SW_VERSION}"==""    Get Software Version
    Run Keyword If    "${L1_TYPE}"==""    Get L1Bypass Type
    Run Keyword If    "${FCT_BOARD_TYPE}"==""    Get Control Board Type    #${FCT_BOARD_TYPE}
    Run Keyword If    "${SW_VERSION}"=="SBTS00" and '${L1_TYPE}'=='FS'
    ...    Start GNB BIP By Admin Method    ${duration}
    ...    ELSE    Start Gnb BIP Log By lfs-nw_switch-mirror-tool    ${duration}

Stop Gnb BIP Log
    [Arguments]    ${log_dir}=${OUTPUT_DIR}
    Run Keyword If    "${SW_VERSION}"=="SBTS00" and '${L1_TYPE}'=='FS'
    ...    Stop Gnb BIP By Admin Method    ${log_dir}
    ...    ELSE    Stop Gnb BIP Log By lfs-nw_switch-mirror-tool    ${log_dir}

Start Gnb BIP Log By lfs-nw_switch-mirror-tool
    [Arguments]    ${duration}=infinite
    [Documentation]    This keyword is to start gnb bip log capture process on different testline types.
    ${ret}=    Run    ${SSH_CMD} ls -al /usr/bin/lfs-nw_switch-mirror-tool.sh
    Get L1Bypass Type    #${L1_TYPE}
    #Get Control Board Type    #${FCT_BOARD_TYPE}
    Get Base Band Boards Type    #@{ASP_BOARDS_TYPE}
    Run Keyword If    "${GNB_FRAME}"==""    Get GNB Position    #${GNB_FRAME}
    ${str_fsp_boards}=    Catenate    @{ASP_BOARDS_TYPE}
    Run Keyword If    '${FCT_BOARD_TYPE}'=='ASIB' and '${L1_TYPE}'=='L1b' and '${str_fsp_boards}'=='ABIO'
    ...    Start BIP Log By Shell Script    bip_ASIB_ABIO.sh
    ...    ELSE IF    '${FCT_BOARD_TYPE}'=='ASIB' and '${L1_TYPE}'=='L1b' and '${str_fsp_boards}'=='ABIO ABIO' and '${GNB_FRAME}'=='right_side'
    ...    Start BIP Log By Shell Script    bip_ASIB_2ABIO.sh
    ...    ELSE IF    '${FCT_BOARD_TYPE}'=='ASIK' and '${L1_TYPE}'=='FS' and '${str_fsp_boards}'=='ABIL ABIL ABIL' and '${GNB_FRAME}'=='left_side'
    ...    Start GNB BIP Log By gnbMirroring    L2_L1_BIP=true    CPRT_L2RT=true    BB_SLOT_1=true    BB_SLOT_2=true    BB_SLOT_5=false
    ...    NUMBER_OF_FILES=10    FILE_SIZE_MBYTES=100
    ...    ELSE IF    '${FCT_BOARD_TYPE}'=='ASIL' and '${L1_TYPE}'=='L1b' and '${str_fsp_boards}'=='ABIO'
    ...    Start BIP Log By Shell Script    bip_ASIL_ABIO.sh
    ...    ELSE IF    '${FCT_BOARD_TYPE}'=='ASIB' and '${L1_TYPE}'=='L1b' and '${str_fsp_boards}'=='ABIL ABIL ABIL'
    ...    Start BIP Log By Shell Script    bip_ASIB_3ABIL_l1bypass.sh
    ...    ELSE IF    '${FCT_BOARD_TYPE}'=='ASOE'    #CLOUD_5G_O_E_AP_LO_NSA_FS_ECPRI_MMWV_TDD
    ...    Start BIP Log By Shell Script    bip_ASOE_little_traffic.sh
    ...    ELSE IF    '${FCT_BOARD_TYPE}'=='ASIM'    #CLOUD_5G_O_E_AP_LO_NSA_FS_ECPRI_MMWV_TDD
    ...    Start BIP Log By Shell Script    gnbMirroring_ASIM_ABIO_FS.sh    shell_script_config=gnbMirroring_ASIM_ABIO_FSConfig.sh
    ...    ELSE
    ...    Start GNB BIP Log By gnbMirroring    ${duration}

Start Airphone BIP Log By gnbMirroring
    [Arguments]    ${duration}=infinite
    Download GNB Mirroring Tool
    Clear The BIP File Dir On FCT    ${AP.ip}
    Log To Console    INFO:Start GNB BIP log On ASIK or ASIB...
    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh    CAPTURING_TIME_SECONDS=[0-9]+    CAPTURING_TIME_SECONDS=${duration}
    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroring.sh    tcpdump_L2L1_bip    5GBipL2L1
    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh    NUMBER_OF_FILES=10    NUMBER_OF_FILES=2
    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh    FILE_SIZE_MBYTES=100    FILE_SIZE_MBYTES=50
    Modify BIP Script File To Adapt Frame    192.168.200.1
    OperatingSystem.Run    sshpass -p ${AP.password} scp ${SCRIPT_PATH}/BIP/* ${AP.username}@${AP.ip}:/ffs/run/config/scripts/
    ${exec_script}    Set Variable    gnbMirroring.sh
    OperatingSystem.Run    sshpass -p ${AP.password} ssh ${AP.username}@${AP.ip} chmod +x /ffs/run/config/scripts/${exec_script}
    SSH.Connect To    ${AP.ip}    ${AP.username}    ${AP.password}    alias=BIP_AP
    SSH.Send Command    command=sh /ffs/run/config/scripts/${exec_script} 1>/dev/null 2>&1 &    connection=BIP_AP
    Set Suite Variable    ${BIP_CMD}           tcpdump -i
    Wait Until Keyword Succeeds    1min    2s    Verify Process Start Success    5GBipL2L1_filtering_off    ${BIP_CMD}    BIP_AP
    Log To Console   INFO:bip start success...

Start GNB BIP Log By gnbMirroring
    [Arguments]    ${duration}=infinite    ${L2_L1_BIP}=true    ${CPRT_L2RT}=false    ${L2HI_TRSP}=false
    ...    ${BB_SLOT_1}=false    ${BB_SLOT_2}=false    ${BB_SLOT_3}=false
    ...    ${BB_SLOT_5}=true    ${BB_SLOT_6}=false    ${BB_SLOT_7}=false
    ...    ${NUMBER_OF_FILES}=2    ${FILE_SIZE_MBYTES}=50
    Download GNB Mirroring Tool
    Clear The BIP File Dir On FCT
    Log To Console    INFO:Start GNB BIP log By gnbMirroring...
    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh    CAPTURING_TIME_SECONDS=[0-9]+    CAPTURING_TIME_SECONDS=${duration}
    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroring.sh    tcpdump_L2L1_bip    5GBipL2L1
    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh    NUMBER_OF_FILES=10    NUMBER_OF_FILES=${NUMBER_OF_FILES}
    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh    FILE_SIZE_MBYTES=100    FILE_SIZE_MBYTES=${FILE_SIZE_MBYTES}
    Run Keyword If    "${L2_L1_BIP}"=="true"    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh
    ...    L2_L1_BIP='false'    L2_L1_BIP='true'
    ...    ELSE    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh    L2_L1_BIP='true'    L2_L1_BIP='false'
    Run Keyword If    "${CPRT_L2RT}"=="true"    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh
    ...    CPRT_MIRRORING='false'    CPRT_MIRRORING='true'
    ...    ELSE    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh    CPRT_MIRRORING='true'    CPRT_MIRRORING='false'
    Run Keyword If    "${L2HI_TRSP}"=="true"    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh
    ...    L2HI_MIRRORING='false'    L2HI_MIRRORING='true'
    ...    ELSE    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh    L2HI_MIRRORING='true'    L2HI_MIRRORING='false'
    #Modify BIP Script File To Adapt Frame
    Run Keyword If    "${BB_SLOT_1}"=="true"    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh
    ...    BB_SLOT_1='false'    BB_SLOT_1='true'
    ...    ELSE        Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh    BB_SLOT_1='true'    BB_SLOT_1='false'
    Run Keyword If    "${BB_SLOT_2}"=="true"    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh
    ...    BB_SLOT_2='false'    BB_SLOT_2='true'
    ...    ELSE        Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh    BB_SLOT_2='true'    BB_SLOT_2='false'
    Run Keyword If    "${BB_SLOT_3}"=="true"    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh
    ...    BB_SLOT_3='false'    BB_SLOT_3='true'
    ...    ELSE        Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh    BB_SLOT_3='true'    BB_SLOT_3='false'
    Run Keyword If    "${BB_SLOT_5}"=="true"    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh
    ...    BB_SLOT_5='false'    BB_SLOT_5='true'
    ...    ELSE        Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh    BB_SLOT_5='true'    BB_SLOT_5='false'
    Run Keyword If    "${BB_SLOT_6}"=="true"    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh
    ...    BB_SLOT_6='false'    BB_SLOT_6='true'
    ...    ELSE        Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh    BB_SLOT_6='true'    BB_SLOT_6='false'
    Run Keyword If    "${BB_SLOT_7}"=="true"    Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh
    ...    BB_SLOT_7='false'    BB_SLOT_7='true'
    ...    ELSE        Modify File Parameter    ${SCRIPT_PATH}/BIP/gnbMirroringConfig.sh    BB_SLOT_7='true'    BB_SLOT_7='false'
    OperatingSystem.Run    sshpass -p ${GNB.password} scp ${SCRIPT_PATH}/BIP/* ${GNB.username}@${GNB.ip}:/ffs/run/config/scripts/
    ${exec_script}    Set Variable    gnbMirroring.sh
    OperatingSystem.Run    sshpass -p ${GNB.password} ssh ${GNB.username}@${GNB.ip} chmod +x /ffs/run/config/scripts/${exec_script}
    SSH.Connect To    ${GNB.ip}    ${GNB.username}    ${GNB.password}    alias=BIP_GNB
    SSH.Send Command    command=sh /ffs/run/config/scripts/${exec_script} 1>/dev/null 2>&1 &    connection=BIP_GNB
    Set Suite Variable    ${BIP_CMD}           tcpdump -i
    Wait Until Keyword Succeeds    1min    2s    Verify Process Start Success    5GBipL2L1_filtering_off    ${BIP_CMD}    BIP_GNB
    Log To Console   INFO:bip start success...

Start BIP Log By Shell Script
    [Arguments]    ${shell_script}    ${shell_script_path}=${SCRIPT_PATH}/shell/    ${shell_script_config}=None
    [Documentation]    user provide shell script
    ...    GNB_ASIB_1ABIO_L1Bypass:    bip_ASIB_ABIO.sh
    ...    GNB_ASIB_2ABIO_L1Bypass:    bip_ASIB_2ABIO.sh
    ...    GNB_ASIL_1ABIO_L1Bypass:    bip_ASIL_ABIO.sh
    Clear The BIP File Dir On FCT
    Log To Console    INFO:Start GNB BIP log...
    Modify File Parameter    ${shell_script_path}/${shell_script}    tcpdumpL2L1    5GBipL2L1    #gnb_mirroring
    Modify File Parameter    ${shell_script_path}/${shell_script}    tcpdump_L2L1_bip    5GBipL2L1    #shell scrip ASIM_ABIO
    Modify File Parameter    ${shell_script_path}/${shell_script}    -C 100    -C 50
    Modify File Parameter    ${shell_script_path}/${shell_script}    -W 20    -W 2
    OperatingSystem.Run
    ...    sshpass -p ${GNB.password} scp ${shell_script_path}/${shell_script} ${GNB.username}@${GNB.ip}:/ffs/run/config/scripts/
    Run Keyword If    "${shell_script_config}"!="None"    OperatingSystem.Run
    ...    sshpass -p ${GNB.password} scp ${shell_script_path}/${shell_script_config} ${GNB.username}@${GNB.ip}:/ffs/run/config/scripts/
    ${gnb_hostname}=    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 hostname 2>/dev/null
    ${slot_id}=    Set Variable If    '${gnb_hostname}'=='fct-4a'    5    1
    ${exec_script}    Set Variable If    "${shell_script_config}"=="None"    ${shell_script} ${slot_id}    ${shell_script}
    OperatingSystem.Run    sshpass -p ${GNB.password} ssh ${GNB.username}@${GNB.ip} chmod +x /ffs/run/config/scripts/${exec_script}
    SSH.Connect To    ${GNB.ip}    ${GNB.username}    ${GNB.password}    alias=BIP_GNB
    SSH.Send Command    command=sh /ffs/run/config/scripts/${exec_script} 1>/dev/null 2>&1 &    connection=BIP_GNB
    Set Suite Variable    ${BIP_CMD}           tcpdump -i
    Wait Until Keyword Succeeds    1min    2s    Verify Process Start Success    5GBipL2L1_filtering_off    ${BIP_CMD}    BIP_GNB
    Log To Console   INFO:bip start success...

Stop Gnb BIP Log By lfs-nw_switch-mirror-tool
    [Arguments]    ${log_dir}=${OUTPUT_DIR}
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
    Run Keyword If    '${FCT_BOARD_TYPE}'=='ASOE'
    ...    Stop BIP Log On ASOE asc-0b    ${log_dir}
    ...    ELSE    Stop BIP Log On GNB FCT    ${log_dir}


Stop BIP Log On GNB FCT
    [Arguments]    ${log_dir}=${OUTPUT_DIR}
    Log To Console    INFO:Stop GNB BIP log...
    ${ret}=    Run Keyword And Return Status    Wait Until Keyword Succeeds    6s    2s    Kill And Verify Process Stop Success
    ...    5GBipL2L1_filtering_off    ${BIP_CMD}    BIP_GNB
    run keyword if    "${ret}"=="False"    Wait Until Keyword Succeeds    6s    2s    Kill And Verify Process Stop Success
   ...    5GBipL2L1_filtering_off    ${BIP_CMD}    BIP_GNB    kill_para=9
    Collect BIP Log From FCT By lfs-nw_switch-mirror-tool    ${log_dir}

Stop BIP Log On ASOE asc-0b
    [Arguments]    ${log_dir}=${OUTPUT_DIR}
    Log To Console    INFO:Stop GNB BIP log...
    Wait Until Keyword Succeeds    6s    2s    Kill And Verify Process Stop Success On ASOE asc-0b    ${BIP_CMD}
    ...    BIP_GNB
    Collect BIP Log From FCT By lfs-nw_switch-mirror-tool    ${log_dir}

Collect BIP Log From FCT
    [Arguments]    ${log_dir}=${OUTPUT_DIR}
    ${bip_counts}=    Run Keyword And Return If    "${SW_VERSION}"=="SBTS00" and '${L1_TYPE}'=='FS' and '${FCT_BOARD_TYPE}'!='ASOE'
    ...    Collect BIP Log From FCT By lfs-nw_switch-mirror-tool    ${log_dir}
    ...    ELSE    Collect GNB BIP By Admin Method    ${log_dir}
    [Return]    ${bip_counts}

Collect BIP Log From FCT By lfs-nw_switch-mirror-tool
    [Arguments]    ${log_dir}=${OUTPUT_DIR}
    Run Keyword If    '${log_dir}'!='${SUITE_LOG_DIRECTORY}' or '${log_dir}'!='${TEST_LOG_DIRECTORY}'    Create Directory    ${log_dir}
    ${bip_counts}    Copy BIP Files And Return Count    ${log_dir}
    Log To Console   INFO:bip end success...
    [Return]    ${bip_counts}

Start GNB BIP By Admin Method
    [Arguments]    ${mirroring_time}=600    ${interface}=L1-L2    ${destination}=Local
    [Documentation]    this keyword is used for catch gnb bip log on webem:Diagnosis -> Mirroring -> Interface Mirroring
    ...    now it doesn't support ASOE. Note: L2-PS,L2lo <-> L1,L2hi <-> L2lo,L2hi doesn't have message with L2-PS and L1,
    ...    | Input Parameters | Man. | Description |
    ...    | ${interface} | No | bip type: L1-L2/L2Hi-L2Lo,for l1bypss testine, choose L2Hi-L2Lo |
    ...    | ${destination} | No | Local/Remote |
    ...    | ${mirroring_time} | No | 0~2147483647 |
    #Run Keyword And Ignore Error    Stop Gnb BIP By Admin Method
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 rm -rf /tmp/CCSPacketCapture/*
    COAM.Setup Admin    timeout=120
    COAM.Interface mirroring    interface=${interface}    destination=${destination}    mirroring_time=${mirroring_time}    operation=Start
    [Teardown]    COAM.Teardown

Collect GNB BIP By Admin Method
    [Arguments]    ${log_path}=${OUTPUT_DIR}
    Run    mkdir -p ${log_path}
    Run Keyword And Ignore Error    Run    rm -rf ${log_path}/mirroring_L2L1*
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 ls -al /tmp/CCSPacketCapture
    Run    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.1:/tmp/CCSPacketCapture/* ${log_path}
    Run    ls -1 ${log_path}
    Run    mergecap -a -w ${log_path}/5GBipL2L1_filtering_off.pcap ${log_path}/mirroring_L2L1*
    ${bip_file}=    Set Variable    ${log_path}/5GBipL2L1_filtering_off.pcap
    OperatingSystem.File Should Exist    ${bip_file}
    Log To Console    bip log:${bip_file}
    [Return]    ${bip_file}

Stop Gnb BIP By Admin Method
    [Arguments]    ${log_path}=${OUTPUT_DIR}    ${interface}=L1-L2    ${destination}=Local    ${mirroring_time}=600
    COAM.Setup Admin    timeout=120
    COAM.Interface mirroring    interface=${interface}    destination=${destination}    mirroring_time=${mirroring_time}    operation=Stop
    Collect GNB BIP By Admin Method    ${log_path}
    [Teardown]    COAM.Teardown

Stop Airphone BIP Log
    [Arguments]    ${log_dir}
    Log To Console    INFO:Stop GNB BIP log...
    Wait Until Keyword Succeeds    6s    2s    Kill And Verify Process Stop Success    5GBipL2L1_filtering_off    ${BIP_CMD}    BIP_AP
    Run Keyword If    '${log_dir}'!='${SUITE_LOG_DIRECTORY}' or '${log_dir}'!='${TEST_LOG_DIRECTORY}'    Create Directory    ${log_dir}
    ${bip_counts}    Copy BIP Files And Return Count    ${log_dir}    ${AP.ip}
    Log To Console   INFO:bip end success...
    [Return]    ${bip_counts}

Enable BIP Port Map On Airphone
    [Documentation]    This keyword is used to enable bip port map on airphone
    ...    sport: source port, dport: destination port
    ...    13:sei port, DCI link to GNB, 21:1st ABIL L1 port, 29: 2nd ABIL L1 port, 37: 3nd ABIL L1 port
    ...    e: enable, b:both
    ute_fsmaccess.Execute Command On Wts    dbgrrc mirror sport 13 dport 6 e b
    ute_fsmaccess.Execute Command On Wts    dbgrrc mirror sport 21 dport 6 e b
    ute_fsmaccess.Execute Command On Wts    dbgrrc mirror sport 29 dport 6 e b
    ute_fsmaccess.Execute Command On Wts    dbgrrc mirror sport 37 dport 6 e b

Disable BIP Port Map On Airphone
    ute_fsmaccess.Execute Command On Wts    dbgrrc mirror sport 13 dport 6 d b
    ute_fsmaccess.Execute Command On Wts    dbgrrc mirror sport 21 dport 6 d b
    ute_fsmaccess.Execute Command On Wts    dbgrrc mirror sport 29 dport 6 d b
    ute_fsmaccess.Execute Command On Wts    dbgrrc mirror sport 37 dport 6 d b

Start BIP Log From Airphone Side On L1bypass Testline
    Setup Wts Fsm Access
    Enable BIP Port Map On Airphone
    ute_fsmaccess.Start Command On Wts    bsh 0:1 tcpdump -i pepbp1 -w /tmp/bip.pcap -vv

Stop BIP Log From Airphone Side On L1bypass Testline
    [Arguments]    ${log_dir}=${OUTPUT_DIR}
    Disable BIP Port Map On Airphone
    ute_fsmaccess.Execute Command On Wts    bsh 0:1 pkill -9 tcpdump
    ute_fsmaccess.Execute Command On Wts    bget 0:1 /tmp/bip.pcap /tmp/
    ute_fsmaccess.Get Wts File    /tmp/bip.pcap    ${log_dir}/5GBipL2L1_filtering_off.pcap0
    [Teardown]    ute_fsmaccess.Teardown Wts Fsm Access

Catch BIP Log From Airphone Side On L1bypass Testline
    [Arguments]    ${time}=10s
    Start BIP Log From Airphone Side On L1bypass Testline
    Sleep    ${time}
    Stop BIP Log From Airphone Side On L1bypass Testline

Download GNB Mirroring Tool
    [Arguments]    ${local_save_path}=${CURDIR}/GNB_mirroring_repo
    [Documentation]     This keyword will download GNB mirroring tool to replace existed.
    ...    Examples:
    ...    | Download GNB Mirroring Tool |
    OperatingSystem.Run    rm -rf ${local_save_path}
    OperatingSystem.Run    git clone ${GNB_MIRRORING_TOOL_LINK} ${local_save_path}
    #OperatingSystem.Run    cd ${local_save_path}; git reset --hard 67ca7e2d735946977e5faa0d956a33c554d49125
    OperatingSystem.Run    cp ${local_save_path}/gnbMirroring/gnbMirroringConfig.sh ${CURDIR}/scripts/BIP/
    OperatingSystem.Run    cp ${local_save_path}/gnbMirroring/gnbMirroring.sh ${CURDIR}/scripts/BIP/

Kill Process On Gnb
    [Arguments]    ${part_proc_msg}    ${process_msg}
    ${pids}    OperatingSystem.Run
    ...    sshpass -p ${GNB.password} ssh ${GNB.username}@${GNB.ip} ps aux|grep ${part_proc_msg}|awk '{print $2}'
    OperatingSystem.Run    sshpass -p ${GNB.password} ssh ${GNB.username}@${GNB.ip} kill -2 ${pids}
    Verify Process Is Not Running On Gnb    ${part_proc_msg}    ${process_msg}

Clear The BIP File Dir On FCT
    [Arguments]   ${ip}=${GNB.ip}
    [Documentation]    This keyword is to clear bip files in gnb /ffs/run/config/scripts if exists.
    ...    As well as the log files /tmp/5GBipL2L1_filtering_off*
    ...    Notice: just available in keyword Start Gnb BIP Log
    ...
    ...    Examples:
    ...    | Clear The BIP File Dir On FCT |
    ...
    OperatingSystem.Run    sshpass -p ${GNB.password} ssh ${GNB.username}@${ip} rm /tmp/5GBipL2L1_filtering_off*
    OperatingSystem.Run    sshpass -p ${GNB.password} ssh ${GNB.username}@${ip} rm -rf /ffs/run/config/scripts
    OperatingSystem.Run    sshpass -p ${GNB.password} ssh ${GNB.username}@${ip} mkdir /ffs/run/config/scripts
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
    [Arguments]    ${band_id}=1    ${L2RT_id}=20
    [Documentation]    This keyword is to start gnb ttitrace.
    ...    [2021.11.19] add two variables
    ...     ${band_id} for cell on which board, ABIO, ABIL
    ...     ${L2RT_id} for the id for L2RT, as for ABIO, there are L2RT20 & L2RT21.
    ...
    ...    Examples:
    ...    | Start GNB TTI Trace | wait_time=5s |
    ...
    Log To Console    INFO:start tti trace on asp...
    ${cpu_id}=    Set Variable If    "${ASP_BOARD_TYPE}"=="ABIO"    0    1
    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 bsh ${band_id}:${cpu_id} rm -rf /var/eventsTrace/*
    ${cmd}=    Catenate    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 bsh ${band_id}:${cpu_id} ls -l /tmp/
    ...    2>/dev/null|grep -e ".*ram.*L2RT${L2RT_id}"|awk -F "node_" '{print $2}'|awk -F " " '{print $1}'
    ${ret}    ${output}=    OperatingSystem.Run And Return Rc And Output    ${cmd}
    ${container_id}=    Set Variable    ${output}
    Set Suite Variable    ${TTITRACE_START_CMD}    sh /opt/tools/ttiTrace/eventsCollect.sh
    ${ssh_connect}=    Set Variable    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1
    ${cmd}=    Set Variable     ${ssh_connect} bsh ${band_id}:${cpu_id} lxc-attach -n ${container_id} ${TTITRACE_START_CMD}
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

Setup Ttitrace
    [Arguments]    ${names}=l2stream3_ttitrace
    log to console    setup admin for ttitrace...
    Run Keyword If    '${SW_BRANCH}'=='${EMPTY}'    Get Software Version
    ${executor}=  Create Dictionary
    ...  host=192.168.255.1
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
    ...  release=${SW_BRANCH}
    Run Keyword If    "${NR_PHY_CELL_IDS}"=="[]"    Get PhysCellId Of GNB
    #${nr_phy_cell_ids}    Set Variable    [50, 51]
    ${localIpAddr}=    Get Mplane IP Of GNB    #10.0.1.2 for ute
    ${gnb_eif_eth_num_on_control_pc}    ${gnb_eif_ip_addr_on_control_pc}=    Get ETH Info For GNB EIF Interface On Control PC
    TCPDUMP.create tcpdump collector
    ...  name=tcpdump_ttitrace
    ...  options=-i ${gnb_eif_eth_num_on_control_pc} udp and dst ${gnb_eif_ip_addr_on_control_pc} and dst port 5678
    ...  sudo_password=ute
    L2STREAM3.create_sbts_l2stream_collector
    ...  name=${names}
    ...  destination_ip_addr=${gnb_eif_ip_addr_on_control_pc}
    ...  collector=tcpdump_ttitrace
    ...  l2_stream_configuration=${L2STREAM_COMPONENT_CONFIG}
    ...  webservice=${executor}
    ...  dscp=10
    L2STREAM3.Set Suite Alias
    ...  alias=${names}
    CORE.setup_collectors
    ...  names=${names}

Setup Ttitrace For Only L2PS
    [Arguments]    ${names}=l2stream3_ttitrace
    log to console    setup admin for ttitrace...
    Run Keyword If    '${SW_BRANCH}'=='${EMPTY}'    Get Software Version
    ${executor}=  Create Dictionary
    ...  host=192.168.255.1
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
    ...  release=${SW_BRANCH}
    Run Keyword If    "${NR_PHY_CELL_IDS}"=="[]"    Get PhysCellId Of GNB
    #${nr_phy_cell_ids}    Set Variable    [50, 51]
    ${localIpAddr}=    Get Mplane IP Of GNB    #10.0.1.2 for ute
    ${gnb_eif_eth_num_on_control_pc}    ${gnb_eif_ip_addr_on_control_pc}=    Get ETH Info For GNB EIF Interface On Control PC
    TCPDUMP.create tcpdump collector
    ...  name=tcpdump_ttitrace
    ...  options=-i ${gnb_eif_eth_num_on_control_pc} udp and dst ${gnb_eif_ip_addr_on_control_pc} and dst port 5678
    ...  sudo_password=ute
    L2STREAM3.create_sbts_l2stream_collector
    ...  name=${names}
    ...  destination_ip_addr=${gnb_eif_ip_addr_on_control_pc}
    ...  collector=tcpdump_ttitrace
    ...  l2_stream_configuration=${L2STREAM_COMPONENT_L2PS_CONFIG}
    ...  webservice=${executor}
    ...  dscp=10
    L2STREAM3.Set Suite Alias
    ...  alias=${names}
    CORE.setup_collectors
    ...  names=${names}

Begin Ttitrace
    [Arguments]    ${names}=l2stream3_ttitrace
    CORE.start_collectors
    ...  names=${names}
    log to console    finish admin process for ttitrace,start to catch ttitrace log...

End Ttitrace
    [Arguments]    ${names}=l2stream3_ttitrace    ${log_dir}=${OUTPUT_DIR}/ttitrace_streaming/
    log to console    stop catching ttitrace...
    CORE.stop_collectors
    ...  names=${names}
    CORE.collect_collectors
    ...  names=${names}    target_dir=${log_dir}

Teardown Ttitrace
    [Arguments]    ${names}=l2stream3_ttitrace
    CORE.teardown_collectors
    ...  names=${names}

Start Ttitrace With Streaming Mode
    [Arguments]    ${names}=l2stream3_ttitrace    ${host}=192.168.255.1
    [Documentation]    This keyword is used to start ttitrace with streaming mode.
    ...    examples 1: catch all cells
    ...    Start Ttitrace With Streaming Mode
    log to console    setup admin for ttitrace...
    Run Keyword If    '${SW_BRANCH}'=='${EMPTY}'    Get Software Version
    ${executor}=  Create Dictionary
    ...  host=${host}
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
    ...  release=${SW_BRANCH}
    Run Keyword If    "${NR_PHY_CELL_IDS}"=="[]"    Get PhysCellId Of GNB
    #${nr_phy_cell_ids}    Set Variable    [50, 51]
    ${localIpAddr}=    Get Mplane IP Of GNB    ${host}    #10.0.1.2 for ute
    ${gnb_eif_eth_num_on_control_pc}    ${gnb_eif_ip_addr_on_control_pc}=    Get ETH Info For GNB EIF Interface On Control PC
    ...    ${host}
    TCPDUMP.create tcpdump collector
    ...  name=tcpdump_ttitrace
    ...  options=-i ${gnb_eif_eth_num_on_control_pc} udp and dst ${gnb_eif_ip_addr_on_control_pc} and dst port 5678
    ...  sudo_password=ute
    L2STREAM3.create_sbts_l2stream_collector
    ...  name=${names}
    ...  destination_ip_addr=${gnb_eif_ip_addr_on_control_pc}
    ...  collector=tcpdump_ttitrace
    ...  l2_stream_configuration=${L2STREAM_COMPONENT_CONFIG}
    ...  webservice=${executor}
    ...  dscp=10
    L2STREAM3.Set Suite Alias
    ...  alias=${names}
    CORE.setup_collectors
    ...  names=${names}
    CORE.start_collectors
    ...  names=${names}
    log to console    finish admin process for ttitrace,start to catch ttitrace log...

Stop Ttitrace
    [Arguments]    ${names}=l2stream3_ttitrace    ${log_dir}=${OUTPUT_DIR}/ttitrace_streaming/
    log to console    stop catching ttitrace...
    CORE.stop_collectors
    ...  names=${names}
    CORE.collect_collectors
    ...  names=${names}    target_dir=${log_dir}
    CORE.teardown_collectors
    ...  names=${names}

Capture Convert Format Ttitrace With Streaming Mode
    [Arguments]    ${capture_time}    ${log_dir}=${TEST_LOG_DIRECTORY}/ttitrace_streaming/    ${filters}=${EMPTY}
    [Documentation]    This keyword is to capture convert format ttitrace log, it also can set filter
    common_Log_capture.Start Ttitrace With Streaming Mode
    Sleep    ${capture_time}    reason=capture ttitrace
    common_Log_capture.Stop Ttitrace    log_dir=${log_dir}
    common_Log_analyzer.Convert Ttitrace From Pcap To Excelcsv    ${log_dir}
    ${csv_files}    OperatingSystem.List Files In Directory    ${log_dir}    output_*.csv    ${True}
    FOR    ${index}    ${csv_file}    IN ENUMERATE    @{csv_files}
        ${format_file}    Replace String    ${csv_file}    .csv    _formated.csv
        Format Tti In Stream Mode    ${csv_file}    ${format_file}    ${filters}
    END
    Log To Console    Please Find ttitrace log in ${log_dir}

Capture Convert L2LOL2HI Ttitrace With Streaming Mode
    [Arguments]    ${capture_time}    ${log_dir}=${TEST_LOG_DIRECTORY}/ttitrace_streaming/
    [Documentation]    This keyword is to capture convert format ttitrace log, it also can set filter
    common_Log_capture.Start Ttitrace With Streaming Mode
    Sleep    ${capture_time}    reason=capture ttitrace
    common_Log_capture.Stop Ttitrace    log_dir=${log_dir}
    Convert Ttitrace From Pcap To Legacycsv    log_dir=${log_dir}

Stop Convert L2LOL2HI Ttitrace With Streaming Mode
    [Arguments]    ${log_dir}=${test_log_directory}/ttitrace_streaming/
    ...    ${names}=l2stream3_ttitrace
    [Documentation]    This keyword is to stop ttitrace log, it also can set filter
    common_Log_capture.Stop Ttitrace    ${names}    log_dir=${log_dir}
    Convert Ttitrace From Pcap To Legacycsv    log_dir=${log_dir}

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

Collect Edaemon Egate Log
    ute_wtssim.Collect Edaemon Log Files
    ute_wtssim.Collect Egate Log Files

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

#Start Gnb Cell Setup Log
#    ${gnb_hostname}=    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 hostname 2>/dev/null
#    ${slot_id}=    Set Variable If    '${gnb_hostname}'=='fct-4a'    5    1
#    Run Keyword If     '${slot_id}'=='1'
#    ...    Start Gnb Cell Setup Log On Left Or Right Frame    ip=192.168.253.17    container_id=0x1520
#    ...    cmd=tcpdump -i any -w /user/toor4nsn/cellsetup_gnb.pcap
#    Run Keyword If     '${slot_id}'=='5'
#    ...    Start Gnb Cell Setup Log On Left Or Right Frame    ip=192.168.253.33    container_id=0x2520
#    ...    cmd=tcpdump -i any -w /user/toor4nsn/cellsetup_gnb.pcap
#
#Start Gnb Cell Setup Log On Left Or Right Frame
#    [Arguments]    ${ip}=${GNB_ASIK_SLAVE.ip}    ${container_id}=0x1520    ${cmd}=${GNBCELLSETUP_CMD}
#    [Documentation]    This keyword is to start gnb Cell Setup Log and save in /ffs/run/logs/cellsetup_gnb.pcap on GNB ASIK.
#    ...    ${GNBCELLSETUP_CMD}    tcpdump -i any -w /ffs/run/logs/cellsetup_gnb.pcap
#    ...
#    ...    Examples:
#    ...    | Start Gnb Cell Setup Log |
#    ...
#    Log To Console    Clear The Gnb Cell Setup Log
#    SSH.Connect To    ${GNB_ASIK.ip}    ${GNB_ASIK.username}    ${GNB_ASIK.password}    alias=ClearCell_ASIK
#    SSH.Execute    rm -rf /ffs/run/logs/cellsetup_gnb.pcap    connection=ClearCell_ASIK
#    SSH.Execute    rm -rf /user/toor4nsn/cellsetup_gnb.pcap    connection=ClearCell_ASIK
#    SSH.Execute    ls /tmp    connection=ClearCell_ASIK
#    Log To Console    start gnb Cell Setup Logs...
#    SSH.Connect To    ${ip}    ${GNB_ASIK_SLAVE.username}    ${GNB_ASIK_SLAVE.password}
#    ...    proxy=ClearCell_ASIK    alias=ASIK_SLAVE
#    SSH.Send Command    command=lxc-attach -n ${container_id}    connection=ASIK_SLAVE
#    SSH.Send Command    command=${cmd}    connection=ASIK_SLAVE
#    Log To Console    gnb Cell Setup log ongoing

#Stop Gnb Cell Setup Log
#    [Arguments]    ${log_dir}=${TEST_LOG_DIRECTORY}
#    [Documentation]    This keyword is to stop gnb Cell Setup Log and copy log to ${log_dir},
#    ...    the default value is ${test_log_directory}
#    ...
#    ...    Examples:
#    ...    | Stop Gnb Cell Setup Log    ${output_dir} |
#    ...
#    Log To Console    stop gnb Cell Setup Log by pkill
#    Kill Process If Existed    cellsetup_gnb.pcap    ${GNBCELLSETUP_CMD}    ASIK_SLAVE
#    Log To Console    gnb Cell Setup Log capture stoped
#    SSH.Send Command    command=cp /user/toor4nsn/cellsetup_gnb.pcap /ffs/run/logs/cellsetup_gnb.pcap    connection=ASIK_SLAVE
#    ${res}    Copy Cell Setup Pcap Files And Return Count    ${log_dir}
#    Run Keyword If    '${res}'!='True'    Log To Console    'seems cellsetup_gnb.pcap not existed'

#Copy Cell Setup Pcap Files And Return Count
#    [Arguments]    ${log_dir}
#    [Documentation]    This keyword is to copy gnb Cell Setup Log to ${log_dir}
#    Log To Console    copy Cell Setup pcap files to ${log_dir}...
#    ${cmd}=    Catenate    sshpass -p oZPS0POrRieRtu scp ${GNB_ASIK_SLAVE.username}@${GNB_ASIK_SLAVE.ip}:/ffs/run/logs/cellsetup_gnb.pcap
#    ...    /ffs/run/logs/cellsetup_gnb.pcap
#    OperatingSystem.Run    ${cmd}
#    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu scp ${GNB_ASIK.username}@${GNB_ASIK.ip}:/ffs/run/logs/cellsetup_gnb.pcap ${log_dir}
#    ${res}    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${log_dir}/cellsetup_gnb.pcap
#    [Return]    ${res}

Start Gnb Wireshark Log
    [Arguments]    ${cmd}=${GNB_WIRESHARK_CMD}    ${duration}=infinite
    [Documentation]    This keyword is to start gnb wireshark log and save in /ffs/run/logs/wireshark_gnb.pcap on gnb fct,F1AP,E1AP,X2AP,NGAP.
    ...    ${GNBCELLSETUP_CMD}    tcpdump -i any -w /ffs/run/logs/wireshark_gnb.pcap
    ...    only support ASIB, ASIL, for ASIK, IP is slave board IP, left 192.168.253.16,192.168.253.17 right 192.168.253.32,192.168.253.33
    ...    Examples:
    ...    | Start Gnb Wireshark Log |
    ...
    Log To Console    Clear gnb wireshark log
    SSH.Connect To    ${GNB.ip}    ${GNB.username}    ${GNB.password}    alias=wireshark_gnb
    SSH.Execute    rm -rf /ffs/run/logs/wireshark_gnb.pcap    connection=wireshark_gnb
    Log To Console    Start gnb wireshark logs...
    Run Keyword If    "${duration}"=="infinite"    SSH.Send Command    command=${cmd}    connection=wireshark_gnb
    ...    ELSE    SSH.Send Command    command=timeout ${duration} ${cmd}    connection=wireshark_gnb
    Log To Console    gnb wireshark logs ongoing

Collect Gnb Wireshark Log
    [Arguments]    ${log_dir}=${TEST_LOG_DIRECTORY}
    SSH.Connect To    ${GNB.ip}    ${GNB.username}    ${GNB.password}    alias=wireshark_gnb
    OperatingSystem.Run    mkdir -p ${log_dir}
    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu scp ${GNB.username}@${GNB.ip}:/ffs/run/logs/wireshark_gnb.pcap ${log_dir}
    Sleep    10s
    ${res}    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${log_dir}/wireshark_gnb.pcap
    Run Keyword If    '${res}'!='True'    Log To Console    'seems wireshark_gnb.pcap not existed'
    [Return]    ${log_dir}/wireshark_gnb.pcap

Stop Gnb Wireshark Log
    [Arguments]    ${log_dir}=${TEST_LOG_DIRECTORY}
    [Documentation]    This keyword is to stop gnb wireshark Log and copy log to ${log_dir},
    ...    the default value is ${test_log_directory}
    ...
    ...    Examples:
    ...    | Gnb Wireshark Log    ${output_dir} |
    ...
    Log To Console    stop gnb wireshark log by pkill
    Kill Process If Existed    wireshark_gnb.pcap    ${GNB_WIRESHARK_CMD}    wireshark_gnb
    Log To Console    gnb wireshark log capture stoped
    ${log_path}=    Collect Gnb Wireshark Log    ${log_dir}
    [Return]    ${log_path}

Start Gnb Cell Setup Log
    Start Gnb Wireshark Log

Stop Gnb Cell Setup Log
    [Arguments]    ${log_dir}
    Stop Gnb Wireshark Log    ${log_dir}

Start Emil Container At First Time
#    [Arguments]    ${force_start}=${False}
    ${ret}=    Run Keyword And Return Status    Check Docker Started Healthy
    run keyword if    "${ret}"=="${False}"    Start Emil Container

Check Docker Started Healthy
    ${ret}=    OperatingSystem.Run    sudo docker ps|grep condor-worker-1
    Should Contain    ${ret}    healthy

Start Emil Container
    OperatingSystem.Run    sudo docker-compose -f ${EMIL_DOCKER_COMPOSE_FILE} kill; sudo rm -rf /home/sharedvolume
    OperatingSystem.Run    sudo mkdir /home/sharedvolume
    OperatingSystem.Run    sudo ln -s /home/sharedvolume /sharedvolume
    OperatingSystem.Run    sudo chown -R ute:ute /home/sharedvolume
    OperatingSystem.Run    mkdir -p /sharedvolume/condor
    #create docker by docker-compose.yml under current execuate dir
    #Run    cd ${CURDIR}; sudo docker-compose up -d
    ${ret}=    OperatingSystem.Run    sudo docker-compose -f ${EMIL_DOCKER_COMPOSE_FILE} up -d
    Log    ${ret}
    Wait Until Keyword Succeeds    300s    10s    Check Docker Started Healthy

Start Emil Log
    Run    sudo docker stop $(sudo docker ps -aq);sudo docker rm $(sudo docker ps -aq);sudo docker rmi $(sudo docker images -q)
    ${start_emil_time}=    Print Time    start emil log time
    ${start_emil_time}=    String.Replace String    ${start_emil_time}    ${SPACE}    T
    Set Suite Variable    ${start_emil_time}
    Run    sudo docker logs -t --since="${start_emil_time}" condor-worker-1 > ${OUTPUT_DIR}/docker_log_start.txt
    #Start Emil Container
    Start Emil Container At First Time
    ${mplane_ip}=    Get Mplane IP Of GNB
    Run    cp ${EMIL_START_CMD} ${OUTPUT_DIR}
    Run    sed -i s"/10.0.1.2/${mplane_ip}/" ${OUTPUT_DIR}/emil_start_cmd.txt
    ${cmd}=    OperatingSystem.Get File    ${OUTPUT_DIR}/emil_start_cmd.txt
    Log    ${cmd}
    Run    ${cmd}
    ${ret}=    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 netstat -an|grep 15067
    Should Contain    ${ret}    ESTABLISHED
    [Teardown]    Run    sudo docker logs -t --since="${start_emil_time}" condor-worker-1 > ${OUTPUT_DIR}/docker_log_start.txt

Stop And Collect Emil Log
#    [Arguments]    ${log_dir}=${OUTPUT_DIR}
    Stop Emil Log
    Collect Emil Log
    [Teardown]    Run    sudo docker logs -t --since="${start_emil_time}" condor-worker-1 > ${OUTPUT_DIR}/docker_log_stop.txt

Stop Emil Log
    ${ret}=    OperatingSystem.Run    curl -X DELETE http://172.21.0.11:10009/dataCollections/CPlane_Traces_5G-10.0.1.2-172.21.0.11
    Should Contain    ${ret}    <h1>Ok</h1>

Collect Emil Log
    [Arguments]    ${log_dir}=${OUTPUT_DIR}
    ${ret}=    OperatingSystem.Run    find /sharedvolume/condor |grep .5gm
    ${emil_files}=    String.Split To Lines    ${ret}
    OperatingSystem.Copy File    ${emil_files}[0]    ${log_dir}

Wait Until User Manually Delete Stop Case File
    OperatingSystem.Create File    ${STOP_CASE_FILE}
    Print Time    run "rm ${STOP_CASE_FILE}" to stop case...
    FOR    ${var}    IN RANGE    9999
        ${stop_flag}=    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${STOP_CASE_FILE}
        Sleep    2s
        Exit For Loop If    "${stop_flag}"=="${False}"
    END

Print Time
    [Arguments]    ${info}
    ${time}    Get Current Date    result_format=timestamp
    Log To Console    \n${time}:${info}
    [Return]    ${time}

Get CPRT Node Id
    Run Keyword If    "${FCT_BOARD_TYPE}"==""    Get Control Board Type
    ${query_cprt_node_on_asib}=    Set Variable    ls -l /tmp/|grep /ram/node_CPRT00|egrep -o 0x[0-9]{4}
    ${query_cprt_node_on_asik}=    Set Variable    bsh 0:1 "ls -l /tmp/|grep /ram/node_CPRT00|egrep -o 0x[0-9]{4}"
    ${cmd_query_cprt_node_id}=    Run Keyword If    "${FCT_BOARD_TYPE}"=="ASIB"    Set Variable    ${query_cprt_node_on_asib}
    ...    ELSE IF    "${FCT_BOARD_TYPE}"=="ASIK"    Set Variable    ${query_cprt_node_on_asik}
    ute_fsmaccess.Setup Enb Fsm Access
    ${cprt_node_id}=    ute_fsmaccess.Execute Command On Enb    ${cmd_query_cprt_node_id}
    ute_fsmaccess.Teardown Enb Fsm Access
    [Return]    ${cprt_node_id}

Save CPRT Info Log On ASIK
    [Arguments]    ${log_name}=cp_rt_all_info_0    ${save_log_path}=${OUTPUT_DIR}
    ${cprt_node_id}=    Get CPRT Node Id
    ute_fsmaccess.Setup Enb Fsm Access
    ute_fsmaccess.Execute Command On Enb    echo "getResourcesUsage -f ${log_name} -l @Cprt #${cprt_node_id}"|nc 0 15007
    ute_fsmaccess.Teardown Enb Fsm Access
    ${log_path}=    Get CPRT Info Log From GNB ASIK To PC    ${log_name}    ${save_log_path}
    Run    python ${CURDIR}/printL2LOResourceInfo.py ${log_path}>${save_log_path}/sort_${log_name}.json
    [Return]    ${save_log_path}/sort_${log_name}.json

Save CPRT Info Log On ASIB
    [Arguments]    ${log_name}=cp_rt_all_info_0    ${save_log_path}=${OUTPUT_DIR}
    ${cprt_node_id}=    Get CPRT Node Id
    ute_fsmaccess.Setup Enb Fsm Access
    ute_fsmaccess.Execute Command On Enb    echo "getResourcesUsage -f ${log_name} -l @Cprt #${cprt_node_id}"|nc 0 15007
    ${log_path}=    ute_fsmaccess.Get Enb File    ${CPRT_INFO_LOG_PATH}/${log_name}.txt    ${save_log_path}/${log_name}.json
    ute_fsmaccess.Teardown Enb Fsm Access
    Run    python ${CURDIR}/scripts/python/printL2LOResourceInfo.py ${log_path}>${save_log_path}/sort_${log_name}.json
    [Return]    ${save_log_path}/sort_${log_name}.json

Get CPRT Info Log From GNB ASIK To PC
    [Arguments]    ${log_name}=cp_rt_all_info_0    ${save_log_path}=${OUTPUT_DIR}
    ute_fsmaccess.Setup Enb Fsm Access
    ute_fsmaccess.Execute Command On Enb    bget 0:1 ${CPRT_INFO_LOG_PATH}/${log_name}.txt /tmp/
    ${log_path}=    ute_fsmaccess.Get Enb File    /tmp/${log_name}.txt    ${save_log_path}/${log_name}.json
    ute_fsmaccess.Teardown Enb Fsm Access
    [Return]    ${log_path}

Save CPRT Info Log
    [Arguments]    ${log_name}    ${save_log_path}=${OUTPUT_DIR}
    Run Keyword If    "${FCT_BOARD_TYPE}"==""    Get Control Board Type
    ${log_cprt_l2low}=    Run Keyword If    "${FCT_BOARD_TYPE}"=="ASIB"    Save CPRT Info Log On ASIB    ${log_name}    ${save_log_path}
    ...    ELSE IF    "${FCT_BOARD_TYPE}"=="ASIK"    Save CPRT Info Log On ASIK    ${log_name}    ${save_log_path}
            Run    python3 ${CURDIR}/scripts/python/appendToPerL2LOResourceUsageCsvsFolder.py ${log_cprt_l2low} ${OUTPUT_DIR}/L2LoParsedLog/
    [Return]    ${log_cprt_l2low}

Get Cell Throughput From Btslog
    [Arguments]    ${duration}=10s    ${log_dir}=${OUTPUT_DIR}
    ${savepoint}=    Capture Savepoint    alias=${GNB_SYSLOG.alias}
    Sleep    ${duration}
    Collect From Savepoint    savepoint=${savepoint}    destination_file=${log_dir}/target_syslog.txt    alias=${GNB_SYSLOG.alias}
    ${tp}=    Analyze_syslog.get_tp_from_syslog    ${log_dir}/target_syslog.txt
    [Return]    ${tp}

Check Cell Throughput Quality From Btslog
    [Arguments]    ${tp_list}    ${cell_id}    ${direction}    ${target_tp}    ${aver_ratio}=${0.95}    ${min_ratio}=${0.85}
    [Documentation]    Check Throughput Quality from keyword "Get Cell Throughput From Btslog"
    ...    | Input Parameters | Man. | Description |
    ...    | ${tp_list} | YES | return value from keyword "Get Throughput From Bts" |
    ...    | ${cell_id} | YES | cell id|
    ...    | ${direction} | YES | dl/ul|
    Should Be True    ${tp_list}[${direction}][${cell_id}][ave]>${target_tp}*${aver_ratio}    Syslog average TP is lower than Target
    Should Be True    ${tp_list}[${direction}][${cell_id}][min]>${target_tp}*${min_ratio}    Syslog min TP is lower than Target

CUDU_L2 Check DTXNACK Rate
    [Arguments]    ${log_id}=dtxnack    ${expect_rate}=0.1
    CUDU_L2 Check Rate    dlFdSchedData.ackNack    ["ACK", "NACK","DTX"]    ["NACK","DTX"]    ${log_id}    ${expect_rate}
    CUDU_L2 Check Rate    dlFdSchedData.speculativeDtxAckDtx    ["ACK", "NACK","DTX"]    ["NACK","DTX"]    ${log_id}    ${expect_rate}
    CUDU_L2 Check Rate    dlHarqRxDataArray.dtx    ["NON_DTX","DTX"]    ["DTX"]    ${log_id}    ${expect_rate}

CUDU_L2 Check UL DTXCRC Rate
    [Arguments]    ${log_id}    ${expect_rate}=0.1
    CUDU_L2 Check Rate    ulHarqRxData.crcResult    ["OK","NOK"]    ["NOK"]    ${log_id}    ${expect_rate}
    CUDU_L2 Check Rate    ulHarqRxData.dtx    ["NON_DTX","DTX"]    ["DTX"]    ${log_id}    ${expect_rate}

CUDU_L2 Check Rate
    [Arguments]    ${name}=dlFdSchedData.ackNack    ${total}=["ACK", "NACK","DTX"]    ${failed}=["NACK","DTX"]    ${log_id}=dtxnack
    ...    ${expect_rate}=0.1
    [Documentation]    This keyword is to check rate.
    ...    | Input Parameters | Man. | Description |
    ...    | name | Yes |the column title to check, default is dlFdSchedData.ackNack |
    ...    | total | Yes | all the status , default is ["ACK", "NACK","DTX"]|
    ...    | failed  | Yes | failed status, default is ["NACK","DTX"] |
    ...    Example:
    ...    | Check Rate | dlFdSchedData.ackNack | ["ACK", "NACK","DTX"] | ["NACK","DTX"] |
    ${total_number}    CUDU_L2 Get Total Number    ${name}    ${total}    ${log_id}
    ${failed_number}    CUDU_L2 Get Total Failed Number    ${name}    ${failed}    ${log_id}
    ${rate}    Evaluate    float(${failed_number})/(${total_number})
    Log To Console    \n${name} rate is ${rate}\n
    Should Be True    ${rate}<${expect_rate}

CUDU_L2 Get Total Number
    [Arguments]    ${name}=dlFdSchedData.ackNack    ${total}=["ACK", "NACK","DTX"]    ${log_id}=dtxnack
    ${sub_name}=    Get Substring    ${name}    0    2
    ${csv_file_name}=    Set Variable If    "${sub_name}"=="dl"    output_dl.csv    output_ul.csv
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}/${csv_file_name}    ${name}    ${total}    include    no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}

CUDU_L2 Get Total Failed Number
    [Arguments]    ${name}=dlFdSchedData.ackNack    ${failed}=["NACK","DTX"]    ${log_id}=dtxnack
    ${sub_name}=    Get Substring    ${name}    0    2
    ${csv_file_name}=    Set Variable If    "${sub_name}"=="dl"    output_dl.csv    output_ul.csv
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}/${csv_file_name}    ${name}     ${failed}    include    no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}

Check DTXNACK Rate From Ttitrace
    [Arguments]    ${duration}=2    ${log_id}=dtxnack
    CUDU_L2 Capture And Decode TTitrace    ${log_id}    ${duration}
    CUDU_L2 Check DTXNACK Rate    ${log_id}

Check UL And DL DTX From Ttitrace Quickly
    [Arguments]    ${log_id}    ${duration}
    [Documentation]    This keyword is used for catching ttitrace for multi times in one case,
    ...    user should use "Setup Ttitrace" and "Teardown Ttitrace" in the case.
    CUDU_L2 Capture And Decode TTitrace Quickly    ${log_id}    ${duration}
    CUDU_L2 Check DTXNACK Rate    ${log_id}
    CUDU_L2 Check UL DTXCRC Rate    ${log_id}

CUDU_L2 Capture And Decode TTitrace Quickly
    [Arguments]    ${log_id}=1    ${duration}=5
    [Documentation]    This keyword is used for catching ttitrace for multi times in one case,
    ...    user should use "Setup Ttitrace" and "Teardown Ttitrace" in the case.
    Begin Ttitrace
    Sleep    ${duration}s    reason=Wait for logs
    End Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}
    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}

CUDU_L2 Capture And Decode TTitrace
    [Arguments]    ${log_id}=1    ${duration}=5
    Start Ttitrace With Streaming Mode
    Sleep    ${duration}s    reason=Wait for logs
    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}
    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}

CUDU_L2 Verify Period Of Beam Or PCSI Report
    [Arguments]    ${cell_id}    ${log_dir}=${OUTPUT_DIR}    ${report_type}=pcsi    ${report_period}=16    ${csv_file}=output_ul.csv
    [Documentation]    This keyword is to check the period of the beam or PCSI report based on ttitrace log.
    ...    | Input Parameters | Man. | Description |
    ...    | cell_id | Yes |the cell's Physcial ID |
    ...    | log_dir | Yes |the directory of the ttitrace log |
    ...    | report_type | Yes |the report type, e.g. pcsi or beam |
    ...    | report_period  | Yes | the period info of the beam or PCSI report  |
    ...    | csv_file | Yes | the name of the csv file transformated from ttitrace log |
    ...    Example:
    ...    | CUDU_L2 Verify Period Of Beam Or PCSI Report | 52 | ${TEST_LOG_DIRECTORY}/ttitrace/ | no | 16 | output_ul.csv |
    Set Test Variable    ${test_cell_id}    ${cell_id}
    Set Test Variable    ${test_period}    ${report_period}
    Run Keyword If      '${report_type}'=='pcsi'    Set Test Variable    ${test_report_type}    15
    ...       ELSE          Set Test Variable    ${test_report_type}    255
    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_report_period.ini    ${csv_file}    ${log_dir}

Capture BIP Log By Admin Method
    [Arguments]    ${capture_time}    ${log_subdir}=bip/1
    [Documentation]    This keyword is to capture BIP log for a period time
    ...    Examples:
    ...    | ${bip_pcap_log}    Capture BIP Log By Admin Method    capture_time=8s     log_dir=${TEST_LOG_DIRECTORY}/BIP/1 |
    Start GNB BIP By Admin Method
    Sleep    ${capture_time}
    Stop Gnb BIP By Admin Method    log_path=${TEST_LOG_DIRECTORY}/${log_subdir}
    [Return]    ${TEST_LOG_DIRECTORY}/${log_subdir}/5GBipL2L1_filtering_off.pcap
