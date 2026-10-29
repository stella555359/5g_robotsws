*** Settings ***
Documentation    Auther:xiaoxia.hao@nokia-sbell.com
Suite Setup    702 Suite Setup For UTE
Suite Teardown    702 Suite TearDown For UTE
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC000702/Resources/5GC000702_common_ute.robot
Resource    Resources/CB012195_case_step.robot
Variables    Resources/CB012195_variables.py

*** Test Cases ***
[1]CB012195_B_14_General_SiSo_E2E_system_setup_with_data_transfer_3S_3CC_3x8DL8UL_8Rx_ABIP
    [Documentation]    3S_3CC_3x8DL8UL_8Rx_ABIP
    ...                CHBW:100+40+40MHz
    ...                Feature_ID:CB0121195
    [Timeout]    120m
    [Tags]    Classical    CRT_TRUNK    CRT_24R3    CRT_25R1    CRT_25R2
    [Setup]  702 Case SetUp For UTE
    CB012195_B_14_General_SiSo_E2E_system_setup_with_data_transfer_3S_3CC_3x8DL8UL_8Rx_ABIP
    ...                                    frames_info=${frame_structure_list_100MHz_40MHz_40MHz}
    [Teardown]    702 Case TearDown For UTE

[1]CB012195_B_23_General_SiSo_Cell_block_and_unblock_3S_3CC_1x16DL8UL_2x8DL4UL_4Rx_8Rx_ABIP
    [Documentation]    3S_3CC_1x16DL8UL_2x8DL4UL_4Rx_8Rx_ABIP
    ...                CHBW:100+40+40MHz
    ...                Feature_ID:CB0121195
    [Timeout]    180m
    [Tags]    Classical    CIT_TRUNK    CIT_24R3    CIT_25R1    CIT_25R2
    [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_1x16DL8UL_2x8DL4UL_${stream}
    CB012195_B_23_General_SiSo_Cell_block_and_unblock_3S_3CC_1x16DL8UL_2x8DL4UL_4Rx_8Rx_ABIP
    ...                                    frames_info=${frame_structure_list_100MHz_40MHz_40MHz}
    [Teardown]    702 Case TearDown For UTE

[1]CB012725_CA_3CC_16D8U_30km_100+50+40_data_transfer
    [Documentation]    CHBW:100_20MHz+mutiple_RAT
    [Timeout]    180m
    [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_3S2CC_multiple_RAT_${stream}
    CB012725_CA_3CC_16D8U_30km_100+50+40_data_transfer    frames_info=${frame_structure_list_100MHz_20MHz}
    [Teardown]   702 Case TearDown For UTE
