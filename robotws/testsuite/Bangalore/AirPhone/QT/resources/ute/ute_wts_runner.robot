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
Library     taf.config.wts    WITH NAME    wts_conf
Library    ${CURDIR}/python_keywords.py
Library    Collections
Library    taf.collectors.core      WITH NAME   core
Library    taf.collectors.btslog    WITH NAME   btslog
Library    ${CURDIR}/NIDD_update.py
Resource   coam.robot
Resource   sosReport.robot
Library     ../python/crash_detection/APCrashDetection.py    WITH NAME     crash_detection

*** Variables ***
${collect_cpu_data_flag}    False
@{CONN_CARDS}    bsh 0:0    bsh 0:1    bsh 1:0    bsh 1:1

${syscom_file}         /tmp/.dciLinkConfigured


${WTS_DIR}             /opt/wts/latest
#${EGATE_CONFIG_DIR}    /airphone_cfg
${TL_INIT_DIR}         /home/ute/testline_update_results/logs

${UE_ID}            1
${BEARER_ID}        2
${TCP_BEARER_ID}    3
${Knife}            0

${gnb_scf_custom_config_file}    /home/ute/workspace/UTE_E2E/PROD/E2E_TESTS/e2e_tests/custom_configs/sm/scfc.xml
${cloud_gnb_scf_custom_config_file}    /home/ute/testline_init_results/configs/common/sm/scfc.xml
${trs_stats_file}                  ${CURDIR}/../scripts/trf_stats_logger.sh

*** Keywords ***
Connect To WTS VM
    [Documentation]    Establish a ssh connection to the WTS machine where the simulator is present
    SSH.Connect to     hostname=${WTS.Ip}
    ...                username=${WTS.Username}
    ...                alias=${WTS.Connection}

    ${command}        Catenate    sysctl -w net.sctp.sack_timeout=20 &&
    ...               sysctl -w net.sctp.rto_min=400 &&
    ...               sysctl -w net.sctp.rto_initial=400 &&
    ...               sysctl -w net.sctp.rto_max=800
    Run               ${command}
    Run               cat /proc/sys/net/sctp/rto_min

Teardown Edaemon and Egate process
    [Documentation]    kill running Edaemon and Egate process
    wtsrunner.kill_wtsemu_edaemon    edaemon_port=22222   connection=${WTS.Connection}    sudo_password=ute
    sleep      5s
    wtsrunner.kill_wtsemu_egate      egate_port=20000     connection=${WTS.Connection}    sudo_password=ute

Start wts interface stats collection
    Run    cp ${perf_wts_stats_script} ${EXECDIR}/
    Run    chmod 777 wts_interface_stats.sh
    Sleep    2s
    Run     ./wts_interface_stats.sh >> ${EXECDIR}/wts_interface_stats.txt &

Stop and Collect WTS Interface Stats
    Run    pkill -f ./wts_interface_stats.sh
    Run    mv ${EXECDIR}/wts_interface_stats.txt ${EXECDIR}/logs
    Run    rm -rf ${EXECDIR}/wts_interface_stats.txt

Download of WTS config Files
    Remove File                    ${WTS_DIR}/AirPhoneConfig*.xml
    Remove File                    ${WTS_DIR}/basic*.cfg
    ${status}    Run Keyword And Return Status    File Should Exist    ${test_property_file}
    Run Keyword If    ${Knife}==1 or '${perf_mue}' == 'True' or '${IWF_ENABLED}' == 'True'
    ...               Copy Custom Files
    ...               ELSE IF    "${status}" == "True" and "${Knife}" != "1"    Copy WTS master Configs
    ...               ELSE    Copy WTS Common Config Files

Start UTE WTS
    [Documentation]    Kill running WTS binaries if any, configure ETH3, retrieve files and configure WTS
    Stop Edaemon Egate
    Configure UTE ETH3
    Run Keyword If    '${4G5G_Combo}'=='1' and '${variant_name}' == '4G5G_COMBO_MultiUE'    Configure UTE and IPV6 ETH3
    ...    ELSE IF    '${4G5G_Combo}'=='1'    Configure IPV6 ETH3
    Run Keyword If    '${4G5G_CUS}'=='1' and '${variant_name}' == '4G5G_CUS_MultiUE'    Configure UTE and IPV6 ETH3 FOR CUS
    ...    ELSE IF    '${4G5G_CUS}'=='1'    Configure UTE ETH3 and ETH4 FOR CUS
    Run Keyword If    '${BOAM_ET_CONF}'=='1'
    ...    Configure UTE ETH3 FOR BOAM_ET_CONF
    Log to Console                 Starting WTS...
    Add ca_5gair User in ssh config
    Run Keyword If    '${variant_name}' == '4G5G_CUS_MultiUE'    Copy CUS MultiUE lua file
    ${SKIP_WTS_CONFIG_DL}    Get Variable Value    ${WTS_CONFIG}    False
    Run Keyword If    '${SKIP_WTS_CONFIG_DOWNLOAD}' == 'False' and '${SKIP_WTS_CONFIG_DL}' == 'False'    Download of WTS config Files
    Run Keyword If    '${SKIP_WTS_CONFIG_DL}' == 'True'    Run    cp ${WTS_DIR}/basic_setup.cfg ${WTS_DIR}/${SUITE_WTS_CFG}
    Run Keyword If    '${4G5G_CUS}' == '1' or '${variant_name}' == '4G5G_CUS_MultiUE'    Enable Uexgate for CUS
    Update Bearer Configuration For TCP Traffic
    Run Keyword If    '${WTS_Config_update_Flag}' == 'True'   Update WTS config file for Htput
    Connect To WTS VM
    wtsrunner.configure_wtsemu_edaemon    edaemon_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=22222
    ...                                   sudo_password=ute
    wtsrunner.configure_wtsemu_egate      egate_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=20000
    ...                                   nostats=True
    wtsrunner.start_wtsemu                egate_console_ip=${WTS.Ip}
    ...                                   egate_port=20000
    ${ls}    Run    ls ${WTS_DIR}/*cfg
    Log To Console    ${ls}
    ${cfg_filename}  set variable   ${WTS_DIR}/${SUITE_WTS_CFG}
    wtsrunner.configure                      file=${cfg_filename}
    Run Keyword If    '${apConfiguration}' == 'fs_tdd_sa_eCpri_cmwv_E_AP_E_6G'    Enable Radio for 6G usage
    wtsrunner.read_wtsemu_output_until_re    expected=SimMode is ready now     timeout=240
    Wait Until Keyword Succeeds    2 min    30 sec    Verify if sim state is active
    Run Keyword If    '${MAX_THROUGHPUT}' == 'True'    Testmode enable
    ${start_fsyslog}    Catenate    '${variant_name}' != '4G5G_COMBO_MultiUE' and  '${variant_name}' != '4G5G_CUS_MultiUE'
    Run Keyword If    ${start_fsyslog}    wait until keyword succeeds    3min    1min    Start syslog Service

Enable Radio for 6G usage
    ${cells_info}=    Run Keyword    Get all cells from BTS
    ${total_cells}=    Get Length    ${cells_info}
    Set Suite Variable    ${total_cells}
    Log    Total number of cells: ${total_cells}
    ExternalAPConnect.Connect Ap Egate To External Ap Server    ${JUMP_HOST}    ${JUMP_USERNAME}
    ...    ${JUMP_PASSWORD}    ${JUMP_PORT}
    Run Keyword If    ${total_cells} == 1    ExternalAPConnect.Execute Ap Egate Command    cfg_sim file=/user/egate/FCT_GOLDEN_1CC_3UPF.lua
    ...    ELSE    ExternalAPConnect.Execute Ap Egate Command    cfg_sim file=/user/egate/FCT_GOLDEN_2CC_6UPF.lua
    ${status}=    Run Keyword And Return Status    ExternalAPConnect.Wait For RU Detection In Ap Egate
    ...    NEW RADIO UNIT \\[1\\] DETECTED\\. STATE\\: DETECTED .*    240
    Run Keyword If    not ${status}    FAIL    Radio unit is not detected
    FOR    ${index}    IN RANGE    ${total_cells}
        ${gscn}=    Set Variable    ${gscns[${index}]}
        ${arfcn}=    Set Variable    ${arfcs[${index}]}
        ${output}=    ExternalAPConnect.Carrier Activation Req Ota    1    77    100    ${gscn}    ${arfcn}    json    0.5
        Log    Carrier Activation Output for Cell ${index}: ${output}
    END
    ExternalAPConnect . Disconnect External Ap Server

Verify if sim state is active
    wtsrunner.sim_state_disp
    wtsrunner.read_wtsemu_output_until_re    expected=The state is ACTIVE   timeout=20

Copy WTS Common Config Files
    Set Suite Variable             ${AP_configs}      ${CURDIR}/AP_configs_repo
    Run    rm -rf ${AP_configs}
    Run    git clone "ssh://ca_5gair@gerrit.ext.net.nokia.com:29418/MN/5G/TEST/testconfigs" ${AP_configs}
    Get config files

Copy CUS MultiUE lua file
    ${cmd}=    Catenate    cp ${EXECDIR}/custom_configs/${ute_ca_variant}/basic.lua
    ...    ${WTS_DIR}/${SUITE_WTS_CFG}
    Run    ${cmd}
    Set Suite Variable    ${SUITE_WTS_CFG}

Copy WTS master Configs
    Set Suite Variable             ${AP_configs}     ${EXECDIR}/testconfigs
    Get config files

Get config files
    ${AP_BUILD}                    Run    ls -l /opt/wts/ | grep latest
    ${AP_build_number}             Fetch From Right    ${AP_BUILD}    /opt/wts/
    ${result}=    Run Keyword and Return Status    Should Match Regexp    ${AP_build_number}    ^\\d
    ${AP_tag}=    Run Keyword If    '${result}' == 'False'    Get Ap Build for Common Agent
    ...    ELSE    Set Variable    ${AP_build_number}
    Run    cd ${AP_configs}; git checkout tags/${AP_tag}
    Run Keyword if    ('${4G5G_Combo}' == '1' or '${4G5G_CUS}' == '1')    Get config files from new yaml parser
    ...    ELSE    Get config files from old yaml parser
    Run Keyword If    '${IWF_ENABLED}' == 'True' and '${test_label}' == 'Perf_Mue'
    ...    Perf Lua file copy    ${WTS_DIR}/${SUITE_WTS_CFG}
    Run Keyword If    '${IWF_ENABLED}' == 'True' and '${test_label}' != 'Perf_Mue'
    ...    Replace Lua Files for Perf IWF    ${WTS_DIR}/${SUITE_WTS_CFG}

Get Ap Build for Common Agent
    ${file_list}=    Create List    ${single_run_info_for_ca}    ${Init_Path}    ${ute_logs_path}    ${workspace_path}
    FOR    ${file}    IN    @{file_list}
        ${result}   ${value} =   Run Keyword And Ignore Error    File Should Exist    ${file}
        ${pattern}=    Run Keyword If    '${result}' == 'PASS'    Get Pattern From File    ${file}
        Continue For Loop If    '${pattern}' == 'None'
        Return From Keyword If    '${pattern}' != 'None'    ${pattern}
    END

Get Pattern From File
    [Arguments]    ${LOG_FILE_PATH}
    ${LOG_File}=    Get file    ${LOG_FILE_PATH}
    ${matches}=    Get regexp matches    ${LOG_File}    ${AP_Pattern}.\\d+.\\d+.\\d+
    ${matches}=    Set Variable    ${matches[0]}
    ${string_match}=    Set Variable    ${matches.split("_"[0])}
    [Return]    ${string_match}[1]

Get config files from old yaml parser
    ${config_yaml}=    Set Variable    ${AP_configs}/${stream_nr}/${deployment}/${l1}/config.yaml
    ${dic}=    parser.parse_yaml    ${config_yaml}    ${duplexing}    ${RF_type}
    ...    ${wavelength}    ${RU_type}    ${gnb_sm_hardware}    ${gnb_cp_hardware}
    ...    ${ap_sm_hardware}    ${ap_cp_hardware}    ${component_carrier}
    Log    ${dic}
    ${wts_cfg_file}=    Get From Dictionary    ${dic}   WTS_config
    Run                cp ${AP_configs}/${wts_cfg_file} ${WTS_DIR}/${SUITE_WTS_CFG}
    Run Keyword If    '${AP_P1Perf}' == 'True' and '${test_label}' != 'SA20'
    ...    Generate perf lua file from basic cfg file    ${AP_configs}/${wts_cfg_file}
    ...    ${lua_generator_script}
    Run Keyword If    '${AP_P1Perf}' == 'True' and '${test_label}' == 'SA20'
    ...    Copy CA Lua file    ${WTS_DIR}/${SUITE_WTS_CFG}
    Run Keyword If    '${perf_mue}' == 'True' and '${test_label}' == '144UEDL'
    ...    Copy CA Lua file    ${WTS_DIR}/${SUITE_WTS_CFG}
    Run Keyword If    '${AP_P1Perf_mmwv}' == 'True'    Generate mmwv perf lua file from basic cfg file
    ...    ${AP_configs}/${wts_cfg_file}
    Run Keyword If    '${perf_mue}' == 'True'    Perf Lua file copy    ${WTS_DIR}/${SUITE_WTS_CFG}
    Run Keyword If    '${Fdd_Perf}' == 'True'   Copy CA Lua file    ${WTS_DIR}/${SUITE_WTS_CFG}
    Run Keyword If    '${AP_P1Perf_ABIL}' == 'True'    Generate perf lua file from basic cfg file
    ...    ${AP_configs}/${wts_cfg_file}    ${lua_generator_fdd_abil}

Get config files from new yaml parser
    ${config_yaml}=    Set Variable    ${AP_configs}/${TOPOLOGY}/${stream_nr}/config.yaml
    ${wts_files_list}=    Get custom file from Yaml Parser    ${config_yaml}    ${variant_name}
    FOR    ${each_file}   IN   @{wts_files_list}
        File Should Exist    ${AP_configs}/${TOPOLOGY}/${stream_nr}/${each_file}
        ...    msg='File doesn't exists at path ${AP_configs}/${TOPOLOGY}/${stream_nr}/${each_file}'
        ${path}   ${extention}=    Split Extension     ${each_file}
        Run Keyword if    '${extention}' == 'cfg'   Run
        ...   cp ${AP_configs}/${TOPOLOGY}/${stream_nr}/${each_file} ${WTS_DIR}/${SUITE_WTS_CFG}
        ${lua_extention}    Catenate   '${extention}' == 'lua' and ('${4G5G_Combo}' == '1' or '${4G5G_CUS}' == '1')
        ...    and ('${variant_name}' == '4G5G_COMBO_MultiUE' or '${variant_name}' == '4G5G_CUS_MultiUE')
        Run Keyword if    ${lua_extention}    Copy MultiUE lua file    ${each_file}
    END

Copy MultiUE lua file
    [Arguments]    ${file}
    Run    cp ${AP_configs}/${TOPOLOGY}/${stream_nr}/${file} ${WTS_DIR}/${file}
    Set Suite Variable    ${SUITE_WTS_CFG}    ${file}

Get custom file from Yaml Parser
    [Arguments]    ${config_yaml_path}    ${variant_name}
    ${wts_files_list}=    parser.print_yaml_config    ${config_yaml_path}    ${variant_name}
    Log    ${wts_files_list}
    [Return]    ${wts_files_list}

Copy Custom Files
    Run Keyword if    ('${4G5G_Combo}' == '1' or '${4G5G_CUS}' == '1')    Copy Custom files for new testconfigs format
    ...    ELSE    Copy Custom files for old testconfigs format

Copy Custom files for old testconfigs format
    File Should Exist    ${EXECDIR}/custom_configs/wts/basic*.cfg
    ...    msg='File is not present at custom path.
    Run    cp ${EXECDIR}/custom_configs/wts/basic*.cfg ${WTS_DIR}/${SUITE_WTS_CFG}
    Run Keyword If    '${perf_mue}' == 'True'    Perf Lua file copy    ${WTS_DIR}/${SUITE_WTS_CFG}
    Run Keyword If    '${IWF_ENABLED}' == 'True' and '${test_label}' == 'Perf_Mue'
    ...    Perf Lua file copy    ${WTS_DIR}/${SUITE_WTS_CFG}
    Run Keyword If    '${IWF_ENABLED}' == 'True' and '${test_label}' != 'Perf_Mue'
    ...    Replace Lua Files for Perf IWF    ${WTS_DIR}/${SUITE_WTS_CFG}

Copy Custom files for new testconfigs format
    Set Suite Variable             ${AP_configs}     ${EXECDIR}/testconfigs
    Get config files from new yaml parser

Start fsyslog Service
    [Documentation]    Start fsyslog daemon
    Run                 killall fsyslog
    ${dir_exist_status}=    Run Keyword And Return Status   Directory Should Exist    ${EXECDIR}/logs
    Run Keyword If    '${dir_exist_status}' == 'False'    Run Keywords
    ...    Remove File    ${EXECDIR}/logs    AND     Create Directory     ${EXECDIR}/logs
    Create directory    ${vm_logdir}/udpsyslog
    Remove files        ${vm_logdir}/udpsyslog/*
    ${command}          Catenate    ${WTS_DIR}/fsyslog --log-dir=${EXECDIR}\/logs\/udpsyslog
    ...                 --log-file-name=udpsyslog.log
    Run                 ${command}

Start syslog Service
    [Arguments]    ${host_ip}=127.0.0.1    ${user}=ute    ${password}=ute
    ${executor_test_vm}=  Create Dictionary
    ...  host=${host_ip}
    ...  user=${user}
    ...  password=${password}
    btslog.create_btslog_collector
    ...     name=${btslog_collector_name}
    ...     executor=${executor_test_vm}
    btslog.setup_collectors    names=${btslog_collector_name}
    btslog.start_collectors    names=${btslog_collector_name}
    btslog.set_suite_alias     ${btslog_collector_name}

Test case updates required when Crash is detected
    Set Suite Variable    ${skip_logs}    0
    Fail    Crash Detected from Logs

Stop and collect btslog
    [Arguments]    ${target_dir}=${vm_logdir}/
    btslog.stop_collectors         names=${btslog_collector_name}
    btslog.collect_collectors      names=${btslog_collector_name}   target_dir=${target_dir}
    btslog.teardown_collectors     names=${btslog_collector_name}

Stop btslogger and collect syslogs
    [Arguments]    ${target_dir}=${vm_logdir}/
    ${stop_status}    ${stop_output}    Run Keyword And Ignore Error    Stop and collect btslog    ${target_dir}
    Return From Keyword If   '${crash_detection_complete_flag}' == 'True' or '${ENABLE_CRASH_DETECTION}' != 'True'    PASS
    ${status}    ${output}    Run Keyword Without Failure
    ...    crash_detection.airphone_crash_detection    ${vm_logdir}/btslog/syslog_files.tgz
    Set Suite Variable    ${crash_detection_complete_flag}    True
    wtsrunner.script    file=${run_script_log_set}    entry=sim_log_re()
    Run Keyword If    "${stop_status}" == "PASS" and "${status}" == "PASS" and "${output}" == "True"
    ...    Test case updates required when Crash is detected

Kill Syslog Process
    ${output}=    Run Process    pgrep    btslog    shell=True
    ${stdout}=    Set Variable    ${output.stdout.strip()}
    Log To Console   Found PIDs: ${stdout}
    ${pids}=    Evaluate    str(${stdout}).splitlines()
    FOR    ${pid}    IN    @{pids}
        Run Process    kill    -9    ${pid}    shell=True
        Log To Console    Killed PID: ${pid}
    END

Stop Edaemon Egate
    [Documentation]    Kill edaemon and egate if already running.
    ${edaemon_pid}=    Run    pgrep edaemon
    ${edaemon_status}    Run Keyword and Return Status    Should Not Be Empty    ${edaemon_pid}
    Run Keyword If    ${edaemon_status}    Run    sudo pkill -9 edaemon
    ${egate_pid}=    Run    pgrep egate
    ${egate_status}    Run Keyword and Return Status    Should Not Be Empty    ${egate_pid}
    Run Keyword If    ${egate_status}    Run    sudo pkill -9 egate
    Run Keyword If    ${edaemon_status} or ${egate_status}    sleep      5s

Configure UTE ETH3
    Run    sudo ip addr add 10.0.1.131/24 dev eth3
    Run    sudo ip addr add 10.0.1.132/24 dev eth3
    Run    sudo ip addr add 10.0.1.133/24 dev eth3
    Run    sudo ip addr add 10.0.1.134/24 dev eth3
    Run    sudo ip addr add 10.0.1.135/24 dev eth3
    Run    sudo ip addr add 10.0.1.136/24 dev eth3
    Run    sudo ip addr add 10.0.1.99/24 dev eth3
    Run    sudo ip addr add 10.0.1.121/24 dev eth3
    Run    sudo ip addr add 10.0.1.137/24 dev eth3
    Run    sudo ip addr add 10.0.1.200/24 dev eth3

Configure IPV6 ETH3
    Run    sudo ip addr add fc00::0001/116 dev eth3
    Run    sudo ip addr add fc00::0131/116 dev eth3
    Run    sudo ip addr add fc00::0132/116 dev eth3
    Run    sudo ip addr add fc00::0133/116 dev eth3
    Run    sudo ip addr add fc00::099/116 dev eth3
    Run    sudo ip addr add fc00::0121/116 dev eth3

Configure UTE ETH3 and ETH4 FOR CUS
    Run    sudo ip addr add fc00::a00:0001/64 dev eth3
    Run    sudo ip addr add fc00::a00:0133/64 dev eth3
    Run    sudo ip addr add fc00::a00:132/64 dev eth3
    Run    sudo ip addr add fc00::a00:131/64 dev eth3
    Run    sudo ip r add 185.4.0.0/16 via 10.0.2.1 dev eth4
    Run    sudo ip a a 10.0.2.10/24 dev eth4
    Run    sudo iptables -I INPUT -p tcp -d 0/0 -j ACCEPT

Configure UTE ETH3 FOR BOAM_ET_CONF
    Run    sudo ip addr add 10.0.1.138/24 dev eth3

Configure UTE and IPV6 ETH3
    Run    sudo ip addr del 10.0.1.99/24 dev eth3
    Run    sudo ip addr del fc00::099/116 dev eth3
    Run    sh ${CURDIR}/../scripts/sudo_ips_mue.sh

Configure UTE and IPV6 ETH3 FOR CUS
    Run    sh ${sudo_ips_for_cus_multi_ues}

Modify UTE SCTP Timeout
    [Documentation]    Starting AirPhone load 4.0.10852, the sack timeout in the WTS VM and AP ASIK must be
    ...                configured before cell setup. This aims to prevent delayed messaging between AirPhone
    ...                and WTS (e.g. CTRL_ADD_UE_NR for attach procedure).
    SSH.Connect To    ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}
    ...               alias=${AP_ASIK.Connection}
    ${command}        Catenate    sysctl -w net.sctp.sack_timeout=10 &&
    ...               sysctl -w net.sctp.rto_min=100 &&
    ...               sysctl -w net.sctp.rto_initial=100 &&
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
    Run Keyword If    'CLOUD_5GC_d' in '${TOPOLOGY}'    Collect CU Snapshot And SCF
    ...    ELSE IF    '${apConfiguration}' == 'fs_tdd_sa_eCpri_cmwv_E_AP_E_6G'    Collect UTE Files 6G
    ...    ELSE    Run Keywords    Get Coam SCF    AND    Collect UTE Files
    Log to Console            Collecting all logs...
    Run Keyword And Ignore Error    Collect gNB_BIP_Logs
    Stop btslogger and collect syslogs
    Run Keyword If    '${4G5G_Combo}'!='1' and '${4G5G_CUS}'!='1' and '${Collect_Sosreport}' == 'True'
    ...    Run Keyword And Ignore Error    Collect gNB Snapshot via adminAPI
    Run Keyword If    '${Collect_Sosreport}' == 'True'    Collect UTE SosReport
    Run Keyword If    '${4G5G_Combo}'=='1'    Collect 4G SosReport
    Collect all logs via log_collector.sh

Collect gNB_BIP_Logs
    Run   cd ${vm_logdir}/ && tar -czvf BIP_Logs.tar.gz BIP/
    Run   rm -r ${vm_logdir}/BIP

Collect UTE Configs
    Log to Console            Collecting configs...
    Run Keyword If    'CLOUD_5GC_d' in '${TOPOLOGY}'    Collect CU Snapshot And SCF
    ...    ELSE IF    '${apConfiguration}' == 'fs_tdd_sa_eCpri_cmwv_E_AP_E_6G'    Collect UTE Files 6G
    ...    ELSE    Run Keywords    Get Coam SCF    AND    Collect UTE Files
    Stop btslogger and collect syslogs
    Log to Console            Collecting snapshot logs...
    Run Keyword If    '${4G5G_Combo}'!='1' and '${4G5G_CUS}'!='1' and '${Collect_Sosreport}' == 'True'
    ...    Run Keyword And Ignore Error    Collect gNB Snapshot via adminAPI
    Run Keyword If    '${Collect_Sosreport}' == 'True'    Collect UTE SosReport

Collect CU Snapshot
    [Arguments]    ${path}
    Log To Console    Collecting Snapshot from CU
    ${timestamp}    Get Current Date    result_format=%d.%m_%H-%M
    Run    mkdir ${path}
    coam_cu.get_local_snapshot    directory=${path}
    Run                           cd ${path}; tar czf Snapshot_CU_${timestamp}.tgz *.*
    Run                           cp ${path}/Snapshot_CU* ${EXECDIR}/logs/
    Run                           rm -rf ${path}/Snapshot*
    Log To Console                CU Snapshot collected successfully...

Collect vDU Snapshot
    ${timestamp}                  Get Current Date    result_format=%d.%m_%H-%M
    Create Directory          ${vm_logdir}/vDU_Snapshot
    vDU.get_local_snapshot    directory=${vm_logdir}/vDU_Snapshot
    Run                           cd logs; tar -cvf vDU_Snapshot.tar.gz vDU_Snapshot
    Log To Console                vDU Snapshot collected successfully...
    Run                           cd logs; rm -rf vDU_Snapshot

Collect UTE Files 6G
    Copy Files       ${WTS_DIR}/${SUITE_WTS_CFG}
    ...              ${TL_INIT_DIR}/DEBUG_log.txt    ${TL_INIT_DIR}/INFO_log.txt    ${vm_logdir}/
    # SSH.Connect To   ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}
    # ...              alias=${AP_ASIK.Connection}
    SSH.Connect To   ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}
    ...              alias=${GNB_ASIK.Connection}
    @{configs}       Create List    /ffs/run/swconfig.txt    /rom/simmode/iphy.xml
    # SSH.Download File    ${configs}    ${vm_logdir}/    ${AP_ASIK.Connection}
    SSH.Download File    /ffs/run/swconfig.txt    ${vm_logdir}/swconfig_gnb.txt
    ...              ${GNB_ASIK.Connection}
    Get Coam SCF
    # SSH.Disconnect   ${AP_ASIK.Connection}
    SSH.Disconnect   ${GNB_ASIK.Connection}

Collect UTE Files
    Copy Files       ${WTS_DIR}/${SUITE_WTS_CFG}
    ...              ${TL_INIT_DIR}/DEBUG_log.txt    ${TL_INIT_DIR}/INFO_log.txt    ${vm_logdir}/
    SSH.Connect To   ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}
    ...              alias=${AP_ASIK.Connection}
    SSH.Connect To   ${GNB_ASIK.Ip}    ${GNB_ASIK.Username}    ${GNB_ASIK.Password}
    ...              alias=${GNB_ASIK.Connection}
    @{configs}       Create List    /ffs/run/swconfig.txt    /rom/simmode/iphy.xml
    SSH.Download File    ${configs}    ${vm_logdir}/    ${AP_ASIK.Connection}
    SSH.Download File    /ffs/run/swconfig.txt    ${vm_logdir}/swconfig_gnb.txt
    ...              ${GNB_ASIK.Connection}
    SSH.Disconnect   ${AP_ASIK.Connection}
    SSH.Disconnect   ${GNB_ASIK.Connection}

Collect UTE SosReport
    Run Keyword And Return If    '${apConfiguration}' == 'fs_tdd_sa_eCpri_cmwv_E_AP_E_6G'
    ...     Collect Logs For 6G
    #wtsrunner.sim_log_set   flush
    ${command}    Catenate    sed -i \'s@LOG_DIR_ON_DEVICE=.*@LOG_DIR_ON_DEVICE="/tmp/sosreport"@g\'
    ...           ${WTS_DIR}/sosReport.cfg
    Run           ${command}
    ${command}    Catenate    sed -i \'s@BTS_IP_1=.*@BTS_IP_1=${4G5G_Combo_GNB_IP}@g\'
    ...           ${WTS_DIR}/sosReport.cfg
    Run Keyword If    ('${4G5G_Combo}'=='1' or '${4G5G_CUS}'=='1')    Run    ${command}
    Run    chmod 777 ${WTS_DIR}/sosReport_ASIL/*
    ${Cmd_1}    Set Variable    cd ${WTS_DIR}/ && ${WTS_DIR}/sosReport_ASIL/sosReport_ASIL.sh -nc -s -d > /dev/null 2>\&1
    ${Cmd_2}    Set Variable    cd ${WTS_DIR}/ && ${WTS_DIR}/sosReport_ASIL/sosReport_ASIL.sh -c -s -d > /dev/null 2>\&1
    Run Keyword If    '${apConfiguration}' in "@{AP_P0_CONFIGURATION}"    Run    ${Cmd_1}    ELSE
    ...            Run    ${Cmd_2}
    Run Keyword If    '${apConfiguration}' in "@{AP_P0_CONFIGURATION}"    Validate SosReport Content
    ...    ${WTS_DIR}/SosReport*.tgz
    run keyword if    '${ap_sm_hardware}' != 'ASIK'    Run    mv /opt/wts/latest/SosReport*.tgz ${vm_logdir}/
    Run           ls ${vm_logdir}/SosReport*.tgz
    File Should Exist    ${vm_logdir}/SosReport*.tgz
    RUN    cp ${WTS_DIR}/sosReport_ASIL/sosReport_ASIL.sh.log ${vm_logdir}/

Validate SosReport Content
    [Arguments]    ${tar_path}    ${report_path}=${EMPTY}    ${python}=python3
    ${report}=    Set Variable If    '${report_path}'=='${EMPTY}'
    ...    ${EXECDIR}/logs/sosreport_validation_report.txt    ${report_path}
    ${res}=    Run Process    ${python}    sos_report_validator.py    ${tar_path}    ${report}
    ...        shell=True    cwd=${CURDIR}
    Log    ${res.stdout}
    Should Be Equal As Integers    ${res.rc}    0    msg=Sosreport check failed!!!
    [Return]    ${report}

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
    Run    scp ${test_pc2}[username]@${test_pc2}[addr]:${WTS_DIR}/SosReport*.tgz ${vm_logdir}/
    SSH.Execute    rm -rf ${WTS_DIR}/SosReport*.tgz     VM2
    SSH.Disconnect    VM2

Collect fsyslog
    Run                 killall fsyslog
    Run Keyword If    'CLOUD_5GC_d' in '${TOPOLOGY}'
    ...    Check fsyslog
    Run                 tar -cvf ${vm_logdir}/udpsyslog.tar.gz ${vm_logdir}/udpsyslog/*.log.*
    Run Keyword And Ignore Error    Remove Files    ${vm_logdir}/udpsyslog/*
    Remove Directory    ${vm_logdir}/udpsyslog    recursive=True

Check fsyslog
    [Arguments]    ${file}=udpsyslog.log.001    ${pattern}=192.168.200.129    ${grepArgs}=grep -i
    File Should Exist    ${vm_logdir}/udpsyslog/*.log.*
    ${command}        Catenate    ${grepArgs} '${pattern}' ${vm_logdir}/udpsyslog/${file}
    ${result}         Run    ${command}
    Should Contain    ${result}    ${pattern}    ignore_case=${TRUE}

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
    [Arguments]    ${bearer_stat}    ${dir}    ${mbps}    ${ueid}
    ${check_file}    Run Keyword And Return Status    File Should Exist    ${OUTPUT_DIR}/l3call_tp.txt
    Run Keyword If   '${check_file}'=='False'    Run Keyword And Ignore Error    Create File    ${OUTPUT_DIR}/l3call_tp.txt
    ${output}         Get Regexp Matches    ${bearer_stat}    Average data rate +(\\d+)    1
    ${output_mbps}    Evaluate    int(${output[0]})/1000000
    ${output_mbps}    Convert To Number    ${output_mbps}    2
    ${result}         Evaluate    (${mbps} * 1000000 * 1.1) > int(${output[0]}) > (${mbps} * 1000000 * 0.9)
    Run Keyword if    ${result}    Run Keywords    Log to Console    UE${ueid}:${dir} Average data rate: ${output[0]}
    ...               AND          Run Keyword And Ignore Error
    ...                            Append To File    ${OUTPUT_DIR}/l3call_tp.txt
    ...                                              \nUE${ueid}:${dir} Average data rate: ${output_mbps} Mbit/s
    ...               ELSE         Run Keywords    Log    UE${ueid}:${dir} Average data rate: ${output[0]}    level=ERROR
    ...               AND          Run Keyword And Ignore Error
    ...                            Append To File    ${OUTPUT_DIR}/l3call_tp.txt
    ...                                              \nUE${ueid}:${dir} Average data rate: ${output_mbps} Mbit/s
    Run Keyword and Continue on Failure
    ...               Should Be True    ${result}    msg=UE${ueid}:${dir} Average data rate failed!

Check DL Data Loss
    [Arguments]    ${bearer_stat_all}    ${bearer_stat_scg}    ${ueid}
    ${bytes_sent}       Get Regexp Matches    ${bearer_stat_all}    Bytes sent +(\\d+)    1
    ${bytes_rec}        Get Regexp Matches    ${bearer_stat_scg}    Bytes received +(\\d+)    1
    ${bytes_sent_int}   Convert To Integer  ${bytes_sent[0]}
    ${bytes_rec_int}    Convert To Integer   ${bytes_rec[0]}
    ${data_loss}        Set Variable if    '${variant_name}' == '4G5G_COMBO_MultiUE' or '${variant_name}' == '4G5G_CUS_MultiUE'
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
    ${data_loss}        Set Variable if    '${variant_name}' == '4G5G_COMBO_MultiUE' or '${variant_name}' == '4G5G_CUS_MultiUE'
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
    [Arguments]    ${dl_rate}    ${ul_rate}    ${UE_ID}=1    ${4G5G_Combo}=${4G5G_Combo}    ${bearer_id}=${BEARER_ID}
    Log    !!!${dl_rate}!${ul_rate}!${4G5G_Combo}!!!
    wtsrunner.bearer_stats  ue=${UE_ID}   id=${bearer_id}   dir=dl
    ${bearer_stat_all}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    wtsrunner.bearer_stats    ue=${UE_ID}   id=${bearer_id}   dir=dl   dc_cell_group=scg
    ${bearer_stat_scg}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check DL Data Loss      ${bearer_stat_all}    ${bearer_stat_scg}    ${UE_ID}

    wtsrunner.bearer_stats  ue=${UE_ID}   id=${bearer_id}   dir=ul
    ${bearer_stat_all}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    wtsrunner.bearer_stats    ue=${UE_ID}   id=${bearer_id}   dir=ul   dc_cell_group=scg
    ${bearer_stat_scg}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check UL Data Loss      ${bearer_stat_all}    ${bearer_stat_scg}    ${UE_ID}

Start Traffic
    [Arguments]    ${UE_ID}=1    ${dl_rate}=5    ${ul_rate}=5    ${duration}=${duration}
    ${duration}       Get Variable Value    ${TRF_DURATION}    ${duration}
    Log to Console    \nRunning DL + UL Traffic for ${duration}...
    wtsrunner.trf_data_start     ue=${UE_ID}    id=${BEARER_ID}    dir=dl    mbps=${dl_rate}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=UDP DL TRF: .*    timeout=60
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    ${output}

    Run Keyword If    '${4G5G_Combo}'=='1'
    ...    wtsrunner.bearer_ue_param    ue=${UE_ID}    id=${Bearer_ID}    scg_ul_dist_percent=${scg_ul_dist_percent}
    wtsrunner.trf_data_start     ue=${UE_ID}    id=${BEARER_ID}    dir=ul    mbps=${ul_rate}
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=UDP UL TRF: .*    timeout=60
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    ${output}

    Sleep             ${duration}

    ${trf_tput_status}     Run Keyword And Ignore Error    Validate Traffic Throughput Average Rate for NSA
    ...    ${dl_rate}    ${ul_rate}   ${UE_ID}

    Log to Console    Stopping DL + UL Traffic...
    wtsrunner.trf_data_stop     ue=${UE_ID}    id=${BEARER_ID}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Traffic was stopped   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    Traffic was stopped   partial_match=${TRUE}
    Log to Console    ${output}
    ${trf_status}     Run Keyword And Ignore Error    Validate Traffic Data Loss for NSA    ${dl_rate}    ${ul_rate}   ${UE_ID}
    Should Be True    '${trf_status[0]}' == 'PASS'    msg=Traffic failed in Data Loss, see error above!
    Should Be True    '${trf_tput_status[0]}' == 'PASS'    msg=Traffic failed in Throughput, see error above!

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
    [Arguments]    ${UE_ID}=1    ${dl_rate}=5    ${ul_rate}=5    ${duration}=${duration}
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
    [Arguments]    ${dl_rate}=5    ${ul_rate}=3    ${UE_ID}=${UE_ID}    ${duration}=${duration}
    Run Keyword If    '${apConfiguration}' in "@{HTpCfg}" and '${RU_type}' != 'ORAN' and '${AP_P1Perf}' != 'True' and '${HTp}' == 'True'
    ...    Highthroughput for QT
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

    ${trf_tput_status}     Run Keyword And Ignore Error    Validate Traffic Throughput Average Rate for SA    ${dl_rate}    ${ul_rate}

    Log to Console    Stopping DL + UL Traffic...
    wtsrunner.trf_data_stop     ue=${UE_ID}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Traffic was stopped   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    Traffic was stopped   partial_match=${TRUE}
    Log to Console    ${output}
    ${trf_status}     Run Keyword And Ignore Error    Validate Traffic Data Loss For SA    ${dl_rate}    ${ul_rate}
    Should Be True    '${trf_status[0]}' == 'PASS'    msg=Traffic failed in Data Loss, see error above!
    Should Be True    '${trf_tput_status[0]}' == 'PASS'    msg=Traffic failed in Throughput, see error above!

Validate Traffic Data Loss For SA
    [Documentation]    SA Traffic Data Loss Criteria
    ...                1. DL Bytes Received must be equal to ALL Bytes Sent
    ...                2. UL Bytes Sent must be equal to ALL Bytes Received
    [Arguments]    ${dl_rate}    ${ul_rate}    ${UE_ID}=${UE_ID}    ${qfi}=1
    Log    !!!${dl_rate}!${ul_rate}!!!
    wtsrunner.bearer_stats  ue=${UE_ID}   pdu=1   qfi=${qfi}   dir=dl
    ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check DL Data Loss      ${bearer_stat_dl}    ${bearer_stat_dl}    ${UE_ID}

    wtsrunner.bearer_stats  ue=${UE_ID}   pdu=1   qfi=${qfi}   dir=ul
    ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check UL Data Loss      ${bearer_stat_ul}    ${bearer_stat_ul}    ${UE_ID}

Start TRS Stats on Airphone
    SSH.Connect To    ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}
    ...               alias=${AP_ASIK.Connection}
    ${time}           Get Time    epoch
    Set Suite Variable    ${trs_stats_log}     trf_stats_AP_${time}.log
    ${command}        Catenate    rm -f trf_stats_AP*.log && chmod +x trf_stats_logger.sh &&
    ...               bash trf_stats_logger.sh ${trs_stats_log} &
    Run And Return Rc And Output    scp ${trs_stats_file} ${AP_ASIK.Username}@${AP_ASIK.Ip}:~/
    SSH.Send Command       ${command}    connection=${AP_ASIK.Connection}
    SSH.Execute       pgrep -f trf_stats_logger.sh    ${AP_ASIK.Connection}
    [Teardown]    SSH.Disconnect    ${AP_ASIK.Connection}

Stop TRS Stats on Airphone
    SSH.Connect To    ${AP_ASIK.Ip}    ${AP_ASIK.Username}    ${AP_ASIK.Password}
    ...               alias=${AP_ASIK.Connection}
    ${command}        Catenate    pgrep -f trf_stats_logger.sh | xargs kill -9
    SSH.Execute       pgrep -f trf_stats_logger.sh    ${AP_ASIK.Connection}
    SSH.Execute       ${command}    ${AP_ASIK.Connection}
    SSH.Execute       pgrep -f trf_stats_logger.sh    ${AP_ASIK.Connection}
    SSH.Download File    remote_path=/user/toor4nsn/${trs_stats_log}
    ...    local_path=${vm_logdir}/${trs_stats_log}
    ...    connection=${AP_ASIK}[Connection]
    [Teardown]    SSH.Disconnect    ${AP_ASIK.Connection}

Start CPU Utilization Collection
    ${time}           Get Time    epoch
    Set Suite Variable    ${cpu_stats_log}     cpu_utilization_${time}.log
    ${cpu_cmd}    Catenate    chmod +x ${CURDIR}/cpu_utlization_n_queue_monitor.sh &&
    ...    cd ${CURDIR} && ./cpu_utlization_n_queue_monitor.sh ${vm_logdir}/${cpu_stats_log} &
    Evaluate    os.system("${cpu_cmd}")    modules=os
    ${val}    Run And Return Rc And Output    ps -aef | grep -i [c]pu_utlization_n_queue_monitor
    Run Keyword If    '${apConfiguration}' not in "@{AP_P0_CONFIGURATION}" and '${apConfiguration}' !='fs_tdd_sa_eCpri_cmwv_E_AP_E_6G'
    ...    Start TRS Stats on Airphone

Stop CPU Utilization Collection
    Run And Return Rc And Output    ps -aef | grep -i [c]pu_utlization_n_queue_monitor
    ${val}    Run And Return Rc And Output    ps -aef | grep -i [c]pu_utlization_n_queue_monitor | awk '{print $2}'| xargs kill -9
    Run And Return Rc And Output    ps -aef | grep -i [c]pu_utlization_n_queue_monitor
    Run Keyword If    '${apConfiguration}' not in "@{AP_P0_CONFIGURATION}" and '${apConfiguration}' != 'fs_tdd_sa_eCpri_cmwv_E_AP_E_6G'
    ...    Stop TRS Stats on Airphone

Start and Validate Traffic For Mixed Mode
    [Arguments]    ${dl_rate}=${Traffic_dl_rate}    ${ul_rate}=${Traffic_ul_rate}    ${duration}=${duration}
    Run Keyword And Ignore Error    Set WTS Default Log Level to Error Level
    ${duration}       Get Variable Value    ${TRF_DURATION}    ${duration}
    Set Suite Variable    ${duration}
    Run Keyword If    '${HIGH_THROUGHPUT_FLAG}' == 'True'
    ...    HighThroughput    ${duration}
    ${tput_validate_list}=    Create List
    ${dataloss_validate_list}=    Create List
    Run Keyword If    '${collect_cpu_data_flag}' != 'False'    Start CPU Utilization Collection
    Start Traffic For SA With Mixed Mode
    Start Traffic For NSA With Mixed Mode
    Run Keyword If    '${4G5G_Combo}'=='1'
    ...    Start Traffic For LTE With Mixed Mode
    Sleep    ${duration}
    ${udp_ue_stats_validate_list}    Verify Traffic Data Rate By UE STATS    Validate UE_stats Throughput Average Rate for SA
    ...    Validate UE_stats Throughput Average Rate for NSA   ${dl_rate}    ${ul_rate}
    ${udp_tput_validate_list}    Verify Traffic Throughput or Data Loss    Validate Traffic Throughput Average Rate for SA
    ...    Validate Traffic Throughput Average Rate for NSA   ${dl_rate}    ${ul_rate}
    ${tcp_tput_validate_list}    Verify Traffic Throughput or Data Loss    Validate TCP Traffic Throughput Average Rate for SA
    ...    Validate TCP Traffic Throughput Average Rate for NSA   ${DL_TCP_data_rate}    ${UL_TCP_data_rate}
    Stop Traffic For SA With Mixed Mode
    Stop Traffic For NSA With Mixed Mode
    Run Keyword If    '${4G5G_Combo}'=='1'
    ...    Stop Traffic For LTE With Mixed Mode
    Run Keyword And Ignore Error    Set WTS Default Log Level to Debug
    ${udp_dataloss_validate_list}    Verify Traffic Throughput or Data Loss    Validate Traffic Data Loss For SA
    ...    Validate Traffic Data Loss for NSA    ${dl_rate}    ${ul_rate}
    ${tcp_dataloss_validate_list}    Verify Traffic Throughput or Data Loss    Validate TCP Traffic Data Loss For SA
    ...    Validate TCP Traffic Data Loss for NSA    ${DL_TCP_data_rate}    ${UL_TCP_data_rate}
    Run Keyword If    '${collect_cpu_data_flag}' != 'False'    Stop CPU Utilization Collection
    Run Keyword and Continue on Failure    Is Traffic stats with tolerance    ${udp_tput_validate_list}    type=Throughput
    ...    protocol=UDP
    Run Keyword and Continue on Failure    Is Traffic stats with tolerance    ${udp_dataloss_validate_list}    type=DataLoss
    ...    protocol=UDP
    Run Keyword If    '${DATA_TCP_ENABLE_FLAG}' == 'True'    Run Keyword and Continue on Failure    Validate TCP related results
    ...    ${tcp_tput_validate_list}    ${tcp_dataloss_validate_list}

Start and Validate Traffic For 4G5G_CUS Mixed Mode
    [Arguments]    ${dl_rate_CUS}=${dl_rate_CUS}    ${ul_rate_CUS}=${ul_rate_CUS}    ${duration}=10min
    Run Keyword And Ignore Error    Set WTS Default Log Level to Error Level
    ${duration}       Get Variable Value    ${TRF_DURATION}    ${duration}
    Run Keyword If    '${HIGH_THROUGHPUT_FLAG}' == 'True'
    ...    HighThroughput    ${duration}
    ${tput_validate_list}=    Create List
    ${dataloss_validate_list}=    Create List
    Start Traffic For SA With Mixed Mode    ${dl_rate_CUS}    ${ul_rate_CUS}
    Start Traffic For 4G5G_CUS NSA With Mixed Mode
    Start Traffic For LTE With Mixed Mode for CUS
    Run Keyword If    '${HIGH_THROUGHPUT_FLAG}' == 'True' and '${HIGH_THROUGHPUT_TCPDUMP}' == 'True'
    ...    Stop tcp dump for high throughput Scenario
    ...    ELSE    Sleep    ${duration}
    ${tput_validate_list}    Verify Traffic Throughput or Data Loss for 4G5G_CUS    Validate Traffic Throughput Average Rate for SA
    ...    Validate Traffic Throughput Average Rate for 4G5G_CUS   ${dl_rate_CUS}    ${ul_rate_CUS}
    Stop Traffic For SA With Mixed Mode
    ${dataloss_validate_list}    Verify Traffic Throughput or Data Loss for 4G5G_CUS    Validate Traffic Data Loss For SA
    ...    Validate Traffic Data Loss for 4G5G_CUS    ${dl_rate_CUS}    ${ul_rate_CUS}
    Stop Traffic For 4G5G_CUS NSA With Mixed Mode
    Stop Traffic For LTE With Mixed Mode for CUS
    Run Keyword And Ignore Error    Set WTS Default Log Level to Debug
    Run Keyword and Continue on Failure    Is Traffic stats with tolerance    ${tput_validate_list}    type=Throughput
    ...    protocol=UDP
    Run Keyword and Continue on Failure    Is Traffic stats with tolerance    ${dataloss_validate_list}    type=DataLoss
    ...    protocol=UDP

Start Traffic For LTE With Mixed Mode for CUS
    FOR   ${ueid}   IN   @{lte_ueids}
         Start LTE Traffic With Mixed Mode for CUS   ${ueid}    ${CUS_LTE_DL}    ${CUS_LTE_UL}
    END

Start Traffic For 4G5G_CUS NSA With Mixed Mode
    FOR   ${ueid}   IN   @{nsa_ueids}
         Start LTE Traffic With Mixed Mode for CUS    ${ueid}    ${CUS_NSA_DL}    ${CUS_NSA_UL}
    END

Start LTE Traffic With Mixed Mode for CUS
    [Arguments]    ${UE_ID}=${UE_ID}    ${dl_rate_CUS}=5    ${ul_rate_CUS}=5
    Log to Console    \nRunning DL + UL Traffic for ${duration}...
    Run UEx command    trf_data_start     ue=${UE_ID}     dir=dl     protocol=udp     bearer=5    Mbps=${dl_rate_CUS}    stats=true    trf_id=1
    Run UEx command    trf_data_start     ue=${UE_ID}     dir=ul     protocol=udp     bearer=5    Mbps=${ul_rate_CUS}    stats=true    trf_id=2

Verify Traffic Throughput or Data Loss for 4G5G_CUS
    [Arguments]    ${sa_keyword}    ${nsa_keyword}    ${dl_rate_CUS}    ${ul_rate_CUS}
    Log    !!!${dl_rate_CUS}!${ul_rate_CUS}!!!
    ${result_status}=    Create List
    FOR   ${nsa_ueid}    ${sa_ueid}  ${lte_ueid}    IN ZIP   ${nsa_ueids}    ${sa_ueids}    ${lte_ueids}
        ${trf_sa_status}    Run Keyword And Ignore Error    ${sa_keyword}    ${CUS_SA_DL}    ${CUS_SA_UL}    ${sa_ueid}
        ${trf_nsa_status}    Run Keyword And Ignore Error    ${nsa_keyword}    ${CUS_NSA_DL}    ${CUS_NSA_UL}   ${nsa_ueid}
        ${trf_lte_status}    Run Keyword And Ignore Error    ${nsa_keyword}    ${CUS_LTE_DL}    ${CUS_LTE_UL}   ${lte_ueid}
        ${status}    Run Keyword And Ignore Error    Should Be True
        ...   '${trf_sa_status[0]}' == 'PASS' and '${trf_nsa_status[0]}' == 'PASS' and '${trf_lte_status[0]}' == 'PASS'
	    ...    msg=Traffic failed, see error above!
        Append To List    ${result_status}    ${status[0]}
    END
    [Return]    ${result_status}

Validate Traffic Throughput Average Rate for 4G5G_CUS
    [Arguments]    ${dl_rate_CUS}=${dl_rate_CUS}    ${ul_rate_CUS}=${ul_rate_CUS}    ${UE_ID}=${UE_ID}
    Check Average Rate for CUS    UE_ID=${UE_ID}    TRF_ID=1    Dir=dl    mbps=${dl_rate_CUS}
    Check Average Rate for CUS    UE_ID=${UE_ID}    TRF_ID=2    Dir=ul    mbps=${ul_rate_CUS}

Validate Traffic Data Loss for 4G5G_CUS
    [Arguments]    ${dl_rate_CUS}=${dl_rate_CUS}    ${ul_rate_CUS}=${ul_rate_CUS}    ${UE_ID}=${UE_ID}
    Log    !!!${dl_rate_CUS}!${ul_rate_CUS}!!!
    Check Data Loss for CUS    UE_ID=${UE_ID}    TRF_ID=1    Dir=dl
    Check Data Loss for CUS    UE_ID=${UE_ID}    TRF_ID=2    Dir=ul

Stop Traffic For LTE With Mixed Mode for CUS
    FOR   ${ueid}   IN   @{lte_ueids}
         Stop LTE Traffic    ${ueid}
    END

Stop Traffic For 4G5G_CUS NSA With Mixed Mode
    FOR   ${ueid}   IN   @{nsa_ueids}
         Stop LTE Traffic    ${ueid}
    END

Stop LTE Traffic
    [Arguments]    ${UE_ID}=${ueid}
    Run UEx command   trf_data_stop    ue=${UE_ID}    bearer=5    trf_id=1
    Run UEx command   trf_data_stop    ue=${UE_ID}    bearer=5    trf_id=2

Verify Traffic Data Rate By UE STATS
    [Arguments]    ${sa_keyword}    ${nsa_keyword}    ${dl_rate}    ${ul_rate}
    Run Keyword If    '${HIGH_THROUGHPUT_FLAG}' == 'True'
    ...    Highthroughput for QT
    ${result_status}=    Create List
    FOR   ${nsa_ueid}    ${sa_ueid}   IN ZIP   ${nsa_ueids}    ${sa_ueids}
        ${trf_sa_status}    Run Keyword And Ignore Error    ${sa_keyword}    ${dl_rate}    ${ul_rate}    ${sa_ueid}
        Log To Console    ${trf_sa_status}
        ${trf_nsa_status}    Run Keyword And Ignore Error    ${nsa_keyword}    ${dl_rate}    ${ul_rate}   ${nsa_ueid}
        Log To Console    ${trf_nsa_status}
    END
    [Return]    ${result_status}

Is Traffic stats with tolerance
    [Arguments]    ${list_value}    ${type}    ${protocol}
    List Should Not Contain Value    ${list_value}    FAIL
    ...    msg=${protocol} Traffic failed in ${type}, see error above!

Validate TCP related results
    [Arguments]    ${tcp_tput_validate_list}    ${tcp_dataloss_validate_list}
    Return From Keyword If    '${DATA_TCP_ENABLE_FLAG}' != 'True'
    Run Keyword and Continue on Failure    Is Traffic stats with tolerance    ${tcp_tput_validate_list}    type=Throughput
    ...    protocol=TCP
    Run Keyword and Continue on Failure    Is Traffic stats with tolerance    ${tcp_dataloss_validate_list}    type=DataLoss
    ...    protocol=TCP

Validate TCP Traffic Data Loss For SA
    [Arguments]    ${dl_rate}    ${ul_rate}    ${ue_id}
    Run Keyword If    '${HIGH_THROUGHPUT_FLAG}' == 'True'
    ...    Highthroughput for QT
    Return From Keyword If    '${DATA_TCP_ENABLE_FLAG}' != 'True'
    Validate Traffic Data Loss For SA    ${dl_rate}    ${ul_rate}    ${ue_id}    qfi=2

Validate TCP Traffic Data Loss for NSA
    [Arguments]    ${dl_rate}    ${ul_rate}    ${ue_id}
    Run Keyword If    '${HIGH_THROUGHPUT_FLAG}' == 'True'
    ...    Highthroughput for QT
    Return From Keyword If    '${DATA_TCP_ENABLE_FLAG}' != 'True'
    Validate Traffic Data Loss for NSA    ${dl_rate}    ${ul_rate}    ${ue_id}    bearer_id=${TCP_BEARER_ID}

Verify Traffic Throughput or Data Loss
    [Arguments]    ${sa_keyword}    ${nsa_keyword}    ${dl_rate}    ${ul_rate}
    Run Keyword If    '${HIGH_THROUGHPUT_FLAG}' == 'True'
    ...    Highthroughput for QT
    ${result_status}=    Create List
    FOR   ${nsa_ueid}    ${sa_ueid}   IN ZIP   ${nsa_ueids}    ${sa_ueids}
        ${trf_sa_status}    Run Keyword And Ignore Error    ${sa_keyword}    ${dl_rate}    ${ul_rate}    ${sa_ueid}
        ${trf_nsa_status}    Run Keyword And Ignore Error    ${nsa_keyword}    ${dl_rate}    ${ul_rate}   ${nsa_ueid}
        ${status}    Run Keyword And Ignore Error    Should Be True
        ...   '${trf_sa_status[0]}' == 'PASS' and '${trf_nsa_status[0]}' == 'PASS'   msg=Traffic failed, see error above!
        Append To List    ${result_status}    ${status[0]}
    END
    [Return]    ${result_status}

Start UDP Traffic For SA
    [Arguments]    ${UE_ID_SA}=1    ${dl_rate}=${Traffic_dl_rate}    ${ul_rate}=${Traffic_ul_rate}    ${duration}=${duration}
    Run Keyword If    '${HIGH_THROUGHPUT_FLAG}' == 'True'
    ...    Highthroughput for QT
    Log to Console    \nRunning DL + UL SA UDP Traffic for ${duration}...
    wtsrunner.trf_data_start     ue=${UE_ID_SA}    pdu=1   qfi=1    dir=dl    mbps=${dl_rate}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=UDP DL TRF: .*    timeout=60
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    DL traffic started...

    wtsrunner.trf_data_start     ue=${UE_ID_SA}   pdu=1   qfi=1    dir=ul    mbps=${ul_rate}
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=UDP UL TRF: .*    timeout=60
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    UL traffic started...

Modify PDU Session
    [Arguments]    ${UE_ID}
    wtsrunner.ue_pdu_session_modify    ue=${UE_ID}    pdu=1    qosflows_to_add=2    by=amf
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=QoS Routing Table .*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    Added QosFlow with QFI:2    partial_match=${TRUE}
    Log to Console    Modified pdu session...

Start TCP Traffic for SA
    [Arguments]    ${UE_ID}    ${dl_rate}=${DL_TCP_data_rate}    ${ul_rate}=${UL_TCP_data_rate}
    Run Keyword If    '${HIGH_THROUGHPUT_FLAG}' == 'True' and '${4G5G_CUS}'=='0'
    ...    Highthroughput for QT
    Log to Console    \nRunning DL + UL SA TCP Traffic
    Modify PDU Session    ${UE_ID}
    wtsrunner.trf_data_start     ue=${UE_ID}    pdu=1   qfi=2    dir=dl    mbps=${dl_rate}    protocol=tcp
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=TCP .*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    DL tcp traffic started...

    wtsrunner.trf_data_start     ue=${UE_ID}   pdu=1   qfi=2    dir=ul    mbps=${ul_rate}    protocol=tcp
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=TCP .*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    UL tcp traffic started...

Start TCP Traffic for NSA
    [Arguments]    ${UE_ID}    ${dl_rate}=${DL_TCP_data_rate}    ${ul_rate}=${UL_TCP_data_rate}
    Run Keyword If    '${HIGH_THROUGHPUT_FLAG}' == 'True'
    ...    Highthroughput for QT
    Log to Console    \nRunning DL + UL NSA TCP Traffic
    wtsrunner.trf_data_start     ue=${UE_ID}    id=${TCP_BEARER_ID}    dir=dl    mbps=${dl_rate}    protocol=tcp
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=TCP .*    timeout=60
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    DL tcp traffic started...
    wtsrunner.trf_data_start     ue=${UE_ID}    id=${TCP_BEARER_ID}    dir=ul    mbps=${ul_rate}    protocol=tcp
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=TCP .*    timeout=60
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    UL tcp traffic started..

Start Traffic For SA With Mixed Mode
    [Arguments]    ${dl_rate}=${Traffic_dl_rate}    ${ul_rate}=${Traffic_ul_rate}
    FOR   ${ueid}   IN   @{sa_ueids}
        Start UDP Traffic For SA   ${ueid}    ${dl_rate}    ${ul_rate}
        Run Keyword If    '${DATA_TCP_ENABLE_FLAG}' == 'True'    Start TCP Traffic for SA    ${ueid}
    END

Start UDP Traffic For NSA
    [Arguments]    ${UE_ID_NSA}=1        ${dl_rate}=${Traffic_dl_rate}    ${ul_rate}=${Traffic_ul_rate}    ${duration}=${duration}
    Run Keyword If    '${HIGH_THROUGHPUT_FLAG}' == 'True'
    ...    Highthroughput for QT
    Log to Console    \nRunning DL + UL NSA UDP Traffic for ${duration}...
    wtsrunner.trf_data_start     ue=${UE_ID_NSA}    id=${BEARER_ID}    dir=dl    mbps=${dl_rate}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=UDP DL TRF: .*    timeout=60
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    DL traffic started...
    Run Keyword If    '${4G5G_Combo}'=='1'
    ...    wtsrunner.bearer_ue_param    ue=${UE_ID_NSA}    id=${Bearer_ID}
    ...    scg_ul_dist_percent=${scg_ul_dist_percent}
    wtsrunner.trf_data_start     ue=${UE_ID_NSA}    id=${BEARER_ID}    dir=ul    mbps=${ul_rate}
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=UDP UL TRF: .*    timeout=60
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    UL traffic started...

Start Traffic For NSA With Mixed Mode
    FOR   ${ueid}   IN   @{nsa_ueids}
        Start UDP Traffic For NSA   ${ueid}
        Run Keyword If    '${DATA_TCP_ENABLE_FLAG}' == 'True'    Start TCP Traffic for NSA    ${ueid}
    END

Stop Traffic For SA
    [Arguments]    ${UE_ID_SA}    ${qfi}=1
    Log to Console    Stopping DL + UL SA Traffic...
    wtsrunner.trf_data_stop     ue=${UE_ID_SA}   pdu=1   qfi=${qfi}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Traffic was stopped   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    Traffic was stopped   partial_match=${TRUE}
    Log to Console    ${output}

Stop Traffic For SA for 6G UL
    [Arguments]    ${UE_ID_SA}    ${qfi}=1
    Log to Console    Stopping UL SA Traffic...
    ExternalAPConnect.Connect Ap Egate To External Ap Server    ${JUMP_HOST}    ${JUMP_USERNAME}
    ...    ${JUMP_PASSWORD}    ${JUMP_PORT}
    ExternalAPConnect.Execute Ap Egate Command    trf_data_stop ue=${UE_ID_SA} pdu=1 qfi=${qfi} dir=ul
    ExternalAPConnect.Disconnect External Ap Server

Stop Traffic For SA for 6G DL
    [Arguments]    ${UE_ID_SA}    ${qfi}=1
    Log to Console    Stopping DL SA Traffic...
    wtsrunner.trf_data_stop     ue=${UE_ID_SA}   pdu=1   qfi=${qfi}   dir=dl
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Traffic was stopped   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    Traffic was stopped   partial_match=${TRUE}
    Log to Console    ${output}

Stop Traffic For SA With Mixed Mode
    FOR   ${ueid}   IN   @{sa_ueids}
        Stop Traffic For SA   ${ueid}
        Run Keyword If    '${DATA_TCP_ENABLE_FLAG}' == 'True'    Stop Traffic For SA   ${ueid}    qfi=2
    END

Stop Traffic For NSA
    [Arguments]    ${UE_ID_NSA}    ${bearer_id}=${BEARER_ID}
    Log to Console    Stopping DL + UL NSA Traffic...
    wtsrunner.trf_data_stop     ue=${UE_ID_NSA}    id=${bearer_id}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Traffic was stopped   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    Traffic was stopped   partial_match=${TRUE}
    Log to Console    ${output}

Stop Traffic For NSA With Mixed Mode
    FOR   ${ueid}   IN   @{nsa_ueids}
        Stop Traffic For NSA   ${ueid}
        Run Keyword If    '${DATA_TCP_ENABLE_FLAG}' == 'True'    Stop Traffic For NSA   ${ueid}
        ...    bearer_id=${TCP_BEARER_ID}
    END

Start Traffic For LTE
    [Arguments]    ${UE_ID}=1    ${dl_rate}=5    ${ul_rate}=3    ${duration}=${duration}
    ${duration}       Get Variable Value    ${TRF_DURATION}    ${duration}
    Log to Console    \nRunning DL + UL Traffic for ${duration}...
    wtsrunner.trf_data_start     ue=${UE_ID}    id=${BEARER_ID}    dir=dl    mbps=${dl_rate}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=UDP DL TRF: .*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    DL traffic started...

    wtsrunner.trf_data_start     ue=${UE_ID}    id=${BEARER_ID}    dir=ul    mbps=${ul_rate}
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=UDP UL TRF: .*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    UL traffic started...

Start Traffic For LTE With Mixed Mode
    FOR   ${ueid}   IN   @{lte_ueids}
        Start Traffic For LTE   ${ueid}
    END

Start LTE Traffic for CUS
    [Arguments]    ${UE_ID}=${UE_ID}    ${dl_rate_CUS}=5    ${ul_rate_CUS}=5    ${duration}=10min
    ${duration}       Get Variable Value    ${TRF_DURATION}    ${duration}
    Log to Console    \nRunning DL + UL Traffic for ${duration}...
    Run UEx command    trf_data_start     ue=${UE_ID}     dir=dl     protocol=udp     bearer=5    Mbps=${dl_rate_CUS}    stats=true    trf_id=1
    Run UEx command    trf_data_start     ue=${UE_ID}     dir=ul     protocol=udp     bearer=5    Mbps=${dl_rate_CUS}    stats=true    trf_id=2
    Sleep             ${duration}
    ${trf_status}     Run Keyword And Ignore Error    Validate Traffic for CUS    ${UE_ID}    ${dl_rate_CUS}    ${ul_rate_CUS}
    Should Be True    '${trf_status[0]}' == 'PASS'    msg=Traffic failed, see error above!
    Log to Console    Stopping DL + UL Traffic...
    Run UEx command   trf_data_stop    ue=${UE_ID}    bearer=5    trf_id=1
    Run UEx command   trf_data_stop    ue=${UE_ID}    bearer=5    trf_id=2

Validate Traffic for CUS
    [Arguments]    ${UE_ID}=${UE_ID}    ${dl_rate_CUS}=5    ${ul_rate_CUS}=5
    Check Average Rate for CUS    UE_ID=${UE_ID}    TRF_ID=1    Dir=dl    mbps=${dl_rate_CUS}
    Check Data Loss for CUS    UE_ID=${UE_ID}    TRF_ID=1    Dir=dl
    Check Average Rate for CUS    UE_ID=${UE_ID}    TRF_ID=2    Dir=ul    mbps=${ul_rate_CUS}
    Check Data Loss for CUS    UE_ID=${UE_ID}    TRF_ID=2    Dir=ul

Check Average Rate for CUS
    [Arguments]    ${UE_ID}=${UE_ID}    ${TRF_ID}=${TRF_ID}    ${Dir}=${Dir}    ${mbps}=${mbps}
    ${trf_stats}=     Run UEx command     get_trf_data_stats     ue=${UE_ID}   unit=Mbps    trf_id=${TRF_ID}
    ${tputs}=     Get From Dictionary     ${trf_stats}     ${Dir}
    ${tputs_avg}=    Get From Dictionary     ${tputs}     avg
    ${result}         Evaluate    (${mbps} * 1.1) > int(${tputs_avg}) > (${mbps} * 0.9)
    Run Keyword if    ${result}    Log to Console    UE${UE_ID}:${Dir} Average data rate: ${tputs_avg}
    ...               ELSE    Log    UE${UE_ID}:${Dir} Average data rate: ${tputs_avg}     level=ERROR
    Run Keyword and Continue on Failure
    ...               Should Be True    ${result}    msg=UE${UE_ID}:${Dir} Average data rate failed!

Check Data Loss for CUS
    [Arguments]    ${UE_ID}=${UE_ID}    ${TRF_ID}=${TRF_ID}    ${Dir}=${Dir}
    ${trf_stats}=     Run UEx command     get_trf_data_stats     ue=${UE_ID}   unit=Mbps    trf_id=${TRF_ID}    succ_rate=on
    ${tputs}=     Get From Dictionary     ${trf_stats}    ${Dir}
    ${tputs_pass}=    Get From Dictionary     ${tputs}     pass
    ${result}         Evaluate    ${tputs_pass} >= ${tput_per}
    Run Keyword if    ${result}    Log to Console    UE${UE_ID}:${Dir} Data Received: ${tputs_pass}
    ...               ELSE    Log    UE${UE_ID}:${Dir} Data Loss!: ${tputs_pass}    level=ERROR
    Run Keyword and Continue on Failure
    ...               Should Be True    ${result}    msg=UE${UE_ID}:${Dir} Data Loss! not matching given threshold!

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

Change WTS VM Timezone to UTC
    Run    sudo timedatectl set-timezone UTC

NG link check using AMF Link Status
    [Arguments]    ${amf_id}=${AMF_ID}    ${gnb_id}=${Target_gNB}
    [Documentation]    This Keyword checks if the NG link status for the mentioned gNB ID using the amf_disp command
    ...    on egate console
    wtsrunner.amf_disp    id=${amf_id}    type=link_info    gnb=${gnb_id}
	${amf_link_status}=    Run Keyword And Return Status
    ...    wtsrunner.read_wtsemu_output_until_re    expected=${Ng_link_pattern}    timeout=60
    Run Keyword If    '${amf_link_status}'=='False' and ('${4G5G_Combo}'=='1' or '${4G5G_CUS}'=='1')
    ...    Search pattern should Exists In EGATE
    ...    ${WTS_DIR}/egate_console.log    ${Ng_link_pattern_dual_stack}
    ...    ELSE IF    '${amf_link_status}'=='True'    Log    "NG Link in UP"
    ...    ELSE    Fail    msg="NG Link is not Up"

S1 link check for eNB
    Search pattern should Exists In EGATE
    ...    ${WTS_DIR}/egate_console.log    ${S1_link_pattern_dual_stack}
    Log                S1_link_status_is_ok

Validate Traffic Throughput Average Rate for SA
    [Documentation]    SA Traffic Throughput Criteria
    ...                Average data rate must be within 90% and 110% of expected rate
    [Arguments]    ${dl_rate}    ${ul_rate}    ${UE_ID}=${UE_ID}    ${qfi}=1
    wtsrunner.bearer_stats  ue=${UE_ID}   pdu=1   qfi=${qfi}   dir=dl
    ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate      ${bearer_stat_dl}    DL    ${dl_rate}    ${UE_ID}

    wtsrunner.bearer_stats  ue=${UE_ID}   pdu=1   qfi=${qfi}   dir=ul
    ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate      ${bearer_stat_ul}    UL    ${ul_rate}    ${UE_ID}

Validate UE_stats Throughput Average Rate for SA
    [Documentation]    SA Traffic Throughput Criteria
    ...                Average data rate must be within 90% and 110% of expected rate
    [Arguments]    ${dl_rate}    ${ul_rate}    ${UE_ID}=${UE_ID}    ${qfi}=1
    Log    !!!${dl_rate}..${ul_rate}..${qfi}!!!
    wtsrunner.ue_stats_nr  id=${UE_ID}  type=pdsch,pusch scell=primary,secondary
    sleep    2s
    ${ue_stat}      wtsrunner.read_wtsemu_output_until    expected=Average
    ...                     timeout=30

Validate TCP Traffic Throughput Average Rate for SA
    [Documentation]    SA TCP Traffic Throughput Criteria
    ...                Average data rate must be within 90% and 110% of expected rate
    [Arguments]    ${dl_rate}    ${ul_rate}    ${UE_ID}=${UE_ID}    ${qfi}=2
    Return From Keyword If    '${DATA_TCP_ENABLE_FLAG}' != 'True'
    Validate Traffic Throughput Average Rate for SA    ${dl_rate}    ${ul_rate}
    ...    ${UE_ID}    ${qfi}

Validate Traffic Throughput Average Rate for NSA
    [Documentation]    NSA Traffic Throughput Criteria
    ...                Average data rate must be within 90% and 110% of expected rate
    [Arguments]    ${dl_rate}    ${ul_rate}    ${UE_ID}=1    ${4G5G_Combo}=${4G5G_Combo}    ${bearer_id}=${BEARER_ID}
    Log    !!!${4G5G_Combo}!!!
    wtsrunner.bearer_stats    ue=${UE_ID}   id=${bearer_id}   dir=dl   dc_cell_group=scg
    ${bearer_stat_scg}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate      ${bearer_stat_scg}    DL    ${dl_rate}    ${UE_ID}

    wtsrunner.bearer_stats  ue=${UE_ID}   id=${bearer_id}   dir=ul
    ${bearer_stat_all}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Average Rate      ${bearer_stat_all}    UL    ${ul_rate}    ${UE_ID}

Validate TCP Traffic Throughput Average Rate for NSA
    [Documentation]    NSA TCP Traffic Throughput Criteria
    ...                Average data rate must be within 90% and 110% of expected rate
    [Arguments]    ${dl_rate}    ${ul_rate}    ${UE_ID}=1    ${4G5G_Combo}=${4G5G_Combo}    ${bearer_id}=${TCP_BEARER_ID}
    Return From Keyword If    '${DATA_TCP_ENABLE_FLAG}' != 'True'
    Validate Traffic Throughput Average Rate for NSA    ${dl_rate}    ${ul_rate}
    ...    ${UE_ID}    ${4G5G_Combo}    ${bearer_id}

Validate UE_stats Throughput Average Rate for NSA
    [Documentation]    NSA Traffic Throughput Criteria
    ...                Average data rate must be within 90% and 110% of expected rate
    [Arguments]    ${dl_rate}    ${ul_rate}    ${UE_ID}=1    ${4G5G_Combo}=${4G5G_Combo}    ${bearer_id}=${BEARER_ID}
    Log    !!!${dl_rate}...${ul_rate}...${4G5G_Combo}...${bearer_id}!!!
    wtsrunner.ue_stats_nr  id=${UE_ID}  type=pdsch,pusch scell=primary,secondary
    ${ue_stat}      wtsrunner.read_wtsemu_output_until    expected=Average
    ...                    timeout=30

Add ca_5gair User in ssh config
    ${grep_status}    Get Status of SSH Config For ca_5gair User Details
    Return From Keyword If    '${grep_status}' == 'True'    ${grep_status}
    ${ssh_config_value}    Set Variable    \nHost gerrit*\n    \tIdentityFile ~/.ssh/id_rsa\n    \tUser ca_5gair\n
    Add Content To File    /home/ute/.ssh/config    ${ssh_config_value}
    ${command}    Catenate    sudo systemctl restart ssh.service
    ${output}    Run    ${command}
    ${grep_status}    Get Status of SSH Config For ca_5gair User Details
    Run Keyword If    '${grep_status}' == 'False'    Log    SSH configuration failure
    [Return]    ${grep_status}

Get Status of SSH Config For ca_5gair User Details
    ${command}    Catenate    grep -i "User ca_5gair" ~ute/.ssh/config
    ${output}    Run    ${command}
    ${grep_status}    Run Keyword And Return Status    Should Contain    ${output}    User ca_5gair
    [Return]    ${grep_status}

Clone and Configure testconfigs repo
    Set Suite Variable             ${AP_configs}     ${EXECDIR}/testconfigs
    ${command}    Catenate    rm -rf ${AP_configs} &&
    ...    git clone ssh://ca_5gair@gerrit.ext.net.nokia.com:29418/MN/5G/TEST/testconfigs ${AP_configs}
    ${rc_clone}    ${output_clone}    Run And Return Rc And Output    ${command}
    Should Be Equal As Integers    ${rc_clone}    0    msg=git clone command failed with error code ${rc_clone}
    ${command}    Catenate    cd ${AP_configs} && git checkout master && git pull origin
    ...    && git config user.email I_MN_5G_AIRPHONE_CI@nokia.com && git config user.name ca_5gair
    Run And Return Rc And Output    ${command}

Get config file path from Yaml
    Clone and Configure testconfigs repo
    ${config_yaml}=    Set Variable    ${AP_configs}/${stream_nr}/${deployment}/${l1}/config.yaml
    ${dic}=    parser.parse_yaml    ${config_yaml}    ${duplexing}    ${RF_type}
    ...    ${wavelength}    ${RU_type}    ${gnb_sm_hardware}    ${gnb_cp_hardware}
    ...    ${ap_sm_hardware}    ${ap_cp_hardware}    ${component_carrier}
    Log    ${dic}
    [Return]    ${dic}

Clone and Configure topologyconfig repo
    Set Suite Variable             ${AP_configs}     ${EXECDIR}/topologyconfigs
    ${command}    Catenate    rm -rf ${AP_configs} &&
    ...    git clone git@gitlabe2.ext.net.nokia.com:uca/ran/topology-configs.git ${AP_configs}
    ${rc_clone}    ${output_clone}    Run And Return Rc And Output    ${command}
    Should Be Equal As Integers    ${rc_clone}    0    msg=git clone command failed with error code ${rc_clone}
    ${command}    Catenate    cd ${AP_configs} && git checkout master && git pull origin
    ...    && git config user.email I_MN_5G_AIRPHONE_CI@nokia.com && git config user.name ca_5gair
    Run And Return Rc And Output    ${command}

Check If Testconfig Repo Configuration
    ${status_flag1}    Run Keyword And Return Status    File Should Exist    ${single_run_info_file}
    ${status_flag2}    Run Keyword And Return Status    File Should Exist    ${testline_results_file}
    ${topologyconfig_flag}    Set Variable If    ${status_flag1} or ${status_flag2}    ${True}    ${False}
    [Return]    ${topologyconfig_flag}

Check NIDD and make update
    ${testconfig_repo_flag}    Check If Testconfig Repo Configuration
    Set Suite Variable    ${testconfig_repo_flag}
    Run keyword If  '${testconfig_repo_flag}' == 'True'    Check NIDD and make update on testconfigs repo
    ...    ELSE    Check NIDD and make update on topologyconfigs repo

Check NIDD and make update on topologyconfigs repo
    ${topo_check}    Verify install and suite topology match
    Return From Keyword If    '${topo_check}' == 'False'
    ${NIDD_Update}    Is NIDD Update Required
    Return From Keyword If    '${NIDD_Update}' == 'False'
    Clone and Configure topologyconfig repo
    ${scfc_xml_repo}    Set Variable    ${AP_configs}/${topology_label}/SBTS00/${topology_variant}/scfc.xml
    ${scfc_repo_path}    Set Variable    ${topology_label}/SBTS00/${topology_variant}/scfc.xml
    ${nidd1_scf_repo}    get_nidd_version_from_scf_file    ${scfc_xml_repo}    1
    ${scfc_xml_tl}    Set Variable    ${vm_logdir}/gnb_coam_scf.xml
    ${nidd1_scf_tl}    get_nidd_version_from_scf_file    ${scfc_xml_tl}    1
    ${nidd2_scf_repo}    get_nidd_version_from_scf_file    ${scfc_xml_repo}    2
    ${nidd2_scf_tl}    get_nidd_version_from_scf_file    ${scfc_xml_tl}    2
    ${install_cmd}    Catenate    sudo chown ute:ute /etc/apt/sources.list.d/debian_repo.list &&
    ...    echo "deb [ arch=amd64 ] http://repo.wroclaw.nsn-rdnet.net/debian buster main" >> /etc/apt/sources.list.d/debian_repo.list &&
    ...    sudo chown root:root /etc/apt/sources.list.d/debian_repo.list && sudo sudo apt-get update && sudo apt-get install dos2unix
    Run And Return Rc And Output    ${install_cmd}
    ${file_cmd}    Catenate    dos2unix ${scfc_xml_tl}
    Run And Return Rc And Output    ${file_cmd}
    ${nidd_condition}  Catenate
    ...    ('${nidd1_scf_tl}' > '${nidd1_scf_repo}'  and 'error' not in '${nidd1_scf_repo}'
    ...    and 'error' not in '${nidd1_scf_tl}' and '${nidd1_scf_repo}' != '' and '${nidd1_scf_tl}' != '')
    ...    or ('${nidd2_scf_tl}' > '${nidd2_scf_repo}' and 'error' not in '${nidd2_scf_repo}'
    ...    and 'error' not in '${nidd2_scf_tl}' and '${nidd2_scf_repo}' != '' and '${nidd2_scf_tl}' != '')
    ${nidd_condition}  Evaluate    ${nidd_condition}
    ${nidd_value}    Get NIDD version    ${nidd1_scf_repo}    ${nidd1_scf_tl}    ${nidd2_scf_repo}    ${nidd2_scf_tl}
    Log To Console    Nidd version ${nidd_value}
    Log To Console    Nidd condition ${nidd_condition}
    Run And Return Rc And Output    echo "" >> ${scfc_xml_tl}
    Run Keyword If    ${nidd_condition}    update_topologyconfig_repo    auto_merge_flag=${auto_merge_flag}    URL=${topology_config_base_url}
    ...    private_token=${ca_5gair_token}    project_id=${topology_config_project_id}
    ...    branch_name=${nidd_value}_${topology_label}_${topology_variant}
    ...    repo_file_path=${scfc_repo_path}    tl_file_path=${scfc_xml_tl}    nidd_version=${nidd_value}
    ...    topology=${topology_label}_${topology_variant}
    ...    ELSE     Log    NIDD version is the same before and after commissioning, no need to update SCF on repo.

Check NIDD and make update on testconfigs repo
    [Documentation]     This keyword is checking NIDD versions from the SCF file used for commissioning (from 'testconfigs'
    ...                 repository) and from the SCF file collected from the TestLine after commissioning.
    ...                 If checked NIDD versions are different AND all TC's in the testsuite have PASSED, then SCF file
    ...                 collected from the TL will be updated on the 'testconfigs' repository automatically.
    ${topo_check}    Verify install and suite topology match
    Return From Keyword If    '${topo_check}' == 'False'
    ${NIDD_Update}    Is NIDD Update Required
    Return From Keyword If    '${NIDD_Update}' == 'False'
    ${status}    Add ca_5gair User in ssh config
    Run Keyword And Return If    '${status}' == 'False'
    ...    Log To Console    NIDD update skipped as ca_5gair user addition failure
    ${dic}    Get config file path from Yaml
    &{gnb_scf_file_repo}    Create Dictionary    gNB_DU_scf=${EMPTY}    gNB_CU_scf=${EMPTY}
    FOR   ${key}  IN   @{gnb_scf_file_repo.keys()}
        ${scf_file_path}    Get From Dictionary    ${dic}   ${key}
        Continue For Loop If    '${key}' == 'gNB_CU_scf' and '${scf_file_path}' == '${None}'
        ${scf_from_repo}=    Set Variable    ${AP_configs}/${scf_file_path}
        ${scf_from_tl}    Set Variable If    '${key}' == 'gNB_DU_scf'    ${coamSCF}    ${CU_SCF}
        ${nidd1_scf_repo}    get_nidd_version_from_scf_file    ${scf_from_repo}    1
        ${nidd1_scf_tl}    get_nidd_version_from_scf_file    ${scf_from_tl}    1
        ${nidd2_scf_repo}    get_nidd_version_from_scf_file    ${scf_from_repo}    2
        ${nidd2_scf_tl}    get_nidd_version_from_scf_file    ${scf_from_tl}    2
        ${nidd_condition}  Catenate
        ...    ('${nidd1_scf_repo}' not in '${nidd1_scf_tl}' and 'error' not in '${nidd1_scf_repo}'
        ...    and 'error' not in '${nidd1_scf_tl}' and '${nidd1_scf_repo}' != '' and '${nidd1_scf_tl}' != '')
        ...    or ('${nidd2_scf_repo}' not in '${nidd2_scf_tl}' and 'error' not in '${nidd2_scf_repo}'
        ...    and 'error' not in '${nidd2_scf_tl}' and '${nidd2_scf_repo}' != '' and '${nidd2_scf_tl}' != '')
        ${nidd_condition}  Evaluate    ${nidd_condition}
        ${nidd_value}    Get NIDD version    ${nidd1_scf_repo}    ${nidd1_scf_tl}    ${nidd2_scf_repo}    ${nidd2_scf_tl}
        Run Keyword If     ${nidd_condition}    Update SCF on testconfigs    ${scf_from_tl}    ${scf_from_repo}    ${nidd_value}
        ...    ELSE     Log    NIDD version is the same before and after commissioning, no need to update SCF on repo.
    END

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
    ${nidd_value}    Evaluate    '${nidd1_scf_tl}' if ('${nidd1_scf_tl}' > '${nidd1_scf_repo}') else None
    ${nidd_value}    Evaluate
    ...    '${nidd2_scf_tl}' if ('${nidd_value}' == 'None' and ('${nidd2_scf_tl}' > '${nidd2_scf_repo}')) else '${nidd_value}'
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
    ${topology_from_install}    Run Keyword If    ${testconfig_repo_flag}    Get Topology From Agent Logs
    ...    ELSE    Get Topology From Common Agent Logs
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

Get Topology From Common Agent Logs
    [Documentation]  This keyword will get the topology from Common Agent logs
    ${single_run_flag}   Run Keyword And Return Status    File Should Exist    ${single_run_info_for_common_agent}
    ${agent_log_file}    Set Variable If    ${single_run_flag}    ${single_run_info_for_common_agent}
    ...    ${testline_results_file_common_agent}
    ${topology_from_install}    Get Topology from Common Agent File    ${agent_log_file}
    [Return]    ${topology_from_install}

Get Topology from INFO File
    [Arguments]    ${file_path}
    ${file_content}    OperatingSystem.Get File    ${file_path}
    ${topology_from_install}    Should Match Regexp    ${file_content}    LABEL:\\s+(\\S+)
    Log To Console    INFO file is present and Topology is ${topology_from_install[1]}
    [Return]    ${topology_from_install[1]}

Get Topology from Common Agent File
    [Arguments]    ${file_path}
    ${file_content}    OperatingSystem.Get File    ${file_path}
    ${label_from_install}    Should Match Regexp    ${file_content}    LABEL:\\s+(\\S+)
    ${variant_from_install}    Should Match Regexp    ${file_content}    VARIANT:\\s+(\\S+)
    ${topology_from_install}	Set Variable	${label_from_install[1]}_${variant_from_install[1]}
    Set Suite Variable    ${topology_label}    ${label_from_install[1]}
    Set Suite Variable    ${topology_variant}    ${variant_from_install[1]}
    Log To Console    Agent file is present and Topology is ${topology_from_install}
    [Return]    ${topology_from_install}

Update WTS Config File To Enable TCP on Another QCI
    [Documentation]    This keyword is used to update WTS config file on bearer config details
    ...                Modified Date: 31-03-2022
    ...                Last Modified by: gopalakrishnan.n@nokia.com
    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_DIR}/${SUITE_WTS_CFG} ${WTS_DIR}/${SUITE_WTS_CFG}_repo
    wts_conf.load_wts_cfg    file_path=${WTS_DIR}/${SUITE_WTS_CFG}
    wts_conf.modify    command=enb_param id=1    modification=endc_capable_qci=all
    wts_conf.insert    command=set_bearer id=3 ue=11 qci=5 pdn=1   location=after    reference=set_bearer id=2 ue=11
    wts_conf.insert    command=set_bearer id=3 ue=12 qci=5 pdn=1   location=after    reference=set_bearer id=2 ue=12
    wts_conf.save_wts_cfg    file_path=${WTS_DIR}/${SUITE_WTS_CFG}

Update Bearer Configuration For TCP Traffic
    [Documentation]    This keyword will updat ethe required configuration updates when TCP traffic needs to be pumped
    ...                Modified Date: 31-03-2022
    ...                Last Modified by: gopalakrishnan.n@nokia.com
    Return From Keyword If    '${DATA_TCP_ENABLE_FLAG}' != 'True'
    Update WTS Config File To Enable TCP on Another QCI

Highthroughput for QT
    Set Suite Variable    ${dl_rate}    ${HighTput_dl_rate}
    Set Suite Variable    ${ul_rate}    ${HighTput_ul_rate}
    Set Suite Variable    ${traffic_dl_rate}    ${HighTput_dl_rate}
    Set Suite Variable    ${traffic_ul_rate}    ${HighTput_ul_rate}
    Set Suite Variable    ${UL_TCP_data_rate}    ${HighTput_ul_rate}
    Set Suite Variable    ${DL_TCP_data_rate}    ${HighTput_dl_rate}

Stop logCollection for HighTput
    Run Keyword Without Failure    Stop sosReport Tcpdump    attach_traffic

Check Trf duration for High Throughput
    [Arguments]    ${duration}
    ${mins}=    Run Keyword And Return Status    Should Match Regexp   ${duration}  \\d(\\s*)+m[a-z]*
    ${secs}=    Run Keyword And Return Status    Should Match Regexp   ${duration}  \\d(\\s*)+s[a-z]*
    ${dur_min}    Run Keyword If    '${mins}' == 'True'
    ...    check Trf Duration for HightTput min    ${duration}
    ${dur_sec}    Run Keyword If    '${secs}' == 'True'
    ...    check Trf Duration for HightTput sec    ${duration}
    Set Suite Variable   ${dur_min}
    Set Suite Variable   ${dur_sec}
    ${dur_null}    Run Keyword If    '${dur_min}' == 'None' and '${dur_sec}' == 'None'
    ...    check Trf Duration for HightTput sec    ${duration}
    Set Suite Variable   ${dur_null}
    Set High Throughput Flag For TCP DUMP

check Trf Duration for HightTput min
    [Arguments]    ${duration}
    ${trf_rm} =    Remove String   ${duration}    minutes    mins    min    m
    Set Suite Variable    ${trf_rm}
    ${trf_dur_check}=    Evaluate    (${trf_rm}>${TP_eval_min})
    [Return]    ${trf_dur_check}

check Trf Duration for HightTput sec
    [Arguments]    ${duration}
    ${trf_sec} =    Remove String   ${duration}    seconds    secs    sec    s
    Set Suite Variable    ${trf_sec}
    ${trf_dur_check}=    Evaluate    (${trf_sec}>${TP_eval_sec})
    [Return]    ${trf_dur_check}

Set High Throughput Flag For Selected Variants
    Run Keyword If    '${apConfiguration}' == '${HTpCfg}[2]'    Set Suite Variable    ${duration}    ${P0_duration}
    Run Keyword If    '${apConfiguration}' in "@{HTpCfg}"
    ...    Set Suite Variable    ${HIGH_THROUGHPUT_FLAG}    True

Set Max Throughput Flag For Selected Variants
    ${MTpCfg}=    Catenate    '${apConfiguration}' in   "@{MTpCfg}"
    Run Keyword If    ${MTpCfg} and '${AP_P1Perf}' != 'True' and '${AP_P1Perf_mmwv}' != 'True'
    ...    Set Suite Variable    ${MAX_THROUGHPUT}    True
    ...    ELSE    Set Suite Variable    ${MAX_THROUGHPUT}    False
    Run Keyword If    '${apConfiguration}' == 'fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_4S_1CC'
    ...    Set Suite Variable    ${FR1_TDD_FDD}    True
    Run Keyword If    '${apConfiguration}' == 'fs_sansa_cpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_4S_1CC_GMC'
    ...    Set Suite Variable    ${FR1_TDD_FDD}    True
    Run Keyword If    '${apConfiguration}' in "@{BFCfg}"
    ...    Set Suite Variable    ${FR1_TDD_FDD}    True
    Run Keyword If    '${apConfiguration}' == 'fs_sansa_ecpri_cmwv_fdd_ecpri_cmwv_tdd_LO_AP_LO_ORAN_GMC'
    ...    Set Suite Variable    ${ORAN_TDD_FDD}    True
    Run Keyword If    '${HIGH_THROUGHPUT_FLAG}' == 'True'    Set Suite Variable    ${MAX_THROUGHPUT}    False
    Run Keyword If    '${MAX_THROUGHPUT}' == 'True'    Set Suite Variable    ${duration}    300sec

Set High Throughput Flag For TCP DUMP
    Run Keyword If    '${dur_min}' == 'True' or '${dur_sec}' == 'True' or '${dur_null}' == 'True'
    ...    Set Suite Variable    ${HIGH_THROUGHPUT_TCPDUMP}    True
    ...    ELSE    Set Suite Variable    ${HIGH_THROUGHPUT_TCPDUMP}    False

HighThroughput
    [Arguments]    ${duration}
    Highthroughput for QT
    Check Trf duration for High Throughput    ${duration}

Stop tcp dump for high throughput Scenario
    sleep    ${tcp_dump_dur_HTp}
    Run Keyword If    '${TTI_TRACE}' == 'False'    Run    sudo pkill tcpdump
    Run Keyword If    '${dur_min}' == 'True'
    ...    Get Tput duration In Min For High Tput Scenario    ${trf_rm}
    Run Keyword If    '${dur_sec}' == 'True'
    ...    Get Tput duration In Sec For High Tput Scenario    ${trf_sec}
    Sleep    ${durationTP}

Get Tput duration In Min For High Tput Scenario
    [Arguments]    ${trf_rm}
    ${durationTP}=    Evaluate    (${trf_rm}-${TP_eval_min})
    ${durationTP}=    Set Variable    ${durationTP}min
    Set Suite Variable    ${durationTP}

Get Tput duration In Sec For High Tput Scenario
    [Arguments]    ${trf_sec}
    ${durationTP}=    Evaluate    (${trf_sec}-${TP_eval_sec})
    Set Suite Variable    ${durationTP}

Start WTS For CUS
    [Documentation]    Kill running WTS binaries if any, configure ETH3, retrieve files and configure WTS
    Log to Console                 Starting WTS...
    Connect To WTS VM
    wtsrunner.configure_wtsemu_edaemon    edaemon_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=22222
    ...                                   sudo_password=ute
    wtsrunner.configure_wtsemu_egate      egate_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=20000
    ...                                   nostats=True
    wtsrunner.start_wtsemu                egate_console_ip=${WTS.Ip}
    ...                                   egate_port=20000
    ${cfg_filename}  set variable   ${WTS_DIR}/${SUITE_WTS_CFG}
    wtsrunner.configure                      file=${cfg_filename}
    Check Simmode Status
    Wait Until Keyword Succeeds    2 min    30 sec    Verify if sim state is active

Verify UE_stats Average Rate for SA
    [Arguments]    ${ueid}    ${DL_RATE}    ${UL_RATE}
    ${data_rate}=     Get Average DL data rate for UE via Egate    ue=${ueid}    scell=primary,secondary    type=pdsch
    ${dl_avg_traffic1}=    Evaluate    (${DL_RATE}*0.9)*1000000
    ${dl_avg_traffic2}=    Evaluate    (${DL_RATE}*1.2)*1000000
    Should Be True    ${data_rate} >= ${dl_avg_traffic1}    msg=DL avg Traffic Failed! for Cell
    ${status}    Run Keyword And Return Status    Should Be True    ${data_rate} <= ${dl_avg_traffic2}    msg=DL avg Traffic is more than actual
    Run Keyword If    '${status}' == 'False'    Log To Console    DL avg Traffic is more than actual
    ${data_rate}=     Get Average UL data rate for UE via Egate    ue=${ueid}    scell=primary,secondary    type=pusch
    ${ul_avg_traffic1}=   Evaluate    (${UL_RATE}*0.9)*1000000
    ${ul_avg_traffic2}=   Evaluate    (${UL_RATE}*1.2)*1000000
    Should Be True    ${data_rate} >= ${ul_avg_traffic1}    msg=UL avg Traffic Failed! for Cell
    ${status_1}    Run Keyword And Return Status    Should Be True    ${data_rate} <= ${ul_avg_traffic2}    msg=UL avg Traffic is more than actual
    Run Keyword If    '${status_1}' == 'False'    Log To Console    UL avg Traffic is more than actual

Verify UE_stats Average Rate for SA_UL
    [Arguments]    ${ueid}    ${UL_RATE}
    ${data_rate}=     Get Average UL data rate for UE via Egate    ue=${ueid}    scell=primary,secondary    type=pusch
    ${ul_avg_traffic1}=   Evaluate    (${UL_RATE}*0.9)*1000000
    ${ul_avg_traffic2}=   Evaluate    (${UL_RATE}*1.2)*1000000
    Should Be True    ${data_rate} >= ${ul_avg_traffic1}    msg=UL avg Traffic Failed! for Cell
    ${status_1}    Run Keyword And Return Status    Should Be True    ${data_rate} <= ${ul_avg_traffic2}    msg=UL avg Traffic is more than actual
    Run Keyword If    '${status_1}' == 'False'    Log To Console    UL avg Traffic is more than actual

Verify UE_stats Average Rate for SA_DL
    [Arguments]    ${ueid}    ${DL_RATE}
    ${data_rate}=     Get Average DL data rate for UE via Egate    ue=${ueid}    scell=primary,secondary    type=pdsch
    ${dl_avg_traffic1}=    Evaluate    (${DL_RATE}*0.9)*1000000
    ${dl_avg_traffic2}=    Evaluate    (${DL_RATE}*1.2)*1000000
    Should Be True    ${data_rate} >= ${dl_avg_traffic1}    msg=DL avg Traffic Failed! for Cell
    ${status}    Run Keyword And Return Status    Should Be True    ${data_rate} <= ${dl_avg_traffic2}    msg=DL avg Traffic is more than actual
    Run Keyword If    '${status}' == 'False'    Log To Console    DL avg Traffic is more than actual

Verify UE_stats Average Rate for NSA
    [Arguments]    ${ueid}    ${DL_RATE}    ${UL_RATE}
    ${data_rate}=      Run Keyword if    '${CARR_AGGR}' == 'True'    Get UE stats for DL Carrier aggergation    ue=${ueid}    ELSE
    ...    Get Average DL data rate for UE via Egate    ue=${ueid}    scell=primary,secondary    type=pdsch
    ${dl_avg_traffic1}=    Evaluate    (${DL_RATE}*0.9)*1000000
    ${dl_avg_traffic2}=    Evaluate    (${DL_RATE}*1.2)*1000000
    Should Be True    ${data_rate} >= ${dl_avg_traffic1}    msg=DL avg Traffic Failed! for Cell
    ${status}    Run Keyword And Return Status    Should Be True    ${data_rate} <= ${dl_avg_traffic2}    msg=DL avg Traffic is more than actual
    Run Keyword If    '${status}' == 'False'    Log To Console    DL avg Traffic is more than actual
    ${data_rate}=      Run Keyword if    '${CARR_AGGR}' == 'True'    Get UE stats for UL Carrier aggergation    ue=${ueid}    ELSE
    ...    Get Average UL data rate for UE via Egate    ue=${ueid}    scell=primary,secondary   type=pusch
    ${ul_avg_traffic1}=   Evaluate    (${UL_RATE}*0.9)*1000000
    ${ul_avg_traffic2}=   Evaluate    (${UL_RATE}*1.2)*1000000
    Should Be True    ${data_rate} >= ${ul_avg_traffic1}    msg=UL avg Traffic Failed! for Cell
    ${status_1}    Run Keyword And Return Status    Should Be True    ${data_rate} <= ${ul_avg_traffic2}    msg=UL avg Traffic is more than actual
    Run Keyword If    '${status_1}' == 'False'    Log To Console    UL avg Traffic is more than actual

Verify UE_stats Average Rate for NSA_UL
    [Arguments]    ${ueid}    ${UL_RATE}
    ${data_rate}=      Run Keyword if    '${CARR_AGGR}' == 'True'    Get UE stats for UL Carrier aggergation    ue=${ueid}    ELSE
    ...    Get Average UL data rate for UE via Egate    ue=${ueid}    scell=primary,secondary   type=pusch
    ${ul_avg_traffic1}=   Evaluate    (${UL_RATE}*0.9)*1000000
    ${ul_avg_traffic2}=   Evaluate    (${UL_RATE}*1.2)*1000000
    Should Be True    ${data_rate} >= ${ul_avg_traffic1}    msg=UL avg Traffic Failed! for Cell
    ${status_1}    Run Keyword And Return Status    Should Be True    ${data_rate} <= ${ul_avg_traffic2}    msg=UL avg Traffic is more than actual
    Run Keyword If    '${status_1}' == 'False'    Log To Console    UL avg Traffic is more than actual


Verify UE_stats Average Rate for NSA_DL
    [Arguments]    ${ueid}    ${DL_RATE}
    ${data_rate}=      Run Keyword if    '${CARR_AGGR}' == 'True'    Get UE stats for DL Carrier aggergation    ue=${ueid}    ELSE
    ...    Get Average DL data rate for UE via Egate    ue=${ueid}    scell=primary,secondary    type=pdsch
    ${dl_avg_traffic1}=    Evaluate    (${DL_RATE}*0.9)*1000000
    ${dl_avg_traffic2}=    Evaluate    (${DL_RATE}*1.2)*1000000
    Should Be True    ${data_rate} >= ${dl_avg_traffic1}    msg=DL avg Traffic Failed! for Cell
    ${status}    Run Keyword And Return Status    Should Be True    ${data_rate} <= ${dl_avg_traffic2}    msg=DL avg Traffic is more than actual
    Run Keyword If    '${status}' == 'False'    Log To Console    DL avg Traffic is more than actual

Get Average data rate for SANSA UE from Egate output
    [Arguments]    ${output}    ${ue}    ${dl_ul}
    ${output}=    Get Average data rate from Egate Console File    ue=${ue}    dl_ul=${dl_ul}
    ${output_1}=    Get Regexp Matches    ${output}    ${SPACE}*(\\d+\.\\d+)${SPACE}*Mbps${SPACE}*    1
    ${output_1}    Evaluate    ${output_1}[-1]
    Append To File    ${OUTPUT_DIR}/l3call_tp.txt    \nUE${ue}:${dl_ul} Average data rate: ${output_1} Mbit/s
    ${data_rate}=     Evaluate    ${output_1} * 1000000
    [Return]    ${data_rate}

Get Average data rate from Egate Console File
    [Arguments]    ${ue}    ${dl_ul}
    ${output}=    Run Keyword if    '${ca_ag}' == 'False'    Derive Average data from Egate console file    ue=${ue}    dl_ul=${dl_ul}    ELSE
    ...               Derive Carrier Aggregated Average data from Egate console file    ue=${ue}    dl_ul=${dl_ul}
    Return From Keyword    ${output}

Derive Average data from Egate console file
    [Arguments]    ${ue}    ${dl_ul}    ${file}=${run_script_log_set}
    Log to console    Fetching ue_nr_stats from egate_console file!!!
    wtsrunner.ue_disp   id=${ue}
    sleep    5s
    wtsrunner.script    file=${file}    entry=sim_log_set_flush()
    sleep    5s
    ${output}=    Run Keyword if    '${dl_ul}' == 'UL'
    ...    find_tput_stats_from_egate_console_file    UE-${ue}: NR PUSCH Throughput
    ...    ${WTS_DIR}/egate_console.log    mode=NON_CA
    ...    ELSE    find_tput_stats_from_egate_console_file    UE-${ue}: NR PDSCH Throughput
    ...    ${WTS_DIR}/egate_console.log    mode=NON_CA
    Return From Keyword    ${output}

Derive Carrier Aggregated Average data from Egate console file
    [Arguments]    ${ue}    ${dl_ul}    ${file}=${run_script_log_set}
    Log to console    Fetching ue_nr_stats from egate_console file!!!
    wtsrunner.ue_disp   id=${ue}
    sleep    5s
    wtsrunner.script    file=${file}    entry=sim_log_set_flush()
    sleep    5s
    ${output}=    Run Keyword if    '${dl_ul}' == 'UL'
    ...    find_tput_stats_from_egate_console_file    UE-${ue}: NR PUSCH Throughput
    ...    ${WTS_DIR}/egate_console.log    mode=CA
    ...    ELSE    find_tput_stats_from_egate_console_file    UE-${ue}: NR PDSCH Throughput
    ...    ${WTS_DIR}/egate_console.log    mode=CA
    Return From Keyword    ${output}

Get Average DL data rate for UE via Egate
    [Arguments]    ${ue}    ${scell}    ${type}    ${dl_ul}=DL
    Log    !!!${dl_ul}!!!
    wtsrunner.script    file=${run_script_log_set}    entry=sim_log_set_flush()
    ${data_rate}=    Display UE DL traffic stats    ue=${ue}    scell=${scell}    type=${type}
    [Return]    ${data_rate}

Get Average UL data rate for UE via Egate
    [Arguments]    ${ue}    ${scell}    ${type}    ${dl_ul}=UL
    Log    !!!${dl_ul}!!!
    wtsrunner.script    file=${run_script_log_set}    entry=sim_log_set_flush()
    ${data_rate}=    Display UE UL traffic stats    ue=${ue}    scell=${scell}    type=${type}
    [Return]    ${data_rate}

Display UE DL traffic stats
    [Arguments]    ${ue}    ${scell}    ${type}    ${dl_ul}=DL
    wtsrunner.ue_stats_nr  id=${ue}  type=${type} scell=${scell}
    Sleep    2s    reason=wait command to be executed
    ${output}      wtsrunner.read_wtsemu_output_until    expected=UE-${ue}: NR PDSCH
    ...     timeout=30
    ${data_rate}=    Get Average data rate for SANSA UE from Egate output    ${output}    ${ue}    ${dl_ul}
    ${data_rate}=    Convert to Number    ${data_rate}
    [Return]    ${data_rate}

Display UE UL traffic stats
    [Arguments]    ${ue}    ${scell}    ${type}    ${dl_ul}=UL
    wtsrunner.ue_stats_nr  id=${ue}  type=${type} scell=${scell}
    Sleep    2s    reason=wait command to be executed
    ${output}      wtsrunner.read_wtsemu_output_until    expected=UE-${ue}: NR PUSCH
    ...     timeout=30
    ${data_rate}=    Get Average data rate for SANSA UE from Egate output    ${output}    ${ue}    ${dl_ul}
    ${data_rate}=    Convert to Number    ${data_rate}
    [Return]    ${data_rate}

Stop tcp dump for QT high throughput Scenario
    Run Keyword If    '${TTI_TRACE}' == 'False'    Run    sudo pkill tcpdump

Highthroughput for QT FR1
    Highthroughput for QT FR1 SA
    Highthroughput for QT FR1 NSA

Highthroughput for QT FR1 SA
    Set Suite Variable    ${traffic_dl_rate}    ${MTp_FR1_TDD_SA_dl}
    Set Suite Variable    ${traffic_ul_rate}    ${MTp_FR1_TDD_SA_ul}
    ${traffic_dl_rate}    Get Variable Value    ${MTp_FR1_TDD_SA_dl}    ${traffic_dl_rate}
    ${traffic_ul_rate}    Get Variable Value    ${MTp_FR1_TDD_SA_ul}    ${traffic_ul_rate}
    Set Suite Variable    ${UL_TCP_data_rate}    ${MTp_FR1_TDD_SA_ul}
    Set Suite Variable    ${DL_TCP_data_rate}    ${MTp_FR1_TDD_SA_dl}

Highthroughput for QT FR1 NSA
    Set Suite Variable    ${traffic_dl_rate}    ${MTp_FR1_TDD_NSA_dl}
    Set Suite Variable    ${traffic_ul_rate}    ${MTp_FR1_TDD_NSA_ul}
    ${traffic_dl_rate}    Get Variable Value    ${MTp_FR1_TDD_NSA_dl}    ${traffic_dl_rate}
    ${traffic_ul_rate}    Get Variable Value    ${MTp_FR1_TDD_NSA_ul}    ${traffic_ul_rate}
    Set Suite Variable    ${UL_TCP_data_rate}    ${MTp_FR1_TDD_NSA_ul}
    Set Suite Variable    ${DL_TCP_data_rate}    ${MTp_FR1_TDD_NSA_dl}

Highthroughput for QT FR2 NSA
    Set Suite Variable    ${traffic_dl_rate}    ${MTp_FR2_TDD_NSA_dl}
    Set Suite Variable    ${traffic_ul_rate}    ${MTp_FR2_TDD_NSA_ul}

Highthroughput for QT FR1 FDD
    Highthroughput for QT FR1 FDD SA
    Highthroughput for QT FR1 FDD NSA

Highthroughput for QT FR2 SA
    Set Suite Variable    ${traffic_dl_rate}    ${MTp_FR2_TDD_NSA_dl}
    Set Suite Variable    ${traffic_ul_rate}    ${MTp_FR2_TDD_NSA_ul}

Highthroughput for QT FR1 FDD SA
    Set Suite Variable    ${traffic_dl_rate}    ${MTp_FR1_FDD_SA_dl}
    Set Suite Variable    ${traffic_ul_rate}    ${MTp_FR1_FDD_SA_ul}
    ${traffic_dl_rate}    Get Variable Value    ${MTp_FR1_FDD_SA_dl}    ${traffic_dl_rate}
    ${traffic_dl_rate}    Get Variable Value    ${MTp_FR1_FDD_SA_ul}    ${traffic_ul_rate}

Highthroughput for QT FR1 FDD NSA
    Set Suite Variable    ${traffic_dl_rate}    ${MTp_FR1_FDD_NSA_dl}
    Set Suite Variable    ${traffic_ul_rate}    ${MTp_FR1_FDD_NSA_ul}
    ${traffic_dl_rate}    Get Variable Value    ${MTp_FR1_FDD_NSA_dl}    ${traffic_dl_rate}
    ${traffic_dl_rate}    Get Variable Value    ${MTp_FR1_FDD_NSA_ul}    ${traffic_ul_rate}

MaxThroughput for 6G SA TDD
    Set Suite Variable    ${traffic_dl_rate}    ${MTp_6G_TDD_SA_dl}
    Set Suite Variable    ${traffic_ul_rate}    ${MTp_6G_TDD_SA_ul}

MaxThroughput for VRAN SA TDD
    Set Suite Variable    ${traffic_dl_rate}    ${MTp_VRAN_TDD_SA_dl}
    Set Suite Variable    ${traffic_ul_rate}    ${MTp_VRAN_TDD_SA_ul}

MaxThroughput for VRAN NSA TDD
    Set Suite Variable    ${traffic_dl_rate}    ${MTp_VRAN_TDD_NSA_dl}
    Set Suite Variable    ${traffic_ul_rate}    ${MTp_VRAN_TDD_NSA_ul}

MaxThroughput for MP AP LO TDD
    Set Suite Variable    ${traffic_dl_rate}    ${MTp_MP_AP_LO_TDD_SA_dl}
    Set Suite Variable    ${traffic_ul_rate}    ${MTp_MP_AP_LO_TDD_SA_ul}

Highthroughput datarates for SA TDD_FDD QT
    Highthroughput for QT SA TDD
    Highthroughput for QT SA FDD

Highthroughput for QT SA TDD
    [Documentation]    This keyword will set Highthroughput values for QT SA TDD
    ...                Modified Date: 15-11-2023
    ...                Last Modified by: m.sangeetha@nokia.com
    Run Keyword if    '${ORAN_TDD_FDD}' == 'True' or '${FR1_TDD_FDD}' == 'True'    Set Suite Variable    ${traffic_sa_tdd_dl_rate}
    ...    ${MTp_FR1_TDD_SA_dl}
    Run Keyword if    '${ORAN_TDD_FDD}' == 'True' or '${FR1_TDD_FDD}' == 'True'    Set Suite Variable    ${traffic_sa_tdd_ul_rate}
    ...    ${MTp_FR1_TDD_SA_ul}

Highthroughput for QT SA FDD
    [Documentation]    This keyword will set Highthroughput values for QT SA FDD
    ...                Modified Date: 15-11-2023
    ...                Last Modified by: m.sangeetha@nokia.com
    Run Keyword if    '${ORAN_TDD_FDD}' == 'True' or '${FR1_TDD_FDD}' == 'True'    Set Suite Variable    ${traffic_sa_fdd_dl_rate}
    ...    ${MTp_FR1_FDD_SA_dl}
    Run Keyword if    '${ORAN_TDD_FDD}' == 'True' or '${FR1_TDD_FDD}' == 'True'    Set Suite Variable    ${traffic_sa_fdd_ul_rate}
    ...    ${MTp_FR1_FDD_SA_ul}

Highthroughput datarates for NSA TDD_FDD QT
    Highthroughput for QT NSA TDD
    Highthroughput for QT NSA FDD

Highthroughput for QT NSA TDD
    [Documentation]    This keyword will set Highthroughput values for QT NSA TDD
    ...                Modified Date: 15-11-2023
    ...                Last Modified by: m.sangeetha@nokia.com
    Run Keyword if    '${ORAN_TDD_FDD}' == 'True' or '${FR1_TDD_FDD}' == 'True'    Set Suite Variable    ${traffic_nsa_tdd_dl_rate}
    ...    ${MTp_FR1_TDD_NSA_dl}
    Run Keyword if    '${ORAN_TDD_FDD}' == 'True' or '${FR1_TDD_FDD}' == 'True'    Set Suite Variable    ${traffic_nsa_tdd_ul_rate}
    ...    ${MTp_FR1_TDD_NSA_ul}

Highthroughput for QT NSA FDD
    [Documentation]    This keyword will set Highthroughput values for QT NSA FDD
    ...                Modified Date: 15-11-2023
    ...                Last Modified by: m.sangeetha@nokia.com
    Run Keyword if    '${ORAN_TDD_FDD}' == 'True' or '${FR1_TDD_FDD}' == 'True'    Set Suite Variable    ${traffic_nsa_fdd_dl_rate}
    ...    ${MTp_FR1_FDD_NSA_dl}
    Run Keyword if    '${ORAN_TDD_FDD}' == 'True' or '${FR1_TDD_FDD}' == 'True'    Set Suite Variable    ${traffic_nsa_fdd_ul_rate}
    ...    ${MTp_FR1_FDD_NSA_ul}

BeamForming Profile creation
    FOR    ${pr_id}    ${ue_beam_index}    ${best_beam}    ${best_rsrp}    ${avg_rsrp}    IN ZIP    ${profile_id_multi_BF}
    ...    ${ueBeamIndexInitial_vals}    ${ssbeam_bestbeam_id_multi_BF}    ${ssbeam_rsrp_best_id_multi_BF}    ${ssbeam_rsrp_avg_id_multi_BF}
        wtsrunner.beam_control_testmode_nr    profile_id=${pr_id}    ueBeamIndexInitial=${ue_beam_index}
        ...    ssbeam_bestbeam=${best_beam}    ssbeam_rsrp_best=${best_rsrp}    ssbeam_rsrp_avg=${avg_rsrp}
        sleep    2s
    END

Enable SA Multi UE BeamForming
    FOR    ${ue_id}    ${pr_id}    IN ZIP    ${sa_ueids_multi_BF}    ${profile_id_multi_BF}
        wtsrunner.ue_testmode_set_nr    id=${ue_id}    testmode=beam_control    action=activate    profile_id=${pr_id}
    END

Enable NSA Multi UE BeamForming
    FOR    ${ue_id}    ${pr_id}    IN ZIP    ${nsa_ueids_multi_BF}    ${profile_id_multi_BF}
        wtsrunner.ue_testmode_set_nr    id=${ue_id}    testmode=beam_control    action=activate    profile_id=${pr_id}
    END

Enable BeamForming For SA
	wtsrunner.beam_control_testmode_nr    profile_id=${profile_id_2}    ueBeamIndexInitial=${ueBIndex_Initial_2}
        ...    ssbeam_bestbeam=${ssbeam_bestbeam_2}    ssbeam_rsrp_best=${ssbeam_rsrp_best_2}    ssbeam_rsrp_avg=${ssbeam_rsrp_avg_2}
	sleep    2s
	wtsrunner.ue_testmode_set_nr    id=1    testmode=beam_control    action=activate    profile_id=${profile_id_2}

Enable BeamForming For NSA
	wtsrunner.beam_control_testmode_nr    profile_id=${profile_id_1}    ueBeamIndexInitial=${ueBIndex_Initial_1}
        ...    ssbeam_bestbeam=${ssbeam_bestbeam_1}    ssbeam_rsrp_best=${ssbeam_rsrp_best_1}    ssbeam_rsrp_avg=${ssbeam_rsrp_avg_1}
	sleep    2s
	wtsrunner.ue_testmode_set_nr    id=101    testmode=beam_control    action=activate    profile_id=${profile_id_1}

Scell Addition for Carrier Aggregation
    wtsrunner.enb_endc_param    id=${enb_endc_param_id}    serving_cell_index_range_scg=${serving_cell_range}

Get UE stats for DL Carrier aggergation
    [Arguments]    ${ue}
    set suite variable    ${ca_ag}    True
    ${data_rate}=    Display UE DL traffic stats    ue=${ue}    scell=primary,secondary    type=pdsch
    [Return]    ${data_rate}

Get UE stats for UL Carrier aggergation
    [Arguments]    ${ue}
    set suite variable    ${ca_ag}    True
    ${data_rate}=    Display UE UL traffic stats    ue=${ue}    scell=primary,secondary    type=pusch
    [Return]    ${data_rate}

Calculate Traffic data rate
    [Arguments]    ${disp}
    ${data_rate_1}=    calculate_sum_of_ca_traffic    ${disp}
    ${data_rate}=     Evaluate    ${data_rate_1} * 1000000
    [Return]    ${data_rate}

Check Scell addition for Carrier Aggregation success
    Check Pattern in Egate Console Log        ${CA_Verification_pattern}

Update WTS config file for Htput
    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_DIR}/${SUITE_WTS_CFG} ${WTS_DIR}/basic_setup_backup.cfg
    wts_conf.load_wts_cfg    file_path=${WTS_DIR}/${SUITE_WTS_CFG}
    wts_conf.insert   command=sim_param_set NR_PDCP_TRUNCATE_DL_SIZE=47 NR_PDCP_BUNDLE_DL_MAX_SIZE=1200 NR_PDCP_BUNDLE_DL_TIMEOUT=100
    ...    location=after    reference=sim_param_set NR_PDCP_CIPHERING=distributed
    wts_conf.save_wts_cfg    file_path=${WTS_DIR}/${SUITE_WTS_CFG}
    [Teardown]    Run keyword And Ignore Error    Run And Return Rc And Output   cp ${WTS_DIR}/${SUITE_WTS_CFG} ${SUITE_WTS_CFG}

Log Bearer stats without verification
    [Arguments]    ${UE_ID}=${UE_ID}    ${qfi}=1
    wtsrunner.bearer_stats  ue=${UE_ID}   pdu=1   qfi=${qfi}   dir=dl
    ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval    timeout=30
    wtsrunner.bearer_stats  ue=${UE_ID}   pdu=1   qfi=${qfi}   dir=ul
    ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval    timeout=30

Log Bearer stats without verification for 6G
    [Arguments]    ${UE_ID}=${UE_ID}    ${qfi}=1
    wtsrunner.bearer_stats  ue=${UE_ID}   pdu=1   qfi=${qfi}   dir=ul
    ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    ExternalAPConnect.Connect Ap Egate To External Ap Server    ${JUMP_HOST}    ${JUMP_USERNAME}
    ...    ${JUMP_PASSWORD}    ${JUMP_PORT}
    ExternalAPConnect.Execute Ap Egate Command    bearer_stats ue=${UE_ID} pdu=1 qfi=${qfi} dir=dl    Average packet interval
    [Teardown]    ExternalAPConnect.Disconnect External Ap Server

Log Bearer stats without verification NSA DL
    [Arguments]    ${UE_ID}=${UE_ID_SANSA}
	FOR    ${UE_ID}    IN    @{UE_IDs_NSA}
        wtsrunner.bearer_stats    ue=${UE_ID}    id=2    dir=dl
        ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
        ...                     timeout=30
	END

Log Bearer stats without verification NSA UL
    [Arguments]    ${UE_ID}=${UE_ID_SANSA}
	FOR    ${UE_ID}    IN    @{UE_IDs_NSA}
        wtsrunner.bearer_stats    ue=${UE_ID}    id=2    dir=ul
        ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
        ...                     timeout=30
	END

Log Bearer stats without verification SA Sequential
    [Arguments]    ${UE_ID}=${UE_ID}    ${qfi}=1
	FOR    ${UE_ID}    IN    @{UE_IDs_SA}
        wtsrunner.bearer_stats  ue=${UE_ID}   pdu=1   qfi=${qfi}   dir=dl
        ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
        ...                     timeout=30
        wtsrunner.bearer_stats  ue=${UE_ID}   pdu=1   qfi=${qfi}   dir=ul
        ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
        ...                     timeout=30
    END

Log Bearer stats without verification NSA Sequential
    Log Bearer stats without verification NSA DL
    Log Bearer stats without verification NSA UL
