*** Settings ***
Documentation    This is private KW
...   author: Liu Ning
...   contact: ning.4.liu@nokia-sbell.com

Library    OperatingSystem
Library    Collections
Library    String
Library    taf.transport.ssh    WITH NAME    csn
Library    Telnet
Library    Process
#Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library    taf.selenium.gnb.oam.coam.cu    WITH NAME   coam_cu
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/qualcomm_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/check_android_ue_l3_call_process.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Throughput_checking_from_GNB.robot
Resource    ./5GC001937_utecloud_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot





*** Variables ***
${DU_OAM_IP}            ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${CU_OAM_IP}            ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${DU_SSH_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_SSH_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}

${WEBUI_URL}        https://${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBUI_USER}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}   ${tl.gnbs[0].cu.oam_http_connection_details.password}

${web_ui_CU}    https://${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${host_addr}    ${tl.test_pc.default_ssh_connection_details.addr}
${host_username}    ${tl.test_pc.default_ssh_connection_details.username}
${host_password}    ${tl.test_pc.default_ssh_connection_details.password}
${gnb_index}    ${0}
${du_index}    ${0}


*** Keywords ***

Start traffic_S21_TL915
    [Arguments]    ${direction}    ${duration}   ${throughput}    ${iperf_port}=default
    ...            ${ue_index}=${0}    ${interval}=1    ${buffer_size}=1024B    ${iperf_type}=via_app
    ...            ${protocol}=udp    ${data_amount}=1M    ${process_num}=${3}
    ...            ${seg_size}=1180    ${window}=2M    ${server_window}=16M    &{kwargs}
    [Documentation]    Start data transfer for L3 call test.
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  duration: Duration of traffic
    ...  :param  throughput: Throughput of new data transfer
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for traffic
    ...  :param  protocal: Traffic protocal type. E.G udp/tcp
    ...  :param  iperf_type: Traffic use iperf command or iperf app type. E.G via_app/via_command
    ${default_port}    set variable if    '${direction}'=='ul'    ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    ...                                                           ${tl.ues[${ue_index}].iperf_details.port}
    ${port}    set variable if   '${iperf_port}' == 'default'    ${default_port}    ${iperf_port}
    run keyword if    '${direction}' == 'dl'    Start DL traffic and check the TP on EPC_Samsung_S21_TL915    ue_index=${ue_index}
    ...                                                                                     time=${duration}
    ...                                                                                     interval=${interval}
    ...                                                                                     traffic=${throughput}
    ...                                                                                     buffer_size=${buffer_size}
    ...                                                                                     iperf_port=${port}
    ...                                                                                     protocol=${protocol}
    ...                                                                                     process_num=${process_num}
    ...                                                                                     seg_size=${seg_size}
    ...                                                                                     window=${window}
	...                                                                                     server_window=${server_window}
    ...    ELSE IF    '${direction}' == 'ul'    Start UL traffic and check the TP on Commercial    time=${duration}
    ...                                                                                            traffic=${throughput}
    ...                                                                                            ue_index=${ue_index}
    ...                                                                                            iperf_port=${port}
    ...                                                                                            iperf_type=${iperf_type}
    ...                                                                                             protocol=${protocol}
    ...                                                                                             data_amount=${data_amount}
    ...                                                                                             buffer_size=${buffer_size}

Start DL traffic and check the TP on EPC_Samsung_S21_TL915
    [Documentation]    stat DL traffic
    ...    :param  ue_index: The list index from tl.ues[]
    ...    :param  time: Duration of traffic
    ...    :param  interval: common which to get UE IP
    ...    :param  traffic: Throughput of new data transfer
    ...    :param  buffer_size: buffer size of new data transfer
    ...    :param  protocal: Traffic protocal type. E.G udp/tcp
    [Arguments]    ${ue_index}=${0}    ${time}=10    ${iperf_port}=${tl.ues[${ue_index}].iperf_details.port}
    ...            ${interval}=1    ${traffic}=10.00M    ${buffer_size}=1024B    ${protocol}=udp
    ...            ${process_num}=${1}    ${seg_size}=1180    ${window}=2M    ${server_window}=16M
    run keyword if    '${protocol}'=='udp'        Start DL traffic and check the TP on EPC with first UE    ue_index=${ue_index}
    ...                                                       time=${time}
    ...                                                       interval=${interval}
    ...                                                       traffic=${traffic}
    ...                                                       buffer_size=${buffer_size}
    ...                                                       DL_port=${iperf_port}
    ...                                                       process_num=${process_num}
    ...    ELSE    Start DL TCP traffic and check the TP on EPC with first UE_Samsung_S21_TL915    ue_index=${ue_index}
    ...                                                       time=${time}
    ...                                                       interval=${interval}
    ...                                                       traffic=${traffic}
    ...                                                       buffer_size=${buffer_size}
    ...                                                       DL_port=${iperf_port}
    ...                                                       process_num=${process_num}
    ...                                                       seg_size=${seg_size}
    ...                                                       window=${window}
	  ...                                                       server_window=${server_window}



Start DL TCP traffic and check the TP on EPC with first UE_Samsung_S21_TL915
    [Documentation]    1. stat DL TCP traffic 2. This is private KW
    ...    :param  ue_index: The list index from tl.ues[]
    ...    :param  time: Duration of traffic
    ...    :param  interval: common which to get UE IP
    ...    :param  traffic: Throughput of new data transfer
    ...    :param  buffer_size: buffer size of new data transfer
    [Arguments]    ${ue_index}=${0}    ${DL_port}=${tl.ues[${ue_index}].iperf_details.port}    ${time}=10
    ...            ${interval}=1    ${traffic}=10.00M
    ...            ${buffer_size}=1024B    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...            ${process_num}=${3}    ${seg_size}=1350    ${window}=12M    ${server_window}=16M
    Get Commercial UE IP    ue_index=${ue_index}
	  sleep    3s
    Connect to control pc via cygwin    ue_index=${ue_index}
	  csn.send_command    command=pwd    connection=cygwin
	  ${tmp_output} =    csn.Read Output    connection=cygwin
	  log to console    This is ${tmp_output}
    csn.send_command    command=adb -s ${serial_number} root &
    ...    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell ps -ef |grep iperf |grep ${DL_port} |grep -v grep |awk '{print $2}'
    ...    connection=cygwin
    ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cygwin
    ${pid}=    Run keyword and continue on failure    Remove String    ${pid}    \n
    csn.send_command    command=adb -s ${serial_number} shell kill -9 ${pid} &
    ...    connection=cygwin
    sleep    1s
    #csn.send_command    command=adb -s ${serial_number} shell /data/local/tmp/iperf -s -p ${DL_port} -i 1 -w ${server_window} &
    #...    connection=cygwin
    sleep    2s
    FOR    ${i}    IN RANGE    10
	    log to console    This is loop${i} in UE
        csn.send_command    command=adb -s ${serial_number} shell /data/local/tmp/iperf -s -p ${DL_port} -i 1 -w ${server_window} &
        ...    connection=cygwin
        sleep    1s
        csn.send_command    command=adb -s ${serial_number} shell ps -ef |grep iperf |grep ${DL_port} |grep -v grep |awk '{print $2}'
        ...    connection=cygwin
        ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cygwin
        ${pid}=    Run keyword and continue on failure    Remove String    ${pid}    \n
        Exit For Loop If    '${pid}' != '${EMPTY}'
    END

    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}
    csn.send_command    command=pwd    connection=EPCAPP
	  ${tmp_output} =    csn.Read Output    connection=EPCAPP
	  log to console    This is ${tmp_output}
    csn.send_command    command=ps -ef|grep iperf|grep -v grep|grep ${DL_port}| awk '{print $2}' |xargs kill -9 &    connection=EPCAPP
    sleep    5s
    FOR    ${i}    IN RANGE    10
	    log to console    This is loop${i}
        csn.send_command
        ...   command=iperf -c ${UE_IP} -p ${DL_port} -i 1 -t ${time} -P ${process_num} -w ${window} -M ${seg_size} -m >/dev/null 2>/dev/null &
        ...   connection=EPCAPP
	    sleep    3s
        csn.send_command    command=ps -ef |grep iperf |grep ${DL_port} |grep -v grep |awk '{print $2}'
        ...   connection=EPCAPP
	    ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=EPCAPP
	    #${testType}    Evaluate    type(${pid})
        #log to console    testtype is ${testType}
	    ${pid}=    Run keyword and continue on failure    Remove String    ${pid}    \n
	    #${pid}=    Run keyword and continue on failure    Convert To String    ${pid}
        Exit For Loop If    '${pid}' != '${EMPTY}'
    END
	  log to console    .....UE_${ue_index} tcp dl iperf start....
    #[Teardown]    csn.disconnect      connection=EPCAPP}


Collect Snapshot in DU
    coam.connect_to    bts_host=${DU_OAM_IP}    bts_port=${443}    username=${WEBUI_USER}    password=${WEBUI_PASSWORD}
    ...   name=DU_OAM
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    coam.get_snapshot     target_file_name=${logPath}/Snapshot_${timestamp}.zip    timeout=720    connection=DU_OAM
    [Teardown]    coam.teardown    connection=DU_OAM

Collect Snapshot in CU
    coam_cu.enable_virtual_display
    sleep    5s
    coam_cu.login    url=${web_ui_CU}
    ...    username=Nemuadmin    password=nemuuser      browser=firefox    timeout=60
    Wait Until Keyword Succeeds    3m    5s     coam_cu.snapshot_collection_settings    coverage=All logs
    ...    save_location=Local
    ${log_ouput}       Wait Until Keyword Succeeds    15m    5s     coam_cu.collect_snapshot
    Set Suite Variable    ${log_ouput}
    [Teardown]    run keywords    coam_cu.logout
                  ...    AND    Run keyword and continue on failure     coam_cu.disable_virtual_display
                  ...    AND    Run keyword and continue on failure     Move Snapshot in UTE

Move Snapshot in UTE
     csn.connect_to    hostname=${host_addr}    username=${host_username}    password=${host_password}    alias=ute
     csn.send_command    command=pwd    connection=ute
     ${tmp_directory}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=ute
     csn.send_command    command=mv ${log_ouput} ${logPath}    connection=ute
     [Teardown]    csn.Disconnect    connection=ute

######innovation#####
Get TP log from aasylog file
     [Arguments]    ${TP_log}    ${Max_duration}    ${Traffic_Direction}
     ...    ${Max_fail_number}=${2}    ${Check_interval}=1min
     ...    ${log_path_GNB}=/tmp/aasyslog_tput.txt    ${Continuous_failure}=${True}    ${target_avg_percent}=0.9
     ...    ${min_percent}=0.75    ${gnb_index}=${0}    ${du_index}=${0} 
    [Documentation]
    ...                Contact: xxxx@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA.
     #Set Test Variable for these parameters can be used in other KW in this case and can be set by user
     Set Test Variable    ${Max_fail_number}
     #Set Test Variable    ${TP_TmpLog}     ${OUTPUT_DIR}/TP_log_tmp.txt
     Set Test Variable    ${min_percent}
     Set Test Variable    ${target_avg_percent}
     Set Test Variable    ${Traffic_Direction}
     ${Start_Line_No}   Set Variable    ${1}
     ${all_status}   Set Variable    ${empty}
     @{status_list}   Create List
     ${Traffic_Direction}   Convert To Lowercase    ${Traffic_Direction}
     ${Max_duration}    Convert Time	${Max_duration}

     ${match_list}    get regexp matches      ${Check_interval}    [s,h,d,m]
     ${match_list_len}    Get Length    ${match_list}
     ${Check_interval}    Run keyword if    ${match_list_len}!=0    Convert Time	${Check_interval}
     #This step is for getting the max loop of checking TP
     ${Max_loop}    Evaluate    int(${Max_duration}/${Check_interval}) 
     csn.connect_to    hostname=${host_addr}    username=${host_username}    password=${host_password}    alias=ute

     FOR  ${i}    IN RANGE    ${Max_loop}
         csn.send_command    command=cat -n '${TP_Log}' | tail -n 1 | awk '{print $1}'    connection=ute
         ${Last_Line_No}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=ute
         ${Last_Line_No}=    Run keyword and continue on failure    Remove String    ${Last_Line_No}    \n
         ${Current_time}   Get Current Date
         Set Test Variable    ${TP_TmpLog}     ${OUTPUT_DIR}/TP_log_tmp${Current_time}.txt
         csn.send_command    command=sed -n '${Start_Line_No},$p' '${TP_Log}' >'${TP_TmpLog}'    connection=ute
         ${status}    Run Keyword And Return Status    Check TP reach to target
         ${status} =  Run Keyword If  '${status}'=='False'  Set Variable  0  ELSE  Set Variable  1
         Append to list    ${status_list}    ${status}
         ${all_status}    Set Variable    ${all_status}${status}
         Run keyword if   "${Continuous failure}"=="True"
         ...    Check TP with continuesous failure    status_list=${all_status}
         Run keyword if   '${Continuous failure}'=='False'
         ...    Check TP with non-continuesous failure    status_list=${status_list}
         sleep    ${Check_interval}
         ${Current_time}   Get Current Date
         Set Test Variable     ${TP_Log}    ${OUTPUT_DIR}/TP_log_All_${Current_time}.txt
         Download Aasyslog File From GNB    log_path=${log_path_GNB}   local_path=${TP_Log}
         ...       gnb_index=${gnb_index}   du_index=${du_index}
         ...        host=${DU_OAM_IP}   username=${DU_SSH_username}    password=${DU_SSH_password}
         ${Start_Line_No}    Evaluate    ${Last_Line_No}+1
         Set Test Variable     ${Start_Line_No}
     END

     [Return]    ${TP_Log}
     [Teardown]      csn.Disconnect    connection=ute


Check TP with continuesous failure
     [Arguments]    ${status_list}
     ${matches}=    Get Regexp Matches    ${status_list}    0{${Max_fail_number}}
     ${matches_len}=    Get Length    ${matches}
     Should Be True   ${matches_len}==${0}

Check TP with non-continuesous failure
    [Arguments]    ${status_list}
    ${fail_counter}    Count Values In List      ${status_list}    0
    Should Be True  ${fail_counter}<=${Max_fail_number}

Check TP reach to target
    Run Keyword If    '${Traffic_Direction}'=='both'    Run keyword and continue on failure    power_ue.Check Bi Tput
	       ...    ue_type=${ue_type}    log=${TP_TmpLog}    cells=${list_of_cell_8CC}
           ...    ultarget_throughput=${8cc_ul_exp_tcp}    dltarget_throughput=${8cc_dl_exp_tcp}    actCarrierAggregation=${True}
           ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    ELSE IF   '${Traffic_Direction}'=='dl' or '${Traffic_Direction}'=='ul'    Run keyword and continue on failure
           ...    power_ue.Check Tput    ue_type=${ue_type}    direction=${Traffic_Direction}
           ...    log=${log}    cells=${list_of_cell_4CC}
           ...    target_throughput=${4cc_dl_exp_tcp}    actCarrierAggregation=${True}
           ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
     [Teardown]

Case Teardown for TL915
    run keyword if test failed    Run Keywords    Run keyword and continue on failure    Collect Snapshot in DU
                                  ...   AND    Run keyword and continue on failure    Collect Snapshot in CU
    Run keyword and continue on failure     step7:stop traffic
    Run keyword and continue on failure     step8:UE Detach
    run keyword and ignore error    Teardown the Aasyslog save progress
            ...     gnb_index=${gnb_index}    du_index=${du_index}
            ...     host=${DU_OAM_IP}   username=${DU_SSH_username}    password=${DU_SSH_password}
