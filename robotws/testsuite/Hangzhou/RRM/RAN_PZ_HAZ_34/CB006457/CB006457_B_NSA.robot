# *** Settings ***
# Suite Setup       Run Keywords    robot_common_operations.Common Suite Setup
# ...    AND    Test suite prepare
# #...    AND        CB006457 NSA case Preparation
# Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown
# Test Setup        Run Keywords    robot_common_operations.Common Case Setup
# Test Teardown     Run Keywords    robot_common_operations.Common Case Teardown
# ...    AND    Stop traffic for NSA multi port and detach UE
# 
# Resource    ./Resources/CB006457_common_keywords.robot
# Variables   ./Resources/CB006457_scf_modify.py
# Resource    ./Resources/CB006457_common_keywords_counter.robot
# 
# Documentation
# ...    author: guo zhenzhen
# ...    contact: zhenzhen.guo@nokia-sbell.com
# ...    squad group: MMW3
# ...    feature : CB006457
# 
# Force Tags    CRT_TRUNK
# 
# *** Variables ***
# @{nbrUlDlSF_list}    4    7
# @{nbrQoS_list}    7    8
# @{nbrDL_list}    50    200    350    50
# @{nbrUL_list}    10    40    70    10
# ${MRBTS_ID}    ${tl.gnbs[0].global_bts_id}
# ${NRBTS_ID}    ${tl.gnbs[0].instance_id}
# 
# *** Test Cases ***
# [1]CB006457-B_B2_01_ArpBasedQosScaling_nbrUlDlSF_MultiUE_Different5QI_Different_Arp_NSA
#     [Documentation]     Case is running in NSA sigle UE multi nonGBR+GBR testline  as multi UE is limited
#     Enable CB006457-B online
#     Online modify parameters "nbrUlDlSF" for multiArpBasedParam    nbrUlDlSF_list=${nbrUlDlSF_list}
#     Online modify parameters NBR for MAC    MAC_ID=1    nbrDl=50    nbrUl=10
# 	UE Prepare
#     Set test variable    ${pcap_log_name}    CB006457-B_B2_01.pcap
#     Get pcap file for master during UE attach    log_path=/tmp   log_name=${pcap_log_name}    is_right_rack=yes
#     ${get_counter}    Run keyword and ignore error    Check NBR counters for multi nonGBR
#     ...    counter1=M55115C03506    counter2=M55115C03507    exp_C03506=4    exp_C03507=4
#     Run keyword if    '${get_counter}[0]'=='FAIL'    Run Keywords    sleep   ${wait_time_next}min
#     ...    AND    Check NBR counters for multi nonGBR    counter1=M55115C03506    counter2=M55115C03507    exp_C03506=4    exp_C03507=4
# 	UE start traffic for period    tp_direction=dl    dl_tp=1000M    iperf_port_dl=50217
#     UE start traffic for period    tp_direction=dl    dl_tp=1000M    iperf_port_dl=50218
#     UE check throughput by syslog    tp_direction=dl    exp_dl_tp=500
#     ${qos1}    ${schedulWeight}    Get the schedulWeight of multi DRB
# 	${qos}    ${nbrdl}    ${nbrul}    Get the NBR of multi DRB
#     Check the NBRDL of multi DRB for NSA as expected    qos=${qos}    nbrdl=${nbrdl}    exp_nbrdl=${nbrDL_list}
#     Check the NBRUL of multi DRB for NSA as expected    qos=${qos}    nbrul=${nbrul}    exp_nbrul=${nbrUL_list}
