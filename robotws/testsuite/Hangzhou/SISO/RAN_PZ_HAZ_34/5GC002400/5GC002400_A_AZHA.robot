# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}
# Test Teardown        SISO Coam Test Teardown
# Test Timeout         200 min
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RU_lock_unlock.robot
# Resource    ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_power_reset.robot
# Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot
# #Resource    ${BASIC_PATH_5G}/General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed_PMAX
# 
# Documentation
# ...    Author: geyou fan
# ...    Contact: geyou.fan@nokia-sbell.com
# ...    squad group:SG_04
# ...    Feature 5GC002400-A in 5G20A program
# 
# Force Tags            5G_RAN_TDD    STATE_GNB_COMMISSIONED   CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AZHA_ENB
# ...   PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]5GC002400_A_AZHA_1S_1CC_General_SiSo_RU_lock_unlock
#     [Tags]    CRT_TRUNK
#     General_SiSo_RU_lock_unlock
# 
# [1]5GC002400_A_AZHA_1S_1CC_General_SiSo_Cell_block_and_unblock
#     [Tags]    CRT_22R3    CRT_22R4    CRT_TRUNK
#     ${fault_list}    Create List    49
#     Allowed Watchdog additional alarms    fault_list=${fault_list}
#     E2E_SiSo_Cell_block_and_unblock_gNB
# 
# [1]5GC002400_A_AZHA_1S_1CC_General_SiSo_RF_module_power_reset
#     [Tags]    CRT_TRUNK
#     ${fault_list}    Create List    10    4589
#     Allowed Watchdog additional alarms    fault_list=${fault_list}
#     General_SiSo_RF_module_power_reset
# 
# [1][1.0] 5GC002400_A_AZHA_1S_2CC_Single_UE_peak_throughput_cell1
#     [Tags]    CRT_22R3    CRT_22R4    CRT_TRUNK
#     General_SiSo_Peak_with_Given_Information    band=20    frame_structure=1116_0ms_GP2_B7    cell_id=1
#     ...    beamset=single beam    duration=${600}
# 
# #[1]5GC002400_A_AZHA_1S_1CC_General_SiSo_CPRI_link_configuration
# #    General_SiSo_CPRI_link_configuration
# #
# #[1]5GC002400_A_AZHA_1S_1CC_General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed_PMAX
# #    General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed_PMAX
# #
# #[1]5GC002400_A_AZHA_General_SiSo_SOAP_RP1_verification
# #    General_SiSo_SOAP_RP1_verification
# #
# #[1]5GC002400_A_AZHA_1S_1CC_General_SiSo_RF_module_addition_in_BIM_and_WebUI
# #    General_SiSo_RF_module_addition_in_BIM_and_WebUI
# #
# #[1]5GC002400_A_AZHA_1S_1CC_General_SiSo_RF_module_IP_adress_allocation
# #    General_SiSo_RF_module_IP_adress_allocation
# #
# #[1]5GC002400_A_AZHA_1S_1CC_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
# #    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
# #
# #[1]5GC002400_A_AZHA_1S_1CC_General_SiSo_Commissioning_BTS_Template_Commissioning
# #    General_SiSo_Commissioning_BTS_Template_Commissioning
# #
# #[1]5GC002400_A_AZHA_General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
# #    General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
# #
# #[1]5GC002400_A_AZHA_General_SiSo_RF_module_reset_from_GUI
# #    General_SiSo_RF_module_reset_from_GUI
# #
# #[1]5GC002400_A_AZHA_1S_1CC_General_SiSo_NR-ARFCN_check
# #    General_SiSo_NR-ARFCN_check
# #
# #[1][1.0] 5GC002400_A_AZHA_1S_2CC_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
# #    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
# #
# #[1]5GC002400_A_AZHA_1S_1CC_General_SiSo_BTS_startup_with_RF_delayed_startup
# #    General_SiSo_BTS_startup_with_RF_delayed_startup
# #
# #[1][1.0] 5GC002400_A_AZHA_1S_2CC_Single_UE_peak_throughput_cell2
# #    General_SiSo_Peak_with_Given_Information    band=20    frame_structure=1116_0ms_GP2_B7    cell_id=2
# #    ...    beamset=single beam
# #
# #[1][1.0] 5GC002400_A_AZHA_1S_2CC_General_SiSo_E2E_system_setup_with_data_transfer_conducted_100m_Fiber_20MHz
# #    General_SiSo_Peak_with_Given_Information    band=20    frame_structure=1116_0ms_GP2_B7    ue_num_each_call=2
# #    ...    beamset=single beam
# #
# #[1]5GC002400_A_AZHA_1S_2CC_OAM_KPI_61a_SiSo_Auto_BTS_site_reset
# #    [Timeout]    8h
# #    Set Log Level    INFO
# #    General_Stability_Test_Case    case_name=General_SiSo_Auto_BTS_site_reset    times=${20}    pass=${19}
# #
# #[1]5GC002400_A_AZHA_OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_WebUI
# #    [Timeout]    12h
# #    Set Log Level    INFO
# #    General_Stability_Test_Case    case_name=General_SiSo_RF_module_reset_from_GUI    times=${34}    pass=${33}
# #
# #[1]5GC002400_A_AZHA_OAM_KPI_64_SiSo_Auto_RU_SW_upgrade_success_rate
# #    [Timeout]    15h
# #    Set Log Level    INFO
# #    General_Stability_Test_Case    case_name=General_SiSo_Auto_Automatic_RAT_SW_upgrade    times=${20}    pass=${19}
# #
# #[1]5GC002400_A_AZHA_1S_1CC_General_SiSo_BTS_reset_with_RF_power_reset
# #    General_SiSo_BTS_reset_with_RF_power_reset
# #
# #[1]5GC002400_A_AZHA_1S_1CC_General_SiSo_RF_module_reset_triggered_by_user_as_part_of_BTS_reset
# #    General_SiSo_RF_module_reset_triggered_by_user_as_part_of_BTS_reset
# #
# #[1]5GC002400_A_AZHA_General_SiSo_LED_states_management_basic
# #    General_SiSo_LED_states_management_basic
# #
# #[1]5GC002400_A_AZHA_1S_1CC_General_SiSo_RF_alarms_with_recovery
# #    General_SiSo_RF_alarms_with_recovery
# #
# #[1]5GC002400_A_AZHA_1S_1CC_General_SiSo_RF_alarms_without_recovery
# #    General_SiSo_RF_alarms_without_recovery
# #
# #[1]5GC002400_A_AZHA_1S_2CC_General_SiSo_Cell_lock_and_unlock
# #    General_SiSo_Cell_lock_and_unlock
# #
# #[1]5GC002400_A_AZHA_1S_2CC_General_SiSo_Commissioning_BTS_Template_Commissioning
# #    General_SiSo_Commissioning_BTS_Template_Commissioning
# #
# #[1]5GC002400_A_AZHA_1S_2CC_General_SiSo_RF_alarms_with_recovery
# #    General_SiSo_RF_alarms_with_recovery
# #
# #[1][1.0] 5GC002400_A_AZHA_1S_1CC_General_SiSo_E2E_system_setup_with_data_transfer_conducted_100m_Fiber_20MHz
# #    General_SiSo_Peak_with_Given_Information    band=20    frame_structure=1116_0ms_GP2_B7    cell_id=1
# #    ...    beamset=single beam
# #
# #[1][1.0] 5GC002400_A_AZHA_1S_1CC_General_SiSo_E2E_system_setup_with_data_transfer_conducted_30km_Fiber_20MHz
# #    General_SiSo_Peak_with_Given_Information    band=20    frame_structure=1116_0ms_GP2_B7    cell_id=1
# #    ...    beamset=single beam
# #
# #[1]5GC002400_A_AZHA_1S_1CC_General_SiSo_Auto_Automatic_RAT_SW_upgrade
# #    General_SiSo_Auto_Automatic_RAT_SW_upgrade
# #
# #[1]5GC002400_A_AZHA_1S_2CC_General_SiSo_Auto_Automatic_RAT_SW_upgrade
# #    General_SiSo_Auto_Automatic_RAT_SW_upgrade
# 
# *** Keywords ***
