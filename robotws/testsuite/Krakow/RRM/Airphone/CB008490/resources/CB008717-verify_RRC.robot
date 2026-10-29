*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...      - Konrad Krzyzak <konrad.krzyzak@nokia.com>
...      - Karolina Sroczyk <karolina.sroczyk@nokia.com>
...      - Adrianna Zenczak <adrianna.zenczak@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Library     CB8717.py

*** Variables ***
${capabilityRequestFilter_hex_n78_n257}=  '0x800C04D82000'
${capabilityRequestFilter_hex_n71_n257}=  '0x800C100808C0'
${capabilityRequestFilter_hex_n78_n257_n260}=  '0x801404D8201040C0'
${capabilityRequestFilter_hex_n66_n5_n260_n261}=  '0x801C0418207041200200'
${capabilityRequestFilter_hex_n66_n260_n261}=  '0x8014103808304100'
${capabilityRequestFilter_hex_n77_n78_n257}=  '0x801404D820101300'

${query_MCG}=  SEPARATOR=
...          masterCellGroup contains (spCellConfig contains (spCellConfigDedicated contains (
...          (tag-Id eq 0) and (csi-MeasConfig contains (setup is present)))))
&{NRHOIF_TO_MEASOBJECTID}=  1=2  2=3  3=4
&{NRHOIF_TO_MEASID}=  1=1  2=2  3=3

*** Keywords ***
Verify in UECapabilityEnquiry that includeNR-DC IE is set for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     UECapabilityEnquiry
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

   Verify That Message Fulfills Query
    ...     includeNR-DC eq 'true'
    ...     message_alias=UECapabilityEnquiry
    ...     flow_alias=${flow_alias}

Verify in UECapabilityEnquiry that includeNR-DC IE is not present for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     UECapabilityEnquiry
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

   Verify That Message Fulfills Query
    ...     includeNR-DC is not present
    ...     message_alias=UECapabilityEnquiry
    ...     flow_alias=${flow_alias}

Verify in UECapabilityEnquiry that rat-Type eq ${rat_type} for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     UECapabilityEnquiry
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     rat-Type eq ${rat_type}
    ...     message_alias=UECapabilityEnquiry
    ...     flow_alias=${flow_alias}

Verify in UECapabilityEnquiry that message includes request for band:n${fr1:\d+} and band:n${fr2:\d+} for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     UECapabilityEnquiry
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     capabilityRequestFilter is present
    ...     message_alias=UECapabilityEnquiry
    ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
    ...     capabilityRequestFilter eq ${capabilityRequestFilter_hex_n${fr1}_n${fr2}}
    ...     message_alias=UECapabilityEnquiry
    ...     flow_alias=${flow_alias}

Verify in UECapabilityEnquiry that message includes request for bands:n${fr1:\d+},n${fr2_1:\d+},n${fr2_2:\d+} for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     UECapabilityEnquiry
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     capabilityRequestFilter is present
    ...     message_alias=UECapabilityEnquiry
    ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
    ...     capabilityRequestFilter eq ${capabilityRequestFilter_hex_n${fr1}_n${fr2_1}_n${fr2_2}}
    ...     message_alias=UECapabilityEnquiry
    ...     flow_alias=${flow_alias}

Verify in UECapabilityEnquiry that message includes request for bands:n${fr1_1:\d+},n${fr1_2:\d+},n${fr2_1:\d+},n${fr2_2:\d+} for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     UECapabilityEnquiry
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     capabilityRequestFilter is present
    ...     message_alias=UECapabilityEnquiry
    ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
    ...     capabilityRequestFilter eq ${capabilityRequestFilter_hex_n${fr1_1}_n${fr1_2}_n${fr2_1}_n${fr2_2}}
    ...     message_alias=UECapabilityEnquiry
    ...     flow_alias=${flow_alias}

Verify that UECapabilityEnquiry was completed successfully for UE${ue_id:\d+} and band:n${fr1:\d+}, band:n${fr2:\d+}
    Verify in UECapabilityEnquiry that includeNR-DC IE is set for UE${ue_id}
    Verify in UECapabilityEnquiry that rat-Type eq 'nr' for UE${ue_id}
    Verify in UECapabilityEnquiry that message includes request for band:n${fr1} and band:n${fr2} for UE${ue_id}

Verify that AMF${amf_id:\d+} NGAP InitialContextSetup contains ${PDU_count:\d+} PDU sessions
    ${flow_alias}=  get flow name
    ...     procedure=initialContextSetup
    ...     device=AMF${amf_id}

    Verify That Message Fulfills Query
    ...     (PDUSessionResourceSetupListCxtReq is present)
    ...     message_alias=InitialContextSetupRequest
    ...     flow_alias=${flow_alias}

    Verify number of elements on the list within NGAP message
    ...     amf_id=${amf_id}
    ...     procedure_name=initialContextSetup
    ...     message=InitialContextSetupRequest
    ...     list_name=PDUSessionResourceSetupListCxtReq
    ...     element_num=${PDU_count}

    Verify number of elements on the list within NGAP message
    ...     amf_id=${amf_id}
    ...     procedure_name=initialContextSetup
    ...     message=InitialContextSetupResponse
    ...     list_name=PDUSessionResourceSetupListCxtRes
    ...     element_num=${PDU_count}

Verify in RRCReconfiguration for UE${ue_id:\d+} that cellGroup eq ${cell:\d+} and ul-DataSplitTreshold eq ${thresh}
    ${flow_alias_rrc}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     drb-ToAddModList contains (cellGroup eq ${cell}
    ...     and
    ...     ul-DataSplitThreshold eq ${thresh})
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}

Verify in RRCReconfiguration for UE${ue_id:\d+} that secondaryCellGroup contains cellGroupId eq ${cgi:\d+} and physCellId eq ${pci:\d+} for SCG
    ${flow_alias_rrc}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     mrdc-SecondaryCellGroupConfig contains ((cellGroupId eq ${cgi}) and (physCellId eq ${pci}))
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}

Verify in ${num:\S+} out of ${all:\d+} RRCReconfiguration for UE${ue_id:\d+} that SCG contains CGI eq ${cgi:\d+} and PCI eq ${pci:\d+} for SCG
    ${flow_alias_rrc}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     mrdc-SecondaryCellGroupConfig contains ((cellGroupId eq ${cgi}) and (physCellId eq ${pci}))
    ...     message_alias=RRCReconfiguration_${num}
    ...     flow_alias=${flow_alias_rrc}

Verify in RRCReconfiguration for UE${ue:\d+} that servCellIndex eq ${servcell_id:\d+}
    ${flow_alias_rrc}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     mrdc-SecondaryCellGroupConfig contains (servCellIndex eq ${servcell_id})
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}

Verify in RRCReconfiguration for UE${ue:\d+} that ${mimo_ul:\d+} MIMO in UL and ${mimo_dl:\d+} MIMO in DL
    ${flow_alias_rrc}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     (pusch-ServingCellConfig contains (maxMIMO-Layers eq ${mimo_ul}))
    ...     and
    ...     (pdsch-ServingCellConfig contains (maxMIMO-Layers eq ${mimo_dl}))
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}

Verify RRCReconfiguration for ulDataPath set to ulOverLteNrPrimaryPathOverLte for UE${ue_id:\d+}
    Verify in RRCReconfiguration for UE${ue_id} that cellGroup eq 0 and ul-DataSplitTreshold eq 'b102400'
    Verify in RRCReconfiguration for UE${ue_id} that cellGroup eq 1 and ul-DataSplitTreshold eq 'inf'

Verify in ${num:\S+} out of ${all:\d+} RRCReconfiguration for UE${ue:\d+} that ${mimo_ul:\d+} MIMO in UL and ${mimo_dl:\d+} MIMO in DL
    ${flow_alias_rrc}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     (pusch-ServingCellConfig contains (maxMIMO-Layers eq ${mimo_ul}))
    ...     and
    ...     (pdsch-ServingCellConfig contains (maxMIMO-Layers eq ${mimo_dl}))
    ...     message_alias=RRCReconfiguration_${num}
    ...     flow_alias=${flow_alias_rrc}


Verify in RRCReconfiguration that csi-ReportConfigToAddModList is present for UE${ue_id:\d+}
    ${flow_alias_rrc}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     csi-ReportConfigToAddModList is present
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}

Verify in ReconfigurationComplete for UE${ue_id:\d+} that message contains encoded RRCReconfigurationComplete for SCG
    ${flow_alias}=     Get flow name
    ...     RRCReconfigurationComplete
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     nr-SCG-Response is present
    ...     message_alias=RRCReconfigurationComplete
    ...     flow_alias=${flow_alias}

Verify in ReconfigurationComplete for UE${ue_id:\d+} that message does not contain encoded RRCReconfigurationComplete for SCG
    ${flow_alias}=     Get flow name
    ...     RRCReconfigurationComplete
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     nr-SCG-Response is not present
    ...     message_alias=RRCReconfigurationComplete
    ...     flow_alias=${flow_alias}

Verify in ${num:\d+} out of ${all:\d+} ReconfigurationComplete for UE${ue_id:\d+} that message contains encoded RRCReconfigurationComplete for SCG
    ${flow_alias}=     Get flow name
    ...     ${all}*RRCReconfigurationComplete
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     nr-SCG-Response is present
    ...     message_alias=RRCReconfigurationComplete_${num}
    ...     flow_alias=${flow_alias}

Verify that RRCReconfiguration was completed successfully for gNB${gnb_id:\d+} and for UE${ue_id:\d+}
    Log    Verify that RRCReconfiguration was completed successfully for gNB${gnb_id} and for UE${ue_id}
    Verify in RRCReconfiguration for UE${ue_id} that cellGroup eq 0 and ul-DataSplitTreshold eq 'inf'
    Verify in RRCReconfiguration for UE${ue_id} that secondaryCellGroup contains cellGroupId eq 1 and physCellId eq 52 for SCG
    Verify in RRCReconfiguration for UE${ue_id} that servCellIndex eq 1
    Verify in RRCReconfiguration for UE${ue_id} that 2 MIMO in UL and 2 MIMO in DL
    Verify in ReconfigurationComplete for UE${ue_id} that message contains encoded RRCReconfigurationComplete for SCG

Verify that ${rrc_message:\S+} does not contain cfra for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     ${rrc_message}
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     cfra is not present
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias}

Verify that ${rrc_message:\S+} contains cfra for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     ${rrc_message}
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     cfra is present
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias}

Verify that ${msg_in_list:\S+} out of ${all:\d+} ${rrc_message:\S+} contains cfra for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     ${all}*${rrc_message}
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     cfra is present
    ...     message_alias=RRCReconfiguration_${msg_in_list}
    ...     flow_alias=${flow_alias}

Verify that RRCReconfiguration does not contain measGapConfig for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     measGapConfig is not present
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias}

Verify that ${msg_in_list:\S+} out of ${all:\d+} ${rrc_message:\S+} does not contain measGapConfig for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     ${all}*${rrc_message}
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     measGapConfig is not present
    ...     message_alias=RRCReconfiguration_${msg_in_list}
    ...     flow_alias=${flow_alias}

Verify that ${rrc_message:\S+} contains measGapConfig=${value:\S+} for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     ${rrc_message}
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     measGapConfig contains (gapUE contains ('${value}'))
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias}

Verify that ${msg_in_list:\S+} out of ${all:\d+} ${rrc_message:\S+} contains measGapConfig=${value:\S+} for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     ${all}*${rrc_message}
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     measGapConfig contains (gapUE contains ('${value}'))
    ...     message_alias=RRCReconfiguration_${msg_in_list}
    ...     flow_alias=${flow_alias}

Verify that in ${msg:\S+} out of ${all:\d+} ${rrc:\S+} measConfig relate to NRHOIF-${nrhoif:\d+}, band:${band:\d+} and ssb:${ssb:\d+} for UE${ue:\d+}
    ${measObjectId}    Get From Dictionary    ${NRHOIF_TO_MEASOBJECTID}   ${nrhoif}
    ${measId}    Get From Dictionary    ${NRHOIF_TO_MEASID}   ${nrhoif}

    ${flow_alias}=     Get flow name
    ...     ${all}*${rrc}
    ...     device=UE_${ue}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     reportConfigToAddModList contains ((reportConfigId eq 1) and (eventA4 is present))
    ...     message_alias=RRCReconfiguration_${msg}
    ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
    ...     measObjectToAddModList contains (
    ...     (measObjectId eq ${measObjectId}) and (ssbFrequency eq ${ssb}) and (freqBandIndicatorNR eq ${band}))
    ...     message_alias=RRCReconfiguration_${msg}
    ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
    ...     measIdToAddModList contains ((measObjectId eq ${measObjectId}) and (measId eq ${measId}) and (reportConfigId eq 1))
    ...     message_alias=RRCReconfiguration_${msg}
    ...     flow_alias=${flow_alias}

Verify that ${msg_in_list:\S+} out of ${all:\d+} ${rrc_message:\S+} contains ssb-RSRP=${value:\d+} for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     ${all}*${rrc_message}
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     s-MeasureConfig contains (ssb-RSRP eq ${value})
    ...     message_alias=RRCReconfiguration_${msg_in_list}
    ...     flow_alias=${flow_alias}

Verify that RRCReconfiguration does not contain ssb-RSRP for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     measConfig contains (ssb-RSRP is not present)
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias}

Verify that ${msg_in_list:\S+} out of ${all:\d+} ${rrc_message:\S+} does not contain ssb-RSRP for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     ${all}*${rrc_message}
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     measConfig contains (ssb-RSRP is not present)
    ...     message_alias=RRCReconfiguration_${msg_in_list}
    ...     flow_alias=${flow_alias}

Verify that ${rrc_message:\S+} contains ssb-RSRP=${value:\d+} for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     ${rrc_message}
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     s-MeasureConfig contains (ssb-RSRP eq ${value})
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias}

Verify that ${rrc_message:\S+} contains measurement results of PSCell for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     ${rrc_message}
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     measResultNeighCells contains ((resultsSSB-Cell is present) and (rsIndexResults is present))
    ...     message_alias=${rrc_message}
    ...     flow_alias=${flow_alias}

Verify that ${rrc_message:\S+} contains measurement results of PSCell and rsIndexResults is not present for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     ${rrc_message}
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     measResultNeighCells contains ((resultsSSB-Cell is present) and (rsIndexResults is not present))
    ...     message_alias=${rrc_message}
    ...     flow_alias=${flow_alias}

Verify that ${rrc_message:\S+} contains measConfig removing A4 measurements related to NRHOIF-${meas_id:\d+} for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     ${rrc_message}
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     measConfig contains (measIdToRemoveList contains (${meas_id}))
    ...     message_alias=${rrc_message}
    ...     flow_alias=${flow_alias}

Verify that ${rrc_message:\S+} contains measConfig removing A4 measurements related to meas_id=${meas_id:\d+} for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     ${rrc_message}
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     measConfig contains (measIdToRemoveList contains (${meas_id}))
    ...     message_alias=${rrc_message}
    ...     flow_alias=${flow_alias}

Verify that ${msg_in_list:\S+} out of ${all:\d+} RRCReconfiguration contains measConfig removing A4 meas for NRHOIF-${meas_id:\d+} for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     measConfig contains (measIdToRemoveList contains (${meas_id}))
    ...     message_alias=RRCReconfiguration_${msg_in_list}
    ...     flow_alias=${flow_alias}

Verify that UE${ue_id:\d+} sends measurement results of NRCELL-${cell_id:\d+} received in NR-DC A4 measurement report
    ${pci} =    Set Variable If     ${cell_id} == 2    ${nrcell2_pci}
    ...                             ${cell_id} == 3    ${nrcell3_pci}
    ...                             ${cell_id} == 6    ${nrcell6_pci}
    ...                             ${cell_id} == 7    ${nrcell7_pci}

    ${flow_alias}=     Get flow name
    ...     MeasurementReport
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     measResult contains ((resultsSSB-Cell is present) and (rsIndexResults is present))
    ...     message_alias=MeasurementReport
    ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
    ...     measResultListNR contains (physCellId eq ${pci})
    ...     message_alias=MeasurementReport
    ...     flow_alias=${flow_alias}

Verify in RRCReconfiguration that Beam refinement configuration is removed towards the UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     masterCellGroup contains (nzp-CSI-RS-ResourceToReleaseList contains (34 ,35, 36, 37) and
    ...     length(nzp-CSI-RS-ResourceToReleaseList) eq 4)
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
    ...     masterCellGroup contains (nzp-CSI-RS-ResourceSetToReleaseList contains (2) and
    ...     length(nzp-CSI-RS-ResourceSetToReleaseList) eq 1)
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
    ...     masterCellGroup contains (csi-SSB-ResourceSetToAddModList contains (
    ...     csi-SSB-ResourceSetId eq 0 and csi-SSB-ResourceList contains (0) and length(csi-SSB-ResourceList) eq 1))
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
    ...     masterCellGroup contains (csi-ResourceConfigToAddModList contains (
    ...     csi-ResourceConfigId eq 10 and
    ...     csi-RS-ResourceSetList contains (
    ...         nzp-CSI-RS-ResourceSetList is not present and
    ...         csi-SSB-ResourceSetList contains (0) and length(csi-SSB-ResourceSetList) eq 1) and
    ...     bwp-Id eq 1 and
    ...     resourceType eq 'periodic'))
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
    ...     masterCellGroup contains (csi-ReportConfigToAddModList contains
    ...     (reportConfigId eq 2 and reportQuantity contains (ssb-Index-RSRP is present)))
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
    ...     masterCellGroup contains (nrofReportedRS eq 'n1')
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias}

Verify in RRCReconfiguration that Beam refinement configuration is not removed towards the UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     masterCellGroup contains (nzp-CSI-RS-ResourceToReleaseList is not present)
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
    ...     masterCellGroup contains (nzp-CSI-RS-ResourceSetToReleaseList is not present)
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
    ...     masterCellGroup contains (csi-SSB-ResourceSetToAddModList is not present)
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
    ...     masterCellGroup contains (csi-ResourceConfigToAddModList is not present)
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
    ...     masterCellGroup contains (csi-ReportConfigToAddModList is not present)
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
    ...     masterCellGroup contains (nrofReportedRS is not present)
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias}

Verify that AMF${amf_id:\d+} NGAP InitialContextSetup contains ${qos_num:\d+} non-GBR QoS Flows
    ${flow_alias}=  get flow name
    ...     procedure=initialContextSetup
    ...     device=AMF${amf_id}

    Verify That Message Fulfills Query
    ...     (length(QosFlowSetupRequestList) eq ${qos_num})
    ...     message_alias=InitialContextSetupRequest
    ...     flow_alias=${flow_alias}

Verify that ${msg_in_list:\S+} out of ${all:\d+} RRCReconfiguration contains drx-Config eq ${value:\S+} for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     drx-Config contains ('${value}')
    ...     message_alias=RRCReconfiguration_${msg_in_list}
    ...     flow_alias=${flow_alias}

Verify RRCReconfiguration message content after A4 measurement configuration for UE${ue_id:\d+}
    Verify that in 2 out of 2 RRCReconfiguration measConfig relate to NRHOIF-1, band:257 and ssb:2071387 for UE${ue_id}
    Verify that 2 out of 2 RRCReconfiguration contains measGapConfig=setup for UE${ue_id}
    Verify that 2 out of 2 RRCReconfiguration contains ssb-RSRP=127 for UE${ue_id}

Verify RRCReconfiguration message content after A4 measurement configuration with DRX for UE${ue_id:\d+}
    Verify that in 2 out of 3 RRCReconfiguration measConfig relate to NRHOIF-1, band:257 and ssb:2071387 for UE${ue_id}
    Verify that 2 out of 3 RRCReconfiguration does not contain measGapConfig for UE${ue_id}
    Verify that 2 out of 3 RRCReconfiguration contains ssb-RSRP=127 for UE${ue_id}
    Verify that 3 out of 3 RRCReconfiguration contains drx-Config eq setup for UE${ue_id}

Verify that reestablishment cause is set to '${reestab_cause}' in RRC:ReestablishmentRequest for UE${ue_id:\d+}
    ${flow_alias_reestab}=     Get Flow Name
    ...     RRCReestablishmentRequest
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     (reestablishmentCause eq '${reestab_cause}')
    ...     message_alias=RRCReestablishmentRequest
    ...     flow_alias=${flow_alias_reestab}

Verify in RRCRelease that redirectedCarrierInfo is present and carrierFreq is equal ${freq:\d+} for UE${ue_id:\d+}
    ${flow_alias_rrc}=     Get Flow Name
    ...     RRCRelease
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     redirectedCarrierInfo contains (carrierFreq eq ${freq})
    ...     message_alias=RRCRelease
    ...     flow_alias=${flow_alias_rrc}

Verify that A4 measurements are configured for UE${ue_id:\d+} in ${msg:\d+} out of ${all:\d+} RRCReconfiguration message
    ${flow_alias_rrc}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     eventA4 is present
    ...     message_alias=RRCReconfiguration_${msg}
    ...     flow_alias=${flow_alias_rrc}

Verify that A4 measurements are not configured for UE${ue_id:\d+} in RRCReconfiguration message
    ${flow_alias_rrc}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     eventA4 is not present
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}

Verify that measObjects and ReportConfigs are not removed for UE${ue_id:\d+} in RRCReconfiguration message
    ${flow_alias_rrc}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     measObjectToRemoveList is not present
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}

    Verify That Message Fulfills Query
    ...     reportConfigToRemoveList is not present
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}

Verify that A4 measurements are configured for UE${ue_id:\d+} in RRCReconfiguration message
    ${flow_alias_rrc}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     eventA4 is present
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}

Verify that A4 measurements are configured with reused MeasObject and ReportConfig for UE${ue_id:\d+} in RRCReconfiguration message
    ${flow_alias_rrc}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     measObjectToAddModList is not present
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}

     Verify That Message Fulfills Query
    ...     reportConfigToAddModList is not present
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}

    Verify That Message Fulfills Query
    ...     measIdToAddModList contains ((measId ne 1) and (reportConfigId eq 1))
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}

Verify that A4 measurements are not configured for UE${ue_id:\d+} in ${msg:\d+} out of ${all:\d+} RRCReconfiguration message
    ${flow_alias_rrc}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     eventA4 is not present
    ...     message_alias=RRCReconfiguration_${msg}
    ...     flow_alias=${flow_alias_rrc}

Verify that A2,A3,A5 measurements are configured for UE${ue_id:\d+} in RRCReconfiguration message
    ${flow_alias_rrc}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     eventA2 is present and eventA3 is present and eventA5 is present
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}

Verify that A2,A3,A5 measurements are configured for UE${ue_id:\d+} in ${msg:\d+} out of ${all:\d+} RRCReconfiguration message
    ${flow_alias_rrc}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     eventA2 is present and eventA3 is present and eventA5 is present
    ...     message_alias=RRCReconfiguration_${msg}
    ...     flow_alias=${flow_alias_rrc}

Verify that A2,A3,A5 measurements are not configured for UE${ue_id:\d+} in RRCReconfiguration message
    ${flow_alias_rrc}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     eventA2 is not present and eventA3 is not present and eventA5 is not present
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}

Verify that A2,A3,A5 measurements are not configured for UE${ue_id:\d+} in ${msg:\d+} out of ${all:\d+} RRCReconfiguration message
    ${flow_alias_rrc}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     eventA2 is not present and eventA3 is not present and eventA5 is not present
    ...     message_alias=RRCReconfiguration_${msg}
    ...     flow_alias=${flow_alias_rrc}

Verify that A2,A3,A5 measurements are deactivated for UE${ue_id:\d+} in ${msg:\d+} out of ${all:\d+} RRCReconfiguration message
    ${flow_alias_rrc}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     length(reportConfigToRemoveList) eq 3 and length(measIdToRemoveList) eq 3
    ...     message_alias=RRCReconfiguration_${msg}
    ...     flow_alias=${flow_alias_rrc}

    Verify That Message Fulfills Query
    ...     measIdToAddModList is not present
    ...     message_alias=RRCReconfiguration_${msg}
    ...     flow_alias=${flow_alias_rrc}

Verify that A2,A3,A5 measurements are activated for UE${ue_id:\d+} in RRCReconfiguration message
    ${flow_alias_rrc}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     eventA2 is present and eventA3 is present and eventA5 is present
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}

Verify that fullConfig is setup for UE${ue_id:\d+} in RRCReconfiguration message
    ${flow_alias_rrc}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     fullConfig is present
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}

Verify that fullConfig is not present for UE${ue_id:\d+} in ${msg:\d+} out of ${all:\d+} RRCReconfiguration message
    ${flow_alias_rrc}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     fullConfig is not present
    ...     message_alias=RRCReconfiguration_${msg}
    ...     flow_alias=${flow_alias_rrc}

Verify that measurements are not removed for UE${ue_id:\d+} in RRCReconfiguration message
    ${flow_alias_rrc}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     measIdToRemoveList is not present
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}

Verify that AMF${amf_id:\d+} NGAP InitialContextSetup contains only 5QI eq ${5qi_value}
    ${flow_alias}=  get flow name
    ...     procedure=initialContextSetup
    ...     device=AMF${amf_id}

    Verify That Message Fulfills Query
    ...     (PDUSessionResourceSetupListCxtReq is present)
    ...     message_alias=InitialContextSetupRequest
    ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
    ...     (fiveQI eq ${5qi_value})
    ...     message_alias=InitialContextSetupRequest
    ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
    ...     (length(QosFlowSetupRequestList) eq 1)
    ...     message_alias=InitialContextSetupRequest
    ...     flow_alias=${flow_alias}

Verify that measurements are ${status:(activated|not activated)} for UE${ue_id:\d+} in ${msg:\d+} out of ${all:\d+} RRCReconfiguration message
    ${flow_alias_rrc}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    ${state} =  Evaluate    '${status}' == 'activated'
    ${query} =  Set Variable If    ${state}  present  not present

    Verify That Message Fulfills Query
    ...     measIdToAddModList is ${query}
    ...     message_alias=RRCReconfiguration_${msg}
    ...     flow_alias=${flow_alias_rrc}

Verify measIdToRemoveList is ${rm_state} and measIdAddModList is ${add_state} UE${ue_id:\d+} in ${msg:\d+} out of ${all:\d+} RRCReconfiguration
    ${flow_alias_rrc}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     measIdToRemoveList is ${rm_state} and measIdToAddModList is ${add_state}
    ...     message_alias=RRCReconfiguration_${msg}
    ...     flow_alias=${flow_alias_rrc}

Verify that in total ${meas_num:\d+} measurements are configured for UE${ue_id:\d+} in RRCReconfiguration message
        ${flow_alias_rrc}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     length(reportConfigToAddModList) eq ${meas_num}
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}
