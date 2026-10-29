*** Settings ***
Library        ute_ue
Library        ./lib/cpe.py
Library        ./lib/string_list.py
Library        cpe.Cpe_operation    WITH NAME    Cpe_operation
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/Power_ue_supports/power_ue_throughput.robot

*** Variables ***
${UE_IP}                    ${tl.ues[0].data_transfer[0].bind_ue_ip}
${UE_PC_IP}                 ${tl.ues[0].ue_pc_address}
${UE_PC_USERNAME}           ${tl.ues[0].ue_pc_login}
${UE_PC_PASSWD}             ${tl.ues[0].ue_pc_password}
${UE_SN}                    ${tl.ues[0].serial_number}
${APPSERVER_ADDR}           ${tl.ues[0].data_transfer[0].app_server.address}
${APPSERVER_USERNAME}       ${tl.ues[0].data_transfer[0].app_server.user}
${APPSERVER_PASSWORD}       ${tl.ues[0].data_transfer[0].app_server.password}
${APPSERVER_PORT}           ${tl.ues[0].data_transfer[0].app_server.app_server_name}
${APPSERVER_ADDR2}          10.71.219.21
${APPSERVER_PORT2}          0

*** Keywords ***
__Keywords only for searching should not use qualcomm cpe
    [Documentation]    this keyword only for searching keywords in the robot, should not use.
    CPE UE attach and collect tcpdump log
    Attach CPE UE for FR2 SA with retry
    Start data transfer based on direction for CPE
    Start traffic and verify tput for CPE
    Check tput for CPE UE
    UE attach and start traffic and check TPUT

attach CPE UE for FR2 SA
    [Documentation]  Author: Fang ludan
    ...          step1: require UE
    ...          step2: UE attach
    ...          step3: check UE attach result
    ...          step4: kill Aasyslog
    [Arguments]  ${alias}=AT_BASED_UE  ${require_UE}=${True}
    Kill At commnad process
    Start UE Proxy if not exist
    run keyword if   ${require_UE}==${True}   Require UE with retry    alias=${alias}
    log to console    \n... CPE SA attach and check status with aasyslog ...
    Teardown the Aasyslog save progress
    Aasyslog precondition
    Start the Aasyslog save progress    filter=L2   log_name=5Grach.txt
    ${5Gra_l2lo_counter}    ${5Gra_l2lo_timed}    Get 5GRACH success times on gnb side    log_type=Aasyslog
    ...                                                                                   log_loca=l2lo
    ${5Gra_l2hidu_counter}    ${5Gra_l2hidu_timed}    Get 5GRACH success times on gnb side    log_type=Aasyslog
    ...                                                                                       log_loca=l2hidu
    ${attach_status}   run keyword and return status   ute_ue.Attach Ue     ${alias}
    run keyword if    ${attach_status}==${False}    Restart UE Proxy
    run keyword if    ${attach_status}==${False}    log to console   \n@@@@@@ ...com issue apperar....\n
    run keyword if    ${attach_status}==${False}    run keyword and ignore error   ute_ue.Detach Ue    ${alias}
    run keyword if    ${attach_status}==${False}    sleep   2s
    run keyword if    ${attach_status}==${False}    ute_ue.Attach Ue     ${alias}
    sleep    10    # wait for create PDU session ready
    ute_ue.Log Ue Info   ${alias}    ALL
    ute_ue.Create PDU session   ${alias}
    ${status_l2lo}    run keyword and return status    wait until keyword succeeds    1 min    10s    Check 5G Rach Status
    ...               before=${5Gra_l2lo_counter}    before_time=${5Gra_l2lo_timed}    log_type=Aasyslog    log_loca=l2lo
    ${status_l2hi}   run keyword and return status
    ...              Run keyword if    '${status_l2lo}'=='False'    wait until keyword succeeds    1 min    10s    Check 5G Rach Status
    ...              before=${5Gra_l2hidu_counter}    before_time=${5Gra_l2hidu_timed}    log_type=Aasyslog    log_loca=l2hidu
    ${5G_attach_status}    set variable if    ${status_l2lo}==${True} or ${status_l2hi}==${True}    ${True}    ${False}
    should be true    ${5G_attach_status}==${True}
    [Teardown]     Run Keyword And Ignore Error   Run Keywords
    ...   Teardown the Aasyslog save progress   AND
    ...   Download aasyslog    local_log_folder=${TS_CASE_LOG_PATH}     aasyslog_name=5Grach.txt

Require UE with retry
    [Documentation]  Author: Wang Yixiang
    ...          if require UE failed, restart UE proxy
    [Arguments]  ${alias}=AT_BASED_UE
    ${require_ue_status}   run keyword and return status   ute_ue.Require Ue    ue_alias=${alias}   capabilities=qualcomm
    run keyword if    ${require_ue_status}==${False}    Restart UE Proxy
    run keyword if    ${require_ue_status}==${False}    log to console   \n@@@@@@ ...com issue apperar....\n
    run keyword if    ${require_ue_status}==${False}    run keyword and ignore error   ute_ue.Detach Ue    ${alias}
    run keyword if    ${require_ue_status}==${False}    sleep   2s
    run keyword if    ${require_ue_status}==${False}    ute_ue.Require Ue    ue_alias=${alias}   capabilities=qualcomm

Attach CPE UE for FR2 SA with retry
    [Documentation]  Author: Wang Yixiang
    ...          Attach again if failed.
    [Arguments]  ${retry_time}=2   ${alias}=AT_BASED_UE   ${require_UE}=${True}
    ${detach_time}    Set variable    ${0}
    FOR    ${i}    IN RANGE    ${retry_time}
        ${attach_status}    run keyword and return status    attach CPE UE for FR2 SA   alias=${alias}   require_UE=${require_UE}
        Exit for loop if    ${attach_status}
        run keyword and ignore error   ute_ue.Release PDU session     ${alias}
        run keyword and ignore error   ute_ue.Detach Ue    ${alias}
        sleep    2s
        ${detach_time}    Evaluate    ${detach_time}+1
        Log to console   \n... UE attached failed, retry detach time ${detach_time} ...
        Exit for loop if    '${detach_time}' == '${retry_time}'
    END
    Should be true    ${detach_time} < ${retry_time}    msg=Retry UE attach with ${retry_time} times and still failed


CPE UE detach
    [Documentation]  Author: Wang Yixiang
    ...    CPE ue detach
    [Arguments]    ${ue_index}=${0}
    run keyword and ignore error    Close the iperf process on APPserver CPE
    run keyword and ignore error    Close the iperf process on APPserver    port=${APPSERVER_PORT}
    run keyword and ignore error    Cpe_operation.stop_ul_data_transfer
    ...   hostname=${UE_PC_IP}
    ...   username=${UE_PC_USERNAME}
    ...   password=${UE_PC_PASSWD}
    ...   port=${APPSERVER_PORT}
    ...   ue_sn=${UE_SN}
    run keyword and ignore error    power_ue.UE detach    ue_type=${UE_TYPE}    ue_index=${ue_index}


Kill At commnad process
    [Documentation]  Author: Wang Yixiang
    ...    Description: Kill at command process if APP start on UE CRTL PC
    ...    At command will lead to automation attach failed
    [Arguments]  ${ue_index}=${0}    ${cpc_alias}=cpc_${ue_index}
    connection_alias_store.Connect to ue control pc    ue_index=${ue_index}    cpc_alias=${cpc_alias}
    ...    cpc_ip=${tl.ues[0].ue_pc_address}
    ...    cpc_username=${tl.ues[0].ue_pc_login}
    ...    cpc_password=${tl.ues[0].ue_pc_password}

    ${is_windows_atCom_exits}    ssh_common_commands.is_process_exist    process_name=ATCom.exe    connection=${cpc_alias}
    ...    is_checking_on_windows=${True}
    ${cmd_kill_atCom_process}    Set variable    taskkill /f /im ATCom.exe
    Run keyword if    ${is_windows_atCom_exits}==${True}
    ...    csn.Execute   command=${cmd_kill_atCom_process}    connection=${cpc_alias}
    ${is_atCom_process_exits_after_kill}    ssh_common_commands.is_process_exist    process_name=ATCom.exe    connection=${cpc_alias}
    ...    is_checking_on_windows=${True}
    Should not be true    ${is_atCom_process_exits_after_kill}

    [Teardown]  Run keyword and ignore error    csn.disconnect   connection=${cpc_alias}

Restart UE Proxy
    [Documentation]  Author: Wang Yixiang
    ...    Description: Kill UE proxy and start again
    ...    python -m taf.ue.proxy.run_ue_proxy
    [Arguments]  ${ue_index}=${0}    ${cpc_alias}=cpc_${ue_index}
    connection_alias_store.Connect to ue control pc    ue_index=${ue_index}    cpc_alias=${cpc_alias}
    ...    cpc_ip=${tl.ues[0].ue_pc_address}
    ...    cpc_username=${tl.ues[0].ue_pc_login}
    ...    cpc_password=${tl.ues[0].ue_pc_password}

    # kill ue proxy on UE CTRL PC if exist
    ${is_windows_proxy_exits}    ssh_common_commands.is_process_exist    process_name=python.exe    connection=${cpc_alias}
    ...    is_checking_on_windows=${True}
    ${cmd_kill_proxy_process}    Set variable    taskkill /f /im python.exe
    Run keyword if    ${is_windows_proxy_exits}==${True}
    ...    csn.Execute   command=${cmd_kill_proxy_process}    connection=${cpc_alias}
    ...    ELSE   Log to console    No need to kill ue proxy on UE CTRL PC as process is not started
    ${is_proxy_process_exits_after_kill}    ssh_common_commands.is_process_exist    process_name=python.exe    connection=${cpc_alias}
    ...    is_checking_on_windows=${True}
    Should not be true    ${is_proxy_process_exits_after_kill}

    # get python install path
    ${python_path_raw}    csn.Execute   command=which python    connection=${cpc_alias}
    ${python_path}    Strip String     ${python_path_raw}

    # kill ue proxy on cygwin is exist
    ${cygwin_process_name}   Set variable    ${python_path}
    ${is_old_cygwin_process_exits}    ssh_common_commands.is_process_exist    process_name=${cygwin_process_name}    connection=${cpc_alias}
    Run keyword if    ${is_old_cygwin_process_exits}==${True}
    ...    csn.Execute   command=ps -ef|grep ${cygwin_process_name}|grep -v grep| awk '{print $2}' |xargs kill -9
    ...    connection=${cpc_alias}
    ${is_old_cygwin_process_exits}    ssh_common_commands.is_process_exist    process_name=${cygwin_process_name}    connection=${cpc_alias}
    Should not be true    ${is_old_cygwin_process_exits}

    # start new ue proxy process on cygwin
    ${cygwin_run_proxy}   Set variable     ${python_path} -m taf.ue.proxy.run_ue_proxy
    csn.send_command   command=${cygwin_run_proxy}    connection=${cpc_alias}
    ${is_new_cygwin_process_exits}    ssh_common_commands.is_process_exist    process_name=${cygwin_process_name}    connection=${cpc_alias}
    Should be true    ${is_new_cygwin_process_exits}
    [Teardown]  Run keyword and ignore error    csn.disconnect   connection=${cpc_alias}

Start UE Proxy if not exist
    [Documentation]  Author: Wang Yixiang
    ...    Description: Start UE Proxy if not exist
    ...    python -m taf.ue.proxy.run_ue_proxy
    [Arguments]  ${ue_index}=${0}    ${cpc_alias}=cpc_${ue_index}
    connection_alias_store.Connect to ue control pc    ue_index=${ue_index}    cpc_alias=${cpc_alias}
    ...    cpc_ip=${tl.ues[0].ue_pc_address}
    ...    cpc_username=${tl.ues[0].ue_pc_login}
    ...    cpc_password=${tl.ues[0].ue_pc_password}

    # check ue proxy on UE CTRL PC if exist
    ${is_windows_proxy_exits}    ssh_common_commands.is_process_exist    process_name=python.exe    connection=${cpc_alias}
    ...    is_checking_on_windows=${True}

    # get python install path
    ${python_path_raw}    csn.Execute   command=which python    connection=${cpc_alias}
    ${python_path}    Strip String     ${python_path_raw}

    # check ue proxy on cygwin is exist
    ${cygwin_process_name}   Set variable    ${python_path}
    ${is_cygwin_process_exits}    ssh_common_commands.is_process_exist    process_name=${cygwin_process_name}    connection=${cpc_alias}

    # start new ue proxy process on cygwin
    run keyword if    ${is_windows_proxy_exits}==${False} and ${is_cygwin_process_exits}==${False}
    ...    Start new UE proxy on cygwin    python_path=${python_path}    cpc_alias=${cpc_alias}
    [Teardown]  Run keyword and ignore error    csn.disconnect   connection=${cpc_alias}

Start new UE proxy on cygwin
    [Documentation]  Author: Wang Yixiang
    ...    Description: Start new UE proxy on cygwin
    ...    python -m taf.ue.proxy.run_ue_proxy
    [Arguments]  ${python_path}    ${cpc_alias}
    ${cygwin_run_proxy}   Set variable     ${python_path} -m taf.ue.proxy.run_ue_proxy
    csn.send_command   command=${cygwin_run_proxy}    connection=${cpc_alias}
    ${is_new_cygwin_process_exits}    ssh_common_commands.is_process_exist    process_name=${python_path}    connection=${cpc_alias}
    Should be true    ${is_new_cygwin_process_exits}

Start both traffic then verify throughput as expect FR2 SA for CPE
    [Documentation]  Author: Fang ludan
    ...              step1: start traffic on DL and UL
    ...              step2: check tput
    ...              ${pcell_nrCellIdentity}:Pcell nrCellIdentity ,such as 608616659
    [Arguments]    ${pcell_nrCellIdentity}    ${exp_ul}=${EXP_UL_COMMON}    ${exp_dl}=${EXP_DL_COMMON}
    ...    ${ul_tput}=${UL_TPUT_COMMON}    ${dl_tput}=${DL_TPUT_COMMON}    ${log_duration}=1m
    ...    ${tput_duration}=120s    ${check_tput_ignore_time}=20s  ${protocol}=udp  ${process_num}=${1}
    ...    ${target_avg_percent}=${PERCENT_AVG}   ${min_percent}=${PERCENT_MIN}   ${dl_length}=1400B
    ...    ${upload_tp}=${False}
    Start both traffic FR2 SA for CPE   ul_tput=${UL_TPUT_COMMON}  dl_tput=${DL_TPUT_COMMON}  dl_length=${dl_length}
    ...  tput_duration=${tput_duration}  protocol=${protocol}  process_num=${process_num}
    verify throughput as expect FR2 SA for CPE  pcell_nrCellIdentity=${pcell_nrCellIdentity}  exp_ul=${exp_ul}
    ...  exp_dl=${exp_dl}    check_tput_ignore_time=${check_tput_ignore_time}   log_duration=${log_duration}
    ...  target_avg_percent=${target_avg_percent}   min_percent=${min_percent}    upload_tp=${upload_tp}

Start both traffic FR2 SA for CPE
    [Documentation]  Author: Fang ludan
    ...              start traffic on DL and UL
    [Arguments]
    ...    ${ul_tput}=${UL_TPUT_COMMON}    ${dl_tput}=${DL_TPUT_COMMON}  ${dl_length}=${dl_length}
    ...    ${tput_duration}=120s     ${protocol}=udp  ${process_num}=${5}
    log to console    \n... Start bi-dir data transmission ...
    Cpe_operation.start_ul_data_transfer
    ...   hostname=${UE_PC_IP}
    ...   username=${UE_PC_USERNAME}
    ...   password=${UE_PC_PASSWD}
    ...   appserver_ip=${APPSERVER_ADDR}
    ...   port=${APPSERVER_PORT}
    ...   ue_sn=${UE_SN}
    ...   duration=${tput_duration}   ul_tput=${ul_tput}   ue_ip=${UE_IP}    protocol=${protocol}

    Start DL traffic via iperf on Appserver    dl_port=${APPSERVER_PORT}    ue_addr=${UE_IP}
    ...                                        dl_time=${tput_duration}   dl_throughput=${dl_tput}
    ...                                        dl_length=${dl_length}   protocol=${protocol}  process_num=${process_num}


verify throughput as expect FR2 SA for CPE
    [Documentation]  Author: Fang ludan
    ...               step1: check tput on DL and UL
    ...              ${pcell_nrCellIdentity}:Pcell nrCellIdentity ,such as 608616659
    [Arguments]    ${pcell_nrCellIdentity}    ${exp_ul}=${EXP_UL_COMMON}    ${exp_dl}=${EXP_DL_COMMON}
    ...    ${check_tput_ignore_time}=10s   ${log_duration}=1m
    ...    ${target_avg_percent}=${PERCENT_AVG}   ${min_percent}=${PERCENT_MIN}
    ...    ${upload_tp}=${False}
    ${log_path}    power_ue_throughput.__Standard Capturing Aasyslog Throughput
    ...            duration=${log_duration}    ignore_time=${check_tput_ignore_time}
    ${list_of_cell_ids}    create list   ${pcell_nrCellIdentity}
    ${throughput_result}    power_ue_throughput.__Standard Check Bi Aasyslog Throughput
    ...                     log=${log_path}    cells=${list_of_cell_ids}
    ...                     ultarget_throughput=${exp_ul}    dltarget_throughput=${exp_dl}
    ...                     actCarrierAggregation=${False}   target_avg_percent=${target_avg_percent}
    ...                     upload_tp=${upload_tp}    min_percent=${min_percent}

Download aasyslog
    [Documentation]     Author: Zhou Charlie
    ...    rename aasyslog with timestamp and collect it to local log path
    [Arguments]    ${local_log_folder}=${TS_CASE_LOG_PATH}    ${aasyslog_name}=aasyslog_message.txt
    ...            ${gnb_index}=0    ${du_index}=0    ${host}=${EMPTY}
    ...            ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ${current_time}    DateTime.Get Current Date    result_format=%Y-%m-%d_%H:%M:%S
    ${local_path}    set variable    ${local_log_folder}/${current_time}_${aasyslog_name}
    Download Aasyslog File From GNB    log_path=/tmp/${aasyslog_name}    local_path=${local_path}
    ...                                gnb_index=${gnb_index}    du_index=${du_index}
    ...                                host=${host}    username=${username}    password=${password}

CPE UE attach and collect tcpdump log
    [Documentation]    Author: Wang Yixiang
    [Arguments]    ${tcpdump_log_name}=basic_l3_call
    ...    ${nr_cell_id}=1   ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    ...    ${ue_type}=${UE_TYPE}    ${prepare_ue_needed}=${False}
    ...    ${attach_check_type}=PROXY_log    ${retry_time}=2
    ...    ${detach_request}=${False}

    Start capture F1AP log    tcpdump_collector_name=${tcpdump_log_name}    options=-i any sctp
    ${attach_result}    run keyword and return status    Retry commercial ue attach if failed
    ...    ue_type=${UE_TYPE}    retry_time=${retry_time}    ue_index=${ue_index}    prepare_ue_needed=${prepare_ue_needed}
    ...    attach_check_type=${attach_check_type}   detach_request=${detach_request}
    ...    cell_id=${nr_cell_id}
    Run Keyword And Continue On Failure    should be true     ${attach_result}==${True}
    set test variable    ${ATTACH_RESULT}    ${attach_result}
    ${ute_log_path_f1ap}    Stop tcpdump log collection    tcpdump_collector_name=${tcpdump_log_name}
    [Return]    ${ute_log_path_f1ap}
    [Teardown]    run keyword and ignore error    Stop Tcpdump via collector    tcpdump_collector_name=${tcpdump_log_name}

UE attach and start traffic and check TPUT
    [Documentation]    Author: Wang Yixiang
    [Arguments]    ${cell_index}     ${dl_tput}=${None}    ${ul_tput}=${None}
    ...    ${exp_ul}=-1    ${exp_dl}=-1    ${tcpdump_log_name}=basic_l3_call
    ...    ${tput_duration}=1800s    ${protocol}=udp    ${process_num}=1   ${appserver_num}=1
    ...    ${direction}=both    ${dl_length}=1400B
    ...    ${target_avg_percent}=0.95    ${min_percent}=0.85
    ...    ${exp_ul_indiv}=${None}    ${exp_dl_indiv}=${None}    ${actCarrierAggregation}=${True}
    ...    ${customized_log_name}=${None}    ${is_need_to_fail_keyword}=${True}
    ...    ${cell_mapping}=${None}    ${connection}=GNB_OAM
    ...    ${log_duration}=60s    ${ignore_time}=30s      ${upload_tp}=${True}

    CPE UE attach and collect tcpdump log    tcpdump_log_name=${tcpdump_log_name}
    Start traffic and verify tput for CPE
    ...    cell_index=${cell_index}     direction=${direction}    dl_tput=${dl_tput}    ul_tput=${ul_tput}
    ...    exp_ul=${exp_ul}    exp_dl=${exp_dl}
    ...    tput_duration=${tput_duration}    protocol=${protocol}    process_num=${process_num}   appserver_num=${appserver_num}
    ...    direction=${direction}    dl_length=${dl_length}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    exp_ul_indiv=${exp_ul_indiv}    exp_dl_indiv=${exp_dl_indiv}    actCarrierAggregation=${actCarrierAggregation}
    ...    connection=${connection}    customized_log_name=${customized_log_name}    is_need_to_fail_keyword=${is_need_to_fail_keyword}
    ...    cell_mapping=${cell_mapping}    log_duration=${log_duration}    ignore_time=${ignore_time}     upload_tp=${upload_tp}

Start traffic and verify tput for CPE
    [Documentation]  Author: Wang Yixiang
    ...              both support non-CA and CA, and support only dl and ul througput check
    [Arguments]    ${cell_index}     ${direction}=both    ${dl_tput}=${None}    ${ul_tput}=${None}
    ...    ${exp_ul}=-1    ${exp_dl}=-1
    ...    ${tput_duration}=1800s    ${protocol}=udp    ${process_num}=1   ${appserver_num}=1
    ...    ${dl_length}=1400B
    ...    ${target_avg_percent}=0.95    ${min_percent}=0.85
    ...    ${exp_ul_indiv}=${None}    ${exp_dl_indiv}=${None}    ${actCarrierAggregation}=${True}    ${connection}=GNB_OAM
    ...    ${customized_log_name}=${None}    ${is_need_to_fail_keyword}=${True}
    ...    ${cell_mapping}=${None}
    ...    ${log_duration}=60s    ${ignore_time}=30s      ${upload_tp}=${True}

    Start data transfer based on direction for CPE   dl_tput=${dl_tput}    ul_tput=${ul_tput}    tput_duration=${tput_duration}
    ...    protocol=${protocol}    process_num=${process_num}    appserver_num=${appserver_num}
    ...    direction=${direction}    dl_length=${dl_length}

    ${tput_log_path}    power_ue_throughput.__Standard Capturing Aasyslog Throughput
    ...            duration=${log_duration}    ignore_time=${ignore_time}
    run keyword and ignore error    check iperf process on appserver
    Check tput for CPE UE    cell_index=${cell_index}     tput_log_path=${tput_log_path}    direction=${direction}
    ...    exp_ul=${exp_ul}    exp_dl=${exp_dl}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    exp_ul_indiv=${exp_ul_indiv}    exp_dl_indiv=${exp_dl_indiv}    actCarrierAggregation=${actCarrierAggregation}
    ...    connection=${connection}   customized_log_name=${customized_log_name}    is_need_to_fail_keyword=${is_need_to_fail_keyword}
    ...    cell_mapping=${cell_mapping}
    ...    log_duration=${log_duration}    ignore_time=${ignore_time}      upload_tp=${upload_tp}

Divid DL throughput by number
    [Documentation]  Author: Wang Yixiang
    [Arguments]    ${dl_tput}=${None}    ${process_num}=1   ${appserver_num}=1
    ${dl_tput_val}    Get Regexp Matches    ${dl_tput}   (\\d+).*    1
    ${dl_tput_process}   evaluate    ${dl_tput_val}[0]/${process_num}
    ${dl_tput_appserver}   evaluate    ${dl_tput_val}[0]/${appserver_num}
    ${dl_tput_val}    set variable if
    ...    '${process_num}'!='1'   ${dl_tput_process}
    ...    '${appserver_num}'!='1'    ${dl_tput_appserver}
    [Return]    ${dl_tput_val}M

Start data transfer based on direction for CPE
    [Documentation]  Author: Wang Yixiang
    ...              Description: Start data transfer based on direction
    ...                           direction: supported values are both, ul, dl
    [Arguments]    ${dl_tput}=${None}    ${ul_tput}=${None}    ${tput_duration}=600s    ${protocol}=udp    ${process_num}=1
    ...    ${direction}=both    ${dl_length}=1400B    ${appserver_num}=1
    log to console    \n... Start data transfer based on direction for CPE ...

    ${dl_tput}    run keyword if   '${process_num}'!='1' or '${appserver_num}'!='1'   Divid DL throughput by number
    ...     dl_tput=${dl_tput}    process_num=${process_num}    appserver_num=${appserver_num}
    ...     ELSE     set variable    ${dl_tput}
    ${APPSERVER_PORT2}   evaluate    ${APPSERVER_PORT} + 1
    Set test variable    ${APPSERVER_PORT2}

    ${direction}=    Convert To Lowercase    ${direction}

    Run keyword if    '${direction}'=='both' and '${appserver_num}'=='1'
    ...        Run keywords      Cpe_operation.start_ul_data_transfer
    ...             hostname=${UE_PC_IP}    username=${UE_PC_USERNAME}
    ...             password=${UE_PC_PASSWD}    appserver_ip=${APPSERVER_ADDR}
    ...             port=${APPSERVER_PORT}    ue_sn=${UE_SN}
    ...             duration=${tput_duration}   ul_tput=${ul_tput}
    ...             ue_ip=${UE_IP}    protocol=${protocol}    AND
    ...        sleep    2s      AND
    ...        Start DL traffic via iperf on Appserver    dl_port=${APPSERVER_PORT}    ue_addr=${UE_IP}
    ...             dl_time=${tput_duration}   dl_throughput=${dl_tput}
    ...             dl_length=${dl_length}   protocol=${protocol}  process_num=${process_num}
    ...    ELSE IF    '${direction}'=='both' and '${appserver_num}'=='2'
    ...        Run keywords      Cpe_operation.start_ul_data_transfer
    ...             hostname=${UE_PC_IP}    username=${UE_PC_USERNAME}
    ...             password=${UE_PC_PASSWD}    appserver_ip=${APPSERVER_ADDR}
    ...             port=${APPSERVER_PORT}    ue_sn=${UE_SN}
    ...             duration=${tput_duration}   ul_tput=${ul_tput}
    ...             ue_ip=${UE_IP}    protocol=${protocol}    AND
    ...        sleep    2s      AND
    ...        Start DL traffic via iperf on Appserver    dl_port=${APPSERVER_PORT}    ue_addr=${UE_IP}
    ...             dl_time=${tput_duration}   dl_throughput=${dl_tput}
    ...             dl_length=${dl_length}   protocol=${protocol}  process_num=${process_num}    AND
    ...        Start DL traffic via iperf on Appserver CPE   dl_port=${APPSERVER_PORT2}    ue_addr=${UE_IP}
    ...             dl_time=${tput_duration}   dl_throughput=${dl_tput}   appserver_addr=${APPSERVER_ADDR2}
    ...             dl_length=${dl_length}   protocol=${protocol}  process_num=${process_num}
    ...    ELSE IF  '${direction}'=='dl' and '${appserver_num}'=='1'
    ...        Start DL traffic via iperf on Appserver    dl_port=${APPSERVER_PORT}    ue_addr=${UE_IP}
    ...             dl_time=${tput_duration}   dl_throughput=${dl_tput}
    ...             dl_length=${dl_length}   protocol=${protocol}  process_num=${process_num}
    ...    ELSE IF  '${direction}'=='dl' and '${appserver_num}'=='2'
    ...        Run keywords      Start DL traffic via iperf on Appserver    dl_port=${APPSERVER_PORT}    ue_addr=${UE_IP}
    ...             dl_time=${tput_duration}   dl_throughput=${dl_tput}
    ...             dl_length=${dl_length}   protocol=${protocol}  process_num=${process_num}   AND
    ...        Start DL traffic via iperf on Appserver CPE   dl_port=${APPSERVER_PORT2}    ue_addr=${UE_IP}
    ...             dl_time=${tput_duration}   dl_throughput=${dl_tput}   appserver_addr=${APPSERVER_ADDR2}
    ...             dl_length=${dl_length}   protocol=${protocol}  process_num=${process_num}
    ...    ELSE IF  '${direction}'=='ul'
    ...        Cpe_operation.start_ul_data_transfer
    ...             hostname=${UE_PC_IP}    username=${UE_PC_USERNAME}
    ...             password=${UE_PC_PASSWD}    appserver_ip=${APPSERVER_ADDR}
    ...             port=${APPSERVER_PORT}    ue_sn=${UE_SN}
    ...             duration=${tput_duration}   ul_tput=${ul_tput}
    ...             ue_ip=${UE_IP}    protocol=${protocol}
    ...    ELSE    Should be true    ${False}    msg=Invalid input for direction, supported values are: both, ul, dl

Connect to APPserver CPE
    [Documentation]    Author: Wang Yixiang
    [Arguments]    ${appserver_addr}=${APPSERVER_ADDR2}   ${appserver_username}=${APPSERVER_USERNAME}
    ...   ${appserver_password}=${APPSERVER_PASSWORD}   ${alias}=APPserver
    csn.Connect to    hostname=${appserver_addr}
    ...               username=${appserver_username}
    ...               password=${appserver_password}
    ...               alias=${alias}

Close the iperf process on APPserver CPE
    [Arguments]    ${appserver_addr}=${APPSERVER_ADDR2}   ${appserver_username}=${APPSERVER_USERNAME}
    ...   ${appserver_password}=${APPSERVER_PASSWORD}   ${port}=${APPSERVER_PORT2}    ${appserver}=APPserver
    run keyword if    '${appserver}'=='APPserver'
    ...    wait until keyword succeeds    1 min    10 sec    Connect to APPserver CPE
    ...    appserver_addr=${appserver_addr}   appserver_username=${appserver_username}    appserver_password=${appserver_password}
    ...    ELSE IF    '${appserver}'=='APPserversim'
    ...    wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to APPserversim
#     wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to APPserver
    run keyword and ignore error    csn.execute    command=ps -ef|grep iperf|grep -v grep    connection=APPserver
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${port}| awk '{print $2}' |xargs kill -9    connection=APPserver
    [Teardown]    csn.disconnect    connection=APPserver


Start DL traffic via iperf on Appserver CPE
    [Documentation]  Wang Yixiang
    [Arguments]     ${ue_addr}    ${dl_time}    ${dl_port}    ${dl_throughput}    ${dl_length}
    ...    ${appserver_addr}=${APPSERVER_ADDR}   ${appserver_username}=${APPSERVER_USERNAME}    ${appserver_password}=${APPSERVER_PASSWORD}
    ...    ${appserver}=APPserver    ${protocol}=udp    ${ue_index}=${0}    ${process_num}=${5}
    ...    ${seg_size}=${1180}    ${window}=2M
    run keyword if    '${appserver}'=='APPserver'
    ...    wait until keyword succeeds    1 min    10 sec    Connect to APPserver CPE
    ...    appserver_addr=${appserver_addr}   appserver_username=${appserver_username}    appserver_password=${appserver_password}
    ...    ELSE IF    '${appserver}'=='APPserversim'
    ...    wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to APPserversim
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${dl_port}| awk '{print $2}'    connection=APPserver
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${dl_port}| awk '{print $2}' |xargs kill -9    connection=APPserver
    run keyword if    '${protocol}'=='udp'    csn.send command
    ...    command=iperf -c ${ue_addr} -u -t ${dl_time} -i 1 -p ${dl_port} -P ${process_num} -f m -b ${dl_throughput} -l ${dl_length} -T 64 &
    ...    connection=APPserver
    ...    ELSE IF    '${protocol}'=='tcp'    Start the tcp DL data via iperf    ue_index=${ue_index}
    ...    dl_time=${dl_time}    ue_addr=${ue_addr}    dl_port=${dl_port}    process_num=${process_num}    seg_size=${seg_size}
    ...    window=${window}
    sleep    3s
    Check the iperf progress exist    connection=APPserver    port=${dl_port}
    [Teardown]    csn.disconnect    connection=APPserver

Check tput for CPE UE
    [Documentation]    Author: Wang Yixiang
    ...   use TPUT check keyword of power ue, and it will draw a tput picture
    ...   :param cell_index: global cell id, can be 1 or 1,2
    ...   :param tput_log_path: log path of aasyslog throughput file.
    ...                Suggest to use the path Power_ue.Collect Aasyslog Throughput Return
    ...   :param direction: supported values are: both, ul, dl
    ...   :param exp_ul/exp_dl: expected tput of UL/DL, Can only be single value.
    ...        If actCarrierAggregation=True, it's the expected UL tput for all cells
    ...        If actCarrierAggregation=False, then each cell should reach with this expected tput
    ...   :param exp_ul_indiv/exp_dl_indiv: only valid when actCarrierAggregation is set to ${True}.
    ...        If not to check for individual cells, then remain it as ${None}
    ...        If check, then input tput should be set for each cell. like: 90,100
    ...    Notes for input expected tput:
    ...       -1: Means not to check tput
    ...        0: Means tput should < 2M
    ...       Negative value: Means tput should < exp_value
    ...       Positive value: Means tput should >= exp_value
    ...   :param actCarrierAggregation: actCarrierAggregation is ${True} or ${False}.
    ...   :param connection: SSL connection alias, pls create the connection before use the keyword
    ...   :param cell_mapping: If cell_mapping has value, then use it directly, otherwise will re-get from GNB based on provided connection
    ...   :param target_avg_percent: allowed avraget percentage. E.G 0.95 or 95%
    ...                              Check_result > target_throughput * target_avg_percent
    ...   :param customized_log_name: For generated tput image file name
    ...   e.g: Check tput for CPE UE    cell_index=1,2    tput_log_path=${tput_log}   direction=both    exp_ul=50    exp_dl=100
    ...            actCarrierAggregation=${False}
    ...        -- Check each cell should reach the expected same ul/dl tput value
    ...        Check tput for CPE UE    cell_index=1,2    tput_log_path=${tput_log}   direction=both    exp_ul=100    exp_dl=100
    ...            actCarrierAggregation=${True}
    ...        -- Check CA total tput should reach the expected value
    ...        Check tput for CPE UE    cell_index=1,2    tput_log_path=${tput_log}   direction=both    exp_ul=130    exp_dl=1200
    ...            exp_ul_indiv=0,130    exp_dl_indiv=800,1400    actCarrierAggregation=${True}
    ...        -- Check CA total tput should reach the expected value and aslo each cell should reach the expected value
    [Arguments]     ${cell_index}     ${tput_log_path}    ${direction}    ${exp_ul}=-1    ${exp_dl}=-1
    ...    ${target_avg_percent}=0.95    ${min_percent}=0.85
    ...    ${exp_ul_indiv}=${None}    ${exp_dl_indiv}=${None}    ${actCarrierAggregation}=${True}    ${connection}=GNB_OAM
    ...    ${customized_log_name}=${None}    ${is_need_to_fail_keyword}=${True}
    ...    ${cell_mapping}=${None}
    ...    ${log_duration}=60s    ${ignore_time}=30s      ${upload_tp}=${True}
    log to console    \n... Check througput ...
    ${direction}    Convert to lower case    ${direction}
    ${list_cell_index}    string2list    ${cell_index}
    @{list_nrCellIdentity}    _Get nrCellIdentity based on cell idx    list_cell_index=${list_cell_index}    connection=${connection}
    ...    cell_mapping=${cell_mapping}

    ${exp_ul}    _Convert expected tput value for checking    exp_tput_value=${exp_ul}
    ${exp_dl}    _Convert expected tput value for checking    exp_tput_value=${exp_dl}
    Run keyword if    '${direction}'!='ul' and '${exp_dl}'=='${None}'
    ...    Fail    msg=Invalid input. exp_dl should not be none if direction is dl or both
    ...    ELSE IF    '${direction}'!='dl' and '${exp_ul}'=='${None}'
    ...    Fail    msg=Invalid input. exp_ul should not be none if direction is ul or both

    ${list_exp_ul}    Run keyword if    ${exp_ul_indiv}    string2list    ${exp_ul_indiv}
    ...    ELSE    Set variable    ${None}
    ${list_exp_dl}    Run keyword if    ${exp_dl_indiv}    string2list    ${exp_dl_indiv}
    ...    ELSE    Set variable    ${None}
    &{dict_exp_indv_tput_ul}    Run keyword if    ${exp_ul_indiv}
    ...    _Get individual expected tput value for cells    list_nrCellIdentity=${list_nrCellIdentity}     list_exp_tput=${list_exp_ul}
    ...    ELSE    Set variable    ${None}
    &{dict_exp_indv_tput_dl}    Run keyword if    ${exp_dl_indiv}
    ...    _Get individual expected tput value for cells    list_nrCellIdentity=${list_nrCellIdentity}     list_exp_tput=${list_exp_dl}
    ...    ELSE    Set variable    ${None}

    ${Check_tput_result}    Run keyword and return status    Run keyword if    '${direction}'=='both'    Run keywords
    ...    Run keyword and continue on failure   power_ue_throughput.__Standard Check Aasyslog Throughput
    ...        direction=ul    log=${tput_log_path}
    ...        cells=${list_nrCellIdentity}   target_throughput=${exp_ul}     target_avg_percent=${target_avg_percent}   min_percent=${min_percent}
    ...        actCarrierAggregation=${actCarrierAggregation}    customized_log_name=${customized_log_name}
    ...        cell_indiv_tput=${dict_exp_indv_tput_ul}    AND
    ...    Run keyword and continue on failure   power_ue_throughput.__Standard Check Aasyslog Throughput
    ...        direction=dl    log=${tput_log_path}
    ...        cells=${list_nrCellIdentity}    target_throughput=${exp_dl}     target_avg_percent=${target_avg_percent}   min_percent=${min_percent}
    ...        actCarrierAggregation=${actCarrierAggregation}    customized_log_name=${customized_log_name}
    ...        cell_indiv_tput=${dict_exp_indv_tput_dl}
    ...    ELSE IF    '${direction}'=='ul'    power_ue_throughput.__Standard Check Aasyslog Throughput
    ...        direction=ul    log=${tput_log_path}
    ...        cells=${list_nrCellIdentity}    target_throughput=${exp_ul}     target_avg_percent=${target_avg_percent}   min_percent=${min_percent}
    ...        actCarrierAggregation=${actCarrierAggregation}    customized_log_name=${customized_log_name}
    ...        cell_indiv_tput=${dict_exp_indv_tput_ul}
    ...    ELSE IF    '${direction}'=='dl'    power_ue_throughput.__Standard Check Aasyslog Throughput
    ...        direction=dl    log=${tput_log_path}
    ...        cells=${list_nrCellIdentity}    target_throughput=${exp_dl}     target_avg_percent=${target_avg_percent}   min_percent=${min_percent}
    ...        actCarrierAggregation=${actCarrierAggregation}    customized_log_name=${customized_log_name}
    ...        cell_indiv_tput=${dict_exp_indv_tput_dl}
    ...    ELSE    Fail    msg=Invalid input for direction, supported values are: both, ul, dl
    Run keyword if    '${is_need_to_fail_keyword}'=='True' and ${Check_tput_result}==${False}    Fail    msg=Validation failed for tput checking

_Get nrCellIdentity based on cell idx
    [Documentation]  Author: Wang Yixiang
    ...    :param ${list_cell_index}: should be in list format
    ...    If cell_mapping has value, then use it directly, otherwise will re-get from GNB based on provided connection
    ...    Return the nrCellIdentity value as a list based on cell index
    [Arguments]    ${list_cell_index}    ${connection}=GNB_OAM    ${cell_mapping}=${None}
    @{list_nrCellIdentity}    Create List
    &{cell_mapping}    Run keyword if    ${cell_mapping}    Set variable    ${cell_mapping}
    ...    ELSE    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids    connection_alias=${connection}

    ${lcrId_list}   Get Dictionary Keys    dictionary=${cell_mapping}
    FOR    ${cell_index}    IN    @{lcrId_list}
        ${nrCellIdentity}    Evaluate    str(${cell_mapping[${cell_index}]['nrCellIdentity']})
        Append to list    ${list_nrCellIdentity}    ${nrCellIdentity}
    END
    [Return]  ${list_nrCellIdentity}
