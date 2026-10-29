# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# Test Timeout         100 min
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RU_lock_unlock.robot
# Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_lock_and_unlock.robot
# Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot
# #Resource    ${BASIC_PATH_5G}/General_Stability_Test_Case.robot
# #Resource    ${BASIC_PATH_5G}/General_SiSo_Auto_BTS_site_reset.robot
# #Resource    ${BASIC_PATH_5G}/General_SiSo_Auto_Automatic_RAT_SW_upgrade.robot
# #Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
# #Resource    ${BASIC_PATH_5G}/General_SiSo_BTS_startup_with_RF_delayed_startup.robot
# 
# Documentation
# ...    Author: zhihao shi
# ...    Contact: zhihao.shi@nokia-sbell.com
# ...    squad group:SG_04
# ...    Feature 5GC002056-CFBH in 5G21A program
# 
# Force Tags            5G_RAN_TDD    STATE_GNB_COMMISSIONED    CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AEQY_ENB
# ...    PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1][1.0] 5GC002056-CFBH_011_AEQY_eCPRI_General_SiSo_RU_lock_unlock
#     [Tags]    CRT_21A
#     General_SiSo_RU_lock_unlock
# 
# [1][1.0] 5GC002056-CFBH_009_AEQY_eCPRI_General_SiSo_Cell_lock_and_unlock_1S
#     [Tags]    CRT_21A
#     General_SiSo_Cell_lock_and_unlock
# 
# [1][1.0] 5GC002056-CFBH_022_AEQY_eCPRI_General_SiSo_E2E_system_setup_with_data_transfer_100MHz_W_DBF_4X4MIMO_with_frame_structure_1208
#     [Tags]    CRT_21A
#     General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1208_GP1_A1    prach_index=98    dl_ul_layer=4DL2UL
# 
# [1][1.0] 5GC002056-CFBH_004_AEQY_eCPRI_General_SiSo_E2E_system_setup_with_data_transfer_20MHz_W_DBF_4X4MIMO_with_frame_structure_1116
#     [Tags]    CRT_TRUNK
#     General_SiSo_Peak_with_Given_Information    band=20    prach_index=98    frame_structure=1116_3ms_GP1_A5
#     ...    suite_name=${SUITE NAME}    test_name=${TEST NAME}
# 
# #[1][1.0] 5GC002056-CFBH_001_AEQY_eCPRI_General_SiSo_E2E_system_setup_with_data_transfer_conducted_WO_DBF_2X2MIMO_with_frame_structure_1116
# #    [Tags]    1S-1CC-2D-2U
# #    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1116_0ms_GP2_A7    prach_index=156
# #    ...    beamset=single beam    dl_ul_layer=2DL2UL
# #
# #[1][1.0] 5GC002056-CFBH_003_AEQY_eCPRI_General_SiSo_E2E_system_setup_with_data_transfer_conducted_WO_DBF_2X2MIMO_with_frame_structure_1070
# #    [Tags]    1S-1CC-2D-2U
# #    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1070_GP1_A3    prach_index=157
# #    ...    beamset=single beam    dl_ul_layer=2DL2UL
# #
# #[1][1.0] 5GC002056-CFBH_002_AEQY_eCPRI_General_SiSo_E2E_system_setup_with_data_transfer_conducted_WO_DBF_2X2MIMO_with_frame_structure_1208
# #    [Tags]    1S-1CC-2D-2U
# #    General_SiSo_Peak_with_Given_Information    band=100   frame_structure=1208_GP1_A1    prach_index=157
# #    ...    beamset=single beam    dl_ul_layer=2DL2UL
# #
# #[1][1.0] 5GC002056-CFBH_005_AEQY_eCPRI_General_SiSo_E2E_system_setup_with_data_transfer_40MHz_W_DBF_4X4MIMO_with_frame_structure_1208
# #    General_SiSo_Peak_with_Given_Information   band=40    frame_structure=1208_GP1_A1    prach_index=98    dl_ul_layer=4DL2UL
# #
# #[1][1.0] 5GC002056-CFBH_006_AEQY_eCPRI_General_SiSo_E2E_system_setup_with_data_transfer_60MHz_W_DBF_4X4MIMO_with_frame_structure_1070
# #    General_SiSo_Peak_with_Given_Information    band=60    frame_structure=1070_GP1_A3    prach_index=98    dl_ul_layer=4DL2UL
# #
# #[1][1.0] 5GC002056-CFBH_007_AEQY_eCPRI_General_SiSo_E2E_system_setup_with_data_transfer_80MHz_W_DBF_4X4MIMO_with_frame_structure_1208
# #    General_SiSo_Peak_with_Given_Information    band=80    frame_structure=1208_GP1_B1    prach_index=98    dl_ul_layer=4DL2UL
# #
# #[1][1.0] 5GC002056-CFBH_015_AEQY_eCPRI_OAM_KPI_61a_SiSo_Auto_BTS_site_reset_1S
# #    [Tags]    stability
# #    [Timeout]    8h
# #    Set Log Level    INFO
# #    General_Stability_Test_Case    case_name=General_SiSo_Auto_BTS_site_reset    times=${20}    pass=${19}
# #
# #[1][1.0] 5GC002056-CFBH_017_AEQY_eCPRI_OAM_KPI_64_SiSo_Auto_RU_SW_upgrade_success_rate
# #    [Tags]    stability
# #    [Timeout]    15h
# #    Set Log Level    INFO
# #    General_Stability_Test_Case    case_name=General_SiSo_Auto_Automatic_RAT_SW_upgrade    times=${20}    pass=${19}
# #
# #[1][1.0] 5GC002056-CFBH_014_AEQY_eCPRI_OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_WebUI
# #    [Tags]    stability
# #    [Timeout]    12h
# #    Set Log Level    INFO
# #    General_Stability_Test_Case    case_name=General_SiSo_RF_module_reset_from_GUI    times=${34}    pass=${33}
# #
# #[1][1.0] 5GC002056-CFBH_018_AEQY_eCPRI_General_SiSo_Auto_Cell_lock_and_unlock
# #    [Tags]    stability
# #    [Timeout]    12h
# #    Set Log Level    INFO
# #    General_Stability_Test_Case    case_name=General_SiSo_Cell_lock_and_unlock    times=${5}    pass=${4}
# #
# #[1][1.0] 5GC002056-CFBH_008_AEQY_eCPRI_General_SiSo_BTS_startup_with_RF_delayed_startup
# #    General_SiSo_BTS_startup_with_RF_delayed_startup
# 
# *** Keywords ***
