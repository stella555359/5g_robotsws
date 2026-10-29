*** Settings ***
Documentation
...   author: tingting.zhong@nokia-sbell.com
...   contact: tingting.zhong@nokia-sbell.com
...   update: jie.2.li@nokia-sbell.com Activate collect ru logs: https://jiradc.ext.net.nokia.com/browse/LEOPARD-2126
...    Deprecated case removed by civen.chen

#Suite Setup         Cloud Suite Setup
#Suite Teardown      Cloud Suite Teardown
#Test Setup          run keywords    robot_common_operations.common case setup    fail_with_alarms=${False}    AND    Cloud Test Setup
#Test Teardown       run keywords    robot_common_operations.Common Case Teardown    AND    Cloud Test Teardown
#
#Force Tags
#...    PY39
#...    CLOUD_5G_AIC                               #TL_TYPE
#...    STATE_ON_AIR                               #gNB_STATE
#...    5G_RAN                                     #CA
#...    master_allincloud_int                      #vDU_Branch_name
#...    RAN_RD_VRF_HAZ4                            #Orginazation
#...    TA_LEVEL_22_FULL_AUTOMATED_CIT_CRT         #Detailed Automation Level
#
#Test Timeout    90 minutes
#
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_Cloud.robot
#Resource    ${BASIC_PATH_CLOUD}/Cloud_Setup_and_Teardown.robot
#Resource    ${BASIC_PATH_CLOUD}/General_SiSo_RU_module_reset_from_GUI_Cloud.robot
#Resource    ${BASIC_PATH_CLOUD}/General_SiSo_Cell_block_and_unblock_Cloud.robot
#Resource    ${BASIC_PATH_CLOUD}/Cloud_General_SiSo_vDU_Reset.robot
#Resource    ${line_case_dir}/Cloud_General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module.robot
#Resource    ${BASIC_PATH_CLOUD}/Cloud_General_SiSo_DL_Test_Model_Verification.robot
#Resource    ${BASIC_PATH_CLOUD}/Cloud_General_SiSo_UL_Test_Model_Verification.robot
#Resource    ${BASIC_PATH_CLOUD}/Cloud_Manual_SiSo_SM_RF_Module_lock_unlock.robot
#Resource    ${BASIC_PATH_CLOUD}/Cloud_Manual_SiSo_REC_Radio_Module_power_reset.robot
#Resource    ${line_case_dir}/Cloud_General_SiSo_vDU_Lock_Unlock.robot
#Resource    ${line_case_dir}/Cloud_General_SiSo_RF_alarms_without_autonomous_reset.robot
#Resource    ${BASIC_PATH_CLOUD}/Cloud_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
#Resource    ${line_case_dir}/Cloud_General_SiSo_Commissioning_BTS_Template_Commissioning.robot
#Resource    ${BASIC_PATH_CLOUD}/Cloud_General_SiSo_stability_with_L3Call.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
#
#*** Variables ***
#${line_case_dir}    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG4/Cloud/cases
#
#*** Test Cases ***
#[1]CB009563-CR-A_05_Cloud_General_SiSo_RU_module_reset_from_GUI
#    [Tags]    RF50
#    ${fault_list}    Create List    4675
#    Allowed Watchdog additional alarms    fault_list=${fault_list}
#    General_SiSo_RU_module_reset_from_GUI
#
#[1]CB009563-CR-A_07_Cloud_General_SiSo_Cell_block_and_unblock
#    [Tags]    1S-4CC_CB013584
#    General_SiSo_Cell_block_and_unblock
#
#[1]CB009563-CR-A_18_Cloud_General_SiSo_vDU_Reset
#    [Tags]    RF50
#    Cloud_General_SiSo_vDU_Reset
#
#[1]CB009563-CR-A_01_Cloud_General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
#    Cloud_General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
#
#[1]CB009563-CR-A_10_Cloud_General_SiSo_DL_Test_Model_Verification
#    ${test_model_list}    create list    NR-FR1-TM1.1    NR-FR1-TM1.2    NR-FR1-TM2    NR-FR1-TM2a
#    ...    NR-FR1-TM3.1    NR-FR1-TM3.1a    NR-FR1-TM3.2    NR-FR1-TM3.3
#    Cloud_General_SiSo_DL_Test_Model_Verification    test_model_list=${test_model_list}
#
#[1]CB009563-CR-A_11_Cloud_General_SiSo_UL_Test_Model_Verification
#    ${frc_index_list}    create list     G-FR1-A1-2
#    Cloud_General_SiSo_UL_Test_Model_Verification    frc_index_list=${frc_index_list}
#
#[1]CB009563-CR-A_08_Cloud_Manual_SiSo_SM_RF_Module_lock_unlock
#    Cloud_Manual_SiSo_SM_RF_Module_lock_unlock
#
#[1]CB009563-CR-A_12_Cloud_General_SiSo_E2E_system_setup_with_data_transfer_conducted
#    ${cell_list}    vDU Get Cells ID list
#    Cloud UE L3 Call And Throughput    cell_list=${cell_list}
#
#[1]CB009563-CR-A_04_Cloud_Manual_SiSo_REC_Radio_Module_power_reset
#    Cloud_Manual_SiSo_REC_Radio_Module_power_reset
#
#[1]CB009563-CR-A_19_Cloud_General_SiSo_vDU_Lock_Unlock
#    Cloud_General_SiSo_vDU_Lock_Unlock
#
#[1]CB009563-CR-A_09_Cloud_General_SiSo_RF_alarms_without_autonomous_reset
#    Cloud_General_SiSo_RF_alarms_without_autonomous_reset
#
#[1]CB009563-CR-A_13_Cloud_General_SiSo_stability_with_L3Call
#    [Timeout]    8h
#    Cloud_General_SiSo_stability_with_L3Call    stability_l3_duration=${stability_l3_duration}
#
#[1]CB009563-CR-A_14_Cloud_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#    Cloud_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#
#[1]CB009563-CR-A_02_Cloud_General_SiSo_Commissioning_BTS_Template_Commissioning
#    Cloud_General_SiSo_Commissioning_BTS_Template_Commissioning
