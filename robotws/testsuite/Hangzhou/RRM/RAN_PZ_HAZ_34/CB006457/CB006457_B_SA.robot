# *** Settings ***
# Suite Setup       Run Keywords    robot_common_operations.Common Suite Setup
# ...    AND    Test suite prepare
# #...    AND        CB006457 SA case Preparation
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
# @{nbrUlDlSF_list}    6  2  10  0.1
# @{nbrQoS_list}   7    8
# @{nbrDL_list}    500000    200000
# @{nbrUL_list}    60000    20000
# @{nbrQoS_list1}   7    8
# @{nbrDL_list1}    100000    100000
# @{nbrUL_list1}    10000    10000
# @{nbrQoS_list2}   8
# @{nbrDL_list2}    200000
# @{nbrUL_list2}    20000
# @{nbrUlDlSF_list2}    2  8  0.5  5
# @{nbrDL_list3}    200000    500000
# @{nbrUL_list3}    20000   80000
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
# *** Test Cases ***
# [1]CB006457-B_B1_01_Feature_activation_Deactiveation_nbrUlDlSF_SingleUE_Multi_NoneGBR_SA_PM_Counter
#     Adjust HBTE ATT Values    ${SA_HBTE}
#     Online modify parameters "nbrUlDlSF" for multiArpBasedParam
#     Online modify parameters "nrDrbMacDN" for NRDRB    NRDRB_ID=12    NRDRB_MAC_ID=2
#     Enable CB006457-B online
#     UE Prepare
#     Set test variable    ${pcap_log_name}    CB006457-B_B1_01.pcap
#     Get pcap file for master during UE attach    log_path=/tmp   log_name=${pcap_log_name}
#     ${get_counter}    Run keyword and ignore error    Check NBR Counters for multi nonGBR     exp_C03506=2    exp_C03507=2
#     Run keyword if    '${get_counter}[0]'=='FAIL'    Run Keywords    sleep   ${wait_time_next}min
#     ...    AND    Check NBR Counters for multi nonGBR    exp_C03506=2    exp_C03507=2
#     UE start traffic for period    tp_direction=dl    dl_tp=1000M    iperf_port_dl=50227
#     UE start traffic for period    tp_direction=dl    dl_tp=1000M    iperf_port_dl=50228
#     UE check throughput by syslog    tp_direction=dl    exp_dl_tp=800
#     #${qos}    ${schedulWeight}    Get the schedulWeight of multi DRB
#     ${qos}    ${nbrdl}    ${nbrul}    Get the NBR of multi DRB
#     Check the nbr of specific qosid is as expected
#     ...    qos=${nbrQoS_list}    nbrdl=${nbrdl}    nbrul=${nbrul}    exp_nbrdl=${nbrDL_list}    exp_nbrul=${nbrUL_list}
#     Stop traffic for SA multi port and detach UE
#     Disable CB006457 online
#     Set test variable    ${pcap_log_name}    CB006457-B_B1_01_disable.pcap
#     Get pcap file for master during UE attach    log_path=/tmp   log_name=${pcap_log_name}
#     ${qos}    ${schedulWeight}    Get the schedulWeight of multi DRB
#     ${qos}    ${nbrdl}    ${nbrul}    Get the NBR of multi DRB
#     Check the nbr of specific qosid is as expected
#     ...    qos=${nbrQoS_list}    nbrdl=${nbrdl}    nbrul=${nbrul}    exp_nbrdl=${nbrDL_list1}    exp_nbrul=${nbrUL_list1}
#     UE start traffic for period    tp_direction=dl    dl_tp=1000M    iperf_port_dl=50227
#     UE start traffic for period    tp_direction=dl    dl_tp=1000M    iperf_port_dl=50228
#     UE check throughput by syslog    tp_direction=dl    exp_dl_tp=800
#     #Enable CB006457-B online
# 
# [1]CB006457-B_B1_05_ArpBasedQosScaling_nbrUlDlSF_MultiUE_normalNonGBR_NBRNonGBR_GBR_SA
#     Online modify parameters "nrDrbMacDN" for NRDRB    NRDRB_ID=12    NRDRB_MAC_ID=1
#     Online modify parameters "nbrUlDlSF" for multiArpBasedParam
#     Enable CB006457-B online
#     #Online modify parameters "nbrUlDlSF" for multiArpBasedParam
#     Set test variable    ${pcap_log_name}    CB006457-B_B1_05.pcap
#     UE Prepare
#     Get pcap file for master during UE attach    log_path=/tmp   log_name=${pcap_log_name}
#     ${get_counter}    Run keyword and ignore error    Check NBR Counters for multi nonGBR    exp_C03506=1    exp_C03507=1
#     Run keyword if    '${get_counter}[0]'=='FAIL'    Run Keywords    sleep   ${wait_time_next}min
#     ...    AND    Check NBR Counters for multi nonGBR    exp_C03506=1    exp_C03507=1
#     UE start traffic for period    tp_direction=dl    dl_tp=1000M    iperf_port_dl=50227
#     UE start traffic for period    tp_direction=dl    dl_tp=1000M    iperf_port_dl=50228
#     UE start traffic for period    tp_direction=dl    dl_tp=40M    iperf_port_dl=50224
#     UE check throughput by syslog    tp_direction=dl    exp_dl_tp=800
#     #${qos}    ${schedulWeight}    Get the schedulWeight of multi DRB
#     ${qos}    ${nbrdl}    ${nbrul}    Get the NBR of multi DRB
#     Check the nbr of specific qosid is as expected
#     ...    qos=${nbrQoS_list2}    nbrdl=${nbrdl}    nbrul=${nbrul}    exp_nbrdl=${nbrDL_list2}    exp_nbrul=${nbrUL_list2}
# 	
# [1]CB006457-B_B1_04_ArpBasedQosScaling_nbrUlDlSF_MultiUE_Different5QI_Different_Arp_SA
#     Online modify parameters "nrDrbMacDN" for NRDRB    NRDRB_ID=12    NRDRB_MAC_ID=2
#     Online modify parameters "nbrUlDlSF" for multiArpBasedParam    nbrUlDlSF_list=${nbrUlDlSF_list2}
#     Enable CB006457-B online
#     UE Prepare
#     Set test variable    ${pcap_log_name}    CB006457-B_B1_04.pcap
#     Get pcap file for master during UE attach    log_path=/tmp   log_name=${pcap_log_name}
#     ${qos}    ${schedulWeight}    Get the schedulWeight of multi DRB
#     ${qos}    ${nbrdl}    ${nbrul}    Get the NBR of multi DRB
#     Check the nbr of specific qosid is as expected
#     ...    qos=${nbrQoS_list}    nbrdl=${nbrdl}    nbrul=${nbrul}    exp_nbrdl=${nbrDL_list3}    exp_nbrul=${nbrUL_list3}
# 	
# [1]CB006457-B_B1_03_ArpBasedQosScaling_nbrUlDlSF_MultiUE_Same5QI_Different_Arp_UL_SA
#     Enable CB006457-B online
#     UE Prepare
#     Set test variable    ${pcap_log_name}    CB006457-B_B1_03.pcap
#     Get pcap file for master during UE attach    log_path=/tmp   log_name=${pcap_log_name}
#     UE start traffic for period    tp_direction=ul    ul_tp=100M    iperf_port_ul=43107
#     UE start traffic for period    tp_direction=ul    ul_tp=100M    iperf_port_ul=43108
#     UE check throughput by syslog    tp_direction=ul    exp_ul_tp=70
#     Run Keyword And Ignore Error    UE stop traffic    tp_direction=ul    iperf_port_ul=43107
#     Run Keyword And Ignore Error    UE stop traffic    tp_direction=ul    iperf_port_ul=43108
#     ${qos}    ${nbrdl}    ${nbrul}    Get the NBR of multi DRB
#     Check the nbr of specific qosid is as expected
#     ...    qos=${nbrQoS_list}    nbrdl=${nbrdl}    nbrul=${nbrul}    exp_nbrdl=${nbrDL_list3}    exp_nbrul=${nbrUL_list3}