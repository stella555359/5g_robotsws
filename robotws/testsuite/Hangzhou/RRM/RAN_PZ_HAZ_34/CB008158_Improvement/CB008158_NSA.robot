# *** Settings ***
# #Suite Setup       Run Keywords    robot_common_operations.Common Suite Setup
# #Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown
# #Test Setup        Run Keywords    robot_common_operations.Common Case Setup
# #Test Teardown     Run Keywords    robot_common_operations.Common Case Teardown
# 
# Resource    ./Resources/CB008158_common_keywords.robot
# Variables   ./Resources/CB008158_scf_modify.py
# 
# Documentation
# ...    author: Luo Tina
# ...    contact: tina.luo@nokia-sbell.com
# ...    squad group: MMW3
# ...    feature : CB008158
# 
# Force Tags    CRT_TRUNK
# 
# *** Variables ***
# ${scf_name}    CB008158_FULL_SCF.xml
# ${5QI_value}    7
# *** Test Cases ***
# 
# 
# 
# [1]CB008158_NSA_PART_D_Related_DL_drx_Counters_checking
#     CB008158 NSA case Preparation      scf_name=SCF_SBTS00.xml
# 	run keyword and continue on failure    QCI-7 small traffic condition
#     run keyword and continue on failure    QCI-7 big traffic condition		
#     [Teardown]    Run Keyword If Test Failed   Test Case teardown in case failure
# 
# 
# 
# *** Keywords ***	
# 
# QCI-7 small traffic condition	
# 	UE Prepare
# 	Attach UE
#     UE start traffic    tp_direction=dl    dl_tp=100k   iperf_port_dl=50227
#     Wait for one counter period     interval_time=5min
# 	Log To Console    \n ### QCI 7 small traffic counters ###
# 	Get all DL counter value for the Corresponding 5QI via admin_cli   5QI_ID=17
# 	Set DL KPI Calculation formula
#     power_ue.Stop traffic   direction=dl    ue_index=${0}    ue_type=${UE_TYPE}   iperf_port=50227
# 	[Teardown]    Detach UE
# 	
# QCI-7 big traffic condition	
# 	UE Prepare
# 	Attach UE
#     UE start traffic    tp_direction=dl    dl_tp=1500M   iperf_port_dl=50227
#     Wait for one counter period     interval_time=5min
# 	Log To Console    \n ### QCI 7 big traffic counters ###
# 	Get all DL counter value for the Corresponding 5QI via admin_cli   5QI_ID=17
# 	Set DL KPI Calculation formula
#     power_ue.Stop traffic   direction=dl    ue_index=${0}    ue_type=${UE_TYPE}   iperf_port=50227
# 	[Teardown]    Detach UE	
# 
# 
# 		
# 	
# Check kpi or counters for F1 related counter
#     should be true    ${value_M55350C00025}==0
#     should be true    ${value_M55159C00003}==0
# 
# check DL kpi for 5QI-7 big traffic condition
#     Check kpi or counters for F1 related counter
# 	should be true     5<${NR_5906a}<20	
# 	should be true     5<${NR_5907a}<20
# 	should be true     5<${NR_5909a}<20
# 	should be true     5<${NR_59010a}<20	
# 	should be true     5<${NR_59011a}<20
# 	should be true     5<${NR_2330a}<20
# 	should be true     5<${NR_2331a}<20	
# 	should be true     5<${NR_2334a}<20		
# 	should be true     5<${NR_2335a}<20	
# 	should be true     5<${NR_2336a}<20		
# 
# check DL kpi for 5QI-4 traffic condition
# 
# 	should be true    ${value_M55158C00001}==0
# 	should be true    ${value_M55158C00002}==0
# 	should be true    ${value_M55158C00003}==0		
#     Check kpi or counters for F1 related counter
# 	
# check DL kpi for 5QI-1 traffic condition	
#     should be true    ${value_M55158C00001}==0
# 	should be true    ${value_M55158C00002}==0
# 	should be true    ${value_M55158C00003}==0		
#     Check kpi or counters for F1 related counter
# 	
# check DL kpi for 5QI-2 traffic condition	
#     should be true    ${value_M55158C00001}==0
# 	should be true    ${value_M55158C00002}==0
# 	should be true    ${value_M55158C00003}==0		
#     Check kpi or counters for F1 related counter
# 
# 
