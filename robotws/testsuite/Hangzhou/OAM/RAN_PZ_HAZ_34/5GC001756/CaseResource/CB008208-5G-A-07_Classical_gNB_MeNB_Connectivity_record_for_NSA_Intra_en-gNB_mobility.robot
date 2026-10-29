*** Settings ***
Documentation
...   Author: liangliang.heng@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
CB008208-5G-A-07_Classical_gNB_MeNB_Connectivity_record_for_NSA_Intra_en-gNB_mobility
#    new record MeNB Connectivity information (target cell),B-110
    &{eNB_info}   Get eNB Variables
    ${X2AP_menbUeX2APId}   ${X2AP_sgnbUeX2APId}   Get menbUeX2APId and sgnbUeX2APId from X2AP info   ${NSA_INTRA_gNB_HO_PATH}

    FOR   ${item}   IN   @{NSA_INTRA_target_crnti_HO_list}
        ${filter_part1}   set variable   nsetapx.CuVendorExtensionRecordDataType == 15 && nsetapx.crnti == ${item}
        ${filter}   set variable   ${filter_part1} && nsetapx.cellIdentity == ${target_cell_identity_filter}
        Load Pcap File with Filter any Expression
            ...   pcap_file=${NSA_INTRA_gNB_HO_PATH}
            ...   any_expression=${filter}
            ...   filter=tcp.dstport==${dcap_server_port}

        ${globaleNBId_xpath1}   set variable   .//nsetapx.menbConnectivityRecord/nsetapx.data_element/nsetapx.setupData//
        ${globaleNBId_xpath2}   set variable   nsetapx.MeNBConnectivitySetupItem_element/nsetapx.enb_Id_element/nsetapx.enb_Id/nsetapx.macro_eNB_Id
        ${globaleNBId}   wireshark.get_field_value_by_xpath
        ...   xpath=${globaleNBId_xpath1}${globaleNBId_xpath2}
        ...   attribute_name=showname
        ${globaleNBId_info}   Should Match Regexp   ${globaleNBId[0]}   value.*
        ${globaleNBId}   Should Match Regexp   ${globaleNBId_info}   \\d+

        ${plmnIdentity_xpath2}   set variable   nsetapx.MeNBConnectivitySetupItem_element/nsetapx.enb_Id_element/nsetapx.plmn_Identity
        ${plmnIdentity}   wireshark.get_field_value_by_xpath
        ...   xpath=${globaleNBId_xpath1}${plmnIdentity_xpath2}
#        ${plmnIdentity_info}   Should Match Regexp   ${plmnIdentity[0]}   \\d+.*
#        ${plmnIdentity}   Should Match Regexp   ${plmnIdentity[0]}   \\d+.*


        ${menbUeX2APId}   wireshark.get_field_value_by_xpath
        ...   xpath=${globaleNBId_xpath1}nsetapx.MeNBConnectivitySetupItem_element/nsetapx.menb_ue_x2ap_Id

#        ${menbUeX2APIdExt}   wireshark.get_field_value_by_xpath
#        ...   xpath=.//nsetapx.CuVendorExtensionRecordDataType/nsetapx.sgnbInitiatedSgNBModRecord

        ${sgnbUeX2APId}   wireshark.get_field_value_by_xpath
        ...   xpath=${globaleNBId_xpath1}nsetapx.MeNBConnectivitySetupItem_element/nsetapx.sgnb_ue_x2ap_Id

        ${result}   wireshark.get_field_value_by_xpath
        ...   xpath=${globaleNBId_xpath1}nsetapx.MeNBConnectivitySetupItem_element/nsetapx.result   attribute_name=showname

        log to console   check globaleNBId
        should be equal   ${eNB_info}[globaleNBId]   ${${globaleNBId}}
        should not be empty   ${plmnIdentity}

        log to console   check menbUeX2APId
        List Should Contain Sub List   ${X2AP_menbUeX2APId}   ${menbUeX2APId}
        run keyword if   ${menbUeX2APId[0]}>4095 or ${menbUeX2APId[0]}<0   fail   msg=menbUeX2APId out of range

#        log to console   check menbUeX2APIdExt

        log to console   check sgnbUeX2APId
        List Should Contain Sub List   ${X2AP_sgnbUeX2APId}   ${sgnbUeX2APId}
        run keyword if   ${sgnbUeX2APId[0]}>4294967295 or ${sgnbUeX2APId[0]}<0   fail   msg=menbUeX2APId out of range

        log to console   check result
        Should Contain Match   ${result}   regexp=.*success.*
    END

Case Setup: CB008208-5G-A-07
    Log To Console   Case Setup: CB008208-5G-A-07
    ${file_status}   run keyword and return status   File Should Not Be Empty   ${NSA_INTRA_gNB_HO_PATH}
    ${HO_status}   run keyword and return status   should not be empty   ${NSA_INTRA_target_crnti_HO_list}
    set test variable   ${file_status}
    set test variable   ${HO_status}
    Run Keyword If   '${file_status}'=='False' or '${HO_status}'=='False'   Run Keywords
    ...   Common Setup 1756   AND
    ...   Remove And Add PCMD Object   AND
    ...   Trigger INTRA gNB HO   ${NSA_ue_index}    ${NSA_INTRA_gNB_HO_FILE}   NSA
    run keyword if  '${file_status}'=='False' or '${HO_status}'=='False'   Get Variables from HO File for CB008208-5G-A-07

Get Variables from HO File for CB008208-5G-A-07
#    ${NSA_INTRA_target_crnti_HO_list}   ${NSA_INTRA_source_crnti_HO_list}   Get nrcti of Target and Source HO   ${NSA_INTRA_gNB_HO_PATH}
#    ...   nsetapx.CuVendorExtensionRecordDataType == 9   nsetapx.CuVendorExtensionRecordDataType == 8
    ${NSA_INTRA_target_crnti_HO_list}   ${NSA_INTRA_source_crnti_HO_list}   Get nrcti of Target and Source in NSA intra HO   ${NSA_INTRA_gNB_HO_PATH}
    set suite variable   ${NSA_INTRA_target_crnti_HO_list}
    set suite variable   ${NSA_INTRA_source_crnti_HO_list}

Case Teardown: CB008208-5G-A-07
    Log To Console   Case Teardown: CB008208-5G-A-07
    Run Keyword If   '${file_status}'=='False' or '${HO_status}'=='False'   Run Keywords
    ...   Initialize PA   AND
    ...   Common Teardown 1756
