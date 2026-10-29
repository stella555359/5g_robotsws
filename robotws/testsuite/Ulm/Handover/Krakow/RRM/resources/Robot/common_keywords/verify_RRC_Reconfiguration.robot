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


*** Keywords ***
Verify in ${rrc_message:\S+} that UE${ue_id:\d+} ${drb_num:\d+} DRBs were added
    ${flow_alias_rrc}=     Get flow name
    ...     ${rrc_message}
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    IF    ${drb_num} > 0
        Verify That Message Fulfills Query
        ...     (length(drb-ToAddModList) eq ${drb_num})
        ...     message_alias=${rrc_message}
        ...     flow_alias=${flow_alias_rrc}
    ELSE IF    ${drb_num} == 0
        Verify That Message Fulfills Query
        ...     (drb-ToAddModList is not present)
        ...     message_alias=${rrc_message}
        ...     flow_alias=${flow_alias_rrc}
    END

Verify in ${rrc_message:\S+} that UE${ue_id:\d+} ${drb_num:\d+} DRBs were released
    ${flow_alias_rrc}=     Get flow name
    ...     ${rrc_message}
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    IF    ${drb_num} > 0
        Verify That Message Fulfills Query
        ...     (length(drb-ToReleaseList) eq ${drb_num})
        ...     message_alias=${rrc_message}
        ...     flow_alias=${flow_alias_rrc}
    ELSE IF    ${drb_num} == 0
        Verify That Message Fulfills Query
        ...     (drb-ToReleaseList is not present)
        ...     message_alias=${rrc_message}
        ...     flow_alias=${flow_alias_rrc}
    END

