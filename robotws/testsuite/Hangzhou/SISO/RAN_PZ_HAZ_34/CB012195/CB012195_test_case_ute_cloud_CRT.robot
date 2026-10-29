*** Settings ***
Documentation    Auther:xiaoxia.hao@nokia-sbell.com
Suite Setup    702 Suite Setup For UTE
Suite Teardown    702 Suite TearDown For UTE    scf_file_name=SCF_${stream}    is_need_enable_uboot=${True}
Force Tags            5G_RAN_TDD    master_classicalbts_all
...    PY310
...          5G_RAN    CIT    RAN_5G    RAN_5G_TDD
Variables    Resources/CB012195_variables.py
Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010744_C/TestData/variables.py
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC000702/Resources/5GC000702_common_ute.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC000702/Resources/5GC000702_common_ute.robot
Resource    Resources/CB012195_case_step.robot

*** Test Cases ***
[1]CB012195_B_14_General_SiSo_E2E_system_setup_with_data_transfer_3S_3CC_3x8DL8UL_8Rx_ABIP
    [Documentation]    3S_3CC_3x8DL8UL_8Rx_ABIP
    ...                CHBW:100+40+40MHz
    ...                Feature_ID:CB0121195
    [Timeout]    180m
    [Setup]  702 Case SetUp For UTE
    CB012195_B_14_General_SiSo_E2E_system_setup_with_data_transfer_3S_3CC_3x8DL8UL_8Rx_ABIP
    ...                                    frames_info=${frame_structure_list_100MHz_40MHz_40MHz}
    [Teardown]    702 Case TearDown For UTE

#[1]CB010744_C_04_General_SiSo_E2E_system_setup_with_data_transfer_for_conducted_multicarrier_1x16DL8UL_2x8DL4UL
#    [Documentation]    CHBW:100_30_20MHz
#    [Timeout]    180m
#    [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_16D8U_${stream}
#    CB010744_C_04_General_SiSo_E2E_system_setup_with_data_transfer_for_conducted_multicarrier_1x16DL8UL_2x8DL4UL
#    ...                                                                                frames_info=${frame_structure_list_100MHz_40MHz_40MHz}
#    ...                                                                                scf_file_name=Configuration_16D8U_${stream}
#    [Teardown]   702 Case TearDown For UTE

[1]CB012725_CA_3CC_16D8U_30km_100+50+40_data_transfer
    [Documentation]    CHBW:100_20MHz+mutiple_RAT
    [Timeout]    180m
    [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_3S2CC_multiple_RAT_${stream}
    CB012725_CA_3CC_16D8U_30km_100+50+40_data_transfer    frames_info=${frame_structure_list_100MHz_20MHz}
    [Teardown]   702 Case TearDown For UTE
