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
Library     ../resources/CB8717.py


*** Keywords ***
##### UEContextModification keywords #####
Verify that F1AP:UEContextModificationRequest ${item:\S+} is set to '${val:\S+}' for ${MN_SN} gNB${gnb_id:\d+}
    Log  Verify that F1AP:UEContextModificationRequest ${item} is set to '${val}' for ${MN_SN} gNB${gnb_id}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     ${item} eq '${val}'
    ...     message_alias=UEContextModificationRequest
    ...     flow_alias=${flow_alias}

Verify that F1AP:UEContextModificationRequired contains cause:${cause_group:\S+}:${cause:\S+}, gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextModificationRequired
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     Cause contains (${cause_group} eq '${cause}')
    ...     message_alias=UEContextModificationRequired
    ...     flow_alias=${flow_alias}

Verify that A4 measurements are ${status:(configured|not configured)} in ${msg:\d+} out of ${all:\d+} UEContextModificationRequest message
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB2
    ...     protocol=F1AP

    ${state} =  Evaluate    '${status}' == 'configured'
    ${query} =  Set Variable If    ${state}  present  not present

    verify_if_measConfig_contains    ${flow_alias}    UEContextModificationRequest_${msg}    eventA4    is ${query}

Verify that A2,A3,A5 measurements are deactivated in ${msg:\d+} out of ${all:\d+} UEContextModificationRequest message
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB2
    ...     protocol=F1AP

   verify_length_of_IE_in_measConfig    ${flow_alias}    UEContextModificationRequest_${msg}    reportConfigToRemoveList    3
   verify_length_of_IE_in_measConfig    ${flow_alias}    UEContextModificationRequest_${msg}    measIdToRemoveList    3

Verify that A4 measurements are deactivated in UEContextModificationRequest message
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextModification
    ...     device=gNB2
    ...     protocol=F1AP

   verify_length_of_IE_in_measConfig    ${flow_alias}    UEContextModificationRequest    reportConfigToRemoveList    1
   verify_length_of_IE_in_measConfig    ${flow_alias}    UEContextModificationRequest    measIdToRemoveList    1
