# *** Settings ***
# Suite Setup          Run Keywords    CBRS Suite Setup
# ...                  AND     Case Preparation
# Suite Teardown       CBRS Suite Teardown
# Test Setup           CB007659 CBRS Test Setup    enable_delta_file=${enable_actcbrs_61}
# Test Teardown        CB007659 Test Teardown    disable_delta_file=${modify_actcbrs_61}
# 
# Resource    resources/CB007659-A_common_keywords.robot
# 
# Documentation
# ...    Author:wangqingqing
# ...    contact:qingqing.wang@nokia-sbell.com
# ...    squad group:SG_08
# ...    Feature CB007659-A
# 
# Force Tags    SBTS00
# ...    PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]CB007659-A_20_gNB_behavior_check_when_NR_CBRS_deactivated
#     [Tags]    CIT_22R4
#     CB007659-A_20_gNB_behavior_check_when_NR_CBRS_deactivated
# 
# [1]CB007659-A_19_gNB_behavior_check_when_LTE_CBRS_deactivated
#     [Tags]    CIT_22R4
#     CB007659-A_19_gNB_behavior_check_when_LTE_CBRS_deactivated    disable_delta_file=${modify_actcbrs_61}
# 
# [1]CB007659-A_30_CBRS_behavior_check_when_modify CBSD parameters
#     [Tags]    CIT_22R4
#     CB007659-A_30_CBRS_behavior_check_when_modify CBSD parameters
# 
# [1]CB007659-A_8_gNB pre-tx measurement not performed when LTE onair
#     [Tags]    CIT_22R4
#     CB007659-A_8_gNB pre-tx measurement not performed when LTE onair
# 
# [1]CB007659-A_27_online_modify_supportedSpectrumV2_to_release_Volatile_MO
#     [Tags]    CIT_22R4
#     CB007659-A_27_online_modify_supportedSpectrumV2_to_release_Volatile_MO
#     ...    disable_delta_file=${modify_actcbrs_61}
#     ...    enable_delta_file=${enable_actcbrs_61}
# 
# [1]CB007659-A_26_CBSD_behavior_check_when_online_modify_desiredpmax
#     [Tags]    CIT_22R4
#     CB007659-A_26_CBSD_behavior_check_when_online_modify_desiredpmax
# 
# *** Keywords ***
