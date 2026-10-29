# *** Settings ***
# Force Tags    PY36
# Documentation    author：Hongyu Jiang
# ...              contact: hongyu.jiang@nokia-sbell.com
# ...              squad group: mmw_SG_04
# 
# Resource          ./resources/5GC001937_mmw4_common_keyword_new.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Variables         ./resources/5GC001937_mmw4_modify_para.py
# 
# Suite Setup       Case Suite Setup
# Suite Teardown    Suite Case Teardown
# 
# 
# *** Variables ***
# 
# 
# *** Test Cases ***
# [1]5GC001937_OTA_8113_NSA_L3_Call_ULDL_TCP_Classical_8CC_1DRB_AEWB_Contiguous
#     [Tags]  CRT_20B    CIT_TRUNK
#     [Documentation]   Multi ue attach and continued start udp traffic at least 5min check tp via iperf
#     [Setup]    robot_common_operations.Common Case Setup
#     Get Theoretical TP From NRDIM
#     Modify Parameters with json    input_list=${gnb_para1}
#     Prepare MultiUE And Attach    multiue_config_direction=${TLCommonConfig["MultiUECFG"]}
#     MultiUE Start UDP Traffic    ul_tp=300    if_ul=${True}    if_dl=${True}
#     Start Spark TP Log
#     sleep    30s
#     Check Throught From Asslog    log_path=${OUTPUT_DIR}/${TEST NAME}    duration=5m    ul_tp=${expect_4cc_ul_tp}    dl_tp=${expect_4cc_dl_tp}
#     ...    target_avg_percent=0.98    min_percent=0.85    if_ul=${True}    if_dl=${True}    ul_list=${4cc_cell_list}    dl_list=${4cc_cell_list}
#     Stop Spark TP Log
#     MultiUE Stop UDP Traffic    if_ul=${True}    if_dl=${True}
#     MultiUE Detach
#     Calculate Total TP From Spark Log    ue_num=${2}
#     [Teardown]  Commmon Case Teardown    input_list=${gnb_para2}
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
