*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown
Test Timeout         2h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_block_and_unblock.robot
##Resource    ${BASIC_PATH_5G}/E2E_SiSo_Cell_block_and_unblock_gNB.robot
#Resource    ${BASIC_PATH_5G}/General_SiSo_Peak_with_Given_Information.robot
#Resource    ${BASIC_PATH_5G}/General_SiSo_Auto_BTS_site_reset.robot
#Resource    ${BASIC_PATH_5G}/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
#Resource    ${BASIC_PATH_5G}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot

Documentation
...    Author: Liu Yue
...    Contact: yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature CB009403 in SBTS23R1 program with configuration ID '23R1_N_CB009403_B'
...    Note: currently additional flag in bts is needed: 0x420062 =1  #enable_rdNewTddCellSlotModel of CB008940

Force Tags     RAN_5G     RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY36    master_classicalbts_all

*** Variables ***

*** Test Cases ***
#[1]CB009403-B-Made1-64TRX_01_General_SiSo_Commissioning_BTS_Template_Commissioning
#    [Tags]    3S-1CC-16D-8U    CRT_TRUNK    CRT_23R1
#    General_SiSo_Commissioning_BTS_Template_Commissioning

[1]CB009403-B-Made1-64TRX_02_General_SiSo_Cell_block_and_unblock
    [Tags]    3S-1CC-16D8U-8D8U-8D8U_CB009403-A    CRT_TRUNK    CRT_23R1
    General_SiSo_Cell_block_and_unblock    with_call=${False}    with_peak=${False}
    #E2E_SiSo_Cell_block_and_unblock_gNB    with_call=${False}    with_peak=${False}

#[1]CB009403-B-Made1-64TRX_03_Manual_SiSo_SM_BTS_Site_Reset
#    [Tags]    3S-1CC-16D-8U    CRT_TRUNK    CRT_23R1
#    General_SiSo_Auto_BTS_site_reset    with_call=${True}    MAX_LOOP=${1}
#
#[1]CB009403-B-Made1-64TRX_04_General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing
#    [Tags]    3S-1CC-16D-8U    CRT_TRUNK    CRT_23R1
#    ${cell_list}  create list  ${1}
#    Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${False}    duration=${300}
#
#[1]CB009403-B-Made1-64TRX_06_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#    [Tags]    3S-1CC-16D-8U    CRT_TRUNK    CRT_23R1
#    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot

*** Keywords ***
