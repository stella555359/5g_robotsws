*** Settings ***
Documentation
...   Author: liping.hong@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
EA_42_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_gNB-CU_PDU_Session_Info_Record_for_Pdu_Session_Resource_Release
    log to console     check elemnet  PDU_Session_Info_Record_for_Pdu_Session_Resource_Release
     Load Pcap File with Filter any Expression
     ...                        pcap_file=${TCPDUMP_PATH}
     ...                        any_expression=ngap.id == 79&&ip.dst == ${LOCAL_SSH_ADDR}
     ...                        filter=tcp.dstport==38412
    ${xpath_IctxsetupR_e1}   set variable   .//ngap.NGAP_PDU/ngap.initiatingMessage_element/ngap.value_element
    ${xpath_IctxsetupR_e2}   set variable    /ngap.PDUSessionResourceReleaseCommand_element/ngap.protocolIEs
    ${xpath_IctxsetupR_e3}   set variable    //ngap.ProtocolIE_Field_element/ngap.value_element/ngap.PDUSessionResourceToReleaseListRelCmd
    ${xpath_IctxsetupR_e4}   set variable    //ngap.PDUSessionResourceToReleaseItemRelCmd_element
    ${xpath_IctxsetupR_E4}   set variable   ${xpath_IctxsetupR_e1}${xpath_IctxsetupR_e2}${xpath_IctxsetupR_e3}${xpath_IctxsetupR_e4}
    ${xpath_IctxsetupR_e5}   set variable   /ngap.pDUSessionResourceReleaseCommandTransfer/ngap.PDUSessionResourceReleaseCommandTransfer_element
    ${ngap_pdusetup_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_IctxsetupR_e1}${xpath_IctxsetupR_e2}${xpath_IctxsetupR_e3}
    ${ngap_pdusetup_length}=  Get Length   ${ngap_pdusetup_list}
    ${ngap_pduSessionId_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_IctxsetupR_E4}/ngap.pDUSessionID
    ${ngap_pdureleasecause_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_IctxsetupR_E4}${xpath_IctxsetupR_e5}/ngap.cause
     Load Pcap File with Filter any Expression
     ...                        pcap_file=${TCPDUMP_PATH}
     ...                        any_expression=nsetapx.CuVendorExtensionRecordDataType == 14&&nsetapx.trigger == 5
     ...                        filter=tcp.dstport==${dcap_server_port}
    ${xpath_Pdu_e}   set variable   .//nsetapx.pduSessionResourceInfoRecord/nsetapx.data_element
    ${trigger_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_Pdu_e}/nsetapx.trigger
    ${result_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_Pdu_e}/nsetapx.result
    ${xpath_PduResource_e}   set variable   /nsetapx.releasedPduSessionResources//nsetapx.PduSessionResourceReleaseItem_element
    ${snssai_sst_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_Pdu_e}${xpath_PduResource_e}/nsetapx.snssai_element/nsetapx.sst
    ${snssai_sd_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_Pdu_e}${xpath_PduResource_e}/nsetapx.snssai_element/nsetapx.sd
    ${pduSessionId_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_Pdu_e}${xpath_PduResource_e}/nsetapx.pduSessionId
    Should Be True   ${ngap_pduSessionId_list} == ${pduSessionId_list}

    FOR   ${idx}    IN RANGE    0   ${ngap_pdusetup_length}
        Should Be True   ${result_list}[${idx}] == 0
        Should Be True   '${snssai_sst_list}[${idx}]' == '01'
        Should Be True   '${snssai_sd_list}[${idx}]' == 'd1:43:a5'
    END
    Length Should Be   ${trigger_list}   ${ngap_pdusetup_length}
    Length Should Be   ${result_list}   ${ngap_pdusetup_length}
    Length Should Be   ${snssai_sst_list}   ${ngap_pdusetup_length}
    Length Should Be   ${snssai_sd_list}   ${ngap_pdusetup_length}
    Length Should Be   ${pduSessionId_list}   ${ngap_pdusetup_length}

    Log To Console   check value is OK

Case Setup: EA_42
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    Log To Console   Case Setup: EA_42

Case Teardown: EA_42
    robot_common_operations.Common Case Teardown
    Log To Console   Case Teardown: EA_42
    Check Extra Reset From Blackbox on Teardown   Reset_before=${RESET_REASON}
