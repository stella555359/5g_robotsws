*** Settings ***
Documentation     author: yifan hu
...                 contact: yifan.hu@nokia-sbell.com
...                 squad group: SG_03
...                 feature : 5GC000784

Resource          ../../5GC000784-A/Resources/5GC000784_common_keyword.robot

*** Variables ***
${command_template_Y}       {tshark_path} -r {pcap_file} -Y  \"ngap\"  -T pdml
${command_template_Y_f1ap}       {tshark_path} -r {pcap_file} -Y  \"f1ap\"  -T pdml
${command_template_Y_s1ap}       {tshark_path} -r {pcap_file} -Y  \"s1ap\"  -T pdml
${command_template_Y_xnap}       {tshark_path} -r {pcap_file} -Y  \"ngap||xnap\"  -T pdml
${att_api_port}         ${tl.attenuator[0].port}
${max_attenuation_value}     ${127}
${vendor}               ${tl.attenuator[0].vendor}
${target_cellID_344}    378
${target_cellID_341}    61
${target_cellID_242}    322


*** Keywords ***
##### analyze log #####
Check intra-F intra-gNB intra-PLMN HO with EC ongoing
    [Arguments]    ${logname}
    log to console    check successfull HO
    run keyword if    '${gnb_instance}'=='${gnb_id[2]}'
    ...    Check wireshark log for intra-F intra-gNB HO    logname=${logname}    target_cellID=${target_cellID_341}
    ...    ELSE IF    '${gnb_instance}'=='${gnb_id[1]}'
    ...    Check wireshark log for intra-F intra-gNB HO    logname=${logname}    target_cellID=${target_cellID_242}
    ...    ELSE
    ...    Check wireshark log for intra-F intra-gNB HO    logname=${logname}    target_cellID=${target_cellID_344}
    log to console    check EC ongoing
    Check wireshark log for EC ongoing    logname=${logname}

Check wireshark log for intra-F intra-gNB HO
    [Arguments]    ${logname}    ${target_cellID}
    Check wireshark log for VoNR    logname=${logname}
    ...    command_template=${command_template_Y_f1ap}
    ...    message_filter=f1ap.procedureCode == 7 and nr-rrc.measResultNeighCellListNR == 1
    ...    xpath_filter=.//nr-rrc.MeasResultNR_element/nr-rrc.physCellId    expect_value=${target_cellID}

Check inter-F inter-gNB intra-PLMN HO with EC ongoing
    [Arguments]    ${logname1}    ${logname2}
    log to console    check inter gnb HO procedure
    Check wireshark log for inter gnb HO    logname1=${logname1}    logname2=${logname2}
    log to console    check EC ongoing
    Check wireshark log for EC ongoing    logname=${logname1}
    Check wireshark log for EC not release unusual    logname=${logname2}

Check wireshark log for inter gnb HO
    [Arguments]    ${logname1}    ${logname2}    #${attribute_name}=show
    ...    ${command_template}=${command_template_Y_xnap}
    ...    ${message_filter1}=ngap.procedureCode == 14 and ngap.fiveQI == 5
    ...    ${message_filter2}=ngap.procedureCode == 29 and ngap.fiveQI == 7
    ...    ${message_filter3}=ngap.procedureCode == 29 and ngap.fiveQI == 5
    ...    ${message_filter_service}=xnap.procedureCode == 0 and xnap.XnAP_PDU == 1
    ...    ${message_filter_target}=ngap.procedureCode == 25 and ngap.NGAP_PDU == 1
    log to console    check service gnb HO procedure
    ${all_packets1}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname1}
    ...    command_template=${command_template}
    ${filter_expression1}=    Catenate    ${message_filter1}
    ${filter_expression2}=    Catenate    ${message_filter2}
    ${filter_expression3}=    Catenate    ${message_filter3}
    ${filter_expression_service}=    Catenate    ${message_filter_service}
    ${filtered_packets1}=    parser.filter_packets_by_expression
    ...    filter_expression=${filter_expression1}
    ${filtered_packets2}=    parser.filter_packets_by_expression
    ...    filter_expression=${filter_expression2}
    ${filtered_packets3}=    parser.filter_packets_by_expression
    ...    filter_expression=${filter_expression3}
    ${filtered_packets_service}=    parser.filter_packets_by_expression
    ...    filter_expression=${filter_expression_service}
    ${filtered_value_pdu}    Create List
    FOR    ${index}    IN    1    2    3
        ${filtered_value}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets${index}}
    ...    xpath=.//ngap.pDUSessionID
        append to list    ${filtered_value_pdu}    ${filtered_value[0]}
    END
    ${filtered_value_qosflow}    Create List
    FOR    ${index}    IN    1    2    3
        ${filtered_value}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets${index}}
    ...    xpath=.//ngap.qosFlowIdentifier
        append to list    ${filtered_value_qosflow}    ${filtered_value[0]}
    END
    ${filtered_value_qosflow_service}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets_service}
    ...    xpath=.//xnap.qosFlowIdentifier
    ${filtered_value_pdu_service}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets_service}
    ...    xpath=.//xnap.pduSessionId
    FOR    ${index}    IN RANGE    ${3}
        Should be equal    ${filtered_value_pdu_service[${index}]}    ${filtered_value_pdu[${index}]}
        Should be equal    ${filtered_value_qosflow_service[${index}]}    ${filtered_value_qosflow[${index}]}
    END
    log to console    check target gnb HO procedure
    ${all_packets2}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname2}
    ...    command_template=${command_template}
    ${filter_expression_target}=    Catenate    ${message_filter_target}
    ${filtered_packets_target}=    parser.filter_packets_by_expression
    ...    filter_expression=${filter_expression_target}
    ${filtered_value_pdu_target}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets_target}
    ...    xpath=.//ngap.pDUSessionID
    FOR    ${index}    IN RANGE    ${3}
        Should be equal    ${filtered_value_pdu_service[${index}]}    ${filtered_value_pdu_target[${index}]}
    END

Check inter-RAT HO with EC ongoing
    [Arguments]    ${logname1}    ${logname2}
    log to console    check inter RAT HO procedure
    Check wireshark log for inter RAT HO    logname1=${logname1}    logname2=${logname2}
    log to console    check EC ongoing
    Check wireshark log for EC setup    logname=${logname1}
    Check wireshark log for EC 5QI 5    logname=${logname1}
    Check wireshark log for EC 5QI 1    logname=${logname1}
    Check wireshark log for EC not release unusual    logname=${logname2}

Check wireshark log for inter RAT HO
    [Arguments]    ${logname1}    ${logname2}
#    ...    ${command_template1}=${command_template_Y}
    ...    ${command_template2}=${command_template_Y_s1ap}
#    ...    ${message_filter_1}=(ngap.fiveQI == 5 and ngap.priorityLevelARP == 1)
#    ...    ${message_filter_2}=(ngap.fiveQI == 1 and ngap.priorityLevelARP == 1)
#    ...    ${message_filter_service}=(ngap.procedureCode == 12 and ngap.NGAP_PDU == 1)
#    ...    ${message_filter_target_req}=(s1ap.procedureCode == 1 and s1ap.S1AP_PDU == 0)
#    ...    ${message_filter_target_Noti}=(s1ap.procedureCode == 2)
#    ...    ${message_filter_target_tau}=(s1ap.procedureCode == 11 and nas-eps.nas_msg_emm_type == 73)
    log to console    check service gnb HO procedure
    Set Test Variable     ${message_filter_1}    (ngap.fiveQI == 5 and ngap.priorityLevelARP == 1)
    Set Test Variable     ${message_filter_2}    (ngap.fiveQI == 1 and ngap.priorityLevelARP == 1)
    parser.load_pcap_file    pcap_file=${epc_log_path}${logname1}
    ${filtered_value_pdu}    Create List
    parser.filter_packets_by_expression    filter_expression=${message_filter_1}
    ${filtered_value_pdu_tmp}=    parser.get_field_value_by_xpath
    ...    xpath=.//ngap.pDUSessionID
    parser.filter_packets_by_expression    filter_expression=(ngap.procedureCode == 12 and ngap.NGAP_PDU == 1)
    ${filtered_value_pdu_service}=    parser.get_field_value_by_xpath
    ...    xpath=.//ngap.pDUSessionID
    Should contain    ${filtered_value_pdu_service}    ${filtered_value_pdu_tmp[0]}

    ${filtered_value_qosflow}    Create List
    FOR    ${index}    IN RANGE    ${2}
        ${tmp}    Evaluate    ${index}+1
        parser.filter_packets_by_expression    filter_expression=${message_filter_${tmp}}
        ${filtered_value_qosflow_tmp}=    parser.get_field_value_by_xpath    xpath=.//ngap.qosFlowIdentifier
        append to list    ${filtered_value_qosflow}    ${filtered_value_qosflow_tmp[0]}
    END
    Sort list     ${filtered_value_qosflow}
    parser.filter_packets_by_expression    filter_expression=(ngap.procedureCode == 12 and ngap.NGAP_PDU == 1)
    ${filtered_value_qosflow_service}=    parser.get_field_value_by_xpath
    ...    xpath=.//ngap.qosFlowIdentifier
    Should contain    ${filtered_value_qosflow_service}    ${filtered_value_qosflow[0]}
    Should contain    ${filtered_value_qosflow_service}    ${filtered_value_qosflow[1]}

    log to console    check target enb HO procedure
    ${all_packets2}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname2}
    ...    command_template=${command_template2}
    ${filtered_packets_target_req}=    parser.filter_packets_by_expression
    ...    filter_expression=(s1ap.procedureCode == 1 and s1ap.S1AP_PDU == 0)
    ${filtered_value_target_qci}=    parser.get_field_value_by_xpath    xpath=.//s1ap.qCI
    Sort list     ${filtered_value_target_qci}
    ${qci}    Create List    1    5
    Should contain    ${filtered_value_target_qci}    ${qci[0]}
    Should contain    ${filtered_value_target_qci}    ${qci[1]}

    ${filtered_packets_target_ack}=    parser.filter_packets_by_expression
    ...    filter_expression=(s1ap.procedureCode == 2)
    ${filtered_value_target_ack}=    parser.get_field_value_by_xpath    xpath=.//s1ap.procedureCode
     Should be equal    ${filtered_value_target_ack[0]}    2
    ${filtered_packets_target_tau}=    parser.filter_packets_by_expression
    ...    filter_expression=(s1ap.procedureCode == 11 and nas-eps.nas_msg_emm_type == 73)
    ${filtered_value_target_tau}=    parser.get_field_value_by_xpath
    ...    xpath=.//nas-eps.emm.tai_tac
    Should be equal    ${filtered_value_target_tau[0]}    20201



Check wireshark log for inter RAT HO_5QI5_first
    [Arguments]    ${logname1}    ${logname2}
#    ...    ${command_template1}=${command_template_Y}
    ...    ${command_template2}=${command_template_Y_s1ap}
#    ...    ${message_filter1}=ngap.fiveQI == 5 and ngap.priorityLevelARP == 5
#    ...    ${message_filter2}=ngap.fiveQI == 7 and ngap.priorityLevelARP == 7
#    ...    ${message_filter3}=ngap.procedureCode == 29 and ngap.fiveQI == 5
#    ...    ${message_filter4}=ngap.procedureCode == 26 and ngap.fiveQI == 1
#    ...    ${message_filter_service}=ngap.procedureCode == 12 and ngap.NGAP_PDU == 1
#    ...    ${message_filter_target_req}=s1ap.procedureCode == 1 and s1ap.S1AP_PDU == 0
#    ...    ${message_filter_target_ack}=s1ap.procedureCode == 1 and s1ap.S1AP_PDU == 1
#    ...    ${message_filter_target_tau}=s1ap.procedureCode == 11 and nas-eps.nas_msg_emm_type == 73
    log to console    check service gnb HO procedure
    parser.load_pcap_file    pcap_file=${epc_log_path}${logname1}
    ${filtered_value_pdu}    Create List
    FOR    ${index}    IN RANGE    ${3}
        ${tmp}    Evaluate    ${index}+1
        parser.filter_packets_by_expression    filter_expression=${message_filter_${tmp}}
        ${filtered_value_pdu_tmp}=    parser.get_field_value_by_xpath
    ...    xpath=.//ngap.pDUSessionID
        append to list    ${filtered_value_pdu}    ${filtered_value_pdu_tmp[0]}
    END

    parser.filter_packets_by_expression    filter_expression=ngap.procedureCode == 12 and ngap.NGAP_PDU == 1
    ${filtered_value_pdu_service}=    parser.get_field_value_by_xpath
    ...    xpath=.//ngap.pDUSessionID
    FOR    ${index}    IN RANGE    ${3}
        Should be equal    ${filtered_value_pdu[${index}]}    ${filtered_value_pdu_service[${index}]}
    END

    ${filtered_value_qosflow}    Create List
    FOR    ${index}    IN RANGE    ${4}
        ${tmp}    Evaluate    ${index}+1
        parser.filter_packets_by_expression    filter_expression=${message_filter_${tmp}}
        ${filtered_value_qosflow_tmp}=    parser.get_field_value_by_xpath    xpath=.//ngap.qosFlowIdentifier
        append to list    ${filtered_value_qosflow}    ${filtered_value_qosflow_tmp[0]}
    END

    parser.filter_packets_by_expression    filter_expression=ngap.procedureCode == 12 and ngap.NGAP_PDU == 1
    ${filtered_value_qosflow_service}=    parser.get_field_value_by_xpath
    ...    xpath=.//ngap.qosFlowIdentifier

    FOR    ${index}    IN RANGE    ${4}
        ${tmp}    Evaluate    ${index}+1
        Should be equal    ${filtered_value_qosflow[${index}]}    ${filtered_value_qosflow_service[${index}]}
    END

    log to console    check target enb HO procedure
    ${all_packets2}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname2}
    ...    command_template=${command_template2}
    ${filtered_packets_target_req}=    parser.filter_packets_by_expression
    ...    filter_expression=s1ap.procedureCode == 1 and s1ap.S1AP_PDU == 0
    ${filtered_value_target_qci}=    parser.get_field_value_by_xpath    xpath=.//s1ap.qCI
    Sort list     ${filtered_value_target_qci}
    ${qci}    Create List    1    5    5    7
    Should be equal    ${filtered_value_target_qci}    ${qci}

    ${filtered_packets_target_ack}=    parser.filter_packets_by_expression
    ...    filter_expression=s1ap.procedureCode == 2
    ${filtered_value_target_ack}=    parser.get_field_value_by_xpath    xpath=.//s1ap.procedureCode
     Should be equal    ${filtered_value_target_ack[0]}    2
    ${filtered_packets_target_tau}=    parser.filter_packets_by_expression
    ...    filter_expression=s1ap.procedureCode == 11 and nas-eps.nas_msg_emm_type == 73
    ${filtered_value_target_tau}=    parser.get_field_value_by_xpath
    ...    xpath=.//nas-eps.emm.tai_tac
    Should be equal    ${filtered_value_target_tau[0]}    20000

Set APN point for sanmsung
    [Arguments]    ${apn_name}    ${ui_version}    ${ue_index}=${0}    ${ue_type}=${ue_type}
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
    Android UE SwitchApn    ue_index=${ue_index}    apn_name=${apn_name}    ui_version=${ui_version}
    [Teardown]    run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}
