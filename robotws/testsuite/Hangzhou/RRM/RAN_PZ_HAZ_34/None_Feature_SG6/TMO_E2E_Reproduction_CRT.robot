*** Settings ***
Documentation    TMO Automation for SISO without L3 call cases
...              Author: xiangsheng.chu@nokia-sbell.com
Suite Setup    TMO_Common_Suite_Setup    is_commission=${False}    whether_do_prepare_ue=${False}    turn_off_pa=${False}
Test Teardown    TMO_Suite_Teardown
Suite Teardown    TMO_Suite_Teardown
Force Tags    5G_SISO    SG_06     CA_VRF_HAZ4
...    PY36

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/TMO/TMO_common_keywords.robot
Resource    taf/rfrl/procedures/SISO/test_models/etsi/resources/Test_Model.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot

*** Variables ***
${spark_ue_logpath}      C:/tmp/uelog/AUTO/${target_version}
${ReportName_ue_kpi}      C:/spark/UE_KPI.rpt
${ReportName_ue_DL_kpi}      C:/spark/UE_DL_KPI.rpt
${ReportName_ue_prach}      C:/spark/UE_prach.rpt
${qc_lab_path_trunk}    Root\\Test_Sets\\Trunk\\VRF_HAZ\\VRF_HAZ_T06\\VRF_HAZ4_T06
${qc_lab_path_SBTS24R3}    Root\\Test_Sets\\24R3_MP\\Regression\\VRF_HAZ4\\VRF_HAZ4_T06
${qc_lab_path_SBTS24R2}    Root\\Test_Sets\\24R2_MP\\Regression\\VRF_HAZ4\\VRF_HAZ4_T06
${SAVE LOG DIRECTORY}      /tmp
${scell_add_fail}    adding UE failed
${Ue_group_full}    The UE group is full
${enb_target_ver}
${enb_target_sw}    ${enb_target_ver}
@{scf_update_params_tac}    modify:MRBTS-816/NRBTS-816/TRACKINGAREA-5700:fiveGsTac=20310
@{CB07334_flag}     0x1300E2=1     0x13001E=1    0x13001F=1     0x130020=1     0x130021=1
#@{CB07334_flag}     0x1300E2=1

*** Test Cases ***
#5603153_E2E_Rep_001_all_TDD_cells_L3call_comparison_before_after_gNB_upgrade
#    [Documentation]    Author:lei.jia@nokia-sbell.com
#    ...                compare TDD L3 call tput before and after upgrade
#    ...                step1: make L3 call one by one on AEHC nr cells, and record tput result
#    ...                step2: perform sw upgrade
#    ...                step3: make L3 call one by one on AEHC nr cells, and record tput result
#    ...                step4: load new scf, make L3 call one by one on AEHC nr cells, and record tput result
#    ...                step5: compare tput
#    ...                EXECUTION TESTLINE: TL073
#    [Setup]    SetUp.TMO Case Common SetUp    is_first_gnb_used=${True}    ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
#    COAM Create log directory
#    # comment: aehc_pcell_scell_list}: [['301', 1, 21, 311], ['302', 2, 22, 312]]
#    @{aehc_pcell_scell_list}    create list
#    &{scell_pcell_mapping_dict}    Create Dictionary
#    ${ue_index}=    Set Variable    ${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
#    Check Rollback is needed before sw upgrade
#    ${stream_version_before_upgrade}    Common_setup_and_teardown.Get Active SW Version Based On Stream Version
#    Common_setup_and_teardown.Common Suite Setup    scf_name=${tl_prefix}_gNB_${stream_version_before_upgrade}.xml    is_commission=${True}
#    ...    timeout_for_commission=20 min
#    sleep  1min
#    Check TMO Gnb Ready And All Cell On Air
#    ${aehc_nr_cell_list}    Get Cell List For Special RU    cell_type=nr
#    # comment: large_chbw_nrcells_list contains 100M AEHC cells id, for example 301/302/303
#    ${large_chbw_nrcells_list}    Get TDD large chbw cells    aehc_nr_cell_list=${aehc_nr_cell_list}
#    FOR    ${pcell_index}    IN    @{large_chbw_nrcells_list}
#        ${SCELL_INDEX_LIST}    Get scell and pcell mapping dict    pcell_index=${pcell_index}    scell_pcell_mapping_dict=${scell_pcell_mapping_dict}
#        ${PCELL_INDEX_LIST}    create list    ${pcell_index}
#        ${pcell_scell_list}    Combine Lists    ${PCELL_INDEX_LIST}     ${SCELL_INDEX_LIST}
#        Append To List    ${aehc_pcell_scell_list}    ${pcell_scell_list}
#    END
#    log to console    \n--- step1: start l3 call before upgrade---
#    ${btsName_before_upgrade}    ${gnb_version_before_upgrade}     Get BtsName and SwVersion
#    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False}    Verify All Enbs Cell On Air
#    Check Alarm and stop robot testing when unexpected alarm raised
#    Wait Until Keyword Succeeds    1 min    5 sec  Connect to gnb coam via ssl
#    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=@{GNB_ALLOWED_FAULT}
#    FOR    ${enb_index}    IN RANGE    ${enb_length}
#        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${enb_index}
#    END
#    ${timestamp_before_upgrade}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d-%H%M%S
#    Run Keyword If    'spark' in '${ue_type}'    Procedures.Start UE Prepare    ue_index=${ue_index}
#    ...                                          ue_type=${ue_type}    detach_request=${true}      power_reset=true
#    ${tput_before_upgrade}    Start L3 call and Record tput with aasyslog    cell_list=${large_chbw_nrcells_list}
#    ...    ue_index=${ue_index}    whether_do_ue_prepare=${True}
#    log to console    \n--- step2:  start to upgrade---
#    Gnb Upgrade Only
#    sleep  5min
#    Check TMO Gnb Ready And All Cell On Air
#    ${btsName_after_upgrade}    ${gnb_version_after_upgrade}    Get BtsName and SwVersion
#    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False}    Verify All Enbs Cell On Air
#    Check Alarm and stop robot testing when unexpected alarm raised
#    Wait Until Keyword Succeeds    1 min    5 sec  Connect to gnb coam via ssl
#    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=@{GNB_ALLOWED_FAULT}
#    Run Keyword And Ignore Error    COAM Teardown gnb connections
#    Sleep    90sec
#    log to console    \n--- step3: start l3 call after upgrade---
#    ${timestamp_after_upgrade}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d-%H%M%S
#    ${tput_after_upgrade}     Start L3 call and Record tput with aasyslog    cell_list=${large_chbw_nrcells_list}
#    ...    ue_index=${ue_index}    whether_do_ue_prepare=${True}
#    log to console    \n--- step4: load scf correspoding to given version---
#    ${stream_version_after_upgrade}    Common_setup_and_teardown.Get Active SW Version Based On Stream Version
#    Common_setup_and_teardown.Common Suite Setup    scf_name=${tl_prefix}_gNB_${stream_version_after_upgrade}.xml    is_commission=${True}
#    ...    timeout_for_commission=20 min
#    Check TMO Gnb Ready And All Cell On Air
#    Sleep    90sec
#    ${btsName_after_upgrade_load_scf}    ${gnb_version_after_upgrade_load_scf}    Get BtsName and SwVersion
#    ${stream_version_after_upgrade}    Common_setup_and_teardown.Get Active SW Version Based On Stream Version
#    Check Alarm and stop robot testing when unexpected alarm raised
#    Wait Until Keyword Succeeds    1 min    5 sec  Connect to gnb coam via ssl
#    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=@{GNB_ALLOWED_FAULT}
#    log to console    \n--- step4.2: start l3 call after load scf---
#    ${timestamp_after_upgrade_load_scf}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d-%H%M%S
#    ${tput_after_upgrade_with_new_scf}     Start L3 call and Record tput with aasyslog    cell_list=${large_chbw_nrcells_list}
#    ...    ue_index=${ue_index}    whether_do_ue_prepare=${True}
#    log to console    \n--- step5: comapre tput and generate tput report--
#    @{tput_results}=    Create List
#    @{tput_report_before_upgrade}=    Create List    ${timestamp_before_upgrade}
#    ...                                            ${gnb_version_before_upgrade}   ${btsName_before_upgrade}
#    @{tput_report_after_upgrade}=    Create List     ${timestamp_after_upgrade}
#    ...                                            ${gnb_version_after_upgrade}    ${btsName_after_upgrade}
#    @{tput_report_after_upgrade_load_scf}=    Create List    ${timestamp_after_upgrade_load_scf}
#    ...                                            ${gnb_version_after_upgrade_load_scf}    ${btsName_after_upgrade_load_scf}
#    @{tput_columns}=    Create List    StartTime    SwBuild    ScfName
#    FOR    ${cell_list}    IN    @{aehc_pcell_scell_list}
#        Get DL and UL tput for pcell and scell lists
#        ...            cell_list=${cell_list}
#        ...            tput_columns=${tput_columns}
#        ...            tput_report_before_upgrade=${tput_report_before_upgrade}
#        ...            tput_report_after_upgrade=${tput_report_after_upgrade}
#        ...            tput_report_after_upgrade_load_scf=${tput_report_after_upgrade_load_scf}
#        ...            scell_pcell_mapping_dict=${scell_pcell_mapping_dict}
#        ...            tput_before_upgrade=${tput_before_upgrade}
#        ...            tput_after_upgrade=${tput_after_upgrade}
#        ...            tput_after_upgrade_with_new_scf=${tput_after_upgrade_with_new_scf}
#    END
#    Append To List    ${tput_results}    ${tput_report_before_upgrade}
#    ...    ${tput_report_after_upgrade}    ${tput_report_after_upgrade_load_scf}
#    ${file_path}    set variable     /home/ute/KPI_report/${tl_prefix}_${stream_version_after_upgrade}_tput.xlsx
#    Log To Console    ${\n}Start to generate data report
#    KPI_report.Generate Data Report From Aasyslog    tput_data_list=${tput_results}
#    ...    header_list=${tput_columns}    file_path=${file_path}
#    [Teardown]    Run Keyword And Ignore Error    TMO_Common_Case_Teardown    ue_index=${ue_index}

5603153_E2E_Rep_001_all_TDD_cells_L3call_comparison_before_after_gNB_upgrade
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                modify:stella.lin@nokia-sbell.com
    ...                compare TDD L3 call tput before and after upgrade
    ...                step1: make L3 call one by one on AEHC nr cells, and record tput result
    ...                step2: perform sw upgrade
    ...                step3: make L3 call one by one on AEHC nr cells, and record tput result
    ...                step4: load new scf, make L3 call one by one on AEHC nr cells, and record tput result
    ...                step5: compare tput
    ...                EXECUTION TESTLINE: TL073
    [Tags]     T073    T080
    [Setup]    SetUp.TMO Case Common SetUp    is_first_gnb_used=${True}    ue_index=${Case_5603153_CHOOSED_UE['${tl_prefix}']}
    # comment: aehc_pcell_scell_list}: [['301', 1, 21, 311], ['302', 2, 22, 312]]
    @{aehc_pcell_scell_list}    create list
    &{scell_pcell_mapping_dict}    Create Dictionary
    ${ue_index}=    Set Variable    ${Case_5603153_CHOOSED_UE['${tl_prefix}']}
    ${aehc_nr_cell_list}    Get Cell List For Special RU    cell_type=nr
    # comment: large_chbw_nrcells_list contains 100M AEHC cells id, for example 301/302/303
    ${large_chbw_nrcells_list}    Get TDD large chbw cells    aehc_nr_cell_list=${aehc_nr_cell_list}
    FOR    ${pcell_index}    IN    @{large_chbw_nrcells_list}
        ${SCELL_INDEX_LIST}    Get scell and pcell mapping dict    pcell_index=${pcell_index}
        ...    scell_pcell_mapping_dict=${scell_pcell_mapping_dict}
        ${PCELL_INDEX_LIST}    create list    ${pcell_index}
        ${pcell_scell_list}    Combine Lists    ${PCELL_INDEX_LIST}     ${SCELL_INDEX_LIST}
        Append To List    ${aehc_pcell_scell_list}    ${pcell_scell_list}
    END
    Set Test Variable    ${ue_index}
    Set Test Variable    ${scell_pcell_mapping_dict}
    Set Test Variable    ${aehc_pcell_scell_list}
    Set Test Variable    ${large_chbw_nrcells_list}
    Procedures.Start UE Prepare    ue_index=${ue_index}    ue_type=${ue_type}
    #---- start test ----
    ${tput_active_build}    ${timestamp_active_build}    ${btsName_active_build}    ${gnb_version_active_build}
    ...    TestCase.Reproduce_5603153
    SetUp.Precondition For First gNB    is_commission=${True}    check_rollback_is_needed=${False}
    ${tput_with_scf}    ${timestamp_with_scf}    ${btsName_with_scf}    ${gnb_version_with_scf}    TestCase.Reproduce_5603153
    Run Keyword And Continue On Failure    SetUp.Precondition For First gNB    is_commission=${True}    check_rollback_is_needed=${False}
    Check Rollback is needed before sw upgrade    active_sw_flag=Low
    ...                                           gnb_index=${0}
    ${tput_passive_build}    ${timestamp_passive_build}    ${btsName_passive_build}    ${gnb_version_passive_build}
    ...    TestCase.Reproduce_5603153
    log to console    \n--- step5: comapre tput and generate tput report--
    @{tput_results}=    Create List
    @{tput_report_before_upgrade}=    Create List    ${timestamp_passive_build}
    ...                                              ${gnb_version_passive_build}    ${btsName_passive_build}
    @{tput_report_after_upgrade}=    Create List     ${timestamp_active_build}
    ...                                              ${gnb_version_active_build}     ${btsName_active_build}
    @{tput_report_after_upgrade_load_scf}=    Create List    ${timestamp_with_scf}
    ...                                                      ${gnb_version_with_scf}     ${btsName_with_scf}
    @{tput_columns}=    Create List    StartTime    SwBuild    ScfName
    FOR    ${cell_list}    IN    @{aehc_pcell_scell_list}
        Get DL and UL tput for pcell and scell lists
        ...            cell_list=${cell_list}
        ...            tput_columns=${tput_columns}
        ...            tput_report_before_upgrade=${tput_report_before_upgrade}
        ...            tput_report_after_upgrade=${tput_report_after_upgrade}
        ...            tput_report_after_upgrade_load_scf=${tput_report_after_upgrade_load_scf}
        ...            scell_pcell_mapping_dict=${scell_pcell_mapping_dict}
        ...            tput_before_upgrade=${tput_passive_build}
        ...            tput_after_upgrade=${tput_active_build}
        ...            tput_after_upgrade_with_new_scf=${tput_with_scf}
    END
    Append To List    ${tput_results}    ${tput_report_before_upgrade}
    ...    ${tput_report_after_upgrade}    ${tput_report_after_upgrade_load_scf}
    ${file_path}    set variable     /home/ute/KPI_Report/Excel_KPI/${tl_prefix}_${gnb_version_active_build}_tput.xlsx
    Log To Console    ${\n}Start to generate data report
    KPI_report.Generate Data Report From Aasyslog    tput_data_list=${tput_results}
    ...    header_list=${tput_columns}    file_path=${file_path}
    Run Keyword And Ignore Error    combine_two_excel_result    first_excel=/home/ute/KPI_Report/KPI_5605001.xlsx    second_excel=${file_path}
    ${remote_server_store_path}    Catenate
    ...    /home/hz4sg6/shared/01_E2E_Rep/5605001/5605001_${tl_prefix}/KPI_5605001.xlsx
    Run Keyword And Ignore Error    upload_files_to_remote_server
    ...    local_path=/home/ute/KPI_Report/KPI_5605001.xlsx
    ...    remote_path=${remote_server_store_path}
    ...    hostname=${samba_server_ip}
    ...    username=${samba_server_username}
    ...    password=${samba_server_password}
    [Teardown]    Run Keywords    Run Keyword And Continue On Failure    TMO_Common_Case_Teardown    ue_index=${ue_index}    AND
    ...    SetUp.Precondition For First gNB    is_commission=${True}    check_rollback_is_needed=${False}    AND    csn.reset_cache


5605003_E2E_Rep_003_Inactive Scell Swap for 4CCs
    [Documentation]    Author:stella.lin@nokia-sbell.com
    ...                EXECUTION TESTLINE: TL073,TL080
    [Tags]     T080_QC    T073_QC    T816_QC
    [Setup]    SetUp.TMO Case Common SetUp    is_first_gnb_used=${True}    ue_index=${REPCASE_5605003_CHOOSED_UE['${tl_prefix}']}
    ...    is_commission_for_first_gnb=${True}
    ${swap_report_timestamps}    ${burst_dl_report_timestamps}    TestCase.Reproduce_5605003
    ${swap_test_description}    Set Variable If    '${tl_prefix}'=='T073' or '${tl_prefix}'=='T080'    Swap_DL_High_Traffic
    ...    Swap_DL_Low_Traffic
    ${swap_report}    Run Keyword And Continue On Failure
    ...    Compass.Single KPI Generate And Upload To Remote Server
    ...    report_timestamps_list=${swap_report_timestamps}    test_comments=${swap_test_description}
#    ${burst_test_description}    Set Variable If    '${tl_prefix}'=='T073'    Burst_DL_8UE
#    ...                                             '${tl_prefix}'=='T080'    Burst_DL_7UE
#    Run Keyword If    '${tl_prefix}'=='T073' or '${tl_prefix}'=='T080'
#    ...    Compass.KPI Generate And Upload To Remote Server
#    ...    report_timestamps_list=${burst_dl_report_timestamps}    test_comments=${burst_test_description}    report_parsed_duration=30
    [Teardown]   Run Keywords
    ...    Run Keyword And Ignore Error     Save Current SCF And Save Snapshot    AND
    ...    Run Keyword And Continue On Failure    TMO_Common_Case_Teardown
    ...    ue_index=${REPCASE_5605003_CHOOSED_UE['${tl_prefix}']}    is_save_snapshot=${False}    AND
    ...    Run Keyword And Continue On Failure    SetUp.Precondition For First gNB
    ...    is_commission=${True}    check_rollback_is_needed=${False}  AND
    ...    csn.reset_cache

5605004_E2E_Rep_004_ping service during Xn-HO intra-frequency mobility
    [Documentation]    Author:stella.lin@nokia-sbell.com
    ...       EXECUTION TESTLINE: TL080/TL282
    [Tags]     T080_QC
    [Setup]    SetUp.TMO Case Common SetUp    is_first_gnb_used=${True}    is_second_gnb_used=${True}    ue_index=${15}
    ...    is_commission_for_first_gnb=${True}    is_second_gnb_used=${True}    is_commission_for_second_gnb=${True}
    ${used_ue_index}    Set Variable If    '${tl_prefix}'=='T073'    ${1}
    ...                                    '${tl_prefix}'=='T080'    ${15}
    set test variable    ${used_ue_index}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${used_ue_index}
    Set Test Variable    ${ue_type}
    Procedures.Start UE Prepare    ue_index=${used_ue_index}   ue_type=${ue_type}    get_spark_license=${False}
    ${report_timestamps_before_restart}    Run Keyword And Continue On Failure    TestCase.Reproduce_5605004
    Perform gNB Reset site and Wait Onair
    ${report_timestamps_after_restart}   Run Keyword And Continue On Failure    TestCase.Reproduce_5605004
    #generate and record kpi report
    ${empty_list}    Create List
    ${report_timestamps_before}    Set Variable If   ${report_timestamps_before_restart}!=${None}     ${report_timestamps_before_restart}
    ...   ${empty_list}
    ${report_timestamps_after}    Set Variable If    ${report_timestamps_after_restart}!=${None}     ${report_timestamps_after_restart}
    ...   ${empty_list}
    ${report_timestamps}    Combine Lists    ${report_timestamps_before}    ${report_timestamps_after}
    ${len_timestamp}    Get Length    ${report_timestamps}
    ${output_file}    Run Keyword If    '${len_timestamp}'=='${0}'     Fail
    ...    msg=no available report timestamps,handover test failed.please check.
    ...     ELSE IF   '${len_timestamp}'=='${2}'    Compass.KPI Generate And Upload To Remote Server    test_comments=Inter_HO
    ...    report_timestamps_list=${report_timestamps}
    ...     ELSE    Compass.Single KPI Generate And Upload To Remote Server    test_comments=Inter_HO
    ...    report_timestamps_list=${report_timestamps}
    #------Reproduction KPI Verification---------------#
    ${NR_5057e_results}    get_kpi_values_rows_by_code_name    file_path=${output_file}    code_name=NR_5057e
    ${NR_5057e_all_values}    Get Dictionary Values    ${NR_5057e_results[0]}
    ${NR_5057e_values}    Set Variable   ${NR_5057e_all_values[3:-1]}
    [Teardown]    Run Keywords  Run Keyword And Continue On Failure    TMO_Common_Case_Teardown    ue_index=${used_ue_index}
    ...    is_save_snapshot=${False}    AND
    ...    Run Keyword And Continue On Failure    SetUp.Precondition For First gNB   is_commission=${True}
    ...    check_rollback_is_needed=${False}    AND
    ...    Run Keyword And Continue On Failure    SetUp.Precondition For Second gNB   is_commission=${True}
    ...    check_rollback_is_needed=${False}    AND   csn.reset_cache

5605005_E2E_Rep_005_Concurrent PS-BWP swtich and scell addtion
    [Documentation]    Author:stella.lin@nokia-sbell.com
    ...       EXECUTION TESTLINE: TL073,TL284,TL282
    [Tags]     T080    T073   T813
    [Setup]    SetUp.TMO Case Common SetUp    ue_index=${REPCASE_5605005_CHOOSED_UE['${tl_prefix}']}
    ...     is_commission_for_first_gnb=${True}
    #####-----testline precondition----####
    Reproduce_5605005.PA Value Setting
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=${PCELL_INDEX}
    ...    connection=GNB_OAM    timeout=300
    ${test_model_description}    Set Variable If    '${tl_prefix}'=='T073'    8UE_DL_SFTP
    ...                                             '${tl_prefix}'=='T080'    7UE_DL_SFTP
    ...                                             '${tl_prefix}'=='T813'    7UE_DL_Burst
    #####-----generate kpi report----####
    ${report_timestamps}    Run Keyword If   '${tl_prefix}'=='T073' or '${tl_prefix}'=='T080'
    ...    T080.KPI Test With DL SFTP
    ...    ELSE IF    '${tl_prefix}'=='T813'    T813.KPI Test With DL Burst Traffic
    Should Be True    ${report_timestamps}!=${None}    msg=Get Report Timestamps Failed.
    #generate and record kpi report
    ${kpi_report_file}    Compass.KPI Generate And Upload To Remote Server
    ...    report_timestamps_list=${report_timestamps}    report_parsed_duration=30    test_comments=${test_model_description}
    Should End With    ${kpi_report_file}    xlsx    msg=Get KPI Merged Results Failed.
    #####-----generate html result----####
    [Teardown]    Run Keywords    Run Keyword And Continue On Failure
    ...    TMO_Common_Case_Teardown    ue_index=${REPCASE_5605005_CHOOSED_UE['${tl_prefix}']}
    ...    AND    csn.reset_cache

5605006_E2E_Rep_006_DL_Spectral_efficiency_comparison_between_before_AEHC_NRCELL_energy_saving_and_exit_MixedSwitchoff_energy_saving
    [Documentation]    Author:stella.lin@nokia-sbell.com
    ...       EXECUTION TESTLINE: TL080
    [Tags]     T813    T284    T283
    [Setup]    SetUp.TMO Case Common SetUp    is_first_gnb_used=${True}    ue_index=${REPCASE_5605006_CHOOSED_UE['${tl_prefix}']}
        ...    is_commission_for_first_gnb=${True}
    ${report_timestamps_target_build}    ${report_timestamps_source_build}    TestCase.Reproduce_5605006
    #------Generate Comparator Report On Compass---------------#
    Run Keyword And Ignore Error    Generate Scout KPI Report And Comparator Report On Compass And Record To Server
    ...    report_timestamps_target_build=${report_timestamps_target_build}
    ...    report_timestamps_source_build=${report_timestamps_source_build}
    ...    gnb_index=${0}
    ...    comparator_filter_distnames=NRCELL-301,BTS
    ...    kpi_report_filter_distnames=bts,NRCELL-301
    ...    is_error_fail_case=${False}
    ...    comments=5605006
    #checkpoint
    ${NR_5108e_step2}    Set Variable    ${reproduce_kpi_info_target_build['reproduce_kpi_values']['NR_5108e']}
    ${NR_5108e_step4}    Set Variable    ${reproduce_kpi_info_source_build['reproduce_kpi_values']['NR_5108e']}
    ${NR_5108e_step2}    Convert To Number    ${NR_5108e_step2}
    ${NR_5108e_step4}    Convert To Number    ${NR_5108e_step4}
    ${compare_value}    Evaluate    ${NR_5108e_step2}*${0.97}
    Run Keyword And Continue On Failure    Should Be True    ${NR_5108e_step4}>=${compare_value}
    ...    msg=NR_5108e is degrade more than 3% for step2 and step4.
    [Teardown]    Run Keywords
    ...    Run Keyword And Continue On Failure    TMO_Common_Case_Teardown    ue_index=${REPCASE_5605006_CHOOSED_UE['${tl_prefix}']}
    ...    is_save_snapshot=${False}    AND
    ...    Run Keyword And Continue On Failure    SetUp.Precondition For First gNB    is_commission=${True}
    ...    check_rollback_is_needed=${False}   AND    csn.reset_cache

5605501_E2E_Rep_501_change_paramter_ulTransPrecodeCtl_enforcePrimaryPathOverLte_after_AMF_lock
    [Documentation]    Author:stella.lin@nokia-sbell.com
    ...       EXECUTION TESTLINE: TL080
    [Tags]     T080    T816
    [Setup]    SetUp.TMO Case Common SetUp    is_first_gnb_used=${True}    ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
    ...    is_commission_for_first_gnb=${True}
    ${report_timestamps_target_build}    ${report_timestamps_source_build}    TestCase.Reproduce_5605501
    #------Generate Comparator Report On Compass---------------#
    Run Keyword And Ignore Error   Generate Scout KPI Report And Comparator Report On Compass And Record To Server
    ...    report_timestamps_target_build=${report_timestamps_target_build}
    ...    report_timestamps_source_build=${report_timestamps_source_build}
    ...    gnb_index=${0}
    ...    comparator_filter_distnames=NRDU
    ...    kpi_report_filter_distnames=NRDU
    ...    is_error_fail_case=${False}
    ...    comments=5605501
#    Run Keyword And Continue On Failure    Generate Scout KPI Report And Comparator Report On Compass And Record To Server
#    ...    report_timestamps_target_build=${report_timestamps_target_build}
#    ...    report_timestamps_source_build=${report_timestamps_source_build}
#    ...    gnb_index=${0}
#    ...    comparator_filter_distnames=NRDU
#    ...    kpi_report_filter_distnames=NRDU
#    ...    is_error_fail_case=${False}
#    checkpoint
    ${M55150C00035_first}    Set Variable    ${reproduce_kpi_info_target_build['reproduce_kpi_values']['M55150C00035']}
    ${M55150C00035_second}    Set Variable    ${reproduce_kpi_info_source_build['reproduce_kpi_values']['M55150C00035']}
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${M55150C00035_first}    ${0}
    ...    msg=M55150C00035 is not zero in first step
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${M55150C00035_second}     ${0}
    ...    msg=M55150C00035 is not zero in second step
    [Teardown]    Run Keywords
    ...    Run Keyword And Continue On Failure    TMO_Common_Case_Teardown    ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
    ...    is_save_snapshot=${False}    is_history_alarm_check=${False}    AND
    ...    Run Keyword And Continue On Failure    SetUp.Precondition For First gNB    is_commission=${True}
    ...    check_rollback_is_needed=${False}   AND    csn.reset_cache

5605011_E2E_Rep_011_RedCap_RRCEstablishment_setup
    [Documentation]    Author:stella.lin@nokia-sbell.com
    ...       EXECUTION TESTLINE: TL080
    [Tags]     T080
    [Setup]    SetUp.TMO Case Common SetUp    is_first_gnb_used=${True}    ue_index=${14}
    ...    is_commission_for_first_gnb=${True}
#    Backup and Modify swconfig file    swconfig_modify=@{wireshark_flag}
#    Perform gNB Reset site and Wait Onair
    Modify PA Value Setting For Required RU    modify_ru_id=0
    ...    ue_index=${4}
    Enable RedCap Function
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=${PCELL_INDEX}
    ...    connection=GNB_OAM    timeout=300
    Run Keyword And Ignore Error     Reset UE Control PC If Connect Failed    ue_index=${14}
    UE With ADB Reboot    ue_index=${14}
    M60_RedCap.Prepare UE    ue_index=${14}
    ${attach_info}    M60_RedCap.UE Attach    ue_index=${14}    expect_attach_cell_index=311
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    Connect to Common Unit Master     alias=ASIK Master0   gnb_index=${0}
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log
    ...    tcpdump_collector_name=wireshark_${timestamp}
    ...    asik_connection_alias=ASIK Master0
    ...    gnb_index=${0}
    ...    du_index=0
    Sleep  20sec
    Run Keyword And Continue On Failure    Procedures.Start TMO L3 Call    cpif_log_path=${attach_info['cpif_log_path']}
    ...                                    dl_throughput=250MKbits/sec
    ...                                    ue_index=${14}
    ...                                    whether_start_ul_call=${False}
    Sleep   15sec
    ${ngap_wireshark}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...    tcpdump_collector_name=wireshark_${timestamp}
    ...    target_dir=${TS_CASE_LOG_PATH}
    ...    asik_connection_alias=ASIK Master0
    Run Keyword And Ignore Error    M60_RedCap.Check Tput    direction=DL    expect_dl_tput=400    cellid=311    duration=60
#    Run Keyword And Continue On Failure    M60_RedCap.Check Tput    direction=DL    expect_dl_tput=400    cellid=301    duration=60
    #checkpoint
    ${filter_expression}    Catenate    ngap.procedureCode == 15 && ngap.RedCapIndication == 0
    pcap.setup    infile=${ngap_wireshark}    display_filter=${filter_expression}    alias=test0
    pcap.get_packets    filter=${filter_expression}   pcap_parser=test0
    ${message_items}    pcap.get_field_value    field_name=ngap.id
    ...    filter=${filter_expression}
    ...    pcap_parser=test0
#    ${compare_message_list}    Create List    id-RAN-UE-NGAP-ID
#    ...                                       id-NAS-PDU
#    ...                                       id-UserLocationInformation
#    ...                                       id-RRCEstablishmentCause
#    ...                                       id-FiveG-S-TMSI
#    ...                                       id-RedCapIndication
    ${compare_message_list}    Create List    85    38    121   90  26   333
    Lists Should Be Equal    ${message_items[0]}    ${compare_message_list}
    ...    msg=message order for initialuemessage are not correct.expect is ${compare_message_list},actual is ${message_items[0]}.
    ${status}    ${cell_301_ttitrace_file}    Run Keyword And Ignore Error    Capture TTI with gnb logs
    ...    bbmod_slots=5,6
    ...    cell_index=311
    ...    duration=5
    ...    direction=dlAndUl
    ...    tti_log_option=T
    ...    tti_package_file_name=tti_packed
    Run Keyword And Ignore Error    RepCase_5603147.Check Tput And Bler Per UE
    ...    pcell_tti_trace=${cell_301_ttitrace_file}
    ...    scell_tti_trace=${cell_301_ttitrace_file}
    [Teardown]   Run Keywords    TMO_Common_Case_Teardown    ue_index=${14}   AND
    ...    Run Keyword And Continue On Failure    SetUp.Precondition For First gNB
    ...    is_commission=${True}    check_rollback_is_needed=${False}  AND
    ...    csn.reset_cache

5605500_E2E_Rep_500_lssIPaddress_change_on_eNB
    [Documentation]    Author:stella.lin@nokia-sbell.com
    ...       EXECUTION TESTLINE: TL080
    [Tags]     T080   T813
    [Setup]    SetUp.TMO Case Common SetUp    ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
    Connect to eNB
    ${status}    ${enb_version}     Run Keyword And Ignore Error    coam.get_sw_version    connection=ENB
    ${mrbts_index}     Set Variable If     '${tl_prefix}'=='T080'    11213
    ...                                    '${tl_prefix}'=='T813'    8131
    Set Test Variable    ${mrbts_index}
    Update lssIPaddress Via RestAPI    value=10.68.88.189     mrbts_index=${mrbts_index}
    Sleep    5min
    ${ssh_status}     Run Keyword And Return Status     Connect to eNB
    ${https_status}    Run Keyword And Return Status     COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ...    url=https://${tl.enbs[${0}].airscale.common_units[0].lmp_connection.addr}
    Run Keyword And Continue On Failure    Run Keyword If    '${ssh_status}'=='${False}'     Fail
    ...    msg=ssh connection failed after lssIPaddress change to 10.68.88.189
    Run Keyword And Continue On Failure    Run Keyword If    '${https_status}'=='${False}'     Fail
    ...    msg=https connection failed after lssIPaddress change to 10.68.88.189
    Verify Enb All Cell On Air
    wait until keyword succeeds     5 min   10 sec     Connect to eNB via ssl    connection=enb
    ...    enb_index=${0}
    ${BTS_SW_Info}=   coam.get_software_info    timeout=${180}    connection=enb
    ${active_SW}=     Get from dictionary    ${BTS_SW_Info}    Active SW version
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    Update lssIPaddress Via RestAPI    mrbts_index=${mrbts_index}    AND
    ...    Run Keyword And Continue On Failure    TMO_Common_Case_Teardown    ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}    AND
    ...    run keyword and ignore error    Enblte close down    connection=enb


5605502_E2E_Rep_502_maxNumX2Links_test
    [Documentation]    Author:stella.lin@nokia-sbell.com
    ...       EXECUTION TESTLINE: TL080
    [Tags]     T080
    [Setup]    SetUp.TMO Case Common SetUp    is_first_gnb_used=${True}    ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}
#    #congiure enb1 x2 to tl080 gnb and tl282 gnb (on enb1)
#    Create LNADJGNB On ENB Side    dist_name=MRBTS-11213/LNBTS-11213/LNADJGNB-80    enb_index=${0}
    Run Keyword And Continue On Failure    Check LTEENB Status On Gnb Side    eNodeBId=11213
    Run Keyword And Continue On Failure    Check x2link Status On Enb Side    enb_index=${0}
#    #change maxNumX2Links on tl080 gnb : 256-->2
    Modify Parameter maxNumX2Links    value=2
##    #reset tl080 gnb
    Perform gNB Reset site and Wait Onair
#    #lock LNADJGNB-80 x2 on enb1
    Lock And Unlock LNADJGNB ON ENB    status=locked
#    #configure enb2 x2 to tl080 gnb (on enb2)
    Create LNADJGNB On ENB Side    dist_name=MRBTS-8131/LNBTS-8131/LNADJGNB-80    enb_index=${1}
    Sleep   20min
    Run Keyword And Continue On Failure    Check LTEENB Status On Gnb Side    eNodeBId=8131
    Run Keyword And Continue On Failure    Check x2link Status On Enb Side    enb_index=${1}
#    #unlock enb1 x2 on tl080 gnb
    Lock And Unlock LNADJGNB ON ENB    status=unlocked
    #check x2 status on enb2 on both enb and gnb side.
    Sleep   4min
    #check x2 links available on gnb
    ${available_enbs}    Check all x2link Status On Gnb Side
    ${available_enbs_length}     Get Length    ${available_enbs}
    Should Be True     '${available_enbs_length}'=='${2}'    msg=more than 2 x2 links are available on gnb.
    #check x2 links available on enb
    FOR    ${enb_id}    IN    @{available_enbs}
        ${is_enb}    Set Variable If    '${enb_id}'=='8131'    ${True}
        ...                             '${enb_id}'=='11213'     ${True}
        ...                             '${enb_id}'=='8080'    ${False}
        ${connection_index}    Set Variable If    '${enb_id}'=='8131'    ${1}
        ...                                       '${enb_id}'=='11213'     ${0}
        ...                                       '${enb_id}'=='8080'    ${0}
        Run Keyword If  ${is_enb}    Check x2link Status On Enb Side    enb_index=${connection_index}    status=available
        ...    ELSE    Check LNADJGNB Status On Gnb Side    status=available    gnb_index=${connection_index}
    END
    ${all_enb_ids}    Create List    ${8131}    ${11213}    ${8080}
    ${unavailable_enb}    Evaluate    list(set(${all_enb_ids})-set(${available_enbs}))
    ${enb_id}    Set Variable    ${unavailable_enb[0]}
    ${is_enb}    Set Variable If    '${enb_id}'=='8131'    ${True}
    ...                             '${enb_id}'=='11213'     ${True}
    ...                             '${enb_id}'=='8080'    ${False}
    ${connection_index}    Set Variable If    '${enb_id}'=='8131'    ${1}
    ...                                       '${enb_id}'=='11213'     ${0}
    ...                                       '${enb_id}'=='8080'    ${0}
    Run Keyword If  ${is_enb}    Check x2link Status On Enb Side    enb_index=${connection_index}    status=unavailable
    ...    ELSE    Check LNADJGNB Status On Gnb Side    status=unavailable    gnb_index=${connection_index}
    [Teardown]    Run Keywords
    ...    Run Keyword And Continue On Failure    Modify Parameter maxNumX2Links    AND
#    ...    Run Keyword And Continue On Failure    Delete LNADJGNB On ENB Side
#    ...    dist_name=MRBTS-11213/LNBTS-11213/LNADJGNB-80    enb_index=${0}    AND
    ...    Run Keyword And Continue On Failure    Delete LNADJGNB On ENB Side
    ...    dist_name=MRBTS-8131/LNBTS-8131/LNADJGNB-80    enb_index=${1}    AND    Sleep   17min    AND
    ...    Run Keyword And Continue On Failure    Perform gNB Reset site and Wait Onair    AND
    ...    TMO_Common_Case_Teardown    ue_index=${CASE_FOR_3CC_CHOOSED_UE['${tl_prefix}']}

5605011_E2E_Rep_011_1RedCapUE_1NonRedCapUe_L3_call
    [Tags]     T080
    [Setup]    SetUp.TMO Case Common SetUp    is_first_gnb_used=${True}    ue_index=${14}
    Delete NRREL Objects Based On Technology
    Modify PA Value Setting For Required RU    modify_ru_id=0
    ...    ue_index=${4}
    Enable RedCap Function
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=${PCELL_INDEX}
    ...    connection=GNB_OAM    timeout=300
#    #normal ue
    ${normal_ue_type}    translate_power_ue_type_from_testline    ue_index=${15}
    Set Test Variable    ${normal_ue_type}
    Run Keyword And Ignore Error     Reset UE Control PC If Connect Failed    ue_index=${14}
    Run Keyword And Ignore Error     Reset UE Control PC If Connect Failed    ue_index=${15}
    UE With ADB Reboot    ue_index=${14}
    UE With ADB Reboot    ue_index=${15}
    Wait Until Keyword Succeeds    3x    1min    Procedures.Start UE Prepare    ue_index=${15}    ue_type=${normal_ue_type}
    Wait Until Keyword Succeeds    3x    1min     M60_RedCap.Prepare UE    ue_index=${14}
    ${attach_info_normal_ue}    M60_RedCap.UE Attach    ue_index=${15}    expect_attach_cell_index=311    ue_type=${normal_ue_type}
    ${attach_info_redcap_ue}    M60_RedCap.UE Attach    ue_index=${14}    expect_attach_cell_index=311
    ${normal_ue_dl_port}    Set Variable     ${tl.ues[${15}].iperf_details.port}
    ${redcap_ue_dl_port}    Evaluate     ${normal_ue_dl_port}+1
    Set Test Variable    ${normal_ue_dl_port}
    Set Test Variable    ${redcap_ue_dl_port}
    Run Keyword And Continue On Failure    Procedures.Start TMO L3 Call    cpif_log_path=${attach_info_normal_ue['cpif_log_path']}
    ...                                    dl_throughput=1400MKbits/sec
    ...                                    ue_index=${15}
    ...                                    ul_throughput=250M
    ...                                    dl_port=${normal_ue_dl_port}
    ...                                    start_keep_on_duration=2400
    ${redcap_ue_ip}    M60_Redcap.Get UE IP    attach_cpif_log=${attach_info_redcap_ue['cpif_log_path']}
    M60_RedCap.Start DL traffic    ue_addr=${redcap_ue_ip}    ue_index=${14}     dl_throughput=150MKbits/sec
    ...    dl_port=${redcap_ue_dl_port}
    Sleep    20sec
    M60_RedCap.Prepare for UL traffic    ue_ip_addr=${redcap_ue_ip}    ue_index=${14}
    M60_RedCap.Start UL traffic    ue_ip=${redcap_ue_ip}    ue_index=${14}
    Sleep    60s
#    #--- Capture the TTiTrace log --- #
    ${status}    ${cell_301_ttitrace_file}    Run Keyword And Ignore Error    Capture TTI with gnb logs
    ...    bbmod_slots=5,6
    ...    cell_index=301
    ...    duration=5
    ...    direction=dlAndUl
    ...    tti_log_option=T
    ...    tti_package_file_name=tti_packed
    ${status}    ${cell_311_ttitrace_file}    Run Keyword And Ignore Error    Capture TTI with gnb logs
    ...    bbmod_slots=5,6
    ...    cell_index=311
    ...    duration=4
    ...    direction=dl
    ...    tti_log_option=T
    ...    tti_package_file_name=tti_packed
    log to console   ---start to check tput for source cell---
#    Run Keyword And Continue On Failure    M60_RedCap.Check Tput    cellid=301    expect_dl_tput=1310    expect_ul_tput=149
#    ...    duration=300
#    Run Keyword And Continue On Failure    M60_RedCap.Check Tput    cellid=311    expect_dl_tput=1170    direction=DL
#    ...    duration=300
    Run Keyword And Continue On Failure    M60_RedCap.Check Tput    cellid=311    expect_dl_tput=1170    expect_ul_tput=100
    ...    duration=300    min_percent=0.2
    Run Keyword And Continue On Failure    M60_RedCap.Check Tput    cellid=301    expect_dl_tput=1310    direction=DL
    ...    duration=300    min_percent=0.2
#    #--- Capture the TTiTrace log --- #
    ${status}    ${cell_311_ttitrace_file_long_time}    Run Keyword And Ignore Error    Capture TTI with gnb logs
    ...    bbmod_slots=5,6
    ...    cell_index=311
    ...    duration=5
    ...    direction=dlAndUl
    ...    tti_log_option=T
    ...    tti_package_file_name=tti_packed
    ${status}    ${cell_301_ttitrace_file_long_time}    Run Keyword And Ignore Error    Capture TTI with gnb logs
    ...    bbmod_slots=5,6
    ...    cell_index=301
    ...    duration=4
    ...    direction=dl
    ...    tti_log_option=T
    ...    tti_package_file_name=tti_packed
    #check tput per ue
    Run Keyword And Ignore Error    RepCase_5603147.Check Tput And Bler Per UE
    ...    pcell_tti_trace=${cell_311_ttitrace_file}
    ...    scell_tti_trace=${cell_301_ttitrace_file}
    Run Keyword And Ignore Error    RepCase_5603147.Check Tput And Bler Per UE
    ...    pcell_tti_trace=${cell_311_ttitrace_file_long_time}
    ...    scell_tti_trace=${cell_301_ttitrace_file_long_time}
    [Teardown]    Run Keywords    RepCase_5603147.Stop Traffic And Detach    AND
    ...    TMO_Common_Case_Teardown    ue_index=${15}    AND
    ...    SetUp.Precondition For First gNB   is_commission=${True}    check_rollback_is_needed=${False}    AND
    ...    csn.reset_cache

5605012_E2E_Rep_012_Shift_in_UL_Consistency_Metrics
    [Tags]     T080    T283
    [Setup]    SetUp.TMO Case Common SetUp    is_first_gnb_used=${True}    ue_index=${REPCASE_5605012_CHOOSED_UE['${tl_prefix}']}
    ...    is_commission_for_first_gnb=${True}
    ${report_timestamps_target_build}    KPI_Report_Case.Test Procedures
    ...                                  case_test_procedure_kw=TestCase.Reproduce_5605012
    ...                                  gnb_index=${0}
    Run Keyword And Continue On Failure     Generate Scout KPI Report For Target Build
    ...     report_timestamps_target_build=${report_timestamps_target_build}
    ...     gnb_index=${0}
    ...     kpi_report_filter_distnames=bts,NRCELL-301
    ...     comments=5605012
    FOR   ${index}    IN RANGE    0    10
        ${counter_name}     Set Variable    M55349C0600${index}
        ${counter}    Set Variable    ${reproduce_kpi_info_target_build['reproduce_kpi_values']['${counter_name}']}
        ${counter}    Convert To Integer    ${counter}
        Run Keyword And Continue On Failure    Should Be True    ${counter}==${0}
        ...    msg=${counter_name} is not all zero. value is ${counter}
    END
    ${M55349C06010}    Set Variable    ${reproduce_kpi_info_target_build['reproduce_kpi_values']['M55349C06010']}
    ${M55118C10005}    Set Variable    ${reproduce_kpi_info_target_build['reproduce_kpi_values']['M55118C10005']}
    ${M55349C06010_value}    Convert To Integer    ${M55349C06010}
    Run Keyword And Continue On Failure    Should Be True    ${M55349C06010}==${0}
    ...    msg=M55349C06010 is not all zero. value is ${M55349C06010}
    &{fault_49}     Create Dictionary     faultId=${49}
    &{fault_7308}     Create Dictionary     faultId=${7308}
    &{fault_7311}     Create Dictionary     faultId=${7311}
    Append To List     ${ALLOWED_HISTORY_FAULT}   ${fault_49}
    Append To List     ${ALLOWED_HISTORY_FAULT}   ${fault_7308}
    Append To List     ${ALLOWED_HISTORY_FAULT}   ${fault_7311}
    Set Test Variable    ${NEW_ALLOWED_HISTORY_FAULT}    ${ALLOWED_HISTORY_FAULT}
    log     ${NEW_ALLOWED_HISTORY_FAULT}
    [Teardown]    Run Keywords
    ...    Run Keyword And Continue On Failure    Lock Or Unlock Single Cell    cell_index=1    action=unblock    AND
    ...    Run keyword If    '${tl_prefix}'=='T080'    Run Keyword And Continue On Failure    Lock Or Unlock Single Cell
    ...    cell_index=11    cell_type=lte    action=unblock
    ...    AND    Sleep    2min    AND
    ...    Run Keyword And Continue On Failure    TMO_Common_Case_Teardown    ue_index=${REPCASE_5605012_CHOOSED_UE['${tl_prefix}']}
    ...    allowed_history_faults=${NEW_ALLOWED_HISTORY_FAULT}    is_save_snapshot=${True}
    ...    AND
    ...    SetUp.Precondition For First gNB   is_commission=${True}    check_rollback_is_needed=${False}    AND
    ...    csn.reset_cache

5605013_E2E_Rep_013 C007447 CPRI forwarding functionality validation for Dual core FDD RU with RFS configuration
    [Tags]     T813    T284
    [Setup]    SetUp.TMO Case Common SetUp    is_first_gnb_used=${True}    ue_index=${REPCASE_5605006_CHOOSED_UE['${tl_prefix}']}
    ...    is_commission_for_first_gnb=${True}
#    Create Case Log Path
    Rep5605013.Parameter Modification
    #do ru reset
    ${selected_ru_index}    Set Variable If    '${tl_prefix}'=='T813'    7
    ...                                        '${tl_prefix}'=='T284'    1
    Perform RU Reset    ru_index=${selected_ru_index}
    Check TMO Gnb Ready And All Cell On Air
    Verify All Enbs Cell On Air
    ${lte_first_port_number}    ${nr_first_port_number}    Get_Lte_And_Nr_First_Port_Number   rmod_index=${selected_ru_index}
    log to console    ${lte_first_port_number}
    log to console    ${nr_first_port_number}
    ${hlapi_state_log_path}    RepCase_5605013.Get_RU_Hlapi_State_Log    ru_index=${selected_ru_index}
    Run Keyword And Continue On Failure    RepCase_5605013.Check_Delay_UTU_Result    ru_log_path=${hlapi_state_log_path}
    ...    lte_port_number=${lte_first_port_number}   nr_port_number=${nr_first_port_number}
    #do gnb reset
    ${timestamp_gnb_reset}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    Perform gNB Reset site and Wait Onair
    Verify All Enbs Cell On Air
    ${up_times}    Run Keyword And Continue On Failure     Get_RU_Update_Time     ru_index=${selected_ru_index}
    ${timestamp_gnb_after}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${times_diff_gnb_reset}    Subtract Date From Date    ${timestamp_gnb_after}    ${timestamp_gnb_reset}
    Should Be True    ${up_times}>${times_diff_gnb_reset}    msg=RU is reseted when gnb restart
    ${lte_first_port_number}    ${nr_first_port_number}    Get_Lte_And_Nr_First_Port_Number    rmod_index=${selected_ru_index}
    ${hlapi_state_log_path}    RepCase_5605013.Get_RU_Hlapi_State_Log    ru_index=${selected_ru_index}
    Run Keyword And Continue On Failure    RepCase_5605013.Check_Delay_UTU_Result    ru_log_path=${hlapi_state_log_path}
    ...    lte_port_number=${lte_first_port_number}   nr_port_number=${nr_first_port_number}
    #do enb reset
    ${timestamp_enb_reset}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    Perform eNB Reset site and Wait Onair
    Check TMO Gnb Ready And All Cell On Air
    ${up_times}    Run Keyword And Continue On Failure     Get_RU_Update_Time     ru_index=${selected_ru_index}
    ${timestamp_enb_after}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${times_diff_enb_reset}    Subtract Date From Date    ${timestamp_enb_after}    ${timestamp_enb_reset}
    Should Be True    ${up_times}>${times_diff_gnb_reset}    msg=RU is reseted when enb restart
    ${lte_first_port_number}    ${nr_first_port_number}    Get_Lte_And_Nr_First_Port_Number     rmod_index=${selected_ru_index}
    ${hlapi_state_log_path}    RepCase_5605013.Get_RU_Hlapi_State_Log    ru_index=${selected_ru_index}
    Run Keyword And Continue On Failure    RepCase_5605013.Check_Delay_UTU_Result    ru_log_path=${hlapi_state_log_path}
    ...    lte_port_number=${lte_first_port_number}   nr_port_number=${nr_first_port_number}

5605014_E2E_Rep_014_Alarm_8150_with_more_than_14_unknown_PCI_cancelling_after_NSA_ANR_activate_online
    [Tags]     T080
    [Setup]    SetUp.TMO Case Common SetUp    is_first_gnb_used=${True}    ue_index=${REPCASE_5605014_CHOOSED_UE['${tl_prefix}']}
    ...    is_commission_for_first_gnb=${True}    is_second_gnb_used=${True}    is_commission_for_second_gnb=${True}
    TestCase.Reproduce_5605014
    &{fault_8150}     Create Dictionary     faultId=${8150}
    &{fault_7308}     Create Dictionary     faultId=${7308}
    &{fault_7311}     Create Dictionary     faultId=${7311}
    Append To List     ${ALLOWED_HISTORY_FAULT}   ${fault_8150}
    Append To List     ${ALLOWED_HISTORY_FAULT}   ${fault_7308}
    Append To List     ${ALLOWED_HISTORY_FAULT}   ${fault_7311}
    Set Test Variable    ${NEW_ALLOWED_HISTORY_FAULT}    ${ALLOWED_HISTORY_FAULT}
    log     ${NEW_ALLOWED_HISTORY_FAULT}
    [Teardown]    Run Keywords  Run Keyword And Continue On Failure    TMO_Common_Case_Teardown
    ...    ue_index=${REPCASE_5605014_CHOOSED_UE['${tl_prefix}']}    allowed_history_faults=${NEW_ALLOWED_HISTORY_FAULT}    AND
    ...    Run Keyword And Continue On Failure    SetUp.Precondition For First gNB   is_commission=${True}
    ...    check_rollback_is_needed=${False}    AND
    ...    Run Keyword And Continue On Failure    SetUp.Precondition For Second gNB   is_commission=${True}
    ...    check_rollback_is_needed=${False}    AND   csn.reset_cache

[1]SR-A-Energy-Consumption_Measurement_CNF_EE_13
    [Setup]    robot_common_operations.Common Case Setup    fail_with_alarms=${True}
    ${gnb_allowed_fault_Before_Commission}   Create List    4203    1838    4741    4681   7311   7331    7107
    ...                                                     4293    4297    4420    4775   1932   1934    1933    8150
    ...                                                     4589    6261    4776    4569    8000    1927
    Set Test Variable    ${gnb_allowed_fault_Before_Commission}
    robot_common_operations.Common Case Setup    fail_with_alarms=${False}
    AlarmWatchdog.add_allow_alarms    fault_id=${gnb_allowed_fault_Before_Commission}
#    ${rus}     Catenate    RMOD-1,RMOD-2,RMOD-3,RMOD-4,RMOD-5,RMOD-6,RMOD-7,RMOD-8,RMOD-9,RMOD-10,RMOD-11,RMOD-12
#    ${all_cell_list}    Catenate    NRCELL-301,NRCELL-302,NRCELL-303,NRCELL-351,NRCELL-352,NRCELL-353,
#    ...    ,NRCELL-1,NRCELL-2,NRCELL-3,NRCELL-21,NRCELL-22,NRCELL-23
    Run Keyword And Ignore Error    SetUp.Precondition For First gNB   is_commission=${True}
    ...    check_rollback_is_needed=${False}    gnb_scf_name=${tl_prefix}_gNB_25R3_for_EE_13.xml
    Connect to gnb coam via ssl    connection=GNB_OAM     gnb_index=${0}
#    Run Keyword And Continue On Failure       Run ETSI Test Model in Loop
    Run Keyword And Continue On Failure        Run Energy Efficiency Measurement Procedure
    ...    connection=GNB_OAM
#    ...    load_levels=load_0_low,load_30_medium,load_50_busy_hour
#    ...     rus=${rus}
    ...    cells=${None}
#    ...    cells=${all_cell_list}
    ...    rus=${None}
    ...    measurment_duration=5400
    Run Keyword and Ignore Error    taf.sw.reporting_portal.Set Reference Configuration Id    CNF_EE_13
#    Run Keyword And Ignore Error    Perform gNB Reset site and Wait Onair
    [Teardown]    Run Keywords
    ...    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown    AND
    ...    run keyword and ignore error    COAM Teardown gnb connections    connection=GNB_OAM    AND
    ...    Run Keyword And Continue On Failure    SetUp.Precondition For First gNB   is_commission=${True}
    ...    check_rollback_is_needed=${False}

[1]SR-A-Energy-Consumption_Measurement_CNF_EE_2b
    [Setup]    robot_common_operations.Common Case Setup    fail_with_alarms=${True}
#    ${rus}     Catenate    RMOD-1,RMOD-2,RMOD-3,RMOD-4,RMOD-5,RMOD-6,RMOD-7,RMOD-8,RMOD-9,RMOD-10,RMOD-11,RMOD-12
    ${gnb_allowed_fault_Before_Commission}   Create List    4203    1838    4741    4681   7311   7331    7107
    ...                                                     4293    4297    4420    4775   1932   1934    1933    8150
    ...                                                     4589    6261    4776    4569    8000    10    6327
    Set Test Variable    ${gnb_allowed_fault_Before_Commission}
    robot_common_operations.Common Case Setup    fail_with_alarms=${False}
    AlarmWatchdog.add_allow_alarms    fault_id=${gnb_allowed_fault_Before_Commission}
    Perform RU Power Off    ru_index=10
    Perform RU Power Off    ru_index=11
    Perform RU Power Off    ru_index=12
    Perform RU Power Off    ru_index=13
    Perform RU Power Off    ru_index=14
    Perform RU Power Off    ru_index=15
    Sleep    1min
    Run Keyword And Ignore Error    SetUp.Precondition For First gNB   is_commission=${True}
    ...    check_rollback_is_needed=${False}    gnb_scf_name=${tl_prefix}_gNB_26R1_for_EE_2b.xml    is_pdl_checking_needed=${False}
    Connect to gnb coam via ssl    connection=GNB_OAM     gnb_index=${0}
    ${all_cell_list}    Catenate    NRCELL-301,NRCELL-302,NRCELL-303,NRCELL-1,NRCELL-2,NRCELL-3,NRCELL-21,NRCELL-22,
    ...    ,NRCELL-23,NRCELL-311,NRCELL-312,NRCELL-313,
    ...    ,LNCEL-11,LNCEL-12,LNCEL-13,LNCEL-21,LNCEL-22,LNCEL-23,LNCEL-31,LNCEL-32,LNCEL-33,LNCEL-61,LNCEL-62,LNCEL-63
#    Run Keyword And Continue On Failure       Run ETSI Test Model in Loop
    Run Keyword And Continue On Failure        Run Energy Efficiency Measurement Procedure
    ...    connection=GNB_OAM
#    ...    load_levels=load_0_low,load_30_medium,load_50_busy_hour
    ...    load_levels=Idle,Low,Medium,Busy,Full
#    ...    load_levels=Idle
    ...    cells=${all_cell_list}
    ...    rus=${None}
    ...    measurment_duration=5400
    Run Keyword and Ignore Error    taf.sw.reporting_portal.Set Reference Configuration Id    CNF_EE_2c
#    Run Keyword And Ignore Error     Create Case Log Path
#    Run Keyword And Ignore Error     Save Current SCF And Save Snapshot
    [Teardown]    Run Keywords        Run Keyword And Continue On Failure    Perform RU Power On    ru_index=10    AND
    ...    Run Keyword And Continue On Failure    Perform RU Power On    ru_index=11    AND
    ...    Run Keyword And Continue On Failure    Perform RU Power On    ru_index=12    AND
    ...    Run Keyword And Continue On Failure    Perform RU Power On    ru_index=13    AND
    ...    Run Keyword And Continue On Failure    Perform RU Power On    ru_index=14    AND
    ...    Run Keyword And Continue On Failure    Perform RU Power On    ru_index=15    AND    Sleep    15min    AND
    ...    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown    AND
    ...    run keyword and ignore error    COAM Teardown gnb connections    connection=GNB_OAM    AND
    ...    run keyword and ignore error    SetUp.Precondition For First gNB   is_commission=${True}
    ...    check_rollback_is_needed=${False}

CB007163_12_EN-DC Handover to preferred layer after incoming handover from inter-eNB cell with EN-DC without MR-DC capability retrieval needed
    [Tags]     T816
    [Setup]    SetUp.TMO Case Common SetUp    is_first_gnb_used=${True}    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    ...    is_commission_for_first_gnb=${True}
    #precondition
    Run Keyword And Continue On Failure    Set All LTE Cell To Barred Status
    Run Keyword And Continue On Failure    Set All NR Cell To Barred Status
    Run Keyword And Continue On Failure    CB007163 Params modification
    Check TMO Gnb Ready And All Cell On Air
#    Backup and Modify swconfig file    swconfig_modify=@{CB07334_flag}
#    Perform gNB Reset site and Wait Onair
    Run Keyword And Ignore Error    UE With ADB Reboot    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    Modify PA Value Setting For Required RU    modify_ru_id=0
    ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    ...    pa_off_value=${15}
    Modify PA Value Setting For Required RU    modify_ru_id=2
    ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    ...    pa_off_value=${10}
    Procedures.Start UE Prepare    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}   ue_type=${ue_type}
    ...    get_spark_license=${False}
    log to console  INFO:--start attach-
#    power_ue.UE Attach    ue_type=${ue_type}    attach_mode=5G_NSA    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    Get Syslog Start Time
    ${attach_info}    Procedures.Start TMO Attach    ue_mode=NSA
    ...                                              ue_type=${ue_type}
    ...                                              ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    ...                                              4G_check=False
    log to console    INFO:--start to l3 call
    Start DL traffic via iperf on Appserver    ue_addr=${tl816_ue_addr}
    ...                                        dl_time=3600
    ...                                        dl_port=${tl.ues[${CB007163_CHOOSED_UE['${tl_prefix}']}].iperf_details.port}
    ...                                        dl_throughput=5MKbits/sec
    ...                                        dl_length=1400B
    ...                                        appserver=APPserver
    ...                                        protocol=udp
    ...                                        ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    ...                                        process_num=${2}
    ...                                        seg_size=${1372}
    ...                                        window=2M
    Sleep   1min
    Run Keyword And Continue On Failure    M60_RedCap.Check Tput    direction=DL    expect_dl_tput=10    cellid=301    duration=90
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    Connect to Common Unit Master     alias=ASIK Master0   gnb_index=${0}
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log
    ...    tcpdump_collector_name=wireshark_${timestamp}
    ...    asik_connection_alias=ASIK Master0
    ...    gnb_index=${0}
    ...    du_index=0
    Sleep   30sec
    Modify PA Value Setting For Required RU    modify_ru_id=5
    ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    ...    pa_off_value=${20}
    Sleep   1min
    Run Keyword And Continue On Failure    M60_RedCap.Check Tput    direction=DL    expect_dl_tput=10    cellid=301    duration=90
    Modify PA Value Setting For Required RU    modify_ru_id=5
    ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    ...    pa_off_value=${127}
    Sleep   1min
    Run Keyword And Continue On Failure    M60_RedCap.Check Tput    direction=DL    expect_dl_tput=10    cellid=301    duration=90
    CB007163 HO Params modification
    Check TMO Gnb Ready And All Cell On Air
    Modify PA Value Setting For Required RU    modify_ru_id=5
    ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    ...    pa_off_value=${20}
    ${ho_wireshark}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...    tcpdump_collector_name=wireshark_${timestamp}
    ...    target_dir=${TS_CASE_LOG_PATH}
    ...    asik_connection_alias=ASIK Master0
    Sleep   1min
    Run Keyword And Continue On Failure    M60_RedCap.Check Tput    direction=DL    expect_dl_tput=10    cellid=301    duration=90
    ${syslog_file}    Run Keyword And Continue On Failure    Get Syslog File During Specific Time    syslog_start_time=${SYSLOG_START_TIME}
    ${syslog_file_path}    Run Keyword And Continue On Failure   Evaluate    '/'.join(${syslog_file.split('/')[0:-1]})
    Run Keyword And Ignore Error    Check ERR Or WRN From Syslog    sys_logs_path=${syslog_file_path}
    ...     UTE_logs_path=/home/ute/ERR_WRN_logs    Fail_Case=True    Check_RF_Log=True    timeout=50 minutes
    Run Keyword And Continue On Failure    Check ERR Syslog Existed
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    Close the iperf process on APPserver
    ...    port=${tl.ues[${CB007163_CHOOSED_UE['${tl_prefix}']}].iperf_details.port}     AND
    ...    Run Keyword And Continue On Failure    TMO_Common_Case_Teardown    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}    AND
    ...    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown    AND
    ...    run keyword and ignore error    COAM Teardown gnb connections    connection=GNB_OAM
    ...    AND
    ...    Run Keyword And Continue On Failure    SetUp.Precondition For First gNB   is_commission=${True}
    ...    check_rollback_is_needed=${False}

CB007035-SR-A-19 NR SBHO is triggered based on received NR SBHO B1-NR measurement report
    [Tags]     T816
    [Setup]    SetUp.TMO Case Common SetUp    is_first_gnb_used=${True}    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    ...    is_commission_for_first_gnb=${True}     test_case_prefix=CB007035
    #precondition
    Run Keyword And Continue On Failure    Set All LTE Cell To Barred Status
    Run Keyword And Continue On Failure    Set All NR Cell To Barred Status
    Run Keyword And Continue On Failure    CB007035 Params modification
    Check TMO Gnb Ready And All Cell On Air
    Backup and Modify swconfig file    swconfig_modify=@{CB07334_flag}
    Perform gNB Reset site and Wait Onair
    Connect to gnb coam via ssl    connection=GNB_0AM   gnb_index=${0}
    ${cur_scf_file}    coam_gnb_classical.COAM Download scf from cluster
    ...    scf_dir_path=${TS_CASE_LOG_PATH}    connection=GNB_0AM
    ${scf_with_update_tac}    perform_update_scf_params
    ...                          update_params=@{scf_update_params_tac}
    ...                          basic_scf_path=${cur_scf_file}
    ...                          update_scf_path=${TS_CASE_LOG_PATH}/CB005825_SCF.xml
    Perform Commission    scf_file_path=${scf_with_update_tac}
    ...                                                                      gnb_index=${0}
    ...                                                                      timeout_for_commission=900
    ...                                                                      wait_gnb_up_timeout=30 min
    ...                                                                      is_pdl_checking_needed=${True}
    Run Keyword And Ignore Error    UE With ADB Reboot    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    Modify PA Value Setting For Required RU    modify_ru_id=5
    ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    ...    pa_off_value=${30}
    Procedures.Start UE Prepare    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}   ue_type=${ue_type}
    ...    get_spark_license=${False}
    log to console  INFO:--start attach-
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    Connect to Common Unit Master     alias=ASIK Master0   gnb_index=${0}
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log
    ...    tcpdump_collector_name=gnb_5825_${timestamp}
    ...    asik_connection_alias=ASIK Master0
    ...    gnb_index=${0}
    ...    du_index=0
    Run Keyword And Continue On Failure    Start tcpdump Log On Enb     tcpdump_collector_name=enb_5825_${timestamp}
    ...                                                                 is_multi_rat=${True}
    ...            enb_host=${None}
    ...            enb_user=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...            enb_password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    Sleep   30sec
    log to console     start to test CB005825
    Get Syslog Start Time
    power_ue.UE Attach    ue_type=${ue_type}    attach_mode=5G_NSA    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
#    ${attach_info}    Procedures.Start TMO Attach    ue_mode=NSA
#    ...                                              ue_type=${ue_type}
#    ...                                              ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
#    ...                                              4G_check=False
#    Sleep    2sec
    Modify PA Value Setting For Required RU    modify_ru_id=1
    ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    ...    pa_off_value=${33}
#    Sleep    1sec
    Modify PA Value Setting For Required RU    modify_ru_id=5
    ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    ...    pa_off_value=${55}
    Sleep    10sec
    FOR    ${i}    IN RANGE    15
        Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
        Modify PA Value Setting For Required RU    modify_ru_id=1
        ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
        ...    pa_off_value=${127}
        Modify PA Value Setting For Required RU    modify_ru_id=5
        ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
        ...    pa_off_value=${30}
        power_ue.UE Attach    ue_type=${ue_type}    attach_mode=5G_NSA    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
#        Sleep    2sec
        Modify PA Value Setting For Required RU    modify_ru_id=1
        ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
        ...    pa_off_value=${33}
#        Sleep    1sec
        Modify PA Value Setting For Required RU    modify_ru_id=5
        ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
        ...    pa_off_value=${55}
        Sleep    8sec
    END
    log to console    INFO:--start to l3 call
    Start DL traffic via iperf on Appserver    ue_addr=${tl816_ue_addr}
    ...                                        dl_time=3600
    ...                                        dl_port=${tl.ues[${CB007163_CHOOSED_UE['${tl_prefix}']}].iperf_details.port}
    ...                                        dl_throughput=5MKbits/sec
    ...                                        dl_length=1400B
    ...                                        appserver=APPserver
    ...                                        protocol=udp
    ...                                        ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    ...                                        process_num=${2}
    ...                                        seg_size=${1372}
    ...                                        window=2M
    Sleep   30sec
    ${ho_5825_wireshark}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...    tcpdump_collector_name=gnb_5825_${timestamp}
    ...    target_dir=${TS_CASE_LOG_PATH}
    ...    asik_connection_alias=ASIK Master0
    Run Keyword And Continue On Failure    Stop tcpdump log collection    tcpdump_collector_name=enb_5825_${timestamp}
    M60_RedCap.Check Tput    direction=DL    expect_dl_tput=10    cellid=302    duration=60
#    Run Keyword And Continue On Failure    M60_RedCap.Check Tput    direction=DL    expect_dl_tput=10    cellid=302    duration=60
    Modify PA Value Setting For Required RU    modify_ru_id=1
    ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    ...    pa_off_value=${127}
    Modify PA Value Setting For Required RU    modify_ru_id=5
    ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    ...    pa_off_value=${20}
    Sleep    30sec
    log to console     start to test CB007035
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
#    CB007035 Params modification after ANR
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log
    ...    tcpdump_collector_name=gnb_7035_${timestamp}
    ...    asik_connection_alias=ASIK Master0
    ...    gnb_index=${0}
    ...    du_index=0
    Run Keyword And Continue On Failure    Start tcpdump Log On Enb     tcpdump_collector_name=enb_7035_${timestamp}
    ...                                                                 is_multi_rat=${True}
    ...            enb_host=${None}
    ...            enb_user=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...            enb_password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    Sleep  30sec
    power_ue.UE Attach    ue_type=${ue_type}    attach_mode=5G_NSA    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    Sleep   5sec
    Modify PA Value Setting For Required RU    modify_ru_id=1
    ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    ...    pa_off_value=${26}
    Sleep   30sec
    Run Keyword And Continue On Failure    M60_RedCap.Check Tput    direction=DL    expect_dl_tput=10    cellid=302    duration=60
    ${ho_7035_wireshark}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...    tcpdump_collector_name=gnb_7035_${timestamp}
    ...    target_dir=${TS_CASE_LOG_PATH}
    ...    asik_connection_alias=ASIK Master0
    Run Keyword And Continue On Failure    Stop tcpdump log collection    tcpdump_collector_name=enb_7035_${timestamp}
    ${syslog_file}    Run Keyword And Continue On Failure    Get Syslog File During Specific Time    syslog_start_time=${SYSLOG_START_TIME}
    ${syslog_file_path}    Run Keyword And Continue On Failure   Evaluate    '/'.join(${syslog_file.split('/')[0:-1]})
    Run Keyword And Ignore Error    Check ERR Or WRN From Syslog    sys_logs_path=${syslog_file_path}
    ...     UTE_logs_path=/home/ute/ERR_WRN_logs    Fail_Case=True    Check_RF_Log=True    timeout=50 minutes
    Run Keyword And Continue On Failure    Check ERR Syslog Existed
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    Close the iperf process on APPserver
    ...    port=${tl.ues[${CB007163_CHOOSED_UE['${tl_prefix}']}].iperf_details.port}     AND
    ...    Run Keyword And Continue On Failure    TMO_Common_Case_Teardown    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}    AND
    ...    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown    AND
    ...    run keyword and ignore error    COAM Teardown gnb connections    connection=GNB_OAM
    ...    AND
    ...    Run Keyword And Continue On Failure    SetUp.Precondition For First gNB   is_commission=${True}
    ...    check_rollback_is_needed=${False}

CNI-145514-A-TC13_CVR001_Redirect to 5G N41 based on B1-NR measurement fulfilling RSRP threshold_UE in LTE without EN-DC and user inactivity detected
    [Tags]     T816
    [Setup]    SetUp.TMO Case Common SetUp    is_first_gnb_used=${True}    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    ...    is_commission_for_first_gnb=${True}     test_case_prefix=CNI_145514
    #precondition
    Run Keyword And Continue On Failure    Set All LTE Cell To Barred Status
    Run Keyword And Continue On Failure    Set All NR Cell To Barred Status
    Run Keyword And Continue On Failure    CNI145514 Params modification
    Check TMO Gnb Ready And All Cell On Air
#    Backup and Modify swconfig file    swconfig_modify=@{CB07334_flag}
#    Perform gNB Reset site and Wait Onair
    Connect to gnb coam via ssl    connection=GNB_0AM   gnb_index=${0}
    ${cur_scf_file}    coam_gnb_classical.COAM Download scf from cluster
    ...    scf_dir_path=${TS_CASE_LOG_PATH}    connection=GNB_0AM
    ${scf_with_update_tac}    perform_update_scf_params
    ...                          update_params=@{scf_update_params_tac}
    ...                          basic_scf_path=${cur_scf_file}
    ...                          update_scf_path=${TS_CASE_LOG_PATH}/CNI145514_SCF.xml
    Perform Commission    scf_file_path=${scf_with_update_tac}
    ...                                                                      gnb_index=${0}
    ...                                                                      timeout_for_commission=900
    ...                                                                      wait_gnb_up_timeout=30 min
    ...                                                                      is_pdl_checking_needed=${True}
    Run Keyword And Ignore Error    UE With ADB Reboot    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    Modify PA Value Setting For Required RU    modify_ru_id=5
    ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    ...    pa_off_value=${20}
    Procedures.Start UE Prepare    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}   ue_type=${ue_type}
    ...    get_spark_license=${False}
    log to console  INFO:--start attach-
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    Connect to Common Unit Master     alias=ASIK Master0   gnb_index=${0}
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log
    ...    tcpdump_collector_name=gnb_${timestamp}
    ...    asik_connection_alias=ASIK Master0
    ...    gnb_index=${0}
    ...    du_index=0
    Run Keyword And Continue On Failure    Start tcpdump Log On Enb     tcpdump_collector_name=enb_${timestamp}
    ...                                                                 is_multi_rat=${True}
    ...            enb_host=${None}
    ...            enb_user=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...            enb_password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    Sleep   30sec
    Get Syslog Start Time
    power_ue.UE Attach    ue_type=${ue_type}    attach_mode=5G_NSA    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
#    ${attach_info}    Procedures.Start TMO Attach    ue_mode=NSA
#    ...                                              ue_type=${ue_type}
#    ...                                              ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
#    ...                                              4G_check=False
    Modify PA Value Setting For Required RU    modify_ru_id=1
    ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    ...    pa_off_value=${26}
    Sleep    14min
    log to console    INFO:--start to l3 call
    Start DL traffic via iperf on Appserver    ue_addr=${tl816_ue_addr}
    ...                                        dl_time=3600
    ...                                        dl_port=${tl.ues[${CB007163_CHOOSED_UE['${tl_prefix}']}].iperf_details.port}
    ...                                        dl_throughput=5MKbits/sec
    ...                                        dl_length=1400B
    ...                                        appserver=APPserver
    ...                                        protocol=udp
    ...                                        ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    ...                                        process_num=${2}
    ...                                        seg_size=${1372}
    ...                                        window=2M
    Run Keyword And Continue On Failure    M60_RedCap.Check Tput    direction=DL    expect_dl_tput=10    cellid=302    duration=120
    ${redirct_wireshark}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...    tcpdump_collector_name=gnb_${timestamp}
    ...    target_dir=${TS_CASE_LOG_PATH}
    ...    asik_connection_alias=ASIK Master0
    Run Keyword And Continue On Failure    Stop tcpdump log collection    tcpdump_collector_name=enb_${timestamp}
    ${syslog_file}    Run Keyword And Continue On Failure    Get Syslog File During Specific Time    syslog_start_time=${SYSLOG_START_TIME}
    ${syslog_file_path}    Run Keyword And Continue On Failure   Evaluate    '/'.join(${syslog_file.split('/')[0:-1]})
    Run Keyword And Ignore Error    Check ERR Or WRN From Syslog    sys_logs_path=${syslog_file_path}
    ...     UTE_logs_path=/home/ute/ERR_WRN_logs    Fail_Case=True    Check_RF_Log=True    timeout=50 minutes
    Run Keyword And Continue On Failure    Check ERR Syslog Existed
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    Close the iperf process on APPserver
    ...    port=${tl.ues[${CB007163_CHOOSED_UE['${tl_prefix}']}].iperf_details.port}     AND
    ...    Run Keyword And Continue On Failure    TMO_Common_Case_Teardown    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}    AND
    ...    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown    AND
    ...    run keyword and ignore error    COAM Teardown gnb connections    connection=GNB_OAM
    ...    AND
    ...    Run Keyword And Continue On Failure    SetUp.Precondition For First gNB   is_commission=${True}
    ...    check_rollback_is_needed=${False}

CB012474_Reattempt of EN-DC Configuration Update procedure with X2 link becoming temporarily unavailable
    [Tags]     T816
    [Setup]    SetUp.TMO Case Common SetUp    is_first_gnb_used=${True}    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    ...    is_commission_for_first_gnb=${True}     test_case_prefix=CB012474
    Get Syslog Start Time
    CB012474 Params modification
    Update Cell Status    administrativeState=Locked
    Run Keyword if   '${tl_prefix}'=='T816'    Parameter maxParallelIncX2SetupOrECUOvl0 Modification    value=0
    ...    ELSE IF   '${tl_prefix}'=='T813'    Parameter maxParallelIncX2SetupOrECUOvl0 Modification on enb    value=0
#    ${sleep_seconds}    Caculate timeToSleep Before Next Counters Period
#    Sleep    ${sleep_seconds}sec
    Update Cell Status    administrativeState=Unlocked
#    Check TMO Gnb Ready And All Cell On Air
    ${timestamp_unlock}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${counter_generatd_time}    robot.libraries.DateTime.Convert Date 	  ${timestamp_unlock}    epoch
    ${bts_Name}    Get Bts Name For Gnb    gnb_id=${0}
    Sleep    6min
    ${source}    Set Variable IF    '${tl_prefix}'=='T816'    [${bts_Name}][D510_Sector1] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-301
    ...    '${tl_prefix}'=='T813'    [${bts_Name}][A9LV1039A11] MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-301
    run keyword and ignore error    COAM Teardown gnb connections    connection=GNB_OAM
#    Connect to gnb coam via ssl    connection=GNB_0AM   gnb_index=${0}
    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    5min    20sec     Expect Fault Should Present    faultId=7101
    ...   source=${None}
#    ...   is_need_to_setup_gnb_connection=${False}
    Run Keyword if   '${tl_prefix}'=='T816'    Parameter maxParallelIncX2SetupOrECUOvl0 Modification    value=10
    ...    ELSE IF   '${tl_prefix}'=='T813'    Parameter maxParallelIncX2SetupOrECUOvl0 Modification on enb    value=10
#    Sleep    10min
    run keyword and ignore error    COAM Teardown gnb connections    connection=GNB_OAM
#    Connect to gnb coam via ssl    connection=GNB_0AM   gnb_index=${0}
    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    15min    30sec     Expect Fault Should Absent    faultId=7101
#    ...    is_need_to_setup_gnb_connection=${False}
    Run Keyword And Continue On Failure    Check Counter M55110C00040    counter_generatd_time=${counter_generatd_time}
    Run Keyword And Continue On Failure    Check TMO Gnb Ready And All Cell On Air
    ${syslog_file}    Run Keyword And Continue On Failure    Get Syslog File During Specific Time    syslog_start_time=${SYSLOG_START_TIME}
    ${syslog_file_path}    Run Keyword And Continue On Failure   Evaluate    '/'.join(${syslog_file.split('/')[0:-1]})
    Run Keyword And Ignore Error    Check ERR Or WRN From Syslog    sys_logs_path=${syslog_file_path}
    ...     UTE_logs_path=/home/ute/ERR_WRN_logs    Fail_Case=True    Check_RF_Log=True    timeout=50 minutes
    Run Keyword And Continue On Failure    Check ERR Syslog Existed
    [Teardown]    Run Keywords
    ...    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown    AND
    ...    run keyword and ignore error    COAM Teardown gnb connections    connection=GNB_OAM
    ...    AND
    ...    Run Keyword And Continue On Failure    SetUp.Precondition For First gNB   is_commission=${True}
    ...    check_rollback_is_needed=${False}


CB007334_01_LNRELGNBCELL removal due to insufficient frequency of B1-NR MR
    [Tags]     T816
    [Setup]    SetUp.TMO Case Common SetUp    is_first_gnb_used=${True}    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    ...    is_commission_for_first_gnb=${True}     test_case_prefix=CB007334
    Run Keyword And Continue On Failure    Set All LTE Cell To Barred Status
    Run Keyword And Continue On Failure    Set All NR Cell To Barred Status
    CB007334 Params modification
    Check TMO Gnb Ready And All Cell On Air
    Connect to gnb coam via ssl    connection=GNB_0AM   gnb_index=${0}
    ${cur_scf_file}    coam_gnb_classical.COAM Download scf from cluster
    ...    scf_dir_path=${TS_CASE_LOG_PATH}    connection=GNB_0AM
    Backup and Modify swconfig file    swconfig_modify=@{CB07334_flag}
    Perform gNB Reset site and Wait Onair
    Run Keyword And Ignore Error    UE With ADB Reboot    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    Modify PA Value Setting For Required RU    modify_ru_id=5
    ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    ...    pa_off_value=${20}
    Modify PA Value Setting For Required RU    modify_ru_id=0
    ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    ...    pa_off_value=${20}
    Procedures.Start UE Prepare    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}   ue_type=${ue_type}
    ...    get_spark_license=${False}
#    Connect to Common Unit Master     alias=ASIK Master0   gnb_index=${0}
#    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log
#    ...    tcpdump_collector_name=gnb_7334_add_${timestamp}
#    ...    asik_connection_alias=ASIK Master0
#    ...    gnb_index=${0}
#    ...    du_index=0
#    Run Keyword And Continue On Failure    Start tcpdump Log On Enb     tcpdump_collector_name=enb_7334_add_${timestamp}
#    ...                                                                 is_multi_rat=${True}
#    ...            enb_host=${None}
#    ...            enb_user=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
#    ...            enb_password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
#    Sleep   30sec
    Get Syslog Start Time
    log to console  INFO:--start to add 255-
    FOR    ${item}    IN RANGE    ${9}
        run keyword and ignore error    power_ue.UE Attach    ue_type=${ue_type}    attach_mode=5G_NSA
        ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
        Sleep    20sec
        run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}
        ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    END
#    ${add_wireshark}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
#    ...    tcpdump_collector_name=gnb_7334_add_${timestamp}
#    ...    target_dir=${TS_CASE_LOG_PATH}
#    ...    asik_connection_alias=ASIK Master0
#    Run Keyword And Continue On Failure    Stop tcpdump log collection    tcpdump_collector_name=enb_7334_add_${timestamp}
    log to console  INFO:--start to add 254-
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    ${255_timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    Modify PA Value Setting For Required RU    modify_ru_id=5
    ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    ...    pa_off_value=${20}
    Modify PA Value Setting For Required RU    modify_ru_id=0
    ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    ...    pa_off_value=${127}
    Modify PA Value Setting For Required RU    modify_ru_id=1
    ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    ...    pa_off_value=${30}
    FOR    ${item}    IN RANGE    ${13}
        run keyword and ignore error    power_ue.UE Attach    ue_type=${ue_type}    attach_mode=5G_NSA
        ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
        Sleep    20sec
        run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}
        ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    END
    Modify PA Value Setting For Required RU    modify_ru_id=5
    ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    ...    pa_off_value=${20}
    Modify PA Value Setting For Required RU    modify_ru_id=0
    ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    ...    pa_off_value=${127}
    Modify PA Value Setting For Required RU    modify_ru_id=1
    ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
    ...    pa_off_value=${127}
    ${254_timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    Connect to gnb coam via ssl    connection=GNB_0AM   gnb_index=${0}
    ${add_scf_file}    Run Keyword And Continue On Failure    coam_gnb_classical.COAM Download scf from cluster
    ...    scf_dir_path=${TS_CASE_LOG_PATH}    connection=GNB_0AM
    run keyword and ignore error    COAM Teardown gnb connections    connection=GNB_OAM
    Check LNRELGNBCELL Object Existence    scf_path=${add_scf_file}     status=Exist
    ...            gnbcell_index=255
    Check LNRELGNBCELL Object Existence    scf_path=${add_scf_file}     status=Exist
    ...            gnbcell_index=254
    Sleep    10min
    Connect to gnb coam via ssl    connection=GNB_0AM   gnb_index=${0}
    ${remove_scf_file}    Run Keyword And Continue On Failure    coam_gnb_classical.COAM Download scf from cluster
    ...    scf_dir_path=${TS_CASE_LOG_PATH}    connection=GNB_0AM
    run keyword and ignore error    COAM Teardown gnb connections    connection=GNB_OAM
    Run Keyword And Continue On Failure    Check LNRELGNBCELL Object Existence    scf_path=${remove_scf_file}
#    Sleep   9min
#    CB007334 Update Cell Lock Status
#    Sleep   10sec
#    CB007334 Update Cell Unlock Status
#    Check TMO Gnb Ready And All Cell On Air
#    Modify PA Value Setting For Required RU    modify_ru_id=5
#    ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
#    ...    pa_off_value=${20}
#    Modify PA Value Setting For Required RU    modify_ru_id=0
#    ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
#    ...    pa_off_value=${127}
#    Modify PA Value Setting For Required RU    modify_ru_id=1
#    ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
#    ...    pa_off_value=${30}
#    FOR    ${item}    IN RANGE    ${9}
#        Run Keyword And Continue On Failure    power_ue.UE Attach    ue_type=${ue_type}    attach_mode=5G_NSA
#        ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
#        Sleep    20sec
#        Run Keyword And Continue On Failure    power_ue.UE Detach    ue_type=${ue_type}
#        ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
#    END
#    Modify PA Value Setting For Required RU    modify_ru_id=1
#    ...    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}
#    ...    pa_off_value=${127}
#    Sleep    10min
#    Connect to gnb coam via ssl    connection=GNB_0AM   gnb_index=${0}
#    ${remove_scf_file}    Run Keyword And Continue On Failure    coam_gnb_classical.COAM Download scf from cluster
#    ...    scf_dir_path=${TS_CASE_LOG_PATH}    connection=GNB_0AM
#    run keyword and ignore error    COAM Teardown gnb connections    connection=GNB_OAM
#    Run Keyword And Continue On Failure    Check LNRELGNBCELL Object Existence    scf_path=${remove_scf_file}
#    Sleep    10min
#    Connect to gnb coam via ssl    connection=GNB_0AM   gnb_index=${0}
#    ${remove_scf_file}    Run Keyword And Continue On Failure    coam_gnb_classical.COAM Download scf from cluster
#    ...    scf_dir_path=${TS_CASE_LOG_PATH}    connection=GNB_0AM
#    run keyword and ignore error    COAM Teardown gnb connections    connection=GNB_OAM
#    Run Keyword And Continue On Failure    Check LNRELGNBCELL Object Existence    scf_path=${remove_scf_file}
    Parameter anrNrNbrRelRemGuardTime Modification
    FOR   ${item}    IN RANGE    ${5}
        log to console  INFO:--start to repeat round-${item} -
        Run Keyword And Continue On Failure    CB007344_Repeat_Remove_Add_LNRELGNBCELL
    END
    ${syslog_file}    Run Keyword And Continue On Failure    Get Syslog File During Specific Time    syslog_start_time=${SYSLOG_START_TIME}
    Run Keyword And Ignore Error    OperatingSystem.Copy File    ${syslog_file}    ${TS_CASE_LOG_PATH}/SYSLOG.tgz
    ${syslog_file_path}    Run Keyword And Continue On Failure   Evaluate    '/'.join(${syslog_file.split('/')[0:-1]})
    Run Keyword And Ignore Error    Check ERR Or WRN From Syslog    sys_logs_path=${syslog_file_path}
    ...     UTE_logs_path=/home/ute/ERR_WRN_logs    Fail_Case=True    Check_RF_Log=True    timeout=50 minutes
    Run Keyword And Continue On Failure    Check ERR Syslog Existed
#    Run Keyword And Ignore Error     Save Current SCF And Save Snapshot
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    Close the iperf process on APPserver
    ...    port=${tl.ues[${CB007163_CHOOSED_UE['${tl_prefix}']}].iperf_details.port}     AND
    ...    Run Keyword And Continue On Failure    TMO_Common_Case_Teardown    ue_index=${CB007163_CHOOSED_UE['${tl_prefix}']}    AND
    ...    Run Keyword And Continue On Failure    Connect to Common Unit Master    AND
    ...    Run Keyword And Continue On Failure    swconf.restore_swConfig_file_on_asik_and_crasign    asik_alias=ASIK Master   AND
    ...    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown    AND
    ...    run keyword and ignore error    COAM Teardown gnb connections    connection=GNB_OAM
    ...    AND
    ...    Run Keyword And Continue On Failure    SetUp.Precondition For First gNB   is_commission=${True}
    ...    check_rollback_is_needed=${False}

05437018_EDA_UL_bler_verify_after_scell_released
    [Setup]    SetUp.TMO Case Common SetUp    is_first_gnb_used=${True}    ue_index=${EDA05437018_CHOOSED_UE['${tl_prefix}']}
    ...    is_commission_for_first_gnb=${True}     test_case_prefix=EDA05437018
    05437018_Parameter Modification
    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=${PCELL_INDEX}
    ...    connection=GNB_OAM    timeout=300
    Modify PA Value Setting For Required RU    modify_ru_id=3
    ...    ue_index=${EDA05437018_CHOOSED_UE['${tl_prefix}']}
    Modify PA Value Setting For Required RU    modify_ru_id=0
    ...    ue_index=${EDA05437018_CHOOSED_UE['${tl_prefix}']}
    ${SCELL_INDEX_LIST}     Create List   301
    Set Test Variable      ${SCELL_INDEX_LIST}
    Procedures.Start UE Prepare    ue_index=${EDA05437018_CHOOSED_UE['${tl_prefix}']}   ue_type=${ue_type}
    ...    get_spark_license=${False}
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${EDA05437018_CHOOSED_UE['${tl_prefix}']}
    Run Keyword And Continue On Failure    Start DL traffic Through Appserver         ue_addr=${ue_addr}
    ...                                        dl_time=1800
    ...                                        dl_port=${tl.ues[${EDA05437018_CHOOSED_UE${tl_prefix}']}].iperf_details.port}
    ...                                        dl_throughput=1200MKbits/sec
    ...                                        dl_length=1400B
    ...                                        appserver=APPserver
    ...                                        protocol=udp
    ...                                        ue_index=${EDA05437018_CHOOSED_UE['${tl_prefix}']}
    ...                                        process_num=${2}
    ...                                        seg_size=${1400}
    ...                                        window=2M
    Run Keyword And Continue On Failure    traffic_via_iperf.Start UL traffic via iperf from andriod UE
    ...        ue_index=${EDA05437018_CHOOSED_UE['${tl_prefix}']}
    ...        ul_time=1800
    ...        ul_port=${tl.ues[${EDA05437018_CHOOSED_UE['${tl_prefix}']}].iperf_details.port}
    ...        ul_throughput=300M
    ...        ul_length=1400B
    ...        appserver=UEserver
    ...        protocol=udp
    ...        iperf_path=iperf
    ...        process_num=${1}
    Sleep   1min
#    ${attach_info}     Procedures.Verify CA Basic L3 Call    dl_throughput=1200MKbits/sec
#    ...                                                      ue_index=${EDA05437018_CHOOSED_UE['${tl_prefix}']}
#    ...                                                      whether_check_on_air=${False}
#    ...                                                      whether_start_ul_call=${False}
#    ...                                                      check_scell_tput_type=not_peak
#    ...                                                      check_ul_pcell_tput_type=not_peak
#    ...                                                      check_pcell_tput_type=not_peak
#    ...                                                      tput_collect_duration=60
#    ...                                                      min_scell_percent=0
#    ...                                                      min_DL_percent=0
#    ...                                                      whether_do_ue_prepare=${True}
#    ...                                                      ue_type=${ue_type}
#    ...                                                      ul_throughput=300M
    ${ul_ttitrace_before}    Run Keyword And Continue On Failure     Capture And Decode TTitrace Log    duration=5
    EDA05437018 add 5QI8
    Sleep   1min
    ${ul_ttitrace_after}    Run Keyword And Continue On Failure     Capture And Decode TTitrace Log    duration=5
    ${output_file}    EDA05437018 Record TestResult And Compare UL Bler    ul_ttitrace_before=${ul_ttitrace_before}
    ...    ul_ttitrace_after=${ul_ttitrace_after}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    Close the iperf process on APPserver
    ...    port=${tl.ues[${EDA05437018_CHOOSED_UE['${tl_prefix}']}].iperf_details.port}     AND
    ...    Run Keyword And Continue On Failure     Close the iperf process on android ue
    ...    ue_index=${EDA05437018_CHOOSED_UE['${tl_prefix}']}
    ...   iperf_port=${tl.ues[${EDA05437018_CHOOSED_UE['${tl_prefix}']}].iperf_details.port}    AND
    ...    Run Keyword And Continue On Failure    TMO_Common_Case_Teardown    ue_index=${EDA05437018_CHOOSED_UE['${tl_prefix}']}


Test_Robot_Case
    log     hello,robot