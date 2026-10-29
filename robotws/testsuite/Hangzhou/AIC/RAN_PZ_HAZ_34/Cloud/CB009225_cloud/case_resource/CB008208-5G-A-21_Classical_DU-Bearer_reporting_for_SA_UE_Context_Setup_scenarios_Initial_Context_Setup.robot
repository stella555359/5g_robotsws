*** Settings ***
Documentation
...   Author: liping.hong@nokia-sbell.com

#Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009225_cloud/Common_resource/common_keyword.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Cloud/CB009225_cloud/Common_resource/common_keyword.robot

*** Keyword ***
CB008208-5G-A-21_Classical_DU-Bearer_reporting_for_SA_UE_Context_Setup_scenarios_Initial_Context_Setup
    [Arguments]  ${f1_file_path}=${TCPDUMP_PATH}    ${du_file_path}=${TCPDUMP_PATH}
    log to console     check elemnet  DU-Bearer_reporting_for_SA_UE_Context_Setup
    ${dutype}   set variable   nsetapx.DuVendorExtensionRecordDataType
     Load Pcap File with Filter any Expression
     ...                        pcap_file=${du_file_path}
     ...                          any_expression=${dutype}==1&&nsetapx.result == 0
     ...                        filter=sctp.dstport==${dcap_server_port}
    ${gnb_cu_ue_f1ap_Id_list_m}=    wireshark.get_field_value_by_xpath
    ...   xpath=.//nsetapx.ueCtxSetupRecord/nsetapx.data_r1_element/nsetapx.gnb_cu_ue_f1ap_Id

    ${gnb_cu_ue_f1ap_Id_list}   Remove Duplicates   ${gnb_cu_ue_f1ap_Id_list_m}
    ${crnti_list}=    wireshark.get_field_value_by_xpath   xpath=.//nsetapx.crnti
    ${crnti_single_list}   Remove Duplicates   ${crnti_list}
    ${crnti_single_length}=  Get Length   ${crnti_single_list}
    ${valid_call}   Create List
    set suite variable     ${valid_call}
    FOR   ${idx}    IN RANGE    0   ${crnti_single_length}
        ${Filter_expression_record}   set variable   ${dutype}==13&&nsetapx.trigger==1&&nsetapx.crnti == ${crnti_single_list}[${idx}]
        ${f1apBearear_list}   ${f1ap_beareritems_list}=   Get Bearer List from F1AP    ${f1_file_path}   set   ${gnb_cu_ue_f1ap_Id_list}[${idx}]
        Continue For Loop If    ${f1ap_beareritems_list} == None
        ${DUBearear_list}   ${trigger_list}=   Get Bearer List from DUBearer Record
        ...   ${du_file_path}   ${Filter_expression_record}   ${f1ap_beareritems_list}[0]
        Should Be True   ${trigger_list}[0] == 1
#        Should Be True   ${f1apBearear_list} == ${DUBearear_list}
    END
    List Should Contain Value    ${valid_call}    ${False}
    Log To Console   check value is OK


Case Setup: CB008208-5G-A-21
    Log To Console   Case Setup: CB008208-5G-A-21
#    Common Setup 1756
#    Remove And Add PCMD Object
#
#    Start Tcpdump To Get PCMD   pcmd_file=EA_21.pcap
#    L3CALL Precondition
#    Wait Until Keyword Succeeds   3x   10s   Attach UE BETA
#
#    Sleep   30s
#    Stop Tcpdump To Get PCMD   pcmd_file=EA_21.pcap
#    Detach UE BETA

Case Teardown: CB008208-5G-A-21
    Log To Console   Case Teardown: CB008208-5G-A-21
#    Detach UE BETA
#    Common Teardown 1756
