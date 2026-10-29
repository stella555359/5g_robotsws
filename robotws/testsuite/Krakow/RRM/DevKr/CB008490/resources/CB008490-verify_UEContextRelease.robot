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

Library     CB008490.py

*** Variables ***

*** Keywords ***
##### UEContextRelease keywords #####
Verify that F1AP:UEContextReleaseCommand contains cause:${cause_group:\S+}:${cause:\S+} for ${MN_SN} gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextRelease
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     Cause contains (${cause_group} eq '${cause}')
    ...     message_alias=UEContextReleaseCommand
    ...     flow_alias=${flow_alias}

Verify that F1AP:UEContextReleaseCommand contains RRCContainer for ${MN_SN} gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextRelease
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     RRCContainer is present
    ...     message_alias=UEContextReleaseCommand
    ...     flow_alias=${flow_alias}

Verify that F1AP:UEContextReleaseCommand does NOT contain RRC-Container for ${MN_SN} gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextRelease
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     RRCContainer is not present
    ...     message_alias=UEContextReleaseCommand
    ...     flow_alias=${flow_alias}

Verify that F1AP:UEContextReleaseCommand contains SRB-ID eq ${srb_id:\d+} for ${MN_SN} gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextRelease
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     SRBID eq ${srb_id}
    ...     message_alias=UEContextReleaseCommand
    ...     flow_alias=${flow_alias}

Verify that F1AP:UEContextReleaseCommand does NOT contain SRB-ID for ${MN_SN} gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextRelease
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     SRBID is not present
    ...     message_alias=UEContextReleaseCommand
    ...     flow_alias=${flow_alias}

Verify that F1AP:UEContextReleaseRequest contains cause:${cause_group:\S+}:${cause:\S+} for ${MN_SN} gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextReleaseRequest
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     Cause contains (${cause_group} eq '${cause}')
    ...     message_alias=UEContextReleaseRequest
    ...     flow_alias=${flow_alias}
