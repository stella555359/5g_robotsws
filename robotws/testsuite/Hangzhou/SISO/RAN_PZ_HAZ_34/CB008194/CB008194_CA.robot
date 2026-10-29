# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
# Test Timeout         12h
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_5G}/General_Stability_Test_Case.robot
# Resource    ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RU_lock_unlock.robot
# Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Online_Cell_addition_deletion.robot
# Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot
# Resource    ${BASIC_PATH_5G}/General_gnb_can_be_on_air_with_Given_Information.robot
# 
# Documentation
# ...    Author:zhihao shi
# ...    contact:zhihao.shi@nokia-sbell.com
# ...    squad group:SG_04
# ...    Feature CB008194 in trunk program
# 
# Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED
# ...   PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# # TL585 1S-1CC-8D-4U
# [1]CB008194_BA_06_General_SiSo_Cell_block_and_unblock
#     [Tags]    CRT_TRUNK    SBTS00    CRT_UTE
#     E2E_SiSo_Cell_block_and_unblock_gNB
# 
# [1]CB008194_BA_10_General_SiSo_E2E_system_setup_with_data_transfer_conducted_max_MCS L3_call
#     General_SiSo_Peak_with_Given_Information    band=20    frame_structure=1208_GP1_A1
# 
# [1]CB008194_CA_24_General_SiSo_E2E_system_setup_with_data_transfer_conducted_with_chbw_40M
#     General_SiSo_Peak_with_Given_Information    band=40    frame_structure=1208_GP1_A1
# 
# [1]CB008194_CA_22_General_SiSo_E2E_system_setup_with_data_transfer_conducted_with_chbw_20M
#     General_SiSo_Peak_with_Given_Information    band=20    frame_structure=1208_GP1_A1
# 
# [1]CB008194_CA_23_General_SiSo_E2E_system_setup_with_data_transfer_conducted_with_chbw_30M
#     General_SiSo_Peak_with_Given_Information    band=30    frame_structure=1208_GP1_A1
# 
# [1]CB008194_CA_25_General_SiSo_E2E_system_setup_with_data_transfer_conducted_with_chbw_50M
#     General_SiSo_Peak_with_Given_Information    band=50    frame_structure=1208_GP1_A1
# 
# [1]CB008194_CA_26_General_SiSo_E2E_system_setup_with_data_transfer_conducted_with_chbw_60M
#     General_SiSo_Peak_with_Given_Information    band=60    frame_structure=1208_GP1_A1
# 
# [1]CB008194_CA_27_General_SiSo_E2E_system_setup_with_data_transfer_conducted_with_chbw_70M
#     General_SiSo_Peak_with_Given_Information    band=70    frame_structure=1208_GP1_A1
# 
# [1]CB008194_CA_28_General_SiSo_E2E_system_setup_with_data_transfer_conducted_with_chbw_80M
#     General_SiSo_Peak_with_Given_Information    band=80    frame_structure=1208_GP1_A1
# 
# [1]CB008194_CA_29_General_SiSo_E2E_system_setup_with_data_transfer_conducted_with_chbw_90M
#     General_SiSo_Peak_with_Given_Information    band=90    frame_structure=1208_GP1_A1
# 
# [1]CB008194_CD_11_General_SiSo_Online_Cell_addition_deletion_50M+50M
#     [Tags]    1S-2CC-8D-4U
#     General_gnb_can_be_on_air_with_Given_Information    band=50    frame_structure=1070_GP1_A3
#     General_SiSo_Online_Cell_addition_deletion
# 
# [1]CB008194_CD_22_20M+20M_cell_block_unblock
#     [Tags]    1S-2CC-8D-4U
#     General_gnb_can_be_on_air_with_Given_Information    band=20    frame_structure=1070_GP1_A3
#     E2E_SiSo_Cell_block_and_unblock_gNB
# 
# [1]CB008194_CD_23_50M+50M_RU_lock_unlock
#     [Tags]    1S-2CC-8D-4U
#     General_gnb_can_be_on_air_with_Given_Information    band=50    frame_structure=1070_GP1_A3
#     General_SiSo_RU_lock_unlock
# 
# [1]CB008194_CA_General_SiSo_E2E_system_setup_with_data_transfer_conducted_with_chbw_40M+40M
#     [Tags]    1S-2CC-8D-4U
#     ${cell_list}    Get All Cell Id
#     ${ue_num_each_call}    Get Tput ue Number    given_num=2
#     Get UE From Init File and Make call  cell_list=${cell_list}  with_peak=${True}
#     ...    duration=${300}  loop_times=${1}  ue_num_each_call=${ue_num_each_call}
# 
# #[1]CB008194_BA_37_General_SiSo_E2E_system_setup_with_data_transfer_conducted_max_MCS L3_call_SFP_10GE
# #    General_SiSo_Peak_with_Given_Information    band=20    frame_structure=1208_GP1_A1
# 
# *** Keywords ***
