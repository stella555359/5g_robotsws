# *** Settings ***
# Documentation
# ...   Author: shengyuan.jiang@nokia-sbell.com
# 
# Resource   ./Resource/Common.robot
# 
# *** Variables ***
# ${NSA_Addition_Reject_FILE}   NSA_Addition_Reject.pcap
# ${NSA_Addition_Reject_PATH}   ${OUTPUT_DIR}/${NSA_Addition_Reject_FILE}
# ${NSA_ue_index}   1
# 
# *** Test Cases ***
# 5GC001097_CB_02_PCMD_Record_classical_NSA_SgNBAdditionTraceRecord_abnormal_call_scenario_addition_request_reject
#     [Documentation]   Author: liping.hong@nokia-sbell.com
#     [Setup]   Case Setup: 5GC001097_CB_02
#     5GC001097_CB_02_PCMD_Record_classical_NSA_SgNBAdditionTraceRecord_abnormal_call_scenario_addition_request_reject
#     [Teardown]   Case Teardown: 5GC001097_CB_02
# 
# *** Keyword ***
# 5GC001097_CB_02_PCMD_Record_classical_NSA_SgNBAdditionTraceRecord_abnormal_call_scenario_addition_request_reject
#     log to console   check NSA_SgNBAdditionTraceRecord_abnormal_call_scenario_addition_request_reject
#     &{eNB_info}   Get eNB Variables
#      Load Pcap File with Filter any Expression
#      ...                        pcap_file=${NSA_Addition_Reject_PATH}
#      ...                          any_expression=x2ap.procedureCode == 27&&ip.dst == &{eNB_info}[ip]
#      ...                        filter=sctp.dstport==36422
#     ${x2ap_menbUeX2APId}=   wireshark.get_field_value_by_xpath   xpath=.//x2ap.UE_X2AP_ID
#     ${x2ap_sgnbUeX2APId}=   wireshark.get_field_value_by_xpath   xpath=.//x2ap.SgNB_UE_X2AP_ID
#     ${x2ap_menbUeX2APId_singal}   Remove Duplicates   ${x2ap_menbUeX2APId}
#     ${x2ap_addition_times}=  Get Length   ${x2ap_menbUeX2APId_singal}
# 
#      Load Pcap File with Filter any Expression
#      ...                        pcap_file=${NSA_Addition_Reject_PATH}
#      ...                          any_expression=nsetapx.CuVendorExtensionRecordDataType == 1
#      ...                        filter=sctp.dstport==${dcap_server_port}
#     ${xpath_gnbadditionR}   set variable   .//nsetapx.sgnbAdditionRecord/nsetapx.data_r1_element
#     ${trigger_list}=   wireshark.get_field_value_by_xpath   xpath=.//nsetapx.triggerReason   attribute_name=showname
#     ${result_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_gnbadditionR}/nsetapx.result   attribute_name=showname
#     ${enbid_list}=    wireshark.get_field_value_by_xpath   xpath=.//nsetapx.enb_Id_element   attribute_name=showname
#     ${enbplmn_list}=    wireshark.get_field_value_by_xpath   xpath=.//nsetapx.enb_Id_element/nsetapx.plmn_Identity
#     ${enbmacro_list}=    wireshark.get_field_value_by_xpath   xpath=.//nsetapx.enb_Id   attribute_name=showname
#     ${enbmacroId}=    wireshark.get_field_value_by_xpath   xpath=.//nsetapx.macro_eNB_Id   attribute_name=showname
#     ${menbUeX2APId}=   wireshark.get_field_value_by_xpath   xpath=.//nsetapx.menb_ue_x2ap_Id
#     ${sgnbUeX2APId}=   wireshark.get_field_value_by_xpath   xpath=.//nsetapx.sgnb_ue_x2ap_Id
#     ${ReqRcvTimeS}=    wireshark.get_field_value_by_xpath   xpath=.//nsetapx.sgnbAdditionReqRcvTime_element/nsetapx.seconds
#     ${ReqRcvTimeUS}=    wireshark.get_field_value_by_xpath   xpath=.//nsetapx.sgnbAdditionReqRcvTime_element/nsetapx.useconds
#     ${ReqAckSndTimeS}=    wireshark.get_field_value_by_xpath   xpath=.//nsetapx.sgnbAdditionReqAckSndTime_element/nsetapx.seconds
#     ${ReqAckSndTimeUS}=    wireshark.get_field_value_by_xpath   xpath=.//nsetapx.sgnbAdditionReqAckSndTime_element/nsetapx.useconds
#     ${ReconfCmplRcvS}=    wireshark.get_field_value_by_xpath   xpath=.//nsetapx.sgnbReconfCmplRcvTime_element/nsetapx.seconds
#     ${ReconfCmplRcvUS}=    wireshark.get_field_value_by_xpath   xpath=.//nsetapx.sgnbReconfCmplRcvTime_element/nsetapx.useconds
#     ${snStatusTransferRcvS}=    wireshark.get_field_value_by_xpath   xpath=.//nsetapx.snStatusTransferRcvTime_element/nsetapx.seconds
#     ${snStatusTransferRcvUS}=    wireshark.get_field_value_by_xpath   xpath=.//nsetapx.snStatusTransferRcvTime_element/nsetapx.useconds
# 
#     Should Be True   ${x2ap_addition_times}>0
#     : FOR   ${idx}    IN RANGE    0   ${x2ap_addition_times}
#         Should Match Regexp   ${trigger_list[${idx}]}   .*initialNsaCall.*
#         Should Match Regexp   ${result_list[${idx}]}   .*cacFailure.*
#         Should Match Regexp   ${enbid_list[${idx}]}   .*enb-Id.*
#         ${globaleNBId_info}   Should Match Regexp   ${enbmacroId[${idx}]}   value.*
#         ${globaleNBId}   Should Match Regexp   ${globaleNBId_info}   \\d+
#         should be equal   &{eNB_info}[globaleNBId]   ${${globaleNBId}}
#         ${plman_clear}   Remove String   @{enbplmn_list}[${idx}]   :
#         Should Be True   '${plman_clear}' == '${PLMN_IDENTITY}'
#         should not be empty   ${ReqRcvTimeS[${idx}]}
#         should not be empty   ${ReqRcvTimeUS[${idx}]}
#     END
#     should be empty   ${ReqAckSndTimeS}
#     should be empty   ${ReqAckSndTimeUS}
#     should be empty   ${ReconfCmplRcvS}
#     should be empty   ${ReconfCmplRcvUS}
#     should be empty   ${snStatusTransferRcvS}
#     should be empty   ${snStatusTransferRcvUS}
#     Should Be True   ${menbUeX2APId} == ${x2ap_menbUeX2APId}
#     Should Be True   ${sgnbUeX2APId} == ${x2ap_sgnbUeX2APId}
# 
#     ${seconds_list}   wireshark.get_field_value_by_xpath   xpath=.//nsetapx.seconds
#     ${useconds_list}   wireshark.get_field_value_by_xpath   xpath=.//nsetapx.useconds
#     ${curr_date}   Get Current Date   result_format=epoch
#     ${curr_date}   Convert To Integer   ${curr_date}
# 
#     :FOR   ${seconds}   IN   @{seconds_list}
#        ${seconds}   Convert To Integer   ${seconds}
#        Should Be True   ${curr_date} - ${seconds} > 0
#        Should Be True   ${curr_date} - ${seconds} < ${86400}
#     END
# 
#     :FOR   ${useconds}   IN   @{useconds_list}
#         ${useconds}   Convert To Integer   ${useconds}
#         Should Be True   ${useconds} < ${1000000}
#     END
# #
# 
# Attach Detach And Get ALL PCMD TCPDUMP File
#     [Arguments]   ${ue_index}=${ue_index}    ${tcptump_file}=${NSA_Addition_Reject_FILE}
#     L3CALL Precondition   ${ue_index}
#     Start Tcpdump To Get PCMD   pcmd_file=${tcptump_file}
#     Wait Until Keyword Succeeds   3x   10s   Attach UE and Detach   ue_index=${ue_index}
#     [Teardown]   Stop Tcpdump To Get PCMD   pcmd_file=${tcptump_file}
# 
# COAM Update MaxnumofUsersPerCell Value
#     [Arguments]   ${maxnumofUsersPerCell_expect_value}=275
#     COAM Update Parameter   dist_name=${INSID}/NRCELL-1   parameter=maxNumOfUsersPerCell   value=${maxnumofUsersPerCell_expect_value}
# 
# 
# Case Setup: 5GC001097_CB_02
#     Log To Console   Case Setup: 5GC001097_CB_02
#     robot_common_operations.Common Case Setup    allowed_faults_ids=8000
#     Run Keyword And Ignore Error   Check Extra Reset From Blackbox
#     Common Setup 1756
#     Get HO Suite Variables
#     Remove And Add PCMD Object
#     Run Keyword And Ignore Error   COAM Logout
#     Wait Until Keyword Succeeds   5m   1m   COAM Login
#     Run Keyword And Ignore Error   COAM Update MaxnumofUsersPerCell Value   0
#     Run Keyword And Ignore Error   COAM Logout
#     Run Keyword And Ignore Error   Initialize PA
#     Run Keyword And Ignore Error   Attach Detach And Get ALL PCMD TCPDUMP File   ${NSA_ue_index}
#     Run Keyword And Ignore Error   COAM Logout
#     [Teardown]  Run Keyword And Ignore Error   COAM Logout
# 
# Case Teardown: 5GC001097_CB_02
#     robot_common_operations.Common Case Teardown
#     Log To Console   Case Teardown: 5GC001097_CB_02
#     Wait Until Keyword Succeeds   5m   1m   COAM Login
#     COAM Update MaxnumofUsersPerCell Value
#     Run Keyword And Ignore Error   COAM Logout
#     Check Extra Reset From Blackbox
# 
# Common Suite Setup
#     robot_common_operations.Common Suite Setup
# 
# Common Suite Teardown
#     robot_common_operations.Common Suite Teardown