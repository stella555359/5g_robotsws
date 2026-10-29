*** Settings ***
Documentation
...   Author: liping.hong@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
CB008208-5G-A-20_Classical_DU_gNB-HO-SRC_and_DU_gNB-HO-TGT_reporting_during_SA_Intra-DU_handover
    log to console     check elemnet  DU_gNB-HO-SRC_and_DU_gNB-HO-TGT_reporting
    ${SA_INTRA_crnti_HO_length}=  Get Length   ${SA_INTRA_crnti_HO_list}
    set test variable   ${SA_INTRA_crnti_HO_length}
    Get Intra gNB HO Record Field List   SRC
    Get Intra gNB HO Record Field List   TGT
    Log To Console   check value is OK

Get Intra gNB HO Record Field List
    [Arguments]   ${SRCorTGT}
    ${input_type}   set variable if   '${SRCorTGT}' == 'SRC'   11   12
    ${xpath_record}   set variable if   '${SRCorTGT}' == 'SRC'   hoSrcRecord  hoTgtRecord
    ${xpath_cellid}   set variable if   '${SRCorTGT}' == 'SRC'   tgtCellId  srcCellId
    ${nrcellid}   set variable if   '${SRCorTGT}' == 'SRC'   ${nrcellid_target}  ${nrcellid_source}
    ${drx}   set variable if   '${SRCorTGT}' == 'SRC' and '${drx_source}' == 'true'   1   0
    Load Pcap File with Filter
     ...                        pcap_file=${SA_INTRA_gNB_HO_PATH}
     ...                        record_type=Du
     ...                        input_type=${input_type}
     ...                        filter=tcp.dstport==${dcap_server_port}
    ${xpath_SAHO_e}   set variable   .//nsetapx.${xpath_record}/nsetapx.data_element/

    ${result_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=${xpath_SAHO_e}/nsetapx.result
    ${plmn_list}=     wireshark.get_field_value_by_xpath
    ...    xpath=${xpath_SAHO_e}/nsetapx.${xpath_cellid}_element/nsetapx.plmn_Identity
    ${CellId_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=${xpath_SAHO_e}/nsetapx.${xpath_cellid}_element/nsetapx.cellIdentity   attribute_name=showname
     ${drxConfigured_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=${xpath_SAHO_e}/nsetapx.drxConfigured
     ${measGapConfigured_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=${xpath_SAHO_e}/nsetapx.measGapConfigured

    Should Contain X Times   ${result_list}   0   ${SA_INTRA_crnti_HO_length}
    Length Should Be   ${plmn_list}   ${SA_INTRA_crnti_HO_length}
    Length Should Be   ${CellId_list}   ${SA_INTRA_crnti_HO_length}
    Length Should Be   ${drxConfigured_list}   ${SA_INTRA_crnti_HO_length}
    Length Should Be   ${measGapConfigured_list}   ${SA_INTRA_crnti_HO_length}

    FOR   ${idx}    IN RANGE    0   ${SA_INTRA_crnti_HO_length}
        ${plman_clear}   Remove String   ${plmn_list}[${idx}]   :
        Should Be True   '${plman_clear}' == '${PLMN_IDENTITY}'
        should contain   ${CellId_list}[${idx}]   ${nrcellid}
        Should Be True   ${drxConfigured_list}[${idx}] == ${drx}
        Should Be True   ${measGapConfigured_list}[${idx}] == 0
    END

Case Setup: CB008208-5G-A-20
    Log To Console   Case Setup: CB008208-5G-A-20
    ${file_status}   run keyword and return status   File Should Not Be Empty   ${SA_INTRA_gNB_HO_PATH}
    ${HO_status}   run keyword and return status   should not be empty   ${SA_INTRA_crnti_HO_list}
    set test variable   ${file_status}
    set test variable   ${HO_status}
    Run Keyword If   '${file_status}'=='False' or '${HO_status}'=='False'   Run Keywords
    ...   Common Setup 1756   AND
    ...   Remove And Add PCMD Object   AND
    ...   Trigger INTRA gNB HO   ${SA_ue_index}    ${SA_INTRA_gNB_HO_FILE}   SA
    ${SA_INTRA_crnti_HO_list}   ${SA_INTRA_crnti_HO_length}   run keyword if  '${file_status}'=='False' or '${HO_status}'=='False'
    ...   Get nrcti of HO    ${SA_INTRA_gNB_HO_PATH}
    ...   nsetapx.CuVendorExtensionRecordDataType==14 && nsetapx.trigger==2
    run keyword if  '${file_status}'=='False' or '${HO_status}'=='False'   Run Keywords   set suite variable   ${SA_INTRA_crnti_HO_list}
    ...   AND   set suite variable   ${SA_INTRA_crnti_HO_length}

Case Teardown: CB008208-5G-A-20
    Log To Console   Case Teardown: CB008208-5G-A-20
    Run Keyword If   '${file_status}'=='False' or '${HO_status}'=='False'   Run Keywords
    ...   Initialize PA   AND
    ...   Common Teardown 1756
