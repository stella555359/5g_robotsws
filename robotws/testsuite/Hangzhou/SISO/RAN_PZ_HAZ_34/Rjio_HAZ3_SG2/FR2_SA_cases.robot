# *** Settings ***
# Documentation     author: Xueqin Deng
# ...               contact: xueqin.deng@nokia-sbell.com
# 
# 
# Library    taf.sbts.oam.coam.admin    WITH NAME    coam
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# 
# *** Variables ***
# ${mrbts_id}    ${tl.gnbs[0].global_bts_id}
# ${nrbts_id}    ${tl.gnbs[0].instance_id}
# ${cell_index}    21
# 
# ${appserver_addr}    ${tl.appserver.iperf_details.ssh_connection_details.addr}
# ${appserver_username}    ${tl.appserver.iperf_details.ssh_connection_details.username}
# ${appserver_password}    ${tl.appserver.iperf_details.ssh_connection_details.password}
# 
# ${uepc_hostname}    ${tl.ues[0].ssh_connection_details.addr}
# ${uepc_username}    ${tl.ues[0].ssh_connection_details.username}
# ${uepc_password}    ${tl.ues[0].ssh_connection_details.password}
# ${iperf_path}    ${tl.ues[0].iperf_details.iperf_path}
# 
# ${ul_port}    ${tl.ues[0].iperf_details.port}
# ${dl_port}    ${tl.appserver.iperf_details.port}
# 
# ${ul_tput}    150M
# ${dl_tput}    500M
# ${ul_expect_tput}    100
# ${dl_expect_tput}    400
# 
# ${dltcp_process_num}    6
# ${dltcp_seg_size}    536
# ${ultcp_process_num}    10
# ${ultcp_seg_size}    513
# 
# ${duration}    1200
# ${apn}    dxdata2
# ${ue_index_0}    0
# 
# ${attach_times}    100
# ${rach_succeess_rate_KPI}    0.85
# ${rach_rtt_KPI}    200
# 
# ${avg_ping_max_true}    30
# ${avg_ping_max_false}    50
# 
# ${ping_times}    100
# ${ping_succeess_rate_KPI}    0.85
# ${ping_latency_KPI}    500
# 
# ${ftp_path_uepc}    C:/FTP_Test
# ${ftp_path_server}    /home/mmw_sg2
# ${ftp_dl_peak_time}   30000
# ${ftp_ul_peak_time}    70000
#   
# *** Test Cases ***
# RJIO_FR2_01_DL_peak_tput_UDP
#     CPE UE prepare
#     ${UE_IP}    CPE UE attach and get UE ip
#     CPE UE perform dl udp transfer    UE_IP=${UE_IP}    dltput=${dl_tput}
#     Collect log and verify throughput    ul_exp_tput=0    dl_exp_tput=${dl_expect_tput}
#     [Teardown]    run keyword and ignore error    CPE UE call teardown
# 
# RJIO_FR2_02_DL_peak_tput_TCP
#     CPE UE prepare
#     ${UE_IP}    CPE UE attach and get UE ip
#     CPE UE perform dl tcp transfer    UE_IP=${UE_IP}    port=${dl_port}    process_num=${dltcp_process_num}
#     ...    seg_size=${dltcp_seg_size}
#     Collect log and verify throughput    ul_exp_tput=0    dl_exp_tput=${dl_expect_tput}
#     [Teardown]    run keyword and ignore error    CPE UE call teardown
# 
# RJIO_FR2_03_DL_peak_tput_FTP
#     CPE UE prepare
#     ${UE_IP}    CPE UE attach and get UE ip
#     CPE UE perform dl ftp transfer
#     ...    UE_IP=${UE_IP}    size=1.0G    file_out=1Gbtest.out    ftp_max_time=${ftp_dl_peak_time}
#     [Teardown]     Run keyword and ignore error    CPE UE detach
# 
# RJIO_FR2_04_UL_peak_tput_UDP
#     CPE UE prepare
#     ${UE_IP}    CPE UE attach and get UE ip
#     CPE UE perform ul udp data transfer    UE_IP=${UE_IP}    ultput=${ul_tput}
#     Collect log and verify throughput    ul_exp_tput=${ul_expect_tput}    dl_exp_tput=0
#     [Teardown]    run keyword and ignore error    CPE UE call teardown
# 
# RJIO_FR2_05_UL_peak_tput_TCP
#     CPE UE prepare
#     ${UE_IP}    CPE UE attach and get UE ip
#     CPE UE perform ul tcp transfer    UE_IP=${UE_IP}    port=${ul_port}    process_num=${ultcp_process_num}
#     ...    seg_size=${ultcp_seg_size}
#     Collect log and verify throughput    ul_exp_tput=${ul_expect_tput}    dl_exp_tput=0
#     [Teardown]    run keyword and ignore error    CPE UE call teardown    port2close_appserver=${ul_port}
# 
# RJIO_FR2_06_UL_peak_tput_FTP
#     CPE UE prepare
#     ${UE_IP}    CPE UE attach and get UE ip
#     CPE UE perform ul ftp transfer
#     ...    UE_IP=${UE_IP}    size=1.0G    file_out=1Gbtest.out    ftp_max_time=${ftp_ul_peak_time}
#     [Teardown]     Run keyword and ignore error    CPE UE detach
# 
# RJIO_FR2_07_UL_DL_peak_tput_UDP
#     CPE UE prepare
#     ${UE_IP}    CPE UE attach and get UE ip
#     CPE UE perform ul udp data transfer    UE_IP=${UE_IP}    ultput=${ul_tput}
#     CPE UE perform dl udp transfer    UE_IP=${UE_IP}    dltput=${dl_tput}
#     Collect log and verify throughput    ul_exp_tput=${ul_expect_tput}    dl_exp_tput=${dl_expect_tput}
#     [Teardown]    run keyword and ignore error    CPE UE call teardown
# 
# RJIO_FR2_08_UL_DL_peak_tput_FTP
#     CPE UE prepare
#     ${UE_IP}    CPE UE attach and get UE ip
#     CPE UE perform uldl ftp transfer    UE_IP=${UE_IP}
#     [Teardown]     Run keyword and ignore error    CPE UE detach
# 
# RJIO_FR2_09_Connected_and_IDLE_state_transfer
#     [Tags]    repeat_test
#     Run keyword and ignore error    Set parameters for ping latency
#     ...    actProactUlScheduling=false    drbInactivityTimerSA=10
#     CPE UE prepare
#     ${UE_IP}    CPE UE attach and get UE ip
#     sleep    10s
#     Ping latency kpi for idle to connected    times=${ping_times}    ip=${UE_IP}
#     [Teardown]     Run keyword and ignore error    CPE UE detach
# 
# RJIO_FR2_10_RACH_KPI_RTT
#     CPE UE prepare
#     Perform rach kpi test    times=${attach_times}
#     [Teardown]    run keyword and ignore error    CPE UE detach
# 
# RJIO_FR2_11_RACH_KPI_accessibility
#     [Tags]    repeat_test
#     CPE UE prepare
#     Perform rach kpi test    times=${attach_times}
#     [Teardown]    run keyword and ignore error    CPE UE detach
# 
# RJIO_FR2_12_ping_latency_IDLE_to_Connected
#     Run keyword and ignore error    Set parameters for ping latency
#     ...    actProactUlScheduling=false    drbInactivityTimerSA=10
#     CPE UE prepare
#     ${UE_IP}    CPE UE attach and get UE ip
#     sleep    10s
#     Ping latency kpi for idle to connected    times=${ping_times}    ip=${UE_IP}
#     [Teardown]     Run keyword and ignore error    CPE UE detach
#     
# RJIO_FR2_13_ping_latency_Connected
#     Set parameters for ping latency    actProactUlScheduling=false    drbInactivityTimerSA=600
#     CPE UE prepare
#     ${UE_IP}    CPE UE attach and get UE ip
#     ${ping_latency}    Get ping latency    ue_ip=${UE_IP}
#     Should Be True    ${ping_latency} < ${avg_ping_max_true}
#     log to console    \nactProactUlScheduling: false, avg_ping_latency: ${ping_latency}
#     CPE UE detach
#     Set parameters for ping latency    actProactUlScheduling=true
#     ${UE_IP_new}    CPE UE attach and get UE ip
#     ${ping_latency_new}    Get ping latency    ue_ip=${UE_IP_new}
#     Should Be True    ${ping_latency_new} < ${avg_ping_max_false}
#     log to console    \nactProactUlScheduling_new: true, avg_ping_latency_new: ${ping_latency_new}
#     [Teardown]     Run keyword and ignore error    Run keywords    CPE UE detach    AND
#     ...    Set parameters for ping latency    actProactUlScheduling=false    drbInactivityTimerSA=10
# 
# RJIO_FR2_14_FTP_with_small_file_upload
#     [Tags]
#     CPE UE prepare
#     ${UE_IP}    CPE UE attach and get UE ip
#     CPE UE perform ul ftp transfer    UE_IP=${UE_IP}    size=100K    file_out=100Kbtest.out    ftp_max_time=500
#     [Teardown]     Run keyword and ignore error    CPE UE detach
# 
# RJIO_FR2_15_FTP_with_small_file_download
#     CPE UE prepare
#     ${UE_IP}    CPE UE attach and get UE ip
#     CPE UE perform dl ftp transfer    UE_IP=${UE_IP}    size=100K    file_out=100Kbtest.out    ftp_max_time=400
#     [Teardown]     Run keyword and ignore error    CPE UE detach
# 
# RJIO_FR2_16_FTP_with_medium_file_upload
#     CPE UE prepare
#     ${UE_IP}    CPE UE attach and get UE ip
#     CPE UE perform ul ftp transfer    UE_IP=${UE_IP}    size=10M    file_out=10Mbtest.out    ftp_max_time=1000
#     [Teardown]     Run keyword and ignore error    CPE UE detach
# 
# RJIO_FR2_17_FTP_with_medium_file_download
#     CPE UE prepare
#     ${UE_IP}    CPE UE attach and get UE ip
#     CPE UE perform dl ftp transfer    UE_IP=${UE_IP}    size=10M    file_out=10Mbtest.out    ftp_max_time=800
#     [Teardown]     Run keyword and ignore error    CPE UE detach
# 
# *** Keywords ***
# CPE UE perform uldl ftp transfer
#     [Arguments]    ${UE_IP}    ${size}=1.0G    ${ul_ftp_max_time}=100000   ${dl_ftp_max_time}=${ftp_dl_peak_time}
#     ${file_in}    set variable    ftp.in
#     Connect to APPserver    alias=APPserver
#     ssh.execute    command=cd ${ftp_path_server}; rm -rf ${file_in}    connection=APPserver
#     ssh.connect to
#     ...    hostname=${uepc_hostname}    username=${uepc_username}   password=${uepc_password}   alias=cygwin
#     ssh.execute    command=cd ${ftp_path_uepc}/data; rm -rf ${file_in}    connection=cygwin
#     ${rt}    ssh.execute    command=route add ${appserver_addr} ${UE_IP}    connection=cygwin
#     Should Contain Any    ${rt}    ok    already exists   ignore_case=true
#     sleep    10s
#     ${ul_time_cost}    ${dl_time_cost}    run ftp uldl transfer scripts on uepc
#     check file exists and transfer complete
#     ...    path=${ftp_path_server}    file=${file_in}    size=${size}    alias=APPserver
#     check file exists and transfer complete
#     ...    path=${ftp_path_uepc}    file=${file_in}    size=${size}    alias=cygwin
#     should be true    ${dl_time_cost} <= ${dl_ftp_max_time}
#     should be true    ${ul_time_cost} <= ${ul_ftp_max_time}
#     [Teardown]    Run keyword and ignore error    Run keywords
#     ...    ssh.execute    command=rm -rf ${ftp_path_server}/${file_in}    connection=APPserver    AND
#     ...    ssh.execute    command=rm -rf ${ftp_path_uepc}/${file_in}    connection=cygwin    AND
#     ...    ssh.disconnect    connection=cygwin    AND
#     ...    ssh.disconnect    connection=APPserver
# 
# run ftp uldl transfer scripts on uepc 
#     ${rt}    ssh.execute    command=python ${ftp_path_uepc}/scripts/run_ftp_uldl.py    connection=cygwin
#     Should Contain    ${rt}    ul ftp transfer success
#     Should Contain    ${rt}    dl ftp transfer success
#     ${ul_time_cost}    get ftp time cost from log    log_output=${rt}    direction=ul
#     ${dl_time_cost}    get ftp time cost from log    log_output=${rt}    direction=dl
#     [Return]    ${ul_time_cost}    ${dl_time_cost}
# 
# get ftp time cost from log
#     [Arguments]    ${log_output}    ${direction}
#     @{output1}    Get Regexp Matches    ${log_output}    ${direction}_time_cost.*
#     @{splits1}    Split String    string=${output1}[0]
#     ${time_cost}    set variable     ${splits1}[1]
#     log to console    \n${direction} ftp transfer time cost: ${time_cost} ms
#     [Return]    ${time_cost}
# 
# CPE UE perform ul ftp transfer
#     [Arguments]    ${UE_IP}    ${size}    ${file_out}    ${ftp_max_time}
#     ${file_in}    set variable     ftp.in
#     Connect to APPserver    alias=APPserver
#     ssh.execute    command=cd ${ftp_path_server}; rm -rf ${file_in}    connection=APPserver
#     ssh.connect to    hostname=${uepc_hostname}    username=${uepc_username}   password=${uepc_password}   alias=cygwin
#     ${rt}    ssh.execute    command=route add ${appserver_addr} ${UE_IP}    connection=cygwin
#     Should Contain Any    ${rt}    ok    already exists   ignore_case=true
#     sleep    10s
#     ${time_cost}    perform ftp transfer via script on uepc    direction=ul
#     ...    server_file=${ftp_path_server}/${file_in}    uepc_file=${ftp_path_uepc}/${file_out}
#     check file exists and transfer complete
#     ...    path=${ftp_path_server}    file=${file_in}    size=${size}    alias=APPserver
#     should be true    ${time_cost} <= ${ftp_max_time}
#     [Teardown]    Run keyword and ignore error    Run keywords
#     ...    ssh.execute    command=rm -rf ${ftp_path_server}/${file_in}    connection=APPserver    AND
#     ...    ssh.disconnect    connection=cygwin    AND
#     ...    ssh.disconnect    connection=APPserver
# 
# CPE UE perform dl ftp transfer
#     [Arguments]    ${UE_IP}    ${size}    ${file_out}=100Kbtest.out    ${ftp_max_time}=100000
#     ${file_in}    set variable     ftp.in
#     ssh.connect to    hostname=${uepc_hostname}    username=${uepc_username}   password=${uepc_password}   alias=cygwin
#     ${rt}    ssh.execute    command=route add ${appserver_addr} ${UE_IP}    connection=cygwin
#     Should Contain Any    ${rt}    ok    already exists   ignore_case=true
#     sleep    10s
#     ssh.execute    command=cd ${ftp_path_uepc}/data; rm -rf ${file_in}    connection=cygwin
#     ${time_cost}    perform ftp transfer via script on uepc    direction=dl
#     ...    server_file=${ftp_path_server}/${file_out}    uepc_file=${ftp_path_uepc}/${file_in}
#     check file exists and transfer complete    path=${ftp_path_uepc}    file=${file_in}    size=${size}    alias=cygwin
#     should be true    ${time_cost} <= ${ftp_max_time}
#     [Teardown]    Run keyword and ignore error    Run keywords
#     ...    ssh.execute    command=rm -rf ${ftp_path_uepc}/${file_in}    connection=cygwin    AND
#     ...    ssh.disconnect    connection=cygwin
# 
# check file exists and transfer complete
#     [Arguments]    ${path}    ${file}    ${size}    ${alias}
#     ${size_value}    ssh.execute   command=cd ${path};du -sh ${file}  connection=${alias}
#     ${size_value}    Fetch From Left    ${size_value}    \t
#     log to console    \nfile exists, size: ${size_value}
#     should be true    '${size_value}'=='${size}'
#     
# perform ftp transfer via script on uepc
#     [Arguments]    ${direction}    ${server_file}    ${uepc_file}
#     ${script}    set variable    ${ftp_path_uepc}/scripts/ftp_cases.py
#     ${cmd}    Catenate
#     ...    python ${script} --direction='${direction}' --server_file='${server_file}' --uepc_file='${uepc_file}'
#     ${rt}    ssh.execute    command=${cmd}    connection=cygwin
#     Should Contain    ${rt}    ${direction} ftp transfer success
#     ${time_cost}    get ftp time cost from log    log_output=${rt}    direction=${direction}
#     [Return]    ${time_cost}
#      
# 
# Ping latency kpi for idle to connected
#     [Arguments]    ${times}    ${ip}
#     ...    ${ping_success_rate_taget}=${ping_succeess_rate_KPI}    ${ping_latency_taget}=${ping_latency_KPI}
#     ${ping_success_num}    set variable    0
#     ${ping_latency_sum}    set variable    0  
#     FOR    ${index}    IN RANGE    1    ${times}+1
#         wait until keyword succeeds    10min    1s    Check rrc state    status=Idle
#         ${ping_result}    ${ping_latency}    run keyword and ignore error
#         ...    Get ping latency    ue_ip=${ip}    ping_count=1
#         ${ping_success_num}    run keyword if    '${ping_result}'=='PASS'
#         ...    Evaluate    ${ping_success_num} + 1
#         ...    ELSE    Evaluate    ${ping_success_num} + 0
#         ${ping_latency_sum}    run keyword if    '${ping_result}'=='PASS'
#         ...    Evaluate    ${ping_latency_sum} + ${ping_latency}
#         ...    ELSE    Evaluate    ${ping_latency_sum} + 0
#         sleep    2s
#         ${is_rrc_connected}    run keyword and return status    Check rrc state    status=Connected
#         run keyword if    '${is_rrc_connected}'!='True'
#         ...    log to console    \n${index} times: rrc state after ping is incorrect
#         sleep    10s
#     END
#     ${ping_success_rate}    Evaluate    ${ping_success_num}/${times}
#     ${ping_latency_avg}    Evaluate    ${ping_latency_sum}/${ping_success_num}
#     log to console    \n${times} times: ping_success_rate: ${ping_success_rate},ping_latency_avg:${ping_latency_avg}
#     should be true    ${ping_success_rate} >= ${ping_success_rate_taget}
#     should be true    ${ping_latency_avg} <= ${ping_latency_taget}
# 
# Get ping latency
#     [Arguments]    ${ue_ip}     ${ping_count}=100    ${interval}=0.2    ${packetsize}=64    ${timeout}=35 s
#     Connect to APPserver    alias=APPserver
#     ${cmd_ping_to_ue}    Set variable  ping -c ${ping_count} -i ${interval} -s ${packetsize} ${ue_ip}
#     ${output_ping_to_ue}  ssh.execute  ${cmd_ping_to_ue}  connection=APPserver  timeout=${timeout}
#     ${avg_ping_to_ue}=    Get ping avg    input_str=${output_ping_to_ue}
#     ssh.disconnect    connection=APPserver
#     [Return]    ${avg_ping_to_ue}
# 
# Get ping avg
#     [Arguments]    ${input_str}
#     @{output1}    Get Regexp Matches    ${input_str}    rtt.*
#     @{splits}    Split String    string=${output1}[0]
#     log to console    ${splits}
#     @{splits1}    Split String    string=${splits}[3]    separator=/
#     [Return]    ${splits1}[1]   
# 
# Check rrc state
#     [Arguments]    ${status}
#     ${rrc_state}    Get rrc state on spark
#     Should Contain    ${rrc_state}[0]    ${status}
# 
# Get rrc state on spark
#     [Arguments]    ${ue_alias}=UE_${ue_index_0}
#     ${param}     create list    RRC Status
#     ${value}    spark.get_parm_value_on_ue    param=${param}    ue_alias=UE_${ue_index_0}
#     [Return]    ${value}
#  
# Set parameters for ping latency
#     [Arguments]    ${actProactUlScheduling}=None    ${drbInactivityTimerSA}=None
#     Du login page via webUI
#     run keyword if    '${actProactUlScheduling}'!='None'
#     ...    selenium_coam.set_parameter_value
#     ...    abbr=actProactUlScheduling
#     ...    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_index}
#     ...    filter_param=Activate UL proactive scheduling
#     ...    new_value=${actProactUlScheduling}
#     sleep    1s
#     run keyword if    '${drbInactivityTimerSA}'!='None'
#     ...    selenium_coam.set_parameter_value
#     ...    abbr=drbInactivityTimerSA
#     ...    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}
#     ...    filter_param=Stand alone UE DRB inactivity timer
#     ...    new_value=${drbInactivityTimerSA}
#     sleep    1s
#     selenium_coam.validate_plan
#     sleep    2s
#     selenium_coam.activate_plan    activate_plan_despite_errors=True
#     sleep    2s
#     [Teardown]   Run Keyword And Ignore Error    DU COAM selenium logout
# 
# Set drbInactivityTimerSA value
#     [Arguments]    ${drbInactivityTimerSA}
#     selenium_coam.set_parameter_value
#     ...    abbr=drbInactivityTimerSA
#     ...    dist_name=MRBTS-121/NRBTS-121
#     ...    filter_param=Stand alone UE DRB inactivity timer
#     ...    new_value=${drbInactivityTimerSA}
#     selenium_coam.validate_plan
#     selenium_coam.activate_plan    activate_plan_despite_errors=True
# 
# Get drbInactivityTimerSA value
#     
#     ${adrbInactivityTimerSA}    selenium_coam.get_parameter_value
#     ...    dist_name=MRBTS-121/NRBTS-121    filter_param=Stand alone UE DRB inactivity timer
#     [Return]    ${drbInactivityTimerSA}
#     
# Set actProactUlScheduling value
#     [Arguments]    ${actProactUlScheduling}
#     selenium_coam.set_parameter_value
#     ...    abbr=actProactUlScheduling
#     ...    dist_name=MRBTS-121/NRBTS-121/NRCELL-21
#     ...    filter_param=Activate UL proactive scheduling
#     ...    new_value=${actProactUlScheduling}
#     selenium_coam.validate_plan
#     selenium_coam.activate_plan    activate_plan_despite_errors=True
#    
# Get actProactUlScheduling value
#     ${actProactUlScheduling}    selenium_coam.get_parameter_value
#     ...    dist_name=MRBTS-121/NRBTS-121/NRCELL-21    filter_param=Activate UL proactive scheduling
#     [Return]    ${actProactUlScheduling}
#    
# CPE UE prepare
#     log to console    \nPrepare UE
#     ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index_0}
#     Set Suite Variable    ${ue_type}
#     power_ue.Prepare UE    ue_index=${ue_index_0}    ue_type=${ue_type}     power_reset=true
# 
# CPE UE attach and get UE ip
#     log to console    \nAttach UE
#     ${5Grach_ed_0}    power_ue.UE Attach
#     ...    ue_index=${ue_index_0}    ue_type=${ue_type}    log_type=Aasyslog    attach_mode=5G_SA    power_reset=true
#     sleep    6s
#     spark.send_at_command_on_ue    command=at$qcrmcall=1,1     ue_alias=UE_${ue_index_0}
#     power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False
#     ${UE_IP}    spark.get_ue_ip_on_ue    ue_alias=UE_${ue_index_0}    apnaddress=${apn}    ue_mode=SA
#     log to console    \nAttach success and UE ip: ${UE_IP}
#     [Return]    ${UE_IP}
# 
# CPE UE detach
#     Power_ue.UE Detach    ue_index=${ue_index_0}    ue_type=${ue_type}    power_reset=true
# 
# Get CPE UE ip
#     ${UE_IP}    spark.get_ue_ip_on_ue    ue_alias=UE_${ue_index_0}    apnaddress=${apn}    ue_mode=SA
#     [Return]    ${UE_IP}
# 
# CPE UE perform dl udp transfer
#     [Arguments]    ${UE_IP}    ${dltput}
#     Start DL traffic via iperf on Appserver    dl_port=${dl_port}    process_num=1    ue_addr=${UE_IP}
#     ...    dl_time=${duration}   dl_throughput=${dltput}    dl_length=1400B   protocol=udp
#     log to console    \nStart dl udp traffic: ${dltput}
# 
# Collect log and verify throughput
#     [Arguments]    ${ul_exp_tput}    ${dl_exp_tput}
#     ${cell_list}    Create List    1982485
#     ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=1m
#     log to console     \nCheck Tput
#     ${all_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=${cell_list}
#     ...    ultarget_throughput=${ul_exp_tput}    dltarget_throughput=${dl_exp_tput}
# 
# Stop data transfer on CPE UE
#     ssh.connect to    hostname=${uepc_hostname}    username=${uepc_username}   password=${uepc_password}   alias=cygwin
#     ${kill_iperf_cmd}  Catenate  ps -ef | grep iperf | grep -v grep | awk '{print $2}' | xargs kill -9 
#     ssh.send command    command=${kill_iperf_cmd}    connection=cygwin
#     sleep    3s
#     ssh.disconnect    connection=cygwin
# 
# Stop data transfer on appserver
#     [Arguments]    ${port}
#     Close the iperf process on APPserver    port=${port}
#     Disconnect from app server
# 
# CPE UE call teardown
#     [Arguments]    ${port2close_appserver}=${dl_port}
#     Run Keyword And Ignore Error    Stop data transfer on appserver    port=${port2close_appserver}
#     Run Keyword And Ignore Error    Stop data transfer on CPE UE
#     Run Keyword And Ignore Error    CPE UE detach
# 
# CPE UE perform ul udp data transfer
#     [Arguments]    ${UE_IP}    ${ultput}
#     ssh.connect to    hostname=${uepc_hostname}    username=${uepc_username}   password=${uepc_password}   alias=cygwin
#     ${kill_iperf_cmd}  Catenate  ps -ef | grep iperf | grep -v grep | awk '{print $2}' | xargs kill -9 
#     ssh.send command    command=${kill_iperf_cmd}    connection=cygwin
#     sleep    3s
#     # add route with admin privilege
#     ${rt}    ssh.execute    command=route add ${appserver_addr} ${UE_IP}    connection=cygwin
#     Should Contain Any    ${rt}    ok    already exists   ignore_case=true
#     sleep    3s
#     ${iperf_cmd}    Catenate
#     ...  ${iperf_path} -c ${appserver_addr} -u -p ${ul_port} -t ${duration} -P 1 -i 1 -b ${ultput} -l 1400B -w 2M &
#     ssh.send command    command=${iperf_cmd}    connection=cygwin
#     ssh.send command    command=ps -ef |grep iperf |grep -v grep |awk '{print $2}'    connection=cygwin
#     ${pid}    wait until keyword succeeds    10s    1s    ssh.read output    connection=cygwin
#     log to console    \nStart ul udp traffic: ${ultput}
#     ssh.disconnect    connection=cygwin
# 
# Start tcp port listening on CPE UE
#     [Arguments]    ${port}
#     ssh.connect to    hostname=${uepc_hostname}    username=${uepc_username}   password=${uepc_password}   alias=cygwin
#     ${kill_iperf_cmd}  Catenate  ps -ef | grep iperf | grep -v grep | awk '{print $2}' | xargs kill -9 
#     ssh.send command    command=${kill_iperf_cmd}    connection=cygwin
#     sleep   2s
#     ${listen_cmd}  Catenate  ${iperf_path} -s -i 1 -p ${port} &
#     ssh.send command    command=${listen_cmd}    connection=cygwin
#     sleep    1s
#     ssh.disconnect    connection=cygwin
# 
# Start tcp data transfer on CPE UE
#     [Arguments]    ${UE_IP}    ${port}    ${process_num}    ${seg_size}
#     ssh.connect to    hostname=${uepc_hostname}    username=${uepc_username}   password=${uepc_password}   alias=cygwin
#     ${kill_iperf_cmd}  Catenate  ps -ef | grep iperf | grep -v grep | awk '{print $2}' | xargs kill -9 
#     ssh.send command    command=${kill_iperf_cmd}    connection=cygwin
#     sleep    2s
#     # add route with admin privilege
#     ${rt}    ssh.execute    command=route add ${appserver_addr} ${UE_IP}    connection=cygwin
#     Should Contain Any    ${rt}    ok    already exists   ignore_case=true
#     sleep    3s
#     ${iperf_cmd}    Catenate
#     ...  ${iperf_path} -c ${appserver_addr} -t ${duration} -i 1 -p ${port} -P ${process_num} -M ${seg_size} -w 16M &
#     ssh.send command    command=${iperf_cmd}    connection=cygwin
#     ssh.read_output_until    match=Transfer    timeout=20    connection=cygwin
#     ssh.disconnect    connection=cygwin
# 
# CPE UE perform dl tcp transfer
#     [Arguments]    ${UE_IP}    ${port}    ${process_num}    ${seg_size}
#     Start tcp port listening on CPE UE    port=${port}
#     Connect to APPserver    alias=APPserver
#     Start tcp data transfer on appserver    destination_address=${UE_IP}    trans_time=${duration}    port=${port}
#     ...    process_num=${process_num}    seg_size=${seg_size}    window=16M
#     ssh.disconnect    connection=APPserver
#     log to console    \nStart dl tcp traffic
# 
# CPE UE perform ul tcp transfer
#     [Arguments]    ${UE_IP}    ${port}    ${process_num}    ${seg_size}
#     Connect to APPserver    alias=APPserver
#     start tcp port listening on appserver    port=${port}
#     ssh.disconnect    connection=APPserver
#     Start tcp data transfer on CPE UE
#     ...    UE_IP=${UE_IP}    port=${port}    process_num=${process_num}    seg_size=${seg_size}
#     log to console    \nStart ul tcp traffic
# 
# Perform rach kpi test
#     [Arguments]    ${times}     ${rach_success_rate_taget}=${rach_succeess_rate_KPI}
#     ...    ${rach_rtt_taget}=${rach_rtt_KPI}
#     ${rach_success_num}    set variable    0
#     ${rach_rtt_sum}    set variable    0
#     FOR    ${index}    IN RANGE    1    ${times}+1
#         ${attach_result}    ${rach_rtt}    run keyword and ignore error    perform attach and get rach rtt on spark
#         log to console    \nThe ${index} times, attach result: ${attach_result}, rach rtt: ${rach_rtt} ms
#         ${rach_success_num}    run keyword if    '${attach_result}'=='PASS'    Evaluate    ${rach_success_num} + 1
#         ...    ELSE    Evaluate    ${rach_success_num} + 0
#         ${rach_rtt_sum}    run keyword if    '${attach_result}'=='PASS'    Evaluate    ${rach_rtt_sum} + ${rach_rtt}
#         ...    ELSE    Evaluate    ${rach_rtt_sum} + 0
#         sleep    3s
#         CPE UE detach
#         sleep    6s
#     END
#     ${rach_success_rate}    Evaluate    ${rach_success_num}/${times}
#     ${rach_rtt_avg}    Evaluate    ${rach_rtt_sum}/${rach_success_num}
#     should be true    ${rach_success_rate} >= ${rach_success_rate_taget}
#     should be true    ${rach_rtt_avg} <= ${rach_rtt_taget}    
#     
# perform attach and get rach rtt on spark
#     CPE UE attach and get UE ip
#     ${rach_begin_time}    spark.get_event_time_on_ue
#     ...    index=1    event_name=NR5G RACH Begin    ue_alias=UE_${ue_index_0}
#     ${rach_complete_time}    spark.get_event_time_on_ue
#     ...    index=1    event_name=NR5G RACH Complete    ue_alias=UE_${ue_index_0}
#     ${rach_rtt}    Evaluate    (${rach_complete_time}-${rach_begin_time})/1000
#     [Return]    ${rach_rtt}
#     
