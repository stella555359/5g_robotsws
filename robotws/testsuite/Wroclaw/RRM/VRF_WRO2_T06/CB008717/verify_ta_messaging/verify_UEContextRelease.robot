*** Settings ***
Documentation    :copyright: Nokia
...             :authors: I_MN_RAN_RD_VRF_WRO2_6
...             :contact: I_MN_RAN_RD_VRF_WRO2_6

*** Keywords ***
Verify that UECtxReleaseCommand_${num:\d+} out of ${all:\d+} was send with cause:radioNetwork:${cause:\S+} for gNB${gnb_id:\d+}
    Verify in UECtxReleaseCommand_${num} out of ${all} that cause:radioNetwork:${cause} is present for gNB${gnb_id}

Verify that UECtxReleaseComplete_${num:\d+} out of ${all:\d+} was send with confirmation of SCG context deletion for gNB${gnb_id:\d+}
    Verify in UECtxReleaseComplete_${num} out of ${all} that UEContextReleaseComplete is present for gNB${gnb_id}

Verify in UECtxReleaseCommand_${num:\d+} out of ${all:\d+} that cause:radioNetwork:${cause:\S+} is present for gNB${gnb_id:\d+}
   Verify That Message Fulfills Query
    ...    Cause contains (radioNetwork eq '${cause}')
    ...    message_alias=SN_UEContextReleaseCommand
    ...    flow_alias=takeback_SN_F1AP
    Log To Console    Verify in UECtxReleaseCommand_${num} out of ${all} that cause:radioNetwork:${cause} is present for gNB${gnb_id}

Verify in UECtxReleaseComplete_${num} out of ${all} that UEContextReleaseComplete is present for gNB${gnb_id}
   Verify That Message Fulfills Query
    ...    UEContextReleaseComplete is present
    ...    message_alias=SN_UEContextReleaseComplete
    ...    flow_alias=takeback_SN_F1AP
    Log To Console    Verify in UECtxReleaseComplete_${num} out of ${all} that UEContextReleaseComplete is present for gNB${gnb_id}

Verify that UECtxReleaseCommand_${num:\d+} out of ${all:\d+} was send with cause:radioNetwork:${cause:\S+} to gNB${gnb_id:\d+}
    Verify in UECtxReleaseCommand_${num} out of ${all} that cause:radioNetwork:${cause} is present to gNB${gnb_id}

Verify in UECtxReleaseCommand_${num:\d+} out of ${all:\d+} that cause:radioNetwork:${cause:\S+} is present to gNB${gnb_id:\d+}
   Verify That Message Fulfills Query
    ...    Cause contains (radioNetwork eq '${cause}')
    ...    message_alias=MN_UEContextReleaseCommand
    ...    flow_alias=F1AP_UECtxRelComm
    Log To Console    Verify in UECtxReleaseCommand_${num} out of ${all} that cause:radioNetwork:${cause} is present to gNB${gnb_id}

Verify that Additional UECtxReleaseCommand_${num:\d+} out of ${all:\d+} was send with cause:radioNetwork:${cause:\S+} to gNB${gnb_id:\d+}
    Verify in Additional UECtxReleaseCommand_${num} out of ${all} that cause:radioNetwork:${cause} is present to gNB${gnb_id}

Verify in Additional UECtxReleaseCommand_${num:\d+} out of ${all:\d+} that cause:radioNetwork:${cause:\S+} is present to gNB${gnb_id:\d+}
    Verify That Message Fulfills Query
    ...    Cause contains (radioNetwork eq '${cause}')
    ...    message_alias=MN_UEContextReleaseCommand2
    ...    flow_alias=F1AP_UECtxRelComm
    Log To Console    Verify in Additional UECtxReleaseCommand_${num} out of ${all} that cause:radioNetwork:${cause} is present to gNB${gnb_id}

Verify that UECtxReleaseRequest_${num:\d+} out of ${all:\d+} was send with cause:radioNetwork:${cause:\S+} for gNB${gnb_id:\d+}
    Verify in UECtxReleaseRequest_${num} out of ${all} that cause:radioNetwork:${cause} for gNB${gnb_id}
    Log To Console    Verify that UECtxReleaseRequest_${num} out of ${all} was send with cause:radioNetwork:${cause} for gNB${gnb_id}

Verify in UECtxReleaseRequest_${num:\d+} out of ${all:\d+} that cause:radioNetwork:${cause:\S+} for gNB${gnb_id:\d+}
   Verify That Message Fulfills Query
    ...    Cause contains (radioNetwork eq '${cause}')
    ...    message_alias=MN_UECtxReleaseRequest
    ...    flow_alias=NGAP_UECtxRelComm
    Log To Console    Verify in UECtxReleaseRequest_${num} out of ${all} that cause:radioNetwork:${cause} for gNB${gnb_id}

Verify that in UECtxReleaseCommand_${n:\d+} out of ${all:\d+} was send cause:radioNetwork:${cause:\S+} for gNB${gnb_id:\d+}
            ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextRelease
    ...     device=AMF${amf_id}
    ...     protocol=NGAP

    ${suffix}=    Set Index    all=${all}    msg_index=${n}

    Verify That Message Fulfills Query
    ...     Cause contains (radioNetwork eq '${cause}')
    ...     message_alias=UEContextReleaseCommand${suffix}
    ...     flow_alias=${flow_alias}
    Log To Console    Verify that in UECtxReleaseCommand_${n} out of ${all} was send cause:radioNetwork:${cause} for gNB${gnb_id}

#NB42c
Verify that in UECtxReleaseCmd_F1AP_${n:\d+} out of ${all:\d+} was send cause:radioNetwork:${cause:\S+} for gNB${gnb_id:\d+}
            ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextRelease
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP

    ${suffix}=    Set Index    all=${all}    msg_index=${n}

    Verify That Message Fulfills Query
    ...     Cause contains (radioNetwork eq '${cause}')
    ...     message_alias=UEContextReleaseCommand${suffix}
    ...     flow_alias=${flow_alias}
    Log To Console      Verify that in UECtxReleaseCmd_F1AP_${n} out of ${all} was send cause:radioNetwork:${cause} for gNB${gnb_id}


