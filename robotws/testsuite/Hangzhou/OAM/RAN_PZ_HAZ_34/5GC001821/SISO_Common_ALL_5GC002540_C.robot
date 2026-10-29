# *** Settings ***
# Resource   ./CaseResource/SISO_Common_General_SiSo_Cell_lock_and_unlock.robot
# Resource   ./CaseResource/SISO_Common_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
# Resource   ./CaseResource/SISO_Common_General_SiSo_Commissioning_BTS_Template_Commissioning.robot
# Resource   ./CaseResource/SISO_Common_General_SiSo_E2E_system_setup_with_data_transfer_conducted.robot
# Resource   ./CaseResource/SISO_Common_General_SiSo_RU_lock_unlock.robot
# Resource   ./CaseResource/SISO_Common_OAM_KPI_61a_SiSo_Auto_BTS_site_reset.robot
# Resource   ./CaseResource/SISO_Common_OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_WebUI_with_L3Call.robot
# 
# Suite Setup   Suite Setup Steps
# Suite Teardown   Suite Teardown Steps
# 
# *** Variables ***
# @{nsa_btsid_list}    10565
# ${reset_times}   2
# ${BTS_ID}   ${tl.gnbs[0].instance_id}
# 
# *** Test Cases ***
# [1]General_SiSo_E2E_system_setup_with_data_transfer_conducted
#     [Timeout]   2h
#     [Setup]   Case Setup: E2E_system_setup_with_data_transfer_conducted
#     Test_Case_General_SiSo_E2E_system_setup_with_data_transfer_conducted
#     [Teardown]   Case Teardown: E2E_system_setup_with_data_transfer_conducted
# 
# [1]General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#     [Timeout]   2h
#     [Setup]   Case Setup: Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#     Test_Case_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#     [Teardown]   Case Teardown: Collect_RFSW_logs_from_RU_into_BTS_Snapshot
# 
# [1]General_SiSo_Cell_lock_and_unlock
#     [Timeout]   2h
#     [Setup]   Case Setup: Cell_lock_and_unlock
#     Test_Case_General_SiSo_Cell_lock_and_unlock
#     [Teardown]   Case Teardown: Cell_lock_and_unlock
# 
# [1]General_SiSo_RU_lock_unlock
#     [Timeout]   2h
#     [Setup]   Case Setup: RU_lock_unlock
#     Test_Case_General_SiSo_RU_lock_unlock
#     [Teardown]   Case Teardown: RU_lock_unlock
# 
# [1]OAM_KPI_61a_SiSo_Auto_BTS_site_reset_with_L3Call
#     [Setup]   Case Setup: Auto_BTS_site_reset_with_L3Call
#     Test_Case_OAM_KPI_61a_SiSo_Auto_BTS_site_reset_with_L3Call
#     [Teardown]   Case Teardown: Auto_BTS_site_reset_with_L3Call
# 
# [1]OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_with_L3Call
#     [Setup]   Case Setup: Auto_RF_reset_success_rate_with_L3Call
#     Test_Case_OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_with_L3Call
#     [Teardown]   Case Teardown: Auto_RF_reset_success_rate_with_L3Call
# 
# # [1]General_SiSo_Commissioning_BTS_Template_Commissioning
# #     [Setup]   Case Setup: Commissioning_BTS_Template_Commissioning
# #     Test_Case_General_SiSo_Commissioning_BTS_Template_Commissioning
# #     [Teardown]   Case Teardown: Commissioning_BTS_Template_Commissioning
