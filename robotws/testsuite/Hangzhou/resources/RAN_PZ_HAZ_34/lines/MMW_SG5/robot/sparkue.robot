*** Settings ***
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/sigspark_yiyuan_multiUE.py
Library     sigspark_yiyuan_multiUE.SigSparkMutiUE    WITH NAME    sparkMultiUE_yiyuan
Library     ../python/sparkue.py


Documentation
...    author: Liqin Yang
...    contact: liqin.yang@nokia-sbell.com
...    Group: HGZ_SG5

*** Variables ***
@{case_row_list}              NR PDCP Thr. DL [Mbps]    NR PDCP Thr. UL [Mbps]    NR PDSCH iBLER[%]    NR PUSCH iBLER[%]
${total_count}                ${180}


*** Keywords ***
Prepare SparkUE And Attach
    [Arguments]    ${multiue_config_direction}    ${ue_alias}=spark_UE    ${restart_ue}=${False}    ${restart_network}=${False}
    ...  ${max_ue_num}=${8}  ${if_ul}=${UL_Enable}
    log to console      "Prepare UE"
    sparkMultiUE_yiyuan.require_ue    ue_alias=${ue_alias}    multiue_traffic_config=${multiue_config_direction}
    ...    get_spark_license=${False}    restart_ue=${restart_ue}    restart_network=${restart_network}     max_ue_num=${max_ue_num}
    ...    is_need_reconnect_spark=${False}
    Run Keyword And Ignore Error  MultiUE Stop UDP Traffic  if_ul=${True}    if_dl=${True}
    log to console      "UE Attach"
    Wait Until Keyword Succeeds  3x  10s  Attach for mapping IP  max_ue_num=${max_ue_num}  if_ul=${if_ul}

Attach for mapping IP
    [Arguments]  ${ue_alias}=spark_UE  ${max_ue_num}=${8}  ${if_ul}=${UL_Enable}
    Run Keyword And Ignore Error  sparkue.MultiUE Detach
    sparkMultiUE_yiyuan.attach_ue    ue_alias=${ue_alias}
    Run Keyword If  ${if_ul}  Wait Until Keyword Succeeds  3min  10s  Check Ue Status Normal  numberOfUe=${max_ue_num}
    ...  ELSE  Wait Until Keyword Succeeds  3x  5s  Judge to get UE IP

Capture Spark TP Log
    [Arguments]  ${logpath}=${TS_CASE_LOG_PATH}  ${log_time}=3min    ${filter}=test    ${ue_alias}=spark_UE
    sparkMultiUE_yiyuan.start_log    ue_alias=${ue_alias}
    sleep   ${log_time}
    sparkMultiUE_yiyuan.stop_log    ue_alias=${ue_alias}
    ${ue_dic}  sparkMultiUE_yiyuan.export_log_file    ue_alias=${ue_alias}     logpath=${logpath}    filter=${filter}
    [Return]  ${ue_dic}


Get Each UE TP From Spark
    [Arguments]  ${ue_list}  ${ue_dic}  ${list_length}=${total_count}    ${row_list}=${case_row_list}
    @{dl_tput_info}    Create list
    @{ul_tput_info}    Create list
    @{dl_bler_info}    Create list
    @{ul_bler_info}    Create list
    @{total_result_list}    Create List
    FOR    ${ue_index}    IN  @{ue_list}
        ${id}  Get From Dictionary  ${ue_dic}  ${ue_index}
        ${result_dic}    Get_UE_TP_Bler_From_spark_log    file_path=${TS_CASE_LOG_PATH}/UE-${id}.csv
        ...    list_length=${list_length}    row_list=${row_list}
        ${DL_bler}    get from dictionary  ${result_dic}    DL_bler
        ${UL_bler}    get from dictionary  ${result_dic}    UL_bler
        ${DL_tp}    get from dictionary  ${result_dic}    DL_tp
        ${UL_tp}    get from dictionary  ${result_dic}    UL_tp
        APPEND TO LIST   ${dl_tput_info}    ${DL_tp}[0]
        APPEND TO LIST   ${ul_tput_info}    ${UL_tp}[0]
        APPEND TO LIST   ${dl_bler_info}    ${DL_bler}[0]
        APPEND TO LIST   ${ul_bler_info}    ${UL_bler}[0]
        append to list   ${total_result_list}   ${result_dic}
    END
    [Return]    ${ul_tput_info}    ${dl_tput_info}   ${ul_bler_info}    ${dl_bler_info}    ${total_result_list}

Check Each UE TP
  [Arguments]   ${ue_list}  ${if_ul}=${UL_Enable}  ${if_dl}=${DL_Enable}  ${ul_bler}=${10}  ${dl_bler}=${10}  ${ul_tp}=${1}  ${dl_tp}=${5}
    Log To Console  Check Each UE TP
    ${ue_dic}  Capture Spark TP Log
    ${spark_result}    Get Each UE TP From Spark    ue_dic=${ue_dic}  ue_list=${ue_list}
    ${status}    Check_Mulite_UE_TP_And_Bler    if_ul=${if_ul}    if_dl=${if_dl}
    ...    actual_value=@{spark_result[-1]}    expect_ul_bler=${ul_bler}    expect_dl_bler=${dl_bler}
    ...    expect_ul_tp=${ul_tp}    expect_dl_tp=${dl_tp}
    Run Keyword And Continue On Failure    should be equal    ${status}    ${True}
    [Return]  ${spark_result}

MultiUE Detach
    [Arguments]  ${ue_alias}=spark_UE
    log to console      "UE Detach"
    Run keyword and ignore error    sparkMultiUE_yiyuan.detach_ue    ue_alias=${ue_alias}
    Run keyword and ignore error    sparkMultiUE_yiyuan.detach_ue    ue_alias=${ue_alias}

MultiUE Stop UDP Traffic
    [Arguments]    ${if_ul}=${True}    ${if_dl}=${True}    ${ue_alias}=spark_UE
    log to console      "UE Stop UL Traffic"
    run keyword if    ${if_ul}==${True}    csn.send command    command=taskkill /fi "imagename eq iperf.exe" /F    connection=sigspark
    run keyword if    ${if_ul}==${True}    csn.send command    command=taskkill /fi "imagename eq iperf3.exe" /F    connection=sigspark
    log to console      "UE Stop DL Traffic"
    run keyword if    ${if_dl}==${True}    sparkMultiUE_yiyuan.stop_data_transfer    ue_alias=${ue_alias}    direction=dl

MultiUE Start UDP UL Traffic
    [Arguments]    ${ul_tp_list}    ${ue_index_list}    ${ue_ip_dict}    ${ul_port_list}    ${ul_duration}
    csn.send command    command=taskkill /fi "imagename eq iperf.exe" /F    connection=sigspark
    sleep    2s
    ${start_call_num}    Set Variable    ${-1}
    FOR  ${ue_index}  IN  @{ue_index_list}
        ${start_call_num}    Evaluate    ${start_call_num}+${1}
        ${UE_ip}    get from dictionary    ${ue_ip_dict}     ${ue_index}
        ${command_str}    Catenate
        ...  iperf.exe -c ${appserver_addr} -t ${ul_duration} -P 1 -p ${ul_port_list[${ue_index}]} -i 1 -l 1350
        ...  -b ${ul_tp_list[${ue_index}]}M -u -B ${UE_ip}&
        csn.send command     command=${command_str}    connection=sigspark
        log to console    ${command_str}
        sleep   2s
        log to console    UE_${ue_index} start UL UDP
    END

MultiUE Start UDP Traffic
    [Arguments]    ${ul_tp_list}=None    ${ul_port_list}=${ul_power_port_list}    ${if_ul}=${True}    ${if_dl}=${True}    ${process}=${4}
    ...    ${buffer}=1400    ${ul_duration}=4200    ${ue_alias}=spark_UE
    ${ue_ip_dict}    sparkMultiUE_yiyuan.get_ue_ip    ue_alias=${ue_alias}
    log to console    ${ue_ip_dict}
    ${ue_index_list}    get dictionary keys    ${ue_ip_dict}
    run keyword if    ${if_ul}==${True}    MultiUE Start UDP UL Traffic    ul_tp_list=${ul_tp_list}
    ...    ue_index_list=${ue_index_list}
    ...    ue_ip_dict=${ue_ip_dict}    ul_port_list=${ul_port_list}    ul_duration=${ul_duration}
    sleep   2s
    run keyword if    ${if_dl}==${True}    log to console      "UE Start DL Traffic"
    run keyword if    ${if_dl}==${True}    sparkMultiUE_yiyuan.start_data_transfer    ue_alias=${ue_alias}    direction=dl    process=${process}
    ...    buffer=${buffer}
    [Return]    ${ue_ip_dict}

ReadOut PID
    [Arguments]    ${ue_index}
    log to console    Read PID
    csn.send command    command=tasklist /fi "imagename eq iperf.exe"    connection=sigspark
    ${pid}    wait until keyword succeeds    10s    2s    csn.Read Output    connection=sigspark
    ${pid}    Strip String    string=${pid}
    ${pid}    Split String    string=${pid}    separator=\r\n
    ${str_len}    get length    ${pid}
    ${pid_len}    Evaluate      ${ue_index} + ${3}
#    Should Be True  ${str_len} == ${pid_len}
    Run keyword and ignore error    Should Be True  ${str_len} >= ${3}
    log to console    ${pid}

Start UDP Commond And ReadOut PID
    [Arguments]  ${command_str}    ${ue_index}
    csn.send command     command=${command_str}    connection=sigspark
    log to console    start command success
    wait until keyword succeeds    40s    8s    ReadOut PID    ue_index=${ue_index}

Start Iperf Listen On Spark
  [Arguments]    ${ue_index_list}    ${ue_ip_dict}  ${ue_config}=${TLCommonConfig["MultiUECFG"]}
  ...  ${server_path}=${tl.ues[0].server_dir}
  ${iperf_path}  ${other}  Split String From Right  ${server_path}  separator=/  max_split=1
    FOR  ${ue_index}  IN  @{ue_index_list}
        ${UE_ip}    get from dictionary    ${ue_ip_dict}     ${ue_index}
        ${iperf_port}  Set Variable  ${ue_config['${ue_index}']['iperf_port']}
        ${command_str}    Catenate
        ...  iperf -s -p ${iperf_port} -i 1 -u -B ${UE_ip}&
        csn.send command     command=${command_str}    connection=sigspark
        log to console    ${command_str}
        sleep   2s
        log to console    UE_${ue_index} Start Iperf Listen On Spark for DL traffic
    END

Stop Iperf Listen On Spark
  [Arguments]    ${ue_index_list}    ${ue_ip_dict}  ${ue_config}=${TLCommonConfig["MultiUECFG"]}
  ...  ${server_path}=${tl.ues[0].server_dir}
  ${iperf_path}  ${other}  Split String From Right  ${server_path}  separator=/  max_split=1
    FOR  ${ue_index}  IN  @{ue_index_list}
        ${UE_ip}    get from dictionary    ${ue_ip_dict}     ${ue_index}
        ${iperf_port}  Set Variable  ${ue_config['${ue_index}']['iperf_port']}
        ${command_str}    Catenate
        ...  ps aux |grep iperf |grep ${UE_ip}|grep ${iperf_port} |awk '{print $2}' | xargs kill -9
        csn.send command     command=${command_str}    connection=sigspark
        log to console    ${command_str}
        sleep   2s
        log to console    UE_${ue_index} Stop Iperf Listen On Spark for DL traffic
    END


Start Iperf Listen On Appserver
  [Arguments]  ${ue_index_list}    ${ul_port_list}
    ...    ${hostname}=${tl.ues[0].iperf_details.ssh_connection_details.addr}
    ...    ${username}=${tl.ues[0].iperf_details.ssh_connection_details.username}
    ...    ${password}=${tl.ues[0].iperf_details.ssh_connection_details.password}
    ...    ${alias}=APPserver
  Wait Until Keyword Succeeds    1 min    10 sec    csn.Connect to
    ...    hostname=${hostname}
    ...    username=${username}
    ...    password=${password}
    ...    alias=${alias}
  FOR  ${ue_index}  IN  @{ue_index_list}
      ${command_str}  Catenate
      ...  iperf -s -p ${ul_port_list[${ue_index}]} -i 1 -u&
      csn.send command  command=${command_str}  connection=${alias}
        sleep   2s
        log to console    UE_${ue_index} Start Iperf Listen On Appserver for UL traffic
  END
  csn.Disconnect   connection=${alias}

Stop Iperf Listen On Appserver
  [Arguments]  ${ue_index_list}    ${ul_port_list}
    ...    ${hostname}=${tl.ues[0].iperf_details.ssh_connection_details.addr}
    ...    ${username}=${tl.ues[0].iperf_details.ssh_connection_details.username}
    ...    ${password}=${tl.ues[0].iperf_details.ssh_connection_details.password}
    ...    ${alias}=APPserver
  Wait Until Keyword Succeeds    1 min    10 sec    csn.Connect to
    ...    hostname=${hostname}
    ...    username=${username}
    ...    password=${password}
    ...    alias=${alias}
  FOR  ${ue_index}  IN  @{ue_index_list}
      ${command_str}  Catenate
      ...  ps aux |grep iperf |grep ${ul_port_list[${ue_index}]} |awk '{print $2}' | xargs kill -9
      csn.send command  command=${command_str}  connection=${alias}
        sleep   2s
        log to console    UE_${ue_index} Stop Iperf Listen On Appserver for UL traffic
  END
  csn.Disconnect   connection=${alias}

Check Ue Status Normal
    [Documentation]    check UE status if it's normal, namely attach successfully.
    [Arguments]    ${cpc_ip}=${tl.ues[0].ssh_connection_details.addr}
    ...    ${cpc_usrname}=${tl.ues[0].ssh_connection_details.username}
    ...    ${cpc_passwd}=${tl.ues[0].ssh_connection_details.password}
    ...    ${local_path}=${TS_CASE_LOG_PATH}/ipconfig.txt
    ...    ${numberOfUe}=8
    Log to console    \n*****Check UE status is normal*****
    Connect to control pc enhanced    cpc_ip=${cpc_ip}
    ...    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
    ${ue_ips}    ${unattach_list}  Get UE Infor From Control PC  local_path=${local_path}
    ${ue_ips_keys}    Get Dictionary Keys    ${ue_ips}
    ${ip_num}    Get Length    ${ue_ips_keys}
    Set Test Variable  ${unattach_list}
    Log To Console  unattach UE:${unattach_list}
    Should Be Equal As Integers    ${numberOfUe}    ${ip_num}

Get UE Infor From Control PC
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    special to get ue ips from cmd ipconfig
    [Arguments]    ${cpc_ip}=${tl.ues[0].ssh_connection_details.addr}
    ...    ${cpc_usrname}=${tl.ues[0].ssh_connection_details.username}
    ...    ${cpc_passwd}=${tl.ues[0].ssh_connection_details.password}
    ...    ${local_path}=/home/ute/MMW_SG5/ipconfig.txt
    Connect to control pc enhanced    cpc_ip=${cpc_ip}
    ...    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
    csn.send_command    command=ipconfig > ipconfig.txt   connection=cpc_0
    Sleep    3s
    csn.download_file    remote_path=ipconfig.txt
    ...                  local_path=${local_path}
    ...                  connection=cpc_0
    ${ue_ips}    ${unattach_list}  get_ue_infor_from_ipconfig    ${local_path}
    [Return]    ${ue_ips}  ${unattach_list}

Judge to get UE IP
    [Arguments]  ${ue_alias}=spark_UE
    ${ue_ip_dict}    sparkMultiUE_yiyuan.get_ue_ip    ue_alias=${ue_alias}
    log to console    ${ue_ip_dict}
    ${ue_index_list}    get dictionary keys    ${ue_ip_dict}
    ${reattach}  Set Variable  False
    FOR  ${ue_index}  IN  @{ue_index_list}
      ${UE_ip}    get from dictionary    ${ue_ip_dict}     ${ue_index}
      Should Start With  ${UE_ip}  10.108.251
    END
