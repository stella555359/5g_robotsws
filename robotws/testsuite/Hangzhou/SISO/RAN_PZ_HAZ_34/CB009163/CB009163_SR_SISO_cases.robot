# *** Settings ***
# Force Tags            5G_RAN_TDD    STATE_SW_UPLOADED    master_classicalbts_all
# ...    PY36
# ...           CLOUD_5G_CLASSICAL_ANDROID_SA_ASILL_ABIOB1B2_3xAEHC_CMA    5G_RAN    SBTS00    CRT_UTE    RAN_5G    RAN_5G_TDD
# Documentation    Auther:xiaoxia.hao@nokia-sbell.com
# Suite Setup    702 Suite Setup For UTE
# Suite Teardown    702 Suite TearDown For UTE
# Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC000702/Resources/5GC000702_common_ute.robot
# Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009163/TestData/variables.py
# *** Variables ***
# ${enb_cell_id}    ${121}
# 
# *** Test Cases ***
# #[1]CB009163-A-A6_General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing
# #    [Documentation]    CHBW:100_40_20MHz
# #    [Tags]    Classical    CRT_TRUNK    CDRT_22R4    CRT_23R1    CRT_23R2
# #    [Timeout]    120m
# #    [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_8x8_3S3CC_${stream}
# #    CB009163-A-A6_General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing
# #    ...                                                                                frames_info=${frame_structure_list_100MHz_40MHz_20MHz}
# #    [Teardown]   702 Case TearDown For UTE
# 
# #[1][2.0] General_SiSo_Cell_lock_and_unlock
# #    [Documentation]    CHBW:100_40_20MHz
# #    [Tags]    Classical    CRT_TRUNK    CRT_22R4    CRT_23R1    CRT_23R2
# #    [Timeout]    120m
# #    [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_8x8_3S3CC_${stream}
# #    General_SiSo_Cell_lock_and_unlock_with_traffic_on_cell1_NR100_40_20
# #    ...                                                                                frames_info=${frame_structure_list_100MHz_40MHz_20MHz}
# #    ...                                                                                scf_file_name=Configuration_8x8_3S3CC_${stream}.xml
# #    [Teardown]   702 Case TearDown For UTE
# 
# #[1][1.1] General_SiSo_E2E_system_setup_with_data_transfer_conducted
# #    [Documentation]    CHBW:100MHz
# #    [Tags]    Classical    CRT_TRUNK    CRT_22R4    CRT_23R1    CRT_23R2
# #    [Timeout]    120m
# #    [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_8x8_3S1CC_multiple_RAT_${stream}
# #    General_SiSo_E2E_system_setup_with_data_transfer_conducted
# #    ...                                                                                frames_info=${frame_structure_list_100MHz_40MHz_20MHz}
# #    ...                                                                                enb_cell_id=${enb_cell_id}
# #    [Teardown]   702 Case TearDown For UTE