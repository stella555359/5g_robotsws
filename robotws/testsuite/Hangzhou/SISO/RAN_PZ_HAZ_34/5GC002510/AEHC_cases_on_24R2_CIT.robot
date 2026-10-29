*** Settings ***
Documentation      Author: xiangyue.zhou@nokia-sbell.com
Suite Setup    702 Suite Setup For UTE    is_x2_check_from_gnb_needed=${False}
Suite Teardown    702 Suite TearDown For UTE    scf_file_name=SCF_${stream}
Force Tags            5G_RAN_TDD    master_classicalbts_all
...    PY310
...         5G_RAN    SBTS24R2    CIT    RAN_5G    RAN_5G_TDD
Resource    Resources/5GC002510_case_step.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC002056_CFAM/Resources/5GC002056_case_common.robot

*** Variables ***
${cell_index}    ${1}
${ru_index}    ${1}
${enb_cell_id}    ${121}
${cell_group_idx}    ${1}

*** Test Cases ***
[1]5GC002510_A_08_SiSo_RU_lock_unlock_ASIK
    [Timeout]    120m
    [Setup]  702 Case SetUp For UTE
    5GC002510_A_08_SiSo_RU_lock_unlock_ASIK    ru_index=${ru_index}    cell_index=${cell_index}    cell_group_idx=${cell_group_idx}
    [Teardown]    702 Case TearDown For UTE

#[1]5GC002510_A_12_SiSo_E2E_system_setup_with_data_transfer_conducted_60M_30KM
#    [Documentation]   Sub-feature:5GC002510-A,L3 call DL TP expect value is 5% bler
#    ...               CHBW:60MHz
#    [Timeout]    60m
#    [Setup]    702 Case SetUp For UTE    scf_file_name=Configuration_8x8_3S3CC_${stream}
#    ...                                  ParameterToDelete=${PARAMS_TO_DELETE_FOR_3SECTOR_2CC_8DL_4UL_2_CAB}
#    ...                                  ListToAdd=${LISTS_TO_ADD_FOR_3SECTOR_2CC_8DL_4UL}
#    ...                                  ParamterToModify=${PARAMS_TO_MODIFY_FOR_3SECTOR_2CC_8DL_4UL}
#    ...                                  update_param_name=${FRAME_TO_11160ms_60MHz_100MHz_4Symbols_AEHC_2CC}
#    5GC002510_A_12_SiSo_E2E_system_setup_with_data_transfer_conducted_60M_30KM
#    [Teardown]    702 Case TearDown For UTE

[1]CB006915_I_03_L3call_3S_1CC_8D4U_1fiber
    [Documentation]    L3 call for 100M 8DL4UL 1CC,1116 0ms
    ...                CHBW:100MHz
    ...                Feature_ID:CB006915-I
    [Timeout]    60m
    [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_8x4_3S1CC_${stream}
    CB006915_I_03_L3call_3S_1CC_8D4U_1fiber
    [Teardown]   702 Case TearDown For UTE

#[1]CB009403_01_07_General_SiSo_E2E_system_setup_with_data_transfer_conducted
#    [Documentation]   Sub-feature:5GC009403-A,L3 call DL TP expect value is 10% bler
#    ...               CHBW:60MHz
#    [Timeout]    60m
#    [Setup]  702 Case SetUp For UTE
#    CB009403_01_07_General_SiSo_E2E_system_setup_with_data_transfer_conducted
#    [Teardown]   702 Case TearDown For UTE

[1]CB009163-A-A6_General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing
    [Documentation]    CHBW:100_40_20MHz
    ...                Feature_ID:CB009163-A
    [Timeout]    150m
    [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_8x8_3S3CC_${stream}
    CB009163-A-A6_General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing
    ...                                                                                frames_info=${frame_structure_list_100MHz_40MHz_20MHz}
    [Teardown]   702 Case TearDown For UTE

#[3][1.1] General_SiSo_E2E_system_setup_with_data_transfer_conducted
#    [Documentation]    CHBW:100MHz
#    ...                Feature_ID:CB009163-B
#    [Timeout]    150m
#    [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_8x8_3S1CC_multiple_RAT_${stream}
#    General_SiSo_E2E_system_setup_with_data_transfer_conducted
#    ...                                                                                frames_info=${frame_structure_list_100MHz_40MHz_20MHz}
#    ...                                                                                enb_cell_id=${enb_cell_id}
#    [Teardown]   702 Case TearDown For UTE
