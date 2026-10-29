*** Settings ***
Documentation
...    author: jqu003
...    this case will verify keyword for TA of CB009225-A on Classical

*** Variables ***
${Intra_gNB_Inter_DU_File_SA}    Intra_gNB_inter_DU_SA.pcap
${Intra_gNB_Inter_DU_File_SA_path}   ${OUTPUT_DIR}/${Intra_gNB_Inter_DU_File_SA}
*** Keyword ***
CB009225_A_03_e2e_B02_Successful_SA_intra_gNB_inter_DU_handover_A3_trigger_cloud
    Log To Console     \n Start To Anlysis CB009225-A Record Content
    # Step-1 setup variable xpath, for get feild value of pcap file.
    Set Test Variable     ${Pcap_file_path}    ${Intra_gNB_Inter_DU_File_SA_path}
    Set IntragNBHoSrcRecord Xpath
    Set IntragNBHoTgtRecord Xpath
    Set UEContextSetupRequest Xpath Of Target CellId
    # Step-1: Get UeContextModification frame list which prepare for Handover
    ${request_list}    ${tgtCellId_signal_list}    Get UEContextSetupRequest Frame List And Target CellId
    # Step-2: Get Source and Target record frame and content
    ${Src_record_list}    ${Src_content}    Get IntragNBHoSrcRecord Frame List
    ${Tgt_record_list}    ${Tgt_content}    Get IntragNBHoTgtRecord Frame List
    # Step-3: Checkpoint1:Compare Src and Tgt record content, which cellid should be expected
    Compare Src And Tgt record Content    ${Src_content}    ${Tgt_content}    ${tgtCellId_signal_list}

Set IntragNBHoSrcRecord Xpath
    Set Test Variable    ${HoSrcbase_structure}    .//nsetapx.intragNBHoSrcRecord/nsetapx.data_element
    Set Test Variable    ${SrcRecordCellId_path}
    ...    //nsetapx.intragNBHoSrcRecord/ancestor::nsetapx.recordingSessionReportList/../nsetapx.cellId/nsetapx.nrcgi_element/nsetapx.cellIdentity
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
    Set Test Variable    ${tgtResult_path}    ${HoTgtbase_structure}/nsetapx.result
    Set Test Variable    ${srcCell_structure}    ${HoTgtbase_structure}/nsetapx.srcCellId_element
    Set Test Variable    ${srcPlmn_path}    ${srcCell_structure}/nsetapx.plmn_Identity
    Set Test Variable    ${srcCellid_path}    ${srcCell_structure}/nsetapx.cellIdentity
    Set Test Variable    ${hoCmdCmplRcvTime_structure}    ${HoTgtbase_structure}/nsetapx.hoCmdCmplRcvTime_element
    Set Test Variable    ${hoCmdCmplRcvTime1_path}    ${hoCmdCmplRcvTime_structure}/nsetapx.seconds
    Set Test Variable    ${hoCmdCmplRcvTime2_path}    ${hoCmdCmplRcvTime_structure}/nsetapx.useconds

Set UEContextSetupRequest Xpath Of Target CellId
    Set Test Variable    ${base_structure}    .//f1ap.UEContextSetupRequest_element/f1ap.protocolIEs
    Set Test Variable    ${cellIdentity_signal}
    ...    ${base_structure}//f1ap.ProtocolIE_Field_element/f1ap.value_element/f1ap.NRCGI_element/f1ap.nRCellIdentity
    Set Test Variable    ${plmn_signal}
    ...    ${base_structure}//f1ap.ProtocolIE_Field_element/f1ap.value_element/f1ap.NRCGI_element/f1ap.pLMN_Identity

Get UEContextSetupRequest Frame List And Target CellId
    [Documentation]  will filter the UeContextModificationRequest which used for handover initiate
    [Arguments]  ${Pcap_file_path}=${Pcap_file_path}
    Load Pcap File with Filter any Expression
    ...   pcap_file=${Pcap_file_path}
    ...   any_expression=f1ap.procedureCode == 5 && nr-rrc.candidateCellInfoList >= 1 && sctp.srcport==38472
    ...   filter= sctp.dstport==38472
    ${request_list}   Check Field Value By Xpath    xpath=.//frame.number
    ${CellId_Signal_list}   Check Field Value By Xpath    xpath=${cellIdentity_signal}
    [Return]  ${request_list}    ${CellId_Signal_list}

Get IntragNBHoSrcRecord Frame List
    [Arguments]  ${Pcap_file_path}=${Pcap_file_path}
    Load Pcap File with Filter any Expression
    ...   pcap_file=${Pcap_file_path}
    ...   any_expression=nsetapx.CuVendorExtensionRecordDataType==16 && ip.dst==${dcap_server_ip}
    ...   filter= tcp.dstport==${dcap_server_port}
    ${record_list}   Check Field Value By Xpath    xpath=.//frame.number
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
        Append To List    ${record_content_list}    ${dic_item}
    END
    [Return]   ${record_list}    ${record_content_list}

Get IntragNBHoTgtRecord Frame List
    [Arguments]  ${Pcap_file_path}=${Pcap_file_path}
    Load Pcap File with Filter any Expression
    ...   pcap_file=${Pcap_file_path}
    ...   any_expression=nsetapx.CuVendorExtensionRecordDataType==17 && ip.dst==${dcap_server_ip}
    ...   filter= tcp.dstport==${dcap_server_port}
    ${record_list}   Check Field Value By Xpath    xpath=.//frame.number
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
        Append To List    ${record_content_list}    ${dic_item}
    END
    [Return]   ${record_list}    ${record_content_list}

Compare Src And Tgt record Content
    [Arguments]  ${Src_content}    ${Tgt_content}    ${TgtCellId_signal}
    ${Handover_index}    Get Length    ${TgtCellId_signal}
    ${src_record_len}    Get Length    ${Src_content}
    ${tgt_record_len}    Get Length    ${Tgt_content}
    Should Be True      ${Handover_index}==${src_record_len}==${tgt_record_len}
    FOR    ${index}    IN RANGE    ${Handover_index}
        ${src_compare}    ${tgt_compare}    Set Variable    ${Src_content}[${index}]     ${Tgt_content}[${index}]
        Should Be True    "${src_compare}[SrcRecordCellId]"=="${tgt_compare}[srcCellId]"
        Should Be True    "${src_compare}[tgtCellId]"=="${tgt_compare}[TgtRecordCellId]"=="${TgtCellId_signal}[${index}]"
    END
