*** Settings ***
Documentation
...    author: jqu003
...    this case will verify keyword for TA of CB009225-A on Classical



*** Variables ***
${SA_ue_index}    0
${SA_INTRA_gNB_HO_FILE}   SA_INTRA_gNB_HO.pcap
${SA_INTRA_gNB_HO_PATH}   ${OUTPUT_DIR}/${SA_INTRA_gNB_HO_FILE}


*** Keyword ***
CB009225_A_01_e2e_B01_Successful_SA_intra_gNB_intra_DU_handover_A3_trigger
    # Step-1 setup variable xpath, for get feild value of pcap file.
    Set Test Variable     ${Pcap_file_path}    ${SA_INTRA_gNB_HO_PATH}
    Set IntragNBHoSrcRecord Xpath
    Set IntragNBHoTgtRecord Xpath
    Set UEContextModificationRequest Xpath Of Target CellId
    # Step-1: Get UeContextModification frame list which prepare for Handover
    ${request_list}    ${tgtCellId_signal_list}    Get UEContextModificationRequest Frame List And Target CellId
    # Step-2: Get Source and Target record frame and content
    ${Src_record_list}    ${Src_content}    Get IntragNBHoSrcRecord Frame List
    ${Tgt_record_list}    ${Tgt_content}    Get IntragNBHoTgtRecord Frame List
    ${request_list}    ${RrcReconfig_celltrace}    Get Rrc Reconfiguration For Handover Frame List
    ${request_list}    ${RrcReconfigCmp_celltrace}    Get Rrc Reconfiguration Complete For Handover Frame List
    # Step-3: Checkpoint1:Compare Src and Tgt record content, which cellid should be expected
    Compare Src And Tgt record Content    ${Src_content}    ${Tgt_content}    ${tgtCellId_signal_list}    ${RrcReconfig_celltrace}
    ...    ${RrcReconfigCmp_celltrace}

Set IntragNBHoSrcRecord Xpath
    Set Test Variable    ${HoSrcbase_structure}    .//nsetapx.intragNBHoSrcRecord/nsetapx.data_element
    Set Test Variable    ${SrcRecordCellId_path}
    ...    //nsetapx.intragNBHoSrcRecord/ancestor::nsetapx.recordingSessionReportList/../nsetapx.cellId/nsetapx.nrcgi_element/nsetapx.cellIdentity
    Set Test Variable    ${SrcRecord_crnti_head_path}
    ...    //nsetapx.intragNBHoSrcRecord/ancestor::nsetapx.CuRecord_element/nsetapx.crnti
    Set Test Variable    ${srcResult_path}    ${HoSrcbase_structure}/nsetapx.result
    Set Test Variable    ${moblilityReason_path}    ${HoSrcbase_structure}/nsetapx.mobilityReason
    Set Test Variable    ${tgtCell_structure}    ${HoSrcbase_structure}/nsetapx.tgtCellId_element
    Set Test Variable    ${tgtPlmn_path}    ${tgtCell_structure}/nsetapx.plmn_Identity
    Set Test Variable    ${tgtCellid_path}    ${tgtCell_structure}/nsetapx.cellIdentity
    Set Test Variable    ${hoDecisionTime_structure}    ${HoSrcbase_structure}/nsetapx.hoDecisionTime_element
    Set Test Variable    ${desionTime1_path}    ${hoDecisionTime_structure}/nsetapx.seconds
    Set Test Variable    ${desionTime2_path}    ${hoDecisionTime_structure}/nsetapx.useconds
    Set Test Variable    ${hoCmdSndTime_structure}    ${HoSrcbase_structure}/nsetapx.hoCmdSndTime_element
    Set Test Variable    ${cmdSendTime1_path}    ${hoCmdSndTime_structure}/nsetapx.seconds
    Set Test Variable    ${cmdSendTime2_path}    ${hoCmdSndTime_structure}/nsetapx.useconds

Set IntragNBHoTgtRecord Xpath
    Set Test Variable    ${HoTgtbase_structure}    .//nsetapx.intragNBHoTgtRecord/nsetapx.data_element
    Set Test Variable    ${TgtRecordCellId_path}
    ...    //nsetapx.intragNBHoTgtRecord/ancestor::nsetapx.recordingSessionReportList/../nsetapx.cellId/nsetapx.nrcgi_element/nsetapx.cellIdentity
    Set Test Variable    ${TgtRecord_crnti_head_path}
    ...    //nsetapx.intragNBHoTgtRecord/ancestor::nsetapx.CuRecord_element/nsetapx.crnti
    Set Test Variable    ${tgtResult_path}    ${HoTgtbase_structure}/nsetapx.result
    Set Test Variable    ${srcCell_structure}    ${HoTgtbase_structure}/nsetapx.srcCellId_element
    Set Test Variable    ${srcPlmn_path}    ${srcCell_structure}/nsetapx.plmn_Identity
    Set Test Variable    ${srcCellid_path}    ${srcCell_structure}/nsetapx.cellIdentity
    Set Test Variable    ${hoCmdCmplRcvTime_structure}    ${HoTgtbase_structure}/nsetapx.hoCmdCmplRcvTime_element
    Set Test Variable    ${hoCmdCmplRcvTime1_path}    ${hoCmdCmplRcvTime_structure}/nsetapx.seconds
    Set Test Variable    ${hoCmdCmplRcvTime2_path}    ${hoCmdCmplRcvTime_structure}/nsetapx.useconds

Set UEContextModificationRequest Xpath Of Target CellId
    Set Test Variable    ${base_structure}    .//f1ap.UEContextModificationRequest_element/f1ap.protocolIEs
    Set Test Variable    ${cellIdentity_signal}
    ...    ${base_structure}//f1ap.ProtocolIE_Field_element/f1ap.value_element/f1ap.NRCGI_element/f1ap.nRCellIdentity
    Set Test Variable    ${plmn_signal}
    ...    ${base_structure}//f1ap.ProtocolIE_Field_element/f1ap.value_element/f1ap.NRCGI_element/f1ap.pLMN_Identity


Get UEContextModificationRequest Frame List And Target CellId
    [Documentation]  will filter the UeContextModificationRequest which used for handover initiate
    [Arguments]  ${Pcap_file_path}=${Pcap_file_path}
    Load Pcap File with Filter any Expression
    ...   pcap_file=${Pcap_file_path}
    ...   any_expression=f1ap.procedureCode == 7 && nr-rrc.candidateCellInfoList >= 1 && sctp.srcport==38472
    ...   filter= sctp.dstport==38472
    ${request_list}   Check Field Value By Xpath    xpath=.//frame.number
    ${CellId_Signal_list}   Check Field Value By Xpath    xpath=${cellIdentity_signal}
    [Return]  ${request_list}    ${CellId_Signal_list}

Get Rrc Reconfiguration For Handover Frame List
    [Arguments]  ${Pcap_file_path}=${Pcap_file_path}
    Load Pcap File with Filter any Expression
    ...   pcap_file=${Pcap_file_path}
    ...   any_expression=nr-rrc.rrcReconfiguration_element && nr-rrc.newUE_Identity && tcp.dstport==49148
    ...   filter= tcp.dstport==49148
    ${record_list}   Check Field Value By Xpath    xpath=.//frame.number
    ${Src_crnti_list}   Check Field Value By Xpath    xpath=.//nsetapx.crnti
    ${Tgt_crnti_list}   Check Field Value By Xpath    xpath=.//nr-rrc.newUE_Identity
    ${RrcSendTime1_Celltrace_list}   Check Field Value By Xpath    xpath=.//nsetapx.seconds
    ${RrcSendTime2_Celltrace_list}   Check Field Value By Xpath    xpath=.//nsetapx.useconds
    ${Msg_content_list}     Create List
    ${record_times}    Get Length    ${record_list}
    FOR     ${index}     IN RANGE    ${record_times}
        ${dic_item}    Create Dictionary
        ...    Src_crnti=${Src_crnti_list}[${index}]
        ...    Tgt_crnti=${Tgt_crnti_list}[${index}]
        ...    RrcSendTime1=${RrcSendTime1_Celltrace_list}[${index}]
        ...    RrcSendTime2=${RrcSendTime2_Celltrace_list}[${index}]
        Append To List    ${Msg_content_list}    ${dic_item}
    END
    [Return]   ${record_list}    ${Msg_content_list}

Get Rrc Reconfiguration Complete For Handover Frame List
    [Arguments]  ${Pcap_file_path}=${Pcap_file_path}
    Load Pcap File with Filter any Expression
    ...   pcap_file=${Pcap_file_path}
    ...   any_expression=nr-rrc.rrcReconfigurationComplete_element && ip.dst==${dcap_server_ip}
    ...   filter= tcp.dstport==49148
    ${record_list}   Check Field Value By Xpath    xpath=.//frame.number
    ${RrcCmpTime1_Celltrace_list}   Check Field Value By Xpath    xpath=.//nsetapx.seconds
    ${RrcCmpTime2_Celltrace_list}   Check Field Value By Xpath    xpath=.//nsetapx.useconds
    ${Msg_content_list}     Create List
    ${record_times}    Get Length    ${RrcCmpTime1_Celltrace_list}
    FOR     ${index}     IN RANGE    ${record_times}
        ${dic_item}    Create Dictionary
        ...    RrcCmpTime1=${RrcCmpTime1_Celltrace_list}[${index}]
        ...    RrcCmpTime2=${RrcCmpTime2_Celltrace_list}[${index}]
        Append To List    ${Msg_content_list}    ${dic_item}
    END
    [Return]   ${record_list}    ${Msg_content_list}

Get IntragNBHoSrcRecord Frame List
    [Arguments]  ${Pcap_file_path}=${Pcap_file_path}
    Load Pcap File with Filter any Expression
    ...   pcap_file=${Pcap_file_path}
    ...   any_expression=nsetapx.CuVendorExtensionRecordDataType==16
    ...   filter= tcp.dstport==49148
    ${record_list}   Check Field Value By Xpath    xpath=.//frame.number
    ${SrcRecord_crnti}   Check Field Value By Xpath    xpath=${SrcRecord_crnti_head_path}
    ${SrcRecordCellId}    Check Field Value By Xpath      xpath=${SrcRecordCellId_path}
    ${moblilityReason}    Check Field Value By Xpath      xpath=${moblilityReason_path}
    ${srcResult}    Check Field Value By Xpath      xpath=${srcResult_path}
    ${tgtPlmn}    Check Field Value By Xpath      xpath=${tgtPlmn_path}
    ${tgtCellid}    Check Field Value By Xpath      xpath=${tgtCellid_path}
    ${desionTime1}    Check Field Value By Xpath      xpath=${desionTime1_path}
    ${desionTime2}    Check Field Value By Xpath      xpath=${desionTime2_path}
    ${cmdSendTime1}    Check Field Value By Xpath      xpath=${cmdSendTime1_path}
    ${cmdSendTime2}    Check Field Value By Xpath      xpath=${cmdSendTime2_path}

    ${record_content_list}     Create List
    ${record_times}    Get Length    ${record_list}
    FOR     ${index}     IN RANGE    ${record_times}
        Should Be True    ${srcResult}[${index}] == 0
        Should Be True    ${moblilityReason}[${index}] == 1
#        Should Be True    ${tgtPlmn}[${index}] == 64:f0:20
        ${dic_item}    Create Dictionary
        ...    SrcRecordCellId=${SrcRecordCellId}[${index}]
        ...    tgtCellId=${tgtCellid}[${index}]
        ...    Src_crnti=${SrcRecord_crnti}[${index}]
        ...    RrcSendTime1=${cmdSendTime1}[${index}]
        ...    RrcSendTime2=${cmdSendTime2}[${index}]
        Append To List    ${record_content_list}    ${dic_item}
    END
    [Return]   ${record_list}    ${record_content_list}

Get IntragNBHoTgtRecord Frame List
    [Arguments]  ${Pcap_file_path}=${Pcap_file_path}
    Load Pcap File with Filter any Expression
    ...   pcap_file=${Pcap_file_path}
    ...   any_expression=nsetapx.CuVendorExtensionRecordDataType==17
    ...   filter= tcp.dstport==49148
    ${record_list}   Check Field Value By Xpath    xpath=.//frame.number
    ${TgtRecord_crnti}   Check Field Value By Xpath    xpath=${TgtRecord_crnti_head_path}
    ${TgtRecordCellId}    Check Field Value By Xpath      xpath=${TgtRecordCellId_path}
    ${tgtResult}    Check Field Value By Xpath      xpath=${tgtResult_path}
    ${srcPlmn}    Check Field Value By Xpath      xpath=${srcPlmn_path}
    ${srcCellid}    Check Field Value By Xpath      xpath=${srcCellid_path}
    ${hoCmdCmplRcvTime1}    Check Field Value By Xpath      xpath=${hoCmdCmplRcvTime1_path}
    ${hoCmdCmplRcvTime2}    Check Field Value By Xpath      xpath=${hoCmdCmplRcvTime2_path}

    ${record_content_list}     Create List
    ${record_times}    Get Length    ${record_list}
    FOR     ${index}     IN RANGE    ${record_times}
        Should Be True    ${tgtResult}[${index}] == 0
#        Should Be True    ${srcPlmn}[${index}] == 64:f0:20
        ${dic_item}    Create Dictionary
        ...    TgtRecordCellId=${TgtRecordCellId}[${index}]
        ...    srcCellId=${srcCellid}[${index}]
        ...    Tgt_crnti=${TgtRecord_crnti}[${index}]
        ...    RrcCmpTime1=${hoCmdCmplRcvTime1}[${index}]
        ...    RrcCmpTime2=${hoCmdCmplRcvTime2}[${index}]
        Append To List    ${record_content_list}    ${dic_item}
    END
    [Return]   ${record_list}    ${record_content_list}

Compare Src And Tgt record Content
    [Arguments]  ${Src_content}    ${Tgt_content}    ${TgtCellId_signal}    ${RrcReconfig_celltrace}    ${RrcReconfigCmp_celltrace}
    ${Handover_index}    Get Length    ${TgtCellId_signal}
    ${src_record_len}    Get Length    ${Src_content}
    ${tgt_record_len}    Get Length    ${Tgt_content}
    Should Be True      ${Handover_index}==${src_record_len}==${tgt_record_len}
    FOR    ${index}    IN RANGE    ${Handover_index}
        ${src_compare}    ${tgt_compare}    ${rrcSend_compare}    Set Variable
        ...    ${Src_content}[${index}]     ${Tgt_content}[${index}]
        ...    ${RrcReconfig_celltrace}[${index}]
        Should Be True    "${src_compare}[SrcRecordCellId]"=="${tgt_compare}[srcCellId]"
        Should Be True    "${src_compare}[tgtCellId]"=="${tgt_compare}[TgtRecordCellId]"=="${TgtCellId_signal}[${index}]"
        Should Be True    "${src_compare}[Src_crnti]"=="${rrcSend_compare}[Src_crnti]"
        Should Be True    "${tgt_compare}[Tgt_crnti]"=="${rrcSend_compare}[Tgt_crnti]"
        Should Be True    "${src_compare}[RrcSendTime1]"=="${rrcSend_compare}[RrcSendTime1]"
        Should Be True    "${src_compare}[RrcSendTime2]"=="${rrcSend_compare}[RrcSendTime2]"
        _Check RrcReconfigCmp Time Alignment    RrcReconfigCmp_list=${RrcReconfigCmp_celltrace}
        ...   RrcReconfigCmp_record_item="${tgt_compare}[RrcCmpTime2]"
    END

_Check RrcReconfigCmp Time Alignment
    [Arguments]  ${RrcReconfigCmp_list}    ${RrcReconfigCmp_record_item}
    ${list_len}    Get Length    ${RrcReconfigCmp_list}
    FOR    ${index}    IN RANGE    ${list_len}
        ${rrcCmp_compare}    Set Variable    ${RrcReconfigCmp_list}[${index}]
        ${flag}    Run Keyword And Return Status    Should Be True    ${RrcReconfigCmp_record_item} == "${rrcCmp_compare}[RrcCmpTime2]"
        Continue For Loop If    not ${flag}
        Exit For Loop If  ${flag}
    END
    run keyword if  not ${flag}   FAIL   RRC Complete Time Not Align!
