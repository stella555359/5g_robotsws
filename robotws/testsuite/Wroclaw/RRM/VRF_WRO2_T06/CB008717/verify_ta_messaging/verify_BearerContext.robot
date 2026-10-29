*** Settings ***
Documentation    :copyright: Nokia
...             :authors: I_MN_RAN_RD_VRF_WRO2_6
...             :contact: I_MN_RAN_RD_VRF_WRO2_6

Resource    suffix.robot

*** Keywords ***
Verify that BearerCtxSetupReq_${n:\d+} out of ${all:\d+} was sent with setup of first DRB for gNB${id:\d+}
    Verify in BearerContextSetupRequest_${n} out of ${all} that dRB-ID is set to 4 for gNB${id}
    Verify in BearerContextSetupRequest_${n} out of ${all} that qoS-Flow-Identifier is set to 1 for gNB${id}

Verify that BearerCtxSetupResp_${n:\d+} out of ${all:\d+} was sent with setup of first DRB for gNB${id:\d+}
    Verify in BearerContextSetupResponse_${n} out of ${all} that dRB-ID is set to 4 for gNB${id}
    Verify in BearerContextSetupResponse_${n} out of ${all} that qoS-Flow-Identifier is set to 1 for gNB${id}

Verify that BearerCtxModReq_${n:\d+} out of ${all:\d+} was sent with setup of second DRB for gNB${id:\d+}
    Verify in BearerContextModificationRequest_${n} out of ${all} that PDU-Session-ID is set to 1 for gNB${id}
    Verify in BearerContextModificationRequest_${n} out of ${all} that dRB-ID is set to 5 for gNB${id}
    Verify in BearerContextModificationRequest_${n} out of ${all} that qoS-Flow-Identifier is set to 2 for gNB${id}

Verify that BearerCtxModResp_${n:\d+} out of ${all:\d+} was sent with setup of second DRB for gNB${id:\d+}
    Verify in BearerContextModificationResponse_${n} out of ${all} that PDU-Session-ID is set to 1 for gNB${id}
    Verify in BearerContextModificationResponse_${n} out of ${all} that dRB-ID is set to 5 for gNB${id}
    Verify in BearerContextModificationResponse_${n} out of ${all} that qoS-Flow-Identifier is set to 2 for gNB${id}

Verify that BearerCtxModReq_${n:\d+} out of ${all:\d+} for PDUSessionID=1 with ${drb:\d+} DRBs were send for gNB${g:\d+} for MN
    Verify in BearerContextModificationRequest_${n} out of ${all} that PDU-Session-ID is set to 1
    Verify in BearerContextModificationRequest_${n} out of ${all} that dRB-IDs are set for ${drb}-DRB
    Verify in BearerContextModificationRequest_${n} out of ${all} that Cell-Group-ID is set to 1 for ${drb}-DRB
    Verify in BearerContextModificationRequest_${n} out of ${all} that DL-TX-Stop is set to stop for ${drb}-DRB
    Log To Console    Verify that BearerCtxModReq_${n} out of ${all} for PDUSessionID=1 with ${drb} DRBs were send for gNB${g} for MN

Verify that BearerCtxModResp_${n:\d+} out of ${all:\d+} for pDUSessionID=1 with ${drb:\d+} DRBs were send for gNB${id:\d+} for MN
    Verify in BearerContextModificationResponse_${n} out of ${all} that dRB-IDs are set for ${drb}-DRB
    Log To Console    Verify that BearerCtxModResp_${n} out of ${all} for pDUSessionID=1 with ${drb} DRBs were send for gNB${id} for MN

Verify that BearerCtxModReq_${n:\d+} out of ${a:\d+} was send to release SCG leg with CellGroupID=${i:\d+} for ${d:\d+}-DRBs for gNB${id:\d+} for MN
    Verify in BearerContextModificationRequest_${n} out of ${a} that Cell-Group-ID set to ${i} is removed for SCG for ${d}-DRBs
    Log To Console    Verify that BearerCtxModReq_${n} out of ${a} was send to release SCG leg with CellGroupID=${i} for ${d}-DRBs
    ...    for gNB${id} for MN

Verify that BearerCtxModResp_${n:\d+} out of ${all:\d+} was send with SCG leg deletion for ${d:\d+}-DRBs for gNB${id:\d+} for MN
    Verify in BearerContextModificationResponse_${n} out of ${all} that dRB-IDs are removed for ${d}-DRBs
    Log To Console    Verify that BearerCtxModResp_${n} out of ${all} was send with SCG leg deletion for ${d}-DRBs for gNB${id} for MN

Verify that BearerCtxModReq_${n:\d+} out of ${all:\d+} for PDU-Session-ID-${pdu:\d+} with ${drb:\d+} DRB was success for gNB${id:\d+} for SN context
    Verify in BearerContextModificationRequest_${n} out of ${all} that PDU-Session-ID-${pdu} is set according to ICS for gNB${id}
    Verify in BearerContextModificationRequest_${n} out of ${all} that ${drb} DRB is set in ICS for gNB${id}
    Verify in BearerContextModificationRequest_${n} out of ${all} that UL-Configuration='shared', cell-Group-ID=1 for ${drb}-DRB and gNB${id}

Verify that BearerCtxModResp_${n:\d+} out of ${all:\d+} for PDU-Session-ID-${pdu:\d+} with ${drb:\d+} DRB was success for gNB${id:\d+} for SN context
    Verify in BearerContextModificationResponse_${n} out of ${all} that PDU-Session-ID-${pdu} is set according to ICS for gNB${id}
    Verify in BearerContextModificationResponse_${n} out of ${all} that ${drb} DRB is set in ICS for gNB${id}
    Verify in BearerContextModificationResponse_${n} out of ${all} that cell-Group-ID eq 1 for gNB${id}
    Verify in BearerContextModificationResponse_${n} out of ${all} that gTPTunnel is present for ${drb}-DRB and gNB${id}

Verify that BearerCtxModReq_${n:\d+} out of ${all:\d+} for PDU-Session-ID-${pdu:\d+} with ${drb:\d+} DRB was success for gNB${id:\d+} for MN context
    Verify in BearerContextModificationRequest_${n} out of ${all} that PDU-Session-ID-${pdu} is set according to ICS for gNB${id}
    Verify in BearerContextModificationRequest_${n} out of ${all} that ${drb} DRB is set in ICS for gNB${id}
    Verify in BearerContextModificationRequest_${n} out of ${all} that cell-Group-ID eq 1 for gNB${id}
    Verify in BearerContextModificationRequest_${n} out of ${all} that gTPTunnel is present for ${drb}-DRB and gNB${id}

Verify that BearerCtxModResp_${n:\d+} out of ${all:\d+} for PDU-Session-ID-${pdu:\d+} with ${drb:\d+} DRB was success for gNB${id:\d+} for MN context
    Verify in BearerContextModificationResponse_${n} out of ${all} that PDU-Session-ID-${pdu} is set according to ICS for gNB${id}
    Verify in BearerContextModificationResponse_${n} out of ${all} that ${drb} DRB is set in ICS for gNB${id}

Verify in ${msg_name:\S+}_${msg_num:\d+} out of ${all:\d+} that dRB-ID is set to ${d:\d+} for gNB${gnb_id:\d+}
    ${container_name}=    Set variable if
    ...     '${msg_name}'=='BearerContextSetupRequest'            BearerContextSetupRequest
    ...     '${msg_name}'=='BearerContextSetupResponse'           BearerContextSetupResponse
    ...     '${msg_name}'=='BearerContextModificationRequest'     BearerContextModificationRequest
    ...     '${msg_name}'=='BearerContextModificationResponse'    BearerContextModificationResponse

    ${msg_type}=     Set variable if
    ...     '${msg_name}'=='BearerContextSetupRequest'            Setup
    ...     '${msg_name}'=='BearerContextSetupResponse'           Setup
    ...     '${msg_name}'=='BearerContextModificationRequest'     Modification
    ...     '${msg_name}'=='BearerContextModificationResponse'    Modification

    ${flow_alias}=     Get flow name
    ...     procedure=${all}*bearerContext${msg_type}
    ...     device=gNB${gnb_id}
    ...     protocol=E1AP

    ${suffix}=    Set Index    all=${all}    msg_index=${msg_num}

    Verify That Message Fulfills Query
    ...     ${container_name} contains (dRB-ID eq ${d})
    ...     message_alias=${msg_name}${suffix}
    ...     flow_alias=${flow_alias}

Verify in ${msg_name:\S+}_${msg_num:\d+} out of ${all:\d+} that qoS-Flow-Identifier is set to ${qos:\d+} for gNB${gnb_id:\d+}
    ${container_name}=    Set variable if
    ...     '${msg_name}'=='BearerContextSetupRequest'            qos-flow-Information-To-Be-Setup
    ...     '${msg_name}'=='BearerContextSetupResponse'           flow-Setup-List
    ...     '${msg_name}'=='BearerContextModificationRequest'     qos-flow-Information-To-Be-Setup
    ...     '${msg_name}'=='BearerContextModificationResponse'    flow-Setup-List

    ${msg_type}=     Set variable if
    ...     '${msg_name}'=='BearerContextSetupRequest'            Setup
    ...     '${msg_name}'=='BearerContextSetupResponse'           Setup
    ...     '${msg_name}'=='BearerContextModificationRequest'     Modification
    ...     '${msg_name}'=='BearerContextModificationResponse'    Modification

    ${flow_alias}=     Get flow name
    ...     procedure=${all}*bearerContext${msg_type}
    ...     device=gNB${gnb_id}
    ...     protocol=E1AP

    ${suffix}=    Set Index    all=${all}    msg_index=${msg_num}

    Verify That Message Fulfills Query
    ...     length(${container_name}) eq 1 and ${container_name} contains (qoS-Flow-Identifier eq ${qos})
    ...     message_alias=${msg_name}${suffix}
    ...     flow_alias=${flow_alias}

Verify in ${msg_name:\S+}_${msg_num:\d+} out of ${all:\d+} that PDU-Session-ID-${pdu_id:\d+} is set according to ICS for gNB${gnb_id:\d+}
    ${pdu_container_name}=    Set variable if    '${msg_name}'=='BearerContextModificationRequest'
    ...    PDU-Session-Resource-To-Modify-List    PDU-Session-Resource-Modified-List
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*bearerContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     (length(${pdu_container_name}) eq 1)
    ...     message_alias=${msg_name}_${msg_num}
    ...     flow_alias=${flow_alias}

   Verify That Message Fulfills Query
    ...     ${pdu_container_name} contains (pDU-Session-ID eq ${pdu_id})
    ...     message_alias=${msg_name}_${msg_num}
    ...     flow_alias=${flow_alias}

Verify in ${msg_name:\S+}_${msg_num:\d+} out of ${all:\d+} that ${drb_num:\d+} DRB is set in ICS for gNB${gnb_id:\d+}
    ${drb_container_name}=    Set variable if    '${msg_name}'=='BearerContextModificationRequest'
    ...    dRB-To-Modify-List-NG-RAN    dRB-Modified-List-NG-RAN
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*bearerContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     length(${drb_container_name}) eq ${drb_num}
    ...     message_alias=${msg_name}_${msg_num}
    ...     flow_alias=${flow_alias}

Verify in BearerContextModification${msg_name:\S+}_${msg_num:\d+} out of ${all:\d+} that cell-Group-ID eq ${cell_group_id:\d+} for gNB${gnb_id:\d+}
    ${container_name}=    Set variable if    '${msg_name}'=='Request'
    ...    dRB-To-Modify-List-NG-RAN    dRB-Modified-List-NG-RAN

    ${flow_alias}=     Get flow name
    ...     procedure=${all}*bearerContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     not ${container_name} contains (cell-Group-ID ne ${cell_group_id})
    ...     message_alias=BearerContextModification${msg_name}_${msg_num}
    ...     flow_alias=${flow_alias}

Verify in ${msg_name:\S+}_${n:\d+} out of ${all:\d+} that UL-Configuration=${ul:\S+}, cell-Group-ID=${cell:\d+} for ${drb:\d+}-DRB and gNB${id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*bearerContextModification
    ...     device=gNB${id}
    ...     protocol=E1AP

    ${expectation}=    KeywordsCB008717.Message To Check    container=dRB-To-Modify-List-NG-RAN
    ...     single_expectation=cell-Group-To-Add contains ((uL-Configuration eq ${ul}) and (cell-Group-ID eq ${cell}))
    ...     number_of_occurrences=${drb}

    Verify That Message Fulfills Query
    ...     ${expectation}
    ...     message_alias=${msg_name}_${n}
    ...     flow_alias=${flow_alias}

Verify in BearerContextModification${msg_name:\S+}_${msg_num:\d+} out of ${all:\d+} that gTPTunnel is present for ${drb:\d+}-DRB and gNB${gnb_id:\d+}
    ${container_name}=    Set variable if    '${msg_name}'=='Request'
    ...    dRB-To-Modify-List-NG-RAN    dRB-Modified-List-NG-RAN

    ${flow_alias}=     Get flow name
    ...     procedure=${all}*bearerContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=E1AP

    ${expectation}=    KeywordsCB008717.Message To Check    container=${container_name}
    ...     single_expectation=(gTP-TEID is present) and (transportLayerAddress is present)    number_of_occurrences=${drb}

    Verify That Message Fulfills Query
    ...     ${expectation}
    ...     message_alias=BearerContextModification${msg_name}_${msg_num}
    ...     flow_alias=${flow_alias}

Verify in ${msg_name:\S+}_${msg_num:\d+} out of ${all:\d+} that PDU-Session-ID is set to ${pdu_id:\d+} for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*bearerContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     ${msg_name} contains (pDU-Session-ID eq ${pdu_id})
    ...     message_alias=${msg_name}_${msg_num}
    ...     flow_alias=${flow_alias}

Verify in BearerContextModificationRequest_${n} out of ${all} that PDU-Session-ID is set to ${pdu_id:\d+}
    Verify That Message Fulfills Query
    ...     BearerContextModificationRequest contains (pDU-Session-ID eq ${pdu_id})
    ...     message_alias=BearerContextModificationRequest
    ...     flow_alias=takeback_bearerContextModification
    Log To Console    Verify in BearerContextModificationRequest_${n} out of ${all} that PDU-Session-ID is set to ${pdu_id}

Verify in BearerContextModificationRequest_${n} out of ${all} that dRB-IDs are set for ${drb}-DRB
    ${message}=    KeywordsCB008717.Build Query For dRBIDs For Given Number Of DRBs
    ...    container=dRB-To-Modify-List-NG-RAN
    ...    num_of_drbs=${drb}

    Verify That Message Fulfills Query
    ...     ${message}
    ...     message_alias=BearerContextModificationRequest
    ...     flow_alias=takeback_bearerContextModification
    Log To Console    Verify in BearerContextModificationRequest_${n} out of ${all} that dRB-IDs are set for ${drb}-DRB

Verify in BearerContextModificationRequest_${n} out of ${all} that Cell-Group-ID is set to ${id:\d+} for ${d:\d+}-DRB
    ${expectation}=    KeywordsCB008717.Message To Check    container=dRB-To-Modify-List-NG-RAN
    ...     single_expectation=cell-Group-ID eq ${id}    number_of_occurrences=${d}

    Verify That Message Fulfills Query
    ...     ${expectation}
    ...     message_alias=BearerContextModificationRequest
    ...     flow_alias=takeback_bearerContextModification
    Log To Console    Verify in BearerContextModificationRequest_${n} out of ${all} that Cell-Group-ID is set to ${id} for ${d}-DRB

Verify in BearerContextModificationRequest_${n} out of ${a} that DL-TX-Stop is set to ${dl:\S+} for ${d:\d+}-DRB
    ${expectation}=    KeywordsCB008717.Message To Check    container=dRB-To-Modify-List-NG-RAN
    ...     single_expectation=dL-TX-Stop eq "${dl}"    number_of_occurrences=${d}

    Verify That Message Fulfills Query
    ...     ${expectation}
    ...     message_alias=BearerContextModificationRequest
    ...     flow_alias=takeback_bearerContextModification
    Log To Console    Verify in BearerContextModificationRequest_${n} out of ${a} that DL-TX-Stop is set to ${dl} for ${d}-DRB

Verify in BearerContextModificationResponse_${n:\d+} out of ${all:\d+} that dRB-IDs are set for ${drb:\d+}-DRB
    ${query}=    KeywordsCB008717.Build Query For dRBIDs For Given Number Of DRBs
    ...    container=dRB-Modified-List-NG-RAN
    ...    num_of_drbs=${drb}

    Verify That Message Fulfills Query
    ...     ${query}
    ...     message_alias=BearerContextModificationResponse
    ...     flow_alias=takeback_bearerContextModification
    Log To Console    Verify in BearerContextModificationResponse_${n} out of ${all} that dRB-IDs are set for ${drb}-DRB

Verify in BearerContextModificationResponse_${n} out of ${all} that dRB-IDs are removed for ${drb:\d+}-DRBs
    ${query}=    KeywordsCB008717.Build Query For dRBIDs For Given Number Of DRBs
    ...    container=dRB-Modified-List-NG-RAN
    ...    num_of_drbs=${drb}

    Verify That Message Fulfills Query
    ...     ${query}
    ...     message_alias=BearerContextModificationResponse_2nd
    ...     flow_alias=takeback_bearerContextModification
    Log To Console    Verify in BearerContextModificationResponse_${n} out of ${all} that dRB-IDs are removed for ${drb}-DRBs

Verify in BearerContextModificationRequest_${n} out of ${all} that Cell-Group-ID set to ${i:\d+} is removed for SCG for ${d:\d+}-DRBs
    ${expectation}=    KeywordsCB008717.Message To Check    container=cell-Group-To-Remove
    ...     single_expectation=cell-Group-ID eq ${i}    number_of_occurrences=${d}

    Verify That Message Fulfills Query
    ...     ${expectation}
    ...     message_alias=BearerContextModificationRequest_2nd
    ...     flow_alias=takeback_bearerContextModification
    Log To Console    Verify in BearerContextModificationRequest_${n} out of ${all} that Cell-Group-ID set to ${i} is removed for SCG for ${d}-DRBs

Verify that BearerCtxReleaseCommand_${num:\d+} out of ${all:\d+} was send with cause:radioNetwork:${cause:\S+} for gNB${gnb_id:\d+}
    Verify in BearerCtxReleaseCommand_${num} out of ${all} that cause:radioNetwork:${cause} for gNB${gnb_id}

Verify in BearerCtxReleaseCommand_${num} out of ${all} that cause:radioNetwork:${cause} for gNB${gnb_id}
   Verify That Message Fulfills Query
    ...    Cause contains (radioNetwork eq '${cause}')
    ...    message_alias=BearerCtxReleaseCommand
    ...    flow_alias=takeback_BearerCtxRel
    Log To Console    Verify in BearerCtxReleaseCommand_${num} out of ${all} that cause:radioNetwork:${cause} for gNB${gnb_id}

Verify that BearerCtxReleaseComplete_${num:\d+} out of ${all:\d+} was send with confirmation of SCG context deletion for gNB${gnb_id:\d+}
    Verify in BearerCtxReleaseComplete_${num} out of ${all} that BearerContextReleaseComplete is present for gNB${gnb_id}
    Log To Console    Verify that BearerCtxReleaseComplete_${num} out of ${all} was send with confirmation of SCG context deletion for gNB${gnb_id}

Verify in BearerCtxReleaseComplete_${num:\d+} out of ${all:\d+} that BearerContextReleaseComplete is present for gNB${gnb_id:\d+}
   Verify That Message Fulfills Query
    ...    BearerContextReleaseComplete is present
    ...    message_alias=BearerCtxReleaseComplete
    ...    flow_alias=takeback_BearerCtxRel
    Log To Console    Verify in BearerCtxReleaseComplete_${num} out of ${all} that BearerContextReleaseComplete is present for gNB${gnb_id}

Verify that BearerCtxModReq_${n:\d+} out of ${a:\d+} for PDUSesID${p:\d+} with ${d:\d+}DRB was success for gNB${id:\d+} for rollback
    Verify in BearerContextModificationRequest_${n} out of ${a} that PDU-Session-ID-${p} is set according to ICS for gNB${id}
    Verify in BearerContextModificationRequest_${n} out of ${a} that ${d} DRB is set in ICS for gNB${id}
    Verify in BearerContextModificationRequest_${n} out of ${a} that cell-Group-ID eq 1 for gNB${id}
    Verify in BearerContextModificationRequest_${n} out of ${a} that dRB_IDs are set for ${d}-DRB for gNB${id}

Verify that BearerCtxModReq_${n:\d+} out of ${a:\d+} for PDUSesID${p:\d+} was send to remove SCG with CellGrID${i:\d+}, ${d:\d+}DRB, gNB${id:\d+}
    Verify in BearerContextModificationRequest_${n} out of ${a} that PDU-Session-ID-${p} is set according to ICS for gNB${id}
    Verify in BearerContextModificationRequest_${n} out of ${a} that ${d} DRB is set in ICS for gNB${id}
    Verify in BearerContextModificationRequest_${n} out of ${a} that Cell-Group-ID ${i} is removed in SN for gNB${id}
    Verify in BearerContextModificationRequest_${n} out of ${a} that dRB_IDs are set for ${d}-DRB for gNB${id}

Verify in BearerContextModificationRequest_${n:\d+} out of ${a:\d+} that Cell-Group-ID ${i:\d+} is removed in SN for gNB${id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${a}*bearerContextModification
    ...     device=gNB${id}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     cell-Group-To-Remove contains (cell-Group-ID eq 1)
    ...     message_alias=BearerContextModificationRequest_${n}
    ...     flow_alias=${flow_alias}
    Log To Console    Verify in BearerContextModificationRequest_${n} out of ${a} that Cell-Group-ID ${i} is removed in SN for gNB${id}

Verify in BearerContextModificationRequest_${n:\d+} out of ${a:\d+} that dRB_IDs are set for ${d:\d+}-DRB for gNB${id:d\+}
    ${flow_alias}=     Get flow name
    ...     procedure=${a}*bearerContextModification
    ...     device=gNB${id}
    ...     protocol=E1AP

    ${message}=    KeywordsCB008717.Build Query For dRBIDs For Given Number Of DRBs
    ...    container=dRB-To-Modify-List-NG-RAN
    ...    num_of_drbs=${d}

    Verify That Message Fulfills Query
    ...     ${message}
    ...     message_alias=BearerContextModificationRequest_${n}
    ...     flow_alias=${flow_alias}

Verify that BearerCtxModResp_${n:\d+} out of ${all:\d+} with ${drb:\d+} DRB was success for gNB${id:\d+} for MN context
    Verify in BearerContextModificationResponse_${n} out of ${all} that ${drb} DRB is set in ICS for gNB${id}

Verify that in BearerCtxReleaseCmd_${n:\d+} out of ${all:\d+} was send cause:radioNetwork:${cause:\S+} for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*bearerContextRelease
    ...     device=gNB${gnb_id}
    ...     protocol=E1AP

    ${suffix}=    Set Index    all=${all}    msg_index=${n}

    Verify That Message Fulfills Query
    ...     Cause contains (radioNetwork eq '${cause}')
    ...     message_alias=BearerContextReleaseCommand${suffix}
    ...     flow_alias=${flow_alias}

