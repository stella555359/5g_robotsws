*** Settings ***
Documentation
...    author: lihong
...    this case will verify keyword for TA ofCB007227-SR-E_gNB_Cplan_record_in_scenario_Intra-gNB_Intra_DU_handover_SA

#Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009225_cloud/Common_resource/common_keyword.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Cloud/CB009225_cloud/Common_resource/common_keyword.robot

*** Variables ***


*** Keywords ***
CB007227-SR-E_gNB_Cplan_record_in_scenario_Intra-gNB_Intra_DU_handover_SA

    log to console     check elemnet  CuVendorExtensionRecordDataType: ueCuUpConnectivityRecord (23) during Intra-gNB_Inter_DU_handover_SA

     Load Pcap File with Filter any Expression
     ...                        pcap_file=${OUTPUT_DIR}/${SA_InterDU_HO_VCU_OAMAGENT_file}
     ...                        any_expression=nsetapx.CuVendorExtensionRecordDataType == 17
     ...                        filter=sctp.dstport==49148
    ${intragNBHoTgtRecord_reportcell}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.cellId/nsetapx.nrcgi_element/nsetapx.cellIdentity   attribute_name=showname
    ${intragNBHoTgtRecord_result}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.intragNBHoTgtRecord/nsetapx.data_element/nsetapx.result   attribute_name=showname
    Should Contain Match   ${intragNBHoTgtRecord_reportcell}   regexp=.*${LOCAL_NRCELLID_2NDCELL}.*
    Should Contain Match   ${intragNBHoTgtRecord_result}   regexp=.*success.*

     Load Pcap File with Filter any Expression
     ...                        pcap_file=${OUTPUT_DIR}/${SA_InterDU_HO_VCU_OAMAGENT_file}
     ...                        any_expression=nsetapx.CuVendorExtensionRecordDataType == 23
     ...                        filter=sctp.dstport==49148

    ${ueCuUpConnectivityRecord_result}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.CuUpBearerCtxSetupData_element/nsetapx.cuUpBearerCtxSetupResult
    ${ueCuUpConnectivityRecord_gnb_cu_up_Ids}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.CuUpBearerCtxSetupData_element/nsetapx.gnb_cu_up_Ids_element
    ${ueCuUpConnectivityRecord_gnb_cu_up_Id}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.CuUpBearerCtxSetupData_element/nsetapx.gnb_cu_up_Ids_element/nsetapx.gnb_cu_up_Id
    ${ueCuUpConnectivityRecord_gnb-Id1}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.CuUpBearerCtxSetupData_element/nsetapx.gnb_cu_up_Ids_element/nsetapx.gnb_Id_element
    ${ueCuUpConnectivityRecord_plmn}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.CuUpBearerCtxSetupData_element/nsetapx.gnb_cu_up_Ids_element/nsetapx.gnb_Id_element/nsetapx.plmn_Identity
    ${ueCuUpConnectivityRecord_gnb-Id2}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.CuUpBearerCtxSetupData_element/nsetapx.gnb_cu_up_Ids_element/nsetapx.gnb_Id_element/nsetapx.gnb_Id
    ${ueCuUpConnectivityRecord_gnb-Id}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.CuUpBearerCtxSetupData_element/nsetapx.gnb_cu_up_Ids_element/nsetapx.gnb_Id_element/nsetapx.gnb_Id/nsetapx.gnb_id
    ...   attribute_name=showname
    ${ueCuUpConnectivityRecord_gnb_cu_cp_ue_e1ap_Id}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.CuUpBearerCtxSetupData_element/nsetapx.gnb_cu_cp_ue_e1ap_Id
    ${ueCuUpConnectivityRecord_gnb_cu_up_ue_e1ap_Id}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.CuUpBearerCtxSetupData_element/nsetapx.gnb_cu_up_ue_e1ap_Id
    ${ueCuUpConnectivityRecord_cuUpBearerCtxSetupReqSndTime}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.CuUpBearerCtxSetupData_element/nsetapx.cuUpBearerCtxSetupReqSndTime_element
    ${ueCuUpConnectivityRecord_cuUpBearerCtxSetupReqSndTime_s}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.CuUpBearerCtxSetupData_element/nsetapx.cuUpBearerCtxSetupReqSndTime_element/nsetapx.seconds
    ${ueCuUpConnectivityRecord_cuUpBearerCtxSetupReqSndTime_us}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.CuUpBearerCtxSetupData_element/nsetapx.cuUpBearerCtxSetupReqSndTime_element/nsetapx.useconds
    ${ueCuUpConnectivityRecord_cuUpBearerCtxSetupCmplRcvTime}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.CuUpBearerCtxSetupData_element/nsetapx.cuUpBearerCtxSetupCmplRcvTime_element
    ${ueCuUpConnectivityRecord_cuUpBearerCtxSetupCmplRcvTime_s}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.CuUpBearerCtxSetupData_element/nsetapx.cuUpBearerCtxSetupCmplRcvTime_element/nsetapx.seconds
    ${ueCuUpConnectivityRecord_cuUpBearerCtxSetupCmplRcvTime_us}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.CuUpBearerCtxSetupData_element/nsetapx.cuUpBearerCtxSetupCmplRcvTime_element/nsetapx.useconds

     Load Pcap File with Filter any Expression
     ...                        pcap_file=${OUTPUT_DIR}/${SA_InterDU_HO_VCU_OAMAGENT_file}
     ...                        any_expression=nsetapx.CuVendorExtensionRecordDataType == 23&&nsetapx.cellIdentity == 00:0d:bc:00:20
     ...                        filter=sctp.dstport==49148

    ${CuUpCR_result}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.CuUpBearerCtxSetupData_element/nsetapx.cuUpBearerCtxSetupResult
    ${CuUpCR_gnb_cu_up_Ids}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.CuUpBearerCtxSetupData_element/nsetapx.gnb_cu_up_Ids_element
    ${CuUpCR_gnb_cu_up_Id}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.CuUpBearerCtxSetupData_element/nsetapx.gnb_cu_up_Ids_element/nsetapx.gnb_cu_up_Id
    ${CuUpCR_gnb-Id1}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.CuUpBearerCtxSetupData_element/nsetapx.gnb_cu_up_Ids_element/nsetapx.gnb_Id_element
    ${CuUpCR_plmn}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.CuUpBearerCtxSetupData_element/nsetapx.gnb_cu_up_Ids_element/nsetapx.gnb_Id_element/nsetapx.plmn_Identity
    ${CuUpCR_gnb-Id2}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.CuUpBearerCtxSetupData_element/nsetapx.gnb_cu_up_Ids_element/nsetapx.gnb_Id_element/nsetapx.gnb_Id
    ${CuUpCR_gnb-Id}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.CuUpBearerCtxSetupData_element/nsetapx.gnb_cu_up_Ids_element/nsetapx.gnb_Id_element/nsetapx.gnb_Id/nsetapx.gnb_id
    ...   attribute_name=showname
    ${CuUpCR_gnb_cu_cp_ue_e1ap_Id}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.CuUpBearerCtxSetupData_element/nsetapx.gnb_cu_cp_ue_e1ap_Id
    ${CuUpCR_gnb_cu_up_ue_e1ap_Id}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.CuUpBearerCtxSetupData_element/nsetapx.gnb_cu_up_ue_e1ap_Id
    ${CuUpCR_cuUpBearerCtxSetupReqSndTime}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.CuUpBearerCtxSetupData_element/nsetapx.cuUpBearerCtxSetupReqSndTime_element
    ${CuUpCR_cuUpBearerCtxSetupReqSndTime_s}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.CuUpBearerCtxSetupData_element/nsetapx.cuUpBearerCtxSetupReqSndTime_element/nsetapx.seconds
    ${CuUpCR_cuUpBearerCtxSetupReqSndTime_us}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.CuUpBearerCtxSetupData_element/nsetapx.cuUpBearerCtxSetupReqSndTime_element/nsetapx.useconds
    ${CuUpCR_cuUpBearerCtxSetupCmplRcvTime}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.CuUpBearerCtxSetupData_element/nsetapx.cuUpBearerCtxSetupCmplRcvTime_element
    ${CuUpCR_cuUpBearerCtxSetupCmplRcvTime_s}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.CuUpBearerCtxSetupData_element/nsetapx.cuUpBearerCtxSetupCmplRcvTime_element/nsetapx.seconds
    ${CuUpCR_cuUpBearerCtxSetupCmplRcvTime_us}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.CuUpBearerCtxSetupData_element/nsetapx.cuUpBearerCtxSetupCmplRcvTime_element/nsetapx.useconds


    list should contain sub list  ${ueCuUpConnectivityRecord_result}   ${CuUpCR_result}
    list should contain sub list  ${ueCuUpConnectivityRecord_gnb_cu_cp_ue_e1ap_Id}   ${CuUpCR_gnb_cu_cp_ue_e1ap_Id}
    list should contain sub list  ${ueCuUpConnectivityRecord_gnb_cu_up_ue_e1ap_Id}   ${CuUpCR_gnb_cu_up_ue_e1ap_Id}
    Should Contain X Times       ${ueCuUpConnectivityRecord_result}   0   2
    Should Contain Match   ${CuUpCR_gnb-Id}   regexp=.*${LOCAL_MRBTS_ID}.*
    ${plman_clear}   Remove String   ${CuUpCR_plmn}[0]   :
    Should Be True   '${plman_clear}' == '${LOCAL_PLMN_IDENTITY}'
    Should Be Empty   ${CuUpCR_cuUpBearerCtxSetupReqSndTime}
    Should Be Empty   ${CuUpCR_cuUpBearerCtxSetupReqSndTime}
    Should Be Empty   ${CuUpCR_cuUpBearerCtxSetupReqSndTime}
    Should Be Empty   ${CuUpCR_cuUpBearerCtxSetupCmplRcvTime}
    Should Be Empty   ${CuUpCR_cuUpBearerCtxSetupCmplRcvTime_s}
    Should Be Empty   ${CuUpCR_cuUpBearerCtxSetupCmplRcvTime_us}
Case Setup: CB007227-SR-E_gNB_Cplan_record_in_scenario_Intra-gNB_Intra_DU_handover_SA
    Log To Console   Case Setup: CB007227-SR-E_gNB_Cplan_record_in_scenario_Intra-gNB_Intra_DU_handover_SA
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

Case Teardown: CB007227-SR-E_gNB_Cplan_record_in_scenario_Intra-gNB_Intra_DU_handover_SA
    Log To Console   CB007227-SR-E_gNB_Cplan_record_in_scenario_Intra-gNB_Intra_DU_handover_SA
#    Detach UE BETA
#    Common Teardown 1756
