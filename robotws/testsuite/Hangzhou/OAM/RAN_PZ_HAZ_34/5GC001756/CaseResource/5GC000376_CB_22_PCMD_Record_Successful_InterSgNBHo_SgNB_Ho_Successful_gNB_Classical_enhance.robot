*** Settings ***
Documentation
...   Author: shengyuan.jiang@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
5GC000376_CB_22_PCMD_Record_Successful_InterSgNBHo_SgNB_Ho_Successful_gNB_Classical_enhance
    ${target_gnb_release}   Get gnb release   host=${PEER_SSH_ADDR}
    ${target_data_xpath}   set variable if   '${target_gnb_release}'>'SBTS22R2'   nsetapx.data_r1_element   nsetapx.data_element
    Load Pcap File with Filter any Expression
            ...   pcap_file=${NSA_INTER_gNB_HO_SOURCE_PATH}
            ...   any_expression=nr-rrc.measObject == 0
            ...   filter=tcp.dstport==49148
    ${cell_freq}   wireshark.get_field_value_by_xpath   .//nr-rrc.measObject/nr-rrc.measObjectNR_element/nr-rrc.ssbFrequency
    set test variable   ${cell_freq}   ${cell_freq[0]}

    Load Pcap File with Filter
     ...                        pcap_file=${NSA_INTER_gNB_HO_TARGET_PATH}
     ...                        record_type=Cu
     ...                        input_type=1
     ...                        filter=tcp.dstport==49148
    ${xpath_head_sgnbAdditionRecord}   set variable   .//nsetapx.sgnbAdditionRecord/${target_data_xpath}/nsetapx.
    ${sgnbAdditionRecord_dict}    Create Dictionary    enb_Id_element/nsetapx.plmn_Identity=plmn-Identity
    ...   enb_Id_element/nsetapx.enb_Id/nsetapx.macro_eNB_Id=macro-eNB-Id   sgnbAdditionReqRcvTime_element=sgnbAdditionReqRcvTime
    ...   triggerReason=triggerReason: snChange (1)    result=result: success (0)
    ${sgnbAdditionRecord_dict_keys} =    Get Dictionary Keys    ${sgnbAdditionRecord_dict}
    FOR    ${xpath_end_sgnbAdditionRecord}   IN    @{sgnbAdditionRecord_dict_keys}
        ${PCMDRecord_Fields_list}=    wireshark.get_field_value_by_xpath
        ...   xpath=${xpath_head_sgnbAdditionRecord}${xpath_end_sgnbAdditionRecord}   attribute_name=showname
        ${sgnbAdditionRecord_dict_values} =    Get From Dictionary    ${sgnbAdditionRecord_dict}   ${xpath_end_sgnbAdditionRecord}
        run keyword if   '${xpath_end_sgnbAdditionRecord}' == 'enb_Id_element/nsetapx.plmn_Identity'
        ...   should contain     ${PCMDRecord_Fields_list}[0]   ${sgnbAdditionRecord_dict_values}
        ...   ELSE IF   '${xpath_end_sgnbAdditionRecord}' == 'enb_Id_element/nsetapx.enb_Id/nsetapx.macro_eNB_Id'
        ...   should contain     ${PCMDRecord_Fields_list}[0]   ${sgnbAdditionRecord_dict_values}
        ...   ELSE   should contain     ${PCMDRecord_Fields_list}   ${sgnbAdditionRecord_dict_values}
    END
    ${PCMDRecord_Fields_list}=    wireshark.get_field_value_by_xpath
    ...   xpath=${xpath_head_sgnbAdditionRecord}menb_ue_x2ap_Id
    Should Be True     0 < ${PCMDRecord_Fields_list}[0] < 4095 or ${PCMDRecord_Fields_list}[0]==0

    Load Pcap File with Filter
     ...                        pcap_file=${NSA_INTER_gNB_HO_TARGET_PATH}
     ...                        record_type=Cu
     ...                        input_type=9
     ...                        filter=tcp.dstport==49148
    ${xpath_head_hoTgtRecord}   set variable   .//nsetapx.hoTgtRecord/nsetapx.data_element/nsetapx.
    ${PCMDRecord_Fields_list}=    wireshark.get_field_value_by_xpath
    ...   xpath=${xpath_head_hoTgtRecord}drxConfigured   attribute_name=showname
    should contain   ${PCMDRecord_Fields_list}   .... ...0 drxConfigured: False
    ${PCMDRecord_Fields_list}=    wireshark.get_field_value_by_xpath
    ...   xpath=${xpath_head_hoTgtRecord}result   attribute_name=showname
    should contain   ${PCMDRecord_Fields_list}   result: success (0)
    ${PCMDRecord_Fields_list}=    wireshark.get_field_value_by_xpath
    ...   xpath=${xpath_head_hoTgtRecord}measGapConfigured   attribute_name=showname
#    Should Contain     ${PCMDRecord_Fields_list}   0... .... measGapConfigured: False
    Load Pcap File with Filter any Expression
    ...   pcap_file=${NSA_INTER_gNB_HO_SOURCE_PATH}
    ...   any_expression=nr-rrc.measGapConfig == 1
    ...   filter=sctp.dstport==38472
    ${xpath1}   set variable   .//f1ap.UEContextSetupRequest_element/f1ap.protocolIEs//f1ap.ProtocolIE_Field_element/f1ap.value_element/
    ${xpath2}   set variable   f1ap.CUtoDURRCInformation_element/f1ap.cG_ConfigInfo/nr-rrc.CG_ConfigInfo_element/nr-rrc.criticalExtensions/
    ${xpath3}   set variable   nr-rrc.c1/nr-rrc.cg_ConfigInfo_element/nr-rrc.measConfigMN_element/nr-rrc.gapPurpose
    ${measGap_f1ap}    wireshark.get_field_value_by_xpath   xpath=${xpath1}${xpath2}${xpath3}   attribute_name=showname

    Run Keyword If   '${measGap_f1ap}[0]'=='gapPurpose: perUE (0)'   Should Contain   ${PCMDRecord_Fields_list}   1... .... measGapConfigured: True
    ...   ELSE   Should Contain   ${PCMDRecord_Fields_list}   0... .... measGapConfigured: False

    Load Pcap File with Filter
     ...                        pcap_file=${NSA_INTER_gNB_HO_TARGET_PATH}
     ...                        record_type=Du
     ...                        input_type=10
     ...                        filter=tcp.dstport==49148
    ${xpath_head_ueCtxModificationRecord}   set variable   .//nsetapx.ueCtxModificationRecord/${target_data_xpath}/nsetapx.
    ${PCMDRecord_Fields_list}=    wireshark.get_field_value_by_xpath
    ...   xpath=${xpath_head_ueCtxModificationRecord}ueCtxModificationReason   attribute_name=showname
    Should Contain     ${PCMDRecord_Fields_list}   ueCtxModificationReason: duUeConfigQuery (6)
    ${PCMDRecord_Fields_list}=    wireshark.get_field_value_by_xpath
    ...   xpath=${xpath_head_ueCtxModificationRecord}result   attribute_name=showname
    Should Contain     ${PCMDRecord_Fields_list}   result: success (0)

    Load Pcap File with Filter
     ...                        pcap_file=${NSA_INTER_gNB_HO_SOURCE_PATH}
     ...                        record_type=Cu
     ...                        input_type=8
     ...                        filter=tcp.dstport==49148
    ${xpath_head_hoSrcRecord}   set variable   .//nsetapx.hoSrcRecord/nsetapx.data_element/nsetapx.
    ${hoSrcRecord_dict}    Create Dictionary    mobilityReason=mobilityReason: snChange (2)    result=result: success (0)
    ...   drxConfigured=.... 0... drxConfigured: False
    ${hoSrcRecord_dict_keys} =    Get Dictionary Keys    ${hoSrcRecord_dict}
    FOR    ${xpath_end_hoSrcRecord}   IN    @{hoSrcRecord_dict_keys}
        ${PCMDRecord_Fields_list}=    wireshark.get_field_value_by_xpath
        ...   xpath=${xpath_head_hoSrcRecord}${xpath_end_hoSrcRecord}   attribute_name=showname
        ${hoSrcRecord_dict_values} =    Get From Dictionary    ${hoSrcRecord_dict}   ${xpath_end_hoSrcRecord}
        Should Contain     ${PCMDRecord_Fields_list}   ${hoSrcRecord_dict_values}
    END

    ${measGap}=    wireshark.get_field_value_by_xpath   xpath=${xpath_head_hoSrcRecord}measGapConfigured   attribute_name=showname

    Load Pcap File with Filter any Expression
    ...   pcap_file=${NSA_INTER_gNB_HO_SOURCE_PATH}
    ...   any_expression=nr-rrc.measGapConfig == 1
    ...   filter=sctp.dstport==38472

    ${measGap_f1ap}    wireshark.get_field_value_by_xpath   xpath=${xpath1}${xpath2}${xpath3}   attribute_name=showname

    Run Keyword If   '${measGap_f1ap}[0]'=='gapPurpose: perUE (0)'   Should Contain   ${measGap}   .... .1.. measGapConfigured: True
    ...   ELSE   Should Contain   ${measGap}   .... .0.. measGapConfigured: False

    run keyword if   '${target_gnb_release}'>'SBTS22R2'   Check ueMeasRecord

Check ueMeasRecord
    Load Pcap File with Filter
     ...                        pcap_file=${NSA_INTER_gNB_HO_SOURCE_PATH}
     ...                        record_type=Cu
     ...                        input_type=3
     ...                        filter=tcp.dstport==49148
    ${xpath_head_ueMeasRecord}   set variable   .//nsetapx.ueMeasRecord/nsetapx.data_element/nsetapx.
    ${ueMeasRecord_dict}    Create Dictionary    carrierFreq=carrierFreq: ${cell_freq}    triggerType=triggerType: a3 (2)
    ...   purpose=purpose: intraFreqHo (0)   measResultNeighCellsNR=measResultNeighCellsNR: 1 item
    ...    measResultNeighCellsNR//nsetapx.MeasResultNR_element/nsetapx.pci=pci: ${targetcell_pci}
    ${ueMeasRecord_dict_keys} =    Get Dictionary Keys    ${ueMeasRecord_dict}
    FOR    ${xpath_end_ueMeasRecord}   IN    @{ueMeasRecord_dict_keys}
        ${PCMDRecord_Fields_list}=    wireshark.get_field_value_by_xpath
        ...   xpath=${xpath_head_ueMeasRecord}${xpath_end_ueMeasRecord}   attribute_name=showname
        ${ueMeasRecord_dict_values} =    Get From Dictionary    ${ueMeasRecord_dict}   ${xpath_end_ueMeasRecord}
        Should Contain     ${PCMDRecord_Fields_list}   ${ueMeasRecord_dict_values}
    END

Case Setup: 5GC000376_CB_22
    Log To Console   Case Setup: 5GC000376_CB_22
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    Read Freqency
    Get Physical Cell ID from Target gnb
    ${file_status}   run keyword and return status   File Should Not Be Empty   ${NSA_INTER_gNB_HO_TARGET_PATH}
    ${HO_status}   run keyword and return status   should not be empty   ${NSA_INTER_target_crnti_HO_list}
    set test variable   ${file_status}
    set test variable   ${HO_status}
    Run Keyword If   '${file_status}'=='False' or '${HO_status}'=='False'   Run Keywords
    ...   Common Setup 1756   AND
    ...   Remove And Add PCMD Object   AND
    ...   Trigger INTER gNB HO   ${NSA_ue_index}    ${NSA_INTER_gNB_HO_TARGET_FILE}   NSA
    run keyword if  '${file_status}'=='False' or '${HO_status}'=='False'   Get Variables from HO File for 5GC000376_CB_22

Get Variables from HO File for 5GC000376_CB_22
    ${NSA_INTER_target_crnti_HO_list}   Get nrcti of HO    ${NSA_INTER_gNB_HO_TARGET_PATH}
    ...   nsetapx.CuVendorExtensionRecordDataType == 9
    set suite variable   ${NSA_INTER_target_crnti_HO_list}

Case Teardown: 5GC000376_CB_22
    Log To Console   Case Teardown: 5GC000376_CB_22
    robot_common_operations.Common Case Teardown
    Check Extra Reset From Blackbox
    Run Keyword If   '${file_status}'=='False' or '${HO_status}'=='False'   Run Keywords
    ...   Initialize PA   AND
    ...   Common Teardown 1756

Read Freqency
    COAM Login   alias=freq
    ${cell_freq}   COAM Get Cell Freq   connection=freq
    set suite variable     ${cell_freq}
    [Teardown]   COAM Logout   connection=freq
