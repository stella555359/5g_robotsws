# *** Settings ***
# Documentation
# ...    author: ChenXu
# ...    contact: xu.2.chen@nokia-sbell.com
# ...    squad group: 5G_PZ_MMW_HZ_5_SG
# ...    Feature CB007539_CB008386 8CCDL2CCUL
# 
# Resource    ./CB007539_AEUD_KW.robot
# Resource    ./TCP_DLUL_traffic_127_iperf.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
# 
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Suite Setup     Run keywords     robot_common_operations.Common Suite Setup   AND    CI_interface.Common Suite Setup
# Suite Teardown   robot_common_operations.Common Suite Teardown
# Test Setup       Run keywords     robot_common_operations.Common Case Setup   AND    Connect to gnb coam via ssl
# Test Teardown    robot_common_operations.Common Case Teardown
# 
# 
# 
# *** Variables ***
# #${du_scf_name}    TL127_SCF_8CC.xml
# ${ultp}    270
# ${dltp}    4300
# 
# *** Test Cases ***
# [1]CB007539_CB008386_A_02_8CCDL2CCUL_Contiguous_CA
#     [Documentation]
#     ...    The purpose of this case is to verify stability of L3 call and UDP/TCP DL/UL throughput.
#     [Tags]    CRT_TRUNK    CRT_22R4
# 	  ${list_of_cell_ids}    Create List    2080778    2080779    2080780    2080781    2080782    2080783    2080784    2080785
#     #Run keyword and continue on failure    step1: Check all cells status
#     step3: Prepare UE
#     Step4: UE Attach
#     Step5: Start traffic TCP ULDL
# 	#Step5: Start traffic    dl_throughput=1500M    protocol=tcp
#     ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=5m    filter=L2Lo
#     ${all_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=${list_of_cell_ids}
#     ...    ultarget_throughput=${ultp}    dltarget_throughput=${dltp}    actCarrierAggregation=${True}
#     ...    min_percent=0.7
#     Set Test Variable    ${all_tp}    ${all_tp}
#     Get Average Value    ${all_tp}
#     [Teardown]     Run Keyword And Ignore Error    Case_Teardown_AEUD
#     
# *** Keywords ***
