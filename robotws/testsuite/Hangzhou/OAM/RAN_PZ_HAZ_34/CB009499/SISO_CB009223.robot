*** Settings ***
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
${scf_imported_need}  ${false}
${PREV_TEST_STATUS}
${configid}   9223
#Askey L3call special para#
${COM_port}   7
${Askey_iperf_ul_cmd}   int
${AT_script_path}    C:tool
#L3 call basic require para#
${NR_L3call_need}   ${true}
${LTE_L3call_need}   ${true}
${L3call_peak}   ${true}
${CM_L3call_needed}   ${true}
${Lockcell_L3call_needed}   ${true}
${Reset_L3call_needed}   ${true}
${CM_L3call_peak_needed}   ${false}
${Lockcell_L3call_peak_needed}   ${false}
${Reset_L3call_peak_needed}   ${false}
${nrcall_cell_index}   1
${ltecall_cell_index}   1
${NR_L3call_UE}   ${1}
${LTE_L3call_UE}   ${0}
#L3 call amount info para#
${NRtput_expect_DL}   285
${NRtput_expect_uL}   37
${LTEtput_expect_DL}   285
${LTEtput_expect_uL}   12
${NR_Peak_Tput_DL_coeff}   0.9
${NR_Peak_Tput_UL_coeff}   0.8
${LTE_Peak_Tput_DL_coeff}   0.9
${LTE_Peak_Tput_UL_coeff}   0.9
${NR_L3call_Peak_Tput_DL_CM_Recom}   1550
${NR_L3call_Peak_Tput_UL_CM_Recom}   215
${LTE_L3call_Peak_Tput_DL_CM_Recom}   140
${LTE_L3call_Peak_Tput_UL_CM_Recom}   6
${NR_Peak_Tput_DL_coeff_CM_Recom}   0.1
${NR_Peak_Tput_UL_coeff_CM_Recom}   0.1
${LTE_Peak_Tput_DL_coeff_CM_Recom}   0.1
${LTE_Peak_Tput_UL_coeff_CM_Recom}   0.1
${NR_Nor_Tput_DL_coeff}   0.1
${NR_Nor_Tput_UL_coeff}  0.1
${LTE_Nor_Tput_DL_coeff}  0.8
${LTE_Nor_Tput_UL_coeff}  0.8
${4G_DL_tput_deviation}   0.6
${4G_UL_tput_deviation}   0.8
${5G_DL_tput_deviation}   0.95
${5G_UL_tput_deviation}   0.95
${5G_min_percent}    0.7
${4G_min_percent}    0.2
${check_tput_ignore_time}   30s
${L3CALL_duration}    180
#CBRS related
${CBRS_chbw_change_Needed}    ${false}
${CBRS_PC_restart_needed}    ${false}
${CBRS_PC_index}     ${1}
${CBRS_File_location}    /cygdrive/c/'New folder'/SASsim_trunk_CBRS_cert/SASsim_trunk_CBRS_cert/SASSim/
#CM commission para#
${NR_chBw_change_Needed}   ${false}
${NR_target_chBw}   100
${NR_target_reqMinNumPuschPrb}   253
${NR_target_cellBwpList_1}   7
${NR_target_cellBwpList_2}   77
${NR_prach_change_Needed}   ${true}
${NR_target_prachConfig}   92
${LTE_target_actDownSampling}   true
${LTE_chBw_change_Needed}   ${false}
${LTE_target_chBw}   10
${LTE_prach_change_Needed}   ${true}
${LTE_target_prachConfIndex}   4
#reset para#
${Reset_times_needed}   5
${Reset_times_without_HWF_needed}   20


*** Test Cases ***
[1]ASOF_9223_Collect_RFSW_logs_into_BTS_Snapshot
    [Timeout]  2h
    [Setup]  Run Keywords
    ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
    ...   Case Setup: ASOF_Collect_RFSW_logs_into_BTS_Snapshot
    Test_Case_ASOF_Collect_RFSW_logs_into_BTS_Snapshot
    [Teardown]  Case Teardown: ASOF_Collect_RFSW_logs_into_BTS_Snapshot

[1]ASOF_9223_CM_Recommissioning
    [Timeout]  2h
    [Setup]  Run Keywords
    ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
    ...   Case Setup: ASOF_CM_Recommissioning
    Test_Case_ASOF_CM_Recommissioning
    [Teardown]  Case Teardown: ASOF_CM_Recommissioning

[1]ASOF_9223_Cell_lock_and_unlock
    [Timeout]  3h
    [Setup]  Run Keywords
    ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
    ...   Case Setup Steps: ASOF_Cell_lock_and_unlock
    Test_Case_ASOF_Cell_lock_and_unlock
    [Teardown]  Case Teardown Steps: ASOF_Cell_lock_and_unlock

[1]ASOF_9223_BTS_Site_Reset
    [Timeout]  5h
    [Setup]  Run Keywords
    ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
    ...   Case Setup: ASOF_BTS_Site_Reset
    Test_Case_ASOF_BTS_Site_Reset
    [Teardown]  Case Teardown: ASOF_BTS_Site_Reset

[1]ASOF_9223_E2E_system_setup_with_data_transfer
    [Timeout]  2h
    [Setup]  Run Keywords
    ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
    ...   Case Setup: ASOF_E2E_system_setup_with_data_transfer
    Test_Case_ASOF_Data_Transfer_Conducted
    [Teardown]  Case Teardown: ASOF_E2E_system_setup_with_data_transfer

[1]ASOF_9223_BTS_Site_Reset_without_HWF_without_L3call
    [Timeout]  15h
    [Setup]  Run Keywords
    ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
    ...   Case Setup: ASOF_BTS_Site_Reset_without_HWF_without_L3call
    Test_Case_ASOF_BTS_Site_Reset_without_HWF_without_L3call
    [Teardown]  Case Teardown: ASOF_BTS_Site_Reset_without_HWF_without_L3call

[1]CB009223_case_regression_summary
    [Tags]   24R1
    [Setup]  Case Setup: ASOF_CRT
    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
    List Should Not Contain Value   ${ALL_TEST_STATUS}   FAIL
    [Teardown]  Case Teardown: ASOF_CRT

