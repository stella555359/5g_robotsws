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
Verify in ${num:\d+} out of ${all:\d+} that ${msg_name:\S+} PDU-Session-ID-${pdu_id:\d+} is set according to ICS for gNB${gnb_id:\d+}
    ${pdu_container_name}=    Set variable if    '${msg_name}'=='BearerContextModificationRequest'
    ...    PDU-Session-Resource-To-Modify-List    PDU-Session-Resource-Modified-List
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*bearerContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     (length(${pdu_container_name}) eq 1)
    ...     message_alias=${msg_name}_${num}
    ...     flow_alias=${flow_alias}

   Verify That Message Fulfills Query
    ...     ${pdu_container_name} contains (pDU-Session-ID eq ${pdu_id})
    ...     message_alias=${msg_name}_${num}
    ...     flow_alias=${flow_alias}

Verify in ${num:\d+} out of ${all:\d+} that ${msg_name:\S+} contains ${drb_num:\d+} DRBs set in ICS for gNB${gnb_id:\d+}
    ${drb_container_name}=    Set variable if    '${msg_name}'=='BearerContextModificationRequest'
    ...    dRB-To-Modify-List-NG-RAN    dRB-Modified-List-NG-RAN
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*bearerContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     length(${drb_container_name}) eq ${drb_num}
    ...     message_alias=${msg_name}_${num}
    ...     flow_alias=${flow_alias}

Verify in ${num:\d+} out of ${all:\d+} that BearerContextModification${msg_name:\S+} cell-Group-ID eq ${cell_group_id:\d+} for gNB${gnb_id:\d+}
    ${container_name}=    Set variable if    '${msg_name}'=='Request'
    ...    dRB-To-Modify-List-NG-RAN    dRB-Modified-List-NG-RAN

    ${flow_alias}=     Get flow name
    ...     procedure=${all}*bearerContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     ${container_name} contains (cell-Group-ID eq ${cell_group_id})
    ...     message_alias=BearerContextModification${msg_name}_${num}
    ...     flow_alias=${flow_alias}

Verify in ${num:\d+} out of ${all:\d+} that ${msg:\S+} UL-Configuration eq ${ul-conf:\S+} and cellGroupID eq ${cell_id:\d+} for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*bearerContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     dRB-To-Modify-List-NG-RAN contains (cell-Group-To-Add contains (uL-Configuration eq ${ul-conf} and cell-Group-ID eq ${cell_id}))
    ...     message_alias=${msg}_${num}
    ...     flow_alias=${flow_alias}

Verify in ${num:\d+} out of ${all:\d+} that BearerContextModification${msg_name:\S+} gTPTunnel is present for gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*bearerContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     (gTP-TEID is present) and (transportLayerAddress is present)
    ...     message_alias=BearerContextModification${msg_name}_${num}
    ...     flow_alias=${flow_alias}

Verify in ${num:\d+} out of ${all:\d+} that ${msg:\S+} UL-Config: ${ulc:\S+}, cellGroupID: ${cid:\d+}, dL-TXStop: ${dlt:\S+} for gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*bearerContextModification
    ...     device=gNB${gnb}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     dRB-To-Modify-List-NG-RAN contains (cell-Group-To-Add contains
    ...     (uL-Configuration eq ${ulc} and cell-Group-ID eq ${cid} and dL-TX-Stop eq ${dlt} and rAT-Type is not present))
    ...     message_alias=${msg}_${num}
    ...     flow_alias=${flow_alias}

Verify in ${num:\d+} out of ${all:\d+} that ${msg:\S+} UL-Config: ${ulc:\S+}, cellGroupID: ${cid:\d+}, dL-TXStop not present for gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*bearerContextModification
    ...     device=gNB${gnb}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     dRB-To-Modify-List-NG-RAN contains (cell-Group-To-Add contains
    ...     (uL-Configuration eq ${ulc} and cell-Group-ID eq ${cid} and dL-TX-Stop is not present and rAT-Type is not present))
    ...     message_alias=${msg}_${num}
    ...     flow_alias=${flow_alias}

Verify that in ${num:\d+} out of ${all:\d+} BearerCtxModReq PDUSessionID-${pdu:\d+} with ${drb:\d+} DRB was success for gNB${gnb:\d+} for SN context
    Verify in ${num} out of ${all} that BearerContextModificationRequest PDU-Session-ID-${pdu} is set according to ICS for gNB${gnb}
    Verify in ${num} out of ${all} that BearerContextModificationRequest contains ${drb} DRBs set in ICS for gNB${gnb}
    Verify in ${num} out of ${all} that BearerContextModificationRequest UL-Configuration eq 'no-data' and cellGroupID eq 1 for gNB${gnb}

Verify ${num:\d+} out of ${all:\d+} BearerCtxModReq for ulDataPath set to ulOverLteNrPrimaryPathOverLte for gNB${gnb:\d+} for SN context
    Verify in ${num} out of ${all} that BearerContextModificationRequest PDU-Session-ID-1 is set according to ICS for gNB${gnb}
    Verify in ${num} out of ${all} that BearerContextModificationRequest contains 2 DRBs set in ICS for gNB${gnb}
    Verify in ${num} out of ${all} that BearerContextModificationRequest UL-Config: 'shared', cellGroupID: 1, dL-TXStop not present for gNB${gnb}
    Verify in ${num} out of ${all} that BearerContextModificationRequest UL-Config: 'only', cellGroupID: 1, dL-TXStop: 'stop' for gNB${gnb}

Verify ${num:\d+} out of ${all:\d+} BearerCtxModReq ulDataPath: ulOverLteNrPrimaryPathOverNr, UL-Config: ${ulc:\S+} for gNB${gnb:\d+} for SN context
    Verify in ${num} out of ${all} that BearerContextModificationRequest PDU-Session-ID-1 is set according to ICS for gNB${gnb}
    Verify in ${num} out of ${all} that BearerContextModificationRequest contains 1 DRBs set in ICS for gNB${gnb}
    Verify in ${num} out of ${all} that BearerContextModificationRequest UL-Config: ${ulc}, cellGroupID: 1, dL-TXStop not present for gNB${gnb}

Verify that in ${num:\d+} out of ${all:\d+} BearerCtxModResp PDUSessionID-${pdu:\d+} with ${drb:\d+} DRB was success for gNB${gnb:\d+} for SN context
    Verify in ${num} out of ${all} that BearerContextModificationResponse PDU-Session-ID-${pdu} is set according to ICS for gNB${gnb}
    Verify in ${num} out of ${all} that BearerContextModificationResponse contains ${drb} DRBs set in ICS for gNB${gnb}
    Verify in ${num} out of ${all} that BearerContextModificationResponse cell-Group-ID eq 1 for gNB${gnb}
    Verify in ${num} out of ${all} that BearerContextModificationResponse gTPTunnel is present for gNB${gnb}

Verify that in ${num:\d+} out of ${all:\d+} BearerCtxModReq PDUSessionID-${pdu:\d+} with ${drb:\d+} DRB was success for gNB${gnb:\d+} for MN context
    Verify in ${num} out of ${all} that BearerContextModificationRequest PDU-Session-ID-${pdu} is set according to ICS for gNB${gnb}
    Verify in ${num} out of ${all} that BearerContextModificationRequest contains ${drb} DRBs set in ICS for gNB${gnb}
    Verify in ${num} out of ${all} that BearerContextModificationRequest cell-Group-ID eq 1 for gNB${gnb}
    Verify in ${num} out of ${all} that BearerContextModificationRequest gTPTunnel is present for gNB${gnb}

Verify that in ${num:\d+} out of ${all:\d+} BearerCtxModResp PDUSessionID-${pdu:\d+} with ${drb:\d+} DRB was success for gNB${gnb:\d+} for MN context
    Verify in ${num} out of ${all} that BearerContextModificationResponse PDU-Session-ID-${pdu} is set according to ICS for gNB${gnb}
    Verify in ${num} out of ${all} that BearerContextModificationResponse contains ${drb} DRBs set in ICS for gNB${gnb}
