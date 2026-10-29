*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...      - Dawid Krawczuk <dawid.krawczuk@nokia.com>
...      - Cezary Dudek <cezary.dudek@nokia.com>
...      - Marek Kieltyka <marek.kieltyka@nokia.com>
...      - Tomasz Pyrek <michal.szymakowski@nokia.com>
...      - Karolina Sroczyk <karolina.sroczyk@nokia.com>
...      - Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
...      - Michal Szymakowski <michal.szymakowski@nokia.com>
...      - Grzegorz Szymik <grzegorz.szymik@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    CB008379-common_keywords.robot

*** Keywords ***
Verify in ${rrc_message:\S+} that UE${ue_id:\d+} SRB-${srb_id:\d+} was added
    ${flow_alias_rrc}=     get flow name
    ...     ${rrc_message}
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     (srb-ToAddModList contains (srb-Identity eq ${srb_id}))
    ...     message_alias=${rrc_message}
    ...     flow_alias=${flow_alias_rrc}

Verify in ${rrc_message:\S+} that UE${ue_id:\d+} SRB-${srb_id:\d+} was not released
    ${flow_alias_rrc}=     get flow name
    ...     ${rrc_message}
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     (srb-ToReleaseList is not present)
    ...     message_alias=${rrc_message}
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

Verify that in ${msg_in_list:\S+} out of ${all:\d+} ${rrc_message:\S+} UE${ue_id:\d+} ${drb_num:\d+} DRBs were added
    ${flow_alias_rrc}=     Get flow name
    ...     ${all}*${rrc_message}
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Run Keyword If    ${drb_num} > 0
    ...     Verify That Message Fulfills Query
    ...     (length(drb-ToAddModList) eq ${drb_num})
    ...     message_alias=RRCReconfiguration_${msg_in_list}
    ...     flow_alias=${flow_alias_rrc}

    Run Keyword If    ${drb_num} == 0
    ...     Verify That Message Fulfills Query
    ...     (drb-ToAddModList is not present)
    ...     message_alias=RRCReconfiguration_${msg_in_list}
    ...     flow_alias=${flow_alias_rrc}

Verify that in ${msg_in_list:\S+} out of ${all:\d+} ${rrc_message:\S+} UE${ue_id:\d+} ${drb_num:\d+} DRBs were released
    ${flow_alias_rrc}=     Get flow name
    ...     ${all}*${rrc_message}
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Run Keyword If    ${drb_num} > 0
    ...     Verify That Message Fulfills Query
    ...     (length(drb-ToReleaseList) eq ${drb_num})
    ...     message_alias=RRCReconfiguration_${msg_in_list}
    ...     flow_alias=${flow_alias_rrc}

    Run Keyword If    ${drb_num} == 0
    ...     Verify That Message Fulfills Query
    ...     (drb-ToReleaseList is not present)
    ...     message_alias=RRCReconfiguration_${msg_in_list}
    ...     flow_alias=${flow_alias_rrc}

Verify in ${msg_in_list:\S+} out of ${all:\d+} ${rrc_message:\S+} that for UE${ue_id:\d+} ${drx_type:(common|VoNR)} DRX was setup
    ${drx_timer}=    Set variable if    '${drx_type}' == 'common'    'ms80'    'ms80'

    ${flow_alias_rrc}=     Get Flow Name
    ...     ${all}*${rrc_message}
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     (mac-CellGroupConfig contains (drx-Config contains (setup contains (drx-InactivityTimer eq ${drx_timer}))))
    ...     message_alias=RRCReconfiguration_${msg_in_list}
    ...     flow_alias=${flow_alias_rrc}

Verify in RRCReconfiguration that for UE${ue_id:\d+} DRX is setup
    Verify in 1 out of 2 RRCReconfiguration that for UE${ue_id} VoNR DRX was setup

Verify in ${msg_in_list:\S+} out of ${all:\d+} ${rrc_message:\S+} that for UE${ue_id:\d+} DRX was released
    ${flow_alias_rrc}=     Get Flow Name
    ...     ${all}*${rrc_message}
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     (mac-CellGroupConfig contains (drx-Config contains (release is present)))
    ...     message_alias=RRCReconfiguration_${msg_in_list}
    ...     flow_alias=${flow_alias_rrc}

Verify in ${rrc_message:\S+} that for UE${ue_id:\d+} DRX was released
    ${flow_alias_rrc}=     Get Flow Name
    ...     ${rrc_message}
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     (mac-CellGroupConfig contains (drx-Config contains (release is present)))
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}

Verify in ${rrc_message:\S+} that for UE${ue_id:\d+} DRX was neither setup nor released
    ${flow_alias_rrc}=     Get Flow Name
    ...     ${rrc_message}
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     (mac-CellGroupConfig is not present)
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${flow_alias_rrc}
