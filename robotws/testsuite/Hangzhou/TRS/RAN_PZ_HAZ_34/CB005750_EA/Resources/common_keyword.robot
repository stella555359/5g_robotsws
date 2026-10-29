*** Settings ***
Documentation    author：Hongyu Jiang
...              contact: hongyu.jiang@nokia-sbell.com
...              squad group: mmw_SG_04
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Library           BuiltIn
Library           taf.ul.oam.selenium_megazone           WITH NAME    selenium_megazone
Library           taf.collectors.btslog                  WITH NAME   btslog
Library           taf.collectors.core                    WITH NAME   core
Library           taf.config.scf                         WITH NAME    scf
Library           taf.transport.ssh                      WITH NAME    csn
Library           taf.analyzer.pcap                      WITH NAME    cap


*** Variables ***
${CURDIR_path}            ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}
${gNB_ip}                 ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${gNB_username}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${TEST_PC_IP}             ${tl.test_pc.default_ssh_connection_details.addr}
${TEST_PC_USERNAME}       ${tl.test_pc.default_ssh_connection_details.username}
${TEST_PC_PASSWORD}       ${tl.test_pc.default_ssh_connection_details.password}

*** Keywords ***
Setup Commission SCF
     ${default_scf}    Get BTS Version And Perare SCF    CURDIR_path=${CURDIR_path}
     Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
     COAM Commission with scf file    scf_file_path=${default_scf}
     COAM Teardown gnb connections
     Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
     Wait Until Keyword Succeeds   16min   2min   common_keyword.Check cell on air
     [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections

Check cell on air
    [Arguments]      ${connection}=GNB_OAM
    log_to_console    Check cell on air
    ${status}            coam.get_bts_statuses         connection=${connection}
    ${bts_status}        get from dictionary     ${status}     proceduralState
    should be equal      ${bts_status}      OnAir

Modify parameters online and Active Plan
    [Arguments]    ${PARAMS_TO_MODIFY}   ${time}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    FOR    ${item}    IN    @{PARAMS_TO_MODIFY}
         ${dist_name}       get from dictionary     ${item}     dist_name
         ${filter_param}    get from dictionary     ${item}     filter_param
         ${new_value}       get from dictionary     ${item}     value
         selenium_coam.set_parameter_value   dist_name=${dist_name}     filter_param=${filter_param}    new_value=${new_value}
    END
    selenium_coam.validate_plan
    selenium_coam.activate_plan   activate_plan_despite_errors=${True}
    Sleep  ${time}
    [Teardown]    Run keyword and ignore error     selenium_coam.logout

Modify Common parameter via Coam
    [Arguments]  ${input_list}    ${connection}=GNB_connection    ${bts_ip}=${gNB_ip}
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}  connection=${connection}
    FOR    ${item}  IN    @{input_list}
         ${dict_value}    Get Content From Input Dict    input_dict=${item}
         coam.Perform Parameter Recommissioning    dist_name=${dict_value}[0]   parameter=${dict_value}[1]   value=${dict_value}[2]
         ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
         sleep  2min
    END
    [Teardown]  Run keyword and ignore error    coam.teardown      connection=${connection}

Modify parameters online two times
    [Arguments]    ${PARAMS_TO_MODIFY1}   ${time1}    ${PARAMS_TO_MODIFY2}   ${time2}
    Modify Common parameter via Coam    input_list=${PARAMS_TO_MODIFY1}
    Sleep   ${time1}
    Modify Common parameter via Coam    input_list=${PARAMS_TO_MODIFY2}
    Sleep   ${time2}

Get Content From Input Dict
    [Arguments]  ${input_dict}
    ${dist_name}    get from dictionary     ${input_dict}    dist_name
    ${parammeter}    get from dictionary    ${input_dict}    parameter
    ${new_value}     get from dictionary    ${input_dict}    value
    ${value_list}    create list    ${dist_name}    ${parammeter}    ${new_value}
    [Return]  ${value_list}

COAM Check TOP Synchronization info
    [Arguments]    ${bts_addr}    ${except_topp_list}
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}   connection=coam_admin
    log to console    bts_host:${bts_addr}
    ${bts_sync_status}=    coam.get_bts_sync_source_status    connection=coam_admin
    coam.teardown      connection=coam_admin
    log to console    bts_sync_source_dict = ${bts_sync_status}
    ${bts_syncMode}=    Get From Dictionary    ${bts_sync_status}    syncMode
    should be equal    ${bts_syncMode}    PhaseSync
    ${syncSourceInfo}=    Get From Dictionary    ${bts_sync_status}    syncSourceInfo
    ${syncSourceInfo_list}    check_syncSourceInfo_if_right    input_list=${syncSourceInfo}
    log to console    ${syncSourceInfo_list}
    should be equal    ${except_topp_list}    ${syncSourceInfo_list}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=coam_admin

Connect to control pc via cygwin
    [Arguments]    ${ue_index}=${1}
    ...    ${hostname}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${username}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    ${password}=${tl.ues[${ue_index}].ssh_connection_details.password}    ${alias}=cygwin
    csn.Connect to    hostname=${hostname}
    ...    username=${username}
    ...    password=${password}    alias=${alias}

Start to Capture DU_TOP Log on Control PC
    [Arguments]    ${filename}    ${connection}    ${listen_port}    ${time}
    csn.send command    command=tshark -i ${listen_port} -w ${filename}  connection=${connection}
    sleep    ${time}

Stop and Download Log
    [Arguments]    ${filename}    ${connection}    ${LOG_PATH}
    ${PID}  csn.Execute  command=ps -ef |grep shark|awk '{{print $2}}'|head -n 1
    ...    connection=${connection}
    ${PID}    strip_string    ${PID}
    csn.Execute    command=kill ${PID}    connection=${connection}
    csn.download_file    remote_path=/home/nokia5g/${filename}    local_path=${LOG_PATH}/${filename}
    ...    connection=${connection}
    sleep    2s
    csn.send command    command=rm /home/nokia5g/${filename}    connection=${connection}
    [Teardown]  Run keyword and ignore error    Csn.Disconnect	connection=${connection}

Get PARAM Value from Wireshark Log
    [Arguments]    ${check_param}    ${element_idx}=${0}    ${default_value}=False    ${condition_expression}=${None}
    ${value}=    cap.Get Element Value    element_expression=${check_param}    element_idx=${element_idx}
    ...    default_value=${default_value}    condition_expression=${condition_expression}
    Sleep    10s
    [Return]    ${value}

Read Wireshark Log
    [Arguments]    ${filename}    ${filter}=${None}
    cap.Read Cap    cap_file=${LOG_PATH}/${filename}    display_filter=${filter}

Convert pcap to text
    [Arguments]  ${source}   ${target}   ${filter}   ${connection}
    csn.send_command
    ...  command=nice tshark -X lua_script:${luashark_path} -V -r ${source} -T text > ${target} -Y ${filter}
    ...  connection=${connection}
    csn.await execution end  connection=${connection}  timeout=30min

Connect to TestPc
    [Arguments]  ${hostname}=${TEST_PC_IP}    ${username}=${TEST_PC_USERNAME}    ${password}=${TEST_PC_PASSWORD}
    ${connection}    csn.Connect to     hostname=${hostname}    username=${username}    password=${password}  alias=TESTPC
    [Return]   ${connection}

Get BTS Counter Change List
    [Arguments]    ${connection}    ${PARAMS_TO_MODIFY1}   ${time1}    ${PARAMS_TO_MODIFY2}   ${time2}
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}     connection=${connection}
    ${befor_list}    Get BTS Counters List    connection=${connection}
    Modify parameters online two times    PARAMS_TO_MODIFY1=${PARAMS_TO_MODIFY1}   time1=${time1}
    ...    PARAMS_TO_MODIFY2=${PARAMS_TO_MODIFY2}   time2=${time2}
    Log    PM Wait To Nearest Measurement Period    console=yes
    Wait Until Keyword Succeeds      70min  5min   Judge Value Is Equal    befor_list=${befor_list}    connection=${connection}
    [Teardown]    run keyword and ignore error    coam.teardown      connection=${connection}

Get BTS Counter Change List2
    [Arguments]    ${connection}    ${except_list}
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}     connection=${connection}
    Log    PM Wait To Nearest Measurement Period    console=yes
    Wait Until Keyword Succeeds      70min  5min   Judge Value Is Equal2    except_list=${except_list}    connection=${connection}
    [Teardown]    run keyword and ignore error    coam.teardown      connection=${connection}

Judge Value Is Equal
    [Arguments]    ${befor_list}    ${connection}
    ${after_list}    Get BTS Counters List    connection=${connection}
    Should Not Be Equal As Integers     ${befor_list}[0]    ${after_list}[0]
    log to console  ${after_list}

Judge Value Is Equal2
    [Arguments]    ${except_list}    ${connection}
    ${after_list}    Get BTS Counters List    connection=${connection}
    Should Be Equal As Integers     ${except_list}[0]    ${after_list}[0]
    log to console  ${after_list}

Get BTS Counters List via Api
    [Arguments]    ${connection}
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}     connection=${connection}
    ${counter_list}    Get BTS Counters List    connection=${connection}
    [Teardown]   Run keyword and ignore error    coam.teardown      connection=${connection}
    [Return]  ${counter_list}

Get BTS Counters List
    [Arguments]    ${connection}
    ${counters_info}    coam.get_counters_info    connection=${connection}    timeout=120
    ${BTS_error}    get from dictionary    ${counters_info}    BTS
    ${SMOD_error}    get from dictionary    ${BTS_error}    SMOD
    ${TOPP_error}    get from dictionary    ${SMOD_error}    TOPP-1
    ${TOP_Stats_error}    get from dictionary    ${TOPP_error}    TOP_PhaseSync_Stats
    ${counter_list}    Create List
    FOR    ${key}    IN    @{BTS_COUNTERS_list}
         ${conuters_info}    get from dictionary    ${TOP_Stats_error}    ${key}
         ${conuters_info}    Get Dictionary Values    ${conuters_info}
         ${number}    Convert to integer    ${conuters_info}[-1]
         Append To List    ${counter_list}    ${number}
    END
    [Return]  ${counter_list}

Get BTS Version And Perare SCF
    [Arguments]    ${CURDIR_path}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}     connection=${connection}
    ${version}    coam.get_sw_version    connection=${connection}
    ${scf_name}    Covert_BTS_Version    version=${version}
    ${default_scf}    set variable    ${CURDIR_path}/${scf_name}
    log to console   ${default_scf}
    [Return]    ${default_scf}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Clear Log And Dir
    [Arguments]   ${root_path}=${output_dir}
    ${del_path}    Get_File_And_Dir    root_path=${root_path}
    csn.connect_to    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}    alias=connection_ute
    FOR   ${item}  IN  @{del_path}
         csn.Execute   command=rm -rf ${item}   connection=connection_ute
    END
    csn.Execute   command=rm -rf ${root_path}/*.txt    connection=connection_ute
    csn.Execute   command=rm -rf ${root_path}/*.pcap    connection=connection_ute
    CI_interface.Common Case Teardown
    [Teardown]    Run keyword and ignore error    csn.Disconnect    connection=connection_ute

Get Active Alarm number
    [Arguments]    ${keywords}
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    ${alarm_list}    coam.get_active_alarms     connection=GNB_OAM
    ${fault_id_list}  get_active_alarms_faultId    alarms_list=${alarm_list}    keyword=${keywords}
    [Return]  ${fault_id_list}
    [Teardown]    Run keyword and ignore error     COAM Teardown gnb connections

BTSLOG Start btslog on local machine
    [Arguments]   ${name}=btslog
    ...           ${bts_logs_dir}=/tmp/btslog2
    __Make empty BTS logs dir      ${bts_logs_dir}
    btslog.create_btslog_collector
    ...    name=${name}
    ...    log_dir=${bts_logs_dir}
    Log To Console    start BTSlog
    core.setup_collectors        names=${name}
    core.start_collectors        names=${name}
    btslog.set_suite_alias       ${name}

BTSLOG Collect btslog
    [Arguments]   ${Test_Case_Name}    ${bts_log_name}=bts_log.tgz    ${bts_logs_dir}=/tmp/btslog2
    Log To Console    stop BTSlog
    __Stop and collect btslog on local machine
    __Copy btslog to logs dir and clean BTSlog workspace    bts_log_name=${bts_log_name}    bts_logs_dir=${bts_logs_dir}
    ...     Test_Case_Name=${Test_Case_Name}

__Stop and collect btslog on local machine
    [Arguments]   ${name}=btslog
    core.stop_collectors         names=${name}
    core.collect_collectors      names=${name}
    core.teardown_collectors     names=${name}

__Make empty BTS logs dir
    [Arguments]     ${bts_logs_dir}=/tmp/btslog2
    Run  if [ ! -d ${bts_logs_dir} ]; then mkdir ${bts_logs_dir}; else rm ${bts_logs_dir}/*; fi

__Copy btslog to logs dir and clean BTSlog workspace
    [Arguments]     ${Test_Case_Name}   ${bts_log_name}=bts_log.tgz     ${bts_logs_dir}=/tmp/btslog2
	Run  mkdir ${OUTPUT_DIR}/${TEST_NAME}
	Run  mkdir ${OUTPUT_DIR}/${Test_Case_Name}
    Run  mv ${bts_logs_dir}/syslog_files.tgz ${OUTPUT_DIR}/${TEST_NAME}/${bts_log_name}
    Run  rm ${bts_logs_dir}/*

Check logfile if message is right for 313
     [Arguments]      ${btslog_name}=btslog.log
    ${connection}    common_keyword.Connect to TestPc
    ${message} =    OperatingSystem.Grep File    ${OUTPUT_DIR}/${TEST NAME}/${btslog_name}   Estimator output    encoding_errors=ignore
    ${ppb_result}   check_parameter_ppb_in_btslog_file    input_content=${message}    keyword=frequency_deviation
    ${ns_result}    check_parameter_ns_in_btslog_file    input_content=${message}
    should be equal as strings    ${ppb_result}    True
    should be equal as strings    ${ns_result}    True
    [Teardown]  Run keyword and ignore error    Csn.Disconnect	connection=TESTPC

Check logfile if message is right for 316
    [Arguments]    ${ppb_value}   ${ns_value_scope}     ${btslog_name}=btslog.log
    ${connection}    common_keyword.Connect to TestPc
    ${message} =    OperatingSystem.Grep File    ${OUTPUT_DIR}/${TEST NAME}/${btslog_name}   Estimator output    encoding_errors=ignore
    ${ppb_result}   check_parameter_value_in_btslog_file    input_content=${message}    keyword=frequency_deviation    except_value=${ppb_value}
    ${ns_result}    check_parameter_value_in_btslog_file    input_content=${message}    keyword=phase_error    except_value=${ns_value_scope}
    should be equal as strings    ${ppb_result}    True
    should be equal as strings    ${ns_result}    True
    [Teardown]    Csn.Disconnect	connection=TESTPC

start btslog capture on ute
    [Arguments]    ${log_dir}=${OUTPUT_DIR}/${TEST NAME}    ${connection}=ute    ${btslog_name}=btslog.log
    csn.Connect to     hostname=${TEST_PC_IP}     username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}  alias=${connection}
    log to console    start syslog...
    Start Syslog    log_dir=${log_dir}      log_name=${btslog_name}
    ...      host_ip=${TEST_PC_IP}    ssh_username=${TEST_PC_USERNAME}    ssh_password=${TEST_PC_PASSWORD}    alias=${connection}

Start btslog on ute and Check btslog for 313
    [Arguments]      ${time}=120s    ${btslog_name}=btslog.log
    start btslog capture on ute     btslog_name=${btslog_name}
    sleep    ${time}
    stop syslog     alias=ute
    Check logfile if message is right for 313    btslog_name=${btslog_name}
    [Teardown]  Run keyword and ignore error     COAM Teardown gnb connections

Start btslog on ute and Check btslog for 316
    [Arguments]    ${time}    ${ppb_value}   ${ns_value_scope}   ${btslog_name}=btslog.log
    start btslog capture on ute     btslog_name=${btslog_name}
    sleep    ${time}
    stop syslog     alias=ute
    Check logfile if message is right for 316   ppb_value=${ppb_value}   ns_value_scope=${ns_value_scope}     btslog_name=${btslog_name}
    [Teardown]  Run keyword and ignore error     COAM Teardown gnb connections
