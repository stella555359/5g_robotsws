*** Settings ***
Documentation
...   Author: shengyuan.jiang@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
CB008208-5G-A-02_Classical_gNB_CU_Bearers_in_NSA_Intra-MeNB_HO_gNB-CU_Bearer_record_should_not_recorded
    should not be empty   ${INTRA_MeNB_crnti_HO_list}
    FOR   ${item}   IN   @{INTRA_MeNB_crnti_HO_list}
        Load Pcap File with Filter any Expression
            ...   pcap_file=${INTRA_MeNB_HO_gNB_PATH}
            ...   any_expression=nsetapx.setupBearers == 1 && nsetapx.cellIdentity == ${source_cell_identity_filter}
            ...   filter=tcp.dstport==${dcap_server_port}
        ${BearRecord}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.bearerRecord/nsetapx.data_element/nsetapx.setupBearers//nsetapx.CuBearerSetupItem_element
        ...   attribute_name=showname

        log to console   check bearRecord
        ${CuBearerSetupItem_count}   Count Values In List   ${BearRecord}   CuBearerSetupItem
        should be equal   ${CuBearerSetupItem_count}   ${1}

        ${filter_part1}   set variable   nsetapx.CuVendorExtensionRecordDataType == 7 && nsetapx.crnti == ${item}
        ${filter}   set variable   ${filter_part1} && nsetapx.cellIdentity == ${source_cell_identity_filter}

        Load Pcap File with Filter any Expression
            ...   pcap_file=${INTRA_MeNB_HO_gNB_PATH}
            ...   any_expression=${filter}
            ...   filter=tcp.dstport==${dcap_server_port}

        ${MeNBInitiatedSgNBModificationTraceRecord}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.menbInitiatedSgNBModRecord

        ${MeNBInitiatedSgNBModificationReason}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.menbInitiatedSgNBModRecord/nsetapx.data_r1_element/nsetapx.sgnbModificationReason
        ...   attribute_name=showname
        ${MeNBInitiatedSgNBModificationResult}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.menbInitiatedSgNBModRecord/nsetapx.data_r1_element/nsetapx.result   attribute_name=showname

        should not be empty   ${MeNBInitiatedSgNBModificationReason}
        Should Contain Match   ${MeNBInitiatedSgNBModificationResult}   regexp=.*success.*

        ${filter_part1}   set variable   nsetapx.CuVendorExtensionRecordDataType == 5 && nsetapx.crnti == ${item}
        ${filter}   set variable   ${filter_part1} && nsetapx.cellIdentity == ${source_cell_identity_filter}

        Load Pcap File with Filter any Expression
            ...   pcap_file=${INTRA_MeNB_HO_gNB_PATH}
            ...   any_expression=${filter}
            ...   filter=tcp.dstport==${dcap_server_port}

        ${SgNBInitiatedSgNBModificationTraceRecord}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.CuVendorExtensionRecordDataType/nsetapx.sgnbInitiatedSgNBModRecord

        ${SgNBInitiatedSgNBModificationReason}   wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.sgnbInitiatedSgNBModRecord/nsetapx.data_r1_element/nsetapx.sgnbModificationReason    attribute_name=showname

        Should Not Contain Match   ${SgNBInitiatedSgNBModificationReason}   regexp=.*intraDuPSCellChange.*

    END

Case Setup: CB008208-5G-A-02
    Log To Console   Case Setup: CB008208-5G-A-02
    ${file_status}   run keyword and return status   File Should Not Be Empty   ${INTRA_MeNB_HO_gNB_PATH}
    ${HO_status}   run keyword and return status   should not be empty   ${INTRA_MeNB_crnti_HO_list}
    set test variable   ${file_status}
    set test variable   ${HO_status}
    Run Keyword If   '${file_status}'=='False' or '${HO_status}'=='False'   Run Keywords
    ...   Common Setup 1756   AND
    ...   Remove And Add PCMD Object   AND
    ...   Trigger INTRA eNB HO   ${NSA_ue_index}    ${INTRA_MeNB_HO_gNB_FILE}
    run keyword if  '${file_status}'=='False' or '${HO_status}'=='False'   Get Variables from HO File for CB008208-5G-A-05

Get Variables from HO File for CB008208-5G-A-02
    ${INTRA_MeNB_crnti_HO_list}   Get nrcti of HO   ${INTRA_MeNB_HO_gNB_PATH}   nsetapx.CuVendorExtensionRecordDataType == 7
    set suite variable   ${INTRA_MeNB_crnti_HO_list}

Case Teardown: CB008208-5G-A-02
    Log To Console   Case Teardown: CB008208-5G-A-02
    Run Keyword If   '${file_status}'=='False' or '${HO_status}'=='False'   Run Keywords
    ...   Initialize PA   AND
    ...   Common Teardown 1756
