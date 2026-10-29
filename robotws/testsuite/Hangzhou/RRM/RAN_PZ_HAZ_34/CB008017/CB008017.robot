# *** Settings ***
# Documentation     author: Qian Jianwu
# ...               Group: 5G_PZ_MMW_HZ_3_SG
# ...               contact: jianwu.qian@nokia-sbell.com
# 
# 
# Resource      ./Resources/CB008017_common_keyword.robot
# Resource      ../5GC001358/Resources/5GC001358_common_keyword.robot
# 
# 
# Suite Setup    Run Keywords    Common Suite Setup for 8017    AND    robot_common_operations.Common Suite Setup
# Suite Teardown    robot_common_operations.Common Suite Teardown
# Test Setup     robot_common_operations.Common Case Setup
# Test Teardown    robot_common_operations.Common Case Teardown
# 
# 
# *** Test Cases ***
# [1]CB008017_C_001_AZQG_send_eCPRI_IQ_Data_to_RAU
#     [Documentation]
#     ...    The purpose of this test case is to verify traffic is success with required configuration.
#     [Tags]    CRT_TRUNK
#     UE prepare and attach
#     UE start traffic   tp_direction=dl   dl_tp=100M
#     UE check throughput by syslog    tp_direction=dl    exp_dl_tp=90    check_times=60s
#     IQ Capture By SSH
#     Download L1SW Package
#     Analyze IQ file
#     IQ Message Check Point
# 	[Teardown]    UE teardown
# 
# [1]CB008017_C_002_RAU_send_eCPRI_Real_Time_Control_to_AZQG
#     [Documentation]
#     ...    The purpose of this test case is to verify traffic is success with required configuration.
#     [Tags]    CRT_TRUNK
#     UE prepare and attach
#     UE start traffic   tp_direction=dl   dl_tp=100M
#     UE check throughput by syslog    tp_direction=dl    exp_dl_tp=90    check_times=60s
#     IQ Capture By SSH
#     Download L1SW Package
#     Analyze IQ file
#     FCP Message Check Point
# 	[Teardown]    UE teardown
