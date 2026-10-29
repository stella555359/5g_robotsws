# *** Settings ***
# Documentation
# ...   author: liping.hong@nokia-sbell.com
# ...   This case can cover case 12, case 15, case 17, case 24 in QC
# #Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009225_cloud/Common_resource/common_keyword.robot
# Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Cloud/CB009225_cloud/Common_resource/common_keyword.robot
# 
# Suite Setup   Common Suite Setup
# Suite Teardown   Common Suite Teardown
# 
# *** Variables ***
# 
# ${dcap_server_port}     49148
# ${source_VCU_CPIF_file}   sourcegnb_sa_cpif.pcap
# ${source_VCU_OAMAGENT_file}   sourcegnb_sa_oamagent.pcap
# ${source_VCU_file}   sourcegnb_sa_VCU.pcap
# ${source_VDU_OCP_file}   sourcegnb_sa_vduocp.pcap
# 
# ${target_VCU_CPIF_file}   targetgnb_sa_cpif.pcap
# ${target_VCU_OAMAGENT_file}   targetgnb_sa_oamagent.pcap
# ${target_VCU_file}   targetgnb_sa_VCU.pcap
# ${target_VDU_OCP_file}   targetgnb_sa_vduocp.pcap
# ${sa_ue_index}        0
# 
# 
# *** Test Cases ***
# CB008340-12_XnAPSourceHO_Record_XNAP_based_inter_gNB_HO_SA_Cloud
#     [Documentation]   Author: liping.hong@nokia-sbell.com
#     [Setup]   Case Setup
#     log to console   Check XnAPSourceHO Record and RRCSetup Record
#     Run Keyword And Continue On Failure   Get Source Fields for XnAPSourceHO Record
#     Run Keyword And Continue On Failure   Check Real Fields for XNAPSourceHO Record
#     Run Keyword And Continue On Failure   Check Real Fields for XNAPTargetHO Record
#     Run Keyword And Continue On Failure   Get Source Fields for RRC Setup Record
#     Run Keyword And Continue On Failure   Check Real Fields for CU-RRCSetup Record
#     Run Keyword And Continue On Failure   Check Real Fields for DU-RRCSetup Record
#     [Teardown]   Case Teardown
# 
# *** Keywords ***
# 
# Common Suite Setup
#     Download wireshark plugin For 1756
#     SA UE Preparation At Case Setup
#     Get ALL Suite Variables on VCU
#     Get Inter gnb HO Suite Variables on VCU
#     Trigger SA INTER gNB HO And Get ALL Tcpdump
# #    Wait Until Keyword Succeeds   15m   1m   CU Verify All Cells Status Are Onair
# 
# Common Suite Teardown
#     Log To Console    TearDown TBD...
# #    Wait Until Keyword Succeeds   15m   1m   CU Verify All Cells Status Are Onair
# 
# Case Setup
#     Log To Console   Case Setup: CB008340-01
# 
# Case Teardown
#     Log To Console   Case Teardown: CB008340-01
# 
# Check Real Fields for XNAPSourceHO Record
#      [Documentation]   This keyword is used to get fields for XNAPSourceHO Record
#      Load Pcap File with Filter any Expression
#      ...                        pcap_file=${OUTPUT_DIR}/${source_VCU_OAMAGENT_file}
#      ...                        any_expression=nsetapx.xnHoSrcRecord == 0
#      ...                        filter=sctp.dstport==49148
#      ${data}   set variable   .//nsetapx.CuVendorExtensionRecordDataType/nsetapx.xnHoSrcRecord/nsetapx.data_element
#      ${xn_ho_result_xpath}   set variable   ${data}/nsetapx.result
#      ${xn_ho_result}=   wireshark.get_field_value_by_xpath   xpath=${xn_ho_result_xpath}   attribute_name=showname
# 
#      ${xn_ho_mobilityreson_xpath}   set variable   ${data}/nsetapx.mobilityReason
#      ${xn_ho_mobilityreson}=   wireshark.get_field_value_by_xpath   xpath=${xn_ho_mobilityreson_xpath}   attribute_name=showname
# 
#      ${xn_ho_plmn_xpath}   set variable   ${data}/nsetapx.tgtNgranNodeId/nsetapx.gnb_Id_element/nsetapx.plmn_Identity
#      ${xn_ho_plmn}=   wireshark.get_field_value_by_xpath   xpath=${xn_ho_plmn_xpath}   attribute_name=showname
# 
#      ${xn_ho_gnbid_xpath}   set variable   ${data}/nsetapx.tgtNgranNodeId/nsetapx.gnb_Id_element/nsetapx.gnb_Id/nsetapx.gnb_id
#      ${xn_ho_gnbid}=   wireshark.get_field_value_by_xpath   xpath=${xn_ho_gnbid_xpath}   attribute_name=showname
# 
#      ${xn_ho_cellidentity_xpath}   set variable   ${data}/nsetapx.tgtNgranCellId/nsetapx.nrcgi_element/nsetapx.cellIdentity
#      ${xn_ho_cellidentity}=   wireshark.get_field_value_by_xpath   xpath=${xn_ho_cellidentity_xpath}   attribute_name=showname
# 
#      ${xn_ho_reqsendtime_xpath}   set variable   ${data}/nsetapx.hoReqSndTime_element/nsetapx.seconds
#      ${xn_ho_reqsendtime_list}=   wireshark.get_field_value_by_xpath   xpath=${xn_ho_reqsendtime_xpath}
#      ${xn_ho_reqsendtime_usec_xpath}   set variable   ${data}/nsetapx.hoReqSndTime_element/nsetapx.useconds
#      ${xn_ho_reqsendtime_usec_list}=   wireshark.get_field_value_by_xpath   xpath=${xn_ho_reqsendtime_usec_xpath}
# 
#      ${xn_ho_cmdsendtime_xpath}   set variable   ${data}/nsetapx.hoCmdSndTime_element/nsetapx.seconds
#      ${xn_ho_cmdsendtime_list}=   wireshark.get_field_value_by_xpath   xpath=${xn_ho_cmdsendtime_xpath}
#      ${xn_ho_cmdsendtime_usec_xpath}   set variable   ${data}/nsetapx.hoCmdSndTime_element/nsetapx.useconds
#      ${xn_ho_cmdsendtime_usec_list}=   wireshark.get_field_value_by_xpath   xpath=${xn_ho_cmdsendtime_usec_xpath}
# 
#      ${xn_ho_sourceNG-RANnodeUEXnAPID_xpath}   set variable   ${data}/nsetapx.src_ng_rannode_ue_xnap_Id
#      ${xn_ho_sourceNG-RANnodeUEXnAPID}=   wireshark.get_field_value_by_xpath   xpath=${xn_ho_sourceNG-RANnodeUEXnAPID_xpath}
# 
#      Run Keyword And Continue On Failure   Should Contain   ${xn_ho_result}[0]   success
#      Run Keyword And Continue On Failure   Should Contain   ${xn_ho_mobilityreson}[0]   radioCondition
#      Run Keyword And Continue On Failure   Should Contain   ${xn_ho_plmn}[0]   ${PEER_PLMN_IDENTITY}
#      Run Keyword And Continue On Failure   Should Contain   ${xn_ho_cellidentity}[0]   ${PEER_NRCELLID}
#      Run Keyword And Continue On Failure   Should Be Equal   ${xn_ho_sourceNG-RANnodeUEXnAPID}[0]   ${sourceNG-RANnodeUEXnAPID}[0]
# 
#      ${PEER_MRBTS_ID}   Convert To String   ${PEER_MRBTS_ID}
#      Run Keyword And Continue On Failure   Should Contain   ${xn_ho_gnbid}[0]   ${PEER_MRBTS_ID}
# 
#      :FOR   ${xn_ho_reqsendtime}   IN   @{xn_ho_reqsendtime_list}
#        ${xn_ho_reqsendtime}   Convert To Integer   ${xn_ho_reqsendtime}
#        Run Keyword And Continue On Failure   Should Be True   ${xn_ho_reqsendtime} != 0
#        ${handover_request_timestamp_convert}   Convert To Integer   ${handover_setup_request_timestamp}[0]
#        Run Keyword And Continue On Failure   Should Be Equal   ${xn_ho_reqsendtime}   ${handover_request_timestamp_convert}
#     END
# 
#     :FOR   ${xn_ho_reqsendtime_usec}   IN   @{xn_ho_reqsendtime_usec_list}
#         Run Keyword And Continue On Failure   Should Be True   ${xn_ho_reqsendtime_usec} != 0
#     END
# 
#     :FOR   ${xn_ho_cmdsendtime}   IN   @{xn_ho_cmdsendtime_list}
#        ${xn_ho_reqsendtime}   Convert To Integer   ${xn_ho_cmdsendtime}
#        Run Keyword And Continue On Failure   Should Be True   ${xn_ho_cmdsendtime} != 0
#     END
# 
#     :FOR   ${xn_ho_cmdsendtime_usec}   IN   @{xn_ho_cmdsendtime_usec_list}
#         Run Keyword And Continue On Failure   Should Be True   ${xn_ho_cmdsendtime_usec} != 0
#     END
# 
# Check Real Fields for XNAPTargetHO Record
#      [Documentation]   This keyword is used to get fields for XNAPTargetHO Records
#      Load Pcap File with Filter any Expression
#      ...                        pcap_file=${OUTPUT_DIR}/${target_VCU_OAMAGENT_file}
#      ...                        any_expression=nsetapx.xnHoTgtRecord == 0
#      ...                        filter=sctp.dstport==49148
#      ${data}   set variable   .//nsetapx.CuVendorExtensionRecordDataType/nsetapx.xnHoTgtRecord/nsetapx.data_element
#      ${xn_ho_tgt_result_xpath}   set variable   ${data}/nsetapx.result
#      ${xn_ho_tgt_result}=   wireshark.get_field_value_by_xpath   xpath=${xn_ho_tgt_result_xpath}   attribute_name=showname
# 
#      ${xn_ho_tgt_plmn_xpath}   set variable   ${data}/nsetapx.srcNgranCellId/nsetapx.nrcgi_element/nsetapx.plmn_Identity
#      ${xn_ho_tgt_plmn}=   wireshark.get_field_value_by_xpath   xpath=${xn_ho_tgt_plmn_xpath}   attribute_name=showname
# 
#      ${xn_ho_tgt_cellidentity_xpath}   set variable   ${data}/nsetapx.srcNgranCellId/nsetapx.nrcgi_element/nsetapx.cellIdentity
#      ${xn_ho_tgt_cellidentity}=   wireshark.get_field_value_by_xpath   xpath=${xn_ho_tgt_cellidentity_xpath}   attribute_name=showname
# 
#      ${xn_ho_tgt_gnbid_xpath}   set variable   ${data}/nsetapx.srcNgranNodeId/nsetapx.gnb_Id_element/nsetapx.gnb_Id/nsetapx.gnb_id
#      ${xn_ho_tgt_gnbid}=   wireshark.get_field_value_by_xpath   xpath=${xn_ho_tgt_gnbid_xpath}   attribute_name=showname
# 
#      ${xn_ho_rcvsendtime_xpath}   set variable   ${data}/nsetapx.hoReqRcvTime_element/nsetapx.seconds
#      ${xn_ho_rcvsendtime_list}=   wireshark.get_field_value_by_xpath   xpath=${xn_ho_rcvsendtime_xpath}
#      ${xn_ho_rcvsendtime_usec_xpath}   set variable   ${data}/nsetapx.hoReqRcvTime_element/nsetapx.useconds
#      ${xn_ho_rcvsendtime_usec_list}=   wireshark.get_field_value_by_xpath   xpath=${xn_ho_rcvsendtime_usec_xpath}
# 
#      ${xn_ho_cmdrcvtime_xpath}   set variable   ${data}/nsetapx.hoCmdCmplRcvTime_element/nsetapx.seconds
#      ${xn_ho_cmdrcvtime_list}=   wireshark.get_field_value_by_xpath   xpath=${xn_ho_cmdrcvtime_xpath}
#      ${xn_ho_cmdrcvtime_usec_xpath}   set variable   ${data}/nsetapx.hoCmdCmplRcvTime_element/nsetapx.useconds
#      ${xn_ho_cmdrcvtime_usec_list}=   wireshark.get_field_value_by_xpath   xpath=${xn_ho_cmdrcvtime_usec_xpath}
# 
#      Run Keyword And Continue On Failure   Should Contain   ${xn_ho_tgt_result}[0]   success
#      Run Keyword And Continue On Failure   Should Contain   ${xn_ho_tgt_plmn}[0]   ${LOCAL_PLMN_IDENTITY}
#      Run Keyword And Continue On Failure   Should Contain   ${xn_ho_tgt_cellidentity}[0]   ${LOCAL_NRCELLID}
# 
#      ${MRBTS_ID_STR}   Convert To String   ${LOCAL_MRBTS_ID}
#      Run Keyword And Continue On Failure   Should Contain   ${xn_ho_tgt_gnbid}[0]   ${MRBTS_ID_STR}
# 
#      :FOR   ${xn_ho_rcvsendtime}   IN   @{xn_ho_rcvsendtime_list}
#        ${xn_ho_reqsendtime}   Convert To Integer   ${xn_ho_rcvsendtime}
#        Run Keyword And Continue On Failure   Should Be True   ${xn_ho_rcvsendtime} != 0
#        ${handover_request_timestamp_convert}   Convert To Integer   ${handover_setup_request_timestamp}[0]
#        Run Keyword And Continue On Failure   Should Be Equal   ${xn_ho_reqsendtime}   ${handover_request_timestamp_convert}
#     END
# 
#     :FOR   ${xn_ho_rcvsendtime_usec}   IN   @{xn_ho_rcvsendtime_usec_list}
#         Run Keyword And Continue On Failure   Should Be True   ${xn_ho_rcvsendtime_usec} != 0
#     END
# 
#     :FOR   ${xn_ho_cmdrcvtime}   IN   @{xn_ho_cmdrcvtime_list}
#        ${xn_ho_reqsendtime}   Convert To Integer   ${xn_ho_cmdrcvtime}
#        Run Keyword And Continue On Failure   Should Be True   ${xn_ho_cmdrcvtime} != 0
#     END
# 
#     :FOR   ${xn_ho_cmdrcvtime_usec}   IN   @{xn_ho_cmdrcvtime_usec_list}
#         Run Keyword And Continue On Failure   Should Be True   ${xn_ho_cmdrcvtime_usec} != 0
#     END
# 
# Get Source Fields for XnAPSourceHO Record
#      [Documentation]   This keyword is used to get source fields of "XnAP HO Request send time"
#     ...   "sourceNG-RANnodeUEXnAPID" "targetNG-RANnodeUEXnAPID" "ng-c-UE-reference" "Target Cell Global ID" for XnAPSourceHO Record
#      Load Pcap File with Filter any Expression
#      ...                        pcap_file=${OUTPUT_DIR}/${source_VCU_OAMAGENT_file}
#      ...                          any_expression=nsetapx.asn1_MsgId == 78
#      ...                        filter=sctp.dstport==49148
#      ${handover_xpath_1}   set variable   xnap.initiatingMessage_element/xnap.value_element/xnap.HandoverRequest_element
#      ${handover_setup_request_xpath}   set variable   .//nsetapx.data/nsetapx.asn1_Data_element/xnap/xnap.XnAP_PDU/${handover_xpath_1}
#      ${handover_setup_request}=   wireshark.get_field_value_by_xpath   xpath=${handover_setup_request_xpath}   attribute_name=showname
# 
#      ${handover_setup_request_timestamp_xpath}   set variable   .//nsetapx.timestamp_element/nsetapx.seconds
#      ${handover_setup_request_timestamp}=   wireshark.get_field_value_by_xpath   xpath=${handover_setup_request_timestamp_xpath}
# 
#      ${sourceNG-RANnodeUEXnAPID_xpath}   set variable
#      ...   .//xnap.HandoverRequest_element/xnap.protocolIEs//xnap.ProtocolIE_Field_element/xnap.value_element/xnap.NG_RANnodeUEXnAPID
#      ${sourceNG-RANnodeUEXnAPID}=   wireshark.get_field_value_by_xpath   xpath=${sourceNG-RANnodeUEXnAPID_xpath}
# 
#      ${Target_Cell_Global_ID_xpath}   set variable   ${handover_setup_request_xpath}/xnap.protocolIEs//xnap.ProtocolIE_Field_element/xnap.id
#      ${Target_Cell_Global_ID}=   wireshark.get_field_value_by_xpath   xpath=${Target_Cell_Global_ID_xpath}   attribute_name=showname
# 
#      ${ng_xpath_1}   set variable   xnap.value_element/xnap.UEContextInfoHORequest_element/xnap.ng_c_UE_reference
#      ${ng-c-UE-reference_xpath}   set variable   ${handover_setup_request_xpath}/xnap.protocolIEs//xnap.ProtocolIE_Field_element/${ng_xpath_1}
#      ${ng-c-UE-reference}=   wireshark.get_field_value_by_xpath   xpath=${ng-c-UE-reference_xpath}   attribute_name=showname
# 
# 
#      Load Pcap File with Filter any Expression
#      ...                        pcap_file=${OUTPUT_DIR}/${source_VCU_OAMAGENT_file}
#      ...                          any_expression=nsetapx.asn1_MsgId == 79
#      ...                        filter=sctp.dstport==49148
#      ${targetNG_xpath_1}   set variable   xnap.ProtocolIE_Field_element/xnap.id
#      ${targetNG-RANnodeUEXnAPID_xpath}   set variable   .//xnap.HandoverRequestAcknowledge_element/xnap.protocolIEs//${targetNG_xpath_1}
#      ${targetNG-RANnodeUEXnAPID}=   wireshark.get_field_value_by_xpath   xpath=${targetNG-RANnodeUEXnAPID_xpath}   attribute_name=showname
# 
#      log to console   ${handover_setup_request}
#      Set Suite Variable   ${handover_setup_request_timestamp}
#      log to console   ${handover_setup_request_timestamp}
#      Set Suite Variable   ${sourceNG-RANnodeUEXnAPID}
#      log to console   ${sourceNG-RANnodeUEXnAPID}[0]
#      log to console   ${Target_Cell_Global_ID}[2]
#      log to console   ${targetNG-RANnodeUEXnAPID}[1]
#      log to console   ${ng-c-UE-reference}
# 
# 
# Get Source Fields for RRC Setup Record
#     [Documentation]   This keyword is used to get source fields of "RRC connection trigger receive time"
#     ...   "RRC connection complete receive time" and "ng-5G-S-TMSI-Value" for gNB-CU RRCSetup Record and
#     ...   gNB-DU RRCSetup Record
#     Load Pcap File with Filter any Expression
#      ...                        pcap_file=${OUTPUT_DIR}/${source_VCU_OAMAGENT_file}
#      ...                          any_expression=nsetapx.asn1_MsgId == 26
#      ...                        filter=sctp.dstport==49148
#      ${CuR1}   Set Variable   .//nsetapx.TraceMessage/nsetapx.report_element/nsetapx.recordingSessionReportList/nsetapx.
# ...cuRecordingSessionReportList
#      ${CuRecord}   Set Variable   ${CuR1}//nsetapx.CuRecordingSessionReport_element/nsetapx.recordList//nsetapx.CuRecord_element
#      ${nr_rrc}   Set Variable   nsetapx.data/nsetapx.asn1_Data_element/nr-rrc
# 
#      ${rrc_setup_request_xpath}   Set Variable
#      ...   ${CuRecord}/${nr_rrc}/nr-rrc.UL_CCCH_Message_element/nr-rrc.message/nr-rrc.c1/nr-rrc.rrcSetupRequest_element
#      ${rrc_setup_request}=   wireshark.get_field_value_by_xpath   xpath=${rrc_setup_request_xpath}   attribute_name=showname
# 
#      ${rrc_setup_request_timestamp_xpath}   set variable   .//nsetapx.timestamp_element/nsetapx.seconds
# #     ${rrc_setup_request_timestamp_xpath}   set variable   ${CuRecord}/nsetapx.timestamp_element/nsetapx.seconds
#      ${rrc_setup_request_timestamp}=   wireshark.get_field_value_by_xpath   xpath=${rrc_setup_request_timestamp_xpath}
#      Set Suite Variable   ${rrc_setup_request_timestamp}
# 
#      ${estab_cause_xpath}   set variable  .//nr-rrc.c1/nr-rrc.rrcSetupRequest_element/nr-rrc.rrcSetupRequest_element/nr-rrc.establishmentCause
#      ${estab_cause}=   wireshark.get_field_value_by_xpath   xpath=${estab_cause_xpath}   attribute_name=showname
#      Set Suite Variable   ${estab_cause}
# 
#      log to console   ${rrc_setup_request}
#      log to console   ${rrc_setup_request_timestamp}
#      Load Pcap File with Filter any Expression
#      ...                        pcap_file=${OUTPUT_DIR}/${source_VCU_OAMAGENT_file}
#      ...                          any_expression=nsetapx.asn1_MsgId == 25
#      ...                        filter=sctp.dstport==49148
#      ${rrc_setup_complete_xpath_1}   Set Variable   nr-rrc.UL_DCCH_Message_element/nr-rrc.message/nr-rrc.c1/nr-rrc.rrcSetupComplete_element
#      ${rrc_setup_complete_xpath}   Set Variable   ${CuRecord}/${nr_rrc}/${rrc_setup_complete_xpath_1}
#      ${rrc_setup_complete}=   wireshark.get_field_value_by_xpath   xpath=${rrc_setup_complete_xpath}   attribute_name=showname
#      ${rrc_setup_complete_timestamp_xpath}   Set Variable   ${CuRecord}/nsetapx.timestamp_element/nsetapx.seconds
#      ${rrc_setup_complete_timestamp}=   wireshark.get_field_value_by_xpath   xpath=${rrc_setup_complete_timestamp_xpath}
#      ${ng-5G-S-TMSI-Value-xpath_1}   Set Variable   nr-rrc.criticalExtensions/nr-rrc.rrcSetupComplete_element/nr-rrc.ng_5G_S_TMSI_Value
#      ${ng-5G-S-TMSI-Value-xpath}   Set Variable   ${rrc_setup_complete_xpath}/${ng-5G-S-TMSI-Value-xpath_1}
#      ${ng-5G-S-TMSI-Value}=   wireshark.get_field_value_by_xpath   xpath=${ng-5G-S-TMSI-Value-xpath}   attribute_name=showname
#      log to console   ${rrc_setup_complete}
#      log to console   ${rrc_setup_complete_timestamp}
#      log to console   ${ng-5G-S-TMSI-Value}
# 
# Check Real Fields for CU-RRCSetup Record
#      [Documentation]   This keyword is used to get fields for CU-RRCSetup Record
#      Load Pcap File with Filter any Expression
#      ...                        pcap_file=${OUTPUT_DIR}/${source_VCU_OAMAGENT_file}
#      ...                        any_expression=nsetapx.CuVendorExtensionRecordDataType == 18
#      ...                        filter=sctp.dstport==49148
#      ${data}   set variable   .//nsetapx.CuVendorExtensionRecordDataType/nsetapx.rrcSetupRecord/nsetapx.data_element
#      ${cu_rrcsetup_result_xpath}   set variable   ${data}/nsetapx.result
#      ${cu_rrcsetup_result}=   wireshark.get_field_value_by_xpath   xpath=${cu_rrcsetup_result_xpath}   attribute_name=showname
# 
#      ${cu_rrcsetup_estab_xpath}   set variable   ${data}/nsetapx.establishmentCauseType/nsetapx.establishmentCause
#      ${cu_rrcsetup_estab}=   wireshark.get_field_value_by_xpath   xpath=${cu_rrcsetup_estab_xpath}   attribute_name=showname
# 
#      ${cu_rrcsetup_Trigger_rcvtime_xpath}   set variable   ${data}/nsetapx.rrcConnReqTriggerRcvTime_element/nsetapx.seconds
#      ${cu_rrcsetup_Trigger_rcvtime_list}=   wireshark.get_field_value_by_xpath   xpath=${cu_rrcsetup_Trigger_rcvtime_xpath}
#      ${cu_rrcsetup_Trigger_rcvtime_usec_xpath}   set variable   ${data}/nsetapx.rrcConnReqTriggerRcvTime_element/nsetapx.useconds
#      ${cu_rrcsetup_Trigger_rcvtime_usec_list}=   wireshark.get_field_value_by_xpath   xpath=${cu_rrcsetup_Trigger_rcvtime_usec_xpath}
# 
#      ${cu_rrcsetup_cmp_rcvtime_xpath}   set variable   ${data}/nsetapx.rrcConnSetupCmplRcvTime_element/nsetapx.seconds
#      ${cu_rrcsetup_cmp_rcvtime_list}=   wireshark.get_field_value_by_xpath   xpath=${cu_rrcsetup_cmp_rcvtime_xpath}
#      ${cu_rrcsetup_cmp_rcvtime_usec_xpath}   set variable   ${data}/nsetapx.rrcConnSetupCmplRcvTime_element/nsetapx.useconds
#      ${cu_rrcsetup_cmp_rcvtime_usec_list}=   wireshark.get_field_value_by_xpath   xpath=${cu_rrcsetup_cmp_rcvtime_usec_xpath}
# 
#      Run Keyword And Continue On Failure   Should Contain   ${cu_rrcsetup_result}[0]   success
#      Run Keyword And Continue On Failure   List Should Contain Value   ${estab_cause}   establishmentCause: mo-Signalling (3)
#      Run Keyword And Continue On Failure   List Should Contain Value   ${cu_rrcsetup_estab}   establishmentCause: moSignalling (4)
# #     Run Keyword And Continue On Failure   List Should Contain Value   ${estab_cause}   ${cu_rrcsetup_estab}[0]
# 
#      :FOR   ${cu_rrcsetup_Trigger_rcvtime}   IN   @{cu_rrcsetup_Trigger_rcvtime_list}
#        ${cu_rrcsetup_Trigger_rcvtime}   Convert To Integer   ${cu_rrcsetup_Trigger_rcvtime}
#        Run Keyword And Continue On Failure   Should Be True   ${cu_rrcsetup_Trigger_rcvtime} != 0
#        ${rrc_setup_request_timestamp_convert}   Convert To Integer   ${rrc_setup_request_timestamp}[0]
#        Exit For Loop If   '${cu_rrcsetup_Trigger_rcvtime}'=='${rrc_setup_request_timestamp_convert}'
#     END
# 
#     :FOR   ${cu_rrcsetup_Trigger_rcvtime_usec}   IN   @{cu_rrcsetup_Trigger_rcvtime_usec_list}
#         Run Keyword And Continue On Failure   Should Be True   ${cu_rrcsetup_Trigger_rcvtime_usec} != 0
#     END
# 
# 
#     :FOR   ${cu_rrcsetup_cmp_rcvtime}   IN   @{cu_rrcsetup_cmp_rcvtime_list}
#        ${cu_rrcsetup_cmp_rcvtime}   Convert To Integer   ${cu_rrcsetup_cmp_rcvtime}
#        Run Keyword And Continue On Failure   Should Be True   ${cu_rrcsetup_cmp_rcvtime} != 0
#     END
# 
#     :FOR   ${cu_rrcsetup_cmp_rcvtime_usec}   IN   @{cu_rrcsetup_cmp_rcvtime_usec_list}
#         Run Keyword And Continue On Failure   Should Be True   ${cu_rrcsetup_cmp_rcvtime_usec} != 0
#     END
# 
# Check Real Fields for DU-RRCSetup Record
#      [Documentation]   This keyword is used to get fields for DU-RRCSetup Record
#      Load Pcap File with Filter any Expression
#      ...                        pcap_file=${OUTPUT_DIR}/${source_VDU_OCP_file}
#      ...                        any_expression=nsetapx.DuVendorExtensionRecordDataType == 16
#      ...                        filter=sctp.dstport==49148
#      ${data}   set variable   .//nsetapx.DuVendorExtensionRecordDataType/nsetapx.rrcSetupRecord/nsetapx.data_element
#      ${du_rrcsetup_result_xpath}   set variable   ${data}/nsetapx.result
#      ${du_rrcsetup_result}=   wireshark.get_field_value_by_xpath   xpath=${du_rrcsetup_result_xpath}   attribute_name=showname
# 
#      ${du_rrcsetup_estab_xpath}   set variable   ${data}/nsetapx.establishmentCauseType/nsetapx.establishmentCause
#      ${du_rrcsetup_estab}=   wireshark.get_field_value_by_xpath   xpath=${du_rrcsetup_estab_xpath}   attribute_name=showname
# 
#      ${du_rrcsetup_Trigger_rcvtime_xpath}   set variable   ${data}/nsetapx.rrcConnReqTriggerRcvTime_element/nsetapx.seconds
#      ${du_rrcsetup_Trigger_rcvtime_list}=   wireshark.get_field_value_by_xpath   xpath=${du_rrcsetup_Trigger_rcvtime_xpath}
#      ${du_rrcsetup_Trigger_rcvtime_usec_xpath}   set variable   ${data}/nsetapx.rrcConnReqTriggerRcvTime_element/nsetapx.useconds
#      ${du_rrcsetup_Trigger_rcvtime_usec_list}=   wireshark.get_field_value_by_xpath   xpath=${du_rrcsetup_Trigger_rcvtime_usec_xpath}
# 
#      ${du_rrcsetup_cmp_rcvtime_xpath}   set variable   ${data}/nsetapx.rrcConnSetupCmplRcvTime_element/nsetapx.seconds
#      ${du_rrcsetup_cmp_rcvtime_list}=   wireshark.get_field_value_by_xpath   xpath=${du_rrcsetup_cmp_rcvtime_xpath}
#      ${du_rrcsetup_cmp_rcvtime_usec_xpath}   set variable   ${data}/nsetapx.rrcConnSetupCmplRcvTime_element/nsetapx.useconds
#      ${du_rrcsetup_cmp_rcvtime_usec_list}=   wireshark.get_field_value_by_xpath   xpath=${du_rrcsetup_cmp_rcvtime_usec_xpath}
# 
#      Run Keyword And Continue On Failure   Should Contain   ${du_rrcsetup_result}[0]   success
#      Run Keyword And Continue On Failure   List Should Contain Value   ${estab_cause}   establishmentCause: mo-Signalling (3)
#      Run Keyword And Continue On Failure   List Should Contain Value   ${du_rrcsetup_estab}   establishmentCause: moSignalling (4)
# #     Run Keyword And Continue On Failure   List Should Contain Value   ${estab_cause}   ${du_rrcsetup_estab}[0]
# 
#      :FOR   ${du_rrcsetup_Trigger_rcvtime}   IN   @{du_rrcsetup_Trigger_rcvtime_list}
#        ${du_rrcsetup_Trigger_rcvtime}   Convert To Integer   ${du_rrcsetup_Trigger_rcvtime}
#        Run Keyword And Continue On Failure   Should Be True   ${du_rrcsetup_Trigger_rcvtime} != 0
#        ${rrc_setup_request_timestamp_convert}   Convert To Integer   ${rrc_setup_request_timestamp}[0]
#        Exit For Loop If   '${du_rrcsetup_Trigger_rcvtime}'=='${rrc_setup_request_timestamp_convert}'
#     END
# 
#     :FOR   ${du_rrcsetup_Trigger_rcvtime_usec}   IN   @{du_rrcsetup_Trigger_rcvtime_usec_list}
#         Run Keyword And Continue On Failure   Should Be True   ${du_rrcsetup_Trigger_rcvtime_usec} != 0
#     END
# 
#     :FOR   ${du_rrcsetup_cmp_rcvtime}   IN   @{du_rrcsetup_cmp_rcvtime_list}
#        ${du_rrcsetup_cmp_rcvtime}   Convert To Integer   ${du_rrcsetup_cmp_rcvtime}
#        Run Keyword And Continue On Failure   Should Be True   ${du_rrcsetup_cmp_rcvtime} != 0
#     END
# 
#     :FOR   ${du_rrcsetup_cmp_rcvtime_usec}   IN   @{du_rrcsetup_cmp_rcvtime_usec_list}
#         Run Keyword And Continue On Failure   Should Be True   ${du_rrcsetup_cmp_rcvtime_usec} != 0
#     END