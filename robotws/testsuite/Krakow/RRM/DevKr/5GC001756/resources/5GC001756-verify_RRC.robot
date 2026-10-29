*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...      - Dawid Krawczuk <dawid.krawczuk@nokia.com>
...      - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...      - Michał Szymakowski <michal.szymakowski@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    ./5GC001756-common_keywords.robot

*** Keywords ***

Verify in ${to_verify:\d+} out of ${all:\d+} ${rrc_message} that UE${ue_id:\d+} ${drb_num} DRBs were added
    ${flow_alias_rrc}=     Get Flow Name
    ...     ${all}*${rrc_message}
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     (length(drb-ToAddModList) eq 1)
    ...     message_alias=${rrc_message}[${to_verify}]
    ...     flow_alias=${flow_alias_rrc}

Verify that UE${ue_id:\d+} RRCSetupRequest establishmnet cause is set to EMERGENCY
    ${flow_alias_rrc}=     Get Flow Name
    ...     RRCSetupRequest
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     (establishmentCause eq "emergency")
    ...     message_alias=RRCSetupRequest
    ...     flow_alias=${flow_alias_rrc}

Verify that UE${ue_id:\d+} RRCReconfiguration that target PCI: ${pci:\d+} is present
    ${flow_alias_rrc}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     (reconfigurationWithSync contains (physCellId eq ${pci}))
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}
