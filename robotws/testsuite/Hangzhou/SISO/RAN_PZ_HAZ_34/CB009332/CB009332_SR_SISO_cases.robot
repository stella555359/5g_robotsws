*** Settings ***
Force Tags    PY36
Documentation    Auther:xiaoxia.hao@nokia-sbell.com
Suite Setup    702 Suite Setup For UTE
Suite Teardown    702 Suite TearDown For UTE    scf_file_name=Configuration_IWK_${stream}
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC000702/Resources/5GC000702_common_ute.robot
Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009332/TestData/variables.py
*** Variables ***

*** Test Cases ***
[1]CB009332_SR_A_007_NR_1S_3CC_Bandwidths_Combinations_max_DL_and_UL_throughput_with_NR100_NR30_NR20_Continuous
    [Documentation]    CHBW:100_30_20MHz
    [Tags]    Classical    CRT_TRUNK    CDRT_22R4    CRT_23R1    CRT_23R2    CRT_23R3    CRT_23R4
    [Timeout]    120m
    [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_1sector_3cc_8D4U_${stream}
    CB009332_SR_A_007_NR_1S_3CC_Bandwidths_Combinations_max_DL_and_UL_throughput_with_NR100_NR30_NR20_Continuous
    ...                                                                                frames_info=${frame_structure_list_100MHz_30MHz_20MHz}
    [Teardown]   702 Case TearDown For UTE

[1]CB009332_SR_A_021_NR_1S_3CC_Bandwidths_Combinations_SiSo_cell_lock_and_unlock_with_traffic_on_cell1_NR100_30_20
    [Documentation]    CHBW:100_30_20MHz
    [Tags]    Classical    CRT_TRUNK    CRT_22R4    CRT_23R1    CRT_23R2
    [Timeout]    120m
    [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_1sector_3cc_8D4U_${stream}
    CB009332_SR_A_021_NR_1S_3CC_Bandwidths_Combinations_SiSo_cell_lock_and_unlock_with_traffic_on_cell1_NR100_30_20
    ...                                                                                frames_info=${frame_structure_list_100MHz_30MHz_20MHz}
    ...                                                                                scf_file_name=Configuration_1sector_3cc_8D4U_${stream}
    [Teardown]   702 Case TearDown For UTE

[1]CB009332_SR_A_005_NR_1S_3CC_Bandwidths_Combinations_SiSo_cell_lock_and_unlock_with_NR40_NR30_NR20
    [Documentation]    CHBW:40_30_20MHz
    [Tags]    Classical    CRT_TRUNK    CRT_22R4    CDRT_23R1    CIT_23R2    CRT_23R1
    [Timeout]    120m
    [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_1sector_3cc_8D4U_${stream}
    ...                                update_param_name=${FRAME_TO_11160ms_40MHz_4Symbols_For_Cell3}
    CB009332_SR_A_005_NR_1S_3CC_Bandwidths_Combinations_SiSo_cell_lock_and_unlock_with_NR40_NR30_NR20
    ...                                                                                frames_info=${frame_structure_list_40MHz_30MHz_20MHz}
    [Teardown]   702 Case TearDown For UTE

