*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         24h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB007331/Resources/CB007331_common_keyword.robot

Documentation
...    Author:zhihao shi
...    contact:zhihao.shi@nokia-sbell.com
...    squad group:SG_04
...    Feature CB007331 in SBTS00 program

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_SA_ASILL_ABIOB1_AZNA
...    PY36

*** Test Cases ***
# TL576(SA)  -- SBTS23R3/SBTS23R2
# TL313(SA)  -- SBTS23R1
# CB007331-5G-A 40M  1 link L3 call
[1]CB007331-5G-A_15_General_SiSo_E2E_system_setup_with_data_transfer_conducted_40M_L3Call
    [Tags]    CRT_23R1    CRT_23R2    SBTS00    CRT_UTE
    Modify_Three_Parameter_for_CB007331    carriermode=true    iqcompression=9bits    actdownsampling=true
    General_SiSo_Peak_with_Given_Information    band=40    frame_structure=1116_0ms_GP1_A8

# CB007331-5G-B 60M  1 link L3 call
[1]CB007331-5G-B_12_General_SiSo_E2E_system_setup_with_data_transfer_conducted_60M_L3Call
    [Tags]    CRT_23R1    CRT_23R2    SBTS00    CRT_UTE
    Modify_Three_Parameter_for_CB007331    carriermode=true    iqcompression=9bits    actdownsampling=false
    General_SiSo_Peak_with_Given_Information    band=60    frame_structure=1116_0ms_GP1_A8

# CB007331-5G-C 80M  2 link L3 call
[1]CB007331-5G-C_1_General_SiSo_E2E_system_setup_with_data_transfer_conducted_80M_L3Call
    [Tags]    CRT_23R1    CRT_23R2    SBTS00    CRT_UTE    1S-1CC-4D-4U_80M    RF50
    # Modify_Three_Parameter_for_CB007331    carriermode=true   iqcompression=9bits    actdownsampling=false
    # General_SiSo_Peak_with_Given_Information    band=80    frame_structure=1116_0ms_GP1_A8
    ${cell_list}  create list  ${7}
    Get UE From Init File and Make call  cell_list=${cell_list}  duration=${60}  loop_times=${1}    with_peak=${True}

[1]CB007331-5G-A_General_SiSo_E2E_system_setup_with_data_transfer_conducted_1UE
    ${cell_list}  create list  ${1}
    Get UE From Init File and Make call  cell_list=${cell_list}  duration=${60}  loop_times=${1}

[1]CB007331-5G-B_15_Reconfiguration_of_wide_NR_carrier_bandwidth_from_20_to_40_to_60_to_20MHz
    [Tags]    RF50
    Reconfiguration of wide NR carrier bandwidth from 20 to 40 to 60 to 20MHz

[1]CB007331-5G-B_16_General_siso_check_alarm_4044
    [Tags]    1S-2CC-2D-2U
    ${fault_list}    Create List    4044
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    Reconfiguration of wide NR carrier bandwidth from 20 to 60MHz and check alarm 4044

#CB007331-5G-A_2_General_SiSo_Commissioning_BTS_Template_Commissioning_AZNA_AZHA_AZNC
#    General_SiSo_Commissioning_BTS_Template_Commissioning
#
#CB007331-5G-A_3_General_SiSo_RF_module_power_reset
#    General_SiSo_RF_module_power_reset
#
#CB007331-5G-A_4_General_SiSo_RU_module_reset_from_GUI_AZNA
#    General_SiSo_RF_module_reset_from_GUI
#
#CB007331-5G-A_5_General_SiSo_RU_module_reset_from_GUI_AZHA
#    General_SiSo_RF_module_reset_from_GUI
#
#CB007331-5G-A_6_General_SiSo_RU_lock_unlock_AZNA
#    General_SiSo_RU_lock_unlock
#
#CB007331-5G-A_7_General_SiSo_RU_lock_unlock_AZHA
#    General_SiSo_RU_lock_unlock
#
#CB007331-5G-A_8_General_SiSo_Cell_block_and_unblock_AZNA
#    General_SiSo_Cell_block_and_unblock
#
#CB007331-5G-A_9_General_SiSo_Cell_block_and_unblock_AZHA
#    General_SiSo_Cell_block_and_unblock
#
#CB007331-5G-A_10_General_SiSo_Cell_Block_and_unblock_AZNC
#    General_SiSo_Cell_block_and_unblock
#
#CB007331-5G-A_11_General_SiSo_CPRI_link_failure_triggered_RF_module_reset_AZNA
#    General_SiSo_RF_module_reset_triggered_by_user_as_part_of_BTS_reset
#
#CB007331-5G-A_12_General_SiSo_CPRI_link_failure_triggered_RF_module_reset_AZHA
#    General_SiSo_RF_module_reset_triggered_by_user_as_part_of_BTS_reset
#
#CB007331-5G-A_13_General_SiSo_CPRI_link_failure_triggered_RF_module_reset_AZNC
#    General_SiSo_RF_module_reset_triggered_by_user_as_part_of_BTS_reset
#
#CB007331-5G-A_14_General_SiSo_E2E_system_setup_with_data_transfer_conducted_5GC001116_NSA_call
#    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1208_GP1_A1
#
#CB007331-5G-A_16_General_SiSo_E2E_system_setup_with_data_transfer_conducted_5GC001116_Multiple_UE_NSA_call
#    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1208_GP1_A1  ue_num_each_call=2
#
#CB007331-5G-A_17_General_SiSo_E2E_system_setup_with_data_transfer_conducted_5GC001116_Multiple_UE_SA_call
#    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1208_GP1_A1  ue_num_each_call=2
#
#CB007331-5G-A_18_General_SiSo_Commissioning_concurrent_mode_LTE_NR
#    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1208_GP1_A1
#
#CB007331-5G-A_19_General_SiSo_data_transfer_conducted_concurrent_mode_LTE_NR
#    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1208_GP1_A1
#
#CB007331-5G-B_1_General_SiSo_Commissioning_BTS_Template_Commissioning_AZNA_AZHA
#    General_SiSo_Commissioning_BTS_Template_Commissioning
#
#CB007331-5G-B_2_General_SiSo_RF_module_power_reset
#    General_SiSo_RF_module_power_reset
#
#CB007331-5G-B_3_General_SiSo_RU_module_reset_from_GUI_AZNA
#    General_SiSo_RF_module_reset_from_GUI
#
#CB007331-5G-B_4_General_SiSo_RU_module_reset_from_GUI_AZHA
#    General_SiSo_RF_module_reset_from_GUI
#
#CB007331-5G-B_5_General_SiSo_RU_lock_unlock_AZNA
#    General_SiSo_RU_lock_unlock
#
#CB007331-5G-B_6_General_SiSo_RU_lock_unlock_AZHA
#    General_SiSo_RU_lock_unlock
#
#CB007331-5G-B_7_General_SiSo_Cell_block_and_unblock_AZNA
#    General_SiSo_Cell_block_and_unblock
#
#CB007331-5G-B_8_General_SiSo_Cell_lock_and_unlock_AZHA
#    General_SiSo_Cell_block_and_unblock
#
#CB007331-5G-B_11_General_SiSo_E2E_system_setup_with_data_transfer_conducted_5GC001116_NSA_call
#    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1208_GP1_A1
#
#CB007331-5G-B_13_General_SiSo_E2E_system_setup_with_data_transfer_conducted_5GC001116_Multiple_UE_NSA_call
#    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1208_GP1_A1  ue_num_each_call=2
#
#CB007331-5G-B_14_General_SiSo_E2E_system_setup_with_data_transfer_conducted_5GC001116_Multiple_UE_SA_call
#    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1208_GP1_A1  ue_num_each_call=2
#
#CB007331-5G-B_15_General_SiSo_Commissioning_concurrent_mode_LTE_NR
#    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1208_GP1_A1
#
#CB007331-5G-B_16_General_SiSo_data_transfer_conducted_concurrent_mode_LTE_NR
#    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1208_GP1_A1
#
#CB007331-5G-B_General_SiSo_E2E_system_setup_with_data_transfer_conducted_1UE
#    ${cell_list}  create list  ${1}
#    Get UE From Init File and Make call  cell_list=${cell_list}  duration=${60}  loop_times=${1}
#
#CB007331-5G-C_2_General_SiSo_Cell_block_and_unblock
#    General_SiSo_Cell_block_and_unblock
#
#CB007331-5G-C_1_General_SiSo_E2E_system_setup_with_data_transfer_conducted
#    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1208_GP1_A1
#
#CB007331-5G-C_3_General_SiSo_RU_lock_unlock
#    General_SiSo_RU_lock_unlock
