*** Settings ***
Force Tags    PY36
Documentation
...    Author:yan meng
...    Contact:meng.yan@nokia-sbell.com
...    Group: VRF_HAZ3_T02
...    Feature: CB012749


Suite Setup         run keywords    Setup Suite For Cloud
Test Setup          Setup Test For Cloud
Test Teardown       Teardown Test For Cloud
Suite Teardown      Teardown Suite For Cloud
Resource          Resource/CB012749_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_Common.robot

*** Variables ***
${scf_path_cu}    ${commissionings_path}/HGZ/${testline_name}/CB012749/cu
${scf_path_du}    ${commissionings_path}/HGZ/${testline_name}/CB012749/dus_0

*** Test Cases ***
#[1][2.0] General_SiSo_Auto_Cell_lock_and_unlock
   # Cell_block_and_unblock

#[1][1.0] General_SiSo_Auto_RF_module_reset_from_WebUI
    #RU_module_Reset_from_Web

#[1]General_SiSo_vDU_Lock_Unlock
    #${du_id}    Create List    1
    #CU Lock DU    ${du_id}
   # CU Unlock DU    ${du_id}

#[1][1.0] General_SiSo_RU_lock_unlock
   # Ru_lock_and_unlock

#[1]General_SiSo_vDU_Reset
   # FOR  ${run_index}  IN RANGE  20
    #Reset DU
   # END
[1][1.0] General_SiSo_Auto_RF_lock_unlock
    Ru_lock_and_unlock

#[1][2.0] General_SiSo_RU_module_reset_from_GUI
   # RU_module_Reset_from_Web
#[1][1.0] Manual_SiSo_SM_RF_Module_lock_unlock
    #Ru_lock_and_unlock
#[1]General_SiSo_Cell_block_and_unblock
    #Cell_block_and_unblock


