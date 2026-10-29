*** Settings ***
Documentation
...   Author: shengyuan.jiang@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
CB008208-5G-A-03_Classical_gNB_CU_Bearers_in_NSA_Intra_en-gNB_mobility_gNB-CU_Bearer_record_not_recorded_on_source_cell
# MeNBInitiatedSgNBModificationTraceRecord and SgNBInitiatedSgNBModificationTraceRecord not both on source cell(nsetapx.cellIdentity==00:a9:6c:00:10)
    FOR   ${item}   IN   @{NSA_INTRA_source_crnti_HO_list}
        ${filter_part1}   set variable   nsetapx.CuVendorExtensionRecordDataType == 10 && nsetapx.crnti == ${item}
        ${filter}   set variable   ${filter_part1} && nsetapx.cellIdentity == ${source_cell_identity_filter}
        Load Pcap File with Filter any Expression
            ...   pcap_file=${NSA_INTRA_gNB_HO_PATH}
            ...   any_expression=${filter}
            ...   filter=tcp.dstport==${dcap_server_port}

        ${beardRecords}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.CuVendorExtensionRecordDataType/nsetapx.bearerRecord/nsetapx.data_element/nsetapx.setupBearers
#        ...   attribute_name=showname

        ${beardRecordsTrigger}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.CuVendorExtensionRecordDataType/nsetapx.bearerRecord/nsetapx.data_element/nsetapx.trigger
        ...   attribute_name=showname

        ${filter_part1}   set variable   nsetapx.CuVendorExtensionRecordDataType == 7 && nsetapx.crnti == ${item}
        ${filter}   set variable   ${filter_part1} && nsetapx.cellIdentity == ${source_cell_identity_filter}

        Load Pcap File with Filter any Expression
            ...   pcap_file=${NSA_INTRA_gNB_HO_PATH}
            ...   any_expression=${filter}
            ...   filter=tcp.dstport==${dcap_server_port}

        ${MeNBInitiatedSgNBModificationTraceRecord}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.menbInitiatedSgNBModRecord

#        ${MeNBInitiatedSgNBModificationReason}   wireshark.get_field_value_by_xpath
#        ...   xpath=.//nsetapx.menbInitiatedSgNBModRecord/nsetapx.data_r1_element/nsetapx.sgnbModificationReason
#        ...   attribute_name=showname
#        ${MeNBInitiatedSgNBModificationResult}   wireshark.get_field_value_by_xpath
#        ...   xpath=.//nsetapx.menbInitiatedSgNBModRecord/nsetapx.data_r1_element/nsetapx.result   attribute_name=showname

        ${filter_part1}   set variable   nsetapx.CuVendorExtensionRecordDataType == 5 && nsetapx.crnti == ${item}
        ${filter}   set variable   ${filter_part1} && nsetapx.cellIdentity == ${source_cell_identity_filter}

        Load Pcap File with Filter any Expression
            ...   pcap_file=${NSA_INTRA_gNB_HO_PATH}
            ...   any_expression=${filter}
            ...   filter=tcp.dstport==${dcap_server_port}

        ${SgNBInitiatedSgNBModificationTraceRecord}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.CuVendorExtensionRecordDataType/nsetapx.sgnbInitiatedSgNBModRecord

        log to console   check MeNBInitiatedSgNBModificationTraceRecord or SgNBInitiatedSgNBModificationTraceRecord

        ${sgnb_length}   Get Length   ${SgNBInitiatedSgNBModificationTraceRecord}

#        run keyword if   '${sgnb_length}'=='1'   Length Should Be   ${MeNBInitiatedSgNBModificationTraceRecord}   1
#        ...   ELSE   Length Should Be   ${MeNBInitiatedSgNBModificationTraceRecord}   0

        Length Should Be   ${MeNBInitiatedSgNBModificationTraceRecord}   0


        ${SgNBInitiatedSgNBModificationReason}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.sgnbInitiatedSgNBModRecord/nsetapx.data_r1_element/nsetapx.sgnbModificationReason    attribute_name=showname
        ${SgNBInitiatedSgNBModificationResult}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.sgnbInitiatedSgNBModRecord/nsetapx.data_r1_element/nsetapx.result    attribute_name=showname

#        ${MeNB_status}   run keyword and return status   Length Should Be   ${MeNBInitiatedSgNBModificationTraceRecord}   0
#        run keyword unless   ${MeNB_status}   run keywords   should not be empty   ${MeNBInitiatedSgNBModificationReason}
#        ...   AND   Get Matches   ${MeNBInitiatedSgNBModificationResult}   .*success.*

        Should Contain Match   ${SgNBInitiatedSgNBModificationReason}   regexp=.*intraDuPSCellChange.*
        Should Contain Match   ${SgNBInitiatedSgNBModificationResult}   regexp=.*success.*

#        Length Should Be   ${beardRecords}   2
        log to console   check beardRecords
        ${beardRecords_length}   Get Length   ${beardRecords}
        run keyword if   '${beardRecords_length}'=='1'   Should Contain Match   ${beardRecordsTrigger}   regexp=.*other.*
        ...   ELSE IF   '${beardRecords_length}'=='2'   run keywords   Should Contain Match   ${beardRecordsTrigger}   regexp=.*other.*
        ...   AND   Should Contain Match   ${beardRecordsTrigger}   regexp=.*intragNBHandover.*
        ...   ELSE   Fail

    END

Case Setup: CB008208-5G-A-03
    Log To Console   CB008208-5G-A-03
    ${file_status}   run keyword and return status   File Should Not Be Empty   ${NSA_INTRA_gNB_HO_PATH}
    ${HO_status}   run keyword and return status   should not be empty   ${NSA_INTRA_target_crnti_HO_list}
    set test variable   ${file_status}
    set test variable   ${HO_status}
    Run Keyword If   '${file_status}'=='False' or '${HO_status}'=='False'   Run Keywords
    ...   Common Setup 1756   AND
    ...   Remove And Add PCMD Object   AND
    ...   Trigger INTRA gNB HO   ${NSA_ue_index}    ${NSA_INTRA_gNB_HO_FILE}   NSA
    run keyword if  '${file_status}'=='False' or '${HO_status}'=='False'   Get Variables from HO File for CB008208-5G-A-03

Get Variables from HO File for CB008208-5G-A-03
    ${NSA_INTRA_target_crnti_HO_list}   ${NSA_INTRA_source_crnti_HO_list}   Get nrcti of Target and Source in NSA intra HO   ${NSA_INTRA_gNB_HO_PATH}
#    ${NSA_INTRA_target_crnti_HO_list}   ${NSA_INTRA_source_crnti_HO_list}   Get nrcti of Target and Source HO   ${NSA_INTRA_gNB_HO_PATH}
#    ...   nsetapx.CuVendorExtensionRecordDataType == 9   nsetapx.CuVendorExtensionRecordDataType == 8
    set suite variable   ${NSA_INTRA_target_crnti_HO_list}
    set suite variable   ${NSA_INTRA_source_crnti_HO_list}

Case Teardown: CB008208-5G-A-03
    Log To Console   Case Teardown: CB008208-5G-A-03
    Run Keyword If   '${file_status}'=='False' or '${HO_status}'=='False'   Run Keywords
    ...   Initialize PA   AND
    ...   Common Teardown 1756
