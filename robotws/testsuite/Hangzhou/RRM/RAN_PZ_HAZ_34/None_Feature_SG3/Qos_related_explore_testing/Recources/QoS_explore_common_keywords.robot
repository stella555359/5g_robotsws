*** Settings ***
Documentation
...    author: Shi Ming
...    contact: ming.shi@nokia-sbell.com
...    squal group: SG03
...    feature: QoS Explore

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/TDD_FDD_SFE_Regression/SISO_Resource/ping_pang_common_keywords.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/get_counters_from_pm_file.py
Library     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/None_Feature_SG3/Qos_related_explore_testing/Recources/QoS_explore_common_keywords.py
Library     taf.analyzer.pcap    WITH NAME    cap

Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/None_Feature_SG3/Qos_related_explore_testing/Recources/QoS_explore_variables.py


*** Keywords ***
Common Suite Setup For Explore
    Common Suite Setup for COAM
    Get sagnb version for selenium
    Set Suite Variable    ${tl_gnb1_scf_${sw_version}}    ${sw_version}_gNB1_Golden_SCF.xml
    Common Case TestLine Setup    is_commission=${True}    scf_path=${tl_scf_dir_path}    golden_scf_name=${tl_gnb1_scf_${sw_version}}

Common Suite Teardown For Explore
    Common Suite Teardown for COAM    gnb_list=${gnb_list}

Common Case Setup For Explore
    robot_common_operations.Common Case Setup    allowed_faults_ids=4291,4546
    AlarmWatchdog.add_allow_alarms    fault_id=4291
    AlarmWatchdog.add_allow_alarms    fault_id=4546
    Start capture syslog via btslog on ute

Common Case Teardown For Explore
    robot_common_operations.Common Case Teardown
    AlarmWatchdog.remove_allow_alarms    fault_id=4291
    AlarmWatchdog.remove_allow_alarms    fault_id=4546
    Stop capture syslog via btslog on ute
    ${name}=    Evaluate    '${TEST NAME}'.replace(" ", "_")
    Set Test Variable    ${name}
    syslog analysis via regex file
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

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

UE attach with wireshark captured
    [Arguments]    ${filename}    ${ue_type}    ${ue_index}    ${4G_check}=False    ${is_new_prepare_ue}=${False}
    IF     ${is_new_prepare_ue}==${False}
        power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ELSE
        power_ue.Prepare UE    ue_type=${tl.ues[${ue_index}].capabilities[2]}    ue_index=${ue_index}
    END
    Start capture gNB log on master    filename=${filename}
    Run Keyword If    '${ue_type}' != 'qct_dx50'    Huawei UE setup    ue_type=${ue_type}    ue_index=${ue_index}
    Set Suite Variable    ${iperf_button}    722 366
    Attach and check power UE    ue_type=${ue_type}    ue_index=${ue_index}    4G_check=${4G_check}
    [Teardown]    Stop and download Logs on gNB on master    filename=${filename}

Start only DL traffic and check tput common ue
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${dl_throughput}=${Send_Tput_DL}    ${cellid}=${1}    ${gnb_index}=${0}
    ...    ${direction}=DL    ${tput_dl_cell}=${expected_tput_dl}    ${dl_port}=${DL_PORT}    ${duration}=${600}
    Power UE Start DL traffic    ue_index=${ue_index}    ue_type=${ue_type}    dl_throughput=${dl_throughput}    duration=${duration}
    ...    dl_port=${dl_port}
    sleep    15s
    ${nrcellid_cell}    COAM Get nrcellid with lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    ${nrcellid_cell}    Create list  ${nrcellid_cell}
    Check single direction throughput     ue_index=${ue_index}    ue_type=${ue_type}    direction=${direction}    list_of_cell_ids=${nrcellid_cell}
    ...    expect_throughput=${tput_dl_cell}    gnb_index=${gnb_index}

Start only UL traffic and check tput common ue
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${ul_throughput}=${Send_Tput_UL}    ${cellid}=${1}    ${gnb_index}=${0}
    ...    ${direction}=UL    ${tput_ul_cell}=${expected_tput_ul}    ${ul_port}=${UL_PORT}    ${duration}=${600}
    ...    ${iperf_type}=via_app
    Power UE Start UL traffic    ue_index=${ue_index}    ue_type=${ue_type}    ul_throughput=${ul_throughput}    duration=${duration}
    ...    ul_port=${ul_port}    iperf_type=${iperf_type}
    sleep    15s
    ${nrcellid_cell}    COAM Get nrcellid with lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    ${nrcellid_cell}    Create list  ${nrcellid_cell}
    Check single direction throughput     ue_index=${ue_index}    ue_type=${ue_type}    direction=${direction}    list_of_cell_ids=${nrcellid_cell}
    ...    expect_throughput=${tput_ul_cell}    gnb_index=${gnb_index}

Stop DL or UL traffic common ue
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${direction}=DL     ${protocol}=udp    ${iperf_port}=default
    ...    ${iperf_type}=via_app
    power_ue.Stop traffic    ue_index=${ue_index}    ue_type=${ue_type}   direction=${direction}    protocol=${protocol}    iperf_port=${iperf_port}
    ...    iperf_type=${iperf_type}

Make a VoNR call(+6688) on SDX80
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=6688
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+${phone_number}
    ...    connection=cygwin${ue_index}
    sleep   1s
    [Teardown]    csn.disconnect      connection=cygwin${ue_index}

hang up VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cygwin${ue_index}
    sleep   1s
    [Teardown]    csn.disconnect      connection=cygwin${ue_index}

check voice call status
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${status}=${2}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   3s
    ##### check voice call enable  #####
    ##### 0: the phone is in standby state. 1: the call is not answered. 2: the phone is busy  #####
    csn.send_command    command=adb -s ${serial_number} shell dumpsys telephony.registry |grep mCallState
    ...    connection=cpc_${ue_index}
    sleep   2s
    ${result} =    csn.read output    connection=cpc_${ue_index}
    sleep    1s
    should contain    ${result}    mCallState=${status}
    [Teardown]    csn.disconnect      connection=cpc_${ue_index}

set apn to default dxdata2
    Set Suite Variable    ${close_task}    538 1874
    set apn with special method    usedapn=${DXDATA2_APN}    location_apn=${CLICK_ACCESS_POINT}

modify sessionAmbr value via SRN soap command
    [Arguments]    ${filename_modified}    ${filename_initial}
    FOR    ${index}    IN RANGE    ${5}
        modify sessionAmbr value to execute txt file
        ...    filename=${filename_modified}
        ...    index=${index}
        ...    EXECUTOR_FILE=${MODIFY_SESSION_AMBR_VALUE_TXT}
        modify sessionAmbr value to execute txt file
        ...    filename=${filename_initial}
        ...    index=${index}
        ...    EXECUTOR_FILE=${RECOVER_MODIFY_SESSION_AMBR_VALUE_TXT}
    END
    [Teardown]    Run Keyword If    '${KEYWORD STATUS}' == 'FAIL'
    ...    modify sessionAmbr value to execute txt file
    ...    filename=${filename_initial}
    ...    index=${index}
    ...    EXECUTOR_FILE=${RECOVER_MODIFY_SESSION_AMBR_VALUE_TXT}

modify sessionAmbr value to execute txt file
    [Arguments]    ${filename}    ${index}    ${EXECUTOR_FILE}
    Start capture gNB log on master    filename=${filename}_${index}.pcap
    Sleep    2s
    ${rc}    ${output}=    run and return rc and output    bash ${EXECUTOR_FILE_PATH}${EXECUTOR_FILE}
    Should Contain    ${output}    result="success"
    [Teardown]    Run Keywords
    ...    Sleep    5s
    ...    AND    Stop and download Logs on gNB on master    filename=${filename}_${index}.pcap
    ...    AND    check AMBR value on wireshark log    filename=${filename}_${index}.pcap

check AMBR value on wireshark log
    [Arguments]    ${filename}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${filename}
    ${PDUSessionResourceModifyRequest}=    Catenate    (ngap.NGAP_PDU == 0) && (ngap.procedureCode == 26)
    ${PDUSessionResourceModifyRequest_packets}    cap.filter_packets_by_expression    filter_expression=${PDUSessionResourceModifyRequest}
    ${procedureCode}=    cap.Get Field Value By Xpath    pdml_list=${PDUSessionResourceModifyRequest_packets}
    ...                                                xpath=.//ngap.procedureCode
    Should Be Equal As Integers    ${procedureCode}[0]    26
    ${PDUSessionResourceModifyResponse}=    Catenate    (ngap.NGAP_PDU == 1) && (ngap.procedureCode == 26)
    ${PDUSessionResourceModifyResponse_packets}    cap.filter_packets_by_expression    filter_expression=${PDUSessionResourceModifyResponse}
    ${ngap_procedureCode}=    cap.Get Field Value By Xpath    pdml_list=${PDUSessionResourceModifyResponse_packets}
    ...                                                xpath=.//ngap.procedureCode
    Should Be Equal As Integers    ${ngap_procedureCode}[0]    26
    ${PDUsessionmodificationcomplete}=    Catenate    (ngap.NGAP_PDU == 0) && (ngap.procedureCode == 46)
    ${PDUsessionmodificationcomplete_packets}    cap.filter_packets_by_expression    filter_expression=${PDUsessionmodificationcomplete}
    ${ngap_procedureCode}=    cap.Get Field Value By Xpath    pdml_list=${PDUsessionmodificationcomplete_packets}
    ...                                                xpath=.//ngap.procedureCode
    Should Be Equal As Integers    ${ngap_procedureCode}[0]    46

Prepare with PM counter time to caculate
    [Arguments]    ${period}=start
    ${utc0} =    Get Time    epoch
    ${utc} =    Evaluate    ${utc0}-${utc0}%300
    ${utc} =    set variable if    '${period}'=='start'     ${utc+300}    ${utc}
    set suite variable    ${${period}_date}    ${utc}
    ${left_timer} =    Evaluate    300-${utc0}%300
    sleep    ${left_timer}

get required kpi values via pm file
    [Arguments]    ${index}=${0}    ${bts_ip}=${tl.gnbs[${index}].cu.oam_ssh_connection_details.addr}
    ...    ${bts_username}=${tl.gnbs[${index}].cu.oam_ssh_connection_details.username}
    ...    ${bts_password}=${tl.gnbs[${index}].cu.oam_ssh_connection_details.password}
    ...    ${kpi_path}=${CURDIR}
    ...    ${KPI_file}=CB008246_E_006_KPI.txt
    ...    ${para_index}=${2}
    ${newest_xml_file}=    get_newest_pm_xml_file    ip=${bts_ip}    username=${bts_username}    password=${bts_password}
    ...    connection=gNB${index}    local_path=${epc_log_path}
    ${dict_kpi_value}=    calculate_kpis_of_kpi_file_via_pm_file    pm_xml_file=${newest_xml_file}
    ...    kpi_file=${kpi_path}/${KPI_file}    para_index=${para_index}
    [Return]    ${dict_kpi_value}

get and write kpis to excel file
    [Arguments]
    ...    ${KPI_file}
    ...    ${para_index}
    ...    ${target_sheet}
    ...    ${build_and_time}
    ...    ${excel_file}=QoS_explore_testing.xlsx
    ${counters}=    get required kpi values via pm file
    ...    KPI_file=${KPI_file}
    ...    para_index=${para_index}
    ${data}=    Evaluate    list(${counters}.values())
    insert_value_to_specific_sheet
    ...    excel_file=${EXCEL_KPI_PATH}/${excel_file}
    ...    target_sheet=${target_sheet}
    ...    insert_column=${1}
    ...    column_data=${data}
    ...    column_name=${build_and_time}

compare kpi result with last time
    [Arguments]
    ...    ${target_sheet}
    ...    ${compare_column}=${1}
    ...    ${current_column}=${2}
    ...    ${excel_file}=QoS_explore_testing.xlsx
    ${compare_columns_results}=    compare_results_with_last_time
    ...    excel_file=${EXCEL_KPI_PATH}/${excel_file}
    ...    target_sheet=${target_sheet}
    ...    compare_column=${compare_column}
    ...    current_column=${current_column}
