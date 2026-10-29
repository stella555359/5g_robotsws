*** Settings ***
Documentation
...   Author: liping.hong@nokia-sbell.com

#Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009225_cloud/Common_resource/common_keyword.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Cloud/CB009225_cloud/Common_resource/common_keyword.robot

*** Variables ***

*** Keyword ***
CB008208-5G-A-12_Classical_gNB-CU_Bearer_record_for_SA_Initial_Context_Setup
    log to console   check BearerRecord after L3call
    log to console   info pduSessionResource
    Load Pcap File with Filter any Expression
        ...   pcap_file=${TCPDUMP_PATH}
        ...   any_expression=nsetapx.CuVendorExtensionRecordDataType == 14 && nsetapx.trigger == 1
        ...   filter=tcp.dstport==${dcap_server_port}

    ${pduSession_path}   set variable   .//nsetapx.setupPduSessionResources//nsetapx.PduSessionResourceSetupItem_element

    ${pduSessionId}   wireshark.get_field_value_by_xpath
    ...   xpath=${pduSession_path}/nsetapx.pduSessionId

    ${pduSeRe_path}   set variable   ${pduSession_path}/nsetapx.setupQosFlows//nsetapx.QosFlowSetupItem_element
#    :FOR   ${item}   IN   @{pduSessionId}
    ${qfi_pduSeRe}   wireshark.get_field_value_by_xpath
    ...   xpath=${pduSeRe_path}/nsetapx.qfi

    ${fiveQi_pduSeRe}   wireshark.get_field_value_by_xpath
    ...   xpath=${pduSeRe_path}/nsetapx.qosParameters_element/nsetapx.qosCharacteristics/nsetapx.nonDynamicFiveQiDescriptor_element/nsetapx.fiveQi

    ${priorityLevel_pduSeRe}   wireshark.get_field_value_by_xpath
    ...   xpath=${pduSeRe_path}/nsetapx.qosParameters_element/nsetapx.arp_element/nsetapx.priorityLevel

    ${preemptionCapability_pduSeRe}   wireshark.get_field_value_by_xpath
    ...   xpath=${pduSeRe_path}/nsetapx.qosParameters_element/nsetapx.arp_element/nsetapx.preemptionCapability

    ${preemptionVulnerability_pduSeRe}   wireshark.get_field_value_by_xpath
    ...   xpath=${pduSeRe_path}/nsetapx.qosParameters_element/nsetapx.arp_element/nsetapx.preemptionVulnerability

    log to console   get BearerRecord after L3call

    Load Pcap File with Filter any Expression
    ...   pcap_file=${TCPDUMP_PATH}
    ...   any_expression=nsetapx.bearerRecord == 1 && nsetapx.pduSessionId == ${pduSessionId[0]}
    ...   filter=tcp.dstport==${dcap_server_port}

    ${common_path}   set variable   .//nsetapx.bearerRecord/nsetapx.data_r1_element/nsetapx.setupBearers//nsetapx.CuBearerDataSetupItem
    ${drbId}   wireshark.get_field_value_by_xpath
    ...   xpath=${common_path}/nsetapx.ngranBearer_element/nsetapx.drb_Id

    ${common_path2}   set variable  ${common_path}/nsetapx.ngranBearer_element/nsetapx.drbQoS_element

    ${fiveQi}   wireshark.get_field_value_by_xpath
    ...   xpath=${common_path2}/nsetapx.qosCharacteristics/nsetapx.nonDynamicFiveQiDescriptor_element/nsetapx.fiveQi

    ${priorityLevel}   wireshark.get_field_value_by_xpath
    ...   xpath=${common_path2}/nsetapx.arp_element/nsetapx.priorityLevel

    ${preemptionCapability}   wireshark.get_field_value_by_xpath
    ...   xpath=${common_path2}/nsetapx.arp_element/nsetapx.preemptionCapability

    ${preemptionVulnerability}   wireshark.get_field_value_by_xpath
    ...   xpath=${common_path2}/nsetapx.arp_element/nsetapx.preemptionVulnerability

    ${qfi_path1}   set variable  ${common_path}/nsetapx.ngranBearer_element/nsetapx.setupQosFlowsMappedToBearer//

    ${qfi}   wireshark.get_field_value_by_xpath
    ...   xpath=${qfi_path1}nsetapx.CuSetupQosFlowMappedToBearerItem_element/nsetapx.qfi

    ${triggerReason}   wireshark.get_field_value_by_xpath
    ...   xpath=.//nsetapx.CuVendorExtensionRecordDataType/nsetapx.bearerRecord/nsetapx.data_r1_element/nsetapx.trigger
    ...   attribute_name=showname

    ${triggerReason}   Remove Duplicates   ${triggerReason}

#    log to console   e1ap.dRB_ID of pduSessionResourceToSetup in BearerContextModificationRequest
#    ${is_CRT}   run keyword and return status   should contain    ${OUTPUT_DIR}   CRT
#    run keyword if   ${is_CRT}   Check DrbId in BearerContextModificationRequest after SA Call
#    ...   pduSessionId=${pduSessionId[0]}   expect_drbId=${drbId}
#    should not be empty   ${drbId}

#    Load Pcap File with Filter any Expression
#    ...   pcap_file=${TCPDUMP_PATH}
#    ...   any_expression=e1ap.pDU_Session_ID == ${pduSessionId[0]}
#    ...   filter=tcp.dstport==38462
#
#
#    ${pduSe_part1}   set variable   .//e1ap.E1AP_PDU/e1ap.initiatingMessage_element/e1ap.value_element/
#    ${pduSe_part2}   set variable   e1ap.BearerContextSetupRequest_element/e1ap.protocolIEs//e1ap.ProtocolIE_Field_element/
#    ${pduSe_part3}   set variable   e1ap.value_element/e1ap.System_BearerContextSetupRequest/e1ap.nG_RAN_BearerContextSetupRequest/
#    ${pduSe_part4}   set variable   /e1ap.ProtocolIE_Field_element/e1ap.value_element/e1ap.PDU_Session_Resource_To_Setup_List//
#    ${pduSe_part5}   set variable   e1ap.PDU_Session_Resource_To_Setup_Item_element/e1ap.dRB_To_Setup_List_NG_RAN//
#    ${pduSe_path}   set variable   ${pduSe_part1}${pduSe_part2}${pduSe_part3}${pduSe_part4}${pduSe_part5}
#    ${drbId_pduSe}   wireshark.get_field_value_by_xpath
#    ...   xpath=${pduSe_path}e1ap.DRB_To_Setup_Item_NG_RAN_element/e1ap.dRB_ID
#
#
#    log to console   check drbId
#    should not be empty   ${drbId}
#    list should contain sub list  ${drbId_pduSe}   ${drbId}

    log to console   check qfi
    should not be empty   ${qfi}
    list should contain sub list  ${qfi_pduSeRe}   ${qfi}

    log to console   check fiveQi
    should not be empty   ${fiveQi}
    list should contain sub list  ${fiveQi_pduSeRe}   ${fiveQi}

    log to console   check priorityLevel, preemptionCapability, and preemptionVulnerability
    should not be empty   ${priorityLevel}
    should not be empty   ${preemptionCapability}
    should not be empty   ${preemptionVulnerability}
    list should contain sub list  ${priorityLevel_pduSeRe}   ${priorityLevel}
    list should contain sub list  ${preemptionCapability_pduSeRe}   ${preemptionCapability}
    list should contain sub list  ${preemptionVulnerability_pduSeRe}   ${preemptionVulnerability}

    log to console   check Trigger Reason
    Should Contain Match   ${triggerReason}   regexp=.*other.*

Case Setup: CB008208-5G-A-12
    robot_common_operations.Common Case Setup
    Log To Console   CB008208-5G-A-12
    ${file_status}   run keyword and return status   File Should Not Be Empty   ${TCPDUMP_PATH}
    Set Test Variable   ${file_status}
    run keyword if  not ${file_status}   Run Keywords
    ...   Common Setup 1756   AND
    ...   Remove And Add PCMD Object   AND
    ...   Run Keyword And Ignore Error   Initialize PA   AND
    ...   Run Keyword And Ignore Error   Make L3CALL And Get ALL PCMD MSG

Case Teardown: CB008208-5G-A-12
    robot_common_operations.Common Case Teardown
    Log To Console   Case Teardown: CB008208-5G-A-12
    run keyword if  not ${file_status}   Run Keywords
    ...   Run Keyword And Ignore Error   Initialize PA   AND
    ...   Common Teardown 1756


Check DrbId in BearerContextModificationRequest after SA Call
    [Arguments]  ${pduSessionId}   ${expect_drbId}   ${file}=${TCPDUMP_PATH}
    Load Pcap File with Filter any Expression
    ...   pcap_file=${TCPDUMP_PATH}
    ...   any_expression=e1ap.pDU_Session_ID == ${pduSessionId[0]}
    ...   filter=tcp.dstport==38462

    ${pduSe_part1}   set variable   .//e1ap.E1AP_PDU/e1ap.initiatingMessage_element/e1ap.value_element/
    ${pduSe_part2}   set variable   e1ap.BearerContextSetupRequest_element/e1ap.protocolIEs//e1ap.ProtocolIE_Field_element/
    ${pduSe_part3}   set variable   e1ap.value_element/e1ap.System_BearerContextSetupRequest/e1ap.nG_RAN_BearerContextSetupRequest/
    ${pduSe_part4}   set variable   /e1ap.ProtocolIE_Field_element/e1ap.value_element/e1ap.PDU_Session_Resource_To_Setup_List//
    ${pduSe_part5}   set variable   e1ap.PDU_Session_Resource_To_Setup_Item_element/e1ap.dRB_To_Setup_List_NG_RAN//
    ${pduSe_path}   set variable   ${pduSe_part1}${pduSe_part2}${pduSe_part3}${pduSe_part4}${pduSe_part5}
    ${drbId_pduSe}   wireshark.get_field_value_by_xpath
    ...   xpath=${pduSe_path}e1ap.DRB_To_Setup_Item_NG_RAN_element/e1ap.dRB_ID

    log to console   check drbId
    list should contain sub list  ${drbId_pduSe}   ${expect_drbId}
