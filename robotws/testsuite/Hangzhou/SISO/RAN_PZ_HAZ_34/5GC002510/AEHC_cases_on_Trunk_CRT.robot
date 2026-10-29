*** Settings ***
Documentation      Author: xiaoxia.hao@nokia-sbell.com
Suite Setup    702 Suite Setup For UTE
Suite Teardown    702 Suite TearDown For UTE
Force Tags            5G_RAN_TDD    master_classicalbts_all
...    PY310
...           CRT_UTE    5G_RAN    SBTS00    RAN_5G    RAN_5G_TDD
Resource    Resources/5GC002510_case_step.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC002056_CFAM/Resources/5GC002056_case_common.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009331/Resources/CB009331_common.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot

*** Variables ***
${cell_index}    ${1}
${ru_index}    ${1}
@{swconfig_enable_rdNewTddCellSlotModel}    0x420062=1    #modify swconfig,enable_rdNewTddCellSlotModel of CB008940
@{rdTddPoolingFeaturesEnable}    0x420068=1

*** Test Cases ***
#[1]5GC002540_E_10_03_AEHC_AEQE_AEQQ_peak_tput_3S_2CC_8D4U_40M60M_20M20M_40M50M_1X25G
#    [Documentation]    L3 call for 40M 8DL4UL 2CC,1116 0ms
#    ...                CHBW:40MHz
#    ...                Feature_ID:5GC002540
#    [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_8x8_3S3CC_${stream}
#    ...                                  ParameterToDelete=${PARAMS_TO_DELETE_FOR_3SECTOR_2CC_8DL_4UL}
#    ...                                  ListToAdd=${LISTS_TO_ADD_FOR_3SECTOR_2CC_8DL_4UL}
#    ...                                  ParamterToModify=${PARAMS_TO_MODIFY_FOR_3SECTOR_2CC_8DL_4UL}
#    5GC002540_E_10_03_AEHC_AEQE_AEQQ_peak_tput_3S_2CC_8D4U_40M60M_20M20M_40M50M_1X25G
#    [Teardown]   702 Case TearDown For UTE

#[1]5GC002510_A_07_SiSo_Cell_lock_and_unlock_ASIK
#    [Documentation]   Sub-feature:5GC002510-A,L3 call DL TP expect value is 10% bler
#    ...               CHBW:60MHz
#    [Timeout]    60m
#    [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_8x8_3S3CC_${stream}
#    ...                                  ParameterToDelete=${PARAMS_TO_DELETE_FOR_3SECTOR_2CC_8DL_4UL}
#    ...                                  ListToAdd=${LISTS_TO_ADD_FOR_3SECTOR_2CC_8DL_4UL}
#    ...                                  ParamterToModify=${PARAMS_TO_MODIFY_FOR_3SECTOR_2CC_8DL_4UL}
#    ...                                update_param_name=${FRAME_TO_11160ms_60MHz_100MHz_4Symbols_AEHC_2CC}
#    @{cellid_list}    create list    1    4
#    5GC002510_A_07_SiSo_Cell_lock_and_unlock_ASIK    cell_list=${cellid_list}
#    [Teardown]   702 Case TearDown For UTE

#[1]CB005739_5GC001301_05_C2_ForamtCell setup with PRACH format switchover bewteen B4 and C2
#    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
#    ...    This test case is used to test 5GC001301 case. Prach index changes from 206 to 158.
#    ...    CHBW:80MHz, Feature_ID:5GC001301;CB005739-LA
#    [Timeout]    90m
#    [Setup]    702 Case SetUp For UTE    scf_file_name=Configuration_8x8_3S3CC_${stream}
#    ...                                  ParameterToDelete=${PARAMS_TO_DELETE_FOR_3SECTOR_2CC_8DL_4UL}
#    ...                                  ListToAdd=${LISTS_TO_ADD_FOR_3SECTOR_2CC_8DL_4UL}
#    ...                                  ParamterToModify=${PARAMS_TO_MODIFY_FOR_3SECTOR_2CC_8DL_4UL}
#    @{cellid_list}    create list    1    4
#    CB005739_5GC001301_05_C2_ForamtCell setup with PRACH format switchover bewteen B4 and C2    cell_index_list=${cellid_list}
#    [Teardown]    702 Case TearDown For UTE

#[1]CB006915_D_01_L3call_test_2S_1CC_8D4U
#    [Documentation]    L3 call for 100M 8DL4UL 1CC,1116 0ms
#    ...                CHBW:100MHz
#    ...                Feature_ID:CB006915-D
#    [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_8x8_3S3CC_${stream}
#    ...                                ParameterToDelete=${PARAMS_TO_DELETE_FOR_2SECTOR_1CC_8DL_4UL}
#    ...                                ListToAdd=${LISTS_TO_ADD_FOR_2SECTOR_1CC_8DL_4UL}
#    ...                                ParamterToModify=${PARAMS_TO_MODIFY_FOR_2SECTOR_1CC_8DL_4UL}
#    CB006915_D_01_L3call_test_2S_1CC_8D4U
#    [Teardown]   702 Case TearDown For UTE

#[1]CB009403_01_06_General_SiSo_RU_lock_unlock
#    [Documentation]   Sub-feature:5GC009403-A,L3 call DL TP expect value is 10% bler
#    ...               CHBW:100MHz
#    [Timeout]    60m
#    [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_CB009403_${stream}
#    @{cellid_list}    create list    1
#    CB009403_01_06_General_SiSo_RU_lock_unlock    cell_list=${cellid_list}
#    [Teardown]   702 Case TearDown For UTE

#[1][1.0] 5GC002089-B_05_5GC002089-42_AEHC_RU_lock_and_unlock_L3_call_multiple_BBMODs
#    [Documentation]   Feature 5GC002089-42 with AEHC
#    [Timeout]    60m
#    [Setup]  702 Case SetUp For UTE    scf_file_name=SCF_2089-42_AEHC_${stream}
#    5GC002510_A_08_SiSo_RU_lock_unlock_ASIK    ru_index=${1}    cell_index=${1}    cell_group_idx=${0}
#    [Teardown]    702 Case TearDown For UTE
#
#[1][1.0] 5GC002089-B_06_5GC002089-42_AEHC_RU_module_reset_from_GUI
#    [Documentation]   Feature 5GC002089-42 with AEHC
#    [Timeout]    60m
#    [Setup]    702 Case SetUp For UTE    scf_file_name=SCF_2089-42_AEHC_${stream}
#    5GC002510_A_04_SiSo_RF_module_reset_from_GUI_under_creation    ru_index=${1}    cell_index=${1}
#    [Teardown]    702 Case TearDown For UTE

#[1]CB006915_G_01_L3call_test_3S_1CC_8D4U
#    [Documentation]    L3 call for 100M 8DL4UL 3S 1CC,1116 0ms
#    ...                CHBW:100MHz
#    ...                Feature_ID:CB006915-G
#    [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_6915_G_DLPRBpooling_${stream}
#    CB006915_G_01_L3call_test_3S_1CC_8D4U
#    [Teardown]   702 Case TearDown For UTE
#[1]CB009359-SR-A_01_NR_only_8DL_8UL_2CC_NR100_NR90
#    [Documentation]    L3 call for 8D8U 1S 2CC,1116 0ms
#    ...                CHBW:100MHz + 40Mhz
#    ...                Feature_ID:CB009359-A
#    [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_8x8_3S3CC_${stream}
#    ...                                ParameterToDelete=${PARAMS_TO_DELETE_FOR_1SECTOR_2CC_8DL_8UL}
#    ...                                ListToAdd=${LISTS_TO_ADD_FOR_1SECTOR_2CC_8DL_8UL}
#    ...                                ParamterToModify=${PARAMS_TO_MODIFY_FOR_1SECTOR_2CC_8DL_8UL}
#    CB009359-SR-A_01_NR_only_8DL_8UL_2CC_NR100_NR90    cellid=${cell_index}
#    [Teardown]   702 Case TearDown For UTE

#[1][2.0] General_SiSo_Cell_lock_and_unlock
#    [Documentation]    CHBW:100_40_20MHz
#    ...                Feature_ID:CB009163-A
#    [Timeout]    120m
#    [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_8x8_3S3CC_${stream}
#    General_SiSo_Cell_lock_and_unlock_with_traffic_on_cell1_NR100_40_20
#    ...                                                                                frames_info=${frame_structure_list_100MHz_40MHz_20MHz}
#    ...                                                                                scf_file_name=Configuration_8x8_3S3CC_${stream}.xml
#    [Teardown]   702 Case TearDown For UTE

[1]CB009331-SR-A_07_NR_only_16DL_8UL_3Sector_2CC_NR50_NR50
    [Tags]    CRT_TRUNK    CIT_23R4    3S-2CC-50-50
    [Timeout]    90m
    [Setup]  9331 Coam Test Setup
    CB009331-SR-A_07_NR_only_16DL_8UL_3Sector_2CC_NR50_NR50
    [Teardown]   702 Case TearDown For UTE

#[1]CB009331-SR-A_05_NR_only_16DL_8UL_3Sector_2CC_NR100_NR50
#    [Tags]    CRT_TRUNK    CRT_23R4    3S-2CC-100-50
#    [Timeout]    90m
#    [Setup]  9331 Coam Test Setup
#    CB009331-SR-A_05_NR_only_16DL_8UL_3Sector_2CC_NR100_NR50
#    [Teardown]   702 Case TearDown For UTE

#[1][1.0] General_SiSo_RU_lock_unlock
#    [Tags]    CRT_TRUNK    CIT_23R4    3S-2CC-100-90
#    [Timeout]    180m
#    [Setup]  9331 Coam Test Setup
#    CB009331-General_SiSo_RU_lock_unlock
#    [Teardown]   702 Case TearDown For UTE    case_contain_special_operation=${True}

#[1][2.0] General_SiSo_RU_module_reset_from_GUI
#    [Tags]    CRT_TRUNK    CRT_23R4    1S-2CC-60-60
#    [Timeout]    120m
#    [Setup]  9331 Coam Test Setup
#    CB009331-General_SiSo_RU_module_reset_from_GUI
#    [Teardown]   702 Case TearDown For UTE

#[1]CB008941-SR-AC_2_L3call_Loki_based_DU_with_UL_PRB_muting_active_FDBF
#    [Tags]    CRT_TRUNK    CRT_23R4    3S-2CC-100-50
#    [Timeout]    180m
#    [Setup]  9331 Coam Test Setup
#    CB008941-SR-AC_2_L3call_Loki_based_DU_with_UL_PRB_muting_active_FDBF
#    [Teardown]   702 Case TearDown For UTE

#[1][1.0] Manual_SiSo_SM_BTS_Site_Reset
#    [Tags]    CRT_TRUNK    CRT_23R4    3S-2CC-100-80
#    [Timeout]    180m
#    [Setup]  9331 Coam Test Setup
#    CB009331-Manual_SiSo_SM_BTS_Site_Reset
#    [Teardown]   702 Case TearDown For UTE

#[1]CB009331-SR-A_06_NR_only_16DL_8UL_3Sector_2CC_NR80_NR80
#    [Tags]    CRT_TRUNK    CRT_23R4    3S-2CC-80-80
#    [Setup]  9331 Coam Test Setup
#    CB009331-SR-A_06_NR_only_16DL_8UL_3Sector_2CC_NR80_NR80
#    [Teardown]   702 Case TearDown For UTE

