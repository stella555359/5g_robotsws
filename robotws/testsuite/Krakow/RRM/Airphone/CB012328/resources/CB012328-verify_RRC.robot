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
Verify that A3, A5, A2, A4 meauserments were configured for UE${ue_id:\d+} in RRCReconfiguration message
    ${flow_alias_rrc}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     (eventA2 is present) and (eventA3 is present) and (eventA5 is present)    #and (event A4 is present)
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}

Verify that A3, A5, A2 meauserments were configured for UE${ue_id:\d+} in RRCReconfiguration message
    ${flow_alias_rrc}=     Get Flow Name
    ...     2*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     (eventA2 is present) and (eventA3 is present) and (eventA5 is present)
    ...     message_alias=RRCReconfiguration_1
    ...     flow_alias=${flow_alias_rrc}

Verify that only A3, A5, A2 meauserments were configured for UE${ue_id:\d+} in RRCReconfiguration message
    ${flow_alias_rrc}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     (eventA2 is present) and (eventA3 is present) and (eventA5 is present) and (eventA4 is not present)
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}

Verify that A4 was NOT configured for UE${ue_id:\d+} in RRCReconfiguration message
    ${flow_alias_rrc}=     Get Flow Name
    ...     2*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     eventA4 is not present
    ...     message_alias=RRCReconfiguration_1
    ...     flow_alias=${flow_alias_rrc}

Verify that DRX was configured for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     2*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     drx-Config is present
    ...     message_alias=RRCReconfiguration_1
    ...     flow_alias=${flow_alias}

Verify that DRX was not configured for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     2*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     drx-Config is not present
    ...     message_alias=RRCReconfiguration_1
    ...     flow_alias=${flow_alias}

Verify that measurements were not uninstalled for UE${ue_id:\d+}
     ${flow_alias}=     Get flow name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     reportConfigToRemoveList is not present
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias}

Verify that DRX was released for UE1
    ${flow_alias}=     Get flow name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     drx-Config is not present
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias}

Verify that A4 was NOT configured for UE${ue_id} after a4RetryTimer
    EXPECT FLOW[timeout=12]: UE_${ue_id} NR-RRC RRCReconfiguration
    FAIL FLOW[timeout=12]: UE_${ue_id} NR-RRC RRCReconfiguration

Expect second RRC Reconfiguration message for UE${ue_id} with timeout=${tmo}s
    EXPECT FLOW[timeout=${tmo}]: UE_${ue_id} NR-RRC 2*RRCReconfiguration

Verify second RRC Reconfiguration message did not occur for UE${ue_id} with timeout=${tmo}s
    FAIL FLOW[timeout=${tmo}]: UE_${ue_id} NR-RRC 2*RRCReconfiguration

Verify A4 measurement setup for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     measIdToAddModList is present
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias}

Verify A4 measurement release for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     measIdToRemoveList is present
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias}


Verify that a4 measurement was activated in second RRCReconfiguration message for UE${ue_id}
    ${flow_alias}=     Get flow name
    ...     2*RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     measIdToAddModList is present
    ...     message_alias=RRCReconfiguration_2
    ...     flow_alias=${flow_alias}

Verify no measurements reconfiguration for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     meaaasConfig is not present
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias}
