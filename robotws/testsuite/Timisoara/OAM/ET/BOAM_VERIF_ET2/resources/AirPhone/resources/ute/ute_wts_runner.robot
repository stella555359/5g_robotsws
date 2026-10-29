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
Library    ${CURDIR}/yaml_parser.py   WITH NAME    parser
Library    Collections
Resource    ../ute/coam.robot

*** Variables ***
&{AP_ASIK}     Ip=192.168.200.1    Username=toor4nsn    Password=oZPS0POrRieRtu    Connection=ApAsik
&{GNB_ASIK}    Ip=192.168.255.1    Username=toor4nsn    Password=oZPS0POrRieRtu    Connection=GnbAsik
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts

${WTS_DIR}             /opt/wts/latest
#${EGATE_CONFIG_DIR}    /airphone_cfg
${TL_INIT_DIR}         /home/ute/testline_update_results/logs

${UE_ID}        1
${BEARER_ID}    2
${Knife}        0

@{IP_LIST}  10.0.1.121  10.0.1.131  10.0.1.132  10.0.1.133  10.0.1.134  10.0.1.135  10.0.1.136  10.0.1.137

*** Keywords ***
Reach OnAir Setup for BL
    Set suite variables for BL
    Wait Coam Site to be Ready
    ute_wts_runner.Modify UTE SCTP Timeout
    ute_wts_runner.Start UTE WTS
    X2 Connection

Reach OnAir Setup for KL
    Set suite variables for KL
    Wait Coam Site to be Ready
    ute_wts_runner.Modify UTE SCTP Timeout
    ute_wts_runner.Start UTE WTS
    X2 Connection

Reach OnAir Setup for BO
    Set suite variables for BO
    Wait Coam Site to be Ready
    ute_wts_runner.Modify UTE SCTP Timeout
    ute_wts_runner.Start UTE WTS
    X2 Connection

Reach OnAir Setup for LO
    Set suite variables for LO
    Wait Coam Site to be Ready
    ute_wts_runner.Modify UTE SCTP Timeout
    ute_wts_runner.Start UTE WTS
    X2 Connection

Reach OnAir Setup for LO_AP_LO
    Set suite variables for LO_AP_LO
    Wait Coam Site to be Ready
    ute_wts_runner.Modify UTE SCTP Timeout
    ute_wts_runner.Start UTE WTS
    X2 Connection

Reach OnAir Setup for MO
    Set suite variables for MO
    Wait Coam Site to be Ready
    ute_wts_runner.Modify UTE SCTP Timeout
    ute_wts_runner.Start UTE WTS
    X2 Connection

Reach OnAir Setup for MP
    Set suite variables for MP
    Wait Coam Site to be Ready
    ute_wts_runner.Modify UTE SCTP Timeout
    ute_wts_runner.Start UTE WTS
    X2 Connection

Reach OnAir Setup for OE
    Get Cell Technology
    Run Keyword If  '${technology}' == 'TDD'  Set suite variables for OE TDD
    ...     ELSE    Set suite variables for OE FDD
    Wait Coam Site to be Ready
    ute_wts_runner.Modify UTE SCTP Timeout
    ute_wts_runner.Start UTE WTS
    X2 Connection

Reach onAir Teardown
    Run Keyword and Ignore Error    ute_wts_runner.Teardown Edaemon and Egate process

Set suite variables for OE TDD
    Set Suite Variable    ${SUITE_WTS_AP_XML}    AP_iphy_AEQE_ASOE_TDD_eCPRI_cmwv_SANSA_L1b_2S_1CC.xml
    Set Suite Variable    ${SUITE_WTS_CFG}       wts_config_ASOE_TDD_eCPRI_cmwv_SANSA_L1b_2S_1CC.cfg
    Set Suite Variable    ${SUITE_CFG_DIR_tmp}   ${CURDIR}/resources/l1b_tdd_sansa_ASOE_eCPRI_cmwv
    Set Suite Variable    ${EXCLUDE_LOGS}        0
    Set Suite Variable    ${apConfiguration}     l1b_tdd_sansa_ASOE_eCPRI_cmwv
    Set Suite Variable    ${gnb_sm_hardware}     ASOE
    Set Suite Variable    ${gnb_cp_hardware}     null
    Set Suite Variable    ${duplexing}           TDD
    Set Suite Variable    ${RF_type}             eCPRI
    Set Suite Variable    ${wavelength}          cmwv
    Set Suite Variable    ${deployment}          SANSA
    Set Suite Variable    ${l1}                  L1b
    Set Suite Variable    ${RU_type}             AEQE

Set suite variables for OE FDD
    Set Suite Variable    ${SUITE_WTS_AP_XML}    AP_iphy_AHLOA_ASOE_FDD_CPRI_cmwv_SANSA_FS.xml
    Set Suite Variable    ${SUITE_WTS_CFG}       wts_config_ASOE_FDD_CPRI_cmwv_SANSA_FS.cfg
    Set Suite Variable    ${SUITE_CFG_DIR_tmp}   ${CURDIR}/fa_fdd_sansa_asoe_cpri
    Set Suite Variable    ${EXCLUDE_LOGS}        0
    Set Suite Variable    ${apConfiguration}     fa_fdd_sansa_asoe_cpri
    Set Suite Variable    ${gnb_sm_hardware}     ASOE
    Set Suite Variable    ${gnb_cp_hardware}     null
    Set Suite Variable    ${duplexing}           FDD
    Set Suite Variable    ${RF_type}             CPRI
    Set Suite Variable    ${wavelength}          cmwv
    Set Suite Variable    ${deployment}          SANSA
    Set Suite Variable    ${l1}                  FS
    Set Suite Variable    ${RU_type}             AHLOA

Set suite variables for LO
    Set Suite Variable    ${SUITE_WTS_AP_XML}    AP_iphy_AEQE_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_2S_1CC.xml
    Set Suite Variable    ${SUITE_WTS_CFG}       wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_2S_1CC.cfg
    Set Suite Variable    ${SUITE_CFG_DIR_tmp}   ${CURDIR}/resources/l1b_tdd_sansa_ABIO_eCPRI_cmwv
    Set Suite Variable    ${EXCLUDE_LOGS}        0
    Set Suite Variable    ${apConfiguration}     l1b_tdd_sansa_ABIO_eCPRI_cmwv
    Set Suite Variable    ${gnb_sm_hardware}     ASIL
    Set Suite Variable    ${gnb_cp_hardware}     ABIO
    Set Suite Variable    ${duplexing}           TDD
    Set Suite Variable    ${RF_type}             eCPRI
    Set Suite Variable    ${wavelength}          cmwv
    Set Suite Variable    ${deployment}          SANSA
    Set Suite Variable    ${l1}                  L1b
    Set Suite Variable    ${RU_type}             AEQE

Set suite variables for LO_AP_LO
    Set Suite Variable    ${SUITE_WTS_AP_XML}    AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.xml
    Set Suite Variable    ${SUITE_WTS_CFG}       wts_config_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.cfg
    Set Suite Variable    ${SUITE_CFG_DIR_tmp}   ../resources/AirPhone/resources/fs_tdd_sansa_cmwv
    Set Suite Variable    ${EXCLUDE_LOGS}        0
    Set Suite Variable    ${apConfiguration}     fs_tdd_sansa_cmwv
    Set Suite Variable    ${gnb_sm_hardware}     ASIL
    Set Suite Variable    ${gnb_cp_hardware}     ABIO
    Set Suite Variable    ${duplexing}           TDD
    Set Suite Variable    ${RF_type}             eCPRI
    Set Suite Variable    ${wavelength}          cmwv
    Set Suite Variable    ${deployment}          SANSA
    Set Suite Variable    ${l1}                  FS
    Set Suite Variable    ${RU_type}             AEQE

Set suite variables for MO
    Set Suite Variable    ${SUITE_WTS_AP_XML}    AP_iphy_AEQE_MO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.xml
    Set Suite Variable    ${SUITE_WTS_CFG}       wts_config_MO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.cfg
    Set Suite Variable    ${SUITE_CFG_DIR_tmp}   ../resources/AirPhone/resources/fs_tdd_sansa_cmwv
    Set Suite Variable    ${EXCLUDE_LOGS}        0
    Set Suite Variable    ${apConfiguration}     fs_tdd_sansa_cmwv
    Set Suite Variable    ${gnb_sm_hardware}     ASIM
    Set Suite Variable    ${gnb_cp_hardware}     ABIO
    Set Suite Variable    ${duplexing}           TDD
    Set Suite Variable    ${RF_type}             eCPRI
    Set Suite Variable    ${wavelength}          cmwv
    Set Suite Variable    ${deployment}          SANSA
    Set Suite Variable    ${l1}                  FS
    Set Suite Variable    ${RU_type}             AEQE

Set suite variables for MP
    Set Suite Variable    ${SUITE_WTS_AP_XML}    AP_iphy_AEQE_MP_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.xml
    Set Suite Variable    ${SUITE_WTS_CFG}       wts_config_MP_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.cfg
    Set Suite Variable    ${SUITE_CFG_DIR_tmp}   ../resources/AirPhone/resources/fs_tdd_sansa_cmwv
    Set Suite Variable    ${EXCLUDE_LOGS}        0
    Set Suite Variable    ${apConfiguration}     fs_tdd_sansa_cmwv
    Set Suite Variable    ${gnb_sm_hardware}     ASIM
    Set Suite Variable    ${gnb_cp_hardware}     ABIP
    Set Suite Variable    ${duplexing}           TDD
    Set Suite Variable    ${RF_type}             eCPRI
    Set Suite Variable    ${wavelength}          cmwv
    Set Suite Variable    ${deployment}          SANSA
    Set Suite Variable    ${l1}                  FS
    Set Suite Variable    ${RU_type}             AEQE

Set suite variables for BO
    Set Suite Variable    ${SUITE_WTS_AP_XML}    AP_iphy_AEQE_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_2S_1CC.xml
    Set Suite Variable    ${SUITE_WTS_CFG}       wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_2S_1CC.cfg
    Set Suite Variable    ${SUITE_CFG_DIR_tmp}   ${CURDIR}/resources/l1b_tdd_sansa_ABIO_eCPRI_cmwv
    Set Suite Variable    ${EXCLUDE_LOGS}        0
    Set Suite Variable    ${apConfiguration}     l1b_tdd_sansa_ABIO_eCPRI_cmwv
    Set Suite Variable    ${gnb_sm_hardware}     ASIB
    Set Suite Variable    ${gnb_cp_hardware}     ABIO
    Set Suite Variable    ${duplexing}           TDD
    Set Suite Variable    ${RF_type}             eCPRI
    Set Suite Variable    ${wavelength}          cmwv
    Set Suite Variable    ${deployment}          SANSA
    Set Suite Variable    ${l1}                  L1b
    Set Suite Variable    ${RU_type}             AEQE

Set suite variables for BL
    Set Suite Variable    ${SUITE_WTS_AP_XML}    AP_iphy_AEQA_ASIB_ABIL_TDD_CPRI_cmwv_SANSA_FS.xml
    Set Suite Variable    ${SUITE_WTS_CFG}       wts_config_ASIB_ABIL_TDD_CPRI_cmwv_SANSA_FS.cfg
    Set Suite Variable    ${SUITE_CFG_DIR_tmp}   ../resources/AirPhone/resources/fs_tdd_sansa_ASIB_cmwv
    Set Suite Variable    ${EXCLUDE_LOGS}        0
    Set Suite Variable    ${apConfiguration}     fs_tdd_sansa_cmwv
    Set Suite Variable    ${gnb_sm_hardware}     ASIB
    Set Suite Variable    ${gnb_cp_hardware}     ABIL
    Set Suite Variable    ${duplexing}           TDD
    Set Suite Variable    ${RF_type}             CPRI
    Set Suite Variable    ${wavelength}          cmwv
    Set Suite Variable    ${deployment}          SANSA
    Set Suite Variable    ${l1}                  FS
    Set Suite Variable    ${RU_type}             AEQA

Set suite variables for KL
    Set Suite Variable    ${SUITE_WTS_AP_XML}    AP_iphy_AEQA_ASIK_ABIL_TDD_CPRI_cmwv_SANSA_FS.xml
    Set Suite Variable    ${SUITE_WTS_CFG}       wts_config_ASIK_ABIL_TDD_CPRI_cmwv_SANSA_FS.cfg
    Set Suite Variable    ${SUITE_CFG_DIR_tmp}   ../resources/AirPhone/resources/fs_tdd_sansa_cmwv
    Set Suite Variable    ${EXCLUDE_LOGS}        0
    Set Suite Variable    ${apConfiguration}     fs_tdd_sansa_cmwv
    Set Suite Variable    ${gnb_sm_hardware}     ASIK
    Set Suite Variable    ${gnb_cp_hardware}     ABIL
    Set Suite Variable    ${duplexing}           TDD
    Set Suite Variable    ${RF_type}             CPRI
    Set Suite Variable    ${wavelength}          cmwv
    Set Suite Variable    ${deployment}          SANSA
    Set Suite Variable    ${l1}                  FS
    Set Suite Variable    ${RU_type}             AEQA

Connect To WTS VM
    [Documentation]    Establish a ssh connection to the WTS machine where the simulator is present
    SSH.Connect to     hostname=${WTS.Ip}
    ...                username=${WTS.Username}
    ...                alias=${WTS.Connection}

Teardown Edaemon and Egate process
    [Documentation]    kill running Edaemon and Egate process
    wtsrunner.kill_wtsemu_edaemon    edaemon_port=22222   connection=${WTS.Connection}    sudo_password=ute
    sleep      5s
    wtsrunner.kill_wtsemu_egate      egate_port=20000     connection=${WTS.Connection}    sudo_password=ute

Start UTE WTS
    [Documentation]    Kill running WTS binaries if any, configure ETH3, retrieve files and configure WTS
    Stop Edaemon Egate

    Configure IP on VM

    Log to Console                 Starting WTS...
    Remove File                    ${WTS_DIR}/AirPhoneConfig*.xml
    Remove File                    ${WTS_DIR}/basic*.cfg
    Run Keyword If    ${Knife}==1   Copy Custom Files
    ...               ELSE    Copy WTS Common Config Files
    Connect To WTS VM
    wtsrunner.configure_wtsemu_edaemon    edaemon_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=22222
    ...                                   sudo_password=ute
    wtsrunner.configure_wtsemu_egate      egate_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=20000
    wtsrunner.start_wtsemu                egate_console_ip=${WTS.Ip}
    ...                                   egate_port=20000
    ${ls}    Run    ls ${WTS_DIR}/*cfg
    Log To Console    ${ls}
    ${cfg_filename}  set variable   ${WTS_DIR}/${SUITE_WTS_CFG}
    wtsrunner.configure                      file=${cfg_filename}
    wtsrunner.read_wtsemu_output_until_re    expected=SimMode is ready now     timeout=240
    wtsrunner.sim_state_disp
    wtsrunner.read_wtsemu_output_until_re    expected=The state is ACTIVE   timeout=120
#    Start fsyslog Service

X2 Connection
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup
#    [Setup]    Run Keywords    Stop Tcpdump For Init
#    ...                        AND    Start sosReport Tcpdump    cell_setup
    ${pattern}    Set Variable    ENB-1: X2AP Link with GNB-2 .* is up
    wtsrunner.enb_x2_link_up    enb=1    target=2
    ${output}    wtsrunner.read_wtsemu_output_until_re
    ...    expected=${pattern}    timeout=300
    ${output}    Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=${TRUE}
    Log to Console    \n${output}
    Log    x2_is_ok

Copy WTS Common Config Files
    ${AP_BUILD}                    Run    ls -l /opt/wts/ | grep latest
    ${AP_build_number}             Fetch From Right    ${AP_BUILD}    /opt/wts/
    Set Suite Variable             ${AP_configs}      ${CURDIR}/AP_configs_repo
    Run    rm -rf ${AP_configs}
    Run    git clone "https://gerrit.ext.net.nokia.com/gerrit/MN/5G/TEST/testconfigs" ${AP_configs}
    Run    cd ${AP_configs}; git checkout tags/${AP_build_number}
    ${config_yaml}=    Set Variable    ${AP_configs}/${stream_nr}/${deployment}/${l1}/config.yaml
    ${dic}=    parser.parse_yaml    ${config_yaml}    ${duplexing}    ${RF_type}
    ...    ${wavelength}    ${RU_type}    ${gnb_sm_hardware}    ${gnb_cp_hardware}
    Log    ${dic}
    ${ap_xml_file}=    Get From Dictionary    ${dic}   AP_iphy_xml
    ${wts_cfg_file}=    Get From Dictionary    ${dic}   WTS_config
    Run                cp ${AP_configs}/${ap_xml_file} ${WTS_DIR}/${SUITE_WTS_AP_XML}
    Run                cp ${AP_configs}/${wts_cfg_file} ${WTS_DIR}/${SUITE_WTS_CFG}

Copy Custom Files
    OperatingSystem.File Should Exist    ${EXECDIR}/custom_configs/wts/basic*.cfg
    ...    msg='File is not present at custom path.'
    OperatingSystem.File Should Exist    ${EXECDIR}/custom_configs/wts/Airphone*.xml
    ...    msg='File is not present at custom path.'
    Run    cp ${EXECDIR}/custom_configs/wts/basic*.cfg ${WTS_DIR}/${SUITE_WTS_CFG}
    Run    cp ${EXECDIR}/custom_configs/wts/Airphone*.xml ${WTS_DIR}/${SUITE_WTS_AP_XML}

Start fsyslog Service
    [Documentation]    Start fsyslog daemon
    Run                 killall fsyslog
    ${dir_exist_status}=    Run Keyword And Return Status   Directory Should Exist    ${EXECDIR}/logs
    Run Keyword If    '${dir_exist_status}' == 'False'    Run Keywords
    ...    Remove File    ${EXECDIR}/logs    AND     Create Directory     ${EXECDIR}/logs
    Create directory    ${EXECDIR}/logs/udpsyslog
    Run     rm -rf ${EXECDIR}/logs/udpsyslog/*
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
    Run           cd ${EXECDIR}/logs/ && ${WTS_DIR}/sosReport.sh -nr -c -s > /dev/null 2>\&1
    Run           ls ${EXECDIR}/logs/SosReport*.tgz

Collect fsyslog
    Run                 killall fsyslog
    Run                 tar -cvf ${EXECDIR}/logs/udpsyslog.tar.gz ${EXECDIR}/logs/udpsyslog/*.log.*
    Run Keyword And Ignore Error    Remove Files    ${EXECDIR}/logs/udpsyslog/*
    Remove Directory    ${EXECDIR}/logs/udpsyslog    recursive=True

Collect all logs via log_collector.sh
    Run and return rc and output    chmod +x ${CURDIR}/../../sh/log_collector.sh
    Run and return rc and output    cd ${OUTPUT_DIR} && ${CURDIR}/../../sh/log_collector.sh

wait_for_sib1_reception
    wtsrunner.read_wtsemu_output_until_re    expected=SystemInformationBlockType1    timeout=300

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
    wtsrunner.bearer_stats  ue=${UE_ID}   id=${BEARER_ID}   dir=dl
    ${bearer_stat_all}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    wtsrunner.bearer_stats  ue=${UE_ID}   id=${BEARER_ID}   dir=dl   dc_cell_group=scg
    ${bearer_stat_scg}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate      ${bearer_stat_scg}    DL    ${dl_rate}
    Check DL Data Loss      ${bearer_stat_all}    ${bearer_stat_scg}

    wtsrunner.bearer_stats  ue=${UE_ID}   id=${BEARER_ID}   dir=ul
    ${bearer_stat_all}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    wtsrunner.bearer_stats  ue=${UE_ID}   id=${BEARER_ID}   dir=ul   dc_cell_group=scg
    ${bearer_stat_scg}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate      ${bearer_stat_all}    UL    ${ul_rate}
    Check UL Data Loss      ${bearer_stat_all}    ${bearer_stat_scg}

Start Traffic
    [Arguments]    ${dl_rate}=5    ${ul_rate}=5    ${duration}=10min
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
    ${trf_status}     Run Keyword And Ignore Error    Validate Traffic    ${dl_rate}    ${ul_rate}
    Should Be True    '${trf_status[0]}' == 'PASS'    msg=Traffic failed, see error above!

Start and Validate Traffic For SA
    [Arguments]    ${dl_rate}=5    ${ul_rate}=3    ${duration}=10min
    ${duration}       Get Variable Value    ${TRF_DURATION}    ${duration}
    Log to Console    \nRunning DL + UL Traffic for ${duration}...
    wtsrunner.trf_data_start     ue=${UE_ID}    pdu=1   qfi=1    dir=dl    mbps=${dl_rate}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=UDP DL TRF: .*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    ${output}

    wtsrunner.trf_data_start     ue=${UE_ID}   pdu=1   qfi=1    dir=ul    mbps=${ul_rate}
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=UDP UL TRF: .*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    ${output}

    Sleep             ${duration}

    Log to Console    Stopping DL + UL Traffic...
    wtsrunner.trf_data_stop     ue=${UE_ID}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Traffic was stopped   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    Traffic was stopped   partial_match=${TRUE}
    Log to Console    ${output}
    ${trf_status}     Run Keyword And Ignore Error    Validate Traffic For SA    ${dl_rate}    ${ul_rate}
    Should Be True    '${trf_status[0]}' == 'PASS'    msg=Traffic failed, see error above!


Validate Traffic For SA
    [Documentation]    SA Traffic Criteria
    ...                1. Average data rate must be within 90% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    ...                3. UL Bytes Sent must be equal to ALL Bytes Received
    [Arguments]    ${dl_rate}    ${ul_rate}
    wtsrunner.bearer_stats  ue=${UE_ID}   pdu=1   qfi=1   dir=dl
    ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate      ${bearer_stat_dl}    DL    ${dl_rate}
    Check DL Data Loss      ${bearer_stat_dl}    ${bearer_stat_dl}

    wtsrunner.bearer_stats  ue=${UE_ID}   pdu=1   qfi=1   dir=ul
    ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate      ${bearer_stat_ul}    UL    ${ul_rate}
    Check UL Data Loss      ${bearer_stat_ul}    ${bearer_stat_ul}

Get Cell Technology
    ${bts_info}   Get Coam BTS Information
    ${cell_list}    Set Variable   ${bts_info['cells']['nr']}
    FOR   ${cell}  IN  @{cell_list}
       Set Suite Variable  ${technology}   ${cell['technology']}
#    \   Should Contain  ${technology}    TDD
    END

Configure IP on VM
    FOR  ${ip}  IN  @{IP_LIST}
        ${rc}=        Run    sudo ip addr add ${ip}/24 dev eth3
        ${output}=    Run    ip addr show dev eth3 | grep ${ip}
        Should Contain    ${output}    ${ip}
    END
