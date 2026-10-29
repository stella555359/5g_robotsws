*** Settings ***
Documentation
...    author: jqu003
...    this case will verify keyword for TA of CB008208

Resource   ../Resource/Common.robot
Library     ../Library/list_time_check.py

*** Variables ***


*** Keywords ***
CB008208-5G-A-15_Classical_gNB-CU_Bearer_record_for_SA_PDU_Session_Resource_Release
    Set Test Variable     ${Pcap_file_path}    ${SA_INTRA_gNB_HO_PATH}
    Set CuBearRecord PDU release Xpath
    Set PduSessionId And DrbId Xpath Of Dadicated Message
    #Step-1.1: Get UeContextModification frame list which For DRB rlease
    ${Pdu_release_request_list}    Get PDUSessionResourceReleaseCommand Frame List
    #Step-1.2: Get UeContextModification frame list which For DRB rlease
    ${DRB_rlease_request_list}    Get UEContextModificationRequest For Drb Release Frame List
    #Step-1.3: Get All CuBearerRecord frame list occured in all scenario
    ${Bearer_record_list}    Get All CuBearerRecord Frame List    Pcap_file_path=${Pcap_file_path}
    #Step-2.1: Get the CuBeaerRecord nearly by UeContextModification message which used for PDU release
    ${Record_neaby_list}    find_nearby_frame    ${Pdu_release_request_list}    ${Bearer_record_list}
    #Step-2.2: Get the UEcontextModification nearby PDUSessionRelease
    ${Drb_release_neaby_list}    find_nearby_frame    ${Pdu_release_request_list}    ${DRB_rlease_request_list}
    #Step-2.3: Get DrbId and PduSessionId list from message of gNB<>AMF need to release
    ${drbId_release_list}     Get DrbId List From UEContextModificationRequest
    ${pduSessionId_release_list}     Get PduSessionId List From UEContextModificationRequest
    #Step-3: Check earch CuBearerRecord content #1 all field predefined is presented. #2 all field value is as predefined
    # and equal to value return by Step2.3
    Check Each Release Record Content    record_frame_list=${Record_neaby_list}    drbId_release_list=${drbId_release_list}
    ...    pduSessionId_release_list=${pduSessionId_release_list}

Case Setup
    Log To Console    Case Preparation:
    ...               1: check pcap file if exist
    ...               2: config case variable that will use in test case e.g. record name, IE's name, Path, value of IE
    ...                 send out time etc...
    Check Pcap File Available
    Set CuBearRecord PDU release Xpath

Case Teardown
    Log To Console   Case Teardown
    run keyword if  not ${rec_status}   Run Keywords
    ...   Initialize PA   AND
    ...   Common Teardown 1756

Set CuBearRecord PDU release Xpath
    Set Test Variable    ${base_structure}    .//nsetapx.bearerRecord/nsetapx.data_r1_element
    Set Test Variable    ${trigger_path}    ${base_structure}/nsetapx.trigger
    Set Test Variable    ${release_bear_structure}    ${base_structure}/nsetapx.releasedBearers
    Set Test Variable    ${ngran_bear_structure}    ${release_bear_structure}//nsetapx.CuBearerDataReleaseItem/nsetapx.ngranBearer_element/
    Set Test Variable    ${release_drbId_path}    ${ngran_bear_structure}/nsetapx.drb_Id
    Set Test Variable    ${release_pduSessionId_path}    ${ngran_bear_structure}/nsetapx.pduSessionId

Set PduSessionId And DrbId Xpath Of Dadicated Message
    Set Test Variable    ${DrbId_base_structure}    .//f1ap.DRBs_ToBeReleased_Item_element
    Set Test Variable    ${EM_DrbId_path}    ${DrbId_base_structure}/f1ap.dRBID
    Set Test Variable    ${PduSessionId_base_structure}    .//ngap.PDUSessionResourceToReleaseItemRelCmd_element
    Set Test Variable    ${EM_PduSessionId_path}    ${PduSessionId_base_structure}/ngap.pDUSessionID

Get UEContextModificationRequest For Drb Release Frame List
    [Documentation]  will filter the UeContextModificationRequest which used for handover initiate
    [Arguments]  ${Pcap_file_path}=${Pcap_file_path}
    Load Pcap File with Filter any Expression
    ...   pcap_file=${Pcap_file_path}
    ...   any_expression=f1ap.procedureCode == 7 && sctp.srcport==38472 && f1ap.id==33
    ...   filter= sctp.dstport==38472
    ${request_list}   wireshark.get_field_value_by_xpath    xpath=.//frame.number
    [Return]  ${request_list}

Get All CuBearerRecord Frame List
    [Arguments]  ${Pcap_file_path}=${Pcap_file_path}
    Load Pcap File with Filter any Expression
    ...   pcap_file=${Pcap_file_path}
    ...   any_expression=nsetapx.CuVendorExtensionRecordDataType==10 && ip.dst==${dcap_server_ip}
    ...   filter= tcp.dstport==49148
    ${record_list}   Check Field Value By Xpath    xpath=.//frame.number
    [Return]  ${record_list}

Check Each Release Record Content
    [Arguments]  ${record_frame_list}    ${Pcap_file_path}=${Pcap_file_path}     ${drbId_release_list}=${drbId_release_list}
    ...    ${pduSessionId_release_list}=${pduSessionId_release_list}
    FOR    ${record_frame}     IN     @{record_frame_list}
        Run Keyword And Continue On Failure
        ...    Check Release Bearer Record IE    record_frame=${record_frame}    drbId_release_list=${drbId_release_list}
    ...    pduSessionId_release_list=${pduSessionId_release_list}
    END

Check Release Bearer Record IE
    [Arguments]   ${record_frame}    ${Pcap_file_path}=${Pcap_file_path}    ${drbId_release_list}=${drbId_release_list}
    ...    ${pduSessionId_release_list}=${pduSessionId_release_list}
    Load Pcap File with Filter any Expression
    ...   pcap_file=${Pcap_file_path}
    ...   any_expression=nsetapx.CuVendorExtensionRecordDataType == 10 && ip.dst==${dcap_server_ip} && frame.number==${record_frame}
    ...   filter= tcp.dstport==49148
    # Refer 5G_TC_736  different content have different field to check, or different value to check
    ${beaer_num}    Check Field Value By Xpath      xpath=${release_bear_structure}
    ${trigger}    Check Field Value By Xpath      xpath=${trigger_path}
    ${drbId}    Check Field Value By Xpath      xpath=${release_drbId_path}
    ${pduSessionId}    Check Field Value By Xpath      xpath=${release_pduSessionId_path}
    List Should Contain Sub List     ${drbId_release_list}    ${drbId}
    List Should Contain Sub List     ${pduSessionId_release_list}    ${pduSessionId}

    ${beaer_num}    Get From List      ${beaer_num}    0
    ${beaer_num}    Convert To Integer      ${beaer_num}
    Should Be True    ${trigger}[0] == ${0}
    FOR     ${index}     IN RANGE    ${beaer_num}
        ${result1}    Evaluate    1 <= ${drbId}[${index}] <= 32
        ${result2}    Evaluate    0 <= ${pduSessionId}[${index}] <= 255
        Should Be True   ${result1}==${result2}==True
    END

Get DrbId List From UEContextModificationRequest
    [Arguments]   ${Pcap_file_path}=${Pcap_file_path}
    Load Pcap File with Filter any Expression
    ...   pcap_file=${Pcap_file_path}
    ...   any_expression=f1ap.procedureCode == 7 && sctp.srcport==38472 && f1ap.id==33
    ...   filter= tcp.dstport==49148
    ${Drb_orignal_list}    Check Field Value By Xpath      xpath=${EM_DrbId_path}
    [Return]  ${Drb_orignal_list}

Get PduSessionId List From UEContextModificationRequest
    [Arguments]   ${Pcap_file_path}=${Pcap_file_path}
    Load Pcap File with Filter any Expression
    ...   pcap_file=${Pcap_file_path}
    ...   any_expression=ngap.procedureCode == 28 && sctp.srcport==38412 && ngap.id == 79
    ...   filter= tcp.dstport==49148
    ${PduSessionId_orignal_list}    Check Field Value By Xpath      xpath=${EM_PduSessionId_path}
    [Return]  ${PduSessionId_orignal_list}
