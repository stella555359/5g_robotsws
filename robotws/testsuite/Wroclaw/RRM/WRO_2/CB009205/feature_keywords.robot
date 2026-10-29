*** Settings ***
Library      ta5g_egate
Library      ta5g_ue_mobility
Library      ta5g_pm_counters
Resource    ../keywords/tshark_verifying.robot
Variables    feature_variables.py

Documentation    Keywords for CB009205.

*** Variables ***
@{SGNB_ADDITION_FILTERS_WITH_A1_FILTERS}=    ${SGNB_ADDITION_REQUEST_FILTER}
...                                          ${UE_CONTEXT_SETUP_REQUEST_FILTER}
...                                          ${UE_CONTEXT_SETUP_RESPONSE_FILTER}
...                                          ${SGNB_ADDITION_REQUEST_ACKNOWLEDGE_FILTER}
...                                          ${SGNB_RECONFIGURATION_COMPLETE_FILTER}
...                                          ${SN_STATUS_TRANSFER_FILTER}

@{A4_CONFIGURATION_FILTERS}=      ${UE_CONTEXT_MODIFICATION_REQUEST__WITH_A4_FILTER}
...                               ${UE_CONTEXT_MODIFICATION_RESPONSE__WITH_MEAS_GAP_CONFIG_FILTER}
...                               ${SGNB_MODIFICATION_REQUIRED__WITH_A4_AND_MEAS_GAP_CONFIG_FILTER}
...                               ${SGNB_MODIFICATION_CONFIRM_FILTER}

*** Keywords ***
Wait Over Potential a4RetryTimer Period
    Sleep    15

Verify A1 Measurement Configuration For UE
    FOR  ${message_filter}    IN    @{SGNB_ADDITION_FILTERS_WITH_A1_FILTERS}
        Verify Tcpdump Log    ${message_filter}
    END

Verify A4 Measurement Absence For UE
    FOR  ${message_filter}    IN    @{A4_CONFIGURATION_FILTERS}
        Verify Tcpdump Log    ${message_filter}    number_of_messages=0
    END

Verify Counters For Robustness Purpose
    ${FETCHED_COUNTERS_FILE}=    Get Next Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55110C00034    1    X2_SGNB_ADD_REQ_REC
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...    file_path=${FETCHED_COUNTERS_FILE}
    Verify Any Counters In File
    ...    M55112C00002    1    X2_SGNB_ADD_REQ_ACK_SENT
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${FETCHED_COUNTERS_FILE}

Set Internal Traffic Type To UE
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
