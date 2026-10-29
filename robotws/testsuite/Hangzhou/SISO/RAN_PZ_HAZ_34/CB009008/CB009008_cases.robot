*** Settings ***
Documentation      Author: jun.8.chen@nokia-sbell.com
Suite Setup    9008 Suite Test Setup
Suite Teardown    9008 Suite Teardown
Test Teardown    9008 Coam Test Teardown
Force Tags    5G_RAN    SG_06    PY36

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    Resources/CB009008_common_keywords.robot
Variables    Resources/TestVariables.py


*** Variables ***
${if_commissioning}    False


*** Test Cases ***
#[1]CB009008-SR-A_04_General_SiSo_Cell_block_and_unblock
#    [Tags]    CRT_TRUNK    3S-1CC
#    [Timeout]    180m
#    [Setup]    9008 Coam Test Setup
#    CB009008-SR-A_04_General_SiSo_Cell_block_and_unblock
#
#[1]CB009008-SR-B_02_General_SiSo_E2E_system_setup_with_data_transfer_conducted_25Gelink
#    [Tags]    CRT_TRUNK    3S-1CC
#    [Timeout]    180m
#    [Setup]    9008 Coam Test Setup    update_params=${SCF_16DL4UL_16DL4UL_16DL4UL}
#    CB009008-SR-B_02_General_SiSo_E2E_system_setup_with_data_transfer_conducted_25Gelink
#
#[1]CB009008-SR-C_03_Manual_SiSo_SM_BTS_Block_Site
#    [Tags]    CRT_TRUNK    3S-1CC
#    [Timeout]    180m
#    [Setup]    9008 Coam Test Setup    update_params=${SCF_8DL8UL_16DL4UL_8DL4UL}
#    CB009008-SR-C_03_Manual_SiSo_SM_BTS_Block_Site
#
#[1]CB009487_B_07_General_SiSo_SM_BTS_Site_Reset_Configuration_#5
#    [Tags]    CRT_TRUNK    3S-1CC
#    [Timeout]    180m
#    [Setup]    9008 Coam Test Setup    update_params=${SCF_16DL8UL_16DL4UL_8DL8UL}
#    CB009487_B_07_General_SiSo_SM_BTS_Site_Reset_Configuration_#5
#
#[1]CB009487_A_04_General_SiSo_Cell_block_and_unblock_Configuration_#2
#    [Tags]    CRT_TRUNK    3S-2CC
#    [Timeout]    240m
#    [Setup]    9008 Coam Test Setup
#    CB009487_A_04_General_SiSo_Cell_block_and_unblock_Configuration_#2
#
[1]CB009487_A_08_General_SiSo_SM_RF_Module_lock_unlock_Configuration_#2
    [Tags]    CRT_TRUNK    3S-2CC
    [Timeout]    240m
    [Setup]    9008 Coam Test Setup
    CB009487_A_08_General_SiSo_SM_RF_Module_lock_unlock_Configuration_#2
