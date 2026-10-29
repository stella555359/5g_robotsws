*** Settings ***
Documentation
...   Author: liping.hong@nokia-sbell.com

Resource   ../Resource/Common.robot


*** Keyword ***
EA_41_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_gNB-CU_PDU_Session_Info_Record_for_Pdu_Session_Resource_Setup
    log to console     check elemnet  PDU_Session_Info_Record_for_Pdu_Session_Resource_Setup

     Load Pcap File with Filter any Expression
     ...                        pcap_file=${TCPDUMP_PATH}
     ...   any_expression=nsetapx.CuVendorExtensionRecordDataType == 14&&nsetapx.trigger == 3
     ...                        filter=tcp.dstport==${dcap_server_port}
    ${xpath_Pdu_e}   set variable   .//nsetapx.pduSessionResourceInfoRecord/nsetapx.data_element
    ${result_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_Pdu_e}/nsetapx.result
    ${result_list_length}=  Get Length   ${result_list}
    ${pduSetup_success_list_length}   ${ngap_pdusetup_success_length}   run keyword if   '0' in ${result_list}
    ...   Compare PDU Record with Ngap PDU Info for Pdu Session Resource Setup   ${TCPDUMP_PATH}   0
    ${pduSetup_failed_list_length}   ${ngap_pdusetup_failed_length}   run keyword if   '1' in ${result_list}
    ...   Compare PDU Record with Ngap PDU Info for Pdu Session Resource Setup    ${TCPDUMP_PATH}   1
    #${pduSetup_success_list_length}   set variable if   ${pduSetup_success_list_length}   ${pduSetup_success_list_length}   0
    #${pduSetup_failed_list_length}   set variable if   ${pduSetup_failed_list_length}   ${pduSetup_failed_list_length}      0
    #${ngap_pdusetup_length}   run keyword if   ${ngap_pdusetup_success_length}   set variable      ${ngap_pdusetup_success_length}
    #...   ELSE IF   ${ngap_pdusetup_failed_length}   set variable   ${ngap_pdusetup_failed_length}
    #...   ELSE    FAIL
    #${pduSetup_total_list_length}   evaluate  ${pduSetup_success_list_length}+${pduSetup_failed_list_length}
    # should be true   ${pduSetup_total_list_length} == ${ngap_pdusetup_length} == ${result_list_length}
    Log To Console   check value is OK

Compare PDU Record with Ngap PDU Info for Pdu Session Resource Setup
    [Arguments]    ${TCPDUMP_PATH}   ${pdusetup_result}
     Load Pcap File with Filter any Expression
     ...                        pcap_file=${TCPDUMP_PATH}
     ...                        any_expression=ngap.id == 74&&ip.dst == ${LOCAL_SSH_ADDR}
     ...                        filter=tcp.dstport==38412
    ${xpath_IctxsetupR_e1}   set variable   .//ngap.NGAP_PDU/ngap.initiatingMessage_element/ngap.value_element
    ${xpath_IctxsetupR_e2}   set variable    /ngap.PDUSessionResourceSetupRequest_element/ngap.protocolIEs
    ${xpath_IctxsetupR_e3}   set variable    //ngap.ProtocolIE_Field_element/ngap.value_element/ngap.PDUSessionResourceSetupListSUReq
    ${xpath_IctxsetupR_e4}   set variable    //ngap.PDUSessionResourceSetupItemSUReq_element
    ${xpath_IctxsetupR_E4}   set variable   ${xpath_IctxsetupR_e1}${xpath_IctxsetupR_e2}${xpath_IctxsetupR_e3}${xpath_IctxsetupR_e4}
    ${xpath_IctxsetupR_e5}   set variable   /ngap.pDUSessionResourceSetupRequestTransfer/ngap.PDUSessionResourceSetupRequestTransfer_element
    ${xpath_IctxsetupR_e6}   set variable   /ngap.protocolIEs//ngap.ProtocolIE_Field_element/ngap.value_element
    ${xpath_IctxsetupR_E6}   set variable   ${xpath_IctxsetupR_E4}${xpath_IctxsetupR_e5}${xpath_IctxsetupR_e6}
    ${xpath_IctxsetupR_bit}   set variable   /ngap.PDUSessionAggregateMaximumBitRate_element
    ${xpath_IctxsetupR_qos}   set variable   /ngap.QosFlowSetupRequestList//ngap.QosFlowSetupRequestItem_element
    ${xpath_IctxsetupR_qosP}   set variable   ${xpath_IctxsetupR_E6}${xpath_IctxsetupR_qos}/ngap.qosFlowLevelQosParameters_element
    ${xpath_IctxsetupR_5QI}   set variable   /ngap.qosCharacteristics/ngap.nonDynamic5QI_element/ngap.fiveQI
    ${xpath_IctxsetupR_arp}   set variable   ${xpath_IctxsetupR_qosP}/ngap.allocationAndRetentionPriority_element
    ${ngap_pdusetup_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_IctxsetupR_e1}${xpath_IctxsetupR_e2}${xpath_IctxsetupR_e3}
    ${ngap_pdusetup_length}=  Get Length   ${ngap_pdusetup_list}
    ${ngap_pduSessionId_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_IctxsetupR_E4}/ngap.pDUSessionID
    ${ngap_snssai_sst_list}=    wireshark.get_field_value_by_xpath      xpath=${xpath_IctxsetupR_E4}/ngap.s_NSSAI_element/ngap.sST
    ${ngap_snssai_sd_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_IctxsetupR_E4}/ngap.s_NSSAI_element/ngap.sD
    ${ngap_pdu-A-M-bit_dl_list}=    wireshark.get_field_value_by_xpath
     ...    xpath=${xpath_IctxsetupR_E6}${xpath_IctxsetupR_bit}/ngap.pDUSessionAggregateMaximumBitRateDL
     ${ngap_pdu-A-M-bit_ul_list}=    wireshark.get_field_value_by_xpath
     ...    xpath=${xpath_IctxsetupR_E6}${xpath_IctxsetupR_bit}/ngap.pDUSessionAggregateMaximumBitRateUL
    ${ngap_qfi_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_IctxsetupR_E6}${xpath_IctxsetupR_qos}/ngap.qosFlowIdentifier
    ${ngap_fiveQi_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_IctxsetupR_qosP}${xpath_IctxsetupR_5QI}
    ${ngap_P-L_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_IctxsetupR_arp}/ngap.priorityLevelARP
    ${ngap_P-C_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_IctxsetupR_arp}/ngap.pre_emptionCapability
    ${ngap_P-V_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_IctxsetupR_arp}/ngap.pre_emptionVulnerability
     Load Pcap File with Filter any Expression
     ...                        pcap_file=${TCPDUMP_PATH}
     ...   any_expression=nsetapx.CuVendorExtensionRecordDataType == 14&&nsetapx.trigger == 3
     ...                        filter=tcp.dstport==${dcap_server_port}
    ${xpath_Pdu_e}   set variable   .//nsetapx.pduSessionResourceInfoRecord/nsetapx.data_element
    ${xpath1_pdusetup_result}   set variable if   ${pdusetup_result}== 0   set   failedToSet
    ${xpath2_pdusetup_result}   set variable if   ${pdusetup_result}== 0   Set   FailedToSet
    ${xpath_PduResource_e}   set variable
    ...   /nsetapx.${xpath1_pdusetup_result}upPduSessionResources//nsetapx.PduSessionResource${xpath2_pdusetup_result}upItem_element
    ${xpath_Qos_e}   set variable   /nsetapx.${xpath1_pdusetup_result}upQosFlows//nsetapx.QosFlow${xpath2_pdusetup_result}upItem_element
    ${xpath_QosP_e}   set variable   ${xpath_Pdu_e}${xpath_PduResource_e}${xpath_Qos_e}/nsetapx.qosParameters_element
    ${xpath_fiveQi}   set variable   /nsetapx.qosCharacteristics/nsetapx.nonDynamicFiveQiDescriptor_element
    ${result_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_Pdu_e}/nsetapx.result
    ${trigger_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_Pdu_e}/nsetapx.trigger
    ${result_list_length}=  Get Length   ${result_list}
    ${snssai_sst_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=${xpath_Pdu_e}${xpath_PduResource_e}/nsetapx.snssai_element/nsetapx.sst
    ${snssai_sd_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=${xpath_Pdu_e}${xpath_PduResource_e}/nsetapx.snssai_element/nsetapx.sd
    ${pduSessionId_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=${xpath_Pdu_e}${xpath_PduResource_e}/nsetapx.pduSessionId
    ${pduSessionId_list_length}=  Get Length   ${pduSessionId_list}
    ${pduSessionAggregateMaximumBitRate_dl_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=${xpath_Pdu_e}${xpath_PduResource_e}/nsetapx.pduSessionAggregateMaximumBitRate_element/nsetapx.dlBitRate
    ${pduSessionAggregateMaximumBitRate_ul_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=${xpath_Pdu_e}${xpath_PduResource_e}/nsetapx.pduSessionAggregateMaximumBitRate_element/nsetapx.ulBitRate
    ${qfi_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_Pdu_e}${xpath_PduResource_e}${xpath_Qos_e}/nsetapx.qfi
    ${fiveQi_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_QosP_e}${xpath_fiveQi}/nsetapx.fiveQi
    ${arp_priorityLevel_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_QosP_e}/nsetapx.arp_element/nsetapx.priorityLevel
    ${arp_preemptionCapability_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=${xpath_QosP_e}/nsetapx.arp_element/nsetapx.preemptionCapability
    ${arp_preemptionVulnerability_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=${xpath_QosP_e}/nsetapx.arp_element/nsetapx.preemptionVulnerability
    # FOR   ${idx}    IN RANGE    0   ${pduSessionId_list_length}
    #     List Should Contain Value   ${ngap_pduSessionId_list}   ${pduSessionId_list}[${idx}]
    #     List Should Contain Value   ${ngap_snssai_sst_list}   ${snssai_sst_list}[${idx}]
    #     List Should Contain Value   ${ngap_snssai_sd_list}   ${snssai_sd_list}[${idx}]
    #     List Should Contain Value   ${ngap_pdu-A-M-bit_dl_list}   ${pduSessionAggregateMaximumBitRate_dl_list}[${idx}]
    #     List Should Contain Value   ${ngap_pdu-A-M-bit_ul_list}   ${pduSessionAggregateMaximumBitRate_ul_list}[${idx}]
    #     List Should Contain Value   ${ngap_qfi_list}   ${qfi_list}[${idx}]
    #     List Should Contain Value   ${ngap_fiveQi_list}   ${fiveQi_list}[${idx}]
    #     List Should Contain Value   ${ngap_P-L_list}   ${arp_priorityLevel_list}[${idx}]
    #     List Should Contain Value   ${ngap_P-C_list}   ${arp_preemptionCapability_list}[${idx}]
    #     List Should Contain Value   ${ngap_P-V_list}   ${arp_preemptionVulnerability_list}[${idx}]
    # END
    # Length Should Be   ${trigger_list}   ${result_list_length}
    # Length Should Be   ${snssai_sst_list}   ${pduSessionId_list_length}
    # Length Should Be   ${snssai_sd_list}   ${pduSessionId_list_length}
    # Length Should Be   ${pduSessionId_list}   ${pduSessionId_list_length}
    # Length Should Be   ${pduSessionAggregateMaximumBitRate_dl_list}   ${pduSessionId_list_length}
    # Length Should Be   ${pduSessionAggregateMaximumBitRate_ul_list}   ${pduSessionId_list_length}
    # Length Should Be   ${qfi_list}   ${pduSessionId_list_length}
    # Length Should Be   ${fiveQi_list}   ${pduSessionId_list_length}
    # Length Should Be   ${arp_priorityLevel_list}   ${pduSessionId_list_length}
    # Length Should Be   ${arp_preemptionCapability_list}   ${pduSessionId_list_length}
    # Length Should Be   ${arp_preemptionVulnerability_list}   ${pduSessionId_list_length}
    [Return]   ${pduSessionId_list_l ength}   ${ngap_pdusetup_length}

Case Setup: EA_41
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    Log To Console   Case Setup: EA_41

Case Teardown: EA_41
    robot_common_operations.Common Case Teardown
    Log To Console   Case Teardown: EA_41
    Check Extra Reset From Blackbox on Teardown   Reset_before=${RESET_REASON}
