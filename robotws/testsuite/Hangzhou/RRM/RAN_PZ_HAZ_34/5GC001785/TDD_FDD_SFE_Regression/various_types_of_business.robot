*** Settings ***
Documentation     author: ming.shi
...                 contact: ming.shi@nokia.com
...                 squad group: SG_03
...                 feature : Various types of business

Suite Setup    Run Keywords
...            get_test_info_for_l3_call
...            AND    SCF commission
#Suite Teardown
Test Setup    Test Start trace faults and capture syslog
Test Teardown    Test End trace faults and stop capture syslog for l3 call

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/dingli_multiUE.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/TDD_FDD_SFE_Regression/SISO_Resource/ping_pang_common_keywords.robot

*** Variables ***
${l3_call_paras_file}    l3_call_paras_file.yml


*** Test Cases ***
L3_call_and_make_various_types_of_business
    [Tags]    L3_call_and_make_various_types_of_business
    L3_call_keyword


*** Keywords ***
L3_call_keyword
    Set Test Variable    ${source_cells}    ${case_test_info}[source_cell]
    FOR    ${cells}    IN    @{source_cells}
        Set the attenuation value of ports simultaneously
        ...    att_ports=${cells}[cell_ant_port]
        ...    values=${cells}[cell_ant_initial_value]
        ...    att_ipaddr=${cells}[att_ip_addr]
    END
    multi_ues_attach_and_verify
    UEs Start DL Data Transfer    ues_index=${dl_data_ues_index}    dl_tput_multiue=${multi_dl_tput}
    UEs Start UL Data Transfer    ues_index=${ul_data_ues_index}    ul_throughput=${multi_ul_tput}
    UEs Check Throughput
    ...    tput_target=${check_multi_dl_tput}    ues_index=${dl_data_ues_index}    direction=dl
    UEs Check Throughput
    ...    tput_target=${check_multi_ul_tput}    ues_index=${ul_data_ues_index}    direction=ul
    UEs Start Voice call    ues_index=${vonr_ues_index}
    FOR    ${t}    IN RANGE    ${case_test_round}
        Set the attenuation value of ports simultaneously by step
        ...    att_ports=${case_test_info}[target_cell][cell_ant_port]
        ...    values=${case_test_info}[target_cell][cell_ant_value]
        ...    att_ipaddr=${case_test_info}[target_cell][att_ip_addr]
        ...    step=${case_test_info}[target_cell][ho_step]
        ...    initial_values=${case_test_info}[target_cell][cell_ant_initial_value]
        ...    pa_set_interval_time=${case_test_info}[target_cell][pa_set_interval_time]
    END
    [Teardown]      Run Keywords
    ...    UEs Stop Voice call    ues_index=${vonr_ues_index}
    ...    AND    UEs Stop DL Data Transfer    ues_index=${dl_data_ues_index}
    ...    AND    UEs Stop UL Data Transfer    ues_index=${ul_data_ues_index}
    ...    AND    UEs Detach    ues_index=${attach_ues_index}
    ...    AND    client.stoplog      service=pioneer

get_test_info_for_l3_call
    ${test_info}=    ping_pang_common.get_info_from_file    file_path=${test_info_path}${l3_call_paras_file}
    Set Suite Variable    ${test_info}
    Set Suite Variable    ${allowed_faults_ids}    ${test_info}[allowed_faults_ids]
    Set Suite Variable    ${is_commission_index_info}    ${test_info}[is_commission_index_info]
    Set Suite Variable    ${all_ant_atts}    ${test_info}[all_ant_atts]
    Set Suite Variable    ${attach_ues_index}    ${test_info}[data_transfer][attach_ues_index]
    Set Suite Variable    ${dl_data_ues_index}    ${test_info}[data_transfer][dl_data_ues_index]
    Set Suite Variable    ${ul_data_ues_index}    ${test_info}[data_transfer][ul_data_ues_index]
    Set Suite Variable    ${multi_dl_tput}    ${test_info}[data_transfer][multi_dl_tput]
    Set Suite Variable    ${multi_ul_tput}    ${test_info}[data_transfer][multi_ul_tput]
    Set Suite Variable    ${check_multi_dl_tput}    ${test_info}[data_transfer][check_multi_dl_tput]
    Set Suite Variable    ${check_multi_ul_tput}    ${test_info}[data_transfer][check_multi_ul_tput]
    Set Suite Variable    ${vonr_ues_index}    ${test_info}[make_vonr][vonr_ues_index]
    Set Suite Variable    ${vonr_phone_num}    ${test_info}[make_vonr][vonr_phone_num]

Test End trace faults and stop capture syslog for l3 call
    Log    End Test Case ${TEST NAME}
    Log To Console    End Test Case ${TEST NAME}
    get gnb snapshot    gnb_index=${0}
    IF    '${TEST STATUS}' == 'FAIL'
        ${name}=    Evaluate    '${TEST NAME}'.replace(" ", "_")
        Set Test Variable    ${name}
        Set Test Variable    ${case_test_info}    ${test_info}[${name}]
        Set Test Variable    ${case_test_round}    ${test_info}[${name}_round]
        ${tl_id}=    Evaluate    str(${tl.gnbs[0].instance_id})[0:3]
        Set Test Variable    ${tl_id}
    END
    Prepare PM counter to caculate time    period=end
    ${end_time}=    record_time    label=end
    Log To Console    ${TEST NAME} end_time: ${end_time}
    Set Test Variable    ${end_time}
    generate and get kpi file
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

Get imei_list from ues_info
    [Arguments]    ${alias}=pioneer
    @{UEs_info}    client.prepare_ues    service=${alias}
    ${imei_list}    create list
    FOR    ${item}    IN    @{UEs_info}
      Append To List     ${imei_list}     ${item}[imei]
    END
    Set Test Variable    ${imei_list}

UE prepare
    [Arguments]
    ...    ${ue_index}=${0}
    ...    ${host}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${username}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    ${password}=${tl.ues[${ue_index}].ssh_connection_details.password}
    ...    ${alias}=pioneer
    ...    ${ue_alias}=multiUE
    ...    ${until_timeout}=${300}
    ...    ${port}=30999
    client.setup_service
    ...    host=${host}
    ...    port=${port}
    ...    ssh_username=${username}
    ...    ssh_password=${password}
    ...    alias=${alias}
    Run Keyword And Ignore Error    client.stoplog      service=${alias}
    Get imei_list from ues_info    alias=${alias}
    ${all_ue_num}=    get length    ${imei_list}
    ${uegroup}    create list
    # all available ues power off
    FOR    ${i}    IN RANGE     ${all_ue_num}
        client.require_ue    imei=${imei_list}[${i}]    service=${alias}    ue_alias=${ue_alias}${i}
        Append To List     ${uegroup}     ${ue_alias}${i}
    END
    Set Test Variable    ${uegroup}
    Run Keyword And Ignore Error    client.poweroff     ue=${uegroup}    until_timeout=${until_timeout}
    Sleep    5s
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Sleep    5s
    client.startlog    logpath=d:/pioneer_logs/${time_stamp}/    logname=ta_log    service=${alias}
    Sleep    1s

UEs Attach
    [Arguments]    ${ues_index}    ${until_timeout}=${300}    ${apn}=wustatic
    FOR    ${i}    IN     @{ues_index}
        client.poweron     ue=${uegroup}[${i}]    until_timeout=${until_timeout}
        Run keyword and Ignore Error     client.sendat    command=${mPDU_atcommand}    until_timeout=${until_timeout}    ue=${uegroup}[${i}]
        ${upd_info}    Run keyword and continue on failure    client.getpduinfo    until_timeout=${until_timeout}
        ...                                                                        apn=${apn}     ue=${uegroup}[${i}]
        should be true    ${upd_info}[Param][State]==0
        Set Test Variable    ${${uegroup}[${i}]_IP}    ${upd_info}[Param][IP]
    END

UEs Start DL Data Transfer
    [Arguments]    ${ues_index}    ${dl_tput_multiue}=${dl_tput_multiue}    ${DL_PORT}=${DL_PORT}    ${process_num}=${1}
    FOR    ${i}    IN    @{ues_index}
        Start MUE dltraffic with appserver    ue_addr=${${uegroup}[${i}]_IP}     dl_port=${DL_PORT}    dl_throughput=${dl_tput_multiue}[${i}]
        ...    process_num=${process_num}
        ${DL_PORT}    Evaluate    ${DL_PORT} + 100
    END

UEs Start UL Data Transfer
    [Arguments]    ${ues_index}=${${0},${1},${2},${3}}
    ...            ${ul_protocol}=UDP
    ...            ${ul_throughput}=2500000
    ...            ${ul_buffersize}=1024
    ...            ${packetsize}=1400
    ...            ${ue_index_in_tl}=${1}
    ...            ${appserver_addr}=${tl.ues[${ue_index_in_tl}].iperf_details.ssh_connection_details.addr}
    Log To Console    ${\n}INFO:-- start to UL call --
    FOR    ${index}    IN    @{ues_index}
        Log To Console    ${\n}INFO:-- start to UL call for ${uegroup}[${index}]--
        ${ul_port}    Evaluate    ${tl.ues[${index}].iperf_details.ssh_connection_details.port} + (${index} * 30)
        Run Keyword And Continue On Failure    client.startultraffic
        ...    protocol=${ul_protocol}
        ...    address=${appserver_addr}
        ...    port=${ul_port}
        ...    testtime=9999
        ...    bandwidth=${ul_throughput}[${index}]
        ...    buffersize=${ul_buffersize}
        ...    packetsize=${packetsize}
        ...    until_timeout=${300}
        ...    ue=${uegroup}[${index}]
        Sleep   15sec
    END

UEs Check Throughput
    [Arguments]    ${tput_target}    ${ues_index}=${${0},${1},${2},${3}}   ${direction}=ul
    Log To Console    ${\n}INFO:-- start to check ${direction} tput --
    FOR    ${index}    IN    @{ues_index}
        ${tput_dic}    Run Keyword And Continue On Failure    client.getparammac    ue=${uegroup}[${index}]
        ${tput_output}    run keyword if    '${direction}'=='ul'    Evaluate    ${tput_dic['Param']['MACUL']} / 1000 / 1000
        ...               ELSE IF    '${direction}'=='dl'    Evaluate    ${tput_dic['Param']['MACDL']} / 1000 / 1000
        Run Keyword And Continue On Failure    should be true    ${tput_output} > ${tput_target}[${index}]
    END

UEs Stop DL Data Transfer
    [Arguments]    ${ues_index}    ${appserver}=APPserver    ${DL_PORT}=${DL_PORT}
    FOR    ${i}    IN    @{ues_index}
        Close the iperf process on APPserver    port=${DL_PORT}    appserver=${appserver}
        ${DL_PORT}    Evaluate    ${DL_PORT} + 100
    END

UEs Stop UL Data Transfer
    [Arguments]    ${ues_index}=${${0},${1},${2},${3}}
    Log To Console    ${\n}INFO:-- start to stop call --
    FOR    ${index}    IN    @{ues_index}
        Run Keyword And Continue On Failure    client.stopultraffic    until_timeout=${300}    ue=${uegroup}[${index}]
        Sleep   5sec
    END

UEs Start Voice call
    [Arguments]    ${ues_index}=${${0},${1},${2},${3}}
    Log To Console    ${\n}INFO:-- start to voice call --
    FOR    ${index}    IN    @{ues_index}
        Run Keyword And Continue On Failure
        ...    start dingli_UE Voice_Call
        ...    until_timeout=${300}
        ...    ue=${uegroup}[${index}]
        ...    call_number=${vonr_phone_num}[${index}]
        Sleep   5sec
    END

UEs Stop Voice call
    [Arguments]    ${ues_index}=${${0},${1},${2},${3}}
    Log To Console    ${\n}INFO:-- stop to voice call --
    FOR    ${index}    IN    @{ues_index}
        Run Keyword And Continue On Failure
        ...    stop dingli_UE Voice_Call
        ...    until_timeout=${300}
        ...    ue=${uegroup}[${index}]
        Sleep   5sec
    END

UEs Detach
    [Arguments]    ${ues_index}    ${until_timeout}=${300}
    FOR    ${i}    IN    @{ues_index}
        client.poweroff     ue=${uegroup}[${i}]    until_timeout=${until_timeout}
    END

UEs Send AT Commnads
    [Arguments]    ${ues_index}    ${until_timeout}=${300}    ${AT_commonds_type}=SA_mode
    FOR    ${i}    IN    @{ues_index}
        IF    '${AT_commonds_type}' == 'SA_mode'
            Log To Console    ${AT_commonds_type} commands are executed!
            client.sendat    command=AT+GTSET="5GSACTR",1    until_timeout=${until_timeout}    ue=${uegroup}[${i}]
            client.sendat    command=AT+GTACT=14    until_timeout=${until_timeout}    ue=${uegroup}[${i}]
        END
    END

multi_ues_attach_and_verify
    #####pioneer part#####
    UE prepare
    UEs Send AT Commnads    ues_index=${attach_ues_index}
    UEs Attach    ues_index=${attach_ues_index}
    #####pioneer part#####




########################################
Set Multi UE to SA mode
    FOR    ${ue}    IN    @{uegroup}
        client.sendat    command=AT+GTSET="5GSACTR",1    until_timeout=${300}    ue=${ue}
        client.sendat    command=AT+GTACT=14    until_timeout=${300}    ue=${ue}
    END

Start multiUEs traffic with appserver for diff throughput
    [Arguments]    ${dl_tput_multiue}=${dl_tput_multiue}    ${DL_PORT}=${DL_PORT}    ${UE_define}=NULL    ${process_num}=${1}
    ${ue_len}    get length     ${uegroup}
    ${ue_num}    set variable if    '${UE_define}' == 'NULL'   ${ue_len}    ${UE_define}
    FOR    ${i}    IN RANGE     0    ${ue_num}
        Start MUE dltraffic with appserver    ue_addr=${${uegroup}[${i}]_IP}     dl_port=${DL_PORT}    dl_throughput=${dl_tput_multiue}[${i}]
        ...    process_num=${process_num}
        ${DL_PORT}    Evaluate    ${DL_PORT} + 100
    END

Start UL Data Transfer with pioneer client for diff throughput
    [Arguments]    ${ues_index}=${${0},${1},${2},${3}}
    ...            ${ul_protocol}=UDP
    ...            ${ul_throughput}=2500000
    ...            ${ul_buffersize}=1024
    ...            ${packetsize}=1400
    ...            ${ue_index_in_tl}=${1}
    ...            ${refine_ue_port}=${None}
    ...            ${appserver_addr}=${tl.ues[${ue_index_in_tl}].iperf_details.ssh_connection_details.addr}
    Log To Console    ${\n}INFO:-- start to UL call --
    ${ues_index_type}    Evaluate    type(${ues_index}).__name__
    ${convert_ues_index_to_list}    Create List    ${ues_index}
    ${ues_index}    Set Variable If    'list' in '${ues_index_type}' or 'tuple' in '${ues_index_type}'
    ...      ${ues_index}     ${convert_ues_index_to_list}
    ${ue_port}    Set Variable If    '${refine_ue_port}'=='None'    ${tl.ues[${ue_index_in_tl}].iperf_details.port}    ${refine_ue_port}
    FOR    ${index}    IN    @{ues_index}
        Log To Console    ${\n}INFO:-- start to UL call for ${uegroup}[${index}]--
        Run Keyword And Continue On Failure    client.startultraffic
        ...    protocol=${ul_protocol}
        ...    address=${appserver_addr}
        ...    port=${ue_port}
        ...    testtime=9999
        ...    bandwidth=${ul_throughput}[${index}]
        ...    buffersize=${ul_buffersize}
        ...    packetsize=${packetsize}
        ...    until_timeout=${300}
        ...    ue=${uegroup}[${index}]
        ${ue_port}    Evaluate    ${ue_port}+1
        Sleep   15sec
    END

Check traffic with pioneer client with pioneer client for diff throughput
    [Arguments]    ${tput_target}    ${ues_index}=${${0},${1},${2},${3}}   ${direction}=ul
    Log To Console    ${\n}INFO:-- start to check ${direction} tput --
    ${ues_index_type}    Evaluate    type(${ues_index}).__name__
    ${convert_ues_index_to_list}    Create List    ${ues_index}
    ${ues_index}    Set Variable If    'list' in '${ues_index_type}' or 'tuple' in '${ues_index_type}'
    ...      ${ues_index}     ${convert_ues_index_to_list}
    FOR    ${index}    IN    @{ues_index}
        ${tput_dic}    Run Keyword And Continue On Failure    client.getparammac    ue=${uegroup}[${index}]
        ${tput_output}    run keyword if    '${direction}'=='ul'    Evaluate    ${tput_dic['Param']['MACUL']} / 1000 / 1000
        ...               ELSE IF    '${direction}'=='dl'    Evaluate    ${tput_dic['Param']['MACDL']} / 1000 / 1000
        Run Keyword And Continue On Failure    should be true    ${tput_output} > ${tput_target}[${index}]
    END

multi_ues_stop_traffic
    Stop multiues traffic with appserver
    Stop UL Data Transfer with pioneer client    ues_index=${used_ues_index}

Detach MultiUEs with client
    [Arguments]    ${until_timeout}=${300}
    ${ue_num}      get length    ${uegroup}
    FOR    ${i}    IN RANGE     0    ${ue_num}
        client.poweroff     ue=${uegroup}[${i}]    until_timeout=${until_timeout}
    END
########################################





Common teardown for L3 call case
#    Run Keyword If    '${TEST STATUS}' == 'FAIL'    collect and get snapshot
    collect and get snapshot
    robot_common_operations.Common Case Teardown
    FOR    ${fault_id}    IN    @{allowed_faults_ids}
        AlarmWatchdog.remove_allow_alarms    fault_id=${fault_id}
    END
    Run Keyword If Test Failed    CI_interface.Common Case Teardown

collect and get snapshot
    [Arguments]    ${gnb_index}=${0}    ${connection_name}=GNB_OAM
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    Save snapshot with BTS    connection=${connection_name}
    [Teardown]    Disconnect With BTS    connection=${connection_name}

PA set required cell to needed value and set other cells to max value
    [Arguments]    ${index}    ${values}
    FOR    ${i}    ${pa_info}    IN ENUMERATE    @{RU_PA_info}
        IF    ${i} != ${index}
            ${max_values}=    Evaluate    [${127}] * len(${pa_info}[ports])
            Set the attenuation value of ports simultaneously
            ...    att_ports=${pa_info}[ports]
            ...    values=${max_values}
            ...    att_ipaddr=${pa_info}[att_ipaddr]
        ELSE
            Set the attenuation value of ports simultaneously
            ...    att_ports=${pa_info}[ports]
            ...    values=${values}
            ...    att_ipaddr=${pa_info}[att_ipaddr]
        END
    END

generate and get kpi file
    ${end_time}=    record_time    label=end
    Log To Console    ${TEST NAME} end_time: ${end_time}
    Set Test Variable    ${end_time}
    ${package_version}=    Get bts package version for kpi
    sleep    16min
    ${rc}    ${output}=    Run And Return Rc And Output    mv ${excel_kpi_path}*.xlsx ${excel_kpi_path}bak
    ${tl_id}=    Evaluate    str(${gnb_instance})[:3]
    ${time}=    Get Time    year month day hour min sec
    ${time_string}=    Evaluate    "_".join(${time})
#    generate kpi report and get report id    file_path=${kpi_template_path}    report_name=${name}_${package_version}_${time_string}
#    ...    tl_id=${tl_id}     package_version=${package_version}    start_time=${start_time}    end_time=${end_time}
    ${report_id}=    generate new report and get report id for kpi    file_path=${kpi_template_path}
    ...    report_name=${name}_${package_version}_${time_string}
    ...    tl_id=${tl_id}     package_version=${package_version}    start_time=${start_time}    end_time=${end_time}
    IF    '${report_id}' != 'None'
        download_kpi_file    report_id=${report_id}    path=${excel_kpi_path}
    END
