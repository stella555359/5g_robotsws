# *** Settings ***
# Suite Setup    Run keywords    SISO Coam Suite Setup    AND    Get PA Ports For All RUs 8953    AND    Get expect tput for each cell
# Suite Teardown    Suite Teardown For Config Recovery
# Test Setup    Run keywords    SISO Coam Test Setup    AND    Get btsName
# ...    AND    Set Whole Attenuator Ports    attenuator_out_ports=${PA_OUT_PORTS}    attenuator_rows=${PA_ROWS}
# Test Teardown    SISO Coam Test Teardown
# #Suite Setup          SISO Coam Suite Setup
# #Suite Teardown       SISO Coam Suite Teardown
# #Test Setup           SISO Coam Test Setup
# #Test Teardown        SISO Coam Test Teardown
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource     Resources/CB008953_common_keyword.robot
# Variables    TestData/8953_variables.py
# 
# Documentation
# ...    Author:eleven 1 wu
# ...    contact:eleven.1.wu@nokia-sbell.com
# ...    squad group:SG_08
# ...    Feature CB008953
# 
# Force Tags    SBTS00
# ...   PY36
# 
# *** Variables ***
# @{nr_cell_1}    ${1}
# @{nr_cell_2}    ${2}
# @{nr_cell_3}    ${3}
# @{nr_cell_4}    ${4}
# @{lte_cell_401}    ${11}
# @{lte_cell_402}    ${12}
# @{lte_cell_403}    ${13}
# @{lte_cell_404}    ${14}
# @{lte_cell_405}    ${15}
# @{lte_cell_406}    ${16}
# 
# *** Test Cases ***
# [1][1.0] General_SiSo_E2E_system_setup_with_data_transfer
#     [Tags]    CRT_TRUNK    CRT_23R4
#     General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing_8953_7   tput_self_define=${tput}
#     ...    config_id=8953_7
# 
# [1][2.0] General_SiSo_Cell_block_and_unblock
#     [Tags]    CRT_TRUNK    CRT_23R4
#     General_SiSo_Cell_block_and_unblock_8953_7    tput_self_define=${tput}    config_id=8953_7
# 
# [1][2.0] Manual_SiSo_SM_NR_RAT_reset
#     [Tags]    CRT_TRUNK    CRT_23R4
#     Manual_SiSo_SM_NR RAT reset_8953_7    tput_self_define=${tput}    config_id=8953_7
# 
# [1][2.0] Manual_SiSo_SM_RF_Module_lock_unlock
#     [Tags]    CRT_TRUNK    CRT_23R4
#     Manual_SiSo_SM_RF_Module_lock_unlock_8953_7    tput_self_define=${tput}    config_id=8953_7