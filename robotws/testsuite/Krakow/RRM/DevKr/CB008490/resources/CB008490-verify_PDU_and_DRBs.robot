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

Library    CB008490.py

*** Keywords ***
Compare GTP tunnels at SN gNB${gnb:\d+}
    [Documentation]
    ...     Keyword compares GTP tunnels for all DRBs between [E1AP:BearerContextSetupResponse and F1AP:UEContextSetupRequest]
    ...     and [E1AP:BearerContextSetupResponse and XNAP:SNodeAdditionRequestAcknowledge].
    ...     DRB IDs must be the same in both compared messages.
    ...     Verified fields for each DRB:
    ...         for E1AP:BearerContextSetupResponse:
    ...             - len('uL-UP-Transport-Parameters') eq 2
    ...         for F1AP:UEContextSetupRequest:
    ...             - len('uLUPTNLInformation-ToBeSetup-List') eq 1
    ...             - gTPTunnel->transportLayerAddress and gTPTunnel->gTP-TEID same as in gTPTunnel from
    ...               BearerContextSetupResponse with cell-Group-ID eq 1
    ...         for XNAP:SNodeAdditionRequestAcknowledge:
    ...             - len('sN-UL-PDCP-UP-TNLInfo') eq 1
    ...             - gTPTunnel->tnl-address and gTPTunnel->gtp-teid same as in gTPTunnel from
    ...               BearerContextSetupResponse with cell-Group-ID eq 0

    ${flow_alias_XNAP}=     Get flow name
    ...     procedure=sNGRANnodeAdditionPreparation
    ...     device=gNB${gnb}
    ...     protocol=XNAP

    ${flow_alias_E1AP}=     Get flow name
    ...     procedure=bearerContextSetup
    ...     device=gNB${gnb}
    ...     protocol=E1AP

    ${flow_alias_F1AP}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb}
    ...     protocol=F1AP

    compare_gTPTunnels_between_messages
    ...    msg1=BearerContextSetupResponse
    ...    msg1_flow=${flow_alias_E1AP}
    ...    msg2=UEContextSetupRequest
    ...    msg2_flow=${flow_alias_F1AP}

    compare_gTPTunnels_between_messages
    ...    msg1=BearerContextSetupResponse
    ...    msg1_flow=${flow_alias_E1AP}
    ...    msg2=SNodeAdditionRequestAcknowledge
    ...    msg2_flow=${flow_alias_XNAP}
