# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}
# Test Teardown        SISO Coam Test Teardown
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB007841_SG04/Resources/7841_common_keywords.robot
# 
# 
# Documentation
# ...    Author:zhihao shi
# ...    contact:zhihao.shi@nokia-sbell.com
# ...    squad group:SG_04
# ...    Feature CB007841_AQQY
# 
# Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_ASIB_ABIO_AQQC_ENB
# ...    PY36
# 
# *** Variables ***
# 
# 
# *** Test Cases ***
# #Tl588 22R4 3 cases
# #Tl582 trunk case 1 and case 2
# #Tl593 trunk case 4
# [1]CB007841-5G-A_001_BTS_startup_SFP_power_level_compatibility_validation
#     [Tags]    CRT_22R4    SBTS00    CRT_UTE
#     BTS_startup_SFP_power_level_compatibility_validation
# 
# [1]CB007841-5G-E_001_The_BTS_shall_support_NIDD_parameter_EQM-APEQM-SFPOperatorMode_to_enable_and_disable_SFP+_or_SFP28_compliance_validation
#     [Tags]    CRT_22R4    SBTS00    CRT_UTE
#     ${fault_list}    Create List    4657    4681
#     # [WESTLAKE-10229] 'SFPWhiteList modification' steps will cause the BTS primary and secondary zones are inconsistent,
#     # trigger the expected FID 4681 when set sfpOperatorMode to 'True'.
#     Allowed Watchdog additional alarms    fault_list=${fault_list}
#     The_BTS_shall_support_NIDD_parameter
# 
# [1]CB007841-5G-E_002_Operator_BTS_startup_SFP+_or_SFP28_transceivers_support_for_fronthaul_and_backhaul_interface
#     Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
# 
# [1]CB007841-5G-C_001_BTS_startup_Cooled_SFP+_or_SFP28_transceivers_support_for_FH_interface
#     [Tags]    CRT_22R4    CRT_TRUNK
#     BTS_startup_Cooled_SFP+_or_SFP28_transceivers_support_for_FH_interface
# 
# [1]CB007841-5G-D_001_BTS_startup_SFP+_or_SFP28_transceivers_cold_start_up_support
#     Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
