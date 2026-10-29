*** Settings ***
Force Tags    PY36
Documentation
...    Author:jiangrong wang
...    Contact:jiangrong.wang@nokia-sbell.com
...    Group: VRF_HAZ3_T7
...    Feature: CB014305


Suite Setup         run keywords    Setup Suite For Cloud
Test Setup          Setup Test For Cloud
Test Teardown       Teardown Test For Cloud
Suite Teardown      Teardown Suite For Cloud
Resource          Resource/CB014305_common_keyword.robot

*** Variables ***
${scf_path_cu}    ${commissionings_path}/HGZ/${testline_name}/CB014305/cu
${scf_path_du}    ${commissionings_path}/HGZ/${testline_name}/CB014305/dus_0

${ns}    cran1
${ru_index}    1

*** Test Cases ***
#[1][2.0] General_SiSo_Auto_Cell_lock_and_unlock
#   Cell_block_and_unblock

#[1][1.0] General_SiSo_Auto_RF_module_reset_from_WebUI
    #RU_module_Reset_from_Web

#[1]General_SiSo_vDU_Lock_Unlock
    #${du_id}    Create List    1
    #CU Lock DU    ${du_id}
   # CU Unlock DU    ${du_id}


[2][1.0] General_SiSo_Auto_Cloud_RMODs_Lock_And_Unlock
   Ru_lock_and_unlock

[1][1.0] General_SiSo_Auto_Cloud_DUs_Reset
   FOR  ${run_index}  IN RANGE  1
    Reset DU
   END

[1][3.0] General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
   Collect snapshot

#[1][2.0] General_SiSo_RU_module_reset_from_GUI
   # RU_module_Reset_from_Web

#[1][1.0] Manual_SiSo_SM_RF_Module_lock_unlock
    #Ru_lock_and_unlock

#[1]General_SiSo_Cell_block_and_unblock
    #Cell_block_and_unblock

#[1]General_SiSo_vDU_Reset
 #   Cloud_General_SiSo_vDU_Reset    with_call=${False}
