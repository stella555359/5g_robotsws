*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...       - Konrad Krzyzak <konrad.krzyzak@nokia.com>
...       - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...       - Michal Szymakowski 	<michal.szymakowski@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>


*** Keywords ***
##### RRCReconfiguration keywords #####
Verify RRCReconfiguration has masterCellGroup, secondaryCellGroup, logicalChannelIdentity and radioBearerConfig2 for UE${ue:\d+}
    Log  Verify RRCReconfiguration has masterCellGroup, secondaryCellGroup, logicalChannelIdentity and radioBearerConfig2 for UE${ue}
    ${flow_alias}=     Get flow name
    ...     RRCReconfiguration
    ...     device=UE_${ue}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     masterCellGroup is present and mrdc-SecondaryCellGroupConfig is present and
    ...     mrdc-SecondaryCellGroupConfig contains (secondaryCellGroup contains (logicalChannelIdentity is present))
    ...     and radioBearerConfig2 is present
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias}

Verify in RRCReconfiguration that rlc-BearerToAddModList has ${num_bearers} elements with logicalChannelIdentity for UE${ue:\d+}
    ${flow_alias}=     Get flow name
    ...     RRCReconfiguration
    ...     device=UE_${ue}
    ...     protocol=NR-RRC

    verify_bearers_in_RRCReconfiguration    ${flow_alias}    RRCReconfiguration    ${num_bearers}

Verify A4 measurement release for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     2*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     measIdToRemoveList is present
    ...     message_alias=RRCReconfiguration_1
    ...     flow_alias=${flow_alias}

Verify DRX configuration for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     2*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     drx-Config is present
    ...     message_alias=RRCReconfiguration_2
    ...     flow_alias=${flow_alias}

Verify that ${rrc_message:\S+} contains measurement results of PSCell with PCIs [${PCIs}] for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     ${rrc_message}
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    @{PCI_list}    Split To List    ${PCIs}
    ${length}=     Get Length       ${PCI_list}

     Verify That Message Fulfills Query
     ...     length(measResultListNR) eq ${length}
     ...     message_alias=${rrc_message}
     ...     flow_alias=${flow_alias}

    FOR    ${PCI}    IN    @{PCI_list}
        Verify That Message Fulfills Query
        ...     measResultNeighCells contains ((physCellId contains (${PCI})) and (resultsSSB-Cell is present))
        ...     message_alias=${rrc_message}
        ...     flow_alias=${flow_alias}
    END

Verify in RRCReconfiguration that sk-Counter is set to ${value} for UE${ue:\d+}
    ${flow_alias}=     Get flow name
    ...     RRCReconfiguration
    ...     device=UE_${ue}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     sk-Counter eq ${value}
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias}

Verify that initial PDU session for UE${ue_id:\d+} contains ${qos_number:\d+} qos flows
    ${flow_alias}=  Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     (length(drb-ToAddModList) eq ${qos_number})
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias}

Verify that A2 for redirection is configured for UE${ue:\d+} in RRCReconfiguration message
    ${flow_alias}=     Get flow name
    ...     RRCReconfiguration
    ...     device=UE_${ue}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     length(measObjectToAddModList) eq 1 and ssbFrequency eq ${A2_redirect_ssb_freq} and eventA2 is present
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias}

Verify that A2 for redirection is configured for UE${ue:\d+} in ${msg:\d+} out of ${all:\d+} RRCReconfiguration message
    ${flow_alias}=     Get flow name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     length(measObjectToAddModList) eq 1 and ssbFrequency eq ${A2_redirect_ssb_freq} and eventA2 is present
    ...     message_alias=RRCReconfiguration_${msg}
    ...     flow_alias=${flow_alias}

Verify that A2 measurements are configured for UE${ue_id:\d+} in ${msg:\d+} out of ${all:\d+} RRCReconfiguration message
    ${flow_alias_rrc}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     eventA2 is present
    ...     message_alias=RRCReconfiguration_${msg}
    ...     flow_alias=${flow_alias_rrc}

Verify that A2 measurements are configured for UE${ue_id:\d+} in RRCReconfiguration message
    ${flow_alias_rrc}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     eventA2 is present
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}

Verify that A3,A5 measurements are not configured for UE${ue_id:\d+} in ${msg:\d+} out of ${all:\d+} RRCReconfiguration message
    ${flow_alias_rrc}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     eventA3 is not present and eventA5 is not present
    ...     message_alias=RRCReconfiguration_${msg}
    ...     flow_alias=${flow_alias_rrc}

Verify that A3,A5 measurements are not configured for UE${ue_id:\d+} in RRCReconfiguration message
    ${flow_alias_rrc}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     eventA3 is not present and eventA5 is not present
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}

Verify that A2 measurements are not deactivated for UE${ue_id:\d+} in ${msg:\d+} out of ${all:\d+} RRCReconfiguration message
    ${flow_alias_rrc}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     measIdToRemoveList is not present
    ...     message_alias=RRCReconfiguration_${msg}
    ...     flow_alias=${flow_alias_rrc}

Verify that A2,A3,A5 measurements are not deactivated for UE${ue_id:\d+} in RRCReconfiguration message
    ${flow_alias_rrc}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     measIdToRemoveList is not present
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}

Verify that A2,A3,A5 measurements are deactivated in ${msg:\d+} out of ${all:\d+} RRCReconfiguration message for UE${ue_id:\d+}
    ${flow_alias_rrc}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     length(reportConfigToRemoveList) eq 3 and length(measIdToRemoveList) eq 3
    ...     message_alias=RRCReconfiguration_${msg}
    ...     flow_alias=${flow_alias_rrc}

Verify NR-DC takeback in RRCReconfiguration message for UE${ue_id:\d+}
    ${flow_alias_rrc}=     Get flow name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     (mrdc-SecondaryCellGroupConfig contains (release is present))
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}


Verify physCellId eq ${pci:\d+} in RRCReconfiguration message for UE${ue_id:\d+}
    ${flow_alias_rrc}=     Get flow name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     physCellId eq ${pci}
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}

Verify A4 measurement setup after HO for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     2*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     measIdToAddModList is present
    ...     message_alias=RRCReconfiguration_2
    ...     flow_alias=${flow_alias}

Verify A4 measurement was not installed after HO for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     2*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     measIdToAddModList is present
    ...     message_alias=RRCReconfiguration_2
    ...     flow_alias=${flow_alias}

Verify CB007517 A4 measurement setup after HO for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     eventA4 is present
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias}

Verify A4 measurement was not setup for UE${ue_id}
    ${flow_alias}=     Get flow name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     eventA4 is not present
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias}

Verify in SNodeModificationRequired ${cc} cells were configured for gNB${gnb} for UE${ue_id}
    Log    Verify in SNodeModificationRequired ${cc} cells were configured for gNB${gnb} for UE${ue_id}
    ${flow_alias}=     Get flow name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     length(sCellToAddModList) eq ${cc}
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias}


Verify that RRC:RRCReconfiguration contains refServCellIndicator:pCell, gNB${gnb_id:\d+} for UE${ue_id}
    Log    Verify that RRC:RRCReconfiguration contains refServCellIndicator:pCell, gNB${gnb_id} for UE${ue_id}
    ${flow_alias}=     Get flow name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     refServCellIndicator eq 'pCell'
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias}
