*** Settings ***
Resource   ./CaseResource/SISO_Common_General_SiSo_Cell_lock_and_unlock.robot
Resource   ./CaseResource/SISO_Common_General_SiSo_Commissioning_BTS_Template_Commissioning.robot
Resource   ./CaseResource/SISO_Common_General_SiSo_E2E_system_setup_with_data_transfer_conducted.robot
Resource   ./CaseResource/SISO_Common_General_SiSo_RU_lock_unlock.robot
Resource   ./CaseResource/SISO_Common_OAM_KPI_61a_SiSo_Auto_BTS_site_reset.robot
Resource   ./CaseResource/SISO_Common_OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_WebUI_with_L3Call.robot
Resource   ./CaseResource/SISO_Common_General_SiSo_Cells_Sectors_number_change_scenario.robot
Resource   ./CaseResource/SISO_Common_General_SiSo_MPlane_Configurable_TDD_Frame_Structure_L3_Call.robot
Resource   ./CaseResource/SISO_Common_General_SiSo_CM_Recommissioning.robot
Resource   ./CaseResource/SISO_Common_General_SiSo_RF_module_reset_from_GUI.robot
Resource   ./CaseResource/SISO_Common_5G_rat_reset.robot
Suite Setup   Suite Setup Steps
Suite Teardown   Suite Teardown Steps

*** Variables ***
@{nsa_btsid_list}    10565
${reset_times}   20
${BTS_ID}   ${tl.gnbs[0].instance_id}

*** Test Cases ***
[1]General_SiSo_Cell_lock_and_unlock
    [Timeout]   3h
    [Setup]   Case Setup: Cell_lock_and_unlock
    Test_Case_General_SiSo_Cell_lock_and_unlock
    [Teardown]   Case Teardown: Cell_lock_and_unlock

[1]General_SiSo_E2E_system_setup_with_data_transfer_conducted
    [Timeout]   3h
    [Setup]   Case Setup: E2E_system_setup_with_data_transfer_conducted
    Test_Case_General_SiSo_E2E_system_setup_with_data_transfer_conducted
    [Teardown]   Case Teardown: E2E_system_setup_with_data_transfer_conducted

[1]General_SiSo_RU_lock_unlock
    [Timeout]   3h
    [Setup]   Case Setup: RU_lock_unlock
    Test_Case_General_SiSo_RU_lock_unlock
    [Teardown]   Case Teardown: RU_lock_unlock

[1]Manual_SiSo_CM_Recommissioning
    [Timeout]   3h
    [Setup]   Case Setup Steps: Manual_SiSo_CM_Recommissioning
    Manual_SiSo_CM_Recommissioning
    [Teardown]   Case Teardown Steps: Manual_SiSo_CM_Recommissioning

[1]OAM_KPI_61a_SiSo_Auto_BTS_site_reset_with_L3Call
    [Timeout]   10h
    [Setup]   Case Setup: Auto_BTS_site_reset_with_L3Call
    Test_Case_OAM_KPI_61a_SiSo_Auto_BTS_site_reset_with_L3Call
    [Teardown]   Case Teardown: Auto_BTS_site_reset_with_L3Call

[1]General_SiSo_RF_module_reset_from_GUI
    [Timeout]   3h
    [Setup]   Case Setup: RF_module_reset_from_GUI
    Test_Case_General_SiSo_RF_module_reset_from_GUI
    [Teardown]   Case Teardown: RF_module_reset_from_GUI

[1]General_SiSo_Online_Cell_Addition_Deletion
    [Timeout]   5h
    [Setup]   Case Setup: Test_Case_General_SiSo_Cells_Sectors_number_change_scenario
    Test_Case_General_SiSo_Cells_Sectors_number_change_scenario
    [Teardown]   Case Teardown: Test_Case_General_SiSo_Cells_Sectors_number_change_scenario

[1]General_SiSo_MPlane_Configurable_TDD_Frame_Structure_L3_Call
    [Timeout]   3h
    [Setup]   Case Setup: Test_Case_General_SiSo_MPlane_Configurable_TDD_Frame_Structure_L3_Call
    Test_Case_General_SiSo_MPlane_Configurable_TDD_Frame_Structure_L3_Call
    [Teardown]   Case Teardown: Test_Case_General_SiSo_MPlane_Configurable_TDD_Frame_Structure_L3_Call


[1]OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_with_L3Call
    [Setup]   Case Setup: Auto_RF_reset_success_rate_with_L3Call
    Test_Case_OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_with_L3Call
    [Teardown]   Case Teardown: Auto_RF_reset_success_rate_with_L3Call

[1]Test_Case_OAM_KPI_5G_reset_rat
    [Timeout]   10h
    [Setup]   Case Setup: OAM_KPI_5G_reset_rat
    Test_Case_OAM_KPI_5G_reset_rat
    [Teardown]   Case Teardown: OAM_KPI_5G_reset_rat
