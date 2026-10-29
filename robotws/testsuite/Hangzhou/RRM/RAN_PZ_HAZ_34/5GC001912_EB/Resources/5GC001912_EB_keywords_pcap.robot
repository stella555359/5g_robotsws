*** Settings ***
Documentation
...   This is for 1912-EB TA keywords related to pcap analysis
...   author: Cui Lingxue
...   contact: lingxue.cui@nokia-sbell.com
...   squad group: MMW_SG1

Library    taf.analyzer.pcap    WITH NAME    pcap

*** Keywords ***
Convert pcap to pdml
    [Arguments]    ${log_path_pcap}=${CPIF_LOG}    ${filter}=f1ap||x2ap||e1ap
    ${pdml_template}    set variable    {tshark_path} -r {input_file} -Y \"${filter}\" -T pdml > {output_file}
    pcap.load_pcap_file    pcap_file=${log_path_pcap}    command_template=${pdml_template}
    ${log_path_pdml}    replace_string    string=${log_path_pcap}    search_for=pcap    replace_with=pdml
    [Return]    ${log_path_pdml}

Get RSRP in measurment report in cpif log
    [Arguments]    ${scf_meas_config}    ${meas_id}    ${is_srb3}=${True}    ${log_path_pcap}=${CPIF_LOG}
    ${pdml_list}    Load pcap file with filter    log_path_pcap=${log_path_pcap}
    ${filter}    set variable if    ${is_srb3}
    ...    (f1ap.procedureCode == 13) && (f1ap.F1AP_PDU == 0) && (nr-rrc.measId == ${meas_id})
    ...    (x2ap.procedureCode == 35) && (x2ap.X2AP_PDU == 0) && (nr-rrc.measId == ${meas_id})
    ${pkt_measReport}    pcap.filter_packets_by_expression    filter_expression=${filter}
    ${rsrp}    pcap.get_field_value_by_xpath    pdml_list=${pkt_measReport}
    ...    xpath=.//nr-rrc.measResultServingMOList//*//nr-rrc.resultsSSB_Cell_element/nr-rrc.rsrp
    ...    attribute_name=show
    [Return]    ${rsrp[0]}

Verify A2 measurement report in cpif log
    [Arguments]    ${scf_meas_config}    ${is_srb3}=${True}    ${log_path_pcap}=${CPIF_LOG}
    ${scf_meas_config}    Convert scf parameters to dict type    scf_parameter_list=${scf_meas_config}
    ${a2_rsrp}    Get RSRP in measurment report in CPIF log    scf_meas_config=${scf_meas_config}    meas_id=${A2_MEAS_ID}
    ...    is_srb3=${is_srb3}    log_path_pcap=${log_path_pcap}
    should be true    ${a2_rsrp} < ${scf_meas_config['a2ThresholdhoSsbRsrp']}

Verify A1 measurement report in cpif log
    [Arguments]    ${scf_meas_config}    ${is_srb3}=${True}    ${log_path_pcap}=${CPIF_LOG}
    ${scf_meas_config}    Convert scf parameters to dict type    scf_parameter_list=${scf_meas_config}
    ${a1_rsrp}    Get RSRP in measurment report in CPIF log    scf_meas_config=${scf_meas_config}    meas_id=${A1_MEAS_ID}
    ...    is_srb3=${is_srb3}    log_path_pcap=${log_path_pcap}
    should be true    ${a1_rsrp} > ${scf_meas_config['a1ThresholdhoSsbRsrp']}

Verify a2 measurement config in cpif log
    [Arguments]    ${a2_meas_config}    ${log_path_pcap}=${CPIF_LOG}
    ${a2_meas_config}    Convert scf parameters to dict type    scf_parameter_list=${a2_meas_config}
    ${pdml_list}    Load pcap file with filter    log_path_pcap=${log_path_pcap}

    ${sgnbAddAck}    pcap.filter_packets_by_expression
    ...    filter_expression=(x2ap.procedureCode == 27) && (x2ap.X2AP_PDU == 1)
    ${ssbFreq}    pcap.get_field_value_by_xpath    pdml_list=${sgnbAddAck}
    ...    xpath=.//nr-rrc.measObjectNR_element/nr-rrc.ssbFrequency
    ...    attribute_name=show
    ${a2MeasType}    pcap.get_field_value_by_xpath    pdml_list=${sgnbAddAck}
    ...    xpath=.//nr-rrc.eventA2_element/nr-rrc.a2_Threshold
    ...    attribute_name=showname
    ${rsrp}    pcap.get_field_value_by_xpath    pdml_list=${sgnbAddAck}
    ...    xpath=.//nr-rrc.eventA2_element/nr-rrc.a2_Threshold/nr-rrc.rsrp
    ...    attribute_name=show
    ${hysteresis}    pcap.get_field_value_by_xpath    pdml_list=${sgnbAddAck}
    ...    xpath=.//nr-rrc.eventA2_element/nr-rrc.hysteresis
    ...    attribute_name=show
    ${timeToTrigger}    pcap.get_field_value_by_xpath    pdml_list=${sgnbAddAck}
    ...    xpath=.//nr-rrc.eventA2_element/nr-rrc.timeToTrigger
    ...    attribute_name=showname

    run keyword and continue on failure    should be equal as strings    ${a2_meas_config['a2MeashoEnabled']}    ${a2MeasType[0].split()[1]}
    run keyword and continue on failure    should be equal as strings    ${a2_meas_config['a2ThresholdhoSsbRsrp']}    ${rsrp[0]}
    run keyword and continue on failure    should be equal as strings    ${a2_meas_config['a2HysteresishoSsbRsrp']}    ${hysteresis[0]}
    should be equal as strings    ${a2_meas_config['a2TimeToTriggerhoSsbRsrp']}    ${timeToTrigger[0].split()[1]}

Verify a1 measurement config in cpif log
    [Arguments]    ${a1_meas_config}    ${is_srb3}=${True}    ${log_path_pcap}=${CPIF_LOG}
    ${a1_meas_config}    Convert scf parameters to dict type    scf_parameter_list=${a1_meas_config}
    ${pdml_list}    Load pcap file with filter    log_path_pcap=${log_path_pcap}
    ${filter}    set variable if    ${is_srb3}
    ...    (f1ap.procedureCode == 12) && (f1ap.F1AP_PDU == 0) && (nr-rrc.eventId == 0)
    ...    (x2ap.procedureCode == 30) && (x2ap.X2AP_PDU == 0) && (nr-rrc.eventId == 0)
    ${RrcReconf}    pcap.filter_packets_by_expression
    ...    filter_expression=${filter}
    ${a1MeasType}    pcap.get_field_value_by_xpath    pdml_list=${RrcReconf}
    ...    xpath=.//nr-rrc.eventA1_element/nr-rrc.a1_Threshold
    ...    attribute_name=showname
    ${rsrp}    pcap.get_field_value_by_xpath    pdml_list=${RrcReconf}
    ...    xpath=.//nr-rrc.eventA1_element/nr-rrc.a1_Threshold/nr-rrc.rsrp
    ...    attribute_name=show
    ${hysteresis}    pcap.get_field_value_by_xpath    pdml_list=${RrcReconf}
    ...    xpath=.//nr-rrc.eventA1_element/nr-rrc.hysteresis
    ...    attribute_name=show
    ${timeToTrigger}    pcap.get_field_value_by_xpath    pdml_list=${RrcReconf}
    ...    xpath=.//nr-rrc.eventA1_element/nr-rrc.timeToTrigger
    ...    attribute_name=showname

    run keyword and continue on failure    should be equal as strings    ${a1_meas_config['a1MeashoEnabled']}    ${a1MeasType[0].split()[1]}
    run keyword and continue on failure    should be equal as strings    ${a1_meas_config['a1ThresholdhoSsbRsrp']}    ${rsrp[0]}
    run keyword and continue on failure    should be equal as strings    ${a1_meas_config['a1HysteresishoSsbRsrp']}    ${hysteresis[0]}
    should be equal as strings    ${a1_meas_config['a1TimeToTriggerhoSsbRsrp']}    ${timeToTrigger[0].split()[1]}

Verify a3 measurement config in cpif log
    [Arguments]    ${a3_meas_config}    ${is_srb3}=${True}    ${log_path_pcap}=${CPIF_LOG}
    ${a3_meas_config}    Convert scf parameters to dict type    scf_parameter_list=${a3_meas_config}
    ${pdml_list}    Load pcap file with filter    log_path_pcap=${log_path_pcap}
    ${filter}    set variable if    ${is_srb3}
    ...    (f1ap.procedureCode == 12) && (f1ap.F1AP_PDU == 0) && (nr-rrc.eventId == 2)
    ...    (x2ap.procedureCode == 30) && (x2ap.X2AP_PDU == 0) && (nr-rrc.eventId == 2)
    ${RrcReconf}    pcap.filter_packets_by_expression
    ...    filter_expression=${filter}
    ${a3MeasType}    pcap.get_field_value_by_xpath    pdml_list=${RrcReconf}
    ...    xpath=.//nr-rrc.eventA3_element/nr-rrc.a3_Offset
    ...    attribute_name=showname
    ${rsrp}    pcap.get_field_value_by_xpath    pdml_list=${RrcReconf}
    ...    xpath=.//nr-rrc.eventA3_element/nr-rrc.a3_Offset/nr-rrc.rsrp
    ...    attribute_name=show
    ${hysteresis}    pcap.get_field_value_by_xpath    pdml_list=${RrcReconf}
    ...    xpath=.//nr-rrc.eventA3_element/nr-rrc.hysteresis
    ...    attribute_name=show
    ${timeToTrigger}    pcap.get_field_value_by_xpath    pdml_list=${RrcReconf}
    ...    xpath=.//nr-rrc.eventA3_element/nr-rrc.timeToTrigger
    ...    attribute_name=showname

    run keyword and continue on failure    should be equal as strings    ${a3_meas_config['a3MeasEnabled']}    ${a3MeasType[0].split()[1]}
    run keyword and continue on failure    should be equal as strings    ${a3_meas_config['a3OffsetSsbRsrp']}    ${rsrp[0]}
    run keyword and continue on failure    should be equal as strings    ${a3_meas_config['a3HysteresisSsbRsrp']}    ${hysteresis[0]}
    should be equal as strings    ${a3_meas_config['a3TimeToTriggerSsbRsrp']}    ${timeToTrigger[0].split()[1]}

Verify measurement gap in cpif log
    [Arguments]    ${meas_gap}    ${is_srb3}=${True}    ${log_path_pcap}=${CPIF_LOG}
    ${meas_gap}    Convert scf parameters to dict type    scf_parameter_list=${meas_gap}
    ${pdml_list}    Load pcap file with filter    log_path_pcap=${log_path_pcap}
    ${filter}    set variable if    ${is_srb3}
    ...    (f1ap.procedureCode == 12) && (f1ap.F1AP_PDU == 0) && (nr-rrc.eventId == 2)
    ...    (x2ap.procedureCode == 30) && (x2ap.X2AP_PDU == 0) && (nr-rrc.eventId == 2)
    ${RrcReconf}    pcap.filter_packets_by_expression
    ...    filter_expression=${filter}
    ${mgta}    pcap.get_field_value_by_xpath    pdml_list=${RrcReconf}
    ...    xpath=.//nr-rrc.mgta
    ...    attribute_name=showname
    ${gapOffset}    pcap.get_field_value_by_xpath    pdml_list=${RrcReconf}
    ...    xpath=.//nr-rrc.gapOffset
    ...    attribute_name=show

    run keyword and continue on failure    should be equal as strings    ${meas_gap['mgta']}    ${mgta[0].split()[1]}
    should be equal as strings    ${meas_gap['gapOffset']}    ${gapOffset[0]}

Verify pscell change in cpif log
    [Arguments]    ${filters}    ${log_path_pcap}=${CPIF_LOG}
    ${log_path_pdml}    Convert pcap to pdml    log_path_pcap=${log_path_pcap}    filter=f1ap||x2ap||e1ap
    verify_msg_type_and_seq_in_pdml    log_path_pdml=${log_path_pdml}    filters=${filters}


# [OBSOLETE]
