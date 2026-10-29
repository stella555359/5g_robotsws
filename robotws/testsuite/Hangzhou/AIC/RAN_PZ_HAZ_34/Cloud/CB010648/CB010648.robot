# *** Settings ***
# Force Tags    PY36
# Documentation
# ...    Author:mengyan
# ...    Contact:meng.yan@nokia-sbell.com
# ...    Group: RAN_PZ_HAZ_3
# ...    Feature: CB010648
# 
# Suite Setup         Setup Suite For Cloud
# Test Setup          Setup Test For Cloud
# Test Teardown       Teardown Test For Cloud
# Suite Teardown      Teardown Suite For Cloud
# Resource          Resource/CB010648_common_keyword.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# 
# *** Variables ***
# ${scf_path_cu}    ${commissionings_path}/HGZ/${testline_name}/gnbs_0/cu
# ${scf_path_du}    ${commissionings_path}/HGZ/${testline_name}/gnbs_0/dus_0
# 
# *** Test Cases ***
# [1]General_SiSo_Cell_block_and_unblock
#     #commission scf    vdu_scf_path=${scf_path_du}/${scf_name_du_40M_60M}    cu_scf_path=${scf_path_cu}/${scf_name_cu_40M_60M}
#     Cell_block_and_unblock_10648
# 
# [1][1.0] Manual_SiSo_SM_RF_Module_lock_unlock
#     #commission scf    vdu_scf_path=${scf_path_du}/${scf_name_du_40M_60M}     cu_scf_path=${scf_path_cu}/${scf_name_cu_40M_60M}
#     Ru_lock_and_unlock_10648
# 
# 
# 
