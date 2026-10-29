# *** Settings ***
# Suite Setup          Run Keywords    CBRS Suite Setup
# ...                  AND     Case Preparation CB008923-C
# Suite Teardown       CBRS Suite Teardown
# Test Setup           CB008923-C CBRS Test Setup
# Test Teardown        CB008923-C CBRS Test Teardown
# 
# Resource    resources/CB008923_common_keywords.robot
# 
# Documentation
# ...    Author:wangqingqing
# ...    contact:qingqing.wang@nokia-sbell.com
# ...    squad group:SG_08
# ...    Feature CB008923-C
# 
# Force Tags    SBTS00
# ...    PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]CB008923-C_16_CBSD_behavior_check_when_gNB_reset_master_is_NR
#     [Tags]    CRT_TRUNK
#     CB008923-C_16_CBSD_behavior_check_when_gNB_reset_master_is_NR
# 
# [1]CB008923-C_13_CBSD_behavior_check_when_RU_reset_master_is_NR
#     [Tags]    CRT_TRUNK
#     CB008923-C_13_CBSD_behavior_check_when_RU_reset_master_is_NR
# 
# [1]CB008923-C_9_CBSD_behavior_check_when_RU_lock_unlock_master_is_NR
#     [Tags]    CRT_TRUNK
#     CB008923-C_9_CBSD_behavior_check_when_RU_lock_unlock_master_is_NR
# 
# [1]CB008923-C_26_data_transfer_conducted_peak_throughput_NR_40MHz_LTE_20MHz
#     [Tags]    CRT_TRUNK
#     CB008923-C_26_data_transfer_conducted_peak_throughput_NR_40MHz_LTE_20MHz
# 
# *** Keywords ***
