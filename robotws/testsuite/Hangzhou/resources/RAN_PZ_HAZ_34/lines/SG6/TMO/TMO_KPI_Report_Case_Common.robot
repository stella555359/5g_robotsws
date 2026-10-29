*** Settings ***
Documentation    This is for TMO KPI report case generate and record keywords.
...              Please do not modify the file without notification to author
...              Author: stella.lin@nokia-sbell.com

Resource  ./TMO_common_keywords.robot
Variables   commissionings/HGZ/7_5_UTE5G402T080/ip_config.py

*** Variables ***
${excel_kpi_download_path}    /home/ute/KPI_Report/Excel_KPI
${report_path_on_ute}    /home/ute/KPI_Report/Scout_KPI_Report
#${comparator_report_path_on_ute}    /home/ute/KPI_Report/Comparator_Report

*** Keywords ***
KPI_Report_Case.Test Procedures For Multi Rounds
    [Arguments]    ${case_test_procedure_kw}=TestCase.Reproduce_5605004
    ...            ${rounds}=1
    ...            ${gnb_index}=${0}
    ...            ${connection}=GNB_OAM${gnb_index}
    ...            ${need_to_check_status}=${True}
    ${btsName}    ${gnb_version}     Get BtsName and SwVersion    gnb_id=${gnb_index}    connection=${connection}
    Set Test Variable    ${btsName}
    Set Test Variable    ${gnb_version}
    ${scf_version}    ${stream_version}    Get scf stream and sw stream    scf_name=${btsName}    sw_version=${gnb_version}
    ${report_start_time}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${report_timestamps}      Create List
    ${empty_list}     Create List
    FOR    ${round}    IN RANGE    ${rounds}
        log to console    start to call round-${round}
        ${status}     Run Keyword And Return Status    ${case_test_procedure_kw}
#        ${call_timestamp}    Run Keyword If    ${status}     Create List    ${call_start_time}
#        ...    ${call_end_time}
#        Run Keyword If    ${status}    Append To List    ${report_timestamps}    ${call_timestamp}
        ${call_timestamp}    Create List    ${call_start_time}    ${call_end_time}
        Run Keyword If    ${need_to_check_status} and ${status}    Append To List    ${report_timestamps}    ${call_timestamp}
        ...    ELSE IF    ${need_to_check_status} and '${status}'=='${False}'    Append To List    ${report_timestamps}    ${empty_list}
        ...    ELSE    Append To List    ${report_timestamps}    ${call_timestamp}
    END
    ${test_procedure_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${diff_time}    Subtract Date From Date    ${test_procedure_time}    ${call_end_time}
    ${duration}    Evaluate   2100-${diff_time}
    ${sleep_time}   Set Variable If   ${diff_time}>=1800    300      ${duration}
    log to console    sleep for wait for scout report : ${sleep_time}
    log    test timestamps for ${rounds} rounds is ${report_timestamps}
    ${report_end_time}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${timestamps_length}    Get Length    ${report_timestamps}
    Run keyword If    '${timestamps_length}'=='${0}'    fail    msg=${case_test_procedure_kw} test for ${rounds}rounds all failed.
    log to console    start to wait ${sleep_time}
    Sleep    ${sleep_time}sec
    [Return]    ${report_timestamps}

KPI_Report_Case.Test Procedures
    [Arguments]    ${case_test_procedure_kw}=TestCase.Reproduce_5605004
    ...            ${gnb_index}=${0}
    ...            ${connection}=GNB_OAM${gnb_index}
    ...            ${warn_err_fail_case}=True
    ...            ${is_sleep}=${True}
    ${btsName}    ${gnb_version}     Get BtsName and SwVersion    gnb_id=${gnb_index}    connection=${connection}
    Set Test Variable    ${btsName}
    Set Test Variable    ${gnb_version}
    ${scf_version}    ${stream_version}    Get scf stream and sw stream    scf_name=${btsName}    sw_version=${gnb_version}
    ${report_start_time}    robot.libraries.DateTime.Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${report_timestamps}      Create List
    ${empty_list}     Create List
    Run Keyword    ${case_test_procedure_kw}    warn_err_fail_case=${warn_err_fail_case}
    ${call_timestamp}    Create List    ${call_start_time}    ${call_end_time}
    Append To List    ${report_timestamps}    ${call_timestamp}
    ${test_procedure_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${diff_time}    Subtract Date From Date    ${test_procedure_time}    ${call_end_time}
    ${duration}    Evaluate   2100-${diff_time}
    ${sleep_time}   Set Variable If   ${diff_time}>=1800    300      ${duration}
    log to console    sleep for wait for scout report : ${sleep_time}
    Run Keyword If   ${is_sleep}    Sleep    ${sleep_time}sec
    [Return]    ${report_timestamps}

Generate And Record KPI Report To Compass And UTE PC
    [Arguments]   ${report_timestamps}
    ...           ${filter_distnames}=bts,NRCELL-301
    ...           ${comments}=PZ4_SG06_case_5605004_overall
    ...           ${template_name}=KPI_24R1_TMO_SA_SG6
    ...           ${output_excel_name}=KPI_5605004.xlsx
    ...           ${check_out_entry}=true
    ...           ${gnb_index}=${0}
    ...           ${connection}=GNB_OAM${gnb_index}
    ...           ${group_name}=${None}
    ${output_excel_name_flag}    Set Variable    ${output_excel_name.split('.xls')[0]}
    ${backup_excel_name}    Set Variable    ${output_excel_name_flag}_backup.xlsx
    OperatingSystem.Copy File    ${report_path_on_ute}/${output_excel_name}    ${report_path_on_ute}/Backup/${backup_excel_name}
    ${filter_distnames}    Set Variable    ${filter_distnames.split(',')}
    ${scout_name}    Set Variable If    '${tl_prefix}'=='T284'    7_5_UTE402T284
    ...     '${tl_prefix}'=='T080' and '${gnb_index}'=='${0}'    7_5_UTE5G402T080
    ...     '${tl_prefix}'=='T080' and '${gnb_index}'=='${1}'    7_5_UTE5G402T282
    ...     '${tl_prefix}'=='T073'    7_5_CLOUD402T073
    ...     '${tl_prefix}'=='T283'    7_5_UTE5G402T283
    ...     '${tl_prefix}'=='T813'    7_5_UTE5G402T813
    ...     '${tl_prefix}'=='T816'    7_5_UTE5G402T816
    log to console    start to generate kpi report on compass for ${scout_name}
    ${excel_report_path_on_ute}    Create List
    ${report_id_list}    Create List
    FOR   ${timestamp}    IN    @{report_timestamps}
       ${status}   ${excel_report}    Run Keyword And Ignore Error    KPI.Generate kpi report in Scout    tl_name=${scout_name}
       ...    start_time=${timestamp[0]}
       ...    end_time=${timestamp[1]}
       ...    comments=${comments}
       ...    template_name=${template_name}
       ...    check_out_entry=${check_out_entry}
       ...    gnb_index=${gnb_index}
       ...    connection=${connection}
       Append To List    ${excel_report_path_on_ute}    ${excel_report}
       Append To List    ${report_id_list}    ${report_id}
    END
    log    ${excel_report_path_on_ute}
    log    ${report_timestamps}
    ${report_length}    Get Length    ${excel_report_path_on_ute}
    Run keyword If    '${report_length}'=='${0}'    fail    msg=no available report get from this round test.
    log to console    start to record kpi report on ute
    ${reproduce_kpi_values_list}    Create List
    FOR    ${excel_report}    IN    @{excel_report_path_on_ute}
       ${report_time}    Set Variable    ${excel_report.split('.')[0].split('/')[-1].split('_')[-1]}
       ${reproduce_kpi_values_dict}    Run Keyword And Continue On Failure
       ...    generate_kpi_report_based_on_scout_report
       ...    sw_version=${gnb_version}
       ...    scf_name=${btsName}
       ...    scout_report_time=${report_time}
       ...    excel_report_path=${excel_report}
       ...    output_report_path=${report_path_on_ute}/${output_excel_name}
       ...    filter_distnames=${filter_distnames}
       ...    group_name=${group_name}
       Append To List    ${reproduce_kpi_values_list}    ${reproduce_kpi_values_dict}
   END
   [Return]    ${reproduce_kpi_values_list}




Generate KPI Report And Record To Compass
    [Arguments]   ${report_timestamps}
    ...           ${comments}=PZ4_SG06_case_5605004_overall
    ...           ${template_name}=KPI_24R1_TMO_SA_SG6
    ...           ${check_out_entry}=false
    ...           ${gnb_index}=${0}
    ...           ${connection}=GNB_OAM${gnb_index}
    ...           ${is_active_package}=${True}
    ${scout_name}    Set Variable If    '${tl_prefix}'=='T284'    7_5_UTE402T284
    ...     '${tl_prefix}'=='T080' and '${gnb_index}'=='${0}'    7_5_UTE5G402T080
    ...     '${tl_prefix}'=='T080' and '${gnb_index}'=='${1}'    7_5_UTE5G402T282
    ...     '${tl_prefix}'=='T073'    7_5_CLOUD402T073
    ...     '${tl_prefix}'=='T283'    7_5_UTE5G402T283
    ...     '${tl_prefix}'=='T813'    7_5_UTE5G402T813
    ...     '${tl_prefix}'=='T816'    7_5_UTE5G402T816
    log to console    start to generate kpi report on compass for ${scout_name}
    ${excel_report_path_on_ute}    Create List
    ${report_id_list}    Create List
#    FOR   ${timestamp}    IN    @{report_timestamps}
#       ${status}   ${excel_report}    Run Keyword And Ignore Error    KPI.Generate kpi report in Scout    tl_name=${scout_name}
#       ...    start_time=${timestamp[0]}
#       ...    end_time=${timestamp[1]}
#       ...    comments=${comments}
#       ...    template_name=${template_name}
#       ...    check_out_entry=${check_out_entry}
#       ...    gnb_index=${gnb_index}
#       ...    connection=${connection}
#       Run Keyword If    '${status}'=='PASS'    Append To List    ${excel_report_path_on_ute}    ${excel_report}
#       ${report_name}    Run Keyword If    '${status}'=='PASS'    Set Variable    ${excel_report.split('/')[-1]}
#       ${test_case_id}    Set Variable    ${TEST NAME.split('_')[0]}
#       Run Keyword And Ignore Error    Run Keyword If    '${status}'=='PASS'    upload_files_to_remote_server
#       ...    local_path=${excel_report}
#       ...    remote_path=/home/hz4sg6/shared/01_E2E_Rep/${test_case_id}/${test_case_id}_${tl_prefix}/Excel_KPI/${report_name}
#    END
    FOR   ${timestamp}    IN    @{report_timestamps}
       ${excel_report}    ${report_id}    Run Keyword And Continue On Failure    KPI.Generate kpi report in Scout
       ...    tl_name=${scout_name}
       ...    start_time=${timestamp[0]}
       ...    end_time=${timestamp[1]}
       ...    comments=${comments}
       ...    template_name=${template_name}
       ...    check_out_entry=${check_out_entry}
       ...    gnb_index=${gnb_index}
       ...    connection=${connection}
    ...       is_active_package=${is_active_package}
       Append To List    ${excel_report_path_on_ute}    ${excel_report}
       Append To List    ${report_id_list}    ${report_id}
       ${report_name}    Set Variable    ${excel_report.split('/')[-1]}
       ${test_case_id}    Set Variable    ${TEST NAME.split('_')[0]}
       Run Keyword And Ignore Error    upload_files_to_remote_server
       ...    local_path=${excel_report}
       ...    remote_path=/home/hz4sg6/shared/01_E2E_Rep/${test_case_id}/${test_case_id}_${tl_prefix}/Excel_KPI/${report_name}
        ...    hostname=${samba_server_ip}
        ...    username=${samba_server_username}
        ...    password=${samba_server_password}
    END
    log    ${excel_report_path_on_ute}
    log    ${report_timestamps}
    ${report_length}    Get Length    ${excel_report_path_on_ute}
    Run keyword If    '${report_length}'=='${0}'    fail    msg=no available report get from this round test.
   [Return]    ${excel_report_path_on_ute}    ${report_id_list}

Record KPI Report To UTE PC
    [Arguments]   ${excel_report_path_on_ute}
    ...           ${filter_distnames}=bts,NRCELL-301
    ...           ${group_name}=${None}
    ...           ${gnb_index}=${0}
    ...           ${connection}=GNB_OAM${gnb_index}
    ...           ${output_excel_name}=KPI_5605004.xlsx
    log    ${connection}
    log    ${filter_distnames}
    ${filter_distnames_type}    Evaluate    type(${filter_distnames}).__name__
    ${convert_filter_distnames}    run keyword if  not 'list' in '${filter_distnames_type}'
    ...    Set Variable    ${filter_distnames.split(',')}
    ${new_filter_distnames}    Set Variable If    'list' in '${filter_distnames_type}'
    ...      ${filter_distnames}     ${convert_filter_distnames}
#    ${btsName}    ${gnb_version}     Get BtsName and SwVersion    gnb_id=${gnb_index}    connection=${connection}
    log to console    start to record kpi report for ${gnb_version} on ute
    ${test_case_id}    Set Variable    ${TEST NAME.split('_')[0]}
    ${output_report_path}    Set Variable    ${report_path_on_ute}/${test_case_id}/${tl_prefix}_${output_excel_name}
    ${reproduce_kpi_values_list}    Create List
    FOR    ${excel_report}    IN    @{excel_report_path_on_ute}
       ${report_time}    Set Variable    ${excel_report.split('.')[0].split('/')[-1].split('_')[-1]}
       ${reproduce_kpi_values_dict}    Run Keyword And Continue On Failure
       ...    generate_kpi_report_based_on_scout_report
       ...    sw_version=${gnb_version}
       ...    scf_name=${btsName}
       ...    scout_report_time=${report_time}
       ...    excel_report_path=${excel_report}
       ...    output_report_path=${output_report_path}
       ...    filter_distnames=${new_filter_distnames}
       ...    group_name=${group_name}
       Append To List    ${reproduce_kpi_values_list}    ${reproduce_kpi_values_dict}
   END
#   Run Keyword And Ignore Error    OperatingSystem.Copy File    ${output_report_path}    ${report_path_on_ute}/Backup/
   ${remote_server_store_path}    Catenate
   ...    /home/hz4sg6/shared/01_E2E_Rep/${test_case_id}/${test_case_id}_${tl_prefix}/Scout_KPI_Report/
   ...    ${tl_prefix}_${output_excel_name}
   Run Keyword And Ignore Error    upload_files_to_remote_server
       ...    local_path=${output_report_path}
       ...    remote_path=${remote_server_store_path}
       ...    hostname=${samba_server_ip}
       ...    username=${samba_server_username}
       ...    password=${samba_server_password}
   [Return]    ${reproduce_kpi_values_list}

Generate And Record Total KPI Report To Compass And UTE
    [Arguments]   ${report_timestamps}
    ...           ${total_template_name}=List1_KPI_TMO_24R1_SA_SG6
    ...           ${comments}=5605005
    ...           ${filter_distnames}=bts,NRCELL-301
    ...           ${gnb_index}=${0}
    ${total_excel_report_path}    ${report_id_list}    Generate KPI Report And Record To Compass
    ...                           report_timestamps=${report_timestamps}
    ...                           comments=PZ4_SG06_${comments}_${total_template_name}
    ...                           template_name=${total_template_name}
    ...                           gnb_index=${gnb_index}
    ${reproduce_kpi_values}    Run Keyword And Continue On Failure    Record KPI Report To UTE PC
    ...                        excel_report_path_on_ute=${total_excel_report_path}
    ...                        filter_distnames=${filter_distnames}
    ...                        output_excel_name=${comments}_${total_template_name}.xlsx
    ...                        gnb_index=${gnb_index}
    ${total_kpi_info}    Create Dictionary    swbuild_info=${gnb_version}_${btsName}
    ...                                       report_period=${report_timestamps}
    ...                                       excel_report_path=${total_excel_report_path}
    ...                                       reproduce_kpi_values=${reproduce_kpi_values}
    ...                                       repord_id_list=${report_id_list}
    [Return]    ${total_kpi_info}

Generate And Record Reproduce KPI Report To Compass And UTE
    [Arguments]   ${report_timestamps}
    ...           ${rep_template_name}=List5_KPI_TMO_Reproduction_CRT_241125
    ...           ${comments}=5605005
    ...           ${filter_distnames}=bts,NRCELL-301
    ...           ${gnb_index}=${0}
    ...           ${group_name}=PR03841043
    ${reproduce_excel_report_path}    ${report_id_list}    Generate KPI Report And Record To Compass
    ...                               report_timestamps=${report_timestamps}
    ...                               comments=PZ4_SG06_${comments}_${rep_template_name}
    ...                               template_name=${rep_template_name}
    ...                               gnb_index=${gnb_index}
    ${reproduce_kpi_values}    Run Keyword And Continue On Failure    Record KPI Report To UTE PC
    ...                        excel_report_path_on_ute=${reproduce_excel_report_path}
    ...                        filter_distnames=${filter_distnames}
    ...                        output_excel_name=${comments}_${rep_template_name}.xlsx
    ...                        gnb_index=${gnb_index}
    ...                        group_name=${group_name}
    ${reproduce_kpi_info}    Create Dictionary    swbuild_info=${gnb_version}_${btsName}
    ...                                           report_period=${report_timestamps}
    ...                                           excel_report_path=${reproduce_excel_report_path}
    ...                                           reproduce_kpi_values=${reproduce_kpi_values}
    ...                                           report_id_list=${report_id_list}
    [Return]    ${reproduce_kpi_info}

Generate And Record Energy Saving KPI Report To Compass And UTE
    [Arguments]   ${report_timestamps}
    ...           ${rep_template_name}=List4_KPI_TMO_Energy_Saving_Bundle_SG6
    ...           ${comments}=5605006
    ...           ${filter_distnames}=bts,NRCELL-301
    ...           ${gnb_index}=${0}
    ${reproduce_excel_report_path}    ${report_id_list}    Generate KPI Report And Record To Compass
    ...                               report_timestamps=${report_timestamps}
    ...                               comments=PZ4_SG06_${comments}_${rep_template_name}
    ...                               template_name=${rep_template_name}
    ...                               gnb_index=${gnb_index}
    ${reproduce_kpi_values}    Run Keyword And Continue On Failure    Record KPI Report To UTE PC
    ...                        excel_report_path_on_ute=${reproduce_excel_report_path}
    ...                        filter_distnames=${filter_distnames}
    ...                        output_excel_name=${comments}_${rep_template_name}.xlsx
    ...                        gnb_index=${gnb_index}
    ${reproduce_kpi_info}    Create Dictionary    swbuild_info=${gnb_version}_${btsName}
    ...                                           report_period=${report_timestamps}
    ...                                           excel_report_path=${reproduce_excel_report_path}
    ...                                           reproduce_kpi_values=${reproduce_kpi_values}
    ...                                           report_id_list=${report_id_list}
    [Return]    ${reproduce_kpi_info}

Generate And Record New Lis 1025 To Compass And UTE
    [Arguments]   ${report_timestamps}
    ...           ${rep_template_name}=List2_KPI_TMO_new_24R2_24R3_25R1
    ...           ${comments}=5605004
    ...           ${filter_distnames}=bts,NRCELL-301
    ...           ${gnb_index}=${0}
    ${reproduce_excel_report_path}    ${report_id_list}    Generate KPI Report And Record To Compass
    ...                               report_timestamps=${report_timestamps}
    ...                               comments=PZ4_SG06_${comments}_${rep_template_name}
    ...                               template_name=${rep_template_name}
    ...                               gnb_index=${gnb_index}
    ${reproduce_kpi_values}    Run Keyword And Continue On Failure    Record KPI Report To UTE PC
    ...                        excel_report_path_on_ute=${reproduce_excel_report_path}
    ...                        filter_distnames=${filter_distnames}
    ...                        output_excel_name=${comments}_${rep_template_name}.xlsx
    ...                        gnb_index=${gnb_index}
    ${reproduce_kpi_info}    Create Dictionary    swbuild_info=${gnb_version}_${btsName}
    ...                                           report_period=${report_timestamps}
    ...                                           excel_report_path=${reproduce_excel_report_path}
    ...                                           reproduce_kpi_values=${reproduce_kpi_values}
    ...                                           report_id_list=${report_id_list}
    [Return]    ${reproduce_kpi_info}


Generate And Record Interference To Compass And UTE
    [Arguments]   ${report_timestamps}
    ...           ${rep_template_name}=List3_KPI_TMO_Interference
    ...           ${comments}=5605004
    ...           ${filter_distnames}=bts,NRCELL-301
    ...           ${gnb_index}=${0}
    ${reproduce_excel_report_path}    ${report_id_list}    Generate KPI Report And Record To Compass
    ...                               report_timestamps=${report_timestamps}
    ...                               comments=PZ4_SG06_${comments}_${rep_template_name}
    ...                               template_name=${rep_template_name}
    ...                               gnb_index=${gnb_index}
    ${reproduce_kpi_values}    Run Keyword And Continue On Failure    Record KPI Report To UTE PC
    ...                        excel_report_path_on_ute=${reproduce_excel_report_path}
    ...                        filter_distnames=${filter_distnames}
    ...                        output_excel_name=${comments}_${rep_template_name}.xlsx
    ...                        gnb_index=${gnb_index}
    ${reproduce_kpi_info}    Create Dictionary    swbuild_info=${gnb_version}_${btsName}
    ...                                           report_period=${report_timestamps}
    ...                                           excel_report_path=${reproduce_excel_report_path}
    ...                                           reproduce_kpi_values=${reproduce_kpi_values}
    ...                                           report_id_list=${report_id_list}
    [Return]    ${reproduce_kpi_info}

Generate And Record Slice To Compass And UTE
    [Arguments]   ${report_timestamps}
    ...           ${rep_template_name}=List7_KPI_TMO_Slice_SG6
    ...           ${comments}=5605004
    ...           ${filter_distnames}=bts,NRCELL-301
    ...           ${gnb_index}=${0}
    log    ${filter_distnames}
    ${reproduce_excel_report_path}    ${report_id_list}    Generate KPI Report And Record To Compass
    ...                               report_timestamps=${report_timestamps}
    ...                               comments=PZ4_SG06_${comments}_${rep_template_name}
    ...                               template_name=${rep_template_name}
    ...                               gnb_index=${gnb_index}
    ${reproduce_kpi_values}    Run Keyword And Continue On Failure    Record KPI Report To UTE PC
    ...                        excel_report_path_on_ute=${reproduce_excel_report_path}
    ...                        filter_distnames=${filter_distnames}
    ...                        output_excel_name=${comments}_${rep_template_name}.xlsx
    ...                        gnb_index=${gnb_index}
    ${reproduce_kpi_info}    Create Dictionary    swbuild_info=${gnb_version}_${btsName}
    ...                                           report_period=${report_timestamps}
    ...                                           excel_report_path=${reproduce_excel_report_path}
    ...                                           reproduce_kpi_values=${reproduce_kpi_values}
    ...                                           report_id_list=${report_id_list}
    [Return]    ${reproduce_kpi_info}

Record KPI Data To TestCase Path
    [Arguments]     ${kpi_info_list}
    ...             ${output_report_name}=total_kpi_result.xlsx
    ...             ${filter_distnames}=bts,NRCELL-301
    ...             ${group_name}=${None}
    ${filter_distnames}    Set Variable    ${filter_distnames.split(',')}
    generate_kpi_data_to_testcase_path   kpi_info_list=${kpi_info_list}
    ...                                  output_report_path=${TS_CASE_LOG_PATH}/${output_report_name}
    ...                                  filter_distnames=${filter_distnames}
    ...                                  group_name=${group_name}

Record Comparator KPI Report To UTE
    [Arguments]   ${compare_report_id}
    ...           ${excel_report_path_on_ute}
    ...           ${filter_distnames}=BTS,NRCELL-301
    ...           ${output_report_prefix}=5605004_reproduce
    ${filter_distnames}    Set Variable    ${filter_distnames.split(',')}
    log to console    start to record comparator kpi report for ${output_report_prefix} template on ute
    ${output_report_path_on_ute}    Wait Until Keyword Succeeds    5x    30s    extract_compare_data_from_scout
    ...    compare_report_id=${compare_report_id}
    ...    excel_report_path=${excel_report_path_on_ute}
    ...    output_report_prefix=${output_report_prefix}
    ...    filter_distnames=${filter_distnames}
    ${path}    Set Variable    ${output_report_path_on_ute.split('/')[-2]}
    ${report_name}     Set Variable    ${output_report_path_on_ute.split('/')[-1]}
    ${test_case_id}    Set Variable    ${TEST NAME.split('_')[0]}
    ${remote_server_store_path}    Catenate
    ...    /home/hz4sg6/shared/01_E2E_Rep/${test_case_id}/${test_case_id}_${tl_prefix}/Comparator_Report/${path}/${report_name}
    Run Keyword And Ignore Error    upload_files_to_remote_server
    ...    local_path=${output_report_path_on_ute}
    ...    remote_path=${remote_server_store_path}
    ...    hostname=${samba_server_ip}
    ...    username=${samba_server_username}
    ...    password=${samba_server_password}
    [Return]    ${output_report_path_on_ute}    ${remote_server_store_path}

Generate And Record Comparator Report On Compass And UTE
    [Arguments]    ${excel_report_path_on_ute}
    ...            ${filter_distnames}
    ...            ${output_report_prefix}
    ...            ${first_description}
    ...            ${first_start_time}
    ...            ${first_end_time}
    ...            ${second_description}
    ...            ${second_start_time}
    ...            ${second_end_time}
    ...            ${template_names_list}=SG6_KPI_TMO_Reproduction_CRT
    ...            ${template_id_list}=1036
    ...            ${alpha_factor}=0.005
    ...            ${comments}=" "
    ...            ${gnb_index}=${0}
    ${compare_report_id}    KPI.Generate Comparator Report On Compass
    ...            first_description=${first_description}
    ...            first_start_time=${first_start_time}
    ...            first_end_time=${first_end_time}
    ...            second_description=${second_description}
    ...            second_start_time=${second_start_time}
    ...            second_end_time= ${second_end_time}
    ...            template_names_list=${template_names_list}
    ...            template_id_list=${template_id_list}
    ...            alpha_factor=${alpha_factor}
    ...            comments=${comments}
    ...            gnb_index=${gnb_index}
    ${output_report_path_on_ute}    ${remote_server_store_path}
    ...    Record Comparator KPI Report To UTE    compare_report_id=${compare_report_id}
    ...    excel_report_path_on_ute=${excel_report_path_on_ute}
    ...    output_report_prefix=${output_report_prefix}
    ...    filter_distnames=${filter_distnames}
    [Return]    ${output_report_path_on_ute}    ${remote_server_store_path}

Generate Scout KPI Report And Comparator Report On Compass And Record To Server
    [Arguments]    ${report_timestamps_target_build}
    ...            ${report_timestamps_source_build}
    ...            ${gnb_index}=${0}
    ...            ${comparator_filter_distnames}=NRCELL-301,BTS
    ...            ${kpi_report_filter_distnames}=bts,NRCELL-301
    ...            ${is_error_fail_case}=${True}
    ...            ${comments}=5605005
    ${filter_distnames}    Set Variable    ALL,${comparator_filter_distnames}
    ${filter_distnames_list}    Set Variable    ${filter_distnames.split(',')}
    ${filter_distnames_without_ALL}    Set Variable    ${comparator_filter_distnames.split(',')}
    ${test_case_id}    Set Variable    ${TEST NAME.split('_')[0]}
    ${all_template_comparator_report}    Create List
    #------Generate KPI Report For Target Build---------------#
    ${reproduce_kpi_info_target_build}    Generate And Record ALL Template KPI Report To Compass And UTE
    ...     report_timestamps=${report_timestamps_target_build}
    ...     comments=${comments}
    ...     filter_distnames=${kpi_report_filter_distnames}
    ...     gnb_index=${gnb_index}
    #------Generate KPI Report For Souce Build---------------#
    ${reproduce_kpi_info_source_build}    Generate And Record ALL Template KPI Report To Compass And UTE
    ...     report_timestamps=${report_timestamps_source_build}
    ...     comments=${comments}
    ...     filter_distnames=${kpi_report_filter_distnames}
    ...     gnb_index=${gnb_index}
    Set Test Variable    ${reproduce_kpi_info_target_build}
    Set Test Variable    ${reproduce_kpi_info_source_build}
    #------Generate Comparator Report On Compass---------------#
    ${reproduce_kpi_info_path_on_ute}    ${reproduce_kpi_info_remote_server_store_path}    Run Keyword And Continue On Failure
    ...            Generate And Record Comparator Report On Compass And UTE
    ...            excel_report_path_on_ute=${list5_excel_report_path[0]}
    ...            filter_distnames=${comparator_filter_distnames}
    ...            output_report_prefix=${test_case_id}_List5_KPI_TMO_Reproduction_CRT_241125
    ...            first_description=${reproduce_kpi_info_target_build["swbuild_info"]}
    ...            first_start_time=${report_timestamps_target_build[0][0]}
    ...            first_end_time=${report_timestamps_target_build[0][1]}
    ...            second_description=${reproduce_kpi_info_source_build["swbuild_info"]}
    ...            second_start_time=${report_timestamps_source_build[0][0]}
    ...            second_end_time=${report_timestamps_source_build[0][1]}
    ...            template_names_list=List5_KPI_TMO_Reproduction_CRT_241125
    ...            template_id_list=1113
    ...            alpha_factor=0.005
    ...            comments="RepCase_${test_case_id}_List5_KPI_TMO_Reproduction_CRT_241125"
    ${total_kpi_info_path_on_ute}    ${total_kpi_info_remote_server_store_path}    Run Keyword And Continue On Failure
    ...            Generate And Record Comparator Report On Compass And UTE
    ...            excel_report_path_on_ute=${list1_excel_report_path[0]}
    ...            filter_distnames=${comparator_filter_distnames}
    ...            output_report_prefix=${test_case_id}_List1_KPI_TMO_24R1_SA_SG6
    ...            first_description=${reproduce_kpi_info_target_build["swbuild_info"]}
    ...            first_start_time=${report_timestamps_target_build[0][0]}
    ...            first_end_time=${report_timestamps_target_build[0][1]}
    ...            second_description=${reproduce_kpi_info_source_build["swbuild_info"]}
    ...            second_start_time=${report_timestamps_source_build[0][0]}
    ...            second_end_time=${report_timestamps_source_build[0][1]}
    ...            template_names_list=List1_KPI_TMO_24R1_SA_SG6
    ...            template_id_list=1037
    ...            alpha_factor=0.005
    ...            comments="RepCase_${test_case_id}_List1_KPI_TMO_24R1_SA_SG6"
    ${new_list_1025_kpi_info_path_on_ute}    ${new_list_1025_kpi_info_remote_server_store_path}    Run Keyword And Continue On Failure
    ...            Generate And Record Comparator Report On Compass And UTE
    ...            excel_report_path_on_ute=${list2_excel_report_path[0]}
    ...            filter_distnames=${comparator_filter_distnames}
    ...            output_report_prefix=${test_case_id}_List2_KPI_TMO_new_24R2_24R3_25R1
    ...            first_description=${reproduce_kpi_info_target_build["swbuild_info"]}
    ...            first_start_time=${report_timestamps_target_build[0][0]}
    ...            first_end_time=${report_timestamps_target_build[0][1]}
    ...            second_description=${reproduce_kpi_info_source_build["swbuild_info"]}
    ...            second_start_time=${report_timestamps_source_build[0][0]}
    ...            second_end_time=${report_timestamps_source_build[0][1]}
    ...            template_names_list=List2_KPI_TMO_new_24R2_24R3_25R1
    ...            template_id_list=1100
    ...            alpha_factor=0.005
    ...            comments="RepCase_${test_case_id}_List2_KPI_TMO_new_24R2_24R3_25R1"
    ${interference_kpi_info_path_on_ute}    ${interference_kpi_info_remote_server_store_path}    Run Keyword And Continue On Failure
    ...            Generate And Record Comparator Report On Compass And UTE
    ...            excel_report_path_on_ute=${list3_excel_report_path[0]}
    ...            filter_distnames=${comparator_filter_distnames}
    ...            output_report_prefix=${test_case_id}_List3_KPI_TMO_Interference
    ...            first_description=${reproduce_kpi_info_target_build["swbuild_info"]}
    ...            first_start_time=${report_timestamps_target_build[0][0]}
    ...            first_end_time=${report_timestamps_target_build[0][1]}
    ...            second_description=${reproduce_kpi_info_source_build["swbuild_info"]}
    ...            second_start_time=${report_timestamps_source_build[0][0]}
    ...            second_end_time=${report_timestamps_source_build[0][1]}
    ...            template_names_list=List3_KPI_TMO_Interference
    ...            template_id_list=1102
    ...            alpha_factor=0.005
    ...            comments="RepCase_${test_case_id}_List3_KPI_TMO_Interference"
    ${energy_saving_kpi_info_path_on_ute}    ${energy_saving_kpi_info_remote_server_store_path}    Run Keyword And Continue On Failure
    ...            Generate And Record Comparator Report On Compass And UTE
    ...            excel_report_path_on_ute=${list4_excel_report_path[0]}
    ...            filter_distnames=${comparator_filter_distnames}
    ...            output_report_prefix=${test_case_id}_List4_KPI_TMO_Energy_Saving_Bundle_SG6
    ...            first_description=${reproduce_kpi_info_target_build["swbuild_info"]}
    ...            first_start_time=${report_timestamps_target_build[0][0]}
    ...            first_end_time=${report_timestamps_target_build[0][1]}
    ...            second_description=${reproduce_kpi_info_source_build["swbuild_info"]}
    ...            second_start_time=${report_timestamps_source_build[0][0]}
    ...            second_end_time=${report_timestamps_source_build[0][1]}
    ...            template_names_list=List4_KPI_TMO_Energy_Saving_Bundle_SG6
    ...            template_id_list=1103
    ...            alpha_factor=0.005
    ...            comments="RepCase_${test_case_id}_List4_KPI_TMO_Energy_Saving_Bundle_SG6"
    ${slice_kpi_info_path_on_ute}    ${slice_kpi_info_remote_server_store_path}    Run Keyword And Continue On Failure
    ...            Generate And Record Comparator Report On Compass And UTE
    ...            excel_report_path_on_ute=${list7_excel_report_path[0]}
    ...            filter_distnames=${comparator_filter_distnames}
    ...            output_report_prefix=${test_case_id}_List7_KPI_TMO_Slice_SG6
    ...            first_description=${reproduce_kpi_info_target_build["swbuild_info"]}
    ...            first_start_time=${report_timestamps_target_build[0][0]}
    ...            first_end_time=${report_timestamps_target_build[0][1]}
    ...            second_description=${reproduce_kpi_info_source_build["swbuild_info"]}
    ...            second_start_time=${report_timestamps_source_build[0][0]}
    ...            second_end_time=${report_timestamps_source_build[0][1]}
    ...            template_names_list=List7_KPI_TMO_Slice_SG6
    ...            template_id_list=1122
    ...            alpha_factor=0.005
    ...            comments="RepCase_${test_case_id}_List7_KPI_TMO_Slice_SG6"
    Run Keyword If    '${reproduce_kpi_info_path_on_ute}'!='${None}'    Append To List
    ...    ${all_template_comparator_report}     ${reproduce_kpi_info_path_on_ute}
    Run Keyword If    '${total_kpi_info_path_on_ute}'!='${None}'    Append To List
    ...    ${all_template_comparator_report}     ${total_kpi_info_path_on_ute}
    Run Keyword If    '${new_list_1025_kpi_info_path_on_ute}'!='${None}'    Append To List
    ...    ${all_template_comparator_report}     ${new_list_1025_kpi_info_path_on_ute}
    Run Keyword If    '${interference_kpi_info_path_on_ute}'!='${None}'    Append To List
    ...    ${all_template_comparator_report}     ${interference_kpi_info_path_on_ute}
    Run Keyword If    '${energy_saving_kpi_info_path_on_ute}'!='${None}'    Append To List
    ...    ${all_template_comparator_report}     ${energy_saving_kpi_info_path_on_ute}
    Run Keyword If    '${slice_kpi_info_path_on_ute}'!='${None}'    Append To List
    ...    ${all_template_comparator_report}     ${slice_kpi_info_path_on_ute}
    ${ute_store_path}    Evaluate    '/'.join(${reproduce_kpi_info_path_on_ute.split('/')[0:-1]})
    ${server_store_path}    Evaluate    '/'.join(${reproduce_kpi_info_remote_server_store_path.split('/')[0:-1]})
    log    ${ute_store_path}
    log    ${server_store_path}
    ${prefix}      Set Variable    ${reproduce_kpi_info_path_on_ute.split('-')[1]}
    ${report_times}    Set Variable    ${reproduce_kpi_info_path_on_ute.split('-')[-1]}
    ${total_template_comparator_report_name}    Set Variable    ${tl_prefix}_${test_case_id}_${prefix}_${report_times}
    ${total_template_comparator_error_name}    Set Variable    ERROR_${tl_prefix}_${test_case_id}_${prefix}_${report_times}
    ${combination_results}    combine_multi_template_comparator_result
    ...    output_excel=${ute_store_path}/${total_template_comparator_report_name}
    ...    results_list=${all_template_comparator_report}
    ...    filter_distnames=${filter_distnames_list}
    Run Keyword And Ignore Error    upload_files_to_remote_server
    ...    local_path=${ute_store_path}/${total_template_comparator_report_name}
    ...    remote_path=${server_store_path}/${total_template_comparator_report_name}
    ...    hostname=${samba_server_ip}
    ...    username=${samba_server_username}
    ...    password=${samba_server_password}
    Run Keyword And Ignore Error    comparator_data_analysis
    ...    compare_report_path=${ute_store_path}/${total_template_comparator_report_name}
    ...    result_report_path=${ute_store_path}/${total_template_comparator_error_name}
    ...    filter_distnames=${filter_distnames_without_ALL}
    ...    is_fail_case=${is_error_fail_case}
    Run Keyword And Ignore Error    upload_files_to_remote_server
    ...    local_path=${ute_store_path}/${total_template_comparator_error_name}
    ...    remote_path=${server_store_path}/${total_template_comparator_error_name}
    ...    hostname=${samba_server_ip}
    ...    username=${samba_server_username}
    ...    password=${samba_server_password}

Generate Scout KPI Report For Target Build
    [Arguments]    ${report_timestamps_target_build}
    ...            ${gnb_index}=${0}
    ...            ${kpi_report_filter_distnames}=bts,NRCELL-301
    ...            ${comments}=5605005
    ${test_case_id}    Set Variable    ${TEST NAME.split('_')[0]}
    #------Generate KPI Report For Target Build---------------#
    ${reproduce_kpi_info_target_build}    Generate And Record ALL Template KPI Report To Compass And UTE
    ...     report_timestamps=${report_timestamps_target_build}
    ...     comments=${comments}
    ...     filter_distnames=${kpi_report_filter_distnames}
    ...     gnb_index=${gnb_index}
    ...     is_active_package=${True}
    Set Test Variable    ${reproduce_kpi_info_target_build}


Generate Scout KPI Report For Source Build
    [Arguments]    ${report_timestamps_source_build}
    ...            ${gnb_index}=${0}
    ...            ${kpi_report_filter_distnames}=bts,NRCELL-301
    ...            ${comments}=5605005
    ${test_case_id}    Set Variable    ${TEST NAME.split('_')[0]}
    #------Generate KPI Report For Souce Build---------------#
    ${reproduce_kpi_info_source_build}    Generate And Record ALL Template KPI Report To Compass And UTE
    ...     report_timestamps=${report_timestamps_source_build}
    ...     comments=${comments}
    ...     filter_distnames=${kpi_report_filter_distnames}
    ...     gnb_index=${gnb_index}
    ...     is_active_package=${False}
    Set Test Variable    ${reproduce_kpi_info_source_build}


Generate Comparator Report On Compass And Record To Server
    [Arguments]    ${report_timestamps_target_build}
    ...            ${report_timestamps_source_build}
    ...            ${gnb_index}=${0}
    ...            ${comparator_filter_distnames}=NRCELL-301,BTS
    ...            ${kpi_report_filter_distnames}=bts,NRCELL-301
    ...            ${is_error_fail_case}=${True}
    log    ${gnb_index}
    log    ${kpi_report_filter_distnames}
    ${filter_distnames}    Set Variable    ALL,${comparator_filter_distnames}
    ${filter_distnames_list}    Set Variable    ${filter_distnames.split(',')}
    ${filter_distnames_without_ALL}    Set Variable    ${comparator_filter_distnames.split(',')}
    ${test_case_id}    Set Variable    ${TEST NAME.split('_')[0]}
    ${all_template_comparator_report}    Create List
    #------Generate Comparator Report On Compass---------------#
    ${reproduce_kpi_info_path_on_ute}    ${reproduce_kpi_info_remote_server_store_path}    Run Keyword And Continue On Failure
    ...            Generate And Record Comparator Report On Compass And UTE
    ...            excel_report_path_on_ute=${list5_excel_report_path[0]}
    ...            filter_distnames=${comparator_filter_distnames}
    ...            output_report_prefix=${test_case_id}_List5_KPI_TMO_Reproduction_CRT_241125
    ...            first_description=${reproduce_kpi_info_target_build["swbuild_info"]}
    ...            first_start_time=${report_timestamps_target_build[0][0]}
    ...            first_end_time=${report_timestamps_target_build[0][1]}
    ...            second_description=${reproduce_kpi_info_source_build["swbuild_info"]}
    ...            second_start_time=${report_timestamps_source_build[0][0]}
    ...            second_end_time=${report_timestamps_source_build[0][1]}
    ...            template_names_list=List5_KPI_TMO_Reproduction_CRT_241125
    ...            template_id_list=1113
    ...            alpha_factor=0.005
    ...            comments="RepCase_${test_case_id}_List5_KPI_TMO_Reproduction_CRT_241125"
    ${total_kpi_info_path_on_ute}    ${total_kpi_info_remote_server_store_path}    Run Keyword And Continue On Failure
    ...            Generate And Record Comparator Report On Compass And UTE
    ...            excel_report_path_on_ute=${list1_excel_report_path[0]}
    ...            filter_distnames=${comparator_filter_distnames}
    ...            output_report_prefix=${test_case_id}_List1_KPI_TMO_24R1_SA_SG6
    ...            first_description=${reproduce_kpi_info_target_build["swbuild_info"]}
    ...            first_start_time=${report_timestamps_target_build[0][0]}
    ...            first_end_time=${report_timestamps_target_build[0][1]}
    ...            second_description=${reproduce_kpi_info_source_build["swbuild_info"]}
    ...            second_start_time=${report_timestamps_source_build[0][0]}
    ...            second_end_time=${report_timestamps_source_build[0][1]}
    ...            template_names_list=List1_KPI_TMO_24R1_SA_SG6
    ...            template_id_list=1037
    ...            alpha_factor=0.005
    ...            comments="RepCase_${test_case_id}_List1_KPI_TMO_24R1_SA_SG6"
    ${new_list_1025_kpi_info_path_on_ute}    ${new_list_1025_kpi_info_remote_server_store_path}    Run Keyword And Continue On Failure
    ...            Generate And Record Comparator Report On Compass And UTE
    ...            excel_report_path_on_ute=${list2_excel_report_path[0]}
    ...            filter_distnames=${comparator_filter_distnames}
    ...            output_report_prefix=${test_case_id}_List2_KPI_TMO_new_24R2_24R3_25R1
    ...            first_description=${reproduce_kpi_info_target_build["swbuild_info"]}
    ...            first_start_time=${report_timestamps_target_build[0][0]}
    ...            first_end_time=${report_timestamps_target_build[0][1]}
    ...            second_description=${reproduce_kpi_info_source_build["swbuild_info"]}
    ...            second_start_time=${report_timestamps_source_build[0][0]}
    ...            second_end_time=${report_timestamps_source_build[0][1]}
    ...            template_names_list=List2_KPI_TMO_new_24R2_24R3_25R1
    ...            template_id_list=1100
    ...            alpha_factor=0.005
    ...            comments="RepCase_${test_case_id}_List2_KPI_TMO_new_24R2_24R3_25R1"
    ${interference_kpi_info_path_on_ute}    ${interference_kpi_info_remote_server_store_path}    Run Keyword And Continue On Failure
    ...            Generate And Record Comparator Report On Compass And UTE
    ...            excel_report_path_on_ute=${list3_excel_report_path[0]}
    ...            filter_distnames=${comparator_filter_distnames}
    ...            output_report_prefix=${test_case_id}_List3_KPI_TMO_Interference
    ...            first_description=${reproduce_kpi_info_target_build["swbuild_info"]}
    ...            first_start_time=${report_timestamps_target_build[0][0]}
    ...            first_end_time=${report_timestamps_target_build[0][1]}
    ...            second_description=${reproduce_kpi_info_source_build["swbuild_info"]}
    ...            second_start_time=${report_timestamps_source_build[0][0]}
    ...            second_end_time=${report_timestamps_source_build[0][1]}
    ...            template_names_list=List3_KPI_TMO_Interference
    ...            template_id_list=1102
    ...            alpha_factor=0.005
    ...            comments="RepCase_${test_case_id}_List3_KPI_TMO_Interference"
    ${energy_saving_kpi_info_path_on_ute}    ${energy_saving_kpi_info_remote_server_store_path}    Run Keyword And Continue On Failure
    ...            Generate And Record Comparator Report On Compass And UTE
    ...            excel_report_path_on_ute=${list4_excel_report_path[0]}
    ...            filter_distnames=${comparator_filter_distnames}
    ...            output_report_prefix=${test_case_id}_List4_KPI_TMO_Energy_Saving_Bundle_SG6
    ...            first_description=${reproduce_kpi_info_target_build["swbuild_info"]}
    ...            first_start_time=${report_timestamps_target_build[0][0]}
    ...            first_end_time=${report_timestamps_target_build[0][1]}
    ...            second_description=${reproduce_kpi_info_source_build["swbuild_info"]}
    ...            second_start_time=${report_timestamps_source_build[0][0]}
    ...            second_end_time=${report_timestamps_source_build[0][1]}
    ...            template_names_list=List4_KPI_TMO_Energy_Saving_Bundle_SG6
    ...            template_id_list=1103
    ...            alpha_factor=0.005
    ...            comments="RepCase_${test_case_id}_List4_KPI_TMO_Energy_Saving_Bundle_SG6"
    ${slice_kpi_info_path_on_ute}    ${slice_kpi_info_remote_server_store_path}    Run Keyword And Continue On Failure
    ...            Generate And Record Comparator Report On Compass And UTE
    ...            excel_report_path_on_ute=${list7_excel_report_path[0]}
    ...            filter_distnames=${comparator_filter_distnames}
    ...            output_report_prefix=${test_case_id}_List7_KPI_TMO_Slice_SG6
    ...            first_description=${reproduce_kpi_info_target_build["swbuild_info"]}
    ...            first_start_time=${report_timestamps_target_build[0][0]}
    ...            first_end_time=${report_timestamps_target_build[0][1]}
    ...            second_description=${reproduce_kpi_info_source_build["swbuild_info"]}
    ...            second_start_time=${report_timestamps_source_build[0][0]}
    ...            second_end_time=${report_timestamps_source_build[0][1]}
    ...            template_names_list=List7_KPI_TMO_Slice_SG6
    ...            template_id_list=1122
    ...            alpha_factor=0.005
    ...            comments="RepCase_${test_case_id}_List7_KPI_TMO_Slice_SG6"
    Run Keyword If    '${reproduce_kpi_info_path_on_ute}'!='${None}'    Append To List
    ...    ${all_template_comparator_report}     ${reproduce_kpi_info_path_on_ute}
    Run Keyword If    '${total_kpi_info_path_on_ute}'!='${None}'    Append To List
    ...    ${all_template_comparator_report}     ${total_kpi_info_path_on_ute}
    Run Keyword If    '${new_list_1025_kpi_info_path_on_ute}'!='${None}'    Append To List
    ...    ${all_template_comparator_report}     ${new_list_1025_kpi_info_path_on_ute}
    Run Keyword If    '${interference_kpi_info_path_on_ute}'!='${None}'    Append To List
    ...    ${all_template_comparator_report}     ${interference_kpi_info_path_on_ute}
    Run Keyword If    '${energy_saving_kpi_info_path_on_ute}'!='${None}'    Append To List
    ...    ${all_template_comparator_report}     ${energy_saving_kpi_info_path_on_ute}
    Run Keyword If    '${slice_kpi_info_path_on_ute}'!='${None}'    Append To List
    ...    ${all_template_comparator_report}     ${slice_kpi_info_path_on_ute}
    ${ute_store_path}    Evaluate    '/'.join(${reproduce_kpi_info_path_on_ute.split('/')[0:-1]})
    ${server_store_path}    Evaluate    '/'.join(${reproduce_kpi_info_remote_server_store_path.split('/')[0:-1]})
    log    ${ute_store_path}
    log    ${server_store_path}
    ${prefix}      Set Variable    ${reproduce_kpi_info_path_on_ute.split('-')[1]}
    ${report_times}    Set Variable    ${reproduce_kpi_info_path_on_ute.split('-')[-1]}
    ${total_template_comparator_report_name}    Set Variable    ${tl_prefix}_${test_case_id}_${prefix}_${report_times}
    ${total_template_comparator_error_name}    Set Variable    ERROR_${tl_prefix}_${test_case_id}_${prefix}_${report_times}
    ${combination_results}    combine_multi_template_comparator_result
    ...    output_excel=${ute_store_path}/${total_template_comparator_report_name}
    ...    results_list=${all_template_comparator_report}
    ...    filter_distnames=${filter_distnames_list}
    Run Keyword And Ignore Error    upload_files_to_remote_server
    ...    local_path=${ute_store_path}/${total_template_comparator_report_name}
    ...    remote_path=${server_store_path}/${total_template_comparator_report_name}
    ...    hostname=${samba_server_ip}
    ...    username=${samba_server_username}
    ...    password=${samba_server_password}
    Run Keyword And Ignore Error    comparator_data_analysis
    ...    compare_report_path=${ute_store_path}/${total_template_comparator_report_name}
    ...    result_report_path=${ute_store_path}/${total_template_comparator_error_name}
    ...    filter_distnames=${filter_distnames_without_ALL}
    ...    is_fail_case=${is_error_fail_case}
    Run Keyword And Ignore Error    upload_files_to_remote_server
    ...    local_path=${ute_store_path}/${total_template_comparator_error_name}
    ...    remote_path=${server_store_path}/${total_template_comparator_error_name}
    ...    hostname=${samba_server_ip}
    ...    username=${samba_server_username}
    ...    password=${samba_server_password}


Generate And Record ALL Template KPI Report To Compass And UTE
    [Arguments]   ${report_timestamps}
    ...           ${comments}=5605005
    ...           ${filter_distnames}=bts,NRCELL-301
    ...           ${gnb_index}=${0}
    ...           ${group_name}=${comments}
    ...           ${is_active_package}=${True}
    ${test_case_id}    Set Variable    ${TEST NAME.split('_')[0]}
    ${all_template_excel_report}    Create List
    ${all_report_id}    Create List
    ${empty_list}    Create List
    ${filter_distnames}    Set Variable    ${filter_distnames.split(',')}
    ${list1_excel_report_path}    ${list1_report_id_list}    Run Keyword And Continue On Failure    Generate KPI Report And Record To Compass
    ...                           report_timestamps=${report_timestamps}
    ...                           comments=PZ4_SG06_${comments}_List1_KPI_TMO_24R1_SA_SG6
    ...                           template_name=List1_KPI_TMO_24R1_SA_SG6
    ...                           gnb_index=${gnb_index}
    ...                           is_active_package=${is_active_package}
    ${list2_excel_report_path}    ${list2_report_id_list}    Run Keyword And Continue On Failure    Generate KPI Report And Record To Compass
    ...                           report_timestamps=${report_timestamps}
    ...                           comments=PZ4_SG06_${comments}_List2_KPI_TMO_new_24R2_24R3_25R1
    ...                           template_name=List2_KPI_TMO_new_24R2_24R3_25R1
    ...                           gnb_index=${gnb_index}
    ...                           is_active_package=${is_active_package}
    ${list3_excel_report_path}    ${list3_report_id_list}    Run Keyword And Continue On Failure   Generate KPI Report And Record To Compass
    ...                           report_timestamps=${report_timestamps}
    ...                           comments=PZ4_SG06_${comments}_List3_KPI_TMO_Interference
    ...                           template_name=List3_KPI_TMO_Interference
    ...                           gnb_index=${gnb_index}
    ...                           is_active_package=${is_active_package}
    ${list4_excel_report_path}    ${list4_report_id_list}    Run Keyword And Continue On Failure    Generate KPI Report And Record To Compass
    ...                           report_timestamps=${report_timestamps}
    ...                           comments=PZ4_SG06_${comments}_List4_KPI_TMO_Energy_Saving_Bundle_SG6
    ...                           template_name=List4_KPI_TMO_Energy_Saving_Bundle_SG6
    ...                           gnb_index=${gnb_index}
    ...                           is_active_package=${is_active_package}
    ${list5_excel_report_path}    ${list5_report_id_list}    Run Keyword And Continue On Failure    Generate KPI Report And Record To Compass
    ...                           report_timestamps=${report_timestamps}
    ...                           comments=PZ4_SG06_${comments}_List5_KPI_TMO_Reproduction_CRT_241125
    ...                           template_name=List5_KPI_TMO_Reproduction_CRT_241125
    ...                           gnb_index=${gnb_index}
    ...                           is_active_package=${is_active_package}
    ${list7_excel_report_path}    ${list7_report_id_list}    Run Keyword And Continue On Failure    Generate KPI Report And Record To Compass
    ...                           report_timestamps=${report_timestamps}
    ...                           comments=PZ4_SG06_${comments}_List7_KPI_TMO_Slice_SG6
    ...                           template_name=List7_KPI_TMO_Slice_SG6
    ...                           gnb_index=${gnb_index}
    ...                           is_active_package=${is_active_package}
    ${Compass_25R1_New_KPIs_excel_report_path}    ${Compass_25R1_New_KPIs_report_id_list}
    ...                           Run Keyword And Continue On Failure    Generate KPI Report And Record To Compass
    ...                           report_timestamps=${report_timestamps}
    ...                           comments=PZ4_SG06_${comments}_Compass_25R1_New_KPIs
    ...                           template_name=Compass_25R1_New_KPIs
    ...                           gnb_index=${gnb_index}
    ...                           is_active_package=${is_active_package}
    ${Compass_25R1_TMO_MOP_KPIs_excel_report_path}    ${Compass_25R1_TMO_MOP_KPIs_report_id_list}
    ...                           Run Keyword And Continue On Failure    Generate KPI Report And Record To Compass
    ...                           report_timestamps=${report_timestamps}
    ...                           comments=PZ4_SG06_${comments}_Compass_25R1_TMO_MOP_KPIs
    ...                           template_name=Compass_25R1_TMO_MOP_KPIs
    ...                           gnb_index=${gnb_index}
    ...                           is_active_package=${is_active_package}
    ${Compass_25R2_New_KPIs_excel_report_path}    ${Compass_25R2_New_KPIs_report_id_list}
    ...                           Run Keyword And Continue On Failure    Generate KPI Report And Record To Compass
    ...                           report_timestamps=${report_timestamps}
    ...                           comments=PZ4_SG06_${comments}_Compass_25R2_New_KPIs
    ...                           template_name=Compass_25R2_New_KPIs
    ...                           gnb_index=${gnb_index}
    ...                           is_active_package=${is_active_package}
    ${Compass_25R2_TMO_MOP_KPIs_excel_report_path}    ${Compass_25R2_TMO_MOP_KPIs_report_id_list}
    ...                           Run Keyword And Continue On Failure    Generate KPI Report And Record To Compass
    ...                           report_timestamps=${report_timestamps}
    ...                           comments=PZ4_SG06_${comments}_Compass_25R2_TMO_MOP_KPIs
    ...                           template_name=Compass_25R2_TMO_MOP_KPIs
    ...                           gnb_index=${gnb_index}
    ...                           is_active_package=${is_active_package}
    ${Compass_25R2_TMO_MOP_KPIs_2_excel_report_path}    ${Compass_25R2_TMO_MOP_KPIs_2_report_id_list}
    ...                           Run Keyword And Continue On Failure    Generate KPI Report And Record To Compass
    ...                           report_timestamps=${report_timestamps}
    ...                           comments=PZ4_SG06_${comments}_Compass_25R2_TMO_MOP_KPIs_2
    ...                           template_name=Compass_25R2_TMO_MOP_KPIs_2
    ...                           gnb_index=${gnb_index}
    ...                           is_active_package=${is_active_package}
    ${Compass_25R3_New_KPIs_excel_report_path}    ${Compass_25R3_New_KPIs_report_id_list}
    ...                           Run Keyword And Continue On Failure    Generate KPI Report And Record To Compass
    ...                           report_timestamps=${report_timestamps}
    ...                           comments=PZ4_SG06_${comments}_Compass_25R3_New_KPIs
    ...                           template_name=Compass_25R3_New_KPIs
    ...                           gnb_index=${gnb_index}
    ...                           is_active_package=${is_active_package}
    ${Compass_25R3_TMO_MOP_KPIs_excel_report_path}    ${Compass_25R3_TMO_MOP_KPIs_report_id_list}
    ...                           Run Keyword And Continue On Failure    Generate KPI Report And Record To Compass
    ...                           report_timestamps=${report_timestamps}
    ...                           comments=PZ4_SG06_${comments}_Compass_25R3_TMO_MOP_KPIs
    ...                           template_name=Compass_25R3_TMO_MOP_KPIs
    ...                           gnb_index=${gnb_index}
    ...                           is_active_package=${is_active_package}
    ${Compass_26R1_New_KPIs_excel_report_path}    ${Compass_26R1_New_KPIs_report_id_list}
    ...                           Run Keyword And Continue On Failure    Generate KPI Report And Record To Compass
    ...                           report_timestamps=${report_timestamps}
    ...                           comments=PZ4_SG06_${comments}_Compass_26R1_New_KPIs
    ...                           template_name=Compass_26R1_New_KPIs
    ...                           gnb_index=${gnb_index}
    ...                           is_active_package=${is_active_package}
    ${Compass_26R2_New_KPIs_excel_report_path}    ${Compass_26R2_New_KPIs_report_id_list}
    ...                           Run Keyword And Continue On Failure    Generate KPI Report And Record To Compass
    ...                           report_timestamps=${report_timestamps}
    ...                           comments=PZ4_SG06_${comments}_Compass_26R2_New_KPIs
    ...                           template_name=Compass_26R2_New_KPIs
    ...                           gnb_index=${gnb_index}
    ...                           is_active_package=${is_active_package}
    ${Compass_26R3_New_KPIs_excel_report_path}    ${Compass_26R3_New_KPIs_report_id_list}
    ...                           Run Keyword And Continue On Failure    Generate KPI Report And Record To Compass
    ...                           report_timestamps=${report_timestamps}
    ...                           comments=PZ4_SG06_${comments}_Compass_26R3_New_KPIs
    ...                           template_name=Compass_26R3_New_KPIs
    ...                           gnb_index=${gnb_index}
    ...                           is_active_package=${is_active_package}
    #for seperate template
    Run Keyword And Ignore Error    Record KPI Report To UTE PC
    ...                             excel_report_path_on_ute=${list1_excel_report_path}
    ...                             filter_distnames=${filter_distnames}
    ...                             output_excel_name=${comments}_List1_KPI_TMO_24R1_SA_SG6.xlsx
    ...                             gnb_index=${gnb_index}
    Run Keyword And Ignore Error    Record KPI Report To UTE PC
    ...                             excel_report_path_on_ute=${list5_excel_report_path}
    ...                             filter_distnames=${filter_distnames}
    ...                             output_excel_name=${comments}_List5_KPI_TMO_Reproduction_CRT_241125.xlsx
    ...                             gnb_index=${gnb_index}
    ...                             group_name=${group_name}
    Run Keyword And Ignore Error    Record KPI Report To UTE PC
    ...                             excel_report_path_on_ute=${list2_excel_report_path}
    ...                             filter_distnames=${filter_distnames}
    ...                             output_excel_name=${comments}_List2_KPI_TMO_new_24R2_24R3_25R1.xlsx
    ...                             gnb_index=${gnb_index}
    Run Keyword And Ignore Error    Record KPI Report To UTE PC
    ...                             excel_report_path_on_ute=${list3_excel_report_path}
    ...                             filter_distnames=${filter_distnames}
    ...                             output_excel_name=${comments}_List3_KPI_TMO_Interference.xlsx
    ...                             gnb_index=${gnb_index}
    Run Keyword And Ignore Error    Record KPI Report To UTE PC
    ...                             excel_report_path_on_ute=${list4_excel_report_path}
    ...                             filter_distnames=${filter_distnames}
    ...                             output_excel_name=${comments}_List4_KPI_TMO_Energy_Saving_Bundle_SG6.xlsx
    ...                             gnb_index=${gnb_index}
    Run Keyword And Ignore Error    Record KPI Report To UTE PC
    ...                             excel_report_path_on_ute=${list7_excel_report_path}
    ...                             filter_distnames=${filter_distnames}
    ...                             output_excel_name=${comments}_List7_KPI_TMO_Slice_SG6.xlsx
    ...                             gnb_index=${gnb_index}
    Set Test Variable    ${list1_excel_report_path}
    Set Test Variable    ${list2_excel_report_path}
    Set Test Variable    ${list3_excel_report_path}
    Set Test Variable    ${list4_excel_report_path}
    Set Test Variable    ${list5_excel_report_path}
    Set Test Variable    ${list7_excel_report_path}
    Set Test Variable    ${list1_report_id_list}
    Set Test Variable    ${list2_report_id_list}
    Set Test Variable    ${list3_report_id_list}
    Set Test Variable    ${list4_report_id_list}
    Set Test Variable    ${list5_report_id_list}
    Set Test Variable    ${list7_report_id_list}
    Set Test Variable    ${Compass_25R1_New_KPIs_excel_report_path}
    Set Test Variable    ${Compass_25R1_TMO_MOP_KPIs_excel_report_path}
    Set Test Variable    ${Compass_25R2_New_KPIs_excel_report_path}
    Set Test Variable    ${Compass_25R2_TMO_MOP_KPIs_excel_report_path}
    Set Test Variable    ${Compass_25R2_TMO_MOP_KPIs_2_excel_report_path}
    Set Test Variable    ${Compass_25R3_New_KPIs_excel_report_path}
    Set Test Variable    ${Compass_25R3_TMO_MOP_KPIs_excel_report_path}
    Set Test Variable    ${Compass_26R1_New_KPIs_excel_report_path}
    Set Test Variable    ${Compass_26R2_New_KPIs_excel_report_path}
    Set Test Variable    ${Compass_26R3_New_KPIs_excel_report_path}
    Set Test Variable    ${Compass_25R1_New_KPIs_report_id_list}
    Set Test Variable    ${Compass_25R1_TMO_MOP_KPIs_report_id_list}
    Set Test Variable    ${Compass_25R2_New_KPIs_report_id_list}
    Set Test Variable    ${Compass_25R2_TMO_MOP_KPIs_report_id_list}
    Set Test Variable    ${Compass_25R2_TMO_MOP_KPIs_2_report_id_list}
    Set Test Variable    ${Compass_25R3_New_KPIs_report_id_list}
    Set Test Variable    ${Compass_25R3_TMO_MOP_KPIs_report_id_list}
    Set Test Variable    ${Compass_26R1_New_KPIs_report_id_list}
    Set Test Variable    ${Compass_26R2_New_KPIs_report_id_list}
    Set Test Variable    ${Compass_26R3_New_KPIs_report_id_list}
    #for combined template
    ${all_template_excel_report}    Run Keyword If    ${list1_excel_report_path}!=${None}    Combine Lists
    ...    ${all_template_excel_report}     ${list1_excel_report_path}
    ...    ELSE    Combine Lists    ${all_template_excel_report}    ${empty_list}
    ${all_template_excel_report}    Run Keyword If    ${list2_excel_report_path}!=${None}    Combine Lists
    ...    ${all_template_excel_report}     ${list2_excel_report_path}
    ...    ELSE    Combine Lists    ${all_template_excel_report}    ${empty_list}
    ${all_template_excel_report}    Run Keyword If    ${list3_excel_report_path}!=${None}    Combine Lists
    ...    ${all_template_excel_report}     ${list3_excel_report_path}
    ...    ELSE    Combine Lists    ${all_template_excel_report}    ${empty_list}
    ${all_template_excel_report}    Run Keyword If    ${list4_excel_report_path}!=${None}    Combine Lists
    ...    ${all_template_excel_report}     ${list4_excel_report_path}
    ...    ELSE    Combine Lists    ${all_template_excel_report}    ${empty_list}
    ${all_template_excel_report}    Run Keyword If    ${list7_excel_report_path}!=${None}    Combine Lists
    ...    ${all_template_excel_report}     ${list7_excel_report_path}
    ...    ELSE    Combine Lists    ${all_template_excel_report}    ${empty_list}
    ${all_template_excel_report}    Run Keyword If    ${list5_excel_report_path}!=${None}    Combine Lists
    ...    ${all_template_excel_report}     ${list5_excel_report_path}
    ...    ELSE    Combine Lists    ${all_template_excel_report}    ${empty_list}
    ${all_template_excel_report}    Run Keyword If    ${Compass_25R1_New_KPIs_excel_report_path}!=${None}    Combine Lists
    ...    ${all_template_excel_report}     ${Compass_25R1_New_KPIs_excel_report_path}
    ...    ELSE    Combine Lists    ${all_template_excel_report}    ${empty_list}
    ${all_template_excel_report}    Run Keyword If    ${Compass_25R1_TMO_MOP_KPIs_excel_report_path}!=${None}    Combine Lists
    ...    ${all_template_excel_report}     ${Compass_25R1_TMO_MOP_KPIs_excel_report_path}
    ...    ELSE    Combine Lists    ${all_template_excel_report}    ${empty_list}
    ${all_template_excel_report}    Run Keyword If    ${Compass_25R2_New_KPIs_excel_report_path}!=${None}    Combine Lists
    ...    ${all_template_excel_report}     ${Compass_25R2_New_KPIs_excel_report_path}
    ...    ELSE    Combine Lists    ${all_template_excel_report}    ${empty_list}
    ${all_template_excel_report}    Run Keyword If    ${Compass_25R2_TMO_MOP_KPIs_excel_report_path}!=${None}    Combine Lists
    ...    ${all_template_excel_report}     ${Compass_25R2_TMO_MOP_KPIs_excel_report_path}
    ...    ELSE    Combine Lists    ${all_template_excel_report}    ${empty_list}
    ${all_template_excel_report}    Run Keyword If    ${Compass_25R2_TMO_MOP_KPIs_2_excel_report_path}!=${None}    Combine Lists
    ...    ${all_template_excel_report}     ${Compass_25R2_TMO_MOP_KPIs_2_excel_report_path}
    ...    ELSE    Combine Lists    ${all_template_excel_report}    ${empty_list}
    ${all_template_excel_report}    Run Keyword If    ${Compass_25R3_New_KPIs_excel_report_path}!=${None}    Combine Lists
    ...    ${all_template_excel_report}     ${Compass_25R3_New_KPIs_excel_report_path}
    ...    ELSE    Combine Lists    ${all_template_excel_report}    ${empty_list}
    ${all_template_excel_report}    Run Keyword If    ${Compass_25R3_TMO_MOP_KPIs_excel_report_path}!=${None}    Combine Lists
    ...    ${all_template_excel_report}     ${Compass_25R3_TMO_MOP_KPIs_excel_report_path}
    ...    ELSE    Combine Lists    ${all_template_excel_report}    ${empty_list}
    ${all_template_excel_report}    Run Keyword If    ${Compass_26R1_New_KPIs_excel_report_path}!=${None}    Combine Lists
    ...    ${all_template_excel_report}     ${Compass_26R1_New_KPIs_excel_report_path}
    ...    ELSE    Combine Lists    ${all_template_excel_report}    ${empty_list}
    ${all_template_excel_report}    Run Keyword If    ${Compass_26R2_New_KPIs_excel_report_path}!=${None}    Combine Lists
    ...    ${all_template_excel_report}     ${Compass_26R2_New_KPIs_excel_report_path}
    ...    ELSE    Combine Lists    ${all_template_excel_report}    ${empty_list}
    ${all_template_excel_report}    Run Keyword If    ${Compass_26R3_New_KPIs_excel_report_path}!=${None}    Combine Lists
    ...    ${all_template_excel_report}     ${Compass_26R3_New_KPIs_excel_report_path}
    ...    ELSE    Combine Lists    ${all_template_excel_report}    ${empty_list}
    #combine report_id
    ${all_report_id}    Run Keyword If    ${list1_report_id_list}!=${None}    Combine Lists
    ...    ${all_report_id}     ${list1_report_id_list}
    ...    ELSE    Combine Lists    ${all_report_id}   ${empty_list}
    ${all_report_id}    Run Keyword If    ${list2_report_id_list}!=${None}    Combine Lists
    ...    ${all_report_id}     ${list2_report_id_list}
    ...    ELSE    Combine Lists    ${all_report_id}    ${empty_list}
    ${all_report_id}    Run Keyword If    ${list3_report_id_list}!=${None}    Combine Lists
    ...    ${all_report_id}     ${list3_report_id_list}
    ...    ELSE    Combine Lists    ${all_report_id}    ${empty_list}
    ${all_report_id}    Run Keyword If    ${list4_report_id_list}!=${None}    Combine Lists
    ...    ${all_report_id}    ${list4_report_id_list}
    ...    ELSE    Combine Lists    ${all_report_id}    ${empty_list}
    ${all_report_id}    Run Keyword If    ${list7_report_id_list}!=${None}    Combine Lists
    ...    ${all_report_id}     ${list7_report_id_list}
    ...    ELSE    Combine Lists    ${all_report_id}    ${empty_list}
    ${all_report_id}    Run Keyword If    ${list5_report_id_list}!=${None}    Combine Lists
    ...    ${all_report_id}     ${list5_report_id_list}
    ...    ELSE    Combine Lists    ${all_report_id}    ${empty_list}
    ${all_report_id}    Run Keyword If    ${Compass_25R1_New_KPIs_report_id_list}!=${None}    Combine Lists
    ...    ${all_report_id}     ${Compass_25R1_New_KPIs_report_id_list}
    ...    ELSE    Combine Lists    ${all_report_id}    ${empty_list}
    ${all_report_id}    Run Keyword If    ${Compass_25R1_TMO_MOP_KPIs_report_id_list}!=${None}    Combine Lists
    ...    ${all_report_id}     ${Compass_25R1_TMO_MOP_KPIs_report_id_list}
    ...    ELSE    Combine Lists    ${all_report_id}    ${empty_list}
    ${all_report_id}    Run Keyword If    ${Compass_25R2_New_KPIs_report_id_list}!=${None}    Combine Lists
    ...    ${all_report_id}     ${Compass_25R2_New_KPIs_report_id_list}
    ...    ELSE    Combine Lists    ${all_report_id}    ${empty_list}
    ${all_report_id}    Run Keyword If    ${Compass_25R2_TMO_MOP_KPIs_report_id_list}!=${None}    Combine Lists
    ...    ${all_report_id}     ${Compass_25R2_TMO_MOP_KPIs_report_id_list}
    ...    ELSE    Combine Lists    ${all_report_id}    ${empty_list}
    ${all_report_id}    Run Keyword If    ${Compass_25R2_TMO_MOP_KPIs_2_report_id_list}!=${None}    Combine Lists
    ...    ${all_report_id}     ${Compass_25R2_TMO_MOP_KPIs_2_report_id_list}
    ...    ELSE    Combine Lists    ${all_report_id}    ${empty_list}
    ${all_report_id}    Run Keyword If    ${Compass_25R3_New_KPIs_report_id_list}!=${None}    Combine Lists
    ...    ${all_report_id}     ${Compass_25R3_New_KPIs_report_id_list}
    ...    ELSE    Combine Lists    ${all_report_id}    ${empty_list}
    ${all_report_id}    Run Keyword If    ${Compass_25R3_TMO_MOP_KPIs_report_id_list}!=${None}    Combine Lists
    ...    ${all_report_id}     ${Compass_25R3_TMO_MOP_KPIs_report_id_list}
    ...    ELSE    Combine Lists    ${all_report_id}    ${empty_list}
    ${all_report_id}    Run Keyword If    ${Compass_26R1_New_KPIs_report_id_list}!=${None}    Combine Lists
    ...    ${all_report_id}     ${Compass_26R1_New_KPIs_report_id_list}
    ...    ELSE    Combine Lists    ${all_report_id}    ${empty_list}
    ${all_report_id}    Run Keyword If    ${Compass_26R2_New_KPIs_report_id_list}!=${None}    Combine Lists
    ...    ${all_report_id}     ${Compass_26R2_New_KPIs_report_id_list}
    ...    ELSE    Combine Lists    ${all_report_id}    ${empty_list}
    ${all_report_id}    Run Keyword If    ${Compass_26R3_New_KPIs_report_id_list}!=${None}    Combine Lists
    ...    ${all_report_id}     ${Compass_26R3_New_KPIs_report_id_list}
    ...    ELSE    Combine Lists    ${all_report_id}    ${empty_list}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${combined_report}    combine_multi_templates_kpi_report_result
    ...    output_excel=/home/ute/KPI_Report/Scout_KPI_Report/${test_case_id}/Excel_KPI/${test_case_id}_${gnb_version}_${timestamp}.xlsx
    ...    results_list=${all_template_excel_report}
    ${timestamp_kpi}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d
    ${reproduce_kpi_values}    record_kpi_reports_for_all_templates
    ...    package_info=exec${timestamp_kpi}_${gnb_version}_${btsName}
    ...    repcase_id=${test_case_id}
    ...    excel_report_path=${combined_report}
    ...    output_report_path=/home/ute/KPI_Report/Scout_KPI_Report/${test_case_id}/${tl_prefix}_${test_case_id}_ALL_TEMPLATES.xlsx
    ...    filter_distnames=${filter_distnames}
    ${origin_report_name}    Set Variable    ${test_case_id}_${gnb_version}_${timestamp}.xlsx
    ${all_template_report}    Set Variable    Scout_KPI_Report/${tl_prefix}_${test_case_id}_ALL_TEMPLATES.xlsx
    ${kpi_rule_report}    Set Variable    Scout_KPI_Report/${tl_prefix}_${test_case_id}_KPI_RULE_RESULT.xlsx
    Run Keyword And Ignore Error    upload_files_to_remote_server
    ...    local_path=${combined_report}
    ...    remote_path=/home/hz4sg6/shared/01_E2E_Rep/${test_case_id}/${test_case_id}_${tl_prefix}/Excel_KPI/${origin_report_name}
    ...    hostname=${samba_server_ip}
    ...    username=${samba_server_username}
    ...    password=${samba_server_password}
    Run Keyword And Ignore Error    upload_files_to_remote_server
    ...    local_path=/home/ute/KPI_Report/Scout_KPI_Report/${test_case_id}/${tl_prefix}_${test_case_id}_ALL_TEMPLATES.xlsx
    ...    remote_path=/home/hz4sg6/shared/01_E2E_Rep/${test_case_id}/${test_case_id}_${tl_prefix}/${all_template_report}
    ...    hostname=${samba_server_ip}
    ...    username=${samba_server_username}
    ...    password=${samba_server_password}
    ${total_kpi_info}    Create Dictionary    swbuild_info=${gnb_version}_${btsName}
    ...                                       report_period=${report_timestamps}
    ...                                       excel_report_path=${combined_report}
    ...                                       reproduce_kpi_values=${reproduce_kpi_values}
    ...                                       report_id_list=${all_report_id}
#    ${combine_report_id}    Run Keyword And Continue On Failure    combine_kpi_reports_on_compass    report_id_list=${all_report_id}
#    Run Keyword If    '${combine_report_id}'=='${None}'     Fail     msg=combine reports on compass failed
#    ${combine_report_id_list}    Create List    ${combine_report_id}
#    Run Keyword And Continue On Failure    analysis_kpi_reports_on_compass    report_id_list=${combine_report_id_list}
#    Run Keyword And Continue On Failure    analysis_kpi_rule_result   report_id=${combine_report_id}
#    ...    output_report_path=/home/ute/KPI_Report/Scout_KPI_Report/${test_case_id}/${tl_prefix}_${test_case_id}_KPI_RULE_RESULT.xlsx
#    ...    package_info=${gnb_version}_${btsName}_${timestamp}
#    Run Keyword And Ignore Error    upload_files_to_remote_server
#    ...    local_path=/home/ute/KPI_Report/Scout_KPI_Report/${test_case_id}/${tl_prefix}_${test_case_id}_KPI_RULE_RESULT.xlsx
#    ...    remote_path=/home/hz4sg6/shared/01_E2E_Rep/${test_case_id}/${test_case_id}_${tl_prefix}/${kpi_rule_report}
#    ...    hostname=${samba_server_ip}
#    ...    username=${samba_server_username}
#    ...    password=${samba_server_password}
    [Return]    ${total_kpi_info}