# *** Settings ***
# Force Tags    PY36
# Documentation
# ...    author: Gu Xinyu
# ...    contact: xinyu.gu@nokia-sbell.com
# ...    squad group: 5G_PZ_MMW_HZ_2_SG
# ...    Feature 5GC00 program  
# 
# Resource    ./Resource/CB005887_resource.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Suite Setup    robot_common_operations.Common Suite Setup
# Suite Teardown    robot_common_operations.Common Suite Teardown
# 
# *** Variables ***
# ${udpultp}    450
# ${ultp}    450
# ${dltp}    4150
# ${ue_index}    0
# 
# *** Test Cases ***
# 
# [1][1.0] CB005887_B_22_8CCDL4CCUL_online_deactivation
#     [Tags]    
#     [Setup]    robot_common_operations.Common Case Setup 
# 	Deactivate CarrierAgg
#     [Teardown]    robot_common_operations.Common Case Teardown
# 
# 
# 
# [1][1.0] CB005887_B_23_8CCDL4CCUL_online_activation
#     [Documentation]
#     ...    The purpose of this test is to verify basic configuration of RU RAU OAM configures RU, 
#     ...    configuration not related to synchronization, transport and U-plane.
#     [Tags]   
#     [Setup]    robot_common_operations.Common Case Setup
#     Activate CarrierAgg
#     [Teardown]    robot_common_operations.Common Case Teardown
# 	
# [1][1.0] CB005887_B_02_8CCDL4CCUL_Contiguous_CA_ABIO
#     [Documentation]
#     ...    The purpose of this test is to verify basic configuration of RU RAU OAM configures RU, 
#     ...    configuration not related to synchronization, transport and U-plane.
#     [Tags]    
#     [Setup]    robot_common_operations.Common Case Setup
#       ${list_of_cell_ids}    Create List    16385    16386    16387    16388    16389    16390    16391    16392
#     Run keyword and continue on failure    step1: Check all cells status
#     sleep    300s
#     step3: Prepare UE
#     Step4: UE Attach
#     Step5: Start traffic udp    ul_throughput=470M
#     ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=5m   
# 	${all_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=${list_of_cell_ids}
#     ...    ultarget_throughput=500    dltarget_throughput=4270    actCarrierAggregation=${True}
#     Set Test Variable    ${all_tp}    ${all_tp}
#     [Teardown]    Case_Teardown
# 	
# 
# [1][1.0] CNI81900_01_graceful_cell_shutdown_FR2_8CC_8DL4UL_CA_check_msg_DlData_slotTypeReq_ABIO
#     [Documentation]
#     ...    The purpose of this test is to verify basic DL tp for 8ccDL4ccUL, 
#     ...    configuration not related to synchronization, transport and U-plane.
#     [Tags]    
#     [Setup]    robot_common_operations.Common Case Setup
#     ${list_of_cell_ids}    Create List    16385    16386    16387    16388    16389    16390    16391    16392
# 	log to console      DL throughput
#     Run keyword and continue on failure    step1: Check all cells status
#     step3: Prepare UE    ue_index=${ue_index}
#     Step4: UE Attach    ue_index=${ue_index}
#     Step5: Start traffic tcp
#     ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=5m
#     ${cellid}    Get nrcellid from aasys log    log_name=/tmp/aasyslog_tput.txt
#     log    ${cell_id}
#     ${all_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=${list_of_cell_ids}
#     ...    ultarget_throughput=${ultp}    dltarget_throughput=${dltp}    actCarrierAggregation=${True}
#     Set Test Variable    ${all_tp}    ${all_tp}
#     [Teardown]     Run Keyword And Ignore Error    Case_Teardown  
# 
# *** Keywords ***
# 
# Case_Teardown
#     [Arguments]    ${connection}=COAM    
#     Log To Console    \n *** Case teardown
#     Run Keyword And Ignore Error    Step7: Stop traffic
#     Run Keyword And Ignore Error    Step8: UE Detach
#     robot_common_operations.Common Case Teardown
#     Run Keyword And Ignore Error    admin_cli.teardown    connection=${connection}
#     Run Keyword And Ignore Error    Teardown the Aasyslog save progress 
#     Run Keyword And Ignore Error    CI_interface.Common Case Teardown
