*** Settings ***
Documentation
...    author: lihong
...    this case will verify keyword for TA of CB009881-CB009225_A_03

#Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009225_cloud/Common_resource/common_keyword.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Cloud/CB009225_cloud/Common_resource/common_keyword.robot

*** Variables ***


*** Keywords ***
CB009881-CB009225_A_03_e2e_B02_Successful_SA_intra_gNB_inter_DU_handover_A3_trigger_cloud

    log to console     check elemnet  DU_gNB-HO-SRC_and_DU_gNB-HO-TGT_reporting

     Load Pcap File with Filter any Expression
     ...                        pcap_file=${OUTPUT_DIR}/${SA_InterDU_HO_VCU_OAMAGENT_file}
     ...                        any_expression=nsetapx.CuVendorExtensionRecordDataType == 16
     ...                        filter=sctp.dstport==49148

    ${srcrecord_result_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.intragNBHoSrcRecord/nsetapx.data_element/nsetapx.result
    ${srcrecord_mobilityreason_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.intragNBHoSrcRecord/nsetapx.data_element/nsetapx.mobilityReason
    ${srcrecord_plmn_list}=     wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.intragNBHoSrcRecord/nsetapx.data_element/nsetapx.tgtCellId_element/nsetapx.plmn_Identity
    ${srcrecord_CellId_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.intragNBHoSrcRecord/nsetapx.data_element/nsetapx.tgtCellId_element/nsetapx.cellIdentity
    ...   attribute_name=showname

    ${srcrecord_hoDecisionTime_list_second}=     wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.intragNBHoSrcRecord/nsetapx.data_element/nsetapx.hoDecisionTime_element/nsetapx.seconds

    ${srcrecord_hoCmdSndTime_list_second}=     wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.intragNBHoSrcRecord/nsetapx.data_element/nsetapx.hoCmdSndTime_element/nsetapx.seconds
    ${srcrecord_recondsend_CellId_list}=     wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.report_element/nsetapx.cellId/nsetapx.nrcgi_element/nsetapx.cellIdentity
    ...   attribute_name=showname
    ${srcrecord_recondsend_time_list}=     wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.timestamp_element/nsetapx.seconds
    ${srcrecord_recondsend_CellId_length}=   Get Length   ${srcrecord_recondsend_CellId_list}
     Load Pcap File with Filter any Expression
     ...                        pcap_file=${OUTPUT_DIR}/${SA_InterDU_HO_VCU_OAMAGENT_file}
     ...                        any_expression=nsetapx.CuVendorExtensionRecordDataType == 17
     ...                        filter=sctp.dstport==49148

    ${tgtrecord_result_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.intragNBHoTgtRecord/nsetapx.data_element/nsetapx.result

    ${tgtrecord_plmn_list}=     wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.intragNBHoTgtRecord/nsetapx.data_element/nsetapx.srcCellId_element/nsetapx.plmn_Identity
    ${tgtrecord_CellId_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.intragNBHoTgtRecord/nsetapx.data_element/nsetapx.srcCellId_element/nsetapx.cellIdentity
    ...   attribute_name=showname
    ${tgtrecord_hoCmdCmplRcvTime_list_second}=     wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.intragNBHoTgtRecord/nsetapx.data_element/nsetapx.hoCmdCmplRcvTime_element/nsetapx.seconds
    ${tgtrecord_recondsend_CellId_list}=     wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.TraceMessage/nsetapx.report_element/nsetapx.cellId/nsetapx.nrcgi_element/nsetapx.cellIdentity
    ...   attribute_name=showname
    ${tgtrecord_recondsend_time_list}=     wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.timestamp_element/nsetapx.seconds

    Should Be True   ${srcrecord_plmn_list} == ${tgtrecord_plmn_list}
    ${plman_clear}   Remove String   ${srcrecord_plmn_list}[0]   :
    Should Be True   '${plman_clear}' == '${LOCAL_PLMN_IDENTITY}'

    should contain   ${srcrecord_CellId_list}[0]   ${LOCAL_NRCELLID_2NDCELL}
    should contain   ${tgtrecord_CellId_list}[0]   ${LOCAL_NRCELLID}
    List Should Contain Sub List   ${tgtrecord_recondsend_CellId_list}   ${srcrecord_CellId_list}
    List Should Contain Sub List   ${srcrecord_recondsend_CellId_list}   ${tgtrecord_CellId_list}

    Should Be True   ${srcrecord_result_list}[0] == ${tgtrecord_result_list}[0] == 0
    Should Be True   ${srcrecord_mobilityreason_list}[0] == 1
    Should Be True   ${srcrecord_hoDecisionTime_list_second} == ${srcrecord_hoCmdSndTime_list_second}

    List Should Contain Sub List   ${srcrecord_recondsend_time_list}   ${srcrecord_hoDecisionTime_list_second}
    List Should Contain Sub List   ${tgtrecord_recondsend_time_list}  ${tgtrecord_hoCmdCmplRcvTime_list_second}

Case Setup: CB009881-CB009225_A_03
    Log To Console   Case Setup: CB009881-CB009225_A_03
#    Common Setup 1756
#    Remove And Add PCMD Object
#
#    Start Tcpdump To Get PCMD   pcmd_file=EA_21.pcap
#    L3CALL Precondition
#    Wait Until Keyword Succeeds   3x   10s   Attach UE BETA
#
#    Sleep   30s
#    Stop Tcpdump To Get PCMD   pcmd_file=EA_21.pcap
#    Detach UE BETA

Case Teardown: CB009881-CB009225_A_03
    Log To Console   Case Teardown: CB009881-CB009225_A_03
#    Detach UE BETA
#    Common Teardown 1756
