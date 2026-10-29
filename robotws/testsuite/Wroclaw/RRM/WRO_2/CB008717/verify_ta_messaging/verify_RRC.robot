*** Settings ***
Documentation    :copyright: Nokia
...             :authors: I_MN_RAN_RD_VRF_WRO2_6
...             :contact: I_MN_RAN_RD_VRF_WRO2_6

Resource    suffix.robot

Library     ../KeywordsCB008717.py

*** Keywords ***
Verify that RRCReconfiguration_${n:\d+} out of ${all:\d+} was completed for gNB${g:\d+}, UE${u:\d+}, ${s:\d+}-SCells, ${m:\d+}-MIMO and ${d:\d+} DRB
    Verify in RRCReconfiguration_${n} out of ${all} for UE${u} that MCG modification and SCG setup is present
    Verify in RRCReconfiguration_${n} out of ${all} for UE${u} that secondaryCellGroup contains cellGroupId eq 1 sent for SCG
    Verify in RRCReconfiguration_${n} out of ${all} for UE${u} that servCellIndex eq 1 and ${m} Max-MIMO
    Verify in RRCReconfiguration_${n} out of ${all} for UE${u} that sCellToAddModList contains ${s} sCells with ${m} Max-MIMO
    Verify in RRCReconfiguration_${n} out of ${all} for UE${u} that A4 measurements related to NRHOIF-1 are removed
    Verify in RRCReconfiguration_${n} out of ${all} for UE${u} that radioBearerConfig contains drb-ToAddModList with ${d}-DRB
    Verify in RRCReconfigurationComplete_${n} out of ${all} for UE${u} that message contains encoded RRCReconfigurationComplete for SCG

Verify that RRCReconfiguration_${n:\d+} out of ${a:\d+} was sent for UE${u:\d+} ${s:\d+}-SCells ${d:\d+}-DRBs aperCSI release ${bO:\S+} betaOffsets
    Verify in RRCReconfiguration_${n} out of ${a} for UE${u} that MCG modification and SCG setup is present
    Verify in RRCReconfiguration_${n} out of ${a} for UE${u} that secondaryCellGroup contains cellGroupId eq 1 sent for SCG
    Verify in RRCReconfiguration_${n} out of ${a} for UE${u} that servCellIndex eq 1 and 2 Max-MIMO
    Verify in RRCReconfiguration_${n} out of ${a} for UE${u} that sCellToAddModList contains ${s} sCells with 2 Max-MIMO
    Verify in RRCReconfiguration_${n} out of ${a} for UE${u} that A4 measurements related to NRHOIF-1 are removed
    Verify in RRCReconfiguration_${n} out of ${a} for UE${u} that radioBearerConfig contains drb-ToAddModList with ${d}-DRB
    Verify in RRCReconfiguration_${n} out of ${a} for UE${u} that CellGroupConfig contains ${bO} betaOffsets
    Verify in RRCReconfiguration_${n} out of ${a} for UE${u} that aperiodicTriggerStateList is set to release

Verify that RRCReconfiguration_${n:\d+} out of ${all:\d+} was sent for band n${band:\d+}, UE${u:\d+}, ${d:\d+} DRB, aperCSI and ${bO:\S+} betaOffsets
    Verify in RRCReconfiguration_${n} out of ${all} for UE${u} that radioBearerConfig contains drb-ToAddModList with ${d}-DRB
    Verify in RRCReconfiguration_${n} out of ${all} for UE${u} that measObjectToAddModList contains band n${band}
    Verify in RRCReconfiguration_${n} out of ${all} for UE${u} that CellGroupConfig contains cellGroupId eq 0
    Verify in RRCReconfiguration_${n} out of ${all} for UE${u} that CellGroupConfig contains uplinkBWP-ToAddModList
    Verify in RRCReconfiguration_${n} out of ${all} for UE${u} that CellGroupConfig contains bwp-Dedicated
    Verify in RRCReconfiguration_${n} out of ${all} for UE${u} that CellGroupConfig contains ${bO} betaOffsets
    Verify in RRCReconfiguration_${n} out of ${all} for UE${u} that ${bO} betaOffsets are configured and their values are correct
    Verify in RRCReconfiguration_${n} out of ${all} for UE${u} that CellGroupConfig contains reportTriggerSize eq 1
    Verify in RRCReconfiguration_${n} out of ${all} for UE${u} that CellGroupConfig contains aperiodicTriggerStateList
    Verify in RRCReconfiguration_${n} out of ${all} for UE${u} that CellGroupConfig contains reportConfigID eq 1

Verify that RRCReconfiguration_${n:\d+} out of ${all:\d+} was completed for band n${band:\d+} and UE${u:\d+}
    Verify in RRCReconfiguration_${n} out of ${all} for UE${u} that measObjectToAddModList contains band n${band}
    Verify in RRCReconfiguration_${n} out of ${all} for UE${u} that reportConfigToAddModList contains eventA4
    Verify in RRCReconfiguration_${n} out of ${all} for UE${u} that CellGroupConfig contains cellGroupId eq 0

Verify that RRCReconfiguration_${n:\d+} out of ${all:\d+} was completed for gNB${gnb_id:\d+} and UE${ue_id:\d+} and 0-SCells and ${drb:\d+} DRB
    Verify in RRCReconfiguration_${n} out of ${all} for UE${ue_id} that MCG modification and SCG setup is present
    Verify in RRCReconfiguration_${n} out of ${all} for UE${ue_id} that secondaryCellGroup contains cellGroupId eq 1 sent for SCG
    Verify in RRCReconfiguration_${n} out of ${all} for UE${ue_id} that servCellIndex eq 1 and 2 Max-MIMO
    Verify in RRCReconfiguration_${n} out of ${all} for UE${ue_id} that sCellToAddModList is not present
    Verify in RRCReconfiguration_${n} out of ${all} for UE${ue_id} that A4 measurements related to NRHOIF-1 are removed
    Verify in RRCReconfiguration_${n} out of ${all} for UE${ue_id} that radioBearerConfig contains drb-ToAddModList with ${drb}-DRB
    Verify in RRCReconfigurationComplete_${n} out of ${all} for UE${ue_id} that message contains encoded RRCReconfigurationComplete for SCG

Verify in RRCReconfiguration_${msg_num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that CellGroupConfig contains uplinkBWP-ToAddModList
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     uplinkBWP-ToAddModList is present
    ...     message_alias=RRCReconfiguration_${msg_num}
    ...     flow_alias=${flow_alias}

Verify in RRCReconfiguration_${msg_num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that CellGroupConfig contains bwp-Dedicated
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     bwp-Dedicated contains (pusch-Config is present)
    ...     message_alias=RRCReconfiguration_${msg_num}
    ...     flow_alias=${flow_alias}

Verify in RRCReconfiguration_${msg_num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that CellGroupConfig contains ${bO:\S+} betaOffsets
    ${suffix}=    Set Index    all=${all}    msg_index=${msg_num}
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     uci-OnPUSCH contains (betaOffsets is present and ${bO} is present)
    ...     message_alias=RRCReconfiguration${suffix}
    ...     flow_alias=${flow_alias}

Verify in RRCReconfiguration_${msg:\d+} out of ${all:\d+} for UE${ue:\d+} that ${bO:\S+} betaOffsets are configured and their values are correct
    [Documentation]   Check of betaOffsets values introduced according to TP
    ...               CB008717-K_B3f_ALT6_Configuration_of_aperiodic_CSI_in_TDD_PCell_not_limited_by_UE capability_with_dynamic_betaOffsets
    ...               5G_CP_IF_RRC_13773

    Verify in RRCReconfiguration_${msg} out of ${all} for UE${ue} that ${bO} betaOffsets are configured
    Verify in RRCReconfiguration_${msg} out of ${all} for UE${ue} betaOffsetACK-Index1 values for ${bO} betaOffsets and TDD PCell
    Verify in RRCReconfiguration_${msg} out of ${all} for UE${ue} betaOffsetACK-Index2 values for ${bO} betaOffsets and TDD PCell
    Verify in RRCReconfiguration_${msg} out of ${all} for UE${ue} betaOffsetACK-Index3 values for ${bO} betaOffsets and TDD PCell
    Verify in RRCReconfiguration_${msg} out of ${all} for UE${ue} betaOffsetCSI-Part1-Index1 values for ${bO} betaOffsets and TDD PCell
    Verify in RRCReconfiguration_${msg} out of ${all} for UE${ue} betaOffsetCSI-Part1-Index2 values for ${bO} betaOffsets and TDD PCell
    Verify in RRCReconfiguration_${msg} out of ${all} for UE${ue} betaOffsetCSI-Part2-Index1 values for ${bO} betaOffsets and TDD PCell
    Verify in RRCReconfiguration_${msg} out of ${all} for UE${ue} betaOffsetCSI-Part2-Index2 values for ${bO} betaOffsets and TDD PCell

Verify in RRCReconfiguration_${msg:\d+} out of ${all:\d+} for UE${ue:\d+} that ${bO:\S+} betaOffsets are configured
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue}
    ...     protocol=NR-RRC

    ${suffix}=       Set Index    all=${all}    msg_index=${msg}
    ${comparator}=   Set variable if    '${bO}'=='dynamic'    eq    ne

    Verify That Message Fulfills Query
    ...     ${bO} is present and length(${bO}) ${comparator} 4
    ...     message_alias=RRCReconfiguration${suffix}
    ...     flow_alias=${flow_alias}

Verify in RRCReconfiguration_${msg:\d+} out of ${all:\d+} for UE${ue:\d+} betaOffsetACK-Index1 values for ${bO:\S+} betaOffsets and TDD PCell
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue}
    ...     protocol=NR-RRC

    ${suffix}=    Set Index    all=${all}    msg_index=${msg}
    ${set}=       Set variable if    '${bO}'=='dynamic'    (10,10,11,11)    (11)

    Verify That Message Fulfills Query
    ...     betaOffsetACK-Index1 contains ${set}
    ...     message_alias=RRCReconfiguration${suffix}
    ...     flow_alias=${flow_alias}

Verify in RRCReconfiguration_${msg:\d+} out of ${all:\d+} for UE${ue:\d+} betaOffsetACK-Index2 values for ${bO:\S+} betaOffsets and TDD PCell
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue}
    ...     protocol=NR-RRC

    ${suffix}=    Set Index    all=${all}    msg_index=${msg}
    ${set}=       Set variable if    '${bO}'=='dynamic'    (8,8,8,8)    (8)

    Verify That Message Fulfills Query
    ...     betaOffsetACK-Index2 contains ${set}
    ...     message_alias=RRCReconfiguration${suffix}
    ...     flow_alias=${flow_alias}

Verify in RRCReconfiguration_${msg:\d+} out of ${all:\d+} for UE${ue:\d+} betaOffsetACK-Index3 values for ${bO:\S+} betaOffsets and TDD PCell
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue}
    ...     protocol=NR-RRC

    ${suffix}=    Set Index    all=${all}    msg_index=${msg}
    ${set}=       Set variable if    '${bO}'=='dynamic'    (6,6,6,6)    (6)

    Verify That Message Fulfills Query
    ...     betaOffsetACK-Index3 contains ${set}
    ...     message_alias=RRCReconfiguration${suffix}
    ...     flow_alias=${flow_alias}

Verify in RRCReconfiguration_${msg:\d+} out of ${all:\d+} for UE${ue:\d+} betaOffsetCSI-Part1-Index1 values for ${bO:\S+} betaOffsets and TDD PCell
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue}
    ...     protocol=NR-RRC

    ${suffix}=    Set Index    all=${all}    msg_index=${msg}
    ${set}=       Set variable if    '${bO}'=='dynamic'    (13,13,13,13)    (13)

    Verify That Message Fulfills Query
    ...     betaOffsetCSI-Part1-Index1 contains ${set}
    ...     message_alias=RRCReconfiguration${suffix}
    ...     flow_alias=${flow_alias}

Verify in RRCReconfiguration_${msg:\d+} out of ${all:\d+} for UE${ue:\d+} betaOffsetCSI-Part1-Index2 values for ${bO:\S+} betaOffsets and TDD PCell
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue}
    ...     protocol=NR-RRC

    ${suffix}=    Set Index    all=${all}    msg_index=${msg}
    ${set}=       Set variable if    '${bO}'=='dynamic'    (13,13,13,13)    (13)

    Verify That Message Fulfills Query
    ...     betaOffsetCSI-Part1-Index2 contains ${set}
    ...     message_alias=RRCReconfiguration${suffix}
    ...     flow_alias=${flow_alias}

Verify in RRCReconfiguration_${msg:\d+} out of ${all:\d+} for UE${ue:\d+} betaOffsetCSI-Part2-Index1 values for ${bO:\S+} betaOffsets and TDD PCell
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue}
    ...     protocol=NR-RRC

    ${suffix}=    Set Index    all=${all}    msg_index=${msg}
    ${set}=       Set variable if    '${bO}'=='dynamic'    (18,15,12,13)    (13)

    Verify That Message Fulfills Query
    ...     betaOffsetCSI-Part2-Index1 contains ${set}
    ...     message_alias=RRCReconfiguration${suffix}
    ...     flow_alias=${flow_alias}

Verify in RRCReconfiguration_${msg:\d+} out of ${all:\d+} for UE${ue:\d+} betaOffsetCSI-Part2-Index2 values for ${bO:\S+} betaOffsets and TDD PCell
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue}
    ...     protocol=NR-RRC

    ${suffix}=    Set Index    all=${all}    msg_index=${msg}
    ${set}=       Set variable if    '${bO}'=='dynamic'    (13,12,13,13)    (13)

    Verify That Message Fulfills Query
    ...     betaOffsetCSI-Part2-Index2 contains ${set}
    ...     message_alias=RRCReconfiguration${suffix}
    ...     flow_alias=${flow_alias}

Verify in RRCReconfiguration_${msg_num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that CellGroupConfig contains reportTriggerSize eq 1
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     csi-MeasConfig contains (reportTriggerSize eq 1)
    ...     message_alias=RRCReconfiguration_${msg_num}
    ...     flow_alias=${flow_alias}

Verify in RRCReconfiguration_${msg_num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that CellGroupConfig contains aperiodicTriggerStateList
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     length(aperiodicTriggerStateList) eq 1 and associatedReportConfigInfoList is present
    ...     message_alias=RRCReconfiguration_${msg_num}
    ...     flow_alias=${flow_alias}

Verify in RRCReconfiguration_${msg_num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that aperiodicTriggerStateList is set to release
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    ${suffix}=    Set Index    all=${all}    msg_index=${msg_num}

    Verify That Message Fulfills Query
    ...     aperiodicTriggerStateList contains (release is present)
    ...     message_alias=RRCReconfiguration${suffix}
    ...     flow_alias=${flow_alias}

Verify in RRCReconfiguration_${msg_num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that CellGroupConfig contains reportConfigID eq 1
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     csi-ReportConfigToAddModList contains (reportConfigId eq 1)
    ...     message_alias=RRCReconfiguration_${msg_num}
    ...     flow_alias=${flow_alias}

Verify in RRCReconfiguration_${msg_num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that MCG modification and SCG setup is present
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    ${suffix}=    Set Index    all=${all}    msg_index=${msg_num}

    Verify That Message Fulfills Query
    ...     masterCellGroup is present
    ...     message_alias=RRCReconfiguration${suffix}
    ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
    ...     mrdc-SecondaryCellGroup is present
    ...     message_alias=RRCReconfiguration${suffix}
    ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
    ...     secondaryCellGroup contains (rlc-BearerToAddModList is present and mac-CellGroupConfig is present and physicalCellGroupConfig is present)
     ...    message_alias=RRCReconfiguration${suffix}
    ...     flow_alias=${flow_alias}

Verify in RRCReconfiguration_${num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that secondaryCellGroup contains cellGroupId eq ${cell:\d+} sent for SCG
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    ${suffix}=    Set Index    all=${all}    msg_index=${num}

    Verify That Message Fulfills Query
    ...     mrdc-SecondaryCellGroupConfig contains (cellGroupId eq ${cell})
    ...     message_alias=RRCReconfiguration${suffix}
    ...     flow_alias=${flow_alias}

Verify in RRCReconfiguration_${msg_num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that servCellIndex eq ${servCellIndex:\d+} and ${mimo:\d+} Max-MIMO
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    ${suffix}=    Set Index    all=${all}    msg_index=${msg_num}

    Verify That Message Fulfills Query
    ...     secondaryCellGroup contains (spCellConfig contains (servCellIndex eq ${servCellIndex})
    ...     and (pusch-ServingCellConfig contains (maxMIMO-Layers eq ${mimo}))
    ...     and (pdsch-ServingCellConfig contains (maxMIMO-Layers eq ${mimo})))
    ...     message_alias=RRCReconfiguration${suffix}
    ...     flow_alias=${flow_alias}

Verify in RRCReconfiguration_${num:\d+} out of ${all:\d+} for UE${ue:\d+} that sCellToAddModList contains ${s:\d+} sCells with ${mimo:\d+} Max-MIMO
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue}
    ...     protocol=NR-RRC

    ${expectation}=    KeywordsCB008717.Build Query For SCellToAddModList With Given Number Of Scells And Mimo
    ...     num_of_scells=${s}
    ...     mimo=${mimo}


    ${suffix}=    Set Index    all=${all}    msg_index=${num}

    Verify That Message Fulfills Query
    ...     ${expectation}
    ...     message_alias=RRCReconfiguration${suffix}
    ...     flow_alias=${flow_alias}

Verify in RRCReconfiguration_${msg_num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that sCellToAddModList is not present
     ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     sCellToAddModList is not present
    ...     message_alias=RRCReconfiguration_${msg_num}
    ...     flow_alias=${flow_alias}

Verify in RRCReconfiguration_${msg_num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that A4 measurements related to NRHOIF-1 are removed
    ${flow_alias}=     Get flow name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    ${suffix}=    Set Index    all=${all}    msg_index=${msg_num}

    Verify That Message Fulfills Query
    ...     measConfig contains (measIdToRemoveList contains (1))
    ...     message_alias=RRCReconfiguration${suffix}
    ...     flow_alias=${flow_alias}

Verify in RRCReconfiguration_${msg_num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that A${m:\d+} measurement related to measid-${meas:\d+} is removed
    ${flow_alias}=     Get flow name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    ${suffix}=    Set Index    all=${all}    msg_index=${msg_num}

    Verify That Message Fulfills Query
    ...     measConfig contains (measIdToRemoveList contains (${meas}))
    ...     message_alias=RRCReconfiguration${suffix}
    ...     flow_alias=${flow_alias}

Verify in RRCReconfigurationComplete_${num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that message contains encoded RRCReconfigurationComplete for SCG
    ${flow_alias}=     Get flow name
    ...     ${all}*RRCReconfigurationComplete
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    ${suffix}=    Set Index    all=${all}    msg_index=${num}

    Verify That Message Fulfills Query
    ...     nr-SCG-Response is present
    ...     message_alias=RRCReconfigurationComplete${suffix}
    ...     flow_alias=${flow_alias}

Verify that RRCReconfigurationComplete_${num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that message contains nr-SCG response
    ${flow_alias}=     Get flow name
    ...     ${all}*RRCReconfigurationComplete
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    ${suffix}=    Set Index    all=${all}    msg_index=${num}

    Verify That Message Fulfills Query
    ...     nr-SCG-Response is present
    ...     message_alias=RRCReconfigurationComplete${suffix}
    ...     flow_alias=${flow_alias}

Verify that RRCReconfigurationComplete_${num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that message does not contain nr-SCG response
    ${flow_alias}=     Get flow name
    ...     ${all}*RRCReconfigurationComplete
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    ${suffix}=    Set Index    all=${all}    msg_index=${num}

    Verify That Message Fulfills Query
    ...     nr-SCG-Response is not present
    ...     message_alias=RRCReconfigurationComplete${suffix}
    ...     flow_alias=${flow_alias}

Verify in RRCReconfiguration_${msg_num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that radioBearerConfig contains drb-ToAddModList with ${drb:\d+}-DRB
     ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    ${suffix}=    Set Index    all=${all}    msg_index=${msg_num}

    Verify That Message Fulfills Query
    ...     (length(drb-ToAddModList) eq ${drb})
    ...     message_alias=RRCReconfiguration${suffix}
    ...     flow_alias=${flow_alias}

Verify that ${rrc_message:\S+} contains ${m} measurement results for UE${ue_id:\d+} and measId=${meas_id:\d+}
    ${flow_alias}=     Get flow name
    ...     ${rrc_message}
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     measurementReport contains (measResults is present)
    ...     and measResults contains (measId eq ${meas_id})
    ...     message_alias=${rrc_message}
    ...     flow_alias=${flow_alias}

Verify in RRCReconfiguration_${msg_num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that measObjectToAddModList contains band n${band:\d+}
    ${flow_alias}=     Get flow name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     measObjectToAddModList contains (freqBandIndicatorNR eq ${band})
    ...     message_alias=RRCReconfiguration_${msg_num}
    ...     flow_alias=${flow_alias}

Verify in RRCReconfiguration_${msg_num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that reportConfigToAddModList contains ${event:\S+}
    ${flow_alias}=     Get flow name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     reportConfigToAddModList contains (${event} is present)
    ...     message_alias=RRCReconfiguration_${msg_num}
    ...     flow_alias=${flow_alias}

Verify in RRCReconfiguration_${msg_num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that CellGroupConfig contains cellGroupId eq 0
    ${flow_alias}=     Get flow name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     cellGroupId eq 0
    ...     message_alias=RRCReconfiguration_${msg_num}
    ...     flow_alias=${flow_alias}

Verify that RRCReconfiguration_${msg_num:\d+} out of ${all:\d+} was send for UE${ue_id:\d+} to release SCG and reconfigure MCG for ${drb:\d+}-DRBs
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that mrdc-SecondaryCellGroupConfig is set to release
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that CellGroupConfig contains cellGroupId as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that spCellConfigDedicated contains exactly 3 elements as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that CellGroupConfig contains uplinkBWP-ToAddModList as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that CellGroupConfig contains bwp-Id as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that CellGroupConfig contains bwp-Dedicated as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that firstActiveUplinkBWP-Id is not present as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that CellGroupConfig contains pusch-ServingCellConfig as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that CellGroupConfig contains pdsch-ServingCellConfig as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that CellGroupConfig contains tag-Id as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that statusReportRequired is set to true for ${drb}-DRBs
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that moreThanOneRLC is not present

Verify that RRCReconfiguration_${msg_num:\d+} out of ${all:\d+} was send for UE${ue_id:\d+} to release SCG&reconfigure MCG for ${drb:\d+}-DRBs F_B7b
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that mrdc-SecondaryCellGroupConfig is set to release
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that CellGroupConfig contains cellGroupId as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that spCellConfigDedicated contains exactly 3 elements as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that CellGroupConfig contains uplinkBWP-ToAddModList as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that CellGroupConfig contains bwp-Id as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that CellGroupConfig contains bwp-Dedicated as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that firstActiveUplinkBWP-Id eq 1 as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that CellGroupConfig contains pusch-ServingCellConfig as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that CellGroupConfig contains pdsch-ServingCellConfig as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that CellGroupConfig contains tag-Id as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that statusReportRequired is set to true for ${drb}-DRBs
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that moreThanOneRLC is not present

Verify that RRCReconfiguration_FB7a_${msg_num:\d+} out of ${all:\d+} was sent for UE${ue_id:\d+} to release SCG&reconfigure MCG for ${drb:\d+}-DRBs
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that mrdc-SecondaryCellGroupConfig is set to release
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that CellGroupConfig contains cellGroupId as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that spCellConfigDedicated contains with at least 4 elements as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that CellGroupConfig contains uplinkBWP-ToAddModList as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that CellGroupConfig contains bwp-Id as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that CellGroupConfig contains bwp-Dedicated as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that firstActiveUplinkBWP-Id is not present as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that CellGroupConfig contains pusch-ServingCellConfig as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that CellGroupConfig contains pdsch-ServingCellConfig as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that CellGroupConfig contains tag-Id as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that statusReportRequired is set to true for ${drb}-DRBs
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that moreThanOneRLC is not present

Verify that RRCReconfiguration_${msg_num:\d+} out of ${all:\d+} was sent for UE${ue_id:\d+} for ${d:\d+}-DRBs with aperCSI and ${bO:\S+} betaOffsets
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that mrdc-SecondaryCellGroupConfig is set to release
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that CellGroupConfig contains cellGroupId as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that spCellConfigDedicated contains with at least 4 elements as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that CellGroupConfig contains uplinkBWP-ToAddModList as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that CellGroupConfig contains bwp-Id as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that CellGroupConfig contains bwp-Dedicated as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that CellGroupConfig contains ${bO} betaOffsets as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that firstActiveUplinkBWP-Id is not present as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that CellGroupConfig contains pusch-ServingCellConfig as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that CellGroupConfig contains pdsch-ServingCellConfig as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that CellGroupConfig contains tag-Id as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that CellGroupConfig contains reportTriggerSize eq 1 as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that CellGroupConfig contains aperiodicTriggerStateList as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that CellGroupConfig contains csi-ReportConfigToAddModList as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that statusReportRequired is set to true for ${d}-DRBs
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that moreThanOneRLC is not present

Verify that SCGFailureInformation_${n:\d+} out of ${all:\d+} was completed RLF in SCG
    Verify in SCGFailureInformation_${n} out of ${all} that scgInformationFailure is present and RLF in SCG

Verify that RRCReconfigurationcomplete_${msg_num:\d+} out of ${all:\d+} was send for UE${ue_id:\d+} in step-by-step message flow
    Verify in RRCReconfigurationComplete_${msg_num} out of ${all} for UE${ue_id} that rrcReconfigurationComplete is present

Verify that RRCReconfigurationcomplete_${msg_num:\d+} out of ${all:\d+} was send for UE${ue_id:\d+}
    Verify in RRCReconfigurationComplete_${msg_num} out of ${all} for UE${ue_id} that message rrcReconfigurationComplete is present

Verify in RRCReconfigurationComplete_${msg_num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that rrcReconfigurationComplete is present
    ${flow_alias}=     Get flow name
    ...     ${all}*RRCReconfigurationComplete
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     rrcReconfigurationComplete is present
    ...     message_alias=RRCReconfigurationComplete_${msg_num}
    ...     flow_alias=${flow_alias}

Verify in RRCReconfiguration_${msg_num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that mrdc-SecondaryCellGroupConfig is set to release
    Verify That Message Fulfills Query
    ...     mrdc-SecondaryCellGroupConfig contains (release is present)
    ...     message_alias=RRCReconfiguration_1st
    ...     flow_alias=takeback_RRCReconfiguration

Verify in RRCReconfiguration_${msg_num:\d+} out of ${all:\d+} for UE${ue:\d+} that statusReportRequired is set to ${status:\S+} for ${drb:\d+}-DRBs
    ${expectation}=    KeywordsCB008717.Message To Check    container=drb-ToAddModList
    ...     single_expectation=statusReportRequired eq "${status}"    number_of_occurrences=${drb}

    Verify That Message Fulfills Query
    ...     ${expectation}
    ...     message_alias=RRCReconfiguration_1st
    ...     flow_alias=takeback_RRCReconfiguration

Verify in RRCReconfiguration_${msg_num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that moreThanOneRLC is not present
    Verify That Message Fulfills Query
    ...     moreThanOneRLC is not present
    ...     message_alias=RRCReconfiguration_1st
    ...     flow_alias=takeback_RRCReconfiguration

Verify in RRCReconfiguration_${msg_num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that CellGroupConfig contains cellGroupId as UECtxModResp
    Verify That Message Fulfills Query
    ...     cellGroupId eq 0
    ...     message_alias=RRCReconfiguration_1st
    ...     flow_alias=takeback_RRCReconfiguration

Verify in RRCReconfiguration_${msg:\d+} out of ${all:\d+} for UE${ue:\d+} that spCellConfigDedicated contains exactly 3 elements as UECtxModResp
    Verify That Message Fulfills Query
    ...     length(spCellConfigDedicated) eq 3
    ...     message_alias=RRCReconfiguration_1st
    ...     flow_alias=takeback_RRCReconfiguration

Verify in RRCReconfiguration_${msg:\d+} out of ${all:\d+} for UE${u:\d+} that spCellConfigDedicated contains with at least 4 elements as UECtxModResp
    Verify That Message Fulfills Query
    ...     length(spCellConfigDedicated) ge 4
    ...     message_alias=RRCReconfiguration_1st
    ...     flow_alias=takeback_RRCReconfiguration

Verify in RRCReconfiguration_${msg_num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that CellGroupConfig contains uplinkBWP-ToAddModList as UECtxModResp
    Verify That Message Fulfills Query
    ...     uplinkBWP-ToAddModList is present
    ...     message_alias=RRCReconfiguration_1st
    ...     flow_alias=takeback_RRCReconfiguration

Verify in RRCReconfiguration_${msg_num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that CellGroupConfig contains bwp-Id as UECtxModResp
    Verify That Message Fulfills Query
    ...     uplinkBWP-ToAddModList contains (bwp-Id eq 1)
    ...     message_alias=RRCReconfiguration_1st
    ...     flow_alias=takeback_RRCReconfiguration

Verify in RRCReconfiguration_${msg_num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that CellGroupConfig contains bwp-Dedicated as UECtxModResp
    Verify That Message Fulfills Query
    ...     bwp-Dedicated contains ((pusch-Config is present) and (srs-Config is present))
    ...     message_alias=RRCReconfiguration_1st
    ...     flow_alias=takeback_RRCReconfiguration

Verify in RRCReconfiguration_${msg_num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that CellGroupConfig contains ${bO:\S+} betaOffsets as UECtxModResp
    Verify That Message Fulfills Query
    ...     uci-OnPUSCH contains (betaOffsets is present and ${bO} is present)
    ...     message_alias=RRCReconfiguration_1st
    ...     flow_alias=takeback_RRCReconfiguration

Verify in RRCReconfiguration_${msg_num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that firstActiveUplinkBWP-Id eq 1 as UECtxModResp
    Verify That Message Fulfills Query
    ...     firstActiveUplinkBWP-Id eq 1
    ...     message_alias=RRCReconfiguration_1st
    ...     flow_alias=takeback_RRCReconfiguration

Verify in RRCReconfiguration_${msg_num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that firstActiveUplinkBWP-Id is not present as UECtxModResp
    Verify That Message Fulfills Query
    ...     firstActiveUplinkBWP-Id is not present
    ...     message_alias=RRCReconfiguration_1st
    ...     flow_alias=takeback_RRCReconfiguration

Verify in RRCReconfiguration_${msg_num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that CellGroupConfig contains pusch-ServingCellConfig as UECtxModResp
    Verify That Message Fulfills Query
    ...     spCellConfig contains (pusch-ServingCellConfig is present)
    ...     message_alias=RRCReconfiguration_1st
    ...     flow_alias=takeback_RRCReconfiguration

Verify in RRCReconfiguration_${msg_num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that CellGroupConfig contains pdsch-ServingCellConfig as UECtxModResp
    Verify That Message Fulfills Query
    ...     spCellConfig contains (pdsch-ServingCellConfig is present)
    ...     message_alias=RRCReconfiguration_1st
    ...     flow_alias=takeback_RRCReconfiguration

Verify in RRCReconfiguration_${msg_num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that CellGroupConfig contains tag-Id as UECtxModResp
    Verify That Message Fulfills Query
    ...    spCellConfig contains (tag-Id eq 0)
    ...    message_alias=RRCReconfiguration_1st
    ...    flow_alias=takeback_RRCReconfiguration

Verify in RRCReconfiguration_${msg_num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that CellGroupConfig contains reportTriggerSize eq 1 as UECtxModResp
    Verify That Message Fulfills Query
    ...     csi-MeasConfig contains (reportTriggerSize eq 1)
    ...    message_alias=RRCReconfiguration_1st
    ...    flow_alias=takeback_RRCReconfiguration

Verify in RRCReconfiguration_${msg:\d+} out of ${all:\d+} for UE${ue_id:\d+} that CellGroupConfig contains aperiodicTriggerStateList as UECtxModResp
    Verify That Message Fulfills Query
    ...     length(aperiodicTriggerStateList) eq 1 and associatedReportConfigInfoList is present
    ...    message_alias=RRCReconfiguration_1st
    ...    flow_alias=takeback_RRCReconfiguration

Verify in RRCReconfiguration_${m:\d+} out of ${all:\d+} for UE${ue_id:\d+} that CellGroupConfig contains csi-ReportConfigToAddModList as UECtxModResp
    Verify That Message Fulfills Query
    ...     csi-ReportConfigToAddModList contains (reportConfigId eq 1)
    ...    message_alias=RRCReconfiguration_1st
    ...    flow_alias=takeback_RRCReconfiguration

Verify in RRCReconfigurationComplete_${msg_num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that message rrcReconfigurationComplete is present
    Verify That Message Fulfills Query
    ...    rrcReconfigurationComplete is present
    ...    message_alias=RRCReconfigurationComplete_1st
    ...    flow_alias=takeback_RRCReconfiguration

Verify that RRCRelase_${msg_num:\d+} out of ${all:\d+} was send for UE${ue_id:\d+}
    Verify in RRCRelase_${msg_num} out of ${all} for UE${ue_id} that message rrc-TransactionIdentifier is present
    Verify in RRCRelase_${msg_num} out of ${all} for UE${ue_id} that message criticalExtensions: rrcRelease is present
    Verify in RRCRelase_${msg_num} out of ${all} for UE${ue_id} that message rrcRelease is present


Verify in RRCRelase_${msg_num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that message rrc-TransactionIdentifier is present
    Verify That Message Fulfills Query
    ...    rrc-TransactionIdentifier is present
    ...    message_alias=RRCRelease_1
    ...    flow_alias=takeback_RRCReconfiguration

Verify in RRCRelase_${msg_num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that message criticalExtensions: rrcRelease is present
    Verify That Message Fulfills Query
    ...    criticalExtensions contains (rrcRelease is present)
    ...    message_alias=RRCRelease_1
    ...    flow_alias=takeback_RRCReconfiguration

Verify in RRCRelase_${msg_num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that message rrcRelease is present
    Verify That Message Fulfills Query
    ...    rrcRelease is present
    ...    message_alias=RRCRelease_1
    ...    flow_alias=takeback_RRCReconfiguration

Verify in RRCReconf_${n:\d+} out of ${all:\d+} for UE${ue:\d+} that A${num:\d} meas was configured with reportConfigId ${id:\d}
        ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     (reportConfigToAddModList contains (eventA${num}  is present)) and (reportConfigToAddModList contains (reportConfigId eq ${id}))
    ...     message_alias=RRCReconfiguration_${n}
    ...     flow_alias=${flow_alias}

Verify in RRCReconf_${n:\d+} out of ${all:\d+} for UE${ue:\d+} if A${num:\d+} id ${id:\d+} is configured for ${y:\d} measObjects with startID ${x:\d}
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue}
    ...     protocol=NR-RRC

   ${meas_ids_query}=   KeywordsCB008717.Build Query For MeasIds With Given Number Of MeasObjects StartID And ReportID
    ...     num_of_measObjects=${y}
    ...     startID=${x}
    ...     reportID=${id}

   Verify That Message Fulfills Query
    ...     ${meas_ids_query}
    ...     message_alias=RRCReconfiguration_${n}
    ...     flow_alias=${flow_alias}

Verify in RRCReconf_${n:\d+} out of ${all:\d+} for UE${ue:\d+} that measObjToAddModList contains ${y:\d} measObj with n${fr:\d+} and startID ${x:\d}
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue}
    ...     protocol=NR-RRC

    ${meas_objects_query}=   KeywordsCB008717.Build Query For MeasObjectToAddModList With Given Number Of MeasObjects Freq And StartID
    ...     num_of_measObjects=${y}
    ...     freq=${fr}
    ...     startID=${x}

   Verify That Message Fulfills Query
    ...     ${meas_objects_query}
    ...     message_alias=RRCReconfiguration_${n}
    ...     flow_alias=${flow_alias}

#Nb6a
Verify that RRCReconfiguration_${msg_num:\d+} out of ${all:\d+} was send for UE${ue:\d+} to release SCG, reconfigure MCG for ${drb:\d+}-DRBs with A1
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue} that mrdc-SecondaryCellGroupConfig is set to release
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue} that CellGroupConfig contains cellGroupId as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue} that spCellConfigDedicated contains exactly 3 elements as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue} that CellGroupConfig contains uplinkBWP-ToAddModList as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue} that CellGroupConfig contains bwp-Id as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue} that CellGroupConfig contains bwp-Dedicated as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue} that firstActiveUplinkBWP-Id eq 1 as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue} that CellGroupConfig contains pusch-ServingCellConfig as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue} that CellGroupConfig contains pdsch-ServingCellConfig as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue} that CellGroupConfig contains tag-Id as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue} that reportConfigToAddModList has eventA1
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue} that measIdToAddModList contains one measId, measObjectId, reportConfId
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue} that statusReportRequired is set to true for ${drb}-DRBs
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue} that moreThanOneRLC is not present

Verify in RRCReconfiguration_${n:\d+} out of ${all:\d+} for UE${ue:\d+} that measIdToAddModList contains one measId, measObjectId, reportConfId
    Verify That Message Fulfills Query
    ...     length(measIdToAddModList) eq 1
    ...     message_alias=RRCReconfiguration_1st
    ...     flow_alias=takeback_RRCReconfiguration

    Verify That Message Fulfills Query
    ...     measIdToAddModList contains ((measId is present) and (measObjectId is present) and (reportConfigId is present))
    ...     message_alias=RRCReconfiguration_1st
    ...     flow_alias=takeback_RRCReconfiguration

Verify in RRCReconfiguration_${msg_num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that reportConfigToAddModList has ${event:\S+}
    Verify That Message Fulfills Query
    ...     reportConfigToAddModList contains (${event} is present)
    ...     message_alias=RRCReconfiguration_1st
    ...     flow_alias=takeback_RRCReconfiguration

#NB6b
Verify that RRCReconfiguration_${n:\d+} out of ${all:\d+} was sent for band n${band:\d+}, UE${u:\d+}, ${d:\d+} DRB
    Verify in RRCReconfiguration_${n} out of ${all} for UE${u} that radioBearerConfig contains drb-ToAddModList with ${d}-DRB
    Verify in RRCReconfiguration_${n} out of ${all} for UE${u} that measObjectToAddModList contains band n${band}
    Verify in RRCReconfiguration_${n} out of ${all} for UE${u} that CellGroupConfig contains cellGroupId eq 0
    Verify in RRCReconfiguration_${n} out of ${all} for UE${u} that CellGroupConfig contains uplinkBWP-ToAddModList
    Verify in RRCReconfiguration_${n} out of ${all} for UE${u} that CellGroupConfig contains bwp-Dedicated
    Verify in RRCReconfiguration_${n} out of ${all} for UE${u} that CellGroupConfig contains reportTriggerSize eq 1
    Verify in RRCReconfiguration_${n} out of ${all} for UE${u} that CellGroupConfig contains reportConfigID eq 1

Verify that RRCReconfiguration_${n:\d+} out of ${a:\d+} was sent for UE${u:\d+}, ${d:\d+}-DRBs
    Verify in RRCReconfiguration_${n} out of ${a} for UE${u} that MCG modification and SCG setup is present
    Verify in RRCReconfiguration_${n} out of ${a} for UE${u} that secondaryCellGroup contains cellGroupId eq 1 sent for SCG
    Verify in RRCReconfiguration_${n} out of ${a} for UE${u} that servCellIndex eq 1 and 2 Max-MIMO
    Verify in RRCReconfiguration_${n} out of ${a} for UE${u} that radioBearerConfig contains drb-ToAddModList with ${d}-DRB
    Verify in RRCReconfiguration_${n} out of ${a} for UE${u} that measConfig contains A1 and A4 measurements to be removed

Verify in RRCReconfiguration_${n:\d+} out of ${all:\d+} for UE${u:\d+} that measConfig contains A1 and A4 measurements to be removed

    ${flow_alias}=     Get flow name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    ${suffix}=    Set Index    all=${all}    msg_index=${n}

    Verify That Message Fulfills Query
    ...     measConfig is present and length(measIdToRemoveList) eq 5
    ...     message_alias=RRCReconfiguration${suffix}
    ...     flow_alias=${flow_alias}

Verify that RRCReconfiguration_${msg_num:\d+} out of ${all:\d+} was sent for UE${ue_id:\d+} for ${d:\d+}-DRB with reconfigured A1 measurement
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that mrdc-SecondaryCellGroupConfig is set to release
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that CellGroupConfig contains cellGroupId as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that spCellConfigDedicated contains exactly 3 elements as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that CellGroupConfig contains uplinkBWP-ToAddModList as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that CellGroupConfig contains bwp-Id as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that CellGroupConfig contains bwp-Dedicated as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that firstActiveUplinkBWP-Id eq 1 as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that CellGroupConfig contains pusch-ServingCellConfig as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that CellGroupConfig contains pdsch-ServingCellConfig as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that CellGroupConfig contains tag-Id as UECtxModResp
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that reportConfigToAddModList has eventA1
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that measIdToAddModList contains one measId, measObjectId, reportConfId
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that statusReportRequired is set to true for ${d}-DRBs
    Verify in RRCReconfiguration_${msg_num} out of ${all} for UE${ue_id} that moreThanOneRLC is not present


Verify that RRCReconfiguration_${n:\d+} out of ${all:\d+} was correctly sent for band n${band:\d+}, UE${u:\d+}, ${d:\d+} DRB
    Verify in RRCReconfiguration_${n} out of ${all} for UE${u} that radioBearerConfig contains drb-ToAddModList with ${d}-DRB
    Verify in RRCReconfiguration_${n} out of ${all} for UE${u} that measObjectToAddModList contains band n${band}
    Verify in RRCReconfiguration_${n} out of ${all} for UE${u} that CellGroupConfig contains cellGroupId eq 0
    Verify in RRCReconfiguration_${n} out of ${all} for UE${u} that CellGroupConfig contains uplinkBWP-ToAddModList
    Verify in RRCReconfiguration_${n} out of ${all} for UE${u} that CellGroupConfig contains bwp-Dedicated
    Verify in RRCReconfiguration_${n} out of ${all} for UE${u} that reportConfigToAddModList contains eventA1

Verify in SCGFailureInformation_${n:\d+} out of ${all} that scgInformationFailure is present and RLF in SCG
    Verify That Message Fulfills Query
    ...     scgFailureInformation is present
    ...     message_alias=SCGFailureInformation_1
    ...     flow_alias=takeback_RRCReconfiguration

Verify in RRCReconfiguration_${n} that sCellToAddModList contains ${s:\d+} sCells with starting phys_id ${id:\d+}
    ${expectation}=    KeywordsCB008717.Build Query For SCellToAddModList With Given Number Of Scells
    ...     num_of_scells=${s}
    ...     starting_scell_index=${id}

    Verify That Message Fulfills Query
    ...     ${expectation}
    ...     message_alias=RRCReconfiguration_${n}
    ...     flow_alias=takeback_and_CA_RRCReconfiguration

Verify in RRCReconfiguration_${n} that sCellToAddModList contains ${s:\d+} sCells with starting phys_id ${id:\d+} after bearer takeback
    ${expectation}=    KeywordsCB008717.Build Query For SCellToAddModList With Given Number Of Scells
    ...     num_of_scells=${s}
    ...     starting_scell_index=${id}

    Verify That Message Fulfills Query
    ...     ${expectation}
    ...     message_alias=RRCReconfiguration_${n}
    ...     flow_alias=blind_FR1_CA_after_bearer_takeback

Verify in RRCReconfiguration_${n} that A${m:\d+} meas related to measid-${meas:\d+} is removed
    Verify That Message Fulfills Query
    ...     measConfig contains (measIdToRemoveList contains (${meas}))
    ...     message_alias=RRCReconfiguration_${n}
    ...     flow_alias=takeback_and_CA_RRCReconfiguration

Verify in RRCReconfiguration_${n} that measObjToAddModList contains ${y:\d} measObj with n${fr:\d+} and startID ${x:\d}
    ${meas_objects_query}=   KeywordsCB008717.Build Query For MeasObjectToAddModList With Given Number Of MeasObjects Freq And StartID
    ...     num_of_measObjects=${y}
    ...     freq=${fr}
    ...     startID=${x}

   Verify That Message Fulfills Query
    ...     ${meas_objects_query}
    ...     message_alias=RRCReconfiguration_${n}
    ...     flow_alias=takeback_and_CA_RRCReconfiguration

Verify in RRCReconfiguration_${n:\d+} if A${num:\d+} report with id ${rep_id:\d+} is configured for measObjectId ${obj:\d+} and measId ${meas_id:\d+}
   Verify That Message Fulfills Query
    ...     measIdToAddModList contains ((measId eq ${meas_id}) and (measObjectId eq ${obj}) and (reportConfigId eq ${rep_id}))
    ...     message_alias=RRCReconfiguration_${n}
    ...     flow_alias=takeback_and_CA_RRCReconfiguration

Verify in RRCReconfig_${n:\d+} out of ${a:\d+} if A${num:\d+} report id ${rep_id:\d+} configured for measObjId ${obj:\d+} and measId ${meas_id:\d+}
    ${flow_alias}=     Get flow name
    ...     ${a}*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    ${suffix}=    Set Index    all=${a}    msg_index=${n}

   Verify That Message Fulfills Query
    ...     measIdToAddModList contains ((measId eq ${meas_id}) and (measObjectId eq ${obj}) and (reportConfigId eq ${rep_id}))
    ...     message_alias=RRCReconfiguration${suffix}
    ...     flow_alias=${flow_alias}

Verify in RRCReconf_${n:\d+} out of ${all:\d+} for UE${ue:\d+} that A${num:\d} meas was not configured with reportConfigId ${id:\d}

    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     (reportConfigToAddModList contains (eventA${num}  is not present)) and (reportConfigToAddModList contains (reportConfigId eq ${id}))
    ...     message_alias=RRCReconfiguration_${n}
    ...     flow_alias=${flow_alias}

Verify in RRCReconf_${n:\d+} out of ${all:\d+} for UE${ue:\d+} that PCell Switch A1 and PCell Change A2 meas was not configured

    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     (length(reportConfigToAddModList) eq 1) and (reportConfigToAddModList contains (eventA2 is present))
    ...     message_alias=RRCReconfiguration_${n}
    ...     flow_alias=${flow_alias}

Verify in RRCReconfig_${n} out of ${all:\d+} for UE${ue:\d+} that sCellToAddModList contains ${s:\d+} sCells with starting phys_id ${id:\d+}
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue}
    ...     protocol=NR-RRC

    ${expectation}=    KeywordsCB008717.Build Query For SCellToAddModList With Given Number Of Scells
    ...     num_of_scells=${s}
    ...     starting_scell_index=${id}

    ${suffix}=    Set Index    all=${all}    msg_index=${n}

    Verify That Message Fulfills Query
    ...     ${expectation}
    ...     message_alias=RRCReconfiguration${suffix}
    ...     flow_alias=${flow_alias}

Verify in RRCReconfig_${n:\d+} out of ${a:\d+} if A${num:\d} for UE${u:\d+} report id ${rep_id:\d+} with measObj ${obj:\d+} and measId ${meas_id:\d+}
    ${flow_alias}=     Get flow name
    ...     ${a}*RRCReconfiguration
    ...     device=UE_${u}
    ...     protocol=NR-RRC

    ${suffix}=    Set Index    all=${a}    msg_index=${n}

   Verify That Message Fulfills Query
    ...     measIdToAddModList contains ((measId eq ${meas_id}) and (measObjectId eq ${obj}) and (reportConfigId eq ${rep_id}))
    ...     and reportConfigToAddModList contains (eventA${num}  is  present)
    ...     message_alias=RRCReconfiguration${suffix}
    ...     flow_alias=${flow_alias}


Verify in RRCReconfig_${msg_num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that sCellToReleaseList contains ${s:\d+} sCells & A4 does not deconfigure
    ${flow_alias}=     Get flow name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    ${suffix}=    Set Index    all=${all}    msg_index=${msg_num}

    Verify That Message Fulfills Query
    ...     (length(sCellToReleaseList) eq ${s})
    ...     and measid is not present
    ...     message_alias=RRCReconfiguration${suffix}
    ...     flow_alias=${flow_alias}

Verify in RRCReconfiguration_${msg_num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that A${m:\d+} for CA related to measid-${meas:\d+} is removed
    ${flow_alias}=     Get flow name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    ${suffix}=    Set Index    all=${all}    msg_index=${msg_num}

    Verify That Message Fulfills Query
    ...     measConfig contains (measIdToRemoveList contains (${meas}))
    ...     and (reportConfigToRemoveList contains (1))
    ...     message_alias=RRCReconfiguration${suffix}
    ...     flow_alias=${flow_alias}

Verify in RRCReconfig_${n:\d+} out of ${all:\d+} for UE${ue:\d+} that SCell Change A1 and SCell Release A2 and SCell Switch A6 are configured

    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     measConfig contains (length(measIdToAddModList) eq 3)
    ...     and (length(reportConfigToAddModList) eq 3)
    ...     and (reportConfigToAddModList contains (eventA1 is present))
    ...     and (reportConfigToAddModList contains (eventA2 is present))
    ...     and (reportConfigToAddModList contains (eventA6 is present))
    ...     message_alias=RRCReconfiguration_${n}
    ...     flow_alias=${flow_alias}

Verify in RRCReconfig_${msg_num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that sCellToReleaseList contains ${s:\d+} sCells
    ${flow_alias}=     Get flow name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    ${suffix}=    Set Index    all=${all}    msg_index=${msg_num}

    Verify That Message Fulfills Query
    ...     (length(sCellToReleaseList) eq ${s})
    ...     message_alias=RRCReconfiguration${suffix}
    ...     flow_alias=${flow_alias}

Verify in RRCReconfig_${n:\d+} out of ${all:\d+} for UE${ue:\d+} that SCell Change A1 and SCell Release A2 and SCell Switch A6 are deconfigured
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue}
    ...     protocol=NR-RRC

    ${suffix}=    Set Index    all=${all}    msg_index=${n}

    Verify That Message Fulfills Query
    ...     measConfig contains (length(measIdToRemoveList) eq 3)
    ...     and (length(reportConfigToRemoveList) eq 3)
    ...     and (reportConfigToRemoveList contains (3))
    ...     and (reportConfigToRemoveList contains (4))
    ...     and (reportConfigToRemoveList contains (5))
    ...     message_alias=RRCReconfiguration${suffix}
    ...     flow_alias=${flow_alias}

Verify in RRCReconfig_${n:\d+} out of ${all:\d+} for UE${ue:\d+} that SCell Addition A1 measurement is configured
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue}
    ...     protocol=NR-RRC

    ${suffix}=    Set Index    all=${all}    msg_index=${n}

    Verify That Message Fulfills Query
    ...     measConfig contains (reportConfigToAddModList contains (eventA1 is present))
    ...     and (length(measIdToAddModList) eq 1)
    ...     message_alias=RRCReconfiguration${suffix}
    ...     flow_alias=${flow_alias}

Verify that RRCReconfiguration_${n:\d+} out of ${all:\d+} was completed for gNB${gnb_id:\d+} and UE${ue_id:\d+} containing NR-DC setup
    Verify in RRCReconfiguration_${n} out of ${all} for UE${ue_id} that MCG modification and SCG setup is present
    Verify in RRCReconfiguration_${n} out of ${all} for UE${ue_id} that secondaryCellGroup contains cellGroupId eq 1 sent for SCG
    Verify in RRCReconfigurationComplete_${n} out of ${all} for UE${ue_id} that message contains encoded RRCReconfigurationComplete for SCG

Verify in RRCReconfiguration_${n} that csi-ReportConfigIDs Related To SCells And Bemforming Configuration Are Present
    Verify That Message Fulfills Query
    ...     csi-MeasConfig contains (csi-ReportConfigToAddModList contains (reportConfigId eq 13))
    ...     and csi-MeasConfig contains (csi-ReportConfigToAddModList contains (reportConfigId eq 14))
    ...     and csi-MeasConfig contains (csi-ReportConfigToAddModList contains (reportConfigId eq 15))
    ...     and csi-MeasConfig contains (csi-ReportConfigToAddModList contains (reportConfigId eq 22))
    ...     and csi-MeasConfig contains (csi-ReportConfigToAddModList contains (reportConfigId eq 23))
    ...     message_alias=RRCReconfiguration_${n}
    ...     flow_alias=takeback_and_CA_RRCReconfiguration

Verify in RRCReconfiguration_${n} that csi-ReportConfigIDs Related To SCells And Bemforming Configuration Are Present After Bearer Takeback
    Verify That Message Fulfills Query
    ...     csi-MeasConfig contains (csi-ReportConfigToAddModList contains (reportConfigId eq 13))
    ...     and csi-MeasConfig contains (csi-ReportConfigToAddModList contains (reportConfigId eq 14))
    ...     and csi-MeasConfig contains (csi-ReportConfigToAddModList contains (reportConfigId eq 15))
    ...     and csi-MeasConfig contains (csi-ReportConfigToAddModList contains (reportConfigId eq 22))
    ...     and csi-MeasConfig contains (csi-ReportConfigToAddModList contains (reportConfigId eq 23))
    ...     message_alias=RRCReconfiguration_${n}
    ...     flow_alias=blind_FR1_CA_after_bearer_takeback

Verify in RRCReconfig_${n:\d+} out of ${a:\d+} for UE${u:\d+} that A${nr:\d} for CA related report id ${rp_id:\d+} and ${len:\d+} measids are removed

    ${flow_alias}=     Get Flow Name
    ...     ${a}*RRCReconfiguration
    ...     device=UE_${u}
    ...     protocol=NR-RRC

   Verify That Message Fulfills Query
    ...     measConfig contains (reportConfigToRemoveList contains (${rp_id}))
    ...     and (length(measIdToRemoveList) eq ${len})
    ...     message_alias=RRCReconfiguration_${n}
    ...     flow_alias=${flow_alias}

Verify that MeasurementReport_${n:\d+} out of ${all:\d+} contains ${m:\S+} measurement result for UE${ue:\d+} and measId=${meas_id:\d+}
    ${flow_alias}=     Get flow name
    ...     ${all}*MeasurementReport
    ...     device=UE_${ue}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     measurementReport contains (measResults is present)
    ...     and measResults contains (measId eq ${meas_id})
    ...     message_alias=MeasurementReport_${n}
    ...     flow_alias=${flow_alias}

Verify in RRCReconfig_${n:\d+} out of ${all:\d+} for UE${ue:\d+} that SCell Release A2 and SCell Switch A6 are deconfigured
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue}
    ...     protocol=NR-RRC

    ${suffix}=    Set Index    all=${all}    msg_index=${n}

    Verify That Message Fulfills Query
    ...     measConfig contains (length(measIdToRemoveList) eq 2)
    ...     and (length(reportConfigToRemoveList) eq 2)
    ...     and (reportConfigToRemoveList contains (3))
    ...     and (reportConfigToRemoveList contains (4))
    ...     message_alias=RRCReconfiguration${suffix}
    ...     flow_alias=${flow_alias}

Verify in RRCReconfig_${n:\d+} out of ${a:\d+} that after takeback with blindCA for UE${u:\d+} csi-ReportCfgIDs Related To SCells And BF Are Present

    ${flow_alias}=     Get flow name
    ...     ${a}*RRCReconfiguration
    ...     device=UE_${u}
    ...     protocol=NR-RRC

    ${suffix}=    Set Index    all=${a}    msg_index=${n}

    Verify That Message Fulfills Query
    ...     csi-MeasConfig contains (csi-ReportConfigToAddModList contains (reportConfigId eq 13))
    ...     and csi-MeasConfig contains (csi-ReportConfigToAddModList contains (reportConfigId eq 21))
    ...     message_alias=RRCReconfiguration${suffix}
    ...     flow_alias=${flow_alias}

Verify in RRCReconfig_${n:\d+} out of ${all:\d+} for UE${ue:\d+} that MeasConfig contains ${num}-items in measIdToAddModList
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue}
    ...     protocol=NR-RRC

    ${suffix}=    Set Index    all=${all}    msg_index=${n}

    Verify That Message Fulfills Query
    ...     (length(measIdToAddModList) eq ${num})
    ...     message_alias=RRCReconfiguration${suffix}
    ...     flow_alias=${flow_alias}

Verify in RRCReconfigation_${num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that sCellToReleaseList contains sCells with indexes ${scell_index_list}
    ${flow_alias}=     Get flow name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    ${suffix}=    Set Index    all=${all}    msg_index=${num}
    ${expectation}=    KeywordsCB008717.Build Query For SCellToReleaseList With Given Scell Index List
    ...     scell_index_list=${scell_index_list}

    Verify That Message Fulfills Query
    ...     ${expectation}
    ...     message_alias=RRCReconfiguration${suffix}
    ...     flow_alias=${flow_alias}

Verify in RRCReconfiguration_${num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that meaaObjectToRemoveList contains meas objects ${meas_obj_list}
    ${flow_alias}=     Get flow name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    ${suffix}=    Set Index    all=${all}    msg_index=${num}
    ${expectation}=    KeywordsCB008717.Build Query For MeasObjectsToRemoveList With Given Meas Objects List
    ...    meas_obj_list=${meas_obj_list}

    Verify That Message Fulfills Query
    ...     ${expectation}
    ...     message_alias=RRCReconfiguration${suffix}
    ...     flow_alias=${flow_alias}

Verify in RRCReconfiguration that csi-ReportConfigIDs Related To SCells And Bemforming Configuration Are Present in flow alias
    [Arguments]    ${report_list}    ${message_alias}     ${all}      ${ue}

    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue}
    ...     protocol=NR-RRC

    ${expectation}=     KeywordsCB008717.Build Query For Csi ReportConfigToAddModList With Given ReportConfigIds
    ...     report_list=${report_list}

    Verify That Message Fulfills Query
    ...     ${expectation}
    ...     message_alias=${message_alias}
    ...     flow_alias=${flow_alias}

Verify in RRCReconfiguration_${num:\d+} out of ${all:\d+} for UE${ue_id:\d+} that meaaObjectToRemoveList contains ${n:\d+} measObjects
    ${flow_alias}=     Get flow name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    ${suffix}=    Set Index    all=${all}    msg_index=${num}

        Verify That Message Fulfills Query
    ...     length(measObjectToRemoveList) eq ${n}
    ...     message_alias=RRCReconfiguration${suffix}
    ...     flow_alias=${flow_alias}
