*** Settings ***
Documentation    :copyright: Nokia
...             :authors: I_MN_RAN_RD_VRF_WRO2_6
...             :contact: I_MN_RAN_RD_VRF_WRO2_6

Resource    suffix.robot
*** Keywords ***
Verify that UECtxModReq_${n:\d+} out of ${all:\d+} was send to stop UL and DL DRB data transmission for gNB${gnb_id:\d+} for SN
    Verify in UECtxModReq_${n} out of ${all} that TransmissionActionIndicator is set to stop
    Log To Console    Verify that UECtxModReq_${n} out of ${all} was send to stop UL and DL DRB data transmission for gNB${gnb_id} for SN

Verify that UECtxModResp_${n:\d+} out of ${all:\d+} was send to suspend data transmission over SCG leg for gNB2 for SN
    Verify in UECtxModResp_${n} out of ${all} that GNB-CU-UE-F1AP-ID and GNB-DU-UE-F1AP-ID are present
`   Log To Console    Verify that UECtxModResp_${n} out of ${all} was send to suspend data transmission over SCG leg for gNB2 for SN

Verify that UECtxModReq_${n:\d+} out of ${all:\d+} was send with adjustment of MCG configuration upon SCG release for the UE${ue_id:\d+} for MN
    Verify in UECtxModReq_${n} out of ${all} that SCGIndicator IE set to released
    Log To Console    Verify that UECtxModReq_${n} out of ${all} was send with adjustment of MCG configuration upon SCG release for the UE${ue_id}

Verify that UECtxModResp_${n:\d+} out of ${all:\d+} was send with confirming modification of MCG for the UE${ue_id:\d+} for MN
    Verify in UECtxModResp_1 out of ${all} that CellGroupConfig contains cellGroupId
    Verify in UECtxModResp_1 out of ${all} that CellGroupConfig contains spCellConfigDedicated with exactly 3 elements
    Verify in UECtxModResp_1 out of ${all} that CellGroupConfig contains uplinkBWP-ToAddModList
    Verify in UECtxModResp_1 out of ${all} that CellGroupConfig contains bwp-Id
    Verify in UECtxModResp_1 out of ${all} that CellGroupConfig contains bwp-Dedicated
    Verify in UECtxModResp_1 out of ${all} that firstActiveUplinkBWP-Id is not present
    Verify in UECtxModResp_1 out of ${all} that CellGroupConfig contains pusch-ServingCellConfig
    Verify in UECtxModResp_1 out of ${all} that CellGroupConfig contains pdsch-ServingCellConfig
    Verify in UECtxModResp_1 out of ${all} that CellGroupConfig contains tag-Id
    Log To Console    Verify that UECtxModResp_${n} out of ${all} was send with confirming modification of MCG for the UE${ue_id} for MN

Verify that UECtxModResp_${n:\d+} out of ${a:\d+} was sent with modification of MCG for the UE${u:\d+} for MN with aperCSI and ${bO:\S+} betaOffsets
    Verify in UECtxModResp_1 out of ${a} that CellGroupConfig contains cellGroupId
    Verify in UECtxModResp_1 out of ${a} that CellGroupConfig contains spCellConfigDedicated with at least 4 elements
    Verify in UECtxModResp_1 out of ${a} that CellGroupConfig contains uplinkBWP-ToAddModList
    Verify in UECtxModResp_1 out of ${a} that CellGroupConfig contains bwp-Id
    Verify in UECtxModResp_1 out of ${a} that CellGroupConfig contains bwp-Dedicated
    Verify in UECtxModResp_1 out of ${a} that CellGroupConfig contains ${bO} betaOffsets
    Verify in UECtxModResp_1 out of ${a} ${bO} betaOffsets are configured and their values are correct
    Verify in UECtxModResp_1 out of ${a} that firstActiveUplinkBWP-Id is not present
    Verify in UECtxModResp_1 out of ${a} that CellGroupConfig contains pusch-ServingCellConfig
    Verify in UECtxModResp_1 out of ${a} that CellGroupConfig contains pdsch-ServingCellConfig
    Verify in UECtxModResp_1 out of ${a} that CellGroupConfig contains tag-Id
    Verify in UECtxModResp_1 out of ${a} that CellGroupConfig contains reportTriggerSize eq 1
    Verify in UECtxModResp_1 out of ${a} that CellGroupConfig contains aperiodicTriggerStateList
    Verify in UECtxModResp_1 out of ${a} that CellGroupConfig contains csi-ReportConfigToAddModList with reportConfigID eq 1
    Log To Console   Verify that UECtxModResp_${n} out of ${a} was sent with modification of MCG for the UE${u} for MN with aperCSI and betaOffsets

Verify that UECtxModReq_${n:\d+} out of ${all:\d+} was send with request to provide full MCG configuration for gNB${gnb_id:\d+} for MN
    Verify in UECtxModReq_${n} out of ${all} that RRCReconfigurationCompleteIndicator is set to true
    Verify in UECtxModReq_${n} out of ${all} that GNB-DUConfigurationQuery is set to true
    Log To Console    Verify that UECtxModReq_${n} out of ${all} was send with request to provide full MCG configuration for gNB${gnb_id} for MN

Verify that UECtxModResp_${n:\d+} out of ${all:\d+} was send with confirmation of MCG reconfiguration for gNB${gnb_id:\d+} for MN
    Verify in UECtxModResp_2 out of ${all} that CellGroupConfig contains cellGroupId
    Verify in UECtxModResp_2 out of ${all} that CellGroupConfig contains uplinkBWP-ToAddModList
    Verify in UECtxModResp_2 out of ${all} that CellGroupConfig contains bwp-Id
    Verify in UECtxModResp_2 out of ${all} that CellGroupConfig contains bwp-Dedicated
    Verify in UECtxModResp_1 out of ${all} that firstActiveUplinkBWP-Id is set to 1
    Verify in UECtxModResp_2 out of ${all} that CellGroupConfig contains pusch-ServingCellConfig
    Verify in UECtxModResp_2 out of ${all} that CellGroupConfig contains pdsch-ServingCellConfig
    Verify in UECtxModResp_2 out of ${all} that CellGroupConfig contains tag-Id
    Log To Console    Verify that UECtxModResp_${n} out of ${all} was send with confirmation of MCG reconfiguration for gNB${gnb_id} for MN

Verify that UECtxModReq_${n:\d+} out of ${all:\d+} was completed with BandCombinationIndex=${b:\d+}, allowedFeatureSetsList=${s:\d+} for gNB${id:\d+}
    Verify in UECtxModReq_${n} out of ${all} that ue-CapabilityInfo is present for gNB${id}
    Verify in UECtxModReq_${n} out of ${all} that BandCombinationIndex eq ${b} and allowedFeatureSetsList eq ${s} for gNB${id}

Verify that UECtxModResp_${msg_num:\d+} out of ${all:\d+} that ${mimo_ul:\d+} MIMO in UL and ${mimo_dl:\d+} MIMO in DL for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     (pusch-ServingCellConfig contains (maxMIMO-Layers eq ${mimo_ul}))
    ...     and
    ...     (pdsch-ServingCellConfig contains (maxMIMO-Layers eq ${mimo_dl}))
    ...     message_alias=UEContextModificationResponse_${msg_num}
    ...     flow_alias=${flow_alias}

Verify that UECtxModResp_${msg_num:\d+} out of ${all:\d+} was completed succesfully for gNB${gnb_id:\d+} for aperCSI and ${bO:\S+} betaOffsets
    Verify that UECtxModResp_${msg_num} out of ${all} that 2 MIMO in UL and 2 MIMO in DL for gNB${gnb_id}
    Verify in UECtxModResp_${msg_num} out of ${all} that CellGroupConfig contains cellGroupId eq 0 for gNB${gnb_id}
    Verify in UECtxModResp_${msg_num} out of ${all} that CellGroupConfig contains ${bO} betaOffsets when NR-DC is established for gNB${gnb_id}
    Verify in UECtxModResp_${msg_num} out of ${all} that ${bO} betaOffsets are configured and their values are correct for gNB${gnb_id}
    Verify in UECtxModResp_${msg_num} out of ${all} that CellGroupConfig contains reportTriggerSize set to 0 for gNB${gnb_id}
    Verify in UECtxModResp_${msg_num} out of ${all} that CellGroupConfig contains csi-ReportConfigToReleaseList for gNB${gnb_id}
    Verify in UECtxModResp_${msg_num} out of ${all} that CellGroupConfig contains aperiodicTriggerStateList set to release for gNB${gnb_id}

Verify in UECtxModResp_${msg_num:\d+} out of ${all:\d+} that CellGroupConfig contains cellGroupId eq 0 for gNB${g:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${g}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     cellGroupId eq 0
    ...     message_alias=UEContextModificationResponse_${msg_num}
    ...     flow_alias=${flow_alias}

Verify in UECtxModResp_${msg_num:\d+} out of ${all:\d+} that CellGroupConfig contains ${bO:\S+} betaOffsets when NR-DC is established for gNB${g:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${g}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     uci-OnPUSCH contains (betaOffsets is present and ${bO} is present)
    ...     message_alias=UEContextModificationResponse_${msg_num}
    ...     flow_alias=${flow_alias}

Verify in UECtxModResp_${msg:\d+} out of ${all:\d+} that ${bO:\S+} betaOffsets are configured and their values are correct for gNB${g:\d+}
    [Documentation]   Check of betaOffsets values introduced according to TP
    ...               CB008717-K_B3f_ALT6_Configuration_of_aperiodic_CSI_in_TDD_PCell_not_limited_by_UE capability_with_dynamic_betaOffsets
    ...               5G_CP_IF_RRC_13773

    Verify in UECtxModResp_${msg} out of ${all} that ${bO} betaOffsets are configured for gNB${g}
    Verify in UECtxModResp_${msg} out of ${all} betaOffsetACK-Index1 values for ${bO} betaOffsets and TDD PCell for gNB${g}
    Verify in UECtxModResp_${msg} out of ${all} betaOffsetACK-Index2 values for ${bO} betaOffsets and TDD PCell for gNB${g}
    Verify in UECtxModResp_${msg} out of ${all} betaOffsetACK-Index3 values for ${bO} betaOffsets and TDD PCell for gNB${g}
    Verify in UECtxModResp_${msg} out of ${all} betaOffsetCSI-Part1-Index1 values for ${bO} betaOffsets and TDD PCell for gNB${g}
    Verify in UECtxModResp_${msg} out of ${all} betaOffsetCSI-Part1-Index2 values for ${bO} betaOffsets and TDD PCell for gNB${g}
    Verify in UECtxModResp_${msg} out of ${all} betaOffsetCSI-Part2-Index1 values for ${bO} betaOffsets and TDD PCell for gNB${g}
    Verify in UECtxModResp_${msg} out of ${all} betaOffsetCSI-Part2-Index2 values for ${bO} betaOffsets and TDD PCell for gNB${g}

Verify in UECtxModResp_${msg:\d+} out of ${all:\d+} that ${bO:\S+} betaOffsets are configured for gNB${g:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${g}
    ...     protocol=F1AP

    ${comparator}=   Set variable if    '${bO}'=='dynamic'    eq    ne

    Verify That Message Fulfills Query
    ...     ${bO} is present and length(${bO}) ${comparator} 4
    ...     message_alias=UEContextModificationResponse_${msg}
    ...     flow_alias=${flow_alias}

Verify in UECtxModResp_${msg:\d+} out of ${all:\d+} betaOffsetACK-Index1 values for ${bO:\S+} betaOffsets and TDD PCell for gNB${g:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${g}
    ...     protocol=F1AP

    ${set}=       Set variable if    '${bO}'=='dynamic'    (10,10,11,11)    (11)

    Verify That Message Fulfills Query
    ...     betaOffsetACK-Index1 contains ${set}
    ...     message_alias=UEContextModificationResponse_${msg}
    ...     flow_alias=${flow_alias}

Verify in UECtxModResp_${msg:\d+} out of ${all:\d+} betaOffsetACK-Index2 values for ${bO:\S+} betaOffsets and TDD PCell for gNB${g:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${g}
    ...     protocol=F1AP

    ${set}=       Set variable if    '${bO}'=='dynamic'    (8,8,8,8)    (8)

    Verify That Message Fulfills Query
    ...     betaOffsetACK-Index2 contains ${set}
    ...     message_alias=UEContextModificationResponse_${msg}
    ...     flow_alias=${flow_alias}

Verify in UECtxModResp_${msg:\d+} out of ${all:\d+} betaOffsetACK-Index3 values for ${bO:\S+} betaOffsets and TDD PCell for gNB${g:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${g}
    ...     protocol=F1AP

    ${set}=       Set variable if    '${bO}'=='dynamic'    (6,6,6,6)    (6)

    Verify That Message Fulfills Query
    ...     betaOffsetACK-Index3 contains ${set}
    ...     message_alias=UEContextModificationResponse_${msg}
    ...     flow_alias=${flow_alias}

Verify in UECtxModResp_${msg:\d+} out of ${all:\d+} betaOffsetCSI-Part1-Index1 values for ${bO:\S+} betaOffsets and TDD PCell for gNB${g:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${g}
    ...     protocol=F1AP

    ${set}=       Set variable if    '${bO}'=='dynamic'    (13,13,13,13)    (13)

    Verify That Message Fulfills Query
    ...     betaOffsetCSI-Part1-Index1 contains ${set}
    ...     message_alias=UEContextModificationResponse_${msg}
    ...     flow_alias=${flow_alias}

Verify in UECtxModResp_${msg:\d+} out of ${all:\d+} betaOffsetCSI-Part1-Index2 values for ${bO:\S+} betaOffsets and TDD PCell for gNB${g:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${g}
    ...     protocol=F1AP

    ${set}=       Set variable if    '${bO}'=='dynamic'    (13,13,13,13)    (13)

    Verify That Message Fulfills Query
    ...     betaOffsetCSI-Part1-Index2 contains ${set}
    ...     message_alias=UEContextModificationResponse_${msg}
    ...     flow_alias=${flow_alias}

Verify in UECtxModResp_${msg:\d+} out of ${all:\d+} betaOffsetCSI-Part2-Index1 values for ${bO:\S+} betaOffsets and TDD PCell for gNB${g:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${g}
    ...     protocol=F1AP

    ${set}=       Set variable if    '${bO}'=='dynamic'    (18,15,12,13)    (13)

    Verify That Message Fulfills Query
    ...     betaOffsetCSI-Part2-Index1 contains ${set}
    ...     message_alias=UEContextModificationResponse_${msg}
    ...     flow_alias=${flow_alias}

Verify in UECtxModResp_${msg:\d+} out of ${all:\d+} betaOffsetCSI-Part2-Index2 values for ${bO:\S+} betaOffsets and TDD PCell for gNB${g:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${g}
    ...     protocol=F1AP

    ${set}=       Set variable if    '${bO}'=='dynamic'    (13,12,13,13)    (13)

    Verify That Message Fulfills Query
    ...     betaOffsetCSI-Part2-Index2 contains ${set}
    ...     message_alias=UEContextModificationResponse_${msg}
    ...     flow_alias=${flow_alias}

Verify in UECtxModResp_${msg_num:\d+} out of ${all:\d+} that CellGroupConfig contains reportTriggerSize set to 0 for gNB${g:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${g}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     csi-MeasConfig contains (reportTriggerSize eq 0)
    ...     message_alias=UEContextModificationResponse_${msg_num}
    ...     flow_alias=${flow_alias}

Verify in UECtxModResp_${msg_num:\d+} out of ${all:\d+} that CellGroupConfig contains csi-ReportConfigToReleaseList for gNB${g:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${g}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     csi-ReportConfigToReleaseList contains (1)
    ...     message_alias=UEContextModificationResponse_${msg_num}
    ...     flow_alias=${flow_alias}

Verify in UECtxModResp_${msg_num:\d+} out of ${all:\d+} that CellGroupConfig contains aperiodicTriggerStateList set to release for gNB${g:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${g}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     aperiodicTriggerStateList contains (release is present)
    ...     message_alias=UEContextModificationResponse_${msg_num}
    ...     flow_alias=${flow_alias}

Verify in UECtxModReq_${msg_num:\d+} out of ${all:\d+} that ue-CapabilityInfo is present for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

   Verify That Message Fulfills Query
    ...     ue-CapabilityInfo is present
    ...     message_alias=UEContextModificationRequest_${msg_num}
    ...     flow_alias=${flow_alias}

Verify in UECtxModReq_${num:\d+} out of ${all:\d+} that BandCombinationIndex eq ${band:\d+} and allowedFeatureSetsList eq ${set:\d+} for gNB${id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     (bandCombinationIndex eq ${band})
    ...     and
    ...     (allowedFeatureSetsList contains (${set}))
    ...     message_alias=UEContextModificationRequest_${num}
    ...     flow_alias=${flow_alias}

Get MN GNB-CU-UE-F1AP-ID From UeCtxModificationRequest_${msg_num:\d+} out of ${all:\d+} for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    ${suffix}=    Set Index    all=${all}    msg_index=${msg_num}

    ${MN_gnb_id}=    Get Values Of Parameter From Message Flow    flow_alias=${flow_alias}
    ...  message_alias=UEContextModificationRequest${suffix}   parameter_name=GNB-CU-UE-F1AP-ID
    [Return]    ${MN_gnb_id}

Verify in UECtxModReq_${n:\d+} out of ${all:\d+} that TransmissionActionIndicator is set to stop
    Verify That Message Fulfills Query
    ...     TransmissionActionIndicator eq "stop"
    ...     message_alias=SN_UEContextModificationRequest
    ...     flow_alias=takeback_SN_F1AP
    Log To Console    Verify in UECtxModReq_${n} out of ${all} that TransmissionActionIndicator is set to stop

Verify in UECtxModResp_${n:\d+} out of ${all:\d+} that GNB-CU-UE-F1AP-ID and GNB-DU-UE-F1AP-ID are present
    Verify That Message Fulfills Query
    ...     length(protocolIEs) eq 2 and GNB-CU-UE-F1AP-ID is present and GNB-DU-UE-F1AP-ID is present
    ...     message_alias=SN_UEContextModificationResponse
    ...     flow_alias=takeback_SN_F1AP
    Log To Console    Verify in UECtxModResp_${n} out of ${all} that GNB-CU-UE-F1AP-ID and GNB-DU-UE-F1AP-ID are present

Verify in UECtxModReq_${n:\d+} out of ${all:\d+} that SCGIndicator IE set to released
    Verify That Message Fulfills Query
    ...     SCGIndicator eq "released"
    ...     message_alias=MN_UEContextModificationRequest
    ...     flow_alias=takeback_MN_F1AP
    Log To Console    Verify in UECtxModReq_${n} out of ${all} that SCGIndicator IE set to released

Verify in UECtxModResp_1 out of ${all:\d+} that CellGroupConfig contains cellGroupId
    Verify That Message Fulfills Query
    ...     cellGroupId eq 0
    ...     message_alias=MN_UEContextModificationResponse
    ...     flow_alias=takeback_MN_F1AP
    Log To Console    Verify in UECtxModResp_1 out of ${all} that CellGroupConfig contains cellGroupId

Verify in UECtxModResp_1 out of ${all:\d+} that CellGroupConfig contains spCellConfigDedicated with exactly 3 elements
    Verify That Message Fulfills Query
    ...     length(spCellConfigDedicated) eq 3
    ...     message_alias=MN_UEContextModificationResponse
    ...     flow_alias=takeback_MN_F1AP
    Log To Console   Verify in UECtxModResp_1 out of ${all} that CellGroupConfig contains spCellConfigDedicated with exactly 3 elements

Verify in UECtxModResp_1 out of ${all:\d+} that CellGroupConfig contains spCellConfigDedicated with at least 4 elements
    Verify That Message Fulfills Query
    ...     length(spCellConfigDedicated) ge 4
    ...     message_alias=MN_UEContextModificationResponse
    ...     flow_alias=takeback_MN_F1AP
     Log To Console   Verify in UECtxModResp_1 out of ${all} that CellGroupConfig contains spCellConfigDedicated with at least 4 elements

Verify in UECtxModResp_1 out of ${all:\d+} that CellGroupConfig contains uplinkBWP-ToAddModList
    Verify That Message Fulfills Query
    ...     uplinkBWP-ToAddModList is present
    ...     message_alias=MN_UEContextModificationResponse
    ...     flow_alias=takeback_MN_F1AP
    Log To Console   Verify in UECtxModResp_1 out of ${all} that CellGroupConfig contains uplinkBWP-ToAddModList

Verify in UECtxModResp_1 out of ${all:\d+} that CellGroupConfig contains bwp-Id
    Verify That Message Fulfills Query
    ...     uplinkBWP-ToAddModList contains (bwp-Id eq 1)
    ...     message_alias=MN_UEContextModificationResponse
    ...     flow_alias=takeback_MN_F1AP
    Log To Console   Verify in UECtxModResp_1 out of ${all} that CellGroupConfig contains bwp-Id

Verify in UECtxModResp_1 out of ${all:\d+} that CellGroupConfig contains ${betaOffsets:\S+} betaOffsets
    Verify That Message Fulfills Query
    ...     uci-OnPUSCH contains (betaOffsets is present and ${betaOffsets} is present)
    ...     message_alias=MN_UEContextModificationResponse
    ...     flow_alias=takeback_MN_F1AP
    Log To Console   Verify in UECtxModResp_1 out of ${all} that CellGroupConfig contains ${betaOffsets} betaOffsets

Verify in UECtxModResp_1 out of ${all:\d+} ${bO:\S+} betaOffsets are configured and their values are correct
    [Documentation]   Check of betaOffsets values introduced according to TP
    ...               CB008717-K_B3f_ALT6_Configuration_of_aperiodic_CSI_in_TDD_PCell_not_limited_by_UE capability_with_dynamic_betaOffsets
    ...               5G_CP_IF_RRC_13773

    Verify in UECtxModResp_1 out of ${all} that ${bO} betaOffsets are configured
    Verify in UECtxModResp_1 out of ${all} betaOffsetACK-Index1 values for ${bO} betaOffsets and TDD PCell
    Verify in UECtxModResp_1 out of ${all} betaOffsetACK-Index2 values for ${bO} betaOffsets and TDD PCell
    Verify in UECtxModResp_1 out of ${all} betaOffsetACK-Index3 values for ${bO} betaOffsets and TDD PCell
    Verify in UECtxModResp_1 out of ${all} betaOffsetCSI-Part1-Index1 values for ${bO} betaOffsets and TDD PCell
    Verify in UECtxModResp_1 out of ${all} betaOffsetCSI-Part1-Index2 values for ${bO} betaOffsets and TDD PCell
    Verify in UECtxModResp_1 out of ${all} betaOffsetCSI-Part2-Index1 values for ${bO} betaOffsets and TDD PCell
    Verify in UECtxModResp_1 out of ${all} betaOffsetCSI-Part2-Index2 values for ${bO} betaOffsets and TDD PCell

Verify in UECtxModResp_1 out of ${all:\d+} that ${bO:\S+} betaOffsets are configured
    ${comparator}=   Set variable if    '${bO}'=='dynamic'    eq    ne

    Verify That Message Fulfills Query
    ...     ${bO} is present and length(${bO}) ${comparator} 4
    ...     message_alias=MN_UEContextModificationResponse
    ...     flow_alias=takeback_MN_F1AP
    Log To Console   Verify in UECtxModResp_1 out of ${all} that ${bO} betaOffsets are configured

Verify in UECtxModResp_1 out of ${all:\d+} betaOffsetACK-Index1 values for ${bO:\S+} betaOffsets and TDD PCell
    ${set}=       Set variable if    '${bO}'=='dynamic'    (10,10,11,11)    (11)

    Verify That Message Fulfills Query
    ...     betaOffsetACK-Index1 contains ${set}
    ...     message_alias=MN_UEContextModificationResponse
    ...     flow_alias=takeback_MN_F1AP
    Log To Console    Verify in UECtxModResp_1 out of ${all} betaOffsetACK-Index1 values

Verify in UECtxModResp_1 out of ${all:\d+} betaOffsetACK-Index2 values for ${bO:\S+} betaOffsets and TDD PCell
    ${set}=       Set variable if    '${bO}'=='dynamic'    (8,8,8,8)    (8)

    Verify That Message Fulfills Query
    ...     betaOffsetACK-Index2 contains ${set}
    ...     message_alias=MN_UEContextModificationResponse
    ...     flow_alias=takeback_MN_F1AP
    Log To Console    Verify in UECtxModResp_1 out of ${all} betaOffsetACK-Index2 values

Verify in UECtxModResp_1 out of ${all:\d+} betaOffsetACK-Index3 values for ${bO:\S+} betaOffsets and TDD PCell
    ${set}=       Set variable if    '${bO}'=='dynamic'    (6,6,6,6)    (6)

    Verify That Message Fulfills Query
    ...     betaOffsetACK-Index3 contains ${set}
    ...     message_alias=MN_UEContextModificationResponse
    ...     flow_alias=takeback_MN_F1AP
    Log To Console    Verify in UECtxModResp_1 out of ${all} betaOffsetACK-Index3 values

Verify in UECtxModResp_1 out of ${all:\d+} betaOffsetCSI-Part1-Index1 values for ${bO:\S+} betaOffsets and TDD PCell
    ${set}=       Set variable if    '${bO}'=='dynamic'    (13,13,13,13)    (13)

    Verify That Message Fulfills Query
    ...     betaOffsetCSI-Part1-Index1 contains ${set}
    ...     message_alias=MN_UEContextModificationResponse
    ...     flow_alias=takeback_MN_F1AP
    Log To Console    Verify in UECtxModResp_1 out of ${all} betaOffsetCSI-Part1-Index1 values

Verify in UECtxModResp_1 out of ${all:\d+} betaOffsetCSI-Part1-Index2 values for ${bO:\S+} betaOffsets and TDD PCell
    ${set}=       Set variable if    '${bO}'=='dynamic'    (13,13,13,13)    (13)

    Verify That Message Fulfills Query
    ...     betaOffsetCSI-Part1-Index2 contains ${set}
    ...     message_alias=MN_UEContextModificationResponse
    ...     flow_alias=takeback_MN_F1AP
    Log To Console    Verify in UECtxModResp_1 out of ${all} betaOffsetCSI-Part1-Index2 values

Verify in UECtxModResp_1 out of ${all:\d+} betaOffsetCSI-Part2-Index1 values for ${bO:\S+} betaOffsets and TDD PCell
    ${set}=       Set variable if    '${bO}'=='dynamic'    (18,15,12,13)    (13)

    Verify That Message Fulfills Query
    ...     betaOffsetCSI-Part2-Index1 contains ${set}
    ...     message_alias=MN_UEContextModificationResponse
    ...     flow_alias=takeback_MN_F1AP
    Log To Console    Verify in UECtxModResp_1 out of ${all} betaOffsetCSI-Part2-Index1 values

Verify in UECtxModResp_1 out of ${all:\d+} betaOffsetCSI-Part2-Index2 values for ${bO:\S+} betaOffsets and TDD PCell
    ${set}=       Set variable if    '${bO}'=='dynamic'    (13,12,13,13)    (13)

    Verify That Message Fulfills Query
    ...     betaOffsetCSI-Part2-Index2 contains ${set}
    ...     message_alias=MN_UEContextModificationResponse
    ...     flow_alias=takeback_MN_F1AP
    Log To Console    Verify in UECtxModResp_1 out of ${all} betaOffsetCSI-Part2-Index2 values

Verify in UECtxModResp_1 out of ${all:\d+} that CellGroupConfig contains bwp-Dedicated
    Verify That Message Fulfills Query
    ...     bwp-Dedicated contains (pusch-Config is present)
    ...     message_alias=MN_UEContextModificationResponse
    ...     flow_alias=takeback_MN_F1AP
    Log To Console    Verify in UECtxModResp_1 out of ${all} that CellGroupConfig contains bwp-Dedicated

Verify in UECtxModResp_1 out of ${all:\d+} that firstActiveUplinkBWP-Id eq 1
    Verify That Message Fulfills Query
    ...     firstActiveUplinkBWP-Id eq 1
    ...     message_alias=MN_UEContextModificationResponse
    ...     flow_alias=takeback_MN_F1AP
    Log To Console    Verify in UECtxModResp_1 out of ${all} that firstActiveUplinkBWP-Id eq 1

Verify in UECtxModResp_1 out of ${all:\d+} that firstActiveUplinkBWP-Id is not present
    Verify That Message Fulfills Query
    ...     firstActiveUplinkBWP-Id is not present
    ...     message_alias=MN_UEContextModificationResponse
    ...     flow_alias=takeback_MN_F1AP
    Log To Console    Verify in UECtxModResp_1 out of ${all} that firstActiveUplinkBWP-Id is not present

Verify in UECtxModResp_1 out of ${all:\d+} that csi-MeasConfig contains reportConfigId
    Verify That Message Fulfills Query
    ...     csi-ReportConfigToAddModList contains (reportConfigId eq 2)
    ...     message_alias=MN_UEContextModificationResponse
    ...     flow_alias=takeback_MN_F1AP
    Log To Console    Verify in UECtxModResp_1 out of ${all} that csi-MeasConfig contains reportConfigId

Verify in UECtxModResp_1 out of ${all:\d+} that csi-MeasConfig contains reportConfigType
    Verify That Message Fulfills Query
    ...     csi-ReportConfigToAddModList contains (reportConfigType contains (periodic is present))
    ...     message_alias=MN_UEContextModificationResponse
    ...     flow_alias=takeback_MN_F1AP
    Log To Console    Verify in UECtxModResp_1 out of ${all} that csi-MeasConfig contains reportConfigType

Verify in UECtxModResp_1 out of ${all:\d+} that csi-MeasConfig contains reportQuantity
    Verify That Message Fulfills Query
    ...     csi-ReportConfigToAddModList contains (reportQuantity contains (cri-RSRP is present))
    ...     message_alias=MN_UEContextModificationResponse
    ...     flow_alias=takeback_MN_F1AP
    Log To Console    Verify in UECtxModResp_1 out of ${all} that csi-MeasConfig contains reportQuantity

Verify in UECtxModResp_1 out of ${all:\d+} that CellGroupConfig contains pusch-ServingCellConfig
    Verify That Message Fulfills Query
    ...     spCellConfig contains (pusch-ServingCellConfig is present)
    ...     message_alias=MN_UEContextModificationResponse
    ...     flow_alias=takeback_MN_F1AP
    Log To Console    Verify in UECtxModResp_1 out of ${all} that CellGroupConfig contains pusch-ServingCellConfig

Verify in UECtxModResp_1 out of ${all:\d+} that CellGroupConfig contains pdsch-ServingCellConfig
    Verify That Message Fulfills Query
    ...     spCellConfig contains (pdsch-ServingCellConfig is present)
    ...     message_alias=MN_UEContextModificationResponse
    ...     flow_alias=takeback_MN_F1AP
    Log To Console    Verify in UECtxModResp_1 out of ${all} that CellGroupConfig contains pdsch-ServingCellConfig

Verify in UECtxModResp_1 out of ${all:\d+} that CellGroupConfig contains tag-Id
    Verify That Message Fulfills Query
    ...     spCellConfig contains (tag-Id eq 0)
    ...     message_alias=MN_UEContextModificationResponse
    ...     flow_alias=takeback_MN_F1AP
    Log To Console    Verify in UECtxModResp_1 out of ${all} that CellGroupConfig contains tag-Id

Verify in UECtxModResp_1 out of ${all:\d+} that CellGroupConfig contains reportTriggerSize eq 1
    Verify That Message Fulfills Query
    ...     csi-MeasConfig contains (reportTriggerSize eq 1)
    ...     message_alias=MN_UEContextModificationResponse
    ...     flow_alias=takeback_MN_F1AP
    Log To Console    Verify in UECtxModResp_1 out of ${all} that CellGroupConfig contains reportTriggerSize eq 1

Verify in UECtxModResp_1 out of ${all:\d+} that CellGroupConfig contains aperiodicTriggerStateList
    Verify That Message Fulfills Query
    ...     length(aperiodicTriggerStateList) eq 1 and associatedReportConfigInfoList is present
    ...     message_alias=MN_UEContextModificationResponse
    ...     flow_alias=takeback_MN_F1AP
    Log To Console    Verify in UECtxModResp_1 out of ${all} that CellGroupConfig contains aperiodicTriggerStateList

Verify in UECtxModResp_1 out of ${all:\d+} that CellGroupConfig contains csi-ReportConfigToAddModList with reportConfigID eq 1
    Verify That Message Fulfills Query
    ...     csi-ReportConfigToAddModList contains (reportConfigId eq 1)
    ...     message_alias=MN_UEContextModificationResponse
    ...     flow_alias=takeback_MN_F1AP
    Log To Console    Verify in UECtxModResp_1 out of ${all} that CellGroupConfig contains csi-ReportConfigToAddModList with reportConfigID eq 1

Verify in UECtxModReq_${n:\d+} out of ${all:\d+} that RRCReconfigurationCompleteIndicator is set to true
    Verify That Message Fulfills Query
    ...     RRCReconfigurationCompleteIndicator eq "true"
    ...     message_alias=MN_UEContextModificationRequest_2nd
    ...     flow_alias=takeback_MN_F1AP
    Log To Console    Verify in UECtxModReq_${n} out of ${all} that RRCReconfigurationCompleteIndicator is set to true

Verify in UECtxModReq_${n:\d+} out of ${all:\d+} that GNB-DUConfigurationQuery is set to true
    Verify That Message Fulfills Query
    ...     GNB-DUConfigurationQuery eq "true"
    ...     message_alias=MN_UEContextModificationRequest_2nd
    ...     flow_alias=takeback_MN_F1AP
    Log To Console    Verify in UECtxModReq_${n} out of ${all} that GNB-DUConfigurationQuery is set to true

Verify in UECtxModResp_2 out of ${all:\d+} that CellGroupConfig contains cellGroupId
    Verify That Message Fulfills Query
    ...     cellGroupId eq 0
    ...     message_alias=MN_UEContextModificationResponse_2nd
    ...     flow_alias=takeback_MN_F1AP
    Log To Console    Verify in UECtxModResp_2 out of ${all} that CellGroupConfig contains cellGroupId

Verify in UECtxModResp_2 out of ${all:\d+} that CellGroupConfig contains uplinkBWP-ToAddModList
    Verify That Message Fulfills Query
    ...     uplinkBWP-ToAddModList is present
    ...     message_alias=MN_UEContextModificationResponse_2nd
    ...     flow_alias=takeback_MN_F1AP
    Log To Console    Verify in UECtxModResp_2 out of ${all} that CellGroupConfig contains uplinkBWP-ToAddModList

Verify in UECtxModResp_2 out of ${all:\d+} that CellGroupConfig contains bwp-Id
    Verify That Message Fulfills Query
    ...     uplinkBWP-ToAddModList contains (bwp-Id eq 1)
    ...     message_alias=MN_UEContextModificationResponse_2nd
    ...     flow_alias=takeback_MN_F1AP
    Log To Console    Verify in UECtxModResp_2 out of ${all} that CellGroupConfig contains bwp-Id

Verify in UECtxModResp_2 out of ${all:\d+} that CellGroupConfig contains bwp-Dedicated
    Verify That Message Fulfills Query
    ...     bwp-Dedicated contains ((pusch-Config is present) and (srs-Config is present))
    ...     message_alias=MN_UEContextModificationResponse_2nd
    ...     flow_alias=takeback_MN_F1AP
    Log To Console    Verify in UECtxModResp_2 out of ${all} that CellGroupConfig contains bwp-Dedicated

Verify in UECtxModResp_1 out of ${all:\d+} that firstActiveUplinkBWP-Id is set to 1
    Verify That Message Fulfills Query
    ...     firstActiveUplinkBWP-Id eq 1
    ...     message_alias=MN_UEContextModificationResponse_2nd
    ...     flow_alias=takeback_MN_F1AP
    Log To Console    Verify in UECtxModResp_1 out of ${all} that firstActiveUplinkBWP-Id is set to 1

Verify in UECtxModResp_2 out of ${all:\d+} that CellGroupConfig contains pusch-ServingCellConfig
    Verify That Message Fulfills Query
    ...     spCellConfig contains (pusch-ServingCellConfig is present)
    ...     message_alias=MN_UEContextModificationResponse_2nd
    ...     flow_alias=takeback_MN_F1AP
    Log To Console    Verify in UECtxModResp_2 out of ${all} that CellGroupConfig contains pusch-ServingCellConfig

Verify in UECtxModResp_2 out of ${all:\d+} that CellGroupConfig contains pdsch-ServingCellConfig
    Verify That Message Fulfills Query
    ...     spCellConfig contains (pdsch-ServingCellConfig is present)
    ...     message_alias=MN_UEContextModificationResponse_2nd
    ...     flow_alias=takeback_MN_F1AP
    Log To Console    Verify in UECtxModResp_2 out of ${all} that CellGroupConfig contains pdsch-ServingCellConfig

Verify in UECtxModResp_2 out of ${all:\d+} that CellGroupConfig contains tag-Id
    Verify That Message Fulfills Query
    ...     spCellConfig contains (tag-Id eq 0)
    ...     message_alias=MN_UEContextModificationResponse_2nd
    ...     flow_alias=takeback_MN_F1AP
    Log To Console    Verify in UECtxModResp_2 out of ${all} that CellGroupConfig contains tag-Id

Verify that UECtxModRequired_${n:\d+} out of ${all:\d+} was send with cause:radioNetwork:${cause:\S+} for gNB${gnb_id:\d+}
    Verify in UECtxModRequired_${n} out of ${all} that cause:radioNetwork:${cause} is present for gNB${gnb_id}

Verify that UECtxModConfirm_${n:\d+} out of ${all:\d+} was message UEContextModificationConfirm is present
    Verify in UECtxModConfirm_${n} out of ${all} that message UEContextModificationConfirm is present

Verify in UECtxModConfirm_${n} out of ${all} that message UEContextModificationConfirm is present
    Verify That Message Fulfills Query
    ...    UEContextModificationConfirm is present
    ...    message_alias=SN_UEContextModificationConfirm
    ...    flow_alias=takeback_SN_F1AP_2
    Log To Console    Verify in UECtxModConfirm_${n} out of ${all} that message UEContextModificationConfirm is present

Verify in UECtxModResp_${n:\d+} out of ${all:\d+} that measGapConfigIE is present for gNB${gnb_id}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     measGapConfig is present
    ...     message_alias=UEContextModificationResponse_${n}
    ...     flow_alias=${flow_alias}

Verify A${meas_nr} measurement report configuration in UECtxtModReq_${n:\d+} out of ${all:\d+} for gNB${gnb_id:\d+}
        ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    KeywordsCB008717.Verify If MeasConfig Contains
    ...     flow_alias=${flow_alias}
    ...     message_alias=UEContextModificationRequest_${n}
    ...     field=eventA${meas_nr}
    ...     value=is present

Verify in UECtxModReq_${n:\d+} out of ${all:\d+} that RRCReconfigurationCompleteIndicator is set to true for gNB${gnb_id:\d+}
            ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    ${suffix}=    Set Index    all=${all}    msg_index=${n}

    Verify That Message Fulfills Query
    ...     RRCReconfigurationCompleteIndicator eq "true"
    ...     message_alias=UEContextModificationRequest${suffix}
    ...     flow_alias=${flow_alias}


Verify in UECtxModReq_${n:\d+} out of ${all:\d+} that GNB-DUConfigurationQuery is set to true for gNB${gnb_id:\d+}
            ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    ${suffix}=    Set Index    all=${all}    msg_index=${n}

    Verify That Message Fulfills Query
    ...     GNB-DUConfigurationQuery eq "true"
    ...     message_alias=UEContextModificationRequest${suffix}
    ...     flow_alias=${flow_alias}

#NB6b
Verify that UECtxModResp_${n:\d+} out of ${a:\d+} was sent with modification of MCG for the UE${u:\d+} for MN
    Verify in UECtxModResp_1 out of ${a} that CellGroupConfig contains cellGroupId
    Verify in UECtxModResp_1 out of ${a} that CellGroupConfig contains spCellConfigDedicated with exactly 3 elements
    Verify in UECtxModResp_1 out of ${a} that CellGroupConfig contains uplinkBWP-ToAddModList
    Verify in UECtxModResp_1 out of ${a} that CellGroupConfig contains bwp-Id
    Verify in UECtxModResp_1 out of ${a} that CellGroupConfig contains bwp-Dedicated
    Verify in UECtxModResp_1 out of ${a} that firstActiveUplinkBWP-Id eq 1
    Verify in UECtxModResp_1 out of ${a} that CellGroupConfig contains pusch-ServingCellConfig
    Verify in UECtxModResp_1 out of ${a} that CellGroupConfig contains pdsch-ServingCellConfig
    Verify in UECtxModResp_1 out of ${a} that CellGroupConfig contains tag-Id
    Log To Console    Verify that UECtxModResp_${n} out of ${a} was sent with modification of MCG for the UE${u} for MN

Verify in UECtxModReq_${n} that SCellToBeSetupList Contains ${s} SCells With PLMN ${PLMN} and starting_id ${nrcell}
    ${expectation}=    KeywordsCB008717.Build Query For SCellToBeSetupMod With Given Number Of Scells And PLMN And NRCellId
    ...     num_of_scells=${s}
    ...     plmn=${PLMN}
    ...     starting_nrcellidentity=${nrcell}

    Verify That Message Fulfills Query
    ...     ${expectation}
    ...     message_alias=MN_UEContextModificationRequest_${n}
    ...     flow_alias=takeback_and_CA_MN_F1AP

Verify in UECtxModReq_${n} that after bearer takeback SCellToBeSetupList Contains ${s} SCells With PLMN ${PLMN} and starting_id ${nrcell}
    ${expectation}=    KeywordsCB008717.Build Query For SCellToBeSetupMod With Given Number Of Scells And PLMN And NRCellId
    ...     num_of_scells=${s}
    ...     plmn=${PLMN}
    ...     starting_nrcellidentity=${nrcell}

    Verify That Message Fulfills Query
    ...     ${expectation}
    ...     message_alias=UEContextModificationRequest_${n}
    ...     flow_alias=blind_FR1_CA_after_bearer_takeback

Verify in MN_UEContextModificationResponse_${n} that sCellToAddModList contains ${s:\d+} sCells with starting phys_id ${id:\d+}
    ${expectation}=    KeywordsCB008717.Build Query For SCellToAddModList With Given Number Of Scells
    ...     num_of_scells=${s}
    ...     starting_scell_index=${id}

    Verify That Message Fulfills Query
    ...     ${expectation}
    ...     message_alias=MN_UEContextModificationResponse_${n}
    ...     flow_alias=takeback_and_CA_MN_F1AP

Verify in MN_UEContextModificationResponse_${n} that sCellToAddModList contains ${s:\d+} sCells with starting phys_id ${id:\d+} after takeback
    ${expectation}=    KeywordsCB008717.Build Query For SCellToAddModList With Given Number Of Scells
    ...     num_of_scells=${s}
    ...     starting_scell_index=${id}

    Verify That Message Fulfills Query
    ...     ${expectation}
    ...     message_alias=UEContextModificationResponse_${n}
    ...     flow_alias=blind_FR1_CA_after_bearer_takeback

Verify that RRCReconfigurationCompleteIndicator is set to true
    [Arguments]     ${message_alias}    ${flow_alias}
    Verify That Message Fulfills Query
    ...     RRCReconfigurationCompleteIndicator eq "true"
    ...     message_alias=${message_alias}
    ...     flow_alias=${flow_alias}

Verify that GNB-DUConfigurationQuery is set to true
    [Arguments]     ${message_alias}    ${flow_alias}
    Verify That Message Fulfills Query
    ...     GNB-DUConfigurationQuery eq "true"
    ...     message_alias=${message_alias}
    ...     flow_alias=${flow_alias}

Verify in UECtxtModReq_${n:\d+} out of ${all:\d+} that freq n${freq:\d+} is present
        ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    KeywordsCB008717.Verify If MeasConfig Contains Non Unique Value
    ...     flow_alias=${flow_alias}
    ...     message_alias=UEContextModificationRequest_${n}
    ...     field=freqBandIndicatorNR
    ...     value=${freq}

Verify in UECtxtModReq_${n:\d+} out of ${all:\d+} that measID ${id:\d+} is present
        ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    KeywordsCB008717.Verify If MeasConfig Contains Non Unique Value
    ...     flow_alias=${flow_alias}
    ...     message_alias=UEContextModificationRequest_${n}
    ...     field=measId
    ...     value=${id}

Verify that UECtxModReq_${n:\d+} out of ${all:\d+} SCellToBeSetupList Contains ${s:\d+} SCells With PLMN ${PLMN} and starting_id ${nrcell:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB2
    ...     protocol=F1AP

    ${expectation}=    KeywordsCB008717.Build Query For SCellToBeSetupMod With Given Number Of Scells And PLMN And NRCellId
    ...     num_of_scells=${s}
    ...     plmn=${PLMN}
    ...     starting_nrcellidentity=${nrcell}

    ${suffix}=    Set Index    all=${all}    msg_index=${n}

    Verify That Message Fulfills Query
    ...     ${expectation}
    ...     message_alias=UEContextModificationRequest${suffix}
    ...     flow_alias=${flow_alias}

Verify that UECtxModReq_${n:\d+} out of ${all:\d+} SCellToBeRemovedList Contains ${s:\d+} SCells With PLMN ${PLMN} and starting_id ${nrcell:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB2
    ...     protocol=F1AP

    ${expectation}=    KeywordsCB008717.Build Query For SCellToBeRemovedList With Given Number Of Scells And PLMN And NRCellId
    ...     num_of_scells=${s}
    ...     plmn=${PLMN}
    ...     starting_nrcellidentity=${nrcell}

    ${suffix}=    Set Index    all=${all}    msg_index=${n}

    Verify That Message Fulfills Query
    ...     ${expectation}
    ...     message_alias=UEContextModificationRequest${suffix}
    ...     flow_alias=${flow_alias}

Verify in MN_UEContextModificationResponse_${n} that csi-ReportConfigIDs Related To SCells And Bemforming Configuration Are Present

    Verify That Message Fulfills Query
    ...     csi-MeasConfig contains (csi-ReportConfigToAddModList contains (reportConfigId eq 13))
    ...     and csi-MeasConfig contains (csi-ReportConfigToAddModList contains (reportConfigId eq 14))
    ...     and csi-MeasConfig contains (csi-ReportConfigToAddModList contains (reportConfigId eq 15))
    ...     and csi-MeasConfig contains (csi-ReportConfigToAddModList contains (reportConfigId eq 22))
    ...     and csi-MeasConfig contains (csi-ReportConfigToAddModList contains (reportConfigId eq 23))
    ...     message_alias=MN_UEContextModificationResponse_${n}
    ...     flow_alias=takeback_and_CA_MN_F1AP

Verify in MN_UEContextModificationResponse_${n} that after takeback with blind FR1 CA csi-ReportConfigIDs Related To SCells And BF Cfg Are Present

    Verify That Message Fulfills Query
    ...     csi-MeasConfig contains (csi-ReportConfigToAddModList contains (reportConfigId eq 13))
    ...     and csi-MeasConfig contains (csi-ReportConfigToAddModList contains (reportConfigId eq 14))
    ...     and csi-MeasConfig contains (csi-ReportConfigToAddModList contains (reportConfigId eq 15))
    ...     and csi-MeasConfig contains (csi-ReportConfigToAddModList contains (reportConfigId eq 22))
    ...     and csi-MeasConfig contains (csi-ReportConfigToAddModList contains (reportConfigId eq 23))
    ...     message_alias=UEContextModificationResponse_${n}
    ...     flow_alias=blind_FR1_CA_after_bearer_takeback

Verify in UECtxtModRes_${n:\d+} out of ${all:\d+} that after takeback with blind FR1 CA csi-ReportConfigIDs Related To SCells And BF Cfg Are Present
            ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB2
    ...     protocol=F1AP

    ${suffix}=    Set Index    all=${all}    msg_index=${n}

    Verify That Message Fulfills Query
    ...     csi-MeasConfig contains (csi-ReportConfigToAddModList contains (reportConfigId eq 13))
    ...     and csi-MeasConfig contains (csi-ReportConfigToAddModList contains (reportConfigId eq 21))
    ...     message_alias=UEContextModificationResponse${suffix}
    ...     flow_alias=${flow_alias}

Verify in UECtxtModReq_${n:\d+} out of ${all:\d+} that measObjectID ${id:\d+} is present
        ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    KeywordsCB008717.Verify If MeasConfig Contains Non Unique Value
    ...     flow_alias=${flow_alias}
    ...     message_alias=UEContextModificationRequest_${n}
    ...     field=measObjectId
    ...     value=${id}

Verify in UECtxModResp_${n} out of ${all:\d+} for UE${ue:\d+} that sCellToAddModList contains ${s:\d+} sCells with starting phys_id ${id:\d+}
    ${flow_alias}=     Get Flow Name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB2
    ...     protocol=F1AP

    ${expectation}=    KeywordsCB008717.Build Query For SCellToAddModList With Given Number Of Scells
    ...     num_of_scells=${s}
    ...     starting_scell_index=${id}

    ${suffix}=    Set Index    all=${all}    msg_index=${n}

    Verify That Message Fulfills Query
    ...     ${expectation}
    ...     message_alias=UEContextModificationResponse${suffix}
    ...     flow_alias=${flow_alias}
    Log To Console    Verify in UECtxModResp_${n} out of ${all} for UE${ue} that sCellToAddModList contains ${s} sCells with starting phys_id ${id}
