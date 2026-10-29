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

*** Keywords ***
##### BearerContextRelease keywords #####
Verify that E1AP:BearerContextReleaseCommand contains cause:${cause_group:\S+}:${cause:\S+} for ${MN_SN} gNB${gnb_id:\d+}
    Log    Verify that E1AP:BearerContextReleaseCommand contains cause:${cause_group}:${cause} for ${MN_SN} gNB${gnb_id}
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextRelease
    ...     device=gNB${gnb_id}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     Cause contains (${cause_group} eq '${cause}')
    ...     message_alias=BearerContextReleaseCommand
    ...     flow_alias=${flow_alias}

Verify that E1AP:BearerContextReleaseComplete contains RetainabilityMeasurementsInfo with dRB-ID eq ${drb_id:\d+} for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextRelease
    ...     device=gNB${gnb_id}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     RetainabilityMeasurementsInfo contains (dRB-ID eq ${drb_id})
    ...     message_alias=BearerContextReleaseComplete
    ...     flow_alias=${flow_alias}

Verify that in E1AP:BearerContextReleaseComplete RetainabilityMeasurementsInfo is ${status:(present|not present)} for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextRelease
    ...     device=gNB${gnb_id}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     RetainabilityMeasurementsInfo is ${status}
    ...     message_alias=BearerContextReleaseComplete
    ...     flow_alias=${flow_alias}

Verify that E1AP:${msg_name} has ${num_of_IEs} IEs for ${MN_SN} gNB${gnb_id:\d+}
    Log    Verify that E1AP:${msg_name} has ${num_of_IEs} IEs for ${MN_SN} gNB${gnb_id}
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextRelease
    ...     device=gNB${gnb_id}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     length(protocolIEs) eq ${num_of_IEs}
    ...     message_alias=${msg_name}
    ...     flow_alias=${flow_alias}

Verify that E1AP:BearerContextReleaseComplete contains RetainabilityMeasurementsInfo:${cause_group:\S+}:${cause:\S+} for ${MN_SN} gNB${gnb_id:\d+}
    Log    Verify that E1AP:BearerContextReleaseComplete contains RetainabilityMeasurementsInfo:${cause_group}:${cause} for ${MN_SN} gNB${gnb_id}
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextRelease
    ...     device=gNB${gnb_id}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     RetainabilityMeasurementsInfo contains (${cause_group} eq '${cause}')
    ...     message_alias=BearerContextReleaseComplete
    ...     flow_alias=${flow_alias}
