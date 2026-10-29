*** Settings ***
Library    OperatingSystem
Library    Collections
Library    taf.stc.config
Library    String
Library    BuiltIn
Library    taf.config.scf    WITH NAME    scf
Library    taf.transport.ssh    WITH NAME    csn
Library    taf.transport.ssh    WITH NAME    ssh
Library    taf.pdu       WITH NAME    pdu
Library    taf.ul.messaging.mtk      WITH NAME    msg_mtk
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    taf/rfrl/common_resources/robot/coam_selenium.robot
Resource    taf/rfrl/common_resources/robot/gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/Huawei_sigspark_L3_call.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/SG2_Common_setup_teardown.robot

Documentation
...   author: Chen Tong
...   contact: tong.chen@nokia-sbell.com
...   squad group: SG_02

*** Variables ***
${cbctest_ip}    10.9.202.153
${cbctest_usr}    cbctest
${cbctest_psw}    cbctest
${cbctest_alias}    cbctest
&{liang_amf}    connect_hostname=10.108.221.101    mcc=460    mnc=02    tac=270
&{tang_amf}    connect_hostname=10.110.227.31    mcc=460    mnc=02    tac=270
&{han_amf}    connect_hostname=10.107.180.36    mcc=262    mnc=03    tac=270
&{zhou_amf}    connect_hostname=10.110.90.92    mcc=262    mnc=03    tac=270
&{sui_amf}    connect_hostname=10.110.66.229    mcc=262    mnc=03    tac=270
&{chu_amf}    connect_hostname=10.110.173.97    mcc=460    mnc=02    tac=270
&{feng_amf}    connect_hostname=10.110.194.163    mcc=460    mnc=02    tac=270
&{shen_amf}    connect_hostname=10.70.255.35    mcc=262    mnc=03    tac=270
&{zheng_amf}    connect_hostname=10.110.115.178    mcc=460    mnc=02    tac=270
&{zheng_amf1}    connect_hostname=10.110.133.97    mcc=262    mnc=03    tac=270


${scf_dir_746}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/5GC000746
${sa_scf_path}    ${scf_dir_746}/scf_SA.xml
${sa_rf64_scf_path}    ${scf_dir_746}/scf_SA_rf64.xml
${4beam_scf_path}    ${scf_dir_746}/scf_SA_4beam.xml
${3amf_scf_path}    ${scf_dir_746}/scf_SA_3amf.xml
${cmas_trigger}    /home/cbctest/HZ_SG2_CIT/testcase

&{warning_area_list}    warning_area_cgi_list_1cell=0
...                     warning_area_cgi_list_2cells=1
...                     warning_area_cgi_list_2cell=2
...                     tai_warning_area_list=3
...                     unknown_tai_warning_area_list=4
...                     warning_area_emergency_list=5
...                     unknown_warning_area_emergency_list=6
...                     warnig_area_list_none=7

${default_message_identifier}    4372
${default_serial_number}    50
${default_repetition_period}    5
${default_number_of_broadcasts_requested}    ${3}
${default_cmas}    /home/cbctest/HZ_SG2_CIT/test_amf_cit.py
${long_cmas}    /home/cbctest/HZ_SG2_CIT/test_amf_long.py
${short_cmas}    /home/cbctest/HZ_SG2_CIT/test_amf_short.py

${tshark_path_for_746}    /usr/bin/tshark
${luashark_path}    /opt/luashark/luashark.lua
${expression_cmas}    \"(f1ap or ngap or nr-rrc.c1 == 1 or nr-rrc.sib_TypeAndInfo_item == 6
...                   or sic.msgid == 0x100d or sic.msgid == 0x100e
...                   or sic.msgid == 0x092a or sic.msgid == 0x092b or sic.msgid == 0x100a)\"
${expression_cmas_sib1}    \"nr-rrc.c1 == 1\"
${expression_cmas_sib8}    \"(f1ap or ngap or nr-rrc.sib_TypeAndInfo_item == 6)\"
${bip_expression_cmas_cell1}    \"(f1ap or ngap or nr-rrc.c1 == 1 or nr-rrc.sib_TypeAndInfo_item == 6
...                             or sic.msgid == 0x100d or sic.msgid == 0x100e
...                             or sic.msgid == 0x092a or sic.msgid == 0x092b or sic.msgid == 0x100a)
...                             and 3gpp.subcellid==0\"
${bip_expression_cmas_cell2}    \"(f1ap or ngap or nr-rrc.c1 == 1 or nr-rrc.sib_TypeAndInfo_item == 6
...                             or sic.msgid == 0x100d or sic.msgid == 0x100e
...                             or sic.msgid == 0x092a or sic.msgid == 0x092b or sic.msgid == 0x100a)
...                             and 3gpp.subcellid==1\"
${command_template}    {tshark_path} -r {pcap_file} -Y ${expression_cmas_sib8} -T pdml
${command_template_sib1}    {tshark_path} -r {pcap_file} -Y ${expression_cmas_sib1} -T pdml
${command_template_bip_cell1}    {tshark_path} -r {pcap_file} -Y ${bip_expression_cmas_cell1} -T pdml
${command_template_bip_cell2}    {tshark_path} -r {pcap_file} -Y ${bip_expression_cmas_cell2} -T pdml
${command_ngap_template}    {tshark_path} -r {pcap_file} -Y "ngap" -T pdml
@{command_template_bip}    ${command_template_bip_cell1}    ${command_template_bip_cell2}

@{segment_size}    ${162}    ${572}
@{sib8_periodicity_list}    8    16    32    64
${sib8_filter_expression}    nr-rrc.sib_TypeAndInfo_item == 6
${sib8_field_name}    nr-rrc.sib_TypeAndInfo_item
${sib8_warningMessageSegmentType}    nr-rrc.warningMessageSegmentType
${sib8_warningMessageSegmentNumber}    nr-rrc.warningMessageSegmentNumber
${sib8_warningMessageSegment}    nr-rrc.warningMessageSegment
${sib8_warningMessageSegment_xpath}    .//nr-rrc.warningMessageSegment
${sib8_warningAreaCoordinatesSegment}    nr-rrc.warningAreaCoordinatesSegment
${sib8_sfn}    _3gpp.sfn
${sib8_slot}    _3gpp.slot
${filter_sib8_sfn}    3gpp.sfn
${filter_sib8_slot}    3gpp.slot

${sib1_with_sib8_scheduling_filter_expression}    nr-rrc.c1 == 1 and nr-rrc.type == 6
${sib8_type_filed_xpath}    nr-rrc.SchedulingInfo_element/nr-rrc.sib_MappingInfo/_/nr-rrc.SIB_TypeInfo_element/nr-rrc.type
${sib8_periodicity_filed_xpath}    nr-rrc.SchedulingInfo_element/nr-rrc.si_Periodicity

${dldata_pdcchsendreq_beamid}    dldata_pdcchsendreq.beamId

${ngap_errorcause_filter_expression}    ngap.procedureCode == 9 and ngap.protocol == 3
${ngap_pwsfailureind_filter_expression}    ngap.procedureCode == 33 and ngap.PWSFailedCellIDList == 1
${ngap_request_filter_expression}    ngap.WriteReplaceWarningRequest_element and ngap.procedureCode == 51
${ngap_response_filter_expression}    ngap.WriteReplaceWarningResponse_element and ngap.procedureCode == 51
${ngap_completedarea_filter_expression}    ngap.id == 13
${ngap_cancelledarealist_filter_expression}    ngap.id == 12
${ngap_pwscancelrequest_filter_expression}    ngap.PWSCancelRequest_element and ngap.procedureCode == 32
${ngap_pwscancelresponse_filter_expression}    ngap.PWSCancelResponse_element and ngap.procedureCode == 32
${ngap_nrcellidentity_field_name}    ngap.NRCellIdentity
${ngap_nrcellidentity_field_xpath}    .//_[1]/ngap.CellIDBroadcastNR_Item_element/ngap.nR_CGI_element/ngap.NRCellIdentity
${ngap_initiatingMessage_procedureCode}    .//ngap.initiatingMessage_element/ngap.procedureCode
${ngap_successfulOutcome_procedureCode}    .//ngap.successfulOutcome_element/ngap.procedureCode
${ngap_warningmessagecontents}    ngap.WarningMessageContents
${ngap_warningmessagecontents_xpath}    .//ngap.WarningMessageContents
${ngap_WarningAreaCoordinates}    ngap.WarningAreaCoordinates

&{ngap_warningarealist}    None=0    cgilist=1    tailist=2

${ngap_emec_register_filter_expression}    (ngap.procedureCode == 15) && (nr-rrc.establishmentCause == 0)
${ngap_pdusessioncomplete_filter_expression}     (ngap.procedureCode == 46) && (nas-5gs.sm.message_type == 0xcc)
${ngap_emc_register}    nr-rrc.establishmentCause

${ngap_pdurelease_filter_expression}    (ngap.procedureCode == 28) && (ngap.nas == 0)
${ngap_pdureleasecomplete_filter_expression}    (ngap.procedureCode == 46) && (nas-5gs.sm.message_type == 0xd4)
${ngap_emc_release}    ngap.nas

${ngap_pdu_messagetype}    nas-5gs.sm.message_type

${f1ap_request_filter_expression}    f1ap.WriteReplaceWarningRequest_element
${f1ap_response_complete_filter_expression}    f1ap.WriteReplaceWarningResponse_element and f1ap.id == 146
${f1ap_initiatingMessage_procedureCode}    .//f1ap.initiatingMessage_element/f1ap.procedureCode
${f1ap_successfulOutcome_procedureCode}    .//f1ap.successfulOutcome_element/f1ap.procedureCode
${f1ap_pwscancelrequest_filter_expression}    f1ap.PWSCancelRequest_element
${f1ap_pwscancelresponse_complete_filter_expression}    f1ap.PWSCancelResponse_element and f1ap.id == 150
${f1ap_nrcellidentity_field_name}    f1ap.nRCellIdentity

${dldata_subcellid}   3gpp.subcellid

${cipheringAlgorithm_field_name}    nr-rrc.cipheringAlgorithm
${securitymodecommand_filter}    nr-rrc.c1 == 4
${mcc_filter}    e212.mcc
${mnc_filter}    e212.mnc

*** Keywords ***
Get The Numeber Of Beams
    [Arguments]    ${cell_group_id}=0
#    ${cell_group_id}    Evaluate    ${cell_id}-${1}
    COAM Navigate to login page via webUI
    ${beamset_para_value}    selenium_coam.get_parameter_value
    ...    dist_name=NRBTS-${nr_bts_id}/NRCELLGRP-${cell_group_id}
    ...    abbr=numberOfTransmittedSsBlocks
    ...    filter_param=Number of transmitted Synchronization Signal Blocks
    ${beamnumber_para_value}    Fetch From Left    string=${beamset_para_value}    marker=${SPACE}
    ${number_of_beam}    Convert To Integer    ${beamnumber_para_value}
    [Return]    ${number_of_beam}
    [Teardown]    COAM selenium logout

5GC000746 Prepare for Case
    [Arguments]    ${cell_group_id}=0
    run   command=killall firefox
    run   command=killall Xvfb
    run   command=killall geckodriver
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${amf_info}    get_amf_info
    COAM selenium logout
    ${amf_info}    Set Variable    ${amf_info['AMF name']}
    ${current_amf}    Set Variable If    '${amf_info}' == 'amf-amf1'    ${zhou_amf}
    ...                                  '${amf_info}' == 'amf3-amf3'    ${tang_amf}
    ...                                  '${amf_info}' == 'amf-amfhan2'    ${han_amf}
    ...                                  '${amf_info}' == 'amf2-amfsui1'    ${sui_amf}
    ...                                  '${amf_info}' == 'amf3-amf3-chu'    ${chu_amf}
    ...                                  '${amf_info}' == 'cmmqa4'    ${feng_amf}
    ...                                  '${amf_info}' == 'amfshen8'    ${shen_amf}
    ...                                  '${amf_info}' == 'cmmqa7-cmmqa7-qa'    ${zheng_amf}
    ...                                  '${amf_info}' == 'amf1-amf1-zheng'    ${zheng_amf1}
    ...                                   ${liang_amf}
    wait until keyword succeeds    1min    2sec    Connect to gnb coam via ssl
    ${hw_info}    coam.get_detected_hw_info    connection=GNB_OAM
    Run keyword and ignore error    COAM Teardown gnb connections
    ${smod}    Set variable    ${hw_info['systemModules'][0]}
    ${ngap_connection}    Set Variable If    '${smod['productName']}' == 'ASIK AirScale Common'    ASIK Slave    ASIK Master
    ${ute_env}    run keyword and return status    run keywords
    ...    Variable Should Exist    ${CONFIGURATION}    AND    Variable Should Exist    ${ENB_BUILD}
    ${number_of_beam}    Get The Numeber Of Beams    cell_group_id=${cell_group_id}
    Set Test Variable    ${ute_env}
    Set Test Variable    ${current_amf}
    Set Test Variable    ${ngap_connection}
    Set Test Variable    ${default_last_segment_repeat_times}    ${number_of_beam}
    Set Test Variable    ${sib8_periodicity_xpath_id}    .//_[2]
    ${tl_name}   run keyword if    '${testline_name}' == 'null'    String.Fetch From Right    string=${CONFIGURATION}    marker=.
    ...           ELSE    set variable     ${testline_name}
    Connect to Cbctest

Suite preparation
    robot_common_operations.Common Suite Setup
    COAM Wait for gnb ready and cell setup    gnb_type='SA'
    COAM commission scf and wait cell setup    scf_file_path=${sa_scf_path}

5GC000746 Case Setup
    [Arguments]    ${cell_group_id}=0
    robot_common_operations.Common Case Setup
    5GC000746 Prepare for Case    cell_group_id=${cell_group_id}
    SG2_Common_setup_teardown.Common Case setup    need_Btslog=${True}

5GC000746 Case Teardown
    Remove Files    ${OUTPUT_DIR}/*.pdml
    csn.Disconnect    connection=${cbctest_alias}
    Run Keyword And Ignore Error    SG2_Common_setup_teardown.Common Case teardown    need_Btslog=${True}

5GC000746 Case Teardown to Recover Configuration
    Remove Files    ${OUTPUT_DIR}/*.pdml
    Run Keyword And Ignore Error    SG2_Common_setup_teardown.Common Case teardown    is_need_to_recover=${True}

5GC000746 Case Reconnect
    ssh.Reset Cache
    Connect to Cbctest
    Connect to Common Unit Master
    Connect to Common Unit Slave

Commission Scf with actCMAS False
    ${scf_file_path}    COAM Modify scf file    scf_file_path=${backup_scf_file}    scf_parameters_list=${SCF_746_001}
    COAM commission scf and wait cell setup    scf_file_path=${scf_file_path}

COAM Get BTS Counters via webUI
    [Arguments]    ${counter_id}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${counters}    selenium_coam.get_bts_counters_info    counter_id=${counter_id}
    COAM selenium logout
    ${counters}    Get Dictionary Values    ${counters}
    [Return]    ${counters}

COAM Update Emergency Area ID List via webUI
    [Arguments]      ${param_emergency_area_id_list}    ${is_need_to_check_validation_errors}=${False}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${cur_para_value}    selenium_coam.get_parameter_value
    ...    dist_name=${param_emergency_area_id_list}[dist_name]
    ...    filter_param=${param_emergency_area_id_list}[filter_param]
    ...    node_index=${0}
    @{diff_para} =    create list
    Run keyword if    '${cur_para_value}'=='${param_emergency_area_id_list['new_value']}'
    ...    Log to console    current value is ${cur_para_value}, no need to update
    ...    ELSE    run keywords    selenium_coam.set_parameter_value    dist_name=${param_emergency_area_id_list}[dist_name]
    ...                                                                 filter_param=${param_emergency_area_id_list}[filter_param]
    ...                                                                 new_value=${param_emergency_area_id_list}[new_value]
    ...                                                                 node_index=${0}    AND
    ...                             Append to list    ${diff_para}    ${param_emergency_area_id_list}    AND
    ...                             selenium_coam.validate_plan    AND
    ...                             COAM check validation errors from webui
    ...                             is_need_to_check_validation_errors=${is_need_to_check_validation_errors}    AND
    ...                             selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    ${cur_para_value}    selenium_coam.get_parameter_value
    ...    dist_name=${param_emergency_area_id_list}[dist_name]
    ...    filter_param=${param_emergency_area_id_list}[filter_param]
    ...    node_index=${0}
    ${new_value}    Convert To String    ${param_emergency_area_id_list}[new_value]
    Should be Equal    ${cur_para_value}    ${new_value}
    COAM selenium logout

COAM Update SIBPERIODICITY via webUI
    [Arguments]      ${param_sibperiodicity}    ${is_need_to_check_validation_errors}=${False}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${cur_para_value}    selenium_coam.get_parameter_value
    ...    dist_name=${param_sibperiodicity}[dist_name]
    ...    filter_param=${param_sibperiodicity}[filter_param]
    ...    node_index=${4}
    ...    abbr=${param_sibperiodicity}[abbr]
    @{diff_para} =    create list
    Run keyword if    '${cur_para_value}'=='${param_sibperiodicity['new_value']}'
    ...    Log to console    current value is ${cur_para_value}, no need to update
    ...    ELSE    run keywords    selenium_coam.set_parameter_value    dist_name=${param_sibperiodicity}[dist_name]
    ...                                                                 filter_param=${param_sibperiodicity}[filter_param]
    ...                                                                 new_value=${param_sibperiodicity}[new_value]
    ...                                                                 node_index=${4}
    ...                                                                 abbr=${param_sibperiodicity}[abbr]    AND
    ...                             Append to list    ${diff_para}    ${param_sibperiodicity}    AND
    ...                             selenium_coam.validate_plan    AND
    ...                             COAM check validation errors from webui
    ...                             is_need_to_check_validation_errors=${is_need_to_check_validation_errors}    AND
    ...                             selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    ${cur_para_value}    selenium_coam.get_parameter_value
    ...    dist_name=${param_sibperiodicity}[dist_name]
    ...    filter_param=${param_sibperiodicity}[filter_param]
    ...    node_index=${4}
    ...    abbr=${param_sibperiodicity}[abbr]
    ${new_value}    Convert To String    ${param_sibperiodicity}[new_value]
    Should be Equal    ${cur_para_value}    ${new_value}
    COAM selenium logout

Connect to Cbctest
    csn.connect to    hostname=${cbctest_ip}
    ...               username=${cbctest_usr}
    ...               password=${cbctest_psw}
    ...               alias=${cbctest_alias}

Convert String format
    [Arguments]    ${string}
    ${string}    Convert To Hex    ${string}    length=4
    ${string}    Convert To String    ${string}
    ${substring_0}    Get Substring    ${string}    0    2
    ${substring_1}    Get Substring    ${string}    2
    ${string}    Set Variable    ${substring_0}:${substring_1}
    [Return]    ${string}

Sum Value in Counter list
    [Arguments]    ${cnt_list}
    ${sum}    Set Variable    0
    FOR  ${item}  IN  @{cnt_list}
        Convert To Integer    ${item}
        ${sum}    Evaluate    ${item} + ${sum}
    END
    [Return]    ${sum}

Precondition for CMAS Notification
    [Arguments]    ${param_list}    ${download_dir}=${TS_CASE_LOG_PATH}
    COAM Navigate to login page via webUI    download_dir=${download_dir}
    FOR  ${iterm}  IN  @{param_list}
        ${value}    selenium_coam.get_parameter_value      dist_name=${iterm}[dist_name]
        ...                                                filter_param=${iterm}[filter_param]
        ...                                                abbr=${iterm}[p_name]
        ...                                                timeout=${120}
        Set Test Variable    ${${iterm}[value_name]}    ${value}
    END
    ${gnodeb_id}    selenium_coam.get_bts_id
    Set Test Variable    ${gnodeb_id}
    Run keyword and ignore error    selenium_coam.logout
    Run keyword and ignore error    selenium_coam.disable_virtual_display

Trigger CMAS Notification
    [Arguments]    ${amf}
    ...            ${warning_area_list_id}
    ...            ${cmas_file}=${default_cmas}
    ...            ${message_identifier}=${default_message_identifier}
    ...            ${serial_number}=${default_serial_number}
    ...            ${repetition_period}=${default_repetition_period}
    ...            ${number_of_broadcasts_requested}=${default_number_of_broadcasts_requested}
    ...            ${connection}=${cbctest_alias}
    ...            ${content_idx}=${0}
    ...            ${timer}=20
    ...            ${cell_id}=${1}
    ${cmd_local}    catenate    ${cmas_trigger} ${cmas_file}
    ...                         ${amf}[connect_hostname] ${amf}[mcc] ${amf}[mnc]
    ...                         ${amf}[tac] ${gnodeb_id} ${nr_of_bits_g_node_b_id}
    ...                         ${message_identifier} ${serial_number} ${repetition_period}
    ...                         ${number_of_broadcasts_requested} ${warning_area_list_id} ${content_idx} ${cell_id}
    csn.send_command    command=${cmd_local}    connection=${connection}
    Sleep    ${timer}s
    csn.read_output    connection=${connection}

Trigger CMAS PWS Cancel
    [Arguments]    ${amf}
    ...            ${warning_area_list_id}
    ...            ${message_identifier}=${default_message_identifier}
    ...            ${serial_number}=${default_serial_number}
    ...            ${connection}=${cbctest_alias}
    ${cmd_local}    catenate    ${cmas_trigger} /home/cbctest/HZ_SG2_CIT/test_cancel_cit.py
    ...                         ${amf}[connect_hostname] ${amf}[mcc] ${amf}[mnc]
    ...                         ${amf}[tac] ${gnodeb_id} ${nr_of_bits_g_node_b_id}
    ...                         ${message_identifier} ${serial_number} ${warning_area_list_id}
    csn.send_command    command=${cmd_local}    connection=${connection}
    Sleep    20s
    csn.read_output    connection=${connection}

Start To Capture Wireshark Background
    [Arguments]     ${filename}=file.pcap  ${connection}=${asik}
    csn.send_command    command=nohup tcpdump sctp or port 49148 -i any -s 0 -p -w ${gnb_tmp_log_dir}/${filename} &>/dev/null &
    ...                 connection=${connection}

Start NGAP and Bip Logs Capture
    ${746_timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
    ${ngap_name}    Set Variable    ngap_${746_timestamp}.pcap
    Set Test Variable    ${746_timestamp}
    Start Bip Log with Suitable Means    target_file_name=l1l2bip_log_${746_timestamp}
#    Bip Capture with gnbMirroring scripts with retry    syscom_mirroring=false
    5GC000746 Case Reconnect
    Start To Capture Wireshark Background    filename=${ngap_name}    connection=${ngap_connection}
    [Return]    ${ngap_name}

Stop NGAP and Bip Logs Capture and Download Logs
    [Arguments]    ${ngap_name}
#    ${bip_log}    Stop BIP capture on ASIK if needed and download BIP Logs to testPC    log_path=${OUTPUT_DIR}
    ${bip_log}    Stop Bip Log with Suitable Means    target_file_name=l1l2bip_log_${746_timestamp}
    5GC000746 Case Reconnect
    Stop and download Wireshark file    filename=${ngap_name}
    ...                                 connection=${ngap_connection}
    ...                                 ute_log_path=${OUTPUT_DIR}
    [Return]    ${OUTPUT_DIR}/${ngap_name}    ${bip_log[0]}

Trigger CMAS Notification and Capture Logs
    [Arguments]    ${amf}
    ...            ${warning_area_list_id}
    ...            ${cmas_file}=${default_cmas}
    ...            ${message_identifier}=${default_message_identifier}
    ...            ${serial_number}=${default_serial_number}
    ...            ${repetition_period}=${default_repetition_period}
    ...            ${number_of_broadcasts_requested}=${default_number_of_broadcasts_requested}
    ...            ${connection}=${cbctest_alias}
    ...            ${content_idx}=${0}
    ...            ${timer}=20
    ...            ${cell_id}=${1}
    Precondition for CMAS Notification    param_list=${PARAM_746_CMAS_PREPARE}
    ${ngap_name}    Start NGAP and Bip Logs Capture
    Trigger CMAS Notification    amf=${amf}    warning_area_list_id=${warning_area_list_id}    cmas_file=${cmas_file}
    ...                          message_identifier=${message_identifier}    serial_number=${serial_number}
    ...                          repetition_period=${repetition_period}
    ...                          number_of_broadcasts_requested=${number_of_broadcasts_requested}
    ...                          connection=${connection}
    ...                          content_idx=${content_idx}
    ...                          timer=${timer}
    ...                          cell_id=${cell_id}
    ${ngap_log}    ${bip_log}    Stop NGAP and Bip Logs Capture and Download Logs    ngap_name=${ngap_name}
    [Return]    ${ngap_log}    ${bip_log}

Trigger CMAS PWS Cancel and Capture Logs
    [Arguments]    ${amf}
    ...            ${warning_area_list_id}
    ...            ${message_identifier}=${default_message_identifier}
    ...            ${serial_number}=${default_serial_number}
    ...            ${connection}=${cbctest_alias}
    ${ngap_name}    Start NGAP and Bip Logs Capture
    Trigger CMAS PWS Cancel    amf=${amf}    warning_area_list_id=${warning_area_list_id}
    ...                        message_identifier=${message_identifier}    serial_number=${serial_number}
    ...                        connection=${connection}
    ${ngap_log}    ${bip_log}    Stop NGAP and Bip Logs Capture and Download Logs    ngap_name=${ngap_name}
    [Return]    ${ngap_log}    ${bip_log}

Check CMAS Log
    [Arguments]    ${filter_expression}    ${field_name}=None    ${field_xpath}=None
    Run Keyword If    '${field_name}' == 'None'
    ...               Check expression in Bip Log by Xpath    filter_expression=${filter_expression}
    ...                                                       field_xpath=${field_xpath}
    ...       ELSE    Check expression in Bip Log by Name    filter_expression=${filter_expression}
    ...                                                      field_name=${field_name}

Load and Check CMAS Log
    [Arguments]    ${pcap_file}    ${filter_expression}    ${field_name}=None    ${field_xpath}=None
    Load BIP Log with Template Command    pcap_file=${pcap_file}
    ...                                   command_template=${command_template}
    ...                                   tshark_path=${tshark_path_for_746}
    Check CMAS Log    filter_expression=${filter_expression}
    ...               field_name=${field_name}    field_xpath=${field_xpath}

Check Write Replace Warning Response Message
    [Arguments]    ${ngap_log}
    Load and Check CMAS Log    pcap_file=${ngap_log}
    ...                        filter_expression=${ngap_response_filter_expression}
    ...                        field_xpath=${ngap_successfulOutcome_procedureCode}

Check Bip Log without CMAS broadcasted
    [Arguments]    ${bip_log}
    ${status}    Run Keyword And Return Status    Load and Check CMAS Log    pcap_file=${bip_log}
    ...                                                                      filter_expression=${sib8_filter_expression}
    ...                                                                      field_name=${sib8_field_name}
    Should not be True    ${status}

Check Error Ind Message with Message Not Compatiable With Receiver State Cause
    [Arguments]    ${ngap_log}    ${bip_log}
    Load and Check CMAS Log    pcap_file=${ngap_log}
    ...                        filter_expression=${ngap_errorcause_filter_expression}
    ...                        field_xpath=${ngap_initiatingMessage_procedureCode}
    Check Bip Log without CMAS broadcasted    bip_log=${bip_log}

Check Write Replace Warning Response without Broadcaset Completed Area List
    [Arguments]    ${ngap_log}    ${bip_log}    ${check_bip}=True
    Check Write Replace Warning Response Message    ngap_log=${ngap_log}
    ${status}    Run Keyword And Return Status    Load and Check CMAS Log    pcap_file=${ngap_log}
    ...                                                                      filter_expression=${ngap_completedarea_filter_expression}
    ...                                                                      field_xpath=${ngap_successfulOutcome_procedureCode}
    Should not be True    ${status}
    Run Keyword If    '${check_bip}' == 'True'    Check Bip Log without CMAS broadcasted    bip_log=${bip_log}

Check PWS Failure Indication Message with PWSFailedCellIDList IE
    [Arguments]    ${ngap_log}
    Load and Check CMAS Log    pcap_file=${ngap_log}
    ...                        filter_expression=${ngap_pwsfailureind_filter_expression}
    ...                        field_xpath=${ngap_initiatingMessage_procedureCode}

Check PWS Failure Indication Message with PWSFailedCellIDList IE for Multi AMFs
    [Arguments]    ${ngap_log}
    Load BIP Log with Template Command    pcap_file=${ngap_log}
    ...                                   command_template=${command_template}
    ...                                   tshark_path=${tshark_path_for_746}
    Filter Packets By Expression    filter_expression=${ngap_pwsfailureind_filter_expression}
    ${value}    Get value from Bip Log by xpath    xpath=${ngap_initiatingMessage_procedureCode}
    ${length}    Get Length    ${value}
    Should Be Equal As Integers    ${length}    2

Check CMAS Broadcasting is Interrupted
    ${current_timestamp}    Get Current Date    result_format=%Y%m%d-%H%M%S
    Start Bip Log with Suitable Means    target_file_name=l1l2bip_log_${current_timestamp}
#    Bip Capture with gnbMirroring scripts with retry    syscom_mirroring=false
    Sleep    10s
#    ${bip_log}    Stop BIP capture on ASIK if needed and download BIP Logs to testPC    log_path=${OUTPUT_DIR}
    ${bip_log}    Stop Bip Log with Suitable Means    target_file_name=l1l2bip_log_${current_timestamp}
    Check Bip Log without CMAS broadcasted    bip_log=${bip_log}

Check Complete Procedure in NGAP Log
    [Arguments]    ${ngap_log}
    ...            ${serial_number}=${default_serial_number}
    ...            ${message_identifier}=${default_message_identifier}
    ...            ${repetition_period}=${default_repetition_period}
    ...            ${number_of_broadcasts_requested}=${default_number_of_broadcasts_requested}
    ...            ${no_wac}=${False}
    ${serial_number}    Convert String format    string=${serial_number}
#    ${message_identifier}    Run Keyword If    ${ute_env}    Set Variable    ${message_identifier}
#    ...                                ELSE    Convert String format    string=${message_identifier}
    ${ngap_WRWReq_filter_expression}    catenate    ${ngap_request_filter_expression}
    ...                                             and ngap.SerialNumber == ${serial_number}
    ...                                             and ngap.MessageIdentifier == ${message_identifier}
    ...                                             and ngap.RepetitionPeriod == ${repetition_period}
    ...                                             and ngap.NumberOfBroadcastsRequested == ${number_of_broadcasts_requested}
    Load and Check CMAS Log    pcap_file=${ngap_log}    filter_expression=${ngap_WRWReq_filter_expression}
    ...                        field_xpath=${ngap_initiatingMessage_procedureCode}
    ${wmc}    Get value from Bip Log by xpath    xpath=${ngap_warningmessagecontents_xpath}
    ${wac}    Get value from Bip Log    field_name=${ngap_WarningAreaCoordinates}
    Load and Check CMAS Log    pcap_file=${ngap_log}    filter_expression=${f1ap_request_filter_expression}
    ...                        field_xpath=${f1ap_initiatingMessage_procedureCode}
    Load and Check CMAS Log    pcap_file=${ngap_log}    filter_expression=${f1ap_response_complete_filter_expression}
    ...                        field_xpath=${f1ap_successfulOutcome_procedureCode}
    ${status}    ${value}    Run Keyword And Ignore Error    Load and Check CMAS Log    pcap_file=${ngap_log}
    ...               filter_expression=${ngap_response_filter_expression} and ${ngap_completedarea_filter_expression}
    ...               field_name=${ngap_nrcellidentity_field_name}
    run keyword if  not '${status}' == 'PASS'    Load and Check CMAS Log    pcap_file=${ngap_log}
    ...               filter_expression=${ngap_response_filter_expression} and ${ngap_completedarea_filter_expression}
    ...               field_xpath=${ngap_nrcellidentity_field_xpath}
    Return From Keyword If    ${no_wac}    ${wmc[0]}    ${EMPTY}
    [Return]    ${wmc[0]}    ${wac[0]}

Check Segment Size
    [Arguments]    ${bip_log}
    ...            ${expected_size}
    ...            ${serial_number}=${default_serial_number}
    ...            ${bip_command_template}=${command_template}
    ${serial_number}    Convert String format    string=${serial_number}
    ${bip_sib8_wmc_filter_expression}    catenate    nr-rrc.serialNumber == ${serial_number}
    ...                                              and ${sib8_filter_expression}
    Load BIP Log with Template Command    pcap_file=${bip_log}
    ...                                   command_template=${bip_command_template}
    ...                                   tshark_path=${tshark_path_for_746}
    Filter Packets By Expression
    ...                         filter_expression=${bip_sib8_wmc_filter_expression} and ${sib8_warningMessageSegmentNumber}==0
    ${value_wmc}    Get value from Bip Log by xpath    xpath=${sib8_warningMessageSegment_xpath}
    ${value_wac}    Get value from Bip Log    field_name=${sib8_warningAreaCoordinatesSegment}
    ${value_wmc}    Remove String    ${value_wmc[0]}    :
    ${value_wac}    Remove String    ${value_wac[0]}    :
    ${wmc_size}    Get Length    ${value_wmc}
    ${wac_size}    Get Length    ${value_wac}
    ${current_size}    Evaluate    ${wmc_size} + ${wac_size}
    Should Be Equal    ${current_size}    ${expected_size}

Check SIB8 Scheduling in SIB1
    [Arguments]    ${bip_log}    ${cellid}=${0}    ${sibperiodicity_id}=${0}
    Load BIP Log with Template Command    pcap_file=${bip_log}
    ...                                   command_template=${command_template_sib1}
    ...                                   tshark_path=${tshark_path_for_746}
    Check CMAS Log    filter_expression=${sib1_with_sib8_scheduling_filter_expression}
    ...               field_xpath=${sib8_periodicity_xpath_id}/${sib8_type_filed_xpath}
    ${cellid_value}    Run Keyword If    ${ute_env}    Convert To Hex    ${cellid}    prefix=0x    length=2
    ...                          ELSE    Set Variable    ${cellid}
    Load BIP Log with Template Command    pcap_file=${bip_log}
    ...                                   command_template=${command_template_sib1}
    ...                                   tshark_path=${tshark_path_for_746}
    Filter Packets By Expression
    ...    filter_expression=${dldata_subcellid}==${cellid_value} and ${sib1_with_sib8_scheduling_filter_expression}
    ${sib_periodicity}    Get value from Bip Log by xpath    xpath=${sib8_periodicity_xpath_id}/${sib8_periodicity_filed_xpath}
    ${sib_periodicity}    Convert To Integer    ${sib_periodicity[0]}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${coam_periodicity}    selenium_coam.get_parameter_value      dist_name=${PARAM_746_SIBPERIODICITY_1[${sibperiodicity_id}]}[dist_name]
    ...                                                           filter_param=${PARAM_746_SIBPERIODICITY_1[${sibperiodicity_id}]}[filter_param]
    ...                                                           node_index=${4}
    ...                                                           abbr=${PARAM_746_SIBPERIODICITY_1[${sibperiodicity_id}]}[p_name]
    ...                                                           timeout=${120}
    Run keyword and ignore error    selenium_coam.logout
    Run keyword and ignore error    selenium_coam.disable_virtual_display
    Should be Equal    rf${sib8_periodicity_list}[${sib_periodicity}]    ${coam_periodicity}
    [Return]    ${sib8_periodicity_list}[${sib_periodicity}]

Compare SIB8 Periodicity
    [Arguments]    ${sib8_periodicity}
    ${slot}    Get value from Bip Log    field_name=${sib8_slot}
    ${slot}    Remove Duplicates    ${slot}
    Filter Packets By Expression    filter_expression=${filter_sib8_slot}==${slot[3]}
    ${sfn}    Get value from Bip Log    field_name=${sib8_sfn}
    ${sfn}    Remove Duplicates    ${sfn}
    ${sib8_periodicity}    Convert To Integer    ${sib8_periodicity}
    ${sfn_0}    Convert To Integer    ${sfn[0]}
    ${sfn_1}    Convert To Integer    ${sfn[1]}
    ${sfn_2}    Convert To Integer    ${sfn[2]}
    ${periodicity_0}    Run Keyword If    ${sfn_0} < ${sfn_1}    Evaluate    ${sfn_1} - ${sfn_0}
    ...               ELSE    Evaluate    ${sfn_1} + 1024 - ${sfn_0}
    ${periodicity_1}    Run Keyword If    ${sfn_1} < ${sfn_2}    Evaluate    ${sfn_2} - ${sfn_1}
    ...               ELSE    Evaluate    ${sfn_2} + 1024 - ${sfn_1}
    ${periodicity}    Set Variable If    ${periodicity_0} > 64    ${periodicity_1}    ${periodicity_0}
    Should be Equal    ${sib8_periodicity}    ${periodicity}

Compare WMC and WAC in SIB8
    [Arguments]    ${bip_log}    ${filter_expression}    ${wmc}    ${wac}    ${no_wac}=${False}
    Load BIP Log with Template Command    pcap_file=${bip_log}
    ...                                   command_template=${command_template}
    ...                                   tshark_path=${tshark_path_for_746}
    Filter Packets By Expression    filter_expression=${filter_expression}
    @{segment_num}    Get value from Bip Log    field_name=${sib8_warningMessageSegmentNumber}
    Sort List    ${segment_num}
    ${segment_num}    Convert To Integer    ${segment_num}[-1]
    ${segment_num}    Evaluate    ${segment_num} + 1
    FOR  ${item}  IN RANGE  ${segment_num}
        Load BIP Log with Template Command    pcap_file=${bip_log}
        ...                                   command_template=${command_template}
        ...                                   tshark_path=${tshark_path_for_746}
        Filter Packets By Expression    filter_expression=${filter_expression} and ${sib8_warningMessageSegmentNumber}==${item}
        ${value_wmc}    Get value from Bip Log by xpath    xpath=${sib8_warningMessageSegment_xpath}
        ${value_wac}    Get value from Bip Log    field_name=${sib8_warningAreaCoordinatesSegment}
        ${status}    ${value}    Run Keyword And Ignore Error    Should Not Be Empty    ${value_wac}
        ${sib8_wmc}    Set Variable If    ${item} == 0    ${value_wmc[0]}    ${sib8_wmc}:${value_wmc[0]}
        Run Keyword If    '${status}' == 'FAIL'    Continue For Loop
        ${sib8_wac}    Set Variable If    ${item} == 0    ${value_wac[0]}    ${sib8_wac}:${value_wac[0]}
    END
    Should be Equal    ${sib8_wmc}    ${wmc}
    run keyword if  not ${no_wac}    Should be Equal    ${sib8_wac}    ${wac}

Check Complete Procedure in BIP Log
    [Arguments]    ${bip_log}
    ...            ${wmc}
    ...            ${wac}
    ...            ${serial_number}=${default_serial_number}
    ...            ${message_identifier}=${default_message_identifier}
    ...            ${repetition_period}=${default_repetition_period}
    ...            ${number_of_broadcasts_requested}=${default_number_of_broadcasts_requested}
    ...            ${last_segment_repeat_times}=${default_last_segment_repeat_times}
    ...            ${bip_command_template}=${command_template}
    ...            ${cellid}=${0}
    ...            ${no_wac}=${False}
    Log to console    ${repetition_period}
    ${serial_number}    Convert String format    string=${serial_number}
    ${bip_sib8_wmc_filter_expression}    catenate    nr-rrc.serialNumber == ${serial_number}
    ...                                              and nr-rrc.messageIdentifier == ${message_identifier}
    ...                                              and ${sib8_filter_expression}
    ${bip_sib8_datacodingscheme_filter_expression}   catenate    nr-rrc.serialNumber == ${serial_number}
    ...                                              and nr-rrc.messageIdentifier == ${message_identifier}
    ...                                              and nr-rrc.warningMessageSegmentNumber==0
    ...                                              and nr-rrc.dataCodingScheme == 03
    ...                                              and ${sib8_filter_expression}
    ${sib8_periodicity}    Check SIB8 Scheduling in SIB1    bip_log=${bip_log}    cellid=${cellid}
    Load BIP Log with Template Command    pcap_file=${bip_log}
    ...                                   command_template=${bip_command_template}
    ...                                   tshark_path=${tshark_path_for_746}
    Filter Packets By Expression    filter_expression=${sib8_filter_expression}
    ${warningMessageSegmentType}    Get value from Bip Log    field_name=${sib8_warningMessageSegmentType}
    ${last_segment_cnt}    Get Count    ${warningMessageSegmentType}    1
    ${real_number_of_lastsegment}    Evaluate    ${last_segment_repeat_times} * ${number_of_broadcasts_requested}
    run keyword if  not ${number_of_broadcasts_requested} == ${0}
    ...                   Should be Equal    ${last_segment_cnt}    ${real_number_of_lastsegment}
    Compare SIB8 Periodicity    sib8_periodicity=${sib8_periodicity}
    Check CMAS Log    filter_expression=${bip_sib8_wmc_filter_expression}
    ...               field_xpath=${sib8_warningMessageSegment_xpath}
    run keyword if  not ${no_wac}    Check CMAS Log    filter_expression=${bip_sib8_datacodingscheme_filter_expression}
    ...                                                  field_name=${sib8_warningAreaCoordinatesSegment}
    Compare WMC and WAC in SIB8    bip_log=${bip_log}
    ...                            filter_expression=${bip_sib8_wmc_filter_expression}
    ...                            wmc=${wmc}
    ...                            wac=${wac}
    ...                            no_wac=${no_wac}

Check Complete Procedure for CMAS broadcasting
    [Arguments]    ${ngap_log}
    ...            ${bip_log}
    ...            ${serial_number}=${default_serial_number}
    ...            ${message_identifier}=${default_message_identifier}
    ...            ${repetition_period}=${default_repetition_period}
    ...            ${number_of_broadcasts_requested}=${default_number_of_broadcasts_requested}
    ...            ${last_segment_repeat_times}=${default_last_segment_repeat_times}
    ...            ${bip_command_template}=${command_template}
    ...            ${cellid}=${0}
    ...            ${no_wac}=${False}
    ${wmc}    ${wac}    Check Complete Procedure in NGAP Log    ngap_log=${ngap_log}
    ...                                     serial_number=${serial_number}
    ...                                     message_identifier=${message_identifier}
    ...                                     repetition_period=${repetition_period}
    ...                                     number_of_broadcasts_requested=${number_of_broadcasts_requested}
    ...                                     no_wac=${no_wac}
    Check Complete Procedure in BIP Log    bip_log=${bip_log}
    ...                                    wmc=${wmc}
    ...                                    wac=${wac}
    ...                                    serial_number=${serial_number}
    ...                                    message_identifier=${message_identifier}
    ...                                    repetition_period=${repetition_period}
    ...                                    number_of_broadcasts_requested=${number_of_broadcasts_requested}
    ...                                    last_segment_repeat_times=${last_segment_repeat_times}
    ...                                    bip_command_template=${bip_command_template}
    ...                                    cellid=${cellid}
    ...                                    no_wac=${no_wac}
    [Return]    ${wmc}    ${wac}

Check CMAS Quantity in BIP Log
    [Arguments]    ${bip_log}    ${expected_cnt}    ${bip_command_template}=${command_template}
    Load BIP Log with Template Command    pcap_file=${bip_log}
    ...                                   command_template=${bip_command_template}
    ...                                   tshark_path=${tshark_path_for_746}
    Filter Packets By Expression    filter_expression=${sib8_filter_expression}
    ${value}    Get value from Bip Log by xpath    xpath=.//nr-rrc.serialNumber
    ${value}    Remove Duplicates    ${value}
    ${length}    Get Length    ${value}
    Should Be Equal As Integers    ${length}    ${expected_cnt}

Check Complete Cancel Procedure in NGAP Log
    [Arguments]    ${ngap_log}
    ...            ${amf}
    ...            ${serial_number}=${default_serial_number}
    ...            ${message_identifier}=${default_message_identifier}
    ...            ${warningarealist_type}=cgilist
    ${serial_number}    Convert String format    string=${serial_number}
#    ${message_identifier}    Run Keyword If    ${ute_env}    Set Variable    ${message_identifier}
#    ...                                ELSE    Convert String format    string=${message_identifier}
    ${mnc}    Strip String    ${amf}[mnc]    left    0
    ${ngap_CancelReq_filter_expression}    catenate    ${ngap_pwscancelrequest_filter_expression}
    ...                                            and ngap.SerialNumber == ${serial_number}
    ...                                            and ngap.MessageIdentifier == ${message_identifier}
    ${ngap_CancelReq_with_warningarealist_filter_expression}    catenate    ${ngap_pwscancelrequest_filter_expression}
    ...                                            and ngap.SerialNumber == ${serial_number}
    ...                                            and ngap.MessageIdentifier == ${message_identifier}
    ...                                            and ${mcc_filter} == ${amf}[mcc]
    ...                                            and ${mnc_filter} == ${mnc}
    ...                                            and ngap.tAC == ${amf}[tac]
    ...                                            and ngap.WarningAreaList == ${ngap_warningarealist}[${warningarealist_type}]
    ${ngap_CancelReq_filter_expression}    Set Variable If    '${warningarealist_type}' == 'None'
    ...    ${ngap_CancelReq_filter_expression}
    ...    ${ngap_CancelReq_with_warningarealist_filter_expression}
    Load BIP Log with Template Command    pcap_file=${ngap_log}
    ...                                   command_template=${command_template}
    ...                                   tshark_path=${tshark_path_for_746}
    Check CMAS Log    filter_expression=${ngap_CancelReq_filter_expression}
    ...               field_xpath=${ngap_initiatingMessage_procedureCode}
    Check CMAS Log    filter_expression=${f1ap_pwscancelrequest_filter_expression}
    ...               field_name=${f1ap_nrcellidentity_field_name}
    Check CMAS Log    filter_expression=${f1ap_pwscancelresponse_complete_filter_expression}
    ...               field_name=${f1ap_nrcellidentity_field_name}
    Check CMAS Log    filter_expression=${ngap_pwscancelresponse_filter_expression} and ${ngap_cancelledarealist_filter_expression}
    ...               field_name=${ngap_nrcellidentity_field_name}

Check PWS Cancel Response without Broadcaset Cancelled Area List
    [Arguments]    ${ngap_log}
    Load and Check CMAS Log    pcap_file=${ngap_log}
    ...                        filter_expression=${ngap_pwscancelresponse_filter_expression}
    ...                        field_xpath=${ngap_successfulOutcome_procedureCode}
    ${status}    Run Keyword And Return Status    Load and Check CMAS Log    pcap_file=${ngap_log}
    ...                                                                      filter_expression=${ngap_cancelledarealist_filter_expression}
    ...                                                                      field_xpath=${ngap_successfulOutcome_procedureCode}
    Should not be True    ${status}
    ${status}    Run Keyword And Return Status    Load and Check CMAS Log    pcap_file=${ngap_log}
    ...                                                                      filter_expression=${f1ap_pwscancelrequest_filter_expression}
    ...                                                                      field_xpath=${f1ap_initiatingMessage_procedureCode}
    Should not be True    ${status}

Check Spark Log for SIB8
    [Arguments]    ${wmc}
    ...            ${wac}
    ...            ${serial_number}=${default_serial_number}
    ...            ${message_identifier}=${default_message_identifier}
    ...            ${logname}=${TS_CASE_LOG_PATH}/uelog_sigspark_RRC_CONNECTED_UE0.xml
    ${wmc}    Remove String    ${wmc}    :
    ${wac}    Remove String    ${wac}    :
    spark.read_log    logname=${logname}
    ${spark_messageIdentifier}    spark.get_expected_val    msg=NR SystemInformationBlocks    expression=messageIdentifier    type=all
    ${spark_messageIdentifier}    Convert To Integer    ${spark_messageIdentifier[-1]}
    ${spark_messageIdentifier}    Convert To String    ${spark_messageIdentifier}
    ${message_identifier}    Convert To Binary    ${message_identifier}
    ${spark_serialnumber}    spark.get_expected_val    msg=NR SystemInformationBlocks    expression=serialNumber    type=all
    #${spark_serialnumber}    Convert To Integer    ${spark_serialnumber[-1]}
    #${spark_serialnumber}    Convert To String    ${spark_serialnumber}
    ${spark_serialnumber}    Remove Duplicates    ${spark_serialnumber}
    ${spark_serialnumber}    Convert To String    ${spark_serialnumber}
    ${serial_number}    Convert To Binary    ${serial_number}
    ${spark_segment_num}    spark.get_expected_val    msg=NR SystemInformationBlocks    expression=warningMessageSegmentNumber    type=all
    ${first_segment}    Set Variable    ${spark_segment_num[0]}
    ${first_segment}    Convert To Integer    ${first_segment}
    Sort List    ${spark_segment_num}
    #${spark_segment_num}    Convert To Integer    @{spark_segment_num}[-1]
    #${spark_segment_num}    Evaluate    ${spark_segment_num} + 1
    ${spark_segment}    spark.get_expected_val    msg=NR SystemInformationBlocks    expression=warningMessageSegment    type=all
    ${spark_segment}    Remove Duplicates    ${spark_segment}
    ${spark_segment_num}    Get Length    ${spark_segment}
    ${spark_wmc}    Set Variable
    ${spark_area}    spark.get_expected_val    msg=NR SystemInformationBlocks    expression=warningAreaCoordinatesSegment    type=all
    ${spark_area}    Remove Duplicates    ${spark_area}
    ${spark_area_num}    Get Length    ${spark_area}
    ${spark_wac}    Set Variable
    #FOR  ${item}  IN RANGE  ${spark_segment_num}
    #    ${segment}    Remove String    ${spark_segment[${item}]}    \n
    #    ${segment}    Remove String    ${segment}    ${SPACE}
    #    ${spark_wmc}    Set Variable    ${spark_wmc}${segment}
    #END
    FOR  ${item}  IN RANGE  ${spark_segment_num}
        ${segment}    Remove String    ${spark_segment[${item}-${first_segment}]}    \n
        ${segment}    Remove String    ${segment}    ${SPACE}
        ${spark_wmc}    Set Variable    ${spark_wmc}${segment}
    END
    FOR  ${item}  IN RANGE  ${spark_area_num}
        ${area}    Remove String    ${spark_area[${item}-${first_segment}]}    \n
        ${area}    Remove String    ${area}    ${SPACE}
        ${spark_wac}    Set Variable    ${spark_wac}${area}
    END
    ${spark_wmc}    Convert To Lower Case    ${spark_wmc}
    ${spark_wac}    Convert To Lower Case    ${spark_wac}
    #Should be Equal    ${spark_wmc}    ${wmc}
    #Should be Equal    ${spark_wac}    ${wac}
    Should Contain    ${spark_wmc}    ${wmc}
    Should Contain    ${spark_wac}    ${wac}
    #Should be Equal    ${spark_messageIdentifier}    ${message_identifier}
    Should Contain    ${spark_serialnumber}    ${serial_number}

Prepare for Check SIB in MTK OTA Log
    msg_mtk.Setup    pyro_ip=${tl.ues[0].ssh_connection_details.addr}    pyro_port=${tl.ues[0].server_port}
    msg_mtk.Create Message Flow Alias    flow_alias=MTK_OTA_MESSAGE    message_type=ota_text
    msg_mtk.Create Message Flow Alias    flow_alias=MTK_OTA_JSON    message_type=ota_json

Prepare for Check SIB in Sigspark Log
    [Arguments]    ${ue_index}=${0}
    spark.start_log    ue_alias=UE_${ue_index}
    Sleep    10s

Prepare for Check SIB
    [Arguments]    ${ue_type}    ${ue_index}=${0}
    Run Keyword If    '${ue_type}' == 'mtk'    Prepare for Check SIB in MTK OTA Log
    ...    ELSE    Prepare for Check SIB in Sigspark Log    ue_index=${ue_index}

Check MTK Log for SIB8
    [Arguments]    ${bip_log}
    ...            ${serial_number}=${default_serial_number}
    ...            ${message_identifier}=${default_message_identifier}
    ${serial_number}    Convert String format    string=${serial_number}
    ${expected_string}    Create List     SIB8
    msg_mtk.Expect Messages in Flow    awaited_messages=${expected_string}    flow_alias=MTK_OTA_MESSAGE
    ${serial_id}    Set Variable    "nr-rrc.messageIdentifier": "${message_identifier}"[\\w\\W]+"nr-rrc.serialNumber": "${serial_number}"
    Load BIP Log with Template Command    pcap_file=${bip_log}
    ...                                   command_template=${command_template}
    ...                                   tshark_path=${tshark_path_for_746}
    Filter Packets By Expression    filter_expression=${sib8_filter_expression}
    @{segment_num}    Get value from Bip Log    field_name=${sib8_warningMessageSegmentNumber}
    Sort List    ${segment_num}
    ${segment_num}    Convert To Integer    ${segment_num}[-1]
    ${segment_num_1}    Evaluate    ${segment_num} + 1
    ${awaited_messages}    Create List
    FOR  ${item}  IN RANGE  ${segment_num_1}
        Filter Packets By Expression
        ...                    filter_expression=${sib8_filter_expression} and ${sib8_warningMessageSegmentNumber}==${item}
        ${value_wmc}    Get value from Bip Log by xpath    xpath=${sib8_warningMessageSegment_xpath}
        ${value_wac}    Get value from Bip Log    field_name=${sib8_warningAreaCoordinatesSegment}
        ${expected_string}    Set Variable    ${serial_id}[\\w\\W]+"nr-rrc.warningMessageSegment": "${value_wmc[0]}"
        ${status}    ${value}    Run Keyword And Ignore Error    Should Not Be Empty    ${value_wac}
        Run Keyword If    '${status}' == 'FAIL'    Continue For Loop
        ${expected_string}    Set Variable    ${expected_string}[\\w\\W]+"nr-rrc.warningAreaCoordinatesSegment": "${value_wac[0]}"
        Append to list    ${awaited_messages}    ${expected_string}
    END
    Append to list    ${awaited_messages}    ${expected_string}
    msg_mtk.Expect Messages in Flow    awaited_messages=${awaited_messages}    flow_alias=MTK_OTA_JSON

Check UE Log for SIB8
    [Arguments]    ${ue_type}
    ...            ${bip_log}
    ...            ${wmc}
    ...            ${wac}
    ...            ${ue_index}=${0}
    ...            ${serial_number}=${default_serial_number}
    ...            ${message_identifier}=${default_message_identifier}
    ...            ${logname}=${TS_CASE_LOG_PATH}/uelog_sigspark_RRC_CONNECTED_UE${ue_index}.xml
    Run Keyword If    '${ue_type}' == 'mtk'    Check MTK Log for SIB8    bip_log=${bip_log}
    ...    ELSE    Check Spark Log for SIB8    wmc=${wmc}    wac=${wac}    logname=${logname}
    ...                                        serial_number=${serial_number}    message_identifier=${message_identifier}

Lock BBMOD to cause L1_L2 pool Failure
    coam.lock
    ...        dist_name=MRBTS-${mr_bts_id}/EQM-1/APEQM-1/CABINET-1/BBMOD-1
    ...        timeout=60
    ...        connection=GNB_OAM

Unlock BBMOD to Recover ENV
    coam.unlock
    ...        dist_name=MRBTS-${mr_bts_id}/EQM-1/APEQM-1/CABINET-1/BBMOD-1
    ...        timeout=60
    ...        connection=GNB_OAM
    COAM Wait for gnb ready and cell setup    gnb_type='SA'
    Connect to Common Unit Master

UE attach and Check Ciphering algorithm
    [Arguments]    ${ue_type}    ${cipheringAlgorithm}    ${ue_index}=${0}    ${power_reset}=False
    ${ngap_name}    Start NGAP and Bip Logs Capture
    Try huawei sigspark attach    ue_type=${ue_type}    ue_index=${ue_index}    power_reset=${power_reset}
    ${ngap_log}    ${bip_log}    Stop NGAP and Bip Logs Capture and Download Logs    ngap_name=${ngap_name}
    Load BIP Log with Template Command    pcap_file=${ngap_log}
    ...                                   command_template=${command_template}
    Check expression in Bip Log by Name    filter_expression=${cipheringAlgorithm_field_name} == ${cipheringAlgorithm}
    ...                                    field_name=${cipheringAlgorithm_field_name}

Make EMC call on samsung UE
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=911
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   3s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:${phone_number}
    ...    connection=cpc_${ue_index}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 538 1959
    ...    connection=cpc_${ue_index}
    csn.disconnect      connection=cpc_${ue_index}

hang up EMC call on samsung UE
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   3s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Samsung S21 WA to click time cancel
    csn.send_command    command=adb -s ${serial_number} shell input tap 285 37    connection=cpc_${ue_index}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 538 1959
    ...    connection=cpc_${ue_index}
    sleep    5s
    csn.disconnect      connection=cpc_${ue_index}

EMC call and capture log
    [Arguments]    ${ue_index}=${0}    #${serial_number}=${tl.ues[${ue_index}].serial_number}
    5GC000746 Case Reconnect
    Start To Capture Wireshark Background    filename=emeccall.pcap    connection=ASIK Master    #${ngap_connection}
    Make EMC call on samsung UE    ue_index=${ue_index}
    Sleep    10s
    hang up EMC call on samsung UE    ue_index=${ue_index}
    Stop and download Wireshark file    filename=emeccall.pcap
    ...                                 connection=ASIK Master    #${ngap_connection}
    ...                                 ute_log_path=${OUTPUT_DIR}
    [Return]    ${OUTPUT_DIR}/emeccall.pcap

Disable Enable sim card on samsung UE
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${enable}=1
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   3s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Open SIM card manager#####
    csn.send_command
    ...    command=adb -s ${serial_number} shell am start -n com.samsung.android.app.telephonyui/.netsettings.ui.simcardmanager.SimCardMgrActivity
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Get SIM card status#####
    csn.send_command    command=adb -s ${serial_number} shell settings get global sim1_onoff_state
    ...                              connection=cpc_${ue_index}
    sleep   2s
    ${output}   csn.read_output    connection=cpc_${ue_index}
    ${output}   Strip String    ${output}   characters='\r\n'
    #####Disable or Enable SIM card#####
    ${tl_name}   run keyword if    ${output} != ${enable}
    ...                            Disable Enable sim card in SIM Manager on samsung UE    enable=${enable}    ue_index=${ue_index}
    csn.disconnect      connection=cpc_${ue_index}

Disable Enable sim card in SIM Manager on samsung UE
    [Arguments]    ${enable}    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.send_command    command=adb -s ${serial_number} shell input tap 918 565
    ...                            connection=cpc_${ue_index}
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 663 2035
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Get SIM card status#####
    csn.send_command    command=adb -s ${serial_number} shell settings get global sim1_onoff_state
    ...                              connection=cpc_${ue_index}
    sleep   2s
    ${output}   csn.read_output    connection=cpc_${ue_index}
    ${output}   Strip String    ${output}   characters='\r\n'
    Should be Equal    ${output}    ${enable}

Check EMC call in ngap log
    [Arguments]    ${emc_log}
    Load BIP Log with Template Command    pcap_file=${emc_log}
    ...                                   command_template=${command_ngap_template}
    Check expression in Bip Log by Name    filter_expression=${ngap_emec_register_filter_expression}
    ...                                    field_name=${ngap_emc_register}
    Check expression in Bip Log by Name    filter_expression=${ngap_pdusessioncomplete_filter_expression}
    ...                                    field_name=${ngap_pdu_messagetype}
    Check expression in Bip Log by Name    filter_expression=${ngap_pdurelease_filter_expression}
    ...                                    field_name=${ngap_emc_release}
    Check expression in Bip Log by Name    filter_expression=${ngap_pdureleasecomplete_filter_expression}
    ...                                    field_name=${ngap_pdu_messagetype}
