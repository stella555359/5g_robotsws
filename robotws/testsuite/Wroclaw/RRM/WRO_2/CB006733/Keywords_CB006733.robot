*** Keywords ***

Activate feature 6733
    Find Scfc And Send Delta Commissioning Retrying After Errors    scfc_filename=${DELTA}

Expect Configuration Of A4 Measurements For SCell Addition Messages Flow
    [Arguments]    ${ue_id}    ${gNB_id}=2
    Expect Message Flow
    ...    gNB${gNB_id}:F1AP_UEContextModificationRequest (measConfig is present) as UEContextModificationRequest
    ...    gNB${gNB_id}:F1AP_UEContextModificationResponse (measGapConfig is present) as UEContextModificationResponse
    ...    UE${ue_id}:NR-RRC_RRCReconfiguration(reportConfigToAddModList is present) as RRCReconfiguration
    ...    UE${UE_ID}:NR-RRC_RRCReconfigurationComplete as RRCReconfigurationComplete
    ...    alias=A4MeasConfiguration${ue_id}    overall_timeout=60

Attach UE And Verify Establishing PDU Session With A4 Configuration
    [Arguments]    ${ue_id}    ${cell_id}    ${gnb_id}    ${pdu_id}    ${gw_id}
    Create SA Aliases    ue_id=${ue_id}    gNB_id=${gnb_id}
    Set expected messages flows for A4 measurement configuration for UE4, gNB2 and AMF1
    Expect UE Attach Messages Flow     ue_id=${ue_id}    gNB_id=${gnb_id}
    Expect PDU Messages Flow     ue_id=${ue_id}    gNB_id=${gnb_id}
    Expect Configuration Of A4 Measurements For SCell Addition Messages Flow    ue_id=${UE_ID}
    Attach UE And Establish PDU Session    ue_id=${ue_id}    cell_id=${cell_id}    enb_id=${gnb_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Check If UE Attach Messages Flow Occurred     ue_id=${ue_id}
    Check If PDU Messages Flow Occurred     ue_id=${ue_id}
    Check If Configuration Of A4 Measurements For SCell Addition Messages Flow Occured    ue_id=${UE_ID}

Attach Multiple UEs And Verify Establishing PDU Session
    [Arguments]    ${number_of_ues}    ${cell_id}    ${gnb_id}    ${pdu_id}    ${gw_id}    ${supervision_timer}
    ${number_of_simulated_ues_increased_by_one} =    Evaluate    ${number_of_ues}+1
    ${timestamp_before_multiple_ue_registration} =    Get Current Date
    Attach Multiple UEs And Establish PDU Session    num_of_ues=${number_of_simulated_ues_increased_by_one}    cell_id=${cell_id}
    ...    enb_id=${gnb_id}    gw_id=${gw_id}
    ${timestamp_after_multiple_ue_registration} =    Get Current Date
    Verify elepsed time for action    timestamp_A=${timestamp_before_multiple_ue_registration}
    ...    timestamp_B=${timestamp_after_multiple_ue_registration}    message=Multiple (${number_of_ues}) UE registration


Attach Multiple UEs And Establish PDU Session
    [Arguments]    ${num_of_ues}    ${cell_id}    ${enb_id}=1    ${gw_id}=1

    FOR    ${ue_id}    IN RANGE    1    ${num_of_ues}    1
        Attach UE    ue_id=${ue_id}    cell=${cell_id}    enb=${enb_id}    timeout=30
        ...    pass_regexp=Received REGISTRATION COMPLETE from UE
    END
    BuiltIn.Sleep    1
    FOR    ${ue_id}    IN RANGE    1    ${num_of_ues}    1
        ${pdu_id}=  Evaluate  (${ue_id} % 15)+1
        Set Internal Traffic Type To UE    ue_id=${ue_id}    pdu_id=${pdu_id}
    END
    BuiltIn.Sleep    3
    FOR    ${ue_id}    IN RANGE    1    ${num_of_ues}    1
        ${pdu_id}=  Evaluate  (${ue_id} % 15)+1
        Establish PDU Session    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}    nwslice=1
        ...    timeout=30
        ...    pass_regexp=UE${ue_id}: Established PDU session ID=${pdu_id} using PDU Gateway ID=
    END

Release multiple UEs
    [Arguments]    ${num_of_ues}
    ${number_of_simulated_ues_increased_by_one} =    Evaluate    ${num_of_ues}+1
    FOR    ${ue_id}    IN RANGE    1    ${number_of_simulated_ues_increased_by_one}    1
        Execute Egate Command    cmd=ue_deregister id=${ue_id} by=ue ue_deregister_type=switch_off
    END

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

Check If Configuration Of A4 Measurements For SCell Addition Messages Flow Occured
    [Arguments]    ${ue_id}
    Flow Occurred As Expected   alias=A4MeasConfiguration${ue_id}

Verify 6733 Activation Message Contents
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=A4MeasConfiguration${ue_id}

Verify 6733 A4 Activation Message Contents AB12
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_A_B12}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=A4MeasConfiguration${ue_id}

Verify Pm Counters 6733
    [Arguments]    ${cell_id}    ${counter_id}    ${counter_name}    ${local_moid}    ${condition}=>0
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...  ${counter_id}    ${condition}    ${counter_name}
    ...  local_moid=${local_moid}
    ...  file_path=${pm_counter_file}

Deactivate feature 6733
    Find Scfc And Send Delta Commissioning Retrying After Errors    scfc_filename=${DELTA_FOR_DEACTIVATION}

Expect A4 Measurements Are Not Configured Messages Flow
    [Arguments]    ${ue_id}    ${gNB_id}=2
    Expect Message Flow
    ...    UE${ue_id}:NR-RRC_RRCReconfiguration(reportConfigToAddModList is not present) as RRCReconfiguration
    ...    UE${UE_ID}:NR-RRC_RRCReconfigurationComplete as RRCReconfigurationComplete
    ...    alias=A4MeasNotConfigured${ue_id}    overall_timeout=60

Check If A4 Measurements Are Not Configured Flow Occured
    [Arguments]    ${ue_id}
    Flow Occurred As Expected   alias=A4MeasNotConfigured${ue_id}

Attach UE And Verify Establishing PDU Session After Deactivation
    [Arguments]    ${ue_id}    ${cell_id}    ${gnb_id}    ${pdu_id}    ${gw_id}
    BuiltIn.Sleep    40s
    Expect A4 Measurements Are Not Configured Messages Flow    ue_id=${ue_id}    gNB_id=${gnb_id}
    Expect UE Attach Messages Flow     ue_id=${ue_id}    gNB_id=${gnb_id}
    Expect PDU Messages Flow     ue_id=${ue_id}    gNB_id=${gnb_id}
    Attach UE And Establish PDU Session    ue_id=${ue_id}    cell_id=${cell_id}    enb_id=${gnb_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Check If UE Attach Messages Flow Occurred     ue_id=${ue_id}
    Check If PDU Messages Flow Occurred     ue_id=${ue_id}
    Check If A4 Measurements Are Not Configured Flow Occured    ue_id=${ue_id}

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

Verify RRC Reconfiguration After A4 Scell Addittion
    [Arguments]    ${RRCReconfiguratonAfterA4SCellAdd}
    Verify Tcpdump Log    packet_filter=${RRCReconfiguratonAfterA4SCellAdd}

Release UE
    [Arguments]    ${ue_id}    ${pdu_id}
    Release PDU session    ue_id=${ue_id}    pdu_id=${pdu_id}
    Deregister UE    ue_id=${ue_id}

Wait for supervision timer and a4retry timer expiration
    [Arguments]    ${supervision_timer}    ${a4_retry_timer}    ${ue_id}
    ${wait_time} =    Evaluate    ${supervision_timer}+${a4_retry_timer}
    ${wait_time2} =    Convert To String    ${wait_time}
    EXPECT FLOW[timeout=${wait_time2}]: UE${ue_id} NR-RRC RRCReconfiguration
    Log to console    \nWaiting ${wait_time} seconds for supervision and retry timers expiration
    BuiltIn.Sleep    ${wait_time}
    FAIL FLOW[timeout=${wait_time2}]: UE${ue_id} NR-RRC RRCReconfiguration

Trigger A2 Measurement
    [Arguments]    ${ue_id}    ${meas_id}    ${srsrp_nr}=20    ${timeout}=60    ${NSA_MODE}=${FALSE}
    ${confirmation_message} =	Set Variable If	${NSA_MODE} == ${FALSE}    rrcReconfigurationComplete	rrcConnectionReconfigurationComplete
    Execute Egate Command And Wait For Data
    ...    cmd=ue_meas_cfg_disp id\=${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id\=${ue_id} meas_id\=${meas_id} event\=A2 srsrp_nr\=${srsrp_nr}
    ...    pass_regexp=message c1 : ${confirmation_message}
    ...    timeout=${timeout}

Trigger A2 Measurement For Both Cells
    [Arguments]    ${ue_id}    ${param1}    ${param2}
    Execute Egate Command    cmd=ue_meas_cfg_disp id\=${ue_id}
    Execute Egate Command    cmd=ue_measurement_send_nr ${param1}
    Execute Egate Command    cmd=ue_measurement_send_nr ${param2}

Trigger A1 Measurement
    [Arguments]    ${ue_id}    ${meas_id}    ${srsrp_nr}=90    ${timeout}=60    ${NSA_MODE}=${FALSE}
    ${confirmation_message} =	Set Variable If	${NSA_MODE} == ${FALSE}    message c1 : rrcReconfigurationComplete
    ...    Dispatch UlInformationTransferMRDC Message
    Execute Egate Command And Wait For Data
    ...    cmd=ue_meas_cfg_disp id\=${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id\=${ue_id} meas_id\=${meas_id} event\=A1 srsrp_nr\=${srsrp_nr}
    ...    pass_regexp=${confirmation_message}
    ...    timeout=${timeout}

Trigger A3 Measurement
    [Arguments]    ${ue_id}    ${nrsrp_nr}    ${cell_id}    ${meas_id}    ${timeout}=60    ${NSA_MODE}=${FALSE}
    ${confirmation_message} =	Set Variable If	${NSA_MODE} == ${FALSE}    rrcReconfigurationComplete	rrcConnectionReconfigurationComplete
    Execute Egate Command And Wait For Data
    ...    cmd=ue_meas_cfg_disp id\=${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id\=${ue_id} meas_id\=${meas_id} event\=A3 phycell_id\=${cell_id} nrsrp_nr\=${nrsrp_nr}
    ...    pass_regexp=message c1 : ${confirmation_message}
    ...    timeout=${timeout}

Trigger A4 Measurement For RSRQ And RSRP
    [Arguments]    ${ue_id}    ${meas_id_rsrq}    ${meas_id_rsrp}    ${phycell_id_cell2}     ${phycell_id_cell3}    ${timeout}=60
    Execute Egate Command    cmd=ue_meas_cfg_disp id\=${ue_id}
    Execute Egate Command    cmd=ue_measurement_send_nr id\=${ue_id} meas_id\=${meas_id_rsrq} event\=A4 phycell_id\=${phycell_id_cell2} nrsrq_nr\=95
    Execute Egate Command    cmd=ue_measurement_send_nr id\=${ue_id} meas_id\=${meas_id_rsrp} event\=A4 phycell_id\=${phycell_id_cell3} nrsrp_nr\=90

Trigger B2 Measurement
    [Arguments]    ${ue_id}    ${nrsrp_nr}    ${nrsrq_nr}    ${cell_id}    ${meas_id}    ${timeout}=60

    Create UE Alias    alias=B2_Meas_UE_${ue_id}    ue_id=${ue_id}    id_type=wts_5g
    Expect Message Flow
    ...    UE${ue_id}:NR-RRC_MeasurementReport as MeasurementReport
    ...    UE${ue_id}:NR-RRC_MobilityFromNRCommand as MobilityFromNRCommand
    ...    alias=B2_Meas_UE_${ue_id}   overall_timeout=${timeout}

    Execute Egate Command And Wait For Data
    ...    cmd=ue_meas_cfg_disp id\=${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id\=${ue_id} meas_id\=${meas_id} event\=B2 phycell_id\=${cell_id} nrsrp_nr\=${nrsrp_nr} nrsrq_nr\=${nrsrq_nr}
    ...    pass_regexp=message c1 : rrcConnectionReconfigurationComplete
    ...    timeout=${timeout}

    Flow Occurred As Expected    alias=B2_Meas_UE_${ue_id}
    Stabilization Time

Start Low DL non-GBR Data Traffic
    [Arguments]    ${ue_id}   ${pdu_id}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=1 dir=dl mbps=1
    BuiltIn.Sleep    2

Start High DL non-GBR Data Traffic AB12
    [Arguments]    ${ue_id}   ${pdu_id}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=1 dir=dl mbps=150
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=2 dir=dl mbps=150
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=3 dir=dl mbps=125
    BuiltIn.Sleep    2

Set ${all:\d+} expected UE Context Modification messages for A2 A4 handling for UE${ue_id:\d+} and gNB${gnb_id:\d+}
    EXPECT FLOW[timeout=30]: gNB${gnb_id} F1AP ${all}*uEContextModification

Verify ${all:\d+} UE Context Modification messages for A2 A4 handling for UE${ue_id:\d+} and gNB${gnb_id:\d+} occured
    PASS FLOW[timeout=30]: gNB${gnb_id} F1AP ${all}*uEContextModification

Verify ${all:\d+} UE Context Modification messages for SCell addition for UE${ue_id:\d+} and gNB${gnb_id:\d+} occured
    PASS FLOW[timeout=90]: gNB${gnb_id} F1AP ${all}*uEContextModification

Check If Configuration Of A2 Measurement Messages Flow Occured
    [Arguments]    ${ue_id}
    Flow Occurred As Expected   alias=A2MeasConfiguration${ue_id}

Check If Configuration Of A4 For SCell Addition Messages Flow Occured
    [Arguments]    ${ue_id}
    Flow Occurred As Expected   alias=A4MeasConfiguration${ue_id}

Verify If A2 Message Trigger Took Place Before Supervision Timer Expiration
    [Arguments]    ${ue_register_timestamp}    ${after_A2_meas_timestamp}    ${supervision_timer}
    ${timeTotalMs} =    Subtract Date From Date    ${after_A2_meas_timestamp}    ${ue_register_timestamp}    result_format=number
    Log to console    Elapsed time between PDU setup and A2 trigger should be less than supervion timer duration
    Log to console    supervision timer duration = ${supervision_timer}
    Log to console    elapsed time = ${timeTotalMs}
    Should Be True     ${timeTotalMs}<${supervision_timer}

Verify elepsed time for action
    [Arguments]    ${timestamp_A}    ${timestamp_B}    ${message}
    ${timeTotal} =    Subtract Date From Date    ${timestamp_B}    ${timestamp_A}    result_format=number
    Log to console    Elapsed time for ${message} = ${timeTotal}

Set Message Flow Expectations for UE Attach and A2 Measurement Trigger
    [Arguments]    ${ue_id}    ${gnb_id}
    Expect UE Attach Messages Flow     ue_id=${ue_id}    gNB_id=${gnb_id}
    Expect PDU Messages Flow     ue_id=${ue_id}    gNB_id=${gnb_id}
    Set 5 expected UE Context Modification messages for A2 A4 handling for UE4 and gNB2
    Set 3 expected RRC Reconfiguration Request and Complete messages for UE4
    Set 9 expected DLRRCMessageTransfer messages for gNB2
    Set 11 expected ULRRCMessageTransfer messages for gNB2
    Set expected Measurement Report messages for for UE4
    Expect Configuration Of A2 Measurement Messages Flow    ue_id=${ue_id}
    Expect Configuration Of A4 For SCell Addition Messages Flow    ue_id=${ue_id}

Set Message Flow Expectations for UE Attach and A2 Measurement Trigger For HO
    [Arguments]    ${ue_id}    ${gnb_id}
    Expect UE Attach Messages Flow     ue_id=${ue_id}    gNB_id=${gnb_id}
    Expect PDU Messages Flow     ue_id=${ue_id}    gNB_id=${gnb_id}
    Set 2 expected RRC Reconfiguration Request and Complete messages after HO for UE4
    Set expected Measurement Report messages timeout 9s for UE4
    Expect Configuration Of A2 Measurement Messages Flow    ue_id=${ue_id}

Check Message Flow Expectations for UE Attach and A2 Measurement Trigger
    [Arguments]    ${ue_id}
    Check If UE Attach Messages Flow Occurred     ue_id=${ue_id}
    Check If PDU Messages Flow Occurred     ue_id=${ue_id}
    Verify 5 UE Context Modification messages for A2 A4 handling for UE4 and gNB2 occured
    Verify that all 3 RRC Reconfiguration Request and Complete messages occured for UE4
    Verify that all 9 DLRRCMessageTransfer messages occured for gNB2
    Verify that all 11 ULRRCMessageTransfer messages occured for gNB2
    Verify that Measurement Report messages occured for UE4
    Check If Configuration Of A2 Measurement Messages Flow Occured    ue_id=${ue_id}
    Check If Configuration Of A4 For SCell Addition Messages Flow Occured    ue_id=${ue_id}

Check Message Flow Expectations for UE Attach and A2 Measurement Trigger For HO
    [Arguments]    ${ue_id}
    Check If UE Attach Messages Flow Occurred     ue_id=${ue_id}
    Check If PDU Messages Flow Occurred     ue_id=${ue_id}
    Verify that all 2 RRC Reconfiguration Request and Complete messages after HO occured for UE4
    Verify that Measurement Report messages timeout 9s occured for UE4
    Check If Configuration Of A2 Measurement Messages Flow Occured    ue_id=${ue_id}

Set ${all:\d+} expected UE Context Modification messages for A1 A4 handling for UE${ue_id:\d+} and gNB${gnb_id:\d+}
    EXPECT FLOW[timeout=90]: gNB${gnb_id} F1AP ${all}*uEContextModification

Set ${all:\d+} expected UE Context Modification messages for SCell addition for UE${ue_id:\d+} and gNB${gnb_id:\d+}
    EXPECT FLOW[timeout=90]: gNB${gnb_id} F1AP ${all}*uEContextModification

Verify ${all:\d+} UE Context Modification messages for A1 A4 handling for UE${ue_id:\d+} and gNB${gnb_id:\d+} occured
    PASS FLOW[timeout=90]: gNB${gnb_id} F1AP ${all}*uEContextModification

Set ${all:\d+} expected UE Context Modification messages for A3 A4 handling for UE${ue_id:\d+} and gNB${gnb_id:\d+}
    EXPECT FLOW[timeout=9]: gNB${gnb_id} F1AP ${all}*uEContextModification

Verify ${all:\d+} UE Context Modification messages for A3 A4 handling for UE${ue_id:\d+} and gNB${gnb_id:\d+} occured
    PASS FLOW[timeout=9]: gNB${gnb_id} F1AP ${all}*uEContextModification

Attach UE And Verify Establishing PDU Session With following A2 Measurement Trigger
    [Arguments]    ${ue_id}    ${cell_id}    ${gnb_id}    ${pdu_id}    ${gw_id}    ${supervision_timer}
    Create SA Aliases    ue_id=${ue_id}    gNB_id=${gnb_id}
    Set Message Flow Expectations for UE Attach and A2 Measurement Trigger    ue_id=${ue_id}    gnb_id=${gnb_id}

    ${UE_register_timestamp} =    Get Current Date
    Attach UE And Establish PDU Session    ue_id=${ue_id}    cell_id=${cell_id}    enb_id=${gnb_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Start Low DL non-GBR Data Traffic    ue_id=${ue_id}   pdu_id=${pdu_id}
    Verify That Throughput Is Reached On All SCells    ue_id=${ue_id}    num_of_scells=0    expected_throughput=0.1Mbps
    Trigger A2 Measurement    ue_id=${ue_id}     meas_id=1    srsrp_nr=20    timeout=60
    ${after_A2_meas_timestamp} =    Get Current Date

    Verify If A2 Message Trigger Took Place Before Supervision Timer Expiration    ue_register_timestamp=${UE_register_timestamp}
    ...    after_A2_meas_timestamp=${after_A2_meas_timestamp}    supervision_timer=${supervision_timer}

    Check Message Flow Expectations for UE Attach and A2 Measurement Trigger    ue_id=${ue_id}

Attach UE And Verify Establishing PDU Session With Following A2 Measurement Trigger For HO
    [Arguments]    ${ue_id}    ${cell_id}    ${gnb_id}    ${pdu_id}    ${gw_id}    ${supervision_timer}
    Create SA Aliases    ue_id=${ue_id}    gNB_id=${gnb_id}
    Set Message Flow Expectations for UE Attach and A2 Measurement Trigger For HO    ue_id=${ue_id}    gnb_id=${gnb_id}

    Attach UE And Establish PDU Session    ue_id=${ue_id}    cell_id=${cell_id}    enb_id=${gnb_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Trigger A2 Measurement   ue_id=${ue_id}     meas_id=1    srsrp_nr=19    timeout=60

    Check Message Flow Expectations for UE Attach and A2 Measurement Trigger For HO    ue_id=${ue_id}

Trigger A1 Measurement And Wait for A4 Measurement Reactivation
    [Arguments]    ${ue_id}   ${gnb_id}

    Set Message Flow Expectations for A1 Measurement Trigger and A4 Measurement Reactivation    ue_id=${ue_id}    gnb_id=${gnb_id}

    Trigger A1 Measurement    ue_id=${ue_id}     meas_id=18    srsrp_nr=90    timeout=60

    Check Message Flow Expectations for A1 Measurement Trigger and A4 Measurement Reactivation    ue_id=${ue_id}
    Verify That Throughput Is Reached On All SCells    ue_id=${ue_id}    num_of_scells=0    expected_throughput=0.1Mbps

Trigger A2 Measurements And Wait for A4 Measurement Reactivation
    [Arguments]    ${ue_id}    ${gnb_id}    ${param1}    ${param2}
    Set Message Flow Expectations for A2 Measurement Trigger and A4 Measurement Reactivation    ue_id=${ue_id}    gnb_id=${gnb_id}
    Expect SCell Release messages flow A_B12 Cell 2     ${ue_id}    ${gnb_id}
    Expect SCell Release messages flow A_B12 Cell 3     ${ue_id}    ${gnb_id}
    Trigger A2 Measurement For Both Cells    ${ue_id}    ${param1}    ${param2}
    Check Message Flow Expectations for A2 Measurement Trigger and A4 Measurement Reactivation    ue_id=${ue_id}

Trigger A4 Measurement And Start High Data Traffic
    [Arguments]    ${ue_id}   ${gnb_id}    ${pdu_id}    ${meas_id_rsrq}    ${meas_id_rsrp}    ${phycell_id_cell2}    ${phycell_id_cell3}
    Set Message Flow Expectations for A4 Measurement Trigger and Starting Data Traffic    ue_id=${ue_id}    gnb_id=${gnb_id}
    Expect SCell Addition Messages Flow B_B12   ue_id=${ue_id}    gnb_id=${gnb_id}
    Trigger A4 Measurement For RSRQ And RSRP    ue_id=${ue_id}     meas_id_rsrq=${meas_id_rsrq}    meas_id_rsrp=${meas_id_rsrp}
    ...    phycell_id_cell2=${phycell_id_cell2}    phycell_id_cell3=${phycell_id_cell3}
    Start High DL non-GBR Data Traffic AB12    ue_id=${ue_id}   pdu_id=${pdu_id}
    Check Message Flow Expectations for A4 Measurement Trigger and Starting Data Traffic AB12    ue_id=${ue_id}
    Verify That Throughput Is Reached On All SCells    ue_id=${ue_id}    num_of_scells=2    expected_throughput=5Mbps

Perform HO To Target Cell For UE
    [Arguments]    ${ue_id}   ${gnb_id}    ${phycell_id}    ${nrsrp_nr}    ${expected_A4_configuration}=${TRUE}
    Set Message Flow Expectations for A3 Measurement Trigger and A4 Measurement Configuration    ue_id=${ue_id}    gnb_id=${gnb_id}
    ...    expected_A4_configuration=${expected_A4_configuration}
    Trigger A3 Measurement    ue_id=${ue_id}    cell_id=${phycell_id}     nrsrp_nr=${nrsrp_nr}    meas_id=3
    Check Message Flow Expectations for A3 Measurement Trigger and A4 Measurement Configuration    ue_id=${ue_id}
    ...    expected_A4_configuration=${expected_A4_configuration}

Perform Inter RAT Handover
    [Arguments]    ${ue_id}      ${targer_gnb}      ${target_cell}      ${plmn}      ${timeout}=30
    Execute Egate Command And Wait For Data
    ...    cmd=ue_disp id\=${ue_id} type\=cell
    Execute Egate Command And Wait For Data
    ...    cmd=gnb_trigger_inter_rat_handover_to_5g ue\=${ue_id} target_gnb\=${targer_gnb} target_cell\=${target_cell} plmn\=${plmn}
    ...    pass_regexp=message c1 : rrcReconfigurationComplete
    ...    timeout=${timeout}

Set Message Flow Expectations for A1 Measurement Trigger and A4 Measurement Reactivation
    [Arguments]    ${ue_id}    ${gnb_id}
    Set 6 expected UE Context Modification messages for A1 A4 handling for UE4 and gNB2
    Set 3 expected RRC Reconfiguration Request and Complete messages for UE4
    Set 3 expected DLRRCMessageTransfer messages for gNB2
    Set 3 expected ULRRCMessageTransfer messages for gNB2
    Set expected Measurement Report messages for for UE4
    Expect Configuration Of A2 Measurement Messages Flow    ue_id=${ue_id}
    Expect 2nd Configuration Of A4 For SCell Addition Messages Flow    ue_id=${ue_id}
    Expect 2nd Deconfiguration Of A4 For SCell Addition Messages Flow    ue_id=${ue_id}

Set Message Flow Expectations for A2 Measurement Trigger and A4 Measurement Reactivation
    [Arguments]    ${ue_id}    ${gnb_id}
    Set 19 expected UE Context Modification messages for SCell addition for UE4 and gNB2
    Set 7 expected RRC Reconfiguration Request and Complete messages for UE4
    Set 2 expected Measurement Report messages for UE4

Set Message Flow Expectations for A3 Measurement Trigger and A4 Measurement Configuration
    [Arguments]    ${ue_id}    ${gnb_id}    ${expected_A4_configuration}
    ${ue_con_req} =	Set Variable If	${expected_A4_configuration} == ${TRUE}    4	2
    ${rrc_recon} =	Set Variable If	${expected_A4_configuration} == ${TRUE}    2	1
    Set ${ue_con_req} expected UE Context Modification messages for A3 A4 handling for UE4 and gNB2
    Set ${rrc_recon} expected RRC Reconfiguration Request and Complete messages after HO for UE4
    Set expected Measurement Report messages timeout 9s for UE4

Set Message Flow Expectations for A4 Measurement Trigger and Starting Data Traffic
    [Arguments]    ${ue_id}    ${gnb_id}
    Set 3 expected PrivateMessages for A4 Measurement Trigger for UE4 and gNB2
    Set 5 expected UE Context Modification messages for SCell addition for UE4 and gNB2
    Set 2 expected RRC Reconfiguration Request and Complete messages after A4 Measurement Report for UE4
    Set 2 expected Measurement Report messages timeout 9s for UE4

Check Message Flow Expectations for A1 Measurement Trigger and A4 Measurement Reactivation
    [Arguments]    ${ue_id}
    Verify 6 UE Context Modification messages for A1 A4 handling for UE4 and gNB2 occured
    Verify that all 3 RRC Reconfiguration Request and Complete messages occured for UE4
    Verify that all 3 DLRRCMessageTransfer messages occured for gNB2
    Verify that all 3 ULRRCMessageTransfer messages occured for gNB2
    Verify that Measurement Report messages occured for UE4
    Check If Configuration Of A2 Measurement Messages Flow Occured    ue_id=${ue_id}
    Check If 2nd Configuration Of A4 For SCell Addition Messages Flow Occured    ue_id=${ue_id}
    Check If 2nd Deconfiguration Of A4 For SCell Addition Messages Flow Occured        ue_id=${ue_id}

Check Message Flow Expectations for A2 Measurement Trigger and A4 Measurement Reactivation
    [Arguments]    ${ue_id}
    Verify 19 UE Context Modification messages for SCell addition for UE4 and gNB2 occured
    Verify that all 7 RRC Reconfiguration Request and Complete messages occured for UE4
    Verify that all 2 Measurement Report messages occured for UE4 after A2

Check Message Flow Expectations for A3 Measurement Trigger and A4 Measurement Configuration
    [Arguments]    ${ue_id}    ${expected_A4_configuration}
    ${ue_con_req} =	Set Variable If	${expected_A4_configuration} == ${TRUE}    4	2
    ${rrc_recon} =	Set Variable If	${expected_A4_configuration} == ${TRUE}    2	1
    Verify ${ue_con_req} UE Context Modification messages for A3 A4 handling for UE4 and gNB2 occured
    Verify that all ${rrc_recon} RRC Reconfiguration Request and Complete messages after HO occured for UE4
    Verify that Measurement Report messages timeout 9s occured for UE4

Check Message Flow Expectations for A4 Measurement Trigger and Starting Data Traffic AB12
    [Arguments]    ${ue_id}
    Verify that all 3 expected PrivateMessages occured A4 Measurement Trigger for UE4 and gNB2
    Verify 5 UE Context Modification messages for SCell addition for UE4 and gNB2 occured
    Verify that all 2 RRC Reconfiguration Request and Complete messages after A4 Measurement Report occured for UE4
    Verify that all 2 Measurement Report messages occured for UE4

Expect Configuration Of A2 Measurement Messages Flow
    [Arguments]    ${ue_id}    ${gNB_id}=2
    Expect Message Flow
    ...    UE${ue_id}:NR-RRC_RRCReconfiguration (reportConfigToAddModList is present and eventA2 is present) as RRCReconfiguration
    ...    alias=A2MeasConfiguration${ue_id}    overall_timeout=60

Expect Configuration Of A4 For SCell Addition Messages Flow
    [Arguments]    ${ue_id}    ${gNB_id}=2
    Expect Message Flow
    ...    UE${ue_id}:NR-RRC_RRCReconfiguration(reportConfigToAddModList is present and eventA4 is present) as RRCReconfiguration
    ...    alias=A4MeasConfiguration${ue_id}    overall_timeout=60

Expect 2nd Configuration Of A4 For SCell Addition Messages Flow
    [Arguments]    ${ue_id}    ${gNB_id}=2
    Expect Message Flow
    ...    UE${ue_id}:NR-RRC_RRCReconfiguration(length(measIdToAddModList) eq 6) as RRCReconfiguration
    ...    alias=2nd_A4MeasConfiguration${ue_id}    overall_timeout=90

Check If 2nd Configuration Of A4 For SCell Addition Messages Flow Occured
    [Arguments]    ${ue_id}
    Flow Occurred As Expected   alias=2nd_A4MeasConfiguration${ue_id}

Wait For Supervision Timer Expiration
    [Arguments]    ${inactive_timer}
    BuiltIn.Sleep    ${inactive_timer}

Expect 2nd Deconfiguration Of A4 For SCell Addition Messages Flow
    [Arguments]    ${ue_id}    ${gNB_id}=2
    Expect Message Flow
    ...    UE${ue_id}:NR-RRC_RRCReconfiguration(length(measIdToRemoveList) eq 6) as RRCReconfiguration
    ...    alias=A4MeasDeconfiguration${ue_id}    overall_timeout=90

Check If 2nd Deconfiguration Of A4 For SCell Addition Messages Flow Occured
    [Arguments]    ${ue_id}
    Flow Occurred As Expected   alias=A4MeasDeconfiguration${ue_id}

Verify if UE${ue_id:\d+} RRCReconfiguration ${rrc_msg:\d+} of ${all:\d+} contains A2 deconfiguration and A1 A3 A5 configuration after A2 trigger
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${Meas_Config_With_A1_A3_A5_Measurements_Configuration_In_RRC_Reconf_A_B5}
    ...  message_alias=RRCReconfiguration_${rrc_msg}
    ...  flow_alias=${flow_alias}

Verify If UE${ue_id:\d+} RRCReconfiguration ${rrc_msg:\d+} Of ${all:\d+} Contains A2 Deconfiguration And A1 A3 A5 Configuration Before HO
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${Meas_Config_With_A1_A3_A5_Measurements_Configuration_In_RRC_Reconf_B_B1}
    ...  message_alias=RRCReconfiguration_${rrc_msg}
    ...  flow_alias=${flow_alias}

Verify if UE${ue_id:\d+} RRCReconfiguration ${rrc_msg:\d+} of ${all:\d+} contains A4 measurements deconfiguration and measConfig release
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${Meas_Config_With_A4_Measurements_Deconfiguration_In_RRC_Reconf_A_B12}
    ...  message_alias=RRCReconfiguration_${rrc_msg}
    ...  flow_alias=${flow_alias}

Verify if UE${ue_id:\d+} RRCReconfiguration ${rrc_msg:\d+} of ${all:\d+} contains A2 measurements configuration
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${Meas_Config_With_A2_Measurements_Configuration_In_RRC_Reconf_A_B12}
    ...  message_alias=RRCReconfiguration_${rrc_msg}
    ...  flow_alias=${flow_alias}

Verify if UE${ue_id:\d+} RRCReconfiguration ${rrc_msg:\d+} of ${all:\d+} contains SCellToBeSetupModList
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${SCellToBeSetupModList_A_B12}
    ...  message_alias=RRCReconfiguration_${rrc_msg}
    ...  flow_alias=${flow_alias}

Verify if UE${ue_id:\d+} RRCReconfiguration ${rrc_msg:\d+} of ${all:\d+} contains Cell2 release
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${SCellToRelease_Cell2_A_B12}
    ...  message_alias=RRCReconfiguration_${rrc_msg}
    ...  flow_alias=${flow_alias}

Verify if UE${ue_id:\d+} RRCReconfiguration ${rrc_msg:\d+} of ${all:\d+} contains Cell3 release
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${SCellToRelease_Cell3_A_B12}
    ...  message_alias=RRCReconfiguration_${rrc_msg}
    ...  flow_alias=${flow_alias}

Verify If UE${ue_id:\d+} RRCReconfiguration ${rrc_msg:\d+} Of ${all:\d+} Contains A2 A3 A5 Deconfiguration And MeasGapConfig Release After HO
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    ${message_alias}    Set Variable If    ${all} != 1    RRCReconfiguration_${rrc_msg}    RRCReconfiguration
    Verify That Message Fulfills Query
    ...  ${Meas_Config_With_A1_A3_A5_Measurements_Deconfiguration_In_RRC_Reconf_B_B1}
    ...  message_alias=${message_alias}
    ...  flow_alias=${flow_alias}

Verify if UE${ue_id:\d+} RRCReconfiguration ${rrc_msg:\d+} of ${all:\d+} contains A4 configuration after HO
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_B_B1}
    ...  message_alias=RRCReconfiguration_${rrc_msg}
    ...  flow_alias=${flow_alias}

Verify if UE${ue_id:\d+} RRCReconfiguration ${rrc_msg:\d+} of ${all:\d+} contains A2 configuration and A1 A3 A5 deconfiguration after A1 trigger
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${Meas_Config_With_A2_Measurement_Configuration_and_A1_A3_A5_Measurements_Deconfiguration_In_RRC_Reconf_A_B5}
    ...  message_alias=RRCReconfiguration_${rrc_msg}
    ...  flow_alias=${flow_alias}

Verify if UE${ue_id:\d+} RRCReconfiguration ${rrc_msg:\d+} of ${all:\d+} contains A4 configuration
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_A_B5}
    ...  message_alias=RRCReconfiguration_${rrc_msg}
    ...  flow_alias=${flow_alias}

Verify if Robusstness UE${ue_id:\d+} RRCReconfiguration ${rrc_msg:\d+} of ${all:\d+} contains A4 configuration
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_A_B11}
    ...  message_alias=RRCReconfiguration_${rrc_msg}
    ...  flow_alias=${flow_alias}

Verify if UE${ue_id:\d+} RRCReconfiguration ${rrc_msg:\d+} of ${all:\d+} contains 2nd A4 configuration
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${Meas_Config_With_A4_Measurements_2nd_Configuration_In_RRC_Reconf_A_B5}
    ...  message_alias=RRCReconfiguration_${rrc_msg}
    ...  flow_alias=${flow_alias}

Verify if UE${ue_id:\d+} Measurement Report is expected A2 measurement
    ${flow_alias}=     Get Flow Name
    ...     MeasurementReport
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${A2_measurementReport_A_B5}
    ...  message_alias=MeasurementReport
    ...  flow_alias=${flow_alias}

Verify If UE${ue_id:\d+} Measurement Report For HO Is Expected A2 Measurement
    ${flow_alias}=     Get Flow Name
    ...     MeasurementReport
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${A2_measurementReport_B_B1}
    ...  message_alias=MeasurementReport
    ...  flow_alias=${flow_alias}

Verify if UE${ue_id:\d+} Measurement Report ${meas_rep_msg:\d+} of ${all:\d+} is expected A4 measurement for Cell2
    ${flow_alias}=     Get Flow Name
    ...     ${all}*MeasurementReport
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${A4_measurementReport_RSRQ}
    ...  message_alias=MeasurementReport_${meas_rep_msg}
    ...  flow_alias=${flow_alias}

Verify if UE${ue_id:\d+} Measurement Report ${meas_rep_msg:\d+} of ${all:\d+} is expected A4 measurement for Cell3
    ${flow_alias}=     Get Flow Name
    ...     ${all}*MeasurementReport
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${A4_measurementReport_RSRP}
    ...  message_alias=MeasurementReport_${meas_rep_msg}
    ...  flow_alias=${flow_alias}

Verify if UE${ue_id:\d+} Measurement Report ${meas_rep_msg:\d+} of ${all:\d+} is expected A2 measurement for Cell2
    ${flow_alias}=     Get Flow Name
    ...     ${all}*MeasurementReport
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${A2_measurementReport_Cell2}
    ...  message_alias=MeasurementReport_${meas_rep_msg}
    ...  flow_alias=${flow_alias}

Verify if UE${ue_id:\d+} Measurement Report ${meas_rep_msg:\d+} of ${all:\d+} is expected A2 measurement for Cell3
    ${flow_alias}=     Get Flow Name
    ...     ${all}*MeasurementReport
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${A2_measurementReport_Cell3}
    ...  message_alias=MeasurementReport_${meas_rep_msg}
    ...  flow_alias=${flow_alias}

Verify If UE${ue_id:\d+} Measurement Report For HO Is Expected A3 Measurement
    ${flow_alias}=     Get Flow Name
    ...     MeasurementReport
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${A3_measurementReport_B_B1}
    ...  message_alias=MeasurementReport
    ...  flow_alias=${flow_alias}

Verify if UE${ue_id:\d+} Measurement Report is expected A1 measurement
    ${flow_alias}=     Get Flow Name
    ...     MeasurementReport
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${A1_measurementReport_A_B5}
    ...  message_alias=MeasurementReport
    ...  flow_alias=${flow_alias}

Verify that all ${rrc_comp:\d+} DLRRCMessageTransfer messages occured for gNB${gnb_id:\d+}
    PASS FLOW[timeout=90]: gNB${gnb_id} F1AP ${rrc_comp}*dLRRCMessageTransfer

Verify that all ${rrc_comp:\d+} DLRRCMessageTransfer messages after HO occured for gNB${gnb_id:\d+}
    PASS FLOW[timeout=9]: gNB${gnb_id} F1AP ${rrc_comp}*dLRRCMessageTransfer

Verify that all ${rrc_comp:\d+} ULRRCMessageTransfer messages occured for gNB${gnb_id:\d+}
    PASS FLOW[timeout=90]: gNB${gnb_id} F1AP ${rrc_comp}*uLRRCMessageTransfer

Verify that all ${rrc_comp:\d+} ULRRCMessageTransfer messages after HO occured for gNB${gnb_id:\d+}
    PASS FLOW[timeout=9]: gNB${gnb_id} F1AP ${rrc_comp}*uLRRCMessageTransfer

Set expected Measurement Report messages for for UE${ue_id:\d+}
    EXPECT FLOW[timeout=90]: UE${ue_id} NR-RRC MeasurementReport

Set expected Measurement Report messages timeout ${timeout:\d+}s for UE${ue_id:\d+}
    EXPECT FLOW[timeout=${timeout}]: UE${ue_id} NR-RRC MeasurementReport

Set ${meas_rep_msg:\d+} expected Measurement Report messages timeout ${timeout:\d+}s for UE${ue_id:\d+}
    EXPECT FLOW[timeout=${timeout}]: UE${ue_id} NR-RRC ${meas_rep_msg}*MeasurementReport

Set ${meas_rep_msg:\d+} expected Measurement Report messages for UE${ue_id:\d+}
    EXPECT FLOW[timeout=60]: UE${ue_id} NR-RRC ${meas_rep_msg}*MeasurementReport

Verify that all ${meas_rep_msg:\d+} Measurement Report messages occured for UE${ue_id:\d+} after A2
    PASS FLOW[timeout=60]: UE${ue_id} NR-RRC ${meas_rep_msg}*MeasurementReport

Verify that all ${meas_rep_msg:\d+} Measurement Report messages occured for UE${ue_id:\d+}
    PASS FLOW[timeout=9]: UE${ue_id} NR-RRC ${meas_rep_msg}*MeasurementReport

Verify that Measurement Report messages occured for UE${ue_id:\d+}
    PASS FLOW[timeout=90]: UE${ue_id} NR-RRC MeasurementReport

Verify that Measurement Report messages timeout ${timeout:\d+}s occured for UE${ue_id:\d+}
    PASS FLOW[timeout=${timeout}]: UE${ue_id} NR-RRC MeasurementReport

Verify A2 measurement configuration during ICS
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${Meas_Config_With_A2_Measurements_Configuration_In_RRC_Reconf_A_B5}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=A2MeasConfiguration${ue_id}

Verify A2 Measurement Configuration Before HO
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${Meas_Config_With_A2_Measurements_Configuration_In_RRC_Reconf_B_B1}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=A2MeasConfiguration${ue_id}

Verify ICS Configured FiveQI And PDU Session
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${InitialContextSetupReq_C_B28}
    ...  message_alias=InitialContextSetupRequest
    ...  flow_alias=Established_PDU_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${InitialContextSetupRsp_C_B28}
    ...  message_alias=InitialContextSetupRequest
    ...  flow_alias=Established_PDU_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${InitialContextSetupReq_C_B28}
    ...  message_alias=InitialContextSetupResponse
    ...  flow_alias=Established_PDU_UE${ue_id}

Verify that all ${rrc_comp:\d+} RRC Reconfiguration Request and Complete messages occured for UE${ue_id:\d+}
    PASS FLOW[timeout=90]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfiguration
    PASS FLOW[timeout=90]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfigurationComplete

Verify that all ${rrc_comp:\d+} RRC Reconfiguration Request and Complete messages after HO occured for UE${ue_id:\d+}
    PASS FLOW[timeout=9]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfiguration
    PASS FLOW[timeout=9]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfigurationComplete

Verify that all ${rrc_comp:\d+} RRC Reconfiguration Request and Complete messages after A4 Measurement Report occured for UE${ue_id:\d+}
    PASS FLOW[timeout=60]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfiguration
    PASS FLOW[timeout=60]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfigurationComplete

Verify that all ${private:\d+} expected PrivateMessages occured A4 Measurement Trigger for UE${ue_id:\d+} and gNB${gnb_id:\d+}
    PASS FLOW[timeout=60]: gNB${gnb_id} F1AP ${private}*privateMessage

Set ${rrc_comp:\d+} expected RRC Reconfiguration Request and Complete messages for UE${ue_id:\d+}
    EXPECT FLOW[timeout=90]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfiguration
    EXPECT FLOW[timeout=90]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfigurationComplete

Set ${rrc_comp:\d+} expected RRC Reconfiguration Request and Complete messages after HO for UE${ue_id:\d+}
    EXPECT FLOW[timeout=9]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfiguration
    EXPECT FLOW[timeout=9]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfigurationComplete

Set ${rrc_comp:\d+} expected RRC Reconfiguration Request and Complete messages after A4 Measurement Report for UE${ue_id:\d+}
    EXPECT FLOW[timeout=60]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfiguration
    EXPECT FLOW[timeout=60]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfigurationComplete

Set ${rrc_comp:\d+} expected DLRRCMessageTransfer messages for gNB${gnb_id:\d+}
    EXPECT FLOW[timeout=90]: gNB${gnb_id} F1AP ${rrc_comp}*dLRRCMessageTransfer

Set ${rrc_comp:\d+} expected DLRRCMessageTransfer messages after HO for gNB${gnb_id:\d+}
    EXPECT FLOW[timeout=9]: gNB${gnb_id} F1AP ${rrc_comp}*dLRRCMessageTransfer

Set ${rrc_comp:\d+} expected ULRRCMessageTransfer messages for gNB${gnb_id:\d+}
    EXPECT FLOW[timeout=90]: gNB${gnb_id} F1AP ${rrc_comp}*uLRRCMessageTransfer

Set ${rrc_comp:\d+} expected ULRRCMessageTransfer messages after HO for gNB${gnb_id:\d+}
    EXPECT FLOW[timeout=9]: gNB${gnb_id} F1AP ${rrc_comp}*uLRRCMessageTransfer

#A_B9
Start Data Traffic
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

Trigger A4 RSRP Measurement
    [Arguments]    ${ue_id}    ${pci}    ${meas_id}    ${nrsrp_nr}=90    ${timeout}=1
    Execute Egate Command
    ...    cmd=ue_measurement_send_nr event\=A4 phycell_id\=${pci} nrsrp_nr\=${nrsrp_nr} id\=${ue_id} meas_id\=${meas_id}
    ...    timeout=${timeout}

Trigger A4 RSRQ Measurement
    [Arguments]    ${ue_id}    ${pci}    ${meas_id}    ${nrsrq_nr}=95    ${timeout}=1
    Execute Egate Command
    ...    cmd=ue_measurement_send_nr event\=A4 phycell_id\=${pci} nrsrq_nr\=${nrsrq_nr} id\=${ue_id} meas_id\=${meas_id}
    ...    timeout=${timeout}

Verify A4 Measurement Configuration
    [Arguments]    ${UeContextModReqBeforeA4}    ${number_of_messages}=0
    Verify Tcpdump Log    packet_filter=${UeContextModReqBeforeA4}    number_of_messages=${number_of_messages}    relation_symbol= >

Verify 2 SCells Addition After A4 Event Trigger
    [Arguments]    ${UeContextModReqAfterA4}
    Verify Tcpdump Log    packet_filter=${UeContextModReqAfterA4}

Verify 3CC Configuration After A4 Event Trigger
    [Arguments]    ${UeContextModRespAfterA4}
    Verify Tcpdump Log    packet_filter=${UeContextModRespAfterA4}    number_of_messages=1    relation_symbol= >

Verify RRC A4 Measurement Removal
    [Arguments]    ${RRCReconfigurationAfterA4}
    Verify Tcpdump Log    packet_filter=${RRCReconfigurationAfterA4}

Verify RRC SCell Addition
    [Arguments]    ${RRCReconfigurationWithA2}
    Verify Tcpdump Log    packet_filter=${RRCReconfigurationWithA2}

Verify Buffer Monitoring Notification
    [Arguments]    ${BufferMonitoringVerification}    ${number_of_messages}
    Verify Tcpdump Log    packet_filter=${BufferMonitoringVerification}    number_of_messages=${number_of_messages}

Verify Buffer Criterion Notification
    [Arguments]    ${BufferCriterionVerification}
    Verify Tcpdump Log    packet_filter=${BufferCriterionVerification}

Verify Pm Counter For 3CC Configuration
    [Arguments]    ${local_moid}
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55118C00030    +1    A4_MEASUR_ACT_SCELL_ADD_SA
        ...    M55118C00031    +2    A4_SCELL_ADDED_SA
        ...    local_moid=${local_moid}
        ...    file_path=${pm_counter_file}

Verify PM Counter For Configuration With Simulated eNB
    [Arguments]    ${cell_id}    ${counter_id}    ${counter_name}    ${local_moid}    ${condition}=>130
    Wait For Next Full Pm Interval
    Verify Pm Counters 6733
    ...    cell_id=${cell_id}    counter_id=${counter_id}    counter_name=${counter_name}    local_moid=${local_moid}      condition=${condition}

Stabilization Time
    [Arguments]    ${time}=5s
    BuiltIn.Sleep      ${time}

#CB006733_A_B10
Attach UE To gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    cmd=ue_register id=${ue_id}
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=3 trf_type=internal
    Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=3 nwslice=1 gw=3

Trigger A4 RSRP Measurement for SCell
    [Arguments]    ${ue_id}    ${pci}    ${meas_id}    ${nrsrp_nr}=90
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr event\=A4 phycell_id\=${pci} nrsrp_nr\=${nrsrp_nr} id\=${ue_id} meas_id\=${meas_id}

Trigger A4 RSRQ Measurement for SCell
    [Arguments]    ${ue_id}    ${pci}    ${meas_id}    ${nrsrq_nr}=95
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr event\=A4 phycell_id\=${pci} nrsrq_nr\=${nrsrq_nr} id\=${ue_id} meas_id\=${meas_id}

Verify RSRP Buffer Monitoring Notification Message
    [Arguments]    ${BufferMonitoringMessageRSRP}
    Verify Tcpdump Log    packet_filter=${BufferMonitoringMessageRSRP}

Verify RSRQ Buffer Monitoring Notification Message
    [Arguments]    ${BufferMonitoringMessageRSRQ}
    Verify Tcpdump Log    packet_filter=${BufferMonitoringMessageRSRQ}

Verify SCell Addition After A4 Event Trigger
    [Arguments]    ${UeContextModReqAfterA4}
    Verify Tcpdump Log    packet_filter=${UeContextModReqAfterA4}

Verify 2CC CA Configuration After A4 Event Trigger
    [Arguments]    ${UeContextModRespAfterA4}
    Verify Tcpdump Log    packet_filter=${UeContextModRespAfterA4}    number_of_messages=1

Verify Pm Counter For Scell Added SA
    [Arguments]    ${counter_id}    ${counter_name}    ${local_moid}
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...  ${counter_id}    >0    ${counter_name}
    ...  local_moid=${local_moid}
    ...  file_path=${pm_counter_file}

Verify Rd Counter For Scell Added SA
    [Arguments]    ${counter_name}    ${local_moid}
    ${rd_counter_file}=    Get Next Unpacked Raw Rd Counters File
    Verify Any Counters In File
    ...    ${counter_name}    >0    ${counter_name}
    ...    local_moid=${local_moid}
    ...    file_path=${rd_counter_file}

#CB006733_B_B2
UE Register to simulated gNB And Establish PDU Session
    [Arguments]  ${ue_id}  ${simgNB_id}  ${cell_id}  ${pdu_id}=4  ${gw_id}=4  ${gnb_id}=2  ${nwslice}=1
    Create SA Aliases    ue_id=${ue_id}    gNB_id=${gnb_id}
    Create AMF device with alias 'AMF1' identified by ip=10.0.1.1
    Log to console  UE Register And Establish PDU Session on simulator side..
    Change UE Location  ue_id=${ue_id}  cell_id=${cell_id}
    Attach UE And Establish PDU Session    ue_id=${ue_id}    cell_id=${cell_id}    enb_id=${simgNB_id}    pdu_id=${pdu_id}    gw_id=${gw_id}

Change UE Location
    [Arguments]  ${ue_id}  ${cell_id}
    Execute egate command   cmd=ue_change_location id=${ue_id} enb=3 cell=${cell_id}
    Execute egate command
    ...     cmd=ue_history_information_list_add_ngran id=4 gnb_id=3 cell_type=medium nrcgi=311:489|0x01 time_ue_stayed_in_cell=100
    Execute egate command   cmd=ue_history_information_list id=4 action=commit
    Execute egate command   cmd=ue_enb_param id=${ue_id} ue_history_list=4

Trigger Inter-frequency Inter-gNB HO based on A3 Measurement
    [Arguments]    ${ue_id}    ${nrsrp_nr}    ${cell_id}    ${meas_id}    ${srsrp_nr}=19    ${timeout}=60
    Execute Egate Command And Wait For Data
    ...    cmd=ue_meas_cfg_disp id\=${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id\=${ue_id} meas_id\=${meas_id} event\=A3 srsrp_nr\=${srsrp_nr} phycell_id\=${cell_id} nrsrp_nr\=${nrsrp_nr}
    ...    pass_regexp=message c1 : rrcReconfigurationComplete
    ...    timeout=${timeout}

Perform Inter-gNB HO via XN from sim gNB to real gNB
    [Arguments]  ${ue_id}  ${gnb_id}  ${phycell_id}  ${nrsrp_nr}=100
    Expect Inter-gNB XNAP Handover Message Flow    ue_id=${ue_id}
    Set Message Flow Expectations for A4 Measurement Configuration    ue_id=${ue_id}    gnb_id=${gnb_id}
    Trigger Inter-frequency Inter-gNB HO based on A3 Measurement    ue_id=${ue_id}    cell_id=${phycell_id}     nrsrp_nr=${nrsrp_nr}    meas_id=7
    Check If Inter-gNB XNAP Handover Flow Occured    ue_id=${ue_id}
    Check Message Flow Expectations for A4 Measurement Configuration    ue_id=${ue_id}

Expect Inter-gNB XNAP Handover Message Flow
    [Arguments]    ${ue_id}
    Expect Message Flow
    ...    gNB2:XNAP_HandoverRequest
    ...    gNB2:XNAP_HandoverRequestAcknowledge
    ...    gNB2:XNAP_SNStatusTransfer
    ...    UE4:NR-RRC_RRCReconfigurationComplete
    ...    gNB2:NGAP_PathSwitchRequest
    ...    AMF1:NGAP_PathSwitchRequestAcknowledge
    ...    gNB2:XNAP_UEContextRelease
    ...    alias=XnAPHandover_UE${ue_id}    overall_timeout=60

Check If Inter-gNB XNAP Handover Flow Occured
    [Arguments]    ${ue_id}
    Flow Occurred As Expected    alias=XnAPHandover_UE${ue_id}

Set ${all:\d+} expected UE Context Modification messages for A4 handling for UE${ue_id:\d+} and gNB${gnb_id:\d+}
    EXPECT FLOW[timeout=30]: gNB${gnb_id} F1AP ${all}*uEContextModification

Verify ${all:\d+} UE Context Modification messages for A4 handling for UE${ue_id:\d+} and gNB${gnb_id:\d+} occured
    PASS FLOW[timeout=30]: gNB${gnb_id} F1AP ${all}*uEContextModification

Set Message Flow Expectations for A4 Measurement Configuration
    [Arguments]    ${ue_id}    ${gnb_id}
    Set 3 expected UE Context Modification messages for A4 handling for UE4 and gNB2
    Set expected RRC Reconfiguration Request and Complete messages after Inter-gNB HO via Xn for UE4

Check Message Flow Expectations for A4 Measurement Configuration
    [Arguments]    ${ue_id}
    Verify 3 UE Context Modification messages for A4 handling for UE4 and gNB2 occured
    Verify that RRC Reconfiguration Request and Complete messages after Inter-gNB HO via XN occured for UE4

Set expected RRC Reconfiguration Request and Complete messages after Inter-gNB HO via Xn for UE${ue_id:\d+}
    EXPECT FLOW[timeout=30]: UE${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=30]: UE${ue_id} NR-RRC RRCReconfigurationComplete

Verify that RRC Reconfiguration Request and Complete messages after Inter-gNB HO via XN occured for UE${ue_id:\d+}
    PASS FLOW[timeout=30]: UE${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=30]: UE${ue_id} NR-RRC RRCReconfigurationComplete

Verify if UE${ue_id:\d+} RRCReconfiguration contains A4 configuration after Inter-gNB HO via XN
    ${flow_alias}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_B_B2}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=${flow_alias}

Attach Robusstness UE And Verify Establishing PDU Session
    [Arguments]    ${ue_id}    ${cell_id}    ${gnb_id}    ${pdu_id}    ${gw_id}    ${supervision_timer}
    Create SA Aliases    ue_id=${ue_id}    gNB_id=${gnb_id}
    Set Message Flow Expectations for UE Attach and A4 Measurements Trigger    ue_id=${ue_id}    gnb_id=${gnb_id}
    Attach UE And Establish PDU Session    ue_id=${ue_id}    cell_id=${cell_id}    enb_id=${gnb_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Check Message Flow Expectations for UE Attach and A4 Measurements Trigger    ue_id=${ue_id}

Set Message Flow Expectations for UE Attach and A4 Measurements Trigger
    [Arguments]    ${ue_id}    ${gnb_id}
    Expect UE Attach Messages Flow     ue_id=${ue_id}    gNB_id=${gnb_id}
    Expect PDU Messages Flow     ue_id=${ue_id}    gNB_id=${gnb_id}
    Set 3 expected RRC Reconfiguration Request and Complete messages for Robusstness UE${ue_id} and 15 s timeout

Check Message Flow Expectations for UE Attach and A4 Measurements Trigger
    [Arguments]    ${ue_id}
    Check If UE Attach Messages Flow Occurred     ue_id=${ue_id}
    Check If PDU Messages Flow Occurred     ue_id=${ue_id}
    Verify that all 3 RRC Reconfiguration Request and Complete messages occured for Robusstness UE${ue_id} and 15 s timeout

Set ${rrc_comp:\d+} expected RRC Reconfiguration Request and Complete messages for Robusstness UE${ue_id:\d+} and ${time_out:\d+} s timeout
    EXPECT FLOW[timeout=${time_out}]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfiguration
    EXPECT FLOW[timeout=${time_out}]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfigurationComplete

Verify that all ${rrc_comp:\d+} RRC Reconfiguration Request and Complete messages occured for Robusstness UE${ue_id:\d+} and ${time_out:\d+} s timeout
    PASS FLOW[timeout=${time_out}]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfiguration
    PASS FLOW[timeout=${time_out}]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfigurationComplete

Set ${rrc_comp:\d+} expected RRC Reconfiguration Request and Complete messages for UE${ue_id:\d+} and ${time_out:\d+} s timeout
    EXPECT FLOW[timeout=${time_out}]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfiguration
    EXPECT FLOW[timeout=${time_out}]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfigurationComplete

Verify that all ${rrc_comp:\d+} RRC Reconfiguration Request and Complete messages occured for UE${ue_id:\d+} and ${time_out:\d+} s timeout
    PASS FLOW[timeout=${time_out}]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfiguration
    PASS FLOW[timeout=${time_out}]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfigurationComplete

Wait Till Second Supervision Timer Launch
    [Arguments]    ${ue_id}    ${cell_id}    ${gnb_id}    ${pdu_id}    ${gw_id}    ${supervision_timer}
    Set 1 expected RRC Reconfiguration Request and Complete messages for Robusstness UE${ue_id} and 61 s timeout
    Verify that all 1 RRC Reconfiguration Request and Complete messages occured for Robusstness UE${ue_id} and 61 s timeout

Trigger Double A4 Measurements
    [Arguments]    ${ue_id}    ${first_meas_id}    ${second_meas_id}    ${nrsrp_nr}=100    ${nrsrq_nr}=100    ${timeout}=15
    Execute Egate Command And Wait For Data
    ...    cmd=ue_meas_cfg_disp id\=${ue_id}
    Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=${ue_id} meas_id\=${first_meas_id} event\=A4 phycell_id=55 nrsrp_nr=100 nrsrq_nr=100
    Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=${ue_id} meas_id\=${second_meas_id} event\=A4 phycell_id=56 nrsrp_nr=100 nrsrq_nr=100

Start High DL non-GBR Data Traffic
    [Arguments]    ${ue_id}   ${pdu_id}    ${trf_level}=175    ${trf_id_1}=1    ${trf_id_2}=2    ${trf_id_3}=3
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=${trf_id_1} dir=dl mbps=${trf_level}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=${trf_id_2} dir=dl mbps=${trf_level}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=${trf_id_3} dir=dl mbps=${trf_level}


Trigger Double A4 Measurements and Start High DL Data Traffic
    [Arguments]    ${ue_id}   ${pdu_id}    ${first_meas_id}    ${second_meas_id}
    ...    ${nrsrp_nr}=100    ${nrsrq_nr}=100    ${timeout}=15
    BuiltIn.Sleep    1
    Trigger Double A4 Measurements    ue_id=${ue_id}    first_meas_id=${first_meas_id}    second_meas_id=${second_meas_id}
    ...    nrsrp_nr=${nrsrp_nr}    nrsrq_nr=${nrsrq_nr}    timeout=${timeout}
    Start High DL non-GBR Data Traffic    ue_id=${ue_id}   pdu_id=${pdu_id}

Set Message Flow Expectations for Robusstness UE Buffer Trigger And SCell Addition
    [Arguments]    ${ue_id}    ${gnb_id}
    Set 3 expected PrivateMessages for Robusstness UE gNB2 and 15 s timeout
    Set 2 expected RRC Reconfiguration Request and Complete messages for Robusstness UE${ue_id} and 7 s timeout

Check Message Flow Expectations for Robusstness UE Buffer Trigger And SCell Addition
    [Arguments]    ${ue_id}
    Verify that all 3 expected PrivateMessages occured for Robusstness UE gNB2 and 15 s timeout
    Verify that all 2 RRC Reconfiguration Request and Complete messages occured for Robusstness UE${ue_id} and 7 s timeout

Set ${private:\d+} expected PrivateMessages for Robusstness UE gNB${gnb_id:\d+} and ${time_out:\d+} s timeout
    EXPECT FLOW[timeout=${time_out}]: gNB${gnb_id} F1AP ${private}*privateMessage

Verify that all ${private:\d+} expected PrivateMessages occured for Robusstness UE gNB${gnb_id:\d+} and ${time_out:\d+} s timeout
    PASS FLOW[timeout=${time_out}]: gNB${gnb_id} F1AP ${private}*privateMessage

Verify if Robusstness UE${ue_id:\d+} RRCReconfiguration ${rrc_msg:\d+} of ${all:\d+} contains A4 deconfiguration
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${Meas_Config_With_A4_Measurements_Deconfiguration_In_RRC_Reconf_A_B11}
    ...  message_alias=RRCReconfiguration_${rrc_msg}
    ...  flow_alias=${flow_alias}

Verify if Robusstness UE${ue_id:\d+} RRCReconfiguration ${rrc_msg:\d+} of ${all:\d+} contains sCellToAddModList and A2 configuration
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${Meas_Config_With_A2_SCell_Release_Meas_Configuration_A_B11}
    ...  message_alias=RRCReconfiguration_${rrc_msg}
    ...  flow_alias=${flow_alias}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_sCellToAddModList_A_B11}
    ...  message_alias=RRCReconfiguration_${rrc_msg}
    ...  flow_alias=${flow_alias}

Set ${all:\d+} expected UE Context Modification messages for A4 deconfiguration for robusstness UE${ue_id:\d+} and gNB${gnb_id:\d+}
    EXPECT FLOW[timeout=7]: gNB${gnb_id} F1AP ${all}*uEContextModification

Verify ${all:\d+} UE Context Modification messages for A4 deconfiguration for robusstness UE${ue_id:\d+} and gNB${gnb_id:\d+} occured
    PASS FLOW[timeout=7]: gNB${gnb_id} F1AP ${all}*uEContextModification

Verify is all UEs are still in active state
    Execute Egate Command    cmd=ue_disp id=1-${number_of_simulated_ues},${UE_ID}
    BuiltIn.Sleep    2
    Verify Egate Content
    ...    expected_pattern=${UE_ID}\\s*INT\\s*ACTIVE
    ...    occurrence=1
    FOR    ${ue}    IN RANGE    1    ${number_of_simulated_ues}    1
        Verify Egate Content
        ...    expected_pattern=${ue}\\s*INT\\s*ACTIVE
        ...    occurrence=1
    END

Stop High Data Traffic and Launch Medium DL non-GBR Data Traffic
    [Arguments]    ${ue_id}   ${pdu_id}    ${qfi_id}=1
    Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=4 dir=dl mbps=10

Wait For SupervisionTimer And RetryTimer period and Verify If all Ues are still in active state
    [Arguments]    ${ue_id}
    ${timeout_sum} =    Evaluate    ${a4_retry_timer}+${supervision_timer_fr1}+1
    ${timeout_sum_string} =    Convert To String    ${timeout_sum}
    EXPECT FLOW[timeout=${timeout_sum_string}]: UE${ue_id} NR-RRC 1*RRCReconfiguration
    FAIL FLOW[timeout=${timeout_sum_string}]: UE${ue_id} NR-RRC 1*RRCReconfiguration
    Verify is all UEs are still in active state

Verify if Robusstness UE${ue_id:\d+} RRCReconfiguration ${rrc_msg:\d+} of ${all:\d+} contains second A4 configuration
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${Meas_Config_With_A4_Measurements_2nd_Configuration_In_RRC_Reconf_A_B11}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=${flow_alias}

#CB006733_B_B6
Perform Ue Reestablishment And Verify RRC Reestablishment Request And A4 Measurements Are Not Activated
    [Arguments]    ${ue_id}    ${gnb_id}    ${source_phy_cell_id}    ${target_cell_id}
    ...    ${cause}=otherFailure    ${reest_cause}="otherFailure"    ${timeout}=60
    EXPECT FLOW[timeout=3]: UE${ue_id} NR-RRC RRCReestablishmentRequest
    EXPECT FLOW[timeout=3]: UE${ue_id} NR-RRC RRCReestablishmentComplete
    EXPECT FLOW[timeout=3]: UE${ue_id} NR-RRC RRCReconfiguration
    Perform Ue Reestablishment    ue_id=${ue_id}    gnb_id=${gnb_id}    target_cell_id=${target_cell_id}    cause=${cause}
    PASS FLOW[timeout=3]: UE${ue_id} NR-RRC RRCReestablishmentRequest
    PASS FLOW[timeout=3]: UE${ue_id} NR-RRC RRCReestablishmentComplete
    PASS FLOW[timeout=3]: UE${ue_id} NR-RRC RRCReconfiguration

    Verify RRC Reestablishment Request Message Content
    ...    ue_id=${ue_id}    source_phy_cell_id=${source_phy_cell_id}    reest_cause=${reest_cause}
    Verify That A4 Measurements Are Not Activated    ue_id=${ue_id}

Perform Ue Reestablishment
    [Arguments]    ${ue_id}    ${gnb_id}    ${target_cell_id}    ${cause}
    Execute Egate Command    cmd=ue_rrc_reestablish id\=${ue_id} gnb\=${gnb_id} cell\=${target_cell_id} cause\=${cause}

Verify RRC Reestablishment Request Message Content
    [Arguments]    ${ue_id}    ${source_phy_cell_id}    ${reest_cause}
    ${rrc_reest_req}=    Get Flow Name
    ...     RRCReestablishmentRequest
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     (physCellId eq ${source_phy_cell_id}) and (reestablishmentCause eq ${reest_cause})
    ...     message_alias=RRCReestablishmentRequest
    ...     flow_alias=${rrc_reest_req}

Verify That A4 Measurements Are Not Activated
    [Arguments]    ${ue_id}
    ${rrc_reconf_after_reest}=    Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     (reportConfigToAddModList is not present) and (measIdToAddModList is not present) and (measGapConfig is not present)
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=${rrc_reconf_after_reest}

Wait For A4 Retry Timer Expiration And Verify A4 Measurements Activation
    [Arguments]    ${a4_retry_timer}    ${ue_id}    ${gnb_id}
    ${wait_time} =    Convert To String    ${a4_retry_timer}

    EXPECT FLOW[timeout=${wait_time}]: UE${ue_id} NR-RRC RRCReconfiguration
    Wait For A4 Retry Timer Expiration    a4_retry_timer=${a4_retry_timer}
    PASS FLOW[timeout=${wait_time}]: UE${ue_id} NR-RRC RRCReconfiguration

    Verify That A4 Measurements Are Activated With Proper Content    ue_id=${ue_id}

Wait For A4 Retry Timer Expiration
    [Arguments]    ${a4_retry_timer}
    Log to console    \nWaiting ${a4_retry_timer} seconds for retry timers expiration
    BuiltIn.Sleep    ${a4_retry_timer}

Verify That A4 Measurements Are Activated With Proper Content
    [Arguments]    ${ue_id}
    ${rrc_reconf_after_a4_retry_timer}=    Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...    (measObjectToAddModList is present) and (length(measObjectToAddModList) eq 5) and
    ...    (reportConfigToAddModList is present) and (length(reportConfigToAddModList) eq 2) and (eventId contains (eventA4 is present)) and
    ...    (measIdToAddModList is present) and (length(measIdToAddModList) eq 6) and
    ...    (measGapConfig is present) and (gapUE contains (setup is present))
    ...    message_alias=RRCReconfiguration
    ...    flow_alias=${rrc_reconf_after_a4_retry_timer}

Verify Pm Counter For Number Of A4 Measurements Activations
    [Arguments]    ${local_moid}
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55118C00030    >0    A4_MEASUR_ACT_SCELL_ADD_SA
    ...    local_moid=${local_moid}
    ...    file_path=${pm_counter_file}

Verify Rd Counter For Number Of A4 Measurements Activations
    [Arguments]    ${local_moid}
    ${rd_counter_file}=    Get Next Unpacked Raw Rd Counters File
    Verify Any Counters In File
    ...    A4_MEASUR_ACT_SCELL_ADD_SA    >0    A4_MEASUR_ACT_SCELL_ADD_SA
    ...    local_moid=${local_moid}
    ...    file_path=${rd_counter_file}

Attach UE And Verify Establishing PDU Session With A4 Configuration B_B12
    [Arguments]    ${ue_id}    ${cell_id}    ${gnb_id}    ${pdu_id}    ${gw_id}
    Create SA Aliases    ue_id=${ue_id}    gNB_id=${gnb_id}
    Set Message Flow Expectations for UE Attach and A2 Measurement Trigger B_B12  ue_id=${ue_id}    gnb_id=${gnb_id}
    Expect UE Attach Messages Flow     ue_id=${ue_id}    gNB_id=${gnb_id}
    Expect PDU Messages Flow     ue_id=${ue_id}    gNB_id=${gnb_id}
    Expect Configuration Of A4 Measurements For SCell Addition Messages Flow    ue_id=${UE_ID}
    Attach UE And Establish PDU Session    ue_id=${ue_id}    cell_id=${cell_id}    enb_id=${gnb_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Check If UE Attach Messages Flow Occurred     ue_id=${ue_id}
    Check If PDU Messages Flow Occurred     ue_id=${ue_id}
    Check If Configuration Of A4 Measurements For SCell Addition Messages Flow Occured    ue_id=${UE_ID}

Set Message Flow Expectations for UE Attach and A2 Measurement Trigger B_B12
    [Arguments]    ${ue_id}    ${gnb_id}
    Set 3 expected UE Context Modification messages for A2 A4 handling for UE4 and gNB2
    Set 2 expected RRC Reconfiguration Request and Complete messages for UE4

Check Message Flow Expectations for A4 Measurement Trigger and Starting Data Traffic
    [Arguments]    ${ue_id}
    Verify 4 UE Context Modification messages for SCell addition for UE4 and gNB2 occured
    Verify that all 4 RRC Reconfiguration Request and Complete messages after A4 Measurement Report occured for UE4
    Verify that all 2 Measurement Report messages occured for UE4

Verify if UE${ue_id:\d+} RRCReconfiguration ${rrc_msg:\d+} of ${all:\d+} contains A4 configuration B_B12
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_B_B12}
    ...  message_alias=RRCReconfiguration_${rrc_msg}
    ...  flow_alias=${flow_alias}


Trigger A4 Measurement And Start High Data Traffic B_B12
    [Arguments]    ${ue_id}   ${gnb_id}    ${pdu_id}    ${meas_id_rsrq}    ${meas_id_rsrpandrsrq}    ${phycell_id_cell2}    ${phycell_id_cell3}
    Set Message Flow Expectations for A4 Measurement Trigger and Starting Data Traffic B_B12   ue_id=${ue_id}    gnb_id=${gnb_id}
    Expect SCell Addition Messages Flow B_B12   ue_id=${ue_id}    gnb_id=${gnb_id}
    Trigger A4 Measurement For RSRQ And RSRPANDRSRQ B_B12   ue_id=${ue_id}     meas_id_rsrq=${meas_id_rsrq}
    ...    meas_id_rsrpandrsrq=${meas_id_rsrpandrsrq}
    ...    phycell_id_cell2=${phycell_id_cell2}    phycell_id_cell3=${phycell_id_cell3}
    Start High DL non-GBR Data Traffic B_B12   ue_id=${ue_id}   pdu_id=${pdu_id}
    Check Message Flow Expectations for A4 Measurement Trigger and Starting Data Traffic B_B12    ue_id=${ue_id}
    Verify That Throughput Is Reached On All SCells    ue_id=${ue_id}    num_of_scells=0    expected_throughput=10Mbps

Set Message Flow Expectations for A4 Measurement Trigger and Starting Data Traffic B_B12
    [Arguments]    ${ue_id}    ${gnb_id}
    Set 4 expected UE Context Modification messages for SCell addition for UE4 and gNB2
    Set 3 expected PrivateMessages UE gNB2 and 15 s timeout
    Set 2 expected RRC Reconfiguration Request and Complete messages after A4 Measurement Report for UE4
    Set 2 expected Measurement Report messages timeout 9s for UE4

Trigger A4 Measurement For RSRQ And RSRPANDRSRQ B_B12
    [Arguments]    ${ue_id}    ${meas_id_rsrq}    ${meas_id_rsrpandrsrq}    ${phycell_id_cell2}     ${phycell_id_cell3}    ${timeout}=60
    Execute Egate Command    cmd=ue_meas_cfg_disp id\=${ue_id}
    Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=${ue_id} meas_id\=${meas_id_rsrq} event\=A4 phycell_id\=${phycell_id_cell2} nrsrq_nr\=95
    Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=${ue_id} meas_id\=${meas_id_rsrpandrsrq} event\=A4 phycell_id\=${phycell_id_cell3} nrsrp_nr\=95 nrsrq_nr\=95


Start High DL non-GBR Data Traffic B_B12
    [Arguments]    ${ue_id}   ${pdu_id}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=1 dir=dl mbps=175
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=2 dir=dl mbps=175
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=3 dir=dl mbps=175
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=4 dir=dl mbps=175
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=5 dir=dl mbps=175
    BuiltIn.Sleep    2

Check Message Flow Expectations for A4 Measurement Trigger and Starting Data Traffic B_B12
    [Arguments]    ${ue_id}
    Verify 4 UE Context Modification messages for SCell addition for UE4 and gNB2 occured
    Verify that all 3 expected PrivateMessages occured UE gNB2 and 15 s timeout
    Verify that all 2 RRC Reconfiguration Request and Complete messages after A4 Measurement Report occured for UE4
    Verify that all 2 Measurement Report messages occured for UE4

Set ${private:\d+} expected PrivateMessages UE gNB${gnb_id:\d+} and ${time_out:\d+} s timeout
    EXPECT FLOW[timeout=${time_out}]: gNB${gnb_id} F1AP ${private}*privateMessage

Verify that all ${private:\d+} expected PrivateMessages occured UE gNB${gnb_id:\d+} and ${time_out:\d+} s timeout
    PASS FLOW[timeout=${time_out}]: gNB${gnb_id} F1AP ${private}*privateMessage

Verify if UE${ue_id:\d+} Measurement Report ${meas_rep_msg:\d+} of ${all:\d+} is expected A4 measurement for Cell2 B_B12
    ${flow_alias}=     Get Flow Name
    ...     ${all}*MeasurementReport
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${A4_measurementReport_RSRQ_B_B12}
    ...  message_alias=MeasurementReport_${meas_rep_msg}
    ...  flow_alias=${flow_alias}

Verify if UE${ue_id:\d+} Measurement Report ${meas_rep_msg:\d+} of ${all:\d+} is expected A4 measurement for Cell3 B_B12
    ${flow_alias}=     Get Flow Name
    ...     ${all}*MeasurementReport
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${A4_measurementReport_RSRPANDRSRQ_B_B12}
    ...  message_alias=MeasurementReport_${meas_rep_msg}
    ...  flow_alias=${flow_alias}

Verify if UE${ue_id:\d+} RRCReconfiguration ${rrc_msg:\d+} of ${all:\d+} contains A4 measurements deconfiguration and measGap release B_B12
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${Meas_Config_With_A4_Measurements_Deconfiguration_In_RRC_Reconf_B_B12}
    ...  message_alias=RRCReconfiguration_${rrc_msg}
    ...  flow_alias=${flow_alias}

Expect SCell Addition Messages Flow B_B12
    [Arguments]    ${ue_id}    ${gnb_id}
    Expect Message Flow
    ...    gNB${gnb_id}:F1AP_UEContextModificationRequest (SCell-ToBeSetupMod-List is present) as UEContModRequest
    ...    gNB${gnb_id}:F1AP_UEContextModificationResponse (sCellToAddModList is present) as UEContModResponse
    ...    alias=SCellAddition_UE${ue_id}   overall_timeout=60

Verify SCell Addition Messages BB12
    [Arguments]    ${ue_id}
        Verify That Message Fulfills Query
        ...  ${selected_SCells_for_3CC_CA_in_UE_CON_MOD_REQ}
        ...  message_alias=UEContModRequest
        ...  flow_alias=SCellAddition_UE${ue_id}
        Verify That Message Fulfills Query
        ...  ${CSI_meas_config_for_3CC_CA_in_UE_CON_MOD_RESP}
        ...  message_alias=UEContModResponse
        ...  flow_alias=SCellAddition_UE${ue_id}
        Verify That Message Fulfills Query
        ...  ${selected_SCells_for_3CC_UE_CA_in_UE_CON_MOD_RESP}
        ...  message_alias=UEContModResponse
        ...  flow_alias=SCellAddition_UE${ue_id}

Verify if UE${ue_id:\d+} RRCReconfiguration ${rrc_msg:\d+} of ${all:\d+} contains A2 measurements configuration before PCell Change
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${Meas_Config_With_A2_Measurements_Configuration_In_RRC_Reconf_B_B12}
    ...  message_alias=RRCReconfiguration_${rrc_msg}
    ...  flow_alias=${flow_alias}

Trigger A2 Measurement For PCell Change
    [Arguments]    ${ue_id}   ${gnb_id}   ${A2_cmd}    ${meas_id_A2}
    Set Message Flow Expectations for A2 Measurement Trigger B_B12   ue_id=${ue_id}    gnb_id=${gnb_id}
    Trigger A2 Based PCell Change B_B12   ue_id=${UE_ID}    A2_cmd=${A2_cmd}    meas_id_A2=${meas_id_A2}    gnb_id=${gnb_id}
    Check Message Flow Expectations for A2 Measurement Trigger B_B12    ue_id=${ue_id}

Set Message Flow Expectations for A2 Measurement Trigger B_B12
    [Arguments]    ${ue_id}    ${gnb_id}
    Set 2 expected UE Context Modification messages for PCell Change for UE4 and gNB2
    Set 1 expected RRC Reconfiguration Request and Complete messages after A2 Measurement Report for UE4
    Set 1 expected Measurement Report messages timeout 9s for UE4

Set ${all:\d+} expected UE Context Modification messages for PCell Change for UE${ue_id:\d+} and gNB${gnb_id:\d+}
    EXPECT FLOW[timeout=90]: gNB${gnb_id} F1AP ${all}*uEContextModification


Set ${rrc_comp:\d+} expected RRC Reconfiguration Request and Complete messages after A2 Measurement Report for UE${ue_id:\d+}
    EXPECT FLOW[timeout=60]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfiguration
    EXPECT FLOW[timeout=60]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfigurationComplete


Trigger A2 Based PCell Change B_B12
    [Arguments]    ${ue_id}    ${gnb_id}    ${A2_cmd}    ${meas_id_A2}
    Expect PCell Change Messages Flow    ${ue_id}    ${meas_id_A2}    ${gnb_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_meas_cfg_disp id=${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr ${A2_cmd}
    Check if PCell Change messages flow occured    ${ue_id}

Expect PCell Change messages flow
    [Arguments]    ${ue_id}    ${meas_id_A2}    ${gnb_id}=2    ${overall_timeout}=60
    Expect message flow
    ...    UE${ue_id}:NR-RRC_MeasurementReport (measId eq ${meas_id_A2}) as A2measurementReport
    ...    gNB${gnb_id}:F1AP_UEContextModificationRequest (SCell-ToBeRemoved-List is present) as UEContextModificationRequest
    ...    gNB${gnb_id}:F1AP_UEContextModificationResponse (sCellToReleaseList is present) as UEContextModificationResponse
    ...    UE${UE_ID}:NR-RRC_RRCReconfiguration (sCellToReleaseList is present) as RRCReconfiguration
    ...    UE${UE_ID}:NR-RRC_RRCReconfigurationComplete as RRCReconfigurationComplete
    ...    gNB${gnb_id}:F1AP_UEContextModificationRequest as UEContextModificationRequest_2nd
    ...    gNB${gnb_id}:F1AP_UEContextModificationResponse as UEContextModificationResponse_2nd
    ...    alias=PCellChange_UE${ue_id}
    ...    overall_timeout=${overall_timeout}

Check if PCell Change messages flow occured
    [Arguments]     ${ue_id}
    Flow occurred as expected  alias=PCellChange_UE${ue_id}

Check Message Flow Expectations for A2 Measurement Trigger B_B12
    [Arguments]    ${ue_id}
    Verify 2 UE Context Modification messages for PCell Change for UE4 and gNB2 occured
    Verify that all 1 RRC Reconfiguration Request and Complete messages after A2 Measurement Report occured for UE4
    Verify that all 1 Measurement Report messages occured for UE4

Verify ${all:\d+} UE Context Modification messages for PCell Change for UE${ue_id:\d+} and gNB${gnb_id:\d+} occured
    PASS FLOW[timeout=90]: gNB${gnb_id} F1AP ${all}*uEContextModification

Verify that all ${rrc_comp:\d+} RRC Reconfiguration Request and Complete messages after A2 Measurement Report occured for UE${ue_id:\d+}
    PASS FLOW[timeout=60]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfiguration
    PASS FLOW[timeout=60]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfigurationComplete

Verify if UE${ue_id:\d+} Measurement Report is expected A2 measurement for PCell Change
    ${flow_alias}=     Get Flow Name
    ...     MeasurementReport
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${A2_measurementReport_PCell_Change}
    ...  message_alias=MeasurementReport
    ...  flow_alias=${flow_alias}

Verify Successful PCell Change And SCells Release
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${HO_PREP_in_UE_CON_MOD_REQ}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=PCellChange_UE${ue_id}
	Verify That Message Fulfills Query
    ...  ${SCell_ToBeRemoved_List_in_UE_CON_MOD_REQ}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=PCellChange_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${spCellConfig_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=PCellChange_UE${ue_id}

Verify if UE${ue_id:\d+} RRCReconfiguration contains A4 and A2 measurements deconfiguration
    ${flow_alias}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${Meas_Config_With_A4_and_A2_Measurements_Deconfiguration_In_RRC_Reconf_B_B12}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=${flow_alias}

Set ${private:\d+} expected PrivateMessages for A4 Measurement Trigger for UE${ue_id:\d+} and gNB${gnb_id:\d+}
    EXPECT FLOW[timeout=60]: gNB${gnb_id} F1AP ${private}*privateMessage

Verify SCell Addition Messages AB12
    [Arguments]    ${ue_id}
        Verify That Message Fulfills Query
        ...  ${selected_SCells_for_3CC_CA_in_UE_CON_MOD_REQ}
        ...  message_alias=UEContModRequest
        ...  flow_alias=SCellAddition_UE${ue_id}
        Verify That Message Fulfills Query
        ...  ${selected_SCells_for_3CC_UE_CA_in_UE_CON_MOD_RESP}
        ...  message_alias=UEContModResponse
        ...  flow_alias=SCellAddition_UE${ue_id}

Expect SCell Release messages flow
    [Arguments]    ${ue_id}    ${gnb_id}=2
    Expect SCell Release messages flow A_B12 Cell 2
    Expect SCell Release messages flow A_B12 Cell 3

Expect SCell Release messages flow A_B12 Cell 2
    [Arguments]    ${ue_id}    ${gnb_id}=2    ${overall_timeout}=60
    Expect message flow
    ...    UE${ue_id}:NR-RRC_MeasurementReport (measId eq ${meas_id_A2_cell2}) as A2measurementReport
    ...    gNB${gnb_id}:F1AP_UEContextModificationRequest (SCell-ToBeRemoved-List is present) as UEContextModificationRequest
    ...    gNB${gnb_id}:F1AP_UEContextModificationResponse (sCellToReleaseList is present) as UEContextModificationResponse
    ...    UE${UE_ID}:NR-RRC_RRCReconfiguration (sCellToReleaseList is present) as RRCReconfiguration
    ...    UE${UE_ID}:NR-RRC_RRCReconfigurationComplete as RRCReconfigurationComplete
    ...    alias=SCellRelease1_UE${ue_id}
    ...    overall_timeout=${overall_timeout}

Expect SCell Release messages flow A_B12 Cell 3
    [Arguments]    ${ue_id}    ${gnb_id}=2    ${overall_timeout}=60
    Expect message flow
    ...    UE${ue_id}:NR-RRC_MeasurementReport (measId eq ${meas_id_A2_cell3}) as A2measurementReport
    ...    gNB${gnb_id}:F1AP_UEContextModificationRequest as UEContextModificationRequest_1st
    ...    gNB${gnb_id}:F1AP_UEContextModificationResponse as UEContextModificationResponse_1st
    ...    gNB${gnb_id}:F1AP_UEContextModificationRequest as UEContextModificationRequest_2nd
    ...    gNB${gnb_id}:F1AP_UEContextModificationResponse (sCellToAddModList is present) as UEContextModificationResponse_2nd
    ...    gNB${gnb_id}:F1AP_UEContextModificationRequest (SCell-ToBeRemoved-List is present) as UEContextModificationRequest_3rd
    ...    gNB${gnb_id}:F1AP_UEContextModificationResponse (sCellToReleaseList is present) as UEContextModificationResponse_3rd
    ...    UE${UE_ID}:NR-RRC_RRCReconfiguration (sCellToReleaseList is present) as RRCReconfiguration
    ...    UE${UE_ID}:NR-RRC_RRCReconfigurationComplete as RRCReconfigurationCompletend
    ...    alias=SCellRelease2_UE${ue_id}
    ...    overall_timeout=${overall_timeout}

Verify Successful Cell2 Release
    [Arguments]    ${ue_id}
	Verify That Message Fulfills Query
    ...  ${SCell_ToBeRemoved_List_in_UE_CON_MOD_REQ_Cell2_A_B12}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=SCellRelease1_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${spCellConfig_in_UE_CON_MOD_RESP_Cell2_A_B12}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellRelease1_UE${ue_id}

Verify Successful Cell3 Release
    [Arguments]    ${ue_id}
	Verify That Message Fulfills Query
    ...  ${SCell_ToBeRemoved_List_in_UE_CON_MOD_REQ_Cell3_A_B12}
    ...  message_alias=UEContextModificationRequest_3rd
    ...  flow_alias=SCellRelease2_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${spCellConfig_in_UE_CON_MOD_RESP_Cell3_A_B12}
    ...  message_alias=UEContextModificationResponse_3rd
    ...  flow_alias=SCellRelease2_UE${ue_id}

Set Traffic Type To UE
    [Arguments]     ${gnb_id}    ${pdu_id}    ${ue_id}
    Execute Egate Command    cmd=gnb_param id=${gnb_id} sib1_period=40
    Execute Egate Command    cmd=gnb_param id=${gnb_id} sib2_period=40
    Execute Egate Command    cmd=gnb_param id=${gnb_id} sib5_period=40
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal

Change UE Location to simulated Gnb
    [Arguments]    ${ue_id}    ${cell_id}    ${gnb_id}
    Execute Egate Command   cmd=ue_change_location id=${ue_id} enb=${gnb_id} cell=${cell_id}
    BuiltIn.Sleep    2s

Trigger NGAP Handover
    [Arguments]    ${ue_id}    ${phycell_id}    ${meas_id}     ${nrsrp_nr}     ${srsrp_nr}    ${gnb_id}
    Set Message Flow Expectations for A4 Measurement Configuration after NG HO    ue_id=${ue_id}    gnb_id=${gnb_id}
    Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=${srsrp_nr} phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr}
    Check Message Flow Expectations for A4 Measurement Configuration after NG HO    ue_id=${ue_id}

Set ${all:\d+} expected UE Context Modification messages for A4 handling after NG HO for UE${ue_id:\d+} and gNB${gnb_id:\d+}
    EXPECT FLOW[timeout=30]: gNB${gnb_id} F1AP ${all}*uEContextModification

Verify ${all:\d+} UE Context Modification messages for A4 handling after NG HO for UE${ue_id:\d+} and gNB${gnb_id:\d+} occured
    PASS FLOW[timeout=30]: gNB${gnb_id} F1AP ${all}*uEContextModification

Set Message Flow Expectations for A4 Measurement Configuration after NG HO
    [Arguments]    ${ue_id}    ${gnb_id}
    Set 3 expected UE Context Modification messages for A4 handling after NG HO for UE4 and gNB2
    Set expected RRC Reconfiguration Request and Complete messages after Inter-gNB HO via NG link for UE4

Check Message Flow Expectations for A4 Measurement Configuration after NG HO
    [Arguments]    ${ue_id}
    Verify 3 UE Context Modification messages for A4 handling after NG HO for UE4 and gNB2 occured
    Verify that RRC Reconfiguration Request and Complete messages after Inter-gNB HO via NG link occured for UE4

Verify that RRC Reconfiguration Request and Complete messages after Inter-gNB HO via NG link occured for UE${ue_id:\d+}
    PASS FLOW[timeout=30]: UE${ue_id} NR-RRC RRCReconfiguration
    PASS FLOW[timeout=30]: UE${ue_id} NR-RRC RRCReconfigurationComplete

Set expected RRC Reconfiguration Request and Complete messages after Inter-gNB HO via NG link for UE${ue_id:\d+}
    EXPECT FLOW[timeout=30]: UE${ue_id} NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=30]: UE${ue_id} NR-RRC RRCReconfigurationComplete

Register UE To source gNB
    [Arguments]    ${ue_id}    ${target_gnb_id}   ${nwslice_id}   ${gw_id}   ${pdu_id}    ${timeout}=5
    Create SA Aliases    ue_id=${ue_id}    gNB_id=${target_gnb_id}
    Execute Egate Command    cmd=ue_register id=${ue_id}
    Wait For UE Register    3s
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${nwslice_id} gw=${gw_id}
    ...    timeout=${timeout}
    BuiltIn.Sleep    10s

Attach UE And Verify Establishing PDU Session With MFBI
    [Arguments]    ${ue_id}    ${cell_id}    ${capa_filter}    ${gnb_id}=2    ${pdu_id}=1    ${gw_id}=1
    Create SA Aliases    ue_id=${ue_id}    gNB_id=${gnb_id}
    Expect UE Attach Messages Flow     ue_id=${ue_id}    gNB_id=${gnb_id}
    Expect PDU Messages Flow     ue_id=${ue_id}    gNB_id=${gnb_id}

    Expect Message Flow
    ...    UE${ue_id}:NR-RRC_UECapabilityEnquiry (capabilityRequestFilter eq ${capa_filter}) as UECapabilityEnquiry
    ...    UE${ue_id}:NR-RRC_RRCReconfigurationComplete as RRCReconfigurationComplete
    ...    alias=NativeAndAlternativeBandsAndRRCReconfComplete${ue_id}    overall_timeout=60

    Expect Message Flow
    ...    UE${ue_id}:NR-RRC_RRCReconfiguration (eventId is not present) as RRCReconfiguration
    ...    alias=A4EventIsNoPresent${ue_id}    overall_timeout=60

    Attach UE And Establish PDU Session    ue_id=${ue_id}    cell_id=${cell_id}    enb_id=${gnb_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Check If UE Attach Messages Flow Occurred     ue_id=${ue_id}
    Check If PDU Messages Flow Occurred     ue_id=${ue_id}
    Flow Occurred As Expected   alias=NativeAndAlternativeBandsAndRRCReconfComplete${ue_id}
    Flow Occurred As Expected   alias=A4EventIsNoPresent${ue_id}

Trigger NGAP with reestablishment Handover
    [Arguments]    ${ue_id}    ${phycell_id}    ${meas_id}     ${nrsrp_nr}     ${srsrp_nr}    ${gnb_id}
    EXPECT FLOW[timeout=3]: UE${ue_id} NR-RRC RRCReestablishmentRequest
    EXPECT FLOW[timeout=3]: UE${ue_id} NR-RRC RRCReestablishmentComplete
    Set Message Flow Expectations for A4 Measurement Configuration after NG HO with reestablishment   ue_id=${ue_id}    gnb_id=${gnb_id}
    Execute Egate Command
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=${srsrp_nr} phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr}
    Check Message Flow Expectations for A4 Measurement Configuration after NG HO with reestablishment   ue_id=${ue_id}
    PASS FLOW[timeout=3]: UE${ue_id} NR-RRC RRCReestablishmentRequest
    PASS FLOW[timeout=3]: UE${ue_id} NR-RRC RRCReestablishmentComplete

Set Message Flow Expectations for A4 Measurement Configuration after NG HO with reestablishment
    [Arguments]    ${ue_id}    ${gnb_id}
    Set 6 expected UE Context Modification messages for A4 handling after NG HO for UE4 and gNB2
    Set 2 expected RRC Reconfiguration Request and Complete messages during and after HO for UE4

Check Message Flow Expectations for A4 Measurement Configuration after NG HO with reestablishment
    [Arguments]    ${ue_id}
    Verify 6 UE Context Modification messages for A4 handling after NG HO for UE4 and gNB2 occured
    Verify that all 2 RRC Reconfiguration Request and Complete messages occured during and after HO for UE4

Send sibs to simulted Gnb and set internal traffic
    [Arguments]     ${gnb_id}    ${pdu_id}    ${ue_id}
    Execute Egate Command    cmd=gnb_param id=${gnb_id} sib1_period=40
    Execute Egate Command    cmd=gnb_param id=${gnb_id} sib2_period=40
    Execute Egate Command    cmd=gnb_param id=${gnb_id} sib5_period=40
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal

Verify bearer context modification response messages in Tcpdump Log
    [Arguments]    ${packet_filter}    ${number_of_messages}=4    ${pcap_file_path}=default    ${timeout}=16    ${relation_symbol}= ==
    ...            ${alias}=${DEFAULT_TCPDUMP_ALIAS}    ${continue_on_failure}=${True}
    Verify Tshark
    ...    alias=${alias}
    ...    packet_filter=${packet_filter}
    ...    pass_criteria=${relation_symbol}${number_of_messages}
    ...    pcap_file_path=${pcap_file_path}
    ...    timeout=${timeout}
    ...    continue_on_failure=${continue_on_failure}

Set ciphering and integrity protection algorithm
    [Arguments]    ${source_gnb_id}
    Execute Egate Command
    ...    cmd=gnb_param id=${source_gnb_id} ciphering_algorithm=nea0 integrityprotection_algorithm=nia2

Prepare Ue for Ng inter-Gnb HO with reestablishment
    [Arguments]    ${params1}      ${params2}
    Execute Egate Command    cmd=ue_nr_rrc_reconf_param ${params1}
    Execute Egate Command    cmd=ue_gnb_ho_param ${params2}


Set ${rrc_comp:\d+} expected RRC Reconfiguration Request and Complete messages during and after HO for UE${ue_id:\d+}
    EXPECT FLOW[timeout=30]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfiguration
    EXPECT FLOW[timeout=30]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfigurationComplete

Verify that all ${rrc_comp:\d+} RRC Reconfiguration Request and Complete messages occured during and after HO for UE${ue_id:\d+}
    PASS FLOW[timeout=30]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfiguration
    PASS FLOW[timeout=30]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfigurationComplete

Verify if UE${ue_id:\d+} RRCReconfiguration ${rrc_msg:\d+} of ${all:\d+} contains A4 configuration after Inter-gNB with reestablishment HO via Ng
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_B_B10}
    ...  message_alias=RRCReconfiguration_${rrc_msg}
    ...  flow_alias=${flow_alias}

Verify if UE${ue_id:\d+} RRCReconfiguration ${rrc_msg:\d+} of ${all:\d+} contains A2,3,5 without A4 events during reestablishment HO via Ng
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  (${Meas_Config_With_A2_A3_A5_Measurements_Configuration_In_RRC_Reconf_B_B10}) and (measGapConfig is not present)
    ...  message_alias=RRCReconfiguration_${rrc_msg}
    ...  flow_alias=${flow_alias}

Verify if UE${ue_id:\d+} RRCReconfiguration contains A4 configuration after Inter-gNB HO via Ng
    ${flow_alias}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_B_B3}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=${flow_alias}

Perform RRC Reestablishment to the same serving cell
    [Arguments]    ${ue_id}    ${gnb_id}    ${source_phy_cell_id}    ${target_cell_id}    ${reest_cause}="otherFailure"    ${cause}=otherFailure
    Expect RRC Reestablishment Message Flow    ue_id=${ue_id}
    Set Message Flow Expectations To Verify A2 Measurement Reactivation and A4 Measurements Are not Activated    ue_id=${ue_id}    gnb_id=${gnb_id}
    Perform Ue Reestablishment    ue_id=${ue_id}    gnb_id=${gnb_id}    target_cell_id=${target_cell_id}    cause=${cause}
    Check If RRC Reestablishment Flow Occured    ue_id=${ue_id}

    Verify RRC Reestablishment Request Message Content
    ...    ue_id=${ue_id}    source_phy_cell_id=${source_phy_cell_id}    reest_cause=${reest_cause}
    Check Message Flow Expectations To Verify A2 Measurement Reactivation and A4 Measurements Are not Activated    ue_id=${ue_id}

Expect RRC Reestablishment Message Flow
    [Arguments]    ${ue_id}
    EXPECT FLOW[timeout=3]: UE${ue_id} NR-RRC RRCReestablishmentRequest
    EXPECT FLOW[timeout=3]: UE${ue_id} NR-RRC RRCReestablishment
    EXPECT FLOW[timeout=3]: UE${ue_id} NR-RRC RRCReestablishmentComplete

Check If RRC Reestablishment Flow Occured
    [Arguments]    ${ue_id}
    PASS FLOW[timeout=3]: UE${ue_id} NR-RRC RRCReestablishmentRequest
    PASS FLOW[timeout=3]: UE${ue_id} NR-RRC RRCReestablishment
    PASS FLOW[timeout=3]: UE${ue_id} NR-RRC RRCReestablishmentComplete

Check Message Flow Expectations To Verify A2 Measurement Reactivation and A4 Measurements Are not Activated
    [Arguments]    ${ue_id}
    Verify that all 2 RRC Reconfiguration Request and Complete messages occured for UE4 during and after RRC Reestablishment

Set Message Flow Expectations To Verify A2 Measurement Reactivation and A4 Measurements Are not Activated
    [Arguments]    ${ue_id}    ${gnb_id}
    Set 2 expected RRC Reconfiguration Request and Complete messages for UE4 during and after RRC Reestablishment

Set ${rrc_comp:\d+} expected RRC Reconfiguration Request and Complete messages for UE${ue_id:\d+} during and after RRC Reestablishment
    EXPECT FLOW[timeout=3]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfiguration
    EXPECT FLOW[timeout=3]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfigurationComplete

Verify that all ${rrc_comp:\d+} RRC Reconfiguration Request and Complete messages occured for UE${ue_id:\d+} during and after RRC Reestablishment
    PASS FLOW[timeout=3]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfiguration
    PASS FLOW[timeout=3]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfigurationComplete

Verify if UE${ue_id:\d+} RRCReconfiguration ${rrc_msg:\d+} of ${all:\d+} contains A2 Measurement Restored and A4 Measurements are not activated
    ${rrc_reconf_after_reest}=    Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     ${Meas_Config_With_A2_Measurement_Restored_Configuration_In_RRC_Reconf_B_B7}
    ...     message_alias=RRCReconfiguration_${rrc_msg}
    ...     flow_alias=${rrc_reconf_after_reest}

Verify if UE${ue_id:\d+} RRCReconfiguration ${rrc_msg:\d+} of ${all:\d+} contains Measurement Gap recovery and coverage based measurements recovered
    ${rrc_reconf_after_reest}=    Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     ${Meas_Config_With_A1_A3_A5_Measurements_Configuration_With_Meas_Gap_Recovery_In_RRC_Reconf_B_B7}
    ...     message_alias=RRCReconfiguration_${rrc_msg}
    ...     flow_alias=${rrc_reconf_after_reest}

Trigger A1 Measurement And Wait for A4 Measurement Reactivation After A4 Retry Timer Expiration
    [Arguments]    ${ue_id}   ${gnb_id}

    Set Message Flow Expectations for A1 Measurement Trigger and A4 Measurement Reactivation    ue_id=${ue_id}    gnb_id=${gnb_id}

    Trigger A1 Measurement    ue_id=${ue_id}     meas_id=30    srsrp_nr=90    timeout=60

    Check Message Flow Expectations for A1 Measurement Trigger and A4 Measurement Reactivation    ue_id=${ue_id}
    Verify That Throughput Is Reached On All SCells    ue_id=${ue_id}    num_of_scells=0    expected_throughput=0.1Mbps

Verify if UE${ue_id:\d+} Measurement Report is expected A1 measurement after RRC Reestablishment
    ${flow_alias}=     Get Flow Name
    ...     MeasurementReport
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${A1_measurementReport_B_B7}
    ...  message_alias=MeasurementReport
    ...  flow_alias=${flow_alias}

Verify if UE${ue_id:\d+} RRCReconfiguration ${rrc_msg:\d+} of ${all:\d+} contains A2 configuration and A1 A3 A5 deconfiguration after A1 trigger B_B7
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${Meas_Config_With_A2_Measurement_Configuration_and_A1_A3_A5_Measurements_Deconfiguration_In_RRC_Reconf_B_B7}
    ...  message_alias=RRCReconfiguration_${rrc_msg}
    ...  flow_alias=${flow_alias}

Verify if UE${ue_id:\d+} RRCReconfiguration ${rrc_msg:\d+} of ${all:\d+} contains 2nd A4 configuration B_B7
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${Meas_Config_With_A4_Measurements_2nd_Configuration_In_RRC_Reconf_B_B7}
    ...  message_alias=RRCReconfiguration_${rrc_msg}
    ...  flow_alias=${flow_alias}

Verify if UE${ue_id:\d+} Measurement Report is expected A1 measurement B_B7
    ${flow_alias}=     Get Flow Name
    ...     MeasurementReport
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${A1_measurementReport_B_B7}
    ...  message_alias=MeasurementReport
    ...  flow_alias=${flow_alias}

#CB006733_B_B9
Prepare and trigger XN handover with reestablishment request
    [Arguments]     ${ue_id}    ${PDU_ID}   ${SOURCE_GNB_ID}    ${TARGET_GNB_ID}    ${TARGET_CELL_ID}    ${msid}
    ...    ${mssr}    ${tpci}    ${msnr}    ${SOURCE_PHYSICAL_CELL_ID}    ${PCELL_ID}    ${UE_NR_RRC_RECONF_PARAM}

    Expect Inter-gNB XNAP Handover Message Flow    ue_id=${ue_id}
    EXPECT FLOW[timeout=3]: UE${ue_id} NR-RRC RRCReestablishmentRequest
    EXPECT FLOW[timeout=3]: UE${ue_id} NR-RRC RRCReestablishmentComplete
    Set 6 expected UE Context Modification messages for A4 handling after Xn HO for UE4 and gNB2
    Set 2 expected RRC Reconfiguration Request and Complete messages during and after Xn HO for UE4
    Prepare for XN handover with reestablishment request
    ...    ${SOURCE_GNB_ID}    ${UE_ID}     ${TARGET_GNB_ID}      ${TARGET_CELL_ID}    ${UE_NR_RRC_RECONF_PARAM}
    Execute Egate Command
    ...   cmd=ue_measurement_send_nr id=${ue_id} meas_id=${msid} event=A3 srsrp_nr=${mssr} phycell_id=${tpci} nrsrp_nr=${msnr}
    Verify that all 2 RRC Reconfiguration Request and Complete messages occured during and after Xn HO for UE4
    Verify 6 UE Context Modification messages for A4 handling after Xn HO for UE4 and gNB2 occured
    Check If Inter-gNB XNAP Handover Flow Occured    ue_id=${ue_id}
    PASS FLOW[timeout=3]: UE${ue_id} NR-RRC RRCReestablishmentRequest
    PASS FLOW[timeout=3]: UE${ue_id} NR-RRC RRCReestablishmentComplete

Prepare for XN handover with reestablishment request
    [Arguments]     ${sgnbid}      ${ue_id}       ${target_gnb_id}       ${target_cell_id}    ${UE_NR_RRC_RECONF_PARAM}

    Execute egate command
    ...     cmd=ue_history_information_list_add_ngran id=${ue_id} gnb_id=${sgnbid} cell_type=medium nrcgi=311:489|0x01 time_ue_stayed_in_cell=100
    Execute egate command   cmd=ue_history_information_list id=4 action=commit
    Execute egate command   cmd=ue_enb_param id=${ue_id} ue_history_list=4
    Execute Egate Command   cmd=gnb_xn_status_transfer_param id=${sgnbid} reset
    Execute Egate Command   cmd=gnb_xn_status_transfer_param id=${sgnbid} action=delayed_rsp time_to_wait=v1s
    Execute Egate Command   cmd=ue_nr_rrc_reconf_param ${UE_NR_RRC_RECONF_PARAM}
    Execute Egate Command
    ...    cmd=gnb_xn_handover_preparation_param id=${sgnbid} include_security_config=true sec_config_nea=nea0 sec_config_nia=nia2
    Execute Egate Command   cmd=gnb_xn_handover_preparation_param id=${sgnbid} reestab_info=4:valid
    Execute Egate Command   cmd=gnb_xn_handover_preparation_param id=${sgnbid}
    Execute Egate Command   cmd=gnb_xn_status_transfer_param id=${sgnbid}

Set ${rrc_comp:\d+} expected RRC Reconfiguration Request and Complete messages during and after Xn HO for UE${ue_id:\d+}
    EXPECT FLOW[timeout=30]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfiguration
    EXPECT FLOW[timeout=30]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfigurationComplete

Verify that all ${rrc_comp:\d+} RRC Reconfiguration Request and Complete messages occured during and after Xn HO for UE${ue_id:\d+}
    PASS FLOW[timeout=30]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfiguration
    PASS FLOW[timeout=30]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfigurationComplete

Set ${all:\d+} expected UE Context Modification messages for A4 handling after Xn HO for UE${ue_id:\d+} and gNB${gnb_id:\d+}
    EXPECT FLOW[timeout=30]: gNB${gnb_id} F1AP ${all}*uEContextModification

Verify ${all:\d+} UE Context Modification messages for A4 handling after Xn HO for UE${ue_id:\d+} and gNB${gnb_id:\d+} occured
    PASS FLOW[timeout=30]: gNB${gnb_id} F1AP ${all}*uEContextModification

Verify if UE${ue_id:\d+} RRCReconfiguration contains A4 configuration after Inter-gNB HO via XN with reestablishment
    ${flow_alias}=     Get Flow Name
    ...     RRCReconfiguration
    ...     device=UE${ue_id}
    ...     protocol=NR-RRCS
    Verify That Message Fulfills Query
    ...  ${Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_B_B10}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=${flow_alias}

Verify if UE${ue_id:\d+} RRCReconfiguration ${rrc_msg:\d+} of ${all:\d+} contains A2,3,5 without A4 events during reestablishment HO via Xn
    [Documentation]    message filters in BB9 scenario are similar to BB10
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  (${Meas_Config_With_A2_A3_A5_Measurements_Configuration_In_RRC_Reconf_B_B10}) and (measGapConfig is not present)
    ...  message_alias=RRCReconfiguration_${rrc_msg}
    ...  flow_alias=${flow_alias}

Verify if UE${ue_id:\d+} RRCReconfiguration ${rrc_msg:\d+} of ${all:\d+} contains A4 configuration after Inter-gNB with reestablishment HO via Xn
    [Documentation]    message filters in BB9 scenario are similar to BB10
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_B_B10}
    ...  message_alias=RRCReconfiguration_${rrc_msg}
    ...  flow_alias=${flow_alias}

Change UE location and set integrity protection
    [Arguments]    ${source_gnb_id}      ${ue_id}    ${cell_id}
    Execute Egate Command    cmd=ue_change_location id=${ue_id} enb=${source_gnb_id} cell=${cell_id}
    Execute Egate Command    cmd=gnb_param id=${source_gnb_id} ciphering_algorithm=nea0 integrityprotection_algorithm=nia2

#B_B22
Verify Measurement Gap Configuration
    [Arguments]    ${UeContextModResp}    ${number_of_messages}=0
    Verify Tcpdump Log    packet_filter=${UeContextModResp}    number_of_messages=${number_of_messages}    relation_symbol= >

Verify RRC Before A4RetryTimer Expiration
    [Arguments]    ${RRCReconfigurationBeforeRetryTimerExp}
    Verify Tcpdump Log    packet_filter=${RRCReconfigurationBeforeRetryTimerExp}    number_of_messages=0    relation_symbol= >

Verify RRC A4 Measurement Configuration
    [Arguments]    ${RRCReconfigurationAfterRetryTimerExp}
    Verify Tcpdump Log    packet_filter=${RRCReconfigurationAfterRetryTimerExp}

#B_B17
Trigger A1 RSRP Measurement
    [Arguments]    ${ue_id}    ${meas_id}    ${srsrp_nr}=90    ${timeout}=1
    Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=${ue_id} meas_id\=${meas_id} event\=A1 srsrp_nr\=${srsrp_nr}
    ...    timeout=${timeout}

Attach UE And Verify Establishing PDU Session With following A4 Measurement Trigger
    [Arguments]    ${ue_id}    ${cell_id}    ${gnb_id}    ${pdu_id}    ${gw_id}
    Create SA Aliases    ue_id=${ue_id}    gNB_id=${gnb_id}
    Set Message Flow Expectations for UE Attach and A4 Measurement Trigger    ue_id=${ue_id}    gnb_id=${gnb_id}

    ${UE_register_timestamp} =    Get Current Date
    Attach UE And Establish PDU Session    ue_id=${ue_id}    cell_id=${cell_id}    enb_id=${gnb_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Trigger A4 Measurement With Two Reported PCIs
    ...    ue_id=${ue_id}     meas_id=5    pci_1=51    pci_2=52    nrsrp_nr_1=95    nrsrp_nr_2=90

    Check Message Flow Expectations for UE Attach and A4 Measurement Trigger    ue_id=${ue_id}    gnb_id=${gnb_id}

    Verify if BB13 UE${ue_id} RRCReconfiguration 2 of 2 contains A4 configuration
    Verify if UE${ue_id} Measurement Report is expected A4 measurement with two measured PCIs
    Verify that PrivateMessage_1 of 1 is BufferMonitoringNotification for gNB${gnb_id}

    ${after_A4_meas_timestamp} =    Get Current Date
    Verify elepsed time for action    timestamp_A=${UE_register_timestamp}    timestamp_B=${after_A4_meas_timestamp}    message=triggering A4


Set Message Flow Expectations for UE Attach and A4 Measurement Trigger
    [Arguments]    ${ue_id}    ${gnb_id}
    Expect UE Attach Messages Flow     ue_id=${ue_id}    gNB_id=${gnb_id}
    Expect PDU Messages Flow     ue_id=${ue_id}    gNB_id=${gnb_id}
    Set 4 expected UE Context Modification messages for A4 handling for UE${ue_id} and gNB${gnb_id}
    Set 2 expected RRC Reconfiguration Request and Complete messages for UE${ue_id}
    Set 8 expected DLRRCMessageTransfer messages for gNB${gnb_id}
    Set 8 expected ULRRCMessageTransfer messages for gNB${gnb_id}
    Set expected Measurement Report messages for for UE${ue_id}
    Set 1 expected PrivateMessages UE gNB${gnb_id} and 15 s timeout

Check Message Flow Expectations for UE Attach and A4 Measurement Trigger
    [Arguments]    ${ue_id}    ${gnb_id}
    Check If UE Attach Messages Flow Occurred     ue_id=${ue_id}
    Check If PDU Messages Flow Occurred     ue_id=${ue_id}
    Verify 4 UE Context Modification messages for A4 handling for UE${ue_id} and gNB${gnb_id} occured
    Verify that all 2 RRC Reconfiguration Request and Complete messages occured for UE${ue_id}
    Verify that all 8 DLRRCMessageTransfer messages occured for gNB${gnb_id}
    Verify that all 8 ULRRCMessageTransfer messages occured for gNB${gnb_id}
    Verify that Measurement Report messages occured for UE${ue_id}
    Verify that all 1 expected PrivateMessages occured UE gNB${gnb_id} and 15 s timeout

Trigger A4 Measurement With Two Reported PCIs
    [Arguments]    ${ue_id}    ${meas_id}    ${pci_1}    ${pci_2}    ${nrsrp_nr_1}=90    ${nrsrp_nr_2}=90    ${timeout}=1
    ${meas_A}    Set Variable    phycell_id\=${pci_1} nrsrp_nr\=${nrsrp_nr_1}
    ${meas_B}    Set Variable    phycell_id\=${pci_2} nrsrp_nr\=${nrsrp_nr_2}

    Execute Egate Command
    ...    cmd=ue_measurement_send_nr event\=A4 id\=${ue_id} meas_id\=${meas_id} ${meas_A} ${meas_B}
    ...    timeout=${timeout}

Verify if BB13 UE${ue_id:\d+} RRCReconfiguration ${rrc_msg:\d+} of ${all:\d+} contains A4 configuration
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_B_B13}
    ...  message_alias=RRCReconfiguration_${rrc_msg}
    ...  flow_alias=${flow_alias}

Verify if UE${ue_id:\d+} Measurement Report is expected A4 measurement with two measured PCIs
    ${flow_alias}=     Get Flow Name
    ...     MeasurementReport
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${A4_measurementReport_with_two_measured_PCIs_BB13}
    ...  message_alias=MeasurementReport
    ...  flow_alias=${flow_alias}

Set Message Flow Expectations for BB13 UE Buffer Trigger And SCell Addition
    [Arguments]    ${ue_id}    ${gnb_id}
    Set 1 expected PrivateMessages UE gNB${gnb_id} and 15 s timeout
    Set 5 expected UE Context Modification messages for A4 handling for UE${ue_id} and gNB${gnb_id}
    Set 2 expected RRC Reconfiguration Request and Complete messages for UE${ue_id}
    Set 2 expected DLRRCMessageTransfer messages for gNB${gnb_id}
    Set 2 expected ULRRCMessageTransfer messages for gNB${gnb_id}

Check Message Flow Expectations for BB13 UE Buffer Trigger And SCell Addition
    [Arguments]    ${ue_id}    ${gnb_id}
    Verify that all 1 expected PrivateMessages occured UE gNB${gnb_id} and 15 s timeout
    Verify 5 UE Context Modification messages for A4 handling for UE${ue_id} and gNB${gnb_id} occured
    Verify that all 2 RRC Reconfiguration Request and Complete messages occured for UE${ue_id}
    Verify that all 2 DLRRCMessageTransfer messages occured for gNB${gnb_id}
    Verify that all 2 ULRRCMessageTransfer messages occured for gNB${gnb_id}

Verify if BB13 UE${ue_id:\d+} RRCReconfiguration ${rrc_msg:\d+} of ${all:\d+} contains A4 measurements deconfiguration and measConfig release
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${Meas_Config_With_A4_Measurements_Deconfiguration_In_RRC_Reconf_B_B13}
    ...  message_alias=RRCReconfiguration_${rrc_msg}
    ...  flow_alias=${flow_alias}

Verify if UE${ue_id:\d+} RRCReconfiguration ${rrc_msg:\d+} of ${all:\d+} contains A2 Scell Release A6 SCell swap and SCell configuration
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${SCell_Addition_With_Meas_Config_containging_A2_A6_Measurements_In_RRC_Reconf_B_B13}
    ...  message_alias=RRCReconfiguration_${rrc_msg}
    ...  flow_alias=${flow_alias}

Set Message Flow Expectations for BB13 SCell Swap
    [Arguments]    ${ue_id}    ${gnb_id}
    Set expected Measurement Report messages for for UE${ue_id}
    Set 3 expected UE Context Modification messages for A4 handling for UE${ue_id} and gNB${gnb_id}
    Set 1 expected RRC Reconfiguration Request and Complete messages for UE${ue_id}
    Set 1 expected DLRRCMessageTransfer messages for gNB${gnb_id}
    Set 2 expected ULRRCMessageTransfer messages for gNB${gnb_id}

Check Message Flow Expectations for BB13 SCell Swap
    [Arguments]    ${ue_id}    ${gnb_id}
    Verify that Measurement Report messages occured for UE${ue_id}
    Verify 3 UE Context Modification messages for A4 handling for UE${ue_id} and gNB${gnb_id} occured
    Verify that all 1 RRC Reconfiguration Request and Complete messages occured for UE${ue_id}
    Verify that all 1 DLRRCMessageTransfer messages occured for gNB${gnb_id}
    Verify that all 2 ULRRCMessageTransfer messages occured for gNB${gnb_id}

Trigger A6 Measurement For SCell Swap
    [Arguments]    ${ue_id}    ${meas_id}    ${srsrp_nr}    ${scell_id}    ${scell_rsrp}
    ...    ${phycell_id_target}    ${nrsrp_nr_target}    ${timeout}=1
    ${meas_PCell}    Set Variable    srsrp_nr\=${srsrp_nr}
    ${meas_SCell_source}    Set Variable    scell\=${scell_id} scell_rsrp\=${scell_rsrp}
    ${meas_SCell_target}    Set Variable    phycell_id\=${phycell_id_target} nrsrp_nr\=${nrsrp_nr_target}

    Execute Egate Command
    ...    cmd=ue_measurement_send_nr event\=A6 id\=${ue_id} meas_id\=${meas_id} ${meas_PCell} ${meas_SCell_source} ${meas_SCell_target}
    ...    timeout=${timeout}

Stop Data Traffic
    [Arguments]    ${ue_id}   ${pdu_id}    ${qfi_id}=1
    Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id}

Verify if UE${ue_id:\d+} Measurement Report is expected A6 measurement for BB13
    ${flow_alias}=     Get Flow Name
    ...     MeasurementReport
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${A6_measurementReport_SCell_Swap_BB13}
    ...  message_alias=MeasurementReport
    ...  flow_alias=${flow_alias}

Verify if UE${ue_id:\d+} RRCReconfiguration ${rrc_msg:\d+} of ${all:\d+} contains Scell Swap Messages
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_sCellToAddModList_after_SCell_Swap_BB13}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=${flow_alias}
    Verify That Message Fulfills Query
    ...  ${spCellConfig_in_UE_CON_MOD_RESP_Cell1_release_BB13}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=${flow_alias}
    Verify That Message Fulfills Query
    ...  ${measIdToAddModList_after_SCell_Swap_BB13}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=${flow_alias}

Verify Pm Counters BB13
    [Arguments]    ${cell_id}    ${counter_id_list}    ${counter_name_list}    ${local_moid}    ${condition}=>0
    ${counters_amount}=    Get length    ${counter_id_list}
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    FOR    ${index}    IN RANGE    0    ${counters_amount}
        Verify Any Counters In File
        ...  @{counter_id_list}[${index}]    ${condition}    @{counter_name_list}[${index}]
        ...  local_moid=${local_moid}
        ...  file_path=${pm_counter_file}
    END

#CB006733_B_B19
Trigger A1 Measurement And Start High DL non-GBR Data Traffic To SCell Addition
    [Arguments]    ${ue_id}    ${A1_meas_id}    ${pdu_id}    ${gnb_id}    ${srsrp_nr}    ${srsrq_nr}    ${scell_phy_cell_id}
    Trigger A1 Measurement For SCell Addition And Start Data Traffic And Expect SCell Addition Messages Flow    ue_id=${ue_id}
    ...    meas_id=${A1_meas_id}    pdu_id=${pdu_id}    gnb_id=${gnb_id}    srsrp_nr=${srsrp_nr}    srsrq_nr=${srsrq_nr}

    Verify RRC Reconfiguration Message After SCell Addition    ue_id=${ue_id}    scell_phy_cell_id=${scell_phy_cell_id}
    ...    flow_alias=SCellAddition_A1_UE

Trigger A1 Measurement For SCell Addition And Start Data Traffic And Expect SCell Addition Messages Flow
    [Arguments]    ${ue_id}    ${meas_id}    ${pdu_id}    ${gnb_id}    ${srsrp_nr}=90    ${srsrq_nr}=95
    Expect A1 Measurement Report And SCell Addition Reconfiguration    gnb_id=${gnb_id}    ue_id=${ue_id}    meas_id=${meas_id}
    Trigger A1 Measurement For SCell Addition And Start Data Traffic And Stop Data Traffic    ue_id=${ue_id}    meas_id=${meas_id}    pdu_id=${pdu_id}
    ...    srsrp_nr=${srsrp_nr}    srsrq_nr=${srsrq_nr}
    Flow Occurred As Expected    alias=SCellAddition_A1_UE${ue_id}

Trigger A1 Measurement For SCell Addition And Start Data Traffic And Stop Data Traffic
    [Arguments]    ${ue_id}    ${meas_id}    ${pdu_id}    ${srsrp_nr}=90    ${srsrq_nr}=95    ${timeout}=10
    Execute Egate Command And Wait For Data    cmd=ue_meas_cfg_disp id\=${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id\=${ue_id} meas_id\=${meas_id} event\=A1 srsrp_nr\=${srsrp_nr} srsrq_nr\=${srsrq_nr}
    ...    timeout=${timeout}
    Start Data Traffic    ue_id=${ue_id}   pdu_id=${pdu_id}
    Stop High DL non-GBR Data Traffic    ue_id=${ue_id}   pdu_id=${pdu_id}

Expect A1 Measurement Report And SCell Addition Reconfiguration
    [Arguments]    ${gnb_id}    ${ue_id}    ${meas_id}    ${overall_timeout}=60
    Expect Message Flow
    ...    UE${ue_id}:NR-RRC_MeasurementReport (measId eq ${meas_id}) as A1measurementReport
    ...    UE${ue_id}:NR-RRC_RRCReconfiguration (sCellToAddModList is present) as RRCReconfiguration
    ...    alias=SCellAddition_A1_UE${ue_id}
    ...    overall_timeout=${overall_timeout}

Stop High DL non-GBR Data Traffic
    [Arguments]    ${ue_id}   ${pdu_id}    ${trf_id_num}=6
    FOR    ${trf_id_index}    IN RANGE    1    ${trf_id_num}
        Execute Egate Command And Wait For Data    cmd=trf_data_stop ue=${ue_id} pdu=${pdu_id} trf_id=${trf_id_index} dir=dl
    END

Verify RRC Reconfiguration Message After SCell Addition
    [Arguments]    ${ue_id}    ${scell_phy_cell_id}    ${flow_alias}    ${scell_index}=1
    Verify That Message Fulfills Query
    ...    (sCellToAddModList is present) and (length(sCellToAddModList) eq 1) and
    ...    (sCellIndex eq ${scell_index}) and (physCellId eq ${scell_phy_cell_id})
    ...    message_alias=RRCReconfiguration
    ...    flow_alias=${flow_alias}${ue_id}

Trigger A2 Measurement For PCell Change And Start High DL non-GBR Data Traffic To SCell Addition
    [Arguments]    ${ue_id}    ${gnb_id}    ${A2_cmd}    ${A2_meas_id}    ${pdu_id}    ${scell_phy_cell_id}
    ...    ${source_phy_cell_id}    ${target_phy_cell_id}
    Trigger A2 Measurement Report For PCell Change And Expect PCell Change Messages Flow    ue_id=${ue_id}   A2_cmd=${A2_cmd}
    ...    meas_id=${A2_meas_id}    gnb_id=${gnb_id}

    Verify A2 Measurement Report For PCell Change    ue_id=${ue_id}    source_phy_cell_id=${source_phy_cell_id}
    ...    target_phy_cell_id=${target_phy_cell_id}
    Verify HO Information And SCell Release    ue_id=${ue_id}    source_phy_cell_id=${source_phy_cell_id}    target_phy_cell_id=${target_phy_cell_id}
    Verify A1 And A4 Measurements Configurations    ue_id=${ue_id}

    Start Data Traffic And Expect SCell Addition And A1 Deactivation Messages Flow And Stop Data Traffic    ue_id=${ue_id}    pdu_id=${pdu_id}
    ...    gnb_id=${gnb_id}

    Verify A4 Measurements Deactivation    ue_id=${ue_id}
    Verify RRC Reconfiguration Message After SCell Addition    ue_id=${ue_id}    scell_phy_cell_id=${scell_phy_cell_id}
    ...    flow_alias=SCellAddition_UE
    Verify A1 Measurements Deactivation    ue_id=${ue_id}

Trigger A2 Measurement Report For PCell Change And Expect PCell Change Messages Flow
    [Arguments]    ${ue_id}    ${A2_cmd}    ${meas_id}    ${gnb_id}
    Expect A2 Measurement Report And PCell Change Messages Flow    ue_id=${ue_id}    meas_id=${meas_id}    gnb_id=${gnb_id}
    Trigger A2 Measurement Report For PCell Change    ue_id=${ue_id}   A2_cmd=${A2_cmd}
    Flow Occurred As Expected    alias=A2_PCellChange_UE${ue_id}

Trigger A2 Measurement Report For PCell Change
    [Arguments]    ${ue_id}    ${A2_cmd}
    Execute Egate Command And Wait For Data    cmd=ue_meas_cfg_disp id=${ue_id}
    Execute Egate Command And Wait For Data    cmd=ue_measurement_send_nr ${A2_cmd}

Expect A2 Measurement Report And PCell Change Messages Flow
    [Arguments]    ${ue_id}    ${meas_id}    ${gnb_id}    ${overall_timeout}=60
    Expect Message Flow
    ...    UE${ue_id}:NR-RRC_MeasurementReport (measId eq ${meas_id}) as A2measurementReport
    ...    gNB${gnb_id}:F1AP_UEContextModificationRequest (SCell-ToBeRemoved-List is present) as UEContextModificationRequest
    ...    gNB${gnb_id}:F1AP_UEContextModificationResponse (sCellToReleaseList is present) as UEContextModificationResponse
    ...    UE${ue_id}:NR-RRC_RRCReconfiguration (eventId contains (eventA1 is present)) as RRCReconfiguration_A1
    ...    gNB${gnb_id}:F1AP_PrivateMessage as BufferMonitoring
    ...    UE${ue_id}:NR-RRC_RRCReconfiguration (eventId contains (eventA4 is present)) as RRCReconfiguration_A4
    ...    alias=A2_PCellChange_UE${ue_id}
    ...    overall_timeout=${overall_timeout}

Verify A2 Measurement Report For PCell Change
    [Arguments]    ${ue_id}    ${source_phy_cell_id}    ${target_phy_cell_id}
    Verify That Message Fulfills Query
    ...     (measResultServingMOList is present) and (length(measResultServingMOList) eq 2) and
    ...     (measResultServingCell contains (physCellId eq ${source_phy_cell_id})) and
    ...     (measResultServingCell contains (physCellId eq ${target_phy_cell_id}))
    ...     message_alias=A2measurementReport
    ...     flow_alias=A2_PCellChange_UE${ue_id}

Verify HO Information And SCell Release
    [Arguments]    ${ue_id}    ${source_phy_cell_id}    ${target_phy_cell_id}    ${scell_index}=1
    Verify That Message Fulfills Query
    ...     (handoverPreparationInformation is present) and
    ...     (measResultServingCell contains (physCellId eq ${source_phy_cell_id})) and
    ...     (SCell-ToBeRemoved-List is present) and (length(SCell-ToBeRemoved-List) eq 1) and
    ...     (sCellConfigCommon contains (physCellId eq ${target_phy_cell_id}))
    ...     message_alias=UEContextModificationRequest
    ...     flow_alias=A2_PCellChange_UE${ue_id}

    Verify That Message Fulfills Query
    ...     (sCellToReleaseList is present) and (length(sCellToReleaseList) eq 1)
    ...     message_alias=UEContextModificationResponse
    ...     flow_alias=A2_PCellChange_UE${ue_id}

Verify A1 And A4 Measurements Configurations
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...    (measObjectToAddModList is present) and (length(measObjectToAddModList) eq 1) and
    ...    (reportConfigToAddModList is present) and (length(reportConfigToAddModList) eq 1) and (eventId contains (eventA1 is present)) and
    ...    (measIdToAddModList is present) and (length(measIdToAddModList) eq 1) and
    ...    (measGapConfig is not present)
    ...    message_alias=RRCReconfiguration_A1
    ...    flow_alias=A2_PCellChange_UE${ue_id}

    Verify That Message Fulfills Query
    ...    (measObjectToAddModList is present) and (length(measObjectToAddModList) eq 1) and
    ...    (reportConfigToAddModList is present) and (length(reportConfigToAddModList) eq 2) and (eventId contains (eventA4 is present)) and
    ...    (measIdToAddModList is present) and (length(measIdToAddModList) eq 2) and
    ...    (measGapConfig is present) and (gapUE contains (setup is present))
    ...    message_alias=RRCReconfiguration_A4
    ...    flow_alias=A2_PCellChange_UE${ue_id}

Start Data Traffic And Expect SCell Addition And A1 Deactivation Messages Flow And Stop Data Traffic
    [Arguments]    ${ue_id}    ${pdu_id}    ${gnb_id}
    Expect SCell Addition Without A1 Measurement Report And A4_A1 Measurements Deactivation Messages Flow    gnb_id=${gnb_id}    ue_id=${ue_id}
    Start Data Traffic    ue_id=${ue_id}   pdu_id=${pdu_id}
    Stop High DL non-GBR Data Traffic    ue_id=${ue_id}   pdu_id=${pdu_id}
    Flow Occurred As Expected    alias=SCellAddition_UE${ue_id}

Expect SCell Addition Without A1 Measurement Report And A4_A1 Measurements Deactivation Messages Flow
    [Arguments]    ${gnb_id}    ${ue_id}    ${overall_timeout}=60
    Expect Message Flow
    ...    gNB${gnb_id}:F1AP_PrivateMessage as BufferCriterion
    ...    UE${ue_id}:NR-RRC_RRCReconfiguration (length(measIdToRemoveList) eq 2) as RRCReconfiguration_A4
    ...    gNB${gnb_id}:F1AP_UEContextModificationRequest (SCell-ToBeSetupMod-List is present) as UEContModRequest
    ...    gNB${gnb_id}:F1AP_UEContextModificationResponse (sCellToAddModList is present) as UEContModResponse
    ...    UE${ue_id}:NR-RRC_RRCReconfiguration (length(measIdToRemoveList) eq 1) as RRCReconfiguration
    ...    alias=SCellAddition_UE${ue_id}
    ...    overall_timeout=${overall_timeout}

Verify A4 Measurements Deactivation
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...    (measIdToRemoveList is present) and (length(measIdToRemoveList) eq 2) and
    ...    (measGapConfig is present) and (gapUE contains (release is present))
    ...    message_alias=RRCReconfiguration_A4
    ...    flow_alias=SCellAddition_UE${ue_id}

Verify A1 Measurements Deactivation
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...    (measIdToRemoveList is present) and (length(measIdToRemoveList) eq 1) and
    ...    (measGapConfig is not present)
    ...    message_alias=RRCReconfiguration
    ...    flow_alias=SCellAddition_UE${ue_id}

Verify A1 Measurement Configuration NSA Mode
    [Arguments]    ${ue_id}
        Verify That Message Fulfills Query
        ...  ${A1_Configuration_UE_CON_MOD_REQ}
        ...  message_alias=ContextSetupReq
        ...  flow_alias=EN-DC_UE${ue_id}
        Verify That Message Fulfills Query
        ...  ${A1_Configuration_SgNBAdditionRequestAcknowledge}
        ...  message_alias=SgnbAddReqAck
        ...  flow_alias=EN-DC_UE${ue_id}
        Verify That Message Fulfills Query
        ...  ${successful_UE_reconfig_SgNBReconfigurationComplete}
        ...  message_alias=SgnbReconfCmp
        ...  flow_alias=EN-DC_UE${ue_id}

Verify candidateCellInfoListMN during SgNBAdditionRequest
    [Arguments]    ${ue_id}
        Verify That Message Fulfills Query
        ...  ${candidateCellInfoListMN_during_SgNBAdditionReq}
        ...  message_alias=SgnbAddReq
        ...  flow_alias=EN-DC_UE${ue_id}

Verify that SgNBAdditionRequestAcknowledge contains reconfigurationWithSync and A1 measurement for UE${ue_id:\d+}
    Verify That Message Fulfills Query
    ...  ${reconfigurationWithSync_sgnb_addition}
    ...  message_alias=SgnbAddReqAck
    ...  flow_alias=EN-DC_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${meas_config_sgnb_addition}
    ...  message_alias=SgnbAddReqAck
    ...  flow_alias=EN-DC_UE${ue_id}
    Verify That Message Fulfills Query
    ...  (pSCellFrequency eq 506430)
    ...  message_alias=SgnbAddReqAck
    ...  flow_alias=EN-DC_UE${ue_id}

Set Message Flow Expectations for A1 Measurement Trigger B_B14
    [Arguments]    ${ue_id}    ${gNB_id}
    Set expected RRCTransfer for measurement report with timeout 9s for gNB${gNB_id}
    Set 1 expected PrivateMessages UE gNB2 and 15 s timeout

Set expected RRCTransfer for measurement report with timeout ${timeout:\d+}s for gNB${gnb_id:\d+}
    EXPECT FLOW[timeout=${timeout}]: gNB${gnb_id} X2AP rRCTransfer

Trigger A1 Measurement For RSRP B_B14
    [Arguments]    ${ue_id}    ${meas_id_rsrp}    ${timeout}=30
    Execute Egate Command    cmd=ue_meas_cfg_disp id\=${ue_id}
    Execute Egate Command
    ...    cmd=ue_measurement_send_nr id\=${ue_id} meas_id\=${meas_id_rsrp} event\=A1 srsrp_nr\=90

Verify RRCTransfer for measurement report with timeout ${timeout:\d+}s occured for gNB${gnb_id:\d+}
    PASS FLOW[timeout=${timeout}]: gNB${gnb_id} X2AP rRCTransfer

Check Message Flow Expectations for A1 Measurement Trigger B_B14
    [Arguments]    ${ue_id}
    Verify RRCTransfer for measurement report with timeout 9s occured for gNB2
    Verify that all 1 expected PrivateMessages occured UE gNB2 and 15 s timeout

Set Message Flow Expectations after data traffic start B_B14
    [Arguments]    ${ue_id}    ${gNB_id}
    Set 1 expected PrivateMessages UE gNB2 and 15 s timeout
    Set 3 expected UE Context Modification messages for SCell Addition for UE${ue_id} and gNB${gnb_id}
    Expect Message Flow
    ...    gNB2:X2AP_SgNBModificationRequired as SgBModificationReq
    ...    gNB2:X2AP_SgNBModificationConfirm as SgBModificationConf
    ...    alias=SgBModificationSCellAdd   overall_timeout=60

Start High DL non-GBR Data Traffic NSA
    [Arguments]    ${ue_id}    ${trf_level}=175    ${trf_id_1}=1    ${trf_id_2}=2    ${trf_id_3}=3    ${trf_id_4}=4    ${trf_id_5}=5
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} id=2 trf_id=${trf_id_1} dir=dl mbps=${trf_level}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} id=2 trf_id=${trf_id_2} dir=dl mbps=${trf_level}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} id=2 trf_id=${trf_id_3} dir=dl mbps=${trf_level}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} id=2 trf_id=${trf_id_4} dir=dl mbps=${trf_level}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} id=2 trf_id=${trf_id_5} dir=dl mbps=${trf_level}

Check Message Flow Expectations after data traffic start B_B14
    [Arguments]    ${ue_id}    ${gNB_id}
    Verify that all 1 expected PrivateMessages occured UE gNB${gNB_id} and 15 s timeout
    Verify 3 UE Context Modification messages for SCell addition for UE${ue_id} and gNB${gNB_id} occured
    Flow Occurred As Expected    alias=SgBModificationSCellAdd

Verify SgNBModificationRequired if contains A2 measurement for SCell Release
        Verify That Message Fulfills Query
        ...  ${measConfig_in_SgNBModificationRequired_B14}
        ...  message_alias=SgBModificationReq
        ...  flow_alias=SgBModificationSCellAdd

# CB006733_B_B16
Trigger A1 And A4 Measurements For Two Different SCells
    [Arguments]    ${ue_id}
    Execute Egate Command    cmd=ue_meas_cfg_disp id\=${ue_id}
    Execute Egate Command    cmd=ue_measurement_send_nr id\=${ue_id} meas_id\=1 event\=A1 srsrp_nr\=90
    Execute Egate Command    cmd=ue_measurement_send_nr event\=A4 phycell_id\=51 nrsrp_nr\=95 id\=${ue_id} meas_id\=2

Start 400 MBPS Data DL Traffic
    [Arguments]    ${ue_id}   ${pdu_id}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=1 dir=dl mbps=100
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=2 dir=dl mbps=100
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=3 dir=dl mbps=100
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=4 dir=dl mbps=100

Stop All Data Traffics
    [Arguments]    ${ue_id}
    Execute Egate Command    cmd=trf_data_stop ue=${ue_id}

Verify SCell Addition Messages For Two Different SCells
    [Arguments]    ${ue_id}    ${nRCellIdentity_1}    ${nRCellIdentity_2}    ${scell_physcellid_1}    ${scell_physcellid_2}
    Verify That Message Has Fields
    ...                              SCell-ToBeSetupMod-List..nRCellIdentity eq ${nRCellIdentity_1}
    ...                              SCell-ToBeSetupMod-List..nRCellIdentity eq ${nRCellIdentity_2}
    ...  message_alias=UEContModRequest
    ...  flow_alias=SCellAddition_UE${ue_id}

    Verify That Message Has Fields
    ...                              csi-ReportConfigToAddModList..reportConfigId eq 13
    ...                              csi-ReportConfigToAddModList..reportConfigId eq 14
    ...  message_alias=UEContModResponse
    ...  flow_alias=SCellAddition_UE${ue_id}

    Verify That Message Has Fields
    ...                              sCellToAddModList..physCellId eq ${scell_physcellid_1}
    ...                              sCellToAddModList..physCellId eq ${scell_physcellid_2}
    ...  message_alias=UEContModResponse
    ...  flow_alias=SCellAddition_UE${ue_id}

#B20
Verify CPlane Overload State Enabled
    [Arguments]    ${Cplane_overload_state}
    Verify Tcpdump Log    packet_filter=${Cplane_overload_state}    number_of_messages=0  relation_symbol= >

Verify CPlane Overload State Disabled
    [Arguments]    ${Cplane_overload_state}
    Verify Tcpdump Log    packet_filter=${Cplane_overload_state}    number_of_messages=0  relation_symbol= >

Verify 1 SCells Addition After A4 Event Trigger
    [Arguments]    ${UeContextModReqAfterA4}
    Verify Tcpdump Log    packet_filter=${UeContextModReqAfterA4}

Extended SupervisionTimer
    [Arguments]    ${a4svtimer_value}
    Log to console    Extended SuperVisionTimer to: ${a4svtimer_value}s
    Run Process    /home/ute/test_repository/testsuite/Wroclaw/RRM/WRO_2/CB006733/RND_change_param.sh ${a4svtimer_value}    shell=True

Set Message Flow Expectations Private Messages And SCell Addition
    [Arguments]    ${ue_id}    ${gnb_id}
    Set 3 expected PrivateMessages UE gNB2 and 15 s timeout
    Expect SCell Addition Messages Flow B_B12   ue_id=${ue_id}    gnb_id=${gnb_id}

Configure simulated interfaces
    With Simulated Network Interface    name=eth3:GNB_S1U    ip=10.0.1.112/24
    With Simulated Network Interface    name=eth3:ENB_X2U    ip=10.0.1.135/24
    With Simulated Network Interface    name=eth3:SGW_S1U    ip=10.0.1.133/24
    With Simulated Network Interface    name=eth3:SGW_S11    ip=10.0.1.134/24
    With Simulated Network Interface    name=eth3:MME1_S1    ip=10.0.1.131/24
    With Simulated Network Interface    name=eth3:ENB1_S1    ip=10.0.1.136/24
    With Simulated Network Interface    name=eth3:ENB1_X2    ip=10.0.1.137/24

Verify A2 Measurement Configuration For HO NSA Mode BB15
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${candidateCellInfoListMN_during_SgNBAdditionReq_BB15}
    ...  message_alias=ContextSetupReq
    ...  flow_alias=EN-DC_UE${ue_id}
    Verify that UEContextSetupRequest contains measConfig with A2 configuration for UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${reconfigurationWithSync_before_HO_BB15}
    ...  message_alias=ContextSetupResp
    ...  flow_alias=EN-DC_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${A2_measurement_configuration_for_HO_B_B15}
    ...  message_alias=SgnbAddReqAck
    ...  flow_alias=EN-DC_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${reconfigurationWithSync_before_HO_BB15}
    ...  message_alias=SgnbAddReqAck
    ...  flow_alias=EN-DC_UE${ue_id}
    Verify That Message Fulfills Query
    ...  nonCriticalExtension contains (pSCellFrequency eq 392410)
    ...  message_alias=SgnbAddReqAck
    ...  flow_alias=EN-DC_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${successful_UE_reconfig_SgNBReconfigurationComplete}
    ...  message_alias=SgnbReconfCmp
    ...  flow_alias=EN-DC_UE${ue_id}

Verify candidateCellInfoListMN during SgNBAdditionRequest BB15
    [Arguments]    ${ue_id}
        Verify That Message Fulfills Query
        ...  ${candidateCellInfoListMN_during_SgNBAdditionReq_BB15}
        ...  message_alias=SgnbAddReq
        ...  flow_alias=EN-DC_UE${ue_id}

Load Measurement Gap Configuration for Simulated ENB
    [Arguments]    ${ue_id}    ${gap_pattern}    ${mgta}
    Execute Egate Command
    ...    cmd=ue_enb_param id=${ue_id} measurement_gap=${gap_pattern} mgta=${mgta} gap_purpose=perUE gap_trigger=gnb_triggered

Set Message Flow Expectations for A2 Measurement Trigger B_B15
    [Arguments]    ${gNB_id}
    Set expected RRCTransfer for measurement report with timeout 9s for gNB${gNB_id}
    Expect Message Flow
    ...    gNB2:X2AP_SgNBModificationRequired as SgBModificationRequired
    ...    gNB2:X2AP_SgNBModificationRequest as SgBModificationRequest
    ...    gNB2:F1AP_UEContextModificationRequest as UEContextModificationReq
    ...    gNB2:F1AP_UEContextModificationResponse as UEContextModificationResp
    ...    gNB2:X2AP_SgNBModificationRequestAcknowledge as SgBModificationReqAck
    ...    gNB2:X2AP_SgNBModificationConfirm (rrcReconfigurationComplete is present) as SgBModificationConf
    ...    alias=A1_A3_measGaps_configuration   overall_timeout=60

Check Message Flow Expectations for A2 Measurement Trigger B_B15
    [Arguments]    ${gNB_id}
    Verify RRCTransfer for measurement report with timeout 9s occured for gNB${gNB_id}
    Flow occurred as expected  alias=A1_A3_measGaps_configuration

Verify that SgBModificationRequired contains measuredFrequenciesSN IE
    Verify That Message Fulfills Query
        ...     ${measuredFrequenciesSN_NSA_BB15}
        ...     message_alias=SgBModificationRequired
        ...     flow_alias=A1_A3_measGaps_configuration

Verify that SgBModificationRequest From MeNB contains measGapConfig configuration IEs
    Verify That Message Fulfills Query
        ...     ${measGapConfig_gaps_MeNB_configured_BB15}
        ...     message_alias=SgBModificationRequest
        ...     flow_alias=A1_A3_measGaps_configuration

Verify that UEContextModificationRequest to DU contains measGapConfig configuration IEs
    Verify That Message Fulfills Query
        ...     ${measGapConfig_gaps_MeNB_configured_BB15}
        ...     message_alias=UEContextModificationReq
        ...     flow_alias=A1_A3_measGaps_configuration

Set Message Flow Expectations for A3 Measurement Trigger B_B15
    [Arguments]    ${gNB_id}
    Set expected RRCTransfer for measurement report with timeout 9s for gNB${gNB_id}
    EXPECT FLOW[timeout=30]: gNB${gNB_id} F1AP 4*uEContextModification
    Expect Message Flow
    ...    gNB2:X2AP_SgNBModificationRequired (measConfig is present) as SgNBModificationRequired
    ...    gNB2:X2AP_SgNBModificationConfirm (rrcReconfigurationComplete is present) as SgNBModificationConf
    ...    gNB2:X2AP_SgNBModificationRequired (measConfig is not present and measConfigSN is not present) as SgNBModificationRequired_2
    ...    gNB2:X2AP_SgNBModificationRequest as SgNBModificationRequest
    ...    gNB2:X2AP_SgNBModificationRequestAcknowledge as SgNBModificationReqAck
    ...    gNB2:X2AP_SgNBModificationConfirm as SgNBModificationConf_2
    ...    alias=A3_measurement_trigger   overall_timeout=60

Check Message Flow Expectations for A3 Measurement Trigger B_B15
    [Arguments]    ${gNB_id}
    Verify RRCTransfer for measurement report with timeout 9s occured for gNB2
    PASS FLOW[timeout=30]: gNB${gNB_id} F1AP 4*uEContextModification
    Flow occurred as expected  alias=A3_measurement_trigger

Verify that SgBModificationRequired contains reconfigurationWithSync and measConfig for SCell addition NSA
    Verify That Message Fulfills Query
    ...  ${reconfigurationWithSync_after_HO_BB15}
    ...  message_alias=SgNBModificationRequired
    ...  flow_alias=A3_measurement_trigger
    Verify That Message Fulfills Query
    ...  ${SgBModificationRequired_Meas_Config_With_A1_for_SCell_addition_after_HO_B_B15}
    ...  message_alias=SgNBModificationRequired
    ...  flow_alias=A3_measurement_trigger

Verify that SgBModificationRequest contains measurement gap release for NSA
    Verify That Message Fulfills Query
    ...  ${meas_gap_release_after_HO_to_target_cell_B_B15}
    ...  message_alias=SgNBModificationRequest
    ...  flow_alias=A3_measurement_trigger

Set Message Flow Expectations for A1 Measurement Trigger B_B15
    [Arguments]    ${gNB_id}
    Set expected RRCTransfer for measurement report with timeout 9s for gNB${gNB_id}
    Set 1 expected PrivateMessages UE gNB${gNB_id} and 15 s timeout

Check Message Flow Expectations for A1 Measurement Trigger B_B15
    [Arguments]    ${gNB_id}
    Verify RRCTransfer for measurement report with timeout 9s occured for gNB${gNB_id}
    Verify that all 1 expected PrivateMessages occured UE gNB${gNB_id} and 15 s timeout

Set Message Flow Expectations after data traffic start B_B15
    [Arguments]    ${ue_id}    ${gNB_id}
    Set 1 expected PrivateMessages UE gNB${gNB_id} and 15 s timeout
    Set 3 expected UE Context Modification messages for SCell Addition for UE${ue_id} and gNB${gnb_id}
    Expect Message Flow
    ...    gNB2:X2AP_SgNBModificationRequired as SgBModificationReq
    ...    gNB2:X2AP_SgNBModificationConfirm (rrcReconfigurationComplete is present) as SgBModificationConf
    ...    alias=SgBModificationSCellAdd   overall_timeout=60

Stop Data Traffic NSA
    [Arguments]    ${ue_id}   ${bearer_id}=2
    Execute Egate Command    cmd=trf_data_stop ue=${ue_id} id=${bearer_id}

Check Message Flow Expectations after data traffic start B_B15
    [Arguments]    ${ue_id}    ${gNB_id}
    Verify that all 1 expected PrivateMessages occured UE gNB2 and 15 s timeout
    Verify 3 UE Context Modification messages for SCell addition for UE11 and gNB2 occured
    Flow Occurred As Expected    alias=SgBModificationSCellAdd

Verify SgNBModificationRequired if contains A2 measurement for SCell Release BB15
        Verify That Message Fulfills Query
        ...  ${SCell_Addition_With_Meas_Config_containing_A2_and_with_ScellToAddModList_BB15}
        ...  message_alias=SgBModificationReq
        ...  flow_alias=SgBModificationSCellAdd

Verify that SgNBModificationReqAck contains A1 ans A3 configuration for HO
    Verify That Message Fulfills Query
        ...     ${SgNB_Modification_Request_Ack_with_A1_A3_meas_configuration_for_HO_BB15}
        ...     message_alias=SgBModificationReqAck
        ...     flow_alias=A1_A3_measGaps_configuration

Verify that SgNBModificationRequest contains measGapConfig release
    Verify That Message Fulfills Query
    ...  ${meas_gap_release_after_HO_to_target_cell_B_B15}
    ...  message_alias=SgNBModificationRequest
    ...  flow_alias=A3_measurement_trigger

# CB006733_B_B34

Trigger Two A4 Measurements For Two Different SCells
    [Arguments]    ${ue_id}
    Execute Egate Command And Wait For Data    cmd=ue_meas_cfg_disp id\=${ue_id}
    Execute Egate Command And Wait For Data    cmd=ue_measurement_send_nr event\=A4 phycell_id\=51 nrsrp_nr\=95 id\=${ue_id} meas_id\=1
    Execute Egate Command And Wait For Data    cmd=ue_measurement_send_nr event\=A4 phycell_id\=56 nrsrp_nr\=95 id\=${ue_id} meas_id\=2

Verify Deactivated A4 Measurements Where Inter-freq A4 for Idle Mode Steering Are Activated In The Same Rrc Conf Message
    [Arguments]    ${Act_Deact_A4_meas}
    Verify Tcpdump Log    packet_filter=${Act_Deact_A4_meas}

Attach Ue With Pdu And Wait Till Inactivity Timer Expires Then Start Traffic Before A4retryTimer And A4fr1SuperTimer Expires
    Execute Egate Command    cmd=script file=${CURDIR}/config/wts_Script_6733_B23.txt

Verify If A4 measurements for Idle mode steering are deactivated After Starting Data Traffic
    [Arguments]    ${A4_Imm_Deactivation}
    Verify Tcpdump Log    packet_filter=${A4_Imm_Deactivation}

Verify If A4 measurements for FR1 CA SCell Addition are activated again at the UE
    [Arguments]    ${A4_Imm_Deactivation}
    Verify Tcpdump Log    packet_filter=${Second_A4_Confirmation}

#C_B29
Register UE To gNB without PDU session setup
    [Arguments]    ${ue_id}    ${timeout}=3
    Execute Egate Command    cmd=amf_param id=1 empty_pdu_session_list=on send_ics_registration=on
    Execute Egate Command    cmd=ue_register id=${ue_id}
    ...    timeout=${timeout}

Setup PDU session with 3 DRBs
    [Arguments]    ${ue_id}    ${timeout}=3
    Execute Egate Command    cmd=smf_param id=1 additional_qosflows_to_activate=2,3
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=3 trf_type=internal
    Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=3 nwslice=1 gw=3
    ...    timeout=${timeout}

Verify PDU Session Resource Setup Request With 3 Eligible DRBs
    [Arguments]    ${PDUSessionResourceSetupRequest}
    Verify Tcpdump Log    packet_filter=${PDUSessionResourceSetupRequest}

Verify PDU Session Resource Setup Response
    [Arguments]    ${PDUSessionResourceSetupResponse}
    Verify Tcpdump Log    packet_filter=${PDUSessionResourceSetupResponse}

#C_B27
Verify PDU Session Resource Setup Request With 3 Eligible DRBs on Ngap
    [Arguments]    ${PDUSessionResourceSetupRequest}
    Verify Ngap Messages    packet_filter=${PDUSessionResourceSetupRequest}

Verify PDU Session Resource Setup Response on Ngap
    [Arguments]    ${PDUSessionResourceSetupResponse}
    Verify Ngap Messages    packet_filter=${PDUSessionResourceSetupResponse}

Setup 2 Additional DRBs
    [Arguments]    ${qos1}    ${qos2}    ${param_id}=1
    Execute Egate Command    cmd=smf_param id=${param_id} additional_qosflows_to_activate=${qos1},${qos2}

Setup PDU Session Only
    [Arguments]    ${ue_id}    ${pdu_id}    ${gw_id}     ${timeout}=3
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1 gw=${gw_id}
    ...    timeout=${timeout}

Verify if UE${ue_id:\d+} RRCReconfiguration ${rrc_msg:\d+} of ${all:\d+} contains A4 configuration for CB27
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    Verify That Message Fulfills Query
    ...  ${Meas_Config_With_A4_Measurements_Configuration_In_RRC_Reconf_C_B27}
    ...  message_alias=RRCReconfiguration_${rrc_msg}
    ...  flow_alias=${flow_alias}

#C_B31
Setup PDU session with non CA eligible DRB
    [Arguments]    ${ue_id}    ${pdu_id}=3    ${gw_id}=3    ${timeout}=3
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1 gw=${gw_id}
    ...    timeout=${timeout}

Verify PDU Session Resource Setup Request With non CA eligible DRB
    [Arguments]    ${PDUSessionResourceSetupRequest}
    Verify Tcpdump Log    packet_filter=${PDUSessionResourceSetupRequest}

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

Activate Feature CB009059 With FR1 CA Incompatible DRB
    [Arguments]    ${delta_scfc}
    Find Scfc And Send Delta Commissioning Retrying After Errors    scfc_filename=${delta_scfc}

Apply Rollback Delta Configuration
    [Arguments]    ${rollback_delta_scfc}
    Find Scfc And Send Delta Commissioning Retrying After Errors    scfc_filename=${rollback_delta_scfc}

Set ${rrc_comp:\d+} Expected RRC Reconfiguration Req And Comp Messages For Unwanted UE${ue_id:\d+} A4 Meas Configuration And ${timeout:\d+}s Timeout
    EXPECT FLOW[timeout=${timeout}]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfiguration
    EXPECT FLOW[timeout=${timeout}]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfigurationComplete


Verify That Occured Less Than ${rrc_comp:\d+} RRC Reconfiguration Request And Complete After HO For UE${ue_id:\d+} And ${timeout:\d+}s Timeout
    FAIL FLOW[timeout=${timeout}]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfiguration
    FAIL FLOW[timeout=${timeout}]: UE${ue_id} NR-RRC ${rrc_comp}*RRCReconfigurationComplete

Verify If UE${ue_id:\d+} RRCReconfiguration ${rrc_msg:\d+} Of ${all:\d+} Contains ReconfigurationWithSync To ID ${target_cell:\d+} Cell
    ${flow_alias}=     Get Flow Name
    ...     ${all}*RRCReconfiguration
    ...     device=UE${ue_id}
    ...     protocol=NR-RRC
    ${message_alias}    Set Variable If    ${all} != 1    RRCReconfiguration_${msg_num}    RRCReconfiguration
    Verify That Message Fulfills Query
    ...  reconfigurationWithSync contains (spCellConfigCommon contains (physCellId eq ${target_cell}))
    ...  message_alias=${message_alias}
    ...  flow_alias=${flow_alias}

Verify That UEContextModificationResponse_${msg_num:\d+} Of ${all:\d+} Contains ReconfWithSync To ID ${target_cell:\d+} Cell For GNB${gnb_id:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=${all}*uEContextModification
    ...     device=gNB${gnb_id}
    ...     protocol=F1AP
    ${message_alias}    Set Variable If    ${all} != 1    UEContextModificationResponse_${msg_num}    UEContextModificationResponse
    Verify That Message Fulfills Query
    ...  reconfigurationWithSync contains (spCellConfigCommon contains (physCellId eq ${target_cell}))
    ...  message_alias=${message_alias}
    ...  flow_alias=${flow_alias}

#C_B30
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
