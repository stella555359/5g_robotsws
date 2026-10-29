*** Settings ***
Documentation    Auther:xiaoxia.hao@nokia-sbell.com
Suite Setup    702 Suite Setup For UTE
Suite Teardown    702 Suite TearDown For UTE    is_need_enable_uboot=${True}
Force Tags            5G_RAN_TDD    master_classicalbts_all
...    PY310
...          5G_RAN    CIT    RAN_5G    RAN_5G_TDD
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC000702/Resources/5GC000702_common_ute.robot
Resource    Resources/CB012195_case_step.robot
Variables    Resources/CB012195_variables.py

*** Test Cases ***
[1]CB012195_B_23_General_SiSo_Cell_block_and_unblock_3S_3CC_1x16DL8UL_2x8DL4UL_4Rx_8Rx_ABIP
    [Documentation]    3S_3CC_1x16DL8UL_2x8DL4UL_4Rx_8Rx_ABIP
    ...                CHBW:100+40+40MHz
    ...                Feature_ID:CB0121195
    [Timeout]    180m
    [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_1x16DL8UL_2x8DL4UL_${stream}
    CB012195_B_23_General_SiSo_Cell_block_and_unblock_3S_3CC_1x16DL8UL_2x8DL4UL_4Rx_8Rx_ABIP
    ...                                    frames_info=${frame_structure_list_100MHz_40MHz_40MHz}
    [Teardown]    702 Case TearDown For UTE
