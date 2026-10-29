*** Settings ***
Documentation
...   Author: yin.4.chen@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
EA_38_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_gNB-CU_UESetup_Record_intra_gnb_HO
    log to console     check elemnet  CuVendorExtensionRecordDataType: ueSetupRecord (13)
#    ${crnti_HO_list}   ${crnti_HO_length}   Get nrcti of gnb HO   ${INTRA_HO_PATH}
    ${SA_INTRA_target_crnti_HO_list}   ${SA_INTRA_source_crnti_HO_list}  Get nrcti of Target and Source HO
    ...   ${INTRA_HO_PATH}   nsetapx.CuVendorExtensionRecordDataType==14 && nsetapx.trigger==2
    ...   nsetapx.CuVendorExtensionRecordDataType==14 && nsetapx.trigger==3
    ${crnti_HO_list}   set variable   ${SA_INTRA_target_crnti_HO_list}
    ${crnti_HO_length}   Get Length   ${SA_INTRA_target_crnti_HO_list}
     Load Pcap File with Filter any Expression
     ...                        pcap_file=${INTRA_HO_PATH}
     ...                        any_expression=ngap.procedureCode == 14&&ip.dst == ${LOCAL_SSH_ADDR}
     ...                        filter=sctp.dstport==38412
    ${xpath_ngap_e1}   set variable   .//ngap.NGAP_PDU/ngap.initiatingMessage_element/ngap.value_element/ngap.InitialContextSetupRequest_element
    ${xpath_ngap_e2}   set variable   /ngap.protocolIEs//ngap.ProtocolIE_Field_element/ngap.value_element
    ${ngap_amf-ue-ngap-Id_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ngap_e1}${xpath_ngap_e2}/ngap.AMF_UE_NGAP_ID
    ${ngap_ran-ue-ngap-Id_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ngap_e1}${xpath_ngap_e2}/ngap.RAN_UE_NGAP_ID
    ${ngap_plmn-Identity_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ngap_e1}${xpath_ngap_e2}/ngap.GUAMI_element/ngap.pLMNIdentity
    ${ngap_amfRegionId_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ngap_e1}${xpath_ngap_e2}/ngap.GUAMI_element/ngap.aMFRegionID
    ${ngap_amfSetId_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ngap_e1}${xpath_ngap_e2}/ngap.GUAMI_element/ngap.aMFSetID
    ${ngap_amfPointer_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ngap_e1}${xpath_ngap_e2}/ngap.GUAMI_element/ngap.aMFPointer

    FOR   ${idx}    IN RANGE    0   ${crnti_HO_length}
        Load Pcap File with Filter any Expression
        ...   pcap_file=${INTRA_HO_PATH}
        ...   any_expression=nsetapx.CuVendorExtensionRecordDataType==13&&nsetapx.crnti == ${crnti_HO_list}[${idx}]
        ...   filter=tcp.dstport==${dcap_server_port}
        ${xpath_ueSetup_e}   set variable   .//nsetapx.ueSetupRecord/nsetapx.data_element
        ${trigger_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ueSetup_e}/nsetapx.trigger
        ${result_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ueSetup_e}/nsetapx.result
        ${ran-ue-ngap-Id_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ueSetup_e}/nsetapx.ran_ue_ngap_Id
        ${amf-ue-ngap-Id_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ueSetup_e}/nsetapx.amf_ue_ngap_Id
        ${plmn-Identity_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ueSetup_e}/nsetapx.guami_element/nsetapx.plmn_Identity
        ${amfRegionId_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ueSetup_e}/nsetapx.guami_element/nsetapx.amfRegionId
        ${amfSetId_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ueSetup_e}/nsetapx.guami_element/nsetapx.amfSetId
        ${amfPointer_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ueSetup_e}/nsetapx.guami_element/nsetapx.amfPointer
        ${trigger_length}=     Get Length   ${trigger_list}
        ${result_length}=   Get Length   ${result_list}
        ${ran-ue-ngap-Id_length}=  Get Length   ${ran-ue-ngap-Id_list}
        ${amf-ue-ngap-Id_length}=  Get Length   ${amf-ue-ngap-Id_list}
        ${plmn-Identity_length}=  Get Length   ${plmn-Identity_list}
        ${amfRegionId_length}=  Get Length   ${amfRegionId_list}
        ${amfSetId_length}=  Get Length   ${amfSetId_list}
        ${amfPointer_length}=  Get Length   ${amfPointer_list}
        Should Contain X Times   ${trigger_list}   0   1
        Should Be True   ${trigger_length} == ${result_length} == ${ran-ue-ngap-Id_length} == ${amf-ue-ngap-Id_length} == ${plmn-Identity_length}
        ...   == ${amfRegionId_length} == ${amfSetId_length} == ${amfPointer_length}
        Should Be True   ${result_list}[${idx}] == 0
        List Should Contain Value   ${ngap_ran-ue-ngap-Id_list}   ${ran-ue-ngap-Id_list}[0]
        List Should Contain Value   ${ngap_amf-ue-ngap-Id_list}   ${amf-ue-ngap-Id_list}[0]
        List Should Contain Value   ${ngap_plmn-Identity_list}   ${plmn-Identity_list}[0]
        List Should Contain Value   ${ngap_amfRegionId_list}   ${amfRegionId_list}[0]
        List Should Contain Value   ${ngap_amfSetId_list}   ${amfSetId_list}[0]
        List Should Contain Value   ${ngap_amfPointer_list}   ${amfPointer_list}[0]
    END


Case Setup: EA_38
    Log To Console   Case Setup: EA_38
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    ${rec_status}   Run Keyword And Return Status   OperatingSystem.File Should Exist   ${INTRA_HO_PATH}
    Set Suite Variable   ${rec_status}
    run keyword if  not ${rec_status}   Run Keywords
    ...   Common Setup 1756   AND
    ...   Remove And Add PCMD Object   AND
    ...   Trigger INTRA HO

    # # SET PA Initial value
    # # Set TL864 cell1(sourcecell) (A1-B1,A2-B2) value to 20
    # # Set TL864 cell2(intraHOtargetcell) (A3-B3,A4-B4) value to 40
    # # Set TL865 cell1(interHOtargetcell) (A5-B5,A6-B6) value to 127
    # Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=0   value=20
    # Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=1   value=40
    # Modify All Attenuation Ports Value For Specific RU   gnb_id=1   RU_id=0   value=127

    # Start Tcpdump To Get PCMD   pcmd_file=EA_25.pcap
    # L3CALL Precondition
    # Wait Until Keyword Succeeds   3x   10s   Attach UE BETA

    # # trigger Intra gnb HO by adjust adjustable attenuation
    # # Keep TL864 cell1(sourcecell) (A1-B1,A2-B2) value to 20
    # # Set TL864 cell2(intraHOtargetcell) (A3-B3,A4-B4) value to 0
    # Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=1   value=0
    # Sleep   30s
    # Stop Tcpdump To Get PCMD   pcmd_file=EA_25.pcap
    # Detach UE BETA

Case Teardown: EA_38
    Log To Console   Case Teardown: EA_38
    run keyword if  not ${rec_status}   Run Keywords
    ...   Initialize PA   AND
    ...   Common Teardown 1756
    robot_common_operations.Common Case Teardown
