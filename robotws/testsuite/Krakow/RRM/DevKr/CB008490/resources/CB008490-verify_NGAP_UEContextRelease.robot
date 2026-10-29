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
Verify that NGAP:UEContextReleaseCommand contains cause:${cause_group:\S+}:${cause:\S+} for ${MN_SN:\S+} AMF${amf_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextRelease
    ...     device=AMF${amf_id}
    ...     protocol=NGAP

    Verify That Message Fulfills Query
    ...     Cause contains (${cause_group} eq '${cause}')
    ...     message_alias=UEContextReleaseCommand
    ...     flow_alias=${flow_alias}

Verify that NGAP:UEContextReleaseRequest contains cause:${cause_group:\S+}:${cause:\S+} for ${MN_SN:\S+} AMF${amf_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextReleaseRequest
    ...     device=AMF${amf_id}

    Verify That Message Fulfills Query
    ...     Cause contains (${cause_group} eq '${cause}')
    ...     message_alias=UEContextReleaseRequest
    ...     flow_alias=${flow_alias}
