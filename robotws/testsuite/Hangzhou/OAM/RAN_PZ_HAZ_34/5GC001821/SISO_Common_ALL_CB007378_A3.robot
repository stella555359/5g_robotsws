*** Settings ***
Resource   ./CaseResource/SISO_Common_General_SiSo_Cell_lock_and_unlock.robot
Resource   ./CaseResource/SISO_Common_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Resource   ./CaseResource/SISO_Common_General_SiSo_Commissioning_BTS_Template_Commissioning.robot
Resource   ./CaseResource/SISO_Common_General_SiSo_E2E_system_setup_with_data_transfer_conducted.robot
Resource   ./CaseResource/SISO_Common_General_SiSo_RU_lock_unlock.robot
Resource   ./CaseResource/SISO_Common_OAM_KPI_61a_SiSo_Auto_BTS_site_reset.robot
Resource   ./CaseResource/SISO_Common_OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_WebUI_with_L3Call.robot
Resource   ./CaseResource/SISO_Common_General_SiSo_Cells_Sectors_number_change_scenario.robot
Resource   ./CaseResource/SISO_Common_General_SiSo_RF_module_power_reset.robot
Suite Setup   Suite Setup Steps
Suite Teardown   Suite Teardown Steps

*** Variables ***
${BTS_ID}   ${tl.gnbs[0].instance_id}
@{nsa_btsid_list}    10565
${reset_times}   10

*** Test Cases ***
[1]General_SiSo_E2E_system_setup_with_data_transfer_conducted
    [Timeout]   3h
    [Setup]   Case Setup: E2E_system_setup_with_data_transfer_conducted
    Test_Case_General_SiSo_E2E_system_setup_with_data_transfer_conducted
    [Teardown]   Case Teardown: E2E_system_setup_with_data_transfer_conducted


