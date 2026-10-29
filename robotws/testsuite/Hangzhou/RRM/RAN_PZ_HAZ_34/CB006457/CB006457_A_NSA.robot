# *** Settings ***
# Suite Setup       Run Keywords    robot_common_operations.Common Suite Setup
# ...    AND    Test suite prepare
# ...    AND    CB006457 NSA case Preparation
# Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown
# Test Setup        Run Keywords    robot_common_operations.Common Case Setup
# Test Teardown     Run Keywords    robot_common_operations.Common Case Teardown
# ...    AND    Stop traffic for NSA multi port and detach UE
# 
# Resource    ./Resources/CB006457_common_keywords.robot
# Resource    ./Resources/CB006457_common_keywords_counter.robot
# Variables   ./Resources/CB006457_scf_modify.py
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
# @{schedulingWeightSF_list}    1  2  10  1
# @{arpPrioLev_list}    6  7  8  9
# @{expected_weight1}    20  20  30  1
# @{expected_weight2}    20  10  5  1
# 
# *** Test Cases ***
# [1]CB006457-A_B2_02_ArpBasedQosScaling_SchedulingWeightSF_Single_Ue_Multi_NoneGBR_NSA
# 	UE Prepare
# 	Attach UE
#     UE start traffic    tp_direction=dl    dl_tp=1000M    iperf_port_dl=50217
# 	UE start traffic    tp_direction=dl    dl_tp=1000M    iperf_port_dl=50218
#     UE check throughput by syslog    tp_direction=dl    exp_dl_tp=500
#     Wait for one counter period     interval_time=5min
#     Wait for one counter period     interval_time=5min
# 	Set PMQAP related counter path for multi nonGBR
#     Check BTS Counter M55352C01002 and M55352C01003 for multi nonGBR    ratio=1.5
# 
# [1]CB006457-A_B2_01_Feature_Activation_Deactivation_SchedulingWeightSF_Single_Ue_NoneGBR_NSA
# 	Enable CB006457 online
# 	#Online modify parameters "schedulingWeightSF" and "arpPrioLev"
# 	UE Prepare
#     Set test variable    ${pcap_log_name}    CB006457-A_B2_01_enable.pcap
# 	Get pcap file for master during UE attach    log_path=/tmp   log_name=${pcap_log_name}    is_right_rack=yes
#     ${qos1}    ${schedulWeight1}    Get the schedulWeight of multi DRB
# 	Check the scheduleight of multi DRB for NSA as expected
#     ...    qos=${qos1}    schedulWeight=${schedulWeight1}    expected_weight=${expected_weight1}
# 	Detach UE
# 	Disable CB006457 online
#     Set test variable    ${pcap_log_name}    CB006457-A_B2_01_disable.pcap
# 	Get pcap file for master during UE attach    log_path=/tmp   log_name=${pcap_log_name}    is_right_rack=yes
#     ${qos2}    ${schedulWeight2}    Get the schedulWeight of multi DRB
# 	Check the scheduleight of multi DRB for NSA as expected
#     ...    qos=${qos2}    schedulWeight=${schedulWeight2}    expected_weight=${expected_weight2}