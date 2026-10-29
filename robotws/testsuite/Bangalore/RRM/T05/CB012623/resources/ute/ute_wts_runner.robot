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
Library    taf.wts.runner                     WITH NAME      wtsrunner
Library    taf.gnb.oam.coam.admin    WITH NAME    CoamAdmin
Library    Collections
Resource   sosReport.robot
Resource   ${CURDIR}/../Variables/common_variables.robot

*** Variables ***
@{CONN_CARDS}          bsh 0:0    bsh 0:1    bsh 1:0    bsh 1:1
${syscom_file}         /tmp/.dciLinkConfigured
${WTS_DIR}             /opt/iphy/latest
${TL_INIT_DIR}         /home/ute/testline_update_results/logs
${AP_CONFIG_BASIC}     ${CURDIR}/../../config/wts
${UE_ID}        1
${BEARER_ID}    2
${Knife}        0
#P1_Perf lua generator script
${lua_generator_script}                    ${CURDIR}/../../../AP_P1Perf/resources/scripts/luaGenerator_APoABIO.py
${lua_generator_mmwv_script}               ${CURDIR}/../../../AP_P1Perf/resources/scripts/luaGenerator_mmwv_APoABIO.py
${gnb_scf_custom_config_file}              /home/ute/workspace/UTE_E2E/PROD/E2E_TESTS/e2e_tests/custom_configs/sm/scfc.xml
${cloud_gnb_scf_custom_config_file}        /home/ute/testline_init_results/configs/scfc.xml

*** Keywords ***
Connect To WTS VM
    [Documentation]    Establish a ssh connection to the WTS machine where the simulator is present
    SSH.Connect to     hostname=${WTS.Ip}
    ...                username=${WTS.Username}
    ...                alias=${WTS.Connection}
    ${command}        Catenate    sysctl -w net.sctp.sack_timeout=10 &&
    ...               sysctl -w net.sctp.rto_min=200 &&
    ...               sysctl -w net.sctp.rto_initial=200 &&
    ...               sysctl -w net.sctp.rto_max=800
    Run               ${command}
    Run               cat /proc/sys/net/sctp/rto_min

Teardown Edaemon and Egate process
    [Documentation]    kill running Edaemon and Egate process
    wtsrunner.kill_wtsemu_edaemon    edaemon_port=22222   connection=${WTS.Connection}    sudo_password=ute
    sleep      5s
    wtsrunner.kill_wtsemu_egate      egate_port=20000     connection=${WTS.Connection}    sudo_password=ute

Start UTE WTS
    [Documentation]     configuring the UTE WTSe
    ...                 arguments    wts_configuration_file is the file name of the config file
    ...                              feature    is the feature id deffault feature id is CB08187
    ...                 Usage   :    Start UTE WTS       basic_config.cfg
    ...                 example :    Start UTE WTS       basic_config.cfg
    [Arguments]         ${wts_configuration_file}
    Stop Edaemon Egate
    Log to Console                 Starting WTS...
    ${status}    Run Keyword And Return Status      File Should Exist       ${test_property_file}
    Log    ${status}
    Connect To WTS VM
    wtsrunner.configure_wtsemu_edaemon              edaemon_ssh_alias=${WTS.Connection}
    ...                                             directory_path=${WTS_DIR}
    ...                                             port=22222
    ...                                             sudo_password=ute
    wtsrunner.configure_wtsemu_egate                egate_ssh_alias=${WTS.Connection}
    ...                                             directory_path=${WTS_DIR}
    ...                                             port=20000
    ...                                             nostats=True
    wtsrunner.start_wtsemu                          egate_console_ip=${WTS.Ip}
    ...                                             egate_port=20000
    ${cfg_filename}         set variable            ${AP_CONFIG_BASIC}/${wts_configuration_file}
    wtsrunner.configure                             file=${cfg_filename}
    wtsrunner.read_wtsemu_output_until_re           expected=SimMode is ready now        timeout=240
    Wait Until Keyword Succeeds         2 min       30 sec              Verify if sim state is active

Verify if sim state is active
    wtsrunner.sim_state_disp
    wtsrunner.read_wtsemu_output_until_re    expected=The state is ACTIVE   timeout=20

Start fsyslog Service
    [Documentation]    Start fsyslog daemon
    Run                 killall fsyslog
    ${dir_exist_status}=    Run Keyword And Return Status   Directory Should Exist    ${EXECDIR}/logs
    Run Keyword If    '${dir_exist_status}' == 'False'    Run Keywords
    ...    Remove File    ${EXECDIR}/logs    AND     Create Directory     ${EXECDIR}/logs
    Create directory    ${EXECDIR}/logs/udpsyslog
    Remove files        ${EXECDIR}/logs/udpsyslog/*
    ${command}          Catenate    ${WTS_DIR}/fsyslog --log-dir=${EXECDIR}\/logs\/udpsyslog
    ...                 --log-file-name=udpsyslog.log
    Run                 ${command}

Stop Edaemon Egate
    [Documentation]    Kill edaemon and egate if already running.
    ${edaemon_pid}=    Run    pgrep edaemon
    ${edaemon_status}    Run Keyword and Return Status    Should Not Be Empty    ${edaemon_pid}
    Run Keyword If    ${edaemon_status}    Run    sudo pkill -9 edaemon
    ${egate_pid}=    Run    pgrep egate
    ${egate_status}    Run Keyword and Return Status    Should Not Be Empty    ${egate_pid}
    Run Keyword If    ${egate_status}    Run    sudo pkill -9 egate
    Run Keyword If    ${edaemon_status} or ${egate_status}    sleep      5s

Configure UTE and IPV6 ETH3
    Run    sudo ip addr del 10.0.1.99/24 dev eth3
    Run    sudo ip addr del fc00::099/116 dev eth3
    Run    sh ${CURDIR}/../scripts/sudo_ips_mue.sh

Configure UTE ETH3 FOR FR1_PERF
    Run    sudo ip addr add 10.0.1.138/24 dev eth3
    Run    sudo ip addr add 10.0.1.139/24 dev eth3
    Run    sudo ip addr add 10.0.1.61/24 dev eth3

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
    ${result}         SSH.Execute    grep -i "Cell Setup Completed" /tmp/APL3.log    ${AP_ASIK.Connection}
    Should Contain    ${result}    Cell Setup Completed    ignore_case=True
    Log to Console    ${result}
    SSH.Disconnect    ${AP_ASIK.Connection}

Check UTE ASIK Gnb F1 link
    SSH.Connect To    ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}
    ...               alias=${GNB_ASIK.Connection}
    ${result}         SSH.Execute    grep -i "F1 setup successfully" /tmp/node_CPRT00/tmp/startup_cp_rt.log
    ...               ${GNB_ASIK.Connection}
    Should Contain    ${result}    F1 setup successfully    ignore_case=True
    Log to Console    ${result}
    SSH.Disconnect    ${GNB_ASIK.Connection}

Collect UTE Logs
    Log to Console            Collecting configs...
    Get Coam SCF
    Collect UTE Files
    Log to Console            Collecting all logs...
    Collect UTE SosReport
    Collect fsyslog
    Run Keyword If    '${4G5G_Combo}'=='1'    Collect 4G SosReport
    Collect all logs via log_collector.sh

Collect UTE Configs
    Log to Console            Collecting configs...
    Get Coam SCF
    Collect UTE Files
    Log to Console            Collecting snapshot logs...
    Collect UTE SosReport

Get Coam SCF
    Set Suite Variable    ${coamSCF}    ${EXECDIR}/logs/gnb_coam_scf.xml
    ${path}                           ${file}    Split Path    ${coamSCF}
    CoamAdmin.Connect To    bts_host=${GNB_ASIK.Ip}
    CoamAdmin.Get Current Scf File    ${path}    ${file}
    File Should Exist                 ${coamSCF}
    [Teardown]    CoamAdmin.Teardown

Collect UTE Files
    Copy Files       ${WTS_DIR}/${SUITE_WTS_CFG}
    ...              ${TL_INIT_DIR}/DEBUG_log.txt    ${TL_INIT_DIR}/INFO_log.txt    ${EXECDIR}/logs/
    SSH.Connect To   ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}
    ...              alias=${AP_ASIK.Connection}
    SSH.Connect To   ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}
    ...              alias=${GNB_ASIK.Connection}
    @{configs}       Create List    /ffs/run/swconfig.txt    /rom/simmode/iphy.xml
    SSH.Download File    ${configs}    ${EXECDIR}/logs/    ${AP_ASIK.Connection}
    SSH.Download File    /ffs/run/swconfig.txt    ${EXECDIR}/logs/swconfig_gnb.txt
    ...              ${GNB_ASIK.Connection}
    SSH.Disconnect   ${AP_ASIK.Connection}
    SSH.Disconnect   ${GNB_ASIK.Connection}

Collect UTE SosReport
    #wtsrunner.sim_log_set   flush
    ${command}    Catenate    sed -i \'s@LOG_DIR_ON_DEVICE=.*@LOG_DIR_ON_DEVICE="/tmp/sosreport"@g\'
    ...           ${WTS_DIR}/sosReport.cfg
    Run           ${command}
    ${command}    Catenate    sed -i \'s@BTS_IP_1=.*@BTS_IP_1=${4G5G_Combo_GNB_IP}@g\'
    ...           ${WTS_DIR}/sosReport.cfg
    Run Keyword If    '${4G5G_Combo}'=='1'    Run    ${command}
    Run    chmod 777 ${WTS_DIR}/sosReport_ASIL/*
    ${Cmd_1}    Set Variable    cd ${EXECDIR}/logs/ && ${WTS_DIR}/sosReport.sh -nr -c -s -d > /dev/null 2>\&1
    ${Cmd_2}    Set Variable    cd ${WTS_DIR}/ && ${WTS_DIR}/sosReport_ASIK_ASIL.sh -c -s -d > /dev/null 2>\&1
    run keyword if    '${ap_sm_hardware}' == 'ASIL'    Run    ${Cmd_2}    ELSE
    ...            Run    ${Cmd_1}
    run keyword if    '${ap_sm_hardware}' == 'ASIL'    Run    mv /opt/wts/latest/SosReport*.tgz ${EXECDIR}/logs/
    Run           ls ${EXECDIR}/logs/SosReport*.tgz
    File Should Exist    ${EXECDIR}/logs/SosReport*.tgz

Collect 4G SosReport
    SSH.Connect To    ${test_pc2}[addr]
    ...               ${test_pc2}[username]
    ...               ${test_pc2}[password]
    ...               alias=VM2
    ${command}    Catenate    sed -i \'s@LOG_DIR_ON_DEVICE=.*@LOG_DIR_ON_DEVICE="/tmp/sosreport"@g\'
    ...           ${WTS_DIR}/sosReport.cfg
    SSH.Execute    ${command}    VM2
    SSH.Execute    cd ${WTS_DIR} && ${WTS_DIR}/sosReport.sh -c -s -d > /dev/null 2>\&1     VM2
    SSH.Execute    ls ${WTS_DIR}/SosReport*.tgz     VM2
    Run    scp ${test_pc2}[username]@${test_pc2}[addr]:${WTS_DIR}/SosReport*.tgz ${EXECDIR}/logs/
    SSH.Execute    rm -rf ${WTS_DIR}/SosReport*.tgz     VM2
    SSH.Disconnect    VM2

Collect fsyslog
    Run                 killall fsyslog
    Run                 tar -cvf ${EXECDIR}/logs/udpsyslog.tar.gz ${EXECDIR}/logs/udpsyslog/*.log.*
    Run Keyword And Ignore Error    Remove Files    ${EXECDIR}/logs/udpsyslog/*
    Remove Directory    ${EXECDIR}/logs/udpsyslog    recursive=True

Collect all logs via log_collector.sh
    Run and return rc and output    chmod +x ${CURDIR}/../../sh/log_collector.sh
    Run and return rc and output    cd ${OUTPUT_DIR} && ${CURDIR}/../../sh/log_collector.sh

Search grep pattern should Exists
    [Arguments]    ${file}    ${expected}    ${connection}=${AP_ASIK.Connection}    ${grepArgs}=grep -i    ${sudo}=${EMPTY}
    ${command}        Catenate    ${sudo} ${grepArgs} '${expected}' ${file}
    SSH.Connect To    ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}
    ...               alias=${AP_ASIK.Connection}
    ${actual}         SSH.Execute    ${command}    ${connection}
    SSH.Disconnect    ${AP_ASIK.Connection}
    ${result}         Run Keyword And Return Status
    ...               Should Match Regexp    ${actual}    ${expected}    msg=No match for ${expected}
    Should be True    ${result}    msg=File or pattern does not exist!

Search pattern should Exists In EGATE
    [Arguments]    ${file}    ${pattern}    ${grepArgs}=grep -i
    ${command}        Catenate    ${grepArgs} '${pattern}' ${file}
    ${result}         Run    ${command}
    Log               ${result}
    Should Contain    """${result}"""    ${pattern}    ignore_case=${TRUE}

Check Average Rate
    [Arguments]    ${bearer_stat}    ${dir}    ${mbps}    ${ueid}
    ${output}         Get Regexp Matches    ${bearer_stat}    Average data rate +(\\d+)    1
    ${result}         Evaluate    (${mbps} * 1000000 * 1.1) > int(${output[0]}) > (${mbps} * 1000000 * 0.9)
    Run Keyword if    ${result}    Log to Console    UE${ueid}:${dir} Average data rate: ${output[0]}
    ...               ELSE    Log    UE${ueid}:${dir} Average data rate: ${output[0]}    level=ERROR
    Run Keyword and Continue on Failure
    ...               Should Be True    ${result}    msg=UE${ueid}:${dir} Average data rate failed!

Check DL Data Loss
    [Arguments]    ${bearer_stat_all}    ${bearer_stat_scg}    ${ueid}
    ${bytes_sent}       Get Regexp Matches    ${bearer_stat_all}    Bytes sent +(\\d+)    1
    ${bytes_rec}        Get Regexp Matches    ${bearer_stat_scg}    Bytes received +(\\d+)    1
    ${bytes_sent_int}   Convert To Integer  ${bytes_sent[0]}
    ${bytes_rec_int}    Convert To Integer   ${bytes_rec[0]}
    ${data_loss}        Set Variable if    '${4G5G_Combo}' == '1' and '${variant_name}' == '4G5G_COMBO_MultiUE'
    ...    0.1    0.01
    ${bytes_sent_min}   Evaluate    ${bytes_sent_int}*(1 - ${data_loss})

    Run Keyword if    ${bytes_sent_min} <= ${bytes_rec_int} <= ${bytes_sent_int}
    ...               Log to Console    UE${ueid}:DL Bytes received complete (${bytes_rec[0]})
    ...               ELSE
    ...               Log    UE${ueid}:DL Data Loss! Bytes Received (${bytes_rec[0]}) not matching given threshold! Sent (${bytes_sent[0]})
    ...               level=ERROR
    Run Keyword and Continue on Failure
    ...               Should Be True    ${bytes_sent_min} <= ${bytes_rec_int} <= ${bytes_sent_int}    msg=${EMPTY}

Check UL Data Loss
    [Arguments]    ${bearer_stat_all}    ${bearer_stat_scg}    ${ueid}
    ${bytes_sent}       Get Regexp Matches    ${bearer_stat_scg}    Bytes sent +(\\d+)    1
    ${bytes_rec}        Get Regexp Matches    ${bearer_stat_all}    Bytes received +(\\d+)    1
    ${bytes_sent_int}   Convert To Integer  ${bytes_sent[0]}
    ${bytes_rec_int}    Convert To Integer   ${bytes_rec[0]}
    ${data_loss}        Set Variable if    '${4G5G_Combo}' == '1' and '${variant_name}' == '4G5G_COMBO_MultiUE'
    ...    0.1    0.01
    ${bytes_sent_min}   Evaluate    ${bytes_sent_int}*(1 - ${data_loss})

    Run Keyword if    ${bytes_sent_min} <= ${bytes_rec_int} <= ${bytes_sent_int}
    ...               Log to Console    UE${ueid}:UL Bytes sent complete (${bytes_sent[0]})
    ...               ELSE
    ...               Log    UE${ueid}:UL Data Loss! Bytes Sent (${bytes_sent[0]}) not matching given threshold! Received (${bytes_rec[0]})
    ...               level=ERROR
    Run Keyword and Continue on Failure
    ...               Should Be True    ${bytes_sent_min} <= ${bytes_rec_int} <= ${bytes_sent_int}    msg=${EMPTY}

Validate Traffic Data Loss for NSA
    [Documentation]    NSA Traffic Data Loss Criteria
    ...                1. DL SCG Bytes Received must be equal to ALL Bytes Sent
    ...                2. UL SCG Bytes Sent must be equal to ALL Bytes Received
    [Arguments]    ${UE_ID}=1
    wtsrunner.bearer_stats  ue=${UE_ID}   id=${BEARER_ID}   dir=dl
    ${bearer_stat_all}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    wtsrunner.bearer_stats    ue=${UE_ID}   id=${BEARER_ID}   dir=dl   dc_cell_group=scg
    ${bearer_stat_scg}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check DL Data Loss      ${bearer_stat_all}    ${bearer_stat_scg}    ${UE_ID}

    wtsrunner.bearer_stats  ue=${UE_ID}   id=${BEARER_ID}   dir=ul
    ${bearer_stat_all}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    wtsrunner.bearer_stats    ue=${UE_ID}   id=${BEARER_ID}   dir=ul   dc_cell_group=scg
    ${bearer_stat_scg}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check UL Data Loss      ${bearer_stat_all}    ${bearer_stat_scg}    ${UE_ID}

Start Traffic
    [Arguments]    ${UE_ID}    ${dl_rate}=5    ${ul_rate}=5    ${duration}=10min
    Log to Console    \nRunning DL + UL Traffic for ${duration}...
    wtsrunner.trf_data_start     ue=${UE_ID}    id=${BEARER_ID}    dir=dl    mbps=${dl_rate}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=UDP DL TRF: .*    timeout=60
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    ${output}
    wtsrunner.trf_data_start     ue=${UE_ID}    id=${BEARER_ID}    dir=ul    mbps=${ul_rate}
    Log to Console    ${output}

Stop Traffic
    [Arguments]     ${UE_ID}    ${BEARER_ID}
    wtsrunner.trf_data_stop     ue=${UE_ID}    id=${BEARER_ID}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Traffic was stopped   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    Traffic was stopped   partial_match=${TRUE}
    Log to Console    ${output}

Validate LTE Traffic
    [Documentation]    NSA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL SCG Bytes Received must be equal to ALL Bytes Sent
    ...                3. UL SCG Bytes Sent must be equal to ALL Bytes Received
    [Arguments]    ${dl_rate}    ${ul_rate}    ${UE_ID}=1    ${BEARER_ID}=${BEARER_ID}
    wtsrunner.bearer_stats  ue=${UE_ID}   id=${BEARER_ID}   dir=dl
    ${bearer_stat_all}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    wtsrunner.bearer_stats    ue=${UE_ID}   id=${BEARER_ID}   dir=dl
    ${bearer_stat_scg}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate      ${bearer_stat_scg}    DL    ${dl_rate}    ${UE_ID}
    Check DL Data Loss      ${bearer_stat_all}    ${bearer_stat_scg}    ${UE_ID}

    wtsrunner.bearer_stats  ue=${UE_ID}   id=${BEARER_ID}   dir=ul
    ${bearer_stat_all}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    wtsrunner.bearer_stats    ue=${UE_ID}   id=${BEARER_ID}   dir=ul
    ${bearer_stat_scg}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate      ${bearer_stat_all}    UL    ${ul_rate}    ${UE_ID}
    Check UL Data Loss      ${bearer_stat_all}    ${bearer_stat_scg}    ${UE_ID}

Start LTE Traffic
    [Arguments]    ${UE_ID}=1    ${dl_rate}=5    ${ul_rate}=5    ${duration}=10min
    ${duration}       Get Variable Value    ${TRF_DURATION}    ${duration}
    Log to Console    \nRunning DL + UL Traffic for ${duration}...
    wtsrunner.trf_data_start     ue=${UE_ID}    id=${BEARER_ID}    dir=dl    mbps=${dl_rate}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=UDP DL TRF: .*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    ${output}
    wtsrunner.trf_data_start     ue=${UE_ID}    id=${BEARER_ID}    dir=ul    mbps=${ul_rate}
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=UDP UL TRF: .*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    ${output}
    Sleep             ${duration}
    Log to Console    Stopping DL + UL Traffic...
    wtsrunner.trf_data_stop     ue=${UE_ID}    id=${BEARER_ID}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Traffic was stopped   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    Traffic was stopped   partial_match=${TRUE}
    Log to Console    ${output}
    ${trf_status}     Run Keyword And Ignore Error    Validate LTE Traffic   ${dl_rate}    ${ul_rate}   ${UE_ID}
    Should Be True    '${trf_status[0]}' == 'PASS'    msg=Traffic failed, see error above!

Start and Validate Traffic For SA
    [Arguments]    ${dl_rate}=5    ${ul_rate}=3    ${UE_ID}=${UE_ID}
    Log to Console    \nRunning DL + UL Traffic
    wtsrunner.trf_data_start     ue=${UE_ID}    pdu=1   qfi=1    dir=dl    mbps=${dl_rate}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=UDP DL TRF: .*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    ${output}
    wtsrunner.trf_data_start     ue=${UE_ID}   pdu=1   qfi=1    dir=ul    mbps=${ul_rate}
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=UDP UL TRF: .*    timeout=10
    Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}

Stop Data Traffic for SA
    [Arguments]     ${UE_ID}=${UE_ID}
    wtsrunner.trf_data_stop     ue=${UE_ID}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Traffic was stopped   timeout=10
    Get Lines Matching Regexp    ${output}    Traffic was stopped   partial_match=${TRUE}

Validate Traffic Data Loss For SA
    [Documentation]    SA Traffic Data Loss Criteria
    ...                1. DL Bytes Received must be equal to ALL Bytes Sent
    ...                2. UL Bytes Sent must be equal to ALL Bytes Received
    [Arguments]    ${UE_ID}=${UE_ID}
    wtsrunner.bearer_stats  ue=${UE_ID}   pdu=1   qfi=1   dir=dl
    ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check DL Data Loss      ${bearer_stat_dl}    ${bearer_stat_dl}    ${UE_ID}
    wtsrunner.bearer_stats  ue=${UE_ID}   pdu=1   qfi=1   dir=ul
    ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check UL Data Loss      ${bearer_stat_ul}    ${bearer_stat_ul}    ${UE_ID}

Start and Validate Traffic For Mixed Mode
    [Arguments]    ${dl_rate}=5    ${ul_rate}=3    ${duration}=10min
    Run Keyword If    (('${gnb_sm_hardware}' == 'ASIK') and ('${ap_sm_hardware}' == 'ASIK')) or ('${ap_sm_hardware}' == 'ASIL')
    ...    Run Keyword And Ignore Error    wtsrunner.sim_debug_log    level=4
    ${duration}       Get Variable Value    ${TRF_DURATION}    ${duration}
    ${tput_validate_list}=    Create List
    ${dataloss_validate_list}=    Create List
    Start Traffic For SA With Mixed Mode
    Start Traffic For NSA With Mixed Mode
    Run Keyword If    '${4G5G_Combo}'=='1'
    ...    Start Traffic For LTE With Mixed Mode
    Sleep             ${duration}
    ${tput_validate_list}    Verify Traffic Throughput or Data Loss    Validate Traffic Throughput Average Rate for SA
    ...    Validate Traffic Throughput Average Rate for NSA    ${dl_rate}    ${ul_rate}
    Stop Traffic For SA With Mixed Mode
    Stop Traffic For NSA With Mixed Mode
    Run Keyword If    '${4G5G_Combo}'=='1'
    ...    Stop Traffic For LTE With Mixed Mode
    Run Keyword If    (('${gnb_sm_hardware}' == 'ASIK') and ('${ap_sm_hardware}' == 'ASIK')) or ('${ap_sm_hardware}' == 'ASIL')
    ...    Run Keyword And Ignore Error    wtsrunner.sim_debug_log    level=0
    ${dataloss_validate_list}    Verify Traffic Throughput or Data Loss    Validate Traffic Data Loss For SA
    ...    Validate Traffic Data Loss for NSA    ${dl_rate}    ${ul_rate}
    List Should Not Contain Value    ${tput_validate_list}    FAIL    msg=Traffic failed in Throughput, see error above!
    List Should Not Contain Value    ${dataloss_validate_list}    FAIL    msg=Traffic failed in Data Loss, see error above!

Verify Traffic Throughput or Data Loss
    [Arguments]    ${sa_keyword}    ${nsa_keyword}    ${dl_rate}    ${ul_rate}
    ${result_status}=    Create List
    FOR   ${nsa_ueid}    ${sa_ueid}   IN ZIP   ${nsa_ueids}    ${sa_ueids}
        ${trf_sa_status}    Run Keyword And Ignore Error    ${sa_keyword}    ${dl_rate}    ${ul_rate}    ${sa_ueid}
        ${trf_nsa_status}    Run Keyword And Ignore Error    ${nsa_keyword}    ${dl_rate}    ${ul_rate}   ${nsa_ueid}
        ${status}    Run Keyword And Ignore Error    Should Be True
        ...   '${trf_sa_status[0]}' == 'PASS' and '${trf_nsa_status[0]}' == 'PASS'   msg=Traffic failed, see error above!
        Append To List    ${result_status}    ${status[0]}
    END
    [Return]    ${result_status}

Start Traffic For SA
    [Arguments]    ${UE_ID_SA}=1    ${dl_rate}=5    ${ul_rate}=3    ${duration}=10min
    Log to Console    \nRunning DL + UL SA Traffic for ${duration}...
    wtsrunner.trf_data_start     ue=${UE_ID_SA}    pdu=1   qfi=1    dir=dl    mbps=${dl_rate}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=UDP DL TRF: .*    timeout=60
    Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    wtsrunner.trf_data_start     ue=${UE_ID_SA}   pdu=1   qfi=1    dir=ul    mbps=${ul_rate}
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=UDP UL TRF: .*    timeout=60
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    ${output}

Start Traffic For SA With Mixed Mode
    FOR   ${ueid}   IN   @{sa_ueids}
        Start Traffic For SA   ${ueid}
        Log    ${ueid}
    END

Start Traffic For NSA
    [Arguments]    ${UE_ID_NSA}=1    ${dl_rate}=5    ${ul_rate}=3    ${duration}=10min
    Log to Console    \nRunning DL + UL NSA Traffic for ${duration}...
    wtsrunner.trf_data_start     ue=${UE_ID_NSA}    id=${BEARER_ID}    dir=dl    mbps=${dl_rate}
    Log    ${ul_rate}

Start Traffic For NSA With Mixed Mode
    FOR   ${ueid}   IN   @{nsa_ueids}
        Start Traffic For NSA   ${ueid}
        Log    ${ueid}
    END

Stop Traffic For SA
    [Arguments]    ${UE_ID_SA}
    Log to Console    Stopping DL + UL SA Traffic...
    wtsrunner.trf_data_stop     ue=${UE_ID_SA}   pdu=1   qfi=1
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Traffic was stopped   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    Traffic was stopped   partial_match=${TRUE}
    Log to Console    ${output}

Stop Traffic For SA With Mixed Mode
    FOR   ${ueid}   IN   @{sa_ueids}
        Stop Traffic For SA   ${ueid}
        Log    ${ueid}
    END

Stop Traffic For NSA
    [Arguments]    ${UE_ID_NSA}
    Log to Console    Stopping DL + UL NSA Traffic...
    wtsrunner.trf_data_stop     ue=${UE_ID_NSA}    id=${BEARER_ID}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Traffic was stopped   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    Traffic was stopped   partial_match=${TRUE}
    Log to Console    ${output}

Stop Traffic For NSA With Mixed Mode
    FOR   ${ueid}   IN   @{nsa_ueids}
        Stop Traffic For NSA   ${ueid}
	Log    ${ueid}
    END

Start Traffic For LTE
    [Arguments]    ${UE_ID}=1    ${dl_rate}=5    ${ul_rate}=3    ${duration}=10min
    ${duration}       Get Variable Value    ${TRF_DURATION}    ${duration}
    Log to Console    \nRunning DL + UL Traffic for ${duration}...
    wtsrunner.trf_data_start     ue=${UE_ID}    id=${BEARER_ID}    dir=dl    mbps=${dl_rate}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=UDP DL TRF: .*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    ${output}

    wtsrunner.trf_data_start     ue=${UE_ID}    id=${BEARER_ID}    dir=ul    mbps=${ul_rate}
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=UDP UL TRF: .*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    ${output}

Start Traffic For LTE With Mixed Mode
    FOR   ${ueid}   IN   @{lte_ueids}
        Start Traffic For LTE   ${ueid}
	Log    ${ueid}
    END

Stop Traffic For LTE
    [Arguments]    ${UE_ID}
    Log to Console    Stopping DL + UL LTE Traffic...
    wtsrunner.trf_data_stop     ue=${UE_ID}    id=${BEARER_ID}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Traffic was stopped   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    Traffic was stopped   partial_match=${TRUE}
    Log to Console    ${output}

Stop Traffic For LTE With Mixed Mode
    [Arguments]    ${dl_rate}=5    ${ul_rate}=3
    ${result_status}=    Create List
    FOR   ${ueid}   IN   @{lte_ueids}
        Stop Traffic For LTE   ${ueid}
        ${trf_lte_status}     Run Keyword And Ignore Error    Validate LTE Traffic   ${dl_rate}    ${ul_rate}   ${ueid}
        ${status}    Run Keyword And Ignore Error    Should Be True
        ...    '${trf_lte_status[0]}' == 'PASS'
        ...    msg=Traffic failed, see error above!
        Append To List    ${result_status}    ${status[0]}
    END
    List Should Not Contain Value    ${result_status}    FAIL    msg=Traffic failed, see error above!

NG link check using AMF Link Status
    [Arguments]    ${amf_id}=${AMF_ID}    ${gnb_id}=${Target_gNB}
    [Documentation]    This Keyword checks if the NG link status for the mentioned gNB ID using the amf_disp command
    ...    on egate console
    wtsrunner.amf_disp    id=${amf_id}    type=link_info    gnb=${gnb_id}
	${amf_link_status}=    Run Keyword And Return Status
    ...    wtsrunner.read_wtsemu_output_until_re    expected=${Ng_link_pattern}    timeout=60
    Run Keyword If    '${amf_link_status}'=='False' and '${4G5G_Combo}'=='1'
    ...    Search pattern should Exists In EGATE
    ...    ${WTS_DIR}/egate_console.log    ${Ng_link_pattern_dual_stack}
    ...    ELSE IF    '${amf_link_status}'=='True'    Log    "NG Link is UP"
    ...    ELSE    Fail    msg="NG Link is not Up"

S1 link check for eNB
    Search pattern should Exists In EGATE
    ...    ${WTS_DIR}/egate_console.log    ${S1_link_pattern_dual_stack}
    Log                S1_link_status_is_ok

Verify Syscom routes and DCI files
    Wait Until Keyword Succeeds    10min    60sec    Verify cOAM Syscom Routes and DCI

Verify cOAM Syscom Routes and DCI
    Run Keyword If    '${ap_sm_hardware}' == 'ASIK'    Verify AP DCI Link Files
    Run Keyword If    '${gnb_sm_hardware}' == 'ASIK'    Verify gnb DCI and Syscom routes

Verify AP DCI Link Files
    SSH.Connect To    ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}    alias=${AP_ASIK.Connection}
    Verify DCI Link Files    ${AP_ASIK}[Connection]
    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect    ${AP_ASIK}[Connection]

Verify gnb DCI and Syscom routes
    SSH.Connect To    ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}    alias=${GNB_ASIK.Connection}
    Verify DCI Link Files    ${GNB_ASIK}[Connection]
    Verify Syscom Routes for GNB
    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect    ${GNB_ASIK}[Connection]

Verify DCI Link Files
    [Arguments]    ${connection}
    FOR    ${index}    IN    @{CONN_CARDS}
        SSH.Send Command    ${index}    connection=${connection}
        ${status}    SSH.Assert File Exists    ${syscom_file}    ${connection}
        Run Keyword If    ${status}    Fail    msg= DCI file not exists
    END

Verify Syscom Routes for GNB
    ${result}         SSH.Execute   bsh 1:0 "echo "syscom -p 0x573a 10 10" | nc 0 15007"
    ...               ${GNB_ASIK}[Connection]
    Should Contain    ${result}    Total time to send/receive 10 mesages
    ...               msg=Error in GNB Syscom Routes!

Check for 6765-D feature enabled and Verify DCI
    Run Keyword And Ignore Error    Run    mkdir -p ${EXECDIR}/logs
    SSH.Connect To    ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}
    ...               alias=${GNB_ASIK.Connection}
    SSH.Download File    /ffs/run/swconfig.txt    ${EXECDIR}/logs/swconfig_gnb.txt
    ...               ${GNB_ASIK.Connection}
    SSH.Disconnect    ${GNB_ASIK.Connection}
    ${status}     Run    grep "^0x20109=1" ${EXECDIR}/logs/swconfig_gnb.txt | cut -d" " -f1
    ${6765D_status}    Run Keyword And Return Status    Should Not Be Equal    "${status}"    "0x20109=1"    msg=6765-D feature is enabled!
    Run Keyword If    ${6765D_status}    Verify Syscom routes and DCI files    ELSE    Verify AP DCI Link Files

Validate Traffic Throughput Average Rate for SA
    [Documentation]    SA Traffic Throughput Criteria
    ...                Average data rate must be within 90% and 110% of expected rate
    [Arguments]    ${dl_rate}    ${ul_rate}    ${UE_ID}=${UE_ID}
    wtsrunner.bearer_stats  ue=${UE_ID}   pdu=1   qfi=1   dir=dl
    ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate      ${bearer_stat_dl}    DL    ${dl_rate}    ${UE_ID}

    wtsrunner.bearer_stats  ue=${UE_ID}   pdu=1   qfi=1   dir=ul
    ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate      ${bearer_stat_ul}    UL    ${ul_rate}    ${UE_ID}

Validate Traffic Throughput Average Rate for NSA
    [Documentation]    NSA Traffic Throughput Criteria
    ...                Average data rate must be within 90% and 110% of expected rate
    [Arguments]    ${dl_rate}    ${ul_rate}    ${UE_ID}=1
    wtsrunner.bearer_stats    ue=${UE_ID}   id=${BEARER_ID}   dir=dl   dc_cell_group=scg
    ${bearer_stat_scg}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate      ${bearer_stat_scg}    DL    ${dl_rate}    ${UE_ID}
    wtsrunner.bearer_stats  ue=${UE_ID}   id=${BEARER_ID}   dir=ul
    ${bearer_stat_all}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate      ${bearer_stat_all}    UL    ${ul_rate}    ${UE_ID}

Add ca_5gair User in ssh config
    ${grep_status}    Get Status of SSH Config For ca_5gair User Details
    Return From Keyword If    '${grep_status}' == 'True'    ${grep_status}
    ${ssh_config_value}    Set Variable    \nHost gerrit*\n    \tIdentityFile ~/.ssh/id_rsa\n    \tUser ca_5gair\n
    Add Content To File    /home/ute/.ssh/config    ${ssh_config_value}
    ${command}    Catenate    sudo systemctl restart ssh.service
    Run    ${command}
    ${grep_status}    Get Status of SSH Config For ca_5gair User Details
    Run Keyword If    ${grep_status}    Log    SSH configuration failure
    [Return]    ${grep_status}

Get Status of SSH Config For ca_5gair User Details
    ${command}    Catenate    grep -i "User ca_5gair" ~ute/.ssh/config
    ${output}    Run    ${command}
    ${grep_status}    Run Keyword And Return Status    Should Contain    ${output}    User ca_5gair
    [Return]    ${grep_status}

Clone and Configure testconfigs repo
    ${command}    Catenate    rm -rf ${AP_configs} &&
    ...    git clone ssh://ca_5gair@gerrit.ext.net.nokia.com:29418/MN/5G/TEST/testconfigs ${AP_configs}
    Run    ${command}
    ${command}    Catenate    cd ${AP_configs} && git checkout master && git pull origin
    ...    && git config user.email I_MN_5G_AIRPHONE_CI@nokia.com && git config user.name ca_5gair
    Run    ${command}

Update SCF on testconfigs
    [Arguments]    ${gnb_scf_tl}    ${scf_from_repo}    ${nidd_value}
    Log To Console    \n NIDD changed, updating SCF from TL to 'testconfigs' repository...
    ${scf_install}    Set Variable if    '${gNB_P1_NIDD_Update_Flag}' == 'False'
    ...    ${gnb_scf_custom_config_file}    ${cloud_gnb_scf_custom_config_file}
    ${diff_cmd}    Catenate
    ...    cd ${AP_configs}
    ...    && git diff --no-index ${scf_install} ${scf_from_repo} > gnb_scf_patch_with_head.patch
    ${rc_git_diff}    ${output}    Run and Return RC and Output    ${diff_cmd}
    copy file    ${gnb_scf_tl}    ${scf_from_repo}
    Run Keyword And Return If    ${rc_git_diff} == None    Fail    msg=GIT DIFF command failed!!
    ${rc_apply_patch}    Run Keyword If    ${rc_git_diff} == 0
    ...    Log To Console    There is no difference between SCF file used during install and HEAD.
    ...    ELSE IF    ${rc_git_diff} == 1    Apply git patch    gnb_scf_patch_with_head.patch    ${scf_from_repo}
    Run Keyword And Return If    ${rc_apply_patch} == 1    Fail    msg=git patch apply command failed with error code ${rc_apply_patch}
    ${push_change}    Catenate
    ...    cd ${AP_configs} && git ls-files --modified | xargs git add
    ...    && git commit -m '[Auto] SCF file update with new NIDD version:${nidd_value}'
    ...    && git push origin master
    ${rc_git_push}    ${output}    Run and Return RC and Output    ${push_change}
    Log        ${output}
    Should Be Equal As Integers    ${rc_git_push}    0    msg=git patch apply command failed with error code ${rc_git_push}

Apply git patch
    [Arguments]    ${patch_file}    ${scf_from_repo}
    Log To Console    Applying GIT Patch...
    copy file    ${AP_configs}/${patch_file}    ${EXECDIR}/logs
    ${apply_patch}    Catenate
    ...    cd ${AP_configs}
    ...    && patch -i ${patch_file} -l -p1 ${scf_from_repo}
    ${rc}    ${output}    Run and Return RC and Output    ${apply_patch}
    Log To Console    ${output}
    Run Keyword If    ${rc} != 0    Log    git patch apply command failed with error code ${rc} ${output}    level=WARN
    [Return]    ${rc}

Get NIDD version
    [Arguments]    ${nidd1_scf_repo}    ${nidd1_scf_tl}    ${nidd2_scf_repo}    ${nidd2_scf_tl}
    ${nidd_value}    Evaluate    '${nidd1_scf_tl}' if ('${nidd1_scf_tl}' not in '${nidd1_scf_repo}') else None
    ${nidd_value}    Evaluate
    ...    '${nidd2_scf_tl}' if ('${nidd_value}' is 'None' and ('${nidd2_scf_tl}' not in '${nidd2_scf_repo}')) else '${nidd_value}'
    [Return]    ${nidd_value}

Is NIDD Update Required
    ${condition}    Catenate    SEPARATOR=${SPACE}    (('${Auto_NIDD_Update_Flag}' == 'True'
    ...    and (('${apConfiguration}' in @{Auto_NIDD_Update_Branch_Variants} and '${stream_nr}' != 'SBTS00')
    ...    or ('${apConfiguration}' in @{Auto_NIDD_Update_Trunk_Variants})))
    ...    or '${gNB_P1_NIDD_Update_Flag}' == 'True')
    ...    and '${CONDITIONAL_LOGGING}' == 'False' and '${SUITE STATUS}' == 'PASS'
    ${NIDD_Update}    Evaluate    ${condition}
    [Return]    ${NIDD_Update}

Verify install and suite topology match
    [Documentation]  This keyword will verify topology from install and suite topology
    ${topology_from_install}    Get Topology From Agent Logs
    ${topo_check}    Run Keyword And Return Status
    ...    Should be Equal   ${TOPOLOGY}    ${topology_from_install}    msg=${TOPOLOGY} and ${topology_from_install} are not matching
    [Return]    ${topo_check}

Get Topology From Agent Logs
    [Documentation]  This keyword will get the topology from Agent logs
    ${AP_status}   Run Keyword And Return Status    File Should Exist    ${testline_results_file}
    ${single_run_status}   Run Keyword And Return Status    File Should Exist    ${single_run_info_file}
    Return From Keyword If    '${AP_status}' == 'False' and '${single_run_status}' == 'True' and '${gNB_P1_NIDD_Update_Flag}' == 'False'
    ...    ${AP_status}
    ${agent_log_file}    Set Variable If    ${AP_status}   ${testline_results_file}    ${single_run_info_file}
    ${topology_from_install}    Get Topology from INFO File    ${agent_log_file}
    [Return]    ${topology_from_install}

Get Topology from INFO File
    [Arguments]    ${file_path}
    ${file_content}    OperatingSystem.Get File    ${file_path}
    ${topology_from_install}    Should Match Regexp    ${file_content}    LABEL:\\s+(\\S+)
    Log To Console    INFO file is present and Topology is ${topology_from_install[1]}
    [Return]    ${topology_from_install[1]}

Generate perf lua file from basic cfg file
    [Arguments]    ${wts_cfg_file}
	${sa_first_cell1}    Get Variable Value    ${SA_CELL1_FIRST}    1
	${sa_end_cell1}    Get Variable Value   ${SA_CELL1_FIRST}    10
	${nsa_first_cell1}    Get Variable Value   ${NSA_CELL1_FIRST}    11
	${nsa_end_cell1}    Get Variable Value   ${NSA_CELL1_FIRST}    20
	${sa_first_cell2}    Get Variable Value   ${SA_CELL2_FIRST}    101
	${sa_end_cell2}    Get Variable Value   ${SA_CELL2_FIRST}    110
	${nsa_first_cell2}    Get Variable Value   ${NSA_CELL2_FIRST}    111
	${nsa_end_cell2}    Get Variable Value   ${NSA_CELL2_FIRST}    120
    ${command}        Catenate     python ${lua_generator_script}
    ...    -cfg ${wts_cfg_file}    -first_sa_cell1 ${sa_first_cell1}    -end_sa_cell1 ${sa_end_cell1}
    ...    -first_nsa_cell1 ${nsa_first_cell1}    -end_nsa_cell1 ${nsa_end_cell1}
    ...    -first_sa_cell2 ${sa_first_cell2}    -end_sa_cell2 ${sa_end_cell2}
	...    -first_nsa_cell2 ${nsa_first_cell2}    -end_nsa_cell2 ${nsa_end_cell2}
    Log    ${command}
    Run    ${command}
    ${file_path}   ${filename}=    Split Path     ${wts_cfg_file}
    ${basename}   ${extention}=    Split Extension     ${filename}
    ${file}        Catenate     SEPARATOR=.   ${basename}   lua
    Log        file name ${filename} extension is ${extention} in ${file_path}
    File Should Exist    ${file}
    ...    msg='Ap P1Perf lua file doesn't exists at path ${file}
    Run    cp ${file} ${WTS_DIR}/${file}
    Set Suite Variable    ${SUITE_WTS_CFG}    ${file}
    Run    ls ${WTS_DIR}/*lua
    Log To Console    ${SUITE_WTS_CFG}
    Run Keyword    Update Perf UE ids list    ${sa_first_cell1}    ${sa_end_cell1}    ${nsa_first_cell1}
    ...    ${nsa_end_cell1}    ${sa_first_cell2}    ${sa_end_cell2}    ${nsa_first_cell2}    ${nsa_end_cell2}

Update Perf UE ids list
    [Arguments]    ${sa_first_cell1}    ${sa_end_cell1}    ${nsa_first_cell1}
    ...    ${nsa_end_cell1}    ${sa_first_cell2}    ${sa_end_cell2}    ${nsa_first_cell2}    ${nsa_end_cell2}
    @{sa_ueids_cell1}=    Create List
    @{nsa_ueids_cell1}=    Create List
    @{sa_ueids_cell2}=    Create List
    @{nsa_ueids_cell2}=    Create List
    @{gwidscell1}=    Create List
    @{gwidscell2}=     Create List
    @{targetCellsIds}=    Create List
    FOR    ${ueid}    IN RANGE      ${sa_first_cell1}    ${sa_end_cell1}+1    1
        Append To List    ${sa_ueids_cell1}    ${ueid}
        Append To List    ${gwids_cell1}    ${ueid}
    END
    FOR    ${ueid}    IN RANGE      ${sa_first_cell2}    ${sa_end_cell2}+1     1
        Append To List    ${sa_ueids_cell2}    ${ueid}
        Append To List    ${gwids_cell2}   ${ueid}
    END
    FOR    ${ueid}    IN RANGE      ${nsa_first_cell1}    ${nsa_end_cell1}+1    1
        Append To List    ${nsa_ueids_cell1}    ${ueid}
    END
    FOR    ${ueid}    IN RANGE      ${nsa_first_cell2}    ${nsa_end_cell2}+1    1
        Append To List    ${nsa_ueids_cell2}    ${ueid}
    END
    FOR    ${value}    IN RANGE    ${component_carrier}
        Append To List    ${targetCellsIds}   ${value+1}
    END
    Set Suite Variable    @{sa_ueids_cell1}
    Set Suite Variable    @{nsa_ueids_cell1}
    Set Suite Variable    @{sa_ueids_cell2}
    Set Suite Variable    @{nsa_ueids_cell2}
    Set Suite Variable    @{gwidscell1}
    Set Suite Variable    @{gwidscell2}
    Set Suite Variable    @{targetCellsIds}

Generate mmwv perf lua file from basic cfg file
    [Arguments]    ${wts_cfg_file}
    ${command}        Catenate     python ${lua_generator_mmwv_script}
    ...    -cfg ${wts_cfg_file}
    Log    ${command}
    Run    ${command}
    ${file_path}   ${filename}=    Split Path     ${wts_cfg_file}
    ${basename}   ${extention}=    Split Extension     ${filename}
    ${file}        Catenate     SEPARATOR=.   ${basename}   lua
    Log        file name ${basename} extension is ${extention} in ${file_path}
    File Should Exist    ${file}
    ...    msg='Ap P1Perf lua file doesn't exists at path ${file}
    Run    cp ${file} ${WTS_DIR}/${file}
    Set Suite Variable    ${SUITE_WTS_CFG}    ${file}
    Log To Console    ${SUITE_WTS_CFG}
