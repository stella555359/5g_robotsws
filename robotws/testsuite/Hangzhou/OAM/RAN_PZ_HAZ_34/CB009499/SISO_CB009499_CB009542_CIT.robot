*** Settings ***
Documentation
    ...    Author: ruiyu.han@nokia-sbell.com
    ...    to define SG07 COMMON SISO Case
    ...    feature : CB009499-CB009542

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
${scf_imported_need}  ${True}
${PREV_TEST_STATUS}
${configid}   T099_9499_F2
#Askey L3call special para#
${COM_port}   6
${Askey_iperf_ul_cmd}   ext
${AT_script_path}    C:/tool
#L3 call basic require para#
${NR_L3call_need}   ${true}
${LTE_L3call_need}   ${false}
${L3call_peak}   ${true}
${CM_L3call_needed}   ${true}
${Lockcell_L3call_needed}   ${true}
${Reset_L3call_needed}   ${true}
${CM_L3call_peak_needed}   ${true}
${Lockcell_L3call_peak_needed}   ${true}
${Reset_L3call_peak_needed}   ${true}
${nrcall_cell_index}   1
${ltecall_cell_index}   1
${NR_L3call_UE}   ${0}
${LTE_L3call_UE}   ${0}
#L3 call amount info para#
${NRtput_expect_DL}   1600
${NRtput_expect_uL}   210
${LTEtput_expect_DL}   285
${LTEtput_expect_uL}   12
${NR_Peak_Tput_DL_coeff}   0.2
${NR_Peak_Tput_UL_coeff}   0.2
${LTE_Peak_Tput_DL_coeff}   0.5
${LTE_Peak_Tput_UL_coeff}   0.5
${NR_L3call_Peak_Tput_DL_CM_Recom}   290
${NR_L3call_Peak_Tput_UL_CM_Recom}   34
${LTE_L3call_Peak_Tput_DL_CM_Recom}   140
${LTE_L3call_Peak_Tput_UL_CM_Recom}   6
${NR_Peak_Tput_DL_coeff_CM_Recom}   0.2
${NR_Peak_Tput_UL_coeff_CM_Recom}   0.2
${LTE_Peak_Tput_DL_coeff_CM_Recom}   0.5
${LTE_Peak_Tput_UL_coeff_CM_Recom}   0.5
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
${check_tput_ignore_time}   60s
${L3CALL_duration}    240
#CBRS related
${CBRS_chbw_change_Needed}    ${false}
${CBRS_PC_restart_needed}    ${false}
${CBRS_PC_index}     ${1}
${CBRS_File_location}    /cygdrive/c/CBRS_Server/SASsim_trunk_CBRS_cert/SASsim_trunk_CBRS_cert/SASSim/
#CM commission para#
${NR_chBw_change_Needed}   ${true}
${NR_target_chBw}   20
${NR_target_reqMinNumPuschPrb}   38
${NR_target_cellBwpList_1}   7
${NR_target_cellBwpList_2}   20
${NR_prach_change_Needed}   ${true}
${NR_target_prachConfig}   151
${LTE_chBw_change_Needed}   ${false}
${LTE_target_chBw}   10
${LTE_target_actDownSampling}   true
${LTE_prach_change_Needed}   ${false}
${LTE_target_prachConfIndex}   4
#reset para#
${Reset_times_needed}   5
${Reset_times_without_HWF_needed}   50
@{sas_faults_list}    6823   6824   6825   6826   6827   6828   6829   6830   6831   6832   6833


*** Test Cases ***
[1]CB009499_CB009542_CIT
   [Timeout]  2h
   [Setup]  Run Keywords
   ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
   ...   Case Setup: ASOF_CM_Recommissioning
   CIT Check Point 1 Lock RU1 check cells
   CIT Check Point 2 Reset RU1 check cells
   CIT Check Point 3 Block Cell1 check cells
   CIT Check Point 4 Reset Cell1 check cells
   AlarmWatchdog.add_allow_alarms    fault_id=${sas_faults_list}
   AlarmWatchdog.add_allow_alarms    fault_id=49
   Test_Case_ASOF_CM_Recommissioning

   [Teardown]  Case Teardown: ASOF_CM_Recommissioning