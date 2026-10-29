*** Settings ***
Documentation    Suite description
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Library           ute_syslog
Library           taf.collectors.btslog                  WITH NAME    btslog
Library           taf.collectors.core                    WITH NAME    core

*** Variables ***
${DU_OAM_IP_URL}            https://${tl.gnbs[0].dus[0].f1_m_ip_addr}
${DU_OAM_WEBUI_IP}         ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${DU_OAM_WEBUI_USER}        ${tl.gnbs[0].cu.oam_http_connection_details.username}
${DU_OAM_WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${DU_OAM_IP_TL}                ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${DU_OAM_SSH_USERNAME_TL}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_OAM_SSH_PASSWORD_TL}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${ru_alias}   RU
${test_ute}                   ${tl.test_pc.default_ssh_connection_details.addr}
${ute_name}                   ${tl.test_pc.default_ssh_connection_details.username}
${test_password}              ${tl.test_pc.default_ssh_connection_details.password}
${DU_OAM_IP}                  ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${Test_Case_Name}             5GC002238_QA_3

*** Keywords ***
login RU to make alarm
    [Arguments]     ${asik_alias}=ASIK Master
    csn.connect_to
    ...    hostname=${DU_OAM_IP_TL}
    ...    username=${DU_OAM_SSH_USERNAME_TL}
    ...    password=${DU_OAM_SSH_PASSWORD_TL}
    ...    alias=${asik_alias}
    ${Get_RU_IP}    Get RU IP
    log to console  GET RU IP：${Get_RU_IP}
    Connect To RU Via FHNET Container     ru_ip_addr=${Get_RU_IP}
    csn.Send Command  command=ls /mnt/factory/configs/unit |grep mk4hf |head -n 1    connection=${ru_alias}
    log to console  Send Command successful
    ${bin_name}  csn.Read Output    connection=${ru_alias}
    ${bin_name}  strip_string    ${bin_name}
    log to console  bin_name is:${bin_name}
    csn.Send Command  command=mv /mnt/factory/configs/unit/${bin_name} /mnt/factory/configs/unit/change.bin
    ...    connection=${ru_alias}
    csn.disconnect    connection=${ru_alias}
    csn.disconnect    connection=${asik_alias}
    [Return]    ${Get_RU_IP}         ${bin_name}
    [Teardown]   Logout

Login DU
    coam.connect_to  bts_host=${DU_OAM_IP_TL}    username=${DU_OAM_WEBUI_USER}   password=${DU_OAM_WEBUI_PASSWORD}
    [Teardown]       coam.teardown

chenk alarm on web
    selenium_coam.login  url=${DU_OAM_IP_URL}    username=${DU_OAM_WEBUI_USER}   password=${DU_OAM_WEBUI_PASSWORD}
    selenium_coam.reset_ru
    log to console  reboot RRU,sleep 100s
    sleep    100s
    Check RU Alarm Info
    [Teardown]    selenium_coam.logout

Get RU IP
    csn.download_file   local_path=${LOG_PATH}/${filename}    remote_path=${epc_log_path_1}/${filename}    connection=${asik_alias}
    log to console  download successful
    ${RU_IP}    GET_test_RU_IP    file_path=${LOG_PATH}/${filename}
    [Return]    ${RU_IP}

Check RU Alarm Info
    Wait Until Keyword Succeeds    15min    10s    Check Alarm Info

Check Alarm Info
    @{alarms}    selenium_coam.get_active_alarm_info    timeout=${100}
    sleep    1s
    log     ${alarms}
    ${fault_id_list}    create list
    ${fault_name_list}    create list
    FOR    ${item}    IN    @{alarms}
         ${fault_id}    get from dictionary    ${item}    Fault ID
         ${fault_name}    get from dictionary    ${item}    Fault name
         append to list    ${fault_id_list}    ${fault_id}
         append to list    ${fault_name_list}    ${fault_name}
    END
    list should contain value     ${fault_id_list}    1901
    list should contain value     ${fault_name_list}    Radio autonomous reset as recovery action

Logout
    Run Keyword And Ignore Error    csn.disconnect    connection=${ru_alias}
    Run Keyword And Ignore Error    csn.disconnect    connection=${asik_alias}
    Run Keyword And Ignore Error    selenium_coam.logout

Du Check cell on air
    ${bts_status}    selenium_coam.get_bts_status
    Should be equal as strings    ${bts_status}    On air    msg=GNB is not on air, Current status is ${bts_status}
    ...                      ignore_case=${True}
Check RU IP nomal
    [Arguments]   ${Recover_get_RU_IP}    ${recover_bin_name}
    ${real_IP}    Get RU IP
    log to console   GET RU IP：${Recover_get_RU_IP} return real_IP：${real_IP} bin_name:${recover_bin_name}
    should not be equal    ${real_IP}    0.0.0.0

Recover alarm
    [Arguments]   ${Recover_get_RU_IP}    ${recover_bin_name}
    log to console  start recover alarm,sleep 600s
    sleep   600s
    csn.connect_to
    ...    hostname=${DU_OAM_IP_TL}
    ...    username=${DU_OAM_SSH_USERNAME_TL}
    ...    password=${DU_OAM_SSH_PASSWORD_TL}
    ...    alias=${asik_alias}
    log to console  connection DU successful
    wait until keyword succeeds    20min    30s
    ...    Check RU IP nomal    Recover_get_RU_IP=${Recover_get_RU_IP}    recover_bin_name=${recover_bin_name}
    ${real_IP}    Get RU IP
    Connect To RU Via FHNET Container     ru_ip_addr=${real_IP}
    log to console  connect to RU successful
    log to console  bin_name is: ${recover_bin_name}
    csn.Send Command  command=mv /mnt/factory/configs/unit/change.bin /mnt/factory/configs/unit/${recover_bin_name}    connection=${ru_alias}
    log to console  command send successful
    sleep   60s
    log to console  recovering need reboot
    selenium_coam.login  url=${DU_OAM_IP_URL}    username=${DU_OAM_WEBUI_USER}   password=${DU_OAM_WEBUI_PASSWORD}
    selenium_coam.reset_ru
    wait until keyword succeeds    20min    10s     Du Check cell on air
    [Teardown]   Logout

Reboot DU and Check cell onAir
    [Arguments]  ${connection}=GNB_OAM
    Connect to gnb coam via ssl      bts_host=${DU_OAM_IP_TL}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    log to console  login web successful
    coam.reset_site    connection=${connection}
    wait until keyword succeeds    15min    10s     COAM Check GNB cell on air
    [Teardown]  COAM Teardown gnb connections

RMOD_unit_recovery
    ${Get_RU_IP}    ${bin_name}    login RU to make alarm
    chenk alarm on web
    [Teardown]   Recover alarm    Recover_get_RU_IP=${Get_RU_IP}    recover_bin_name=${bin_name}

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
    [Arguments]    ${bts_log_name}=bts_log.tgz    ${bts_logs_dir}=/tmp/btslog2
    Log To Console    stop BTSlog
    __Stop and collect btslog on local machine
    __Copy btslog to logs dir and clean BTSlog workspace    bts_log_name=${bts_log_name}    bts_logs_dir=${bts_logs_dir}

__Stop and collect btslog on local machine
    [Arguments]   ${name}=btslog
    core.stop_collectors         names=${name}
    core.collect_collectors      names=${name}
    core.teardown_collectors     names=${name}

__Make empty BTS logs dir
    [Arguments]     ${bts_logs_dir}=/tmp/btslog2
    Run  if [ ! -d ${bts_logs_dir} ]; then mkdir ${bts_logs_dir}; else rm ${bts_logs_dir}/*; fi

__Copy btslog to logs dir and clean BTSlog workspace
    [Arguments]     ${bts_log_name}=bts_log.tgz     ${bts_logs_dir}=/tmp/btslog2
	Run  mkdir ${OUTPUT_DIR}/${TEST_NAME}
	Run  mkdir ${OUTPUT_DIR}/${Test_Case_Name}
    Run  mv ${bts_logs_dir}/syslog_files.tgz ${OUTPUT_DIR}/${TEST_NAME}/${bts_log_name}
    Run  rm ${bts_logs_dir}/*

Connection to Du making alarm
    [Arguments]       ${asik_alias}=ASIK Master     ${bts_log_name}=bts_log.tgz
    BTSLOG Start btslog on local machine
    csn.connect_to
    ...    hostname=${DU_OAM_IP_TL}
    ...    username=${DU_OAM_SSH_USERNAME_TL}
    ...    password=${DU_OAM_SSH_PASSWORD_TL}
    ...    alias=${asik_alias}
    csn.Send Command  command=lxc-ls --active > /tmp/lxc.txt  connection=${asik_alias}
    csn.download_file  local_path=${LOG_PATH}/lxc.txt    remote_path=/tmp/lxc.txt    connection=${asik_alias}
    log to console  download lxc.txt successful
    ${lxc}  GET_lxc_active    file_path=${LOG_PATH}/lxc.txt
    ${lxc}  strip_string   ${lxc}
    csn.Send Command  command=rm /tmp/lxc.txt   connection=${asik_alias}
    csn.Send Command  command=lxc-attach -n ${lxc}  connection=${asik_alias}
    sleep  40s
    log to console  lxc active :${lxc}
    csn.Send Command  command=ps aux |grep ${lxc} |grep /opt/CCS/CCSDaemonExe |awk '{print $2}' |xargs kill -9   connection=${asik_alias}
    log to console  kill ${lxc} successful
    sleep     1min
    wait until keyword succeeds    5min    10s    login DU
    sleep    2min
#    Stop syslog    alias=ute
    BTSLOG Collect btslog      bts_log_name=${bts_log_name}
    run keyword and continue on failure    Check Btslog and Alarm     command=grep "AlarmNumber: 7101"
    Check Btslog and Alarm     command=grep "FaultId: 4383"
    log to console  check alarm successful
    sleep  60s
    [Teardown]   csn.disconnect    connection=${asik_alias}

Check Btslog and Alarm
    [Arguments]    ${command}    ${bts_log_name}=bts_log.tgz   ${bts_log}=bts_log.log   ${connection}=ute
    csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
    csn.execute    command=tar zxvf ${OUTPUT_DIR}/${TEST_NAME}/${bts_log_name} -C ${OUTPUT_DIR}/${Test_Case_Name}/    connection=${connection}
	csn.execute    command=mv ${OUTPUT_DIR}/${Test_Case_Name}/*.LOG ${OUTPUT_DIR}/${Test_Case_Name}/${bts_log}   connection=${connection}
    csn.Send Command  command=cat ${OUTPUT_DIR}/${Test_Case_Name}/${bts_log} | ${command}    connection=${connection}
    ${data}    csn.Read Output    connection=${connection}
    ${data}    strip_string    ${data}
    should not be empty    ${data}
    [Teardown]    csn.Disconnect   connection=${connection}

Connection to web and check cell onAir
    Connect to gnb coam via ssl      bts_host=${DU_OAM_IP_TL}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    wait until keyword succeeds    15min    10s     COAM Check GNB cell on air
    [Teardown]  COAM Teardown gnb connections

Login ssh du and capture wireshark
    [Arguments]    ${listen_port}    ${log_dir}    ${filename_tcp}     ${connection}
    csn.connect_to   hostname=${DU_OAM_IP}  username=${DU_OAM_SSH_USERNAME_TL}   password=${DU_OAM_SSH_PASSWORD_TL}    alias=${connection}
    csn.send command    command=tcpdump -s0 -i ${listen_port} -w ${log_dir}/${filename_tcp}
    ...     connection=${connection}
    sleep    2s

attach multi power ue
    [Arguments]    ${ue_num}
    log to console       Prepare UE
    FOR    ${item}    IN RANGE    ${ue_num}
         ${status}    run keyword and return status    power ue attach again    ue_index=${item}
         run keyword if  not ${status}    power ue attach again    ue_index=${item}
    END
    start multi power ue traffic ul  ue_num=${1}    ul_throughput=${ul_throughput}

power ue attach again
    [Arguments]    ${ue_index}
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=samsung
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=samsung    log_type=Aasyslog
    power_ue.Verify attach    ue_type=samsung   5Grach_ed=${5Grach_ed_0}    4G_check=False

start power ue traffic
    [Arguments]    ${ue_num}    ${ul_throughput}=${None}        ${ul_duration}=6000    ${protocol}=udp
    log to console      Start traffic    console=yes
    FOR    ${item}    IN RANGE    ${ue_num}
         power_ue.Start traffic    ue_index=${item}    direction=ul
         ...    throughput=${ul_throughput}    duration=${ul_duration}    ue_type=samsung    iperf_type=via_command    protocol=${protocol}
          sleep    1s
    END

Stop and Download Log
    [Arguments]    ${filename_tcp}    ${connection}
    ${PID}  csn.Execute  command=ps -ef |grep tcpdump|awk '{{print $2}}'|head -n 1
    ...    connection=${connection}
    ${PID}    strip_string    ${PID}
    csn.Execute    command=kill -2 ${PID}
    ...   connection=${connection}
    sleep    3s
    csn.connect_to    hostname=${test_ute}    username=${ute_name}    password=${test_password}    alias=connection_ute
    csn.send command   command=sshpass -p oZPS0POrRieRtu scp toor4nsn@${DU_OAM_IP}:${log_dir}/${filename_tcp} ${TS_CASE_LOG_PATH}
    ...     connection=connection_ute
    sleep    2s
    csn.Disconnect    connection=connection_ute
    log to console  Download Log successful

start multi power ue traffic ul
    [Arguments]    ${ue_num}    ${ul_throughput}=${None}        ${ul_duration}=6000    ${protocol}=udp
    log to console      Start traffic    console=yes
    FOR    ${item}    IN RANGE    ${ue_num}
         power_ue.Start traffic    ue_index=${item}    direction=ul
         ...    throughput=${ul_throughput}    duration=${ul_duration}    ue_type=samsung    iperf_type=via_command    protocol=${protocol}
          sleep    1s
    END

stop multi power ue traffic
    [Arguments]    ${ue_num}    ${protocol}=tcp    ${if_ul}=${True}
    log to console     Stop traffic    console=yes
    FOR    ${item}    IN RANGE    ${ue_num}
         run keyword if    ${if_ul}    power_ue.Stop traffic    direction=ul    ue_index=${item}    ue_type=samsung    iperf_type=via_command
          ...    protocol=${protocol}
    END

Get PARAM Value from Wireshark Log
    [Arguments]    ${check_param}    ${element_idx}=${0}    ${default_value}=False    ${condition_expression}=${None}
    ${value}     cap.Get Element Value    element_expression=${check_param}    element_idx=${element_idx}
    ...    default_value=${default_value}    condition_expression=${condition_expression}
    log to console  Get PARAM Value from Wireshark Log successful
    [Return]    ${value}
