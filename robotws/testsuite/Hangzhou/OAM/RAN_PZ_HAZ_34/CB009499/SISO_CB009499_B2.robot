*** Settings ***
Documentation
    ...    Author: ruiyu.han@nokia-sbell.com
    ...    to define SG07 COMMON SISO Case
    ...    feature : CB009499

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
${configid}   T93_9499_B2
#Askey L3call special para#
${COM_port}   28
${Askey_iperf_ul_cmd}   int
${AT_script_path}    C:tool
#L3 call basic require para#
${NR_L3call_need}   ${false}
${LTE_L3call_need}   ${true}
${L3call_peak}   ${true}
${CM_L3call_needed}   ${true}
${Lockcell_L3call_needed}   ${true}
${Reset_L3call_needed}   ${true}
${CM_L3call_peak_needed}   ${true}
${Lockcell_L3call_peak_needed}   ${true}
${Reset_L3call_peak_needed}   ${true}
${nrcall_cell_index}   1
${ltecall_cell_index}   1
${NR_L3call_UE}   ${3}
${LTE_L3call_UE}   ${3}
#L3 call amount info para#
#LTE chbw from 20M to 10M
${NRtput_expect_DL}   575
${NRtput_expect_uL}   72
${LTEtput_expect_DL}   280
${LTEtput_expect_uL}   12
${NR_Peak_Tput_DL_coeff}   0.9
${NR_Peak_Tput_UL_coeff}   0.9
${LTE_Peak_Tput_DL_coeff}   0.9
${LTE_Peak_Tput_UL_coeff}   0.9
${NR_L3call_Peak_Tput_DL_CM_Recom}   280
${NR_L3call_Peak_Tput_UL_CM_Recom}   34
${LTE_L3call_Peak_Tput_DL_CM_Recom}   140
${LTE_L3call_Peak_Tput_UL_CM_Recom}   5
${NR_Peak_Tput_DL_coeff_CM_Recom}   0.9
${NR_Peak_Tput_UL_coeff_CM_Recom}   0.9
${LTE_Peak_Tput_DL_coeff_CM_Recom}   0.9
${LTE_Peak_Tput_UL_coeff_CM_Recom}   0.9
${NR_Nor_Tput_DL_coeff}   0.1
${NR_Nor_Tput_UL_coeff}  0.1
${LTE_Nor_Tput_DL_coeff}  0.5
${LTE_Nor_Tput_UL_coeff}  0.5
${5G_DL_tput_deviation}   0.01
${5G_UL_tput_deviation}   0.01
${4G_DL_tput_deviation}   0.01
${4G_UL_tput_deviation}   0.01
${5G_min_percent}    0.7
${4G_min_percent}    0.2
${check_tput_ignore_time}   30s
${L3CALL_duration}    180
#CBRS related
${CBRS_chbw_change_Needed}    ${true}
${CBRS_PC_restart_needed}    ${true}
${CBRS_PC_index}     ${0}
${CBRS_File_location}    /cygdrive/c/CBRS_Server/SASsim_trunk_CBRS_cert/SASsim_trunk_CBRS_cert/SASSim/
#CM commission para#
${NR_chBw_change_Needed}   ${false}
${NR_target_chBw}   20
${NR_target_reqMinNumPuschPrb}   38
${NR_target_cellBwpList_1}   7
${NR_target_cellBwpList_2}   20
${NR_prach_change_Needed}   ${false}
${NR_target_prachConfig}   194
${LTE_chBw_change_Needed}   ${true}
${LTE_target_chBw}   10
${LTE_target_actDownSampling}   true
${LTE_prach_change_Needed}   ${true}
${LTE_target_prachConfIndex}   4
#reset para#
${Reset_times_needed}   5
${Reset_times_without_HWF_needed}   10
@{sas_faults_list}    6823   6824   6825   6826   6827   6828   6829   6830   6831   6832   6833


*** Test Cases ***
[1]CB009499_B2_LTE_3S_4CC_CRT
   [Tags]   24R1
   [Setup]  Case Setup: ASOF_CRT
   AlarmWatchdog.add_allow_alarms    fault_id=${sas_faults_list}
   AlarmWatchdog.add_allow_alarms    fault_id=49
#   run keyword and continue on failure   ASOF_Collect_RFSW_logs_into_BTS_Snapshot
#   run keyword and continue on failure   ASOF_E2E_system_setup_with_data_transfer
   run keyword and continue on failure   ASOF_CM_Recommissioning
#   run keyword and continue on failure   ASOF_Cell_lock_and_unlock
#   run keyword and continue on failure   ASOF_BTS_Site_Reset
#   run keyword and continue on failure   ASOF_BTS_Site_Reset_without_HWF_without_L3call
   [Teardown]  Case Teardown: ASOF_CRT