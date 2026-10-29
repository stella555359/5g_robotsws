*** Settings ***
Documentation
...   Author: shengyuan.jiang@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
5GC001097_CB_01_PCMD_Record_classical_NSA_SgNBAdditionTraceRecord_normal_call_scenario
    log to console   check NSA_SgNBAdditionTraceRecord_normal_call_scenario
    &{eNB_info}   Get eNB Variables

     Load Pcap File with Filter any Expression
     ...                        pcap_file=${NSA_Normal_Call_PATH}
     ...                          any_expression=x2ap.procedureCode == 27&&ip.dst == ${eNB_info}[ip]
     ...                        filter=sctp.dstport==36422
    ${x2ap_menbUeX2APId}=   wireshark.get_field_value_by_xpath   xpath=.//x2ap.UE_X2AP_ID
    ${x2ap_sgnbUeX2APId}=   wireshark.get_field_value_by_xpath   xpath=.//x2ap.SgNB_UE_X2AP_ID

     Load Pcap File with Filter any Expression
     ...                        pcap_file=${NSA_Normal_Call_PATH}
     ...                          any_expression=nsetapx.CuVendorExtensionRecordDataType == 1
     ...                        filter=sctp.dstport==${dcap_server_port}
    ${xpath_gnbadditionR}   set variable   .//nsetapx.sgnbAdditionRecord/nsetapx.data_r1_element
    ${trigger_list}=   wireshark.get_field_value_by_xpath   xpath=.//nsetapx.triggerReason   attribute_name=showname
    ${result_list}=    wireshark.get_field_value_by_xpath   xpath=${xpath_gnbadditionR}/nsetapx.result   attribute_name=showname
    ${enbid_list}=    wireshark.get_field_value_by_xpath   xpath=.//nsetapx.enb_Id_element   attribute_name=showname
    ${enbplmn_list}=    wireshark.get_field_value_by_xpath   xpath=.//nsetapx.enb_Id_element/nsetapx.plmn_Identity
    ${enbmacro_list}=    wireshark.get_field_value_by_xpath   xpath=.//nsetapx.enb_Id   attribute_name=showname
    ${enbmacroId}=    wireshark.get_field_value_by_xpath   xpath=.//nsetapx.macro_eNB_Id   attribute_name=showname
    ${menbUeX2APId}=   wireshark.get_field_value_by_xpath   xpath=.//nsetapx.menb_ue_x2ap_Id
    ${sgnbUeX2APId}=   wireshark.get_field_value_by_xpath   xpath=.//nsetapx.sgnb_ue_x2ap_Id
    ${ReqRcvTimeS}=    wireshark.get_field_value_by_xpath   xpath=.//nsetapx.sgnbAdditionReqRcvTime_element/nsetapx.seconds
    ${ReqRcvTimeUS}=    wireshark.get_field_value_by_xpath   xpath=.//nsetapx.sgnbAdditionReqRcvTime_element/nsetapx.useconds
    ${ReqAckSndTimeS}=    wireshark.get_field_value_by_xpath   xpath=.//nsetapx.sgnbAdditionReqAckSndTime_element/nsetapx.seconds
    ${ReqAckSndTimeUS}=    wireshark.get_field_value_by_xpath   xpath=.//nsetapx.sgnbAdditionReqAckSndTime_element/nsetapx.useconds
    ${ReconfCmplRcvS}=    wireshark.get_field_value_by_xpath   xpath=.//nsetapx.sgnbReconfCmplRcvTime_element/nsetapx.seconds
    ${ReconfCmplRcvUS}=    wireshark.get_field_value_by_xpath   xpath=.//nsetapx.sgnbReconfCmplRcvTime_element/nsetapx.useconds
    ${snStatusTransferRcvS}=    wireshark.get_field_value_by_xpath   xpath=.//nsetapx.snStatusTransferRcvTime_element/nsetapx.seconds
    ${snStatusTransferRcvUS}=    wireshark.get_field_value_by_xpath   xpath=.//nsetapx.snStatusTransferRcvTime_element/nsetapx.useconds
    ${crnti_list}=    wireshark.get_field_value_by_xpath   xpath=.//nsetapx.crnti
    ${crnti_list}   Remove Duplicates   ${crnti_list}
    ${crnti_length}=  Get Length   ${crnti_list}
    Should Be True   ${crnti_length}>0
    FOR   ${idx}    IN RANGE    0   ${crnti_length}
        Should Match Regexp   ${trigger_list[${idx}]}   .*initialNsaCall.*
        Should Match Regexp   ${result_list[${idx}]}   .*success.*
        Should Match Regexp   ${enbid_list[${idx}]}   .*enb-Id.*
        ${globaleNBId_info}   Should Match Regexp   ${enbmacroId[${idx}]}   value.*
        ${globaleNBId}   Should Match Regexp   ${globaleNBId_info}   \\d+
        should be equal   ${eNB_info}[globaleNBId]   ${${globaleNBId}}
        ${plman_clear}   Remove String   ${enbplmn_list}[${idx}]   :
        Should Be True   '${plman_clear}' == '${PLMN_IDENTITY}'
        should not be empty   ${ReqRcvTimeS[${idx}]}
        should not be empty   ${ReqRcvTimeUS[${idx}]}
        should not be empty   ${ReqAckSndTimeS[${idx}]}
        should not be empty   ${ReqAckSndTimeUS[${idx}]}
        should not be empty   ${ReconfCmplRcvS[${idx}]}
        should not be empty   ${ReconfCmplRcvUS[${idx}]}
        should not be empty   ${snStatusTransferRcvS[${idx}]}
        should not be empty   ${snStatusTransferRcvUS[${idx}]}
    END
    Should Be True   ${menbUeX2APId} == ${x2ap_menbUeX2APId}
    Should Be True   ${sgnbUeX2APId} == ${x2ap_sgnbUeX2APId}

    ${seconds_list}   wireshark.get_field_value_by_xpath   xpath=.//nsetapx.seconds
    ${useconds_list}   wireshark.get_field_value_by_xpath   xpath=.//nsetapx.useconds
    ${curr_date}   Get Current Date   result_format=epoch
    ${curr_date}   Convert To Integer   ${curr_date}

    FOR   ${seconds}   IN   @{seconds_list}
       ${seconds}   Convert To Integer   ${seconds}
       Should Be True   ${curr_date} - ${seconds} > 0
       Should Be True   ${curr_date} - ${seconds} < ${86400}
    END

    FOR   ${useconds}   IN   @{useconds_list}
        ${useconds}   Convert To Integer   ${useconds}
        Should Be True   ${useconds} < ${1000000}
    END
#



Case Setup: 5GC001097_CB_01
    Log To Console   Case Setup: 5GC001097_CB_01
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000

Case Teardown: 5GC001097_CB_01
    Log To Console   Case Teardown: 5GC001097_CB_01
    Check Extra Reset From Blackbox
    robot_common_operations.Common Case Teardown
