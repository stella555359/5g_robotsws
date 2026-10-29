*** Settings ***
Documentation    author：Hongyu Jiang
...              contact: hongyu.jiang@nokia-sbell.com
...              squad group: mmw_SG_04
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Library     taf.sbts.oam.coam.admin              WITH NAME    coam
Library     taf.transport.ssh      WITH NAME    csn
Library     ./5GC001937_mmw4_common_keywords.py
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/sigspark_yiyuan_multiUE.py
Library     sigspark_yiyuan_multiUE.SigSparkMutiUE    WITH NAME    sparkMultiUE_yiyuan
Library     taf.sw.nrdim    WITH NAME    NRDIM
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py    WITH NAME
...    throughput_computation





*** Variables ***
${gNB_ip}                 ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${gNB_username}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${ul_power_port_list}     ${tl.ues[0].iperf_details.ports[0:3]}
${dl_power_port_list}     ${tl.ues[0].iperf_details.ports[3:6]}
${UE_TYPE}                samsung
${TS_CASE_LOG_PATH}       ${output_dir}
${CURDIR_path}            ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/
${appserver_addr}         ${tl.ues[0].iperf_details.ssh_connection_details.addr}
${TEST_PC_IP}             ${tl.test_pc.default_ssh_connection_details.addr}
${TEST_PC_USERNAME}       ${tl.test_pc.default_ssh_connection_details.username}
${TEST_PC_PASSWORD}       ${tl.test_pc.default_ssh_connection_details.password}
${total_count}            ${300}
${control_pc}             ${tl.ues[0].ssh_connection_details.addr}
${control_pc_name}        ${tl.ues[0].ssh_connection_details.username}
${control_pc_pass}        ${tl.ues[0].ssh_connection_details.password}
@{case_row_list}          NR PDCP Thr. DL [Mbps]    NR PDCP Thr. UL [Mbps]    NR PDSCH iBLER[%]    NR PUSCH iBLER[%]
@{all_cell_list}          16385    16386    16387    16388    16389    16390    16391    16392
@{4cc_cell_list}          16385    16386    16387    16388
@{all_cell_id_list}       1    2    3    4    5    6    7   8

*** Keywords ***
########### Suite Setup #################
Case Suite Setup
    CI_interface.Common Suite Setup
    robot_common_operations.Common Suite Setup

Get Theoretical TP From NRDIM
    ${default_scf}    Set Default scf name
    ${total_ul_tp}    ${total_dl_tp}    ${total_dl_tp_tmp}    Calculate Theoretical TP    scf_path=${default_scf}
    ...    ul_cell_list=${all_cell_id_list[0:4]}    dl_cell_list=${all_cell_id_list}
    Set Suite Variable      ${expect_4cc_ul_tp}    ${total_ul_tp}
    Set Suite Variable      ${expect_4cc_dl_tp}    ${total_dl_tp_tmp}
    Set Suite Variable      ${expect_8cc_dl_tp}    ${total_dl_tp}

########### check bts on air #################
Set Default scf name
    [Arguments]  ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    _
    ${if_common_load}     run keyword and return status    should contain    ${version_list[2]}    9999
    ${default_scf}    set variable if    ${if_common_load}    ${CURDIR_path}SCF_SBTS00.xml
    ...     ${CURDIR_path}SCF_${version_list[0]}.xml
    set suite variable    ${default_scf}
    log to console   ${default_scf}
    [Return]  ${default_scf}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Setup Commission SCF
    [Arguments]  ${connection}=GNB_OAM
    robot_common_operations.Common Suite Setup
    ${default_scf}    Set Default scf name
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    COAM Commission with scf file    scf_file_path=${default_scf}    timeout=600
    sleep    5min
    Check GNB on air
    [Return]  ${default_scf}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Check GNB on air
    [Timeout]    20 min
    [Arguments]  ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    Wait Until Keyword Succeeds    20min    20s    COAM Check GNB cell on air    connection=${connection}
    Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=${connection}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

########## modify parameter ###################
Modify Parameters with json
    [Timeout]  10min
    [Arguments]    ${input_list}    ${bts_host}=${gnb_ip}    ${delta_id}=update_parameter    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    coam.create_delta    delta_id=${delta_id}
    FOR    ${item}  IN    @{input_list}
        ${operation}    get from dictionary    ${item}    operation
        Run keyword if    '${operation}'=='update'
        ...    coam.append_parameter_update_to_delta    dist_name=${item['dist_name']}    parameter=${item['parameter']}
        ...    value=${item['value']}    delta_id=${delta_id}
        Run keyword if    '${operation}'=='delete'
        ...    coam.append_parameter_delete_to_delta    dist_name=${item['dist_name']}    parameter=${item['parameter']}
        ...    delta_id=${delta_id}
        Log to console    Add task - ${operation}: ${item['dist_name']}.${item['parameter']}
    END
    ${delta_file}    coam.get_delta    delta_id=${delta_id}
    ${timeout}    set variable    480
    Log to console    Perform parameters via delta_id:${delta_id} is ongoing, timeout ${timeout}s.
    coam.perform_delta_recommissioning
    ...    delta_file=${delta_file}
    ...    skip_parameter_relation_errors=${False}
    ...    should_activate=${True}
    ...    timeout=${timeout}
    ...    connection=${connection}
    Log to console    Perform parameters done.
    run keyword and ignore error    coam.remove_delta    delta_id=${delta_id}
    [Teardown]    run keyword and ignore error    coam.teardown      connection=${connection}

################# Log ###########################
Save Snapshot
    [Arguments]    ${connection}=cOAM    ${timeout}=5min
    run keyword and ignore error     coam.teardown    connection=${connection}
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${snapshot_path}    Get Snapshot From BTS    alias=${connection}    timeout=${timeout}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
    [Return]    ${snapshot_path}

Check Throught From Asslog
    [Arguments]  ${log_path}     ${ul_tp}    ${dl_tp}    ${duration}=1m    ${ul_list}=${all_cell_list}    ${dl_list}=${all_cell_list}
    ...    ${if_ul}=${True}    ${if_dl}=${True}    ${target_avg_percent}=0.98    ${min_percent}=0.85    ${ue_type}=samsung
    ${log_path}    power_ue.Collect Tput    ue_type=${ue_type}    log_dir=${log_path}    duration=${duration}    ignore_time=20s
    run keyword and continue on failure    run keyword if    ${if_ul}==${True}    power_ue.Check Tput    ue_type=${ue_type}
    ...    direction=UL    log=${log_path}    cells=${ul_list}    target_throughput=${ul_tp}    target_avg_percent=${target_avg_percent}
    ...    actCarrierAggregation=${True}    min_percent=${min_percent}
    run keyword and continue on failure    run keyword if    ${if_dl}==${True}    power_ue.Check Tput    ue_type=${ue_type}
    ...    direction=DL    log=${log_path}    cells=${dl_list}    target_throughput=${dl_tp}    target_avg_percent=${target_avg_percent}
    ...    actCarrierAggregation=${True}    min_percent=${min_percent}

################# Teardown  ###########################
Commmon Case Teardown
    [Arguments]    ${input_list}
    Modify Parameters with json    input_list=${input_list}
    Run Keyword And Ignore Error     Clear All DU Connection From UTE    connect_ip=${gNB_ip}
    robot_common_operations.Common Case Teardown
    CI_interface.Common Case Teardown

Clear All DU Connection From UTE
    [Arguments]    ${connect_ip}    ${connection}=TEST_PC
    csn.Connect to     hostname=${TEST_PC_IP}   username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}  alias=${connection}
    csn.send_command    command=ps -ef | grep ${connect_ip} | awk '{print $2}' | xargs kill -9    connection=${connection}
    [Teardown]   run keyword and ignore error  csn.Disconnect	connection=${connection}

Suite Case Teardown
    [Arguments]
    Run Keyword And Ignore error    Clear All Log Frome Control PC
    robot_common_operations.Common Suite Teardown

Clear All Log Frome Control PC
    [Arguments]    ${connection}=Control_pc
    csn.Connect to     hostname=${control_pc}   username=${control_pc_name}    password=${control_pc_pass}  alias=${connection}
    csn.send_command    command=cd '/cygdrive/c/tmp/uelog/AUTO';rm -rf *    connection=${connection}
    csn.send_command    command=cd '/cygdrive/c/Program Files (x86)/Spark1.1.1998.9/Data/Tmp';rm -rf *    connection=${connection}
    csn.send_command    command=cd '/cygdrive/c/Program Files (x86)/Spark1.1.1998.2/Data/Tmp';rm -rf *    connection=${connection}
    [Teardown]   run keyword and ignore error  csn.Disconnect	connection=${connection}

################## New KW ######################################
Prepare MultiUE And Attach
    [Arguments]    ${multiue_config_direction}    ${ue_alias}=spark_UE    ${restart_ue}=${False}    ${restart_network}=${False}
    ...    ${get_spark_license}=${True}
    log to console      "Prepare UE"
    sparkMultiUE_yiyuan.require_ue    ue_alias=${ue_alias}    multiue_traffic_config=${multiue_config_direction}
    ...    restart_ue=${restart_ue}    restart_network=${restart_network}    get_spark_license=${get_spark_license}
    log to console      "UE Attach"
    sparkMultiUE_yiyuan.attach_ue    ue_alias=${ue_alias}

MultiUE Start UDP Traffic
    [Arguments]    ${ul_tp}    ${ul_port_list}=${ul_power_port_list}    ${if_ul}=${True}    ${if_dl}=${True}
    ...    ${ue_alias}=spark_UE
    ${ue_ip_dict}    sparkMultiUE_yiyuan.get_ue_ip    ue_alias=${ue_alias}
    log to console    ${ue_ip_dict}
    ${ue_index_list}    get dictionary keys    ${ue_ip_dict}
    run keyword if    ${if_ul}==${True}    ssh.send command    command=taskkill /fi "imagename eq iperf.exe" /F    connection=sigspark
    run keyword if    ${if_ul}==${True}    ssh.send command    command=taskkill /fi "imagename eq iperf3.exe" /F    connection=sigspark
    FOR  ${ue_index}  IN  @{ue_index_list}
        ${UE_ip}    get from dictionary    ${ue_ip_dict}     ${ue_index}
        ${command_str}    Catenate
        ...    cmd /C "iperf.exe -c ${appserver_addr} -u -p ${ul_port_list[${ue_index}]} -l 1350B -f k -b ${ul_tp}M -t 9999 -i 1 -P 1 -B ${UE_ip}"
        sleep   2s
        wait until keyword succeeds    2x    60s    Start UDP Commond And ReadOut PID    command_str=${command_str}    ue_index=${ue_index}
        run keyword if    ${if_ul}==${True}    log to console    UE_${ue_index} start UL UDP
    END
    sleep   2s
    run keyword if    ${if_dl}==${True}    log to console      "UE Start DL Traffic"
    run keyword if    ${if_dl}==${True}    sparkMultiUE_yiyuan.TL750_start_data_transfer    ue_alias=${ue_alias}    direction=dl
    [Return]    ${ue_ip_dict}

ReadOut PID
    [Arguments]    ${ue_index}
    ssh.send command    command=tasklist /fi "imagename eq iperf.exe"    connection=sigspark
    ${pid}    wait until keyword succeeds    10s    2s    csn.Read Output    connection=sigspark
    ${pid}    Strip String    string=${pid}
    ${pid}    Split String    string=${pid}    separator=\r\n
    ${str_len}    get length    ${pid}
    ${pid_len}    Evaluate      ${ue_index} + ${3}
    Should Be True  ${str_len} == ${pid_len}
    log to console    ${pid}

Start UDP Commond And ReadOut PID
    [Arguments]  ${command_str}    ${ue_index}
    csn.send command     command=${command_str}    connection=sigspark
    log to console    start command success
    wait until keyword succeeds    40s    10s    ReadOut PID    ue_index=${ue_index}

MultiUE Start TCP Traffic
    [Arguments]  ${port_list}    ${process_num}     ${time}    ${direction}    ${ue_alias}=spark_UE
    ${ue_ip_dict}    sparkMultiUE_yiyuan.get_ue_ip    ue_alias=${ue_alias}
    log to console    ${ue_ip_dict}
    ${ue_index_list}    get dictionary keys    ${ue_ip_dict}
    FOR  ${ue_index}  IN  @{ue_index_list}
        ${UE_ip}    get from dictionary    ${ue_ip_dict}     ${ue_index}
        ${command_str}    Catenate    cmd /C "iperf3 -s -p ${port_list[${ue_index}]} -i 1"
        sleep   2s
        ssh.send command     command=${command_str}    connection=sigspark
        wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}
        ssh.send_command    command=ps -ef|grep iperf3|grep -v grep|grep ${port_list[${ue_index}]}| awk '{print $2}' |xargs kill -9 &
        ...    connection=EPCAPP
        sleep    5s
        ${command_str}    Catenate    iperf3 -t ${time} -P ${process_num} -w 2M -M 1280 -p ${port_list[${ue_index}]} -c ${UE_ip}
        run keyword if    '${direction}'=='ul'    ssh.send_command    command=${command_str} -R >/dev/null 2>/dev/null &    connection=EPCAPP
        run keyword if    '${direction}'=='ul'    log to console    .....UE_${ue_index} tcp ul iperf start....
        run keyword if    '${direction}'=='dl'    ssh.send_command    command=${command_str} >/dev/null 2>/dev/null &    connection=EPCAPP
        run keyword if    '${direction}'=='dl'    log to console    .....UE_${ue_index} tcp dl iperf start....
    END
    [Teardown]    ssh.disconnect      connection=EPCAPP

MultiUE Stop UDP Traffic
    [Arguments]    ${if_ul}=${False}    ${if_dl}=${True}    ${ue_alias}=spark_UE
    log to console      "UE Stop UL Traffic"
    run keyword if    ${if_ul}==${True}    ssh.send command    command=taskkill /fi "imagename eq iperf.exe" /F    connection=sigspark
    run keyword if    ${if_ul}==${True}    ssh.send command    command=taskkill /fi "imagename eq iperf3.exe" /F    connection=sigspark
    log to console      "UE Stop DL Traffic"
    run keyword if    ${if_dl}==${True}    sparkMultiUE_yiyuan.stop_data_transfer    ue_alias=${ue_alias}    direction=dl

MultiUE Detach
    [Arguments]  ${ue_alias}=spark_UE
    log to console      "UE Detach"
    sparkMultiUE_yiyuan.detach_ue    ue_alias=${ue_alias}

Start Spark TP Log
    [Arguments]    ${ue_alias}=spark_UE
    Create Directory     ${OUTPUT_DIR}/${TEST NAME}
    sparkMultiUE_yiyuan.start_log    ue_alias=${ue_alias}

Stop Spark TP Log
    [Arguments]  ${ue_alias}=spark_UE    ${logpath}=${OUTPUT_DIR}/${TEST NAME}    ${filter}=test
    sparkMultiUE_yiyuan.stop_log    ue_alias=${ue_alias}
    sparkMultiUE_yiyuan.export_log_file    ue_alias=${ue_alias}     logpath=${logpath}    filter=${filter}

Get Each UE TP From Spark
    [Arguments]  ${ue_num}    ${list_length}=${total_count}    ${row_list}=${case_row_list}
    @{dl_tput_info}    Create list
    @{ul_tput_info}    Create list
    @{dl_bler_info}    Create list
    @{ul_bler_info}    Create list
    @{total_result_list}    Create List
    FOR    ${ue_index}    IN RANGE  ${ue_num}
        ${id}    Evaluate    ${ue_index}+1
        ${result_dic}    Get_UE_TP_Bler_From_spark_log    file_path=${OUTPUT_DIR}/${TEST NAME}/UE-${id}.csv
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

Calculate Total TP From Spark Log
    [Arguments]  ${ue_num}    ${list_length}=${total_count}    ${row_list}=${case_row_list}
    ${result_list}    Get Each UE TP From Spark    ue_num=${ue_num}    list_length=${list_length}    row_list=${row_list}
    ${total_result_dict}    set variable    ${result_list}[-1]
    ${total_tp_dict}    Caculate_total_tp    total_message_dict=${total_result_dict}

#Calculate Theoretical TP
#    [Arguments]    ${scf_path}    ${ul_cell_list}    ${dl_cell_list}
#    ${cellgroup_distname}    set variable    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELLGRP-0
#    ${total_ul_tp}    set variable    ${0}
#    ${total_dl_tp}    set variable    ${0}
#    ${ul_cell_num}    get length    ${ul_cell_list}
#    ${dl_cell_num}    get length    ${dl_cell_list}
#    FOR  ${i}  IN RANGE   ${ul_cell_num}
#        ${cell_distname}    set variable    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-${ul_cell_list[${i}]}
#        NRDIM.Setup    scf_file_path=${scf_path}    cell_distname=${cell_distname}    cellgroup_distname=${cellgroup_distname}    alias=Test
#        NRDIM.set_parameter    name=UEmaxDataCheck     value=${1}    calculator=Test
#        ${calculator_tp_dict}    NRDIM.calculate_expected_throughput    calculator=Test
#        ${calculator_tp_ul}    get from dictionary      ${calculator_tp_dict}    uplink
#        ${calculator_tp_dl}    get from dictionary      ${calculator_tp_dict}    downlink
#        ${total_ul_tp}    Evaluate    ${calculator_tp_ul}+${total_ul_tp}
#        ${total_dl_tp}    Evaluate    ${calculator_tp_dl}+${total_dl_tp}
#    END
#    ${total_dl_tp_tmp}    set variable    ${total_dl_tp}
#    FOR  ${i}  IN RANGE  ${ul_cell_num}    ${dl_cell_num}
#        ${cell_distname}    set variable    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-${dl_cell_list[${i}]}
#        NRDIM.Setup    scf_file_path=${scf_path}    cell_distname=${cell_distname}    cellgroup_distname=${cellgroup_distname}    alias=Test
#        NRDIM.set_parameter    name=UEmaxDataCheck     value=${1}    calculator=Test
#        ${calculator_tp_dict}    NRDIM.calculate_expected_throughput    calculator=Test
#        ${calculator_tp_dl}    get from dictionary      ${calculator_tp_dict}    downlink
#        ${total_dl_tp}    Evaluate    ${calculator_tp_dl}+${total_dl_tp}
#    END
#    [Return]  ${total_ul_tp}    ${total_dl_tp}    ${total_dl_tp_tmp}

Calculate Theoretical TP
    [Arguments]  ${scf_path}    ${ul_cell_list}    ${dl_cell_list}
    ${total_ul_tp}    set variable    ${0}
    ${total_dl_tp}    set variable    ${0}
    ${ul_cell_num}    get length    ${ul_cell_list}
    ${dl_cell_num}    get length    ${dl_cell_list}
    FOR  ${i}  IN RANGE   ${ul_cell_num}
        ${cell_id}    Evaluate    ${i}+${1}
        ${calculator_tp_dl}    ${calculator_tp_ul}    throughput_computation.get_theoretical_throughput    scf_path=${scf_path}    cell_id=${cell_id}
        ...    UEmaxData=${1}
        ${total_ul_tp}    Evaluate    ${calculator_tp_ul}+${total_ul_tp}
        ${total_dl_tp}    Evaluate    ${calculator_tp_dl}+${total_dl_tp}
    END
    ${total_dl_tp_tmp}    set variable    ${total_dl_tp}
    FOR  ${i}  IN RANGE  ${ul_cell_num}    ${dl_cell_num}
        ${cell_id}    Evaluate    ${i}+${1}
        ${calculator_tp_dl}    ${calculator_tp_ul}    throughput_computation.get_theoretical_throughput    scf_path=${scf_path}    cell_id=${cell_id}
        ...    UEmaxData=${1}
        ${total_dl_tp}    Evaluate    ${calculator_tp_dl}+${total_dl_tp}
    END
    [Return]  ${total_ul_tp}    ${total_dl_tp}    ${total_dl_tp_tmp}
