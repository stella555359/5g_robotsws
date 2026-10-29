*** Settings ***
Documentation
    ...    To verifiy CB009565 L3CALL case
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001821/CaseResource/SISO_Common_General_SiSo_Cell_lock_and_unlock.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001821/CaseResource/SISO_Common_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001821/CaseResource/SISO_Common_General_SiSo_E2E_system_setup_with_data_transfer_conducted.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001821/CaseResource/SISO_Common_OAM_KPI_61a_SiSo_Auto_BTS_site_reset.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001821/CaseResource/SISO_Common_General_SiSo_CM_Recommissioning.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001821/Resource/702.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001821/Resource/common.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009499/Resource/CB009499_common.robot
Suite Setup   ASOF Suite Setup Steps
Suite Teardown   ASOF Suite Teardown Steps

*** Variables ***
@{ALL_TEST_STATUS}
${scf_imported_need}  ${true}
${PREV_TEST_STATUS}
${configid}   AVQF
#Askey L3call special para#
${COM_port}   6
${Askey_iperf_ul_cmd}   ext
${AT_script_path}    C:/tool
#L3 call basic require para#
${NR_L3call_need}   ${true}
${LTE_L3call_need}   ${false}
${L3call_peak}   ${true}
${CM_L3call_needed}   ${false}
${Lockcell_L3call_needed}   ${true}
${Reset_L3call_needed}   ${false}
${CM_L3call_peak_needed}   ${false}
${Lockcell_L3call_peak_needed}   ${false}
${Reset_L3call_peak_needed}   ${false}
${nrcall_cell_index}   1
${ltecall_cell_index}   1
${NR_L3call_UE}   ${0}
${LTE_L3call_UE}   ${0}
#L3 call amount info para#
${NRtput_expect_DL}   1000
${NRtput_expect_uL}   150
${LTEtput_expect_DL}   1
${LTEtput_expect_uL}   1
${NR_Peak_Tput_DL_coeff}   0.1
${NR_Peak_Tput_UL_coeff}   0.01
${LTE_Peak_Tput_DL_coeff}   0.02
${LTE_Peak_Tput_UL_coeff}   0.02
${NR_L3call_Peak_Tput_DL_CM_Recom}   750
${NR_L3call_Peak_Tput_UL_CM_Recom}   90
${LTE_L3call_Peak_Tput_DL_CM_Recom}   1
${LTE_L3call_Peak_Tput_UL_CM_Recom}   1
${NR_Peak_Tput_DL_coeff_CM_Recom}   0.2
${NR_Peak_Tput_UL_coeff_CM_Recom}   0.2
${LTE_Peak_Tput_DL_coeff_CM_Recom}   0.02
${LTE_Peak_Tput_UL_coeff_CM_Recom}   0.02
${NR_Nor_Tput_DL_coeff}   0.1
${NR_Nor_Tput_UL_coeff}  0.1
${LTE_Nor_Tput_DL_coeff}  0.01
${LTE_Nor_Tput_UL_coeff}  0.01
${5G_DL_tput_deviation}   0.01
${5G_UL_tput_deviation}   0.01
${4G_DL_tput_deviation}   0.01
${4G_UL_tput_deviation}   0.01
${5G_min_percent}    0.0
${4G_min_percent}    0.0
${check_tput_ignore_time}   60s
${L3CALL_duration}    240
#CBRS related
${CBRS_chbw_change_Needed}    ${false}
${CBRS_PC_restart_needed}    ${false}
${CBRS_PC_index}     ${1}
${CBRS_File_location}    /cygdrive/c/CBRS_Server/SASsim_trunk_CBRS_cert/SASsim_trunk_CBRS_cert/SASSim/
#CM commission para#
${NR_chBw_change_Needed}   ${false}
${NR_target_chBw}   38
${NR_target_reqMinNumPuschPrb}   38
${NR_target_cellBwpList_1}   7
${NR_target_cellBwpList_2}   20
${NR_prach_change_Needed}   ${false}
${NR_target_prachConfig}   151
${LTE_chBw_change_Needed}   ${false}
${LTE_target_chBw}   10
${LTE_target_actDownSampling}   true
${LTE_prach_change_Needed}   ${false}
${LTE_target_prachConfIndex}   4
#reset para#
${Reset_times_needed}   5
${Reset_times_without_HWF_needed}   50


*** Test Cases ***
CB009565_AVQF_L3call_CRT
   [Tags]   25R2
   [Setup]  Case Setup: ASOF_CRT
   run keyword and continue on failure   AVQF_E2E_system_setup_with_data_transfer
#   run keyword and continue on failure   AVQF_Cell_lock_and_unlock
   [Teardown]  Case Teardown: ASOF_CRT

*** Keywords ***
AVQF_E2E_system_setup_with_data_transfer
   [Timeout]  2h
   Case Setup: ASOF_E2E_system_setup_with_data_transfer
   AlarmWatchdog.add_allow_alarms    fault_id=49
   Test_Case_ASOF_Data_Transfer_Conducted
   [Teardown]  Case Teardown: ASOF_E2E_system_setup_with_data_transfer

AVQF_Cell_lock_and_unlock
   [Timeout]  3h
   Case Setup Steps: ASOF_Cell_lock_and_unlock
   AlarmWatchdog.add_allow_alarms    fault_id=49
   Test_Case_ASOF_Cell_lock_and_unlock
   [Teardown]  Case Teardown Steps: ASOF_Cell_lock_and_unlock