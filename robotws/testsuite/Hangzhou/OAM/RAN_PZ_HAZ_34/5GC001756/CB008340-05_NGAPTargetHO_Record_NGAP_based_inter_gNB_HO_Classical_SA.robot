# *** Settings ***
# Documentation
# ...   Author: xiaofei.li@nokia-sbell.com
# ...   This case can cover case 02, case 05 in QC
# 
# Resource   Resource/Common.robot
# 
# *** Variables ***
# ${SA_ue_index}    0
# ${NGAP_SA_INTER_gNB_HO_TARGET_FILE}   NGAP_SA_INTER_gNB_HO_TARGET.pcap
# ${NGAP_SA_INTER_gNB_HO_TARGET_PATH}   ${OUTPUT_DIR}/${NGAP_SA_INTER_gNB_HO_TARGET_FILE}
# ${NGAP_SA_INTER_gNB_HO_SOURCE_FILE}   NGAP_SA_INTER_gNB_HO_SOURCE.pcap
# ${NGAP_SA_INTER_gNB_HO_SOURCE_PATH}   ${OUTPUT_DIR}/${NGAP_SA_INTER_gNB_HO_SOURCE_FILE}
# 
# *** Test Cases ***
# [1]CB008340-05_NGAPTargetHO_Record_NGAP_based_inter_gNB_HO_Classical_SA
#     [Documentation]   Author: xiaofei.li@nokia-sbell.com
#     [Setup]   Case Setup
#     Run Keyword And Continue On Failure   Get Source Fields for NGAPHO Record
#     Run Keyword And Continue On Failure   Check Real Fields for NGAPSourceHO Record
#     Run Keyword And Continue On Failure   Check Real Fields for NGAPTargetHO Record
#     [Teardown]   Case Teardown
# 
# *** Keywords ***
# Common Suite Setup
#     robot_common_operations.Common Suite Setup
# 
# Common Suite Teardown
#     robot_common_operations.Common Suite Teardown
# 
# Case Setup
#     Log To Console   Case Setup: CB008340-05
#     robot_common_operations.Common Case Setup    allowed_faults_ids=8000
#     Common Setup 1756
#     Get HO Suite Variables
#     Should Be True   '${actCellTraceReportingCU_peer}'=='true'
#     Remove And Add PCMD Object
#     Update NG Based HO Parameters For Local
#     Update NG Based HO Parameters For Peer
#     Run Keyword And Ignore Error   COAM Logout
#     Trigger INTER gNB HO   ${SA_ue_index}   ${NGAP_SA_INTER_gNB_HO_TARGET_FILE}   ${NGAP_SA_INTER_gNB_HO_SOURCE_FILE}   SA
# 
# Case Teardown
#     robot_common_operations.Common Case Teardown
#     Log To Console   Case Teardown: CB008340-05
#     Run Keyword If Test Failed   Save gNB Snapshot   host=${LOCAL_SSH_ADDR}   alias=master
#     Run Keyword If Test Passed   Run Keyword And Ignore Error   RUN   rm -rf ${NGAP_SA_INTER_gNB_HO_SOURCE_PATH}
#     Run Keyword If Test Passed   Run Keyword And Ignore Error   RUN   rm -rf ${NGAP_SA_INTER_gNB_HO_TARGET_PATH}
#     Recovery NG Based HO Parameters For Local
#     Recovery NG Based HO Parameters For Peer
#     Run Keyword And Ignore Error   Initialize PA
#     Run Keyword And Ignore Error   Common Teardown 1756
# 
# Check NGbased Handover Status
#      log to console   Check XNbased Handover Status from Target gNB
#      Load Pcap File with Filter any Expression
#      ...                        pcap_file=${NGAP_SA_INTER_gNB_HO_SOURCE_PATH}
#      ...                          any_expression=ngap.HandoverRequired_element
#      ...                        filter=sctp.dstport==49148
#      ${handover_xpath}   Catenate  SEPARATOR=
#      ...   .//ngap.NGAP_PDU/ngap.initiatingMessage_element/ngap.value_element/ngap.HandoverRequired_element
#      ...   /ngap.protocolIEs//ngap.ProtocolIE_Field_element/ngap.value_element/ngap.Cause/ngap.radioNetwork
#      ${handover_check}=   wireshark.get_field_value_by_xpath   xpath=${handover_xpath}   attribute_name=showname
#      log to console   ${handover_check}
#      should contain   ${handover_check}[-1]   handover-desirable-for-radio-reason
# 
# Check Real Fields for NGAPSourceHO Record
#      [Documentation]   This keyword is used to get fields for NGAPSourceHO Record
#      Load Pcap File with Filter any Expression
#      ...                        pcap_file=${NGAP_SA_INTER_gNB_HO_SOURCE_PATH}
#      ...                        any_expression=nsetapx.ngHoSrcRecord == 0
#      ...                        filter=sctp.dstport==49148
#      ${data}   set variable   .//nsetapx.CuVendorExtensionRecordDataType/nsetapx.ngHoSrcRecord/nsetapx.data_element
#      ${ng_ho_result_xpath}   set variable   ${data}/nsetapx.result
#      ${ng_ho_result}=   wireshark.get_field_value_by_xpath   xpath=${ng_ho_result_xpath}   attribute_name=showname
# 
#      ${ng_ho_mobilityreson_xpath}   set variable   ${data}/nsetapx.mobilityReason
#      ${ng_ho_mobilityreson}=   wireshark.get_field_value_by_xpath   xpath=${ng_ho_mobilityreson_xpath}   attribute_name=showname
# 
#      ${ng_ho_plmn_xpath}   set variable   ${data}/nsetapx.tgtRanNodeId/nsetapx.gnb_Id_element/nsetapx.plmn_Identity
#      ${ng_ho_plmn}=   wireshark.get_field_value_by_xpath   xpath=${ng_ho_plmn_xpath}   attribute_name=showname
# 
#      ${ng_ho_gnbid_xpath}   set variable   ${data}/nsetapx.tgtRanNodeId/nsetapx.gnb_Id_element/nsetapx.gnb_Id/nsetapx.gnb_id
#      ${ng_ho_gnbid}=   wireshark.get_field_value_by_xpath   xpath=${ng_ho_gnbid_xpath}   attribute_name=showname
# 
#      ${ng_ho_cellidentity_xpath}   set variable   ${data}/nsetapx.tgtRanCellId/nsetapx.nrcgi_element/nsetapx.cellIdentity
#      ${ng_ho_cellidentity}=   wireshark.get_field_value_by_xpath   xpath=${ng_ho_cellidentity_xpath}   attribute_name=showname
# 
#      ${ng_ho_reqsendtime_xpath}   set variable   ${data}/nsetapx.hoReqSndTime_element/nsetapx.seconds
#      ${ng_ho_reqsendtime_list}=   wireshark.get_field_value_by_xpath   xpath=${ng_ho_reqsendtime_xpath}
#      ${ng_ho_reqsendtime_usec_xpath}   set variable   ${data}/nsetapx.hoReqSndTime_element/nsetapx.useconds
#      ${ng_ho_reqsendtime_usec_list}=   wireshark.get_field_value_by_xpath   xpath=${ng_ho_reqsendtime_usec_xpath}
# 
#      ${ng_ho_cmdsendtime_xpath}   set variable   ${data}/nsetapx.hoCmdSndTime_element/nsetapx.seconds
#      ${ng_ho_cmdsendtime_list}=   wireshark.get_field_value_by_xpath   xpath=${ng_ho_cmdsendtime_xpath}
#      ${ng_ho_cmdsendtime_usec_xpath}   set variable   ${data}/nsetapx.hoCmdSndTime_element/nsetapx.useconds
#      ${ng_ho_cmdsendtime_usec_list}=   wireshark.get_field_value_by_xpath   xpath=${ng_ho_cmdsendtime_usec_xpath}
# 
#      Run Keyword And Continue On Failure   Should Contain   ${ng_ho_result}[0]   success
#      Run Keyword And Continue On Failure   Should Contain   ${ng_ho_mobilityreson}[0]   radioCondition
#      Run Keyword And Continue On Failure   Should Contain   ${ng_ho_plmn}[0]   ${PEER_PLMN_IDENTITY}
#      Run Keyword And Continue On Failure   Should Contain   ${ng_ho_cellidentity}[0]   ${nrcellid_peer}
#      ${PEER_MRBTS_ID}   Convert To String   ${PEER_MRBTS_ID}
#      Run Keyword And Continue On Failure   Should Contain   ${ng_ho_gnbid}[0]   ${PEER_MRBTS_ID}
# 
#      :FOR   ${ng_ho_reqsendtime}   IN   @{ng_ho_reqsendtime_list}
#        ${ng_ho_reqsendtime}   Convert To Integer   ${ng_ho_reqsendtime}
#        Run Keyword And Continue On Failure   Should Be True   ${ng_ho_reqsendtime} != 0
#        ${handover_required_timestamp_convert}   Convert To Integer   ${handover_required_timestamp}[0]
#        Run Keyword And Continue On Failure   Should Be Equal   ${ng_ho_reqsendtime}   ${handover_required_timestamp_convert}
#     END
# 
#     :FOR   ${ng_ho_reqsendtime_usec}   IN   @{ng_ho_reqsendtime_usec_list}
#         Run Keyword And Continue On Failure   Should Be True   ${ng_ho_reqsendtime_usec} != 0
#     END
# 
#     :FOR   ${ng_ho_cmdsendtime}   IN   @{ng_ho_cmdsendtime_list}
#        ${ng_ho_reqsendtime}   Convert To Integer   ${ng_ho_cmdsendtime}
#        Run Keyword And Continue On Failure   Should Be True   ${ng_ho_cmdsendtime} != 0
#     END
# 
#     :FOR   ${ng_ho_cmdsendtime_usec}   IN   @{ng_ho_cmdsendtime_usec_list}
#         Run Keyword And Continue On Failure   Should Be True   ${ng_ho_cmdsendtime_usec} != 0
#     END
# 
# Check Real Fields for NGAPTargetHO Record
#      [Documentation]   This keyword is used to get fields for NGATargetHO Records
#      Load Pcap File with Filter any Expression
#      ...                        pcap_file=${NGAP_SA_INTER_gNB_HO_TARGET_PATH}
#      ...                        any_expression=nsetapx.ngHoTgtRecord == 0
#      ...                        filter=sctp.dstport==49148
#      ${data}   set variable   .//nsetapx.CuVendorExtensionRecordDataType/nsetapx.ngHoTgtRecord/nsetapx.data_element
#      ${ng_ho_tgt_result_xpath}   set variable   ${data}/nsetapx.result
#      ${ng_ho_tgt_result}=   wireshark.get_field_value_by_xpath   xpath=${ng_ho_tgt_result_xpath}   attribute_name=showname
# 
#      ${ng_ho_tgt_plmn_xpath}   set variable   ${data}/nsetapx.srcRanCellId/nsetapx.nrcgi_element/nsetapx.plmn_Identity
#      ${ng_ho_tgt_plmn}=   wireshark.get_field_value_by_xpath   xpath=${ng_ho_tgt_plmn_xpath}   attribute_name=showname
# 
#      ${ng_ho_tgt_cellidentity_xpath}   set variable   ${data}/nsetapx.srcRanCellId/nsetapx.nrcgi_element/nsetapx.cellIdentity
#      ${ng_ho_tgt_cellidentity}=   wireshark.get_field_value_by_xpath   xpath=${ng_ho_tgt_cellidentity_xpath}   attribute_name=showname
# 
#      ${ng_ho_rcvsendtime_xpath}   set variable   ${data}/nsetapx.hoReqRcvTime_element/nsetapx.seconds
#      ${ng_ho_rcvsendtime_list}=   wireshark.get_field_value_by_xpath   xpath=${ng_ho_rcvsendtime_xpath}
#      ${ng_ho_rcvsendtime_usec_xpath}   set variable   ${data}/nsetapx.hoReqRcvTime_element/nsetapx.useconds
#      ${ng_ho_rcvsendtime_usec_list}=   wireshark.get_field_value_by_xpath   xpath=${ng_ho_rcvsendtime_usec_xpath}
# 
#      ${ng_ho_cmdrcvtime_xpath}   set variable   ${data}/nsetapx.hoCmdCmplRcvTime_element/nsetapx.seconds
#      ${ng_ho_cmdrcvtime_list}=   wireshark.get_field_value_by_xpath   xpath=${ng_ho_cmdrcvtime_xpath}
#      ${ng_ho_cmdrcvtime_usec_xpath}   set variable   ${data}/nsetapx.hoCmdCmplRcvTime_element/nsetapx.useconds
#      ${ng_ho_cmdrcvtime_usec_list}=   wireshark.get_field_value_by_xpath   xpath=${ng_ho_cmdrcvtime_usec_xpath}
# 
#      Run Keyword And Continue On Failure   Should Contain   ${ng_ho_tgt_result}[0]   success
#      Run Keyword And Continue On Failure   Should Contain   ${ng_ho_tgt_plmn}[0]   ${PLMN_IDENTITY}
#      Run Keyword And Continue On Failure   Should Contain   ${ng_ho_tgt_cellidentity}[0]   ${nrcellid_source}
# 
#      :FOR   ${ng_ho_rcvsendtime}   IN   @{ng_ho_rcvsendtime_list}
#        ${ng_ho_reqsendtime}   Convert To Integer   ${ng_ho_rcvsendtime}
#        Run Keyword And Continue On Failure   Should Be True   ${ng_ho_rcvsendtime} != 0
#        ${NG_HO_Request_receive_time_convert}   Convert To Integer   ${NG_HO_Request_receive_time}[0]
#        Run Keyword And Continue On Failure   Should Be Equal   ${ng_ho_reqsendtime}   ${NG_HO_Request_receive_time_convert}
#     END
# 
#     :FOR   ${ng_ho_rcvsendtime_usec}   IN   @{ng_ho_rcvsendtime_usec_list}
#         Run Keyword And Continue On Failure   Should Be True   ${ng_ho_rcvsendtime_usec} != 0
#     END
# 
#     :FOR   ${ng_ho_cmdrcvtime}   IN   @{ng_ho_cmdrcvtime_list}
#        ${ng_ho_reqsendtime}   Convert To Integer   ${ng_ho_cmdrcvtime}
#        Run Keyword And Continue On Failure   Should Be True   ${ng_ho_cmdrcvtime} != 0
#     END
# 
#     :FOR   ${ng_ho_cmdrcvtime_usec}   IN   @{ng_ho_cmdrcvtime_usec_list}
#         Run Keyword And Continue On Failure   Should Be True   ${ng_ho_cmdrcvtime_usec} != 0
#     END
# 
# Get Source Fields for NGAPHO Record
#      [Documentation]   This keyword is used to get source fields of "NG HO Required send time"
#     ...   "Target eNB ID" "Target gNB ID" "NG HO Request receive time" for NGAPSourceHO Records and NGATargetHO Records
#      Load Pcap File with Filter any Expression
#      ...                        pcap_file=${NGAP_SA_INTER_gNB_HO_SOURCE_PATH}
# #     ...                        any_expression=ngap.HandoverRequired_element
#      ...                          any_expression=nsetapx.asn1_MsgId == 61
#      ...                        filter=sctp.dstport==49148
#      ${handover_required_xpath}   Catenate  SEPARATOR=
#      ...   .//nsetapx.TraceMessage/nsetapx.report_element/nsetapx.recordingSessionReportList
#      ...   /nsetapx.cuRecordingSessionReportList//nsetapx.CuRecordingSessionReport_element
#      ...   /nsetapx.recordList//nsetapx.CuRecord_element/nsetapx.data/nsetapx.asn1_Data_element
#      ...   /ngap/ngap.NGAP_PDU/ngap.initiatingMessage_element/ngap.value_element/ngap.HandoverRequired_element
#      ${handover_required}=   wireshark.get_field_value_by_xpath   xpath=${handover_required_xpath}   attribute_name=showname
# 
#      ${handover_required_timestamp_xpath}   set variable   .//nsetapx.seconds
#      ${handover_required_timestamp}=   wireshark.get_field_value_by_xpath   xpath=${handover_required_timestamp_xpath}
#      ${Target_gNB_ID_xpath}   Catenate  SEPARATOR=
#      ...   ${handover_required_xpath}/ngap.protocolIEs//ngap.ProtocolIE_Field_element
#      ...   /ngap.value_element/ngap.TargetID/ngap.targetRANNodeID_element/ngap.globalRANNodeID
#      ...   /ngap.globalGNB_ID_element/ngap.globalGNB_ID.gNB_ID/ngap.gNB_ID
#      ${Target_gNB_ID}=   wireshark.get_field_value_by_xpath   xpath=${Target_gNB_ID_xpath}   attribute_name=showname
# 
#      Load Pcap File with Filter any Expression
#      ...                        pcap_file=${NGAP_SA_INTER_gNB_HO_TARGET_PATH}
#      ...                          any_expression=nsetapx.asn1_MsgId == 64
#      ...                        filter=sctp.dstport==49148
#      ${NG_HO_Request_receive_time_xpath}   set variable   .//nsetapx.CuRecord_element/nsetapx.timestamp_element/nsetapx.seconds
#      ${NG_HO_Request_receive_time}=   wireshark.get_field_value_by_xpath   xpath=${NG_HO_Request_receive_time_xpath}
#      log to console   ${handover_required}
#      Set Suite Variable   ${handover_required_timestamp}
#      log to console   ${handover_required_timestamp}
#      log to console   ${Target_gNB_ID}
#      Set Suite Variable   ${NG_HO_Request_receive_time}
#      log to console   ${NG_HO_Request_receive_time}
# 
# Update NGAP Parameter for LOCAL
#     [Arguments]   ${NGAP}=allowed
#     Wait Until Keyword Succeeds   5m   1m   COAM Login
#     COAM Update Parameter
#     ...   dist_name=${INSID}/NRCELL-1/NRREL-1
#     ...   parameter=handoverAllowedSA
#     ...   value=${NGAP}
#     [Teardown]   Run Keyword And Ignore Error   COAM Logout
# 
# Update NGAP Parameter for PEER
#     [Arguments]   ${NGAP}=allowed
#     Wait Until Keyword Succeeds   5m   1m   COAM Login
#     ...   bts_host=${PEER_WEBUI_ADDR}
#     ...   username=${PEER_WEBUI_USER}
#     ...   password=${PEER_WEBUI_PWD}
#     ...   alias=PEER
#     COAM Update Parameter
#     ...   dist_name=${PEER_INSID}/NRCELL-1/NRREL-1
#     ...   parameter=handoverAllowedSA
#     ...   value=${NGAP}
#     ...   connection=PEER
#     [Teardown]   Run Keyword And Ignore Error   COAM Logout   connection=PEER
# 
# Update NG Based HO Parameters For Local
#      [Arguments]    ${enable_NG}=sourceAndTarget   ${NGAP}=XnHoNotAllowed
#      Wait Until Keyword Succeeds   5m   1m   COAM Login   alias=LOCAL_NG
#      ${delta_file}   Catenate  SEPARATOR=
#      ...   [{
#      ...       "distName":"${INSID}",
#      ...       "operation":"update",
#      ...       "parameters":[{
#      ...           "parameterName":"actIntraNrNgHo",
#      ...           "value":"${enable_NG}",
#      ...           "operation":"update"
#      ...       }]
#      ...   },{
#      ...       "distName":"${INSID}",
#      ...       "operation":"update",
#      ...       "parameters":[{
#      ...           "parameterName":"tNgRelocExecDeltN",
#      ...           "value":"3000",
#      ...           "operation":"update"
#      ...       }]
#      ...   },{
#      ...       "distName":"${INSID}",
#      ...       "operation":"update",
#      ...       "parameters":[{
#      ...           "parameterName":"tNgRelocCancelN",
#      ...           "value":"2000",
#      ...           "operation":"update"
#      ...       }]
#      ...   },{
#      ...       "distName":"${INSID}",
#      ...       "operation":"update",
#      ...       "parameters":[{
#      ...           "parameterName":"tNgRelocOverallN",
#      ...           "value":"2000",
#      ...           "operation":"update"
#      ...       }]
#      ...   },{
#      ...       "distName":"${INSID}",
#      ...       "operation":"update",
#      ...       "parameters":[{
#      ...           "parameterName":"tNgRelocPrepN",
#      ...           "value":"2000",
#      ...           "operation":"update"
#      ...       }]
#      ...   },{
#      ...       "distName":"${INSID}/NRCELL-1/NRREL-1",
#      ...       "operation":"update",
#      ...       "parameters":[{
#      ...           "parameterName":"handoverAllowedSA",
#      ...           "value":"${NGAP}",
#      ...           "operation":"update"
#      ...       }]
#      ...   }]
#     COAM Perform Delta Recommission   delta_file=${delta_file}   connection=LOCAL_NG
#     [Teardown]   Run Keyword And Ignore Error   COAM Logout   alias=LOCAL_NG
# 
# Update NG Based HO Parameters For Peer
#     [Arguments]   ${enable_NG}=sourceAndTarget   ${NGAP}=XnHoNotAllowed
#     Wait Until Keyword Succeeds   5m   1m   COAM Login
#     ...   bts_host=${PEER_WEBUI_ADDR}
#     ...   username=${PEER_WEBUI_USER}
#     ...   password=${PEER_WEBUI_PWD}
#     ...   alias=PEER_NG
#     ${delta_file}   Catenate  SEPARATOR=
#      ...   [{
#      ...       "distName":"${PEER_INSID}",
#      ...       "operation":"update",
#      ...       "parameters":[{
#      ...           "parameterName":"actIntraNrNgHo",
#      ...           "value":"${enable_NG}",
#      ...           "operation":"update"
#      ...       }]
#      ...   },{
#      ...       "distName":"${PEER_INSID}",
#      ...       "operation":"update",
#      ...       "parameters":[{
#      ...           "parameterName":"tNgRelocExecDeltN",
#      ...           "value":"3000",
#      ...           "operation":"update"
#      ...       }]
#      ...   },{
#      ...       "distName":"${PEER_INSID}",
#      ...       "operation":"update",
#      ...       "parameters":[{
#      ...           "parameterName":"tNgRelocCancelN",
#      ...           "value":"2000",
#      ...           "operation":"update"
#      ...       }]
#      ...   },{
#      ...       "distName":"${PEER_INSID}",
#      ...       "operation":"update",
#      ...       "parameters":[{
#      ...           "parameterName":"tNgRelocOverallN",
#      ...           "value":"2000",
#      ...           "operation":"update"
#      ...       }]
#      ...   },{
#      ...       "distName":"${PEER_INSID}",
#      ...       "operation":"update",
#      ...       "parameters":[{
#      ...           "parameterName":"tNgRelocPrepN",
#      ...           "value":"2000",
#      ...           "operation":"update"
#      ...       }]
#      ...   },{
#      ...       "distName":"${PEER_INSID}/NRCELL-1/NRREL-1",
#      ...       "operation":"update",
#      ...       "parameters":[{
#      ...           "parameterName":"handoverAllowedSA",
#      ...           "value":"${NGAP}",
#      ...           "operation":"update"
#      ...       }]
#      ...   }]
#     COAM Perform Delta Recommission   delta_file=${delta_file}   connection=PEER_NG
#     [Teardown]   Run Keyword And Ignore Error   COAM Logout   connection=PEER_NG
# 
# Recovery NG Based HO Parameters For Local
#      [Arguments]    ${enable_NG}=disabled   ${NGAP}=allowed
#      Wait Until Keyword Succeeds   5m   1m   COAM Login   alias=LOCAL_NG
#      ${delta_file}   Catenate  SEPARATOR=
#      ...   [{
#      ...       "distName":"${INSID}",
#      ...       "operation":"update",
#      ...       "parameters":[{
#      ...           "parameterName":"actIntraNrNgHo",
#      ...           "value":"${enable_NG}",
#      ...           "operation":"update"
#      ...       }]
#      ...   },{
#      ...       "distName":"${INSID}",
#      ...       "operation":"update",
#      ...       "parameters":[{
#      ...           "parameterName":"tNgRelocExecDeltN",
#      ...           "value":"3000",
#      ...           "operation":"delete"
#      ...       }]
#      ...   },{
#      ...       "distName":"${INSID}",
#      ...       "operation":"update",
#      ...       "parameters":[{
#      ...           "parameterName":"tNgRelocCancelN",
#      ...           "value":"2000",
#      ...           "operation":"delete"
#      ...       }]
#      ...   },{
#      ...       "distName":"${INSID}",
#      ...       "operation":"update",
#      ...       "parameters":[{
#      ...           "parameterName":"tNgRelocOverallN",
#      ...           "value":"2000",
#      ...           "operation":"delete"
#      ...       }]
#      ...   },{
#      ...       "distName":"${INSID}",
#      ...       "operation":"update",
#      ...       "parameters":[{
#      ...           "parameterName":"tNgRelocPrepN",
#      ...           "value":"2000",
#      ...           "operation":"delete"
#      ...       }]
#      ...   },{
#      ...       "distName":"${INSID}/NRCELL-1/NRREL-1",
#      ...       "operation":"update",
#      ...       "parameters":[{
#      ...           "parameterName":"handoverAllowedSA",
#      ...           "value":"${NGAP}",
#      ...           "operation":"update"
#      ...       }]
#      ...   }]
#     COAM Perform Delta Recommission   delta_file=${delta_file}   connection=LOCAL_NG
#     [Teardown]   Run Keyword And Ignore Error   COAM Logout   alias=LOCAL_NG
# 
# Recovery NG Based HO Parameters For Peer
#     [Arguments]   ${enable_NG}=disabled   ${NGAP}=allowed
#     Wait Until Keyword Succeeds   5m   1m   COAM Login
#     ...   bts_host=${PEER_WEBUI_ADDR}
#     ...   username=${PEER_WEBUI_USER}
#     ...   password=${PEER_WEBUI_PWD}
#     ...   alias=PEER_NG
#     ${delta_file}   Catenate  SEPARATOR=
#      ...   [{
#      ...       "distName":"${PEER_INSID}",
#      ...       "operation":"update",
#      ...       "parameters":[{
#      ...           "parameterName":"actIntraNrNgHo",
#      ...           "value":"${enable_NG}",
#      ...           "operation":"update"
#      ...       }]
#      ...   },{
#      ...       "distName":"${PEER_INSID}",
#      ...       "operation":"update",
#      ...       "parameters":[{
#      ...           "parameterName":"tNgRelocExecDeltN",
#      ...           "value":"3000",
#      ...           "operation":"delete"
#      ...       }]
#      ...   },{
#      ...       "distName":"${PEER_INSID}",
#      ...       "operation":"update",
#      ...       "parameters":[{
#      ...           "parameterName":"tNgRelocCancelN",
#      ...           "value":"2000",
#      ...           "operation":"delete"
#      ...       }]
#      ...   },{
#      ...       "distName":"${PEER_INSID}",
#      ...       "operation":"update",
#      ...       "parameters":[{
#      ...           "parameterName":"tNgRelocOverallN",
#      ...           "value":"2000",
#      ...           "operation":"delete"
#      ...       }]
#      ...   },{
#      ...       "distName":"${PEER_INSID}",
#      ...       "operation":"update",
#      ...       "parameters":[{
#      ...           "parameterName":"tNgRelocPrepN",
#      ...           "value":"2000",
#      ...           "operation":"delete"
#      ...       }]
#      ...   },{
#      ...       "distName":"${PEER_INSID}/NRCELL-1/NRREL-1",
#      ...       "operation":"update",
#      ...       "parameters":[{
#      ...           "parameterName":"handoverAllowedSA",
#      ...           "value":"${NGAP}",
#      ...           "operation":"update"
#      ...       }]
#      ...   }]
#     COAM Perform Delta Recommission   delta_file=${delta_file}   connection=PEER_NG
#     [Teardown]   Run Keyword And Ignore Error   COAM Logout   connection=PEER_NG