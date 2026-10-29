*** Settings ***
Resource    ../../common_resources.robot

*** Keywords ***
Test VoNR and UDP traffic
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${scell_id}=${SCELL_ID}    ${dl_tput}=${DL_TPUT}    ${ul_tput}=${UL_TPUT}
    ...    ${exp_dl}=100,600    ${exp_ul}=50,0    ${target_avg_percent}=0.95    ${min_percent}=0.85
    ...    ${tput_duration}=${DURATION_OF_TPUT_CHECK}    ${duration}=${DURATION_OF_DATA_TRANSFER}
    ...    ${ue_index}=${0}    ${try_voice_call_duration}=50    ${log_path}=${TS_CASE_LOG_PATH}
    ...    ${log_name_for_vonr}=asik_master_vonr    ${expect_call_duration}=${28}    ${interface}=fp0
    ...    ${command_template}=${None}    ${vonr_num}=9988
    Connect to gnb coam via ssl
    Connect to Common Unit Master    alias=ASIK Master
    FOR    ${pcell_info}    IN    @{PCELL_LIST}
        ${pcell_id}    set variable    ${pcell_info['nrCellId']}
        Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=${pcell_id}
        Test CA UDP plus VoNR    pcell_id=${pcell_id}    scell_id=${scell_id}    dl_tput=${dl_tput}    ul_tput=${ul_tput}
        ...    exp_dl=${exp_dl}    exp_ul=${exp_ul}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
        ...    tput_duration=${tput_duration}    duration=${duration}
        ...    ue_index=${ue_index}    try_voice_call_duration=${try_voice_call_duration}    log_path=${log_path}
        ...    log_name_for_vonr=${log_name_for_vonr}    expect_call_duration=${expect_call_duration}    interface=${interface}
        ...    command_template=${command_template}    vonr_num=${vonr_num}
        Change status for parameter cellBarred on GNB    exp_status=notBarred
    END

Test CA UDP plus VoNR
    [Documentation]     Author: Liu Zheng
    [Arguments]    ${pcell_id}    ${scell_id}=${SCELL_ID}    ${dl_tput}=${DL_TPUT}    ${ul_tput}=${UL_TPUT}
    ...    ${exp_dl}=100,600    ${exp_ul}=50,-1    ${target_avg_percent}=0.95    ${min_percent}=0.85
    ...    ${tput_duration}=${DURATION_OF_TPUT_CHECK}    ${duration}=${DURATION_OF_DATA_TRANSFER}
    ...    ${ue_index}=${0}    ${try_voice_call_duration}=50    ${log_path}=${TS_CASE_LOG_PATH}
    ...    ${log_name_for_vonr}=asik_master_vonr    ${expect_call_duration}=${28}    ${interface}=fp0
    ...    ${command_template}=${None}    ${vonr_num}=9988    ${target_avg_percent}=0.95    ${connection}=GNB_OAM
    Start pcap trace capturing by tcpdump    log_name=${log_name_for_vonr}    interface=${interface} sctp    alias=ASIK Master
    ${udp_tput_info_without_vonr}    Run keyword and continue on failure    CA_basic_L3_call    dl_tput=${dl_tput}    ul_tput=${ul_tput}
    ...    dl_cell_id=${pcell_id},${scell_id}    exp_dl=${exp_dl}    ul_cell_id=${pcell_id}     exp_ul=${exp_ul}
    ${tput_aasyslog_local_path}    Run keyword and continue on failure    collect udp throughput data when do VoNR call
    ...    try_voice_call_duration=${try_voice_call_duration}    vonr_num=${vonr_num}
    Connect to Common Unit Master    alias=ASIK Master
    Stop wireshark log capture from gNB    log_name_for_vonr=${log_name_for_vonr}
    analysis wireshark log for VoNR    pcap_file=${log_path}/${log_name_for_vonr}.pcap    expect_duration=${expect_call_duration}
    ...    command_template=${command_template}

    &{cell_mapping}    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids    connection_alias=${connection}
    ${ul_exp_tp_sum}    get the sum of the expect dl or ul throughput    exp_tp_number=${exp_ul}
    ${dl_exp_tp_sum}    get the sum of the expect dl or ul throughput    exp_tp_number=${exp_dl}
    ${list_of_nrcellidentity_ids}    Get the nrcellidentity_list    nr_cell_id_mapping=${cell_mapping}
    ${ul_tput_after}   ${dl_tput_after}    power_ue.Check Bi Tput    ue_type=${UE_TYPE}   log=${tput_aasyslog_local_path}
    ...    cells=${list_of_nrcellidentity_ids}    ultarget_throughput=${ul_exp_tp_sum}   dltarget_throughput=${ul_exp_tp_sum}
    ...    target_avg_percent=${target_avg_percent}    actCarrierAggregation=${True}
    ${throughput_info_with_vonr}  Create Dictionary   UL=${ul_tput_after}   DL=${dl_tput_after}
    log to console    \ntput_info_with_vonr: ${throughput_info_with_vonr}
    run keyword and continue on failure    verify throughput should be as expected    pcell_id=${pcell_id}    scell_id=${scell_id}
    ...    tput_info_1=${udp_tput_info_without_vonr}    tput_info_2=${throughput_info_with_vonr}
    [Teardown]    teardown for CA UDP plus VoNR    log_name_for_vonr=${log_name_for_vonr}    alias=ASIK Master

Get the sum of the expect dl or ul throughput
    [Documentation]     Author: Liu Zheng
    ...   the input is string like 1,2,3, then convert it to list, then get the sum of the list
    [Arguments]    ${exp_tp_number}=100,600
    ${list_exp}    string2list    ${exp_tp_number}
    ${sum}    set variable    ${0}
    FOR    ${var}    IN    @{list_exp}
        ${sum}    evaluate    ${sum}+int(${var})
    END
    [Return]    ${sum}

Get the nrcellidentity_list
    [Documentation]     Author: Liu Zhengl
    [Arguments]    ${nr_cell_id_mapping}
    ${info}   get dictionary values    ${nr_cell_id_mapping}
    ${list_of_nrcellidentity_ids}    create list
    FOR    ${cur_info}    IN    @{info}
           ${cur_nridentiity}    set variable   ${cur_info}[nrCellIdentity]
           ${cur_nridentiity}   convert to string    ${cur_nridentiity}
           append to list    ${list_of_nrcellidentity_ids}    ${cur_nridentiity}
    END
    [Return]    ${list_of_nrcellidentity_ids}

Verify throughput should be as expected
    [Documentation]   Author: Liu Zheng
    ...    compare the throughputs which are returned from CA_basic_l3_call
    [Arguments]    ${pcell_id}    ${scell_id}    ${tput_info_1}    ${tput_info_2}    ${target_avg_percent}=0.95
    ${1st_ul_pcell}    set variable    ${tput_info_1['${pcell_id}']['ul_avg_tput']}
    ${1st_dl_pcell_1}    set variable    ${tput_info_1['${pcell_id}']['dl_avg_tput']}
    ${1st_dl_scell_1}    set variable    ${tput_info_1['${scell_id}']['dl_avg_tput']}
    ${1st_dl_pcell_and_scell}    evaluate    ${1st_dl_pcell_1}+${1st_dl_scell_1}

    ${2_ul_pcell}    set variable    ${tput_info_2['UL'][0]['average']}
    ${2_dl_pcell_and_scell}    set variable    ${tput_info_2['DL'][0]['average']}

    run keyword and continue on failure    should be true    ${1st_dl_scell_1} > ${10}
    run keyword and continue on failure    should be true    ${2_ul_pcell} > ${1st_ul_pcell}*${target_avg_percent}
    run keyword and continue on failure    should be true    ${2_dl_pcell_and_scell} > ${1st_dl_pcell_and_scell}*${target_avg_percent}

collect udp throughput data when do VoNR call
    [Documentation]    Keep capturing Aasyslog for when do VoNR call.
    ...                Author: Liu Zheng
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${type}=MCU   ${duration}=20s    ${Teardown_after_finished}=${True}
    ...            ${log_ip}=127.0.0.1    ${start_timeout}=15m    ${gnb_path}=/tmp/    ${log_name}=Aasys_CCS_MCU.txt
    ...            ${aa_sys_mode}=2    ${aa_sys_addr}=0x7F000001    ${aa_sys_udp_port}=0xC738    ${filter}=L2Lo
    ...            ${host}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...            ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...            ${ue_index}=${0}    ${try_voice_call_duration}=50    ${vonr_num}=9988    ${hung_up_voice_call}=${True}

    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    ...                                    host=${host}    username=${username}    password=${password}
    Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}    type=${type}
    ...                      aa_sys_mode=${aa_sys_mode}    aa_sys_addr=${aa_sys_addr}    aa_sys_udp_port=${aa_sys_udp_port}
    ...                      host=${host}    username=${username}    password=${password}
    Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=${filter}
    ...                                 gnb_path=${gnb_path}    log_name=${log_name}
    ...                                 host=${host}    username=${username}    password=${password}
    ...                                 log_ip=${log_ip}    timeout=${start_timeout}
    Run keyword and continue on failure      Make a VoNR call    ue_index=${ue_index}    try_voice_call_duration=${try_voice_call_duration}
    ...        vonr_num=${vonr_num}    hung_up_voice_call=${hung_up_voice_call}
    ${current_time}    DateTime.Get Current Date
    ${local_path}    set variable    ${OUTPUT_DIR}/${current_time}_${log_name}
    Download Aasyslog File From GNB    log_path=${gnb_path}${log_name}    local_path=${local_path}
    ...                                gnb_index=${gnb_index}    du_index=${du_index}
    ...                                host=${host}    username=${username}    password=${password}
    [Return]    ${local_path}
    [Teardown]    run keyword if    '${Teardown_after_finished}'=='${True}'
    ...           Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    ...                                                  host=${host}    username=${username}    password=${password}

Teardown for CA UDP plus VoNR
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${log_name_for_vonr}=asik_master_vonr    ${alias}=ASIK Master
    Run Keyword And Ignore Error     Stop trace capturing    log_prefix=${log_name_for_vonr}    connection_alias=${alias}
    # the UE with version Lahaina.LA.1.1-00180-STD.PROD-2 will very slow after voice call, need reboot UE as WA, then the UE function is normal.
    UE soft reboot    ue_index=${0}   detach_request=${False}    reboot_timeout=120
    Check UE device exist    ue_index=${0}
    Run Keyword And Ignore Error     Stop data transfer and detach UE

Stop wireshark log capture from gNB
    [Documentation]     Author: Liu Zheng
    ...                 Description: Stop wireshark log capture on gNB, and download pcap log to testpc.
    ...                 pcap file on gNB will be deleted if ${remove_remote_file} is set to True.
    ...                 If file already exist on testPC, and ${overwrite_local_file} is set to False, it won't be downloaded again.
    ...    :param ${local_dir}: dir on test pc to put downloaded file.
    ...    :param ${local_file_name}: if ${None}, downloaded file will use same file name from remote;
    ...                              if specified, downloaded file will be renamed to ${local_file_name}.
    ...    :return: file path on test pc.
    [Arguments]    ${log_name_for_vonr}=asik_master_vonr    ${log_path}=${TS_CASE_LOG_PATH}    ${alias}=ASIK Master    ${local_file_name}=${None}
    ...    ${overwrite_local_file}=${True}    ${remove_remote_file}=${False}    ${remote_log_dir}=/tmp
    ${remote_log_path}    join path    ${remote_log_dir}    ${log_name_for_vonr}.pcap
    run keyword and continue on failure    Trace capturing process should be triggered
    ...    log_prefix=${log_name_for_vonr}    connection_alias=${alias}
    Stop trace capturing    log_prefix=${log_name_for_vonr}    connection_alias=${alias}
    ${local_log_path}    Download file to testPC    remote_file_path=${remote_log_path}    connection=${alias}    local_dir=${log_path}
    ...    local_file_name=${local_file_name}    overwrite_local_file=${overwrite_local_file}    remove_remote_file=${remove_remote_file}
    [Return]    ${local_log_path}

Make a VoNR call
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${connection}=cpc_${ue_index}
    ...    ${try_voice_call_duration}=50    ${vonr_num}=9988    ${hung_up_voice_call}=${True}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=${connection}
    sleep   5s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82
    ...    connection=${connection}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=${connection}
    sleep   2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+${vonr_num}
    ...    connection=${connection}
    sleep    ${try_voice_call_duration}s
    run keyword if    ${hung_up_voice_call}    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=${connection}
    run keyword if    ${hung_up_voice_call}    sleep    15s

hang up voice call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${connection}=cpc_${ue_index}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=${connection}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=${connection}
#    sleep    15s

analysis wireshark log for VoNR
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${pcap_file}    ${expect_duration}=${10}    ${command_template}=${None}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${pcap_file}    command_template=${command_template}
    set test variable    ${all_packets}
    #5qi5
    Run keyword and continue on failure      Analysis wireshark log for 5QI5    packets=${all_packets}
    #5qi1
    Run keyword and continue on failure      Analysis wireshark log for 5QI1    packets=${all_packets}
    # release success
    Run keyword and continue on failure      Analysis wireshark log for VoNR release success   packets=${all_packets}
    #time duration
    Check voice call duration    expect_duration=${expect_duration}    packets=${all_packets}

Analysis wireshark log for 5QI1
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${packets}
    ${Code26_0} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26 and ngap.fiveQI==1
    Log To Console    check PDUSessionResourceModifyRequest
    ${filtered_packets}=     cap.filter_packets_by_expression
    ...    filter_expression=${Code26_0}
    ${5qi}=     cap.get_field_value_by_xpath
    ...    xpath=.//ngap.fiveQI
    Should Be Equal    ${5qi[0]}    1

Analysis wireshark log for VoNR release success
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${packets}
    Log To Console    check release value on PDUSessionResourceModifyRequest message
    ${Code26_0} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26 and ngap.nas==0
    ${filtered_packets}=     cap.filter_packets_by_expression    filter_expression=${Code26_0}

    ${ngap_nas} =     cap.get_field_value_by_xpath    xpath=.//ngap.nas
    Should Be Equal    ${ngap_nas[0]}    0

    ${PDUSessionResourceModifyResponse} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log To Console    check release value on PDUSessionResourceModifyResponse
    ${filtered_packets}=
    ...     cap.filter_packets_by_expression    filter_expression=${PDUSessionResourceModifyResponse}
    ${ngap_id} =     cap.get_field_value_by_xpath    xpath=.//ngap.criticality
    Should Be Equal    ${ngap_id[0]}    0

Analysis wireshark log for 5QI5
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${packets}
    ...    ${message_filter}=(ngap.procedureCode == 14 and ngap.fiveQI == 5) or (ngap.procedureCode == 29 and ngap.fiveQI == 5)
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=     cap.filter_packets_by_expression    filter_expression=${filter_expression}
    ${ngap_fiveQI}=      cap.get_field_value_by_xpath
    ...                                                xpath=.//ngap.fiveQI
    should be equal    ${ngap_fiveQI[0]}    5

Check voice call duration
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${expect_duration}    ${packets}    ${index_for_start}=0    ${index_for_end}=-1
    ${voice_call_filter_start}    set variable    ngap.fiveQI == 1 and frame.time_epoch
    ${voice_call_filter_end}    set variable    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26 and ngap.nas==0
    ${time_start} =    Get message time    packets=${packets}    message_filter=${voice_call_filter_start}    index=${index_for_start}
    ${time_end} =    Get message time    packets=${packets}    message_filter=${voice_call_filter_end}    index=${index_for_end}
    ${time_diff} =    evaluate  float(${time_end})-float(${time_start})
    ${time_duration} =    convert_to_number    ${time_diff}	0
    should be true    ${time_duration}>=${expect_duration}
    [Return]    ${time_duration}

Get message time
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${message_filter}    ${packets}    ${index}=${index}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=     cap.filter_packets_by_expression    filter_expression=${filter_expression}
    @{frame_time}=      cap.get_field_value_by_xpath
    ...                                                xpath=.//frame.time_epoch
    log many    @{frame_time}
    ${timestamp}=    convert_to_number    ${frame_time}[${index}]
    [Return]    ${timestamp}
