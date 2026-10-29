*** Settings ***
Documentation
...   Author: liping.hong@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
CB008208-5G-A-19_Classical_DU_UE_context_setup_and_bearer_data_reporting_on_target_cell_during_NSA_Intra-DU_handover
    log to console     check elemnet  DU_UE_context_setup_and_bearer_data_reporting
    ${SCS}=    create dictionary    15 KHz=0   30 KHz=1   60 KHz=2
    ${scs_d}   set variable   ${FR1}[${ssbScs}]
    ${Bandwidth_index}   set variable   ${scs_d}[${chbw}]
    ${dutype}   set variable   nsetapx.DuVendorExtensionRecordDataType
    ${NSA_INTRA_target_crnti_HO_length}=  Get Length   ${NSA_INTRA_target_crnti_HO_list}
    ${xpath_ueCtxSetup_e}   set variable   .//nsetapx.ueCtxSetupRecord/nsetapx.data_r1_element
    FOR   ${idx}    IN RANGE    0   ${NSA_INTRA_target_crnti_HO_length}
         Load Pcap File with Filter any Expression
         ...                        pcap_file=${NSA_INTRA_gNB_HO_PATH}
         ...                        any_expression=${dutype}==1&&nsetapx.crnti==${NSA_INTRA_target_crnti_HO_list}[${idx}]
         ...                        filter=sctp.dstport==${dcap_server_port}
        ${xpath_ueCtxSetup_e}   set variable   .//nsetapx.ueCtxSetupRecord/nsetapx.data_r1_element
        ${gnb_cu_ue_f1ap_Id_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ueCtxSetup_e}/nsetapx.gnb_cu_ue_f1ap_Id
        ${gnb_cu_ue_f1ap_Id_length}=  Get Length   ${gnb_cu_ue_f1ap_Id_list}
        ${result_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ueCtxSetup_e}/nsetapx.result
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

         Load Pcap File with Filter any Expression
         ...                        pcap_file=${NSA_INTRA_gNB_HO_PATH}
         ...                        any_expression=${dutype}==13&&nsetapx.crnti==${NSA_INTRA_target_crnti_HO_list}[${idx}]
         ...                        filter=sctp.dstport==${dcap_server_port}
         ${xpath_dubear_e}   set variable   .//nsetapx.bearerRecord/nsetapx.data_element/nsetapx.setupBearers//nsetapx.DuBearerSetupItem_element
        ${xpath_Qos_e}   set variable   /nsetapx.eutran_Qos_element/nsetapx.arp_element/nsetapx.
        ${trigger_list}=    wireshark.get_field_value_by_xpath   xpath=.//nsetapx.bearerRecord/nsetapx.data_element/nsetapx.trigger
        ${DRBsetup_list}=    wireshark.get_field_value_by_xpath   xpath=.//nsetapx.bearerRecord/nsetapx.data_element/nsetapx.setupBearers
        ${DRB ID_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_dubear_e}/nsetapx.drb_Id
        ${EQOS_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_dubear_e}/nsetapx.eutran_Qos_element    attribute_name=showname
        ${QCI_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_dubear_e}/nsetapx.eutran_Qos_element/nsetapx.qci
        ${timestaps_list}=    wireshark.get_field_value_by_xpath   xpath=.//nsetapx.timestamp_element/nsetapx.seconds
        ${timestapus_list}=    wireshark.get_field_value_by_xpath   xpath=.//nsetapx.timestamp_element/nsetapx.useconds
        ${Priority level_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_dubear_e}${xpath_Qos_e}priorityLevel
        ${Pre-emption capability_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_dubear_e}${xpath_Qos_e}preemptionCapability
        ${Pre-emption vulnerability_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_dubear_e}${xpath_Qos_e}preemptionVulnerability

        Load Pcap File with Filter any Expression
         ...                        pcap_file=${NSA_INTRA_gNB_HO_PATH}
         ...                        any_expression=f1ap.id == 31&&f1ap.GNB_CU_UE_F1AP_ID == ${gnb_cu_ue_f1ap_Id_list}[0]
         ...                        filter=sctp.dstport==38472
        ${xpath_uectxreq_e1}   set variable
        ...   .//f1ap.F1AP_PDU/f1ap.initiatingMessage_element/f1ap.value_element/f1ap.UEContextModificationRequest_element
        ${xpath_uectxreq_e2}   set variable   /f1ap.protocolIEs//f1ap.ProtocolIE_Field_element/f1ap.value_element/f1ap.DRBs_ToBeModified_List
        ${xpath_uectxreq_e3}   set variable   //f1ap.ProtocolIE_SingleContainer_element/f1ap.value_element/f1ap.DRBs_ToBeModified_Item_element
        ${xpath_uectxreq_E4}   set variable   ${xpath_uectxreq_e1}${xpath_uectxreq_e2}${xpath_uectxreq_e3}/f1ap.qoSInformation/f1ap.eUTRANQoS_element
        ${xpath_uectxreq_E5}   set variable   ${xpath_uectxreq_E4}/f1ap.allocationAndRetentionPriority_element
        ${xpath_f1ap_e1}   set variable   /f1ap.protocolIEs//f1ap.ProtocolIE_Field_element/f1ap.value_element
        ${f1ap_GNB_DU_UE_F1AP_ID_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_uectxreq_e1}${xpath_f1ap_e1}/f1ap.GNB_DU_UE_F1AP_ID
        ${f1ap_DRBsetup_list}=     wireshark.get_field_value_by_xpath   xpath=${xpath_uectxreq_e1}${xpath_uectxreq_e2}
        ${f1ap_DRBID_list}=     wireshark.get_field_value_by_xpath   xpath=${xpath_uectxreq_e1}${xpath_uectxreq_e2}${xpath_uectxreq_e3}/f1ap.dRBID
        ${f1ap_QCI_list}=     wireshark.get_field_value_by_xpath   xpath=${xpath_uectxreq_E4}/f1ap.qCI
        ${f1ap_P-L_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_uectxreq_E5}/f1ap.priorityLevel
        ${f1ap_P-E-C_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_uectxreq_E5}/f1ap.pre_emptionCapability
        ${f1ap_P-E-V_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_uectxreq_E5}/f1ap.pre_emptionVulnerability
        Should Contain X Times   ${trigger_list}   3   1
        Should Contain X Times   ${result_list}   0   1
        Length Should Be   ${DRB ID_list}   1
        Length Should Be   ${QCI_list}   1
        Length Should Be   ${Priority level_list}   1
        Length Should Be   ${Pre-emption capability_list}   1
        Length Should Be   ${Pre-emption vulnerability_list}   1
        Should Be True   ${f1ap_GNB_DU_UE_F1AP_ID_list} == ${gnb_du_ue_f1ap_Id_list}
        Should Be True   ${ssbSubcarrierSpacing}[0]== ${SCS}[${ssbScs}]
        ${dlCarrierBandwidthTdd_f}   Should Match Regexp   ${dlCarrierBandwidthTdd}[${idx}]   n\\d+
        Should Be True   '${dlCarrierBandwidthTdd_f}' == 'n${Bandwidth_index}'
        Should Be True   ${absoluteFrequencySsb}[0] == ${arfcnSsbPbch}
        List Should Contain Value   ${EQOS_list}   eutran-Qos
        Should Be Empty    ${ueCtxSetupCmplSndTime_list}
        Should Be Empty    ${ueCtxSetupReqRcvTime_list}
        Should Be Empty    ${initialTime_list}
        Should Be True   ${f1ap_DRBsetup_list} == ${DRBsetup_list}
        Should Be True   ${DRB ID_list} == ${f1ap_DRBID_list}
        Should Be True   ${QCI_list} == ${f1ap_QCI_list}
        Should Be True   ${Priority level_list} == ${f1ap_P-L_list}
        Should Be True   ${Pre-emption capability_list} == ${f1ap_P-E-C_list}
        Should Be True   ${Pre-emption vulnerability_list} == ${f1ap_P-E-V_list}
    END
    Log To Console   check value is OK



Case Setup: CB008208-5G-A-19
    Log To Console   Case Setup: CB008208-5G-A-19
    ${file_status}   run keyword and return status   File Should Not Be Empty   ${NSA_INTRA_gNB_HO_PATH}
    ${HO_status}   run keyword and return status   should not be empty   ${NSA_INTRA_target_crnti_HO_list}
    set test variable   ${file_status}
    set test variable   ${HO_status}
    Run Keyword If   '${file_status}'=='False' or '${HO_status}'=='False'   Run Keywords
    ...   Common Setup 1756   AND
    ...   Remove And Add PCMD Object   AND
    ...   Trigger INTRA gNB HO   ${NSA_ue_index}    ${NSA_INTRA_gNB_HO_FILE}   NSA
    run keyword if  '${file_status}'=='False' or '${HO_status}'=='False'   Get Variables from HO File for CB008208-5G-A-19

Get Variables from HO File for CB008208-5G-A-19
#    ${NSA_INTRA_target_crnti_HO_list}   ${NSA_INTRA_source_crnti_HO_list}   Get nrcti of Target and Source HO   ${NSA_INTRA_gNB_HO_PATH}
#    ...   nsetapx.CuVendorExtensionRecordDataType == 9   nsetapx.CuVendorExtensionRecordDataType == 8
    ${NSA_INTRA_target_crnti_HO_list}   ${NSA_INTRA_source_crnti_HO_list}   Get nrcti of Target and Source in NSA intra HO   ${NSA_INTRA_gNB_HO_PATH}
    set suite variable   ${NSA_INTRA_target_crnti_HO_list}
    set suite variable   ${NSA_INTRA_source_crnti_HO_list}

Case Teardown: CB008208-5G-A-19
    Log To Console   Case Teardown: CB008208-5G-A-19
    Run Keyword If   '${file_status}'=='False' or '${HO_status}'=='False'   Run Keywords
    ...   Initialize PA   AND
    ...   Common Teardown 1756
