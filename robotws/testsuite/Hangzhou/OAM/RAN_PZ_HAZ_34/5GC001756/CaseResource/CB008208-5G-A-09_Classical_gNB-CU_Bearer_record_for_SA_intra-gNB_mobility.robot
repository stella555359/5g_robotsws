*** Settings ***
Documentation
...    author: jqu003
...    this case will verify keyword for TA of CB008208

Library     ../Library/list_time_check.py

*** Variables ***
${base_xpath}    .//f1ap.F1AP_PDU/f1ap.successfulOutcome_element/f1ap.value_element/f1ap.UEContextModificationResponse_element/f1ap.protocolIEs
${c_rnti_xpath}    //f1ap.ProtocolIE_Field_element/f1ap.value_element/f1ap.C_RNTI

*** Keyword ***
CB008208-5G-A-09_Classical_gNB-CU_Bearer_record_for_SA_intra-gNB_mobility
    Set Test Variable     ${Pcap_file_path}    ${SA_INTRA_gNB_HO_PATH}
    Set CuBearRecord Xpath
    Set UEContextModificationRequest for Xpath Of CB008208
    # Step-1: Get UeContextModification frame list which prepare for Handover
    ${request_list}    ${signal_list}    Get UEContextModificationRequest Frame List
    # Step-2: Get All CuBearerRecord frame list occured in all scenario
    ${Bearer_record_list}    ${record_content_list}    Get CuBearerRecord Frame List    Pcap_file_path=${Pcap_file_path}
    # Step-3: Get the CuBeaerRecord nearly by UeContextModification message which used for handover scenarion
    ${neaby_list}    find_nearby_frame    ${request_list}    ${Bearer_record_list}
    # Check Point-1: Each Handover should generate one BearerRecord
    ${record_content_list}   set variable   ${record_content_list}[0]
    ${pduId_list_res}   Copy List  ${record_content_list}[pduId]
    ${drbId_list_res}   Copy List  ${record_content_list}[drbId]
    ${QFI_list_res}   Copy List  ${record_content_list}[QFI]
    Reverse List   ${pduId_list_res}
    Reverse List   ${drbId_list_res}
    Reverse List   ${QFI_list_res}
    ${record_content_list_res}    Create Dictionary
        ...    pduId=${pduId_list_res}
        ...    drbId=${drbId_list_res}
        ...    QFI=${QFI_list_res}
    ${status}   Run Keyword And Return Status   Dictionaries Should Be Equal  ${signal_list}[0]   ${record_content_list}
    ${status_res}   Run Keyword And Return Status   Dictionaries Should Be Equal  ${signal_list}[0]   ${record_content_list_res}
    Should Be True   ${status} or ${status_res}
#    Should Be True      ${signal_list} == ${record_content_list}
    # Check Point-2: Check earch CuBearerRecord content #1 all field predefined is presented. #2 all field value is as predefined
    Check Each Record Content    record_frame_list=${neaby_list}

Case Setup: CB008208-5G-A-09
    Log To Console   Case Setup: CB008208-5G-A-09
    ${file_status}   run keyword and return status   File Should Not Be Empty   ${SA_INTRA_gNB_HO_PATH}
    ${HO_status}   run keyword and return status   should not be empty   ${SA_INTRA_crnti_HO_list}
    Run Keyword If   '${file_status}'=='False' or '${HO_status}'=='False'   Run Keywords
    ...   Common Setup 1756   AND
    ...   Remove And Add PCMD Object   AND
    ...   Trigger INTRA gNB HO   ${SA_ue_index}    ${SA_INTRA_gNB_HO_PATH}   SA
    Set CuBearRecord Xpath

Case Teardown: CB008208-5G-A-09
    Log To Console   Case Teardown: CB008208-5G-A-09
    Run Keyword If   '${file_status}'=='False' or '${HO_status}'=='False'   Run Keywords
    ...   Initialize PA   AND
    ...   Common Teardown 1756

Set CuBearRecord Xpath
    Set Test Variable    ${base_structure}    .//nsetapx.bearerRecord/nsetapx.data_r1_element
    Set Test Variable    ${trigger_path}    ${base_structure}/nsetapx.trigger
    Set Test Variable    ${setup_bear_structure}    ${base_structure}/nsetapx.setupBearers
    Set Test Variable    ${bear_data_structure}    ${setup_bear_structure}//nsetapx.CuBearerDataSetupItem/nsetapx.ngranBearer_element
    Set Test Variable    ${drb_QoS_structure}    ${bear_data_structure}/nsetapx.drbQoS_element
    Set Test Variable    ${qfi_structure}
    ...    ${bear_data_structure}/nsetapx.setupQosFlowsMappedToBearer//nsetapx.CuSetupQosFlowMappedToBearerItem_element
    Set Test Variable    ${qfi_path}    ${qfi_structure}/nsetapx.qfi
    Set Test Variable    ${QoS_character_structure}    ${drb_QoS_structure}/nsetapx.qosCharacteristics
    Set Test Variable    ${nonDynamic_fqi_path}    ${QoS_character_structure}/nsetapx.nonDynamicFiveQiDescriptor_element
    Set Test Variable    ${fqi_path}    ${nonDynamic_fqi_path}/nsetapx.fiveQi
    Set Test Variable    ${arp_structure}    ${drb_QoS_structure}/nsetapx.arp_element
    Set Test Variable    ${priorityLevel_path}    ${arp_structure}/nsetapx.priorityLevel
    Set Test Variable    ${preemptionCapability_path}    ${arp_structure}/nsetapx.preemptionCapability
    Set Test Variable    ${preemptionVulnerability_path}    ${arp_structure}/nsetapx.preemptionVulnerability
    Set Test Variable    ${drbid_path}    ${bear_data_structure}/nsetapx.drb_Id
    Set Test Variable    ${pdusessionid_path}    ${bear_data_structure}/nsetapx.pduSessionId

Set UEContextModificationRequest for Xpath Of CB008208
    Set Test Variable    ${signal_base_structure}    .//nr-rrc.drb_ToAddModList//nr-rrc.DRB_ToAddMod_element
    Set Test Variable    ${pduId_signal_xpath}    ${signal_base_structure}/nr-rrc.cnAssociation/nr-rrc.sdap_Config_element/nr-rrc.pdu_Session
    Set Test Variable    ${QFI_signal_xpath}
    ...    ${signal_base_structure}/nr-rrc.cnAssociation/nr-rrc.sdap_Config_element/nr-rrc.mappedQoS_FlowsToAdd//nr-rrc.QFI
    Set Test Variable    ${drbId_signal_xpath}    ${signal_base_structure}/nr-rrc.drb_Identity

Get UEContextModificationRequest Frame List
    [Documentation]  will filter the UeContextModificationRequest which used for handover initiate
    [Arguments]  ${Pcap_file_path}=${Pcap_file_path}
    Load Pcap File with Filter any Expression
    ...   pcap_file=${Pcap_file_path}
    ...   any_expression=f1ap.procedureCode == 7 && nr-rrc.candidateCellInfoList >= 1 && sctp.srcport==38472
    ...   filter= sctp.dstport==38472
    ${request_list}   Check Field Value By Xpath    xpath=.//frame.number
    ${drbAdd_list}   Check Field Value By Xpath    xpath=${signal_base_structure}
    ${pduId_list}   Check Field Value By Xpath    xpath=${pduId_signal_xpath}
    ${QFI_list}   Check Field Value By Xpath    xpath=${QFI_signal_xpath}
    ${drbId_list}   Check Field Value By Xpath    xpath=${drbId_signal_xpath}
    ${signal_list}     Create List
    ${handover_request_times}    Get Length    ${request_list}
    FOR     ${index}     IN RANGE    ${handover_request_times}
        ${dic_item}    Create Dictionary
#        ...    frame=${request_list}[${index}]
        ...    pduId=${pduId_list}
        ...    drbId=${drbId_list}
        ...    QFI=${QFI_list}
        Append To List    ${signal_list}    ${dic_item}
    END
    [Return]  ${request_list}    ${signal_list}

Get UEContextModificationResponse Frame List
    [Arguments]  ${Pcap_file_path}=${Pcap_file_path}
    Load Pcap File with Filter any Expression
    ...   pcap_file=${Pcap_file_path}
    ...   any_expression=f1ap.UEContextModificationResponse_element && sctp.srcport==38472
    ...   filter= sctp.dstport==38472
    ${response_list}   Check Field Value By Xpath    xpath=.//frame.number
    [Return]  ${response_list}

Get C-RNTI List UEContextModificationResponse
    [arguments]    ${frame_list}    ${Pcap_file_path}=${Pcap_file_path}
    @{r_rnti_list}    Create List
    FOR    ${frame_num}    IN    @{frame_list}
        ${c_rnti}    Get C-RNTI Efficent UEContextModificationResponse    ${frame_num}
        Append To List     ${r_rnti_list}     ${c_rnti}
    END
    [Return]   ${r_rnti_list}

Get C-RNTI Efficent UEContextModificationResponse
    [arguments]    ${frame_num}    ${Pcap_file_path}=${Pcap_file_path}
    Load Pcap File with Filter any Expression
    ...   pcap_file=${Pcap_file_path}
    ...   any_expression=f1ap.UEContextModificationResponse_element && frame.number == ${frame_num} && sctp.srcport==38472
    ...   filter= sctp.dstport==38472
    # Refer 5G_TC_736  different content have different field to check, or different value to check
    ${c_rnti}    Check Field Value By Xpath      xpath=${base_xpath}${c_rnti_xpath}
    [Return]  ${c_rnti}

Get Available CuBearRecord Items
    ${request_frame}    Get Time List Of Each Initial Request frame List     Pcap_file_path=${Pcap_file_path}
    ${response_frame}    Get Time List Of Each Initial Response frame List    Pcap_file_path=${Pcap_file_path}
    ${record_frame}    Get Time List Of Each CuRecord frame list     Pcap_file_path=${Pcap_file_path}
    ${available_request}    ${available_record}      check_record    request_time_list=${request_frame}     response_time_list=${response_frame}
    ...    recorde_time_list=${record_frame}
    {numb_CuBearRecord}    Get Length    ${available_record}
    Should Be True    {numb_CuBearRecord} > 1
    [Return]  ${available_record}

Get InitialContextSetupRequest Frame List
    [Arguments]  ${Pcap_file_path}=${Pcap_file_path}
    Load Pcap File with Filter any Expression
    ...   pcap_file=${Pcap_file_path}
    ...   any_expression=ngap.InitialContextSetupRequest_element && sctp.srcport==38412
    ...   filter= sctp.dstport==38412
    ${reques_list}   Check Field Value By Xpath    xpath=.//frame.number
    [Return]  ${reques_list}

Get InitialContextSetupResponse Frame List
    [Arguments]  ${Pcap_file_path}=${Pcap_file_path}
    Load Pcap File with Filter any Expression
    ...   pcap_file=${Pcap_file_path}
    ...   any_expression=ngap.InitialContextSetupResponse_element && sctp.srcport==38412
    ...   filter= sctp.dstport==38412
    ${response_list}   Check Field Value By Xpath    xpath=.//frame.number
    [Return]  ${response_list}

Get PDUSessionResourceSetupRequest Frame List
    [Arguments]  ${Pcap_file_path}=${Pcap_file_path}
    Load Pcap File with Filter any Expression
    ...   pcap_file=${Pcap_file_path}
    ...   any_expression=ngap.PDUSessionResourceSetupRequest_element && sctp.srcport==38412
    ...   filter= sctp.dstport==38412
    ${reques_list}   Check Field Value By Xpath    xpath=.//frame.number
    [Return]  ${reques_list}

Get PDUSessionResourceSetupResponse Frame List
    [Arguments]  ${Pcap_file_path}=${Pcap_file_path}
    Load Pcap File with Filter any Expression
    ...   pcap_file=${Pcap_file_path}
    ...   any_expression=ngap.PDUSessionResourceSetupResponse_element && sctp.srcport==38412
    ...   filter= sctp.dstport==38412
    ${response_list}   Check Field Value By Xpath    xpath=.//frame.number
    [Return]  ${response_list}

Get PDUSessionResourceReleaseCommand Frame List
    [Arguments]  ${Pcap_file_path}=${Pcap_file_path}
    Load Pcap File with Filter any Expression
    ...   pcap_file=${Pcap_file_path}
    ...   any_expression=ngap.PDUSessionResourceReleaseCommand_element && sctp.srcport==38412
    ...   filter= sctp.dstport==38412
    ${reques_list}   Check Field Value By Xpath    xpath=.//frame.number
    [Return]  ${reques_list}

Get PDUSessionResourceReleaseResponse Frame List
    [Arguments]  ${Pcap_file_path}=${Pcap_file_path}
    Load Pcap File with Filter any Expression
    ...   pcap_file=${Pcap_file_path}
    ...   any_expression=ngap.PDUSessionResourceReleaseResponse_element && sctp.srcport==38412
    ...   filter= sctp.dstport==38412
    ${response_list}   Check Field Value By Xpath    xpath=.//frame.number
    [Return]  ${response_list}

Get CuBearerRecord Frame List
    [Arguments]  ${Pcap_file_path}=${Pcap_file_path}
    Load Pcap File with Filter any Expression
    ...   pcap_file=${Pcap_file_path}
    ...   any_expression=nsetapx.CuVendorExtensionRecordDataType==10 && nsetapx.trigger==1 && nsetapx.setupBearers==2 && ip.dst==${dcap_server_ip}
    ...   filter= tcp.dstport==49148
    ${record_list}   Check Field Value By Xpath    xpath=.//frame.number
    ${drbId}    Check Field Value By Xpath      xpath=${drbid_path}
    ${pduSessionId}    Check Field Value By Xpath      xpath=${pdusessionid_path}
    ${QoS_qfi}    Check Field Value By Xpath      xpath=${qfi_path}
    ${record_content_list}     Create List
    ${record_times}    Get Length    ${record_list}
    FOR     ${index}     IN RANGE    ${record_times}
        ${dic_item}    Create Dictionary
#        ...    frame=${request_list}[${index}]
        ...    pduId=${pduSessionId}
        ...    drbId=${drbId}
        ...    QFI=${QoS_qfi}
        Append To List    ${record_content_list}    ${dic_item}
    END
    [Return]   ${record_list}    ${record_content_list}

Check Each Record Content
    [Arguments]  ${record_frame_list}    ${Pcap_file_path}=${Pcap_file_path}
    FOR    ${record_frame}     IN     @{record_frame_list}
        Run Keyword And Continue On Failure
        ...    Check SetupBearer Record IE    record_frame=${record_frame}
    END


Check SetupBearer Record IE
    [Arguments]   ${record_frame}    ${Pcap_file_path}=${Pcap_file_path}
    Load Pcap File with Filter any Expression
    ...   pcap_file=${Pcap_file_path}
    ...   any_expression=nsetapx.CuVendorExtensionRecordDataType == 10 && ip.dst==${dcap_server_ip} && frame.number==${record_frame}
    ...   filter= tcp.dstport==49148
    # Refer 5G_TC_736  different content have different field to check, or different value to check
    ${beaer_num}    Check Field Value By Xpath      xpath=${setup_bear_structure}
    ${trigger}    Check Field Value By Xpath      xpath=${trigger_path}
    ${drbId}    Check Field Value By Xpath      xpath=${drbid_path}
    ${pduSessionId}    Check Field Value By Xpath      xpath=${pdusessionid_path}
    ${fiveQi}    Check Field Value By Xpath      xpath=${fqi_path}
    ${priorityLevel}    Check Field Value By Xpath      xpath=${priorityLevel_path}
    ${preemptionCapability}    Check Field Value By Xpath      xpath=${preemptionCapability_path}
    ${preemptionVulnerability}    Check Field Value By Xpath      xpath=${preemptionVulnerability_path}
    ${QoS_qfi}    Check Field Value By Xpath      xpath=${qfi_path}

    ${beaer_num}    Get From List      ${beaer_num}    0
    ${beaer_num}    Convert To Integer      ${beaer_num}
    Should Be True    ${trigger}[0] == ${1}
    FOR     ${index}     IN RANGE    ${beaer_num}
        ${result1}    Evaluate    1 <= ${drbId}[${index}] <= 32
        ${result2}    Evaluate    0 <= ${pduSessionId}[${index}] <= 255
        ${result3}    Evaluate    0 <= ${fiveQi}[${index}] <= 255
        ${result4}    Evaluate    1 <= ${priorityLevel}[${index}] <= 127
        ${result5}    Evaluate    0 <= ${QoS_qfi}[${index}] <= 63
        ${result6}    Run Keyword And Return Status    Should Contain Any	 ${preemptionCapability}[${index}]     1     0
        ${result7}    Run Keyword And Return Status    Should Contain Any	 ${preemptionVulnerability}[${index}]     1     0
        Should Be True   ${result1}==${result2}==${result3}==${result4}==${result5}==${result7}==True
    END
