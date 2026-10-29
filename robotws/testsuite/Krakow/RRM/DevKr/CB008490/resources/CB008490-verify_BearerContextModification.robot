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
##### BearerContextModificationRequest keywords #####
Verify in BearerContextModReq that PDU-Session-Resource-To-Modify-List has 1 element with PDU-Session 1 and DRB-ID 4 for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextModification
    ...     device=gNB${gnb}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     length(PDU-Session-Resource-To-Modify-List) eq 1 and PDU-Session-Resource-To-Modify-List contains
    ...     (pDU-Session-ID eq 1 and dRB-To-Modify-List-NG-RAN contains (dRB-ID eq 4 and pdcp-SN-Status-Information is present))
    ...     message_alias=BearerContextModificationRequest
    ...     flow_alias=${flow_alias}

Verify that BearerContextModReq contains 1 PDU session with id 1 and DRBs [${drb_ids}] for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextModification
    ...     device=gNB${gnb}
    ...     protocol=E1AP

    verify_drbs_in_BearerContextModReq    ${flow_alias}    BearerContextModificationRequest    ${drb_ids}

Verify that BearerContextModReq contains pdcp-SN-Status-Information copied form SNStatusTransfer for all DRBs for SN gNB${gnb:\d+}
    ${E1_flow_alias}=     Get flow name
    ...     procedure=bearerContextModification
    ...     device=gNB${gnb}
    ...     protocol=E1AP

    ${XN_flow_alias}=     Get flow name
    ...     procedure=sNStatusTransfer
    ...     device=gNB${gnb}
    ...     protocol=XNAP

    compare_pdcp_SN_Status_Information
    ...     ${E1_flow_alias}
    ...     BearerContextModificationRequest
    ...     ${XN_flow_alias}
    ...     SNStatusTransfer

Verify in BearerContextModReq that all DRBs has the same gTPTunnels as in UEContextSetupResponse for SN gNB${gnb:\d+}
    ${E1_flow_alias}=     Get flow name
    ...     procedure=bearerContextModification
    ...     device=gNB${gnb}
    ...     protocol=E1AP

    ${F1_flow_alias}=     Get flow name
    ...     procedure=uEContextSetup
    ...     device=gNB${gnb}
    ...     protocol=F1AP

    ${XN_flow_alias}=     Get flow name
    ...     procedure=xnUAddressIndication
    ...     device=gNB${gnb}
    ...     protocol=XNAP

    compare_tunnels_in_BearerContextModReq
    ...     ${E1_flow_alias}
    ...     BearerContextModificationRequest
    ...     ${F1_flow_alias}
    ...     UEContextSetupResponse
    ...     ${XN_flow_alias}
    ...     XnUAddressIndication

Verify that E1AP:BearerContextModificationRequest ${item:\S+} includes ${item_number:\d+} items, gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     dRB-To-Modify-List-NG-RAN contains (length(cell-Group-To-Modify) eq ${item_number})
    ...     message_alias=BearerContextModificationRequest
    ...     flow_alias=${flow_alias}

Verify that E1AP:BearerContextModificationRequest cell-Group-ID eq ${cid:\d+} and dL-TX-Stop eq ${dltx:\S+}, gNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     (cell-Group-To-Modify contains ((cell-Group-ID eq ${cid}) and (dL-TX-Stop eq '${dltx}')))
    ...     message_alias=BearerContextModificationRequest
    ...     flow_alias=${flow_alias}

Verify that E1AP:BearerContextModificationRequest ${item:\S+} same as in XNAP:SnodeReleaseRequest
    ${flow_alias_bearerModReq}=     Get flow name
    ...     procedure=bearerContextModification
    ...     device=gNB3
    ...     protocol=E1AP

    ${flow_alias_snodeRel}=     Get flow name
    ...     procedure=mNGRANnodeinitiatedSNGRANnodeRelease
    ...     device=gNB3
    ...     protocol=XNAP

    compare_field_between_two_messages
    ...    msg1=BearerContextModificationRequest
    ...    msg1_flow=${flow_alias_bearerModReq}
    ...    msg2=SNodeReleaseRequest
    ...    msg2_flow=${flow_alias_snodeRel}
    ...    field=${item}

Verify that E1AP:BearerContextModificationResponse ${item:\S+} same as in E1AP:BearerContextModificationRequest
    ${flow_alias_bearerMod}=     Get flow name
    ...     procedure=bearerContextModification
    ...     device=gNB3
    ...     protocol=E1AP

    compare_field_between_two_messages
    ...    msg1=BearerContextModificationRequest
    ...    msg1_flow=${flow_alias_bearerMod}
    ...    msg2=BearerContextModificationResponse
    ...    msg2_flow=${flow_alias_bearerMod}
    ...    field=${item}

##### BearerContextModificationResponse keywords #####
Verify in BearerContextModResp that PDU-Session-Resource-To-Modify-List has 1 element with PDU-Session 1 and DRB-ID 4 for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextModification
    ...     device=gNB${gnb}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     nG-RAN-BearerContextModificationResponse contains (length(PDU-Session-Resource-Modified-List) eq 1 and
    ...     PDU-Session-Resource-Modified-List contains (pDU-Session-ID eq 1 and length(dRB-Modified-List-NG-RAN) eq 1 and
    ...     dRB-Modified-List-NG-RAN contains (dRB-ID eq 4)))
    ...     message_alias=BearerContextModificationResponse
    ...     flow_alias=${flow_alias}

Verify that BearerContextModResp contains 1 PDU session with id 1 and DRBs [${drb_ids}] for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextModification
    ...     device=gNB${gnb}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     nG-RAN-BearerContextModificationResponse contains (length(PDU-Session-Resource-Modified-List) eq 1 and
    ...     PDU-Session-Resource-Modified-List contains (pDU-Session-ID eq 1))
    ...     message_alias=BearerContextModificationResponse
    ...     flow_alias=${flow_alias}

    verify_drbs_in_BearerContextModResp    ${flow_alias}    BearerContextModificationResponse    ${drb_ids}

Verify that E1AP:BearerContextModificationResponse contains size of ${item:\S+} equal ${len:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextModification
    ...     device=gNB3
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     length(${item}) eq ${len}
    ...     message_alias=BearerContextModificationResponse
    ...     flow_alias=${flow_alias}

Verify in BearerContextModificationRequest that DRBs [${drbs}] has dRB-Inactivity-Timer set to [${timers}] for ${opt:SN|MN} gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextModification
    ...     device=gNB${gnb}
    ...     protocol=E1AP

    verify_multi_dRB_Inactivity_Timer    ${flow_alias}    BearerContextModificationRequest    ${drbs}    ${timers}
