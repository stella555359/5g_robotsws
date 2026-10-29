*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...      - Konrad Krzyzak <konrad.krzyzak@nokia.com>
...      - Karolina Sroczyk <karolina.sroczyk@nokia.com>
...      - Adrianna Zenczak <adrianna.zenczak@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

*** Keywords ***
Verify in BearerContextReleaseCommand that cause:${group:\S+}:${cause:\S+} is present for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextRelease
    ...     device=gNB${gnb_id}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     Cause contains (${group} eq '${cause}')
    ...     message_alias=BearerContextReleaseCommand
    ...     flow_alias=${flow_alias}

Verify in BearerContextModificationRequired that cause:${group:\S+}:${cause:\S+} is present for gNB${gnb_id:\d+}
    ${flow_alias}=     Get Flow Name
    ...     procedure=bearerContextModificationRequired
    ...     device=gNB${gnb_id}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     Cause contains (${group} eq '${cause}')
    ...     message_alias=BearerContextModificationRequired
    ...     flow_alias=${flow_alias}

Verify in NGAP UEContextReleaseCommand that cause:nas:${cause:\S+} is present for AMF${amf_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextRelease
    ...     device=AMF${amf_id}
    ...     protocol=NGAP

    Verify That Message Fulfills Query
    ...     Cause contains (nas eq '${cause}')
    ...     message_alias=UEContextReleaseCommand
    ...     flow_alias=${flow_alias}

Verify in NGAP UEContextReleaseCommand that cause:radioNetwork:${cause:\S+} is present for AMF${amf_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextRelease
    ...     device=AMF${amf_id}
    ...     protocol=NGAP

    Verify That Message Fulfills Query
    ...     Cause contains (radioNetwork eq '${cause}')
    ...     message_alias=UEContextReleaseCommand
    ...     flow_alias=${flow_alias}

Verify in NGAP UEContextReleaseRequest that cause:radioNetwork:${cause:\S+} is present for AMF${amf_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextReleaseRequest
    ...     device=AMF${amf_id}

    Verify That Message Fulfills Query
    ...     Cause contains (radioNetwork eq '${cause}')
    ...     message_alias=UEContextReleaseRequest
    ...     flow_alias=${flow_alias}

Verify in NGAP UEContextReleaseRequest,UEContextReleaseCommand cause:${cause_type:\S+}:${cause:\S+} is present for AMF${amf_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextReleaseRequest,uEContextRelease
    ...     device=AMF${amf_id}

    Verify That Message Fulfills Query
    ...     Cause contains (${cause_type} eq '${cause}')
    ...     message_alias=UEContextReleaseRequest
    ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
    ...     Cause contains (${cause_type} eq '${cause}')
    ...     message_alias=UEContextReleaseCommand
    ...     flow_alias=${flow_alias}

Verify in F1AP UEContextReleaseRequest that cause:radioNetwork:${cause:\S+} is present for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextReleaseRequest
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     Cause contains (radioNetwork eq '${cause}')
    ...     message_alias=UEContextReleaseRequest
    ...     flow_alias=${flow_alias}

Verify in F1AP UeContextModificationRequired that cause:radioNetwork:${cause:\S+} is present for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextModificationRequired
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     Cause contains (radioNetwork eq '${cause}')
    ...     message_alias=UEContextModificationRequired
    ...     flow_alias=${flow_alias}

Verify in F1AP UEContextReleaseCommand that cause:${group:\S+}:${cause:\S+} is present for ${context:(MN|SN)} context UE${ue_id:\d+}
    Verify That Message Fulfills Query
    ...     Cause contains (${group} eq '${cause}')
    ...     message_alias=UEContextReleaseCommand${context}Context
    ...     flow_alias=F1apUeContextRelease${context}Context

Verify in F1AP UEContextReleaseCommand that RRCContainer ${is_present:(is|is not)} present for ${context:(MN|SN)} context UE${ue_id:\d+}
    Verify That Message Fulfills Query
    ...     RRCContainer ${is_present} present
    ...     message_alias=UEContextReleaseCommand${context}Context
    ...     flow_alias=F1apUeContextRelease${context}Context

Verify in F1AP UEContextReleaseCommand that RRCContainer is present for MN and is not present for SN context UE${ue_id:\d+}
    Verify That Message Fulfills Query
    ...     RRCContainer is present
    ...     message_alias=UEContextReleaseCommandMNContext
    ...     flow_alias=F1apUeContextReleaseMNandSNContext

    Verify That Message Fulfills Query
    ...     RRCContainer is not present
    ...     message_alias=UEContextReleaseCommandSNContext
    ...     flow_alias=F1apUeContextReleaseMNandSNContext

Verify in F1AP UeContextReleaseCommand that cause:radioNetwork:${cause:\S+} is present for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextRelease
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    Verify That Message Fulfills Query
    ...     Cause contains (radioNetwork eq '${cause}')
    ...     message_alias=UEContextReleaseCommand
    ...     flow_alias=${flow_alias}

Verify in both MN and SN context F1AP UeContextReleaseCommand that cause:radioNetwork:${cause:\S+} is present for gNB${gnb_id:\d+}
    Verify That Message Fulfills Query
    ...     Cause contains (radioNetwork eq '${cause}')
    ...     message_alias=UEContextReleaseCommandMNContext
    ...     flow_alias=F1apUeContextReleaseMNandSNContext

    Verify That Message Fulfills Query
    ...     Cause contains (radioNetwork eq '${cause}')
    ...     message_alias=UEContextReleaseCommandSNContext
    ...     flow_alias=F1apUeContextReleaseMNandSNContext

Get GNB-CU-UE-F1AP-ID and GNB-DU-UE-F1AP-ID of Master and Secondary Node for gNB${gnb_id:\d+}
    Get GNB-CU-UE-F1AP-ID and GNB-DU-UE-F1AP-ID of Master Node for UE1 for gNB
    Get GNB-CU-UE-F1AP-ID and GNB-DU-UE-F1AP-ID of Secondary Node for UE1 for gNB

Get GNB-CU-UE-F1AP-ID and GNB-DU-UE-F1AP-ID of Master Node for UE${ue_id:\d+} for gNB
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB2
    ...     protocol=F1AP

    save_cu_du_ue_id_from_ue_ctx_setup_mn
    ...     message_alias=UEContextSetupResponse
    ...     flow_alias=${flow_alias}

Get GNB-CU-UE-F1AP-ID and GNB-DU-UE-F1AP-ID of Secondary Node for UE${ue_id:\d+} for gNB
    ${flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB2
    ...     protocol=F1AP

   save_cu_du_ue_id_from_ue_ctx_setup_sn
    ...     message_alias=UEContextSetupResponse
    ...     flow_alias=${flow_alias}

Verify in E1AP BearerContextModificationRequired that cause:radioNetwork:${cause:\S+} is present for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextModificationRequired
    ...     device=gNB${gnb_id}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     cause contains (radioNetwork eq '${cause}')
    ...     message_alias=BearerContextModificationRequired
    ...     flow_alias=${flow_alias}
