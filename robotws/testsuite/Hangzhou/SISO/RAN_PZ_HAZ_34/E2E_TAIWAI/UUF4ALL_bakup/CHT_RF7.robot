*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Timeout

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_Stability_Test_Case.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
Resource    ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_lock_and_unlock_gNB.robot
Resource    ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot
Resource    ${BASIC_PATH_5G}/E2E_SiSo_RU_lock_and_unlock_gNB.robot
Resource    ${BASIC_PATH_5G}/Baseband_module_reset_via_WEBUI.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_power_reset.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_via_admin.robot
Resource    ${BASIC_PATH_5G}/BTS/Capture_snapshot_during_tracffic.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG4/Classical/cases/General_siso_SFP_lock_Trigger_Fault10_immediately_unlock.robot
Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Online_Cell_addition_deletion.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Modify_Prach_Online_with_Frame_Structure.robot
Resource    ${BASIC_PATH_5G}/General_RU_entering_deep_sleep_mode_for_energy_efficiency_with_CB007511_enabled.robot
Variables   ../TestData/E2E_variables.py
Resource    ../Resource/e2e_common_cases.robot
Resource    ../Resource/e2e_step_keywords.robot
Resource    ../Resource/e2e_oam_kpi_keywords.robot
Resource    taf/rfrl/uuf4all/uuf4all_test_cases.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/selenium.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/AVQE_Bootcamp/resource/common_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/AVQE_Bootcamp/resource/common_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/cell_addition_deletion_online.robot

Documentation
...    Author: tingting zhong
...    Contact: tingting.zhong@nokia-sbell.com
...    squad group:SG_04
...    Feature E2E CHT for RF7

Force Tags            5G_RAN_TDD    STATE_GNB_COMMISSIONED
...   PY36

*** Variables ***
${if_commissioning}                     True
${L3call_stability_times}       ${10}
${L3call_longer_duration}       ${3600}
${runs_of_cell_lock}            ${1}
${runs_of_cell_block}           ${1}
${runs_of_bbmd_reset}           ${1}
${rf_reset_total_times}         ${1}
${rf_power_reset_times}         ${1}
${site_reset_times}             ${10}
${runs_of_delt_commision}       ${1}
@{critical_faults}       10    16    1806    1868    4341    4352    4383
@{customers}             Chungwa Telecom
@{custom_alarms}         4293   62003   61074   7509
${is_enb_test}           False
${should_be_reported}    True
${disable_syslog_check}  True
${qc_domain}=            MN_RAN_ST
${qc_id}=                ${None}
${qc_project}=           RAN_ST
${LABEL}=                ${None}
${L3_CALL}               Make Call With All UE
@{addition_deletion_cell_list}       ${1}
@{addition_deletion_cellgrp_list}    ${0}
@{lcrid_list}                        ${1}
@{cell_grp}                          ${0}  ${1}  ${2}
@{del_cell_grp}                      ${0}
${ru_index}=              ${1}

*** Test Cases ***
[1]E2E_01_SiSo_Delta_Commissioning_With_Online_Parameter_Modification_and_L3Call
    [Setup]  SISO Coam Test Setup
    [Documentation]
    ...    Duration: 25m with pass 1times
    Delta_Commissioning_With_Given_Parameter    with_peak=${False}
    [Teardown]   SISO Coam Test Teardown

[1]E2E_02_SiSo_Cell_lock_and_unlock_gNB_with_Single_UE_perCell_L3call_peak_NSA
    [Tags]    RF50
    [Setup]    UUF4ALL NR Test Setup
    [Documentation]
    ...    Duration: 1h40m with pass 3tims
    ${TEST_NAME}   Set Variable   [1]e2e_tl_cell_lock_unlock_nr_with_oam_kpi
    Set Global Variable   ${TEST_NAME}
    OAM_NRCEL_LOCK
    ...    test_iteration=${runs_of_cell_lock}
    ...    critical_faults=@{critical_faults}
    ...    customers_list=${customers}
    ...    custom_alarms=@{custom_alarms}
    ...    use_remote_node=${is_enb_test}
    ...    should_be_reported=${should_be_reported}
    ...    attach_test_keyword=${L3_CALL}
    ...    disable_syslog_check=${disable_syslog_check}
    ...    qc_domain=${qc_domain}
    ...    qc_id=${qc_id}
    ...    qc_project=${qc_project}
    ...    label=${LABEL}
    [Teardown]    UUF4ALL NR Test Teardown

[1]E2E_03_SiSo_Cell_block_and_unblock_gNB_with_Single_UE_perCell_L3call_peak_NSA
    [Tags]    RF50
    [Setup]    UUF4ALL NR Test Setup
    [Documentation]
    ...    Duration: 1h15m with pass 3times
    ${TEST_NAME}   Set Variable   [1]e2e_tl_cell_block_unblock_nr_with_oam_kpi
    Set Global Variable   ${TEST_NAME}
    OAM_NRCEL_BLOCK
    ...    test_iteration=${runs_of_cell_block}
    ...    critical_faults=@{critical_faults}
    ...    customers_list=${customers}
    ...    custom_alarms=@{custom_alarms}
    ...    use_remote_node=${is_enb_test}
    ...    should_be_reported=${should_be_reported}
    ...    attach_test_keyword=${L3_CALL}
    ...    disable_syslog_check=${disable_syslog_check}
    ...    qc_domain=${qc_domain}
    ...    qc_id=${qc_id}
    ...    qc_project=${qc_project}
    ...    label=${LABEL}
    [Teardown]    UUF4ALL NR Test Teardown

[1]E2E_04_SiSo_RU_lock_and_unlock_gNB_with_Single_UE_perCell_L3call_peak_NSA
    [Tags]    RF50
    [Setup]  SISO Coam Test Setup
    [Documentation]
    ...    Duration: 1h with pass 1times
    E2E_SiSo_RU_lock_and_unlock_gNB    with_call=${True}    with_peak=${True}  call_duration=${300}
    [Teardown]   SISO Coam Test Teardown

[1]E2E_05_SiSo_BBMOD_module_reset_from_GUI_with_Single_UE_perCell_L3call_peak_NSA
    [Tags]    RF50
    [Setup]    UUF4ALL NR Test Setup
    ${TEST_NAME}   Set Variable   [1]e2e_tl_capacity_module_reset_with_oam_kpi
    Set Global Variable   ${TEST_NAME}
    OAM_BBMOD_RESET
    ...    test_iteration=${runs_of_bbmd_reset}
    ...    critical_faults=@{critical_faults}
    ...    customers_list=${customers}
    ...    custom_alarms=@{custom_alarms}
    ...    use_remote_node=${is_enb_test}
    ...    should_be_reported=${should_be_reported}
    ...    attach_test_keyword=${L3_CALL}
    ...    disable_syslog_check=${disable_syslog_check}
    [Teardown]    UUF4ALL NR Test Teardown

[1]E2E_07_SiSo_RF_module_reset_from_GUI_with_Single_UE_perCell_L3call_peak_NSA
    [Setup]   SISO Coam Test Setup    enable_watchdog=${false}
    [Documentation]
    ...    Duration: 0.5h with pass 1times
    log to console    \ntotal times:${rf_reset_total_times}
    log to console    \nneed pass times:${rf_reset_total_times}
    General_Stability_Test_Case    case_name=General_SiSo_RF_module_reset_via_admin
    ...    times=${rf_reset_total_times}    pass=${rf_reset_total_times}    with_recovery=${False}
    ...    common_setup_each_time=${True}    with_call=${True}    with_peak=${False}
    [Teardown]    SISO Coam Test Teardown    enable_watchdog=${false}    is_check_historyalarm=${True}

[1]E2E_12_SiSo_Radio_memory_verification_by_capturing_snapshot_during_L3call
    [Setup]  SISO Coam Test Setup
    [Documentation]
    ...    Duration: 50min with pass 1times
    Capture_snapshot_during_tracffic
    [Teardown]   SISO Coam Test Teardown

[1]E2E_14_SiSo_Delta_Commissioning_With_Rat_Reset_and_L3Call
    [Setup]  SISO Coam Test Setup
    [Documentation]
    ...    Duration: 3h with pass 3times
    ${TEST_NAME}   Set Variable   [1]e2e_tl_delta_commissioning_with_nr_rat_reset
    Set Global Variable   ${TEST_NAME}
    ${delta_file}   Get_DeltaFile_With_Modify_Parameter  connection=GNB_OAM   dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...   filter_parameter=Activate Multiple VLAN interfaces   pattern=actMultVlan
    DELTA_COMMISSIONING_WITH_NR_RAT_RESET
    ...          test_iteration=${runs_of_delt_commision}
    ...          delta_file=${delta_file}
    ...          custom_alarms=@{custom_alarms}
    ...          critical_faults=@{critical_faults}
    ...          use_remote_node=${is_enb_test}
    ...          disable_syslog_check=${disable_syslog_check}
    ...          should_be_reported=${should_be_reported}
    ...          attach_test_keyword=${L3_CALL}
    ...          qc_domain=${qc_domain}
    ...          qc_id=${qc_id}
    ...          qc_project=${qc_project}
    ...          label=${LABEL}
    [Teardown]    SISO Coam Test Teardown

[1]General_SiSo_Online_Cell_Addition_Deletion
    [Setup]   SISO Coam Test Setup
    [Documentation]
    ...    Duration: 40min with pass 1times
    Selenium Login And Disable Screen Lock
    Prepare for delete NRPGRP
    Online delete NRPGRP
    General_SiSo_Online_Cell_addition_deletion
    [Teardown]  run keywords    SISO Coam Test Teardown    perform_case_scf=${True}    AND
    ...    Selenium Logout And Close Browser

[1]General_SiSo_PRACH_Online_Change
    [Setup]   SISO Coam Test Setup
    ${ue_num_each_call}    Get Tput ue Number    given_num=1
    ${prach_index_list}    create list    2
    General_SiSo_Modify_Prach_Online_with_Frame_Structure    prach_index_list=${prach_index_list}    band=90
    ...    frame_structure=1070_GP1_A3    ue_num_each_call=${ue_num_each_call}
    ...    suite_name=${SUITE NAME}    test_name=${TEST NAME}
    [Teardown]  SISO Coam Test Teardown    perform_case_scf=${True}

[1]General_SiSo_SFP_lock_unlock
   [Setup]   SISO Coam Test Setup
   General_Siso_Lock_Unlock_SFP_BBMOD_Trigger_Fault10
   [Teardown]    SISO Coam Test Teardown

[1]General_SiSo_BTS_Site_Reset
     [Setup]   SISO Coam Test Setup    enable_watchdog=${false}
     log to console    \nStart to test case loop check site reset
     ${fail_times}   Set variable    ${0}
     ${result}   Set variable    ${True}
     FOR    ${loop_index}    IN RANGE   1   ${site_reset_times}+1
         ${result}=    General_SiSo_Site_Reset_Check
         ${fail_times}    run keyword if    ${result}    set variable    ${fail_times}   ELSE   evaluate    ${fail_times}+1
         run keyword if      not ${result}    FAIL
         log to console    \nthe ${loop_index} time sleep 5s
         sleep    5s
     END
     should be true    ${fail_times}==${0}
     [Teardown]    SISO Coam Test Teardown    enable_watchdog=${false}

[1]General_SiSo_Radio_Module_Power_Reset
     [Setup]   SISO Coam Test Setup
     log to console    \nStart to test case loop power reset RF
     FOR    ${loop_index}    IN RANGE   1   ${rf_power_reset_times}+1
         General_SiSo_RF_module_power_reset    with_call=${False}    with_peak=${False}
         log to console    \nthe ${loop_index} time sleep 30s
         sleep    30s
     END
     [Teardown]    SISO Coam Test Teardown

[1]E2E_SiSo_UE_L3call_1hour
    [Setup]    SISO Coam Test Setup
    [Documentation]
    ...    Duration: 1.5h with pass 3times
    log to console    \n L3call_Longer:${L3call_longer_duration}
    E2E_SiSo_UE_L3call    duration=${L3call_longer_duration}
    [Teardown]    SISO Coam Test Teardown

[1]E2E_SiSo_5G_Accessibility_Success_Ratio_Check_NR_5013a
    [Setup]    SISO Coam Test Setup
    [Documentation]
    ...    Duration: 2h40min with pass 20times
    log to console    \n L3call_Stability:${L3call_stability_times}
    FOR    ${index}    IN RANGE    ${L3call_stability_times}
      E2E_SiSo_UE_L3call    duration=${60}
    END
    [Teardown]    SISO Coam Test Teardown

[1]General_SiSo_Auto_Deep_Sleep_RU_cells_lock_unlock_with_L3call
    [Setup]    SISO Coam Test Setup
       ${fault_list}    Create List    49
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    selenium Login And Disable Screen Lock    version=${stream}
    log to console  \n Enable CB007511
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${ru_index}
    ...    filter_param=Energy Saving Mode Activation    abbr=energySavingMode    new_value=DEEPSLEEP
    General_SiSo_Auto_Deep_Sleep_RU_cells_lock_unlock_with_L3call
    [Teardown]    run keywords
    ...    Selenium Logout And Close Browser    AND
    ...    SISO Coam Test Teardown    perform_case_scf=${True}

[1]General_SiSo_Auto_Deep_Sleep_RU_awake_after_parameter_change
    [Setup]    SISO Coam Test Setup
    General_RU_entering_deep_sleep_mode_for_energy_efficiency_with_CB007511_enabled
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate NR load-based power saving    abbr=actNrLBPowerSaving    new_value=false
    wait until keyword succeeds   10min    30s    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=${0}
    wait until keyword succeeds   10min    30s    Verify all cells should be onair
    [Teardown]    run keywords
    ...    Selenium Logout And Close Browser    AND
    ...    SISO Coam Test Teardown

[1]General_SiSo_Auto_Deep_Sleep_RU_awake_after_adding_new_cell
    [Setup]    SISO Coam Test Setup
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    selenium Login And Disable Screen Lock    version=${stream}
    log to console  \n Enable CB007511
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${ru_index}
    ...    filter_param=Energy Saving Mode Activation    abbr=energySavingMode    new_value=DEEPSLEEP
    Prepare for delete NRPGRP
    Online delete NRPGRP
    Online delete cells    addition_deletion_cell_list=@{addition_deletion_cell_list}
    ...    addition_deletion_cellgrp_list=@{addition_deletion_cellgrp_list}
    ...   lcrid_list=@{lcrid_list}
    ...    cell_grp=@{del_cell_grp}    scf_path=${scf_path}
    sleep    300s
    log to console  \ncheck RMOD status
    run keyword and return status    RU Status Info Should Be as Expect    ru_index=${ru_index}    powerState=SLEEP
    Online Cells Addition    addition_deletion_cell_list=@{addition_deletion_cell_list}
    ...    addition_deletion_cellgrp_list=@{addition_deletion_cellgrp_list}
    ...   lcrid_list=@{lcrid_list}
    ...    cell_grp=@{cell_grp}    scf_path=${scf_path}
    wait until keyword succeeds   10min    30s    Verify all cells should be onair
    [Teardown]    run keywords
    ...    Selenium Logout And Close Browser    AND
    ...    SISO Coam Test Teardown    perform_case_scf=${True}

*** Keywords ***
E2E_SiSo_UE_L3call
    [Arguments]    ${duration}
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${cell_list}    Get All Cell Id    ${ru_index}
        Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${False}    duration=${duration}
    END

General_SiSo_Auto_Deep_Sleep_RU_cells_lock_unlock_with_L3call
    Get X2 link shutdown waiting time
    ${cell_id_list}  Get All Cell Id
    ${cell_num}    get length  ${cell_id_list}
    ${check_alarm}    set variable if    ${cell_num}==1    ${True}    ${False}
    FOR  ${lock_id}  IN  @{cell_id_list}
        ${operate_list}    create list    ${lock_id}
        Lock cells or groups and check status  lock_list=${operate_list}  is_group=${False}  check_alarm=${check_alarm}
        ...    gnb_type='${gNb_CuType}'
        sleep    300s
        Unlock cells or groups and check status  lock_list=${operate_list}  is_group=${False}  check_alarm=${check_alarm}
        ...    gnb_type='${gNb_CuType}'
    END
