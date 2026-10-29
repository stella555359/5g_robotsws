*** Settings ***

*** Variables ***
# gNB-CU UE F1AP ID,
# gNB-CU-CP UE E1AP ID
# gNB NGAP UE ID
# SgNB UE X2AP ID
# gNB XnAP ID
${ranueid_filt}   nsetapx.ranUeId
${e1apid_filt}   e1ap.GNB_CU_CP_UE_E1AP_ID
${xnap_src_id_filt}   nsetapx.src_ng_rannode_ue_xnap_Id
${xnap_tgt_id_filt}   nsetapx.tgt_ng_rannode_ue_xnap_Id
${f1apid_filt}   nsetapx.gnb_cu_ue_f1ap_Id
${ngapid_filt}   nsetapx.ran_ue_ngap_Id
${x2apid_filt}   nsetapx.sgnb_ue_x2ap_Id

*** Keyword ***
Cloud Check PCMD RAN UE ID
    [Arguments]   ${pcmd_file_path}   ${HO_file_type}=NONE

    # Load Pcap File with Filter any Expression
    # ...   pcap_file=${pcmd_file_path}
    # ...   any_expression=nsetapx.recordingSessionReportList==0||nsetapx.recordingSessionReportList==2
    # ...   filter=sctp.dstport==${dcap_server_port}
    # ${all_record_list}   wireshark.get_field_value_by_xpath   xpath=.
    # ${ranueid_record_list}   wireshark.get_field_value_by_xpath   xpath=.//nsetapx.ranUeId
    # ${all_record_number}   Get Length   ${all_record_list}
    # ${ranueid_record_number}   Get Length   ${ranueid_record_list}
    # Should Be Equal   ${all_record_number}   ${ranueid_record_number}
    Load Pcap File with Filter any Expression
    ...   pcap_file=${pcmd_file_path}
    ...   any_expression=nsetapx && !nsetapx.ranUeId && nsetapx.TraceMessage != 1 && nsetapx.TraceMessage != 2 && nsetapx.TraceMessage != 3
    ...   filter=sctp.dstport==${dcap_server_port}
    ${miss_record_list}   wireshark.get_field_value_by_xpath   xpath=.
    Log To Console   ${miss_record_list}
    Should Be Empty   ${miss_record_list}

    Load Pcap File with Filter any Expression
    ...   pcap_file=${pcmd_file_path}
    ...   any_expression=${ranueid_filt}||${e1apid_filt}||${xnap_src_id_filt}||${xnap_tgt_id_filt}||${f1apid_filt}||${ngapid_filt}||${x2apid_filt}
    ...   filter=sctp.dstport==${dcap_server_port}
    ${ranUeId_List}   wireshark.get_field_value_by_xpath   xpath=.//nsetapx.ranUeId
    ${ranUeId_List}   Remove Duplicates   ${ranUeId_List}
    ${ranUeId_Number}   Create List
    FOR   ${ranUeId}   IN   @{ranUeId_List}
        ${ranUeId}   Replace String   ${ranUeId}   :   ${SPACE}
        ${ranUeId}   Convert To Integer   ${ranUeId}   16
        Append To List   ${ranUeId_Number}   ${ranUeId}
    END

    ${GNB_CU_CP_UE_E1AP_ID_LIST}   wireshark.get_field_value_by_xpath   xpath=.//e1ap.GNB_CU_CP_UE_E1AP_ID
    ${GNB_CU_CP_UE_E1AP_ID_LIST}   Remove Duplicates   ${GNB_CU_CP_UE_E1AP_ID_LIST}
    ${GNB_CU_CP_UE_E1AP_ID_Number}   Create List
    FOR   ${GNB_CU_CP_UE_E1AP_ID}   IN   @{GNB_CU_CP_UE_E1AP_ID_LIST}
        ${GNB_CU_CP_UE_E1AP_ID}   Convert To Integer   ${GNB_CU_CP_UE_E1AP_ID}
        Append To List   ${GNB_CU_CP_UE_E1AP_ID_Number}   ${GNB_CU_CP_UE_E1AP_ID}
    END

    ${xnap_src_id_LIST}   wireshark.get_field_value_by_xpath   xpath=.//nsetapx.src_ng_rannode_ue_xnap_Id
    ${xnap_src_id_LIST}   Remove Duplicates   ${xnap_src_id_LIST}
    ${xnap_src_id_Number}   Create List
    FOR   ${xnap_src_id}   IN   @{xnap_src_id_LIST}
        ${xnap_src_id}   Convert To Integer   ${xnap_src_id}
        Append To List   ${xnap_src_id_Number}   ${xnap_src_id}
    END

    ${xnap_tgt_id_LIST}   wireshark.get_field_value_by_xpath   xpath=.//nsetapx.tgt_ng_rannode_ue_xnap_Id
    ${xnap_tgt_id_LIST}   Remove Duplicates   ${xnap_tgt_id_LIST}
    ${xnap_tgt_id_Number}   Create List
    FOR   ${xnap_tgt_id}   IN   @{xnap_tgt_id_LIST}
        ${xnap_tgt_id}   Convert To Integer   ${xnap_tgt_id}
        Append To List   ${xnap_tgt_id_Number}   ${xnap_tgt_id}
    END

    ${gnb_cu_ue_f1ap_Id_LIST}   wireshark.get_field_value_by_xpath   xpath=.//nsetapx.gnb_cu_ue_f1ap_Id
    ${gnb_cu_ue_f1ap_Id_LIST}   Remove Duplicates   ${gnb_cu_ue_f1ap_Id_LIST}
    ${gnb_cu_ue_f1ap_Id_Number}   Create List
    FOR   ${gnb_cu_ue_f1ap_Id}   IN   @{gnb_cu_ue_f1ap_Id_LIST}
        ${gnb_cu_ue_f1ap_Id}   Convert To Integer   ${gnb_cu_ue_f1ap_Id}
        Append To List   ${gnb_cu_ue_f1ap_Id_Number}   ${gnb_cu_ue_f1ap_Id}
    END

    ${sgnb_ue_x2ap_Id_LIST}   wireshark.get_field_value_by_xpath   xpath=.//nsetapx.sgnb_ue_x2ap_Id
    ${sgnb_ue_x2ap_Id_LIST}   Remove Duplicates   ${sgnb_ue_x2ap_Id_LIST}
    ${sgnb_ue_x2ap_Id_Number}   Create List
    FOR   ${sgnb_ue_x2ap_Id}   IN   @{sgnb_ue_x2ap_Id_LIST}
        ${sgnb_ue_x2ap_Id}   Convert To Integer   ${sgnb_ue_x2ap_Id}
        Append To List   ${sgnb_ue_x2ap_Id_Number}   ${sgnb_ue_x2ap_Id}
    END

    ${ran_ue_ngap_Id_LIST}   wireshark.get_field_value_by_xpath   xpath=.//nsetapx.ran_ue_ngap_Id
    ${ran_ue_ngap_Id_LIST}   Remove Duplicates   ${ran_ue_ngap_Id_LIST}
    ${ran_ue_ngap_Id_Number}   Create List
    FOR   ${ran_ue_ngap_Id}   IN   @{ran_ue_ngap_Id_LIST}
        ${ran_ue_ngap_Id}   Convert To Integer   ${ran_ue_ngap_Id}
        Append To List   ${sgnb_ue_x2ap_Id_Number}   ${ran_ue_ngap_Id}
    END

    Log To Console   ranUeId: ${ranUeId_Number}
    Log To Console   GNB_CU_CP_UE_E1AP_ID: ${GNB_CU_CP_UE_E1AP_ID_Number}
    Log To Console   xnap_src_id: ${xnap_src_id_Number}
    Log To Console   xnap_tgt_id: ${xnap_tgt_id_Number}
    Log To Console   gnb_cu_ue_f1ap_Id: ${gnb_cu_ue_f1ap_Id_Number}
    Log To Console   sgnb_ue_x2ap_Id: ${sgnb_ue_x2ap_Id_Number}
    Log To Console   ran_ue_ngap_Id: ${ran_ue_ngap_Id_Number}

    List Should Contain Sub List   ${ranUeId_Number}   ${GNB_CU_CP_UE_E1AP_ID_Number}
    List Should Contain Sub List   ${ranUeId_Number}   ${gnb_cu_ue_f1ap_Id_Number}
    List Should Contain Sub List   ${ranUeId_Number}   ${sgnb_ue_x2ap_Id_Number}
    List Should Contain Sub List   ${ranUeId_Number}   ${ran_ue_ngap_Id_Number}
    Run Keyword If   '${HO_file_type}'=='source'   List Should Contain Sub List   ${ranUeId_Number}   ${xnap_src_id_Number}
    Run Keyword If   '${HO_file_type}'=='target'   List Should Contain Sub List   ${ranUeId_Number}   ${xnap_tgt_id_Number}
