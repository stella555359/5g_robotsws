*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...       - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...       - Konrad Bem <konrad.bem@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>


*** Keywords ***
Verify for UE${ue_id:\d+} that in RRCReconfiguration only spCellConfig with firstActiveDownlinkBWP-Id and firstActiveUplinkBWP-Id is present
    ${flow_alias_rrc}=     Get Flow Name
    ...    RRCReconfiguration
    ...    device=UE_${ue_id}
    ...    protocol=NR-RRC

    Verify That Message Fulfills Query
    ...    (spCellConfigDedicated contains (firstActiveDownlinkBWP-Id eq 1))
    ...    and
    ...    (spCellConfigDedicated contains (firstActiveUplinkBWP-Id eq 1))
    ...    and
    ...    (uplinkBWP-ToAddModList is not present)
    ...    message_alias=RRCReconfiguration
    ...    flow_alias=${flow_alias_rrc}

Verify for UE${ue_id:\d+} that F1AP UEContextModificationRequired contains Cause radioNetwork: action-desirable-for-radio-reasons
    ${flow}=     Get Flow Name
    ...     procedure=uEContextModificationRequired
    ...     device=gNB2
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...    Cause contains (radioNetwork is present)
    ...    message_alias=UEContextModificationRequired
    ...    flow_alias=${flow}
