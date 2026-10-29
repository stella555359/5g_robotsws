*** Settings ***
Documentation
...    author: lihong
...    this case will verify keyword for TA of CB009881-CB009225_A_03

#Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009225_cloud/Common_resource/common_keyword.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Cloud/CB009225_cloud/Common_resource/common_keyword.robot



*** Keywords ***
CB007227-SR-E_gNB_Cplan_and_Uplan_PCMD_record_in_scenario_Initial_Context_Setup

    log to console     check elemnet  Cplan_and_Uplan_PCMD_record_in_scenario_Initial_Context_Setup

     Load Pcap File with Filter any Expression
     ...                        pcap_file=${OUTPUT_DIR}/${source_VCU_OAMAGENT_file}
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
     ...                        pcap_file=${OUTPUT_DIR}/${source_VCU_OAMAGENT_file}
     ...                        any_expression=nsetapx.CuUpVendorExtensionRecordDataType == 0
     ...                        filter=sctp.dstport==49148
    ${bearerCtxSetupRecord_result}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.bearerCtxSetupRecord/nsetapx.data_element/nsetapx.result
    ${bearerCtxSetupRecord_gnb_cu_cp_ue_e1ap_Id}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.bearerCtxSetupRecord/nsetapx.data_element/nsetapx.gnb_cu_cp_ue_e1ap_Id
    ${bearerCtxSetupRecord_gnb_cu_up_ue_e1ap_Id}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.bearerCtxSetupRecord/nsetapx.data_element/nsetapx.gnb_cu_up_ue_e1ap_Id
    ${bearerCtxSetupRecord_bearerCtxSetupReqRcvTime}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.bearerCtxSetupRecord/nsetapx.data_element/nsetapx.bearerCtxSetupReqRcvTime_element

    ${bearerCtxSetupRecord_bearerCtxSetupReqRcvTime_s}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.bearerCtxSetupRecord/nsetapx.data_element/nsetapx.bearerCtxSetupReqRcvTime_element/nsetapx.seconds
    ${bearerCtxSetupRecord_bearerCtxSetupReqRcvTime_us}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.bearerCtxSetupRecord/nsetapx.data_element/nsetapx.bearerCtxSetupReqRcvTime_element/nsetapx.useconds
    ${bearerCtxSetupRecord_bearerCtxSetupCmplSndTime}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.bearerCtxSetupRecord/nsetapx.data_element/nsetapx.bearerCtxSetupCmplSndTime_element
    ${bearerCtxSetupRecord_bearerCtxSetupCmplSndTime_s}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.bearerCtxSetupRecord/nsetapx.data_element/nsetapx.bearerCtxSetupCmplSndTime_element/nsetapx.seconds
    ${bearerCtxSetupRecord_bearerCtxSetupCmplSndTime_us}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.bearerCtxSetupRecord/nsetapx.data_element/nsetapx.bearerCtxSetupCmplSndTime_element/nsetapx.useconds

    ${bearerRecord_xpath1}   set variable   .//nsetapx.bearerRecord/nsetapx.data_element/nsetapx.setupBearers//nsetapx.CuUpBearerDataSetupItem
    ${bearerRecord_drb_Id}   wireshark.get_field_value_by_xpath
    ...   xpath=${bearerRecord_xpath1}/nsetapx.ngranBearer_element/nsetapx.drb_Id
    ${bearerRecord_pduSessionId}=    wireshark.get_field_value_by_xpath
    ...    xpath=${bearerRecord_xpath1}/nsetapx.ngranBearer_element/nsetapx.pduSessionId

    ${bearerRecord_trigger}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.bearerRecord/nsetapx.data_element/nsetapx.trigger  attribute_name=showname
    ${bearerRecord_xpath2}   set variable  ${bearerRecord_xpath1}/nsetapx.ngranBearer_element/nsetapx.drbQoS_element
    ${bearerRecord_qosCharacteristics}   wireshark.get_field_value_by_xpath
    ...   xpath=${bearerRecord_xpath2}/nsetapx.qosCharacteristics
    ${bearerRecord_fiveQi}   wireshark.get_field_value_by_xpath
    ...   xpath=${bearerRecord_xpath2}/nsetapx.qosCharacteristics/nsetapx.nonDynamicFiveQiDescriptor_element/nsetapx.fiveQi

    ${bearerRecord_priorityLevel}   wireshark.get_field_value_by_xpath
    ...   xpath=${bearerRecord_xpath2}/nsetapx.arp_element/nsetapx.priorityLevel

    ${bearerRecord_preemptionCapability}   wireshark.get_field_value_by_xpath
    ...   xpath=${bearerRecord_xpath2}/nsetapx.arp_element/nsetapx.preemptionCapability

    ${bearerRecord_preemptionVulnerability}   wireshark.get_field_value_by_xpath
    ...   xpath=${bearerRecord_xpath2}/nsetapx.arp_element/nsetapx.preemptionVulnerability

    ${qfi_path1}   set variable  ${bearerRecord_xpath1}/nsetapx.ngranBearer_element/nsetapx.setupQosFlowsMappedToBearer//

    ${bearerRecord_qfi}   wireshark.get_field_value_by_xpath
    ...   xpath=${qfi_path1}nsetapx.CuUpSetupQosFlowMappedToBearerItem_element/nsetapx.qfi



    ${pduSession_path}   set variable   .//nsetapx.setupPduSessionResources//nsetapx.PduSessionResourceSetupItem_element
    ${pduSession_path1}   set variable   .//nsetapx.CuUpVendorExtensionRecordDataType/nsetapx.pduSessionResourceInfoRecord/nsetapx.data_element
    ${pduSession_path2}   set variable   ${pduSession_path1}/nsetapx.setupPduSessionResources//nsetapx.CuUpPduSessionResourceSetupItem_element
    ${pduSession_trigger}   wireshark.get_field_value_by_xpath
    ...   xpath=${pduSession_path1}/nsetapx.trigger   attribute_name=showname

    ${pduSessionId}   wireshark.get_field_value_by_xpath
    ...   xpath=${pduSession_path2}/nsetapx.pduSessionId

    ${pduSeRe_path}   set variable   ${pduSession_path2}/nsetapx.setupQosFlows//nsetapx.CuUpQosFlowSetupItem_element
#    :FOR   ${item}   IN   @{pduSessionId}
    ${qfi_pduSeRe}   wireshark.get_field_value_by_xpath
    ...   xpath=${pduSeRe_path}/nsetapx.qfi

    ${fiveQi_pduSeRe}   wireshark.get_field_value_by_xpath
    ...   xpath=${pduSeRe_path}/nsetapx.qosParameters_element/nsetapx.qosCharacteristics/nsetapx.nonDynamicFiveQiDescriptor_element/nsetapx.fiveQi

    ${priorityLevel_pduSeRe}   wireshark.get_field_value_by_xpath
    ...   xpath=${pduSeRe_path}/nsetapx.qosParameters_element/nsetapx.arp_element/nsetapx.priorityLevel

    ${preemptionCapability_pduSeRe}   wireshark.get_field_value_by_xpath
    ...   xpath=${pduSeRe_path}/nsetapx.qosParameters_element/nsetapx.arp_element/nsetapx.preemptionCapability

    ${preemptionVulnerability_pduSeRe}   wireshark.get_field_value_by_xpath
    ...   xpath=${pduSeRe_path}/nsetapx.qosParameters_element/nsetapx.arp_element/nsetapx.preemptionVulnerability
#    Should Be True   ${ueCuUpConnectivityRecord_result} == ${bearerCtxSetupRecord_result}
#    Should Be True   ${ueCuUpConnectivityRecord_gnb_cu_cp_ue_e1ap_Id} == ${bearerCtxSetupRecord_gnb_cu_cp_ue_e1ap_Id}
#    Should Be True   ${ueCuUpConnectivityRecord_gnb_cu_up_ue_e1ap_Id} == ${bearerCtxSetupRecord_gnb_cu_up_ue_e1ap_Id}
#    should not be empty   ${ueCuUpConnectivityRecord_cuUpBearerCtxSetupReqSndTime}
#    should not be empty   ${ueCuUpConnectivityRecord_cuUpBearerCtxSetupReqSndTime_s}
#    should not be empty   ${ueCuUpConnectivityRecord_cuUpBearerCtxSetupReqSndTime_us}
#    should not be empty   ${ueCuUpConnectivityRecord_cuUpBearerCtxSetupCmplRcvTime}
#    should not be empty   ${ueCuUpConnectivityRecord_cuUpBearerCtxSetupCmplRcvTime_s}
#    should not be empty   ${ueCuUpConnectivityRecord_cuUpBearerCtxSetupCmplRcvTime_us}
#
#    log to console   check qfi
#    should not be empty   ${bearerRecord_qfi}
#    list should contain sub list  ${bearerRecord_qfi}   ${qfi_pduSeRe}
#
#    log to console   check fiveQi
#    should not be empty   ${bearerRecord_fiveQi}
#    list should contain sub list  ${bearerRecord_fiveQi}   ${fiveQi_pduSeRe}
#
#    log to console   check priorityLevel, preemptionCapability, and preemptionVulnerability
#    should not be empty   ${bearerRecord_priorityLevel}
#    should not be empty   ${bearerRecord_preemptionCapability}
#    should not be empty   ${bearerRecord_preemptionVulnerability}
#    list should contain sub list  ${priorityLevel_pduSeRe}   ${bearerRecord_priorityLevel}
#    list should contain sub list  ${preemptionCapability_pduSeRe}   ${bearerRecord_preemptionCapability}
#    list should contain sub list  ${preemptionVulnerability_pduSeRe}   ${bearerRecord_preemptionVulnerability}
#
#    log to console   check Trigger Reason
#    Should Contain Match   ${bearerRecord_trigger}   regexp=.*setup.*
#    Should Contain Match   ${pduSession_trigger}   regexp=.*pduSessionResourceSetupReq.*
#    Should Contain Match   ${ueCuUpConnectivityRecord_gnb-Id}   regexp=.*${LOCAL_MRBTS_ID}.*
#    ${plman_clear}   Remove String   ${ueCuUpConnectivityRecord_plmn}[0]   :
#    Should Be True   '${plman_clear}' == '${LOCAL_PLMN_IDENTITY}'

Case Setup: CB007227-SR-E_gNB_Cplan_and_Uplan_PCMD_record_in_scenario_Initial_Context_Setup
    Log To Console   CB007227-SR-E_gNB_Cplan_and_Uplan_PCMD_record_in_scenario_Initial_Context_Setup
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

Case Teardown: CB007227-SR-E_gNB_Cplan_and_Uplan_PCMD_record_in_scenario_Initial_Context_Setup
    Log To Console   CB007227-SR-E_gNB_Cplan_and_Uplan_PCMD_record_in_scenario_Initial_Context_Setup
#    Detach UE BETA
#    Common Teardown 1756
