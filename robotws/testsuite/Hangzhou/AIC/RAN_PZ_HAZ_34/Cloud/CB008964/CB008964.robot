# *** Settings ***
# Force Tags    PY36
# Documentation
# ...    Author:linjiangjing
# ...    Contact:jiangjing.lin@nokia-sbell.com
# ...    Group: HGZ_SG8
# ...    Feature: CB008964
# 
# Suite Setup         run keywords    Setup Suite For Cloud    AND    Prepare scf for cases
# Test Setup          Setup Test For Cloud
# Test Teardown       Teardown Test For Cloud
# Suite Teardown      Teardown Suite For Cloud
# Resource          Resource/CB008964_common_keyword.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# 
# *** Variables ***
# ${scf_path_cu}    ${commissionings_path}/HGZ/${testline_name}/gnbs_0/cu
# ${scf_path_du}    ${commissionings_path}/HGZ/${testline_name}/gnbs_0/dus_0
# 
# *** Test Cases ***
# [1]CB008964_B_01_Activate_and_configuration_of_NR_NR_16TRX_full_split_antenna_array_mode
#     commission scf and make call    vdu_scf_path=${scf_path_du}/${scf_name_du_20M_20M}
#     ...    cu_scf_path=${scf_path_cu}/${scf_name_cu_20M_20M}
#     ...    tput_self_define=${tput_20M_20M}
# 
# [1]CB008964_B_02_Activate_and_configuration_of_NR_NR_16TRX_half_split_antenna_array_mode
#     commission scf and make call    vdu_scf_path=${scf_path_du}/${scf_name_du_100M}
#     ...    cu_scf_path=${scf_path_cu}/${scf_name_cu_100M}
#     ...    tput_self_define=${tput_100M}
# 
# [1]CB008964_B_07_Split_Mode_General_SiSo_Cell_block_and_unblock
#     commission scf    vdu_scf_path=${scf_path_du}/${scf_name_du_40M_60M}    cu_scf_path=${scf_path_cu}/${scf_name_cu_40M_60M}
#     Cell_block_and_unblock_and_make_call    tput_self_define=${tput_40M_60M}
# 
# [1]CB008964_B_8_Split_Mode_General_SiSo_Ru_lock_and_unlock
#     commission scf    vdu_scf_path=${scf_path_du}/${scf_name_du_40M_60M}     cu_scf_path=${scf_path_cu}/${scf_name_cu_40M_60M}
#     Ru_lock_and_unlock_and_make_call    tput_self_define=${tput_40M_60M}
# 
# [1]CB008964_B_09_Split_Mode_General_SiSo_RU_module_Reset_from_Web
#     commission scf    vdu_scf_path=${scf_path_du}/${scf_name_du_50M_100M}     cu_scf_path=${scf_path_cu}/${scf_name_cu_50M_100M}
#     RU_module_Reset_from_Web_and_make_call    tput_self_define=${tput_50M_100M}
# 
# [1]CB008964_F_01_General_SiSo_alarm_trigger_with_split_mode
#     trigger fault 7116
