# *** Settings ***
# Suite Setup          Run Keywords    CBRS Suite Setup
# ...                  AND     Case Preparation CRT
# Suite Teardown       CBRS Suite Teardown
# Test Setup           CB007659 CBRS Test Setup
# Test Teardown        CB007659 Test Teardown
# 
# Resource    resources/CB007659-A_common_keywords.robot
# 
# Documentation
# ...    Author:wangqingqing
# ...    contact:qingqing.wang@nokia-sbell.com
# ...    squad group:SG_08
# ...    Feature CB007659-A
# 
# Force Tags    SBTS00    CRT_23R1
# ...    PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]CB007659-A_20_gNB_behavior_check_when_NR_CBRS_deactivated
#     [Tags]    CRT_TRUNK
#     CB007659-A_20_gNB_behavior_check_when_NR_CBRS_deactivated
# 
# [1]CB007659-A_19_gNB_behavior_check_when_LTE_CBRS_deactivated
#     [Tags]    CRT_TRUNK
#     CB007659-A_19_gNB_behavior_check_when_LTE_CBRS_deactivated
# 
# [1]CB007659-A_30_CBRS_behavior_check_when_modify CBSD parameters
#     [Tags]    CRT_TRUNK
#     CB007659-A_30_CBRS_behavior_check_when_modify CBSD parameters
# 
# [1]CB007659-A_7_gNB pre-tx measurement performed when LTE onair
#     [Tags]    CRT_TRUNK
#     CB007659-A_7_gNB pre-tx measurement performed when LTE onair
# 
# [1]CB007659-A_8_gNB pre-tx measurement not performed when LTE onair
#     [Tags]    CRT_TRUNK
#     CB007659-A_8_gNB pre-tx measurement not performed when LTE onair
# 
# [1]CB007659-A_11_gNB_cell_lock_unlock_when_master_is_NR
#     [Tags]    CRT_TRUNK
#     CB007659-A_11_gNB_cell_lock_unlock_when_master_is_NR
# 
# [1]CB007659-A_22_gNB_data_transfer_conducted_peak_throughput_SA
#     [Tags]    CRT_TRUNK
#     CB007659-A_22_gNB_data_transfer_conducted_peak_throughput_SA
# 
# [1]CB007659-A_16_gNB_behavior_check_when_gNB_reset_master_is_NR
#     [Tags]    CRT_TRUNK
#     CB007659-A_16_gNB_behavior_check_when_gNB_reset_master_is_NR
# 
# [1]CB007659-A_14_gNB_behavior_check_when_RU_reset_master_is_NR
#     [Tags]    CRT_TRUNK
#     CB007659-A_14_gNB_behavior_check_when_RU_reset_master_is_NR
# 
# [1]CB007659-A_27_online_modify_supportedSpectrumV2_to_release_Volatile_MO
#     [Tags]    CRT_TRUNK
#     CB007659-A_27_online_modify_supportedSpectrumV2_to_release_Volatile_MO
# 
# [1]CB007659-A_26_CBSD_behavior_check_when_online_modify_desiredpmax
#     [Tags]    CRT_TRUNK
#     CB007659-A_26_CBSD_behavior_check_when_online_modify_desiredpmax
# 
# *** Keywords ***
