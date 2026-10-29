*** Settings ***
Documentation
...    author: Jing.Qu@nokia-sbell.com
...    this case will verify keyword for TA of CB009225-B B01

*** Variables ***
${Intra_gNB_Inter_DU_File_NSA}    Intra_gNB_inter_DU_NSA.pcap
${Intra_gNB_Inter_DU_File_NSA_path}   ${OUTPUT_DIR}/${Intra_gNB_Inter_DU_File_NSA}

*** Keywords ***
CB009225_B_04_B02_e2e_gNB_CU_UeDuConectivity_PCMD_record_intra_gNB_inter_DU_mobility_for_NSA_Cloud_gNB.robot
    Log To Console     \n Start To Anlysis CB009225-B Record Content
    Set Test Variable     ${Pcap_file_path}    ${Intra_gNB_Inter_DU_File_NSA_path}
    Set Xpath Variable To Get Info From Signal
    Set SgNBinitiatedSgNbModificationRecord Xpath
    Set UeDuConnectivityRecord Xpath
    ${status}    ${dir1}    Run Keyword And Ignore Error    Get Target NrCellId From UEContextSetupRequest for PScell Change
    ${status}    ${dir2}    Run Keyword And Ignore Error    Get CU_UE_F1AP And DU_UE_F1AP From UEContextSetupResponse
    ${status}    ${dir3}    Run Keyword And Ignore Error    Get X2AP_UE_ID From SgNBModificationRequired
    ${status}    ${dir4}    Run Keyword And Ignore Error    Get UeDuConnectivityRecord for PScell Change Cloud
    ${status}    ${dir5}    Run Keyword And Ignore Error    Get SgNBinitiatedSgNbModificationRecord content Cloud
    Dictionaries Should Be Equal    ${dir3}[0]     ${dir5}[0]
    Dictionary Should Contain Sub Dictionary    ${dir4}[0]    ${dir1}[0]
    Dictionary Should Contain Sub Dictionary    ${dir4}[0]    ${dir2}[0]

Get UeDuConnectivityRecord for PScell Change Cloud
    [Documentation]  will filter the UeDuConnectivityRecord which used for PScell Change on Traget Cell
    ...   Note: this keyword for cloud set DU2 will be handover target cell
    [Arguments]  ${Pcap_file_path}=${Pcap_file_path}
    Load Pcap File with Filter any Expression
    ...   pcap_file=${Pcap_file_path}
    ...   any_expression=nsetapx.CuVendorExtensionRecordDataType == 12 && nsetapx.ueCtxSetupReqSndTime_element && nsetapx.gnb_du_Id == 2
    ...   filter=sctp.dstport==${dcap_server_port}
    ${request_list}   Check Field Value By Xpath    xpath=.//frame.number
    ${cellIdentity_list}   Check Field Value By Xpath    xpath=${cellidentity_id}
    ${plmn_list}   Check Field Value By Xpath    xpath=${plmn_path}
    ${cu_ue_f1ap_signal_list}   Check Field Value By Xpath    xpath=${cu_ue_f1ap_path}
    ${du_ue_f1ap_signal_list}   Check Field Value By Xpath    xpath=${du_ue_f1ap_path}
    ${result}   Check Field Value By Xpath    xpath=${result_path}
    ${gNB_id}   Check Field Value By Xpath    xpath=${gNBid_path}
    ${du_id}   Check Field Value By Xpath    xpath=${duId_path}
    ${signal_list}     Create List
    ${PScell_change_times}    Get Length    ${request_list}
    FOR     ${index}     IN RANGE     ${PScell_change_times}
        Should Be True    ${du_id}[${index}] == 2
        Should Be True    ${result}[${index}] == 0
        ${dic_item}    Create Dictionary
#        ...    frame=${request_list}[${index}]
        ...    cellidentity=${cellIdentity_list}[${index}]
        ...    plmn=${plmn_list}[${index}]
        ...    cu_ue_f1ap=${cu_ue_f1ap_signal_list}[${index}]
        ...    du_ue_f1ap=${du_ue_f1ap_signal_list}[${index}]
        Append To List    ${signal_list}    ${dic_item}
    END
    [Return]  ${signal_list}

Get Target NrCellId From UEContextSetupRequest for PScell Change
    [Documentation]  will filter the UEContextSetupRequest which used for PScell Change
    [Arguments]  ${Pcap_file_path}=${Pcap_file_path}
    Load Pcap File with Filter any Expression
    ...   pcap_file=${Pcap_file_path}
    ...   any_expression=f1ap.procedureCode == 5 && nr-rrc.measResultNeighCellListNR >= 1 && nr-rrc.measResultServingCell_element
    ...   filter=sctp.dstport==38472
    ${request_list}   Check Field Value By Xpath    xpath=.//frame.number
    ${target_nrcellid_list}   Check Field Value By Xpath    xpath=${nrcellid_path}
    ${plmn_list}   Check Field Value By Xpath    xpath=${f1ap_plmn_path}
    ${signal_list}     Create List
    ${PScell_change_times}    Get Length    ${request_list}
    FOR     ${index}     IN RANGE     ${PScell_change_times}
        ${dic_item}    Create Dictionary
#        ...    frame=${request_list}[${index}]
        ...    cellidentity=${target_nrcellid_list}[${index}]
        ...    plmn=${plmn_list}[${index}]
        Append To List    ${signal_list}    ${dic_item}
    END
    [Return]  ${signal_list}

Get CU_UE_F1AP And DU_UE_F1AP From UEContextSetupResponse
    [Documentation]  will filter the UEContextSetupResponse which used for PScell Change
    ...   Not found very suitable filter to get CUUE and DUUE F1AP ID of Target DU
    [Arguments]  ${Pcap_file_path}=${Pcap_file_path}
    Load Pcap File with Filter any Expression
    ...   pcap_file=${Pcap_file_path}
    ...   any_expression=f1ap.procedureCode == 5 && f1ap.GNB_DU_UE_F1AP_ID && !nr-rrc.servedRadioBearer
    ...   filter=sctp.dstport==38472
    ${request_list}   Check Field Value By Xpath    xpath=.//frame.number
    ${cu_ue_f1ap_list}   Check Field Value By Xpath    xpath=${msg_cu_ue_f1ap_path}
    ${du_ue_f1ap_list}   Check Field Value By Xpath    xpath=${msg_du_ue_f1ap_path}
    ${signal_list}     Create List
    ${PScell_change_times}    Get Length    ${request_list}
    FOR     ${index}     IN RANGE     ${PScell_change_times}
        ${dic_item}    Create Dictionary
#        ...    frame=${request_list}[${index}]
        ...    cu_ue_f1ap=${cu_ue_f1ap_list}[${index}]
        ...    du_ue_f1ap=${du_ue_f1ap_list}[${index}]
        Append To List    ${signal_list}    ${dic_item}
    END
    [Return]  ${signal_list}

Get X2AP_UE_ID From SgNBModificationRequired
    [Documentation]  will filter the UeContextModificationRequest which used for PScell Change
    [Arguments]  ${Pcap_file_path}=${Pcap_file_path}
    Load Pcap File with Filter any Expression
    ...   pcap_file=${Pcap_file_path}
    ...   any_expression=x2ap.procedureCode==30 && x2ap.radioNetwork==0 && sctp.dstport==36422
    ...   filter=sctp.dstport==36422
    ${request_list}   Check Field Value By Xpath    xpath=.//frame.number
    ${SgNB_ue_x2ap_id_list}   Check Field Value By Xpath    xpath=${SgNB_ue_x2ap_id_path}
    ${MeNB_ue_x2ap_id_list}   Check Field Value By Xpath    xpath=${MeNB_ue_x2ap_id_path}
    ${signal_list}     Create List
    ${PScell_change_times}    Get Length    ${request_list}
    FOR     ${index}     IN RANGE     ${PScell_change_times}
        ${dic_item}    Create Dictionary
#        ...    frame=${request_list}[${index}]
        ...    sgnb_ue_x2ap_Id=${SgNB_ue_x2ap_id_list}[${index}]
        ...    menb_ue_x2ap_Id=${MeNB_ue_x2ap_id_list}[${index}]
        Append To List    ${signal_list}    ${dic_item}
    END
    [Return]  ${signal_list}

Get SgNBinitiatedSgNbModificationRecord content Cloud
    [Documentation]  will filter the UeDuConnectivityRecord which used for PScell Change on Traget Cell
    ...   Note: this keyword for cloud set DU2 will be handover target cell
    [Arguments]  ${Pcap_file_path}=${Pcap_file_path}
    Load Pcap File with Filter any Expression
    ...   pcap_file=${Pcap_file_path}
    ...   any_expression=nsetapx.CuVendorExtensionRecordDataType==5 && nsetapx.sgnbModificationReason==1
    ...   filter=sctp.dstport==${dcap_server_port}
    ${request_list}   Check Field Value By Xpath    xpath=.//frame.number
    ${sgnb_ue_x2ap_Id}   Check Field Value By Xpath    xpath=${nsetapx_sgnb_ue_x2ap_Id_path}
    ${menb_ue_x2ap_Id}   Check Field Value By Xpath    xpath=${nsetapx_menb_ue_x2ap_Id_path}
    ${eNBid}   Check Field Value By Xpath    xpath=${eNBid_path}
    ${signal_list}     Create List
    ${PScell_change_times}    Get Length    ${request_list}
    FOR     ${index}     IN RANGE     ${PScell_change_times}
        Should Be True    "${eNBid}[${index}]" == "02:8c:f0"
        ${dic_item}    Create Dictionary
#        ...    frame=${request_list}[${index}]
        ...    sgnb_ue_x2ap_Id=${sgnb_ue_x2ap_Id}[${index}]
        ...    menb_ue_x2ap_Id=${menb_ue_x2ap_Id}[${index}]
        Append To List    ${signal_list}    ${dic_item}
    END
    [Return]  ${signal_list}

Set Xpath Variable To Get Info From Signal
    Set Test Variable    ${msg_cu_ue_f1ap_path}    .//f1ap.GNB_CU_UE_F1AP_ID
    Set Test Variable    ${msg_du_ue_f1ap_path}    .//f1ap.GNB_DU_UE_F1AP_ID
    Set Test Variable    ${nrcellid_path}       .//f1ap.nRCellIdentity
    Set Test Variable    ${f1ap_plmn_path}           .//f1ap.pLMN_Identity
    Set Test Variable    ${SgNB_ue_x2ap_id_path}           .//x2ap.SgNB_UE_X2AP_ID
    Set Test Variable    ${MeNB_ue_x2ap_id_path}           .//x2ap.UE_X2AP_ID

Set UeDuConnectivityRecord Xpath
    Set Test Variable    ${cellidentity_id}
    ...    //nsetapx.ueDuConnectivityRecord/ancestor::nsetapx.recordingSessionReportList/../nsetapx.cellId/nsetapx.nrcgi_element/nsetapx.cellIdentity
    Set Test Variable    ${base_structure}    .//nsetapx.DuUeCtxSetupData_element
    Set Test Variable    ${result_path}    ${base_structure}/nsetapx.result
    Set Test Variable    ${duId_path}    ${base_structure}/nsetapx.gnb_du_Ids_element/nsetapx.gnb_du_Id
    Set Test Variable    ${cu_ue_f1ap_path}    ${base_structure}/nsetapx.gnb_cu_ue_f1ap_Id
    Set Test Variable    ${du_ue_f1ap_path}    ${base_structure}/nsetapx.gnb_du_ue_f1ap_Id
    Set Test Variable    ${plmn_path}    ${base_structure}/nsetapx.gnb_du_Ids_element/nsetapx.gnb_Id_element/nsetapx.plmn_Identity
    Set Test Variable    ${gNBid_path}    ${base_structure}/nsetapx.gnb_du_Ids_element/nsetapx.gnb_Id_element/nsetapx.gnb_Id/nsetapx.gnb_id

Set SgNBinitiatedSgNbModificationRecord Xpath
    Set Test Variable    ${nsetapx_sgnb_ue_x2ap_Id_path}    .//nsetapx.sgnb_ue_x2ap_Id
    Set Test Variable    ${nsetapx_menb_ue_x2ap_Id_path}    .//nsetapx.menb_ue_x2ap_Id
    Set Test Variable    ${eNBid_path}    .//nsetapx.macro_eNB_Id
