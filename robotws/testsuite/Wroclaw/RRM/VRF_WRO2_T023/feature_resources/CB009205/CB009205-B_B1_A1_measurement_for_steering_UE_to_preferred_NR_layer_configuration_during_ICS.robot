*** Settings ***
Documentation    Keywords for the CB009205

Library     ta5g_egate
Library     ta5g_ue_mobility

*** Variables ***
${NGAP: INITIAL CONTEXT SETUP REQUEST}=
...    (ngap.InitialContextSetupRequest_element)&&
...    (ngap.PDUSessionResourceSetupListCxtReq==1)
${F1AP: UE CONTEXT SETUP REQUEST}=    f1ap.UEContextSetupRequest_element
${F1AP: UE CONTEXT SETUP RESPONSE}=    f1ap.UEContextSetupResponse_element
${E1AP: BEARER CONTEXT SETUP REQUEST}=    e1ap.BearerContextSetupRequest_element
${E1AP: BEARER CONTEXT SETUP RESPONSE}=    e1ap.BearerContextSetupResponse_element
${RRC Reconfiguration}=
...    (nr-rrc.rrcReconfiguration_element)&&
...    (nr-rrc.ssbFrequency==633312)&&
...    (nr-rrc.eventId==1)&&
...    (nr-rrc.eventId==2)&&
...    (nr-rrc.eventId==4)&&
...    (nr-rrc.eventId==0)&&
...    (nr-rrc.a1_Threshold==1)&&
...    (nr-rrc.measIdToAddModList==4)
${RRC Reconfiguration Complete}=    nr-rrc.rrcReconfigurationComplete_element
${NGAP: INITIAL CONTEXT SETUP RESPONSE}=    ngap.InitialContextSetupResponse_element


*** Keywords ***
TC__CB009205-B_B1_A1_measurement_for_steering_UE_to_preferred_NR_layer_configuration_during_ICS_(RSRQ_case)
    Set Internal Traffic Type To UE with Sibs
    Register UE To gNB With PDU Session Setup
    Wait For Registration Procedure Ending    2s
    Verify NGAP Initial Context Setup Request Occurred    ${NGAP: INITIAL CONTEXT SETUP REQUEST}
    Verify F1AP UE Context Setup Request Message Occurred    ${F1AP: UE CONTEXT SETUP REQUEST}
    Verify F1AP UE Context Setup Response Message Occurred    ${F1AP: UE CONTEXT SETUP RESPONSE}
    Verify E1AP Bearer Context Setup Request Message Occurred    ${E1AP: BEARER CONTEXT SETUP REQUEST}
    Verify E1AP Bearer Context Setup Response Message Occurred    ${E1AP: BEARER CONTEXT SETUP RESPONSE}
    Verify RRC Reconfiguration Message Occurred    ${RRC Reconfiguration}
    Verify RRC Reconfiguration Complete Message Occurred    ${RRC Reconfiguration Complete}
    Verify NGAP Initial Context Setup Response Occurred    ${NGAP: INITIAL CONTEXT SETUP RESPONSE}

Set Internal Traffic Type To UE With Sibs
    Execute Egate Command    cmd=gnb_param id=3 sib1_period=40
    Execute Egate Command    cmd=gnb_param id=3 sib2_period=40
    Execute Egate Command    cmd=gnb_param id=3 sib5_period=40
    Execute Egate Command    cmd=set_pdu_param ue=1 pdu=1 trf_type=internal

Register UE To gNB With PDU Session Setup
    Attach Ue    ue_id=1
    Execute Egate Command    cmd=ue_pdu_session_setup ue=1 pdu=1 nwslice=1 gw=1

Wait For Registration Procedure Ending
    [Arguments]    ${time_to_wait}
    Sleep    ${time_to_wait}

Verify NGAP Initial Context Setup Request Occurred
    [Arguments]    ${NGAP: Initial Context Setup Request appears}
    Verify Tcpdump Log    ${NGAP: Initial Context Setup Request appears}

Verify NGAP Initial Context Setup Response Occurred
    [Arguments]    ${NGAP: Initial Context Setup Response appears}
    Verify Tcpdump Log    ${NGAP: Initial Context Setup Response appears}

Verify F1AP UE Context Setup Request Message Occurred
    [Arguments]    ${F1AP: UE Context Setup Request message}
    Verify Tcpdump Log    ${F1AP: UE Context Setup Request message}

Verify F1AP UE Context Setup Response Message Occurred
    [Arguments]    ${F1AP: UE Context Setup Response message}
    Verify Tcpdump Log    ${F1AP: UE Context Setup Response message}

Verify E1AP Bearer Context Setup Request Message Occurred
    [Arguments]    ${E1AP: Bearer Context Setup Request message}
    Verify Tcpdump Log    ${E1AP: Bearer Context Setup Request message}

Verify E1AP Bearer Context Setup Response Message Occurred
    [Arguments]    ${E1AP: Bearer Context Setup Response message}
    Verify Tcpdump Log    ${E1AP: Bearer Context Setup Response message}

Verify RRC Reconfiguration Message Occurred
    [Arguments]    ${RRC Reconfiguration}
    Verify Tcpdump Log    ${RRC Reconfiguration}

Verify RRC Reconfiguration Complete Message Occurred
    [Arguments]    ${RRC Reconfiguration Complete}
    Verify Tcpdump Log    ${RRC Reconfiguration Complete}
