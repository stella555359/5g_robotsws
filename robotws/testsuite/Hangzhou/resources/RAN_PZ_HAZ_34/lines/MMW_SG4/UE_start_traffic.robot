*** Settings ***
Documentation    author：Hongyu Jiang
...              contact: hongyu.jiang@nokia-sbell.com
...              squad group: mmw_SG_04

Library     OperatingSystem
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/sigspark_yiyuan_multiUE.py
Library     sigspark_yiyuan_multiUE.SigSparkMutiUE    WITH NAME    sparkMultiUE_yiyuan
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot
Library     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001937_OTA/resources/samsung_sigspark.py
Library     samsung_sigspark.SigSpark    WITH NAME    samsung_spark
Library     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010706/Resources/CB010706_common_keywords.py


*** Keywords ***
############# Module UE Start Traffic ###################
Start Traffic By Spark
    [Arguments]    ${multiue_config_direction}    ${ul_port_list}    ${get_spark_license}    ${ul_tp_list}=None    ${if_ul}=${True}
    ...    ${if_dl}=${True}    ${duration}=10    ${process}=${1}
    Prepare MultiUE And Attach    multiue_config_direction=${multiue_config_direction}    get_spark_license=${get_spark_license}
    MultiUE Start UDP Traffic    ul_port_list=${ul_port_list}   ul_tp_list=${ul_tp_list}    if_ul=${if_ul}    if_dl=${if_dl}
    ...    process=${process}    ul_duration=${duration}
    sleep    20s

Prepare MultiUE And Attach
    [Timeout]    12min
    [Arguments]    ${multiue_config_direction}    ${ue_alias}=spark_UE    ${restart_ue}=${False}    ${restart_network}=${False}
    ...    ${get_spark_license}=${False}
    log to console      "Prepare UE"
    sparkMultiUE_yiyuan.require_ue    ue_alias=${ue_alias}    multiue_traffic_config=${multiue_config_direction}
    ...    get_spark_license=${get_spark_license}    restart_ue=${restart_ue}    restart_network=${restart_network}
    log to console      "UE Attach"
    sparkMultiUE_yiyuan.attach_ue    ue_alias=${ue_alias}

MultiUE Start UDP Traffic
    [Arguments]    ${ul_port_list}   ${ul_tp_list}=None    ${if_ul}=${True}    ${if_dl}=${True}    ${process}=${1}
    ...    ${ul_duration}=10    ${ue_alias}=spark_UE
    ${ue_ip_dict}    wait until keyword succeeds    10x    30s    Get All UE IP    ue_alias=${ue_alias}
    log to console    ${ue_ip_dict}
    ${ue_index_list}    get dictionary keys    ${ue_ip_dict}
    run keyword if    ${if_ul}==${True}    MultiUE Start UDP UL Traffic    ul_tp_list=${ul_tp_list}    ue_index_list=${ue_index_list}
    ...    ue_ip_dict=${ue_ip_dict}    ul_port_list=${ul_port_list}    ul_duration=${ul_duration}
    sleep   2s
    run keyword if    ${if_dl}==${True}    log to console      "UE Start DL Traffic"
    run keyword if    ${if_dl}==${True}    sparkMultiUE_yiyuan.start_data_transfer    ue_alias=${ue_alias}    direction=dl    process=${process}
    [Return]    ${ue_ip_dict}

MultiUE Start UDP UL Traffic
    [Arguments]    ${ul_tp_list}    ${ue_index_list}    ${ue_ip_dict}    ${ul_port_list}    ${ul_duration}
    csn.send command    command=taskkill /fi "imagename eq iperf.exe" /F    connection=sigspark
    csn.send command    command=taskkill /fi "imagename eq iperf3.exe" /F    connection=sigspark
    ${start_call_num}    Set Variable    ${-1}
    FOR  ${ue_index}  IN  @{ue_index_list}
        ${start_call_num}    Evaluate    ${start_call_num}+${1}
        ${UE_ip}    get from dictionary    ${ue_ip_dict}     ${ue_index}
        ${command_str}    Catenate
        ...    /Bin/iperf -c ${appserver_addr} -u -p ${ul_port_list[${ue_index}]}
        ...    -l 1350B -f k -b ${ul_tp_list[${ue_index}]}M -t ${ul_duration} -i 1 -P 1 -B ${UE_ip}
        sleep   10s
        wait until keyword succeeds    2x    60s    Start UDP Commond And ReadOut PID    command_str=${command_str}    ue_index=${start_call_num}
        log to console    UE_${ue_index} start UL UDP
    END

Get All UE IP
    [Arguments]    ${ue_alias}
    ${ue_ip_dict}    sparkMultiUE_yiyuan.get_ue_ip    ue_alias=${ue_alias}
    ${ue_index}    Get Dictionary Keys    ${ue_ip_dict}
    FOR   ${index}  IN  @{ue_index}
        ${ue_ip}    Get From Dictionary    ${ue_ip_dict}    ${index}
        Run Keyword And Continue On Failure    Should Be True    '${ue_ip}' != ''
    END
    [Return]    ${ue_ip_dict}

ReadOut PID
    [Arguments]    ${ue_index}
    csn.send command    command=tasklist /fi "imagename eq iperf.exe"    connection=sigspark
    ${pid}    wait until keyword succeeds    10s    2s    csn.Read Output    connection=sigspark
    ${pid}    Strip String    string=${pid}
    ${pid}    Split String    string=${pid}    separator=\r\n
    ${str_len}    get length    ${pid}
    ${pid_len}    Evaluate      ${ue_index} + ${3}
    Should Be True  ${str_len} >= ${pid_len}
    log to console    ${pid}

Start UDP Commond And ReadOut PID
    [Arguments]  ${command_str}    ${ue_index}
    csn.send command     command=${command_str}    connection=sigspark
    log to console    start command success
    wait until keyword succeeds    40s    10s    ReadOut PID    ue_index=${ue_index}

Stop Traffic And Detach UE
    [Arguments]  ${if_ul}=${True}    ${if_dl}=${True}
    MultiUE Stop UDP Traffic    if_ul=${if_ul}    if_dl=${if_dl}
    MultiUE Detach

MultiUE Stop UDP Traffic
    [Arguments]    ${if_ul}=${True}    ${if_dl}=${True}    ${ue_alias}=spark_UE
    log to console      "UE Stop UL Traffic"
    run keyword if    ${if_ul}==${True}    csn.send command    command=taskkill /fi "imagename eq iperf.exe" /F    connection=sigspark
    run keyword if    ${if_ul}==${True}    csn.send command    command=taskkill /fi "imagename eq iperf3.exe" /F    connection=sigspark
    log to console      "UE Stop DL Traffic"
    run keyword if    ${if_dl}==${True}    sparkMultiUE_yiyuan.stop_data_transfer    ue_alias=${ue_alias}    direction=dl

MultiUE Detach
    [Arguments]  ${ue_alias}=spark_UE
    log to console      "UE Detach"
    sparkMultiUE_yiyuan.detach_ue    ue_alias=${ue_alias}

Check TP From Aasyslog
    [Arguments]    ${log_time}    ${ul_list}    ${dl_list}    ${exp_ul_tp}    ${exp_dl_tp}
    ...    ${target_avg_percent}    ${min_percent}   ${if_ul}=${True}    ${if_dl}=${True}
    ${log_path}    power_ue.Collect Tput   ue_type=samsung    duration=${log_time}    ignore_time=10s
    run keyword and continue on failure    run keyword if    ${if_ul}==${True}    power_ue.Check Tput    ue_type=samsung
    ...    direction=UL    log=${log_path}    cells=${ul_list}    target_throughput=${exp_ul_tp}    target_avg_percent=${target_avg_percent}
    ...    actCarrierAggregation=${True}    min_percent=${min_percent}
    run keyword and continue on failure    run keyword if    ${if_dl}==${True}    power_ue.Check Tput    ue_type=samsung
    ...    direction=DL    log=${log_path}    cells=${dl_list}    target_throughput=${exp_dl_tp}    target_avg_percent=${target_avg_percent}
    ...    actCarrierAggregation=${True}    min_percent=${min_percent}

Start Spark TP Log
    [Arguments]    ${ue_alias}=spark_UE
    Create Directory     ${OUTPUT_DIR}/${TEST NAME}
    sparkMultiUE_yiyuan.start_log    ue_alias=${ue_alias}

Stop Spark TP Log
    [Arguments]  ${ue_alias}=spark_UE    ${logpath}=${OUTPUT_DIR}/${TEST NAME}    ${filter}=test
    sparkMultiUE_yiyuan.stop_log    ue_alias=${ue_alias}
    sparkMultiUE_yiyuan.export_log_file    ue_alias=${ue_alias}     logpath=${logpath}    filter=${filter}

############# Commercial UE Start Traffic ###################
attach multi power ue
    [Arguments]    ${ue_index_list}    ${ue_type}=samsung
    log to console       Prepare UE
    FOR    ${ue_index}   IN    @{ue_index_list}
        power_ue.Prepare UE    ue_index=${ue_index}    ue_type=samsung
        ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    attach_mode=5G_NSA   ue_type=${ue_type}
        power_ue.Verify attach    ue_type=samsung    ue_index=${ue_index}   5Grach_ed=${5Grach_ed_0}    4G_check=False
    END

start multi power ue traffic ul and dl
    [Arguments]    ${ue_index_list}    ${ul_power_port_list}    ${dl_power_port_list}    ${ul_throughput}=${None}    ${dl_throughput}=${None}
    ...    ${ul_duration}=6000    ${dl_duration}=6000    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}    ${process_num}=${2}
    ...    ${ue_type}=samsung
    log to console      Start traffic    console=yes
    FOR    ${item}    IN    @{ue_index_list}
        run keyword and continue on failure    run keyword if     ${if_ul}    power_ue.Start traffic    ue_index=${item}    direction=ul
    ...    throughput=${ul_throughput}    duration=${ul_duration}    ue_type=${ue_type}    iperf_type=via_command    protocol=${protocol}
    ...    iperf_port=@{ul_power_port_list}[${item}]
        sleep    1s
        run keyword and continue on failure    run keyword if    ${if_dl}    power_ue.Start traffic    ue_index=${item}    direction=dl
        ...    throughput=${dl_throughput}    duration=${dl_duration}    ue_type=${ue_type}    protocol=${protocol}
        ...    iperf_port=@{dl_power_port_list}[${item}]    process_num=${process_num}
    END

stop multi power ue traffic ul and dl
    [Arguments]    ${ue_index_list}    ${ul_power_port_list}    ${dl_power_port_list}    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}
    ...    ${ue_type}=samsung
    log to console     Stop traffic    console=yes
    FOR    ${item}    IN    @{ue_index_list}
        run keyword if    ${if_ul}    power_ue.Stop traffic    direction=ul    ue_index=${item}    ue_type=${ue_type}    iperf_type=via_command
        ...    protocol=${protocol}    iperf_port=@{ul_power_port_list}[${item}]
        run keyword if    ${if_dl}    power_ue.Stop traffic    direction=dl    ue_index=${item}    ue_type=${ue_type}    protocol=${protocol}
        ...    iperf_port=@{dl_power_port_list}[${item}]
    END

detach multi power ue
    [Arguments]    ${ue_index_list}    ${ue_type}=samsung
    log to console      UE Detach    console=yes
    FOR    ${item}    IN    @{ue_index_list}
         power_ue.UE Detach    ue_index=${item}    ue_type=${ue_type}
    END

Start UL UDP traffic via iperf command1
    [Arguments]    ${EPC_IP}=${tl.appserver.iperf_details.network_interface_address}
    ...    ${UL_port}=${tl.appserver.iperf_details.port}    ${buffer_size}=1024B    ${ue_index}=${0}
    ...    ${time}=10    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${traffic}=10.00M    ${window_size}=2M    ${process_num}=${1}
    sleep   2s
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send_command    command=adb -s ${serial_number} root &
    ...    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell ps -ef | grep iperf |grep ${UL_port} |grep -v grep |awk '{print $2}'
    ...    connection=cygwin
    ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell kill -9 ${pid} &
    ...    connection=cygwin
    sleep    2s
    ${cmd}=    catenate    adb -s ${serial_number} shell /data/local/tmp/iperf -c ${EPC_IP} -u -p ${UL_port}
    ...    -t ${time} -P ${process_num} -i 1 -f m -b ${traffic} -l ${buffer_size} -T 64 -w ${window_size} &
    csn.send_command    command=${cmd}
    ...    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell ps -ef |grep iperf |grep ${UL_port} |grep -v grep |awk '{print $2}'
    ...    connection=cygwin
    ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cygwin
    log to console    .....UE_${ue_index} udp ul iperf start....
    [Teardown]    csn.disconnect      connection=cygwin

############# Commercial UE Use Spark ###################
Prepare UE and Attach UE by spark
    [Arguments]  ${ue_index}    ${attach_mode}=5G_NSA
    samsung_spark.require_ue    ue_alias=UE_${ue_index}    index=${ue_index}    reset_sol=${None}
    ${5Grach_ed}    samsung_spark.attach_ue    ue_alias=UE_${ue_index}   attach_mode=${attach_mode}     power_reset=False    timeout=90000
    log to console    UE_${ue_index}
    log to console    ${5Grach_ed}
    [Return]  ${5Grach_ed}

UE attach by Spark
    [Timeout]  6min
    [Arguments]  ${ue_index}    ${ue_type}=huawei_sigspark    ${attach_mode}=5G_NSA
    ${5Grach_ed}    wait until keyword succeeds    2X    2min    Prepare UE and Attach UE by spark    ue_index=${ue_index}
    ...    attach_mode=${attach_mode}
    Run keyword if    '${attach_mode}' == '5G_NSA'
    ...    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${ue_index}    4G_check=False
    ...    ELSE    Verify 4G Attach by ADB Command    ue_index=${ue_index}
    Log To Console    Attach UE_${ue_index} success

UE detach by Spark
    [Arguments]  ${ue_index_list}
    FOR    ${ue_index}    IN    @{ue_index_list}
        Run Keyword And Ignore error    samsung_spark.detach_ue    ue_alias=UE_${ue_index}
    END

Spark Start UE Log
    [Documentation]    Author:jiang.hongyu@nokia-sbell.com
    [Arguments]    ${ue_index}
    ${ue_alias}    set variable    UE_${ue_index}
    samsung_spark.start_log    ue_alias=${ue_alias}

Spark Stop UE Log
    [Documentation]    Author:jiang.hongyu@nokia-sbell.com
    [Arguments]    ${ue_index}    ${log_name}=uelog_sigspark_UE${ue_index}
    Create Directory     ${output_dir}/${TEST_NAME}
    ${log_path}    set variable    ${output_dir}/${TEST_NAME}/${log_name}
    ${ue_alias}    set variable    UE_${ue_index}
    samsung_spark.stop_log    ue_alias=${ue_alias}    logname=${log_path}.xml   filter=test
    [Return]  ${log_path}.csv

Attach Multi Power Ue And Verify 4G Attach
    [Arguments]    ${ue_index_list}
    log to console       Prepare UE
    FOR    ${ue_index}   IN    @{ue_index_list}
        power_ue.Prepare UE    ue_index=${ue_index}    ue_type=samsung
        power_ue.UE Attach    ue_index=${ue_index}    attach_mode=5G_NSA   ue_type=samsung
        wait until keyword succeeds    1 min    10s    Verify 4G Attach by ADB Command    ue_index=${ue_index}
    END

Get UE IP And Start UL DL traffic TCP
    [Arguments]    ${DL_port}    ${UL_port}    ${control_pc}    ${control_pc_name}    ${control_pc_pass}    ${ue_index}=${2}    ${time}=6000
    ...    ${process_num}=${2}    ${connection}=cygwin
    #get ue ip
    ssh.connect to    hostname=${control_pc}    username=${control_pc_name}    password=${control_pc_pass}    alias=${connection}
    ${serial_number}    set variable    ${tl.ues[${ue_index}].serial_number}
    ssh.send_command    command=adb -s ${serial_number} shell ip -f inet addr |grep inet |grep -v ims00 | cut -d '/' -f 1 |awk '{print $2}'
    ...    connection=${connection}
    ${UE_IP_info}    ssh.read_output    connection=${connection}
    ${UE_IP}    Get_UE_Right_IP    cmd_info=${UE_IP_info}
    #ue iperf
    ssh.send_command    command=adb -s ${serial_number} root &
    ...    connection=${connection}
    ssh.send_command    command=adb -s ${serial_number} shell ps -ef |grep iperf |grep ${DL_port} |grep -v grep |awk '{print $2}'
    ...    connection=${connection}
    ${pid}    wait until keyword succeeds    1 min    10 sec    ssh.read_output    connection=${connection}
    ssh.send_command    command=adb -s ${serial_number} shell kill -9 ${pid} &
    ...    connection=${connection}
    ssh.send_command    command=adb -s ${serial_number} shell ps -ef |grep iperf |grep ${UL_port} |grep -v grep |awk '{print $2}'
    ...    connection=${connection}
    ${pid}    wait until keyword succeeds    1 min    10 sec    ssh.read_output    connection=${connection}
    ssh.send_command    command=adb -s ${serial_number} shell kill -9 ${pid} &
    ...    connection=${connection}
    sleep  2s
    ssh.send_command    command=adb -s ${serial_number} shell /data/local/tmp/iperf3 -s -p ${UL_port} -i 1 &
    ...    connection=${connection}
    ssh.send_command    command=adb -s ${serial_number} shell /data/local/tmp/iperf3 -s -p ${DL_port} -i 1 &
    ...    connection=${connection}
    sleep  3s
    #send DL command
    log to console    Start TCP Traffic
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}
    sleep  3s
    ssh.send_command   command=ps -ef|grep iperf3|grep -v grep|grep ${UL_port}| awk '{print $2}' |xargs kill -9 &    connection=EPCAPP
    ssh.send_command   command=ps -ef|grep iperf3|grep -v grep|grep ${DL_port}| awk '{print $2}' |xargs kill -9 &    connection=EPCAPP
    ssh.send_command
    ...    command=iperf3 -c ${UE_IP} -p ${UL_port} -t ${time} -P ${process_num} -R -w 2M -M 1180 >/dev/null 2>/dev/null &
    ...    connection=EPCAPP
    ssh.send_command
    ...    command=iperf3 -c ${UE_IP} -p ${DL_port} -t ${time} -P ${process_num} -w 2M -M 1180 >/dev/null 2>/dev/null &
    ...    connection=EPCAPP
    sleep   20s
    ssh.disconnect    connection=EPCAPP
    [Teardown]  ssh.disconnect    connection=${connection}

LTE UE Start Traffic And Check Tp
    [Arguments]    ${ul_throughput}    ${dl_throughput}    ${protocol}    ${list_length}    ${if_ul}=${True}    ${if_dl}=${True}    ${log_time}=30s
    @{ue_index_list}    create list    ${0}
    UE attach by Spark    ue_index=${0}    ue_type=huawei_sigspark    attach_mode=LTE
    Spark Start UE Log    ue_index=${0}
    start multi power ue traffic ul and dl    ue_index_list=${ue_index_list}    ul_throughput=${ul_throughput}M    dl_throughput=${dl_throughput}M
    ...    if_ul=${if_ul}    if_dl=${if_dl}    process_num=${3}    protocol=${protocol}    ue_type=samsung
    sleep    ${log_time}
    ${log_path}    Spark Stop UE Log    ue_index=${0}
    stop multi power ue traffic ul and dl    ue_index_list=${ue_index_list}    if_ul=${if_ul}    if_dl=${if_dl}    protocol=${protocol}
    Check UE TP From Spark Log    log_path=${log_path}    expect_ul=${ul_throughput}    expect_dl=${dl_throughput}    row_list=${LTE_row_list}
    ...    list_length=${list_length}
    [Teardown]  UE detach by Spark    ue_index_list=${ue_index_list}

Check UE TP From Spark Log
    [Arguments]  ${log_path}    ${expect_ul}    ${expect_dl}    ${row_list}    ${list_length}
    ${throughput_dict}    Get_UE_TP_From_spark_log    file_path=${log_path}    list_length=${list_length}    row_list=${row_list}
    log to console    ${throughput_dict}
    ${DL_tp_info}    get from dictionary  ${throughput_dict}    DL_tp
    ${UL_tp_info}    get from dictionary  ${throughput_dict}    UL_tp
    run keyword and continue on failure    Should Be True     ${DL_tp_info}[${0}] > ${expect_dl}
    run keyword and continue on failure    Should Be True     ${UL_tp_info}[${0}] > ${expect_ul}

######################  VONR call ##############################
Make a VoNR call(+6688)
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${during}=90s
    log to console    \n *** Make a VoNR call(+6688)
    ssh.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    #####Press the Home button to open the screen#####
    ssh.send_command   connection=cygwin${ue_index}
    ...   command=adb -s ${serial_number} shell dumpsys window | grep -E \"mAwake|isStatusBarKeyguard|mShowingLockscreen\"
    sleep   2s
    ${output}   ssh.read_output   connection=cygwin${ue_index}
    Run Keyword If   ${output.lower().count('mawake=false')}>0
    ...    ssh.send_command    command=adb -s ${serial_number} shell input keyevent 82    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    ssh.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800    connection=cygwin${ue_index}
    sleep   2s
    #####make VoNR call#####
    ssh.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+6688
    ...    connection=cygwin${ue_index}
    sleep    ${during}

hang up VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    log to console    \n *** hang up VoNR call
    ssh.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    ssh.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cygwin${ue_index}