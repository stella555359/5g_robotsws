# *** Settings ***
# Suite Setup    SISO Coam Suite Setup
# #Suite Setup          AENB CPRI Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RU_lock_unlock.robot
# Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_lock_and_unlock.robot
# Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RF_alarms_with_recovery.robot
# Resource    ./Resources/CB007833-td-cpri_Keywords.robot
# Resource    ./Resources/CB006502_Keywords.robot
# Library    ./TestData/variables_CB007833.py
# Variables    ./TestData/variables_6502_60M.py
# 
# 
# Documentation
# ...    Author: Melinda
# ...    Contact: meinda.gao@nokia-sbell.com
# ...    squad group:SG_08
# ...    Feature CB006502 made, Feature CB007833-5G-A-td_cpri_Amber
# 
# Force Tags    RAN_5G_TDD    5G_RAN_TDD    master_classicalbts_all    RAN_5G    5G_RAN    STATE_SW_UPLOADED
# ...    PY36
# ...    SBTS00    CLOUD_5G_CLASSICAL_QC_ASIKL_ABILB1_AENB_ENB    SBTS22R1    SBTS22R2    SBTS22R4    CRT_22R4    CRT_23R1
# ...    SBTS23R1    SBTS23R2
# 
# *** Variables ***
# 
# *** Test Cases ***
# #[1]CB007833-5G-A_01_RU_online_access_to_Black_Box_contents
# #    [Tags]    CRT_TRUNK    CRT_22R1    CRT_22R2    CRT_22R3
# #    CB007833-5G-A_01_RU_online_access_to_Black_Box_contents
# #
# #[1]CB007833-5G-A_02_RU_Definition_of_Black_Box_Contents_Format
# #    [Tags]    CRT_TRUNK    CRT_22R1    CRT_22R2    CRT_22R3
# #    CB007833-5G-A_02_RU_Definition_of_Black_Box_Contents_Format
# #
# #[1]CB007833-5G-A_04_RU_Black_Box_Handing_not_to_affect_other_BTS_functions
# #    [Tags]    CRT_TRUNK    CRT_22R1    CRT_22R2    CRT_22R3
# #    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
# #
# #[1]CB007833-5G-A_05_RU_Time-of-day_for_BlackBox_entries
# #    [Tags]    CRT_TRUNK    CRT_22R1    CRT_22R2    CRT_22R3
# #    CB007833-5G-A_05_RU_Time-of-day_for_BlackBox_entries
# 
# #[1]CB007833-5G-A_08_RU_parameter_CPU_load_in_BBOX5
# #    [Tags]    CRT_TRUNK    CRT_22R1    CRT_22R2    CRT_22R3
# #    CB007833-5G-A_8_RU_parameter_CPU_load_in_BBOX5
# #
# #[1]CB007833-5G-A_09_RU_parameter_memory_load_in_BBOX5
# #    [Tags]    CRT_TRUNK    CRT_22R1    CRT_22R2    CRT_22R3
# #    CB007833-5G-A_9_RU_parameter_memory_load_in_BBOX5
# #
# #[1]CB007833-5G-A_10_RU_installation_time_optical_signal_level_in_BBOX5
# #    [Tags]    CRT_TRUNK    CRT_22R1    CRT_22R2    CRT_22R3
# #    CB007833-5G-A_10_RU_installation_time_optical_signal_level_in_BBOX5
# 
# #[1]CB006502_AENB_General_SiSo_RF_module_power_reset
# #    [Tags]    CRT_20B    CRT_TRUNK    CRT_21A    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3
# #    General_SiSo_RF_module_power_reset
# #
# #[1]CB006502_AENB_General_SiSo_BTS_startup_with_RF_delayed_startup
# #    [Tags]    CRT_20B    CRT_TRUNK    CRT_21A    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3
# #    General_SiSo_BTS_startup_with_RF_delayed_startup
# #
# #[1]CB006502_AENB_General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed_PMAX
# #    [Tags]    CRT_20B    CRT_TRUNK    CRT_21A    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3
# #    General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed_PMAX
# 
# #[1]CB006502_AENB_General_SiSo_NR-ARFCN_check
# #    [Tags]    CRT_20B    CRT_TRUNK    CRT_21A    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3
# #    General_SiSo_NR-ARFCN_check
# #
# #[1]CB006502_AENB_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
# #    [Tags]    CRT_20B    CRT_TRUNK    CRT_21A    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3
# #    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
# 
# [1]CB006502_AENB_General_SiSo_E2E_system_setup_with_data_transfer_conducted_MCS27_30km_60MHz
#     [Tags]    CRT_20B    CRT_TRUNK    CRT_21A    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3
#     reboot_ue_except_askey_and_cpe
#     data_transfer_common    tput_self_define=${tput_define_60M}    cell_id=${cell_1}    loop_times=${3}    duration=${300}
#     ...    ui_version=${ui_version_xiaomi}    target_avg_percent=0.95    min_percent=0.85
# 
# [1]CB006502_AENB_General_SiSo_RU_lock_unlock
#     [Tags]    CRT_20B    CRT_TRUNK    CRT_21A    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3
#     reboot_ue_except_askey_and_cpe
#     RU_lock_unlock_excute
# 
# [1]CB006502_AENB_General_SiSo_Cell_lock_and_unlock
#     [Tags]    CRT_20B    CRT_TRUNK    CRT_21A    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3
#     reboot_ue_except_askey_and_cpe
#     General_SiSo_Cell_lock_and_unlock    with_peak=True
# 
# #[1]CB006502_AENB_General_SiSo_E2E_system_setup_with_data_transfer_conducted_60MHz_1070_GP1
# #    [Tags]    CRT_20B    CRT_TRUNK    CRT_21A    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3
# #    General_SiSo_Peak_with_Given_Information    band=60    frame_structure=1070_GP1_A3    iperf_type=via_command
# #
# #[1]CB006502_AENB_General_SiSo_E2E_system_setup_with_data_transfer_conducted_60MHz_1116_3ms_GP1
# #    [Tags]    CRT_20B    CRT_TRUNK    CRT_21A    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3
# #    General_SiSo_Peak_with_Given_Information    band=60    frame_structure=1116_3ms_GP1_A5    iperf_type=via_command
# #
# #[1]CB006502_AENB_General_SiSo_E2E_system_setup_with_data_transfer_conducted_60MHz_1208_GP1
# #    [Tags]    CRT_20B    CRT_TRUNK    CRT_21A    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3
# #    General_SiSo_Peak_with_Given_Information    band=60    frame_structure=1208_GP1_A1    iperf_type=via_command
# 
# #[1]CB006502_AENB_General_SiSo_E2E_system_setup_with_data_transfer_conducted_MCS27_30km_40MHz
# #   [Tags]    CRT_20B    CRT_TRUNK    CRT_21A    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3
# #    General_SiSo_Peak_with_Given_Information    band=40    frame_structure=1116_0ms_GP2_A7    iperf_type=via_command
# 
# #[1]CB006502_AENB_General_SiSo_RF_alarms_without_recovery
# #    [Tags]    CRT_20B    CRT_TRUNK    CRT_21A    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3
# #    General_SiSo_RF_alarms_without_recovery
# 
# #[1]General_SiSo_BTS_(Q)SFP+SFP28_provisioning_enhancements
# #    General_SiSo_BTS_(Q)SFP+SFP28_provisioning_enhancements
# 
# #CB006502_Customer_Pronto_PMAX
# #    [Tags]    CRT_20B    CRT_TRUNK    CRT_21A    CRT_21B    CRT_22R1    CRT_22R2
# #    Customer_Pronto_PMAX
# 
# #[1]CB007833-5G-A_06_RU_Black_Box_contents_in_BTS_Technical_Log
# #    [Tags]    CRT_TRUNK    CRT_22R1    CRT_22R2    CRT_22R3
# #    CB007833-5G-A_06_RU_Black_Box_contents_in_BTS_Technical_Log_All_RU_Operation
# #
# #[1]CB007833-5G-A_07_RU_Minimum_information_in_Black_Box
# #    [Tags]    CRT_TRUNK    CRT_22R1    CRT_22R2    CRT_22R3
# #    CB007833-5G-A_7_RU_Minimum_information_in_Black_Box_snapshot_operation
# #
# #[1]CB006502_AENB_General_SiSo_RF_alarms_with_recovery
# #    [Tags]    CRT_20B    CRT_TRUNK    CRT_21A    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3
# #    General_SiSo_RF_alarms_with_recovery
# 
# *** Keywords ***
