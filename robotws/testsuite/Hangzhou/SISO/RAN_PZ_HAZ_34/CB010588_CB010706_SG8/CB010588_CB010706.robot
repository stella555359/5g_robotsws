*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    Resources/CB010588_common_keywords.robot


Documentation
...    Author:wangqingqing
...    contact:qingqing.wang@nokia-sbell.com
...    squad group:SG_08
...    Feature CB010588 & CB010706

Force Tags    CRT_23R1    CRT_23R2    CRT_TRUNK
...    PY39

#*** Variables ***

*** Test Cases ***
[1]General_SiSo_RU_module_reset_from_GUI
    [Tags]    CRT_TRUNK
    General_SiSo_RF_module_reset_from_GUI_5times

[1]Manual_SiSo_SM_NR_RAT_reset_A13
    [Tags]    CRT_TRUNK
    Manual_SiSo_SM_LTE RAT reset_10times

[1]General_SiSo_Cell_lock_and_unlock_A10
    [Tags]    CRT_TRUNK
    General_SiSo_Cell_lock_and_unlock_A10

[1]General_SiSo_RU_lock_unlock_A14_A16_combination
    [Tags]    CRT_TRUNK
    General_SiSo_RU_lock_unlock_A14_A16_combination

[1]General_SiSo_E2E_system_setup_with_data_transfer_A2_A12_mix_bandwidth_combination
    [Tags]    CRT_TRUNK
    General_SiSo_E2E_system_setup_with_data_transfer_A2_A12_mix_bandwidth_combination

[1]General_SiSo_SuperCell_Reconfiguration_normal_cells_to_supercell_when_combination_-A_and_-D
    [Tags]    CRT_TRUNK
    General_SiSo_SuperCell_Reconfiguration_normal_cells_to_supercell_when_combination_-A_and_-D

[1][1.0] General_SiSo_SuperCell_Subcell_failure_statemangement
    [Tags]    CRT_TRUNK
    General_SiSo_SuperCell_Subcell_failure_statemangement_SG08

[1]General_SiSo_SuperCell_Reconfiguration_3supercells_to_1supercell
    [Tags]    CRT_TRUNK
    General_SiSo_SuperCell_Reconfiguration_3supercells_to_1supercell

[1]CB0010706-F_cell_Setup_NRTDD_4x80M_4T4R_NRFDD_6x40M_4T4R
    [Tags]    CRT_TRUNK
    CB0010706-F_cell_Setup_NRTDD_4x80M_4T4R_NRFDD_6x40M_4T4R

[1]General_SiSo_Online_FDD_Sector_Addition_Deletion_when_TDD_supercell_configured_on_half_ABIP
    [Tags]    CRT_TRUNK
    General_SiSo_Online_FDD_Sector_Addition_Deletion_when_TDD_supercell_configured_on_half_ABIP

#*** Keywords ***
