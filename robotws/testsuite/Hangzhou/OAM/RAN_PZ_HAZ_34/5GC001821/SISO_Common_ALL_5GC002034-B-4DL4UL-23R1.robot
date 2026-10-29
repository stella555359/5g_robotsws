# *** Settings ***
# Resource   ./CaseResource/SISO_Common_General_SiSo_Cell_lock_and_unlock.robot
# Resource   ./CaseResource/SISO_Common_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
# Resource   ./CaseResource/SISO_Common_General_SiSo_Commissioning_BTS_Template_Commissioning.robot
# Resource   ./CaseResource/SISO_Common_General_SiSo_E2E_system_setup_with_data_transfer_conducted.robot
# Resource   ./CaseResource/SISO_Common_General_SiSo_RU_lock_unlock.robot
# Resource   ./CaseResource/SISO_Common_OAM_KPI_61a_SiSo_Auto_BTS_site_reset.robot
# Resource   ./CaseResource/SISO_Common_OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_WebUI_with_L3Call.robot
# Resource   ./CaseResource/SISO_Common_General_SiSo_CM_Recommissioning.robot
# Suite Setup   Suite Setup Steps For 2034B
# Suite Teardown   Suite Teardown Steps
# 
# *** Variables ***
# @{nsa_btsid_list}    10565
# ${reset_times}   10
# ${BTS_ID}   ${tl.gnbs[0].instance_id}
# ${instance_id}   ${tl.gnbs[0].instance_id}
# ${testline_name}   7_5_UTE5G402T088
# 
# *** Test Cases ***
# [1]5GC000702_commission_configuration_4DL
#     [Timeout]   2h
#     [Setup]     Case Setup for 842
#     wait until keyword succeeds   5x   10s    Import SCF by Custom for 842
#     ...   local_path=${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_${scfname}_4DL4UL.xml
#     [Teardown]   Case Teardown for 842
# 
# [3]General_SiSo_E2E_system_setup_with_data_transfer_conducted
#     [Timeout]   3h
#     [Setup]   Case Setup: E2E_system_setup_with_data_transfer_conducted
#     Test_Case_General_SiSo_E2E_system_setup_with_data_transfer_conducted
#     [Teardown]   Case Teardown: E2E_system_setup_with_data_transfer_conducted
# 
# [4][2.0] Manual_SiSo_CM_Recommissioning
#     [Timeout]   3h
#     [Setup]   Case Setup Steps: Manual_SiSo_CM_Recommissioning
#     Manual_SiSo_CM_Recommissioning
#     [Teardown]   Case Teardown Steps: Manual_SiSo_CM_Recommissioning
