# *** Settings ***
# Suite Setup          Run Keywords    CBRS Suite Setup
# ...                  AND     Case Preparation
# Suite Teardown       CBRS Suite Teardown
# Test Setup           CBRS Test Setup
# Test Teardown        CBRS Test Teardown
# 
# Resource    resources/CB008923_common_keywords.robot
# 
# Documentation
# ...    Author:wangqingqing & gaoshengqing
# ...    contact:qingqing.wang@nokia-sbell.com & melinda.gao@nokia-sbell.com
# ...    squad group:SG_08
# ...    Feature CB008923
# 
# Force Tags    SBTS00    CRT_23R1
# ...    PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]CB008923-A_8_Verify_CBSD_cells_behavior_when_online_modify_desirePmax
#     [Tags]    CRT_TRUNK    CRT_22R4
#     CB008923-A_8_Verify_CBSD_cells_behavior_when_online_modify_desirePmax
# 
# [1]CB008923-A_13_data_transfer_conducted_2CC_4D4U_SA
#     [Tags]    CRT_TRUNK    CRT_22R4
#     CB008923-A_13_data_transfer_conducted_2CC_4D4U_SA
# 
# [1]CB008923-A_10_Cell_block_and_unblock
#     [Tags]    CRT_TRUNK    CRT_22R4
#     CB008923-A_10_Cell_block_and_unblock
# 
# [1]CB008923-A_7_Online_modify_supportedSpectrumV2_when_two_CBSD_cells_with_different_priority
#     [Tags]    CRT_TRUNK    CRT_22R4
#     CB008923-A_7_Online_modify_supportedSpectrumV2_when_two_CBSD_cells_with_different_priority
# 
# [1]CB008923-A_9_Verify_CBSD_cells_behavior_when_online_modify_cbrsFreqPriority
#     [Tags]    CRT_TRUNK    CRT_22R4
#     CB008923-A_9_Verify_CBSD_cells_behavior_when_online_modify_cbrsFreqPriority
# 
# [1]CB008923-A_20_Online_modify_desiredPmax when CBSD cell blocked
#     [Tags]    CRT_TRUNK    CRT_22R4
#     CB008923-A_20_Online_modify_desiredPmax when CBSD cell blocked
# 
# [1]CB008923-A_5_Online_delete_the_higher_priority_CBRS_cell_when_only_20MHz_PAL_channel_block_available
#     [Tags]    CRT_TRUNK    CRT_22R4
#     CB008923-A_5_Online_delete_the_higher_priority_CBRS_cell_when_only_20MHz_PAL_channel_block_available
# 
# [1]CB008923-A_4_Online_add_one_higher_priority_CBRS_cell_when_only_20MHz_channel_block_available
#     [Tags]    CRT_TRUNK    CRT_22R4
#     CB008923-A_4_Online_add_one_higher_priority_CBRS_cell_when_only_20MHz_channel_block_available
# 
# [1]CB008923-A_14_Online_modify_channelSpace2020_when_continuous_CA_enable
#     [Tags]    CRT_TRUNK    CRT_22R4
#     CB008923-A_14_Online_modify_channelSpace2020_when_continuous_CA_enable
# 
# *** Keywords ***
