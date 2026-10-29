# Copyright (c) 2020 Nokia. All rights reserved.

*** Settings ***
Documentation    It is of paramount importance to separate contents of this file into other files.

Library    BuiltIn
Library    DateTime
Library    OperatingSystem
Library    Process
Library    String
Library    Telnet
Library    taf.transport.ssh  WITH NAME  SSH
Library    ute_wtssim

Resource   coam.robot


*** Variables ***
&{AP_ASIK}     Ip=192.168.200.1    Username=toor4nsn    Password=oZPS0POrRieRtu    Connection=ApAsik
&{GNB_ASIK}    Ip=192.168.255.1    Username=toor4nsn   Password=oZPS0POrRieRtu    Connection=GnbAsik

${WTS_DIR}             /opt/iphy/latest/
#${EGATE_CONFIG_DIR}    /airphone_cfg
${TL_INIT_DIR}         /home/ute/testline_update_results/logs

${UE_ID}        1
${BEARER_ID}    2


*** Keywords ***
Starting  UTE_WTS
    [Documentation]    Kill running WTS binaries if any, configure ETH3, retrieve files and configure WTS
    Stop Edaemon Egate

    Configure UTE ETH3

    Log to Console                 Starting WTS...
    Remove File                    ${WTS_DIR}/AirPhoneConfig*.xml

    Copy Files                     ${SUITE_CFG_DIR}/AirPhoneConfig*.xml            ${WTS_DIR}

    Copy Files                     ${SUITE_CFG_DIR}/basic*.cfg                     ${WTS_DIR}

	Copy Files                     ${SUITE_CFG_DIR}/AirPhoneConfig*.xml            ${WTS_DIR}
    Copy Files                     ${SUITE_CFG_DIR}/basic*.cfg                     ${WTS_DIR}
    Setup Edaemon                  edaemon_port=22222    tool_dir=${WTS_DIR}    alias=edaemon
    Start Edaemon Process          alias=edaemon
    Setup Egate                    egate_port=20000    tool_dir=${WTS_DIR}
    Start Egate Process
    ${ls}    Run    ls ${WTS_DIR}/*cfg
    Log To Console    ${ls}
    Execute Egate Command          cfg file\=${WTS_DIR}/${SUITE_WTS_CFG}
    ...                            pass_regexp=(SimMode is ready now|UEC-1 is active)

    Wait Until Keyword Succeeds    120sec    15sec
    ...                            Execute Egate Command    state_sim_disp    pass_regexp=The state is ACTIVE
    Start fsyslog Service

Start fsyslog Service
    [Documentation]    Start fsyslog daemon
    Run                 killall fsyslog
    Create directory    ${EXECDIR}/logs/udpsyslog
    Remove files        ${EXECDIR}/logs/udpsyslog/*
    ${command}          Catenate    ${WTS_DIR}/fsyslog --log-dir=${EXECDIR}\/logs\/udpsyslog
    ...                 --log-file-name=udpsyslog.log
    Run                 ${command}

Stopping Edaemon Egate
    [Documentation]    Kill edaemon and egate if already running.
    ${pid}=    Run    pgrep edaemon
    Run Keyword If    '${pid}'!='${EMPTY}'    Run    sudo kill -9 ${pid}
    ${pid}=    Run    pgrep egate
    Run Keyword If    '${pid}'!='${EMPTY}'    Run    sudo kill -9 ${pid}

Configure UTE ETH3
    Run    sudo ip addr add 10.0.1.200/24 dev eth3
    Run    sudo ip addr add 10.0.1.131/24 dev eth3
    Run    sudo ip addr add 10.0.1.132/24 dev eth3
    Run    sudo ip addr add 10.0.1.133/24 dev eth3
    Run    sudo ip addr add 10.0.1.134/24 dev eth3
    Run    sudo ip addr add 10.0.1.135/24 dev eth3
    Run    sudo ip addr add 10.0.1.136/24 dev eth3
    Run    sudo ip addr add 10.0.1.137/24 dev eth3
    Run    sudo ip addr add 10.0.1.138/24 dev eth3
    Run    sudo ip addr add 10.0.1.139/24 dev eth3
    Run    sudo ip addr add 10.0.1.140/24 dev eth3
    Run    sudo ip addr add 10.0.1.99/24 dev eth3
    Run    sudo ip addr add 10.0.1.121/24 dev eth3
    Run    sudo ip addr add 10.0.1.3/24 dev eth3
    Run    sudo ip addr add 10.0.1.4/24 dev eth3

Modify UTE SCTP Timeout
    [Documentation]    Starting AirPhone load 4.0.10852, the sack timeout in the WTS VM and AP ASIK must be
    ...                configured before cell setup. This aims to prevent delayed messaging between AirPhone
    ...                and WTS (e.g. CTRL_ADD_UE_NR for attach procedure).
    SSH.Connect To    ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}
    ...               alias=${AP_ASIK.Connection}
    ${command}        Catenate    sysctl -w net.sctp.sack_timeout=10 &&
    ...               sysctl -w net.sctp.rto_min=200 &&
    ...               sysctl -w net.sctp.rto_initial=200 &&
    ...               sysctl -w net.sctp.rto_max=800
    SSH.Execute       ${command}    ${AP_ASIK.Connection}
    SSH.Disconnect    ${AP_ASIK.Connection}

Check UTE ASIK AP Cell Setup
    SSH.Connect To    ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}
    ...               alias=${AP_ASIK.Connection}
    ${result}         SSH.Execute    grep -i "Cell Setup Completed" /tmp/startup_l3.log    ${AP_ASIK.Connection}
    Should Contain    ${result}    Cell Setup Completed    ignore_case=True
    Log to Console    ${result}
    SSH.Disconnect    ${AP_ASIK.Connection}

Search grep message should Exists
    [Arguments]    ${file}    ${expected}    ${connection}=${AP_ASIK.Connection}    ${grepArgs}=grep -i    ${sudo}=${EMPTY}
    ...            ${grepPostArgs}=${EMPTY}    ${catPostArgs}=${EMPTY}
    ${command}        Catenate    ${sudo} cat ${file} ${catPostArgs} | ${grepArgs} '${expected}' ${grepPostArgs}
    SSH.Connect To    ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}
    ...               alias=${AP_ASIK.Connection}
    ${actual}         SSH.Execute    ${command}    ${connection}
    SSH.Disconnect    ${AP_ASIK.Connection}
    ${result}         Run Keyword And Return Status
    ...               Should Match Regexp    ${actual}    ${expected}    msg=No match for ${expected}
    Should be True    ${result}    msg=File or pattern does not exist!

Get Egate Output UTE
    [Arguments]    ${expected}    ${display}=${TRUE}
    [Documentation]    Use Open Egate Connection before using this keyword
    ${output}                 Read Until    ${expected}
    Should Contain            ${output}    ${expected}    ignore_case=True
    Return From Keyword if    ${display} is ${FALSE}
    ${output}                 Get Lines Matching Regexp    ${output}    ${expected}    partial_match=${TRUE}
    Log to Console            ${output}
    [Return]    ${output}

Open Egate Connection
    [Arguments]    ${timeout}=5 minutes
    [Documentation]    UTE
    Open Connection    127.0.0.1    port=20000    connection_timeout=20    prompt=EGATE>
    Set Timeout        ${timeout}

Collect UTE Logs
    Log to Console            Collecting configs...
    Get Coam SCF
    Collect UTE Files
    Log to Console            Collecting all logs...
    Collect UTE SosReport
    Collect fsyslog
    Collect all logs via log_collector.sh

Collect UTE Configs
    Log to Console            Collecting configs...
    Get Coam SCF
    Collect UTE Files
    Log to Console            Collecting snapshot logs...
    Collect UTE SosReport

Collect UTE Files
    Copy Files       ${WTS_DIR}/${SUITE_WTS_CFG}    ${WTS_DIR}/${SUITE_WTS_AP_XML}
    ...              ${TL_INIT_DIR}/DEBUG_log.txt    ${TL_INIT_DIR}/INFO_log.txt    ${EXECDIR}/logs/
    SSH.Connect To   ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}
    ...              alias=${AP_ASIK.Connection}
    SSH.Connect To   ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}
    ...              alias=${GNB_ASIK.Connection}
    @{configs}       Create List    /ffs/run/swconfig.txt    /rom/simmode/iphy.xml
    Download File    ${configs}    ${EXECDIR}/logs/    ${AP_ASIK.Connection}
    Download File    /ffs/run/swconfig.txt    ${EXECDIR}/logs/swconfig_gnb.txt
    ...              ${GNB_ASIK.Connection}
    SSH.Disconnect   ${AP_ASIK.Connection}
    SSH.Disconnect   ${GNB_ASIK.Connection}

Collect UTE SosReport
    ${result}     Execute Egate Command    sim_log_set flush
    ${command}    Catenate    sed -i \'s@LOG_DIR_ON_DEVICE=.*@LOG_DIR_ON_DEVICE="/tmp/sosreport"@g\'
    ...           ${WTS_DIR}/sosReport.cfg
    Run           ${command}
    Run           cd ${EXECDIR}/logs/ && ${WTS_DIR}/sosReport.sh -nr -c -s > /dev/null 2>\&1
    Run           ls ${EXECDIR}/logs/SosReport*.tgz

Collect fsyslog
    Run                 killall fsyslog
    Run                 tar -cvf ${EXECDIR}/logs/udpsyslog.tar.gz ${EXECDIR}/logs/udpsyslog/*.log.*
    Remove Files        ${EXECDIR}/logs/udpsyslog/*
    Remove Directory    ${EXECDIR}/logs/udpsyslog

Collect all logs via log_collector.sh
    Run and return rc and output    chmod +x ${CURDIR}/../../sh/log_collector.sh
    Run and return rc and output    cd ${OUTPUT_DIR} && ${CURDIR}/../../sh/log_collector.sh


Check Average Rate
    [Arguments]    ${bearer_stat}    ${dir}    ${mbps}
    ${output}         Get Regexp Matches    ${bearer_stat}    Average data rate +(\\d+)    1
    ${result}         Evaluate    (${mbps} * 1000000 * 1.1) > int(${output[0]}) > (${mbps} * 1000000 * 0.9)
    Run Keyword if    ${result}    Log to Console    ${dir} Average data rate: ${output[0]}
    ...               ELSE    Log    ${dir} Average data rate: ${output[0]}    level=ERROR
    Run Keyword and Continue on Failure
    ...               Should Be True    ${result}    msg=${dir} Average data rate failed!

Check DL Data Loss
    [Arguments]    ${bearer_stat_all}    ${bearer_stat_scg}
    ${bytes_sent}       Get Regexp Matches    ${bearer_stat_all}    Bytes sent +(\\d+)    1
    ${bytes_rec}        Get Regexp Matches    ${bearer_stat_scg}    Bytes received +(\\d+)    1
    ${bytes_sent_int}   Convert To Integer  ${bytes_sent[0]}
    ${bytes_rec_int}    Convert To Integer   ${bytes_rec[0]}
    ${data_loss}        Set Variable    0.01
    ${bytes_sent_min}   Evaluate    ${bytes_sent_int}*(1 - ${data_loss})

    Run Keyword if    ${bytes_sent_min} <= ${bytes_rec_int} <= ${bytes_sent_int}
    ...               Log to Console    DL Bytes received complete (${bytes_rec[0]})
    ...               ELSE
    ...               Log    DL Data Loss! Bytes Received (${bytes_rec[0]}) not matching given threshold! Sent (${bytes_sent[0]})
    ...               level=ERROR
    Run Keyword and Continue on Failure
    ...               Should Be True    ${bytes_sent_min} <= ${bytes_rec_int} <= ${bytes_sent_int}    msg=${EMPTY}

Check UL Data Loss
    [Arguments]    ${bearer_stat_all}    ${bearer_stat_scg}
    ${bytes_sent}       Get Regexp Matches    ${bearer_stat_scg}    Bytes sent +(\\d+)    1
    ${bytes_rec}        Get Regexp Matches    ${bearer_stat_all}    Bytes received +(\\d+)    1
    ${bytes_sent_int}   Convert To Integer  ${bytes_sent[0]}
    ${bytes_rec_int}    Convert To Integer   ${bytes_rec[0]}
    ${data_loss}        Set Variable    0.01
    ${bytes_sent_min}   Evaluate    ${bytes_sent_int}*(1 - ${data_loss})

    Run Keyword if    ${bytes_sent_min} <= ${bytes_rec_int} <= ${bytes_sent_int}
    ...               Log to Console    UL Bytes sent complete (${bytes_sent[0]})
    ...               ELSE
    ...               Log    UL Data Loss! Bytes Sent (${bytes_sent[0]}) not matching given threshold! Received (${bytes_rec[0]})
    ...               level=ERROR
    Run Keyword and Continue on Failure
    ...               Should Be True    ${bytes_sent_min} <= ${bytes_rec_int} <= ${bytes_sent_int}    msg=${EMPTY}

Validate Traffic
    [Documentation]    NSA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL SCG Bytes Received must be equal to ALL Bytes Sent
    ...                3. UL SCG Bytes Sent must be equal to ALL Bytes Received
    [Arguments]    ${dl_rate}    ${ul_rate}
    ${bearer_stat_all}      Execute Egate Command and Wait for Data
    ...                     bearer_stats id\=${BEARER_ID} ue\=${UE_ID} dir\=dl
    ${bearer_stat_scg}      Execute Egate Command and Wait for Data
    ...                     bearer_stats id\=${BEARER_ID} ue\=${UE_ID} dir\=dl dc_cell_group\=scg
    Check Average Rate      ${bearer_stat_scg}    DL    ${dl_rate}
    Check DL Data Loss      ${bearer_stat_all}    ${bearer_stat_scg}

    ${bearer_stat_all}      Execute Egate Command and Wait for Data
    ...                     bearer_stats id\=${BEARER_ID} ue\=${UE_ID} dir\=ul
    ${bearer_stat_scg}      Execute Egate Command and Wait for Data
    ...                     bearer_stats id\=${BEARER_ID} ue\=${UE_ID} dir\=ul dc_cell_group\=scg
    Check Average Rate      ${bearer_stat_all}    UL    ${ul_rate}
    Check UL Data Loss      ${bearer_stat_all}    ${bearer_stat_scg}

Start Traffic
    [Arguments]    ${dl_rate}=5    ${ul_rate}=5    ${duration}=10min
    ${duration}       Get Variable Value    ${TRF_DURATION}    ${duration}
    Log to Console    \nRunning DL + UL Traffic for ${duration}...
    ${output}         Execute Egate Command and Wait for Data
    ...               trf_data_start ue\=${UE_ID} id\=${BEARER_ID} dir\=dl mbps\=${dl_rate}
    ...               pass_regexp=TRF:
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    ${output}

    ${output}         Execute Egate Command and Wait for Data
    ...               trf_data_start ue\=${UE_ID} id\=${BEARER_ID} dir\=ul mbps\=${ul_rate}
    ...               pass_regexp=TRF:
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    ${output}

    Sleep             ${duration}

    Log to Console    Stopping DL + UL Traffic...
    ${output}         Execute Egate Command and Wait for Data
    ...               trf_data_stop ue\=${UE_ID} id\=${BEARER_ID}    pass_regexp=Traffic was stopped
    ${output}         Get Lines Matching Regexp    ${output}    Traffic was stopped   partial_match=${TRUE}
    Log to Console    ${output}

    ${trf_status}     Run Keyword And Ignore Error    Validate Traffic    ${dl_rate}    ${ul_rate}
    Should Be True    '${trf_status[0]}' == 'PASS'    msg=Traffic failed, see error above!
