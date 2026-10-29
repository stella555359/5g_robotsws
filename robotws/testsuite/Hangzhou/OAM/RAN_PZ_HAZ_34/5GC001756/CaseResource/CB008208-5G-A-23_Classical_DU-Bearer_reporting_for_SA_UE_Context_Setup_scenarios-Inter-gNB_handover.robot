*** Settings ***
Documentation
...   Author: liping.hong@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
CB008208-5G-A-23_Classical_DU-Bearer_reporting_for_SA_UE_Context_Setup_scenarios-Inter-gNB_handover
    log to console     check elemnet  DU-Bearer_reporting_for_SA_UE_Context_Setup_scenarios-Inter-gNB_handover
    ${SA_INTER_crnti_HO_length}=  Get Length   ${SA_INTER_crnti_HO_list}
    ${dutype}   set variable   nsetapx.DuVendorExtensionRecordDataType

    FOR   ${idx}    IN RANGE    0   ${SA_INTER_crnti_HO_length}
         Load Pcap File with Filter any Expression
         ...                        pcap_file=${SA_INTER_gNB_HO_TARGET_PATH}
         ...                          any_expression=${dutype}==1
         ...                        filter=sctp.dstport==${dcap_server_port}
        ${gnb_cu_ue_f1ap_Id_list_m}=    wireshark.get_field_value_by_xpath
        ...   xpath=.//nsetapx.ueCtxSetupRecord/nsetapx.data_r1_element/nsetapx.gnb_cu_ue_f1ap_Id
        ${gnb_cu_ue_f1ap_Id_list}   Remove Duplicates   ${gnb_cu_ue_f1ap_Id_list_m}
        ${Filter_expression_record}   set variable   ${dutype}==13&&nsetapx.crnti==${SA_INTER_crnti_HO_list}[${idx}]
        ${f1apBearear_list}=   Get Bearer List from F1AP    ${SA_INTER_gNB_HO_TARGET_PATH}   set   ${gnb_cu_ue_f1ap_Id_list}[0]
        ${DUBearear_list}   ${trigger_list}=   Get Bearer List from DUBearer Record
        ...   ${SA_INTER_gNB_HO_TARGET_PATH}   ${Filter_expression_record}   2
        Should Be True   ${trigger_list}[0] == 1
        Should Be True   ${f1apBearear_list} == ${DUBearear_list}
    END

    Log To Console   check value is OK



Case Setup: CB008208-5G-A-23
    Log To Console   Case Setup: CB008208-5G-A-23
    ${file_status}   run keyword and return status   File Should Not Be Empty   ${SA_INTER_gNB_HO_TARGET_PATH}
    ${HO_status}   run keyword and return status   should not be empty   ${SA_INTER_gNB_HO_TARGET_PATH}
    set test variable   ${file_status}
    set test variable   ${HO_status}
    Run Keyword If   '${file_status}'=='False' or '${HO_status}'=='False'   Run Keywords
    ...   Common Setup 1756   AND
    ...   Remove And Add PCMD Object   AND
    ...   Trigger INTER gNB HO   ${SA_ue_index}    ${SA_INTER_gNB_HO_TARGET_FILE}   SA
    ${SA_INTER_crnti_HO_list}   ${SA_INTER_crnti_HO_length}   run keyword if  '${file_status}'=='False' or '${HO_status}'=='False'
    ...   Get nrcti of HO    ${SA_INTER_gNB_HO_TARGET_PATH}
    ...   nsetapx.CuVendorExtensionRecordDataType==14 && nsetapx.trigger==2
    run keyword if  '${file_status}'=='False' or '${HO_status}'=='False'   Run Keywords   set suite variable   ${SA_INTER_crnti_HO_list}
    ...   AND   set suite variable   ${SA_INTER_crnti_HO_length}

Case Teardown: CB008208-5G-A-23
    Log To Console   Case Teardown: CB008208-5G-A-23
    Run Keyword If   '${file_status}'=='False' or '${HO_status}'=='False'   Run Keywords
    ...   Initialize PA   AND
    ...   Common Teardown 1756
