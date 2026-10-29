*** Settings ***
Documentation
...   Author: liping.hong@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
EA_23_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_gNB-CU_UeDuConnectivity_Record
    # ${PLMN_IDENTITY}    ${gNbIdLength}   Get plmnandgnbidlength from webui
    log to console     check elemnet  CuVendorExtensionRecordDataType: ueDuConnectivityRecord (12)
#
     Load Pcap File with Filter any Expression
     ...                        pcap_file=${TCPDUMP_PATH}
#     ...                        any_expression=nr-rrc.criticalExtensions == 0
     ...                          any_expression=f1ap.procedureCode == 12
     ...                        filter=sctp.dstport==38472
    ${xpath_f1ap_e1}   set variable   .//f1ap.F1AP_PDU/f1ap.initiatingMessage_element/f1ap.value_element
    ${xpath_f1ap_e2}   set variable   /f1ap.DLRRCMessageTransfer_element/f1ap.protocolIEs//f1ap.ProtocolIE_Field_element/f1ap.value_element/
    ${f1ap_GNB_CU_UE_F1AP_ID_mutil_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_f1ap_e1}${xpath_f1ap_e2}/f1ap.GNB_CU_UE_F1AP_ID
    ${f1ap_GNB_DU_UE_F1AP_ID_mutil_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_f1ap_e1}${xpath_f1ap_e2}/f1ap.GNB_DU_UE_F1AP_ID
    ${f1ap_GNB_CU_UE_F1AP_ID_list}   Remove Duplicates   ${f1ap_GNB_CU_UE_F1AP_ID_mutil_list}
    ${f1ap_GNB_DU_UE_F1AP_ID_list}   Remove Duplicates   ${f1ap_GNB_DU_UE_F1AP_ID_mutil_list}

     Load Pcap File with Filter any Expression
     ...                        pcap_file=${TCPDUMP_PATH}
     ...                        any_expression=f1ap.procedureCode == 11
     ...                        filter=sctp.dstport==38472
    ${rrcsetuprequest_time_list}=    wireshark.get_field_value_by_xpath   xpath=.//frame.time_epoch
     Load Pcap File with Filter any Expression
     ...                        pcap_file=${TCPDUMP_PATH}
     ...                        any_expression=f1ap.procedureCode == 5
     ...                        filter=sctp.dstport==38472
    ${UEContextSetupRequest_time_list}=    wireshark.get_field_value_by_xpath   xpath=.//frame.time_epoch
    Load Pcap File with Filter
     ...                        pcap_file=${TCPDUMP_PATH}
     ...                        record_type=Cu
     ...                        input_type=12
     ...                        filter=tcp.dstport==${dcap_server_port}
    ${xpath_ueDuC_e}   set variable   .//nsetapx.ueDuConnectivityRecord/nsetapx.data_element/nsetapx.setupData//nsetapx.DuUeCtxSetupData_element
    ${xpath_gnb_Id_e}   set variable   /nsetapx.gnb_du_Ids_element/nsetapx.gnb_Id_element
    ${result_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ueDuC_e}/nsetapx.result
    ${gnb_du_Id_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ueDuC_e}/nsetapx.gnb_du_Ids_element/nsetapx.gnb_du_Id
    ${plmn_Identity_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ueDuC_e}${xpath_gnb_Id_e}/nsetapx.plmn_Identity
    ${gnb_id_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ueDuC_e}${xpath_gnb_Id_e}/nsetapx.gnb_Id/nsetapx.gnb_id
    ${gnb_id_showname_list}   wireshark.get_field_value_by_xpath
    ...   xpath=${xpath_ueDuC_e}${xpath_gnb_Id_e}/nsetapx.gnb_Id/nsetapx.gnb_id   attribute_name=showname
    ${gnb_cu_ue_f1ap_Id_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ueDuC_e}/nsetapx.gnb_cu_ue_f1ap_Id
    ${gnb_du_ue_f1ap_Id_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ueDuC_e}/nsetapx.gnb_du_ue_f1ap_Id
    ${initialTime_list}=    wireshark.get_field_value_by_xpath
    ...   xpath=${xpath_ueDuC_e}/nsetapx.initialUeRrcMessageTransferRcvTime_element/nsetapx.seconds
    ${ueCtxSetupReqSndTime_list}=    wireshark.get_field_value_by_xpath
    ...   xpath=${xpath_ueDuC_e}/nsetapx.ueCtxSetupReqSndTime_element/nsetapx.seconds
    ${ueCtxSetupCmplRcvTime_list}=    wireshark.get_field_value_by_xpath
    ...   xpath=${xpath_ueDuC_e}/nsetapx.ueCtxSetupCmplRcvTime_element/nsetapx.seconds

    ${crnti_list}=    wireshark.get_field_value_by_xpath   xpath=.//nsetapx.crnti
    ${crnti_single_list}   Remove Duplicates   ${crnti_list}
    ${crnti_single_length}=  Get Length   ${crnti_single_list}
    ${result_length}=   Get Length   ${result_list}

    ${record_expected_times}=   Evaluate   2*${crnti_single_length}
    run keyword if   ${record_expected_times} == 0   fail
    ...   ELSE  Should Contain X Times   ${result_list}   0   ${record_expected_times}
    ${MRBTS_ID}=   Convert To String   ${MRBTS_ID}

    FOR   ${idx}    IN RANGE    0   ${crnti_single_length}
        ${idxf}   evaluate  ${idx}*2
        ${idxs}   evaluate  ${idx}*2+1
        Should Be True   ${result_list}[${idxf}] == ${result_list}[${idxs}]
        Should Be True   ${gnb_cu_ue_f1ap_Id_list}[${idxf}] == ${gnb_cu_ue_f1ap_Id_list}[${idxs}] == ${f1ap_GNB_CU_UE_F1AP_ID_list}[${idx}]
        Should Be True   ${gnb_du_ue_f1ap_Id_list}[${idxf}] == ${gnb_du_ue_f1ap_Id_list}[${idxs}]== ${f1ap_GNB_DU_UE_F1AP_ID_list}[${idx}]
        Should Be True   '${gnb_id_list}[${idxf}]' == '${gnb_id_list}[${idxs}]'
        should contain   ${gnb_id_showname_list}[${idxf}]   ${gNbIdLength}
        should contain   ${gnb_id_showname_list}[${idxf}]   ${MRBTS_ID}
        Should Be True   '${plmn_Identity_list}[${idxf}]' == '${plmn_Identity_list}[${idxs}]'
        ${plman_clear}   Remove String   ${plmn_Identity_list}[${idxf}]   :
        Should Be True   '${plman_clear}' == '${PLMN_IDENTITY}'
        Should Not Be Empty    ${gnb_du_Id_list}[${idx}]
        Should Not Be Empty    ${initialTime_list}[${idx}]
        Should Not Be Empty    ${ueCtxSetupReqSndTime_list}[${idx}]
        Should Not Be Empty    ${ueCtxSetupReqSndTime_list}[${idx}]

    END

Case Setup: EA_23
    Log To Console   Case Setup: EA_23

Case Teardown: EA_23
    Log To Console   Case Setup: EA_23
