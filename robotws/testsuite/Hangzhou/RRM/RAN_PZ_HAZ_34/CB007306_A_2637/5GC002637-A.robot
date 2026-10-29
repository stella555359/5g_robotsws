# *** Settings ***
# Documentation
# ...    author: Jiang Hongyu
# ...    contact: hongyu.jiang@nokia-sbell.com
# ...    squad group: MMW_SG_04
# ...    feature : 5GC002637-A
# 
# Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource           ./Resources/5GC002637_common_keywords.robot
# Variables          ./Resources/5GC002637_modify_para.py
# Library            ./Resources/5GC002637_common_keywords.py
# 
# Suite Setup      Case Suite Setup
# Suite Teardown   run keywords    Suite Case Teardown    AND     robot_common_operations.Common Suite Teardown
# 
# 
# *** Test Cases ***
# [1]CB007306-SR-A-5GC002637-A_01_MAC_Layer_Thoughput_PM_Counter
#     [Tags]    CRT_22R2    CRT_TRUNK    CRT_22R4     CRT_22R3
#     [Setup]  robot_common_operations.Common case Setup
#     Modify SCF And Commission SCF    para_list=${case1_modify_para1}    modify_scf=case1_new.xml
#     ${old_counter_result_dict}    Get Multiple counter result    counter_id_dict=${case1_counter}
#     Start Traffic by Spark    ue_num=${1}   log_time=5s    spark_log=case1_spark    ul_throughput=${ul_tput_udp}
#     ...    dl_throughput=${dl_tput_udp}
#     ...    if_ul=${True}   if_dl=${True}    duration=${5}
#     ${dl_tp_max}    ${ul_tp_max}    ${dl_tp_sum}    ${ul_tp_sum}    Get Total UL And DL Max TP    spark_log=case1_spark
#     ...    row_list=${case1_row_list}    list_length=${300}
#     ...    ue_num=${1}
#     ${counter_result_dict}    ${new_counter_result_dict}    Calculate the total value of counter
#     ...    counter_id_dict=${case1_counter}
#     ...    old_counter_result_dict=${old_counter_result_dict}
#     Case1 Check Counter    counter_result_dict=${counter_result_dict}    dl_tp=${dl_tp_max}    ul_tp=${ul_tp_max}
#     ...    new_counter_result_dict=${new_counter_result_dict}
#     [Teardown]  Commmon Case Teardown
# 
# [1]CB007306-SR-A-5GC002637-A_03_DL_Data_Thoughput_Counter
#     [Tags]    CRT_22R2    CRT_TRUNK     CRT_22R4     CRT_22R3
#     [Setup]  robot_common_operations.Common case Setup
#     Modify SCF And Commission SCF    para_list=${case3_modify_para1}    modify_scf=case3_new.xml
#     ${old_counter_result_dict}    Get Multiple counter result    counter_id_dict=${case3_counter}
#     Start Traffic by Spark    ue_num=${1}   log_time=5s    spark_log=case3_spark    ul_throughput=${ul_tput_udp}
#     ...    dl_throughput=${dl_tput_udp}    if_ul=${False}   if_dl=${True}    duration=${5}
#     ${dl_5G_tp_max}    ${ul_5G_tp_max}    ${dl_tp_sum}    ${ul_tp_sum}    Get Total UL And DL Max TP    spark_log=case3_spark
#     ...    row_list=${case3_row_list1}    list_length=${300}    ue_num=${1}
#     ${dl_4G_tp_max}    Capture Snapshot and Get 4G TP
#     ${counter_result_dict}    ${new_counter_result_dict}    Calculate the total value of counter
#     ...    counter_id_dict=${case3_counter}    old_counter_result_dict=${old_counter_result_dict}
#     Case3 Check Counter    dl_5G_tp=${dl_5G_tp_max}    dl_4G_tp=${dl_4G_tp_max}
#     ...    new_counter_result_dict=${new_counter_result_dict}    traffic_time=${5}
#     [Teardown]  Commmon Case Teardown
# 
# [1]CB007306-SR-A-5GC002637-A_05_UL_RLC_Thoughput_Counter
#     [Tags]    CRT_22R2    CRT_TRUNK     CRT_22R4     CRT_22R3
#     [Setup]  robot_common_operations.Common case Setup
#     Modify SCF And Commission SCF    para_list=${case3_modify_para1}    modify_scf=case5_new.xml
#     ${old_counter_result_dict}    Get Multiple counter result    counter_id_dict=${case5_counter}
#     Start Traffic by Spark    ue_num=${1}   log_time=5s    spark_log=case5_spark    ul_throughput=${ul_tput_udp}
#     ...    dl_throughput=${dl_tput_udp}    if_ul=${True}   if_dl=${False}    duration=${5}
#     ${dl_5G_tp_max}    ${ul_5G_tp_max}    ${dl_tp_sum}    ${ul_tp_sum}    Get Total UL And DL Max TP    spark_log=case5_spark
#     ...    row_list=${case5_row_list}    list_length=${300}    ue_num=${1}
#     ${counter_result_dict}    ${new_counter_result_dict}    Calculate the total value of counter
#     ...    counter_id_dict=${case5_counter}    old_counter_result_dict=${old_counter_result_dict}
#     Case5 Check Counter    ul_total_5G_tp=${ul_tp_sum}    new_counter_result_dict=${new_counter_result_dict}
#     [Teardown]  Commmon Case Teardown
# 
# 
# 
# 
# 
# 
# 
# 
# 
