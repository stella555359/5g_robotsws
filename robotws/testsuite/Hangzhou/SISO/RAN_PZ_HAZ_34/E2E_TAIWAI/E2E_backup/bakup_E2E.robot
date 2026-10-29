# *** Settings ***
# Suite Setup       Run Keywords  SISO Coam Suite Setup  AND   Run Keyword And Ignore Error   Get Mapping Info With ScoutName And TestLine
# Suite Teardown        SISO Coam Suite Teardown
# Test Timeout         1200 min
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
# Resource    ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_lock_and_unlock_gNB.robot
# Resource    ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot
# Resource    ${BASIC_PATH_5G}/E2E_SiSo_RU_lock_and_unlock_gNB.robot
# Resource    ${BASIC_PATH_5G}/Baseband_module_reset_via_WEBUI.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_power_reset.robot
# Resource    ${BASIC_PATH_5G}/RF/General_SiSo_Beamforming_calibration.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
# Resource    ${BASIC_PATH_5G}/General_Stability_Test_Case.robot
# Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_via_admin.robot
# Resource    ${BASIC_PATH_5G}/BTS/Capture_snapshot_during_tracffic.robot
# Resource    ${BASIC_PATH_5G}/E2E_SiSo_RAT_block_unblock_via_WEBUI.robot
# Resource    taf/rfrl/uuf4all/resources/robot/uuf_rfrl_common_keywords.robot
# Resource    ../Resource/e2e_common_cases.robot
# Resource    ../Resource/e2e_step_keywords.robot
# Resource    ../Resource/e2e_oam_kpi_keywords.robot
# Resource    taf/rfrl/uuf4all/uuf4all_test_cases.robot
# Variables   ../TestData/E2E_variables.py
# 
# 
# Documentation
# ...    Author: tingting zhong
# ...    Contact: tingting.zhong@nokia-sbell.com
# ...    squad group:SG_04
# ...    Feature E2E TWM
# 
# Force Tags            5G_RAN_TDD    STATE_GNB_COMMISSIONED
# ...   PY36
# 
# *** Variables ***
# ${if_commissioning}             True
# ${if_teardown_commissioning}    False
# ${rf_reset_total_times}         ${20}
# ${rf_reset_pass_times}          ${20}
# ${runs_of_cell_lock}         ${10}
# ${runs_of_cell_block}         ${10}
# ${commission_times}          ${30}
# ${runs_of_delt_commision}         ${10}
# ${runs_of_bbmd_reset}         ${10}
# ${runs_of_rf_reset}         ${20}
# ${target_version}       SBTS00_ENB_9999_230824_000011
# ${restore_to_target_sw}    True
# @{critical_faults}       10    16    1806    1868    4341    4352    4383
# @{customers}             Taiwan Mobile
# @{custom_alarms}     4293   62003   61074   7509
# ${remote_node_update}   False
# ${is_enb_test}     False
# ${should_be_reported}       True
# #${L3_CALL}   ${None}
# ${L3_CALL}   Make Call With All UE
# ${disable_syslog_check}   True
# ${common_web_service_hz}    http://10.135.157.75:8081/artifactory/mn5gran_hzlog-local
# ${qc_domain}=                   MN_RAN_ST
# ${qc_id}=                      ${None}  # SHOULD BE DIFFERENT FOR EACH TEST CASE ACCORDING TO QC_ID OF EACH TEST
# ${qc_project}=                  RAN_ST
# ${LABEL}=                       ${None}
# 
# *** Test Cases ***
# [1]E2E_SiSo_Single_UE_L3call_peak_at_first
#     [Setup]  SISO Coam Test Setup
#     ${gnb_len}    get length    ${tl.gnbs}
#     :FOR    ${gnb_index}    IN RANGE    ${gnb_len}
#         run keyword if    ${gnb_index}!=0    run keywords    SISO Coam Suite Setup    gnb_index=${gnb_index}    AND
#         ...    SISO Coam Test Setup    gnb_index=${gnb_index}
#         ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
#         run keyword and continue on failure    Make Call with all ue attached RU    connection=${connection}
#         run keyword and continue on failure    CI_commssion.common commissioning    gnb_index=${gnb_index}
#         run keyword if    ${gnb_index}!=0    run keywords    SISO Coam Test Teardown    gnb_index=${gnb_index}
#         ...    is_case_teardown=${False}        AND
#         ...    SISO Coam Suite Teardown    gnb_index=${gnb_index}
#     END
#     [Teardown]   SISO Coam Test Teardown
# 
# [1]E2E_01_SiSo_Delta_Commissioning_With_Online_Parameter_Modification_and_L3Call
#     [Setup]  SISO Coam Test Setup
#     #run keyword and continue on failure    CI_commssion.common commissioning
#     Delta_Commissioning_With_Given_Parameter    with_peak=${True}
#     [Teardown]   SISO Coam Test Teardown
# 
# [1]E2E_SiSo_Cell_lock_and_unlock_gNB
#     [Setup]    UUF4ALL NR Test Setup
#     ${TEST_NAME}   Set Variable   [1]e2e_tl_cell_lock_unlock_nr_with_oam_kpi
#     Set Global Variable   ${TEST_NAME}
#     OAM_NRCEL_LOCK
#     ...    test_iteration=${runs_of_cell_lock}
#     ...    critical_faults=@{critical_faults}
#     ...    customers_list=${customers}
#     ...    custom_alarms=@{custom_alarms}
#     ...    use_remote_node=${is_enb_test}
#     ...    should_be_reported=${should_be_reported}
#     ...    attach_test_keyword=${L3_CALL}
#     ...    disable_syslog_check=${disable_syslog_check}
#     ...    qc_domain=${qc_domain}
#     ...    qc_id=${qc_id}
#     ...    qc_project=${qc_project}
#     ...    label=${LABEL}
#     [Teardown]   UUF4ALL NR Test Teardown
# 
# [1]E2E_SiSo_Cell_block_and_unblock_gNB
#     [Setup]    UUF4ALL NR Test Setup
#     ${TEST_NAME}   Set Variable   [1]e2e_tl_cell_block_unblock_nr_with_oam_kpi
#     Set Global Variable   ${TEST_NAME}
#     OAM_NRCEL_BLOCK
#     ...    test_iteration=${runs_of_cell_block}
#     ...    critical_faults=@{critical_faults}
#     ...    customers_list=${customers}
#     ...    custom_alarms=@{custom_alarms}
#     ...    use_remote_node=${is_enb_test}
#     ...    should_be_reported=${should_be_reported}
#     ...    attach_test_keyword=${L3_CALL}
#     ...    disable_syslog_check=${disable_syslog_check}
#     ...    qc_domain=${qc_domain}
#     ...    qc_id=${qc_id}
#     ...    qc_project=${qc_project}
#     ...    label=${LABEL}
#     [Teardown]    UUF4ALL NR Test Teardown
# 
# [1]E2E_SiSo_RU_lock_and_unlock_gNB
#     [Setup]  SISO Coam Test Setup
#     E2E_SiSo_RU_lock_and_unlock_gNB    with_call=${True}    with_peak=${True}    call_duration=${300}
#     [Teardown]   SISO Coam Test Teardown
# 
# [1]E2E_SiSo_BBMOD_module_reset_from_GUI_L3call
#     [Setup]    UUF4ALL NR Test Setup
#     ${TEST_NAME}   Set Variable   [1]e2e_tl_capacity_module_reset_with_oam_kpi
#     Set Global Variable   ${TEST_NAME}
#     OAM_BBMOD_RESET
#     ...    test_iteration=${runs_of_bbmd_reset}
#     ...    critical_faults=@{critical_faults}
#     ...    customers_list=${customers}
#     ...    custom_alarms=@{custom_alarms}
#     ...    use_remote_node=${is_enb_test}
#     ...    should_be_reported=${should_be_reported}
#     ...    attach_test_keyword=${L3_CALL}
#     ...    disable_syslog_check=${disable_syslog_check}
#     [Teardown]    UUF4ALL NR Test Teardown
# 
# [1]E2E_SiSo_Beamforming_calibration
#     [Setup]  SISO Coam Test Setup
#     general_siso_beamforming_calibration
#     [Teardown]   SISO Coam Test Teardown
# 
# [1]E2E_SiSo_Single_UE_L3call_peak_NSA_60Mhz_1070_A3
#     [Setup]  SISO Coam Test Setup
#     ${ru_index_list}  Get All RU Index
#     FOR  ${ru_index}  IN  @{ru_index_list}
#         ${cell_list}    Get All Cell Id    ${ru_index}
#         Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${True}    duration=${600}
#     END
#     [Teardown]   SISO Coam Test Teardown
# 
# [1]E2E_11_OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_webem_with_L3Call
#     [Setup]    UUF4ALL NR Test Setup
#     ${TEST_NAME}   Set Variable   [1]e2e_tl_ru_reset_with_oam_kpi
#     Set Global Variable   ${TEST_NAME}
#     OAM_RMOD_RESET
#     ...    test_iteration=${runs_of_rf_reset}
#     ...    critical_faults=@{critical_faults}
#     ...    customers_list=${customers}
#     ...    custom_alarms=@{custom_alarms}
#     ...    use_remote_node=${is_enb_test}
#     ...    should_be_reported=${should_be_reported}
#     ...    attach_test_keyword=${L3_CALL}
#     ...    disable_syslog_check=${disable_syslog_check}
#     [Teardown]    UUF4ALL NR Test Teardown
# 
# [1]E2E_12_SiSo_Radio_memory_verification_by_capturing_snapshot_during_L3call
#     [Setup]   SISO Coam Test Setup
#     Capture_snapshot_during_tracffic
#     [Teardown]   SISO Coam Test Teardown
# 
# [1]E2E_13_Timing_offset_online_activation_and_modification_L3call
#     [Setup]   SISO Coam Test Setup
#     Timing_offset_online_activation_and_modification_L3call
#     [Teardown]  run keywords    SISO Coam Test Teardown    perform_case_scf=${True}    AND    SISO Coam Suite Teardown
# 
# 
# [1]E2E_14_SiSo_Delta_Commissioning_With_Rat_Reset_and_L3Call
#     [Setup]  SISO Coam Test Setup
#     ${TEST_NAME}   Set Variable   [1]e2e_tl_delta_commissioning_with_nr_rat_reset
#     Set Global Variable   ${TEST_NAME}
#     ${delta_file}   Get_DeltaFile_With_Modify_Parameter  connection=GNB_OAM   dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
#     ...   filter_parameter=Activate Multiple VLAN interfaces   pattern=actMultVlan
#     DELTA_COMMISSIONING_WITH_NR_RAT_RESET
#     ...          test_iteration=${runs_of_delt_commision}
#     ...          delta_file=${delta_file}
#     ...          custom_alarms=@{custom_alarms}
#     ...          critical_faults=@{critical_faults}
#     ...          use_remote_node=${is_enb_test}
#     ...          disable_syslog_check=${disable_syslog_check}
#     ...          should_be_reported=${should_be_reported}
#     ...          attach_test_keyword=${L3_CALL}
#     ...         qc_domain=${qc_domain}
#     ...        qc_id=${qc_id}
#     ...        qc_project=${qc_project}
#     ...        label=${LABEL}
#     [Teardown]    UUF4ALL NR Test Teardown
# 
# [1]E2E_15_SiSo_Delta_Commissioning_With_Site_Reset_and_L3Call
#     [Setup]  SISO Coam Test Setup
#     ${TEST_NAME}   Set Variable   [1]e2e_tl_delta_commissioning_with_site_reset_required
#     Set Global Variable   ${TEST_NAME}
#     ${delta_file}   Get_DeltaFile_With_Modify_Parameter  connection=GNB_OAM   dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
#     ...   filter_parameter=Activate support for distributed site   pattern=actDistributedSite
#     DELTA_COMMISSIONING_WITH_SITE_RESET_REQUIRED
#     ...          test_iteration=${runs_of_delt_commision}
#     ...          delta_file=${delta_file}
#     ...          custom_alarms=@{custom_alarms}
#     ...          critical_faults=@{critical_faults}
#     ...          use_remote_node=${is_enb_test}
#     ...          disable_syslog_check=${disable_syslog_check}
#     ...          should_be_reported=${should_be_reported}
#     ...          attach_test_keyword=${None}
#     ...         qc_domain=${qc_domain}
#     ...        qc_id=${qc_id}
#     ...        qc_project=${qc_project}
#     ...        label=${LABEL}
#     [Teardown]    UUF4ALL NR Test Teardown
# 
# [1]E2E_16_SiSo_debug_SCF_commission
#     [Setup]  SISO Coam Test Setup
#     FOR    ${num}    IN RANGE    1    ${commission_times}
#         CI_interface.Common Suite Setup
#     END
#     [Teardown]    SISO Coam Test Teardown
# *** Keywords ***
