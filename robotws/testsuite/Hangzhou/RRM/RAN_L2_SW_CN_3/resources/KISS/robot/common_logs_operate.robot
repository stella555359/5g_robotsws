*** Settings ***
Documentation    Author: leo.y.wang@nokia-sbell.com
...              \n Please do not edit the existing keywords in this file without testing.
...              \n list of available keywords in CORE.
...              \n https://docs.taf.nsn-rdnet.net/taf.collectors.core/2.0.10/1/robot.collector_keywords/

Library     String
Library     BuiltIn
Library     OperatingSystem
Library     ute_syslog
Library     ute_wtssim
Library     taf.collectors.core    WITH NAME    CORE
Library     taf.collectors.tcpdump    WITH NAME    TCPDUMP
Library     taf.collectors.tshark    WITH NAME    TSHARK
Library     taf.collectors.l2stream3    WITH NAME    L2STREAM3
Library     taf.collectors.ttitrace_snapshot_airphone    WITH NAME    AP_COLLECT_TTITRACR
Library     taf.transport.ssh    WITH NAME    SSH
Library     taf.transport.ssh    WITH NAME    csn
Library    taf.sw.dcap.rd       WITH NAME    rd
Resource    base.robot
Resource    common_airphone.robot
Resource    common_gnb.robot
Resource    internal_logs_operate.robot
Variables     ../python/tak_log/log_directory.py
Library     taf.sbts.oam.coam.admin    WITH NAME   COAM
Library     taf.ul.gnb.bip.collection    WITH NAME   bip_collection

*** Variables ***
&{GNB_SYSLOG}        ip=192.168.255.126    file_limit=104857600    log_name=GNB_syslog_common
...                  tar_log_name=GNB_syslog_common.tar.gz    alias=GNB_syslog_common
&{AP_SYSLOG}         ip=192.168.200.126    file_limit=104857600    log_name=AP_syslog_common
...                  tar_log_name=AP_syslog_common.tar.gz     alias=AP_syslog_common
${TCPDUMP_NAME}      common_tcpdump
${APBIP_CMD}         tcpdump -i ethbp1 -s 65535 -w /tmp/apL1L2.pcap
${GNBL3_PCAP_CMD}    tcpdump -i any -w /tmp/gnbL3.pcap
${WTS_PCAP_CMD}      tcpdump -i any -w /tmp/wts.pcap
${GNB_LUA_SHARK_STORE_PATH}     /opt/luashark
${AP_LUA_SHARK_TOOL_LINK}       https://hzisoj70.china.nsn-net.net/artifactory/mnp5g-airphone-ci-gen-local/Airphone
${AP_LUA_SHARK_STORE_PATH}      /opt/luashark_ap
${GNB_MIRRORING_TOOL_LINK}      https://gitlabe2.ext.net.nokia.com/juhakang/tools.git
${SCRIPT_PATH}                  ${CURDIR}${/}scripts
${MAX_WAITTIME_SOSREPORT}       10min
${RESERVE_FILE}                 /opt/ute/reservation.json


*** Keywords ***
Start Collect Logs
    [Arguments]    ${log_name_list}=${LOG_NAME_LIST}    ${log_dir}=${TEST_LOG_DIRECTORY()}/All
    [Documentation]    This keyword is to start to capture logs.
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_name_list} | No | log type list, default is global Variables LOG_NAME_LIST  |
    ...    | ${log_dir} | No | log directory, default is global Variables TEST_LOG_DIRECTORY/All |
    ...    | *** Variables *** |
    ...    | @{LOG_NAME_LIST} | btslog | ap_syslog | tcpdump | tshark | bip | ap_bip | gnb_l3 | wts_pcap |
    ...    Examples:
    ...    | Start Collect Logs | ${log_name_list} | /tmp |
    OperatingSystem.create directory    ${log_dir}
    FOR    ${log}    IN    @{log_name_list}
        ${log}    String.Convert To Lowercase    ${log}
        Run Keyword If    '${log}'=='btslog'     Start GNB Syslog     ${log_dir}
        Run Keyword If    '${log}'=='ap_syslog'     Start AP Syslog    ${log_dir}
        Run Keyword If    '${log}'=='tcpdump'    Start Tcpdump    remote_info=${GNB}
        Run Keyword If    '${log}'=='tshark'     Start TShark Log
        Run Keyword If    '${log}'=='bip'        Start GNB BIP Log
        Run Keyword If    '${log}'=='ap_bip'     Start AP BIP Log
        Run Keyword If    '${log}'=='gnb_l3'     Start GNB L3 Pcap Log
        Run Keyword If    '${log}'=='wts_pcap'     Start WTS Pcap Log
    END

Stop Collect Logs
    [Arguments]    ${log_name_list}=${LOG_NAME_LIST}    ${log_dir}=${TEST_LOG_DIRECTORY()}/All
    [Documentation]    This keyword is to stop logs.
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_name_list} | No | log type list, default is global Variables LOG_NAME_LIST  |
    ...    | ${log_dir} | No | log directory, default is global Variables TEST_LOG_DIRECTORY |
    ...    | *** Variables *** |
    ...    | @{LOG_NAME_LIST} | btslog | ap_syslog | gnb_snapshot | ap_snapshot | tcpdump | tshark | egatelog | bip |
    ...                       ap_bip | gnb_l3 | sosreport | wts_pcap |
    ...    Examples:
    ...    | Stop Collect Logs | @{log_name_list} |
    FOR    ${log}    IN    @{log_name_list}
        ${log}    String.Convert To Lowercase    ${log}
        Run Keyword If    '${log}'=='btslog'    Run Keyword And Ignore Error    Stop Collect GNB Syslog
         ...               log_dir=${log_dir}
        Run Keyword If    '${log}'=='ap_syslog'    Run Keyword And Ignore Error    Stop Collect AP Syslog
         ...               log_dir=${log_dir}
        Run Keyword If    '${log}'=='tcpdump'   Run Keyword And Ignore Error    Stop Tcpdump
         ...               log_dir=${log_dir}
        Run Keyword If    '${log}'=='gnb_snapshot'    Run Keyword And Ignore Error    Collect GNB SnapShot
         ...               target_file_name=${log_dir}${/}gnb_comon_snapshot.zip
        Run Keyword If    '${log}'=='ap_snapshot'    Run Keyword And Ignore Error    Collect AP SnapShot Via AaShell
         ...               log_dir=${log_dir}
        Run Keyword If    '${log}'=='egatelog'    Run Keyword And Ignore Error    Collect Edaemon And Egate Log    ${log_dir}
        Run Keyword If    '${log}'=='tshark'    Run Keyword And Ignore Error    Stop TShark Log    log_dir=${log_dir}
        Run Keyword If    '${log}'=='bip'    Run Keyword And Ignore Error    Stop Gnb BIP Log    log_dir=${log_dir}
        Run Keyword If    '${log}'=='ap_bip'    Run Keyword And Ignore Error    Stop AP BIP Log    log_dir=${log_dir}
        Run Keyword If    '${log}'=='gnb_l3'    Run Keyword And Ignore Error    Stop GNB L3 Pcap Log    log_dir=${log_dir}
        Run Keyword If    '${log}'=='sosreport'    Run Keyword And Ignore Error    Collect WTS SosReport    log_dir=${log_dir}
        Run Keyword If    '${log}'=='wts_pcap'    Run Keyword And Ignore Error    Stop WTS Pcap Log    log_dir=${log_dir}
    END

Start GNB Syslog
    [Arguments]    ${log_dir}    ${alias}=${GNB_SYSLOG.alias}
    [Documentation]    This keyword is to start GNB Syslog
    ...    Examples:
    ...    | Start GNB Syslog | /tmp |
    ute_syslog.Start Syslog    file_limit=${GNB_SYSLOG.file_limit}    log_dir=${log_dir}
    ...    log_name=${GNB_SYSLOG.log_name}    ip=${GNB_SYSLOG.ip}    alias=${alias}

Stop Collect GNB Syslog
    [Arguments]    ${log_dir}    ${alias}=${GNB_SYSLOG.alias}
    [Documentation]    This keyword is to stop GNB Syslog
    ...    Examples:
    ...    | Stop Collect GNB Syslog | /tmp |
    ute_syslog.Collect Syslog Results    alias=${alias}    unzip=${False}
    ...                                  destination=${log_dir}${/}${GNB_SYSLOG.tar_log_name}

Start AP Syslog
    [Arguments]    ${log_dir}    ${alias}=${AP_SYSLOG.alias}
    [Documentation]    This keyword is to start AP Syslog
    ...    Examples:
    ...    | Start AP Syslog | /tmp |
    ute_syslog.Start Syslog    file_limit=${AP_SYSLOG.file_limit}    log_dir=${log_dir}
    ...    log_name=${AP_SYSLOG.log_name}    ip=${AP_SYSLOG.ip}    alias=${alias}

Stop Collect AP Syslog
    [Arguments]    ${log_dir}    ${alias}=${AP_SYSLOG.alias}
    [Documentation]    This keyword is to stop GNB Syslog
    ...    Examples:
    ...    | Stop Collect AP Syslog | /tmp |
    ute_syslog.Collect Syslog Results    alias=${alias}     unzip=${False}
    ...                                  destination=${log_dir}${/}${AP_SYSLOG.tar_log_name}

Start Collect GNB and AP Syslog in '${file_name}' File
    [Documentation]    This keyword is to start GNB and AP Syslog
    ...    Examples:
    ...    | Start Collect GNB and AP Syslog in 'syslog' File|
    ute_syslog.Start Syslog    file_limit=${GNB_SYSLOG.file_limit}    log_dir=${TEST_LOG_DIRECTORY()}/${file_name}
    ...    log_name=${file_name}_gnb    ip=${GNB_SYSLOG.ip}    alias=collect_gnb
    ute_syslog.Start Syslog    file_limit=${AP_SYSLOG.file_limit}    log_dir=${TEST_LOG_DIRECTORY()}//${file_name}
    ...    log_name=${file_name}_ap    ip=${AP_SYSLOG.ip}    alias=collect_ap

Stop Collect GNB and AP Syslog in '${file_name}' File
    [Documentation]    This keyword is to stop GNB and AP Syslog
    ...    Examples:
    ...    | Stop Collect GNB and AP Syslog in 'syslog' File |
    ute_syslog.Collect Syslog Results    alias=collect_gnb    unzip=${False}
    ...    destination=${TEST_LOG_DIRECTORY()}${/}${file_name}${/}${file_name}_gnb.tar.gz
    ute_syslog.Collect Syslog Results    alias=collect_ap    unzip=${False}
    ...    destination=${TEST_LOG_DIRECTORY()}${/}${file_name}${/}${file_name}_ap.tar.gz

Start Tcpdump
    [Arguments]    ${name}=${TCPDUMP_NAME}    ${options}=-v -i any    ${remote_info}=None
    [Documentation]    create tcpdump log collector on local/remote testvm.
    ...    | Input Parameters | Man. | Description |
    ...    | name: | Y | tcpdump file name, this name also will use as alias Ex: oamTcpdump |
    ...    | options: | Y | tcpdump options which excute ok by manual way |
    ...    Examples:
    ...    | Start Tcpdump | tcpdump |
    ...    | ${remote info} | Create Dictionary |  host=192.168.255.1 | user=toor4nsn | password=oZPS0POrRieRtu |
    ...    | Start Tcpdump  | remote_info=${remote info} | options=-w -i any -s 0 -v  |  name=${TCPDUMP_NAME}
    ...    | sleep  |  1 |
    ...    | stop tcpdump  | name=${TCPDUMP_NAME}    |

        ${w_file_path}=    Set Variable If    ${remote_info}==None    ${CURDIR}/${name}.pcap    /tmp/${name}.pcap
        ${tcpdump_cmd}=    Set Variable If    ${remote_info}==None    sudo tcpdump    tcpdump
        ${exist_w_para}=    Run Keyword And Return Status    Should Contain    ${options}    '-w '
        ${cmd}=    Set Variable If   ${exist_w_para}==${True}    ${tcpdump_cmd} ${options}    ${tcpdump_cmd} -w ${w_file_path} ${options}
        log    start tcpdump command is: ${cmd}
        nohup_bg_start_process     ${cmd}       ${remote info}   alias=${name}

Stop Tcpdump
    [Arguments]    ${name}=${TCPDUMP_NAME}    ${log_dir}=${test_log_directory()}
    [Documentation]    stop tcpdump log collector on local testvm.
    ...    Examples:
	...    | Start Tcpdump | tcpdump |
    ...    | Stop Tcpdump | tcpdump |
    nohup_bg_stop_process    alias=${name}    save_path=${log_dir}

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
    SSH.Read output until      ${prompt}       timeout=1500        connection=connection_gnb_snapshot
    SSH.Write input            quit\n                             connection=connection_gnb_snapshot
    SSH.Await execution end                                       connection=connection_gnb_snapshot
    ${cp_cmd}=    Set Variable    scp ${GNB_ASIK.username}@${GNB_ASIK.ip}:${/}tmp${/}${log_name} ${log_dir}/${log_name}
    OperatingSystem.Run    sshpass -p ${GNB_ASIK.password} ${cp_cmd}
    SSH.Disconnect         connection=connection_gnb_snapshot

Collect GNB SnapShot
    [Arguments]    ${target_file_name}=/tmp/snapshot   ${coverage}=Full   ${force}=${True}   ${timeout}=300
    ...            ${regexp_filter}=${None}   ${reason}=${None}   ${cells}=${None}   ${detailed_output}=${False}
    [Documentation]    collect GNB snapshot
    ...    Parameter ${target_file_name} Location where snapshot shall be saved
    ...    Parameter ${coverage} Full, Minor or HealthCheck (only for SRAN) snapshot scope.
    ...    defaults set to Full
    ...    Parameter ${force} True or False to force snapshot creation
    ...    Parameter ${timeout} Timeout for the operation. Note: CLI request for snapshot is
    ...    not cancelled after timeout. For cancel please call snapshot_cancel()
    ...    Parameter ${regexp_filter} optional, since SBTS18, Data “regExpFilter” will be
    ...    ignored if coverage is “HealthCheck”
    ...    Parameter ${reason}  reason for the operation
    ...    Parameter ${cells} list of str of network cell distnames (only for SRAN builds)
    ...    Parameter ${detailed_output} return full request response when True, defaults set to False.
    ...    Examples:
    ...    | Collect GNB SnapShot  | /tmp/snapshot |
    COAM.setup admin    bts_host=${GNB_ASIK.ip}   alias=coam_procedural
    Run Keyword If    '${cells}' != 'None'  COAM.Collect Snapshot    target_file_name=${target_file_name}
    ...                coverage=${coverage}     force=${force}
    ...                timeout=${timeout}      regexp_filter=${regexp_filter}     reason=${reason}
    ...                cells=${cells}     detailed_output=${detailed_output}     connection=coam_procedural
    Run Keyword If    '${cells}' == 'None'  COAM.Collect Snapshot    target_file_name=${target_file_name}
    ...                coverage=${coverage}     force=${force}
    ...                timeout=${timeout}      regexp_filter=${regexp_filter}     reason=${reason}
    ...                detailed_output=${detailed_output}     connection=coam_procedural
    [Teardown]    COAM.Teardown    coam_procedural

Collect AP SnapShot Via AaShell
    [Arguments]    ${log_dir}    ${log_name}=snapShot_ap.zip
    [Documentation]    collect AP snapshot
    ...    Examples:
    ...    | Collect AP SnapShot Via AaShell | /tmp |
    Execute Command On AaShell    ${AP_ASIK.ip}     log -c full -a -z ${log_name}    AaSysComUserDeregister succeed!
    ${cp_cmd}=    Set Variable    scp ${AP_ASIK.username}@${AP_ASIK.ip}:${/}tmp${/}${log_name} ${log_dir}/${log_name}
    OperatingSystem.Run    sshpass -p ${AP_ASIK.password} ${cp_cmd}

Collect Edaemon And Egate Log
    [Arguments]    ${log_dir}
    [Documentation]    Collect Edaemon and Egate Log
    ...    Examples:
    ...    | Collect Edaemon And Egate Log | /tmp |
    Airphone Collect Edaemon Log Files    ${log_dir}
    Airphone Collect Egate Log Files      ${log_dir}

Start GNB BIP Log
    [Arguments]    ${script_path}=${SCRIPT_PATH}/shell    ${duration}=infinite    ${bip_use_admin_api}=true
    [Documentation]    This keyword is to Start GNB BIP Log capture process.
    ...    Parameter ${duration} default value is infinite which means this process will never be stopped automatically.
    ...    To stop this process, keyword Stop GNB BIP Log need to be used.
    ...    When this parameter is set to a real number, such as 10, 20 which means 10s, 20s, this process will be stopped
    ...    The BIP Method is set only in Start GNB BIP Log and the same is automatically used in `Stop GNB BIP Log`
    ...    automatically after time expires, keyword Stop GNB BIP Log is not needed any more.
    ...    | Input Parameters | Man. | Description |
    ...    | ${script_path} | No | default ${CURDIR}/scripts/shell |
    ...    | ${duration} | No | duration bip log capture |
    ...    | ${bip_use_admin_api} | No | which method to be used for BIP capture |
    ...    Examples1:
    ...    | Start GNB BIP Log | duration=infinite |
    ...    | ${bip_counts} | Stop GNB BIP Log | ${output_dir} |
    ...    Examples2:
    ...    | Start GNB BIP Log | duration=10 |
    log    ${SW_VERSION}
    Set Suite Variable    ${bip_use_admin_api}
    Run Keyword If    '${bip_use_admin_api}'!='false'     _Start GNB BIP By Admin Method
    ...     ELSE    _start gnb bip with trace       ${duration}

Stop GNB BIP Log
    [Arguments]    ${log_dir}
    [Documentation]    This keyword is to stop bip log capture process started by keyword Start GNB BIP Log
    ...    when durarion=infinite(necessory). It also will copy bip log files to given log_dir and this keyword
    ...    will return the numer of bip files.
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_dir} | Yes | Directory where to put the bip logs in |
    ...    Examples:
    ...    | Start GNB BIP Log | duration=infinite |
    ...    | ${bip_counts} | Stop GNB BIP Log | ${output_dir} |
    Log    Stop GNB BIP Log...

    Run Keyword If    '${bip_use_admin_api}'!='false'     _Stop GNB BIP By Admin Method       ${log_dir}
    ...     ELSE    _stop gnb bip with trace       ${log_dir}


Capture GNB BIP Log
    [Arguments]    ${script_path}=${SCRIPT_PATH}/shell    ${duration}=infinite
    [Documentation]    This keyword is to Start GNB BIP Log capture process.
    ...    Parameter ${duration} default value is infinite which means this process will never be stopped automatically.
    ...    When this parameter is set to a real number, such as 10, 20 which means 10s, 20s, this process will be stopped
    ...    automatically after time expires, keyword Stop GNB BIP Log is not needed any more.
    ...    | Input Parameters | Man. | Description |
    ...    | ${script_path} | No | default ${CURDIR}/scripts/shell |
    ...    | ${duration} | No | duration bip log capture |
    ...    Examples1:
    ...    | Capture GNB BIP Log | duration=infinite |
    ...    Examples2:
    ...    | Capture GNB BIP Log | duration=10 |
        Start GNB BIP Log    ${script_path}    ${duration}

Get GNB BIP Log
    [Arguments]    ${log_dir}
    [Documentation]    This keyword is to get bip log, will return the numer of bip files.
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_dir} | Yes | Directory where to put the bip logs in |
    ...    Examples:
    ...    | ${bip_counts} | Get GNB BIP Log | ${log_dir} |
    Log    Get GNB BIP Log...
    Run Keyword If                '${log_dir}'!='${TEST_LOG_DIRECTORY()}'    Create Directory    ${log_dir}
    ${count}    _Copy BIP Files And Return Count    ${log_dir}
    [Return]    ${count}

Clear The AP BIP Log On Bord
    [Documentation]    This keyword is to 'rm -rf /tmp/*.pcap' on AP_ASIK and AP_ABIL bord.
    ...    Examples:
    ...    | Clear The AP BIP Log On Bord |
    ${apbip_asik_connection}=    SSH.Connect To    ${AP_ASIK.ip}    ${AP_ASIK.username}    ${AP_ASIK.password}    alias=ClearAPBip_ASIK
    ${apbip_asp_connection}=    SSH.Connect To    ${AP_ABIL_1.ip}    ${AP_ABIL_1.username}    ${AP_ABIL_1.password}
    ...    proxy=${apbip_asik_connection}    alias=APBIP_ASP
    SSH.Execute    rm -rf /tmp/*.pcap    connection=${apbip_asik_connection}
    SSH.Execute    ls /tmp    connection=${apbip_asik_connection}
    SSH.Execute    rm -rf /tmp/*.pcap    connection=${apbip_asp_connection}
    SSH.Execute    ls /tmp    connection=${apbip_asp_connection}
    SSH.Disconnect    connection=APBIP_ASP
    SSH.Disconnect    connection=ClearAPBip_ASIK

Start AP BIP Log
    [Documentation]    This keyword is to Start AP BIP Log and save in /tmp/apL1L2.pcap on AP_ABIL bord.
    ...    ${APBIP_CMD}    tcpdump -i ethbp1 -s 65535 -w /tmp/apL1L2.pcap
    ...    Examples:
    ...    | Start AP BIP Log |
    Run Keyword And Ignore Error    Clear The AP BIP Log On Bord
    ${apbip_asik_connection}=    SSH.Connect To    ${AP_ASIK.ip}    ${AP_ASIK.username}    ${AP_ASIK.password}    alias=APBip_ASIK_start
    SSH.Connect To    ${AP_ABIL_1.ip}    ${AP_ABIL_1.username}    ${AP_ABIL_1.password}
    ...    proxy=${apbip_asik_connection}    alias=APBIP_ASP_END
    ${apbip_asp_connection}=    SSH.Connect To    ${AP_ABIL_1.ip}    ${AP_ABIL_1.username}    ${AP_ABIL_1.password}
    ...    proxy=${apbip_asik_connection}    alias=APBIP_ASP
    Log To Console    Start AP BIP Logs...
    Kill Process If Existed    apL1L2.pcap    ${APBIP_CMD}    APBIP_ASP
    SSH.Execute    command=bsh 1:2 fpga_rw wa 0xDF1D0398 0x3002000C    connection=${apbip_asik_connection}
    SSH.Execute    command=bsh 1:2 fpga_rw wa 0xDF1D0394 0x3001000C    connection=${apbip_asik_connection}
    SSH.Execute    command=dbgrrc mirror sport 22 dport 21 e b    connection=${apbip_asik_connection}
    SSH.Execute    command=dbgrrc mirror sport 23 dport 21 e b    connection=${apbip_asik_connection}
    SSH.Execute    command=dbgrrc mirror sport 25 dport 21 e b    connection=${apbip_asik_connection}
    SSH.Send Command    command=${APBIP_CMD}    connection=${apbip_asp_connection}
    Wait Until Keyword Succeeds    10s    2s    Verify Process Start Success    apL1L2.pcap    ${APBIP_CMD}    APBIP_ASP_END
    SSH.Disconnect    connection=APBIP_ASP_END
    SSH.Disconnect    connection=APBIP_ASP
    SSH.Disconnect    connection=APBip_ASIK_start
    Log To Console    BIP ongoing

Stop AP BIP Log
    [Arguments]    ${log_dir}
    [Documentation]    This keyword is to Stop AP BIP Log and copy log to ${log_dir}
    ...    Examples:
    ...    | Stop AP BIP Log |
    Log To Console    stop Bip by pkill
    ${apbip_asik_connection}=    SSH.Connect To    ${AP_ASIK.ip}    ${AP_ASIK.username}    ${AP_ASIK.password}    alias=APBip_ASIK_start
    ${apbip_asp_connection}=    SSH.Connect To    ${AP_ABIL_1.ip}    ${AP_ABIL_1.username}    ${AP_ABIL_1.password}
    ...    proxy=${apbip_asik_connection}    alias=APBIP_ASP
    Wait Until Keyword Succeeds    6s    2s    Kill And Verify Process Stop Success    apL1L2.pcap    ${APBIP_CMD}    ${apbip_asp_connection}
    SSH.Execute    bget 1:1 /tmp/apL1L2.pcap /tmp    connection=${apbip_asik_connection}
    SSH.Execute    ls -l /tmp    connection=${apbip_asp_connection}
    Log To Console    BIP stoped
    ${count}    Copy AP BIP Files And Return Count    ${log_dir}
    SSH.Execute    rm -rf /tmp/*.pcap    connection=${apbip_asik_connection}
    SSH.Execute    rm -rf /tmp/*.pcap    connection=${apbip_asp_connection}
    SSH.Disconnect    connection=APBIP_ASP
    SSH.Disconnect    connection=APBip_ASIK_start

Copy AP BIP Files And Return Count
    [Arguments]    ${log_dir}
    [Documentation]    This keyword is to copy AP BIP log to ${log_dir}
    ...    Examples:
    ...    | Copy AP BIP Files And Return Count | /tmp/ |
    Log To Console    copy bip files to ${log_dir}...
    OperatingSystem.Run    sshpass -p ${AP_ASIK.password} scp ${AP_ASIK.username}@${AP_ASIK.ip}:/tmp/*.pcap* ${log_dir}
    ${count}    OperatingSystem.Count Items In Directory    ${log_dir}    pattern=*.pcap*
    [Return]    ${count}

Start TShark Log
    [Arguments]    ${name}=oamTShark    ${options}=-i eth1    ${sudo_password}=None
    [Documentation]    create tShark log collector on local testvm.
    ...    | Input Parameters | Man. | Description |
    ...    | name: | N | name of the collector. default: oamTShark |
    ...    | options: | N | (optional) Path of tShark path executable, default value is “tShark” |
    ...    | sudo_password: | N | password for sudo, default: None |
    ...    Examples:
    ...    | Start TShark Log | | |
    Run Keyword And Ignore Error    OperatingSystem.Run    pkill tShark
    TSHARK.Create TShark Collector    name=${name}    options=${options}    sudo_password=${sudo_password}
    TSHARK.Set Suite Alias    ${name}
    CORE.Setup Collectors    names=${name}
    CORE.Start Collectors    names=${name}

Stop TShark Log
    [Arguments]    ${log_dir}
    [Documentation]    This keyword is to stop tshark log.
    ...    Examples:
    ...    | Stop TShark Log | /tmp/ |
    CORE.Collect Collectors    names=oamTShark    target_dir=${log_dir}
    CORE.Teardown Collectors    names=oamTShark

Collect WTS SosReport
    [Arguments]    ${log_dir}
    [Documentation]    This keyword is to collect WTS sosReport
    ...    Examples:
    ...    | Collect WTS SosReport | /tmp/ |
    Run Keyword And Ignore Error    Airphone Set Log Flush
    ${command}    Catenate    sed -i \'s@LOG_DIR_ON_DEVICE=.*@LOG_DIR_ON_DEVICE="/tmp/sosreport"@g\'
    ...    ${WTS_DIR}/sosReport.cfg
    OperatingSystem.Run    ${command}
    OperatingSystem.Run    cd ${WTS_DIR}/ && ls ${WTS_DIR}/SosReport*.tgz
    OperatingSystem.Run    cd ${WTS_DIR}/ && rm ${WTS_DIR}/SosReport*.tgz
    OperatingSystem.Run    cd ${WTS_DIR}/ && ${WTS_DIR}/sosReport_ASIK_ASIL.sh > /dev/null 2>\&1
#    OperatingSystem.Run    cd ${log_dir}/ && ${WTS_DIR}/sosReport.sh -nr -c -s > /dev/null 2>\&1
    OperatingSystem.Run    ls ${WTS_DIR}/SosReport*.tgz
    OperatingSystem.Run    cp ${WTS_DIR}/SosReport*.tgz ${log_dir}/
    OperatingSystem.Run    cd ${log_dir}/ && ls ${log_dir}/SosReport*.tgz

Start Sos Report
    [Arguments]    ${loner_version}=D    ${phoner_version}=PH7    ${l1_mode}=fullstack
    [Documentation]    This keyword is to use script 'AP_Classical_Fullstack_startTestwithSosReport.sh'
    ...    to start capture Airphone SosReport log.
    ...    | Input Parameters | Man. | Description |
    ...    | ${loner_version} | No | define in sosReport.cfg. The default value is D |
    ...    | ${phoner_version} | No | define in sosReport.cfg. The default value is PH7 |
    ...    | ${l1_mode} | No | define in sosReport.cfg. The default value is fullstack |
    ...    Examples:
    ...    | Start Sos Report |  |
    ...    | Start Sos Report | l1_mode=l1bypass |
    OperatingSystem.Remove File    ${WTS_DIR}${/}SosReport*_iphy1.tgz
    ${start_sosreport_cmd}    Set Variable
    ...    .${/}AP_Classical_Fullstack_startTestwithSosReport.sh -nr -c -s -m\=${loner_version} -a\=${phoner_version} -l1\=${l1_mode}
    ${result}    Process.Start Process    ${start_sosreport_cmd}    shell=True    cwd=${WTS_DIR}
    ...    stdout=${TEMPDIR}/start_stdout.txt
    ${success_msg}    Set Variable    You can now start your tests in egate
    Wait Until Keyword Succeeds    1min    5s    _Check Suscess Msg Exist    ${TEMPDIR}${/}start_stdout.txt    ${success_msg}

Stop Sos Report
    [Arguments]    ${log_dir}
    [Documentation]    This keyword is to use script 'AP_Classical_Fullstack_stopTestwithSosReport.sh' to stop Sosreport
    ...     and copy the log to the specified directory.
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_dir} | Yes | the log path to restore sosreport log. |
    ...    Examples:
    ...    | Stop Sos Report | /tmp |
    ${stop_sosreport_cmd}    Set Variable    .${/}AP_Classical_Fullstack_stopTestwithSosReport.sh
    ${result}    Process.Start Process    ${stop_sosreport_cmd}    shell=True    cwd=${WTS_DIR}
    ...    stdout=${TEMPDIR}/stop_stdout.txt
    ${success_msg}    Set Variable    _iphy1.tgz created
    Wait Until Keyword Succeeds    ${MAX_WAITTIME_SOSREPORT}    10s    _Check Suscess Msg Exist    ${TEMPDIR}${/}stop_stdout.txt    ${success_msg}
    OperatingSystem.Copy Files    ${WTS_DIR}${/}SosReport*_iphy1.tgz    ${log_dir}

Start GNB L3 Pcap Log
    [Documentation]    This keyword is to start GNB l3 log and save in /tmp/gnbL3.pcap on GNB ASIK bord.
    ...    Examples:
    ...    | Start GNB L3 Pcap Log |
    ${asik_connection}=    SSH.Connect To    ${GNB_ASIK.ip}    ${GNB_ASIK.username}    ${GNB_ASIK.password}    alias=GNB_ASIK
    SSH.Execute    rm -rf /tmp/gnbL3.pcap    connection=${asik_connection}
    SSH.Execute    ls /tmp    connection=${asik_connection}
    SSH.Send Command    command=${GNBL3_PCAP_CMD}    connection=GNB_ASIK
    [Teardown]    SSH.Disconnect    connection=GNB_ASIK

Stop GNB L3 Pcap Log
    [Arguments]    ${log_dir}
    [Documentation]    This keyword is to stop GNB L3 log and copy log to log_dir
    ...    Examples:
    ...    | Stop GNB L3 Pcap Log | /tmp |
    ${asik_connection}=    SSH.Connect To    ${GNB_ASIK.ip}    ${GNB_ASIK.username}    ${GNB_ASIK.password}    alias=GNB_ASIK_STOP
    Kill Process If Existed    gnbL3.pcap    ${GNBL3_PCAP_CMD}    GNB_ASIK_STOP
    ${res}    _Copy GNB Files And Return Status    ${log_dir}
    Run Keyword If    '${res}'=='False'    Log    'Seems gnbL3.pcap not existed'
    [Teardown]    SSH.Disconnect    connection=GNB_ASIK_STOP

Start WTS Pcap Log
    [Documentation]    This keyword is to start WTS log and save in /tmp/wts.pcap on GNB ASIK bord.
    ...    Examples:
    ...    | Start WTS Pcap Log |
    SSH.Connect To    ${AP_ASIK.ip}    ${AP_ASIK.username}    ${AP_ASIK.password}    alias=WTS_PCAP_ASIK_START
    SSH.Execute    rm -rf /tmp/wts.pcap    connection=WTS_PCAP_ASIK_START
    SSH.Execute    ls /tmp    connection=WTS_PCAP_ASIK_START
    SSH.Send Command    command=${WTS_PCAP_CMD}    connection=WTS_PCAP_ASIK_START
    [Teardown]    SSH.Disconnect    connection=WTS_PCAP_ASIK_START

Stop WTS Pcap Log
    [Arguments]    ${log_dir}
    [Documentation]    This keyword is to stop WTS log and copy log to log_dir
    ...    Examples:
    ...    | Stop WTS Pcap Log | /tmp |
    SSH.Connect To    ${AP_ASIK.ip}    ${AP_ASIK.username}    ${AP_ASIK.password}    alias=WTS_PCAP_ASIK_STOP
    Kill Process If Existed    wts.pcap    ${WTS_PCAP_CMD}    WTS_PCAP_ASIK_STOP
    ${res}    _Copy WTS Files And Return Status    ${log_dir}
    Run Keyword If    '${res}'=='False'    Log    'Seems wts.pcap not existed'
    [Teardown]    SSH.Disconnect    connection=WTS_PCAP_ASIK_STOP

Set CP Debug Log
    [Documentation]    This keyword is to set CP debug log on GNB_ASIK with the cmd
    ...     echo -e "[control]\nLoggingSeverity=trace" > /ffs/run/cp_runtime.ini
    ...    Examples:
    ...    | Set CP Debug Log |
    ${cmd_open_cp_debug}    Set Variable    echo -e "[control]\nLoggingSeverity=trace" > /ffs/run/cp_runtime.ini
    ${connection_gnb}    SSH.Connect To    ${GNB_ASIK.ip}    ${GNB_ASIK.username}    ${GNB_ASIK.password}    alias=${GNB_ASIK.connection}
    SSH.Execute    ${cmd_open_cp_debug}    connection=${GNB_ASIK.connection}
    SSH.Disconnect    connection=${GNB_ASIK.connection}

Start AirPhone Ttitrace
    [Arguments]     ${ap_name}=ap_ttitrace
    ${airphone_asik}=    create dictionary    host=${AP_ASIK.ip}    user=${AP_ASIK.username}    password=${AP_ASIK.password}
    ${airphone_abil}=    create dictionary    host=${AP_ABIL_0.ip}    user=${AP_ABIL_0.username}      password=${AP_ABIL_0.password}
    ...    proxy=${airphone_asik}
    AP_COLLECT_TTITRACR.create_ttitrace_snapshot_airphone_collector    name=${ap_name}    executor=${airphone_abil}
    CORE.setup_collectors    names=${ap_name}
    CORE.start_collectors    names=${ap_name}
    CORE.Set Suite Alias     ${ap_name}

Stop AirPhone Ttitrace
    [Arguments]     ${ap_name}=ap_ttitrace     ${save_path}=${TEST_LOG_DIRECTORY()}
    CORE.stop_collectors    names=${ap_name}
    CORE.collect_collectors    names=${ap_name}      target_dir=${save_path}
    CORE.teardown_collectors    names=${ap_name}

Start GNB Ttitrace With Streaming Mode
    [Arguments]     ${lcr_cell_id}=All    ${up_sw}=L2Ps     ${name}=l2stream3
    [Documentation]    This keyword will collect gnb ttitrace log.
    ...    | Input Parameters | Man. | Description |
    ...    | ${lcr_cell_id} | No | lcr cell id, it can be like 1 or 1,2 or ALL. The default value is ALL. |
    ...    | ${up_sw}       | No | option for capture. Default value is "L2Ps". It can be "L2Ps", "L2Lo", "L2iPdcp", "L2HiRlc"  |
    ...    | ${name}        | No | It can be the same as alias. The default value is l2stream3 |
    ...    Examples(BTS should be Onair and UE attach and data transfer is started. ):
    ...    | Start GNB Ttitrace With Streaming Mode | lcr_cell_id=1,2  | name=myttitrace |
    ...    | ${pacp}=  |  Stop GNB Ttitrace With Streaming Mode  |  save_path=${TEST_LOG_DIRECTORY()} | name=myttitrace |
    ...    or
    ...    | Start GNB Ttitrace With Streaming Mode | | |
    ...    | ${pacp}=  |  Stop GNB Ttitrace With Streaming Mode  |  save_path=${TEST_LOG_DIRECTORY()} |
    ...    | Download Ttitrace Decode Tool  | | |
    ...    | Decoder Tttirace From Pcap To Csv  | pcap_path=${pacp} | output_path_with_tag=${TEST_LOG_DIRECTORY()}nsa_tti |
    @{sw_list}    String.Split String    ${SOFTWARE_INFO}    _
	&{asik_vm}=         Create Dictionary
	...    host=${GNB.ip}
	...    user=Nemuadmin
	...    password=nemuuser
	...    port=443
	...    release=${sw_list[0]}
	${scfc_on_gnb_now}=    common_gnb.Backup Scf     ${test_log_directory()}      scfc_for_tti.xml
	${lcr_cell_id}=     String.Convert To Upper Case       ${lcr_cell_id}
	${nr_phy_cell_ids}=    Run Keyword If     '${lcr_cell_id}'=='ALL'    _Get All PhysCellId In GNB    ${scfc_on_gnb_now}
	...    ELSE    _Get PhysCellId In GNB By LcrdId    ${scfc_on_gnb_now}    ${lcr_cell_id}
	${local_ip_addr}=    _Get localIpAddr Of GNB      ${scfc_on_gnb_now}
	${eth_port}    ${eth_ip}=      _Get EIF Info From Control PC
    ${l2_stream_config_1}=    Create Dictionary       nr_phy_cell_ids=${nr_phy_cell_ids}     up_sw=${up_sw}
    @{l2_stream_configuration}=    Create List    ${l2_stream_config_1}
	TCPDUMP.Create Tcpdump Collector
	...  name=tcpdump
	...  options=-i ${eth_port} udp and dst ${eth_ip} and dst port 5678
	...  sudo_password=ute
	L2STREAM3.Create Sbts L2stream Collector
	...  name=${name}
	...  destination_ip_addr=${eth_ip}
	...  collector=tcpdump
	...  l2_stream_configuration=${l2_stream_configuration}
	...  webservice=${asik_vm}
    ...  dscp=15
    L2STREAM3.Set Suite Alias    alias=${name}
    CORE.setup_collectors    names=${name}
    CORE.start_collectors    names=${name}
    [Teardown]    Run Keyword And Ignore Error    Run    rm ${scfc_on_gnb_now}

Stop GNB Ttitrace With Streaming Mode
    [Arguments]    ${save_path}=${TEST_LOG_DIRECTORY()}    ${name}=l2stream3
    [Documentation]    This keyword will stop collect gnb ttitrace log.
    ...    | Input Parameters | Man. | Description |
    ...    | ${save_path}   | No | ttitrace save path. The default value is ${TEST_LOG_DIRECTORY()}. |
    ...    | ${name}        | No | It should be the same as it set in 'Start GNB Ttitrace With Streaming Mode'. The default value is l2stream3 |
    ...    Example:
    ...    | Start GNB Ttitrace With Streaming Mode | | |
    ...    | some action | | |
    ...    | ${pacp}=  |  Stop GNB Ttitrace With Streaming Mode  |  save_path=${TEST_LOG_DIRECTORY()} |
    ...    | Download Ttitrace Decode Tool  | | |
    ...    | Decoder Tttirace From Pcap To Csv  | pcap_path=${pacp} | output_path_with_tag=${TEST_LOG_DIRECTORY()}nsa_tti |
    CORE.stop_collectors    names=${name}
    CORE.collect_collectors    names=${name}     target_dir=${save_path}
    CORE.teardown_collectors    names=${name}
	[Return]    ${save_path}/${name}/tcpdump/tcpdump.pcap

Download Ttitrace Decode Tool
    [Documentation]     Download Ttitrace decode tool and install it.
    ...    Examples:
    ...    | Download Ttitrace Decode Tool |
    ...    | Decoder Tttirace From Pcap To Csv | pcap_path=${pacp} | output_path_with_tag=/tmp/mytag |
    [Timeout]    300
    ${decode_tool_in_file_server}    _Download Ttitrace Decode Tool From File Server
    ${status}    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${decode_tool_in_file_server}
    ${decode_tool}   Run Keyword If    '${status}' != 'True'    _Download Ttitrace Decode Tool From WFT
    ...    ELSE     Set Variable    ${decode_tool_in_file_server}
    OperatingSystem.File Should Exist    ${decode_tool}
    OperatingSystem.Run     scp /opt/ute/python3/bin/python /opt/ute/python3/bin/python3
    ${rc}     ${output}=     OperatingSystem.Run and Return RC and Output     sudo dpkg -i ${decode_tool}
    Run Keyword If        '${rc}'!= '0'       Log      ${output}      	WARN
    OperatingSystem.Run     rm -rf ${decode_tool}
    update numpy

Download Luashark Tool
    [Documentation]     This keyword will download GNB and AP luashark tool if luashark.lua not exist.
    ...    Examples:
    ...    | Download Luashark Tool |
    ${status}    ${value}    Run Keyword And Ignore Error    OperatingSystem.File Should Not Exist    ${RESERVE_FILE}
    Run Keyword If    '${status}'=='PASS'    _Download GNB Luashark Tool
    ${status}    ${value}    Run Keyword And Ignore Error    OperatingSystem.File Should Not Exist    ${RESERVE_FILE}
    Run Keyword If    '${status}'=='PASS'    _Download AP Luashark Tool

Download GNB BIP
    [Arguments]    ${local_save_path}=/home/ute/kiss_files/GNB_BIP
    [Documentation]     This keyword will download GNB mirroring tool to replace existed.
    ...    Examples:
    ...    | Download GNB Mirroring Tool |
    OperatingSystem.Run    rm -rf ${local_save_path}
    OperatingSystem.Run    git clone ${GNB_MIRRORING_TOOL_LINK} ${local_save_path}
    Run Keyword And Ignore Error     Create Directory     ${SCRIPT_PATH}/shell
    OperatingSystem.Run    cp -rf ${local_save_path}/gnbMirroring/gnbMirroringConfig.sh ${SCRIPT_PATH}/shell/
    OperatingSystem.Run    cp -rf ${local_save_path}/gnbMirroring/gnbMirroring.sh ${SCRIPT_PATH}/shell/

DCAP start collect log
    [Documentation]     start Capture log by DCAP
    ...    | Input Parameters | Man. | Description |
    ...    | ${bts_host} | Yes | ie. "10.0.1.2" |
    ...    | ${bts_port} | No | default "443" |
    ...    | ${bts_username} | No | default "Nemuadmin" |
    ...    | ${bts_password} | No | ie. "nemuuser" |
    ...    | ${remote_host} | No | default "None" |
    ...    | ${remote_username} | No | default. "None" |
    ...    | ${remote_password} | No | default "None" |
    ...    | ${gnb_trace_profile} | No | default "None" |
    ...    | ${enb_trace_profile} | No | default "None" |
    ...    | ${bts_trace_profile} | No | default "None" |
    ...    | ${vdu_trace_profile} | No | default "None" |
    ...    | ${vcu_trace_profile} | No | default "None" |
    ...
    ...    Examples:
    ...    | ${trace_id}    |     DCAP start collect log  |  enb_trace_profile=dcap-lite-default |   bts_trace_profile=dcap-lite-default     |
    ...    | DCAP stop collect log   |     ${trace_id}    |
    ...    | ${trace_id}    |   DCAP start collect log  |  bts_host=192.168.100.129 | bts_password=Nokia@123  |
    ...    | DCAP stop collect log   |     ${trace_id}    |
    ...    | ...      vdu_trace_profile=dcap-lite-default |   vcu_trace_profile=dcap-lite-default     |
    [Arguments]      ${bts_host}=10.0.1.2     ${bts_port}=443      ${bts_username}=Nemuadmin     ${bts_password}=nemuuser
    ...    ${remote_host}=${None}     ${remote_username}=${None}     ${remote_password}=${None}
    ...    ${gnb_trace_profile}=${None}    ${enb_trace_profile}=${None}    ${bts_trace_profile}=${None}
    ...    ${vdu_trace_profile}=${None}    ${vcu_trace_profile}=${None}
    ...    ${duration}=1
    Run Keyword And Ignore Error     Run    DCAP_Basic_controller start
    ${dcap_ip}     set variable if    ${remote_host}==${None}      127.0.0.1       ${remote_host}
    Wait Until Keyword Succeeds    60    10    rd.connect_to     host=${dcap_ip}      port=9443     rd_version=dcapv3    secure=${True}
    &{bts_info}     create dictionary    host=${bts_host}    port=${bts_port}
    ...    username=${bts_username}     password=${bts_password}
    ${output}     rd.start_trace    tag=ta_trace      duration=${duration}     bts=${bts_info}
    ...           gnb_trace_profile=${gnb_trace_profile}     bts_trace_profile=${bts_trace_profile}
    ...           enb_trace_profile=${enb_trace_profile}
    ...           vdu_trace_profile=${vdu_trace_profile}     vcu_trace_profile=${vcu_trace_profile}
    ${trace_id} =   Get From Dictionary   ${output}   tracer_id
    [Return]   ${trace_id}

DCAP stop collect log
    [Documentation]     stop Capture log by DCAP
    ...    | Input Parameters | Man. | Description |
    ...    | ${trace_id} | Yes | ${trace_id} |
    ...    | ${log_save_path} | No | default as ${TEST_LOG_DIRECTORY()}/dcap/ |
    [Arguments]   ${trace_id}    ${log_save_path}=${TEST_LOG_DIRECTORY()}/dcap/
    rd.stop_trace     trace_id=${trace_id}
    ${ret}    run keyword and ignore error     Directory Should Exist      ${log_save_path}
    run keyword if     '${ret[0]}'=='FAIL'       Create Directory     ${log_save_path}
    ${zip_path}    rd.get_results    result_id=${trace_id}       target_dir=${log_save_path}/    timeout=200
    [Return]    ${zip_path}

update numpy
	TAF_SSH.Connect To    127.0.0.1    ute    ute    alias=bsh
	TAF_SSH.Execute    cd    connection=bsh
	TAF_SSH.Send Command    source /opt/tti-dec/venv/bin/activate;cd /opt/tti-dec/tti-dec-bin;pip install --upgrade 'numpy<2.0'    connection=bsh
