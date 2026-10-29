*** Settings ***
Documentation
...     Author: xi.wu@Nokia-sbell.com
Library           taf.collectors.core      WITH NAME   core
Library           taf.collectors.btslog    WITH NAME   btslog
Library           ${CURDIR}/utils.py
Library           SSHLibrary
Library           OperatingSystem
Library           BuiltIn
Library           Collections
Library           Process
Library           Telnet
Library           DateTime
Library           XML
Library           String
Resource          TAF_Common_Admin.robot
Library           taf.sbts.oam.coam.admin    WITH NAME    coam
Library           taf.collectors.tcpdump    WITH NAME    tcpdump
Library           taf.collectors.tshark        WITH NAME    tshark
Library           taf.sw.scout    WITH NAME    scout

*** Variables ***
${cmd}    pip3 install --upgrade --timeout 60 --trusted-host 10.69.239.163 --disable-pip-version-check -i http://10.69.239.163/ nbs==trunk.3.9.5
${G_BTSAlias}     BTSSession
${G_bts_host}     192.168.255.129
${G_bts_user}     toor4nsn
${G_bts_passwd}    oZPS0POrRieRtu

*** Keywords ***
Common BTS Suite Setup
    Get Suite Log Directory
    ADMIN Setup Admin

Common BTS Suite Teardown
	Log    \n *** Case teardown
	ADMIN Teardown Admin

Common BTS Test Setup
    Get Test Log Directory
    BTSLOG Start btslog on local machine

Common BTS Test Teardown
    BTSLOG Collect btslog
	${hostname}=  Get UTE VM Hostname
    Wait Until Keyword Succeeds    3x    30s    Get SCF Internal Id By Scout    bts_id=${hostname}    no_ute=False
    Run Keyword If Test Failed    ADMIN Collect Snapshot

Get SCF Internal Id By Scout
    [Arguments]    ${bts_id}=${TESTLINE_NAME}    ${no_ute}=${True}
    [Documentation]    This kw is used to get scf id from scout by testline id
    ...    Author: Xu Yuyan
    ...    | Input Parameters | Man. | Description |
    ...    | bts_id | yes | use the scout testline id ,usually is bts id |
    ...    | no_ute | yes | if you use CM single run or auto trigger, please set False |
    ...
    ...    | Return Value | Description |
    ...    | scf_id | the internal id from scout |
    ...
    ...    Example
    ...    | Get SCF Internal Id By Scout | testline_name=6141 |
    [Timeout]    3 minutes
    scout.setup_scout    ${bts_id}
    ${scf_id}    scout.request_scf    use_scout_internal_id=${no_ute}
    Log to Console    scf id is: ${scf_id}
    [Teardown]    scout.teardown_scout_api

Get UTE VM Hostname
    [Documentation]    This kw is used to get the UTE VM Hostname as the UTE TL name
    ...
    ...    Author: Xu Yuyan
    ...
    ...    | Return Value | Description |
    ...    | hostname_tmp | the ute vm host name in UTE TL name format |
    ...
    ...    Example
    ...    | ${hostname} | Get UTE VM Hostname |
    ...
    ${rc}  ${hostname_tmp}=  Run And Return Rc And Output  hostname
    ${hostname_tmp}=  Replace String  ${hostname_tmp}  -  _
    ${hostname_tmp}=  convert to string  ${hostname_tmp}
    [Return]  ${hostname_tmp}


BTSLOG Start btslog on local machine
    [Arguments]   ${bts_logs_dir}=/tmp/btslog2    ${name}=btslog
    Run  if [ ! -d ${bts_logs_dir} ]; then mkdir ${bts_logs_dir}; else rm ${bts_logs_dir}/*; fi
    btslog.create_btslog_collector
    ...    name=${name}
    ...    log_dir=${bts_logs_dir}
    core.setup_collectors    names=${name}
    core.start_collectors    names=${name}
    btslog.set_suite_alias    ${name}

BTSLOG Collect btslog
    [Arguments]    ${bts_logs_dir}=/tmp/btslog2
    run keyword and ignore error    Stop and collect btslog on local machine
    #Copy btslog to logs dir and clean BTSlog workspace    ${bts_logs_dir}
    Run  rm ${bts_logs_dir}/*

Stop and collect btslog on local machine
    [Arguments]   ${name}=btslog    ${target_dir}=${OUTPUTDIR}/${TESTNAME}
    core.stop_collectors         names=${name}
    core.collect_collectors      names=${name}    target_dir=${target_dir}
    core.teardown_collectors     names=${name}

Copy btslog to logs dir and clean BTSlog workspace
    [Arguments]     ${bts_logs_dir}=/tmp/btslog2
    Run  mv ${bts_logs_dir}/syslog_files.tgz ${OUTPUT_DIR}/${TEST_NAME}/bts_log.tgz
    Run  rm ${bts_logs_dir}/*

Install NBS
    ${result}    Process.run process    ${cmd}    shell=${True}     cwd=${CURDIR}    timeout=30

Get Suite Log Directory
    ${timestamp}    Get Timestamp
    ${FILE_NAME} =    Replace String Using Regexp    ${SUITE_NAME[:50]}    \\s+$    ${EMPTY}
    ${SUITE_LOG_DIR}    Catenate    SEPARATOR=${/}    ${OUTPUT_DIR}    ev_logs    ${FILE_NAME}_${timestamp}
    ${SUITE_LOG_DIR}    Replace String    ${SUITE_LOG_DIR}    &    ${SPACE}
    ${SUITE_LOG_DIR}    Replace String    ${SUITE_LOG_DIR}    ${SPACE}    _
    Set Suite Variable    ${SUITE_LOG_DIR}
    Create Directory    ${SUITE_LOG_DIR}
    log    save log dir:${SUITE_LOG_DIR}
    [Return]    ${SUITE_LOG_DIR}

Get Test Log Directory
    ${timestamp}    Get Timestamp
    ${TEST_LOG_DIR}    Catenate    SEPARATOR=${/}    ${SUITE_LOG_DIR}    ${TEST_NAME[:50]}
    ${TEST_LOG_DIR}    Replace String    ${TEST_LOG_DIR}    ${SPACE}    _
    Set Suite Variable    ${TEST_LOG_DIR}
    Create Directory    ${TEST_LOG_DIR}
    Set Suite Variable    ${TA_LOG_DIRECTORY}    ${TEST_LOG_DIR}
    log    save log dir:${TEST_LOG_DIR}
    [Return]    ${TEST_LOG_DIR}

BTS Get ParaValue
    [Arguments]    ${FilePath}    ${ParaName}    ${MOC}=LNBTS    ${DistName}=PLMN-PLMN/MRBTS-${BTS_INFO.ID}/LNBTS-${BTS_INFO.ID}
    ${xml}    Parse Xml    source=${FilePath}
    ${precondition}    set variable    .//*[@class="${MOC}"]..//*[@distName="${DistName}"]
    ${Paralist}    Get Element    source=${xml}    xpath=${precondition}
    ${paravalue}    Get Element Text    source=${Paralist}    xpath=.//p[@name="${ParaName}"]
    [Return]    ${ParaValue}

Connect to bts
    [Arguments]    ${Alias}=${G_BTSAlias}
    ${BTS_connection}    Connect    ${G_bts_host}    ${G_bts_user}    ${G_bts_passwd}    ${Alias}
    Set Suite Variable    ${BTS_connection}
    [Return]    ${BTS_connection}

Disconnect to bts
    [Arguments]    ${Alias}=${G_BTSAlias}
    Disconnect    ${Alias}

BTS Check ParaValue
    [Arguments]    ${MOC}    ${DistName}    ${ParaName}    ${Para_value}
	${Scf_file}    ADMIN Get SCF
	${value}    BTS Get ParaValue    ${Scf_file}    ${ParaName}    ${MOC}    ${DistName}
	Should Be Equal    ${value}    ${Para_value}


Wireshark Start pcap on gNB
    [Arguments]    ${host}=10.0.1.2    ${name}=oamTcpdump    ${options}=-f sctp -i any -s0
    ${executor_oam}=  Create Dictionary
    ...  host=${host}
    ...  user=toor4nsn
    ...  password=oZPS0POrRieRtu
    tcpdump.create_tcpdump_collector
    ...     name=${name}
    ...     options=${options}
    ...     executor=${executor_oam}
    core.setup_collectors    names=${name}
    core.start_collectors    names=${name}
    tcpdump.set_test_alias    ${name}


Start pcap collection on gNB
    [Arguments]    ${host}=10.0.1.2    ${name}=oamTcpdump    ${options}=-i any -s0 not udp
    Wireshark Start pcap on gNB    ${host}    ${name}    ${options}


Stop pcap collection on gNB
    [Arguments]    ${name}=oamTcpdump    ${test_log_path}=${OUTPUTDIR}
    core.stop_collectors    names=${name}
    core.collect_collectors    names=${name}    target_dir=${test_log_path}
    core.teardown_collectors    names=${name}


Wireshark Collect pcap on gNB
    [Arguments]    ${name}=oamTcpdump    ${pcap_logs_dir}=${OUTPUTDIR}
    run keyword and ignore error    Stop pcap collection on gNB    ${name}    ${pcap_logs_dir}
