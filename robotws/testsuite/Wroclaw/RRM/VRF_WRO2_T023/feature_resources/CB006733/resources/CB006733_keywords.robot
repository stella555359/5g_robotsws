*** Settings ***
Documentation    Keywords for the CB006733

Library     ute_wtssim
Library     ta5g_ue_mobility
Resource    testsuite/Wroclaw/RRM/WRO_2/keywords/tshark_verifying.robot


*** Keywords ***
Register UE To gNB
    [Arguments]    ${ue_id}    ${timeout}=3
    Execute Egate Command    cmd=ue_register id=${ue_id}
    Wait For UE Register    3s
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=3 trf_type=internal
    Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=3 nwslice=1 gw=3
    ...    timeout=${timeout}

Wait For UE Register
    [Arguments]    ${inactive_timer}
    BuiltIn.Sleep    ${inactive_timer}

Wait for SuperVisionTimer Expired More Than 6 Times
    [Arguments]    ${inactive_timer}
    BuiltIn.Sleep   ${inactive_timer}

Verify Ue Context Modification Request
    [Arguments]    ${UEContextModificationRequestForA4SCellAdd}
    Verify Tcpdump Log    packet_filter=${UEContextModificationRequestForA4SCellAdd}    number_of_messages=6    relation_symbol= ==

Verify 4FDD SCells Addition
    [Arguments]    ${RRCReconfiguratonForA4SCellAdd}
    Verify Tcpdump Log    packet_filter=${RRCReconfiguratonForA4SCellAdd}

Verify RRC After A4RetryTimerExpire
    [Arguments]    ${RRCReconfiguratonPCellAfterA4RetryTimerExpire}
    Verify Tcpdump Log    packet_filter=${RRCReconfiguratonPCellAfterA4RetryTimerExpire}    number_of_messages=6    relation_symbol= ==

Verify RRC After A4Fr1SuperVisionTimerExpire
    [Arguments]    ${RRCReconfiguratonPCellAfterA4Fr1SuperVisionTimerExpire}
    Verify Tcpdump Log    packet_filter=${RRCReconfiguratonPCellAfterA4Fr1SuperVisionTimerExpire}    number_of_messages=6    relation_symbol= ==

Trigger A1 RSRP Measurement
    [Arguments]    ${ue_id}    ${meas_id}    ${srsrp_nr}=90    ${timeout}=1
    Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=${ue_id} meas_id\=${meas_id} event\=A1 srsrp_nr\=${srsrp_nr}
    ...    timeout=${timeout}

Trigger A4 RSRQ Measurement
    [Arguments]    ${ue_id}    ${pci}    ${meas_id}    ${nrsrq_nr}=95    ${timeout}=1
    Execute Egate Command
    ...    cmd=ue_measurement_send_nr event\=A4 phycell_id\=${pci} nrsrq_nr\=${nrsrq_nr} id\=${ue_id} meas_id\=${meas_id}
    ...    timeout=${timeout}

Start DL Data Traffic
    [Arguments]    ${ue_id}=4   ${pdu_id}=3    ${Inactive Timer}=100ms
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=1 dir=dl mbps=175
    BuiltIn.Sleep    ${Inactive Timer}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=2 dir=dl mbps=175
    BuiltIn.Sleep    ${Inactive Timer}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=3 dir=dl mbps=175
    BuiltIn.Sleep    ${Inactive Timer}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=4 dir=dl mbps=175
    BuiltIn.Sleep    ${Inactive Timer}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=5 dir=dl mbps=175
    BuiltIn.Sleep    ${Inactive Timer}

Verify Buffer Monitoring Notification
    [Arguments]    ${BufferMonitoringVerification}    ${number_of_messages}
    Verify Tcpdump Log    packet_filter=${BufferMonitoringVerification}    number_of_messages=${number_of_messages}

Verify Buffer Criterion Notification
    [Arguments]    ${BufferCriterionVerification}
    Verify Tcpdump Log    packet_filter=${BufferCriterionVerification}

Verify RRC A4 Measurement Removal
    [Arguments]    ${RRCReconfigurationAfterA4}
    Verify Tcpdump Log    packet_filter=${RRCReconfigurationAfterA4}

Verify 2 SCells Addition After A4 Event Trigger
    [Arguments]    ${UeContextModReqAfterA4}
    Verify Tcpdump Log    packet_filter=${UeContextModReqAfterA4}

Verify 3CC Configuration After A4 Event Trigger
    [Arguments]    ${UeContextModRespAfterA4}
    Verify Tcpdump Log    packet_filter=${UeContextModRespAfterA4}    number_of_messages=1    relation_symbol= >

Verify RRC SCell Addition
    [Arguments]    ${RRCReconfigurationWithA2}
    Verify Tcpdump Log    packet_filter=${RRCReconfigurationWithA2}

Extended SupervisionTimer
    [Arguments]    ${a4svtimer_value}
    Log to console    Extended SuperVisionTimer to: ${a4svtimer_value}s
    Run Process    /home/ute/test_repository/testsuite/Wroclaw/RRM/WRO_2/CB006733/RND_change_param.sh ${a4svtimer_value}    shell=True

Trigger A4 RSRP Measurement
    [Arguments]    ${ue_id}    ${pci}    ${meas_id}    ${nrsrp_nr}=90    ${timeout}=1
    Execute Egate Command
    ...    cmd=ue_measurement_send_nr event\=A4 phycell_id\=${pci} nrsrp_nr\=${nrsrp_nr} id\=${ue_id} meas_id\=${meas_id}
    ...    timeout=${timeout}

Verify 1 SCells Addition After A4 Event Trigger
    [Arguments]    ${UeContextModReqAfterA4}
    Verify Tcpdump Log    packet_filter=${UeContextModReqAfterA4}

Wait For A4 Retry Timer Expiration
    [Arguments]    ${a4_retry_timer}
    Log to console    \nWaiting ${a4_retry_timer} seconds for retry timers expiration
    BuiltIn.Sleep    ${a4_retry_timer}

Verify A4 Measurement Configuration
    [Arguments]    ${UeContextModReqBeforeA4}    ${number_of_messages}=0
    Sleep    2s    reason=Waiting for messages collection
    Verify Tcpdump Log    packet_filter=${UeContextModReqBeforeA4}    number_of_messages=${number_of_messages}    relation_symbol= >

Verify Measurement Gap Configuration
    [Arguments]    ${UeContextModResp}    ${number_of_messages}=0
    Verify Tcpdump Log    packet_filter=${UeContextModResp}    number_of_messages=${number_of_messages}    relation_symbol= >

Verify RRC Before A4RetryTimer Expiration
    [Arguments]    ${RRCReconfigurationBeforeRetryTimerExp}
    Verify Tcpdump Log    packet_filter=${RRCReconfigurationBeforeRetryTimerExp}    number_of_messages=0    relation_symbol= >

Verify RRC A4 Measurement Configuration
    [Arguments]    ${RRCReconfigurationAfterRetryTimerExp}
    Verify Tcpdump Log    packet_filter=${RRCReconfigurationAfterRetryTimerExp}

Register UE To gNB without PDU session setup
    [Arguments]    ${ue_id}
    Execute Egate Command    cmd=amf_param id=1 empty_pdu_session_list=on send_ics_registration=on
    Execute Egate Command    cmd=ue_register id=${ue_id}
    ...    pass_regexp=Received REGISTRATION COMPLETE from UE

Setup PDU Session With CA Eligible DRB
    [Arguments]    ${ue_id}    ${pdu_id}    ${gw_id}    ${timeout}=3
    Setup PDU Session Only      ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}     timeout=${timeout}

Setup Additional DRB
    [Arguments]    ${additional_qos}    ${smf_id}=1    ${timeout}=3
    Execute Egate Command    cmd=smf_param id=${smf_id} additional_qosflows_to_activate=${additional_qos}
    ...    timeout=${timeout}

Release PDU Session With Non CA Eligible DRB
    [Arguments]    ${ue_id}    ${pdu_id}
    Release PDU session    ue_id=${ue_id}    pdu_id=${pdu_id}

Verify PDU Session Resource Release Command
    [Arguments]    ${PDUSessionResourceReleaseCommand}
    Verify Tcpdump Log    packet_filter=${PDUSessionResourceReleaseCommand}

Verify UE Context Modification Request During PDU Session Release
    [Arguments]    ${UEContextModificationRequest}
    Verify Tcpdump Log    packet_filter=${UEContextModificationRequest}

Verify UE Context Modification Response During PDU Session Release
    [Arguments]    ${UEContextModificationResponse}
    Verify Tcpdump Log    packet_filter=${UEContextModificationResponse}

Verify PDU Session Resource Release Response
    [Arguments]    ${PDUSessionResourceReleaseResponse}
    Verify Tcpdump Log    packet_filter=${PDUSessionResourceReleaseResponse}

Setup PDU Session Only
    [Arguments]    ${ue_id}    ${pdu_id}    ${gw_id}     ${timeout}=3
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1 gw=${gw_id}
    ...    timeout=${timeout}

Setup PDU session with non CA eligible DRB
    [Arguments]    ${ue_id}    ${pdu_id}=3    ${gw_id}=3    ${timeout}=3
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1 gw=${gw_id}
    ...    timeout=${timeout}

Verify PDU Session Resource Setup Request With non CA eligible DRB
    [Arguments]    ${PDUSessionResourceSetupRequest}
    Verify Tcpdump Log    packet_filter=${PDUSessionResourceSetupRequest}

Verify PDU Session Resource Setup Response
    [Arguments]    ${PDUSessionResourceSetupResponse}
    Verify Tcpdump Log    packet_filter=${PDUSessionResourceSetupResponse}

Modify PDU session with CA eligible DRB
    [Arguments]    ${ue_id}    ${timeout}=3
    Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=3 qosflows_to_add=2 by=amf
    ...    timeout=${timeout}

Verify PDU Session Resource Modify Request With CA eligible DRB
    [Arguments]    ${PDUSessionResourceModifyRequest}
    Verify Tcpdump Log    packet_filter=${PDUSessionResourceModifyRequest}

Verify CA eligible DRB Addition
    [Arguments]    ${UeContextModWithEligibleDRB}
    Verify Tcpdump Log    packet_filter=${UeContextModWithEligibleDRB}

Verify PDU Session Resource Modify Response
    [Arguments]    ${PDUSessionResourceModifyResponse}
    Verify Tcpdump Log    packet_filter=${PDUSessionResourceModifyResponse}
