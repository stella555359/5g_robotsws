# *** Settings ***
# Documentation
# ...   Author: di.yang@nokia-sbell.com
# Force Tags                 5G_RAN    5G_RAN_TDD    CRT_TRUNK
# 
# Resource   ./Resource/Common.robot
# 
# 
# 
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# 
# Suite Setup    Run Keywords
# ...         robot_common_operations.Common Suite Setup
# ...       AND       CI_interface.Common Suite Setup
# ...       AND       COAM Update SERVEDAMF administrativeState        Locked
# ...       AND       COAM Update absThreshSsbRsrpConsolidation
# 
# Suite Teardown  Run Keywords     COAM Update SERVEDAMF administrativeState
# ...    AND     robot_common_operations.Common Suite Teardown
# Test Setup       robot_common_operations.Common Case Setup
# Test Teardown     Run Keywords    Case Teardown: CB008196-B
# ...       AND     robot_common_operations.Common Case Teardown
# 
# 
# 
# *** Variables ***
# ${NSA_SgNB_Addition_FILE}   NSA_SgNB_Addition.pcap
# ${NSA_SgNB_Addition_PATH}   ${OUTPUT_DIR}/${NSA_SgNB_Addition_FILE}
# ${NSA_ue_index}   0
# ${NSA_ue_1}   1
# ${packet_filter}     ((nr-rrc.measId)&&(x2ap.procedureCode == 35))&&(tcp.dstport == 49148)   #CellTrace
# ${NSA_1UE_Infinity_FILE}   NSA_1UE_Infinity.pcap
# ${NSA_1UE_Infinity_PATH}   ${OUTPUT_DIR}/${NSA_1UE_Infinity_FILE}
# ${NSA_1UE_R8_FILE}   NSA_1UE_R8.pcap
# ${NSA_1UE_R8_PATH}   ${OUTPUT_DIR}/${NSA_1UE_R8_FILE}
# ${NSA_1UE_R8_UE2_FILE}   NSA_1UE_R8_UE2.pcap
# ${NSA_1UE_R8_UE2_PATH}   ${OUTPUT_DIR}/${NSA_1UE_R8_UE2_FILE}
# ${NSA_002_FILE}   NSA_002.pcap
# ${NSA_002_PATH}   ${OUTPUT_DIR}/${NSA_002_FILE}
# 
# *** Test Cases ***
# CB008196_B_001_Periodic_UE_Measurements_Cell_PCMD_Trace_SgNB_Addition
#     [Documentation]   Author: di.yang@nokia-sbell.com
#     [Tags]  001
#     Case Setup: CB008196-B_001
#     CB008196-B_001_Periodic_UE_Measurements_Cell_PCMD_Trace_SgNB_Addition
# 
# CB008196_B_002_Periodic_UE_Measurements_Cell_PCMD_Trace_SgNB_Release-MeNB_Initiated_Normal_Release
#     [Tags]  002
#     Common Setup 8196
# 
#     ${result}    ${release}    Run Keyword And Ignore Error
#     ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
#     ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
#     Run keyword If  '${release_sbts}'=='SBTS23R1'
#     ...    Remove And Add NRCTRLTS Object   add_object=${add_nrctrlts_002}
#     ...    ELSE    Remove And Add NRCTRLTS Object   add_object=${add_nrctrlts_002_23R2}
# 
#     #Remove And Add NRCTRLTS Object   add_object=${add_nrctrlts_002}
#     Attach 2UE And Get TCPDUMP File   ${NSA_002_FILE}   detach=${True}
#     Check 5G UE Connection establishment   ${NSA_002_PATH}
#     Check CellTrace And PCMD    tcp_file=${NSA_002_PATH}    trace_no=2
# 
# CB008196_B_006_Deactivation_of_Periodic_UE_Measurements_via_feature_flag_actCellTraceReport
#     [Tags]  006
#     Common Setup 8196
#     ${result}    ${release}    Run Keyword And Ignore Error
#     ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
#     ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
#     Run keyword If  '${release_sbts}'=='SBTS23R1' 
#     ...    Remove And Add NRCTRLTS Object   add_object=${add_nrctrlts_006}
#     ...    ELSE    Remove And Add NRCTRLTS Object   add_object=${add_nrctrlts_006_23R2}
# 
#     #Remove And Add NRCTRLTS Object   add_object=${add_nrctrlts_006}
#     Run Keyword And Ignore Error   Make L3CALL And Start PCMD TCPDUMP   ue_index=${NSA_ue_index}
#     COAM Update Celltrace Flag   false
#     Get ALL PCMD TCPDUMP File After Call And Traffic
#     Detach UE BETA   ue_index=${NSA_ue_index}
#     Check CellTrace And PCMD    ${TCPDUMP_PATH}
#     Run Keyword And Ignore Error   Make L3CALL And Start PCMD TCPDUMP   ue_index=${NSA_ue_index}
#     Get ALL PCMD TCPDUMP File After Call And Traffic
#     ${status}=    Run keyword and return status     Check CellTrace And PCMD    ${TCPDUMP_PATH}
#     Run keyword if   ${dict_No} != ${0}   Fail   0 trace expected but got ${dict_No}
#     Run keyword if   '${status}' == 'True'   Fail   Deactivation check of Periodic UE Measurements failing
# 
# CB008196_B_007_Deactivation_of_Periodic_UE_Measurements_via_feature_flag_actPCMDReport
#     [Tags]  007
#     Common Setup 8196
#     ${result}    ${release}    Run Keyword And Ignore Error
#     ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
#     ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
#     Run keyword If  '${release_sbts}'=='SBTS23R1'
#     ...    Remove And Add NRCTRLTS Object   add_object=${add_nrctrlts_007} 
#     ...    ELSE    Remove And Add NRCTRLTS Object   add_object=${add_nrctrlts_007_23R2}
# 
#     #Remove And Add NRCTRLTS Object   add_object=${add_nrctrlts_007}
#     Run Keyword And Ignore Error   Make L3CALL And Start PCMD TCPDUMP   ue_index=${NSA_ue_index}
#     COAM Update PCMD Flag   false
#     Get ALL PCMD TCPDUMP File After Call And Traffic
#     Detach UE BETA   ue_index=${NSA_ue_index}
#     Check CellTrace And PCMD    ${TCPDUMP_PATH}
#     Run Keyword And Ignore Error   Make L3CALL And Start PCMD TCPDUMP   ue_index=${NSA_ue_index}
#     Get ALL PCMD TCPDUMP File After Call And Traffic
#     ${status}=    Run keyword and return status     Check CellTrace And PCMD    ${TCPDUMP_PATH}
#     Run keyword if   ${dict_No} != ${0}   Fail   0 trace expected but got ${dict_No}
#     Run keyword if   '${status}' == 'True'   Fail   Deactivation check of Periodic UE Measurements failing
# 
# *** Keyword ***
# CB008196-B_001_Periodic_UE_Measurements_Cell_PCMD_Trace_SgNB_Addition
#     Check 5G UE Connection establishment
#     Check CellTrace And PCMD    ${NSA_SgNB_Addition_PATH}
# 
#     ${result}    ${release}    Run Keyword And Ignore Error
#     ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
#     ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
#     Run keyword If  '${release_sbts}'=='SBTS23R1' 
#     ...    Remove And Add NRCTRLTS Object   add_object=${add_nrctrlts_1ue} 
#     ...    ELSE    Remove And Add NRCTRLTS Object   add_object=${add_nrctrlts_1ue_23R2}
# 
#     #Remove And Add NRCTRLTS Object   add_object=${add_nrctrlts_1ue}
#     Attach 2UE And Get TCPDUMP File   ${NSA_1UE_Infinity_FILE}
#     Detach UE BETA   ue_index=${NSA_ue_index}
#     Detach UE BETA   ue_index=${NSA_ue_1}
#     Check CellTrace And PCMD    tcp_file=${NSA_1UE_Infinity_PATH}
# 
#     ${result}    ${release}    Run Keyword And Ignore Error
#     ...    Wait Until Keyword Succeeds    1 min    2 sec    gnb_classical_hangzhou.Get sw build version
#     ${release_sbts}    Replace String    string=${release}    search_for=5G    replace_with=SBTS
#     Run keyword If  '${release_sbts}'=='SBTS23R1'
#     ...    Remove And Add NRCTRLTS Object   add_object=${add_nrctrlts_1ue_r8} 
#     ...    ELSE    Remove And Add NRCTRLTS Object    add_object=${add_nrctrlts_1ue_r8_23R2}
# 
#     #Remove And Add NRCTRLTS Object   add_object=${add_nrctrlts_1ue_r8}
#     Attach 2UE And Get TCPDUMP File   ${NSA_1UE_R8_FILE}
#     Detach UE BETA   ue_index=${NSA_ue_1}
#     Check CellTrace And PCMD    tcp_file=${NSA_1UE_R8_PATH}   reportAmount=no_check
# 
#     ${1_time}=  Get Current Date
#     ${time_diff}=  Subtract Date From Date  ${ue_2_time}  ${1_time}
#     Sleep    ${time_diff}    reason=Wait for UE1 report end
#     Run Keyword And Ignore Error   Attach Detach And Get ALL PCMD TCPDUMP File   ${NSA_ue_1}   ${NSA_1UE_R8_UE2_FILE}
#     Detach UE BETA   ue_index=${NSA_ue_index}
#     Check CellTrace And PCMD    tcp_file=${NSA_1UE_R8_UE2_PATH}   reportAmount=no_check
# 
# 
# Attach Detach And Get ALL PCMD TCPDUMP File
#     [Arguments]   ${ue_index}=${ue_index}    ${tcptump_file}=${NSA_SgNB_Addition_FILE}
#     L3CALL Precondition   ${ue_index}
#     Start Tcpdump To Get PCMD   pcmd_file=${tcptump_file}
#     Run Keyword And Ignore Error   Attach UE and Detach   ue_index=${ue_index}
#     [Teardown]   Stop Tcpdump To Get PCMD   pcmd_file=${tcptump_file}
# 
# Case Setup: CB008196-B_001
#     Log To Console   Case Setup: CB008196-B_001
#     Common Setup 8196
#     Remove And Add PCMD Object
#     Run Keyword And Ignore Error   COAM Logout
#     Run Keyword And Ignore Error   Initialize PA
#     Run Keyword And Ignore Error   Attach Detach And Get ALL PCMD TCPDUMP File   ${NSA_ue_index}
#     Run Keyword And Ignore Error   COAM Logout
#     [Teardown]  Run Keyword And Ignore Error   COAM Logout
# 
# Case Teardown: CB008196-B
#     Log To Console   Case Teardown: CB008196-B
#     Run Keyword And Ignore Error   Detach UE BETA   ue_index=${NSA_ue_index}
#     Run Keyword And Ignore Error   Detach UE BETA   ue_index=${NSA_ue_1}
#     Wait Until Keyword Succeeds   5m   1m   COAM Login
#     COAM Update actInactDetNSAUe
#     Run Keyword And Ignore Error   COAM Logout
# 
# Check 5G UE Connection establishment
#     [Arguments]    ${pcap_file}=${NSA_SgNB_Addition_PATH}
#     log to console   check 5G UE Connection establishment triggered by X2 sgNB Addtion Request. UE selected for trace.
#     &{eNB_info}   Get eNB Variables
#     Load Pcap File with Filter any Expression
#     ...                        pcap_file=${pcap_file}
#     ...                        any_expression=x2ap.procedureCode == 27&&ip.dst == &{eNB_info}[ip]
#     ...                        filter=sctp.dstport==36422
#     ${x2ap_menbUeX2APId}=   wireshark.get_field_value_by_xpath   xpath=.//x2ap.UE_X2AP_ID
#     ${x2ap_sgnbUeX2APId}=   wireshark.get_field_value_by_xpath   xpath=.//x2ap.SgNB_UE_X2AP_ID
#     ${x2ap_menbUeX2APId_singal}   Remove Duplicates   ${x2ap_menbUeX2APId}
#     ${x2ap_addition_times}=  Get Length   ${x2ap_menbUeX2APId_singal}
# 
#     Load Pcap File with Filter any Expression
#     ...                        pcap_file=${pcap_file}
#     ...                        any_expression=nsetapx.CuVendorExtensionRecordDataType == 1
#     ...                        filter=sctp.dstport==${dcap_server_port}
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
#         Should Match Regexp   ${result_list[${idx}]}   .*success.*
#         Should Match Regexp   ${enbid_list[${idx}]}   .*enb-Id.*
#         ${globaleNBId_info}   Should Match Regexp   ${enbmacroId[${idx}]}   value.*
#         ${globaleNBId}   Should Match Regexp   ${globaleNBId_info}   \\d+
#         should be equal   &{eNB_info}[globaleNBId]   ${${globaleNBId}}
#         ${plman_clear}   Remove String   @{enbplmn_list}[${idx}]   :
#         Should Be True   '${plman_clear}' == '${PLMN_IDENTITY}'
#         should not be empty   ${ReqRcvTimeS[${idx}]}
#         should not be empty   ${ReqRcvTimeUS[${idx}]}
#     END
#     should not be empty   ${ReqAckSndTimeS}
#     should not be empty   ${ReqAckSndTimeUS}
#     should not be empty   ${ReconfCmplRcvS}
#     should not be empty   ${ReconfCmplRcvUS}
#     should not be empty   ${snStatusTransferRcvS}
#     should not be empty   ${snStatusTransferRcvUS}
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
# 
