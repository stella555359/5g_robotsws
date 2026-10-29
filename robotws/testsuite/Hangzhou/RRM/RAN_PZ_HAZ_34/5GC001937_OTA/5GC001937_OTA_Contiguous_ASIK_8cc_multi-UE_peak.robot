*** Settings ***
Force Tags    PY36
Documentation    author：Hongyu Jiang
...              contact: hongyu.jiang@nokia-sbell.com
...              squad group: mmw_SG_04

Resource          ./resources/5GC001937_mmw4_common_keyword.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Variables         ./resources/5GC001937_mmw4_modify_para.py

Suite Setup       Setup Commission SCF
Suite Teardown    Suite Case Teardown


*** Variables ***
@{empty_list}    ${0.0}    ${0.0}    ${0.0}


*** Test Cases ***
[1]5GC001937_OTA_8111_NSA_L3_Call_UL_UDP_Classical_8CC_1DRB_AEWB_Contiguous
    [Tags]    CRT_20B    CRT_TRUNK
    [Documentation]   Multi ue attach and continued start udp traffic at least 5min check tp via iperf
    [Setup]    robot_common_operations.Common Case Setup
    ${total_result_dict}    set variable   ${total_tp_orge}
    UE attach by Spark    ue_num=${ue_number}
    Start data traffic and Record TP Log and Aasys Log
    ...    ue_num=${ue_number}    ul_throughput=${ul_tput_udp}    dl_throughput=${dl_tput_udp}    ul_duration=${duration}    dl_duration=${duration}
    ...    protocol=udp    if_ul=${True}    if_dl=${False}    file_name=Asys_ul_udp.txt    time=${log_time}
    Stop data traffic and Stop Record TP Log and Aasys Log    ue_num=${ue_number}    if_ul=${True}    if_dl=${False}    protocol=udp
    ...    spark_log_name=spark_ul_udp
    ${total_result_list}   Get Each UE TP From Spark    ue_num=${ue_number}    spark_log_name=spark_ul_udp    list_length=${total_count}
    ${total_result_dict}    set variable    ${total_result_list}[-1]
    ${aasyslog_status}     run keyword and return status    Check TP From Aasyslog     file_name=Asys_ul_udp.txt
    ${dl_list}     ${ul_list}    run keyword if     ${aasyslog_status}    Check TP From Aasyslog     file_name=Asys_ul_udp.txt
    ${dl_list}    set variable if    ${aasyslog_status}    ${dl_list}    ${empty_list}
    ${ul_list}    set variable if    ${aasyslog_status}    ${ul_list}    ${empty_list}
    Run Keyword And Ignore Error    Power UE Check TP From Aasyslog    
    ...    log_path=Asys_ul_udp.txt    if_ul=${True}    if_dl=${False}    exp_ul_tp=${220}    exp_dl_tp=${4360}
    [Teardown]  Commmon Case Teardown    total_result_list=${total_result_dict}    syslog_dl_list=${dl_list}    syslog_ul_list=${ul_list}
    ...    if_ul=${True}    if_dl=${False}    protocol=UDP    flag=${False}

[1]5GC001937_OTA_8111_NSA_L3_Call_DL_UDP_Classical_8CC_1DRB_AEWB_Contiguous
    [Tags]  CRT_20B    CRT_TRUNK
    [Documentation]   Multi ue attach and continued start udp traffic at least 5min check tp via iperf
    [Setup]    robot_common_operations.Common Case Setup
    ${total_result_dict}    set variable   ${total_tp_orge}
    UE attach by Spark    ue_num=${ue_number}
    Start data traffic and Record TP Log and Aasys Log
    ...    ue_num=${ue_number}    ul_throughput=${ul_tput_udp}    dl_throughput=${dl_tput_udp}    ul_duration=${duration}    dl_duration=${duration}
    ...    protocol=udp    if_ul=${False}    if_dl=${True}    file_name=Asys_dl_udp.txt    time=${log_time}
    Stop data traffic and Stop Record TP Log and Aasys Log    ue_num=${ue_number}    if_ul=${False}    if_dl=${True}    protocol=udp
    ...    spark_log_name=spark_dl_udp
    ${total_result_list}    Get Each UE TP From Spark    ue_num=${ue_number}    spark_log_name=spark_dl_udp    list_length=${total_count}
    ${total_result_dict}    set variable    ${total_result_list}[-1]
    ${aasyslog_status}     run keyword and return status    Check TP From Aasyslog     file_name=Asys_dl_udp.txt
    ${dl_list}     ${ul_list}    run keyword if     ${aasyslog_status}    Check TP From Aasyslog     file_name=Asys_dl_udp.txt
    ${dl_list}    set variable if    ${aasyslog_status}    ${dl_list}    ${empty_list}
    ${ul_list}    set variable if    ${aasyslog_status}    ${ul_list}    ${empty_list}
    Run Keyword And Ignore Error    Power UE Check TP From Aasyslog    
    ...    log_path=Asys_dl_udp.txt    if_ul=${False}    if_dl=${True}    exp_ul_tp=${220}    exp_dl_tp=${4360}
    [Teardown]  Commmon Case Teardown    total_result_list=${total_result_dict}     syslog_dl_list=${dl_list}    syslog_ul_list=${ul_list}
    ...    if_ul=${False}    if_dl=${True}    protocol=UDP    flag=${False}

[1]5GC001937_OTA_8111_NSA_L3_Call_ULDL_UDP_Classical_8CC_1DRB_AEWB_Contiguous
    [Tags]  CRT_20B    CIT_TRUNK
    [Documentation]   Multi ue attach and continued start udp traffic at least 5min check tp via iperf
    [Setup]    robot_common_operations.Common Case Setup
    ${total_result_dict}    set variable   ${total_tp_orge}
    UE attach by Spark    ue_num=${ue_number}
    Start data traffic and Record TP Log and Aasys Log
    ...    ue_num=${ue_number}    ul_throughput=${ul_tput_udp}    dl_throughput=${dl_tput_udp}    ul_duration=${duration}    dl_duration=${duration}
    ...    protocol=udp    if_ul=${True}    if_dl=${True}    file_name=Asys_ul_dl_udp.txt    time=${log_time}
    Stop data traffic and Stop Record TP Log and Aasys Log    ue_num=${ue_number}    if_ul=${True}    if_dl=${True}    protocol=udp
    ...    spark_log_name=spark_ul_dl_udp
    ${total_result_list}    Get Each UE TP From Spark    ue_num=${ue_number}    spark_log_name=spark_ul_dl_udp    list_length=${total_count}
    ${total_result_dict}    set variable    ${total_result_list}[-1]
    ${aasyslog_status}     run keyword and return status    Check TP From Aasyslog     file_name=Asys_ul_dl_udp.txt
    ${dl_list}     ${ul_list}    run keyword if     ${aasyslog_status}    Check TP From Aasyslog     file_name=Asys_ul_dl_udp.txt
    ${dl_list}    set variable if    ${aasyslog_status}    ${dl_list}    ${empty_list}
    ${ul_list}    set variable if    ${aasyslog_status}    ${ul_list}    ${empty_list}
    Run Keyword And Ignore Error    Power UE Check TP From Aasyslog    
    ...    log_path=Asys_ul_dl_udp.txt    if_ul=${True}    if_dl=${True}    exp_ul_tp=${220}    exp_dl_tp=${4360}
    [Teardown]  Commmon Case Teardown    total_result_list=${total_result_dict}     syslog_dl_list=${dl_list}    syslog_ul_list=${ul_list}
    ...    if_ul=${True}    if_dl=${True}    protocol=UDP

[1]5GC001937_OTA_8113_NSA_L3_Call_UL_TCP_Classical_8CC_1DRB_AEWB_Contiguous
    [Tags]  CRT_20B    CIT_TRUNK
    [Documentation]   Multi ue attach and continued start udp traffic at least 5min check tp via iperf
    [Setup]    robot_common_operations.Common Case Setup
    ${total_result_dict}    set variable   ${total_tp_orge}
    UE attach by Spark    ue_num=${ue_number}
    Start data traffic and Record TP Log and Aasys Log
    ...    ue_num=${ue_number}    ul_throughput=${ul_tput_tcp}    dl_throughput=${dl_tput_tcp}    ul_duration=${duration}
    ...    dl_duration=${duration}
    ...    protocol=tcp    if_ul=${True}    if_dl=${False}    file_name=Asys_ul_tcp.txt    time=${log_time}
    Stop data traffic and Stop Record TP Log and Aasys Log    ue_num=${ue_number}    if_ul=${True}    if_dl=${False}    protocol=tcp
    ...    spark_log_name=spark_ul_tcp
    ${total_result_list}    Get Each UE TP From Spark    ue_num=${ue_number}    spark_log_name=spark_ul_tcp    list_length=${total_count}
    ${total_result_dict}    set variable    ${total_result_list}[-1]
    ${aasyslog_status}     run keyword and return status    Check TP From Aasyslog     file_name=Asys_ul_tcp.txt
    ${dl_list}     ${ul_list}    run keyword if     ${aasyslog_status}    Check TP From Aasyslog     file_name=Asys_ul_tcp.txt
    ${dl_list}    set variable if    ${aasyslog_status}    ${dl_list}    ${empty_list}
    ${ul_list}    set variable if    ${aasyslog_status}    ${ul_list}    ${empty_list}
    Run Keyword And Ignore Error    Power UE Check TP From Aasyslog    
    ...    log_path=Asys_ul_tcp.txt    if_ul=${True}    if_dl=${False}    exp_ul_tp=${219}    exp_dl_tp=${4360}
    [Teardown]  Commmon Case Teardown    total_result_list=${total_result_dict}    syslog_dl_list=${dl_list}    syslog_ul_list=${ul_list}
    ...    if_ul=${True}    if_dl=${False}    protocol=TCP

[1]5GC001937_OTA_8113_NSA_L3_Call_ULDL_TCP_Classical_8CC_1DRB_AEWB_Contiguous
    [Tags]  CRT_20B    CIT_TRUNK
    [Documentation]   Multi ue attach and continued start udp traffic at least 5min check tp via iperf
    [Setup]    robot_common_operations.Common Case Setup
    ${total_result_dict}    set variable   ${total_tp_orge}
    UE attach by Spark    ue_num=${ue_number}
    Start data traffic and Record TP Log and Aasys Log
    ...    ue_num=${ue_number}    ul_throughput=${ul_tput_tcp}    dl_throughput=${dl_tput_tcp}    ul_duration=${duration}
    ...    dl_duration=${duration}
    ...    protocol=tcp    if_ul=${True}    if_dl=${True}    file_name=Asys_ul_dl_tcp.txt    time=${log_time}
    Stop data traffic and Stop Record TP Log and Aasys Log    ue_num=${ue_number}    if_ul=${True}    if_dl=${True}    protocol=tcp
    ...    spark_log_name=spark_ul_dl_tcp
    ${total_result_list}    Get Each UE TP From Spark    ue_num=${ue_number}    spark_log_name=spark_ul_dl_tcp    list_length=${total_count}
    ${total_result_dict}    set variable    ${total_result_list}[-1]
    ${aasyslog_status}     run keyword and return status    Check TP From Aasyslog     file_name=Asys_ul_dl_tcp.txt
    ${dl_list}     ${ul_list}    run keyword if     ${aasyslog_status}    Check TP From Aasyslog     file_name=Asys_ul_dl_tcp.txt
    ${dl_list}    set variable if    ${aasyslog_status}    ${dl_list}    ${empty_list}
    ${ul_list}    set variable if    ${aasyslog_status}    ${ul_list}    ${empty_list}
    Run Keyword And Ignore Error    Power UE Check TP From Aasyslog    
    ...    log_path=Asys_ul_dl_tcp.txt    if_ul=${True}    if_dl=${True}    exp_ul_tp=${219}    exp_dl_tp=${4360}
    [Teardown]  Commmon Case Teardown    total_result_list=${total_result_dict}    syslog_dl_list=${dl_list}    syslog_ul_list=${ul_list}
    ...    if_ul=${True}    if_dl=${True}    protocol=TCP

[1]5GC001937_OTA_8113_NSA_L3_Call_DL_TCP_Classical_8CC_1DRB_AEWB_Contiguous
    [Tags]  CRT_20B    CIT_TRUNK
    [Documentation]   Multi ue attach and continued start udp traffic at least 5min check tp via iperf
    [Setup]    robot_common_operations.Common Case Setup
    ${total_result_dict}    set variable   ${total_tp_orge}
    UE attach by Spark    ue_num=${ue_number}
    Start data traffic and Record TP Log and Aasys Log
    ...    ue_num=${ue_number}    ul_throughput=${ul_tput_tcp}    dl_throughput=${dl_tput_tcp}    ul_duration=${duration}
    ...    dl_duration=${duration}
    ...    protocol=tcp    if_ul=${False}    if_dl=${True}    file_name=Asys_dl_tcp.txt    time=${log_time}
    Stop data traffic and Stop Record TP Log and Aasys Log    ue_num=${ue_number}    if_ul=${False}    if_dl=${True}    protocol=tcp
    ...    spark_log_name=spark_dl_tcp
    ${total_result_list}    Get Each UE TP From Spark    ue_num=${ue_number}    spark_log_name=spark_dl_tcp    list_length=${total_count}
    ${total_result_dict}    set variable    ${total_result_list}[-1]
    ${aasyslog_status}     run keyword and return status    Check TP From Aasyslog     file_name=Asys_dl_tcp.txt
    ${dl_list}     ${ul_list}    run keyword if     ${aasyslog_status}    Check TP From Aasyslog     file_name=Asys_dl_tcp.txt
    ${dl_list}    set variable if    ${aasyslog_status}    ${dl_list}    ${empty_list}
    ${ul_list}    set variable if    ${aasyslog_status}    ${ul_list}    ${empty_list}
    Run Keyword And Ignore Error    Power UE Check TP From Aasyslog    
    ...    log_path=Asys_dl_tcp.txt    if_ul=${False}    if_dl=${True}    exp_ul_tp=${219}    exp_dl_tp=${4360}
    [Teardown]  Commmon Case Teardown    total_result_list=${total_result_dict}    syslog_dl_list=${dl_list}    syslog_ul_list=${ul_list}
    ...    if_ul=${False}    if_dl=${True}    protocol=TCP
