# *** Settings ***
# Suite Setup    Run Keywords    robot_common_operations.Common Suite Setup
# ...    AND    Suite Setup
# Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown
# ...    AND    Suite Teardown
# 
# Resource    ./Resources/CB009226_common_keywords.robot
# 
# Documentation
# ...    Author:Guo Zhenzhen
# ...    contact:zhenzhen.guo@nokia-sbell.com
# ...    squad group:mmw_SG_03
# ...    Feature CB009226
# 
# *** Variables ***
# 
# 
# *** Test Cases ***
# [1]CB009226_A_AKQJ_2_FID4698_[Q]SFP_Transceiver_Temp_Too_High_on_Radio_Unit
#     [Tags]    CRT_TRUNK
#     [Setup]    run keywords    robot_common_operations.Common Case Setup
#     Feature CB009226 Transceiver alarms and warnings
#     PM counter update enabled
# 	Trigger Fault and check fault    expected_fault=4698    warning_alarm=warning
#     Trigger Fault and check fault    expected_fault=4698    warning_alarm=alarm
#     [teardown]    run keywords    robot_common_operations.Common Case Teardown 
# 
# 
# [1]CB009226_A_AKQJ_3_FID4699_TX_Bias_Current_on_[Q]SFP’s_LANE_too_low_on_Radio_Unit
#     [Tags]    CRT_TRUNK
#     [Setup]    run keywords    robot_common_operations.Common Case Setup
# 	#CB009226_common_keywords.Expect Fault Should Present    id=4699    severity=Minor    alarmId=7115
# 	Trigger Fault and check fault    expected_fault=4699    warning_alarm=warning
#     Trigger Fault and check fault    expected_fault=4699    warning_alarm=alarm
#     [teardown]    run keywords    robot_common_operations.Common Case Teardown 
# 
# 
# [1]CB009226_A_AKQJ_4_FID4700_TX_Power_on_[Q]SFP’s LANE_too_low_on_Radio_Unit
#     [Tags]    CRT_TRUNK
#     [Setup]    run keywords    robot_common_operations.Common Case Setup
# 	Trigger Fault and check fault    expected_fault=4700    warning_alarm=warning
#     Trigger Fault and check fault    expected_fault=4700    warning_alarm=alarm
#     [teardown]    run keywords    robot_common_operations.Common Case Teardown 
# 
# 	
# [1]CB009226_A_AKQJ_5_RX_Power_on_[Q]SFP’s_LANE_too_low_on_Radio_Unit
#     [Tags]    CRT_TRUNK
#     [Setup]    run keywords    robot_common_operations.Common Case Setup
# 	Trigger Fault and check fault    expected_fault=4701    warning_alarm=warning
#     Trigger Fault and check fault    expected_fault=4701    warning_alarm=alarm
#     [teardown]    run keywords    robot_common_operations.Common Case Teardown 
# 
# 
# [1]CB009226_BD_AKQJ_6_CB009226-BD_FID2928_[Q]SFP_TX_fault_from_Radio_Unit_in_BTS_and_Log_Prints
#     [Setup]    run keywords    robot_common_operations.Common Case Setup
#     #Catch Snapshot COAM    faultid=2928
#     #Set Suite Variable    ${local_file_path}    /home/ute/zhenzhen/snapshot_coam_fault2928__2024-01-18-16_02_05.zip/
# 	#Get snapshot and check R&D fault    faultid=2928
# 	Trigger Fault and check fault    expected_fault=2928
# 	Should Contain    ${fault_output}    EFaultId_SfpTxFaultEcpri (1404)
# 	Should Contain    ${fault_output}    externalEthernetPort0
#     Should Contain    ${fault_output}    warning
#     [teardown]    run keywords    robot_common_operations.Common Case Teardown 
#     ...    AND    Delete snapshot
# 	
# [1]CB009226_CE_AKQJ_7_CB009226-CE_FID2929_SFP_RX_LOS_fault_from_Radio_Unit_in_BTS_and_Log_Prints
#     [Tags]    CRT_TRUNK
#     [Setup]    run keywords    robot_common_operations.Common Case Setup
#     Trigger Fault and check fault    expected_fault=2929
#     #${fault_output}    Collect raw fault in radio history
# 	Should Contain    ${fault_output}    EFaultId_LossOfSignalCapacityWarning (1385)
# 	Should Contain    ${fault_output}    externalEthernetPort0
#     Should Contain    ${fault_output}    warning
#     [teardown]    run keywords    robot_common_operations.Common Case Teardown 
#     ...    AND    Delete snapshot
# 	
# #[1]CB009226_FG_AKQJ_8_CB009226-FG_FID2930_Loss_of_Ethernet_link_(eCPRI_link)_from_Radio_Unit_in_BTS
# #    [Tags]    CRT_TRUNK
# #    [Setup]    run keywords    robot_common_operations.Common Case Setup
# #    Trigger Fault and check fault    expected_fault=2930
# #    [teardown]    run keywords    robot_common_operations.Common Case Teardown
# 
# 	
# [1]CB009226_H_AKQJ_10_CB009226-H_Clock_sync_lost_event_log_in_Radio_Unit_only
#     [Tags]    CRT_TRUNK
#     [Setup]    run keywords    robot_common_operations.Common Case Setup
#     Trigger Fault and check fault    expected_fault=sync_lost
#     #${fault_output}    Collect raw fault in radio history
# 	Should Contain    ${fault_output}    EEventId_SyncLost (10001)
# 	Should Contain    ${fault_output}    module
#     Should Contain    ${fault_output}    critical
#     [teardown]    run keywords    robot_common_operations.Common Case Teardown	
