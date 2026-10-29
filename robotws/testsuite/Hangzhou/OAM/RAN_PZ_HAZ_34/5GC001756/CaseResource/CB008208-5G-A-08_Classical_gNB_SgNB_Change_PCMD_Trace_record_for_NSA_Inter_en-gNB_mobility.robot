*** Settings ***
Documentation
...   Author: shengyuan.jiang@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
CB008208-5G-A-08_Classical_gNB_SgNB_Change_PCMD_Trace_record_for_NSA_Inter_en-gNB_mobility
#    in the source cell, B-111
    &{eNB_info}   Get eNB Variables
    ${X2AP_menbUeX2APId}   ${X2AP_sgnbUeX2APId}   Get menbUeX2APId and sgnbUeX2APId from X2AP info
    ...   file_path=${NSA_INTER_gNB_HO_SOURCE_PATH}   xpath=x2ap.SgNBChangeRequired_element   expression=34
    FOR   ${item}   IN   @{NSA_INTER_source_crnti_HO_list}
        ${filter_part1}   set variable   nsetapx.CuVendorExtensionRecordDataType == 6 && nsetapx.crnti == ${item}
        ${filter}   set variable   ${filter_part1} && nsetapx.cellIdentity == ${source_cell_identity_filter}
        Load Pcap File with Filter any Expression
            ...   pcap_file=${NSA_INTER_gNB_HO_SOURCE_PATH}
            ...   any_expression=${filter}
            ...   filter=tcp.dstport==${dcap_server_port}
        ${globaleNBId}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.sgnbChangeRecord/nsetapx.data_r1_element/nsetapx.enb_Id_element/nsetapx.enb_Id/nsetapx.macro_eNB_Id
        ...   attribute_name=showname
        ${globaleNBId_info}   Should Match Regexp   ${globaleNBId[0]}   value.*
        ${globaleNBId}   Should Match Regexp   ${globaleNBId_info}   \\d+

        ${menbUeX2APId}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.sgnbChangeRecord/nsetapx.data_r1_element/nsetapx.menb_ue_x2ap_Id

#        ${menbUeX2APIdExt}   wireshark.get_field_value_by_xpath
#        ...   xpath=.//nsetapx.CuVendorExtensionRecordDataType/nsetapx.menbInitiatedSgNBModRecord

        ${sgnbUeX2APId}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.sgnbChangeRecord/nsetapx.data_r1_element/nsetapx.sgnb_ue_x2ap_Id

        ${result}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.sgnbChangeRecord/nsetapx.data_r1_element/nsetapx.result
        ...   attribute_name=showname

        ${ReqSnd_sec}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.sgnbChangeRecord/nsetapx.data_r1_element/nsetapx.sgnbChangeReqSndTime_element/nsetapx.seconds
        ${ReqSnd_use}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.sgnbChangeRecord/nsetapx.data_r1_element/nsetapx.sgnbChangeReqSndTime_element/nsetapx.useconds

        ${ConfirmRcv_sec}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.sgnbChangeRecord/nsetapx.data_r1_element/nsetapx.sgnbChangeConfirmRcvTime_element/nsetapx.seconds
        ${ConfirmRcv_use}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.sgnbChangeRecord/nsetapx.data_r1_element/nsetapx.sgnbChangeConfirmRcvTime_element/nsetapx.useconds

        ${ReleaseRcv_sec}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.sgnbChangeRecord/nsetapx.data_r1_element/nsetapx.x2UeCtxReleaseRcvTime_element/nsetapx.seconds
        ${ReleaseRcv_use}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.sgnbChangeRecord/nsetapx.data_r1_element/nsetapx.x2UeCtxReleaseRcvTime_element/nsetapx.useconds

        log to console   check globaleNBId
        should be equal   ${eNB_info}[globaleNBId]   ${${globaleNBId}}

        log to console   check menbUeX2APId
        should not be empty   ${menbUeX2APId}
        List Should Contain Sub List   ${X2AP_menbUeX2APId}   ${menbUeX2APId}

#        log to console   check menbUeX2APIdExt

        log to console   check sgnbUeX2APId
        should not be empty   ${sgnbUeX2APId}
        List Should Contain Sub List   ${X2AP_sgnbUeX2APId}   ${sgnbUeX2APId}

        log to console   check result
        Should Contain Match   ${result}   regexp=.*success.*

        log to console   check Time
        should not be empty   ${ReqSnd_sec}
        should not be empty   ${ReqSnd_use}
        should not be empty   ${ConfirmRcv_sec}
        should not be empty   ${ConfirmRcv_use}
        should not be empty   ${ReleaseRcv_sec}
        should not be empty   ${ReleaseRcv_use}
    END
#
#
Case Setup: CB008208-5G-A-08
    Log To Console   Case Setup: CB008208-5G-A-08
    ${file_status}   run keyword and return status   File Should Not Be Empty   ${NSA_INTER_gNB_HO_TARGET_PATH}
    ${HO_target_status}   run keyword and return status   should not be empty   ${NSA_INTER_target_crnti_HO_list}
    ${HO_source_status}   run keyword and return status   should not be empty   ${NSA_INTER_source_crnti_HO_list}
    set test variable   ${file_status}
    set test variable   ${HO_target_status}
    set test variable   ${HO_source_status}
    Run Keyword If   '${file_status}'=='False' or '${HO_target_status}'=='False' or '${HO_source_status}'=='False'   Run Keywords
    ...   Common Setup 1756   AND
    ...   Remove And Add PCMD Object   AND
    ...   Trigger INTER gNB HO   ${NSA_ue_index}    ${NSA_INTER_gNB_HO_TARGET_FILE}   ${NSA_INTER_gNB_HO_SOURCE_FILE}   NSA
    run keyword if  '${file_status}'=='False' or '${HO_target_status}'=='False' or '${HO_source_status}'=='False'
    ...   Get Variables from HO File for CB008208-5G-A-08

Get Variables from HO File for CB008208-5G-A-08
    ${NSA_INTER_target_crnti_HO_list}   Get nrcti of HO    ${NSA_INTER_gNB_HO_TARGET_PATH}
    ...   nsetapx.CuVendorExtensionRecordDataType == 9
    set suite variable   ${NSA_INTER_target_crnti_HO_list}
    ${NSA_INTER_source_crnti_HO_list}   Get nrcti of HO   ${NSA_INTER_gNB_HO_SOURCE_PATH}
    ...   nsetapx.CuVendorExtensionRecordDataType == 8
    set suite variable   ${NSA_INTER_source_crnti_HO_list}

Case Teardown: CB008208-5G-A-08
    Log To Console   Case Teardown: CB008208-5G-A-08
    Run Keyword If   '${file_status}'=='False' or '${HO_target_status}'=='False' or '${HO_source_status}'=='False'   Run Keywords
    ...   Initialize PA   AND
    ...   Common Teardown 1756
