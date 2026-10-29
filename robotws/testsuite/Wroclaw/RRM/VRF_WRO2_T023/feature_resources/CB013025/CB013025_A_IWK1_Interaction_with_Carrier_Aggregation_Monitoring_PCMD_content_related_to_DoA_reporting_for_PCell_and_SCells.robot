*** Settings ***
Documentation    Keywords for the CB013025_A_IWK1 test case

Library      ute_wtssim
Library      ta5g_tshark
Library      ta5g_throughput
Library      ta5g_egate
Library      ta5g_testline_management
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T023/resources/airphone/L3_call.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T023/feature_resources/CB013025/resources/CB013025_keywords.robot


*** Variables ***
${UE_ID}=       1    # ID of tested UE from EGATE configuration file connected to NR cell with cell tracing
${PDU_ID}=      1    # ID of used PDU session

*** Keywords ***
TC__CB013025_A_IWK1_Interaction_with_Carrier_Aggregation_Monitoring_PCMD_content_related_to_DoA_reporting_for_PCell_and_SCells
    Update BeamControl Parameters    ue_id=${UE_ID}
    Attach SA UE And Establish PDU Session
    Start High DL Data Traffic    ue_id=${UE_ID}    pdu_id=${PDU_ID}
    Wait For caSCellDirectionOfArrivalRecordReports With BeamType And PCell DoA

    [Teardown]    Run Keywords
    ...           Stop Data Traffic    ues=${UE_ID}
    ...    AND    Deregister UE    ue_id=${UE_ID}

Wait For caSCellDirectionOfArrivalRecordReports With BeamType And PCell DoA
    [Arguments]   ${alias}=${TCE_ALIAS}    ${number_of_messages}=1   ${timeout}=40
    Log  \n==== Validate Trace Recording Sesion Elements MBA ====  console=True
    ${filter}=    Catenate    nsetapx.traceActivationType == 0 && nsetapx.DuVendorExtensionRecordDataType == 29 &&
    ...                                nsetapx.DuVendorExtensionRecordDataType == 36 && nsetapx.beamType == 2
    Verify Tshark For At Least Given Number Of Messages
    ...    alias=${alias}
    ...    packet_filter=${filter}
    ...    number_of_messages=${number_of_messages}
    ...    timeout=${timeout}

Update BeamControl Parameters
    [Arguments]    ${ue_id}
    Log  \n==== Update BeamControl Parameters ====  console=True
    Execute Egate Cmd    cmd=beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1,2,3 ssbeam_bestbeam=0
    Execute Egate Cmd    cmd=ue_testmode_set_nr id=${ue_id} testmode=beam_control action=activate profile_id=1 beamaction=attach

Start High DL Data Traffic
    [Arguments]    ${ue_id}    ${pdu_id}    ${inactive_timer}=200ms
    Log  \n==== Start High Data Traffic ====  console=True
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=1 dir=dl mbps=175
    BuiltIn.Sleep    ${inactive_timer}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=2 dir=dl mbps=175
    BuiltIn.Sleep    ${inactive_timer}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=3 dir=dl mbps=175
    BuiltIn.Sleep    ${inactive_timer}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=4 dir=dl mbps=175
    BuiltIn.Sleep    ${inactive_timer}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=5 dir=dl mbps=175
    BuiltIn.Sleep    ${inactive_timer}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=6 dir=dl mbps=175
    BuiltIn.Sleep    ${inactive_timer}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=7 dir=dl mbps=175
    BuiltIn.Sleep    ${inactive_timer}
