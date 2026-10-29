*** Settings ***
Documentation   This is a keyword file for 5GC000711-A, part wireshark keywords
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
*** Variables ***

${filter_handoverRequestAck}        (ngap.procedureCode == 13) && (ngap.NGAP_PDU == 1)
${filter_handoverNotify}            (ngap.procedureCode == 11)
${filter_handoverCancel}            (ngap.procedureCode == 10)
${filter_UEContextRel_cause_cancelled}            (ngap.procedureCode == 41) && (ngap.radioNetwork == 5)
${filter_handoverFailure}           (ngap.procedureCode == 13) && (ngap.NGAP_PDU == 2)
${filter_InitialContextSetupReponse}        (ngap.procedureCode == 14) && (ngap.NGAP_PDU == 1)
${filter_handoverRequestRFSP}       (ngap.procedureCode == 13) && (ngap.indexToRFSP == 12)
${filter_MobilityRestrictionList}   ((ngap.id == 36) && (ngap.RATRestrictionInformation.e_UTRA == 1)) && (ngap.RATRestrictionInformation.nR == 1)
${filter_handoverRequest}           (ngap.procedureCode == 13)
${filter_voiceFallback}             (ngap.procedureCode == 26) && (ngap.radioNetwork == 36)
${filter_UEContextRelReq_cause_redirection}        (ngap.procedureCode == 42) && (ngap.radioNetwork == 41)
${filter_NAS_confUpdCmd}            ngap && (nas_5gs.mm.message_type == 0x54)
${filter_pdu_resource_setup_req}             (ngap.procedureCode == 29) && (ngap.id == 74)
${filter_pdu_resource_setup_successful}      (ngap.procedureCode == 29) && (ngap.NGAP_PDU == 1)
${filter_pdu_resource_release_cmd}           (ngap.procedureCode == 28) && (ngap.PDUSessionResourceReleaseCommand_element)
${filter_pdu_resource_release_response_successful}      (ngap.procedureCode == 28) && (ngap.NGAP_PDU == 1)
${filter_pdu_resource_modify_req}             (ngap.procedureCode == 26) && (ngap.id == 64)
${filter_pdu_resource_modify_successful}      (ngap) && (ngap.procedureCode == 26) && (ngap.NGAP_PDU == 1)
${filter_location_report}                     (ngap.procedureCode == 18)
${filter_UERadioCapabilityInfoIndication}     (ngap.procedureCode == 44) && (ip.src == 10.0.1.2)


*** Keywords ***

verify wireshark PDU setup
    [Documentation]    [PRIVATE]    verify PDU resource setup in wireshark
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_file}
    Log To Console    verify PDU resource setup request message
    ${pdml_xml}   create xml file
    ...    wireshark_file=${wireshark_file}
    ...    filter=${filter_pdu_resource_setup_req}
    ...    xml_file=${resultDir}/NGAP_pdu_setup_req.xml
    ${successful_msg}    Get Element Count      ${pdml_xml}
    ...    xpath=.//field[@showname="procedureCode: id-PDUSessionResourceSetup (29)"]
    Run Keyword And Continue On Failure   Should Be Equal As Integers    ${successful_msg}    ${1}
    ...     wrong number of Message id-PDUSessionResourceSetup (29)

    Log To Console    verify PDU resource setup successful message
    check wireshark pdu successful message
    ...      wireshark_file=${wireshark_file}
    ...      filter=${filter_pdu_resource_setup_successful}
    ...      xml_file=${resultDir}/NGAP_pdu_setup_succ.xml


verify wireshark PDU release
    [Documentation]    [PRIVATE]    verify PDU resource release in wireshark
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_file}
    Log To Console    verify PDU resource release command message
    ${pdml_xml}   create xml file
    ...    wireshark_file=${wireshark_file}
    ...    filter=${filter_pdu_resource_release_cmd}
    ...    xml_file=${resultDir}/NGAP_pdu_release.xml
    ${successful_msg}    Get Element Count      ${pdml_xml}
    ...    xpath=.//field[@showname="procedureCode: id-PDUSessionResourceRelease (28)"]
    Run Keyword And Continue On Failure   Should Be Equal As Integers    ${successful_msg}    ${1}
    ...     wrong number of Message id-PDUSessionResourceRelease (28)

    Log To Console    verify PDU resource release response successful message
    check wireshark pdu successful message
    ...      wireshark_file=${wireshark_file}
    ...      filter=${filter_pdu_resource_release_response_successful}
    ...      xml_file=${resultDir}/NGAP_pdu_release_succ.xml


verify wireshark PDU modify
    [Documentation]    [PRIVATE]    verify PDU resource modify in wireshark
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_file}
    Log To Console    verify PDU resource modify request message
    ${pdml_xml}   create xml file
    ...    wireshark_file=${wireshark_file}
    ...    filter=${filter_pdu_resource_modify_req}
    ...    xml_file=${resultDir}/NGAP_pdu_modify.xml
    ${successful_msg}    Get Element Count      ${pdml_xml}
    ...    xpath=.//field[@showname="procedureCode: id-PDUSessionResourceModify (26)"]
    Run Keyword And Continue On Failure   Should Be Equal As Integers    ${successful_msg}    ${1}
    ...     wrong number of Message id-PDUSessionResourceModify (26)

    Log To Console    verify PDU resource modify response successful message
    check wireshark pdu successful message
    ...      wireshark_file=${wireshark_file}
    ...      filter=${filter_pdu_resource_modify_successful}
    ...      xml_file=${resultDir}/NGAP_pdu_modify_succ.xml


check wireshark pdu successful message
    [Documentation]    [PRIVATE]    verify PDU successful message present in wireshark
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_file}     ${filter}    ${xml_file}
    ${pdml_xml}   create xml file
    ...    wireshark_file=${wireshark_file}
    ...    filter=${filter}
    ...    xml_file=${xml_file}
    ${successful_msg}    Get Element Count      ${pdml_xml}
    ...    xpath=.//field[@showname="successfulOutcome"]
    Run Keyword And Continue On Failure   Should Be Equal As Integers    ${successful_msg}    ${1}
    ...     wrong number of PDU resource successful message


verify wireshark location report
    [Documentation]    [PRIVATE]    verify location report contains event_type in wireshark
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_file}     ${event_type}    ${ue_id}
    Log To Console    \nverify location report contains "event_type=${event_type}"
    ${pdml_xml}   create xml file
    ...    wireshark_file=${wireshark_file}
    ...    filter=${filter_location_report}
    ...    xml_file=${resultDir}/NGAP_location_report_${ue_id}.xml
    ${loc_rep_msg}    Get Element Count      ${pdml_xml}
    ...    xpath=.//field[@showname="eventType: ${event_type}"]
    Run Keyword And Continue On Failure   Should Be Equal As Integers    ${loc_rep_msg}    ${1}
    ...     wrong number of location update message eventType: ${event_type}


verify wireshark no location report
    [Documentation]    [PRIVATE]    verify no location report in wireshark
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_file}    ${ue_id}
    ${pdml_xml}   create xml file
    ...    wireshark_file=${wireshark_file}
    ...    filter=${filter_location_report}
    ...    xml_file=${resultDir}/NGAP_location_report_${ue_id}.xml
    ${msg}    Get Element Count      ${pdml_xml}
    ...    xpath=.//proto[@name="ngap"]
     Run Keyword And Continue On Failure   Should Be Equal As Integers    ${msg}    ${0}
    ...     unexpected location report message found


verify wireshark NAS conf update
    [Documentation]    [PRIVATE]    verify NAS configuration update in wireshark
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_file}
    Log To Console    \nverify in NAS message with configuration update command present
    ${pdml_xml}   create xml file
    ...    wireshark_file=${wireshark_file}
    ...    filter=${filter_NAS_confUpdCmd}
    ...    xml_file=${resultDir}/NGAP_NAS_conf.xml
    ${successful_msg}    Get Element Count      ${pdml_xml}
    ...    xpath=.//field[@showname="Message type: Configuration update command (0x54)"]
    Run Keyword And Continue On Failure   Should Be Equal As Integers    ${successful_msg}    ${1}
    ...     wrong number of Message type: Configuration update command (0x54) message


verify wireshark redirection
    [Documentation]    [PRIVATE]    verify redirection in wireshark
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_file}
    Log To Console    \nverify in UEContextReleaseRequest, cause redirection present
    ${pdml_xml}   create xml file
    ...    wireshark_file=${wireshark_file}
    ...    filter=${filter_UEContextRelReq_cause_redirection}
    ...    xml_file=${resultDir}/NGAP_redirection.xml
    ${successful_msg}    Get Element Count      ${pdml_xml}
    ...    xpath=.//field[@showname="radioNetwork: redirection (41)"]
    Run Keyword And Continue On Failure   Should Be Equal As Integers    ${successful_msg}    ${1}
    ...     wrong number of UEContextReleaseRequest message


verify wireshark voiceFallback
    [Documentation]    [PRIVATE]    verify voiceFallback in wireshark
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_file}
    Log To Console    \nverify in PDUSessionResourceModifyResponse, cause ims-voice-eps-fallback-or-rat-fallback-triggered present
    ${pdml_xml}   create xml file
    ...    wireshark_file=${wireshark_file}
    ...    filter=${filter_voiceFallback}
    ...    xml_file=${resultDir}/NGAP_voiceFallback.xml
    ${successful_msg}    Get Element Count      ${pdml_xml}
    ...    xpath=.//field[@showname="radioNetwork: ims-voice-eps-fallback-or-rat-fallback-triggered (36)"]
    Run Keyword And Continue On Failure   Should Be Equal As Integers    ${successful_msg}    ${1}
    ...     wrong number of PDUSessionResourceModifyResponse message


verify wireshark no handover request
    [Documentation]    [PRIVATE]    verify no handover request in wireshark
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_file}
    ${pdml_xml}   create xml file
    ...    wireshark_file=${wireshark_file}
    ...    filter=${filter_handoverRequest}
    ...    xml_file=${resultDir}/no_ho_req.xml
    ${msg}    Get Element Count      ${pdml_xml}
    ...    xpath=.//proto[@name="ngap"]
     Run Keyword And Continue On Failure   Should Be Equal As Integers    ${msg}    ${0}
    ...     unexpected handover request message found


verify wireshark mobilityRestrictionList
    [Documentation]    [PRIVATE]    verify mobilityRestrictionList in wireshark
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_file}
    Log To Console    \nverify mobilityRestrictionList present
    ${pdml_xml}   create xml file
    ...    wireshark_file=${wireshark_file}
    ...    filter=${filter_MobilityRestrictionList}
    ...    xml_file=${resultDir}/NGAP_mobilityRestrictionList.xml
    ${successful_msg}    Get Element Count      ${pdml_xml}
    ...    xpath=.//field[@name="ngap.MobilityRestrictionList_element"]
    Run Keyword And Continue On Failure   Should Be Equal As Integers    ${successful_msg}    ${1}
    ...     wrong number of mobilityRestrictionList message


verify wireshark InitialContextSetupReponse
    [Documentation]    [PRIVATE]    verify successful InitialContextSetupReponse in wireshark
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_file}    ${number_expected_msgs}
    Log To Console    \nverify ${number_expected_msgs} successful InitialContextSetupReponse present
    ${pdml_xml}   create xml file
    ...    wireshark_file=${wireshark_file}
    ...    filter=${filter_InitialContextSetupReponse}&&(ip.src == 10.0.1.2)
    ...    xml_file=${resultDir}/NGAP_succInitContSetupResp.xml
    ${successful_msg}    Get Element Count      ${pdml_xml}
    ...    xpath=.//field[@name="ngap.successfulOutcome_element"]
    Run Keyword And Continue On Failure   Should Be Equal As Integers    ${successful_msg}    ${number_expected_msgs}
    ...     wrong number of handoverRequestAcknowledge message with ip.src == 10.0.1.2


verify wireshark handoverRequestAck
    [Documentation]    [PRIVATE]    verify handoverRequestAck in wireshark
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_file}   ${source_ip}=10.0.1.2
    Log To Console    \nverify handoverRequestAcknowledge present
    ${pdml_xml}   create xml file
    ...    wireshark_file=${wireshark_file}
    ...    filter=${filter_handoverRequestAck}&&(ip.src == ${source_ip})
    ...    xml_file=${resultDir}/NGAP_hoReqAck.xml
    ${successful_msg}    Get Element Count      ${pdml_xml}
    ...    xpath=.//field[@name="ngap.successfulOutcome_element"]
    Run Keyword And Continue On Failure   Should Be Equal As Integers    ${successful_msg}    ${1}
    ...     wrong number of handoverRequestAcknowledge message with ip.src == ${source_ip}


verify wireshark handoverNotify
    [Documentation]    [PRIVATE]    verify handoverNotify in wireshark
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_file}   ${source_ip}=10.0.1.2
    Log To Console    \nverify handoverNotify present
    ${pdml_xml}   create xml file
    ...    wireshark_file=${wireshark_file}
    ...    filter=${filter_handoverNotify}&&(ip.src == ${source_ip})
    ...    xml_file=${resultDir}/NGAP_hoNotify.xml
    ${successful_msg}    Get Element Count      ${pdml_xml}
    ...    xpath=.//field[@name="ngap.HandoverNotify_element"]
    Run Keyword And Continue On Failure   Should Be Equal As Integers    ${successful_msg}    ${1}
    ...     wrong number of handoverNotify message with ip.src == ${source_ip}


verify wireshark no handoverNotify
    [Documentation]    [PRIVATE]    verify no handoverNotify in wireshark
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_file}
    Log To Console    \nverify no handoverNotify present
    ${pdml_xml}   create xml file
    ...    wireshark_file=${wireshark_file}
    ...    filter=${filter_handoverNotify}&&(ip.src == 10.0.1.2)
    ...    xml_file=${resultDir}/NGAP_hoNotify.xml
    Run Keyword And Continue On Failure   element should not exist
    ...    source=${pdml_xml}
    ...    xpath=.//field[@name="ngap.HandoverNotify_element"]
    ...    message=Error - notify message found


verify wireshark handoverRequest with rfsp
    [Documentation]    [PRIVATE]    verify handoverRequest with rfsp in wireshark
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_file}
    Log To Console    \nverify handoverRequest with rfsp=12 present
    ${pdml_xml}   create xml file
    ...    wireshark_file=${wireshark_file}
    ...    filter=${filter_handoverRequestRFSP}&&(ip.src == 10.0.1.1)
    ...    xml_file=${resultDir}/NGAP_hoReqRFSP.xml
    ${rfsp_msg}    Get Element Count      ${pdml_xml}
    ...    xpath=.//field[@name="ngap.indexToRFSP"]
    Run Keyword And Continue On Failure   Should Be Equal As Integers    ${rfsp_msg}    ${1}
    ...     wrong number of handoverRequest with rfsp message with ip.src == 10.0.1.1


verify wireshark handoverCancel
    [Documentation]    [PRIVATE]    verify handoverCancel in wireshark
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_file}
    Log To Console    \nverify 1 handoverCancel message present
    ${pdml_xml}   create xml file
    ...    wireshark_file=${wireshark_file}
    ...    filter=${filter_handoverCancel}
    ...    xml_file=${resultDir}/NGAP_hoCancel.xml
    ${radioNetwork}    Get Element Count      ${pdml_xml}
    ...    xpath=.//field[@name="ngap.radioNetwork"]
    Run Keyword And Continue On Failure   Should Be Equal As Integers    ${radioNetwork}    ${1}
    ...     wrong number of handoverCancel messages


verify wireshark handoverFailure
    [Documentation]    [PRIVATE]    verify handoverCancel in wireshark
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_file}   ${cause}
    Log To Console    \nverify 1 handoverCancel message present with cause ${cause}
    ${pdml_xml}   create xml file
    ...    wireshark_file=${wireshark_file}
    ...    filter=${filter_handoverFailure}
    ...    xml_file=${resultDir}/NGAP_hoFailure.xml
    Run Keyword And Continue On Failure   Element Attribute should match    ${pdml_xml}
    ...    showname
    ...    *${cause}*
    ...    xpath=.//field[@name="ngap.radioNetwork"]


verify wireshark UeContextRel cause cancel
    [Documentation]    [PRIVATE]    verify UeContextRel cause cancel in wireshark
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_file}
    Log To Console    \nverify 1 UeContextRelease cause handover-cancelled message present
    ${pdml_xml}   create xml file
    ...    wireshark_file=${wireshark_file}
    ...    filter=${filter_UEContextRel_cause_cancelled}
    ...    xml_file=${resultDir}/NGAP_UeContextRelCancel.xml
    ${radioNetwork}    Get Element Count      ${pdml_xml}
    ...    xpath=.//field[@name="ngap.radioNetwork"]
    Run Keyword And Continue On Failure   Should Be Equal As Integers    ${radioNetwork}    ${1}
    ...     wrong number of UEContextRelease cause handover-cancelled messages


verify wireshark UERadioCapability
    [Documentation]    [PRIVATE]    verify UERadioCapability in wireshark
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_file}
    Log To Console    \nverify UERadioCapabilityInfoIndication present
    ${pdml_xml}   create xml file
    ...    wireshark_file=${wireshark_file}
    ...    filter=${filter_UERadioCapabilityInfoIndication}
    ...    xml_file=${resultDir}/NGAP_UERadioCapability.xml
    ${successful_msg}    Get Element Count      ${pdml_xml}
    ...    xpath=.//field[@showname="UERadioCapabilityInfoIndication"]
    Run Keyword And Continue On Failure   Should Be Equal As Integers    ${successful_msg}    ${1}
    ...     wrong number of UERadioCapabilityInfoIndication message


create xml file
    [Documentation]    [PRIVATE]    create xml file
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_file}    ${filter}    ${xml_file}
    setup tshark    eth1
    Log To Console    create xml file with filter "${filter}"
    read_pcap_and_save_to_file
    ...   filename=${xml_file}
    ...   packet_filter=${filter}
    ...   output_type=pdml
    ...   pcap_file_path=${wireshark_file}
    teardown tshark
    ${pdml_xml}    parse xml    ${xml_file}
    RETURN     ${pdml_xml}
