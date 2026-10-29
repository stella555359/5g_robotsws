*** Settings ***
Documentation    Author: ming.shi@nokia-sbell.com
Library    OperatingSystem
Library     taf.hw.rf_attenuator    WITH NAME    att
Library    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/TDD_FDD_SFE_Regression/SISO_Resource/ping_pang_common.py
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/SFE_TMO_HO_common_keywords.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/KPI/generate_padding_analysis_kpi.robot

*** Variables ***
${excel_kpi_path}    /opt/workspace/SCF/Excel_KPI/
${scf_file_path}    /opt/workspace/CRT/Master/SCF_file/
${test_info_path}    /opt/workspace/SCF/
${test_info_file}    ping_pang_test_info.yml
${gnb_instance}     ${tl.gnbs[0].instance_id}
${enb_instance}     ${tl.enbs[0].instance_id}
${path}    /opt/workspace/SCF/
${kpi_template_path}    /opt/workspace/SCF/SA_kpi_report.yml
${report_name_pingpang}    ping_pang_cases
${case_logs_path}    /opt/workspace/CRT/Master/Case_Logs/
${attach_file_name}    all_ue_attach.py
${detach_file_name}    all_ue_detach.py
${att_ipaddr}      ${tl.attenuator[0].ip_addr}
${att_ipaddr_1}    ${tl.attenuator[1].ip_addr}
${att_connection_port}       ${tl.attenuator[0].attenuator_ports[5]}
${att_api_port}              ${tl.attenuator[0].port}
${vendor}                    ${tl.attenuator[0].vendor}
${model}                     ${tl.attenuator[0].model}
${max_attenuation_value}     ${127}

*** Keywords ***
SCF commission
    FOR    ${index}    ${value}    IN ENUMERATE    @{is_commission_index_info}
        IF    ${value}[${index}] == ${True}
            multi bts scf files commission    gnb_index=${index}
        END
    END

snapshot collected
    FOR    ${index}    ${value}    IN ENUMERATE    @{is_snapshot_collected_index_info}
        IF    ${value}[${index}] == ${True}
            get gnb snapshot    gnb_index=${index}
        END
    END

Get gnb sw version
    [Arguments]   ${gnb_index}    ${connection}=release_info_${gnb_index}
    csn.Connect To
    ...    hostname=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...    username=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[0].lmp_connection.password}
    ...    alias=${connection}
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=${connection}
    ${sw_version}     set variable    ${info.split('_')[1]}
    set suite variable    ${sw_version}
    [Return]    ${sw_version}
    [Teardown]   csn.Disconnect   connection=${connection}

multi bts scf files commission
    [Arguments]    ${gnb_index}    ${connection}=GNB_OAM_${gnb_index}    ${timeout_for_commission}=900
    ...    ${is_pdl_checking_needed}=${True}    ${wait_gnb_up_timeout}=20 min    ${gnb_type}='SA'
    ...    ${is_x2_check_from_gnb_needed}=${False}
    Get gnb sw version    gnb_index=${gnb_index}
    ${gnb_id}=    Evaluate    ${gnb_index} + ${1}
    Set Suite Variable    ${tl_gnb${gnb_id}_scf_${sw_version}}    ${sw_version}_gNB${gnb_id}_Golden_SCF.xml
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    COAM Commission with scf file    scf_file_path=${scf_files_path}/${tl_gnb${gnb_id}_scf_${sw_version}}
    ...                              connection=${connection}
    ...                              timeout=${timeout_for_commission}
    ...                              is_pdl_checking_needed=${is_pdl_checking_needed}
    COAM Wait For Gnb Ready And Cell Setup     timeout=${wait_gnb_up_timeout}
    ...                                        connection=${connection}
    ...                                        gnb_type=${gnb_type}
    ...                                        gnb_index=${gnb_index}
    ...                                        is_x2_check_from_gnb_needed=${is_x2_check_from_gnb_needed}
    [Teardown]    COAM Teardown gnb connections    connection=${connection}

get_test_info
    ${test_info}=    get_info_from_file    file_path=${test_info_path}${test_info_file}
    Set Suite Variable    ${test_info}
    Set Suite Variable    ${allowed_faults_ids}    ${test_info}[allowed_faults_ids]
    Set Suite Variable    ${pc_ip}    ${test_info}[pc_ip]
    Set Suite Variable    ${pc_user}    ${test_info}[pc_user]
    Set Suite Variable    ${pc_pwd}    ${test_info}[pc_pwd]
    Set Suite Variable    ${is_commission_index_info}    ${test_info}[is_commission_index_info]
    Set Suite Variable    ${is_snapshot_collected_index_info}    ${test_info}[is_snapshot_collected_index_info]
    Set Suite Variable    ${scf_files_path}    ${test_info}[scf_files_path]
#    Set Suite Variable    ${ue_index_list}    ${test_info}[ue_index_list]
    Set Suite Variable    ${ues_actions}    ${test_info}[ues_actions]
    Set Suite Variable    ${all_ant_atts}    ${test_info}[all_ant_atts]
    ${tl_id}=    Evaluate    str(${tl.gnbs[0].instance_id})[0:3]
    Set Suite Variable    ${tl_id}

Suite prepare
    get_test_info
    SCF commission
    ${start_time}=    record_time    label=start
    Log To Console    ${SUITE NAME} start_time: ${start_time}
    Set Suite Variable    ${suite_start_time}    ${start_time}


Suite end
#    get kpi file
    snapshot collected

Test Start trace faults and capture syslog
    ${allowed_faults_ids_string}=    Evaluate    ','.join(${allowed_faults_ids})
    robot_common_operations.Common Case Setup    allowed_faults_ids=${allowed_faults_ids_string}
    FOR    ${fault_id}    IN    @{allowed_faults_ids}
        AlarmWatchdog.add_allow_alarms    fault_id=${fault_id}
    END
    Log    Start Test Case ${TEST NAME}
    Log To Console    Start Test Case ${TEST NAME}
    ${name}=    Evaluate    '${TEST NAME}'.replace(" ", "_")
    Set Test Variable    ${name}
    Set Test Variable    ${case_test_info}    ${test_info}[${name}]
    Set Test Variable    ${case_test_round}    ${test_info}[${name}_round]
    IF    ${case_test_info}[is_capture_syslog] == True
        Start capture syslog via btslog on ute
    END
    FOR    ${att}    IN    @{all_ant_atts}
        ${recovery_values}=    Evaluate    [${att}[max_value]] * len(${att}[ports])
        ping_pang_common_keywords.Set the attenuation value of ports simultaneously
        ...    att_ports=${att}[ports]
        ...    values=${recovery_values}
        ...    att_ipaddr=${att}[ip]
    END
    ${tl_id}=    Evaluate    str(${tl.gnbs[0].instance_id})[0:3]
    Set Test Variable    ${tl_id}
    IF    ${case_test_info}[required_locked_LTE_cells][0] != None
        Online modify parmeters    parameters_to_update=${case_test_info}[required_locked_LTE_cells]    skip_parameter_relation_errors=False
    END
    IF    ${case_test_info}[required_locked_NR_cells][0] != None
        Online modify parmeters    parameters_to_update=${case_test_info}[required_locked_NR_cells]    skip_parameter_relation_errors=False
    END
    Prepare PM counter to caculate time    period=start
    ${start_time}=    record_time    label=start
    Log To Console    ${TEST NAME} start_time: ${start_time}
    Set Test Variable    ${start_time}

Test End trace faults and stop capture syslog
    Log    End Test Case ${TEST NAME}
    Log To Console    End Test Case ${TEST NAME}
    Prepare PM counter to caculate time    period=end
    ${end_time}=    record_time    label=end
    Log To Console    ${TEST NAME} end_time: ${end_time}
    Set Test Variable    ${end_time}
    get kpi file
    IF    '${TEST STATUS}' == 'FAIL'
        ${name}=    Evaluate    '${TEST NAME}'.replace(" ", "_")
        Set Test Variable    ${name}
        Set Test Variable    ${case_test_info}    ${test_info}[${name}]
        Set Test Variable    ${case_test_round}    ${test_info}[${name}_round]
        ${tl_id}=    Evaluate    str(${tl.gnbs[0].instance_id})[0:3]
        Set Test Variable    ${tl_id}
        get gnb snapshot    gnb_index=${0}
        ${is_contain_in_test_name}=    Run Keyword And Return Status    Should Contain    ${TEST NAME}    inter gnb
        IF    ${is_contain_in_test_name} == ${True}
            get gnb snapshot    gnb_index=${1}
        END
    END
#    Sleep    10s
    IF    ${case_test_info}[VoNR] == True
        hang_up_vonr_calls    ue_index_list=${case_test_info}[make_vonr][ue_index_list]
        Wait Until Keyword Succeeds    10x    2s    check_voice_calls   ue_index_list=${case_test_info}[make_vonr][ue_index_list]    state_code=${0}
    END
    IF    ${case_test_info}[EMC] == True
        hang_up_emc_calls    ue_index_list=${case_test_info}[make_emc][ue_index_list]
        Wait Until Keyword Succeeds    10x    2s    check_voice_calls   ue_index_list=${case_test_info}[make_emc][ue_index_list]    state_code=${0}
    END
    stop_traffic_with_multi_ues    yml_file_path=${path}${test_info_file}    case_name=${name}
    UEs operate via py file
    ...    tl_id=${tl_id}    path=${path}    py_file_name=${detach_file_name}    yml_file_name=${test_info_file}
    IF    ${case_test_info}[required_unlocked_LTE_cells][0] != None
        Online modify parmeters    parameters_to_update=${case_test_info}[required_unlocked_LTE_cells]    skip_parameter_relation_errors=False
    END
    IF    ${case_test_info}[required_unlocked_NR_cells][0] != None
        Online modify parmeters    parameters_to_update=${case_test_info}[required_unlocked_NR_cells]    skip_parameter_relation_errors=False
    END
    IF    ${case_test_info}[is_capture_syslog] == True
        Stop capture syslog via btslog on ute
        syslog analysis via regex file
    END
    robot_common_operations.Common Case Teardown
    FOR    ${fault_id}    IN    @{allowed_faults_ids}
        AlarmWatchdog.remove_allow_alarms    fault_id=${fault_id}
    END
    Run Keyword If Test Failed    CI_interface.Common Case Teardown

analyze syslog
    ${is_exist}=    Run Keyword And Return Status    Directory Should Exist    path=${case_logs_path}/${TEST NAME}
    IF    ${is_exist} == ${True}
        Remove Directory    path=${case_logs_path}/${TEST NAME}    recursive=${True}
    END
    Create Directory    path=${case_logs_path}/${TEST NAME}
    ${is_exist}=    Run Keyword And Return Status    File Should Exist    path=/home/ute/BTS_logs/SYSLOG.tgz
    IF    ${is_exist} == ${True}
        Copy File    /home/ute/BTS_logs/SYSLOG.tgz    ${case_logs_path}/${TEST NAME}/SYSLOG.tgz
        ${is_exist}=    Run Keyword And Return Status    File Should Exist    path=${case_logs_path}/${TEST NAME}/SYSLOG.tgz
        IF    ${is_exist} == ${True}
            Log    /home/ute/BTS_logs/SYSLOG.tgz copy to ${case_logs_path}/${TEST NAME}/SYSLOG.tgz success
        END
    END
    ${Rc}    ${output}=    Run And Return Rc And Output
    ...    command=tar zxvf "${case_logs_path}/${TEST NAME}/SYSLOG.tgz" -C ${case_logs_path}
    IF    ${Rc} == ${0}
        ${syslogs_name_list}=    Split String    string=${output}    separator=\n
        ${syslogs_name}=    Evaluate    ",".join(${syslogs_name_list})
    END
    ${tl_id}=    Evaluate    str(${gnb_instance})[0:3]
    ${Rc}    ${output}=    Run And Return Rc And Output
    ...    command=source CIENV/7_5_UTE5G402T${tl_id}/bin/activate;python /opt/workspace/SCF/check_err_wrn_on_syslogs.py ${syslogs_name} ${name}.LOG
    IF    ${Rc} == ${0}
        Log    check_err_wrn_on_syslogs.py execute success!!!
        Log To Console    check_err_wrn_on_syslogs.py execute success!!!
    END
    File Should Be Empty    path=/opt/workspace/SCF/${name}.LOG    msg=there are ERR prints on ${name}.LOG

syslog analysis via regex file
    [Arguments]    ${index}=${0}    ${ERR_WRN_file_name}=ERR_WRN_regex.yml
    ${is_exist}=    Run Keyword And Return Status    Directory Should Exist    path="${case_logs_path}/${TEST NAME}/${index}"
    IF    ${is_exist} == ${False}
        ${is_exist}=    Run Keyword And Return Status    Directory Should Exist    path="${case_logs_path}/${TEST NAME}"
        IF    ${is_exist} == ${False}
            Create Directory    path="${case_logs_path}/${TEST NAME}"
            Create Directory    path="${case_logs_path}/${TEST NAME}/${index}"
        ELSE IF    ${is_exist} == ${True}
            Create Directory    path="${case_logs_path}/${TEST NAME}/${index}"
        END
    ELSE IF    ${is_exist} == ${True}
#        Remove Files    "${case_logs_path}/${TEST NAME}/${index}/*"
        ${Rc}    ${output}=    Run And Return Rc And Output    cd "${case_logs_path}/${TEST NAME}/${index}/";rm -rf SYSLOG*
        IF    ${Rc} == ${0}
            Log    old syslogs are removed under path ${case_logs_path}/${TEST NAME}/${index}/
        END
    END
    ${is_exist}=    Run Keyword And Return Status    File Should Exist    path=/home/ute/BTS_logs/SYSLOG.tgz
    IF    ${is_exist} == ${True}
        Copy File    /home/ute/BTS_logs/SYSLOG.tgz    ${case_logs_path}/${TEST NAME}/${index}/SYSLOG.tgz
        ${is_exist}=    Run Keyword And Return Status    File Should Exist    path=${case_logs_path}/${TEST NAME}/${index}/SYSLOG.tgz
        IF    ${is_exist} == ${True}
            Log    /home/ute/BTS_logs/SYSLOG.tgz copy to ${case_logs_path}/${TEST NAME}/${index}/SYSLOG.tgz success
        END
    END
    ${Rc}    ${output}=    Run And Return Rc And Output
    ...    command=tar zxvf "${case_logs_path}/${TEST NAME}/${index}/SYSLOG.tgz" -C "${case_logs_path}${TEST NAME}/${index}"
    IF    ${Rc} == ${0}
        ${syslogs_name_list_initial}=    Split String    string=${output}    separator=\n
        ${syslogs_name_list}=    Evaluate    [sys_name.replace("./", "") for sys_name in ${syslogs_name_list_initial}]
        ${syslogs_path_name_list}    Evaluate    ['${case_logs_path}${TEST NAME}/${index}/' + syslog_name for syslog_name in ${syslogs_name_list}]
        run_main_syslog_analysis    syslog_files=${syslogs_path_name_list}    regex_file=${test_info_path}${ERR_WRN_file_name}
        ...    output_file=${test_info_path}${name}_${index}.LOG
    END
    ${ERR_analysis}=    check_syslog_analysis_file    output_file=${test_info_path}${name}_${index}.LOG
    ${err_status}=    Run Keyword And Return Status
    ...    Should Not Contain     ${ERR_analysis}    ERR/
    IF    '${err_status}' == 'True'
        Log    No ERR prints on ${name}_${index}.LOG
        Log To Console    No ERR prints on ${name}_${index}.LOG
    ELSE
        Log    ${ERR_analysis}
        Log To Console    ${ERR_analysis}
        ${complete_sw_version}=    Get completed release    bts_index=${0}
        ${tl_id}=    Evaluate    str(${gnb_instance})[0:3]
        ${subject}=    Catenate    7_5_UTE5G402T${tl_id}    there are ERR prints on ${name}_${index}.LOG    ${complete_sw_version}
        ${command}=    Catenate
        ...    source CIENV/7_5_UTE5G402T${tl_id}/bin/activate;python /opt/workspace/SCF/send_email_to_owner.py
        ...    '${subject}'
        ...    '${ERR_analysis}'
        ${Rc}    ${output}=    Run Keyword And Ignore Error    Run And Return Rc And Output    command=${command}
        Fail    msg=there are ERR prints on ${name}_${index}.LOG
    END
    [Teardown]    syslog analysis teardown    index=${index}

syslog analysis teardown
    [Arguments]    ${index}=${0}
    IF    '${KEYWORD STATUS}' == 'FAIL'
        get gnb snapshot    timeout=${900}
    ELSE
        ${Rc}    ${output}=    Run And Return Rc And Output    cd "${case_logs_path}/${TEST NAME}/${index}/";rm -rf SYSLOG*
    END


generate new report and get report id for kpi
    [Arguments]
    ...    ${file_path}
    ...    ${report_name}
    ...    ${tl_id}
    ...    ${package_version}
    ...    ${start_time}
    ...    ${end_time}
    ...    ${comments}=${EMPTY}
    ...    ${check_out_entry}=false
    ${report_id}    generate_new_report_on_compass
    ...    file_path=${file_path}
    ...    report_name=${report_name}
    ...    tl_id=${tl_id}
    ...    package_version=${package_version}
    ...    start_time=${start_time}
    ...    end_time=${end_time}
    ...    comments=${comments}
    ...    check_out_entry=${check_out_entry}
    [Return]    ${report_id}

generate kpi report and get report id
    [Arguments]
    ...    ${file_path}
    ...    ${report_name}
    ...    ${tl_id}
    ...    ${package_version}
    ...    ${start_time}
    ...    ${end_time}
#    ...    ${comments}=${EMPTY}
#    ...    ${check_out_entry}=false
    ${command}=    Catenate
    ...    source CIENV/7_5_UTE5G402T${tl_id}/bin/activate;python ${path}generate_kpi_report_on_compass.py
    ...    ${file_path}
    ...    '${report_name}'
    ...    ${tl_id}
    ...    ${package_version}
    ...    '${start_time}'
    ...    '${end_time}'
    ...    ${excel_kpi_path}
    ...    &
    Log To Console    ${command}
    ${rc}    ${output}=    Run And Return Rc And Output    ${command}
    IF    ${Rc} == ${0}
        Log To Console    ${path}generate_kpi_report_on_compass.py execute success!
    END

get kpi file
    ${end_time}=    record_time    label=end
    Log To Console    ${TEST NAME} end_time: ${end_time}
    Set Test Variable    ${end_time}
    ${package_version}=    Get bts package version for kpi
#    sleep    16min
#    ${rc}    ${output}=    Run And Return Rc And Output    mv ${excel_kpi_path}*.xlsx ${excel_kpi_path}bak
#    ${tl_id}=    Evaluate    str(${gnb_instance})[:3]
    ${time}=    Get Time    year month day hour min sec
    ${time_string}=    Evaluate    "_".join(${time})
    generate kpi to check and analysis    kpi_template_index=${0}    test_line_index=${0}    time_string=${time_string}


generate kpi to check and analysis
    [Arguments]    ${kpi_template_index}    ${test_line_index}    ${time_string}=${time_string}
    Run_Script_To_Generate_Padding_Analysis_KPI
    ...    template_name=${case_test_info}[template_name][${kpi_template_index}]
    ...    report_name=${case_test_info}[report_name]_${package_version}_${time_string}
    ...    ute_tl_id=${case_test_info}[ute_tl_id]
    ...    package_version=${package_version}
    ...    start_time=${start_time}
    ...    end_time=${end_time}
    ...    report_excel_file_path=${case_test_info}[excel_kpi_path]
    ...    origin_kpi_excel=${case_test_info}[origin_kpi_excel]
    ...    suite_timestamp=${suite_start_time}
    ...    sheet_name=${case_test_info}[sheet_name]
    ...    receiver_email=${case_test_info}[receiver_email]
    ...    sw_build_name_row=${case_test_info}[sw_build_name_row]
    ...    start_row_index=${case_test_info}[start_row_index]
    ...    start_row_sparkline_index=${case_test_info}[start_row_sparkline_index]
    ...    sparkline_col=${case_test_info}[sparkline_col]
    ...    kpi_value_col=${case_test_info}[kpi_value_col]
    ...    kpi_name_col=${case_test_info}[kpi_name_col]
    ...    kpi_rule_col=${case_test_info}[kpi_rule_col]
    ...    case_kpi_excel=${case_test_info}[excel_kpi_path]${case_test_info}[report_name]_${package_version}_${time_string}.xlsx
    ...    test_line=${case_test_info}[test_line][${test_line_index}]

Prepare PM counter to caculate time
    [Arguments]    ${period}=start
    ${utc0} =    Get Time    epoch
    ${utc} =    Evaluate    ${utc0}-${utc0}%300
    ${utc} =    set variable if    '${period}'=='start'     ${utc+300}    ${utc}
    set suite variable    ${${period}_date}    ${utc}
    ${left_timer} =    Evaluate    300-${utc0}%300
    sleep    ${left_timer}

UEs operate via py file
    [Arguments]    ${tl_id}    ${path}    ${py_file_name}    ${yml_file_name}
    ${Rc}=    Run And Return Rc    source CIENV/7_5_UTE5G402T${tl_id}/bin/activate;python ${path}${py_file_name} ${path}${yml_file_name} ${name}
    IF    ${Rc} == ${0}
        Log To Console    ${py_file_name} execute success!
    END

PA one cell 0 on and set other cell value 4 port for T348
    [Arguments]    ${cellid}    ${set_value}=${0}    ${total_cell}=${6}
    IF    '${cellid}' == '5' or '${cellid}' == '6'
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cellid}    value=${set_value}    ip_addr=${att_ipaddr_1}
    ELSE
        Change Attenuation value 4 port for multi PAs    cell=5Gcell${cellid}    value=${set_value}    ip_addr=${att_ipaddr}
    END
    FOR  ${index}  IN RANGE   ${total_cell}
        ${cellnum} =    evaluate    ${index}+1
        IF    ('${cellid}' != '${cellnum}') and ('${cellnum}' == '5' or '${cellnum}' == '6')
            Change Attenuation value 4 port for multi PAs    cell=5Gcell${cellnum}    value=${127}    ip_addr=${att_ipaddr_1}
        ELSE IF    ('${cellid}' != '${cellnum}') and ('${cellnum}' != '5' or '${cellnum}' != '6')
            Change Attenuation value 4 port for multi PAs    cell=5Gcell${cellnum}    value=${127}    ip_addr=${att_ipaddr}
        END
    END

Change Attenuation value 4 port for multi PAs
    [Arguments]    ${cell}    ${value}    ${ip_addr}=${att_ipaddr}
    Set Programmable Attenuation Value for multi PAs    ports=${${cell}_ANT1}    value=${value}    ip_addr=${ip_addr}
    Set Programmable Attenuation Value for multi PAs    ports=${${cell}_ANT2}    value=${value}    ip_addr=${ip_addr}
    Set Programmable Attenuation Value for multi PAs    ports=${${cell}_ANT3}    value=${value}    ip_addr=${ip_addr}
    Set Programmable Attenuation Value for multi PAs    ports=${${cell}_ANT4}    value=${value}    ip_addr=${ip_addr}

Set Programmable Attenuation Value for multi PAs
    [Arguments]    ${ports}    ${value}    ${ip_addr}=${att_ipaddr}
    att.setup_attenuator    ip_addr=${ip_addr}    port=${att_api_port}
    ...    attenuation_port_numbers=${ports}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ...    model=${model}
    att.set_attenuation     port=${ports}    value=${value}

Set the attenuation value of ports simultaneously by step
    [Arguments]    ${att_ports}    ${values}    ${step}    ${initial_values}
    ...    ${att_connection_port}=${att_connection_port}    ${att_ipaddr}=${att_ipaddr}
    ...    ${max_attenuation_value}=${127}    ${model}=${model}    ${att_api_port}=${att_api_port}    ${vendor}=${vendor}
    ...    ${pa_set_interval_time}=1s
    [Documentation]    ming.shi@nokia-sbell.com
    ...    This keyword is to set the test environment PA values, HBTE and topyoung.
    ...    ${att_ports}:List all the attenuator ports as int list (list[int])
    ...    ${values}:List the value of attenuator ports  int list  (list[Union[str,int,float]])
    ...    ${step}:Int value of adjust pa step
    ...    ${initial_value}:
    ...    ${att_connection_port}:if PA is HBTE, the port is any one port.
    ...                           if PA is topyoung, the port is a List all the attenuator ports as int list
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ...    model=${model}
    ${end_value}=    Evaluate    list(set(${values}))[0]
    ${initial_value}=    Evaluate    list(set(${initial_values}))[0]
    FOR    ${i}    IN RANGE    ${initial_value}    ${end_value} + ${step}    ${step}
#        ${new_values}=    Evaluate    [j + ${i} for j in ${initial_values}]
        ${new_values}=    Evaluate    [${i}] * len(${values})
        att.set_ports_attenuation    ports=${att_ports}    values=${new_values}
        Sleep    ${pa_set_interval_time}
    END
    FOR    ${o}    IN RANGE    ${end_value}    ${initial_value} - ${step}    -${step}
#        ${new_values}=    Evaluate    [k + ${o} for k in ${values}]
        ${new_values}=    Evaluate    [${o}] * len(${values})
        att.set_ports_attenuation    ports=${att_ports}    values=${new_values}
        Sleep    ${pa_set_interval_time}
    END
    ${ports_values}=    att.read_ports_attenuation    ports=${att_ports}
#    Lists Should Be Equal    list1=${values}    list2=${ports_values}    msg=Inconsistencies before and after modification

Set the attenuation value of ports simultaneously
    [Arguments]    ${att_ports}    ${values}    ${att_connection_port}=${att_connection_port}    ${att_ipaddr}=${att_ipaddr}
    ...    ${max_attenuation_value}=${127}    ${model}=${model}    ${att_api_port}=${att_api_port}    ${vendor}=${vendor}
    [Documentation]    ming.shi@nokia-sbell.com
    ...    This keyword is to set the test environment PA values, HBTE and topyoung.
    ...    ${att_ports}:List all the attenuator ports as int list (list[int])
    ...    ${value}:List the value of attenuator ports  int list  (list[Union[str,int,float]])
    ...    ${att_connection_port}:if PA is HBTE, the port is any one port.
    ...                           if PA is topyoung, the port is a List all the attenuator ports as int list
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ...    model=${model}
    att.set_ports_attenuation    ports=${att_ports}    values=${values}
    ${ports_values}=    att.read_ports_attenuation    ports=${att_ports}
    Lists Should Be Equal    list1=${values}    list2=${ports_values}    msg=Inconsistencies before and after modification

Start capture syslog via btslog on ute
    Start BTSlogs Collection In Log Server
    ...    Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...    Test_PC_password=${Test_PC_password}
    ...    btslog_path=/tmp/btslog2    btslog_launcher=/opt/btslog/btslog_launcher
    ...    btslog_launcher_path=/opt/btslog/btslog
    ...    Login_UTE=False

Stop capture syslog via btslog on ute
    Stop BTSlogs Collection And Download Logs To Log Server
    ...    UTE_syslogs_path=/home/ute/BTS_logs    btslog_path=/tmp/btslog2
    ...    btslog_launcher=/opt/btslog/btslog_launcher    btslog_launcher_path=/opt/btslog/btslog
    ...    Login_UTE=${False}

get gnb snapshot
    [Arguments]     ${gnb_index}=${0}    ${timeout}=${360}
    Connect to gnb coam via ssl    gnb_index=${gnb_index}
    COAM Save snapshot via rest api    log_path=${epc_log_path}    timeout=${timeout}
    [Teardown]    COAM Teardown gnb connections

Get bts package version for kpi
    [Arguments]
    ...    ${gnb_index}=${0}
    ...    ${host}=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[0].lmp_connection.password}
    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=version_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=version_info
    ${package_version}     set variable    ${info.split('_', 1)[1].split('.')[0]}
    Set Suite Variable    ${package_version}
    [Teardown]   csn.Disconnect   connection=version_info
    [Return]    ${package_version}

make traffic with different file
    [Arguments]    ${path}    ${file_name}    ${shell_file_name}
    Run And Return Rc And Output    command=source CIENV/7_5_UTE5G402T${tl_id}/bin/activate;python ${path}${file_name} ${shell_file_name}

stop traffic with different file
    [Arguments]    ${shell_file_name}
    Run And Return Rc And Output    command=ps -ef |grep ${shell_file_name} |awk '{print $2}'|xargs kill -9

check firmware upgrade ongoing fid 4420
    [Arguments]    ${gnb_index}=${0}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ${activate_alarms}=    coam.get_active_alarms    connection=${connection}
    ${faultIds}=    Create List
    FOR    ${alarm}    IN    @{activate_alarms}
        append to list    ${faultIds}    ${alarm}[faultId]
    END
    ${fid_4420_status}=    Run Keyword And Return Status    Should Contain    ${faultIds}    ${4420}
    Should be equal    ${fid_4420_status}    ${False}
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

ssh to right and operation interface
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}
    csn.connect to
    ...    hostname=${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...    username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    alias=Master
    ${connection}    csn.get_connection_by_alias    alias=Master
    ${channel}    Call Method    ${connection}    invoke_shell
    Sleep  2
    Call Method    ${channel}
    ...    send    ssh ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}@fct4s0icom.local\n
    Sleep  2
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    Sleep  2
    Call Method    ${channel}    send    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}\n
    Sleep  2
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    Sleep  2
    Call Method    ${channel}    send    tcpdump -i any -w /tmp/smod_dump.pcap\n
    Sleep  2
    [Teardown]   csn.disconnect    connection=Master

stop ssh to right and operation interface
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}
    csn.connect to
    ...    hostname=${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...    username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    alias=Master
    ${connection}    csn.get_connection_by_alias    alias=Master
    ${channel}    Call Method    ${connection}    invoke_shell
    Sleep  2
    Call Method    ${channel}
    ...    send    ssh ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}@fct4s0icom.local\n
    Sleep  2
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    Sleep  2
    Call Method    ${channel}    send    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}\n
    Sleep  2
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    Sleep  2
    Call Method    ${channel}    send    killall tcpdump\n
    Sleep  2
    Call Method    ${channel}    send    scp /tmp/smod_dump.pcap toor4nsn@fct0s0icom.local:/tmp\n
    Sleep  2
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    Sleep  2
    Call Method    ${channel}    send    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}\n
    Sleep  2
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    Sleep  2
    [Teardown]   csn.disconnect    connection=Master

download the Logs
    [Arguments]    ${index}    ${gNB_index}=${0}
    wait until keyword succeeds    1min   10s    Connect gNB    gNB_index=${gNB_index}
    csn.download_file   remote_path=/tmp/smod_dump.pcap   local_path=/tmp/smod_dump_${index}.pcap   connection=gNB${gNB_index}
    sleep    3
    [Teardown]    csn.disconnect    connection=gNB${gNB_index}

ssh to right and collect logs of ru
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}    ${ru_index}=${0}
    ...    ${ru_addr}=${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].default_ssh_connection_details.addr}
    ...    ${ru_username}=${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].default_ssh_connection_details.username}
    ...    ${ru_password}=${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}].default_ssh_connection_details.password}
    csn.connect to
    ...    hostname=${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...    username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    alias=Master
    ${connection}    csn.get_connection_by_alias    alias=Master
    ${channel}    Call Method    ${connection}    invoke_shell
    Sleep  2
    Call Method    ${channel}
    ...    send    ssh ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}@fct4s0icom.local\n
    Sleep  2
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    Sleep  2
    Call Method    ${channel}    send    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}\n
    Sleep  2
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    Call Method    ${channel}    send    lxc-attach -n 0x4018\n
    Sleep  2
    Call Method    ${channel}    send    ssh ${ru_username}@${ru_addr}\n
    Sleep  2
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    Call Method    ${channel}    send    ${ru_password}\n
    Sleep  2
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    Sleep  2
    Call Method    ${channel}    send    sudo /usr/sbin/nft list ruleset >> /tmp/firewall_Mars.txt\n
    Sleep  2
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    Sleep  2
    Call Method    ${channel}    send    ssh serviceuser@192.168.101.17\n
    Sleep  2
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    Sleep  2
    Call Method    ${channel}    send    sudo /usr/sbin/nft list ruleset >> /tmp/firewall_Thor.txt\n
    Sleep  2
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    Sleep  2
    Call Method    ${channel}    send    exit\n
    Sleep  2
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    Sleep  2
    Call Method    ${channel}    send    scp -r serviceuser@192.168.101.17:/tmp/firewall_Thor.txt /tmp/firewall_Thor.txt\n
    Sleep  2
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    Sleep  2
    Call Method    ${channel}    send    exit\n
    Sleep  2
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    Sleep  2
    Call Method    ${channel}    send    scp -r ${ru_username}@${ru_addr}:/tmp/firewall_Mars.txt firewall_Mars.txt\n
    Sleep  2
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    Sleep  2
    Call Method    ${channel}    send    ${ru_password}\n
    Sleep  2
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    Sleep  2
    Call Method    ${channel}    send    scp -r ${ru_username}@${ru_addr}:/tmp/firewall_Thor.txt firewall_Thor.txt\n
    Sleep  2
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    Sleep  2
    Call Method    ${channel}    send    ${ru_password}\n
    Sleep  2
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    Sleep  2
    Call Method    ${channel}    send    exit\n
    Sleep  2
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    Sleep  2
    Call Method    ${channel}    send    exit\n
    Sleep  2
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    Sleep  2
    Call Method    ${channel}    send    scp -r toor4nsn@fct4s0icom.local:/user/toor4nsn/firewall_Mars.txt /tmp/firewall_Mars.txt\n
    Sleep  2
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    Sleep  2
    Call Method    ${channel}    send    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}\n
    Sleep  2
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    Sleep  2
    Call Method    ${channel}    send    scp -r toor4nsn@fct4s0icom.local:/user/toor4nsn/firewall_Thor.txt /tmp/firewall_Thor.txt\n
    Sleep  2
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    Sleep  2
    Call Method    ${channel}    send    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}\n
    Sleep  2
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    Sleep  2
    [Teardown]   csn.disconnect    connection=Master

download the Logs of firewall
    [Arguments]    ${index}    ${status}=before    ${gNB_index}=${0}
    wait until keyword succeeds    1min   10s    Connect gNB    gNB_index=${gNB_index}
    csn.download_file   remote_path=/tmp/firewall_Mars.txt   local_path=/tmp/firewall_Mars_${status}_${index}.txt   connection=gNB${gNB_index}
    Sleep    3
    csn.download_file   remote_path=/tmp/firewall_Thor.txt   local_path=/tmp/firewall_Thor_${status}_${index}.txt   connection=gNB${gNB_index}
    sleep    3
    [Teardown]    csn.disconnect    connection=gNB${gNB_index}
