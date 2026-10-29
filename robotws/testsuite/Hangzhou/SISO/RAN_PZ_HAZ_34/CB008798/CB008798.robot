*** Settings ***
Suite Setup    SISO Coam Suite Setup
Suite Teardown    Suite Teardown For Config Recovery
Test Setup    Run keywords    SISO Coam Test Setup    AND    Get btsName
Test Teardown    SISO Coam Test Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource     Resources/CB008798_common_keyword.robot
Variables    TestData/8798_variables.py

Documentation
...    Author:linjiangjing
...    contact:jiangjing.lin@nokia-sbell.com
...    squad group:SG_08
...    Feature CB008798

Force Tags    SBTS00
...   PY36

*** Variables ***
@{nr_cell_1}    ${1}
@{nr_cell_2}    ${2}
@{nr_cell_3}    ${3}
@{nr_cell_4}    ${4}
@{nr_cell_5}    ${5}
@{nr_cell_6}    ${6}
@{lte_cell_401}    ${401}
@{lte_cell_402}    ${402}
@{lte_cell_403}    ${403}
@{lte_cell_404}    ${404}
@{lte_cell_405}    ${405}
@{lte_cell_406}    ${406}
@{cell_id_NR}    ${1}
@{cell_id_LTE}    ${401}
${ue_used_index}    0
*** Test Cases ***
[1]General_SiSo_E2E_system_setup_with_data_transfer_conducte_8798_J
    [Tags]    CRT_TRUNK    CRT_22R4
    General_SiSo_E2E_system_setup_with_data_transfer_conducte_8798_config    config_id=J    tput_nr=${tput_nr_8798}
    ...    tput_lte=${tput_lte_8798}

#[1]CB006876_ASOE_Concurrent_Mode_Individual_RAT_Reset
#    [Tags]    CRT_TRUNK    CRT_22R4
#    CB006876_ASOE_Concurrent_Mode_Individual_RAT_Reset_8798-J    tput_self_define=${tput}    config_id=J

[1]Manual_SiSo_SM_RF_Module_lock_unlock_8798_J
    [Tags]    CRT_TRUNK    CRT_22R4
    Manual_SiSo_SM_RF_Module_lock_unlock_8798_config    config_id=J    tput_nr=${tput_nr_8798}    tput_lte=${tput_lte_8798}

#[1]General_SiSo_Cell_block_and_unblock_8798_J
#    [Tags]    CRT_TRUNK    CRT_22R4
#    General_SiSo_Cell_block_and_unblock_8798_J    tput_self_define=${tput}    config_id=J

#[1][1.0] OAM_KPI_61a_SiSo_Auto_BTS_site_reset
#    [Tags]    CRT_TRUNK    CRT_22R4
#    Auto_BTS_site_reset_kpi    config_id=J

#[1]General_SiSo_E2E_system_setup_with_data_transfer_conducte_8798_M1
#    [Tags]    CRT_TRUNK    CRT_22R4
#    General_SiSo_E2E_system_setup_with_data_transfer_conducte_8798_M1    tput_self_define=${tput_M}    config_id=M1

#[1]General_SiSo_Cell_block_and_unblock_8798_M1
#    [Tags]    CRT_TRUNK    CRT_22R4
#    General_SiSo_Cell_block_and_unblock_8798_M1    tput_self_define=${tput_M}    config_id=M1

[1]Manual_SiSo_SM_RF_Module_lock_unlock_8798_M1
   [Tags]    CRT_TRUNK    CRT_22R4
   Manual_SiSo_SM_RF_Module_lock_unlock_8798_config    config_id=M1    tput_nr=${tput_nr_8798_M}    tput_lte=${None}

#[1]General_SiSo_E2E_system_setup_with_data_transfer_conducte_8798_M2
#    [Tags]    CRT_TRUNK    CRT_22R4
#    General_SiSo_E2E_system_setup_with_data_transfer_conducte_8798_M2    tput_self_define=${tput_M}    config_id=M2

[1]General_SiSo_Cell_block_and_unblock_8798_M2
    [Tags]    CRT_TRUNK    CRT_22R4
    General_SiSo_Cell_block_and_unblock_8798_config    config_id=M2    tput_nr=${tput_nr_8798_M}    tput_lte=${None}

#[1]Manual_SiSo_SM_RF_Module_lock_unlock_8798_M2
#    [Tags]    CRT_TRUNK    CRT_22R4
#    Manual_SiSo_SM_RF_Module_lock_unlock_8798_M2   tput_self_define=${tput_M}    config_id=M2

#[1]General_SiSo_E2E_system_setup_with_data_transfer_conducte_6876_Config1
#    [Tags]    CRT_TRUNK    CRT_22R3    CRT_22R4
#    General_SiSo_E2E_system_setup_with_data_transfer_conducted_by_config_6876    tput_self_define=${tput_6876}    cell_id_NR=${cell_id_NR}
#    ...    config_id=1

#[1]General_SiSo_Cell_block_and_unblock_6876_Config1
#    [Tags]    CRT_TRUNK    CRT_22R3    CRT_22R4
#    General_SiSo_Cell_lock_and_unlock_by_config_6876    tput_self_define=${tput_6876}    cell_id_NR=${cell_id_NR}    cell_id_LTE=${cell_id_LTE}
#    ...    config_id=1    ue_index= ${ue_used_index}
