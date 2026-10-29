*** Settings ***
Suite Setup    Run keywords    SISO Coam Suite Setup    AND    Case Preparation CB0011092
Suite Teardown    SISO Coam Suite Teardown
Test Setup    Run keywords    SISO Coam Test Setup    AND    AlarmWatchdog.add_allow_alarms    fault_id=49
Test Teardown    SISO Coam Test Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource     Resources/CB011092_common_keyword.robot
Variables    TestData/11092_variables.py

Documentation
...    Author:linjiangjing
...    contact:jiangjing.lin@nokia-sbell.com
...    squad group:SG_08
...    Feature CB011092

Force Tags    SBTS00
...   PY36



*** Test Cases ***
[1]CB011092_C_General_SiSo_E2E_system_setup_with_data_transfer_conducted_C10
    CB011092_C_General_SiSo_E2E_system_setup_with_data_transfer_conducted_C10

[1]CB011092_C_General_SiSo_E2E_system_setup_with_data_transfer_conducted_C11
    CB011092_C_General_SiSo_E2E_system_setup_with_data_transfer_conducted_C11

[1]E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    CB011092_common_keyword.E2E_TL_SW_upgrade_rollback_with_OAM_KPI

[1]E2E_TL_Site_reset_without_HWF_with_OAM_KPI
    CB011092_common_keyword.E2E_TL_Site_reset_without_HWF_with_OAM_KPI

[1]E2E_TL_Activation_Reset_with_OAM_KPI
    E2E_TL_Activation_Reset_with_OAM_KPI_11092

[1]CB011092_C_General_SiSo_SuperCell_Reconfiguration_C9_add_one_subcell
    CB011092_C_General_SiSo_SuperCell_Reconfiguration_C9_add_one_subcell

[1]CB011092_A_General_SiSo_Online_Cell_Addition_Deletion_A8
    CB011092_A_General_SiSo_Online_Cell_Addition_Deletion_A8

[1]CB011092_A_General_SiSo_E2E_system_setup_with_data_transfer_A4_A5_combination
    CB011092_A_General_SiSo_E2E_system_setup_with_data_transfer_A4_A5_combination

[1]CB011092_C_General_SiSo_E2E_system_setup_with_data_transfer_A6_C9_combination
    CB011092_C_General_SiSo_E2E_system_setup_with_data_transfer_A6_C9_combination
