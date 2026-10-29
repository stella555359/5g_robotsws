# *** Settings ***
# Documentation
# ...    author: Jiang Hongyu
# ...    contact: hongyu.jiang@nokia-sbell.com
# ...    squad group: MMW_SG_04
# ...    feature : CB009010
# 
# Resource    ./Resources/CB009010_common_keyword.robot
# Library     ../CB007306_OTA/Resources/CB007306_common.py
# Variables   ./Resources/CB009010_modify_para.py
# 
# 
# Suite Setup       CB009010 Suite Setup
# Suite Teardown    CB009010 Suite Teardown
# 
# 
# *** Test Cases ***
# [1]CB009010_01_NSA_FR2_Inter_freq_inter_gnb_HO_with_ANR_succesfully_with_hoForPlmnResForOpUseEnabled_true
#     [Setup]     Case Setup
#     Start Collect Tcpdump    host_ip=${eNB_ip}    log_name=${case_log_name}.pcap
#     Prepare UE and Attach UE
#     Set X and Y PositionMotion    ip=${Turntable_PB_ip2}     if_X=${False}    start_Y=${90}     end_Y=${90}    exceed=${360}    speed_Y=${3}
#     sleep    5s
#     Set X and Y PositionMotion    ip=${Turntable_PB_ip1}     if_X=${False}    start_Y=${360}     end_Y=${360}    exceed=${360}    speed_Y=${3}
#     Stop Collect Tcpdump    host_ip=${eNB_ip}    log_name=${case_log_name}.pcap    time=30s
#     MTK UE detach
#     Check wireshark log Parameter    sgnb_chg_ho_message=${tcpdump_check_para}    message_dict=${message_flow}
#     Check Node Parameter
#     [Teardown]  Case Teardown
# 
# *** Keywords ***
# 
# 
# 
# 
# 
