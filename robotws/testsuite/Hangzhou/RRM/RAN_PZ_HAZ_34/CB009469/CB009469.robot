# *** Settings ***
# Documentation
# ...    author: Jiang Hongyu
# ...    contact: hongyu.jiang@nokia-sbell.com
# ...    squad group: MMW_SG_04
# ...    feature : CB009469
# 
# 
# Resource    ./Resources/CB009469_common_keywords.robot
# Library     ./Resources/CB009469_common_keywords.py
# Variables   ./Resources/CB009469_modify_para.py
# 
# 
# Suite Setup       CB009469 Suite Setup
# Suite Teardown    CB009469 Suite Teardown
# 
# *** Test Cases ***
# [1]CB009469_F_06_8CCDL_4CCUL_UL_counters
#     [Tags]  CRT_TRUNK
#     [Setup]    robot_common_operations.Common case Setup
#     Modify Parameters with json    input_list=${gnb_para1}    bts_host=${gNB_ip}
#     Check GNB on air    bts_host=${gNB_ip}
#     Wait for counter to be gathered after guard peroid    if_current_time=${True}
#     sleep    120s
#     ${counter_result_dict1}    Get Multiple counter result    counter_id_dict=${case6_counter}    host_ip=${gNB_ip} 
#     ${5Grach_time_ing}    Capture Syslog And Start Traffic    file_name=data_ul.txt    if_ul=${True}    if_dl=${False}
#     ...    ul_throughput=300M    time=30s
#     Wait for counter to be gathered after guard peroid    if_current_time=${True}
#     sleep    2min
#     Wait for counter to be gathered after guard peroid    if_current_time=${True}
#     sleep    120s
#     ${counter_result_dict2}    Get Multiple counter result    counter_id_dict=${case6_counter}    host_ip=${gNB_ip}
#     Check Multiple counter result    befor_counter_dict=${counter_result_dict1}    after_counter_dict=${counter_result_dict2}    Toler=5
#     ...    check_counter_dict=${case6_check_counter}    file_name=data_ul.txt    if_ul=${True}    if_dl=${False}    counter_id=M55316C06003
#     ...    cell_id=${cell_id}    attach_rach_time=${5Grach_time_ing}
#     [Teardown]    Case Teardown
# 
# 
# [1]CB009469_F_07_8CCDL_4CCUL_DL_counters
#     [Tags]  CRT_TRUNK
#     [Setup]    robot_common_operations.Common case Setup
#     Modify Parameters with json    input_list=${gnb_para1}    bts_host=${gNB_ip}
#     Check GNB on air    bts_host=${gNB_ip}
#     Wait for counter to be gathered after guard peroid    if_current_time=${True}
#     sleep    120s
#     ${counter_result_dict1}    Get Multiple counter result    counter_id_dict=${case7_counter}    host_ip=${gNB_ip}
#     ${5Grach_time_ing}    Capture Syslog And Start Traffic    file_name=data_dl.txt    if_ul=${False}    if_dl=${True}
#     ...    dl_throughput=2200M    time=30s
#     Wait for counter to be gathered after guard peroid    if_current_time=${True}
#     sleep   2min
#     Wait for counter to be gathered after guard peroid    if_current_time=${True}
#     sleep    120s
#     ${counter_result_dict2}    Get Multiple counter result    counter_id_dict=${case7_counter}    host_ip=${gNB_ip}
#     Check Multiple counter result    befor_counter_dict=${counter_result_dict1}    after_counter_dict=${counter_result_dict2}    Toler=5
#     ...    check_counter_dict=${case7_check_counter}    file_name=data_dl.txt    if_ul=${False}    if_dl=${True}    counter_id=M55316C05007
#     ...    cell_id=${cell_id}    attach_rach_time=${5Grach_time_ing}
#     [Teardown]    Case Teardown
# 
# 
# [1]CB009469_F_08_8CCDL_4CCUL_Cells_deletion_and_addtion_online
#     [Tags]  CRT_TRUNK
#     [Setup]    robot_common_operations.Common case Setup
#     Modify Parameters with json    input_list=${gnb_para1}    bts_host=${gNB_ip}
#     Check GNB on air    bts_host=${gNB_ip}
#     Start Traffic And Check Tp    ul_throughput=200    dl_throughput=2050    ul_list=${all_cell_id_list}   dl_list=${all_cell_id_list}
#     Add Or Delete Cell By WebUI    if_add=${False}
#     Start Traffic And Check Tp    ul_throughput=200    dl_throughput=2050    ul_list=${all_cell_id_list1}   dl_list=${all_cell_id_list1}
#     Add Or Delete Cell By WebUI    if_add=${True}
#     Start Traffic And Check Tp    ul_throughput=200    dl_throughput=2050    ul_list=${all_cell_id_list}   dl_list=${all_cell_id_list}
#     [Teardown]    Case Teardown
# 
# 
# [1]CB009469_F_09_8CCDL_4CCUL_sCellActivationMethod_blind
#     [Tags]  CRT_TRUNK
#     [Setup]    robot_common_operations.Common case Setup
#     Modify Parameters with json    input_list=${gnb_para2}    bts_host=${gNB_ip}
#     Check GNB on air    bts_host=${gNB_ip}
#     Wait for counter to be gathered after guard peroid    if_current_time=${True}
#     sleep    120s
#     ${counter_result_dict1}    Get Multiple counter result    counter_id_dict=${case9_counter}    host_ip=${gNB_ip}
#     ${5Grach_time_ing}    Capture Syslog And Attach UE    file_name=data_attach.txt    time=30s
#     Wait for counter to be gathered after guard peroid    if_current_time=${True}
#     sleep   2min
#     Wait for counter to be gathered after guard peroid    if_current_time=${True}
#     sleep    120s
#     ${counter_result_dict2}    Get Multiple counter result    counter_id_dict=${case9_counter}    host_ip=${gNB_ip}
#     Check Multiple counter result    befor_counter_dict=${counter_result_dict1}    after_counter_dict=${counter_result_dict2}    Toler=5
#     ...    check_counter_dict=${case7_check_counter}    file_name=data_attach.txt    if_ul=${False}    if_dl=${False}    cell_id=${cell_id}
#     ...    attach_rach_time=${5Grach_time_ing}
#     [Teardown]    run keywords    robot_common_operations.Common Case Teardown    AND    CI_interface.Common Case Teardown
# 
# 
# 
# 
# 
# 
