# *** Settings ***
# Suite Setup   Test Suite Setup
# Suite Teardown     #SISO Coam Suite Teardown
# Test Setup    #SISO Coam Test Setup
# Test Teardown    #Coam Test Teardown
# Test Timeout    1000 min
# 
# Resource    ./Resources/CB010564_Common_Keyword.robot
# 
# 
# 
# *** Variables ***
# ${testline_name}    7_5_UTE5G402T904
# #${scf_file_path}    ${commissionings_path}/HGZ/${testline_name}/CB010564
# ${scf_file}    904_SCF.xml
# 
# *** Test Cases ***
# [1]CB010564_22_General_SiSo_Cell_block_and_unblock
#     [Setup]    Case Setup
#     [Teardown]    case teardown
# ##    Run Keyword and Continue on Failure    Scf commission and wait on-air    scf_name=${scf_file_path}/${scf_file}
#      Run Keyword and Continue on Failure    Block NR and LTE cells for 300 times
# 
# [1]CB010564_23_Manual_SiSo_SM_BTS_Site_Reset
#     [Setup]    Case Setup
#     [Teardown]    case teardown
#      Run Keyword and Continue on Failure    Site reset 300 times
# 
# [1]CB010564_25_General_SiSo_RAT_NR_Block_Unblock_with_L3Call
#     [Setup]    Case Setup
#     [Teardown]    case teardown
#     Run Keyword and Continue on Failure    Block and Unblock NR 300 times
# 
# [1]CB010564_25_General_SiSo_RAT_LTE_Block_Unblock_with_L3Call
#     [Setup]    Case Setup
#     [Teardown]    case teardown
#     Run Keyword and Continue on Failure    Block and Unblock LTE 300 times
# 
# [1]CB010564_25_General_SiSo_RAT_NR_reset
#     [Setup]    Case Setup
#     [Teardown]    case teardown
#     Run Keyword and Continue on Failure    NR reset 300 times
# 
# [1]CB010564_27_General_SiSo_Auto_Cell_lock_and_unlock_with_L3call
#     [Setup]    Case Setup
#     [Teardown]    case teardown
#     Run Keyword and Continue on Failure    Lock NR and LTE cells for 300 times
# 
# 
# [1]CB010564_33_General_robust_Block_unblock_Site
#     [Setup]    Case Setup
#     [Teardown]    case teardown
#      Run Keyword and Continue on Failure    Block and Unblock site 300 times
# 
# [1]CB010564_33_General_robust_reset_LTE_NR
#      [Setup]    Case Setup
#      [Teardown]    case teardown
#      Run Keyword and Continue on Failure    NR reset 30 times
#      Run Keyword and Continue on Failure    LTE reset 30 times
# 
# [1]CB010564_26_Auto_cell_deletion_addition_loops
#     [Setup]    Case Setup
#     [Teardown]    case teardown
#     Run Keyword and Continue on Failure    Delete and add cells in 10 loops
# 
# RU Power Off and Power on loop
#     [Setup]    Case Setup
#     [Teardown]    case teardown
#     Run Keyword and Continue on Failure    RU Power Off and Power On 300 times
# 
# CB010564_Cablink lock and unlock
#      [Setup]    Case Setup
#      [Teardown]    case teardown
#     Run Keyword and Continue on Failure    RU Cablink Lock Unlock for 100 times
# 
# CB010564_RU_Operation
#      [Setup]    Case Setup
#      [Teardown]    case teardown
#     Run Keyword and Continue on Failure    RU Lock Reset Unlock for 300 times
# 
# Power Reset gNB
#      [Setup]    Case Setup
#      [Teardown]    case teardown
#     Run Keyword and Continue on Failure    Power Reset gNB 300 times
# 
# RU Power Off On With L3 Call
#      [Setup]    Case Setup
#      [Teardown]    case teardown
#     Run Keyword and Continue on Failure    RU Power Off On 50 times With L3 Call
# 
# RU Cablink Lock Unlock With L3 Call
#      [Setup]    Case Setup
#      [Teardown]    case teardown
#     Run Keyword and Continue on Failure    RU Cablink Lock Unlock for 50 times With L3 Call
# 
# 
# 
