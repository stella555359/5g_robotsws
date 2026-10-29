*** Settings ***
Documentation    author：Hongyu Jiang
...              contact: hongyu.jiang@nokia-sbell.com
...              squad group: mmw_SG_04
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Library           BuiltIn
Library           taf.selenium.gnb.oam.coam.classical    WITH NAME    selenium_coam
Library           taf.ul.oam.selenium_megazone           WITH NAME    selenium_megazone
Library           taf.sbts.oam.coam.admin              WITH NAME    coam
Library           taf.ul.oam.selenium_coam    WITH NAME    seleniumC
Library           taf.collectors.btslog    WITH NAME   btslog
Library           taf.collectors.core   WITH NAME   core
#Resource          ../../../../../resources/sites/Ulm/Common/commissioning.robot
Library           taf.config.scf                WITH NAME    scf
#Library          ../../../../../resources/sites/Ulm/Common/python/gnb.py
Library           taf.transport.ssh      WITH NAME    csn


*** Keywords ***
Setup Commission SCF
    [Arguments]  ${connection}=GNB_OAM
    ${default_scf}    Get BTS Version And Perare SCF    CURDIR_path=${CURDIR_path}
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    COAM Commission with scf file    scf_file_path=${default_scf}
    Wait Until Keyword Succeeds   16min   2min   Check cell on air
    [Teardown]  run keyword and ignore error    coam.teardown    connection=${connection}

Check cell on air
    [Arguments]  ${connection}=GNB_OAM
    log_to_console    Check cell on air
    ${status}            coam.get_bts_statuses       connection=${connection}
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

Modify Value On DU
    [Arguments]    ${structure_modify_list}    ${bts_ip}    ${common_modify_list}=None    ${keywords_list}=None    ${connection}=GNB_connection
    ...    ${class_name}=None   ${is_structure}=${True}    ${is_common}=${True}    ${structure_index}=${CB005750_5G_EAAG_TC01}
    run keyword if  ${is_structure}    Modify Structure parameter via Coam    bts_ip=${bts_ip}    class_name=${class_name}
    ...   connection=${connection}    modify_list=${structure_modify_list}    keywords_list=${keywords_list}    index=${structure_index}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Modify Common parameter via Coam
    [Arguments]  ${input_list}    ${connection}=GNB_connection    ${bts_ip}=${gNB_ip}
    Connect to gnb coam via ssl    bts_host=${bts_ip}    connection=${connection}
    FOR    ${item}  IN    @{input_list}
         ${dict_value}    Get Content From Input Dict    input_dict=${item}
         ${status}    run keyword and return status    coam.Perform Parameter Recommissioning    
         ...    dist_name=${dict_value}[0]   parameter=${dict_value}[1]   value=${dict_value}[2]    timeout=180s
         ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
         sleep  2min
         run keyword if    ${status}==${False}    Connect to gnb coam via ssl    bts_host=${bts_ip}    connection=${connection}
         run keyword if    ${status}==${False}    Wait Until Keyword Succeeds   16min   2min   Check cell on air    connection=${connection}
         run keyword if    ${status}==${False}    coam.Perform Parameter Recommissioning    
         ...    dist_name=${dict_value}[0]   parameter=${dict_value}[1]   value=${dict_value}[2]    timeout=180s
         ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
         sleep  2min
    END
    [Teardown]  Run keyword and ignore error    coam.teardown      connection=${connection}


Modify Structure parameter via Coam
    [Arguments]   ${class_name}   ${modify_list}    ${keywords_list}    ${index}   ${connection}=GNB_CON    ${bts_ip}=${gNB_ip}
    Connect to gnb coam via ssl    bts_host=${bts_ip}    connection=${connection}
    ${get_managed_objects}     coam.get_managed_objects     class_name=${class_name}    connection=${connection}
    ${output_dict_list}    Return_Structure_Mofify_Value    input_list=${get_managed_objects}    modify_list=${modify_list}
    ...    keywords_list=${keywords_list}    index=${index}
    FOR    ${item}  IN  @{output_dict_list}
         ${dict_value}    Get Content From Input Dict    input_dict=${item}
         coam.Perform Parameter Recommissioning    dist_name=${dict_value}[0]   parameter=${dict_value}[1]   value=${dict_value}[2]
         ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
         sleep  2min
    END
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

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
    Connect to gnb coam via ssl    bts_host=${bts_addr}    connection=coam_admin
    log to console    bts_host:${bts_addr}
    ${bts_sync_status}=    coam.get_bts_sync_source_status    connection=coam_admin
    log to console    bts_sync_source_dict = ${bts_sync_status}
    ${bts_syncMode}=    Get From Dictionary    ${bts_sync_status}    syncMode
    should be equal    ${bts_syncMode}    PhaseSync
    ${syncSourceInfo}=    Get From Dictionary    ${bts_sync_status}    syncSourceInfo
    ${syncSourceInfo_list}    check_syncSourceInfo_if_right    input_list=${syncSourceInfo}
    log to console    ${syncSourceInfo_list}
    should be equal    ${except_topp_list}    ${syncSourceInfo_list}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=coam_admin

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

Start BTSlog and Dowmload Btslog
    [Arguments]  ${time}=2min
    BTSLOG Start btslog on remote machine
    sleep    ${time}
    Stop BTSLOG Collect btslog on remote machine
    Copy Btslog to UTE
    [Teardown]    Run Keyword And Ignore error    Csn.Disconnect	connection=TESTPC

BTSLOG Start btslog on remote machine
    [Arguments]    ${name}=btslog     ${bts_logs_dir}=/tmp/btslog2    ${alias}=TESTPC
    csn.Connect to    hostname=${TEST_PC_IP}    username=ute    password=ute    alias=${alias}
    csn.send_command  command=if [ ! -d ${bts_logs_dir} ]; then mkdir ${bts_logs_dir}; else rm ${bts_logs_dir}/*; fi    connection=${alias}
    &{executor}=    create dictionary    host=${TEST_PC_IP}     user=ute    password=ute
    btslog.create_btslog_collector    name=${name}    log_dir=${bts_logs_dir}    executor=${executor}
    core.setup_collectors        names=${name}
    core.start_collectors        names=${name}
    btslog.set_suite_alias       ${name}

Stop BTSLOG Collect btslog on remote machine
    [Arguments]   ${name}=btslog    ${bts_logs_dir}=/tmp/btslog2    ${alias}=TESTPC
    core.stop_collectors         names=${name}
    core.collect_collectors      names=${name}
    core.teardown_collectors     names=${name}
	csn.send_command  command=mkdir /tmp/${TEST_NAME}    connection=${alias}
    csn.send_command  command=mv ${bts_logs_dir}/syslog_files.tgz /tmp/${TEST_NAME}/bts_log.tgz    connection=${alias}
    csn.send_command  command=rm ${bts_logs_dir}/*    connection=${alias}
    [Teardown]  Run Keyword And Ignore error    Csn.Disconnect	connection=TESTPC

Copy Btslog to UTE
    [Arguments]  ${username}=${TEST_PC_USERNAME}   ${password}=${TEST_PC_PASSWORD}   ${alias}=TESTPC_local  ${dir}=/${OUTPUT_DIR}/${Test_Case_Name}
    csn.Connect to     hostname=${TEST_PC_IP}    username=${username}    password=${password}	alias=${alias}
    csn.send_command  command=if [ ! -d ${dir} ]; then mkdir ${dir}; else rm ${dir}/*; fi    connection=${alias}
    csn.send_command  command=mkdir /${OUTPUT_DIR}/${TEST_NAME}    connection=${alias}
    csn.execute    command=sudo sshpass -p ${password} scp -p ${username}@10.57.157.246:/tmp/${TEST_NAME}/bts_log.tgz /${OUTPUT_DIR}/${TEST_NAME}
    ...    connection=${alias}
    csn.execute    command=tar zxvf ${OUTPUT_DIR}/${TEST_NAME}/bts_log.tgz -C ${OUTPUT_DIR}/${Test_Case_Name}/    connection=${alias}
	csn.execute    command=mv ${OUTPUT_DIR}/${Test_Case_Name}/*.LOG ${OUTPUT_DIR}/${Test_Case_Name}/bts_log.log    connection=${alias}
    ${message} =    OperatingSystem.Grep File    ${OUTPUT_DIR}/${Test_Case_Name}/bts_log.log    Estimator output
    [Teardown]   Run Keyword And Ignore error    Csn.Disconnect	connection=${alias}


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
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    connection=${connection}
    ${befor_list}    Get BTS Counters List    connection=${connection}
    Modify parameters online two times    PARAMS_TO_MODIFY1=${PARAMS_TO_MODIFY1}   time1=${time1}
    ...    PARAMS_TO_MODIFY2=${PARAMS_TO_MODIFY2}   time2=${time2}
    Log    PM Wait To Nearest Measurement Period    console=yes
    Wait Until Keyword Succeeds      70min  5min   Judge Value Is Equal    befor_list=${befor_list}    connection=${connection}
    [Teardown]    run keyword and ignore error    coam.teardown      connection=${connection}

Get BTS Counter Change List2
    [Arguments]    ${connection}    ${except_list}
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    connection=${connection}
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
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    connection=${connection}
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
    Connect to gnb coam via ssl    bts_host=${gNB_ip}
    ${version}    coam.get_sw_version    connection=${connection}
    ${scf_name}    Covert_BTS_Version    version=${version}
    ${default_scf}    set variable    ${CURDIR_path}/${scf_name}
    log to console   ${default_scf}
    [Return]    ${default_scf}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections

Clear Log And Dir
    [Arguments]   ${root_path}=${OUTPUT DIR}
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
    [Arguments]    ${keywords}    ${BTS_IP}=${gNB_ip}
    Connect to gnb coam via ssl    bts_host=${BTS_IP}    username=${gNB_username}    password=${gNB_password}
    ${alarm_list}    coam.get_active_alarms     connection=GNB_OAM
    ${fault_id_list}  get_active_alarms_faultId    alarms_list=${alarm_list}    keyword=${keywords}
    COAM Teardown gnb connections
    [Return]  ${fault_id_list}


Check Top Source Info and Capture wireshark
    [Arguments]  ${PARAMS_TO_MODIFY}    ${except_topp_list}    ${is_commission}    ${file_name}    ${except_sync_number}   ${except_announce_number}
    ...    ${except_dscp_number}    ${listen_port}=Ethernet    ${time}=6s    ${connection}=GNB_connection
    Run Keyword If    ${is_commission}    Modify Common parameter via Coam    input_list=${PARAMS_TO_MODIFY}    connection=${connection}
    Run Keyword If    ${is_commission}    Sleep    5min
    COAM Check TOP Synchronization info   bts_addr=${gNB_ip}    except_topp_list=${except_topp_list}
    Capture Wireshark Log And Download     filename=${file_name}.pcap    time=${time}    listen_port=${listen_port}
    Convert pcap to text And Get txt Content   pacp_filename=${file_name}.pcap    txt_filename=${file_name}.txt
    ...    except_sync_number=${except_sync_number}    except_announce_number=${except_announce_number}    except_dscp_number=${except_dscp_number}

Modify parameters via Coam And Check Top Source Info
    [Arguments]  ${PARAMS_TO_MODIFY}    ${except_topp_list}    ${connection}=GNB_connection
    Modify Common parameter via Coam    input_list=${PARAMS_TO_MODIFY}    connection=${connection}
    Sleep    5min
    COAM Check TOP Synchronization info   bts_addr=${gNB_ip}    except_topp_list=${except_topp_list}

Modify parameters and Check Alarm
    [Arguments]    ${PARAMS_TO_MODIFY}   ${except_topp_list}    ${except_value}   ${alarm_number}=4298
    Modify parameters via Coam And Check Top Source Info    PARAMS_TO_MODIFY=${PARAMS_TO_MODIFY}    except_topp_list=${except_topp_list}
    Check Alarm Number Is Right    alarm_number=${alarm_number}    except_value=${except_value}

Convert pcap to text And Get txt Content
    [Arguments]      ${pacp_filename}  ${txt_filename}    ${except_sync_number}    ${except_announce_number}    ${except_dscp_number}
    ${connection}    CB005750_common_keyword.Connect to TestPc
    Convert pcap to text    source=${LOG_PATH}/${pacp_filename}
    ...  target=${LOG_PATH}/${txt_filename}   filter=" "  connection=${connection}
    ${sync_number}    get_txt_content_by_line_index    file_path=${LOG_PATH}/${txt_filename}    message=control: Sync Message (0)
    ${announce_number}    get_txt_content_by_line_index    file_path=${LOG_PATH}/${txt_filename}     message=messageId: Announce Message
    ${dscp_number}    get_txt_content_by_line_index    file_path=${LOG_PATH}/${txt_filename}     message=DSCP
    Should Be Equal As Numbers    ${sync_number}    ${except_sync_number}
    Should Be Equal As Numbers    ${announce_number}     ${except_announce_number}
    Should Be Equal As Numbers    ${dscp_number}   ${except_dscp_number}
    [Teardown]  Run keyword and ignore error    csn.Disconnect	connection=${connection}

Check Signalling Message In txt
    [Arguments]    ${pacp_filename}  ${txt_filename}
    ${connection}    CB005750_common_keyword.Connect to TestPc
    Convert pcap to text    source=${LOG_PATH}/${pacp_filename}
    ...  target=${LOG_PATH}/${txt_filename}   filter="ptp.v2.messageid == 0xc"  connection=${connection}
    ${TextFileContent}    Get File    ${LOG_PATH}/${txt_filename}
    should not be empty   ${TextFileContent}
    [Teardown]  Run keyword and ignore error    csn.Disconnect	connection=${connection}

Start btslog on ute and Check btslog
    [Arguments]    ${time}    ${ppb_value}   ${ns_value_scope}
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}   password=${gNB_password}
    BTSLOG Start btslog on local machine
    Sleep    ${time}
    BTSLOG Collect btslog
    COAM Teardown gnb connections
    Check logfile if message is right    ppb_value=${ppb_value}   ns_value_scope=${ns_value_scope}

Check logfile if message is right
    [Arguments]    ${ppb_value}   ${ns_value_scope}
    csn.Connect to     hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}	alias=TESTPC
    csn.execute    command=tar zxvf ${OUTPUT_DIR}/${TEST_NAME}/bts_log.tgz -C ${OUTPUT_DIR}/${Test_Case_Name}/    connection=TESTPC
	csn.execute    command=mv ${OUTPUT_DIR}/${Test_Case_Name}/*.LOG ${OUTPUT_DIR}/${Test_Case_Name}/bts_log.log    connection=TESTPC
    ${message} =    OperatingSystem.Grep File    ${OUTPUT_DIR}/${Test_Case_Name}/bts_log.log    Estimator output
    ${ppb_result}   check_parameter_value_in_btslog_file    input_content=${message}    keyword=frequency_deviation    except_value=${ppb_value}
    ${ns_result}    check_parameter_value_in_btslog_file    input_content=${message}    keyword=phase_error    except_value=${ns_value_scope}
    should be equal as strings    ${ppb_result}    True
    should be equal as strings    ${ns_result}    True
    [Teardown]    Csn.Disconnect	connection=TESTPC

Modify TOP Domain Number
    [Arguments]    ${alias}=cOAM_toor4nsn
    ${connection}    Connect to cOAM as toor4nsn    ip_address=${gNB_ip}     alias=${alias}
    csn.Send Command    command=iptables -I INPUT -s 10.57.249.62 -j DROP    connection=${connection}
    csn.Send Command    command=iptables -D INPUT -s 10.57.249.62 -j DROP    connection=${connection}
    csn.disconnect    connection=${alias}

Connect to cOAM as toor4nsn
    [Arguments]  ${ip_address}   ${alias}
    ${connection}=  csn.Connect to  hostname=${ip_address}
    ...                             username=toor4nsn
    ...                             password=oZPS0POrRieRtu
    ...                             alias=${alias}
    [Return]  ${connection}

Modify TOP Domain Number1
    [Arguments]    ${alias}=cOAM_toor4nsn
    ${connection}    Connect to cOAM as toor4nsn    ip_address=${gNB_ip}     alias=${alias}
    csn.Send Command    command=iptables -I INPUT -s 10.57.249.62 -j DROP    connection=${connection}
    sleep    2s
    csn.Send Command    command=iptables -D INPUT -s 10.57.249.62 -j DROP    connection=${connection}
    sleep    1s
    csn.Send Command    command=iptables -D INPUT -s 10.57.249.62 -j DROP    connection=${connection}
    csn.disconnect      connection=${alias}
    log to console      block top less than 5s
    sleep    3min

Check Information On WebUI And Check Btslog
    [Arguments]    ${except_topp_list}    ${except_other_list}   ${except_value}  ${ns_value_scope}   ${fault_id}=${True}
    ...    ${total_flag}=${True}
    Wait until keyword succeeds   10min   1min     COAM Check TOP Synchronization source info    bts_addr=${gNB_ip}
    ...    except_topp_list=${except_topp_list}    except_other_list=${except_other_list}    total_flag=${total_flag}
    sleep    3min
    ${FaultID_list}    Get Active Alarm number    keywords=additionalFaultID
    ${return_value}    check_active_alarms_faultId     faultId_list=${FaultID_list}    faultId=4298
    run keyword if    ${fault_id}    should be equal as strings    ${return_value}    ${except_value}
    Start btslog on ute and Check btslog    time=2min   ppb_value=20   ns_value_scope=${ns_value_scope}

COAM Check TOP Synchronization source info
    [Arguments]                     ${bts_addr}    ${except_topp_list}    ${except_other_list}    ${total_flag}=${False}
    Connect to gnb coam via ssl     bts_host=${bts_addr}    connection=coam_admin
    log to console                  bts_host:${bts_addr}
    ${bts_sync_status}=             coam.get_bts_sync_source_status          connection=coam_admin
    log to console                  bts_sync_source_dict=${bts_sync_status}
    ${bts_syncMode}=                Get From Dictionary                  ${bts_sync_status}         syncMode
    should be equal                 ${bts_syncMode}                      PhaseSync
    ${tuning_Mode}=                 Get From Dictionary                  ${bts_sync_status}         tuningMode
    should be equal                 ${tuning_Mode}                       Normal tuning
    ${syncSourceInfo}=              Get From Dictionary                  ${bts_sync_status}         syncSourceInfo
    ${syncSourceInfo_list}    run keyword if    ${total_flag}==${False}    check_syncSourceInfo_if_right    ${syncSourceInfo}
    ${syncSourceInfo_list}    run keyword if    ${total_flag}    check_total_syncSourceInfo_if_right    ${syncSourceInfo}
    log    ${syncSourceInfo_list}
    should be equal    ${except_topp_list}    ${syncSourceInfo_list}[0]
    should be equal    ${except_other_list}    ${syncSourceInfo_list}[1]
    [Teardown]     COAM Teardown gnb connections      connection=coam_admin

Check Alarm List Not Change
    [Arguments]  ${input_alarm_list}
    ${fault_id_list}    Get Active Alarm number    keywords=additionalFaultID
    ${return_value}    Judge_List_Is_Change    input_list1=${input_alarm_list}  input_list2=${fault_id_list}
    should be equal as strings    ${return_value}    ${True}

Modify Domain Number and Check WebUI and Btslog
    [Arguments]  ${except_topp_list}    ${except_other_list}    ${except_value}    ${ns_value_scope}   ${input_list}=None
    ...    ${time_control}=${True}    ${fault_id}=${True}
    run keyword if    ${time_control}==${False}    Modify TOP Domain Number
    run keyword if    ${time_control}    Modify Common parameter via Coam   input_list=${input_list}
    run keyword if    ${time_control}    sleep    3min
    Check Information On WebUI And Check Btslog    except_topp_list=${except_topp_list}    except_other_list=${except_other_list}
    ...    except_value=${except_value}   ns_value_scope=${ns_value_scope}    fault_id=${fault_id}

Check TOP SynInfo Alarm Number
    [Arguments]  ${except_topp_list}    ${except_other_list}    ${total_flag}=${True}
    COAM Check TOP Synchronization source info    bts_addr=${gNB_ip}    except_topp_list=${except_topp_list}
    ...   except_other_list=${except_other_list}    total_flag=${True}
    ${fault_id_list}    Get Active Alarm number    keywords=additionalFaultID
    [Return]  ${fault_id_list}

Modify Parameters and check TOP SyncInfo and Alarm Number
    [Arguments]  ${modify_list}    ${keywords_list}    ${index}    ${except_topp_list}    ${except_other_list}    ${input_alarm_list}
    ...    ${total_flag}=${True}
    Modify Structure parameter via Coam   class_name=CLOCK_A   modify_list=${modify_list}
    ...    keywords_list=${keywords_list}    index=${index}
    COAM Check TOP Synchronization source info    bts_addr=${gNB_ip}    except_topp_list=${except_topp_list}
    ...   except_other_list=${except_other_list}    total_flag=${total_flag}
    Check Alarm List Not Change    input_alarm_list=${input_alarm_list}

Capture Wireshark Log And Download
    [Arguments]    ${filename}    ${time}    ${listen_port}
    Connect to control pc via cygwin
    Start to Capture DU_TOP Log on Control PC    filename=${filename}   connection=cygwin   listen_port=${listen_port}   time=${time}
    Stop and Download Log    filename=${filename}    connection=cygwin   LOG_PATH=${LOG_PATH}

Check Alarm Number Is Right
    [Arguments]    ${alarm_number}    ${except_value}
    ${FaultID_list}    Get Active Alarm number    keywords=additionalFaultID
    ${return_value}    check_active_alarms_faultId    faultId_list=${FaultID_list}    faultId=${alarm_number}
    should be equal as strings    ${return_value}    ${except_value}

Enable Test Clock
    [Arguments]   ${time}
    Du login page via webUI
    selenium_coam.enable_test_clock_for_rap_and_return_outcome
    sleep   ${time}
    [Teardown]  Run keyword and ignore error    selenium_coam.logout

Check BTS Counters Value Scope
    [Arguments]    ${flag}    ${except_number_list}    ${connection}
    ${counter_list}    Get BTS Counters List via Api    connection=${connection}
    log to console    ${counter_list}
    ${return_value}    check_value_scope  flag=${flag}  number_list=${counter_list}  except_number_list=${except_number_list}
    should be equal as strings    ${return_value}    True

Check BTS TOP Synchronization Detail info On WebUi
    [Arguments]    ${expect_detail_list}    ${except_topp_list}     ${connection}=GNB_OAM
    COAM Check TOP Synchronization info    bts_addr=${gNB_ip}     except_topp_list=${except_topp_list}
    Connect to gnb coam via ssl    bts_host=${gNB_ip}
    ${get_managed_objects}     coam.get_managed_objects     class_name=TOPP_R    connection=${connection}
    ${dist_name}    Get_Dist_Name    input_list=${get_managed_objects}
    ${topmasterlistinfo}   coam.get_parameters    dist_name=${dist_name}   pattern=topMasterList
    log to console  ${topmasterlistinfo}
    ${Webui_detail_list}    Create List
    Append To List    ${Webui_detail_list}   ${topmasterlistinfo['topMasterList'][0]['receivedPriority_2']}
    Append To List    ${Webui_detail_list}    ${topmasterlistinfo['topMasterList'][0]['topGMasterClockClass']}
    Append To List    ${Webui_detail_list}    ${topmasterlistinfo['topMasterList'][0]['topGMasterClockAccuracy']}
    Append To List    ${Webui_detail_list}    ${topmasterlistinfo['topMasterList'][0]['topGMasterClockIdentity']}
    ${len}    get length    ${Webui_detail_list}
    FOR    ${i}    IN RANGE    ${len}
         should be equal as strings    ${expect_detail_list}[${i}]    ${Webui_detail_list}[${i}]
    END
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

5GC000314_case_setup
    Log To Console    case set up
    Setup Commission SCF
    Change BTS Sync Mode To PhaseSync    DU_IP=${gNB_ip}    BTS_ID=${gnb_id}
    Change BTS Sync Mode To PhaseSync    DU_IP=${SLAVE_DU_OAM_IP}    BTS_ID=${SLAVE_BTS_ID}
    Change Sync Input Type And Delete Structure2    DU_IP=${gNB_ip}    BTS_ID=${gnb_id}
    ...    synctype=1pps/ToD from external GNSS receiver
    Check Sync Status    DU_IP=${gNB_ip}    expect_syncInputType=1pps/ToD from external GNSS receiver    expect_isActive=${True}
    ...    expect_availability=Available    expect_usability=Usable    expect_tuningMode=Normal tuning
    Change Sync Input Type And Delete Structure2    DU_IP=${SLAVE_DU_OAM_IP}    BTS_ID=${SLAVE_BTS_ID}
    ...    synctype=1pps/ToD from Sync Hub Master
    Check BTS Should Be Normal

5GC000352_case_setup
    Setup Commission SCF
    Check BTS Should Be Normal
    Change Sync Input Type And Delete Structure2    BTS_ID=${gnb_id}    synctype=1pps/ToD from external GNSS receiver
    Check BTS Should Be Normal

Change BTS Sync Mode To PhaseSync
    [Arguments]    ${DU_IP}    ${BTS_ID}=${gnb_id}     ${connection}=GNB_OAM
    Log To Console    Change BTS Sync Mode To PhaseSync
    Connect to gnb coam via ssl    bts_host=${DU_IP}
    ${dict}    create dictionary    parameterName=btsSyncMode    operation=update    value=PhaseSync
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1     connection=${connection}
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    Wait Until Keyword Succeeds   16min   2min   Check cell on air    connection=${connection}
    [Teardown]    Run Keyword And Ignore error    COAM Teardown gnb connections

Change Sync Input Type And Delete Structure2
    [Arguments]    ${synctype}    ${BTS_ID}=${gnb_id}    ${DU_IP}=${gNB_ip}    ${Num}=${1}     ${connection}=GNB_OAM
    Log To Console    Change Sync Input Type And Delete Structure2
    Connect to gnb coam via ssl    bts_host=${DU_IP}
    ${object_list}    coam.get_managed_objects    class_name=CLOCK_A     connection=${connection}
    ${object}     set variable    ${None}
    FOR    ${item}    IN    @{object_list}
        ${parameter_list}    get from dictionary     ${item}    parameters
        ${sync_list}    get from dictionary    ${parameter_list}    syncInputList
        ${object}     set variable if    ${sync_list}!=[]    ${item}
        Exit For loop if    ${sync_list}!=[]
    END
    ${parameter}    get from dictionary     ${object}    parameters
    ${syncInputList}     get from dictionary    ${parameter}    syncInputList
    remove from list    ${syncInputList}    ${Num}
    set to dictionary    ${syncInputList}[0]     syncInputType=${synctype}
    set to dictionary    ${syncInputList}[0]     syncInputPrio=${1}
    ${dict}    create dictionary    parameterName=syncInputList    operation=update    value=${syncInputList}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1     connection=${connection}
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    sleep    120s
    [Teardown]    Run Keyword And Ignore error    COAM Teardown gnb connections

Change Sync Input Type And Add Structure2
    [Arguments]    ${DU_IP}    ${BTS_ID}    ${synctype1}    ${synctype2}    ${connection}=GNB_OAM
    Log To Console    Change Sync Input Type And Add Structure2
    Connect to gnb coam via ssl    bts_host=${DU_IP}
    ${object_list}    coam.get_managed_objects    class_name=CLOCK_A    connection=${connection}
    ${object}     set variable    ${None}
    FOR    ${item}    IN    @{object_list}
        ${parameter_list}    get from dictionary     ${item}    parameters
        ${sync_list}    get from dictionary    ${parameter_list}    syncInputList
        ${object}     set variable if    ${sync_list}!=[]    ${item}
        Exit For loop if    ${sync_list}!=[]
    END
    ${parameter}    get from dictionary     ${object}    parameters
    ${syncInputList}     get from dictionary    ${parameter}    syncInputList
    set to dictionary    ${syncInputList}[0]     syncInputType=${synctype1}
    set to dictionary    ${syncInputList}[0]     syncInputPrio=${1}
    ${structure2}    create dictionary     syncInputPrio=${2}    syncInputType=${synctype2}
    append to list    ${syncInputList}    ${structure2}
    ${dict}    create dictionary    parameterName=syncInputList    operation=update    value=${syncInputList}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1    connection=${connection}
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    sleep    120s
    [Teardown]    Run Keyword And Ignore error    coam.Teardown  connection=${connection}

Change Sync Input Type
    [Arguments]    ${DU_IP}    ${BTS_ID}    ${synctype}    ${connection}=GNB_OAM
    Log To Console    Change Sync Input Type
    Connect to gnb coam via ssl    bts_host=${DU_IP}
    ${object_list}    coam.get_managed_objects    class_name=CLOCK_A     connection=${connection}
    ${object}     set variable    ${None}
    FOR    ${item}    IN    @{object_list}
        ${parameter_list}    get from dictionary     ${item}    parameters
        ${sync_list}    get from dictionary    ${parameter_list}    syncInputList
        ${object}     set variable if    ${sync_list}!=[]    ${item}
        Exit For loop if    ${sync_list}!=[]
    END
    ${parameter}    get from dictionary     ${object}    parameters
    ${syncInputList}     get from dictionary    ${parameter}    syncInputList
    set to dictionary    ${syncInputList}[0]     syncInputType=${synctype}
    ${dict}    create dictionary    parameterName=syncInputList    operation=update    value=${syncInputList}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1    connection=${connection}
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    sleep    120s
    [Teardown]    Run Keyword And Ignore error    coam.Teardown  connection=${connection}

Check Sync Status
    [Arguments]    ${expect_syncInputType}    ${expect_isActive}    ${expect_availability}
    ...    ${expect_usability}    ${expect_tuningMode}    ${DU_IP}=${gNB_ip}     ${connection}=GNB_OAM
    sleep    120s
    Log To Console    Check Sync Status
    Connect to gnb coam via ssl    bts_host=${DU_IP}
    ${bts_sync_status}    coam.get_bts_sync_source_status    connection=${connection}
    Log To Console    Check syncMode
    ${bts_syncMode}    Get From Dictionary    ${bts_sync_status}    syncMode
    should be equal    ${bts_syncMode}    PhaseSync
    Check SyncSourceInfo Status    bts_sync_status=${bts_sync_status}    SN=${0}    expect_syncInputPrio=${1}
    ...    expect_syncInputType=${expect_syncInputType}    expect_isActive=${expect_isActive}
    ...    expect_availability=${expect_availability}    expect_usability=${expect_usability}
    Log To Console    Check tuningMode
    ${tuningMode}    Get From Dictionary    ${bts_sync_status}    tuningMode
    should be equal    ${tuningMode}    ${expect_tuningMode}
    [Teardown]    Run Keyword And Ignore error    coam.Teardown  connection=${connection}

Check SyncSourceInfo Status
    [Arguments]    ${bts_sync_status}    ${SN}    ${expect_syncInputPrio}    ${expect_syncInputType}
    ...    ${expect_isActive}    ${expect_availability}    ${expect_usability}
    Log To Console    Check syncSourceInfo
    ${syncSourceInfo}    Get From Dictionary    ${bts_sync_status}    syncSourceInfo
    ${isActive}    Get From Dictionary    ${syncSourceInfo}[0]   isActive
    should be equal    ${isActive}    ${expect_isActive}
    ${status}    Get From Dictionary    ${syncSourceInfo}[0]    status
    ${availability}    Get From Dictionary    ${status}    availability
    should be equal    ${availability}    ${expect_availability}
    ${usability}    Get From Dictionary    ${status}    usability
    should be equal    ${usability}    ${expect_usability}
    ${syncInputPrio}    Get From Dictionary    ${syncSourceInfo}[0]    syncInputPrio
    should be equal    ${syncInputPrio}    ${expect_syncInputPrio}
    ${syncInputType}    Get From Dictionary    ${syncSourceInfo}[0]    syncInputType
    should be equal    ${syncInputType}    ${expect_syncInputType}

Check BTS Should Be Normal
    [Arguments]   ${BTS_IP}=${gNB_ip}    ${connection}=GNB_OAM
    Log To Console  Check BTS Should Be Normal
    Connect to gnb coam via ssl    bts_host=${BTS_IP}
    Wait Until Keyword Succeeds   16min   2min   Check cell on air    connection=${connection}
    [Teardown]   Run Keyword And Ignore error    coam.Teardown  connection=${connection}

Change Master Clock Output
    [Arguments]    ${Actual_value}    ${connection}=GNB_OAM
    Log To Console    Change Master Clock Output
    Connect to gnb coam via ssl    bts_host=${gNB_ip}
    ${dict}    create dictionary    parameterName=outputConfiguration1Pps    operation=update    value=${Actual_value}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${gnb_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1    connection=${connection}
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    Wait Until Keyword Succeeds   16min   2min   Check cell on air    connection=${connection}
    [Teardown]    Run Keyword And Ignore error    coam.Teardown  connection=${connection}

Check Alarm Contain Target FaultID
    [Arguments]    ${DU_IP}    ${expect_fault}    ${contain_flag}=${True}
    ${fault_id_list}    Get Active Alarm number    keywords=additionalFaultID    BTS_IP=${DU_IP}
    run keyword if    ${contain_flag}    list should contain value    ${fault_id_list}    ${expect_fault}
    run keyword if    ${contain_flag}==${False}    list should not contain value    ${fault_id_list}    ${expect_fault}
    [Return]  ${fault_id_list}

Change Clock Output and Check Sync Status
    [Arguments]  ${DU_IP}    ${Actual_value}    ${expect_isActive}    ${expect_availability}    ${expect_usability}    ${expect_tuningMode}
    ...    ${expect_fault}    ${contain_flag}    ${expect_syncInputType}=1pps/ToD from Sync Hub Master
    Change Master Clock Output    Actual_value=${Actual_value}
    Check Sync Status    DU_IP=${DU_IP}    expect_syncInputType=${expect_syncInputType}    expect_isActive=${expect_isActive}
    ...     expect_availability=${expect_availability}    expect_usability=${expect_usability}    expect_tuningMode=${expect_tuningMode}
    wait until keyword succeeds    150s    30s    Check Alarm Contain Target FaultID    DU_IP=${DU_IP}    expect_fault=${expect_fault}
    ...    contain_flag=${contain_flag}

Change Sync Type and Check Sync Status
    [Arguments]    ${DU_IP}    ${expect_isActive}    ${expect_availability}    ${expect_usability}    ${expect_tuningMode}
    ...    ${expect_fault}    ${contain_flag}    ${expect_syncInputType}=1pps/ToD from Sync Hub Master
    Change Sync Input Type    DU_IP=${gNB_ip}    BTS_ID=${gnb_id}    synctype=TOPP
    Check Sync Status    DU_IP=${DU_IP}    expect_syncInputType=${expect_syncInputType}    expect_isActive=${expect_isActive}
    ...     expect_availability=${expect_availability}    expect_usability=${expect_usability}    expect_tuningMode=${expect_tuningMode}
    wait until keyword succeeds    150s    30s    Check Alarm Contain Target FaultID    DU_IP=${DU_IP}    expect_fault=${expect_fault}
    ...    contain_flag=${contain_flag}

Start BTSLog and Check Phase Error
    [Arguments]  ${time}
    BTSLOG Start btslog on local machine
    sleep    ${time}
    __Stop and collect btslog on local machine
    Check Phase Error

Check Phase Error
    [Arguments]    ${bts_logs_dir}=/tmp/btslog2
    Log To Console    Check Phase Error
    csn.Connect to    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}    alias=VM
    sleep    2s
    csn.send_command    cat ${bts_logs_dir}/SYSLOG_*.LOG | grep 'phase error'| grep 'time_object:' | rev |cut -d ' ' -f 1| rev | tail -n 1
    ...    connection=VM
    sleep    2s
    ${output}    csn.read output    connection=VM
    ${number}    evaluate    abs(float(${output}))
    should be true    ${number} < ${1500.0}
    [Teardown]    csn.disconnect    connection=VM

5GC000314_case_teardown
    Log To Console    case teardown
    Change Sync Input Type And Add Structure2    DU_IP=${gnb_ip}    BTS_ID=${gnb_id}
    ...    synctype1=1pps/ToD from external GNSS receiver    synctype2=TOPP
    Change Sync Input Type And Add Structure2   DU_IP=${SLAVE_DU_OAM_IP}    BTS_ID=${SLAVE_BTS_ID}
    ...    synctype1=TOPP    synctype2=1pps/ToD from Sync Hub Master
    CI_interface.Common Case Teardown

Check GNSS Product Name And status
    [Arguments]  ${expect_product_name}=None    ${GNSS_mode}=None    ${BeiDou}=None    ${GLONASS}=None    ${GPS}=None
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    Log To Console    Get GNSS Info
    ${Get_information_GNSS}    selenium_coam.get_gnss_info
    ${product_name}    get from dictionary    ${Get_information_GNSS}    Product name
    ${product_code}    get from dictionary    ${Get_information_GNSS}    Product code
    ${serial_num}    get from dictionary    ${Get_information_GNSS}     Serial number
    ${status}    get from dictionary    ${Get_information_GNSS}    Status
    ${Location_mode}    get from dictionary    ${Get_information_GNSS}     Location mode
    ${Position}    get from dictionary    ${Get_information_GNSS}    Position
    ${Allow_BeiDou}    get from dictionary    ${Get_information_GNSS}    Allow usage of BeiDou
    ${Allow_GLONASS}    get from dictionary    ${Get_information_GNSS}    Allow usage of GLONASS
    ${Allow_GPS}    get from dictionary    ${Get_information_GNSS}    Allow usage of GPS
#    ${Control_mode}    get from dictionary    ${Get_information_GNSS}     Constellation mode
    ${Availability_status}    get from dictionary    ${status}    Availability status
    ${Latitude}    get from dictionary    ${Position}    Latitude
    ${Longitude}    get from dictionary    ${Position}    Longitude
    ${Altitude}    get from dictionary    ${Position}    Altitude
    Log To Console    Check status
    should not be equal    ${product_name}    -
    should not be equal    ${product_code}    -
    should not be equal    ${serial_num}    -
    should not be equal    ${Latitude}    -
    should not be equal    ${Longitude}    -
    should not be equal    ${Altitude}    -
    Should be equal as strings    ${Location_mode}    automatic
    run keyword if    "${expect_product_name}"!="${None}"     Should be equal as strings    ${product_name}    ${expect_product_name}
    run keyword if    "${GNSS_mode}"!="${None}"    Should be equal as strings    ${Allow_BeiDou}    ${BeiDou}
    run keyword if    "${GNSS_mode}"!="${None}"    Should be equal as strings    ${Allow_GLONASS}    ${GLONASS}
    run keyword if    "${GNSS_mode}"!="${None}"    Should be equal as strings    ${Allow_GPS}    ${GPS}
    run keyword if    "${GNSS_mode}"!="${None}"    Should be equal as strings    ${Availability_status}    Online
    [Teardown]    Run keyword and ignore error     selenium_coam.logout

Change GNSS Operation Mode And Check Sync Stutas
    [Arguments]  ${gnss_mode}
    FOR    ${item}    IN    @{gnss_mode}
        Modify Common parameter via Coam    input_list=${item}    connection=GNB_connection    bts_ip=${gNB_ip}
        wait until keyword succeeds     20min    1min    Check Sync Status2    expect_syncInputType=1pps/ToD from external GNSS receiver
    END

5GC000352_case_teardown
    Modify Common parameter via Coam    input_list=${GPS_GLONASS1}    connection=GNB_connection    bts_ip=${gNB_ip}
    Change Sync Input Type And Add Structure2   DU_IP=${gnb_ip}   BTS_ID=${gnb_id}   synctype1=TOPP   synctype2=1pps/ToD from external GNSS receiver
    CI_interface.Common Case Teardown

Prepare GPS and TOPP status
    [Arguments]  ${parameter2}=${False}    ${input_list}=${parameter0_315}    ${input_list2}=${parameter_0}
    log to console    Delete Master topp
    Run Keyword And Ignore Error    Change Sync Input Type And Delete Structure2    synctype=1pps/ToD from external GNSS receiver    Num=${0}
    Modify Common parameter via Coam    bts_ip=${gnb_ip}    input_list=${input_list}
#    run keyword if    ${parameter2}    Modify Common parameter via Coam    bts_ip=${SHM_IP}    input_list=${input_list2}
    log to console    Delete SHM  topp
    Change Sync Input Type And Delete Structure2    synctype=1pps/ToD from Sync Hub Master    BTS_ID=${SLAVE_BTS_ID}    DU_IP=${SHM_IP}   Num=${0}

check master btslog
    [Arguments]    ${BTS_IP}    ${message1}    ${message2}    ${connection}=GNB_OAM
    csn.Connect to     hostname=${TEST_PC_IP}   username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}  alias=${connection}
    csn.Send Command    command=cat ${source} |grep ${BTS_IP} |grep TSIP_0x1C_0x83 |grep Hardware |grep version
    ...    connection=${connection}
    ${Hardware}  csn.Read Output    connection=${connection}
    should not be empty    ${Hardware}
    csn.Send Command    command=cat ${source} |grep ${BTS_IP} |grep TSIP_0x8F_0xAB |grep Primary |grep timing
    ...    connection=${connection}
    ${Primary}  csn.Read Output    connection=${connection}
    should not be empty    ${Primary}

    csn.Send Command    command=cat ${source} |grep ${BTS_IP} |grep TSIP_0x8F-AC |grep MinorAlarms
    ...    connection=${connection}
    ${MinorAlarms}  csn.Read Output    connection=${connection}
    should not be empty    ${MinorAlarms}

    csn.Send Command    command=${message1}    connection=${connection}
    ${Receiver}  csn.Read Output    connection=${connection}
    should not be empty    ${Receiver}

    csn.Send Command    command=${message2}    connection=${connection}
    ${Satellite}  csn.Read Output    connection=${connection}
    should not be empty    ${Satellite}
    log to console    check btslog successful
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}

Check accuracy lpp
    [Arguments]    ${PC_IP}   ${limit1}    ${BTS_IP}     ${connection}=GNB_OAM
    csn.Connect to     hostname=${PC_IP}   username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}  alias=${connection}
    csn.Send Command    command=cat ${source} |grep ${BTS_IP} |grep phase_error:|cut -d '[' -f 5|cut -d ':' -f 2|cut -d 'n' -f 1|head -1|tr '\n' ' '
    ...    connection=${connection}
    ${phase}  csn.Read Output    connection=${connection}
    should not be empty    ${phase}
    ${phase}    Evaluate    abs(int(${phase}))
    log to console    ${phase}
    should be true    ${phase} < ${limit1}
    log to console    check lpp successful
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}

Check Sync Status2
    [Arguments]    ${expect_syncInputType}    ${BTS_IP}=${gNB_ip}     ${connection}=GNB_OAM
    Log To Console    Check Sync Status
    Connect to gnb coam via ssl    bts_host=${BTS_IP}
    Wait Until Keyword Succeeds   20min   30s   Check cell on air    connection=${connection}
    ${bts_sync_status}    coam.get_bts_sync_source_status    connection=${connection}
    Log To Console    Check syncMode
    ${bts_syncMode}    Get From Dictionary    ${bts_sync_status}    syncMode
    should be equal    ${bts_syncMode}    PhaseSync
    Log To Console    Check syncSourceInfo
    ${syncSourceInfo}    Get From Dictionary    ${bts_sync_status}    syncSourceInfo
    ${isActive}    Get From Dictionary    ${syncSourceInfo}[0]    isActive
    should be equal    ${isActive}    ${True}
    ${status}    Get From Dictionary    ${syncSourceInfo}[0]    status
    ${availability}    Get From Dictionary    ${status}    availability
    should be equal    ${availability}    Available
    ${usability}    Get From Dictionary    ${status}    usability
    should be equal    ${usability}    Usable
    ${syncInputType}    Get From Dictionary    ${syncSourceInfo}[0]    syncInputType
    should be equal    ${syncInputType}    ${expect_syncInputType}
    Log To Console    Check tuningMode
    ${tuningMode}    Get From Dictionary    ${bts_sync_status}    tuningMode
    should be equal    ${tuningMode}    Normal tuning
    [Teardown]    Run keyword and ignore error    coam.Teardown  connection=${connection}

Check BTSLog For 5GC000315
    [Arguments]    ${BTS_IP}    ${message1}    ${message2}    ${limit1}    ${expect_syncInputType}
    check master btslog    BTS_IP=${BTS_IP}    message1=${message1}    message2=${message2}
    Check accuracy lpp    PC_IP=${TEST_PC_IP}    limit1=${limit1}    BTS_IP=${BTS_IP}
    Check Sync Status2    expect_syncInputType=${expect_syncInputType}    BTS_IP=${BTS_IP}
    Check BTS Should Be Normal    BTS_IP=${BTS_IP}

5GC000315 case Teardown
    Run Keyword And Ignore Error    coam.teardown    connection=GNB_OAM
    log to console    ADD Master topp
    Change Sync Input Type And Add Structure2   DU_IP=${gnb_ip}   BTS_ID=${gnb_id}   synctype1=1pps/ToD from external GNSS receiver   synctype2=TOPP
    log to console    ADD Master topp
    Change Sync Input Type And Add Structure2   DU_IP=${SHM_IP}   BTS_ID=${SLAVE_BTS_ID}   synctype1=1pps/ToD from Sync Hub Master    synctype2=TOPP
    Modify Value On DU    bts_ip=${SHM_IP}    structure_modify_list=${parameter4_315}    class_name=TRBLCADM_A    keywords_list=${keywords_list1}
    Reset site    BTS_IP=${SHM_IP}
    sleep    180s
    Check BTS Should Be Normal    BTS_IP=${SHM_IP}

Reset site
    [Arguments]    ${BTS_IP}    ${connection}=GNB_OAM
    log to console    reset site IP；${BTS_IP}
    Connect to gnb coam via ssl    bts_host=${BTS_IP}
    coam.reset_site    connection=${connection}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

GNSS Check and BTSlog
    [Arguments]    ${parameter1}    ${parameter2}
    Modify Value On DU    bts_ip=${SHM_IP}    structure_modify_list=${parameter1}    class_name=TRBLCADM_A    keywords_list=${keywords_list1}
    Modify Value On DU    bts_ip=${gNB_ip}    structure_modify_list=${parameter2}    class_name=TRBLCADM_A    keywords_list=${keywords_list1}
    log to console    start get btslog
    Start BTSlog and Dowmload Btslog    time=2min
    Check BTSLog For 5GC000315    BTS_IP=${gNB_ip}    limit1=${500}    expect_syncInputType=1pps/ToD from external GNSS receiver
    ...    message1=cat ${source} |grep ${gnb_ip} |grep TSIP_0x6C |grep Receiver |grep position
    ...    message2=cat ${source} |grep ${gnb_ip} |grep TSIP_0x47 |grep Satellite |grep Signal
    Check BTSLog For 5GC000315    BTS_IP=${SHM_IP}    limit1=${1500}    expect_syncInputType=1pps/ToD from Sync Hub Master
    ...    message1=cat ${source} |grep ${SHM_IP} |grep TSIP_0x8F_0xF2 |grep SyncHub |grep Information
    ...    message2=cat ${source} |grep ${SHM_IP} |grep TSIP_0x8F_0xF3 |grep SyncHub

check DU alarm
    [Arguments]    ${BTS_IP}    ${fault_id}    ${fault_name}   ${expect_status}
    log to console    check alarm...
    ${fault_id_list}    ${fault_name_list}    check alarm active    BTS_IP=${BTS_IP}
    ${fault_id_status}    Run Keyword And Return Status   list should contain value     ${fault_id_list}    ${fault_id}
    ${fault_name_status}    Run Keyword And Return Status    list should contain value     ${fault_name_list}    ${fault_name}
    Should be True    ${fault_id_status} == ${expect_status}
    Should be True    ${fault_name_status} == ${expect_status}

check alarm active
    [Arguments]    ${BTS_IP}
    log to console    start check alarm
    Connect to gnb coam via ssl    bts_host=${BTS_IP}     connection=GNB_CON
    ${alarms}    coam.get_active_alarms    connection=GNB_CON
    sleep    1s
    log     ${alarms}
    ${fault_id_list}    create list
    ${fault_name_list}    create list
    FOR    ${item}    IN    @{alarms}
         ${fault_id}    get from dictionary    ${item}    alarmId
         ${fault_name}    get from dictionary    ${item}    faultName
         append to list    ${fault_id_list}    ${fault_id}
         append to list    ${fault_name_list}    ${fault_name}
    END
    [Return]    ${fault_id_list}    ${fault_name_list}
    [Teardown]    run keyword and ignore error    coam.teardown     connection=GNB_CON

Recover GPS alarm
    [Arguments]    ${parameter}    ${fault_name}    ${BTS_IP}=${gnb_ip}
    Modify Common parameter via Coam    bts_ip=${BTS_IP}    input_list=${parameter}
    sleep    2min
    Wait Until Keyword Succeeds    10min    10sec    check DU alarm
    ...    BTS_IP=${BTS_IP}    fault_id=${7108}    fault_name=${fault_name}    expect_status=${False}
    log to console    Recover alarm successful

End topp check
    Add GPS and TOPP    synctype1=TOPP    synctype2=1pps/ToD from external GNSS receiver    bts_IP=${DU_OAM_IP_TL}    BTS_ID=${BTS_ID_M}
    [Teardown]    run keyword and ignore error    coam.teardown

Trigger alarm and recovery
    [Arguments]    ${parameter1}    ${parameter2}    ${fault_name}    ${BTS_IP}=${gnb_ip}
    Modify Common parameter via Coam    bts_ip=${BTS_IP}    input_list=${parameter1}
    Wait Until Keyword Succeeds    10min    10sec    check DU alarm
    ...    BTS_IP=${BTS_IP}    fault_id=${7108}    fault_name=${fault_name}    expect_status=${True}
    log to console    Check alarm successful
    log to console    sleep 10min
    sleep    10min
    check DU alarm    BTS_IP=${BTS_IP}    fault_id=${7108}    fault_name=${fault_name}    expect_status=${True}
    log to console    Check alarm successful
    [Teardown]    Recover GPS alarm    parameter=${parameter2}    fault_name=${fault_name}

Modify parameters and check GNSS status
    [Arguments]  ${input_list}    ${GNSS_mode}    ${BeiDou}    ${GLONASS}    ${GPS}    ${connection}=GNB_connection    ${bts_ip}=${gNB_ip}
    Modify Common parameter via Coam    input_list=${input_list}    connection=${connection}    bts_ip=${bts_ip}
    Reset site    BTS_IP=${bts_ip}
    wait until keyword succeeds    25min   1min   Check BTS Should Be Normal    BTS_IP=${bts_ip}
    wait until keyword succeeds    5min    10s   Check GNSS Product Name And status    GNSS_mode=${GNSS_mode}    BeiDou=${BeiDou}
    ...    GLONASS=${GLONASS}    GPS=${GPS}
    wait until keyword succeeds    5min    10s   Check BTS Should Be Normal    BTS_IP=${bts_ip}

################### UTE Cloud ######################
Commission_CU_DU
    [Documentation]
    ...                Description: do cu and du commission
    Cloud DU connect to gnb coam via ssl    bts_host=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    COAM Commission with scf file
    ...    scf_file_path=${CURDIR}/../../../../commissionings/HGZ/7_5_UTE5G401T701/SCF_10.1100_DU.xml
    ...    is_pdl_checking_needed=${False}    timeout=1200
    CU Full Commission
    ...    path_of_commission_file=${CURDIR}/../../../../commissionings/HGZ/7_5_UTE5G401T701/SCF_10.1100_CU.xml
    wait until keyword succeeds    25 min    10 sec    COAM Check GNB cell on air
    COAM Teardown gnb connections

Test Suite Setup
    Commission_CU_DU
