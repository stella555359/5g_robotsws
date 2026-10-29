# *** Settings ***
# Force Tags            5G_RAN_TDD    STATE_SW_UPLOADED    master_classicalbts_all
# ...    PY39
# ...           CLOUD_5G_CLASSICAL_ANDROID_ASILL_ABIOB1_2xAWHQE_ENB    5G_RAN    SBTS23R1    SBTS23R2    CRT_UTE    RAN_5G    RAN_5G_TDD
# Documentation    Auther:xiaoxia.hao@nokia-sbell.com
# Suite Setup    702 Suite Setup For UTE
# Suite Teardown    702 Suite TearDown For UTE
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_power_reset.robot
# Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/FGCR_3610/Resources/FGCR_3610_case_common.robot
# Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/FGCR_3610/TestData/variables.py
# *** Variables ***
# 
# *** Test Cases ***
# [1]5GC001274_008_1UE_1Sector_4DL_256QAM_MCS27_using_2SFP_100MHz
#     [Documentation]    CHBW:100MHz
#     [Tags]    Classical    CRT_22R3    CDRT_22R3    CDRT_22R4    CRT_23R1    CRT_23R2
#     [Timeout]    45m
#     [Setup]  702 Case SetUp For UTE
#     5GC001274_008_1UE_1Sector_4DL_256QAM_MCS27_using_2SFP_100MHz
#     [Teardown]   702 Case TearDown For UTE
# 
# [1]FGCR8131_A_1UE_1Sector_4DL_256QAM_MCS27_using_2SFP+_90MHz_AWHQE
#     [Documentation]    CHBW:90MHz
#     ...                Feature_ID:FGCR-3610-B
#     [Tags]    Classical    CRT_22R3    CDRT_22R3    CDRT_22R4    CRT_23R1    CRT_23R2
#     [Timeout]    45m
#     [Setup]  702 Case SetUp For UTE
#     FGCR8131_A_1UE_1Sector_4DL_256QAM_MCS27_using_2SFP+_90MHz_AWHQE
#     [Teardown]   702 Case TearDown For UTE
# 
# #[1]FGCR4454_1UE_1Sector_2UL_64QAM_MCS27_using_2SFP_40MHz_AWHQE
# #    [Documentation]    CHBW:40MHz
# #    [Tags]    Classical    CRT_22R3    CDRT_22R3    CDRT_22R4
# #    [Timeout]    45m
# #    [Setup]  702 Case SetUp For UTE
# #    FGCR4454_1UE_1Sector_2UL_64QAM_MCS27_using_2SFP_40MHz_AWHQE
# #    [Teardown]   702 Case TearDown For UTE
# 
# #[1]FGCR8131_A_1UE_1Sector_4DL_256QAM_MCS27_using_2SFP+_50MHz_AWHQE
# #    [Documentation]    CHBW:50MHz
# #    ...    Feature_ID:FGCR-3610-C
# #    [Tags]    Classical    CIT_21B    CDRT_22R2    CIT_22R4
# #    [Timeout]    45m
# #    [Setup]  702 Case SetUp For UTE
# #    FGCR8131_A_1UE_1Sector_4DL_256QAM_MCS27_using_2SFP+_50MHz_AWHQE
# #    [Teardown]   702 Case TearDown For UTE
# 
# [1]5GC001157_09_1UE_1Sector_2UL_64QAM_MCS27_using_2SFP_20MHz
#     [Documentation]    CHBW:20MHz
#     ...    Feature_ID:FGCR-3610;FGCR-3626
#     [Tags]    Classical    CRT_22R3    CDRT_22R3    CDRT_22R4    CRT_23R1    CRT_23R2
#     [Timeout]    90m
#     [Setup]  702 Case SetUp For UTE
#     5GC001157_09_1UE_1Sector_2UL_64QAM_MCS27_using_2SFP_20MHz
#     [Teardown]   702 Case TearDown For UTE    case_contain_special_operation=${True}
# 
# [1][1.0] General_SiSo_RU_lock_unlock
#     [Tags]    Classical    CRT_22R3    CDRT_22R3    CRT_22R4    CRT_23R1
#     [Timeout]    90m
#     [Setup]  702 Case SetUp For UTE
#     RRH_common_keyword.General SiSo RU Lock Unlock
#     [Teardown]  702 Case TearDown For UTE    case_contain_special_operation=${True}
# 
# [1][1.0] General_SiSo_RF_module_power_reset
#     [Tags]    Classical    CDRT_22R3    CDRT_22R4    CRT_22R4
#     [Timeout]    90m
#     [Setup]  702 Case SetUp For UTE
#     General_SiSo_RF_module_power_reset.General_SiSo_RF_module_power_reset
#     [Teardown]    702 Case TearDown For UTE    case_contain_special_operation=${True}
# 
# [1][1.0] General_SiSo_Cell_lock_and_unlock
#     [Tags]    Classical    CRT_22R3    CDRT_22R3    CDRT_22R4    CRT_23R1    CRT_23R2
#     [Documentation]    Feature_ID:5GC001274-A;FGCR-3610;FGCR-4454
#     [Setup]  702 Case SetUp For UTE
#     General_SiSo_Cell_lock_and_unlock    with_call=${False}
#     [Teardown]   702 Case TearDown For UTE    case_contain_special_operation=${True}
# 
# #[2][1.0] General_SiSo_RF_module_power_reset
# #    [Tags]    Classical    CRT_23R2
# #    [Timeout]    90m
# #    [Setup]  702 Case SetUp For UTE
# #    General_SiSo_RF_module_power_reset.General_SiSo_RF_module_power_reset
# #    [Teardown]    702 Case TearDown For UTE    case_contain_special_operation=${True}
# 
