# *** Settings ***
# Documentation      author: Lixia Wang
# ...                 contact: lixia.wang@nokia-sbell.com
# ...                This robot file is for CB009199-C Startup KPI cases.This robot is for all configurations.
# 
# #Suite Setup       KW.TestSuilt.Start
# #Suite Teardown    KW.TestSuilt.Stop
# Suite Setup       Run Keywords    robot_common_operations.Common Suite Setup    AND    KW.TestSuilt.Start
# Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown    AND    KW.TestSuilt.Stop
# Force Tags               SG_01   5G_RAN
# Resource           ../5GC002479/Resources/5GC002479_CP_Resource.robot
# Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# *** Test Cases ***
#  [1]CB009395_SR_C_01_Energy_Consumption_Measurements
#      [Documentation]
#      [Tags]     C&P    CB009395-C    CNF_5G_4    CNF_5G_9    CNF_5G_10    CNF_5G_15b
#      [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start_2479
#      [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    Teardown case
#      TC.CB008681_SR_C_01_Energy_Consumption_Measurements
# 
# [1]CB009395_SR_C_06_Site_Rest_downtime_KPI1a_WithOut_GracefulCellShutdown
#     [Documentation]     KPI1A
#     [Tags]     C&P    CB009395-C    CNF_5G_4    CNF_5G_9    CNF_5G_10    CNF_5G_15b
# #    [Setup]    TestCase.Start_2479
# #    [Teardown]  Teardown case
#     [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start_WithOut_GracefulCellShutdown
#     [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    Teardown case
#     TC.CP_HA_01_OAM_KPI_1a_Site_Reset_Outage_Duration_Single_Core
# 
# [1]CB009395_SR_C_06_Site_Rest_downtime_KPI1a_With_GracefulCellShutdown
#     [Documentation]     KPI1A
#     [Tags]     C&P    CB009395-C    CNF_5G_15b
# #    [Setup]    TestCase.Start_2479
# #    [Teardown]  Teardown case
#     [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start_With_GracefulCellShutdown
#     [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    Teardown case
#     TC.CP_HA_01_OAM_KPI_1a_Site_Reset_Outage_Duration_Single_Core
# 
# [1]CB009395_SR_C_07_Site_Power_Rest_downtime_KPI3
#     [Documentation]     KPI3
#     [Tags]     C&P    CB009395-C    CNF_5G_4    CNF_5G_9    CNF_5G_10    CNF_5G_15b
# #    [Setup]    TestCase.Start_2479
# #    [Teardown]  Teardown case
#     [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start_2479
#     [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    Teardown case
#     TC.CP_HA_04_OAM_KPI_3_Power_Reset_Outage_Duration_Single_Core
# 
# [1]CB009395_SR_C_08_Capacity_Module_Rest_downtime_KPI5
#     [Documentation]
#     [Tags]     C&P    CB009395-C    CNF_5G_4    CNF_5G_9    CNF_5G_10
# #    [Setup]    TestCase.Start_2479
# #    [Teardown]  Teardown Case
#     [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start_2479
#     [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    Teardown case
#     TC.5GC002536_HA_03_OAM_KPI_5_Capacity_Module_Reset_Outage_Duration
# 
# [1]CB009395_SR_C_09_10_Cell_lock_unlock_duration_KPI16a_KPI16b
#     [Documentation]
#     [Tags]     C&P    CB009395-C    CNF_5G_4    CNF_5G_9    CNF_5G_10    CNF_5G_15b
# #    [Setup]    TestCase.Start_2479
# #    [Teardown]  AA_Teardown case
#     [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start_2479
#     [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    AA_Teardown case
#     TC.CB008181_SR_C_09_Cell_lock_unlock_duration_KPI16a_KPI16b
# 
# [1]CB009395_SR_C_11_12_Cell_block_duration_KPI17a_KPI17b
#     [Documentation]
#     [Tags]     C&P    CB009395-C    CNF_5G_4    CNF_5G_9    CNF_5G_10    CNF_5G_15b
# #    [Setup]    TestCase.Start_2479
# #    [Teardown]  HA_KPI17_Teardown case
#     [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start_2479
#     [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    HA_KPI17_Teardown case
#     TC.CB006939_HA_05_OAM_KPI_17_Cell_Block_Unblock_Outage_Duration
# 
# [1]CB009395_SR_C_13_RU_reset_duration_KPI51a_WithOut_GracefulCellShutdown
#     [Documentation]     This case is to verify OAM KPI51, RU reset time is less than 3min
#     [Tags]     C&P    CB009395-C    CNF_5G_4    CNF_5G_9    CNF_5G_10    CNF_5G_15b
# #    [Setup]    TestCase.Start_2479
# #    [Teardown]  Teardown Case
#     [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start_WithOut_GracefulCellShutdown
#     [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    Teardown case
#     TC.CB006939_HA_10_OAM_KPI_51a_RU_Reset_Time
# 
# [1]CB009395_SR_C_13_RU_reset_duration_KPI51a_With_GracefulCellShutdown
#     [Documentation]     This case is to verify OAM KPI51, RU reset time is less than 3min
#     [Tags]     C&P    CB009395-C    CNF_5G_15b
# #    [Setup]    TestCase.Start_2479
# #    [Teardown]  Teardown Case
#     [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start_With_GracefulCellShutdown
#     [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    Teardown case
#     TC.CB006939_HA_10_OAM_KPI_51a_RU_Reset_Time
# 
# [1]CB009395_SR_C_14_RU_power_reset_KPI154a
#     [Documentation]
#     [Tags]     C&P    CB009395-C    CNF_5G_4    CNF_5G_9    CNF_5G_10    CNF_5G_15b
# #    [Setup]    TestCase.Start_2479
# #    [Teardown]  Teardown Case
#     [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start_2479
#     [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    Teardown case
#     TC.CB006939_HA_04_OAM_KPI_54a_RU_Cold_Reset_Time
# 
# [1]CB009395_SR_C_15_OAM_KPI_10_5G_RAT_reset
#     [Documentation]
#     [Tags]     C&P    CB009395-C    CNF_5G_4    CNF_5G_9    CNF_5G_10    CNF_5G_15b
# #    [Setup]    TestCase.Start_2479
# #    [Teardown]  Teardown Case
#     [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start_2479
#     [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    Teardown case
#     TC.CB008181_SR_C_15_OAM_KPI_10_5G_RAT_reset
# 
# [1]CB009395_SR_C_16_CM_Duration_of_BTS_autonomous_reset_after_plan_activation_KPI12_WithOut_GracefulCellShutdown
#     [Documentation]
#     [Tags]     C&P    CB009395-C    CNF_5G_4    CNF_5G_9    CNF_5G_10    CNF_5G_15b
# #    [Setup]    TestCase.Start_2479
# #    [Teardown]  Teardown Case
#     [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start_WithOut_GracefulCellShutdown
#     [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    Teardown case
#     TC.CB008962_SR_C_16_CM_Duration_of_BTS_autonomous_reset_after_plan_activation_KPI12
# 
# [1]CB009395_SR_C_16_CM_Duration_of_BTS_autonomous_reset_after_plan_activation_KPI12_With_GracefulCellShutdown
#     [Documentation]
#     [Tags]     C&P    CB009395-C    CNF_5G_15b
# #    [Setup]    TestCase.Start_2479
# #    [Teardown]  Teardown Case
#     [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start_With_GracefulCellShutdown
#     [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    Teardown case
#     TC.CB008962_SR_C_16_CM_Duration_of_BTS_autonomous_reset_after_plan_activation_KPI12
# 
# [1]CB009395_SR_C_17_Site_romote_power_reset_downtime_KPI11_WithOut_GracefulCellShutdown
#     [Documentation]
#     [Tags]     C&P    CB009395-C    CNF_5G_4    CNF_5G_9    CNF_5G_10    CNF_5G_15b
# #    [Setup]    TestCase.Start_2479
# #    [Teardown]  Teardown Case
#     [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start_WithOut_GracefulCellShutdown
#     [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    Teardown case
#     TC.CB008962_SR_C_17_Site_romote_power_reset_downtime_KPI11
# 
# [1]CB009395_SR_C_17_Site_romote_power_reset_downtime_KPI11_With_GracefulCellShutdown
#     [Documentation]
#     [Tags]     C&P    CB009395-C    CNF_5G_15b
# #    [Setup]    TestCase.Start_2479
# #    [Teardown]  Teardown Case
#     [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start_With_GracefulCellShutdown
#     [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    Teardown case
#     TC.CB008962_SR_C_17_Site_romote_power_reset_downtime_KPI11
# 
# [1]CB009395_SR_C_18_SW_rollback_downtime_Manually_Triggered_KPI13
#     [Documentation]
#     [Tags]     C&P    CB009395-C    CNF_5G_4    CNF_5G_9    CNF_5G_10    CNF_5G_15b
# #    [Setup]    TestCase.Start_2479
# #    [Teardown]  Teardown Case
#     [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start_2479
#     [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    Teardown case
#     TC.CB009199_SR_C_18_SW_rollback_downtime_Manually_Triggered_KPI13
# 
# [1]CB009395_SR_C_03_SW_Activation_downtime_KPI2c_WithOut_GracefulCellShutdown
#     [Documentation]
#     [Tags]     C&P    CB009395-C    CNF_5G_4    CNF_5G_9    CNF_5G_10    CNF_5G_15b
# #    [Setup]    TestCase.Start_2479
# #    [Teardown]  Teardown Case
#     [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start_WithOut_GracefulCellShutdown
#     [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    Teardown case
#     TC.5GC002479_IA_04_OAM_KPI_2c_SWM_Outage_Duration_of_SW_Activation_Intra_Release_without_SM_Firmware_Upgrade
# 
# [1]CB009395_SR_C_03_SW_Activation_downtime_KPI2c_With_GracefulCellShutdown
#     [Documentation]
#     [Tags]     C&P    CB009395-C    CNF_5G_15b
# #    [Setup]    TestCase.Start_2479
# #    [Teardown]  Teardown Case
#     [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start_With_GracefulCellShutdown
#     [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    Teardown case
#     TC.5GC002479_IA_04_OAM_KPI_2c_SWM_Outage_Duration_of_SW_Activation_Intra_Release_without_SM_Firmware_Upgrade
# 
# [1]CB009395_SR_C_04_SW_Activation_downtime_KPI2d_WithOut_GracefulCellShutdown
#     [Documentation]
#     [Tags]     C&P    CB009395-C    CNF_5G_4    CNF_5G_9    CNF_5G_10    CNF_5G_15b
# #    [Setup]    TestCase.Start_2479
# #    [Teardown]  Teardown Case
#     [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start_WithOut_GracefulCellShutdown
#     [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    Teardown case
#     TC.5GC002479_IA_06_OAM_KPI_2d_SWM_Outage_Duration_of_SW_Activation_Intra_Release_with_SM_Firmware_Upgrade
# 
# [1]CB009395_SR_C_04_SW_Activation_downtime_KPI2d_With_GracefulCellShutdown
#     [Documentation]
#     [Tags]     C&P    CB009395-C    CNF_5G_15b
# #    [Setup]    TestCase.Start_2479
# #    [Teardown]  Teardown Case
#     [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start_With_GracefulCellShutdown
#     [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    Teardown case
#     TC.5GC002479_IA_06_OAM_KPI_2d_SWM_Outage_Duration_of_SW_Activation_Intra_Release_with_SM_Firmware_Upgrade
# 
# [1]CB009395_SR_C_05_SW_Upgrade_duration_KPI4
#     [Documentation]
#     [Tags]     C&P    CB009395-C    CNF_5G_4    CNF_5G_9    CNF_5G_10    CNF_5G_15b
# #    [Setup]    TestCase.Start_2479
# #    [Teardown]  Teardown Case
#     [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start_2479
#     [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    Teardown case
#     TC.5GC002479_IA_15_OAM_KPI_4_SWM_SW_Upgrade_Time_Intra_Release
# 
# [1]CB009395_SR_C_02_SW_Activation_downtime_KPI2b_WithOut_GracefulCellShutdown
#     [Documentation]
#     [Tags]     C&P    CB009395-C    CNF_5G_4    CNF_5G_9    CNF_5G_10    CNF_5G_15b
# #    [Setup]    TestCase.Start_2479
# #    [Teardown]  Teardown Case
#     [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start_WithOut_GracefulCellShutdown
#     [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    Teardown case
#     TC.5GC002479_IA_03_OAM_KPI_2b_SWM_Outage_Duration_of_SW_activation_Inter_Release_with_SM_Firmware_Upgrade
# 
# [1]CB009395_SR_C_02_SW_Activation_downtime_KPI2b_With_GracefulCellShutdown
#     [Documentation]
#     [Tags]     C&P    CB009395-C    CNF_5G_15b
# #    [Setup]    TestCase.Start_2479
# #    [Teardown]  Teardown Case
#     [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start_With_GracefulCellShutdown
#     [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    Teardown case
#     TC.5GC002479_IA_03_OAM_KPI_2b_SWM_Outage_Duration_of_SW_activation_Inter_Release_with_SM_Firmware_Upgrade
# 
# [1]CB009395_SR_A_14_SWM_Duration_of_SW_Download
#     [Documentation]
#     [Tags]     C&P    CB009395-C    CNF_5G_4    CNF_5G_9    CNF_5G_10    CNF_5G_15b
# #    [Setup]    TestCase.Start_2479
# #    [Teardown]  Teardown Case
#     [Setup]    Run Keywords    robot_common_operations.Common Case Setup    AND    TestCase.Start_2479
#     [Teardown]  Run Keywords    robot_common_operations.Common Case Teardown    AND    Teardown case
#     TC.5GC002479_IA_01_SWM_Max_Duration_of_SW_Download
# 
# 
# 
