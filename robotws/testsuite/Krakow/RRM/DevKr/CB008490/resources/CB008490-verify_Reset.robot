*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...      - Malgorzata Konior     <malgorzata.konior@nokia.com>
...      - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
...      - Maciej Madej          <maciej.madej@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Library     CB008490.py

*** Variables ***

*** Keywords ***
Verify that E1AP Reset contains cause:${cause_group}:${cause}, gNB${gnb}
    ${flow_alias}=     Get flow name
    ...     procedure=reset
    ...     device=gNB${gnb}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     Cause contains (${cause_group} eq '${cause}')
    ...     message_alias=Reset
    ...     flow_alias=${flow_alias}

Verify that F1AP Reset contains cause:${cause_group}:${cause}, gNB${gnb}
    ${flow_alias}=     Get flow name
    ...     procedure=reset
    ...     device=gNB${gnb}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     Cause contains (${cause_group} eq '${cause}')
    ...     message_alias=Reset
    ...     flow_alias=${flow_alias}

Verify that XNAP ResetRequest ResetRequestTypeInfo contains '${field}', gNB${gnb}
    ${flow_alias}=     Get flow name
    ...     procedure=reset
    ...     device=gNB${gnb}
    ...     protocol=XNAP

    Verify That Message Fulfills Query
    ...     ResetRequestTypeInfo contains ('${field}')
    ...     message_alias=ResetRequest
    ...     flow_alias=${flow_alias}

Verify that E1AP GNBDUConfigurationUpdate contains PCell id eq ${cell}, gNB${gnb}
    ${flow_alias}=     Get flow name
    ...     procedure=gNBDUConfigurationUpdate
    ...     device=gNB${gnb}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     nRCellIdentity eq '0b000000000000000000001000000000000001'
    ...     message_alias=GNBDUConfigurationUpdate
    ...     flow_alias=${flow_alias}

Verify that NGAP NGReset contains cause:radioNetwork:release-due-to-ngran-generated-reason, gNB${gnb}
    ${flow_alias}=     Get flow name
    ...     procedure=nGReset
    ...     device=gNB${gnb}
    ...     protocol=NGAP

    Verify That Message Fulfills Query
    ...     Cause contains (radioNetwork eq 'release-due-to-ngran-generated-reason')
    ...     message_alias=NGReset
    ...     flow_alias=${flow_alias}


Verify that NGAP NGReset ResetType contains 'partOfNG-Interface', gNB${gnb}
    ${flow_alias}=     Get flow name
    ...     procedure=nGReset
    ...     device=gNB${gnb}
    ...     protocol=NGAP

    Verify That Message Fulfills Query
    ...     ResetType contains ('partOfNG-Interface')
    ...     message_alias=NGReset
    ...     flow_alias=${flow_alias}

Verify that XNAP ${mulitiplier}ResetRequest contains cause:${cause_group}:${cause}, gNB${gNB}
    ${flow_alias}=     Get flow name
    ...     procedure=${mulitiplier}reset
    ...     device=gNB${gnb}
    ...     protocol=XNAP

    Verify That Message Fulfills Query
    ...     Cause contains (${cause_group} eq '${cause}')
    ...     message_alias=ResetRequest
    ...     flow_alias=${flow_alias}

Verify That E1AP GNBDUConfigurationUpdate contains NRDC cell id eq 3, GNB${gnb}
    ${flow_alias}=     Get flow name
    ...     procedure=gNBDUConfigurationUpdate
    ...     device=gNB${gnb}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     nRCellIdentity eq '0b000000000000000000001100000000000011'
    ...     message_alias=GNBDUConfigurationUpdate
    ...     flow_alias=${flow_alias}

Verify that both E1AP Reset messages contains cause:transport:unspecified, gNB2
    Verify That Message Fulfills Query
    ...     (Cause contains (transport eq 'unspecified'))
    ...     message_alias=Reset
    ...     flow_alias=E1_reset_1

    Verify That Message Fulfills Query
    ...     (Cause contains (transport eq 'unspecified'))
    ...     message_alias=Reset
    ...     flow_alias=E1_reset_2

Verify that XNAP:ResetRequest contains ${item:\S+} same as in XnAP:SNodeAdditionRequestAcknowledge for gNB${gnb_id}
    ${flow_alias_snodeReset}=     Get flow name
    ...     procedure=reset
    ...     device=gNB${gnb_id}
    ...     protocol=XNAP

    ${flow_alias_snodeAdd}=     Get flow name
    ...     procedure=sNGRANnodeAdditionPreparation
    ...     device=gNB${gnb_id}
    ...     protocol=XNAP

    compare_field_between_two_messages
    ...    msg1=ResetRequest
    ...    msg1_flow=${flow_alias_snodeReset}
    ...    msg2=SNodeAdditionRequestAcknowledge
    ...    msg2_flow=${flow_alias_snodeAdd}
    ...    field=${item}
