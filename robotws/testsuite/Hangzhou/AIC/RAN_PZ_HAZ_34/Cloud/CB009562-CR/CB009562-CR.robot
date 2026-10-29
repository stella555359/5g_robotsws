# *** Settings ***
# Documentation
# ...   author: kaihui.fan@nokia-sbell.com
# ...   contact: kaihui.fan@nokia-sbell.com
# 
# Suite Setup         Cloud Suite Setup
# Suite Teardown      Cloud Suite Teardown
# Test Setup          Cloud Test Setup
# # Test Teardown       Cloud Test Teardown
# 
# Force Tags
# ...    PY39
# ...    CLOUD_5G_AIC                               #TL_TYPE
# ...    STATE_ON_AIR                               #gNB_STATE
# ...    5G_RAN                                     #CA
# ...    master_allincloud_int                      #vDU_Branch_name
# ...    RAN_RD_VRF_HAZ4                            #Orginazation
# ...    TA_LEVEL_22_FULL_AUTOMATED_CIT_CRT         #Detailed Automation Level
# 
# Test Timeout    90 minutes
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_Cloud.robot
# Resource    ${BASIC_PATH_CLOUD}/Cloud_Setup_and_Teardown.robot
# Resource     ${BASIC_PATH_CLOUD}/Cloud_Manual_SiSo_REC_Radio_Module_power_reset.robot
# Resource     ${BASIC_PATH_CLOUD}/General_SiSo_RU_module_reset_from_GUI_Cloud.robot
# Resource     ${BASIC_PATH_CLOUD}/General_SiSo_Cell_block_and_unblock_Cloud.robot
# Resource     ${BASIC_PATH_CLOUD}/Cloud_Manual_SiSo_SM_RF_Module_lock_unlock.robot
# Resource     ${BASIC_PATH_CLOUD}/Manual_Siso_PM_5G_uDTX.robot
# Resource     ${BASIC_PATH_CLOUD}/Cloud_General_SiSo_vDU_Reset.robot
# Resource     ${BASIC_PATH_CLOUD}/Cloud_General_SiSo_E2E_system_setup_with_data_transfer_conducted.robot
# 
# 
# *** Variables ***
# ${reset_times}    5
# ${fail_times}    ${0}
# ${reset_sleep_time}    ${60}
# 
# *** Test Cases ***
# [1]CB009562_CR_A_05_AVQA_Cloud_Manual_SiSo_REC_Radio_Module_power_reset
#     Cloud_Manual_SiSo_REC_Radio_Module_power_reset
# 
# [1]CB009562_CR_A_06_AVQA_Cloud_General_SiSo_RU_module_reset_from_GUI
#     General_SiSo_RU_module_reset_from_GUI
# 
# [1]CB009562_CR_A_07_AVQA_Cloud_General_SiSo_Cell_block_and_unblock
#     General_SiSo_Cell_block_and_unblock
# 
# [1]CB009562_CR_A_08_AVQA_Cloud_Manual_SiSo_SM_RF_Module_lock_unlock
#     Cloud_Manual_SiSo_SM_RF_Module_lock_unlock
# 
# [1]CB009562_CR_A_09_AVQA_Cloud_Manual_Siso_PM_5G_Udtx
#     Manual_Siso_PM_5G_uDTX
# 
# [1]CB009562_CR_A_10_AVQA_Cloud_General_SiSo_E2E_system_setup_with_data_transfer_conducted
#     Cloud_General_SiSo_E2E_system_setup_with_data_transfer_conducted
#     ...    suite_name=${SUITE NAME}   test_name=${TEST NAME}
# 
# [1]CB009562_CR_A_11_AVQA_Robustness_vDU_Reset_Many_time
#     ${reset_times}  Convert To Integer  ${reset_times}
#     FOR    ${loop_index}    IN RANGE   1   ${reset_times}+1
#          ${result}=     Run Keyword And Return Status   Cloud_General_SiSo_vDU_Reset
#          ${fail_times}    run keyword if    ${result}    set variable    ${fail_times}   ELSE   evaluate    ${fail_times}+1
#          run keyword if      not ${result}    FAIL
#          log to console    \nthe ${loop_index} time sleep ${reset_sleep_time}s
#          sleep    ${reset_sleep_time}
#     END
# 
# *** Keywords ***
