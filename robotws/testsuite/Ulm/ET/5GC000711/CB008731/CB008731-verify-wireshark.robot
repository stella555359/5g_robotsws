*** Settings ***
Documentation   This is a keyword file for CB008731, part wireshark verification
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
*** Variables ***

${filter_HoFailure_radio-resources-not-available}    (ngap.procedureCode==13)&&(ngap.radioNetwork==22)
${filter_hoReqAck_qosFlowFailedToSetupList}       (ngap.procedureCode==13)&&(ngap.NGAP_PDU==1)&&(ngap.qosFlowIdentifier==3)&&(ngap.radioNetwork==22)
${filter_UeContRelReq_preEmption}                 (ngap.procedureCode==42)&&(ngap.radioNetwork==46)
${filter_Ho_ReqAck}                               (ngap.procedureCode==13)&&(ngap.NGAP_PDU==1)

*** Keywords ***

Verify Wireshark 8731 t1
    [Documentation]    [PRIVATE]    Verify Wireshark for InterRAT_handover_from_LTE_with_ROHC_for_VoNR_call
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification for CB008731 InterRAT_handover_from_LTE_with_ROHC_for_VoNR_call
    Verify Wireshark handoverRequestAck    wireshark_file=${resultDir}/wireshark_part2.pcap
    Verify Wireshark handoverNotify        wireshark_file=${resultDir}/wireshark_part2.pcap


Verify Wireshark 8731 t2
    [Documentation]    [PRIVATE]    Verify Wireshark for Partial_admission_control_for_interRAT_handover_from_LTE
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification for CB008731_Partial_admission_control_for_interRAT_handover_from_LTE
    Verify Wireshark HandoverFailure radio-resources-not-available             wireshark_file=${resultDir}/wireshark_part2.pcap
    Verify Wireshark HandoverRequestAcknowledge qosFlowFailedToSetupList       wireshark_file=${resultDir}/wireshark_part3.pcap
    Verify Wireshark handoverNotify                                            wireshark_file=${resultDir}/wireshark_part3.pcap


Verify Wireshark 8731 t3
    [Documentation]    [PRIVATE]    Verify Wireshark for ARP_based_preemption_for_interRAT_HO_from_LTE
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification for CB008731_ARP_based_preemption_for_interRAT_HO_from_LTE
    Verify Wireshark UE Context Release Request Pre-emption         wireshark_file=${resultDir}/wireshark_part3.pcap
    Verify Wireshark handoverRequestAck                             wireshark_file=${resultDir}/wireshark_part3.pcap
    Verify Wireshark handoverNotify                                 wireshark_file=${resultDir}/wireshark_part3.pcap


Verify Wireshark 8731 t4
    [Documentation]    [PRIVATE]    Verify Wireshark for InterRAT_handover_from_LTE_with_high_priority_access
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification for CB008731_InterRAT_handover_from_LTE_with_high_priority_access
    Verify Wireshark HandoverFailure radio-resources-not-available        wireshark_file=${resultDir}/wireshark_part4.pcap
    Verify Wireshark handoverRequestAck                                   wireshark_file=${resultDir}/wireshark_part4.pcap
    Verify Wireshark handoverNotify                                       wireshark_file=${resultDir}/wireshark_part4.pcap


Verify Wireshark 8731 t5
    [Documentation]    [PRIVATE]    Verify Wireshark for InterRAT_handover_from_LTE_with_GBR_services_for_non_voice_bearer
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification for CB008731_InterRAT_handover_from_LTE_with_GBR_services_for_non_voice_bearer
    Log To Console    verification UE1
    Verify Wireshark handoverRequestAck                                   wireshark_file=${resultDir}/wireshark_part3.pcap
    Verify Wireshark handoverNotify                                       wireshark_file=${resultDir}/wireshark_part3.pcap
    Log To Console    verification UE2
    Verify Wireshark handoverRequestAck                                   wireshark_file=${resultDir}/wireshark_part4.pcap
    Verify Wireshark handoverNotify                                       wireshark_file=${resultDir}/wireshark_part4.pcap


Verify Wireshark 8731 t6
    [Documentation]    [PRIVATE]    Verify Wireshark for A1_based_traffic_steering_to_preferred_NR_layer_after_IRAT_HO_from_LTE
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification for CB008731_A1_based_traffic_steering_to_preferred_NR_layer_after_IRAT_HO_from_LTE
    Verify Wireshark handoverRequestAck                                   wireshark_file=${resultDir}/wireshark_part2.pcap
    Verify Wireshark handoverNotify                                       wireshark_file=${resultDir}/wireshark_part2.pcap


Verify Wireshark 8731 t7
    [Documentation]    [PRIVATE]    Verify Wireshark for Periodic_A4_based_mobility_after_interRAT_HO_from_LTE
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification for CB008731_Periodic_A4_based_mobility_after_interRAT_HO_from_LTE
    Verify Wireshark handoverRequestAck                                   wireshark_file=${resultDir}/wireshark_part2.pcap
    Verify Wireshark handoverNotify                                       wireshark_file=${resultDir}/wireshark_part2.pcap


Verify Wireshark HandoverRequestAcknowledge qosFlowFailedToSetupList
    [Documentation]    [PRIVATE]    verify HandoverRequestAcknowledge qosFlowFailedToSetupList in wireshark
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_file}
    Log To Console    verify message 1 HandoverRequestAcknowledge (ngap.procedureCode==13)&&(ngap.NGAP_PDU==1) with
    Log To Console    -- qosFlowFailedToSetupList (qosFlowIdentifier==3)
    Log To Console    -- radio-resources-not-available (radioNetwork==22)
    ${msg}     Run     tshark -r ${wireshark_file} -Y "${filter_hoReqAck_qosFlowFailedToSetupList}" | wc -l
    Run Keyword And Continue On Failure   Should Be True    ${msg}==${1}
    ...     Wrong number of messages


Verify Wireshark UE Context Release Request Pre-emption
    [Documentation]    [PRIVATE]    verify UE context release request pre-emption in wireshark
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_file}
    Log To Console    verify message 1 UE context release request (ngap.procedureCode==42) with
    Log To Console    -- release-due-to-premption (ngap.radioNetwork==46)
    ${msg}     Run     tshark -r ${wireshark_file} -Y "${filter_UeContRelReq_preEmption}" | wc -l
    Run Keyword And Continue On Failure   Should Be True    ${msg}==${1}
    ...     Wrong number of messages


Verify Wireshark HandoverFailure radio-resources-not-available
    [Documentation]    [PRIVATE]    verify HandoverCommand radio-resources-not-available in wireshark
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${wireshark_file}
    Log To Console    verify message 1 HandoverCommand (ngap.procedureCode==12) with release-due-to-premption (ngap.radioNetwork==22)
    ${msg}     Run     tshark -r ${wireshark_file} -Y "${filter_HoFailure_radio-resources-not-available}" | wc -l
    Run Keyword And Continue On Failure   Should Be True    ${msg}==${1}
    ...     Wrong number of messages


Verify Wireshark 8731 force HO
    [Documentation]    [PRIVATE]    Verify Wireshark for 03775066_Force_LTE_to_5G_handover_for_UE_with_insufficient_UE_Capability
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification for CB008731_03775066_Force_LTE_to_5G_handover_for_UE_with_insufficient_UE_Capability
    Verify Wireshark HandoverFailure radio-resources-not-available          wireshark_file=${resultDir}/wireshark_force_HO.pcap
    Verify Wireshark handoverRequestAck                                     wireshark_file=${resultDir}/wireshark_force_HO.pcap
    Verify Wireshark handoverNotify                                         wireshark_file=${resultDir}/wireshark_force_HO.pcap
    Verify Wireshark UERadioCapability                                      wireshark_file=${resultDir}/wireshark_force_HO.pcap



Verify Wireshark 8731 force HO TMO
    [Documentation]    [PRIVATE]    Verify Wireshark for 03775066_Force_LTE_to_5G_handover_for_UE_with_insufficient_UE_Capability
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification for CB008731_03775066_Force_LTE_to_5G_handover_for_UE_with_insufficient_UE_Capability
    Verify Wireshark HandoverFailure radio-resources-not-available          wireshark_file=${resultDir}/wireshark_81_ho_enb2_cell4_failure.pcap
    Verify Wireshark handoverRequestAck                                     wireshark_file=${resultDir}/wireshark_81_ho_enb2_cell4.pcap
    Verify Wireshark handoverNotify                                         wireshark_file=${resultDir}/wireshark_81_ho_enb2_cell4.pcap
    Verify Wireshark UERadioCapability                                      wireshark_file=${resultDir}/wireshark_81_ho_enb2_cell4.pcap
