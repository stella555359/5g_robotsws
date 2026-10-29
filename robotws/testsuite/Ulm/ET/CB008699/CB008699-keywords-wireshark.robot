*** Settings ***
Documentation   This is a keyword file for CB008699 part wireshark
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Variables ***

${WIRESHARK_RUNNING}     false

*** Keywords ***


start wireshark trace
    [Documentation]    [PRIVATE]    start wireshark trace
    ...       :Autor: Sylvia Schneider
    Start Tcpdump on TestPc
    ...  options=-i any sctp or icmp
    ...  collector=dump_testpc
    sleep     1s
    Set suite variable      ${WIRESHARK_RUNNING}    true


stop wireshark trace
    [Documentation]    [PRIVATE]    stop wireshark trace
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_store}=${resultDir}/wireshark.pcap
    IF    '${WIRESHARK_RUNNING}'=='false'   RETURN
    sleep     2s
    ${tcpdump_file}    Stop Tcpdump on TestPc
    ...  collector=dump_testpc
    ...  target_dir=${resultDir}
    sleep     2s
    Move File    ${tcpdump_file}    ${wireshark_store}
    Set suite variable      ${WIRESHARK_RUNNING}    false


stop wireshark trace for setup
    [Documentation]    [PRIVATE]    stop wireshark trace for setup
    ...       :Autor: Sylvia Schneider
    stop wireshark trace            wireshark_store=${resultDir}/wireshark_startTL.pcap


verify wireshark CB008699 t1_t5
    [Documentation]    [PRIVATE]    verify wireshark for Source_DRB_to_QoS_flow_mapping_missing_at_target_gNB_during_Xn_handover
    ...                             verify wireshark for CNI_96896_Data_Forwarding_Info_is_missing_at_target_gNB_during_Xn_handover
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification for
    Log To Console    CB008699_A_Source_DRB_to_QoS_flow_mapping_missing_at_target_gNB_during_Xn_handover
    Log To Console    CB008699_CNI_96896_Data_Forwarding_Info_is_missing_at_target_gNB_during_Xn_handover
    verify wireshark handoverPreparationFailure
    verify wireshark handoverRequestAck     wireshark_file=${resultDir}/wireshark_part4.pcap
    verify wireshark UeContextRelease       wireshark_file=${resultDir}/wireshark_part4.pcap


verify wireshark CB008699 t2
    [Documentation]    [PRIVATE]    verify wireshark for Unknown_RRC_extension_detected_by_target_gNB_during_Xn_handover
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification for CB008699_B_Unknown_RRC_extension_detected_by_target_gNB_during_Xn_handover
    verify wireshark handoverRequestAck     wireshark_file=${resultDir}/wireshark_part3.pcap
    verify wireshark UeContextRelease       wireshark_file=${resultDir}/wireshark_part3.pcap


verify wireshark CB008699 t3
    [Documentation]    [PRIVATE]    verify wireshark for Unknown_critical_RRC_extension_detected_by_target_gNB_during_Xn_handover
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification for CB008699_B_Unknown_critical_RRC_extension_detected_by_target_gNB_during_Xn_handover
    verify wireshark handoverPreparationFailure


verify wireshark CB008699 t4
    [Documentation]    [PRIVATE]    verify wireshark for Source_DRB_to_QoS_flow_mapping_not_supported_at_target_gNB_during_Xn_handover
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification for CB008699_A_Source_DRB_to_QoS_flow_mapping_not_supported_at_target_gNB_during_Xn_handover
    verify wireshark handoverRequestAck     wireshark_file=${resultDir}/wireshark_part3.pcap
    verify wireshark UeContextRelease       wireshark_file=${resultDir}/wireshark_part3.pcap


verify wireshark CB008699 t6
    [Documentation]    [PRIVATE]    verify wireshark for Force_full_RRC_configuration_at_target_gNB_during_Xn_handover
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification for Force_full_RRC_configuration_at_target_gNB_during_Xn_handover
    FOR   ${ue_id}   IN   1   2   3   4
       Log To Console    verify UE${ue_id}
       verify wireshark handoverRequestAck     wireshark_file=${resultDir}/wireshark_handover_UE${ue_id}.pcap
       verify wireshark UeContextRelease       wireshark_file=${resultDir}/wireshark_handover_UE${ue_id}.pcap
    END


verify wireshark handoverPreparationFailure
    [Documentation]    [PRIVATE]    verify  handoverPreparationFailure in wireshark
    ...       :Autor: Sylvia Schneider
    ${filter_handoverFailure}    set variable   (xnap.procedureCode == 0) && (xnap.XnAP_PDU == 2)
    Log To Console    \nverify 1 handoverPreparationFailure message present
    ${msg}     Run     tshark -r ${resultDir}/wireshark_part3.pcap -Y "${filter_handoverFailure}" | wc -l
    Run Keyword And Continue On Failure   Should Be True    ${msg}==${1}
    ...     Wrong number of handoverPreparationFailure messages


verify wireshark handoverRequestAck
    [Documentation]    [PRIVATE]    verify handoverRequestAck in wireshark
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_file}

    Log To Console    \nverify handoverRequestAcknowledge present
    ${filter_hoReqAck}    set variable   (xnap.procedureCode == 0) && (xnap.XnAP_PDU == 1)
    ${msg}     Run     tshark -r ${wireshark_file} -Y "${filter_hoReqAck}" | wc -l
    Run Keyword And Continue On Failure   Should Be True    ${msg}==${1}
    ...     Wrong number of handoverRequestAck messages


verify wireshark UeContextRelease
    [Documentation]    [PRIVATE]    verify UeContextRelease in wireshark
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_file}
    Log To Console    \nverify UeContextRelease present
    ${filter_uecContRel}    set variable   xnap.procedureCode == 6
    ${msg}     Run     tshark -r ${wireshark_file} -Y "${filter_uecContRel}" | wc -l
    Run Keyword And Continue On Failure   Should Be True    ${msg}==${1}
    ...     Wrong number of UeContextRelease messages


verify wireshark CB008699 FR2
    [Documentation]    [PRIVATE]    verify wireshark for Partial_admission_control_for_Xn_handover_with_full_RRC_configuration
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification for Partial_admission_control_for_Xn_handover_with_full_RRC_configuration

    Log To Console    \nverify 1 messages present with handover preparation failure and cause no-radio-resources-available-in-target-cell
    ${filter_ho_prep_no_cells}    set variable   (xnap.procedureCode == 0) && (xnap.radioNetwork == 4) && (xnap.XnAP_PDU == 2)
    ${msg}     Run     tshark -r ${resultDir}/wireshark.pcap -Y "${filter_ho_prep_no_cells}" | wc -l
    Run Keyword And Continue On Failure   Should Be True    ${msg}==${1}
    ...     Wrong number of handover preparation failure and cause no-radio-resources-available-in-target-cell messages

    Log To Console
    ...    \nverify 1 messages present with handover request acknowledge, cause no-radio-resources-available-in-target-cell, qosFlowsNotAdmittedList
    ${filter_ho_ack_no_cells}
    ...    set variable   (xnap.procedureCode == 0) && (xnap.radioNetwork == 4) && (xnap.XnAP_PDU == 1) && (xnap.qosFlowsNotAdmitted_List == 1)
    ${msg}     Run     tshark -r ${resultDir}/wireshark.pcap -Y "${filter_ho_ack_no_cells}" | wc -l
    Run Keyword And Continue On Failure   Should Be True    ${msg}==${1}
    ...     Wrong number of messages, 1 message expected, ${msg} received

    Log To Console
    ...    \nverify 1 >UE context release message present with source 10.0.1.2
    ${filter_ueContRel}
    ...    set variable   (xnap.procedureCode == 6) && (ip.src == 10.0.1.2)
    ${msg}     Run     tshark -r ${resultDir}/wireshark.pcap -Y "${filter_ueContRel}" | wc -l
    Run Keyword And Continue On Failure   Should Be True    ${msg}==${1}
    ...     Wrong number of messages, 1 message expected, ${msg} received
