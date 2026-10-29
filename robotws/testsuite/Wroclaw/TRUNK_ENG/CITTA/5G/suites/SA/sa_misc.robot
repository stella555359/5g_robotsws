*** Settings ***
Documentation
...    Collection of unrelated tests that uses same configuration, in SA Mode.
...
...    Suite verifies:
...    - packet flow for NG Link Setup
...    - if messages of NAS Protocol in both directions are transferred successfully
...    - if HO request contains new Mobility Restriction List Container (MRLC) Information Element (IE)
...
...    Subfeatures covered: 5GC000638-A, 5GC000853-A and 5GC002518-A

Metadata    branch    ${ENB_BRANCH}
Metadata    build    ${ENB_BUILD}
Metadata    topology    CLOUD_5G_I_LO_AP_LO
Metadata    variant    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Force Tags    OPTION_RELATED_ARTIFACTS_5G    TOOLS_PROFILE_AP_WTS    PY310    RF50

Resource    ../../resources/main_resources.robot

# -- extra resources --
Variables    ${RESOURCES}/messages_definition.py
Library    ute_tshark

# -- setup/teardown --
Suite Setup    RUN KEYWORDS    Prepare Testing Environment
...    AND    Start Mandatory Logging
...    AND    Backup BTS Configuration Files
...    AND    Get Active BTS Alarms
...    AND    Test suite preconditions

Suite Teardown    RUN KEYWORDS
...    Get Active BTS Alarms    AND
...    Collect Mandatory Logs    AND
...    Cleanup Testing Environment

*** Variables ***
${RESOURCES}    ${CURDIR}/sa_misc.resources

# -- test scenario variables --
${LUA_CONFIG}    ${RESOURCES}/epcsim.cfg
${DELTA_ACTIVATE_XN_LINK_AND_HO}    ${RESOURCES}/delta_activate_xn_link_and_ho.json
${DELTA_UNLOCK_XN}    ${RESOURCES}/delta_xn_unlock.json
${RMODS_NUMBER}    4

*** Test Cases ***
5GC000638-A_1_NGSetupRequest_Response_flow
    [Documentation]    Verifies packet flow for NG Link Setup
    [Setup]    [PRE]5GC000638-A_1_NGSetupRequest_Response_flow
    [Teardown]    [POST]5GC000638-A_1_NGSetupRequest_Response_flow
    Start Tshark Packet Capturing
    Establish NG link and check alarm 7107 is not visible
    Stop Tshark Packet Capturing
    Check NG Setup flow

5GC000853-A_Downlink_NAS_Transport
    [Documentation]
    ...    Verifies successful transfer of NAS protocol messages in Downlink direction
    [Setup]    [PRE]5GC000853-A_Downlink_NAS_Transport
    [Teardown]    [POST]5GC000853-A_Downlink_NAS_Transport
    Start Tshark Packet Capturing
    SA 5G Attach UE"1"
    Start PDU"1" Session For UE"1"
    Stop Tshark Packet Capturing
    Verify DL NAS Transfer Messages

5GC000853-A_Uplink_NAS_Transport
    [Documentation]
    ...    Verifies successful transfer of NAS protocol messages in Uplink direction
    [Setup]    [PRE]5GC000853-A_Uplink_NAS_Transport
    [Teardown]    [POST]5GC000853-A_Uplink_NAS_Transport
    Start Tshark Packet Capturing
    SA 5G Attach UE"2"
    Start PDU"1" Session For UE"2"
    Stop Tshark Packet Capturing
    Verify UL NAS Transfer Messages

5GC002518-A_-_Propagation_Of_MRLC_During_HO_MRL_In_The_Initial_Context_Setup_Request
    [Documentation]
    ...    Verifies if HO request contains MRLC IE
    [Setup]    [PRE]5GC002518-A_-_Propagation_Of_MRLC_During_HO_MRL_In_The_Initial_Context_Setup_Request
    [Teardown]    [POST]5GC002518-A_-_Propagation_Of_MRLC_During_HO_MRL_In_The_Initial_Context_Setup_Request
    Start Tshark Packet Capturing
    Unlock Xn Link Status And Check Status
    Set MRL In Initial Context Setup And Trigger Xn Setup Request
    SA 5G Attach UE"1"
    SA Setup Primary PDU Session For PDU"1" UE"1" GW"1" NWSLICE"1"
    Perform HO Using A5 Event
    Stop Tshark Packet Capturing
    Verify Packet Flow If MRLC Is Received

*** Keywords ***
Test suite preconditions
    Commission eNB To SA Mode
    Eth Interfaces

[PRE]5GC000638-A_1_NGSetupRequest_Response_flow
    Check if BTS is correctly configured    rmods_number=${RMODS_NUMBER}

[POST]5GC000638-A_1_NGSetupRequest_Response_flow
    Report miscellaneous KPIs
    Stop WTS
    ute_tshark.teardown_tshark

[PRE]5GC000853-A_Downlink_NAS_Transport
    Start WTS    ${LUA_CONFIG}    check_version=False
    Check if BTS is OnAir

[POST]5GC000853-A_Downlink_NAS_Transport
    Report miscellaneous KPIs
    SA 5G Detach UE"1"
    Stop WTS
    ute_tshark.teardown_tshark

[PRE]5GC000853-A_Uplink_NAS_Transport
    Start WTS    ${LUA_CONFIG}    check_version=False
    Check if BTS is OnAir

[POST]5GC000853-A_Uplink_NAS_Transport
    Report miscellaneous KPIs
    SA 5G Detach UE"2"
    Stop WTS
    ute_tshark.teardown_tshark

[PRE]5GC002518-A_-_Propagation_Of_MRLC_During_HO_MRL_In_The_Initial_Context_Setup_Request
    Delta Commissisoning    ${DELTA_ACTIVATE_XN_LINK_AND_HO}
    Check if BTS is correctly configured    rmods_number=${RMODS_NUMBER}
    Start WTS    ${LUA_CONFIG}    check_version=False
    Check if BTS is OnAir

[POST]5GC002518-A_-_Propagation_Of_MRLC_During_HO_MRL_In_The_Initial_Context_Setup_Request
    Report miscellaneous KPIs
    SA 5G Detach UE"1"
    Stop WTS
    ute_tshark.teardown_tshark

Start Tshark Packet Capturing
    [Documentation]    Captures SCTP traffic on eth3 and eth3 interface
    [Tags]    DESIGNSTEP
    ${tshark_logs}    Prepare Logs Directory Path    tshark/    with_timestamp=${FALSE}
    Setup Tshark    interface=eth3 eth4    log_dir=${tshark_logs}  log_name=eth3_eth4_sctp.pcap
    Start capturing  capture_filter=sctp
    Sleep    10s    reason=Ensure all essential packets has been captured

Establish NG link and check alarm 7107 is not visible
    [Tags]    DESIGNSTEP
    Start WTS    ${LUA_CONFIG}    check_version=False
    Check if BTS is OnAir
    Check if no alarm "7107"

Stop Tshark Packet Capturing
    [Tags]    DESIGNSTEP
    Sleep    10s    reason=Ensure all essential packets has been captured
    Stop Capturing

Check NG Setup flow
    [Tags]    DESIGNSTEP
    ${NG_SETUP_REQUEST}    ute_tshark.get_packets_count
    ...    packet_filter=ngap.NGSetupRequest_element
    ${NG_SETUP_RESPONSE}    ute_tshark.get_packets_count
    ...    packet_filter=ngap.NGSetupResponse_element
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${NG_SETUP_REQUEST}==${1}
    ...    msg=Number of NG_SETUP REQUESTS packet are not as expected. Number of counted requests: ${NG_SETUP_REQUEST}
    RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${NG_SETUP_RESPONSE}==${1}
    ...    msg=Number of NG_SETUP RESPONSE packets are not as expected. Number of counted responses: ${NG_SETUP_RESPONSE}

Start PDU"${pdu_id}" Session For UE"${ue_id}"
    [Tags]    DESIGNSTEP
    ${egate_cmd}    SET VARIABLE    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1 gw=1
    ${command_result}    ute_wtssim.execute_egate_command_and_wait_for_data
    ...    cmd=${egate_cmd}
    ...    timeout=${__EGATE_COMMAND_TIMEOUT___}

Verify DL NAS Transfer Messages
    [Tags]    DESIGNSTEP
    FOR    ${message}    IN    @{NAS_DL_MESSAGES}
        ${packets_count}    ute_tshark.get_packets_count    packet_filter=${message['filter']}
        RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${packets_count}>=${1}
        ...    msg=Amount of ${message['name']} (${packets_count}) is not equal to expected amount (1)
    END

Verify UL NAS Transfer Messages
    [Tags]    DESIGNSTEP
    FOR    ${message}    IN    @{NAS_UL_MESSAGES}
        ${packets_count}    ute_tshark.get_packets_count    packet_filter=${message['filter']}
        RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${packets_count}>=${1}
        ...    msg=Amount of ${message['name']} (${packets_count}) is not equal to expected amount (1)
    END

Unlock Xn Link Status And Check Status
    [Tags]    DESIGNSTEP
    Delta Commissisoning    ${DELTA_UNLOCK_XN}
    Verify Xn Link Status Is Available

Set MRL In Initial Context Setup And Trigger Xn Setup Request
    [Tags]    DESIGNSTEP
    ${command_amf_list_param}    CATENATE
    ...    amf_mobility_restriction_list_param
    ...    id=1
    ...    equiv_plmn=514:104
    ...    equiv_plmn=514:106
    ...    fa_plmn=123:124
    ...    forbidden_tacs=1,2,3
    ...    fa_plmn=123:125
    ...    forbidden_tacs=1,2,3
    ...    sa_plmn=514:106
    ...    allowed_tacs=52719,52720
    ${command_amf_ue}    SET VARIABLE    amf_ue_ics_param id=1 ue=1 mobility_restriction_list_id=1
    ute_wtssim.execute_egate_command
    ...    cmd=${command_amf_list_param}
    ...    timeout=${__EGATE_COMMAND_TIMEOUT___}
    ute_wtssim.execute_egate_command
    ...    cmd=${command_amf_ue}
    ...    timeout=${__EGATE_COMMAND_TIMEOUT___}

Perform HO Using A5 Event
    [Tags]    DESIGNSTEP
    ${command}    CATENATE
    ...    ue_measurement_send_nr
    ...    id=1 meas_id=2
    ...    index=0
    ...    nrs_result=101:101:0
    ...    event=A5 phycell_id=49
    ...    nrsrp_nr=30 srsrp_nr=11
    ...    srsrq_nr=11
    ute_wtssim.execute_egate_command_and_wait_for_data
    ...    cmd=${command}
    ...    timeout=${__EGATE_COMMAND_TIMEOUT___}
    SLEEP    10s

Verify Packet Flow If MRLC Is Received
    [Tags]    DESIGNSTEP
    FOR    ${message}    IN    @{NGAP_MESSAGES}    @{XNAP_MESSAGES}
        ${packets_count}    ute_tshark.get_packets_count    packet_filter=${message['filter']}
        RUN KEYWORD AND CONTINUE ON FAILURE    SHOULD BE TRUE    ${packets_count}>${0}
        ...    msg=Missing `${message['name']}` packets. Expected at least one.
    END

# -- internals --
Eth Interfaces
    Add Eth    ip=10.0.1.101    mask=24    interface=eth3    label=eth3:xn
    Add Eth    ip=10.0.1.102    mask=24    interface=eth3    label=eth3:ng

Check if no alarm "${alarm_id}"
    ute_admin_infomodel.query infomodel    every //ALARM-* is [alarmNumber!=${alarm_id}]    timeout=120

Verify Xn Link Status Is Available
    ute_admin_infomodel.query_infomodel    //XNLINK_R-1 is [xnLinkStatus=available]    timeout=300
