*** Settings ***
Documentation
...   Author: yin.4.chen@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
EA_36_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_DU_UE_context_setup_Trace_Record_intra_gnb_HO
    [Arguments]  ${record_file_path}=${INTRA_HO_PATH}
#    ${crnti_HO_list}   ${crnti_HO_length}   Get nrcti of gnb HO   ${record_file_path}
    ${SA_INTRA_target_crnti_HO_list}   ${SA_INTRA_source_crnti_HO_list}  Get nrcti of Target and Source HO
    ...   ${record_file_path}   nsetapx.CuVendorExtensionRecordDataType==14 && nsetapx.trigger==2
    ...   nsetapx.CuVendorExtensionRecordDataType==14 && nsetapx.trigger==3
    ${crnti_HO_list}   set variable   ${SA_INTRA_target_crnti_HO_list}
    ${crnti_HO_length}   Get Length   ${SA_INTRA_target_crnti_HO_list}
    ${SCS}=    create dictionary    15 KHz=0   30 KHz=1   60 KHz=2
    ${scs_d}   set variable   ${FR1}[${ssbScs}]
    ${Bandwidth_index}   set variable   ${scs_d}[${chbw}]
     Load Pcap File with Filter any Expression
     ...                        pcap_file=${record_file_path}
     ...                          any_expression=f1ap.procedureCode == 12
     ...                        filter=sctp.dstport==38472
    ${xpath_f1ap_e1}   set variable   .//f1ap.F1AP_PDU/f1ap.initiatingMessage_element/f1ap.value_element
    ${xpath_f1ap_e2}   set variable   /f1ap.DLRRCMessageTransfer_element/f1ap.protocolIEs//f1ap.ProtocolIE_Field_element/f1ap.value_element/
    ${f1ap_GNB_CU_UE_F1AP_ID_mutil_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_f1ap_e1}${xpath_f1ap_e2}/f1ap.GNB_CU_UE_F1AP_ID
    ${f1ap_GNB_DU_UE_F1AP_ID_mutil_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_f1ap_e1}${xpath_f1ap_e2}/f1ap.GNB_DU_UE_F1AP_ID
    ${f1ap_GNB_CU_UE_F1AP_ID_list}   Remove Duplicates   ${f1ap_GNB_CU_UE_F1AP_ID_mutil_list}
    ${f1ap_GNB_DU_UE_F1AP_ID_list}   Remove Duplicates   ${f1ap_GNB_DU_UE_F1AP_ID_mutil_list}
    ${xpath_ueCtxSetup_e}   set variable   .//nsetapx.ueCtxSetupRecord/nsetapx.data_r1_element

    FOR   ${idx}    IN RANGE    0   ${crnti_HO_length}
        Load Pcap File with Filter any Expression
        ...   pcap_file=${record_file_path}
        ...   any_expression=nsetapx.DuVendorExtensionRecordDataType==1&&nsetapx.crnti == ${crnti_HO_list}[${idx}]
        ...   filter=tcp.dstport==${dcap_server_port}
        ${result_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ueCtxSetup_e}/nsetapx.result
        ${gnb_cu_ue_f1ap_Id_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ueCtxSetup_e}/nsetapx.gnb_cu_ue_f1ap_Id
        ${gnb_du_ue_f1ap_Id_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ueCtxSetup_e}/nsetapx.gnb_du_ue_f1ap_Id
        ${ssbSubcarrierSpacing}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ueCtxSetup_e}/nsetapx.ssbSubcarrierSpacing
        ${dlCarrierBandwidthTdd}=   wireshark.get_field_value_by_xpath
        ...   xpath=${xpath_ueCtxSetup_e}/nsetapx.dlCarrierBandwidthTdd   attribute_name=showname
        ${absoluteFrequencySsb}=   wireshark.get_field_value_by_xpath   xpath=${xpath_ueCtxSetup_e}/nsetapx.absoluteFrequencySsb
        ${ueCtxSetupCmplSndTime_list}  wireshark.get_field_value_by_xpath
        ...   xpath=${xpath_ueCtxSetup_e}/nsetapx.ueCtxSetupCmplSndTime_element/nsetapx.seconds
        ${ueCtxSetupReqRcvTime_list}   wireshark.get_field_value_by_xpath
        ...   xpath=${xpath_ueCtxSetup_e}/nsetapx.ueCtxSetupReqRcvTime_element/nsetapx.seconds
        ${initialTime_list}  wireshark.get_field_value_by_xpath
        ...   xpath=${xpath_ueCtxSetup_e}/nsetapx.initialUeRrcMessageTransferSndTime_element/nsetapx.seconds
        ${result_length}=   Get Length   ${result_list}
        ${gnb_cu_ue_f1ap_Id_length}=   Get Length   ${gnb_cu_ue_f1ap_Id_list}
        ${gnb_du_ue_f1ap_Id_length}=   Get Length   ${gnb_du_ue_f1ap_Id_list}
        ${ssbSubcarrierSpacing_length}=   Get Length   ${ssbSubcarrierSpacing}
        ${dlCarrierBandwidthTdd_length}=   Get Length   ${dlCarrierBandwidthTdd}
        ${absoluteFrequencySsb_length}=   Get Length   ${absoluteFrequencySsb}
        Should Be True   ${result_length}==${gnb_cu_ue_f1ap_Id_length}==${gnb_du_ue_f1ap_Id_length}==${ssbSubcarrierSpacing_length}
        ...   ==${dlCarrierBandwidthTdd_length}==${absoluteFrequencySsb_length}
        Should Contain X Times   ${result_list}   0   1
        List Should Contain Value   ${f1ap_GNB_CU_UE_F1AP_ID_list}   ${gnb_cu_ue_f1ap_Id_list}[0]
        List Should Contain Value   ${f1ap_GNB_DU_UE_F1AP_ID_list}   ${gnb_du_ue_f1ap_Id_list}[0]
        Should Be True   ${ssbSubcarrierSpacing}[${idx}]== ${SCS}[${ssbScs}]
        ${dlCarrierBandwidthTdd_f}   Should Match Regexp   ${dlCarrierBandwidthTdd}[${idx}]   n\\d+
        Should Be True   '${dlCarrierBandwidthTdd_f}' == 'n${Bandwidth_index}'
        Should Be True   ${absoluteFrequencySsb}[${idx}] == ${arfcnSsbPbch}
        Should Be Empty    ${ueCtxSetupCmplSndTime_list}
        Should Be Empty    ${ueCtxSetupReqRcvTime_list}
        Should Be Empty    ${initialTime_list}
    END




Case Setup: EA_36
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    Log To Console   Case Setup: EA_36
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

Case Teardown: EA_36
    Log To Console   Case Teardown: EA_36
    run keyword if  not ${rec_status}   Run Keywords
    ...   Initialize PA   AND
    ...   Common Teardown 1756
    robot_common_operations.Common Case Teardown
