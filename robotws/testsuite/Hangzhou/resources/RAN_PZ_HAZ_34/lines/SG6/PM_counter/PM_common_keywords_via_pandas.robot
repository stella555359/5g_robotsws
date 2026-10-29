*** Settings ***
Documentation    This is for PM counter via scout.
...              Please do not modify the file without notification to author
...              Author: lei.jia@nokia-sbell.com
Library    BuiltIn
Library    Collections
Library    OperatingSystem
Library    String
Library    DateTime
Library     taf.sw.scout    WITH NAME   scout
Library   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/PM_counter/KPI_report_with_pandas.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Resources.robot

*** Variables ***
${testline}         ${testline_name}


*** Keywords ***
Get KPI Report From Scout And Convert To Excel
    [Documentation]   lei.jia@nokia-sbell.com
    ...               Note: one scout count have one api key, please replace with your own api-keys during testing
    [Arguments]    ${start_time}    ${end_time}    ${template_id}=1565
    ...            ${file_path}=/home/ute/KPI_report/
    ...            ${api_key}=5954d576-f448-41ee-b3e1-73180ea6a0cb
    ...            ${scout_testline_name}=${testline}
    ...            ${report_name}=${scout_testline_name}_kpi_report
    ...            ${stream_version}=24R2
    ...            ${try_index}=0
    ...            ${scf_version}=24R2
    ...            ${sw_version}=${None}
    ${timestamp}    Get current date    result_format=%Y%m%dT%H%M%S
    ${report}    Generate KPI Report From Scout    start_time=${start_time}
    ...                                       end_time=${end_time}
    ...                                       template_id=${template_id}
    ...                                       api_key=${api_key}
    ...                                       report_name=${report_name}_${timestamp}
    ...                                       scout_testline_name=${scout_testline_name}
    ${kpi_output_file_path}    Join path    ${file_path}    ${report_name}_${timestamp}.xlsx
    Convert Genrated KPI Report To Excel    report=${report}    file_path=${kpi_output_file_path}
    ...                                     stream_version=${stream_version}
    ...                                     try_index=${try_index}
    ...                                     scf_version=${scf_version}
    ...                                     sw_version=${sw_version}
    [Return]    ${kpi_output_file_path}

Generate KPI Report From Scout
    [Documentation]   lei.jia@nokia-sbell.com
    ...               Param: the style of ${end_time} and ${start_time} like as "2022-03-29 04:10:00"
    ...                      Time delta between start and end must be above 15 minutes"
    ...                      ${end_time} and ${start_time}:  Date and time must be in past
    ...                      Use the pm xml file under the path "/ffs/run/uri/PERFMON_FILES/" of gnb
    ...                      if " -rw-r--r-- 1 root btssw  72682 Mar 31 11:35 PM.BTS-813.20220331.033500.ANY.xml.gz "
    ...                      so ${end_time} or ${start_time} use 20220331.033500 into "2022-03-31 03:35:00"
    ...               Param: ${template_id}---https://scout.nsn-rdnet.net/kpis-templates/382/, 382 is ${template_id}
    ...               Param: ${api_key}---scout for easy access from robot framework to Scout API
    ...                      Note: one scout count have one api key, please replace with your own api-keys during testing
    [Arguments]    ${start_time}
    ...            ${end_time}
    ...            ${template_id}=1565
    ...            ${api_key}=5954d576-f448-41ee-b3e1-73180ea6a0cb
     ...           ${timeout}=360
    ...            ${interval}=30 minutes
    ...            ${alias}=scout
    ...            ${scout_testline_name}=${testline}
    ...            ${report_name}=${scout_testline_name}_kpi_report
    # it takes 30 minutes for gnb to sync counters to scout.
    ${curr_time} = 	DateTime.Get Current Date 	time_zone=UTC     exclude_millis=yes
    ${added_end_time}    Add Time To Date    ${end_time}    ${interval}    exclude_millis=yes
    ${difference}  Subtract Date From Date    ${added_end_time}    ${curr_time}
    ...    timer    exclude_millis=True
    Run Keyword If  '${difference}'>'00:00:01'
    ...    Run Keywords    Log  Sleep for ${difference} until scout sync finished  console=true
    ...             AND    Sleep  ${difference}
    scout.setup_scout    scout_testline_name=${scout_testline_name}    api_key=${api_key}    timeout=${timeout}    alias=${alias}
    ${report}    scout.generate kpi report    report_name=${report_name}
    ...                                       template_id=${template_id}
    ...                                       start_time=${start_time}
    ...                                       end_time=${end_time}
    ...                                       alias=${alias}
    [Return]    ${report}
    [Teardown]    Run Keyword And Ignore Error    scout.teardown_scout_api    alias=${alias}

Convert Genrated KPI Report To Excel
    [Documentation]   lei.jia@nokia-sbell.com
    [Arguments]    ${report}
    ...            ${file_path}=/home/ute/KPI_report/${testline}_kpi_report.xlsx
    ...            ${stream_version}=24R2
    ...            ${try_index}=0
    ...            ${scf_version}=24R2
    ...            ${sw_version}=${None}
    KPI_report_with_pandas.generate_excel_report    file_path=${file_path}
    ...                                 scout_report=${report}
    ...                                 stream_version=${stream_version}
    ...                                 try_index=${try_index}
    ...                                 scf_version=${scf_version}
    ...                                 sw_version=${sw_version}

Caculate timeToSleep Before Next Counters Period
    [Documentation]    Author:lei.jia
    ...        This function calculates the time to sleep before the start of the next PM counters period
    ...    ${counterPeriod} defined the PM counter Period in mins: either 5min or 15min.
    ...    ${offset}        defined the minimum time (in seconds) before the start of the next PM counters period
    ...    return: the time to sleep (in seconds) before the next PM counters period
    [Arguments]    ${counter_period}=5    ${offset}=30
    ${currTime}     robot.libraries.DateTime.Get Current Date
    ${currTime}     robot.libraries.DateTime.Convert Date    ${currTime}     epoch
    ${getNextTimeSlot}     Evaluate   (int((${currTime} / (int(${counter_period}) * 60))) + 1) * (int(${counter_period}) * 60)
    ${timeToSleep}     Evaluate    int(${getNextTimeSlot} - ${currTime}) + 1
    ${tempTime}    Evaluate    ${timeToSleep}+ int(${counter_period}) * 60
    ${timeToSleep}    Set Variable If    ${timeToSleep} < int(${offset})
    ...        ${tempTime}    ${timeToSleep}
    ${timeToSleep}    Evaluate     ${timeToSleep} + 60
    [Return]    ${timeToSleep}


KPI.Generate kpi report in Scout
    [Documentation]   stella.lin@nokia-sbell.com
    ...               Param: ${scout_testline_name} is "TL73_gNB" or "TL813_gNB", scout_testline_name in scout, type: str
    ...               Param: the style of ${end_time} and ${start_time} like as "2022-03-29 04:10:00"
    ...                      Time delta between start and end must be above 15 minutes"
    ...                      ${end_time} and ${start_time}:  Date and time must be in past
    ...                      Use the pm xml file under the path "/ffs/run/uri/PERFMON_FILES/" of gnb
    ...                      if " -rw-r--r-- 1 root btssw  72682 Mar 31 11:35 PM.BTS-813.20220331.033500.ANY.xml.gz "
    ...                      so ${end_time} or ${start_time} use 20220331.033500 into "2022-03-31 03:35:00"
    ...               Param: ${template_id}---https://scout.nsn-rdnet.net/kpis-templates/382/, 382 is ${template_id}
    ...               Param: ${api_key}---scout for easy access from robot framework to Scout API
    [Arguments]    ${tl_name}
    ...            ${start_time}
    ...            ${end_time}
    ...            ${comments}=PZ4_SG06_KPI_Report
    ...            ${template_name}=KPI_24R1_TMO_SA_SG6
    ...            ${check_out_entry}=false
    ...            ${gnb_index}=${0}
    ...            ${connection}=GNB_OAM${gnb_index}
    ...            ${is_active_package}=${True}
    ${test_case_id}    Set Variable    ${TEST NAME.split('_')[0]}
    ${active_sw}    Run Keyword If    ${is_active_package}    get_build_version_from_robot_variables
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${current_sw_version}     coam.get_sw_version    connection=GNB_OAM${gnb_index}
    ${sw_version}    Set Variable If    ${is_active_package}    ${active_sw}    ${current_sw_version}
    ${report_time}  DateTime.Get Current Date  result_format=%Y-%m-%d %H:%M:%S
#    ${report_date}    Get Substring    ${report_time}    0    10
    ${kpi_report_name}   Catenate    SEPARATOR=_   PZ4_SG06    ${tl_name}   ${sw_version}
    ${report_id}    Wait Until Keyword Succeeds    3x    30s    generate_new_report_on_compass
    ...    report_name=${kpi_report_name}
    ...    tl_id=${tl_name}
    ...    package_version=${test_case_id}_${sw_version}
    ...    start_time=${start_time}
    ...    end_time=${end_time}
    ...    comments=${comments}
    ...    template_name=${template_name}
    ...    check_out_entry=${check_out_entry}
    Set Test Variable    ${report_id}
    Run keyword If    '${report_id}'=='${None}'     fail    msg=failed to get scout report id.
    ${excel_file_name}    download_kpi_file    report_id=${report_id}    path=${excel_kpi_download_path}
    [Return]    ${excel_file_name}    ${report_id}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

KPI.Generate Comparator Report On Compass
    [Arguments]    ${first_description}
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
    ${test_line_name}    Set Variable If    '${tl_prefix}'=='T284'    7_5_UTE402T284
    ...     '${tl_prefix}'=='T080' and '${gnb_index}'=='${0}'    7_5_UTE5G402T080
    ...     '${tl_prefix}'=='T080' and '${gnb_index}'=='${1}'    7_5_UTE5G402T282
    ...     '${tl_prefix}'=='T073'    7_5_CLOUD402T073
    ...     '${tl_prefix}'=='T283'    7_5_UTE5G402T283
    ...     '${tl_prefix}'=='T813'    7_5_UTE5G402T813
    ...     '${tl_prefix}'=='T816'    7_5_UTE5G402T816
    ...      7_5_UTE5G402${tl_prefix}
    log to console    start to generate kpi comparator report on compass for ${test_line_name}
    ${test_line_id}     Set Variable If    '${test_line_name}'=='7_5_UTE5G402T080'    TL_1745
    ...                                    '${test_line_name}'=='7_5_UTE5G402T282'    TL_8431
    ...                                    '${test_line_name}'=='7_5_UTE402T284'    TL_976
    ...                                    '${test_line_name}'=='7_5_CLOUD402T073'    TL73_gNB
    ...                                    '${test_line_name}'=='7_5_UTE5G402T813'    TL813_gNB
    ...                                    '${test_line_name}'=='7_5_UTE5G402T816'    TL816
    ...                                    '${test_line_name}'=='7_5_UTE5G402T283'    TL_982
    ...                                     ${tl_prefix}_gNB
    ${template_names_list}    Create List     ${template_names_list}
    ${template_id_list}    Create List     ${template_id_list}
    ${report_time}  DateTime.Get Current Date  result_format=%Y-%m-%d %H:%M:%S
    ${report_date}    Get Substring    ${report_time}    0    10
    ${report_name}   Catenate    SEPARATOR=_   PZ4_SG06    ${report_date}   ${test_line_name}   ${first_description}
    ${comparator_report_id}     Wait Until Keyword Succeeds    3x    30s    generate_new_comparator_report_on_compass
    ...     report_name=${report_name}
    ...     test_line_id=${test_line_id}
    ...     test_line_name=${test_line_name}
    ...     template_names_list=${template_names_list}
    ...     template_id_list=${template_id_list}
    ...     first_description=${first_description}
    ...     first_start_time= ${first_start_time}
    ...     first_end_time=${first_end_time}
    ...     second_description=${second_description}
    ...     second_start_time=${second_start_time}
    ...     second_end_time=${second_end_time}
    ...     alpha_factor=${alpha_factor}
    ...     comments=${comments}
#    Set Test Variable    ${comparator_report_id}
    Run keyword If    '${comparator_report_id}'=='${None}'     fail    msg=failed to get scout comparator report id.
    [Return]    ${comparator_report_id}

Compass.Generate KPI Report
    [Documentation]   stella.lin@nokia-sbell.com
    ...               Param: ${scout_testline_name} is "TL73_gNB" or "TL813_gNB", scout_testline_name in scout, type: str
    ...               Param: the style of ${end_time} and ${start_time} like as "2022-03-29 04:10:00"
    ...                      Time delta between start and end must be above 15 minutes"
    ...                      ${end_time} and ${start_time}:  Date and time must be in past
    ...                      Use the pm xml file under the path "/ffs/run/uri/PERFMON_FILES/" of gnb
    ...                      if " -rw-r--r-- 1 root btssw  72682 Mar 31 11:35 PM.BTS-813.20220331.033500.ANY.xml.gz "
    ...                      so ${end_time} or ${start_time} use 20220331.033500 into "2022-03-31 03:35:00"
    ...               Param: ${template_id}---https://scout.nsn-rdnet.net/kpis-templates/382/, 382 is ${template_id}
    ...               Param: ${api_key}---scout for easy access from robot framework to Scout API
    [Arguments]    ${timestamp_list}
    ...            ${check_out_entry}=false
    ...            ${gnb_index}=${0}
    ...            ${connection}=GNB_OAM${gnb_index}
    ...            ${download_report}=${False}
    ...            ${test_comments}=${EMPTY}
    ...            ${restore_path}=/home/ute/Compass_Report
    log    ${connection}
    log to console    report timestap is:${timestamp_list}
    ${scout_name}    Set Variable If    '${tl_prefix}'=='T284'    7_5_UTE402T284
    ...     '${tl_prefix}'=='T080' and '${gnb_index}'=='${0}'    7_5_UTE5G402T080
    ...     '${tl_prefix}'=='T080' and '${gnb_index}'=='${1}'    7_5_UTE5G402T282
    ...     '${tl_prefix}'=='T073'    7_5_CLOUD402T073
    ...     '${tl_prefix}'=='T283'    7_5_UTE5G402T283
    ...     '${tl_prefix}'=='T813'    7_5_UTE5G402T813
    ...     '${tl_prefix}'=='T816'    7_5_UTE5G402T816
    log to console    start to generate kpi report on compass for ${scout_name}
##    ${test_case_id}    Set Variable    ${TEST NAME.split('_')[0]}
##    ${sw_build}    get_build_version_from_robot_variables
##    ${status}    ${sw_info}     Run Keyword And Ignore Error
##    ...    Get BtsName and SwVersion    gnb_id=${gnb_index}    connection=${connection}
##    ${sw_version}     Set Variable If   '${status}'=='PASS'     ${sw_info[0]}_${sw_info[1]}    ${sw_build}
    ${bts_name}    ${sw_version}    Wait Until Keyword Succeeds    3x    30s
    ...     Get BtsName and SwVersion    gnb_id=${gnb_index}    connection=${connection}
    ${release_info}    Set Variable     ${sw_version.split('_')[0].split('BTS')[1]}
    ${bts_name_format}    Replace String    ${bts_name}    _    .
    ${sw_version_format}    Replace String    ${sw_version}    _    .
    log to console    release is ${release_info}
    ${report_timestamp}    Get current date    result_format=%Y%m%dT%H%M%S
    ${formatted_start_timestamp}    Convert Date    ${timestamp_list[0]}    result_format=%Y%m%dT%H%M%S
    ${formatted_end_timestamp}    Convert Date    ${timestamp_list[1]}    result_format=%Y%m%dT%H%M%S
    ${kpi_report_name}   Catenate    SEPARATOR=_   SG06    ${sw_version}   ${formatted_start_timestamp}
    ${report_id_list}     Create List
    ${template_names_list}    get_kpi_template_names_based_on_branch    release=${release_info}
    ${current_date}    Get Current Date    result_format=%m%d
#    ${package_version}     Set Variable    exec${formatted_start_timestamp}_${test_comments}_${bts_name}_${sw_version}
    ${package_version}     Set Variable
    ...    exec${formatted_start_timestamp}_${sw_version_format}_${tl_prefix}.SCF.${bts_name_format}_${test_comments}_1csv
    FOR    ${template}    IN   @{template_names_list}
        Log To Console     start to get kpi report for ${template}
        ${status}    ${report_id}    Run Keyword And Ignore Error    generate_new_report_on_compass
        ...    report_name=${kpi_report_name}
        ...    tl_id=${scout_name}
        ...    package_version=${package_version}
        ...    start_time=${timestamp_list[0]}
        ...    end_time=${timestamp_list[1]}
        ...    template_name=${template}
        ...    check_out_entry=${check_out_entry}
        Run Keyword If  "${status}"=="PASS"   Append To List    ${report_id_list}    ${report_id}
    END
    log    ${report_id_list}
    Sleep   15sec
    ${combine_report_id}    combine_kpi_reports_on_compass    report_id_list=${report_id_list}
    ${full_path}    create_kpi_report_directories    base_path=${restore_path}
    ...    subdirs=${TEST NAME}/${sw_version}
    ${kpi_report}    Run Keyword If    ${download_report}    Wait Until Keyword Succeeds    5x    30s
    ...    get_kpi_result_from_compass    report_id=${combine_report_id}
    ...    output_report=${full_path}/KpiReport_${test_comments}_${sw_version}_${formatted_start_timestamp}_to_${formatted_end_timestamp}.xlsx
    ...    package_version=${package_version}
    [Return]    ${combine_report_id}    ${kpi_report}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Compass.Compare KPI Report
    [Arguments]    ${report_ids}
    ...            ${gnb_index}=${0}
    ...            ${connection}=GNB_OAM${gnb_index}
    ...            ${restore_path}=/home/ute/Compass_Report
    ...            ${test_comments}=${EMPTY}
#    ${test_case_id}    Set Variable    ${TEST NAME.split('_')[0]}
#    ${sw_version}    get_build_version_from_robot_variables
    ${bts_name}    ${sw_version}    Wait Until Keyword Succeeds    3x    30s
    ...     Get BtsName and SwVersion    gnb_id=${gnb_index}    connection=${connection}
    ${bts_name_format}    Replace String    ${bts_name}    _    .
    ${sw_version_format}    Replace String    ${sw_version}    _    .
    ${report_timestamp}    Get current date    result_format=%Y%m%dT%H%M%S
    ${full_path}    create_kpi_report_directories    base_path=${restore_path}
    ...    subdirs=${TEST NAME}/${sw_version}
    ${full_name}    Set Variable
    ...    exec${report_timestamp}_${sw_version_format}_${tl_prefix}.SCF.${bts_name_format}_${test_comments}_1csv
    ${output_file}     Set Variable    ${full_path}/${full_name}.xlsx
    get_compare_kpi_report_from_compass    reports=${report_ids}
    ...    file_name=${output_file}
    [Return]    ${output_file}

Compass.Merge KPI Report
    [Arguments]    ${report_id_list}
    ...            ${gnb_index}=${0}
    ...            ${connection}=GNB_OAM${gnb_index}
    ...            ${restore_path}=/home/ute/Compass_Report
    ...            ${test_comments}=${EMPTY}
#    ${test_case_id}    Set Variable    ${TEST NAME.split('_')[0]}
#    ${sw_version}    get_build_version_from_robot_variables
    ${bts_name}    ${sw_version}    Wait Until Keyword Succeeds    3x    30s
    ...     Get BtsName and SwVersion    gnb_id=${gnb_index}    connection=${connection}
    ${bts_name_format}    Replace String    ${bts_name}    _    .
    ${sw_version_format}    Replace String    ${sw_version}    _    .
    ${report_timestamp}    Get current date    result_format=%Y%m%dT%H%M%S
    ${full_path}    create_kpi_report_directories    base_path=${restore_path}
    ...    subdirs=${TEST NAME}/${sw_version}
    ${full_name}    Set Variable
    ...    exec${report_timestamp}_${sw_version_format}_${tl_prefix}.SCF.${bts_name_format}_${test_comments}_1csv
    ${output_file}     Set Variable    ${full_path}/${full_name}.xlsx
    get_horizontal_merge_reports    report_id_list=${report_id_list}
    ...    file_path=${output_file}
    [Return]    ${output_file}

Compass.Save Compare KPI Report
    [Arguments]    ${report_ids}
    ...            ${gnb_index}=${0}
    ...            ${connection}=GNB_OAM${gnb_index}
    ...            ${restore_path}=/home/ute/Compass_Report
    ...            ${test_comments}=${EMPTY}
    ${report_id_list}    Evaluate    [id.strip() for id in ${report_ids.split(',')}]
    ${len}    Get Length   ${report_id_list}
    ${formatted_report_ids}    Evaluate    '&'.join(${report_id_list})
    log to console     ${formatted_report_ids}
    ${reports_id_input}    Set Variable If    ${len}>${3}     ${report_id_list}    ${formatted_report_ids}
    ${output_file}    Run Keyword If    ${len}>${3}    Compass.Merge KPI Report     report_id_list=${reports_id_input}
    ...    gnb_index=${gnb_index}    connection=${connection}    restore_path=${restore_path}    test_comments=${test_comments}
    ...     ELSE        Compass.Compare KPI Report      report_ids=${reports_id_input}
    ...    gnb_index=${gnb_index}    connection=${connection}    restore_path=${restore_path}     test_comments=${test_comments}
    [Return]    ${output_file}

Compass.Append Result To Excel
    [Arguments]    ${append_kpi_report_path}
    ...            ${gnb_index}=${0}
    ...            ${connection}=GNB_OAM${gnb_index}
    ...            ${restore_path}=/home/ute/Compass_Report
    ${full_path}    create_kpi_report_directories    base_path=${restore_path}
    ...    subdirs=${TEST NAME}
    #based on release
    ${bts_name}    ${sw_version}    Wait Until Keyword Succeeds    3x    30s
    ...     Get BtsName and SwVersion    gnb_id=${gnb_index}    connection=${connection}
    ${release_info}    Set Variable     ${sw_version.split('_')[0].split('BTS')[1]}
    Run Keyword And Continue On Failure    create_and_append_all_results_to_excel
    ...    single_file_path=${append_kpi_report_path}
    ...    all_file_path=${full_path}/KPI_Reports_ALL.xlsx
    create_and_append_all_results_to_excel
    ...    single_file_path=${append_kpi_report_path}
    ...    all_file_path=${full_path}/KPI_Reports_${release_info}.xlsx
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Compass.Upload Result To Remote Server
    [Arguments]    ${restore_path}=/home/ute/Compass_Report
    ...            ${server_path}=/home/hz4sg6/shared/01_E2E_Rep/${tl_prefix}/${TEST NAME}/
    ${local_file_path}    Set Variable    ${restore_path}/${TEST NAME}/
    ${remote_path}    Set Variable    ${server_path}
    Run Keyword And Ignore Error    copy_local_to_remote
    ...    local_path=${local_file_path}
    ...    remote_path=${remote_path}
    ...    hostname=${samba_server_ip}
    ...    username=${samba_server_username}
    ...    password=${samba_server_password}

Compass.KPI Generate And Upload To Remote Server
    [Arguments]    ${report_timestamps_list}    ${report_parsed_duration}=${None}
    ...    ${restore_path}=/home/ute/Compass_Report    ${test_comments}=${EMPTY}
    [Documentation]    Auther:stella.lin
    ...    ${report_timestamps_list}:[['2026-01-30 03:10:44', '2026-01-30 07:40:44'],['2026-01-30 08:10:44', '2026-01-30 11:40:44']]
    ...    ${test_comments}:test description
    ...    ${report_parsed_duration}:is not ${None},timestamp will parsed as duration ${report_parsed_duration}sec.
    ${new_report_timestamps_list}    Run Keyword If    '${report_parsed_duration}'!='${None}'
    ...    split_intervals    intervals=${report_timestamps_list}
    ${input_report_timestamps_list}    Set Variable If    '${report_parsed_duration}'!='${None}'    ${new_report_timestamps_list}
    ...    ${report_timestamps_list}
    log to console  input timestamp is:${input_report_timestamps_list}
    ${current_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${last_end_time}    Set Variable    ${report_timestamps_list[-1][1]}
    ${diff_time}    Subtract Date From Date    ${current_time}    ${last_end_time}
    ${duration}    Evaluate   1860-${diff_time}
    ${sleep_time}   Set Variable If   ${diff_time}>=1800    10      ${duration}
    log to console   prepare to generate scout report,SLEEP:${sleep_time}sec
    Sleep    ${sleep_time}sec
    log to console   start to generate compass kpi report
    ${combine_report_id_all}    Create List
    FOR    ${time_stamp}    IN    @{input_report_timestamps_list}
        ${status}    ${report_info}    Run Keyword And Ignore Error
        ...    Compass.Generate KPI Report    timestamp_list=${time_stamp}    test_comments=${test_comments}
        ...    restore_path=${restore_path}
        Run Keyword If    '${status}'=='PASS'    Append To List     ${combine_report_id_all}     ${report_info[0]}
    END
    Log To Console   all report ids：${combine_report_id_all}
    log to console   start to combine and compare kpi report
    ${formatted_report_ids}    Evaluate    ','.join(${combine_report_id_all})
    ${output_file}    Run Keyword And Continue On Failure    Compass.Save Compare KPI Report
    ...    report_ids=${formatted_report_ids}
    ...    restore_path=${restore_path}
    ...    test_comments=${test_comments}
    log to console   compare report is:${output_file}
    log to console   start to append kpi report
    Run Keyword And Ignore Error    Compass.Append Result To Excel    append_kpi_report_path=${output_file}
    ...    restore_path=${restore_path}
    log to console   start to upload to remote server
    Run Keyword And Ignore Error     Compass.Upload Result To Remote Server    restore_path=${restore_path}
    [Return]    ${output_file}

Compass.Single KPI Generate And Upload To Remote Server
    [Arguments]    ${report_timestamps_list}    ${test_comments}=7UE_DL_SFTP    ${report_parsed_duration}=${None}
    ...    ${restore_path}=/home/ute/Compass_Report    ${test_comments}=${EMPTY}
    [Documentation]    Auther:stella.lin
    ...    ${report_timestamps_list}:[['2026-01-30 03:10:44', '2026-01-30 07:40:44'],['2026-01-30 08:10:44', '2026-01-30 11:40:44']]
    ...    ${test_comments}:test description
    ...    ${report_parsed_duration}:is not ${None},timestamp will parsed as duration ${report_parsed_duration}sec.
    ${new_report_timestamps_list}    Run Keyword If    '${report_parsed_duration}'!='${None}'
    ...    split_intervals    intervals=${report_timestamps_list}
    ${input_report_timestamps_list}    Set Variable If    '${report_parsed_duration}'!='${None}'    ${new_report_timestamps_list}
    ...    ${report_timestamps_list}
    log to console  input timestamp is:${input_report_timestamps_list}
    ${current_time}    robot.libraries.DateTime.Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${last_end_time}    Set Variable    ${report_timestamps_list[-1][1]}
    ${diff_time}    Subtract Date From Date    ${current_time}    ${last_end_time}
    ${duration}    Evaluate   1860-${diff_time}
    ${sleep_time}   Set Variable If   ${diff_time}>=1800    10      ${duration}
    log to console   prepare to generate scout report,SLEEP:${sleep_time}sec
    Sleep    ${sleep_time}sec
    log to console   start to generate compass kpi report
    ${combine_report_id_all}    Create List
    ${kpi_report_list}    Create List
    FOR    ${time_stamp}    IN    @{input_report_timestamps_list}
        ${status}    ${report_info}    Run Keyword And Ignore Error
        ...    Compass.Generate KPI Report    timestamp_list=${time_stamp}    test_comments=${test_comments}
        ...    restore_path=${restore_path}       download_report=${True}
        Run Keyword If    '${status}'=='PASS'    Append To List     ${kpi_report_list}     ${report_info[1]}
        Run Keyword If    '${status}'=='PASS'    Append To List     ${combine_report_id_all}     ${report_info[0]}
    END
    Log To Console   all report ids：${combine_report_id_all}
    Log To Console   all report is：${kpi_report_list}
    FOR    ${report}    IN   @{kpi_report_list}
        Run Keyword And Ignore Error    Compass.Append Result To Excel    append_kpi_report_path=${report}
        ...    restore_path=${restore_path}
    END
    log to console   start to upload to remote server
    Run Keyword And Ignore Error     Compass.Upload Result To Remote Server    restore_path=${restore_path}
    [Return]    ${kpi_report_list[0]}



