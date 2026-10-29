*** Settings ***
Documentation      Author: xiaoxia.hao@nokia-sbell.com
Suite Setup    702 Suite Setup For UTE
Suite Teardown    702 Suite TearDown For UTE
Force Tags            5G_RAN_TDD    master_classicalbts_all
...    PY310
...           CRT_UTE    5G_RAN    SBTS23R4    RAN_5G    RAN_5G_TDD
Resource    Resources/5GC002510_case_step.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC002056_CFAM/Resources/5GC002056_case_common.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009331/Resources/CB009331_common.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot

*** Variables ***
${cell_index}    ${1}
${ru_index}    ${1}
${cell_group_idx}    ${1}
${enb_cell_id}    ${121}
@{swconfig_enable_rdNewTddCellSlotModel}    0x420062=1    #modify swconfig,enable_rdNewTddCellSlotModel of CB008940
@{rdTddPoolingFeaturesEnable}    0x420068=1

*** Test Cases ***
[1]5GC002548_B_002_5GC000399_eCPRI_U-plane_Fast_C-plane_counters_ASIK
    [Documentation]    Sub-feature:5GC002548-BG,set miNrEcpriUpFCp=5 to trigger M55318 measurement enable
    [Timeout]    60m
    [Setup]    702 Case SetUp For UTE     scf_file_name=Configuration_8x8_3S2CC_${stream}
    5GC002548_B_002_5GC000399_eCPRI_U-plane_Fast_C-plane_counters_ASIK
    [Teardown]    702 Case TearDown For UTE

#[1][2.0] General_SiSo_Cell_lock_and_unlock
#    [Documentation]    CHBW:100_40_20MHz
#    ...                Feature_ID:CB009163-A
#    [Timeout]    120m
#    [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_8x8_3S3CC_${stream}
#    General_SiSo_Cell_lock_and_unlock_with_traffic_on_cell1_NR100_40_20
#    ...                                                                                frames_info=${frame_structure_list_100MHz_40MHz_20MHz}
#    ...                                                                                scf_file_name=Configuration_8x8_3S3CC_${stream}.xml
#    [Teardown]   702 Case TearDown For UTE
#
[1]CB009331-SR-A_07_NR_only_16DL_8UL_3Sector_2CC_NR50_NR50
    [Tags]    CRT_23R3    3S-2CC-50-50
    [Timeout]    90m
    [Setup]  9331 Coam Test Setup
    CB009331-SR-A_07_NR_only_16DL_8UL_3Sector_2CC_NR50_NR50
    [Teardown]    702 Case TearDown For UTE

#[1][1.0] General_SiSo_RU_lock_unlock
#    [Tags]    CRT_23R3    3S-2CC-100-90
#    [Timeout]    180m
#    [Setup]  9331 Coam Test Setup
#    CB009331-General_SiSo_RU_lock_unlock
#    [Teardown]    702 Case TearDown For UTE    case_contain_special_operation=${True}
#
[1][2.0] General_SiSo_RU_module_reset_from_GUI
    [Tags]    CRT_23R3    1S-2CC-60-60
    [Timeout]    90m
    [Setup]  9331 Coam Test Setup
    CB009331-General_SiSo_RU_module_reset_from_GUI
    [Teardown]   702 Case TearDown For UTE

[1][1.0] Manual_SiSo_SM_BTS_Site_Reset
    [Tags]    CRT_23R3    3S-2CC-100-80
    [Setup]  9331 Coam Test Setup
    CB009331-Manual_SiSo_SM_BTS_Site_Reset
    [Teardown]   702 Case TearDown For UTE

[1]CB008941-SR-AC_2_L3call_Loki_based_DU_with_UL_PRB_muting_active_FDBF
    [Tags]    CRT_TRUNK    CRT_23R4    3S-2CC-100-50
    [Timeout]    180m
    [Setup]  9331 Coam Test Setup
    CB008941-SR-AC_2_L3call_Loki_based_DU_with_UL_PRB_muting_active_FDBF
    [Teardown]   702 Case TearDown For UTE
