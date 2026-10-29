*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         12h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Auto_BTS_site_reset.robot
#Resource    ${BASIC_PATH_5G}/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
#Resource    ${BASIC_PATH_5G}/E2E_SiSo_Cell_block_and_unblock_gNB.robot
#Resource    ${BASIC_PATH_5G}/General_SiSo_RU_lock_unlock.robot
#Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
#Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_power_reset.robot
#Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_triggered_by_user_as_part_of_BTS_reset.robot

Documentation
...    Author:zhihao shi
...    contact:zhihao.shi@nokia-sbell.com
...    squad group:SG_04
...    Feature CB009403 in 23R1 program

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AEQY
...   PY36

*** Variables ***

*** Test Cases ***
#TL583
[1]CB009403-C-Made1-32TRX_04_General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing
    [Tags]    3S-1CC-16D-8U    CRT_TRUNK
    ${cell_list}  create list  ${1}
    Get UE From Init File and Make call  cell_list=${cell_list}  with_peak=${True}  duration=${300}

[1]CB009403-C-Made1-32TRX_03_Manual_SiSo_SM_BTS_Site_Reset
    [Tags]    3S-1CC-16D-8U    CRT_TRUNK    RF50
    General_SiSo_Auto_BTS_site_reset  with_call=${True}  MAX_LOOP=${3}

#[1]CB009403-C-Made1-32TRX_01_General_SiSo_Commissioning_BTS_Template_Commissioning
#    General_SiSo_Commissioning_BTS_Template_Commissioning
#
#[1]CB009403-C-Made1-32TRX_02_General_SiSo_Cell_block_and_unblock
#    E2E_SiSo_Cell_block_and_unblock_gNB
#
#[1]CB009403-C-Made1-32TRX_05_Common_SiSo_RU_lock_unlock
#    General_SiSo_RU_lock_unlock
#
#[1]CB009403-C-Made1-32TRX_06_General_SiSo_RU_module_reset_from_GUI
#    General_SiSo_RF_module_reset_from_GUI    with_call=${True}
#
#[1]CB009403-C-Made1-32TRX_07_General_SiSo_Auto_RF_module_power_reset_with_L3call
#    General_SiSo_RF_module_power_reset
#
#[1]CB009403-C-Made1-32TRX_08_General_SiSo_CPRI_link_failure_triggered_RF_module_reset
#    General_SiSo_RF_module_reset_triggered_by_user_as_part_of_BTS_reset

*** Keywords ***
