*** Settings ***
Documentation
...   Author: liping.hong@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
EA_20_SA_ClassicalgNB_Streaming_PCMD_gNB-CU_Cplane_gNB-CU_UESetup_Record
    log to console     check elemnet  CuVendorExtensionRecordDataType: ueSetupRecord (13)

     Load Pcap File with Filter any Expression
     ...                        pcap_file=/home/ute/hlp/TCPDUMP_20220125_0708.pcap
     ...                        any_expression=ngap.procedureCode == 14&&ip.dst == 10.57.151.226
     ...                        filter=sctp.dstport==38412
    ${xpath_ngap_e1}   set variable   .//ngap.NGAP_PDU/ngap.initiatingMessage_element/ngap.value_element/ngap.InitialContextSetupRequest_element
    ${xpath_ngap_e2}   set variable   /ngap.protocolIEs//ngap.ProtocolIE_Field_element/ngap.value_element
    ${ngap_amf-ue-ngap-Id_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ngap_e1}${xpath_ngap_e2}/ngap.AMF_UE_NGAP_ID
    ${ngap_ran-ue-ngap-Id_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ngap_e1}${xpath_ngap_e2}/ngap.RAN_UE_NGAP_ID
    ${ngap_plmn-Identity_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ngap_e1}${xpath_ngap_e2}/ngap.GUAMI_element/ngap.pLMNIdentity
    ${ngap_amfRegionId_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ngap_e1}${xpath_ngap_e2}/ngap.GUAMI_element/ngap.aMFRegionID
    ${ngap_amfSetId_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ngap_e1}${xpath_ngap_e2}/ngap.GUAMI_element/ngap.aMFSetID
    ${ngap_amfPointer_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ngap_e1}${xpath_ngap_e2}/ngap.GUAMI_element/ngap.aMFPointer
    ${xpath_ueSetup_e}   set variable   .//nsetapx.ueSetupRecord/nsetapx.data_element
    Load Pcap File with Filter
     ...                        pcap_file=/home/ute/hlp/TCPDUMP_20220125_0708.pcap
     ...                        record_type=Cu
     ...                        input_type=13
     ...                        filter=tcp.dstport==${dcap_server_port}
    ${ran-ue-ngap-Id_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ueSetup_e}/nsetapx.ran_ue_ngap_Id
    ${ran-ue-ngap-Id_length}=  Get Length   ${ran-ue-ngap-Id_list}
    FOR   ${idx}    IN RANGE    1   ${ran-ue-ngap-Id_length}
        ${idxless}   evaluate  ${idx}-1
#        Exit For Loop If   ${idxadd}==${ran-ue-ngap-Id_length}
        ${ran-ue-ngap-Id_repeat}   set variable if   ${ran-ue-ngap-Id_list}[${idxless}]==${ran-ue-ngap-Id_list}[${idx}]
        ...   ${ran-ue-ngap-Id_list}[${idx}]
#        Run Keyword If   @{ran-ue-ngap-Id_list}[${idxless}]==@{ran-ue-ngap-Id_list}[${idx}]   Run Keywords
#        Set Variable   ${ran-ue-ngap-Id_repeat}   @{ran-ue-ngap-Id_list}[${idx}]
#        ...   AND   Exit For Loop
    END

    Load Pcap File with Filter any Expression
    ...   pcap_file=/home/ute/hlp/TCPDUMP_20220125_0708.pcap
    ...   any_expression=nsetapx.CuVendorExtensionRecordDataType==13&&nsetapx.ran_ue_ngap_Id == ${ran-ue-ngap-Id_repeat}
    ...   filter=tcp.dstport==${dcap_server_port}
    ${trigger_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ueSetup_e}/nsetapx.trigger
    ${result_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ueSetup_e}/nsetapx.result
    ${ran-ue-ngap-Id_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ueSetup_e}/nsetapx.ran_ue_ngap_Id
    ${amf-ue-ngap-Id_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ueSetup_e}/nsetapx.amf_ue_ngap_Id
    ${plmn-Identity_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ueSetup_e}/nsetapx.guami_element/nsetapx.plmn_Identity
    ${amfRegionId_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ueSetup_e}/nsetapx.guami_element/nsetapx.amfRegionId
    ${amfSetId_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ueSetup_e}/nsetapx.guami_element/nsetapx.amfSetId
    ${amfPointer_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_ueSetup_e}/nsetapx.guami_element/nsetapx.amfPointer
    ${trigger_length}=     Get Length   ${trigger_list}
    ${result_length}=   Get Length   ${result_list}
    ${ran-ue-ngap-Id_length}=  Get Length   ${ran-ue-ngap-Id_list}
    ${amf-ue-ngap-Id_length}=  Get Length   ${amf-ue-ngap-Id_list}
    ${plmn-Identity_length}=  Get Length   ${plmn-Identity_list}
    ${amfRegionId_length}=  Get Length   ${amfRegionId_list}
    ${amfSetId_length}=  Get Length   ${amfSetId_list}
    ${amfPointer_length}=  Get Length   ${amfPointer_list}
    Should Contain X Times   ${trigger_list}   0   2
    Should Be True   ${result_list}[0] == ${result_list}[1] == 0
    Should Be True   ${ran-ue-ngap-Id_list}[0] == ${ran-ue-ngap-Id_list}[1]
    Should Be True   ${amf-ue-ngap-Id_list}[0] == ${amf-ue-ngap-Id_list}[1]
    Should Be True   '${plmn-Identity_list}[0]' == '${plmn-Identity_list}[1]'
    Should Be True   '${amfRegionId_list}[0]' == '${amfRegionId_list}[1]'
    Should Be True   '${amfSetId_list}[0]' == '${amfSetId_list}[1]'
    Should Be True   '${amfPointer_list}[0]' == '${amfPointer_list}[1]'
    List Should Contain Value   ${ngap_amf-ue-ngap-Id_list}   ${amf-ue-ngap-Id_list}[0]
    List Should Contain Value   ${ngap_ran-ue-ngap-Id_list}   ${ran-ue-ngap-Id_list}[0]
    List Should Contain Value   ${ngap_plmn-Identity_list}   ${plmn-Identity_list}[0]
    List Should Contain Value   ${ngap_amfRegionId_list}   ${amfRegionId_list}[0]
    List Should Contain Value    ${ngap_amfSetId_list}   ${amfSetId_list}[0]
    List Should Contain Value   ${ngap_amfPointer_list}   ${amfPointer_list}[0]



Case Setup: EA_20
    Log To Console   Case Setup: EA_20

Case Teardown: EA_20
    Log To Console   Case Teardown: EA_20
