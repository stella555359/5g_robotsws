*** Settings ***
Documentation
    ...    To verifiy CB012842 L3CALL case
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001821/CaseResource/SISO_Common_General_SiSo_Cell_lock_and_unlock.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001821/CaseResource/SISO_Common_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001821/CaseResource/SISO_Common_General_SiSo_E2E_system_setup_with_data_transfer_conducted.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001821/CaseResource/SISO_Common_OAM_KPI_61a_SiSo_Auto_BTS_site_reset.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001821/CaseResource/SISO_Common_General_SiSo_CM_Recommissioning.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001821/Resource/702.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001821/Resource/common.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009499/Resource/CB009499_common.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Suite Setup   AZNA Suite Setup Steps
Suite Teardown   AZNA Suite Teardown Steps

*** Variables ***
@{ALL_TEST_STATUS}
${scf_imported_need}  ${False}
${PREV_TEST_STATUS}
${configid}   T835_AZNA
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
${nrcall_cell_index}   11
${ltecall_cell_index}   11
${NR_L3call_UE}   ${0}
${LTE_L3call_UE}   ${0}
${cpe_lock}   ${false}
#L3 call amount info para#
${NRtput_expect_DL}   103
${NRtput_expect_uL}   23
${LTEtput_expect_DL}   100
${LTEtput_expect_uL}   10
${NR_Peak_Tput_DL_coeff}   1
${NR_Peak_Tput_UL_coeff}   1
${LTE_Peak_Tput_DL_coeff}   0.5
${LTE_Peak_Tput_UL_coeff}   0.5
${NR_L3call_Peak_Tput_DL_CM_Recom}   500
${NR_L3call_Peak_Tput_UL_CM_Recom}   49
${LTE_L3call_Peak_Tput_DL_CM_Recom}   50
${LTE_L3call_Peak_Tput_UL_CM_Recom}   5
${NR_Peak_Tput_DL_coeff_CM_Recom}   0.2
${NR_Peak_Tput_UL_coeff_CM_Recom}   0.2
${LTE_Peak_Tput_DL_coeff_CM_Recom}   0.2
${LTE_Peak_Tput_UL_coeff_CM_Recom}   0.2
${NR_Nor_Tput_DL_coeff}   0.3
${NR_Nor_Tput_UL_coeff}  0.3
${LTE_Nor_Tput_DL_coeff}  0.5
${LTE_Nor_Tput_UL_coeff}  0.5
${5G_DL_tput_deviation}   0.01
${5G_UL_tput_deviation}   0.01
${4G_DL_tput_deviation}   0.01
${4G_UL_tput_deviation}   0.01
${5G_min_percent}    0.2
${4G_min_percent}    0.2
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
CB013861_AZNA_L3call_CRT
    [Tags]   26R1
    [Timeout]   2h
    [Setup]  Case Setup: AZNA_CRT

    AlarmWatchdog.add_allow_alarms   fault_id=49
    Test_Case_AZNA_Data_Transfer_Conducted

    [Teardown]  Case Teardown: AZNA_CRT

*** Keywords ***
Test_Case_AZNA_Data_Transfer_Conducted
    [Arguments]   ${bip_enable}=${false}    ${traffic_stop}=${true}   ${duration}=${L3CALL_duration}   ${direction}=BOTH
    ...   ${CM_Call}=${false}   ${5G_call_celllock}=${true}   ${4G_call_celllock}=${true}
    ...   ${CM_peak}=${true}   ${Lock_peak}=${true}   ${Reset_peak}=${true}
    Log to console   AZNA_Data_Transfer_Conducted start
    Set Suite variable for L3 Call   CM_Call=${CM_Call}
    ${5Gtput_expect_DL}   Run Keyword If
    ...   ${CM_Call}==${true} and (${CM_peak}==${false} or ${Lock_peak}==${false} or ${Reset_peak}==${false})
    ...   Set peak number   before_number=${NR_L3call_Peak_Tput_DL_CM_Recom}   ratio=${NR_Nor_Tput_DL_coeff}
    ...   ELSE IF   ${CM_Call}==${false} and (${CM_peak}==${false} or ${Lock_peak}==${false} or ${Reset_peak}==${false})
    ...   Set peak number   before_number=${NRtput_expect_DL}   ratio=${NR_Nor_Tput_DL_coeff}
    ...   ELSE   set variable   ${5Gtput_expect_DL}
    ${5Gtput_expect_uL}   Run Keyword If
    ...   ${CM_Call}==${true} and (${CM_peak}==${false} or ${Lock_peak}==${false} or ${Reset_peak}==${false})
    ...   Set peak number   before_number=${NR_L3call_Peak_Tput_UL_CM_Recom}   ratio=${NR_Nor_Tput_UL_coeff}
    ...   ELSE IF   ${CM_Call}==${false} and (${CM_peak}==${false} or ${Lock_peak}==${false} or ${Reset_peak}==${false})
    ...   Set peak number   before_number=${NRtput_expect_uL}   ratio=${NR_Nor_Tput_UL_coeff}
    ...   ELSE   set variable   ${5Gtput_expect_uL}
    ${4Gtput_expect_DL}   Run Keyword If
    ...   ${CM_Call}==${true} and (${CM_peak}==${false} or ${Lock_peak}==${false} or ${Reset_peak}==${false})
    ...   Set peak number   before_number=${LTE_L3call_Peak_Tput_DL_CM_Recom}   ratio=${LTE_Nor_Tput_DL_coeff}
    ...   ELSE IF   ${CM_Call}==${false} and (${CM_peak}==${false} or ${Lock_peak}==${false} or ${Reset_peak}==${false})
    ...   Set peak number   before_number=${LTEtput_expect_DL}   ratio=${LTE_Nor_Tput_DL_coeff}
    ...   ELSE   set variable   ${4Gtput_expect_DL}
    ${4Gtput_expect_uL}   Run Keyword If
    ...   ${CM_Call}==${true} and (${CM_peak}==${false} or ${Lock_peak}==${false} or ${Reset_peak}==${false})
    ...   Set peak number   before_number=${LTE_L3call_Peak_Tput_UL_CM_Recom}   ratio=${LTE_Nor_Tput_UL_coeff}
    ...   ELSE IF   ${CM_Call}==${false} and (${CM_peak}==${false} or ${Lock_peak}==${false} or ${Reset_peak}==${false})
    ...   Set peak number   before_number=${LTEtput_expect_uL}   ratio=${LTE_Nor_Tput_UL_coeff}
    ...   ELSE   set variable   ${4Gtput_expect_uL}
    Get NR and LTE L3CALL Cell info
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${NR_L3call_UE}
    ${ue_lock}    set variable if   '${ue_type}'=='nokia_fastmile' and ${cpe_lock}   ${True}   ${False}
    Run Keyword If   ${NR_L3call_need}==${true} and ${5G_call_celllock}==${true}
    ...   Start NRcall   bip_enable=${bip_enable}   traffic_stop=${traffic_stop}   duration=${duration}   direction=${direction}
    ...    ue_lock=${ue_lock}   4G_operation=skip
    Run Keyword If   ${LTE_L3call_need}==${true} and ${4G_call_celllock}==${true}
    ...   Start LTEcall   bip_enable=${bip_enable}   traffic_stop=${traffic_stop}   duration=${duration}   direction=${direction}
    ...    ue_lock=${ue_lock}
    Log to console   AZNA_Data_Transfer_Conducted finish

    [Teardown]   NRcall Teardown   traffic_stop=${traffic_stop}


AZNA Suite Setup Steps
    Log To Console   AZNA Suite Setup
    robot_common_operations.Common Suite Setup
    Wait Until Keyword Succeeds   3x   30s   COAM commissioning if not onair
    AlarmWatchdog.add_allow_alarms   fault_id=${sas_faults_list}
    # COAM LOGIN
    # Run Keyword If    ${CBRS_chbw_change_Needed} and ${CBRS_PC_restart_needed}    Restart CBRS Service at Control PC

AZNA Suite Teardown Steps
    Log To Console   AZNA Suite Teardown
    robot_common_operations.Common Suite Teardown
    # Run Keyword and Ignore Error    COAM LOGOUT


Case Setup: AZNA_CRT
    robot_common_operations.Common Case Setup

    # COAM WEBUI Login   display=${${DEBUG}}
    # COAM WEBUI Whether Close Start Up View Window
    COAM Login
    ${is_cells_onair}   Run Keyword and Return Status   COAM Check all cells should be onair

    Log To Console   Check all cells should be onair result is ${is_cells_onair}
    Run Keyword If   ${scf_imported_need}==${true} or ${is_cells_onair}==${false}    ASOF Import Scf   feature=${configid}
    ${NR_ue_type}    translate_power_ue_type_from_testline    ue_index=${NR_L3call_UE}
    Set Suite Variable   ${NR_ue_type}
    Run Keyword and Ignore Error   Set Sanity Check to False
    Run Keyword and Ignore Error   Start BTS Log Collection


Case Teardown: AZNA_CRT
    Check Extra Reset From Blackbox
    # COAM WEBUI Whether Close Start Up View Window
    Run Keyword and Ignore Error   Run Keyword If   '${TEST_STATUS}' == 'FAIL'    Siso Common Save Logs
    # Run Keyword If    ${CBRS_chbw_change_Needed} and ${CBRS_PC_restart_needed}    Check CBRS If Cell Not Onair
    # Run Keyword If    ${CBRS_chbw_change_Needed} and ${CBRS_PC_restart_needed}    Download CBRS Log
    # Run Keyword and Ignore Error    COAM WEBUI Logout   display=${${DEBUG}}
    Run Keyword and Ignore Error   COAM Logout

    robot_common_operations.Common Case Teardown
    CI_interface.Common Case Teardown
