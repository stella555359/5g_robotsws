*** Settings ***
Documentation
...    = Author =
...    _karol.palamarz@nokia.com_
...    = Maintainer =
...    _piotr.lukaszewicz@nokia.com_
...    = Reviewer =
...    _artur.czainski@nokia.com_
...    _michal.moskala@nokia.com_
...    _lukasz.lechowicz@nokia.com_
...    = Summary =
...    This test checks if CBSD reports alarm EFaultId_SasRegistrationFailureAl with error code.
...    cbrsaVersion mismatch occurs between CBSD and SAS server.
...    By this case, after SasMessageRetryTimer, CBSD resend Registration Request.
...    This is done by triggering CBRS feature with proper SAS Sim configuration.
...    = Pre - Requirements =
...    _actCBRS flag is set to false_
...    _robotlte/config/<testline name>/__init__.py and site specific keyword_
...    = Additional Info =

*** Keywords ***
CBRS_LTE5703_FeVe_07_CBSD_receives_different_cbrsaVersion_from_SAS
    [Documentation]    Requirement: OM_GEN_SFS_CBRS.281
    Log To Console    ${\n}Step 1: Test preparation, setup environment
    ${enb_id}                      Set Variable    ${testlines.${testline_id}.enb_id}
    ${alias}                       Set Variable    RAT_1ST
    ${sas_new_config}              Set Variable    ${CURDIR}/Data/feve07/SAS_Sim_registration_request_07.conf
    ${registrationRequest}         Set Variable    ${CURDIR}/Data/feve07/registrationRequest.json
    ${registrationResponse}        Set Variable    ${CURDIR}/Data/feve07/registrationResponse.json
    ${deregistrationRequest}       Set Variable    ${CURDIR}/Data/feve07/deregistrationRequest.json
    ${deregistrationResponse}      Set Variable    ${CURDIR}/Data/feve07/deregistrationResponse.json
    ${registrationResponse_v1.2}   Set Variable    ${CURDIR}/Data/feve07/registrationResponse_cbrsaVersion.json
    &{expected_alarm_1}   Create Dictionary    fault_id=6832    fault_name=SAS Server Communication Failure    severity=Critical
    &{expected_alarm_2}   Create Dictionary    fault_id=6826    fault_name=SAS Registration Failure    severity=Critical
    ...                                          reason=cbrsaVersion conflicts between CBSD and SAS
    ${expected_alarms_list}      Create List    ${expected_alarm_1}    ${expected_alarm_2}
    ${expected_alarms_objects}   Create Watchdog Alarm List    ${expected_alarms_list}
    ${bts_side}   Set Variable    *
    Disable CBRS Feature On eNB
    Add ICG And CCG Group ID
    Kill All SAS Processes

    Log To Console    ${\n}Step 2: Enable CBRS feature flag, expecting CBSD registrationRequest and SAS registrationResponse
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}
    Enable CBRS Feature On eNB
    Wait Until BTS Is Not Busy
    ${first_registration_log_start}   Get Time
    ${sas_pid}    ${sas_log}   Start SAS Process    port=4433    config=${sas_new_config}
    Wait Until Keyword Succeeds    10x    10s    Required CBSD Status Should Be Reached    expected_status=Unregistered    enb_id=${enb_id}
    ${unreg_CBSD_IDs}   Get Unregistered CBSD IDs    ${enb_id}    ${bts_side}    ${alias}
    Wait For Watchdog Alarm Activation    fault_id=${expected_alarm_1}[fault_id]    fault_name=${expected_alarm_1}[fault_name]
    ...                                   severity=${expected_alarm_1}[severity]    timeout=60
    Wait For Watchdog Alarm Deactivation    fault_id=${expected_alarm_1}[fault_id]    fault_name=${expected_alarm_1}[fault_name]
    ...                                     severity=${expected_alarm_1}[severity]    timeout=60
    Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm_1}[fault_id]    fault_name=${expected_alarm_1}[fault_name]
    ...                                        severity=${expected_alarm_1}[severity]

    Log To Console    ${\n}Step 3: Getting data from Infomodel and prepare messages based on CBSD Unregistered state
    ${registration_requests_registered}   Create Registration Request Messages According to CBSD State
    ...    ${bts_side}    ${enb_id}    ${alias}    ${registrationRequest}    Unregistered
    ${response_messages_1.2}   Create Messages With Required CBSD State
    ...    ${bts_side}    ${enb_id}    ${alias}    ${registrationResponse_v1.2}    Unregistered
    ${deregistration_requests}   Create Messages With Required CBSD State
    ...    ${bts_side}    ${enb_id}    ${alias}    ${deregistrationRequest}    Unregistered
    ${deregistration_responses}   Create Messages With Required CBSD State
    ...    ${bts_side}    ${enb_id}    ${alias}    ${deregistrationResponse}    Unregistered
    ${re-registration_requests}   Create Registration Request Messages According to CBSD State
    ...    ${bts_side}    ${enb_id}    ${alias}    ${registrationRequest}    Unregistered
    ${re-registration_responses}   Create Registration Request Messages According to CBSD State
    ...    ${bts_side}    ${enb_id}    ${alias}    ${registrationResponse}    Unregistered

    Log To Console    ${\n}Step 4: Checking if FID:6826 (SAS Registration Failure) raised
    Wait For Watchdog Alarm Activation    fault_id=${expected_alarm_2}[fault_id]    fault_name=${expected_alarm_2}[fault_name]
    ...                                   severity=${expected_alarm_2}[severity]    reason=${expected_alarm_2}[reason]    timeout=60
    ${first_registration_log_stop}   Get Time

    Log To Console    ${\n}Step 5: Getting data from Infomodel and prepare messages based on CBSD Registered state
    ${second_registration_log_start}   Get Time
    ${registration_requests_unregistered}   Create Registration Request Messages According to CBSD State
    ...    ${bts_side}    ${enb_id}    ${alias}    ${registrationRequest}    Registered
    ${request_messages}   Create List    ${registration_requests_registered}    ${registration_requests_unregistered}
    ${response_messages_2.0}   Create Messages With Required CBSD State
    ...    ${bts_side}    ${enb_id}    ${alias}    ${registrationResponse}    Registered
    ${response_messages}   Create List    ${response_messages_1.2}    ${response_messages_2.0}

    Log To Console   ${\n}Step 6: Waiting for CBSD second registrationRequest with correct cbrsaVersion and checking if OnAir
    Wait Until Keyword Succeeds    10x    10s    Required CBSD Status Should Be Reached    expected_status=Registered    enb_id=${enb_id}
    Wait For All Cells To Be OnAir
    Wait Until Keyword Succeeds    5x    1min    Check If TS Version Is As Expected    ${enb_id}    ${alias}    2.0
    ${second_registration_log_stop}   Get Time
    Wait For Watchdog Alarm Deactivation    fault_id=${expected_alarm_2}[fault_id]    fault_name=${expected_alarm_2}[fault_name]
    ...                                     severity=${expected_alarm_2}[severity]    reason=${expected_alarm_2}[reason]    timeout=60
    Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm_2}[fault_id]    fault_name=${expected_alarm_2}[fault_name]
    ...                                        severity=${expected_alarm_2}[severity]    reason=${expected_alarm_2}[reason]

    Log To Console    ${\n}Step 7: Checking if second request was sent after specified 30s period
    ${first_parsed_log_file}   Parse Sas Log File    log_file_name=${sas_log}
    ...                                                date_start=${first_registration_log_start}
    ...                                                date_stop=${first_registration_log_stop}
    ${second_parsed_log_file}   Parse Sas Log File    log_file_name=${sas_log}
    ...                                                 date_start=${second_registration_log_start}
    ...                                                 date_stop=${second_registration_log_stop}
    ${first_registration_requests_lines}   Create List
    FOR    ${line}    IN    @{first_parsed_log_file}
        ${status}   Run Keyword And Return Status    Dictionary Should Contain Key    ${line}    registrationRequest
        IF  ${status}==True    Append To List    ${first_registration_requests_lines}    ${line}
    END
    ${first_registration_request}   Set Variable    ${first_registration_requests_lines[0]}
    ${first_registration_request_date}   Extract Values From Sas Log    log_name=${first_registration_request}    parameter=date
    ${second_registration_requests_lines}   Create List
    FOR    ${line}    IN    @{second_parsed_log_file}
        ${status}   Run Keyword And Return Status    Dictionary Should Contain Key    ${line}    registrationRequest
        IF  ${status}==True    Append To List    ${second_registration_requests_lines}    ${line}
    END
    ${second_registration_request}   Set Variable    ${second_registration_requests_lines[0]}
    ${second_registration_request_date}   Extract Values From Sas Log    log_name=${second_registration_request}    parameter=date
    ${time}   Subtract Date From Date    ${second_registration_request_date[0]}    ${first_registration_request_date[0]}
    ${time_string}   Convert To String    ${time}
    Should Be True    '${time_string}'=='30.0' or '${time_string}'=='31.0'

    Log To Console    ${\n}Step 8: Getting first registrationRequests from SAS_Sim.log and checking if messeges are correct
    ${first_registration_requests}   Get Messages From SAS Log
    ...    ${sas_log}    ${first_registration_log_start}    ${first_registration_log_stop}    registrationRequest
    FOR    ${line}    IN    @{request_messages[0]}
        Compare Messages    ${line}    ${first_registration_requests}
    END

    Log To Console    ${\n}Step 9: Getting second registrationRequests from SAS_Sim.log and checking if messeges are correct
    ${second_registration_requests}   Get Messages From SAS Log
    ...    ${sas_log}    ${second_registration_log_start}    ${second_registration_log_stop}    registrationRequest
    FOR    ${line}    IN    @{re-registration_requests}
        Compare Messages    ${line}    ${second_registration_requests}
    END

    Log To Console    ${\n}Step 12: Getting deregistration messages from SAS_Sim.log file and checking if messeges are correct
    ${deregistration_request}   Get Messages From SAS Log
    ...    ${sas_log}    ${first_registration_log_start}    ${first_registration_log_stop}    deregistrationRequest
    FOR    ${line}    IN    @{deregistration_requests}
        Compare Messages    ${line}    ${deregistration_request}
    END

    [Teardown]    Run Keywords    Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Delete ICG And CCG Group ID    AND
    ...                           Get SAS Logs To Logs Dir    alias=default
