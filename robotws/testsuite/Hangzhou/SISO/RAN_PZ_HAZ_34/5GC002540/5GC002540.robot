# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}
# Test Teardown        SISO Coam Test Teardown
# Test Timeout         800 min
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot
# 
# Documentation
# ...    Author: zhihao shi
# ...    Contact: zhihao.shi@nokia-sbell.com
# ...    squad group:SG_04
# ...    Feature 5GC002540 in trunk program
# 
# Force Tags            5G_RAN_TDD
# ...   PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1][1.0] 5GC002540-E-11_04_AEQY_mix_AEQE_General_SiSo_E2E_system_setup_with_data_transfer_conducted_3S_100+50M
#     [Tags]    3S-2CC-8D-4U    CRT_22R4    CRT_22R3    CRT_TRUNK
#     ${cell_list}    Get All Cell Id
#     Get UE From Init File and Make call  cell_list=${cell_list}  with_peak=${True}  duration=${600}    check_ue=${True}
# 
# [1][1.0] 5GC002540-E-11_02_AEQY_mix_AEQE_General_SiSo_Cell_block_and_unblock
#     [Tags]    3S-2CC-8D-4U    CRT_22R4    CRT_22R3    CRT_TRUNK
#     ${fault_list}    Create List    49
#     Allowed Watchdog additional alarms    fault_list=${fault_list}
#     E2E_SiSo_Cell_block_and_unblock_gNB
# 
# #[1][1.0] 5GC002540-E-11_02_AEQY_mix_AEQE_General_SiSo_Cell_lock_and_unlock
# #    General_SiSo_Cell_lock_and_unlock
# #
# #[1]5GC002540-G-15_07_AEQY_OAM_KPI_61a_SiSo_Auto_BTS_site_reset
# #    [Tags]    3S-2CC-4D-4U
# #    [Timeout]    8h
# #    Set Log Level    INFO
# #    General_Stability_Test_Case    case_name=General_SiSo_Auto_BTS_site_reset    times=${20}    pass=${19}
# #
# #[1]5GC002540-G-15_07_AEQY_mix_AEQE_OAM_KPI_61a_SiSo_Auto_BTS_site_reset
# #    [Tags]    3S-2CC-4D-4U
# #    [Timeout]    8h
# #    Set Log Level    INFO
# #    General_Stability_Test_Case    case_name=General_SiSo_Auto_BTS_site_reset    times=${20}    pass=${19}
# #
# #[1]5GC002540-E-11_07_AEQY_OAM_KPI_61a_SiSo_Auto_BTS_site_reset
# #    [Tags]    3S-2CC-8D-4U
# #    [Timeout]    8h
# #    Set Log Level    INFO
# #    General_Stability_Test_Case    case_name=General_SiSo_Auto_BTS_site_reset    times=${20}    pass=${19}
# #
# #[1]5GC002540-C-9_07_AEQY_OAM_KPI_61a_SiSo_Auto_BTS_site_reset
# #    [Tags]    1S-2CC-8D-4U  25Ge
# #    [Timeout]    8h
# #    Set Log Level    INFO
# #    General_Stability_Test_Case    case_name=General_SiSo_Auto_BTS_site_reset    times=${20}    pass=${19}
# #
# #[1]5GC002540-C-23_07_AEQY_OAM_KPI_61a_SiSo_Auto_BTS_site_reset
# #    [Tags]    1S-2CC-8D-4U  10Ge
# #    [Timeout]    8h
# #    Set Log Level    INFO
# #    General_Stability_Test_Case    case_name=General_SiSo_Auto_BTS_site_reset    times=${20}    pass=${19}
# #
# #[1]5GC002540-G-15_01_AEQY_mix_AEQE_General_SiSo_Commissioning_BTS_Template_Commissioning
# #    [Tags]    3S-2CC-4D-4U
# #    General_SiSo_Commissioning_BTS_Template_Commissioning
# #
# #[1]5GC002540-G-15_02_AEQY_mix_AEQE_General_SiSo_Cell_lock_and_unlock
# #    [Tags]    3S-2CC-4D-4U
# #    General_SiSo_Cell_lock_and_unlock
# #
# #[1]5GC002540-G-15_03_AEQY_mix_AEQE_General_SiSo_RU_lock_unlock
# #    [Tags]    3S-2CC-4D-4U
# #    General_SiSo_RU_lock_unlock
# #
# #[1]5GC002540-G-15_04_AEQY_mix__AEQE_General_SiSo_E2E_system_setup_with_data_transfer_conducted_3S_100+100M
# #    [Tags]    3S-2CC-4D-4U
# #    ${ue_num_each_call}    Get Tput ue Number    given_num=2
# #    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1208_GP1_A1    ue_num_each_call=${ue_num_each_call}
# #
# #[1]5GC002540-G-15_05_AEQY_mix_AEQE_General_SiSo_RF_module_reset_from_GUI
# #    [Tags]    3S-2CC-4D-4U
# #    General_SiSo_RF_module_reset_from_GUI    with_call=${True}
# #
# #[1]5GC002540-G-15_08_AEQY_mix_AEQE_General_SiSo_RF_module_power_reset_with_L3call
# #    [Tags]    3S-2CC-4D-4U
# #    General_SiSo_RF_module_power_reset
# #
# #[1]5GC002540-C-9_01_AEQY_General_SiSo_Commissioning_BTS_Template_Commissioning
# #    [Tags]    1S-2CC-8D-4U
# #    General_SiSo_Commissioning_BTS_Template_Commissioning
# #
# #[1]5GC002540-C-9_02_AEQY_General_SiSo_Cell_lock_and_unlock
# #    [Tags]    1S-2CC-8D-4U
# #    General_SiSo_Cell_lock_and_unlock
# #
# #[1]5GC002540-C-9_03_AEQY_General_SiSo_RU_lock_unlock
# #    [Tags]    1S-2CC-8D-4U
# #    General_SiSo_RU_lock_unlock
# #
# #[1]5GC002540-C-9_04_AEQY_General_SiSo_E2E_system_setup_with_data_transfer_conducted_100+100M
# #    [Tags]    1S-2CC-8D-4U
# #    ${ue_num_each_call}    Get Tput ue Number    given_num=2
# #    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1208_GP1_A1    ue_num_each_call=${ue_num_each_call}
# #
# #[1]5GC002540-C-9_05_AEQY_General_SiSo_RF_module_reset_from_GUI
# #    [Tags]    1S-2CC-8D-4U
# #    General_SiSo_RF_module_reset_from_GUI    with_call=${True}
# #
# #[1]5GC002540-C-9_08_AEQY_General_SiSo_RF_module_power_reset_with_L3call
# #    [Tags]    1S-2CC-8D-4U
# #    General_SiSo_RF_module_power_reset    with_call=${True}
# #
# #[1]5GC002540-C-23_01_AEQY_General_SiSo_Commissioning_BTS_Template_Commissioning
# #    [Tags]    1S-2CC-8D-4U
# #    General_SiSo_Commissioning_BTS_Template_Commissioning
# #
# #[1]5GC002540-C-23_02_AEQY_General_SiSo_Cell_lock_and_unlock
# #    [Tags]    1S-2CC-8D-4U
# #    General_SiSo_Cell_lock_and_unlock
# #
# #[1]5GC002540-C-23_03_AEQY_General_SiSo_RU_lock_unlock
# #    [Tags]    1S-2CC-8D-4U
# #    General_SiSo_RU_lock_unlock
# #
# #[1]5GC002540-C-23_04_AEQY_General_SiSo_E2E_system_setup_with_data_transfer_conducted_60+60M
# #    [Tags]    1S-2CC-8D-4U
# #    ${ue_num_each_call}    Get Tput ue Number    given_num=2
# #    General_SiSo_Peak_with_Given_Information    band=60    frame_structure=1116_3ms_GP1_B5    ue_num_each_call=${ue_num_each_call}
# #
# #[1]5GC002540-C-23_05_AEQY_General_SiSo_RF_module_reset_from_GUI
# #    [Tags]    1S-2CC-8D-4U
# #    General_SiSo_RF_module_reset_from_GUI    with_call=${True}
# #
# #[1]5GC002540-C-23_08_AEQY_General_SiSo_RF_module_power_reset_with_L3call
# #    [Tags]    1S-2CC-8D-4U
# #    General_SiSo_RF_module_power_reset    with_call=${True}
# #
# #[1]5GC002540-C-23_09_AEQY_General_SiSo_E2E_system_setup_with_data_transfer_conducted_20+20M
# #    [Tags]    1S-2CC-8D-4U
# #    General_SiSo_E2E_system_setup_with_data_transfer    band=20    ue_num_each_call=2    random_access=${True}
# #
# #[1]5GC002540-C-23_10_AEQY_General_SiSo_E2E_system_setup_with_data_transfer_conducted_20+100M
# #    [Tags]    1S-2CC-8D-4U
# #    ${ue_num_each_call}    Get Tput ue Number    given_num=2
# #    General_SiSo_Peak_with_Given_Information    use_case_variable=${True}    suite_name=${SUITE NAME}    test_name=${TEST NAME}
# #    ...    ue_num_each_call=${ue_num_each_call}
# #
# #[1]5GC002540-C-23_11_AEQY_General_SiSo_E2E_system_setup_with_data_transfer_conducted_20+60M
# #    [Tags]    1S-2CC-8D-4U
# #    ${ue_num_each_call}    Get Tput ue Number    given_num=2
# #    General_SiSo_Peak_with_Given_Information    use_case_variable=${True}    suite_name=${SUITE NAME}    test_name=${TEST NAME}
# #    ...    ue_num_each_call=${ue_num_each_call}
# #
# #5GC002540-G-27_01_AEQY_mix_AEQE_General_SiSo_Commissioning_BTS_Template_Commissioning
# #    [Tags]    3S-2CC-4D-4U
# #    General_SiSo_Commissioning_BTS_Template_Commissioning
# #
# #5GC002540-G-27_02_AEQY_mix_AEQE_General_SiSo_Cell_lock_and_unlock
# #    [Tags]    3S-2CC-4D-4U
# #    General_SiSo_Cell_lock_and_unlock
# #
# #5GC002540-G-27_03_AEQY_mix_AEQE_General_SiSo_RU_lock_unlock
# #    [Tags]    3S-2CC-4D-4U
# #    E2E_SiSo_RU_lock_and_unlock_gNB
# #
# #[1]5GC002540-G-27_04_AEQY_mix_AEQE_General_SiSo_E2E_system_setup_with_data_transfer_conducted_3S_100+50M
# #    [Tags]    3S-2CC-4D-4U
# #    ${cell_list}  create list  ${2}
# #    Get UE From Init File and Make call  cell_list=${cell_list}  with_peak=${True}
# #
# #5GC002540-G-27_05_AEQY_mix_AEQE_General_SiSo_RF_module_reset_from_GUI
# #    [Tags]    3S-2CC-4D-4U
# #    General_SiSo_RF_module_reset_from_GUI    with_call=${True}
# #
# #5GC002540-G-27_07_AEQY_mix_AEQE_OAM_KPI_61a_SiSo_Auto_BTS_site_reset
# #    [Tags]    3S-2CC-4D-4U
# #    [Timeout]    8h
# #    Set Log Level    INFO
# #    General_Stability_Test_Case    case_name=General_SiSo_Auto_BTS_site_reset    times=${20}    pass=${19}
# #
# #5GC002540-G-27_08_AEQY_mix_AEQE_General_SiSo_RF_module_power_reset_with_L3call
# #    [Tags]    3S-2CC-4D-4U
# #    General_SiSo_RF_module_power_reset    with_call=${True}
# #
# #[1]5GC002540-G-15_09_AEQY_mix_AEQE_General_SiSo_E2E_system_setup_with_data_transfer_conducted_2020M_20100M_6050M
# #    [Tags]    3S-2CC-4D-4U
# #    ${ue_num_each_call}    Get Tput ue Number    given_num=2
# #    General_SiSo_Peak_with_Given_Information    use_case_variable=${True}    suite_name=${SUITE NAME}    test_name=${TEST NAME}
# #    ...    ue_num_each_call=${ue_num_each_call}
# #
# #[1]5GC002540-G-15_10_AEQY_mix_AEQE_General_SiSo_E2E_system_setup_with_data_transfer_conducted_10030M_8070M_5050M
# #    [Tags]    3S-2CC-4D-4U
# #    ${ue_num_each_call}    Get Tput ue Number    given_num=2
# #    General_SiSo_Peak_with_Given_Information    use_case_variable=${True}    suite_name=${SUITE NAME}    test_name=${TEST NAME}
# #    ...    ue_num_each_call=${ue_num_each_call}
# #
# #[1]5GC002540-G-15_11_AEQY_mix_AEQE_General_SiSo_E2E_system_setup_with_data_transfer_conducted_6040M_7020M_8050M
# #    [Tags]    3S-2CC-4D-4U
# #    ${ue_num_each_call}    Get Tput ue Number    given_num=2
# #    General_SiSo_Peak_with_Given_Information    use_case_variable=${True}    suite_name=${SUITE NAME}    test_name=${TEST NAME}
# #    ...    ue_num_each_call=${ue_num_each_call}
# #
# #[1]5GC002540-E-11_01_AEQY_mix_AEQE_General_SiSo_Commissioning_BTS_Template_Commissioning
# #    [Tags]    3S-2CC-8D-4U
# #    General_SiSo_Commissioning_BTS_Template_Commissioning
# #
# #[1]5GC002540-E-11_03_AEQY_mix_AEQE_General_SiSo_RU_lock_unlock
# #    [Tags]    3S-2CC-8D-4U
# #    General_SiSo_RU_lock_unlock
# #
# #[1]5GC002540-E-11_05_AEQY_mix_AEQE_General_SiSo_RF_module_reset_from_GUI
# #    [Tags]    3S-2CC-8D-4U
# #    General_SiSo_RF_module_reset_from_GUI
# #
# #[1]5GC002540-E-11_07_AEQY_mix_AEQE_OAM_KPI_61a_SiSo_Auto_BTS_site_reset
# #    [Tags]    3S-2CC-8D-4U
# #    [Timeout]    8h
# #    Set Log Level    INFO
# #    General_Stability_Test_Case    case_name=General_SiSo_Auto_BTS_site_reset    times=${20}    pass=${19}
# #
# #[1]5GC002540-E-11_08_AEQY_AEQE_General_SiSo_RF_module_power_reset_with_L3call
# #    [Tags]    3S-2CC-8D-44
# #    General_SiSo_RF_module_power_reset    with_call=${True}
# #
# #[1]5GC002540-E-11_09_AEQY_AEQE_General_SiSo_E2E_system_setup_with_data_transfer_conducted_2020M_20100M_2060M
# #    [Tags]    3S-2CC-8D-4U
# #    ${ue_num_each_call}    Get Tput ue Number    given_num=2
# #    General_SiSo_Peak_with_Given_Information    use_case_variable=${True}    suite_name=${SUITE NAME}    test_name=${TEST NAME}
# #    ...    ue_num_each_call=${ue_num_each_call}
# 
# *** Keywords ***
