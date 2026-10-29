*** Settings ***
Documentation    author: Jing.Qu@nokia-sbell.com

Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001756/Resource/Common.robot


*** Variables ***
${dcap_server_port}     49148


*** Keywords ***
SgNBReleaseRecord Verify Inter_MeNB handover Without PScell Change
    [Documentation]      this case for CRT enhance about customer PR02183839
    Set Test Variable     ${Pcap_file_path}    ${NSA_INTER_MeNB_HO_PATH}
    # Step1: Set the xpath about field in singal and record to check info
    Set SgNBReleaseRequest Xpath
    Set SgNBReleaseRecord Xpath
    # Step2: Get ue_x2ap id <> MeNB and SgNB from sginal orginal for compare
    ${MeNB_ue_x2ap_and_SgNB_ue_x2ap_dic}    Get SgNBRelease signal Content
    # Step3: Get Record x2ap id <> MeNB and SgNB from record to compare with signal content
    ${record_x2apid_list}    Get SgNBReleaseRecord Content
    # Step4: Compare with Signal and record Content
    Lists Should Be Equal    ${MeNB_ue_x2ap_and_SgNB_ue_x2ap_dic}     ${record_x2apid_list}


Get SgNBRelease signal Content
    [Documentation]  will filter the MeNBinitiatedSgNBRelease which used for inter_MeNB handover
    [Arguments]  ${Pcap_file_path}=${Pcap_file_path}
    Load Pcap File with Filter any Expression
    ...   pcap_file=${Pcap_file_path}
    ...   any_expression=x2ap.procedureCode == 31 && x2ap.radioNetwork == 46 && sctp.srcport == 36422
    ...   filter=sctp.dstport==36422
    ${frame_num_list}   Check Field Value By Xpath    xpath=.//frame.number
    ${frame_time_list}   Check Field Value By Xpath    xpath=//frame.time_epoch
    ${menb_ue_x2ap_id_signal}   Check Field Value By Xpath    xpath=${menb_ue_x2ap_id_signal_path}
    ${sgNB_ue_x2ap_id_signal}   Check Field Value By Xpath    xpath=${sgNB_ue_x2ap_id_signal_path}
    ${signal_list}     Create List
    ${frame_lenth}    Get Length    ${frame_num_list}
    FOR     ${index}     IN RANGE     ${frame_lenth}
        ${dic_item}    Create Dictionary
#        ...    frame=${frame_num_list}[${index}]
#        ...    sgnbReleaseReqTime=${frame_time_list}[${index}]
        ...    menb_ue_x2ap_Id=${menb_ue_x2ap_id_signal}[${index}]
        ...    sgnb_ue_x2ap_Id=${sgNB_ue_x2ap_id_signal}[${index}]
        Append To List    ${signal_list}    ${dic_item}
    END
    [Return]    ${signal_list}

Get SgNBReleaseAck Frame Info
    [Documentation]  Get all SgNBReleaseAck frame num and time, include normal release
    [Arguments]  ${Pcap_file_path}=${Pcap_file_path}
    Load Pcap File with Filter any Expression
    ...   pcap_file=${Pcap_file_path}
    ...   any_expression=x2ap.SgNBReleaseRequestAcknowledge_element
    ...   filter=sctp.dstport==36422
    ${frame_num_list}   Check Field Value By Xpath    xpath=.//frame.number
    ${frame_time_list}   Check Field Value By Xpath    xpath=//frame.time_epoch
    ${signal_list}     Create List
    ${frame_lenth}    Get Length    ${frame_num_list}
    FOR     ${index}     IN RANGE     ${frame_lenth}
        ${dic_item}    Create Dictionary
        ...    frame=${frame_num_list}[${index}]
        ...    sgnbReleaseRespTime=${frame_time_list}[${index}]
        Append To List    ${signal_list}    ${dic_item}
    END
    [Return]  ${signal_list}

Get UeContextRelease Frame Info
    [Documentation]  Get all UeContextRelease frame num and time, include normal release
    [Arguments]  ${Pcap_file_path}=${Pcap_file_path}
    Load Pcap File with Filter any Expression
    ...   pcap_file=${Pcap_file_path}
    ...   any_expression=x2ap.procedureCode == 5
    ...   filter=sctp.dstport==36422
    ${frame_num_list}   Check Field Value By Xpath    xpath=.//frame.number
    ${frame_time_list}   Check Field Value By Xpath    xpath=//frame.time_epoch
    ${signal_list}     Create List
    ${frame_lenth}    Get Length    ${frame_num_list}
    FOR     ${index}     IN RANGE     ${frame_lenth}
        ${dic_item}    Create Dictionary
        ...    frame=${frame_num_list}[${index}]
        ...    ueCtxReleaseRcvTime=${frame_time_list}[${index}]
        Append To List    ${signal_list}    ${dic_item}
    END
    [Return]  ${signal_list}

Get SgNBReleaseRecord Content
    [Documentation]  will filter the MeNBinitiatedSgNBRelease which used for inter_MeNB handover
    [Arguments]  ${Pcap_file_path}=${Pcap_file_path}
    Load Pcap File with Filter any Expression
    ...   pcap_file=${Pcap_file_path}
    ...   any_expression=nsetapx.CuVendorExtensionRecordDataType == 2 && !nsetapx.snStatusTransferSndTime_element
    ...   filter=sctp.dstport==49148
    ${frame_list}   Check Field Value By Xpath    xpath=.//frame.number
    ${gnbReleaseReason}   Check Field Value By Xpath    xpath=${gnbReleaseReason_path}
    ${plmn_list}   Check Field Value By Xpath    xpath=${plmn_path}
    ${eNBId_list}   Check Field Value By Xpath    xpath=${eNBId_path}
    ${menb_ue_x2ap_Id_list}   Check Field Value By Xpath    xpath=${menb_ue_x2ap_Id_path}
    ${sgnb_ue_x2ap_Id_list}   Check Field Value By Xpath    xpath=${sgnb_ue_x2ap_Id_path}
    ${sgnbReleaseReqTime_list}   Check Field Value By Xpath    xpath=${sgnbReleaseReqTime_path}
    ${sgnbReleaseRespTime_list}   Check Field Value By Xpath    xpath=${sgnbReleaseRespTime_path}
    ${ueCtxReleaseRcvTime_list}   Check Field Value By Xpath    xpath=${UeCtxReleaseRcvTime_path}
    ${signal_list}     Create List
    ${PScell_change_times}    Get Length    ${frame_list}
    FOR     ${index}     IN RANGE     ${PScell_change_times}
        Should Be True    ${gnbReleaseReason}[${index}] == 0
        # this field need to enhance later
        Should Not Be Empty    ${plmn_list}[${index}]
        Should Not Be Empty    ${eNBId_list}[${index}]
        Should Not Be Empty    ${sgnbReleaseReqTime_list}[${index}]
        Should Not Be Empty    ${sgnbReleaseRespTime_list}[${index}]
        Should Not Be Empty    ${ueCtxReleaseRcvTime_list}[${index}]
        ${dic_item}    Create Dictionary
#        ...    frame=${request_list}[${index}]
        ...    menb_ue_x2ap_Id=${menb_ue_x2ap_Id_list}[${index}]
        ...    sgnb_ue_x2ap_Id=${sgnb_ue_x2ap_Id_list}[${index}]
#        ...    sgnbReleaseReqTime=${request_time}
#        ...    sgnbReleaseRespTime=${response_time}
#        ...    ueCtxReleaseRcvTime=${contextrelease_time}
        Append To List    ${signal_list}    ${dic_item}
    END
    [Return]  ${signal_list}

Transformate Date to Time
    [Arguments]   ${Date}


Set SgNBReleaseRequest Xpath
    Set Test Variable    ${base_structure}    .//x2ap.SgNBReleaseRequest_element/x2ap.protocolIEs//x2ap.ProtocolIE_Field_element/x2ap.value_element
    Set Test Variable    ${sgnbReleaseReason_path}    //nsetapx.sgnbReleaseReason
    Set Test Variable    ${menb_ue_x2ap_id_signal_path}    ${base_structure}/x2ap.UE_X2AP_ID
    Set Test Variable    ${sgNB_ue_x2ap_id_signal_path}    ${base_structure}/x2ap.SgNB_UE_X2AP_ID

Set SgNBReleaseRecord Xpath
    Set Test Variable    ${base_structure}     .//nsetapx.sgnbReleaseRecord/nsetapx.data_r1_element
    Set Test Variable    ${enb_Id_element_structure}     ${base_structure}/nsetapx.enb_Id_element
    Set Test Variable    ${gnbReleaseReason_path}     ${base_structure}/nsetapx.sgnbReleaseReason
    Set Test Variable    ${plmn_path}     ${enb_Id_element_structure}/nsetapx.plmn_Identity
    Set Test Variable    ${eNBId_path}     ${enb_Id_element_structure}/nsetapx.enb_Id/nsetapx.macro_eNB_Id
    Set Test Variable    ${menb_ue_x2ap_Id_path}    ${base_structure}/nsetapx.menb_ue_x2ap_Id
    Set Test Variable    ${sgnb_ue_x2ap_Id_path}    ${base_structure}/nsetapx.sgnb_ue_x2ap_Id
    Set Test Variable    ${sgnbReleaseReqTime_path}     ${base_structure}/nsetapx.tstamp[1]
    Set Test Variable    ${sgnbReleaseRespTime_path}     ${base_structure}/nsetapx.tstamp[2]
    Set Test Variable    ${UeCtxReleaseRcvTime_path}     ${base_structure}/nsetapx.tstamp[3]

