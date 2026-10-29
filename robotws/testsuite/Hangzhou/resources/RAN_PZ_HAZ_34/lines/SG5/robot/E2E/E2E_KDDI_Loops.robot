*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown
Test Timeout         400 min

Resource    resources/e2e_common_cases.robot

Documentation
...    Author:Zhaojun Chen
...    contact:zhaojun.chen@nokia-sbell.com
...    squad group:SG_05
...    Feature CB007835-5G-A: Key customer scenario testing - KDDI cmWave in 22R1 program
...    Configuration blocks:

Force Tags    5G_RAN_TDD
...   PY27

*** Variables ***
${loop_times}           5
${RU_index_to_Test}     1
${RU_type_to_Test}      AZQJ

*** Test Cases ***
[1][1.0] 5GI000146-E_TC03_AEQV_General_SiSo_RU_lock_unlock
    [Tags]    E2E_22R1
    General_Stability_Test_Case
    ...    case_name=E2E_gNB_SiSo_RU_lock_and_unlock_by_RadioIndex
    ...    times=${loop_times}    pass=${loop_times}
    ...    ru_index=${RU_index_to_Test}    with_call=${False}

[1][1.0] 5GI000146-E_TC02_AEQV_General_SiSo_Cell_lock_and_unlock
    [Tags]    E2E_22R1
    General_Stability_Test_Case
    ...    case_name=E2E_gNB_SiSo_cell_block_and_unblock_by_RadioIndex
    ...    times=${loop_times}    pass=${loop_times}
    ...    ru_index=${RU_index_to_Test}    with_call=${False}

[1][1.0] 5GI000146-E_TC01_AEQV_General_SiSo_RF_module_power_reset
    [Tags]    E2E_22R1
    General_Stability_Test_Case
    ...    case_name=E2E_gNB_SiSo_RF_module_power_reset_by_RadioIndex
    ...    times=${loop_times}    pass=${loop_times}
    ...    ru_index=${RU_index_to_Test}    with_call=${False}

[1][1.0] E2E_gNB_SiSo_RF_module_reset_from_WebEM_by_RadioIndex
    [Tags]    E2E_22R1
    General_Stability_Test_Case
    ...    case_name=E2E_gNB_SiSo_RF_module_reset_from_WebEM_by_RadioIndex
    ...    times=${loop_times}    pass=${loop_times}
    ...    ru_index=${RU_index_to_Test}    with_call=${False}

[1][1.0] E2E_gNB_SiSo_site_power_reset
    [Tags]    E2E_22R1
    E2E_gNB_SiSo_site_power_reset

[1][1.0] E2E_gNB_SiSo_site_software_reset
    [Tags]    E2E_22R1
    E2E_gNB_SiSo_site_software_reset

[1][1.0] E2E_gNB_SiSo_RU_lock_and_unlock_by_RadioType
    [Tags]    E2E_22R1
    E2E_gNB_SiSo_RU_lock_and_unlock_by_RadioType    RU_type_to_Test=${RU_type_to_Test}    with_call=${False}

[1][1.0] E2E_gNB_SiSo_cell_block_and_unblock_by_RadioType
    [Tags]    E2E_22R1
    E2E_gNB_SiSo_cell_block_and_unblock_by_RadioType    RU_type_to_Test=${RU_type_to_Test}    with_call=${False}


*** Keywords ***
