*** Settings ***
Documentation
...   Author: yin.4.chen@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
EA_26_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_gNB-CU_PDU_Session_Info_Record_inter_gnb_HO
    Load Pcap File with Filter any Expression
    ...   pcap_file=${INTER_HO_PATH}
    ...   any_expression=nsetapx.CuVendorExtensionRecordDataType==14 && nsetapx.trigger==2
    ...   filter=tcp.dstport==${dcap_server_port}
    ${xpath_Pdu_e}   Set Variable   .//nsetapx.pduSessionResourceInfoRecord/nsetapx.data_element
    ${xpath_PduResource_e}   Set Variable   /nsetapx.setupPduSessionResources//nsetapx.PduSessionResourceSetupItem_element
    ${xpath_Qos_element}   Set Variable   /nsetapx.setupQosFlows//nsetapx.QosFlowSetupItem_element/nsetapx.qosParameters_element
    ${xpath_fiveQi}   Set Variable   /nsetapx.qosCharacteristics/nsetapx.nonDynamicFiveQiDescriptor_element

    ${result_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=${xpath_Pdu_e}/nsetapx.result

    ${pduSessionId_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=${xpath_Pdu_e}${xpath_PduResource_e}/nsetapx.pduSessionId

    ${snssai_sst_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=${xpath_Pdu_e}${xpath_PduResource_e}/nsetapx.snssai_element/nsetapx.sst
    ${snssai_sd_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=${xpath_Pdu_e}${xpath_PduResource_e}/nsetapx.snssai_element/nsetapx.sd

    ${pduSessionAggregateMaximumBitRate_dl_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=${xpath_Pdu_e}${xpath_PduResource_e}/nsetapx.pduSessionAggregateMaximumBitRate_element/nsetapx.dlBitRate
    ${pduSessionAggregateMaximumBitRate_ul_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=${xpath_Pdu_e}${xpath_PduResource_e}/nsetapx.pduSessionAggregateMaximumBitRate_element/nsetapx.ulBitRate

    ${qfi_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=${xpath_Pdu_e}${xpath_PduResource_e}/nsetapx.setupQosFlows//nsetapx.QosFlowSetupItem_element/nsetapx.qfi
    ${fiveQi_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=${xpath_Pdu_e}${xpath_PduResource_e}${xpath_Qos_element}${xpath_fiveQi}/nsetapx.fiveQi
    ${arp_priorityLevel_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=${xpath_Pdu_e}${xpath_PduResource_e}${xpath_Qos_element}/nsetapx.arp_element/nsetapx.priorityLevel
    ${arp_preemptionCapability_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=${xpath_Pdu_e}${xpath_PduResource_e}${xpath_Qos_element}/nsetapx.arp_element/nsetapx.preemptionCapability
    ${arp_preemptionVulnerability_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=${xpath_Pdu_e}${xpath_PduResource_e}${xpath_Qos_element}/nsetapx.arp_element/nsetapx.preemptionVulnerability

    ${crnti_list}   wireshark.get_field_value_by_xpath   xpath=.//nsetapx.crnti
    ${crnti_single_list}   Remove Duplicates   ${crnti_list}

    List Should Contain Value   ${result_list}   0
    Should Not Be Empty   ${pduSessionId_list}
    Should Not Be Empty   ${snssai_sst_list}
    Should Not Be Empty   ${snssai_sd_list}
    Should Not Be Empty   ${pduSessionAggregateMaximumBitRate_dl_list}
    Should Not Be Empty   ${pduSessionAggregateMaximumBitRate_ul_list}
    Should Not Be Empty   ${qfi_list}
    Should Not Be Empty   ${fiveQi_list}
    Should Not Be Empty   ${arp_priorityLevel_list}
    Should Not Be Empty   ${arp_preemptionCapability_list}
    Should Not Be Empty   ${arp_preemptionVulnerability_list}
    Should Not Be Empty   ${crnti_single_list}

Case Setup: EA_26
    Log To Console   Case Setup: EA_26
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    ${rec_status}   Run Keyword And Return Status   OperatingSystem.File Should Exist   ${INTER_HO_PATH}
    Set Suite Variable   ${rec_status}
    run keyword if  not ${rec_status}   Run Keywords
    ...   Common Setup 1756   AND
    ...   Remove And Add PCMD Object   AND
    ...   Trigger INTER HO

    # # SET PA Initial value
    # # Set TL864 cell1(sourcecell) (A1-B1,A2-B2) value to 20
    # # Set TL864 cell2(intraHOtargetcell) (A3-B3,A4-B4) value to 40
    # # Set TL865 cell1(interHOtargetcell) (A5-B5,A6-B6) value to 127
    # Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=0   value=20
    # Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=1   value=127
    # Modify All Attenuation Ports Value For Specific RU   gnb_id=1   RU_id=0   value=40

    # Start Tcpdump To Get PCMD   pcmd_file=EA_26.pcap
    # L3CALL Precondition
    # Wait Until Keyword Succeeds   3x   10s   Attach UE BETA

    # # trigger Intra gnb HO by adjust adjustable attenuation
    # # Keep TL864 cell1(sourcecell) (A1-B1,A2-B2) value to 20
    # # Set TL865 cell1(interHOtargetcell) (A5-B5,A6-B6) value to 5
    # Modify All Attenuation Ports Value For Specific RU   gnb_id=1   RU_id=0   value=5
    # Sleep   30s
    # Stop Tcpdump To Get PCMD   pcmd_file=EA_26.pcap
    # Detach UE BETA

Case Teardown: EA_26
    Log To Console   Case Teardown: EA_26
    run keyword if  not ${rec_status}   Run Keywords
    ...   Initialize PA   AND
    ...   Common Teardown 1756
    robot_common_operations.Common Case Teardown
