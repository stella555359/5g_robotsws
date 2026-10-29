*** Settings ***
Documentation
...    author: lihong
...    this case will verify keyword for TA of CB007227-SR-A_RAN_UE_ID_Sent_by_gNB-CU-UP_during_SgNB_Addition_NSA_and_initial_access_SA

#Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009225_cloud/Common_resource/common_keyword.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Cloud/CB009225_cloud/Common_resource/common_keyword.robot

*** Variables ***


*** Keywords ***
CB007227-SR-A_RAN_UE_ID_Sent_by_gNB-CU-UP_during_SgNB_Addition_NSA_or_initial_access_SA
    [Arguments]   ${cu_pcmd_file}
    log to console     check elemnet  CB007227-SR-A_RAN_UE_ID_Sent_by_gNB-CU-UP_during_SgNB_Addition_NSA_or_initial_access_SA

     Load Pcap File with Filter any Expression
     ...                        pcap_file=${OUTPUT_DIR}/${cu_pcmd_file}
     ...                        any_expression=nsetapx.CuUpVendorExtensionRecordDataType == 0
     ...                        filter=sctp.dstport==49148

    ${gnb-cu-cp-ue-e1ap-Id_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.bearerCtxSetupRecord/nsetapx.data_element/nsetapx.gnb_cu_cp_ue_e1ap_Id

     Load Pcap File with Filter any Expression
     ...                        pcap_file=${OUTPUT_DIR}/${cu_pcmd_file}
     ...                        any_expression=nsetapx.gnb_cu_up_Id == 0
     ...                        filter=sctp.dstport==49148
    ${ranUeId_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.ranUeId
    ${ranUeId_List}   Remove Duplicates   ${ranUeId_List}
    ${ranUeId_Number}   Create List
    FOR   ${ranUeId}   IN   @{ranUeId_List}
        ${ranUeId}   Replace String   ${ranUeId}   :   ${SPACE}
        ${ranUeId}   Convert To Integer   ${ranUeId}   16
        ${ranUeId}   Convert To String   ${ranUeId}
        Append To List   ${ranUeId_Number}   ${ranUeId}
    END
#    Should Be True   ${gnb-cu-cp-ue-e1ap-Id_list} == ${ranUeId_Number}




Case Setup: CB009881-CB009225_A_03
    Log To Console   Case Setup: CB009881-CB009225_A_03
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

Case Teardown: CB009881-CB009225_A_03
    Log To Console   Case Teardown: CB009881-CB009225_A_03
#    Detach UE BETA
#    Common Teardown 1756

