# *** Settings ***
# Documentation    Auther:xiaoxia.hao@nokia-sbell.com
# Suite Setup    702 Suite Setup For UTE
# Suite Teardown    702 Suite TearDown For UTE
# Force Tags            5G_RAN_TDD    STATE_SW_UPLOADED    master_classicalbts_all    CLOUD_5G_CLASSICAL_ASIKL_ABILB1_2xAZQH
# ...    PY39
# ...           CRT_UTE    5G_RAN    SBTS23R1    RAN_5G    RAN_5G_TDD
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_lock_and_unlock.robot
# Resource    Resources/5GC000702_common_ute.robot
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]5GC000702_M_159_Configuration_Of_2S_1CC_4DL_2UL_RU_lock_unlock_AZQH
#     [Documentation]    1 RU lock and unlock one by one, 5GC001821-4;5GC000702-28
#     ...                CHBW:80MHz
#     [Timeout]    90m
#     [Setup]  702 Case SetUp For UTE    update_param_name=${FRAME_TO_11163ms_80MHz_4Symbols}
#     5GC000702_M_159_Configuration_Of_2S_1CC_4DL_2UL_RU_lock_unlock_AZQH
#     [Teardown]   702 Case TearDown For UTE    case_contain_special_operation=${True}
# 
# [1]5GC000702_M_166_Configuration_Of_2S_1CC_4DL_2UL_RU_lock_unlock_AZQL
#     [Documentation]    1 RU lock and unlock one by one, 5GC000702-26;5GC000702-28
#     ...                CHBW:20MHz
#     ...                Feature_ID:5GC000702-M;5GC001849-A;5GC002142-B
#     [Timeout]    90m
#     [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_26_${stream}    update_param_name=${FRAME_TO_1208_20MHz_2Symbols}
#     5GC000702_M_166_Configuration_Of_2S_1CC_4DL_2UL_RU_lock_unlock_AZQL
#     [Teardown]    702 Case TearDown For UTE
# 
# [1]5GC000702_M_161_Configuration_Of_2S_1CC_4DL_2UL_RU_lock_unlock_AZQH
#     [Documentation]    1 RU lock and unlock one by one, 5GC000702-36;5GC000702-28
#     ...                CHBW:80MHz
#     [Timeout]    90m
#     [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_36_${stream}
#     5GC000702_M_161_Configuration_Of_2S_1CC_4DL_2UL_RU_lock_unlock_AZQH
#     [Teardown]   702 Case TearDown For UTE
# 
# [1]5GC000702_M_153_Configuration_Of_2S_1CC_4DL_2UL_cell_lock_unlock_AZQH
#     [Documentation]    1 cell lock and unlock one by one,5GC000702-36;5GC000702-28
#     ...                CHBW:60MHz
#     ...                Feature_ID:5GC000702-MG
#     [Timeout]    90m
#     [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_36_${stream}    update_param_name=${FRAME_TO_11160ms_60MHz_4Symbols}
#     5GC000702_M_153_Configuration_Of_2S_1CC_4DL_2UL_cell_lock_unlock_AZQH
#     [Teardown]    702 Case TearDown For UTE
# 
# [1]5GC000702_M_112_Configuration_Of_2S_1CC_4DL_256QAM_2UL_64QAM_100MHz_mcs15_SFP_FORT_[L3CALL]_AZQL
#     [Documentation]    L3 call for 100M 4X4,5GC001821-4;5GC000702-28
#     ...               CHBW:100MHz
#     [Timeout]    60m
#     [Setup]  702 Case SetUp For UTE
#     5GC000702_M_112_Configuration_Of_2S_1CC_4DL_256QAM_2UL_64QAM_100MHz_mcs15_SFP_FORT_L3_Call_AZQL
#     [Teardown]   702 Case TearDown For UTE
# 
# [1]5GC001451_4_subSector_OpenLoop_2x2_256QAM_Rank2
#     [Documentation]
#     ...    This test case is used to test 1451-B case : openloop fixed rank2, 256qam
#     ...    CHBW:100MHz
#     ...    This case used to cover FGCR-7155 General_SiSo_Cell_lock_and_unlock on 20B,
#     [Timeout]    90m
#     [Setup]    702 Case SetUp For UTE    scf_file_name=Configuration_2142_A_4_subSector_${stream}
#     5GC001451_4_subSector_OpenLoop_2x2_256QAM_Rank2
#    [Teardown]    702 Case TearDown For UTE
