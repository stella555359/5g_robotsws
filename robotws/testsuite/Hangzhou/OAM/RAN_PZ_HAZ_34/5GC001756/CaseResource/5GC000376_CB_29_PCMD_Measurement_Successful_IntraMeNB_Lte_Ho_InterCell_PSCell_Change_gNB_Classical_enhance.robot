*** Settings ***
Documentation
...   Author: shengyuan.jiang@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
5GC000376_CB_29_PCMD_Measurement_Successful_IntraMeNB_Lte_Ho_InterCell_PSCell_Change_gNB_Classical_enhance
    ${gnb_release}   Get gnb release
     Load Pcap File with Filter
            ...   pcap_file=${INTRA_MeNB_HO_gNB_PATH}
            ...   record_type=Du
            ...   input_type=10
            ...   filter=tcp.dstport==${dcap_server_port}
     ${data_path}   set variable if   '${gnb_release}'>'SBTS22R2'   nsetapx.data_r1_element   nsetapx.data_element
     ${xpath_head_ueCtxModificationRecord}   set variable   .//nsetapx.ueCtxModificationRecord/${data_path}/nsetapx.
     ${ueCtxModificationRecordResult}=    wireshark.get_field_value_by_xpath
     ...   xpath=${xpath_head_ueCtxModificationRecord}result   attribute_name=showname
     Should Contain     ${ueCtxModificationRecordResult}   result: success (0)
     ${ueCtxModificationReason}=    wireshark.get_field_value_by_xpath
     ...   xpath=${xpath_head_ueCtxModificationRecord}ueCtxModificationReason   attribute_name=showname
     Should Contain     ${ueCtxModificationReason}   ueCtxModificationReason: pdcpCountWraparound (7)

    Load Pcap File with Filter any Expression
            ...   pcap_file=${INTRA_MeNB_HO_gNB_PATH}
            ...   any_expression=x2ap
            ...   filter=tcp.dstport==${dcap_server_port}

    ${path1}   Set Variable   .//x2ap.SgNBModificationRequest_element/x2ap.protocolIEs//x2ap.ProtocolIE_Field_element/x2ap.value_element/
    ${path2}   Set Variable   x2ap.MeNBtoSgNBContainer/nr-rrc.CG_ConfigInfo_element/nr-rrc.criticalExtensions/nr-rrc.c1/nr-rrc.cg_ConfigInfo_element
    ${path3}   Set Variable   /nr-rrc.ue_CapabilityInfo/nr-rrc.UE_CapabilityRAT_ContainerList//nr-rrc.UE_CapabilityRAT_Container_element/
    ${path4}   Set Variable   nr-rrc.ue_CapabilityRAT_Container/nr-rrc.UE_MRDC_Capability_element/nr-rrc.rf_ParametersMRDC_element/
    ${path5}   Set Variable   nr-rrc.supportedBandCombinationList//nr-rrc.BandCombination_element/nr-rrc.bandList

    ${BandList}   wireshark.get_field_value_by_xpath   xpath=${path1}${path2}${path3}${path4}${path5}
    ${BandList_status}   Run Keyword And Return Status   Should Not Be Empty   ${BandList}
    ${allowedBC}   wireshark.get_field_value_by_xpath   xpath=${path1}${path2}/nr-rrc.configRestrictInfo_element/nr-rrc.allowedBC_ListMRDC
    ${allowedBC_status}   Run Keyword And Return Status   Should Not Be Empty   ${allowedBC}

    ${path1}   Set Variable   .//x2ap.SgNBModificationRequest_element/x2ap.protocolIEs//x2ap.ProtocolIE_Field_element/x2ap.value_element/
    ${SecurityKey}   wireshark.get_field_value_by_xpath   xpath=${path1}x2ap.UE_ContextInformation_SgNBModReq_element/x2ap.sgNB_SecurityKey
    ${SecurityKey_status}   Run Keyword And Return Status   Should Not Be Empty   ${SecurityKey}

     Load Pcap File with Filter
     ...                        pcap_file=${INTRA_MeNB_HO_gNB_PATH}
     ...                        record_type=Cu
     ...                        input_type=7
     ...                        filter=tcp.dstport==${dcap_server_port}
     ${MeNBInitiatedSgNBModificationReason}   wireshark.get_field_value_by_xpath
     ...   xpath=.//nsetapx.menbInitiatedSgNBModRecord/${data_path}/nsetapx.sgnbModificationReason
     ...   attribute_name=showname
#     Should Contain     ${MeNBInitiatedSgNBModificationReason}   sgnbModificationReason: securityKeyRefresh (2)
    Run Keyword If   ${BandList_status} and ${allowedBC_status}
     ...   Should Contain     ${MeNBInitiatedSgNBModificationReason}   sgnbModificationReason: scgConfigChangeOnly (1)
     ...   ELSE IF   '${BandList_status}'=='False' and '${allowedBC_status}'=='False' and '${SecurityKey_status}'
     ...   Should Contain     ${MeNBInitiatedSgNBModificationReason}   sgnbModificationReason: securityKeyRefresh (2)
     ...   ELSE   Fail
     
     ${MeNBInitiatedSgNBModificationReason_result}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.menbInitiatedSgNBModRecord/${data_path}/nsetapx.result   attribute_name=showname
     Should Contain     ${MeNBInitiatedSgNBModificationReason_result}   result: success (0)

#     ${MeNBInitiatedSgNBModificationReason_duUeCtxModificationResult}   wireshark.get_field_value_by_xpath
#     ...   xpath=.//nsetapx.menbInitiatedSgNBModRecord/nsetapx.data_r1_element/nsetapx.duUeCtxModificationResult
#     Should Contain    ${MeNBInitiatedSgNBModificationReason_duUeCtxModificationResult}  result: success (0)

     ${ReqRcv_sec}   wireshark.get_field_value_by_xpath
     ...   xpath=.//nsetapx.menbInitiatedSgNBModRecord/${data_path}/nsetapx.sgnbModificationReqRcvTime_element/nsetapx.seconds
     ${ReqRcv_use}   wireshark.get_field_value_by_xpath
     ...   xpath=.//nsetapx.menbInitiatedSgNBModRecord/${data_path}/nsetapx.sgnbModificationReqRcvTime_element/nsetapx.useconds

     ${ReqAckSnd_sec}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.menbInitiatedSgNBModRecord/${data_path}/nsetapx.sgnbModificationReqAckSndTime_element/nsetapx.seconds
     ${ReqAckSnd_use}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.menbInitiatedSgNBModRecord/${data_path}/nsetapx.sgnbModificationReqAckSndTime_element/nsetapx.useconds

     ${CmpRcv_sec}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.menbInitiatedSgNBModRecord/${data_path}/nsetapx.sgnbModificationCmplRcvTime_element/nsetapx.seconds
     ${CmpRcv_use}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.menbInitiatedSgNBModRecord/${data_path}/nsetapx.sgnbModificationCmplRcvTime_element/nsetapx.useconds

     log to console   check Time
     should not be empty   ${ReqRcv_sec}
     should not be empty   ${ReqRcv_use}
     should not be empty   ${ReqAckSnd_sec}
     should not be empty   ${ReqAckSnd_use}
     should not be empty   ${CmpRcv_sec}
     should not be empty   ${CmpRcv_use}

#     Load Pcap File with Filter
#     ...                        pcap_file=${INTRA_MeNB_HO_gNB_PATH}
#     ...                        record_type=Cu
#     ...                        input_type=12
#     ...                        filter=tcp.dstport==${dcap_server_port}
#     ${xpath_ueDuConnectivityRecord}   set variable   .//nsetapx.ueDuConnectivityRecord/nsetapx.data_element/nsetapx.modificationData//
#     ${duUeCtxModificationResult}=    wireshark.get_field_value_by_xpath
#     ...   xpath=${xpath_ueDuConnectivityRecord}nsetapx.DuUeCtxModificationData_element/nsetapx.duUeCtxModificationResult   attribute_name=showname
#     Should Contain    ${duUeCtxModificationResult}  duUeCtxModificationResult: success (0)
     Load Pcap File with Filter
     ...                        pcap_file=${INTRA_MeNB_HO_gNB_PATH}
     ...                        record_type=Du
     ...                        input_type=10
     ...                        filter=tcp.dstport==49148
    ${xpath_head_ueCtxModificationRecord}   set variable   .//nsetapx.ueCtxModificationRecord/${data_path}/nsetapx.
    ${PCMDRecord_Fields_list}=    wireshark.get_field_value_by_xpath
    ...   xpath=${xpath_head_ueCtxModificationRecord}result   attribute_name=showname
    Should Contain     ${PCMDRecord_Fields_list}   result: success (0)
    ${PCMDRecord_Fields_list}=    wireshark.get_field_value_by_xpath
    ...   xpath=${xpath_head_ueCtxModificationRecord}ueCtxModificationReason   attribute_name=showname
    Should Contain     ${PCMDRecord_Fields_list}   ueCtxModificationReason: pdcpCountWraparound (7)

     Load Pcap File with Filter
     ...                        pcap_file=${INTRA_MeNB_HO_gNB_PATH}
     ...                        record_type=Du
     ...                        input_type=1
     ...                        filter=tcp.dstport==${dcap_server_port}
     ${xpath_head_ueCtxSetupRecord}   set variable   .//nsetapx.ueCtxSetupRecord/${data_path}/nsetapx.
     ${ueCtxSetupReqRcvTime}=    wireshark.get_field_value_by_xpath
     ...   xpath=${xpath_head_ueCtxSetupRecord}ueCtxSetupReqRcvTime_element   attribute_name=showname
     should be equal     ${ueCtxSetupReqRcvTime}[0]   ueCtxSetupReqRcvTime
     ${ueCtxSetupRecordResult}=    wireshark.get_field_value_by_xpath
     ...   xpath=${xpath_head_ueCtxSetupRecord}result   attribute_name=showname
     should be equal     ${ueCtxSetupRecordResult}[0]   result: success (0)
#    ${PCMDRecord_Fields_list}=    wireshark.get_field_value_by_xpath    pdml_list=${filtered_PCMDRecord_packets}
#    ...   xpath=${xpath_head_ ueCtxSetupRecord}result   attribute_name=showname      #UE Context Setup Response send time??
##    should be equal     @{PCMDRecord_Fields_list}[0]   result: success (0)
     ${gnb_cu_ue_f1ap_Id}=    wireshark.get_field_value_by_xpath
     ...   xpath=${xpath_head_ueCtxSetupRecord}gnb_cu_ue_f1ap_Id
     Should Be True     0 < ${gnb_cu_ue_f1ap_Id}[0] < 4294967296 or ${gnb_cu_ue_f1ap_Id}[0]==0              #2^32-1


     Load Pcap File with Filter
     ...                        pcap_file=${INTRA_MeNB_HO_gNB_PATH}
     ...                        record_type=Du
     ...                        input_type=2
     ...                        filter=tcp.dstport==${dcap_server_port}
     ${xpath_head_ueCtxReleaseRecord}   set variable   .//nsetapx.ueCtxReleaseRecord/nsetapx.data_element/nsetapx.
     ${ueCtxReleaseRecord}=    wireshark.get_field_value_by_xpath
     ...   xpath=${xpath_head_ueCtxReleaseRecord}ueCtxReleaseReason   attribute_name=showname
     should be equal     ${ueCtxReleaseRecord}[0]   ueCtxReleaseReason: normal (0)


Case Setup: 5GC000376_CB_29
    Log To Console   Case Setup: 5GC000376_CB_29
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    ${file_status}   run keyword and return status   File Should Not Be Empty   ${INTRA_MeNB_HO_gNB_PATH}
    ${HO_status}   run keyword and return status   should not be empty   ${INTRA_MeNB_crnti_HO_list}
    set test variable   ${file_status}
    set test variable   ${HO_status}
    Run Keyword If   '${file_status}'=='False' or '${HO_status}'=='False'   Run Keywords
    ...   Common Setup 1756   AND
    ...   Remove And Add PCMD Object   AND
    ...   Trigger INTRA eNB HO   ${NSA_ue_index}    ${INTRA_MeNB_HO_gNB_FILE}
    run keyword if  '${file_status}'=='False' or '${HO_status}'=='False'   Get Variables from HO File for 5GC000376_CB_29

Get Variables from HO File for 5GC000376_CB_29
    ${INTRA_MeNB_crnti_HO_list}   Get nrcti of HO   ${INTRA_MeNB_HO_gNB_PATH}   nsetapx.CuVendorExtensionRecordDataType == 7
    set suite variable   ${INTRA_MeNB_crnti_HO_list}

Case Teardown: 5GC000376_CB_29
    Log To Console   Case Teardown: 5GC000376_CB_29
    robot_common_operations.Common Case Teardown
    Check Extra Reset From Blackbox
    Run Keyword If   '${file_status}'=='False' or '${HO_status}'=='False'   Run Keywords
    ...   Initialize PA   AND
    ...   Common Teardown 1756
