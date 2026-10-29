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
Resource   ./CaseResource/SISO_Common_General_SiSo_CM_Recommissioning.robot
Resource   ./CaseResource/SISO_Common_General_SiSo_RF_module_reset_from_GUI.robot
Suite Setup   Suite Setup Steps
Suite Teardown   Suite Teardown Steps

*** Variables ***
@{nsa_btsid_list}    10565
${reset_times}   10
${BTS_ID}   ${tl.gnbs[0].instance_id}

*** Test Cases ***
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

[1]General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Timeout]   3h
     [Setup]   Case Setup: Collect_RFSW_logs_from_RU_into_BTS_Snapshot
     Test_Case_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
     [Teardown]   Case Teardown: Collect_RFSW_logs_from_RU_into_BTS_Snapshot

[1]General_SiSo_RF_module_reset_from_GUI
    [Timeout]   3h
    [Setup]   Case Setup: RF_module_reset_from_GUI
    Test_Case_General_SiSo_RF_module_reset_from_GUI
    [Teardown]   Case Teardown: RF_module_reset_from_GUI

[1]General_SiSo_Auto_RF_module_power_reset
    [Timeout]   3h
    [Setup]   Case Setup: Test_Case_General_SiSo_RF_module_power_reset
    Test_Case_General_SiSo_RF_module_power_reset
    [Teardown]   Case Teardown: Test_Case_General_SiSo_RF_module_power_reset

# [1]General_SiSo_Commissioning_BTS_Template_Commissioning
#     [Setup]   Case Setup: Commissioning_BTS_Template_Commissioning
#     Test_Case_General_SiSo_Commissioning_BTS_Template_Commissioning
#     [Teardown]   Case Teardown: Commissioning_BTS_Template_Commissioning

# [1]OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_with_L3Call
#     [Setup]   Case Setup: Auto_RF_reset_success_rate_with_L3Call
#     Test_Case_OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_with_L3Call
#     [Teardown]   Case Teardown: Auto_RF_reset_success_rate_with_L3Call
