# *** Settings ***
# Force Tags            5G_RAN_TDD    STATE_SW_UPLOADED    master_classicalbts_all    CLOUD_5G_CLASSICAL_QC_ASIBL_ABIOB1B2_3xAHFIB_2xAEHC_ENB
# ...    PY39
# ...           CRT    5G_RAN    SBTS00    RAN_5G    RAN_5G_TDD
# Documentation    Auther:xiaoxia.hao@nokia-sbell.com
# Suite Setup    Suite Setup For RFS On UTE Cloud
# Suite Teardown    702 Suite TearDown For UTE
# Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC000702/Resources/5GC000702_common_ute.robot
# Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009332/TestData/variables.py
# Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB008145_A/TestData/variables.py
# Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CNI_85831/TestData/variables.py
# *** Variables ***
# 
# *** Test Cases ***
# #[1]CB009332_SR_A_007_NR_1S_3CC_Bandwidths_Combinations_max_DL_and_UL_throughput_with_NR100_NR30_NR20_Continuous
# #    [Documentation]    CHBW:100_30_20MHz
# #    [Timeout]    120m
# #    [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_1sector_3cc_8D4U_${stream}
# #    CB009332_SR_A_007_NR_1S_3CC_Bandwidths_Combinations_max_DL_and_UL_throughput_with_NR100_NR30_NR20_Continuous
# #    ...                                                                                frames_info=${frame_structure_list_100MHz_30MHz_20MHz}
# #    [Teardown]   702 Case TearDown For UTE
# 
# #[1]CB009332_SR_A_021_NR_1S_3CC_Bandwidths_Combinations_SiSo_cell_lock_and_unlock_with_traffic_on_cell1_NR100_30_20
# #    [Documentation]    CHBW:100_30_20MHz
# #    [Timeout]    120m
# #    [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_1sector_3cc_8D4U_${stream}
# #    CB009332_SR_A_021_NR_1S_3CC_Bandwidths_Combinations_SiSo_cell_lock_and_unlock_with_traffic_on_cell1_NR100_30_20
# #    ...                                                                                frames_info=${frame_structure_list_100MHz_30MHz_20MHz}
# #    ...                                                                                scf_file_name=Configuration_1sector_3cc_8D4U_${stream}
# #    [Teardown]   702 Case TearDown For UTE
# #
# #[1]CB009332_SR_A_005_NR_1S_3CC_Bandwidths_Combinations_SiSo_cell_lock_and_unlock_with_NR40_NR30_NR20
# #    [Documentation]    CHBW:40_30_20MHz
# #    [Timeout]    120m
# #    [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_1sector_3cc_8D4U_${stream}
# #    ...                                update_param_name=${FRAME_TO_11160ms_40MHz_4Symbols_For_Cell3}
# #    CB009332_SR_A_005_NR_1S_3CC_Bandwidths_Combinations_SiSo_cell_lock_and_unlock_with_NR40_NR30_NR20
# #    ...                                                                                frames_info=${frame_structure_list_40MHz_30MHz_20MHz}
# #    [Teardown]   702 Case TearDown For UTE
# #
# #[1]5GC008145_A_35_SA_TDD_BF_Activated_2UE_1Sector_2CC_8DL_8UL_ECPRI_70Mhz_30Mhz_Cell_lock_and_unlock
# #    [Documentation]    CHBW:70_30MHz
# #    [Tags]    Classical    CRT_22R3    CRT_22R4    CRT_TRUNK    CRT_23R1    CRT_23R2     CRT_23R3
# #    [Timeout]    120m
# #    [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_1Sector_2CC_8DL_8UL_Continuous_70_30_${stream}
# #    5GC008145_A_SA_TDD_BF_Activated_2UE_8DL_8UL_ECPRI    frames_info=${frame_structure_list_70MHz_30MHz}    cellid=5
# #    [Teardown]   702 Case TearDown For UTE
# 
# #[1]CB008145_A_61_SA_TDD_BF_Activated_2UE_1Sector_2CC_8DL_4UL_ECPRI_100Mhz_90Mhz
# #    [Documentation]    CHBW:100_90MHz
# #    [Tags]    Classical    CRT_TRUNK    CRT_22R4    CRT_23R1    CRT_23R2    CRT_23R3
# #    [Timeout]    120m
# #    [Setup]  702 Case SetUp For UTE
# #    CB008145_A_61_SA_TDD_BF_Activated_2UE_1Sector_2CC_8DL_4UL_ECPRI_100Mhz_90Mhz
# #    ...                                                                           scf_file_name=Configuration_1Sector_2
# ...CC_8DL_8UL_90_50_${stream}.xml
# #    ...                                                                           frames_info=${frame_structure_list_100MHz_90MHz}    cellid=5
# #    [Teardown]   702 Case TearDown For UTE
# 
# #[1]CNI_85831_010_Full_NR_2cc_on_AEHC_max_DL_and_UL_throughput_with_NR60_NR60
# #    [Documentation]    CHBW:60_60MHz
# #    [Tags]    Classical    CRT_TRUNK    CRT_23R1    CRT_23R2    CRT_23R3
# #    [Timeout]    120m
# #    [Setup]  702 Case SetUp For UTE
# #    CNI_85831_010_Full_NR_2cc_on_AEHC_max_DL_and_UL_throughput_with_NR60_NR60
# #    ...                                                                           scf_file_name=Configuration_1Sector_2
# ...CC_8DL_8UL_90_50_${stream}.xml
# #    ...                                                                           frames_info=${frame_structure_list_60MHz_60MHz}
# #    [Teardown]   702 Case TearDown For UTE    case_contain_special_operation=${True}
# #
# #[1]CNI_85831_008_Full_NR_2cc_on_AEHC_max_DL_and_UL_throughput_with_NR80_NR70
# #    [Documentation]    CHBW:80_70MHz
# #    [Tags]    Classical    CRT_TRUNK    CRT_23R3
# #    [Timeout]    120m
# #    [Setup]  702 Case SetUp For UTE
# #    CNI_85831_008_Full_NR_2cc_on_AEHC_max_DL_and_UL_throughput_with_NR80_NR70
# #    ...                                                                           scf_file_name=Configuration_1Sector_2
# ...CC_8DL_8UL_90_50_${stream}.xml
# #    ...                                                                           frames_info=${frame_structure_list_80MHz_70MHz}
# #    [Teardown]   702 Case TearDown For UTE    case_contain_special_operation=${True}
