# *** Settings ***
# Suite Setup          Run Keywords    robot_common_operations.Common Suite Setup    AND    SISO OAM Suite Setup
# Suite Teardown       Run Keywords    robot_common_operations.Common Suite Teardown    AND    SISO Suite Teardown
# Test Setup           Run Keywords    robot_common_operations.Common Case Setup    AND    SISO Test Setup
# Test Teardown        Run Keywords    robot_common_operations.Common Case Teardown    AND    SISO Test Teardown
# #Test Teardown        SISO Test Teardown
# Test Timeout         600 min
# 
# Resource     Resource/CB008445_Resource.robot
# Resource     Resource/CB008445_Resource_RRM.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Documentation
# ...    Author:Frank Luo
# ...    contact:frank.s.luo@nokia-sbell.com
# ...    squad group:SG_01
# ...    Feature CB008445 in 5G22R4 program
# 
# Force Tags            5G_RAN    5G_RAN_TDD    STATE_SW_UPLOADED  SBTS00
# #...    CLOUD_5G_CLASSICAL_ANDROID_ASIBL_ABIOB1_AWHQN_ENB
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1][1.0] Manual_SiSo_SM_LTE Cell_block_unblock
#     [Tags]    CRT_TRUNK   OAM    OAM_10   OAM_PASS
#     [Timeout]  60min
#     TC.62_Manual_SiSo_SM_LTE Cell_block_unblock
# 
# [1]Manual_SiSo_CALL_LTE_data_call
#     [Tags]    OAM   CRT_22R4    CRT_TRUNK
#     [Timeout]  60min
#     TC.Manual_SiSo_CALL_LTE_data_call
# 
# [1]BS-RF__EDA_Validation_of_power_exceeding_max_allowed_power_per_pipe
#     [Tags]    OAM    OAM_17   CRT_TRUNK       OAM_PASS
#     [Timeout]  60min
#     TC.BS-RF__EDA_Validation_of_power_exceeding_max_allowed_power_per_pipe
# 
# OAM_13
#     [Tags]    OAM    OAM_13
#     [Timeout]  60min
#     TC.63_LTE_cell_graceful_shutdown_from_WebEm
# 
# OAM_14
#     [Tags]    OAM    OAM_14       OAM_PASS
#     [Timeout]  60min
#     TC.64_LTE_cell_lock_unlock_(administrative_state_change)_from_WebEm
# 
# OAM_11
#     [Tags]    OAM    OAM_11       OAM_PASS
#     [Timeout]  120min
#     TC.65_Manual_SiSo_SM_LTE RAT reset
# 
# OAM_4
#     [Tags]    OAM    OAM_4       OAM_PASS
#     [Timeout]  60min
#     TC.66_Manual_SiSo_STARTUP_Start-up_and_Detection_of_RF_Module
# 
# ##########################################################
# OAM_12
#     #[Tags]    CRT_TRUNK   OAM    OAM_12
#     [Timeout]  60min
#     TC.BS-RF__LTE1530_Activation_Deactivation_in_WebEM
# 
# OAM_6
#     [Timeout]  60min
#     #[Tags]   CRT_TRUNK    OAM    OAM_6
#     TC.Manual_SiSo_ALD_Detect_and_setup_AL_devices_Start-up
# 
# OAM_18
#     [Tags]    OAM    OAM_18
#     [Timeout]  60min
#     TC.SiSo_Plug-in_Package_check
# OAM_19
#     [Tags]    OAM    OAM_19
#     [Timeout]  60min
#     TC.SiSo_Plug-in_Update_RFM_plug-in_package
# OAM_20
#     [Tags]    OAM    OAM_20
#     [Timeout]  60min
#     TC.SiSo_Plug-in_Download_RFM_plug-in_package_and_insert_new_Radio_Module