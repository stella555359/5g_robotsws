# *** Settings ***
# Force Tags    PY36
# Documentation
# ...    author: jiayi tang
# ...    contact: jiayi.tang@nokia-sbell.com
# ...    squad group: 5G_PZ_MMW_HZ_2_SG
# ...    Feature 5GC002256 program
# 
# Resource    ./Resources/5GC002056_resource_mmw2.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Suite Setup    robot_common_operations.Common Suite Setup
# Suite Teardown    robot_common_operations.Common Suite Teardown
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1][1.0] CB006086_E_002_Transmission_reconfigure_from_Rank2_to_Rank1
#     [Documentation]
#     ...    The purpose of this test is to verify basic configuration of RU RAU OAM configures RU, 
#     ...    configuration not related to synchronization, transport and U-plane.
#     [Tags]
#     [Setup]    robot_common_operations.Common Case Setup
#     Log to Console    *TopYong Attenuation Initial Value set*
#     TopYong Attenuation Initial Value set
#     Log to Console    *Start UL L3call*
#     Start UL L3call
#     Log to Console    *TopYong Attenuation Initial Value set*
#     TopYong Attenuation Initial Value set
#     Log to Console    *Get TcpdumpLogs*
#     Get TcpdumpLogs from Remote machine with local capture
#     Log to Console    *Check Rank Value*
#     Check Rank Value
#     [Teardown]     Case Teardown
#     
# 
# [1]CB006086_E_001_Transmission_reconfigure_from_Rank1_to_Rank2
#     [Tags]    
#     [Setup]    robot_common_operations.Common Case Setup
#     Check Rank Value    filter_expression=${maxMIMO_Layers_filter1}
#     [Teardown]    Case Teardown
# 
# *** Keywords ***
# Case Teardown
#     Log to Console    *Case Teardown*
#     Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}
#     Run Keyword And Ignore Error    process.Terminate All Processes    kill=True
#     robot_common_operations.Common Case Teardown
#     Run Keyword And Ignore Error    CI_interface.Common Case Teardown
