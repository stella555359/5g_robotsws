*** Settings ***
Documentation
...   Author: shengyuan.jiang@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
CB008208-5G-A-05_Classical_gNB_connectivity_information_in_eNB_initiated_SgNB_Modification_record_for_Intra-MeNB_HO
#   extension of existing records with MeNB Connectivity information (source cell), B105
    &{eNB_info}   Get eNB Variables
    ${X2AP_menbUeX2APId}   ${X2AP_sgnbUeX2APId}   Get menbUeX2APId and sgnbUeX2APId from X2AP info   ${INTRA_MeNB_HO_gNB_PATH}

    FOR   ${item}   IN   @{INTRA_MeNB_crnti_HO_list}
        ${filter_part1}   set variable   nsetapx.CuVendorExtensionRecordDataType == 7 && nsetapx.crnti == ${item}
        ${filter}   set variable   ${filter_part1} && nsetapx.cellIdentity == ${source_cell_identity_filter}
        Load Pcap File with Filter any Expression
            ...   pcap_file=${INTRA_MeNB_HO_gNB_PATH}
            ...   any_expression=${filter}
            ...   filter=tcp.dstport==${dcap_server_port}
        ${MeNBInitiatedSgNBModificationReason}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.menbInitiatedSgNBModRecord/nsetapx.data_r1_element/nsetapx.sgnbModificationReason
        ...   attribute_name=showname

        ${MeNBInitiatedSgNBModificationReason_result}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.menbInitiatedSgNBModRecord/nsetapx.data_r1_element/nsetapx.result   attribute_name=showname

        ${globaleNBId}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.menbInitiatedSgNBModRecord/nsetapx.data_r1_element/nsetapx.enb_Id_element/nsetapx.enb_Id/nsetapx.macro_eNB_Id
        ...   attribute_name=showname
        ${globaleNBId_info}   Should Match Regexp   ${globaleNBId[0]}   value.*
        ${globaleNBId}   Should Match Regexp   ${globaleNBId_info}   \\d+

        ${menbUeX2APId}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.menbInitiatedSgNBModRecord/nsetapx.data_r1_element/nsetapx.menb_ue_x2ap_Id

#        ${menbUeX2APIdExt}   wireshark.get_field_value_by_xpath
#        ...   xpath=.//nsetapx.menbInitiatedSgNBModRecord/nsetapx.data_r1_element

        ${sgnbUeX2APId}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.menbInitiatedSgNBModRecord/nsetapx.data_r1_element/nsetapx.sgnb_ue_x2ap_Id

        ${ReqRcv_sec}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.menbInitiatedSgNBModRecord/nsetapx.data_r1_element/nsetapx.sgnbModificationReqRcvTime_element/nsetapx.seconds
        ${ReqRcv_use}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.menbInitiatedSgNBModRecord/nsetapx.data_r1_element/nsetapx.sgnbModificationReqRcvTime_element/nsetapx.useconds

        ${ReqAckSnd_sec}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.menbInitiatedSgNBModRecord/nsetapx.data_r1_element/nsetapx.sgnbModificationReqAckSndTime_element/nsetapx.seconds
        ${ReqAckSnd_use}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.menbInitiatedSgNBModRecord/nsetapx.data_r1_element/nsetapx.sgnbModificationReqAckSndTime_element/nsetapx.useconds

        ${CmpRcv_sec}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.menbInitiatedSgNBModRecord/nsetapx.data_r1_element/nsetapx.sgnbModificationCmplRcvTime_element/nsetapx.seconds
        ${CmpRcv_use}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.menbInitiatedSgNBModRecord/nsetapx.data_r1_element/nsetapx.sgnbModificationCmplRcvTime_element/nsetapx.useconds

        log to console   check MeNBInitiatedSgNBModificationReason
        should not be empty   ${MeNBInitiatedSgNBModificationReason}
        Should Contain Match   ${MeNBInitiatedSgNBModificationReason_result}   regexp=.*success.*

        log to console   check globaleNBId
        should be equal   ${eNB_info}[globaleNBId]   ${${globaleNBId}}

        log to console   check menbUeX2APId
        List Should Contain Sub List   ${X2AP_menbUeX2APId}   ${menbUeX2APId}
        run keyword if   ${menbUeX2APId[0]}>4095 or ${menbUeX2APId[0]}<0   fail   msg=menbUeX2APId out of range

#        log to console   check menbUeX2APIdExt

        log to console   check sgnbUeX2APId
        List Should Contain Sub List   ${X2AP_sgnbUeX2APId}   ${sgnbUeX2APId}
        run keyword if   ${sgnbUeX2APId[0]}>4294967295 or ${sgnbUeX2APId[0]}<0   fail   msg=menbUeX2APId out of range

        log to console   check Time
        should not be empty   ${ReqRcv_sec}
        should not be empty   ${ReqRcv_use}
        should not be empty   ${ReqAckSnd_sec}
        should not be empty   ${ReqAckSnd_use}
        should not be empty   ${CmpRcv_sec}
        should not be empty   ${CmpRcv_use}
    END

Case Setup: CB008208-5G-A-05
    Log To Console   Case Setup: CB008208-5G-A-05
    ${file_status}   run keyword and return status   File Should Not Be Empty   ${INTRA_MeNB_HO_gNB_PATH}
    ${HO_status}   run keyword and return status   should not be empty   ${INTRA_MeNB_crnti_HO_list}
    set test variable   ${file_status}
    set test variable   ${HO_status}
    Run Keyword If   '${file_status}'=='False' or '${HO_status}'=='False'   Run Keywords
    ...   Common Setup 1756   AND
    ...   Remove And Add PCMD Object   AND
    ...   Trigger INTRA eNB HO   ${NSA_ue_index}    ${INTRA_MeNB_HO_gNB_FILE}
    run keyword if  '${file_status}'=='False' or '${HO_status}'=='False'   Get Variables from HO File for CB008208-5G-A-05

Get Variables from HO File for CB008208-5G-A-05
    ${INTRA_MeNB_crnti_HO_list}   Get nrcti of HO   ${INTRA_MeNB_HO_gNB_PATH}   nsetapx.CuVendorExtensionRecordDataType == 7
    set suite variable   ${INTRA_MeNB_crnti_HO_list}

Case Teardown: CB008208-5G-A-05
    Log To Console   Case Teardown: CB008208-5G-A-05
    Run Keyword If   '${file_status}'=='False' or '${HO_status}'=='False'   Run Keywords
    ...   Initialize PA   AND
    ...   Common Teardown 1756
