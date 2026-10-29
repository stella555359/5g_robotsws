# *** Settings ***
# Documentation    Author: xiaoxia.hao@nokia-sbell.com
# Suite Setup    702 Suite Setup For UTE
# Suite Teardown    702 Suite TearDown For UTE
# Force Tags            5G_RAN_TDD    STATE_SW_UPLOADED    master_classicalbts_all    CLOUD_5G_CLASSICAL_ASIKL_ABILB1_2xAZQH
# ...    PY36
# ...           CRT_UTE    SBTS00    RAN_5G    RAN_5G_TDD
# Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC000702/Resources/5GC000702_common_ute.robot
# 
# 
# *** Test Cases ***
# #[1]5GC001451_2_subSector_2xPol_CloseLoop_4x4_64QAM_Rank4
# #    [Documentation]
# #    ...    This test case is used to test 1451-A : closeloop gnb fixed rank4, 64qam
# #    ...    CHBW:100MHz
# #    [Timeout]    60m
# #    [Setup]    702 Case SetUp For UTE    scf_file_name=Configuration_36
# #    5GC001451_2_subSector_2xPol_CloseLoop_4x4_64QAM_Rank4
# #   [Teardown]    702 Case TearDown For UTE
# 
# #[1]5GC001451_2_subSector_1xPol_CloseLoop_4x4_256QAM_Rank4
# #    [Documentation]
# #    ...    This test case is used to test 1451-A : closeloop gnb fixed rank4, 256qam
# #    ...    CHBW:100MHz
# #    [Timeout]    60m
# #    [Setup]    702 Case SetUp For UTE    scf_file_name=Configuration_36    update_param_name=${FRAME_TO_1208_50MHz_2Symbols}
# #    5GC001451_2_subSector_1xPol_CloseLoop_4x4_256QAM_Rank4
# #   [Teardown]    702 Case TearDown For UTE
# 
# #[1]5GC001451_4_subSector_CloseLoop_2x2_256QAM_Rank2
# #    [Documentation]
# #    ...    This test case is used to test 1451-B : closeloop gnb fixed rank1, 256qam
# #    ...    CHBW:100MHz
# #    ...    This case used to cover FGCR-7155 General_SiSo_RU_lock_unlock on 20B,
# #    [Timeout]    60m
# #    [Setup]    702 Case SetUp For UTE    scf_file_name=Configuration_2142_A_4_subSector
# #    5GC001451_4_subSector_CloseLoop_2x2_256QAM_Rank2
# #   [Teardown]    702 Case TearDown For UTE
# 
# #[1]5GC001451_4_subSector_OpenLoop_2x2_256QAM_Rank2
# #    [Documentation]
# #    ...    This test case is used to test 1451-B case : openloop fixed rank2, 256qam
# #    ...    CHBW:100MHz
# #    ...    This case used to cover FGCR-7155 General_SiSo_Cell_lock_and_unlock on 20B,
# #    [Timeout]    60m
# #    [Setup]    702 Case SetUp For UTE    scf_file_name=Configuration_2142_A_4_subSector
# #    5GC001451_4_subSector_OpenLoop_2x2_256QAM_Rank2
# #   [Teardown]    702 Case TearDown For UTE