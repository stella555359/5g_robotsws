*** Settings ***
Documentation     author: Ming Shi
...                 contact: ming.shi@nokia.com
...                 feature : CB008148-SR

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/dingli_multiUE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008148/Resources/CB008148_Variables.py
Library      testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/TDD_FDD_SFE_Regression/SISO_Resource/ping_pang_common.py

*** Variables ***
@{gnb_list}    ${0}
${test_yml_path}    /opt/workspace/SCF/
${case_logs_path}    /opt/workspace/CRT/Master/Case_Logs/

*** Keywords ***
Common Suite Setup For CB008148
    Common Suite Setup for COAM
    Get sagnb version for selenium
    Set Suite Variable    ${tl_gnb1_scf_${sw_version}}    ${sw_version}_gNB1_Golden_SCF.xml
    Common Case TestLine Setup    is_commission=${True}    scf_path=${tl_scf_dir_path}    golden_scf_name=${tl_gnb1_scf_${sw_version}}

Common Suite Teardown For CB008148
    Common Suite Teardown for COAM    gnb_list=${gnb_list}

Common Test Setup for CB008148 without AP
    robot_common_operations.Common Case Setup    allowed_faults_ids=4291
    Start capture syslog via btslog on ute

Common Test Teardown for CB014044 without AP
    robot_common_operations.Common Case Teardown
    AlarmWatchdog.remove_allow_alarms    fault_id=4291
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

get gnb snapshot
    [Arguments]     ${gnb_index}=${0}
    Connect to gnb coam via ssl    gnb_index=${gnb_index}
    COAM Save snapshot via rest api    log_path=${epc_log_path}
    [Teardown]    COAM Teardown gnb connections

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

syslog analysis via regex file
    [Arguments]    ${index}=${0}    ${ERR_WRN_file_name}=ERR_WRN_regex.yml
    ${name}=    Evaluate    '${TEST NAME}'.replace(" ", "_")
    Set Test Variable    ${name}
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
        run_main_syslog_analysis    syslog_files=${syslogs_path_name_list}    regex_file=${test_yml_path}${ERR_WRN_file_name}
        ...    output_file=${test_yml_path}${name}_${index}.LOG
    END
    ${ERR_analysis}=    check_syslog_analysis_file    output_file=${test_yml_path}${name}_${index}.LOG
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
        get gnb snapshot
    ELSE
        ${Rc}    ${output}=    Run And Return Rc And Output    cd "${case_logs_path}/${TEST NAME}/${index}/";rm -rf SYSLOG*
    END




################################## UE part ###############################################
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

multi_ues_attach_and_verify
    [Arguments]    ${ues_index}=${${0},${1},${2},${3}}
    #####pioneer part#####
    UE prepare
    UEs Send AT Commnads    ues_index=${ues_index}
    UEs Attach    ues_index=${ues_index}
    #####pioneer part#####

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
            Log To Console    ue_${i} ${AT_commonds_type} commands are executed!
            client.sendat    command=AT+GTSET="5GSACTR",1    until_timeout=${until_timeout}    ue=${uegroup}[${i}]
            client.sendat    command=AT+GTACT=14    until_timeout=${until_timeout}    ue=${uegroup}[${i}]
        END
    END






################################## PA part ###############################################
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

Set the attenuation value of ports simultaneously step by step
    [Arguments]
    ...    ${start_value}
    ...    ${end_value}
    ...    ${step}
    ...    ${index}
    ...    ${pa_interval_time}=1s
    ...    ${direction}=increase
    IF    '${direction}' == 'increase'
        FOR    ${i}    IN RANGE    ${start_value}    ${end_value} + ${step}    ${step}
            ${set_values}=    Evaluate    [${i}] * len(${RU_PA_info}[${index}][ports])
            Set the attenuation value of ports simultaneously
            ...    att_ports=${RU_PA_info}[${index}][ports]
            ...    values=${set_values}
            ...    att_ipaddr=${RU_PA_info}[${index}][att_ipaddr]
            Sleep    ${pa_interval_time}
        END
    ELSE IF    '${direction}' == 'decrease'
        FOR    ${i}    IN RANGE    ${start_value}    ${end_value} - ${step}    -${step}
            ${set_values}=    Evaluate    [${i}] * len(${RU_PA_info}[${index}][ports])
            Set the attenuation value of ports simultaneously
            ...    att_ports=${RU_PA_info}[${index}][ports]
            ...    values=${set_values}
            ...    att_ipaddr=${RU_PA_info}[${index}][att_ipaddr]
            Sleep    ${pa_interval_time}
        END
    END

Set the attenuation value of ports simultaneously by step for loop ho
    [Arguments]
    ...    ${start_value}
    ...    ${end_value}
    ...    ${step}
    ...    ${index}
    ...    ${pa_interval_time}=1s
    FOR    ${i}    IN RANGE    ${start_value}    ${end_value} + ${step}    ${step}
        ${set_values}=    Evaluate    [${i}] * len(${RU_PA_info}[${index}][ports])
        Set the attenuation value of ports simultaneously
        ...    att_ports=${RU_PA_info}[${index}][ports]
        ...    values=${set_values}
        ...    att_ipaddr=${RU_PA_info}[${index}][att_ipaddr]
        Sleep    ${pa_interval_time}
    END
    FOR    ${i}    IN RANGE    ${end_value}    ${start_value} - ${step}    -${step}
        ${set_values}=    Evaluate    [${i}] * len(${RU_PA_info}[${index}][ports])
        Set the attenuation value of ports simultaneously
        ...    att_ports=${RU_PA_info}[${index}][ports]
        ...    values=${set_values}
        ...    att_ipaddr=${RU_PA_info}[${index}][att_ipaddr]
        Sleep    ${pa_interval_time}
    END

Set the attenuation value of ports simultaneously by step for loop Reestablish
    [Arguments]
    ...    ${source_initial_value}
    ...    ${target_initial_value}
    ...    ${source_index}
    ...    ${target_index}
    ...    ${pa_interval_time}
    ${set_values}=    Evaluate    [${target_initial_value}] * len(${RU_PA_info}[${target_index}][ports])
    Set the attenuation value of ports simultaneously
    ...    att_ports=${RU_PA_info}[${target_index}][ports]
    ...    values=${set_values}
    ...    att_ipaddr=${RU_PA_info}[${target_index}][att_ipaddr]
#    Sleep    ${pa_interval_time}
    ${set_values}=    Evaluate    [${127}] * len(${RU_PA_info}[${source_index}][ports])
    Set the attenuation value of ports simultaneously
    ...    att_ports=${RU_PA_info}[${source_index}][ports]
    ...    values=${set_values}
    ...    att_ipaddr=${RU_PA_info}[${source_index}][att_ipaddr]
    Sleep    ${pa_interval_time}
    ${set_values}=    Evaluate    [${source_initial_value}] * len(${RU_PA_info}[${source_index}][ports])
    Set the attenuation value of ports simultaneously
    ...    att_ports=${RU_PA_info}[${source_index}][ports]
    ...    values=${set_values}
    ...    att_ipaddr=${RU_PA_info}[${source_index}][att_ipaddr]
#    Sleep    ${pa_interval_time}
    ${set_values}=    Evaluate    [${127}] * len(${RU_PA_info}[${target_index}][ports])
    Set the attenuation value of ports simultaneously
    ...    att_ports=${RU_PA_info}[${target_index}][ports]
    ...    values=${set_values}
    ...    att_ipaddr=${RU_PA_info}[${target_index}][att_ipaddr]
    Sleep    ${pa_interval_time}







################################## MCS part ###############################################
Set MCS phase and att values
    TOPYOUNG MCS SETUP Phases AND SET ATT
    ...    mcs_type=topyoung
    ...    frequency=2600_1_ALL
    ...    att_value1=${15}
    ...    att_value2=${15}
    ...    vertical_angle=${0}
    ...    first_beam_begin_output_port=${1}     first_beam_end_output_port=${2}     first_beam_horizontal_angle=${0}
    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}    second_beam_horizontal_angle=${0}







################################## wireshark log analysis part ###############################################
Check IE from tcpdump logs
    [Arguments]
    ...    ${filename}
    ...    ${message_filter}
    ...    ${xpath_filter}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${filename}
    ${message}    Catenate    ${message_filter}
    ${message_packets}    cap.filter_packets_by_expression    filter_expression=${message}
    ${xpath_result}=    cap.Get Field Value By Xpath    pdml_list=${message_packets}
    ...                                                xpath=${xpath_filter}
    [Return]    ${xpath_result}

Check intra gnb HO is successfully
    [Arguments]    ${filename}    ${physCellId_1}    ${physCellId_2}    ${event_ID}=2
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${filename}
    ${measurement_filter}    Catenate     f1ap.procedureCode == 13 and nr-rrc.physCellId == ${physCellId_1}
    ${measurement_packets}    cap.filter_packets_by_expression    filter_expression=${measurement_filter}
    ${target_cell}=     cap.get_field_value_by_xpath    pdml_list=${measurement_packets}
    ...                                                xpath=.//nr-rrc.physCellId
    should not be empty    ${target_cell}
    ${UeModify_req_filter}    Catenate    f1ap.procedureCode == 7  and nr-rrc.eventId == ${event_ID} and  nr-rrc.physCellId == ${physCellId_1}
    ${UeModify_req_packets}    cap.filter_packets_by_expression    filter_expression=${UeModify_req_filter}
    ${eventIds}=    cap.get_field_value_by_xpath    pdml_list=${UeModify_req_packets}
    ...                                                xpath=.//nr-rrc.eventId
    should not be empty    ${eventIds}
    ${UeModify_res_filter}    Catenate    f1ap.protocolIEs == 5
    ${UeModify_res_packets}    cap.filter_packets_by_expression    filter_expression=${UeModify_res_filter}
    ${UeModify_res}    cap.get_field_value_by_xpath    pdml_list=${UeModify_res_packets}
    ...                                                xpath=.//f1ap.procedureCode
#    should be equal    ${UeModify_res[0]}    7
    should be equal    ${UeModify_res[0]}    12
    ${RRC_reconfig_filter}    Catenate    f1ap.procedureCode == 12
    ${RRC_reconfig_packets}    cap.filter_packets_by_expression    filter_expression=${RRC_reconfig_filter}
    ${RRC_reconfig}    cap.get_field_value_by_xpath    pdml_list=${RRC_reconfig_packets}
    ...                                                xpath=.//nr-rrc.physCellId
    ${rrc_TransactionIdentifier}    cap.get_field_value_by_xpath    pdml_list=${RRC_reconfig_packets}
    ...                                                xpath=.//nr-rrc.rrc_TransactionIdentifier
    should be equal    ${RRC_reconfig[0]}    ${physCellId_2}
    ${RRC_re_complete_filter}    Catenate    f1ap.procedureCode == 13 and nr-rrc.rrc_TransactionIdentifier == ${rrc_TransactionIdentifier[0]}
    ${RRC_re_complete_packets}    cap.filter_packets_by_expression    filter_expression=${RRC_re_complete_filter}
    ${RRC_re_complete}    cap.get_field_value_by_xpath    pdml_list=${RRC_re_complete_packets}
    ...                                                xpath=.//f1ap.procedureCode
    should be equal    ${RRC_re_complete[0]}    13

Check intra gnb re-establish is successfully
    [Arguments]    ${filename}    ${physCellId}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${filename}
    ${RRC_Reestablishment_Req_filter}=     Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 11
    ${RRC_Reestablishment_Req_packets}=    cap.filter_packets_by_expression    filter_expression=${RRC_Reestablishment_Req_filter}
    ${RRC_Reestablishment_Req}=     cap.get_field_value_by_xpath    pdml_list=${RRC_Reestablishment_Req_packets}
    ...                                                xpath=.//nr-rrc.physCellId
    should contain    ${RRC_Reestablishment_Req}    ${physCellId}

    #####RRC Reestablishment MAC=0xd5c7b0db
    ${Reestablishment} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12
    Log To Console    check Reestablishment
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Reestablishment}
    ${nr_rrc_criticalExtensions} =    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//nr-rrc.criticalExtensions
    Should Be Equal    ${nr_rrc_criticalExtensions[0]}    0

#    ${UEContextModificationRequired} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 8
#    Log To Console    check UEContextModificationRequired
#    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${UEContextModificationRequired}
#    ${f1ap_radioNetwork} =    get_field_value_by_xpath    pdml_list=${filtered_packets}
#    ...    xpath=.//f1ap.radioNetwork
#    Should Be Equal    ${f1ap_radioNetwork[0]}    12

    #####RRC Reestablishment Complete MAC=0xd6dc9cb9
    ${Reestablishment_Complete} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 13
    Log To Console    check Reestablishment Complete
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${Reestablishment_Complete}
    ${nr_rrc_criticalExtensions} =    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//nr-rrc.criticalExtensions
    Should Be Equal    ${nr_rrc_criticalExtensions[0]}    0

    ${BearerContextModificationResponse} =    Catenate    e1ap.E1AP_PDU == 1 and e1ap.procedureCode == 9
    Log To Console    check UEContextModificationRequired
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${BearerContextModificationResponse}
    ${e1ap_dRB_ID} =    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//e1ap.dRB_ID
    ${length_drb_id}    Get Length    ${e1ap_dRB_ID}
    ${drb_id}    Evaluate    ${length_drb_id}%3
    ${string_drb_id}    Convert To String    ${drb_id}
    Should Be Equal    ${string_drb_id}    0
