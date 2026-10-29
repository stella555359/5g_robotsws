*** Settings ***
Documentation    author：Hongyu Jiang
...              contact: hongyu.jiang@nokia-sbell.com
...              squad group: mmw_SG_04
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Library           BuiltIn
Library           taf.ul.oam.selenium_megazone           WITH NAME    selenium_megazone
Library           ./5G000313_common_keywords.py
Variables         ./5G000313_modify_para.py
Library           taf.collectors.btslog    WITH NAME   btslog
Library           taf.collectors.core   WITH NAME   core
Library           taf.config.scf                WITH NAME    scf
Library    taf.analyzer.pcap     WITH NAME    cap
Library           taf.sbts.oam.coam.admin                 WITH NAME   admin
#Resource          ../../../../../resources/sites/Ulm/Common/commissioning.robot
#Library          ../../../../../resources/sites/Ulm/Common/python/gnb.py



*** Keywords ***
Check cell on air
    admin.connect_to    bts_host=${gNB_ip}     name=GNB_OAM
    ${status}       admin.get_bts_statuses          connection=GNB_OAM
    ${BTS_Status}     Get From Dictionary    ${status}     proceduralState
    should be equal    ${BTS_Status}     OnAir
    [Teardown]     admin.Teardown  connection=GNB_OAM

Teardown gNB cOAM SSL Connection
    [Arguments]    ${connection}=GNB_OAM
    admin.teardown    connection=GNB_OAM

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

Modify parameters online two times
    [Arguments]    ${PARAMS_TO_MODIFY1}   ${time1}    ${PARAMS_TO_MODIFY2}   ${time2}
    Modify parameters online and Active Plan    PARAMS_TO_MODIFY=${PARAMS_TO_MODIFY1}    time=${time1}
    Modify parameters online and Active Plan    PARAMS_TO_MODIFY=${PARAMS_TO_MODIFY2}    time=${time2}

COAM Check TOP Synchronization info
    [Arguments]    ${bts_addr}    ${except_topp_list}
    admin.connect_to    bts_host=${bts_addr}    name=coam_admin
    log to console    bts_host:${bts_addr}
    ${bts_sync_status}=    admin.get_bts_sync_source_status    connection=coam_admin
    admin.teardown      connection=coam_admin
    log to console    bts_sync_source_dict = ${bts_sync_status}
    ${bts_syncMode}=    Get From Dictionary    ${bts_sync_status}    syncMode
    should be equal    ${bts_syncMode}    PhaseSync
    ${syncSourceInfo}=    Get From Dictionary    ${bts_sync_status}    syncSourceInfo
    ${syncSourceInfo_list}    check_syncSourceInfo_if_right    input_list=${syncSourceInfo}
    log to console    ${syncSourceInfo_list}
    should be equal    ${except_topp_list}    ${syncSourceInfo_list}

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
    csn.Execute    command=ps -ef | grep shark | awk '{print $2}' | xargs kill -9    connection=${connection}
    csn.download_file    remote_path=/home/nokia5G/${filename}    local_path=${LOG_PATH}/${filename}
    ...    connection=${connection}
    sleep    2s
    csn.send command    command=rm /home/nokia5G/${filename}    connection=${connection}
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

BTSLOG Start btslog on local machine
    [Arguments]   ${name}=btslog
    ...           ${bts_logs_dir}=/tmp/btslog2
    __Make empty BTS logs dir      bts_logs_dir=${bts_logs_dir}
    btslog.create_btslog_collector
    ...    name=${name}
    ...    log_dir=${bts_logs_dir}
    core.setup_collectors        names=${name}
    core.start_collectors        names=${name}
    btslog.set_suite_alias       ${name}

BTSLOG Collect btslog
    [Arguments]  ${bts_logs_dir}=/tmp/btslog2
    __Stop and collect btslog on local machine
    __Copy btslog to logs dir and clean BTSlog workspace     bts_logs_dir=${bts_logs_dir}

__Stop and collect btslog on local machine
    [Arguments]   ${name}=btslog
    core.stop_collectors         names=${name}
    core.collect_collectors      names=${name}
    core.teardown_collectors     names=${name}

__Make empty BTS logs dir
    [Arguments]     ${bts_logs_dir}
    Run  if [ ! -d ${bts_logs_dir} ]; then mkdir ${bts_logs_dir}; else rm ${bts_logs_dir}/*; fi

__Copy btslog to logs dir and clean BTSlog workspace
    [Arguments]     ${bts_logs_dir}
	Run  mkdir ${OUTPUT_DIR}/${TEST_NAME}
	Run  mkdir ${OUTPUT_DIR}/${Test_Case_Name}
    Run  mv ${bts_logs_dir}/syslog_files.tgz ${OUTPUT_DIR}/${TEST_NAME}/bts_log.tgz
    Run  rm ${bts_logs_dir}/*

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
    admin.connect_to    bts_host=${gNB_ip}     name=${connection}
    ${befor_list}    Get BTS Counters List    connection=${connection}
    Modify parameters online two times    PARAMS_TO_MODIFY1=${PARAMS_TO_MODIFY1}   time1=${time1}
    ...    PARAMS_TO_MODIFY2=${PARAMS_TO_MODIFY2}   time2=${time2}
    Log    PM Wait To Nearest Measurement Period    console=yes
    Wait Until Keyword Succeeds      70min  5min   Judge Value Is Equal    befor_list=${befor_list}    connection=${connection}
    [Teardown]    run keyword and ignore error    admin.teardown      connection=${connection}

Get BTS Counter Change List2
    [Arguments]    ${connection}    ${except_list}
    admin.connect_to    bts_host=${gNB_ip}     name=${connection}
    Log    PM Wait To Nearest Measurement Period    console=yes
    Wait Until Keyword Succeeds      70min  5min   Judge Value Is Equal2    except_list=${except_list}    connection=${connection}
    [Teardown]    run keyword and ignore error    admin.teardown      connection=${connection}

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
    admin.connect_to    bts_host=${gNB_ip}     name=${connection}
    ${counter_list}    Get BTS Counters List    connection=${connection}
    [Teardown]   Run keyword and ignore error    admin.teardown      connection=${connection}
    [Return]  ${counter_list}

Get BTS Counters List
    [Arguments]    ${connection}
    ${counters_info}    admin.get_counters_info    connection=${connection}    timeout=120
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
    [Arguments]    ${CURDIR_path}
    ${connection}    admin.connect_to    bts_host=${gNB_ip}     name=GNB_OAM
    ${version}    admin.get_sw_version    connection=${connection}
    ${scf_name}    5G000313_common_keywords.Covert_BTS_Version    version=${version}
    ${default_scf}    set variable    ${CURDIR_path}/${scf_name}
    log to console   ${default_scf}
    [Return]    ${default_scf}
    [Teardown]    Run keyword and ignore error    admin.teardown      connection=${connection}

Check logfile if message is right for 313
     [Arguments]    ${Test_Case_Name}=CB005750_EA_313    ${btslog_name}=btslog.log    ${btslog_tgz}=bts_log.tgz
    ${connection}    common_keyword.Connect to TestPc
    csn.execute    command=tar zxvf ${OUTPUT_DIR}/${TEST_NAME}/${btslog_tgz} -C ${OUTPUT_DIR}/${Test_Case_Name}/    connection=${connection}
	csn.execute    command=mv ${OUTPUT_DIR}/${Test_Case_Name}/*.LOG ${OUTPUT_DIR}/${Test_Case_Name}/${btslog_name}   connection=${connection}
	sleep   5s
    ${message} =    OperatingSystem.Grep File    ${OUTPUT_DIR}/${Test_Case_Name}/${btslog_name}   Estimator output
    ${ppb_result}   check_parameter_ppb_in_btslog_file    input_content=${message}    keyword=frequency_deviation
    ${ns_result}    check_parameter_ns_in_btslog_file    input_content=${message}
    should be equal as strings    ${ppb_result}    True
    should be equal as strings    ${ns_result}    True
    [Teardown]  Run keyword and ignore error    Csn.Disconnect	connection=TESTPC

Check logfile if message is right for 316
    [Arguments]    ${ppb_value}   ${ns_value_scope}     ${btslog_name}=btslog.log
    ...    ${Test_Case_Name}=CB005750_EA_316     ${btslog_tgz}=bts_log.tgz
    ${connection}    common_keyword.Connect to TestPc
    csn.execute    command=tar zxvf ${OUTPUT_DIR}/${TEST_NAME}/${btslog_tgz} -C ${OUTPUT_DIR}/${Test_Case_Name}/    connection=${connection}
	csn.execute    command=mv ${OUTPUT_DIR}/${Test_Case_Name}/*.LOG ${OUTPUT_DIR}/${Test_Case_Name}/${btslog_name}   connection=${connection}
	sleep   5s
    ${message} =    OperatingSystem.Grep File    ${OUTPUT_DIR}/${Test_Case_Name}/${btslog_name}   Estimator output
    ${ppb_result}   check_parameter_value_in_btslog_file    input_content=${message}    keyword=frequency_deviation    except_value=${ppb_value}
    ${ns_result}    check_parameter_value_in_btslog_file    input_content=${message}    keyword=phase_error    except_value=${ns_value_scope}
    should be equal as strings    ${ppb_result}    True
    should be equal as strings    ${ns_result}    True
    [Teardown]    Csn.Disconnect	connection=TESTPC

Start btslog on ute and Check btslog for 313
    [Arguments]      ${time}=120s    ${btslog_name}=btslog
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}   password=${gNB_password}
    BTSLOG Start btslog on local machine
    sleep    ${time}
    BTSLOG Collect btslog      Test_Case_Name=CB005750_EA_313
    Check logfile if message is right for 313
    [Teardown]  Run keyword and ignore error     COAM Teardown gnb connections

Start btslog on ute and Check btslog for 316
    [Arguments]    ${time}    ${ppb_value}   ${ns_value_scope}   ${btslog_name}=btslog.log
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}   password=${gNB_password}
    BTSLOG Start btslog on local machine
    sleep    ${time}
    BTSLOG Collect btslog      Test_Case_Name=CB005750_EA_316
    Check logfile if message is right for 316   ppb_value=${ppb_value}   ns_value_scope=${ns_value_scope}
    [Teardown]  Run keyword and ignore error     COAM Teardown gnb connections
