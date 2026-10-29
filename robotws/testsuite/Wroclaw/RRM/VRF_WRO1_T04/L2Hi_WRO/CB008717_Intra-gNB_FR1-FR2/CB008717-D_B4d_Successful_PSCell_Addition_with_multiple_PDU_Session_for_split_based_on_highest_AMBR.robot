*** Settings ***
Resource    keywords_CB008717.robot
Library     keywords_CB008717.py

Documentation
...    author: Lukasz Filipek
...    maintainer: Lukasz Filipek (lukasz.filipek@nokia.com)
...    testline: CLOUD_5G_I_BOO_AP_LOO

*** Variables ***
${TRAFFIC_DURATION_SEC_D_B4d}=       5m
${WAIT_FOR_EGATE}=    5s

*** Keywords ***
CB008717-D_B4d_Successful_PSCell_Addition_with_multiple_PDU_Session_for_split_based_on_highest_AMBR
    Attach Ue    ue_id=1
    Modify Ambr Params For Ue and Setup Pdu    ue_id=1    pdu_id=1    ambr_dl=100    gw=1
    Modify Ambr Params For Ue and Setup Pdu    ue_id=1    pdu_id=2    ambr_dl=300    gw=2
    Modify Pdu Session    ue_id=1    pdu_id=2    qos_to_add=3
    Sleep    ${WAIT_FOR_EGATE}
    Modify Ambr Params For Ue and Setup Pdu    ue_id=1    pdu_id=3    ambr_dl=200    gw=3
    Send A4 Measurement and Set Message Flow    ue_id=1
    Verify expected message flow
    Verify PDU-Session-ID    pdu_id=3
    Start 50Mbps Traffic In UL    ue_id=1    pdu_id=3
    Check Ul Data Traffic On Mcg And Scg Leg    ue_id=1    pdu_id=3    traffic_duration=${TRAFFIC_DURATION_SEC_D_B4d}
    ...    expected_throughput=30    expected_ul=29    scell=1    cell_group=SCG
    Stop Data Traffic and Deregister UE    ue_id=1

    Attach Ue    ue_id=2
    Modify Ambr Params For Ue and Setup Pdu    ue_id=2    pdu_id=1    ambr_dl=300    ambr_ul=300    gw=1
    Modify Ambr Params For Ue and Setup Pdu    ue_id=2    pdu_id=2    ambr_dl=100    ambr_ul=200    gw=2
    Modify Ambr Params For Ue and Setup Pdu    ue_id=2    pdu_id=3    ambr_dl=200    ambr_ul=100    gw=3
    Send A4 Measurement and Set Message Flow    ue_id=2
    Verify expected message flow
    Verify PDU-Session-ID    pdu_id=1
    Start 50Mbps Traffic In UL    ue_id=2    pdu_id=1
    Check Ul Data Traffic On Mcg And Scg Leg    ue_id=2    pdu_id=1    traffic_duration=${TRAFFIC_DURATION_SEC_D_B4d}
    ...    expected_throughput=30    expected_ul=29    scell=1    cell_group=SCG
    Stop Data Traffic and Deregister UE    ue_id=2

    Attach Ue    ue_id=3
    Modify Ambr Params For Ue and Setup Pdu    ue_id=3    pdu_id=1    ambr_dl=100    ambr_ul=100    gw=1
    Modify Ambr Params For Ue and Setup Pdu    ue_id=3    pdu_id=2    ambr_dl=100    ambr_ul=100    gw=2
    Modify Ambr Params For Ue and Setup Pdu    ue_id=3    pdu_id=3    ambr_dl=100    ambr_ul=100    gw=3
    Send A4 Measurement and Set Message Flow    ue_id=3
    Verify expected message flow
    Verify PDU-Session-ID    pdu_id=1
    Start 50Mbps Traffic In UL    ue_id=3    pdu_id=1
    Check Ul Data Traffic On Mcg And Scg Leg    ue_id=3    pdu_id=1    traffic_duration=${TRAFFIC_DURATION_SEC_D_B4d}
    ...    expected_throughput=30    expected_ul=29    scell=1    cell_group=SCG
    Stop Data Traffic and Deregister UE    ue_id=3

Modify Ambr Params For Ue and Setup Pdu
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${ambr_dl}=100    ${ambr_ul}=100    ${gw}=1
    Execute Egate Command    cmd=smf_ue_pdu_param id=1 ue=${ue_id} pdu=${pdu_id} session_ambr_dl=${ambr_dl}:Kbps session_ambr_ul=${ambr_ul}:Kbps
    Sleep    ${WAIT_FOR_EGATE}
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command And Wait For Data    cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1 gw=${gw}
    Sleep    ${WAIT_FOR_EGATE}

Send A4 Measurement and Set Message Flow
    [Arguments]    ${ue_id}=1
    Execute egate command    cmd=ue_im_entry id=${ue_id} by=ue
    Sleep    ${WAIT_FOR_EGATE}
    Execute egate command    cmd=ue_im_exit id=${ue_id}
    Sleep    ${WAIT_FOR_EGATE}
    Set expected message flow
    Execute Egate Command    cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 phycell_id=52 nrsrp_nr=60 event=A4
    Sleep    ${WAIT_FOR_EGATE}

Start 50Mbps Traffic In UL
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=30

Verify PDU-Session-ID
    [Arguments]    ${pdu_id}=1    ${msg_name}=BearerContextModificationRequest
    ${pdu_container_name}=    Set variable if    '${msg_name}'=='BearerContextModificationRequest'
    ...    PDU-Session-Resource-To-Modify-List    PDU-Session-Resource-Modified-List
    ${flow_alias}=     Get flow name
    ...     procedure=2*bearerContextModification
    ...     device=gNB2
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     (length(${pdu_container_name}) eq 1)
    ...     message_alias=BearerContextModificationRequest_1
    ...     flow_alias=${flow_alias}

   Verify That Message Fulfills Query
    ...     ${pdu_container_name} contains (pDU-Session-ID eq ${pdu_id})
    ...     message_alias=BearerContextModificationRequest_1
    ...     flow_alias=${flow_alias}

Set expected message flow
    EXPECT FLOW[timeout=20]: gNB2 E1AP 2*bearerContextModification

Verify expected message flow
    PASS FLOW[timeout=20]: gNB2 E1AP 2*bearerContextModification

Stop Data Traffic and Deregister UE
    [Arguments]    ${ue_id}=1
    Execute Egate Command    cmd=trf_data_stop ue=${ue_id}
    Run Keywords    Deregister Ue   ue_id=${ue_id}
   ...        AND   Sleep    3s   Waiting for deregister
