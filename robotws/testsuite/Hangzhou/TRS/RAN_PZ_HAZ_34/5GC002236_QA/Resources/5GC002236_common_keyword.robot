*** Settings ***
Documentation    author：Hongyu Jiang
...              contact: hongyu.jiang@nokia-sbell.com
...              squad group: mmw_SG_04


*** Variables ***
${CURDIR_path}            ${CURDIR}/../../../../../../commissionings/HGZ/7_5_UTE5G401T702
${gNB_ip}                 ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${gNB_username}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${LOG_PATH}               ${OUTPUT DIR}
${TEST_PC_IP}             ${tl.test_pc.default_ssh_connection_details.addr}
${TEST_PC_USERNAME}       ${tl.test_pc.default_ssh_connection_details.username}
${TEST_PC_PASSWORD}       ${tl.test_pc.default_ssh_connection_details.password}
${Test_Case_Name}         5GC000313_01
${luashark_path}          /opt/luashark/luashark.lua
${gnb_id}                 ${tl.gnbs[0].instance_id}
${list}                   51000

${DU_OAM_SSH_USERNAME_TL}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_OAM_SSH_PASSWORD_TL}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}

${filename_1}         topp02.pcap
${filename_2}         topp03.pcap
${epc_log_path}       /tmp
${ip_test_scope}      User-defined address
${dscp}               44
${Payload_size}       59

${MRBTS}    MRBTS-${tl.gnbs[0].instance_id}
${ID}       1
${interface}    fp0
${up_filename}    trigger_bfd_up.pcap
${dowm_filename}    trigger_bfd_down.pcap
${remote_path}    /tmp
${src_ip_value}     10.57.243.129
${bfd_ip_notok}    10.57.243.12
${bfd_state_true}    bfd.sta == 0x3
${bfd_state_down}    bfd.sta == 0x1
${IPRT_distname_1}    ${MRBTS}/TNLSVC-1/TNL-1/IPNO-1/IPRT-1
${BFD_distname_1}    ${MRBTS}/TNLSVC-1/TNL-1/IPAPP-1/BFD-1
${ip_flag}    -4
${dist_name}    MRBTS-${gnb_id}/TNLSVC-1/TNL-1/IPNO-1/RTPOL-1
${parameter}    routingPolicies
${operation}    update
${conn}         default
${1566_D_default_scf}    ${CURDIR}/../../../../../../commissionings/HGZ/7_5_UTE5G401T702/SCF_10.1100_DU.xml





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
    [Arguments]    ${PARAMS_TO_MODIFY}   ${time}=10min
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
    should be equal    ${except_topp_list}    ${syncSourceInfo_list}[0]

Connect to control pc via cygwin
    [Arguments]    ${ue_index}=${0}
    ...    ${hostname}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${username}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    ${password}=${tl.ues[${ue_index}].ssh_connection_details.password}    ${alias}=cygwin
    ssh.Connect to    hostname=${hostname}
    ...    username=${username}
    ...    password=${password}    alias=${alias}

Start to Capture DU_TOP Log on Control PC
    [Arguments]    ${filename}    ${connection}    ${listen_port}    ${time}
    ssh.send command    command=tshark -i ${listen_port} -w ${filename}  connection=${connection}
    sleep    ${time}

Stop and Download Log
    [Arguments]    ${filename}    ${connection}    ${LOG_PATH}
    ${PID}  ssh.Execute  command=ps -ef |grep shark|awk '{{print $2}}'|head -n 1
    ...    connection=${connection}
    ${PID}    strip_string    ${PID}
    ssh.Execute    command=kill ${PID}    connection=${connection}
    ssh.Execute    command=ps -ef | grep shark | awk '{print $2}' | xargs kill -9    connection=${connection}
    ssh.download_file    remote_path=/home/nokia5G/${filename}    local_path=${LOG_PATH}/${filename}
    ...    connection=${connection}
    sleep    2s
    ssh.send command    command=rm /home/nokia5G/${filename}    connection=${connection}
    [Teardown]  Run keyword and ignore error    ssh.Disconnect	connection=${connection}

Get PARAM Value from Wireshark Log
    [Arguments]    ${check_param}    ${element_idx}=${0}    ${default_value}=False    ${condition_expression}=${None}
    ${value}=    cap.Get Element Value    element_expression=${check_param}    element_idx=${element_idx}
    ...    default_value=${default_value}    condition_expression=${condition_expression}
    Sleep    10s
    [Return]    ${value}

Read Wireshark Log
    [Arguments]    ${filename}    ${filter}=${None}
    cap.Read Cap    cap_file=${LOG_PATH}/${filename}    display_filter=${filter}

COAM_WebEM.EnableSync
    [Arguments]     ${pattern}=completed
    COAM_WebEM.Login
    ${output}    selenium_coam.enable_test_clock_for_rap_and_return_outcome
    should contain   ${output}    ${pattern}
    COAM_WebEM.Logout

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
    [Arguments]     ${bts_logs_dir}=/tmp/btslog2
    Run  if [ ! -d ${bts_logs_dir} ]; then mkdir ${bts_logs_dir}; else rm ${bts_logs_dir}/*; fi

__Copy btslog to logs dir and clean BTSlog workspace
    [Arguments]     ${bts_logs_dir}=/tmp/btslog2
	Run  mkdir ${OUTPUT DIR}/${TEST_NAME}
	Run  mkdir ${OUTPUT DIR}/${Test_Case_Name}
    Run  mv ${bts_logs_dir}/syslog_files.tgz ${OUTPUT DIR}/${TEST_NAME}/bts_log.tgz
    Run  rm ${bts_logs_dir}/*

Convert pcap to text
    [Arguments]  ${source}   ${target}   ${filter}   ${connection}
    ssh.send_command
    ...  command=nice tshark -X lua_script:${luashark_path} -V -r ${source} -T text > ${target} -Y ${filter}
    ...  connection=${connection}
    ssh.await execution end  connection=${connection}  timeout=30min

Connect to TestPc
    [Arguments]  ${hostname}=${TEST_PC_IP}    ${username}=${TEST_PC_USERNAME}    ${password}=${TEST_PC_PASSWORD}
    ${connection}    ssh.Connect to     hostname=${hostname}    username=${username}    password=${password}  alias=TESTPC
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
    ${scf_name}    Covert_BTS_Version    version=${version}
    ${default_scf}    set variable    ${CURDIR_path}/${scf_name}
    log to console   ${default_scf}
    [Return]    ${default_scf}
    [Teardown]    Run keyword and ignore error    admin.teardown      connection=${connection}

#5GC002236_QA_5GC000316
Setup Commission SCF
     ${default_scf}    Get BTS Version And Perare SCF    CURDIR_path=${CURDIR_path}
     Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
     COAM Commission with scf file    scf_file_path=${default_scf}
     Wait Until Keyword Succeeds   16min   2min   Check cell on air

Modify parameters Set syncInputType And btsSyncMode
    [Arguments]  ${param_to_modify}    ${expected_error}
    [Documentation]    *****************
    ...    The purpose of this test is to verify the ability to clock sync
    ...    gNB-DU configuration set TOPF and PhaseSync.
    ...    ******************
    ...    *******************
    ${relation_errors}     Modify parameters online And Get Relation Error    PARAMS_TO_MODIFY=${param_to_modify}
    ${key_List}    get dictionary keys    ${relation_errors}
    ${expect_error_key_list}    get dictionary keys    ${expected_error}
    FOR    ${keys}    IN    @{key_List}
         ${status}    run keyword and return status    list should contain value    ${expect_error_key_list}    ${keys}
         run keyword and continue on failure    Run keyword if   ${status}  Check Error infor    relation_errors=${relation_errors}
         ...     expected_error=${expected_error}    keys=${keys}
    END

Du login page via webUI
    [Documentation]  Author: Wu Jerry
    ...              Description: If case failed, the snapshot from webUI will be stored in the ${download_dir} folder
    [Arguments]  ${download_dir}=/home/ute/robotws5g/testsuite/TRS/Hangzhou/5GC002236_316/backup/
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${gNB_ip}
    ...                    username=${gNB_username}
    ...                    password=${gNB_password}
    ...                    download_dir=${download_dir}
    selenium_coam.disable_message_box

Modify parameters online And Get Relation Error
    [Arguments]    ${PARAMS_TO_MODIFY}
    5GC002236_common_keyword.Du login page via webUI
    log    ${PARAMS_TO_MODIFY}
    FOR    ${item}    IN    @{PARAMS_TO_MODIFY}
         Log    ${item}
         ${dist_name}       get from dictionary     ${item}     dist_name
         ${filter_param}    get from dictionary     ${item}     filter_param
         ${new_value}       get from dictionary     ${item}     value
         selenium_coam.set_parameter_value    dist_name=${dist_name}    filter_param=${filter_param}    new_value=${new_value}
    END
    selenium_coam.validate_plan
    ${relation_errors}      selenium_coam.get_relation_errors
    [Return]     ${relation_errors}
    [Teardown]    selenium_coam.logout

Check Error infor
    [Arguments]    ${relation_errors}    ${expected_error}    ${keys}
    ${error}    get from dictionary    ${relation_errors}    ${keys}
    ${true_error}    get from dictionary    ${expected_error}    ${keys}
    Should Be Equal As Strings    ${error}     ${true_error}    msg=the error info is not correct

Check Relation Errors When Right Config
    [Arguments]    ${relation_errors}    ${excpect_list}
    ${relation_errors_key_list}   Get Dictionary Keys    ${relation_errors}
    ${except_value}    check_relation_error    input_list=${relation_errors_key_list}    excpect_list=${excpect_list}
    should be equal as strings    ${except_value}   True

Start btslog on ute and Check btslog
    [Arguments]    ${time}    ${ppb_value}   ${ns_value_scope}    ${btslog_name}
    Start Syslog    log_dir=${OUTPUT DIR}
    ...    log_name=${btslog_name}   host_ip=${TEST_PC_IP}    ssh_username=ute    ssh_password=ute    ports=${list}    alias=ute
    sleep    ${time}
    Stop syslog    alias=ute
    Check logfile if message is right    ppb_value=${ppb_value}   ns_value_scope=${ns_value_scope}    btslog_name=${btslog_name}

Check logfile if message is right
    [Arguments]    ${ppb_value}   ${ns_value_scope}    ${btslog_name}
    ssh.Connect to     hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}	alias=TESTPC
    ${message} =     Get_line_message     file_path=${OUTPUT DIR}/${btslog_name}
#    ${message} =    OperatingSystem.Grep File    ${OUTPUT DIR}/${btslog_name}    Estimator output
    ${ppb_result}   check_parameter_value_in_btslog_file    input_content=${message}   keyword=frequency_deviation    except_value=${ppb_value}
    ${ns_result}    check_parameter_value_in_btslog_file    input_content=${message}   keyword=phase_error    except_value=${ns_value_scope}
    should be equal as strings    ${ppb_result}    True
    should be equal as strings    ${ns_result}    True
    [Teardown]    ssh.Disconnect	connection=TESTPC

Modify TOP Domain Number
    [Arguments]    ${alias}=cOAM_toor4nsn
    ${connection}    Connect to cOAM as toor4nsn    ip_address=${gNB_ip}     alias=${alias}
    ssh.Send Command    command=iptables -I INPUT -s 10.57.249.62 -j DROP    connection=${connection}
    ssh.Send Command    command=iptables -D INPUT -s 10.57.249.62 -j DROP    connection=${connection}
    ssh.disconnect    connection=${alias}

Connect to cOAM as toor4nsn
    [Arguments]  ${ip_address}   ${alias}
    ${connection}=  ssh.Connect to  hostname=${ip_address}
    ...                             username=toor4nsn
    ...                             password=oZPS0POrRieRtu
    ...                             alias=${alias}
    [Return]  ${connection}

Check Information On WebUI And Check Btslog
    [Arguments]    ${except_topp_list}    ${except_other_list}   ${except_value}  ${ns_value_scope}     ${btslog_name}
    COAM Check TOP Synchronization source info    bts_addr=${gNB_ip}    except_topp_list=${except_topp_list}
    ...     except_other_list=${except_other_list}
    ${FaultID_list}    Get Active Alarm number    keywords=additionalFaultID
    ${return_value}    check_active_alarms_faultId     faultId_list=${FaultID_list}    faultId=4298
    should be equal as strings    ${return_value}    ${except_value}
    Start btslog on ute and Check btslog    time=2min   ppb_value=20   ns_value_scope=${ns_value_scope}   btslog_name=${btslog_name}

COAM Check TOP Synchronization source info
    [Arguments]                     ${bts_addr}    ${except_topp_list}    ${except_other_list}
    admin.connect_to                 bts_host=${bts_addr}    name=coam_admin
    log to console                  bts_host:${bts_addr}
    ${bts_sync_status}=             admin.get_bts_sync_source_status          connection=coam_admin
    log to console                  bts_sync_source_dict=${bts_sync_status}
    ${bts_syncMode}=                Get From Dictionary                  ${bts_sync_status}         syncMode
    should be equal                 ${bts_syncMode}                      PhaseSync
    ${tuning_Mode}=                 Get From Dictionary                  ${bts_sync_status}         tuningMode
    should be equal                 ${tuning_Mode}                       Normal tuning
    ${syncSourceInfo}=              Get From Dictionary                  ${bts_sync_status}         syncSourceInfo
    ${syncSourceInfo_list}    check_syncSourceInfo_if_right    ${syncSourceInfo}
    log    ${syncSourceInfo_list}
    should be equal    ${except_topp_list}    ${syncSourceInfo_list}[0]
    should be equal    ${except_other_list}    ${syncSourceInfo_list}[1]
    [Teardown]        admin.teardown      connection=coam_admin

Get Active Alarm number
    [Arguments]    ${keywords}
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    ${alarm_list}    admin.get_active_alarms     connection=GNB_OAM
    ${fault_id_list}  get_active_alarms_faultId    alarms_list=${alarm_list}    keyword=${keywords}
    Teardown gNB cOAM SSL Connection
    [Return]  ${fault_id_list}

#5GC002236_QA_5GC000313
Convert pcap to text And Get txt Content
    [Arguments]      ${pacp_filename}    ${txt_filename}     ${except_sync_number}    ${except_announce_number}
    ...    ${except_dscp_number}
    ${connection}    5GC002236_common_keyword.Connect to TestPc
    Convert pcap to text    source=${LOG_PATH}/${pacp_filename}
    ...  target=${LOG_PATH}/${txt_filename}   filter=" "  connection=${connection}
    ${sync_number}    get_txt_content_by_line_index    file_path=${LOG_PATH}/${txt_filename}    message=control: Sync Message (0)
    ${announce_number}    get_txt_content_by_line_index    file_path=${LOG_PATH}/${txt_filename}     message=messageId: Announce Message
    ${dscp_number}    get_txt_content_by_line_index    file_path=${LOG_PATH}/${txt_filename}     message=DSCP
    Should Be Equal As Numbers    ${sync_number}    ${except_sync_number}
    Should Be Equal As Numbers    ${announce_number}     ${except_announce_number}
    Should Be Equal As Numbers    ${dscp_number}   ${except_dscp_number}
    [Teardown]  Run keyword and ignore error    ssh.Disconnect	connection=${connection}

Capture Wireshark Log And Download
    [Arguments]    ${filename}    ${time}    ${listen_port}
    Connect to control pc via cygwin
    Start to Capture DU_TOP Log on Control PC    filename=${filename}   connection=cygwin   listen_port=${listen_port}   time=${time}
    Stop and Download Log    filename=${filename}    connection=cygwin   LOG_PATH=${LOG_PATH}

Enable Test Clock
    [Arguments]   ${time}
    5GC002236_common_keyword.Du login page via webUI
    selenium_coam.enable_test_clock_for_rap_and_return_outcome
    sleep   ${time}
    [Teardown]  Run keyword and ignore error    selenium_coam.logout

Modify parameters And Check TOP Source Info
    [Arguments]    ${PARAMS_TO_MODIFY}    ${time}    ${except_topp_list}
    Modify parameters online and Active Plan     PARAMS_TO_MODIFY=${PARAMS_TO_MODIFY}    time=${time}
    COAM Check TOP Synchronization info   bts_addr=${gNB_ip}    except_topp_list=${except_topp_list}
    [Teardown]  Run keyword and ignore error    selenium_coam.logout

Check Signalling Message In txt
    [Arguments]    ${pacp_filename}  ${txt_filename}
    ${connection}    5GC002236_common_keyword.Connect to TestPc
    Convert pcap to text    source=${LOG_PATH}/${pacp_filename}
    ...  target=${LOG_PATH}/${txt_filename}   filter="ptp.v2.messageid == 0xc"  connection=${connection}
    ${TextFileContent}    Get File    ${LOG_PATH}/${txt_filename}
    should not be empty   ${TextFileContent}
    [Teardown]  Run keyword and ignore error    ssh.Disconnect	connection=${connection}

Check Alarm Number Is Right
    [Arguments]    ${alarm_number}    ${except_value}
    ${FaultID_list}    Get Active Alarm number    keywords=additionalFaultID
    ${return_value}    check_active_alarms_faultId    faultId_list=${FaultID_list}    faultId=${alarm_number}
    should be equal as strings    ${return_value}    ${except_value}

#5GC002236_IA_5GC000307_01
start IP connectivity test
    Log to console  start IP connectivity test
    selenium_coam.enable_virtual_display
    selenium_coam.login  url=https://${gNB_ip}    username=${gNB_username}   password=${gNB_password}
    ${serverHost}  ${gateway}   Get Web_config value
    start pmut extract log    ${filename_1}
    selenium_coam.start_ip_connectivity_test    scope=${ip_test_scope}  source_address=${gNB_ip}  dscp=${dscp}  address=${serverHost}
    ...      payload_size=${Payload_size}
    sleep    5s
    end pmtu extract log
    sleep    3s
    start pmut extract log    ${filename_2}
    selenium_coam.start_ip_connectivity_test    scope=${ip_test_scope}  source_address=${gNB_ip}  dscp=${dscp}  address=$${gateway}
    ...      payload_size=${Payload_size}
    sleep    5s
    end pmtu extract log

Get Web_config value
    Log to console  Web_config value
#    selenium_coam.login  url=${DU_OAM_IP_URL}    username=${DU_OAM_WEBUI_USER}   password=${DU_OAM_WEBUI_PASSWORD}
    Log to console  login DU WEBUI successful
    ${mrbtsId}    selenium_coam.get_bts_id
    ${out1}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsId}/MNL-1/CERTH-1/CMP-1   abbr=serverHost
    ...    filter_param=CMP server IP address
    ${out2}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/IPNO-1/IPRT-1   abbr=gateway
    ...    filter_param=IP address of the next hop of the route
#    selenium_coam.logout
    [Return]  ${out1}      ${out2}

start pmut extract log
    [Arguments]    ${filename}
    ssh.connect_to   hostname=${gNB_ip}    username=${DU_OAM_SSH_USERNAME_TL}    password=${DU_OAM_SSH_PASSWORD_TL}
    log to console  start pmut extract log
    ${cmd}   Set Variable  tcpdump -n -i fp0 -w /tmp/${filename} -vv
    ssh.Send Command   command=${cmd}

end pmtu extract log
    ssh.Send Command  command=ps -ef |grep tcpdump|awk '{{print $2}}'|head -n 1
    ${PID}  ssh.Read Output
    ${PID}  strip_string    ${PID}
    log to console  Extract log successful
    log to console  PID output: ${PID}
    ssh.Send Command  command=kill ${PID}

check wireshark log
    [Arguments]    ${filename}
    Wireshark DownloadLog    ${filename}
    Read Wireshark Log  filename=${filename}
    ${icmp.resptime}   Get PARAM Value from Wireshark Log    icmp.resptime
    ...   element_idx=${0}
    ...    condition_expression=${None}
    ${ip.dsfield.dscp}   Get PARAM Value from Wireshark Log    ip.dsfield.dscp
    ...   element_idx=${0}
    ...    condition_expression=${None}
    ${ip.len}   Get PARAM Value from Wireshark Log    ip.len
    ...   element_idx=${0}
    ...    condition_expression=${None}
    ${ip.dsfield.dscp}   swith_number_to_16      list=${ip.dsfield.dscp}
    ${ip.len}            swith_number_to_16      list=${ip.len}
    should not be empty    ${icmp.resptime}
    Log to console   SET DSCP:${dscp}
    ${Payload_size_change}    evaluate   ${Payload_size}+28
    ${Payload_size_change}    convert to string    ${Payload_size_change}
    Log to console   Payload_size:${Payload_size_change}
    run keyword and continue on failure  list should contain value     ${ip.dsfield.dscp}    ${dscp}
    run keyword and continue on failure  list should contain value     ${ip.len}    ${Payload_size_change}

Wireshark DownloadLog
    [Arguments]    ${filename}
    ssh.download_file   local_path=${LOG_PATH}/${filename}    remote_path=${epc_log_path}/${filename}
    sleep    20s
    log to console  Download Log successful

5GC002236_307_Teardown
    [Arguments]
    selenium_coam.logout
    TRANS Common Teardown
    CI_interface.Common Case Teardown

#5GC001566_D_5GC00986
step1:Creat parameters for bfd and trigger
    [Arguments]    ${ID}    ${PARAMS_TRIGGER}
    ${dict_ipappid}    Create IPAA object    ID=${ID}
    Create BFD object    ID=${ID}
    Create trigger object    ID=${ID}    para_trigger=${PARAMS_TRIGGER}
    [Return]    ${dict_ipappid}

Create IPAA object
    [Arguments]    ${ID}
    ${dict_ipappid}    Create IPAPP list via parameters
    Create object    dn=MRBTS-${gnb_id}/TNLSVC-1/TNL-1/IPAPP-${ID}    para_name=${dict_ipappid}
    [Return]    ${dict_ipappid}

Create IPAPP list via parameters
    BuiltIn.Log    \n Create IPAPP object \n    console=yes
    ${ipappid}    create dictionary    parameterName=ipAppId    operation=update    value=${1}
    ${dict_ipappid}    create list    ${ipappid}
    [Return]    ${dict_ipappid}

Create object
    [Arguments]    ${dn}    ${para_name}
    ${conn}    admin.connect_to    bts_host=${gNB_ip}     name=GNB_OAM
    admin.perform_object_recommissioning
    ...    dist_name=${dn}
    ...    parameter=${para_name}    operation=create     skip_parameter_relation_errors=${True}
    ...    should_activate=${True}    connection=${conn}
    [Teardown]    Teardown gNB cOAM SSL Connection

Create BFD object
    [Arguments]    ${ID}
    ${dict_bfd}    Create BFD list via parameters
    Create object    dn=MRBTS-${gnb_id}/TNLSVC-1/TNL-1/IPAPP-1/BFD-${ID}    para_name=${dict_bfd}
    [Return]    ${dict_bfd}

Create BFD list via parameters
    BuiltIn.Log    \n Create BFD parameters \n    console=yes
    ${bfdActivation}    create dictionary    parameterName=bfdActivation    operation=update    value=${True}
    ${bfdAdminUp}    create dictionary    parameterName=bfdAdminUp    operation=update    value=${True}
    ${bfdDestIpAddr}    create dictionary    parameterName=bfdDestIpAddr    operation=update    value=10.57.243.129
    ${bfdDetectMult}    create dictionary    parameterName=bfdDetectMult    operation=update    value=3
    ${bfdDscp}    create dictionary    parameterName=bfdDscp    operation=update    value=48
    ${bfdId}    create dictionary    parameterName=bfdId    operation=update    value=1
    ${bfdSrcIpAddrDN}    create dictionary    parameterName=bfdSrcIpAddrDN    operation=update
    ...    value=MRBTS-${gnb_id}/TNLSVC-1/TNL-1/IPNO-1/IPIF-4/IPADDRESSV4-1
    ${bfdSrcUdpPort}    create dictionary    parameterName=bfdSrcUdpPort    operation=update    value=3784
    ${bfdType}    create dictionary    parameterName=bfdType    operation=update    value=singleHopBFD
    ${desMinTxInt}    create dictionary    parameterName=desMinTxInt    operation=update    value=500
    ${reqMinRxInt}    create dictionary    parameterName=reqMinRxInt    operation=update    value=500
    ${dict_bfd}    create list    ${bfdActivation}    ${bfdAdminUp}    ${bfdDestIpAddr}    ${bfdDetectMult}
    ...    ${bfdDscp}    ${bfdId}    ${bfdSrcIpAddrDN}    ${bfdSrcUdpPort}    ${bfdType}    ${desMinTxInt}
    ...    ${reqMinRxInt}    ${reqMinRxInt}
    [Return]    ${dict_bfd}

Create trigger object
    [Arguments]    ${ID}    ${para_trigger}
    BuiltIn.Log    \n Create trigger parameters \n    console=yes
    Create object    dn=${MRBTS}/TNLSVC-1/TNL-1/TRIGGER-${ID}    para_name=${para_trigger}

step2:Modify IPRT-1 triggerDN parameter
    [Arguments]    ${IPRT_distname_1}    ${PARAMS}
    ${conn}    admin.connect_to    bts_host=${gNB_ip}     name=GNB_OAM
    modify parameter    dn=${IPRT_distname_1}    parameter=staticRoutes    value=${PARAMS}    connection=${conn}
    [Teardown]    Teardown gNB cOAM SSL Connection

modify parameter
    [Arguments]    ${dn}    ${parameter}    ${value}    ${connection}
    admin.perform_parameter_recommissioning     dist_name=${dn}
    ...                                        parameter=${parameter}
    ...                                        operation=update
    ...                                        value=${value}
    ...                                        skip_parameter_relation_errors=${True}
    ...                                        should_activate=${True}
    ...                                        connection=${connection}

step3:Check bfd state is up and trigger route
    BFD TCPDUMP LOG    filename=${up_filename}    interface=${interface}    remote_path=${remote_path}    local_path=${LOG_PATH}
    Download Log    filename=${up_filename}
    Another Check bfd state in tcpdump    local_path=${LOG_PATH}    filename=${up_filename}    condition_expression=${bfd_state_true}
    Check ipv4 route about trigger    ip_flag=${ip_flag}    gateway=${src_ip_value}    interface=${interface}

BFD TCPDUMP LOG
    [Arguments]     ${filename}    ${interface}    ${remote_path}    ${local_path}   ${conn}=GNB_SSH
    ssh.connect_to   hostname=${gNB_ip}    username=${DU_OAM_SSH_USERNAME_TL}    password=${DU_OAM_SSH_PASSWORD_TL}    alias=${conn}
    BuiltIn.Log    \n Start To Capture tcpdump \n    console=yes
    ssh.send command    command=tcpdump -s0 -i ${interface} -w ${remote_path}/${filename}    connection=${conn}
    sleep    40s
    BuiltIn.Log    \n Stop To Capture tcpdump \n    console=yes
    ssh.send command    command=killall tcpdump     connection=${conn}
    ${tcpdunmp_log}    ssh.download_file   remote_path=${remote_path}/${filename}
    ...    local_path=${local_path}/${filename}   connection=${conn}
    [Teardown]    ssh.Disconnect    connection=${conn}

Download Log
    [Arguments]     ${filename}
    ssh.connect_to    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}    alias=connection_ute
    ssh.send command   command=sudo ssh-keygen -f "/root/.ssh/known_hosts" -R "${gNB_ip}"     connection=connection_ute
    ssh.send command   command=sudo sshpass -p oZPS0POrRieRtu scp toor4nsn@${gNB_ip}:/tmp/${filename} ${LOG_PATH}
    ...     connection=connection_ute
    sleep    10s
    ssh.Disconnect    connection=connection_ute
    log to console  Download Log successful

Another Check bfd state in tcpdump
    [Arguments]    ${local_path}    ${filename}    ${condition_expression}
    ssh.connect_to    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}    alias=connection_ute
    ssh.send command
    ...    command=/usr/bin/tshark -r ${local_path}/${filename} -X lua_script:${luashark_path} -Y "${condition_expression}" -T fields -e bfd.sta
    ...    connection=connection_ute
    ${return_value}    csn.Read Output    connection=connection_ute
    run keyword and continue on failure    should not be empty    ${return_value}
    sleep    10s
    ssh.Disconnect    connection=connection_ute

Check ipv4 route about trigger
    [Documentation]    Login gNB and check Route on gNB
    [Arguments]    ${interface}    ${ip_flag}    ${gateway}   ${table}=main
    ${result}=              Login and Send Command    commands=ip ${ip_flag} route list table ${table}
    Log To Console          \n checking route on table 1${table}: ${result}
    Should Match Regexp     ${result}   default via.*${gateway} dev.*${interface}
    [Return]      ${result}

Login and Send Command
    [Documentation]   Login gNB and execute commands on gNB
    [Arguments]    ${commands}    ${connection}=GNB_SSH
    ssh.connect_to   hostname=${gNB_ip}    username=${DU_OAM_SSH_USERNAME_TL}    password=${DU_OAM_SSH_PASSWORD_TL}    alias=${connection}
    ${result}=    ssh.execute    command=${commands}    connection=${connection}
    ${stdout}=    csn.Read Output    connection=${connection}
    ${stderr}=    csn.Read Error    connection=${connection}
    [Teardown]    csn.Disconnect    connection=${connection}
    [Return]    ${result}

step4:Modify bfdDestIpAddr Parameters
    [Arguments]    ${BFD_distname_1}    ${bfd_ip_notok}
    ${conn}    admin.connect_to    bts_host=${gNB_ip}     name=GNB_OAM
    ${get_managed_objects}=    admin.get_managed_objects    class_name=BFD_A    connection=${conn}
    ${bfd_parameters}    get from dictionary    ${get_managed_objects}[0]    parameters
    ${bfdDestIpAddr}    get from dictionary    ${bfd_parameters}    bfdDestIpAddr
    modify parameter    dn=${BFD_distname_1}    parameter=bfdDestIpAddr    value=${bfd_ip_notok}    connection=${conn}
    [Teardown]    Teardown gNB cOAM SSL Connection
    [Return]    ${bfdDestIpAddr}

step5:Check bfd state is down
    BFD TCPDUMP LOG    filename=${dowm_filename}    interface=${interface}    remote_path=${remote_path}    local_path=${LOG_PATH}
    Download Log   filename=${dowm_filename}
    Another Check bfd state in tcpdump    local_path=${LOG_PATH}    filename=${dowm_filename}    condition_expression=${bfd_state_down}
    Check ipv4 route not have about trigger    ip_flag=${ip_flag}    gateway=${src_ip_value}    interface=${interface}
    Check trigger state is false

Check ipv4 route not have about trigger
    [Documentation]    Login gNB and check Route on gNB
    [Arguments]    ${interface}    ${ip_flag}    ${gateway}   ${table}=main
    ${result}=              Login and Send Command    commands=ip ${ip_flag} route list table ${table}
    Log To Console          \n checking route on table 1${table}: ${result}
    Should not Match Regexp     ${result}   default via.*${gateway} dev.*${interface}
    [Return]      ${result}

Check trigger state is false
    5GC002236_common_keyword.Du login page via webUI
    Log To Console      \n start get trig_stat
    ${trig_state}    selenium_coam.get parameter value    dist_name=${Trigger_distname_1_1}
    ...                              filter_param=State of the trigger
    should be equal    ${trig_state}    FALSE
    [Teardown]    selenium_coam.logout

Recover the test ENV
    [Arguments]    ${PARAMS_TRIGGER}    ${bfdDestIpAddr}    ${PARAMS}    ${dict_ipappid}
    ${conn}    admin.connect_to    bts_host=${gNB_ip}     name=GNB_OAM
    BuiltIn.Log    \n Recover bfdDestIpAddr Parameters \n    console=yes
    modify parameter    dn=${BFD_distname_1}    parameter=bfdDestIpAddr    value=${bfdDestIpAddr}    connection=${conn}
    BuiltIn.Log    \n Delete IPRT-1 triggerDN parameter \n    console=yes
    modify parameter    dn=${IPRT_distname_1}    parameter=staticRoutes    value=${PARAMS}    connection=${conn}
    Teardown gNB cOAM SSL Connection
    run keyword and continue on failure    Delete trigger object    para_name=${PARAMS_TRIGGER}
    run keyword and continue on failure    Delete IPAPP parameters    dn=${MRBTS}/TNLSVC-1/TNL-1/IPAPP-${ID}    dict_ipappid=${dict_ipappid}

Delete trigger object
    [Arguments]    ${para_name}
    Delete object    dn=${MRBTS}/TNLSVC-1/TNL-1/TRIGGER-1    para_name=${para_name}

Delete object
    [Arguments]    ${dn}    ${para_name}
    ${conn}    admin.connect_to    bts_host=${gNB_ip}     name=GNB_OAM
    admin.perform_object_recommissioning
    ...    dist_name=${dn}
    ...    parameter=${para_name}    operation=delete     skip_parameter_relation_errors=${True}
    ...    should_activate=${True}    connection=${conn}
    [Teardown]    Teardown gNB cOAM SSL Connection

Delete IPAPP parameters
    [Arguments]    ${dn}    ${dict_ipappid}
    Delete object    dn=${dn}    para_name=${dict_ipappid}

#New
Modify parameters via Coam And Check Top Source Info
    [Arguments]  ${PARAMS_TO_MODIFY}    ${except_topp_list}    ${connection}=GNB_connection
    Modify Common parameter via Coam    input_list=${PARAMS_TO_MODIFY}    connection=${connection}
    Sleep    5min
    COAM Check TOP Synchronization info   bts_addr=${gNB_ip}    except_topp_list=${except_topp_list}

Modify Common parameter via Coam
    [Arguments]  ${input_list}    ${connection}=GNB_connection    ${bts_ip}=${gNB_ip}
    admin.connect_to    bts_host=${bts_ip}   name=${connection}
    FOR    ${item}  IN    @{input_list}
         ${dict_value}    Get Content From Input Dict    input_dict=${item}
         admin.Perform Parameter Recommissioning    dist_name=${dict_value}[0]   parameter=${dict_value}[1]   value=${dict_value}[2]
         ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
         sleep  2min
    END
    [Teardown]  Run keyword and ignore error    admin.teardown      connection=${connection}

Get Content From Input Dict
    [Arguments]  ${input_dict}
    ${dist_name}    get from dictionary     ${input_dict}    dist_name
    ${parammeter}    get from dictionary    ${input_dict}    parameter
    ${new_value}     get from dictionary    ${input_dict}    value
    ${value_list}    create list    ${dist_name}    ${parammeter}    ${new_value}
    [Return]  ${value_list}
