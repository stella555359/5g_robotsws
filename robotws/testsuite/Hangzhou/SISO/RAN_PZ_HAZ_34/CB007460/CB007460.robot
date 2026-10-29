# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}
# Test Teardown        SISO Coam Test Teardown
# Test Timeout         180 min
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot
# 
# 
# Documentation
# ...    Author:zhihao shi
# ...    contact:zhihao.shi@nokia-sbell.com
# ...    squad group:SG_04
# ...    Feature CB007460 in 5G21B program
# 
# Force Tags            5G_RAN    5G_RAN_TDD
# ...    PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# #TL316
# [1]CB007460-5G-B_03_03_AEQQ_Full_Split_Mode_General_SiSo_E2E_system_L3Call_when_mixed-BW_80MHz_50MHz
#     [Tags]    1S-2CC-4D-4U_Split_Mode    CRT_22R3    CRT_22R4    CRT_TRUNK
#     ${ue_num_each_call}    Get Tput ue Number    given_num=2
#     General_SiSo_Peak_with_Given_Information    use_case_variable=${True}    suite_name=${SUITE NAME}    test_name=${TEST NAME}
#     ...    ue_num_each_call=${ue_num_each_call}
# 
# #[1]CB007460-5G-B_01_04_Reconfiguration_from_full_TRX_mode_to_full_split_panel_mode_of_NR-NR_16TRX
# #    [Tags]    1S-2CC-4D-4U_Split_Mode
# #    General_SiSo_Reconfiguration_from_full_TRX_mode_to_full_split_panel_mode_of_NR-NR_16TRX
# #
# #[1]CB007460-5G-B_01_05_Reconfiguration_from_full_split_panel_mode_of_NR-NR_16TRX_to_full_TRX_mode
# #    [Tags]    1S-2CC-4D-4U_Split_Mode
# #    General_SiSo_Reconfiguration_from_full_split_panel_mode_of_NR-NR_16TRX_to_full_TRX_mode
# #
# #[1]CB007460-5G-B_02_01_Split_Mode_General_SiSo_Cell_lock_and_unlock
# #    [Tags]    1S-2CC-4D-4U_Split_Mode
# #    General_SiSo_Cell_lock_and_unlock
# #
# #[1]CB007460-5G-B_02_02_Split_Mode_General_SiSo_RU_lock_and_unlock
# #    [Tags]    1S-2CC-4D-4U_Split_Mode
# #    General_SiSo_RU_lock_unlock
# #
# #[1]CB007460-5G-B_02_03_Split_Mode_General_SiSo_RU_module_reset_from_GUI
# #    [Tags]    1S-2CC-4D-4U_Split_Mode
# #    General_SiSo_RF_module_reset_from_GUI
# #
# #[1]CB007460-5G-B_03_01_AEQQ_Full_Split_Mode_General_SiSo_E2E_system_L3Call_setup_with_data_transfer_conducted_when_mixed-BW_60MHz_30MHz
# #    [Tags]    1S-2CC-4D-4U_Split_Mode
# #    ${ue_num_each_call}    Get Tput ue Number    given_num=2
# #    General_SiSo_Peak_with_Given_Information    use_case_variable=${True}    suite_name=${SUITE NAME}    test_name=${TEST NAME}
# #    ...    ue_num_each_call=${ue_num_each_call}
# #
# #[1]CB007460-5G-B_03_02_AEQQ_Full_Split_Mode_General_SiSo_E2E_system_L3Call_setup_with_data_transfer_conducted_when_mixed-BW_70MHz_20MHz
# #    [Tags]    1S-2CC-4D-4U_Split_Mode
# #    ${ue_num_each_call}    Get Tput ue Number    given_num=2
# #    General_SiSo_Peak_with_Given_Information    use_case_variable=${True}    suite_name=${SUITE NAME}    test_name=${TEST NAME}
# #    ...    ue_num_each_call=${ue_num_each_call}
# #
# #[1]CB007460-5G-B_03_04_AEQZ_Full_Split_Mode_General_SiSo_E2E_system_L3Call_setup_with_data_transfer_conducted_when_mixed-BW_100MHz_40MHz
# #    [Tags]    1S-2CC-4D-4U_Split_Mode
# #    ${ue_num_each_call}    Get Tput ue Number    given_num=2
# #    General_SiSo_Peak_with_Given_Information    use_case_variable=${True}    suite_name=${SUITE NAME}    test_name=${TEST NAME}
# #    ...    ue_num_each_call=${ue_num_each_call}
# #
# #[1]CB007460-5G-B_03_05_AEQZ_Full_Split_Mode_General_SiSo_E2E_system_L3Call_setup_with_data_transfer_conducted_when_mixed-BW_60MHz_40MHz
# #    [Tags]    1S-2CC-4D-4U_Split_Mode
# #    ${ue_num_each_call}    Get Tput ue Number    given_num=2
# #    General_SiSo_Peak_with_Given_Information    use_case_variable=${True}    suite_name=${SUITE NAME}    test_name=${TEST NAME}
# #    ...    ue_num_each_call=${ue_num_each_call}
# #
# #[1]CB007460-5G-B_03_06_AEQZ_Full_Split_Mode_General_SiSo_E2E_system_L3Call_setup_with_data_transfer_conducted_when_mixed-BW_20MHz_20MHz
# #    [Tags]    1S-2CC-4D-4U_Split_Mode
# #    General_SiSo_E2E_system_setup_with_data_transfer    band=20    ue_num_each_call=2
# #
# #[1]CB007460-5G-E_02_01_AEQQ_mix_AEQY_Split_Mode_General_SiSo_Cell_lock_and_unlock_when_mixed-BW_60+30MHz_20+70M_80+50M
# #    [Tags]    3S-2CC-4D-4U_Split_Mode
# #    General_SiSo_Cell_lock_and_unlock
# #
# #[1]CB007460-5G-E_02_02_AEQQ_mix_AEQY_Split_Mode_General_SiSo_RU_lock_unlock_when_mixed-BW_60+30MHz_20+70M_80+50M
# #    [Tags]    3S-2CC-4D-4U_Split_Mode
# #    General_SiSo_RU_lock_unlock
# #
# #[1]CB007460-5G-E_02_03_AEQQ_mix_AEQY_Split_Mode_General_SiSo_RU_module_reset_from_GUI_when_mixed-BW_60+30MHz_20+70M_80+50M
# #    [Tags]    3S-2CC-4D-4U_Split_Mode
# #    General_SiSo_RF_module_reset_from_GUI
# #
# #[1]CB007460-5G-E_02_07_AEQQ_mix_AEQY_Split_Mode_General_SiSo_OAM_KPI_61a_SiSo_Auto_BTS_site_reset
# #    [Tags]    3S-2CC-4D-4U_Split_Mode
# #    [Timeout]    12h
# #    Set Log Level    INFO
# #    General_Stability_Test_Case    case_name=General_SiSo_Auto_BTS_site_reset    times=${20}    pass=${19}
# #
# #[1]CB007460-5G-E_02_08_AEQY_mix_AEQQ_Split_Mode_General_SiSo_E2E_system_L3Call_setup_with_data_transfer_conducted
# #    [Tags]    3S-2CC-4D-4U_Split_Mode
# #    ${ue_num_each_call}    Get Tput ue Number    given_num=1
# #    General_SiSo_Peak_with_Given_Information    use_case_variable=${True}    suite_name=${SUITE NAME}    test_name=${TEST NAME}
# #    ...    ue_num_each_call=${ue_num_each_call}
# #
# #[1]CB007460-5G-E_02_09_AEQY_mix_AEQQ_Split_Mode_General_SiSo_E2E_system_L3Call_setup_with_data_transfer_conducted
# #    [Tags]    3S-2CC-4D-4U_Split_Mode
# #    ${ue_num_each_call}    Get Tput ue Number    given_num=1
# #    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1208_GP1_A1    ue_num_each_call=${ue_num_each_call}
# #
# #[1]CB007460-5G-B_01_01_Feature_Activate_and_Configure_SCF_Paramerer_Migration_Checking_on_WebUI
# #    [Tags]    1S-2CC-4D-4U_Split_Mode
# #    General_SiSo_Activate_and_Configure_SCF_Paramerer_Migration_Checking_on_WebUI
# #
# #[1]CB007460-5G-B_01_02_Activation_and_configuration_of_NR-NR_16TRX_full_split_antenna_array_mode
# #    [Tags]    1S-2CC-4D-4U_Split_Mode
# #    General_SiSo_Activation_and_configuration_of_NR-NR_16TRX_full_split_antenna_array_mode
# #
# #[1]CB007460-5G-B_01_03_Activation_and_configuration_of_NR-NR_16TRX_half_split_panel_antenna_array_mode
# #    [Tags]    1S-2CC-4D-4U_Split_Mode
# #    General_SiSo_Activation_and_configuration_of_NR-NR_16TRX_half_split_panel_antenna_array_mode
# #
# #[1]CB007460-5G-B_01_07_Reconfiguration_from_half_split_panel_mode_of_NR-NR_16TRX_to_full_TRX_mode
# #    [Tags]    1S-2CC-4D-4U_Split_Mode
# #    General_SiSo_Reconfiguration_from_half_split_panel_mode_of_NR-NR_16TRX_to_full_TRX_mode
# #
# #[1]CB007460-5G-B_04_06_Split_Mode_Interworking_with_5GC000430_Powering_Saving
# #    [Tags]    1S-2CC-4D-4U_Split_Mode
# #    General_SiSo_Split_Mode_Interworking_with_5GC000430_Powering_Saving
# 
# *** Keywords ***
