*** Settings ***
Documentation   This is a keyword file for 5GC000711-A, part wireshark
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Keywords ***

verify wireshark t1
    [Documentation]    [PRIVATE]    verify wireshark for interRAT_HO_from_LTE_to_5G_without_data_forwarding test
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification for 5GC000711_A_Successful_interRAT_HO_from_LTE_to_5G_without_data_forwarding
    verify wireshark handoverRequestAck    wireshark_file=${resultDir}/wireshark.pcap
    verify wireshark handoverNotify        wireshark_file=${resultDir}/wireshark.pcap


verify wireshark t2
    [Documentation]    [PRIVATE]    verify wireshark for Cancellation_of_interRAT_handover_from_LTE test
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification for 5GC000711_A_Cancellation_of_interRAT_handover_from_LTE
    verify wireshark handoverRequestAck     wireshark_file=${resultDir}/wireshark_UE1.pcap
    verify wireshark handoverCancel         wireshark_file=${resultDir}/wireshark_UE1.pcap
    verify wireshark UeContextRel cause cancel        wireshark_file=${resultDir}/wireshark_UE1.pcap


verify wireshark t3
    [Documentation]    [PRIVATE]    verify wireshark for Rejection_of_interRAT_handover_from_LTE test
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification for 5GC000711_A_Rejection_of_interRAT_handover_from_LTE
    verify wireshark handoverFailure       wireshark_file=${resultDir}/wireshark_part2.pcap   cause=radio-resources-not-available
    verify wireshark handoverFailure       wireshark_file=${resultDir}/wireshark_part3.pcap   cause=slice-not-supported
    verify wireshark handoverRequestAck    wireshark_file=${resultDir}/wireshark_part4.pcap
    verify wireshark handoverNotify        wireshark_file=${resultDir}/wireshark_part4.pcap


verify wireshark t4
    [Documentation]    [PRIVATE]    verify wireshark for Abort_of_handover_due_to_expiry_of_supervision_timer test
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification for 5GC000711_A_Abort_of_handover_due_to_expiry_of_supervision_timer
    verify wireshark handoverCancel        wireshark_file=${resultDir}/wireshark_part2.pcap
    verify wireshark handoverRequestAck    wireshark_file=${resultDir}/wireshark_part2.pcap
    verify wireshark no handoverNotify     wireshark_file=${resultDir}/wireshark_part2.pcap


verify wireshark t5
    [Documentation]    [PRIVATE]    verify wireshark for Activation_and_deactivation_of_feature test
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification for 5GC000711_A_Activation_and_deactivation_of_feature_5GC000711
    verify wireshark handoverFailure       wireshark_file=${resultDir}/wireshark_part1.pcap   cause=ho-target-not-allowed
    verify wireshark handoverRequestAck    wireshark_file=${resultDir}/wireshark_part2.pcap
    verify wireshark handoverNotify        wireshark_file=${resultDir}/wireshark_part2.pcap


verify wireshark t6
    [Documentation]    [PRIVATE]    verify wireshark for RRC_Re_Establishment_request_for_IRAT_HO_from_LTE test
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification for 5GC000711_A_RRC_Re_Establishment_request_for_IRAT_HO_from_LTE
    verify wireshark handoverRequestAck    wireshark_file=${resultDir}/wireshark_part1.pcap
    verify wireshark InitialContextSetupReponse        wireshark_file=${resultDir}/wireshark_part1.pcap   number_expected_msgs=2
    verify wireshark InitialContextSetupReponse        wireshark_file=${resultDir}/wireshark_part2.pcap   number_expected_msgs=1


verify wireshark t7
    [Documentation]    [PRIVATE]    verify wireshark for InterRAT_handover_from_LTE_for_voice_over_NR_call test
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification for 5GC000711_A_InterRAT_handover_from_LTE_for_voice_over_NR_call
    verify wireshark handoverRequestAck    wireshark_file=${resultDir}/wireshark.pcap
    verify wireshark handoverNotify        wireshark_file=${resultDir}/wireshark.pcap


verify wireshark t8
    [Documentation]    [PRIVATE]    verify wireshark for InterRAT_handover_from_LTE_with_RFSP_and_mobility_profiles test
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification for 5GC000711_A_InterRAT_handover_from_LTE_with_RFSP_and_mobility_profiles
    Log To Console    verify 1st handover
    verify wireshark handoverRequestAck          wireshark_file=${resultDir}/wireshark_ho1.pcap    source_ip=10.0.1.3
    verify wireshark handoverNotify              wireshark_file=${resultDir}/wireshark_ho1.pcap    source_ip=10.0.1.3
    Log To Console    verify 2nd handover with rfsp
    verify wireshark handoverRequestAck          wireshark_file=${resultDir}/wireshark_ho2.pcap
    verify wireshark handoverNotify              wireshark_file=${resultDir}/wireshark_ho2.pcap
    verify wireshark handoverRequest with rfsp   wireshark_file=${resultDir}/wireshark_ho2.pcap


verify wireshark t9
    [Documentation]    [PRIVATE]    verify wireshark for InterRAT_handover_from_LTE_with_mobility_restriction_list test
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification for 5GC000711_A_InterRAT_handover_from_LTE_with_mobility_restriction_list
    Log To Console    verify 1st handover
    verify wireshark handoverRequestAck          wireshark_file=${resultDir}/wireshark_part1.pcap    source_ip=10.0.1.3
    verify wireshark handoverNotify              wireshark_file=${resultDir}/wireshark_part1.pcap    source_ip=10.0.1.3
    Log To Console    verify handover with mobility restriction list
    verify wireshark handoverRequestAck          wireshark_file=${resultDir}/wireshark_part2.pcap
    verify wireshark handoverNotify              wireshark_file=${resultDir}/wireshark_part2.pcap
    verify wireshark mobilityRestrictionList     wireshark_file=${resultDir}/wireshark_part2.pcap
    Log To Console    verify no handover request because tracking area of cell 49 is not allowed
    verify wireshark no handover request         wireshark_file=${resultDir}/wireshark_part3.pcap


verify wireshark t10
    [Documentation]    [PRIVATE]    verify wireshark for Voice_fallback_via_redirection_after_interRAT_HO_from_LTE test
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification for 5GC000711_A_Voice_fallback_via_redirection_after_interRAT_HO_from_LTE
    verify wireshark handoverRequestAck          wireshark_file=${resultDir}/wireshark_part2.pcap    source_ip=10.0.1.2
    verify wireshark handoverNotify              wireshark_file=${resultDir}/wireshark_part2.pcap    source_ip=10.0.1.2
    verify wireshark voiceFallback               wireshark_file=${resultDir}/wireshark_part2.pcap
    verify wireshark redirection                 wireshark_file=${resultDir}/wireshark_part2.pcap


verify wireshark t11
    [Documentation]    [PRIVATE]    verify wireshark for InterRAT_handover_from_LTE_for_emergency_call test
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification for 5GC000711_A_InterRAT_handover_from_LTE_for_emergency_call
    verify wireshark handoverFailure             wireshark_file=${resultDir}/wireshark_part4.pcap    cause=radio-resources-not-available
    verify wireshark handoverRequestAck          wireshark_file=${resultDir}/wireshark_part4.pcap    source_ip=10.0.1.2
    verify wireshark handoverNotify              wireshark_file=${resultDir}/wireshark_part4.pcap    source_ip=10.0.1.2


verify wireshark t12
    [Documentation]    [PRIVATE]    verify wireshark for DL_NAS_message_transfer_during_IRAT_HO_from_LTE test
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification for 5GC000711_A_DL_NAS_message_transfer_during_IRAT_HO_from_LTE
    verify wireshark handoverRequestAck          wireshark_file=${resultDir}/wireshark_part2.pcap    source_ip=10.0.1.2
    verify wireshark NAS conf update             wireshark_file=${resultDir}/wireshark_part2.pcap
    verify wireshark handoverNotify              wireshark_file=${resultDir}/wireshark_part2.pcap    source_ip=10.0.1.2


verify wireshark t13
    [Documentation]    [PRIVATE]    verify wireshark for PDU_session_setup_release_modification_during_IRAT_HO_from_LTE test
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification for 5GC000711_A_PDU_session_setup_release_modification_during_IRAT_HO_from_LTE
    Log To Console    \nverify PDUSessionResourceSetup in ${resultDir}/wireshark_part1b.pcap
    verify wireshark handoverRequestAck          wireshark_file=${resultDir}/wireshark_part1b.pcap    source_ip=10.0.1.2
    verify wireshark handoverNotify              wireshark_file=${resultDir}/wireshark_part1b.pcap    source_ip=10.0.1.2
    verify wireshark PDU setup                   wireshark_file=${resultDir}/wireshark_part1b.pcap

    Log To Console    \nverify PDUSessionResourceRelease in ${resultDir}/wireshark_part2b.pcap
    verify wireshark handoverRequestAck          wireshark_file=${resultDir}/wireshark_part2b.pcap    source_ip=10.0.1.2
    verify wireshark handoverNotify              wireshark_file=${resultDir}/wireshark_part2b.pcap    source_ip=10.0.1.2
    verify wireshark PDU release                 wireshark_file=${resultDir}/wireshark_part2b.pcap

    Log To Console    \nverify PDUSessionResourceModify in ${resultDir}/wireshark_part3b.pcap
    verify wireshark handoverRequestAck          wireshark_file=${resultDir}/wireshark_part3b.pcap    source_ip=10.0.1.2
    verify wireshark handoverNotify              wireshark_file=${resultDir}/wireshark_part3b.pcap    source_ip=10.0.1.2
    verify wireshark PDU modify                  wireshark_file=${resultDir}/wireshark_part3b.pcap


verify wireshark t14
    [Documentation]    [PRIVATE]    verify wireshark for Successful_location_reporting_at_incoming_IRAT_HO_from LTE test
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification for 5GC000711_A_Successful_location_reporting_at_incoming_IRAT_HO_from LTE
    Log To Console    \nverify Location Report for change-of serving-cell in ${resultDir}/wireshark_part1b.pcap
    verify wireshark handoverRequestAck          wireshark_file=${resultDir}/wireshark_part1b.pcap    source_ip=10.0.1.2
    verify wireshark handoverNotify              wireshark_file=${resultDir}/wireshark_part1b.pcap    source_ip=10.0.1.2
    verify wireshark location report             wireshark_file=${resultDir}/wireshark_part1b.pcap
    ...                                          event_type=change-of-serve-cell (1)                  ue_id=1

    Log To Console    \nverify Location Report for area-of interest in ${resultDir}/wireshark_part2b.pcap
    verify wireshark handoverRequestAck          wireshark_file=${resultDir}/wireshark_part2b.pcap    source_ip=10.0.1.2
    verify wireshark handoverNotify              wireshark_file=${resultDir}/wireshark_part2b.pcap    source_ip=10.0.1.2
    verify wireshark location report             wireshark_file=${resultDir}/wireshark_part2b.pcap
    ...                                          event_type=ue-presence-in-area-of-interest (2)       ue_id=2

    Log To Console    \nverify Location Reporting deactivated in ${resultDir}/wireshark_part3b.pcap
    verify wireshark handoverRequestAck          wireshark_file=${resultDir}/wireshark_part3b.pcap    source_ip=10.0.1.2
    verify wireshark handoverNotify              wireshark_file=${resultDir}/wireshark_part3b.pcap    source_ip=10.0.1.2
    verify wireshark no location report          wireshark_file=${resultDir}/wireshark_part3b.pcap    ue_id=3


verify wireshark t15
    [Documentation]    [PRIVATE]    verify wireshark for UE_capability_retrieval_from_UE_after_IRAT_HO_from_LTE test
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification for 5GC000711_A_UE_capability_retrieval_from_UE_after_IRAT_HO_from_LTE
    verify wireshark handoverRequestAck          wireshark_file=${resultDir}/wireshark_part2.pcap    source_ip=10.0.1.2
    verify wireshark handoverNotify              wireshark_file=${resultDir}/wireshark_part2.pcap    source_ip=10.0.1.2
    verify wireshark UERadioCapability           wireshark_file=${resultDir}/wireshark_part2.pcap

verify wireshark t16
    [Documentation]    [PRIVATE]    verify wireshark for Blind_Scell_addition_after_handover_from_LTE test
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification for 5GC000711_A_Blind_Scell_addition_after_handover_from_LTE
    Log To Console    \nverify UE1 in ${resultDir}/wireshark_part1b.pcap
    verify wireshark handoverRequestAck          wireshark_file=${resultDir}/wireshark_part1b.pcap    source_ip=10.0.1.2
    verify wireshark handoverNotify              wireshark_file=${resultDir}/wireshark_part1b.pcap    source_ip=10.0.1.2
    Log To Console    \nverify UE2 in ${resultDir}/wireshark_part2b.pcap
    verify wireshark handoverRequestAck          wireshark_file=${resultDir}/wireshark_part2b.pcap    source_ip=10.0.1.2
    verify wireshark handoverNotify              wireshark_file=${resultDir}/wireshark_part2b.pcap    source_ip=10.0.1.2


verify wireshark t17
    [Documentation]    [PRIVATE]    verify wireshark for Measurement_based_SCell_addition_after_handover_from_LTE test
    ...       :Autor: Sylvia Schneider
    Log To Console    \nwireshark verification for 5GC000711_A_Measurement_based_SCell_addition_after_handover_from_LTE
    verify wireshark handoverRequestAck          wireshark_file=${resultDir}/wireshark_part2.pcap    source_ip=10.0.1.2
    verify wireshark handoverNotify              wireshark_file=${resultDir}/wireshark_part2.pcap    source_ip=10.0.1.2


