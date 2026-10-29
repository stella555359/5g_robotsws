*** Settings ***
Documentation
...   Author: shengyuan.jiang@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
CB008208-5G-A-06_Classical_gNB_connectivity_information_in_gNB_initiated_SgNB_Modification_record_for_NSA_Intra_en-gNB_mobility
#   extension of existing records with MeNB Connectivity information (source cell), B107
    &{eNB_info}   Get eNB Variables
    ${X2AP_menbUeX2APId}   ${X2AP_sgnbUeX2APId}   Get menbUeX2APId and sgnbUeX2APId from X2AP info   ${NSA_INTRA_gNB_HO_PATH}

    FOR   ${item}   IN   @{NSA_INTRA_source_crnti_HO_list}
        ${filter_part1}   set variable   nsetapx.CuVendorExtensionRecordDataType == 5 && nsetapx.crnti == ${item}
        ${filter}   set variable   ${filter_part1} && nsetapx.cellIdentity == ${source_cell_identity_filter}
        Load Pcap File with Filter any Expression
            ...   pcap_file=${NSA_INTRA_gNB_HO_PATH}
            ...   any_expression=${filter}
            ...   filter=tcp.dstport==${dcap_server_port}

        ${globaleNBId}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.sgnbInitiatedSgNBModRecord/nsetapx.data_r1_element/nsetapx.enb_Id_element/nsetapx.enb_Id/nsetapx.macro_eNB_Id
        ...   attribute_name=showname

        ${globaleNBId_info}   Should Match Regexp   ${globaleNBId[0]}   value.*
        ${globaleNBId}   Should Match Regexp   ${globaleNBId_info}   \\d+

        ${menbUeX2APId}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.sgnbInitiatedSgNBModRecord/nsetapx.data_r1_element/nsetapx.menb_ue_x2ap_Id

        ${sgnbUeX2APId}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.sgnbInitiatedSgNBModRecord/nsetapx.data_r1_element/nsetapx.sgnb_ue_x2ap_Id

        ${reason}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.sgnbInitiatedSgNBModRecord/nsetapx.data_r1_element/nsetapx.sgnbModificationReason
        ...   attribute_name=showname

        ${result}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.sgnbInitiatedSgNBModRecord/nsetapx.data_r1_element/nsetapx.result
        ...   attribute_name=showname

        ${ReqSndTime_sec}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.sgnbInitiatedSgNBModRecord/nsetapx.data_r1_element/nsetapx.sgnbModificationReqSndTime_element/nsetapx.seconds
        ${ReqSndTime_use}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.sgnbInitiatedSgNBModRecord/nsetapx.data_r1_element/nsetapx.sgnbModificationReqSndTime_element/nsetapx.useconds

        ${confirmTime_sec}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.sgnbInitiatedSgNBModRecord/nsetapx.data_r1_element/nsetapx.sgnbModificationConfirmRcvTime_element/nsetapx.seconds
        ${confirmTime_use}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.sgnbInitiatedSgNBModRecord/nsetapx.data_r1_element/nsetapx.sgnbModificationConfirmRcvTime_element/nsetapx.useconds

        log to console   check globaleNBId
        should be equal   ${eNB_info}[globaleNBId]   ${${globaleNBId}}

        log to console   check menbUeX2APId
        should not be empty   ${menbUeX2APId}
        List Should Contain Sub List   ${X2AP_menbUeX2APId}   ${menbUeX2APId}

#        log to console   check menbUeX2APIdExt

        log to console   check sgnbUeX2APId
        should not be empty   ${menbUeX2APId}
        List Should Contain Sub List   ${X2AP_sgnbUeX2APId}   ${sgnbUeX2APId}

        log to console   check SgNBModificationReason
        Should Contain Match   ${reason}   regexp=.*intraDuPSCellChange.*
        Should Contain Match   ${result}   regexp=.*success.*

        log to console   check record send time and confirm time
        should not be empty   ${ReqSndTime_sec}
        should not be empty   ${ReqSndTime_use}
        should not be empty   ${confirmTime_sec}
        should not be empty   ${confirmTime_use}

    END

Case Setup: CB008208-5G-A-06
    Log To Console   Case Setup: CB008208-5G-A-06
    ${file_status}   run keyword and return status   File Should Not Be Empty   ${NSA_INTRA_gNB_HO_PATH}
    ${HO_status}   run keyword and return status   should not be empty   ${NSA_INTRA_target_crnti_HO_list}
    set test variable   ${file_status}
    set test variable   ${HO_status}
    Run Keyword If   '${file_status}'=='False' or '${HO_status}'=='False'   Run Keywords
    ...   Common Setup 1756   AND
    ...   Remove And Add PCMD Object   AND
    ...   Trigger INTRA gNB HO   ${NSA_ue_index}    ${NSA_INTRA_gNB_HO_FILE}   NSA
    run keyword if  '${file_status}'=='False' or '${HO_status}'=='False'   Get Variables from HO File for CB008208-5G-A-06

Get Variables from HO File for CB008208-5G-A-06
    ${NSA_INTRA_target_crnti_HO_list}   ${NSA_INTRA_source_crnti_HO_list}   Get nrcti of Target and Source HO   ${NSA_INTRA_gNB_HO_PATH}
    ...   nsetapx.CuVendorExtensionRecordDataType == 9   nsetapx.CuVendorExtensionRecordDataType == 8
    set suite variable   ${NSA_INTRA_target_crnti_HO_list}
    set suite variable   ${NSA_INTRA_source_crnti_HO_list}

Case Teardown: CB008208-5G-A-06
    Log To Console   Case Teardown: CB008208-5G-A-06
    Run Keyword If   '${file_status}'=='False' or '${HO_status}'=='False'   Run Keywords
    ...   Initialize PA   AND
    ...   Common Teardown 1756
