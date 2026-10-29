*** Settings ***
Force Tags    PY36
Documentation
...    Author: Lusha Zhang
...    Contact: lusha.zhang@nokia-sbell.com
...    Group: VRF_HAZ3_2
...    Feature: CB010261

Suite Setup         run keywords    Cloud Suite Setup    AND    Set_scf_name_for_cases_CFG11
Test Setup          Tribe Common Test Setup
Test Teardown       Tribe Common Test Teardown
Suite Teardown      Cloud Suite Teardown
Resource          Resource/CB010261_common_keyword.robot


*** Variables ***
${scf_path_cu}    ${commissionings_path}/HGZ/${testline_name}/gnbs_0/cu
${scf_path_du}    ${commissionings_path}/HGZ/${testline_name}/gnbs_0/dus_0
# ${if_commissioning}    False

*** Test Cases ***
[1][2.0] General_SiSo_Commissioning_BTS_Template_Commissioning
    [Setup]    Tribe Common Test Setup with allowed faults    allowed_faults_ids=7504
    Log to console    \n CB010261 CFG11 Commissioning test\n
    General_SiSo_Commissioning_BTS_Template_Commissioning
    ...    vdu_scf_path=${scf_path_du}/${scf_name_du_CFG11}
    ...    cu_scf_path=${scf_path_cu}/${scf_name_cu_CFG11}

[1]General_SiSo_vDU_Lock_Unlock
    Log to console    \n General_SiSo_vDU_Lock_Unlock test\n
    ${du_id}    Create List    1
    vCU Lock vDU And Check Result    ${du_id}
    vCU Unlock vDU And Check Result    ${du_id}
    [Teardown]    vDU lock Test Teardown    du_id_list=${du_id}

[1][3.0] General_SiSo_Cell_block_and_unblock
    [Setup]    Tribe Common Test Setup with allowed faults    allowed_faults_ids=49
    Log to console    \n CB010261_CFG11 Cell_block_and_unblock test
    Cell_block_and_unblock

[1]General_SiSo_vDU_Reset
    Cloud_General_SiSo_vDU_Reset    with_call=${False}

[1][2.0] General_SiSo_RU_module_reset_from_GUI
    Log to console    \n CB010261_CFG11 RU_module_reset_from_GUI test
    General_SiSo_RU_module_reset_from_GUI    with_call=${False}

General_SiSo_RU_lock_unlock
    Log to console    \n General_SiSo_RU_lock_unlock test\n
    Cloud_Manual_SiSo_SM_RF_Module_lock_unlock    with_call=${False}


*** Keywords ***
Set_scf_name_for_cases_CFG11
    Get_vdu_and_vcu_release_version
    set suite variable    ${scf_name_du_CFG11}    SCF_SBTS${release_du}_${version_du}_CFG11.xml
    set suite variable    ${scf_name_cu_CFG11}    SCF_SBTS${release_cu}_${version_cu}_CFG11.xml
