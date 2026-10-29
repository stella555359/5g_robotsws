
*** Keywords ***

Configure simulated interfaces
    With Simulated Network Interface    name=eth3:ENB3_X2    ip=10.0.1.122/24
    With Simulated Network Interface    name=eth3:ENB1_X2    ip=10.0.1.121/24
    With Simulated Network Interface    name=eth3:ENB3_S1    ip=10.0.1.138/24
    With Simulated Network Interface    name=eth3:EN1_X2U    ip=10.0.1.135/24
    With Simulated Network Interface    name=eth3:EN3_X2U    ip=10.0.1.139/24

Expect ENDC X2 Setup flow
    [Arguments]     ${flow_id}    ${gNB_id}
    Expect Message Flow
    ...    ENB3:X2AP_ENDCX2SetupRequest as ENDCX2SetupReq
    ...    gNB${gNB_id}:X2AP_ENDCX2SetupResponse as ENDCX2SetupResp
    ...    alias=ENDC_X2_Setup_${flow_id}   overall_timeout=60
    Sleep    2s    Wait for capture start

Verify ENDC X2 Setup contents when NokiaENDCChallenge not included
    [Arguments]     ${flow_id}
    Verify NokiaENDCChallenge not included in ENDCX2SetupRequest    flow_id=${flow_id}
    Verify NokiaENDCChallengeResponse not included in ENDCX2SetupResponse    flow_id=${flow_id}

Verify NokiaENDCChallenge not included in ENDCX2SetupRequest
    [Arguments]     ${flow_id}
    Verify That Message Fulfills Query
    ...  ${X2AP_ENDCX2SetupRequest_wo_NokiaENDCChallenge}
    ...  message_alias=ENDCX2SetupReq
    ...  flow_alias=ENDC_X2_Setup_${flow_id}

Verify NokiaENDCChallengeResponse not included in ENDCX2SetupResponse
    [Arguments]     ${flow_id}
    Verify That Message Fulfills Query
    ...  ${X2AP_ENDCX2SetupResponse_wo_NokiaENDCChallengeResponse}
    ...  message_alias=ENDCX2SetupResp
    ...  flow_alias=ENDC_X2_Setup_${flow_id}

Trigger ENDC Connection
    [Arguments]     ${flow_id}=0
    Log To Console	Establishing ENDC X2 connection from eNB ID=3 to gNB ID=2 - flow_id=${flow_id}
    Execute Egate Command    cmd=enb_x2_link_up enb=3 target=2

Check ENDC X2 Setup flow occured
    [Arguments]     ${flow_id}
    Flow Occurred As Expected    alias=ENDC_X2_Setup_${flow_id}

Verify ENDC X2 Setup Response Sent counter
    [Arguments]    ${expected_value}
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55110C00004    ${expected_value}    ENDC_X2_SETUP_RESPONSE_SENT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${pm_counter_file}

Verify ENDC X2 Setup contents when NokiaENDCChallenge included
    [Arguments]     ${flow_id}
    Verify NokiaENDCChallenge included in ENDCX2SetupRequest    flow_id=${flow_id}
    Verify NokiaENDCChallengeResponse included in ENDCX2SetupResponse    flow_id=${flow_id}

Verify NokiaENDCChallenge included in ENDCX2SetupRequest
    [Arguments]     ${flow_id}
    Verify That Message Fulfills Query
    ...  ${X2AP_ENDCX2SetupRequest_with_NokiaENDCChallenge}
    ...  message_alias=ENDCX2SetupReq
    ...  flow_alias=ENDC_X2_Setup_${flow_id}

Verify NokiaENDCChallengeResponse included in ENDCX2SetupResponse
    [Arguments]     ${flow_id}
    Verify That Message Fulfills Query
    ...  ${X2AP_ENDCX2SetupResponse_with_NokiaENDCChallengeResponse}
    ...  message_alias=ENDCX2SetupResp
    ...  flow_alias=ENDC_X2_Setup_${flow_id}

Verify NokiaENDCChallengeResponse content matching expected contentB
    [Arguments]     ${flow_id}
    ${occurrences}=    Evaluate    int(${flow_id}) + int(1)
    Verify Egate Content
    ...    expected_pattern=ENB-3: CalculatedContentB is same as NokiaENDCChallengeResponse received
    ...    occurrence=${occurrences}

Expect X2 Reset flow
    [Arguments]     ${flow_id}    ${gNB_id}
    Expect Message Flow
    ...    ENB3:X2AP_ResetRequest as ResetReq
    ...    gNB${gNB_id}:X2AP_ResetResponse as ResetResp
    ...    alias=X2_Reset_${flow_id}   overall_timeout=60
    Sleep    2s    Wait for capture start

Trigger X2 Reset
    [Arguments]     ${flow_id}
    Log To Console	Triggering X2 ResetRequest - flow_id=${flow_id}
    Execute Egate Command    cmd=link_x2_reset from=3 to=2

Check X2 Reset flow occured
    [Arguments]     ${flow_id}
    Flow Occurred As Expected    alias=X2_Reset_${flow_id}

Reboot Testline
    [Arguments]    ${reboot}=${True}
    Run Keyword If    ${reboot}    Trigger Site Reset
    Wait For Testline ICMP Echo Replies And SSH Services
