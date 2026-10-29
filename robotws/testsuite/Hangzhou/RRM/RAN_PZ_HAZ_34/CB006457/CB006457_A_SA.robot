# *** Settings ***
# Suite Setup       Run Keywords    robot_common_operations.Common Suite Setup
# ...    AND    Test suite prepare
# ...    AND        CB006457 SA case Preparation
# Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown
# Test Setup        Run Keywords    robot_common_operations.Common Case Setup
# Test Teardown     Run Keywords    robot_common_operations.Common Case Teardown
# ...    AND    Stop traffic for SA multi port and detach UE
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
# 
# ${5QI7_DRB}    ${MR_NR_BTS_NAME}/NRDRB-12
# ${schedulWeight}     10
# ${schedulingWeightSF}    2
# ${btsname}    SBTS_4G_FXED
# @{expected_weight}    60  30  1  5
# ${att_ipaddr}               ${tl.attenuator.ip_addr}
# ${att_port_number}         ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
# ${att_port_0}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
# ${att_port_1}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
# ${att_port_2}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
# ${att_port_3}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
# ${att_port_4}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[4].port_no}
# ${att_port_5}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[5].port_no}
# ${att_port_6}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[6].port_no}
# ${att_port_7}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[7].port_no}
# ${att_port_8}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[8].port_no}
# ${att_port_9}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[9].port_no}
# ${att_port_10}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[10].port_no}
# ${att_port_11}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[11].port_no}
# ${att_api_port}             ${tl.attenuator.port}
# ${model}                     ${tl.attenuator.model}
# ${vendor}                   HBTE
# 
# 
# *** Test Cases ***
# [1]CB006457-A_B1_03_ArpBasedQosScaling_SchedulingWeightSF_Single_Ue_Multi_NoneGBR_SA_PM_Counter
#     Adjust HBTE ATT Values    ${SA_HBTE}
# 	Online modify parameters "schedulingWeightSF" for first arp   new_value=2
# 	UE Prepare
#     Set test variable    ${pcap_log_name}    CB006457-A_B1_03.pcap
#     Get pcap file for master during UE attach    log_path=/tmp   log_name=${pcap_log_name}
#     ${qos}    ${schedulWeight}    Get the schedulWeight of multi DRB
# 	UE start traffic for period    tp_direction=dl    dl_tp=1000M    iperf_port_dl=50227    duration=420s
#     UE start traffic for period    tp_direction=dl    dl_tp=1000M    iperf_port_dl=50228    duration=417s
#     UE check throughput by syslog    tp_direction=dl    exp_dl_tp=800
# 	Set PMQAP related counter path for multi nonGBR
#     Check the scheduleight of specific qosid is as expected
#     ...    qos=${qos}    qosId=7    schedulWeight=${schedulWeight}    Weight_value=20
# 	Check the scheduleight of specific qosid is as expected
#     ...    qos=${qos}    qosId=8    schedulWeight=${schedulWeight}    Weight_value=30
#     Wait for one counter period     interval_time=5min
#     Run Keyword And Ignore Error    Check BTS Counter M55352C01002 and M55352C01003 for multi nonGBR    ratio=1.5
# 	sleep    5min
# 	Run Keyword And Ignore Error    Check BTS Counter M55352C01002 and M55352C01003 for multi nonGBR    ratio=1.5
# 
# [1]CB006457-A_B1_05_ArpBasedQosScaling_SchedulingWeightSF_MultiUE_NoneGBR_Alongwith_GBR_SA
#     [Documentation]    case is running in SA sigle UE multi nonGBR+GBR testline as multi UE is limited
#     #Delta Commission Parameters    ${PARAMS_FOR_6457}
# 	Online modify parameters "schedulingWeightSF" for first arp   new_value=6
# 	UE Prepare
# 	Set test variable    ${pcap_log_name}    CB006457-A_B1_05.pcap
# 	#Online modify parameters "schedulWeight" of DRB    DRB_dist=${5QI7_DRB}    new_value=10
#     Get pcap file for master during UE attach    log_path=/tmp   log_name=${pcap_log_name}
#     ${qos}    ${schedulWeight}    Get the schedulWeight of multi DRB
# 	Check the scheduleight of multi DRB as expected    qos=${qos}    schedulWeight=${schedulWeight}    expected_weight=${expected_weight}
# 
# [1]CB006457-A_B1_06_ArpBasedQosScaling_SchedulingWeightSF_MultiUE_Different5QI_Different_ARP_SA_PM_Counter
#     [Documentation]     Case is running in SA sigle UE multi nonGBR+GBR testline  as multi UE is limited
#     ...                 And legacy counter did not update when buffer is full, so TA check counter is optional
#     Online modify parameters "schedulingWeightSF" for first arp   new_value=2
# 	UE Prepare
#     Set test variable    ${pcap_log_name}    CB006457-A_B1_06.pcap
#     Get pcap file for master during UE attach    log_path=/tmp   log_name=${pcap_log_name}
#     ${qos}    ${schedulWeight}    Get the schedulWeight of multi DRB
# 	UE start traffic for period    tp_direction=dl    dl_tp=1000M    iperf_port_dl=50227    duration=360s
#     UE start traffic for period    tp_direction=dl    dl_tp=1000M    iperf_port_dl=50228    duration=357s
#     UE start traffic for period    tp_direction=dl    dl_tp=40M    iperf_port_dl=50224    duration=354s
#     UE check throughput by syslog    tp_direction=dl    exp_dl_tp=800
#     Check the scheduleight of specific qosid is as expected
#     ...    qos=${qos}    qosId=7    schedulWeight=${schedulWeight}    Weight_value=20
# 	Check the scheduleight of specific qosid is as expected
#     ...    qos=${qos}    qosId=8    schedulWeight=${schedulWeight}    Weight_value=30
#     Check the scheduleight of specific qosid is as expected
#     ...    qos=${qos}    qosId=4    schedulWeight=${schedulWeight}    Weight_value=1
# 	Check the scheduleight of specific qosid is as expected
#     ...    qos=${qos}    qosId=5    schedulWeight=${schedulWeight}    Weight_value=5
# 	Set PMQAP related counter path for multi nonGBR
#     Set PMQAP related counter path for GBR4
#     Wait for one counter period     interval_time=5min
# 	Run Keyword And Ignore Error    Check BTS Counter M55352C01002 and M55352C01003 for GBR4
#     Run Keyword And Ignore Error    Check BTS Counter M55352C01002 and M55352C01003 for multi nonGBR    ratio=1.5
# 
