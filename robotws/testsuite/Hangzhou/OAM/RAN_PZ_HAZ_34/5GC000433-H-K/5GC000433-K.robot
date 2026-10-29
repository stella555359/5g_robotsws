# *** Settings ***
# Suite Setup           Run Keywords     robot_common_operations.Common Suite Setup
# ...                   AND     SISO Coam Suite Setup
# ...                   AND     5GC000433-H-K Case Preparation
# Suite Teardown        Run Keywords     robot_common_operations.Common Suite Teardown
# ...                   AND     SISO Coam Suite Teardown
# Test Setup            Run Keywords     robot_common_operations.Common Case Setup   
# ...                   AND     SISO Coam Test Setup
# Test Teardown         Run Keywords     robot_common_operations.Common Case Teardown  
# ...                   AND     SISO Coam Test Teardown
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    Resources/5GC000433-H-K_common_keywords.robot
# 
# 
# Documentation
# ...    author: Luo Tina
# ...    contact: tina.luo@nokia-sbell.com
# ...    squad group: MMW3
# ...    feature : 5GC000433-K
# 
# Force Tags    CRT_TRUNK    CRT_21B
# ...    PY36
# *** Variables ***
# #${M40003C0_1}    51250
# #${M40003C2}      4882
# #${M40003C3_5}    195277
# #${M40004C0}      5564
# #${M40004C1_3}    222739
# #${M40004C4_5}    52078
# #${if_commissioning}   False
# 
# ${M40003C0_1}    51250
# ${M40003C2}      3702
# ${M40003C3_5}    148100
# ${M40004C0}      5493
# ${M40004C1_3}    220046
# ${M40004C4_5}    51500
# 
# *** Test Cases ***
# [1]CB007304-A-5GC000433-K_001_WebEM_voltage_and_power_display_after_RF_disconnect_and_reconnect
#     [Tags]    CRT_21B    CRT_TRUNK
#     RF Power Off On and Check Energy Consumption Counters    interval=1min
# 
# [1]CB007304-A-5GC000433-K_003_SM_energy_consumption_counters_display_in_BTS_PM_panel_and_PM_file
#     [Tags]    CRT_21B    CRT_TRUNK
#     Wait for New Interval BTS counters Generate    interval=15min
#     Check BTS Counter M40004C of 5GC000433-H-K    interval=15min
#     Check BTS Counter M40002C of 5GC000433-H-K for case 003   interval=15min
#     5GC000433-H-K_common_keywords.Collect snapshot log
#     Get snapshot and check energy consumption counter
#     Delete snapshot     ${local_file_path}   ${unzipped}
# 
# [1]CB007304-A-5GC000433-K_004_Radio_energy_consumption_counters_display_in_BTS_PM_panel_and_PM_file
#     [Tags]    CRT_21B    CRT_TRUNK
#     ${wait_time}    Get wait value minutes    interval=15min
#     sleep    ${wait_time}min
#     Sleep  30
#     Check BTS Counter M40003C of 5GC000433-H-K    interval=15min
#     Check BTS Counter M40002C of 5GC000433-H-K for case 004   interval=15min
# 
# [1]CB007304-A-5GC000433-K_002_Enable_disable_energy_consumption_measurement_collectection_via_WebEM
#     [Tags]    CRT_21B    CRT_TRUNK
#     Wait for New Interval BTS counters Generate    interval=15min
#     Disable Energy Consumption Measurement Collectection    interval=15min
#     Set Power meter    power_meter=true
