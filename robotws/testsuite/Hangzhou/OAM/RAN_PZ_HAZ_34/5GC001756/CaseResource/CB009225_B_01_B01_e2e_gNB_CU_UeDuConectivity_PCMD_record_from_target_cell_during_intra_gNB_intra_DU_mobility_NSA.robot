*** Settings ***
Documentation
...    author: Jing.Qu@nokia-sbell.com
...    this case will verify keyword for TA of CB009225-B B01

Resource   ../Resource/Common.robot
Library     ../Library/list_time_check.py

*** Variables ***



*** Keywords ***
CB009225_B_01_B01_e2e_gNB_CU_UeDuConectivity_PCMD_record_from_target_cell_during_intra_gNB_intra_DU_mobility_NSA
    Set Test Variable     ${Pcap_file_path}    ${NSA_INTRA_gNB_HO_PATH}
    # Step 1: Set xpath which used for find the value in message
    Set UEContextModificationRequest Xpath
    Set UeDuConnectivityRecord Xpath
    # Step 2: Get info from UEcontextmodificationrequest which intiate for NSA intr-DU handover
    ${info_signal}    Get UEContextModificationRequest Content for PScell Change
    # Step 3: Get info from record which generate for NSA intra-DU handover from target cell, CB009225-B B01
    ${info_record}    Get UeDuConnectivityRecord for PScell Change
    # Step 4: Compare signal info and Record info
    Should Be True    ${info_signal}==${info_record}


Get UEContextModificationRequest Content for PScell Change
    [Documentation]  will filter the UeContextModificationRequest which used for PScell Change
    [Arguments]  ${Pcap_file_path}=${Pcap_file_path}
    Load Pcap File with Filter any Expression
    ...   pcap_file=${Pcap_file_path}
    ...   any_expression=f1ap.procedureCode == 7 && nr-rrc.measResultNeighCellListNR >= 1
    ...   filter=sctp.dstport==38472
    ${request_list}   Check Field Value By Xpath    xpath=.//frame.number
    ${cellIdentity_list}   Check Field Value By Xpath    xpath=${cellIdentity_signal}
    ${plmn_list}   Check Field Value By Xpath    xpath=${plmn_signal}
    ${cu_ue_f1ap_signal_list}   Check Field Value By Xpath    xpath=${cu_ue_f1ap_path_signal}
    ${du_ue_f1ap_signal_list}   Check Field Value By Xpath    xpath=${du_ue_f1ap_path_signal}
    ${signal_list}     Create List
    ${PScell_change_times}    Get Length    ${request_list}
    FOR     ${index}     IN RANGE     ${PScell_change_times}
        ${dic_item}    Create Dictionary
#        ...    frame=${request_list}[${index}]
        ...    cellidentity=${cellIdentity_list}[${index}]
        ...    plmn=${plmn_list}[${index}]
        ...    cu_ue_f1ap=${cu_ue_f1ap_signal_list}[${index}]
        ...    du_ue_f1ap=${du_ue_f1ap_signal_list}[${index}]
        Append To List    ${signal_list}    ${dic_item}
    END
    [Return]  ${signal_list}

Get UeDuConnectivityRecord for PScell Change
    [Documentation]  will filter the UeDuConnectivityRecord which used for PScell Change on Traget Cell
    ...   Note: this keyword for classical gNB, du_id check always 0.
    [Arguments]  ${Pcap_file_path}=${Pcap_file_path}
    Load Pcap File with Filter any Expression
    ...   pcap_file=${Pcap_file_path}
    ...   any_expression=nsetapx.setupData && nsetapx.CuVendorExtensionRecordDataType == 12 && !nsetapx.ueCtxSetupReqSndTime_element
    ...   filter=sctp.dstport==49148
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
        Should Be True    ${du_id}[${index}] == 0
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

Set UEContextModificationRequest Xpath
    Set Test Variable    ${base_structure}    .//f1ap.UEContextModificationRequest_element/f1ap.protocolIEs
    Set Test Variable    ${cu_ue_f1ap_path_signal}    ${base_structure}//f1ap.ProtocolIE_Field_element/f1ap.value_element/f1ap.GNB_CU_UE_F1AP_ID
    Set Test Variable    ${du_ue_f1ap_path_signal}    ${base_structure}//f1ap.ProtocolIE_Field_element/f1ap.value_element/f1ap.GNB_DU_UE_F1AP_ID
    Set Test Variable    ${cellIdentity_signal}
    ...    ${base_structure}//f1ap.ProtocolIE_Field_element/f1ap.value_element/f1ap.NRCGI_element/f1ap.nRCellIdentity
    Set Test Variable    ${plmn_signal}
    ...    ${base_structure}//f1ap.ProtocolIE_Field_element/f1ap.value_element/f1ap.NRCGI_element/f1ap.pLMN_Identity

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


