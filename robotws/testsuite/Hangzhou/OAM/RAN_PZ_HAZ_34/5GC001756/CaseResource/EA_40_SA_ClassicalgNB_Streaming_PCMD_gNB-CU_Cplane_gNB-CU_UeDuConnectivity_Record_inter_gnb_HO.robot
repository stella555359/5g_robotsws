*** Settings ***
Documentation
...   Author: yin.4.chen@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
EA_40_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_gNB-CU_UeDuConnectivity_Record_inter_gnb_HO
    Log To Console   CuVendorExtensionRecordDataType: ueDuConnectivityRecord (12)
    ${crnti_HO_list}   ${crnti_HO_length}   Get nrcti of gnb HO   ${INTER_HO_PATH}
    Load Pcap File with Filter any Expression
    ...   pcap_file=${INTER_HO_PATH}
    ...   any_expression=f1ap.procedureCode == 12
    ...   filter=sctp.dstport==38472
    ${xpath_f1ap_e1}   Set Variable
    ...   .//f1ap.F1AP_PDU/f1ap.initiatingMessage_element/f1ap.value_element
    ${xpath_f1ap_e2}   Set Variable
    ...   /f1ap.DLRRCMessageTransfer_element/f1ap.protocolIEs//f1ap.ProtocolIE_Field_element/f1ap.value_element/
    ${f1ap_GNB_CU_UE_F1AP_ID_mutil_list}   wireshark.get_field_value_by_xpath   xpath=${xpath_f1ap_e1}${xpath_f1ap_e2}/f1ap.GNB_CU_UE_F1AP_ID
    ${f1ap_GNB_DU_UE_F1AP_ID_mutil_list}   wireshark.get_field_value_by_xpath   xpath=${xpath_f1ap_e1}${xpath_f1ap_e2}/f1ap.GNB_DU_UE_F1AP_ID
    ${f1ap_GNB_CU_UE_F1AP_ID_list}   Remove Duplicates   ${f1ap_GNB_CU_UE_F1AP_ID_mutil_list}
    ${f1ap_GNB_DU_UE_F1AP_ID_list}   Remove Duplicates   ${f1ap_GNB_DU_UE_F1AP_ID_mutil_list}

    FOR   ${idx}    IN RANGE    0   ${crnti_HO_length}
        Load Pcap File with Filter any Expression
        ...   pcap_file=${INTER_HO_PATH}
        ...   any_expression=nsetapx.CuVendorExtensionRecordDataType==12&&nsetapx.crnti == ${crnti_HO_list}[${idx}]
        ...   filter=tcp.dstport==${dcap_server_port}
        ${xpath_ueDuC_e}   Set Variable   .//nsetapx.ueDuConnectivityRecord/nsetapx.data_element/nsetapx.setupData//nsetapx.DuUeCtxSetupData_element
        ${xpath_gnb_Id_e}   Set Variable   /nsetapx.gnb_du_Ids_element/nsetapx.gnb_Id_element
        ${result_list}   wireshark.get_field_value_by_xpath   xpath=${xpath_ueDuC_e}/nsetapx.result
        ${gnb_du_Id_list}   wireshark.get_field_value_by_xpath   xpath=${xpath_ueDuC_e}/nsetapx.gnb_du_Ids_element/nsetapx.gnb_du_Id
        ${plmn_Identity_list}   wireshark.get_field_value_by_xpath   xpath=${xpath_ueDuC_e}${xpath_gnb_Id_e}/nsetapx.plmn_Identity
        ${gnb_id_list}   wireshark.get_field_value_by_xpath   xpath=${xpath_ueDuC_e}${xpath_gnb_Id_e}/nsetapx.gnb_Id/nsetapx.gnb_id
        ${gnb_id_showname_list}   wireshark.get_field_value_by_xpath
        ...   xpath=${xpath_ueDuC_e}${xpath_gnb_Id_e}/nsetapx.gnb_Id/nsetapx.gnb_id   attribute_name=showname
        ${gnb_cu_ue_f1ap_Id_list}   wireshark.get_field_value_by_xpath   xpath=${xpath_ueDuC_e}/nsetapx.gnb_cu_ue_f1ap_Id
        ${gnb_du_ue_f1ap_Id_list}   wireshark.get_field_value_by_xpath   xpath=${xpath_ueDuC_e}/nsetapx.gnb_du_ue_f1ap_Id
        ${initialTime_list}   wireshark.get_field_value_by_xpath
        ...   xpath=${xpath_ueDuC_e}/nsetapx.initialUeRrcMessageTransferRcvTime_element/nsetapx.seconds
        ${ueCtxSetupReqSndTime_list}   wireshark.get_field_value_by_xpath
        ...   xpath=${xpath_ueDuC_e}/nsetapx.ueCtxSetupReqSndTime_element/nsetapx.seconds
        ${ueCtxSetupCmplRcvTime_list}   wireshark.get_field_value_by_xpath
        ...   xpath=${xpath_ueDuC_e}/nsetapx.ueCtxSetupCmplRcvTime_element/nsetapx.seconds
        ${result_length}=   Get Length   ${result_list}
        ${gnb_du_Id_length}=  Get Length   ${gnb_du_Id_list}
        ${plmn_Identity_length}=  Get Length   ${plmn_Identity_list}
        ${gnb_id_length}=  Get Length   ${gnb_id_list}
        ${gnb_cu_ue_f1ap_Id_length}=  Get Length   ${gnb_cu_ue_f1ap_Id_list}
        ${gnb_du_ue_f1ap_Id_length}=  Get Length   ${gnb_du_ue_f1ap_Id_list}
        ${ueCtxSetupReqSndTime_length}=  Get Length   ${ueCtxSetupReqSndTime_list}
        ${ueCtxSetupCmplRcvTime_length}=  Get Length   ${ueCtxSetupCmplRcvTime_list}
        Should Contain X Times   ${result_list}   0   1
        Should Be True   ${result_length}==${gnb_du_Id_length}==${plmn_Identity_length}==${gnb_id_length}
        ...   ==${gnb_cu_ue_f1ap_Id_length}==${gnb_du_ue_f1ap_Id_length}==${ueCtxSetupReqSndTime_length}==${ueCtxSetupCmplRcvTime_length}
        ${PEER_MRBTS_ID_string}=   Convert To String   ${PEER_MRBTS_ID}
        Should Be True   ${result_list}[0] == 0
        List Should Contain Value   ${f1ap_GNB_CU_UE_F1AP_ID_list}   ${gnb_cu_ue_f1ap_Id_list}[0]
        List Should Contain Value   ${f1ap_GNB_DU_UE_F1AP_ID_list}   ${gnb_du_ue_f1ap_Id_list}[0]
        should contain   ${gnb_id_showname_list}[0]   ${PEER_gNbIdLength}
        should contain   ${gnb_id_showname_list}[0]   ${PEER_MRBTS_ID_string}
        ${plman_clear}   Remove String   ${plmn_Identity_list}[0]   :
        Should Be True   '${plman_clear}' == '${PEER_PLMN_IDENTITY}'
        Should Not Be Empty    ${gnb_du_Id_list}
        Should Be Empty    ${initialTime_list}
        Should Not Be Empty    ${ueCtxSetupReqSndTime_list}
        Should Not Be Empty    ${ueCtxSetupReqSndTime_list}
    END

Case Setup: EA_40
    Log To Console   Case Setup: EA_40
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

Case Teardown: EA_40
    Log To Console   Case Teardown: EA_40
    run keyword if  not ${rec_status}   Run Keywords
    ...   Initialize PA   AND
    ...   Common Teardown 1756
    robot_common_operations.Common Case Teardown
