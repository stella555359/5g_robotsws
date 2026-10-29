# *** Settings ***
# Documentation    Auther:xiaoxia.hao@nokia-sbell.com
# Suite Setup    702 Suite Setup For UTE
# Suite Teardown    702 Suite TearDown For UTE
# Force Tags            5G_RAN_TDD    master_classicalbts_all
# ...    PY39
# ...           CIT    5G_RAN    SBTS00    SBTS24R1    RAN_5G    RAN_5G_TDD
# Resource    Resources/5GC000702_common_ute.robot
# 
# *** Variables ***
# 
# *** Test Cases ***
# #[1]5GC000702_M_159_Configuration_Of_2S_1CC_4DL_2UL_RU_lock_unlock_AZQH
# #    [Documentation]    1 RU lock and unlock one by one, 5GC001821-4;5GC000702-28
# #    ...                CHBW:80MHz
# #    [Timeout]    90m
# #    [Setup]  702 Case SetUp For UTE    update_param_name=${FRAME_TO_11163ms_80MHz_4Symbols}
# #    5GC000702_M_159_Configuration_Of_2S_1CC_4DL_2UL_RU_lock_unlock_AZQH
# #    [Teardown]   702 Case TearDown For UTE    case_contain_special_operation=${True}
# 
# #[1]5GC000702_M_151_Configuration_Of_2S_1CC_4DL_2UL_cell_lock_unlock_AZQH
# #    [Documentation]    onair for 20M 4X4,5GC001821-4;5GC000702-28
# #    ...                Add L3 call process for 20M,modified by xiangyue.zhou@nokia-sbell.com
# #    ...                CHBW:20MHz
# #    [Timeout]    90m
# #    [Setup]  702 Case SetUp For UTE    update_param_name=${FRAME_TO_1208_20MHz_2Symbols}
# #    5GC000702_M_151_Configuration_Of_2S_1CC_4DL_2UL_cell_lock_unlock_AZQH
# #    [Teardown]   702 Case TearDown For UTE
# 
# #[1]5GC000702_M_172_Configuration_Of_2S_1CC_CL_2DL_2UL_L3_Call_AZQL
# #    [Documentation]    L3 call for 100M 4X4,5GC000702-26;5GC000702-28
# #    ...                CHBW:100MHz
# #    ...                Feature_ID:5GC000702-M;5GC001849-A;5GC002142-B;CB005912-5G-B
# #    [Timeout]    60m
# #    [Setup]    702 Case SetUp For UTE    scf_file_name=Configuration_26    update_param_name=${FRAME_TO_1070_80MHz_2Symbols}
# #    5GC000702_M_172_Configuration_Of_2S_1CC_CL_2DL_2UL_L3_Call_AZQL
# #    [Teardown]    702 Case TearDown For UTE
# 
# #[1]5GC000702_M_161_Configuration_Of_2S_1CC_4DL_2UL_RU_lock_unlock_AZQH
# #    [Documentation]    1 RU lock and unlock one by one, 5GC000702-36;5GC000702-28
# #    ...                CHBW:80MHz
# #    [Timeout]    90m
# #    [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_36
# #    5GC000702_M_161_Configuration_Of_2S_1CC_4DL_2UL_RU_lock_unlock_AZQH
# #    [Teardown]   702 Case TearDown For UTE
# 
# #[1]5GC000702_M_108_Configuration_Of_2S_1CC_4DL_2UL_on_air_AZQH
# #    [Documentation]    L3 call for 40M 4X4,5GC000702-36;5GC000702-28
# #    ...                CHBW:40MHz
# #    [Timeout]    60m
# #    [Setup]  702 Case SetUp For UTE     scf_file_name=Configuration_36    update_param_name=${FRAME_TO_11160ms_40MHz_4Symbols}
# #    5GC000702_M_108_Configuration_Of_2S_1CC_4DL_2UL_on_air_AZQH
# #    [Teardown]   702 Case TearDown For UTE
# 
# [1]5GC000702_M_112_Configuration_Of_2S_1CC_4DL_256QAM_2UL_64QAM_100MHz_mcs15_SFP_FORT_[L3CALL]_AZQL
#     [Documentation]    L3 call for 100M 4X4,5GC001821-4;5GC000702-28
#     ...               CHBW:100MHz
#     [Timeout]    60m
#     [Setup]  702 Case SetUp For UTE
#     5GC000702_M_112_Configuration_Of_2S_1CC_4DL_256QAM_2UL_64QAM_100MHz_mcs15_SFP_FORT_L3_Call_AZQL
#     [Teardown]   702 Case TearDown For UTE