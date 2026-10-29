*** Settings ***
Documentation
...   Author: liangliang.heng@nokia-sbell.com
Resource   ../Resource/Common.robot

*** Variables ***
${MRBTS_ID}   ${tl.gnbs[0].instance_id}
${NRBTS_ID}   ${tl.gnbs[0].global_bts_id}

*** Keyword ***
EA_24_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_DU_UE_context_setup_Trace_Record
#    log to console     &{FR1}
    # ${ssbScs}   ${chbw}   ${arfcnSsbPbch}   Get frequencyinfo from webui
    ${SCS}=    create dictionary    15 KHz=0   30 KHz=1   60 KHz=2
    ${scs_d}   set variable   ${FR1}[${ssbScs}]
    ${Bandwidth_index}   set variable   ${scs_d}[${chbw}]
     Load Pcap File with Filter any Expression
     ...                        pcap_file=${TCPDUMP_PATH}
     ...                          any_expression=f1ap.procedureCode == 12
     ...                        filter=sctp.dstport==38472
    ${xpath_f1ap_e1}   set variable   .//f1ap.F1AP_PDU/f1ap.initiatingMessage_element/f1ap.value_element
    ${xpath_f1ap_e2}   set variable   /f1ap.DLRRCMessageTransfer_element/f1ap.protocolIEs//f1ap.ProtocolIE_Field_element/f1ap.value_element/
    ${f1ap_GNB_CU_UE_F1AP_ID_mutil_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_f1ap_e1}${xpath_f1ap_e2}/f1ap.GNB_CU_UE_F1AP_ID
    ${f1ap_GNB_DU_UE_F1AP_ID_mutil_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_f1ap_e1}${xpath_f1ap_e2}/f1ap.GNB_DU_UE_F1AP_ID
    ${f1ap_GNB_CU_UE_F1AP_ID_list}   Remove Duplicates   ${f1ap_GNB_CU_UE_F1AP_ID_mutil_list}
    ${f1ap_GNB_DU_UE_F1AP_ID_list}   Remove Duplicates   ${f1ap_GNB_DU_UE_F1AP_ID_mutil_list}

    log to console     check elemnet  UE_context_setup_Trace_Record
    Load Pcap File with Filter
     ...                        pcap_file=${TCPDUMP_PATH}
     ...                        record_type=Du
     ...                        input_type=1
     ...                        filter=tcp.dstport==${dcap_server_port}
    ${xpath_ueCtxSetup_e}   set variable   .//nsetapx.ueCtxSetupRecord/nsetapx.data_r1_element
    ${result_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ueCtxSetup_e}/nsetapx.result
    ${gnb_cu_ue_f1ap_Id_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ueCtxSetup_e}/nsetapx.gnb_cu_ue_f1ap_Id
    ${gnb_du_ue_f1ap_Id_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ueCtxSetup_e}/nsetapx.gnb_du_ue_f1ap_Id
    ${ssbSubcarrierSpacing}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ueCtxSetup_e}/nsetapx.ssbSubcarrierSpacing
    ${dlCarrierBandwidthTdd}=   wireshark.get_field_value_by_xpath
    ...   xpath=${xpath_ueCtxSetup_e}/nsetapx.dlCarrierBandwidthTdd   attribute_name=showname
#    ${dlCarrierBandwidthTdd_index}   Should Match Regexp   dlCarrierBandwidthTdd: n273 (28)   n\\d+
#    ${dlCarrierBandwidthTdd_index}   Should Match Regexp   ${dlCarrierBandwidthTdd}[0]   n\\d+
    ${absoluteFrequencySsb}=   wireshark.get_field_value_by_xpath   xpath=${xpath_ueCtxSetup_e}/nsetapx.absoluteFrequencySsb
    ${ueCtxSetupCmplSndTime_list}=  wireshark.get_field_value_by_xpath
    ...   xpath=${xpath_ueCtxSetup_e}/nsetapx.ueCtxSetupCmplSndTime_element/nsetapx.seconds
    ${ueCtxSetupReqRcvTime_list}=   wireshark.get_field_value_by_xpath
    ...   xpath=${xpath_ueCtxSetup_e}/nsetapx.ueCtxSetupReqRcvTime_element/nsetapx.seconds
    ${initialTime_list}=  wireshark.get_field_value_by_xpath
    ...   xpath=${xpath_ueCtxSetup_e}/nsetapx.initialUeRrcMessageTransferSndTime_element/nsetapx.seconds
    ${crnti_list}=    wireshark.get_field_value_by_xpath   xpath=.//nsetapx.crnti
    ${crnti_single_list}   Remove Duplicates   ${crnti_list}
    ${crnti_single_length}=  Get Length   ${crnti_single_list}
    ${result_length}=   Get Length   ${result_list}
    ${record_expected_times}=   Evaluate   2*${crnti_single_length}
    run keyword if   ${record_expected_times} == 0   fail
    ...   ELSE  Should Contain X Times   ${result_list}   0   ${record_expected_times}
#
    FOR   ${idx}    IN RANGE    0   ${crnti_single_length}
        ${idxf}   evaluate  ${idx}*2
        ${idxs}   evaluate  ${idx}*2+1
        Should Be True   ${result_list}[${idxf}] == ${result_list}[${idxs}]
        Should Be True   ${gnb_cu_ue_f1ap_Id_list}[${idxf}] == ${gnb_cu_ue_f1ap_Id_list}[${idxs}] == ${f1ap_GNB_CU_UE_F1AP_ID_list}[${idx}]
        Should Be True   ${gnb_du_ue_f1ap_Id_list}[${idxf}] == ${gnb_du_ue_f1ap_Id_list}[${idxs}]== ${f1ap_GNB_DU_UE_F1AP_ID_list}[${idx}]
        Should Be True   ${ssbSubcarrierSpacing}[${idxf}] == ${ssbSubcarrierSpacing}[${idxs}] == ${SCS}[${ssbScs}]
        ${dlCarrierBandwidthTdd_f}   Should Match Regexp   ${dlCarrierBandwidthTdd}[${idxf}]   n\\d+
        ${dlCarrierBandwidthTdd_s}   Should Match Regexp   ${dlCarrierBandwidthTdd}[${idxs}]   n\\d+
        Should Be True   '${dlCarrierBandwidthTdd_f}' == '${dlCarrierBandwidthTdd_s}' == 'n${Bandwidth_index}'
        Should Be True   ${absoluteFrequencySsb}[${idxf}] == ${absoluteFrequencySsb}[${idxs}] == ${arfcnSsbPbch}
        Should Not Be Empty    ${initialTime_list}[${idx}]
        Should Not Be Empty    ${ueCtxSetupCmplSndTime_list}[${idx}]
        Should Not Be Empty    ${ueCtxSetupReqRcvTime_list}[${idx}]
    END


Case Setup: EA_24
    Log To Console   Case Setup: EA_24

Case Teardown: EA_24
    Log To Console   Case Teardown: EA_24
