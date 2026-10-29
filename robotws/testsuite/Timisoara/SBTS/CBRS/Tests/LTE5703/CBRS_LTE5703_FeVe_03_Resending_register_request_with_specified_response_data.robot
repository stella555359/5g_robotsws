*** Settings ***
Documentation
...    = Author = Karol Palamarz
...    _karol.palamarz@nokia.com_
...    = Maintainer =
...    _piotr.lukaszewicz@nokia.com_
...    = Reviewer =
...    _artur.czainski@nokia.com_
...    _michal.moskala@nokia.com_
...    _lukasz.lechowicz@nokia.com_
...    = Summary =
...    This Test Case checks if CBSD Registration Procedure to SAS v2 fails after receiving responseCode 106 from SAS and
...    resends registration request message after the time specified in responseData.
...    = Pre - Requirements =
...    _actCBRS flag is set to false_
...    _robotlte/config/<testline name>/__init__.py and site specific keyword_
...    _cbrsaGroupType parameters should be configured for both group types ICG and CCG
...    = Additional Info =

*** Keywords ***
CBRS_LTE5703_FeVe_03_Resending_register_request_with_specified_response_data
    [Documentation]    Requirement: OM_GEN_SFS_CBRS.281

    Log To Console    ${\n}Step 1: Test preparation, setup environment
    ${enb_id}                     Set Variable    ${testlines.${testline_id}.enb_id}
    ${alias}                      Set Variable    RAT_1ST
    ${sas_new_config}             Set Variable    ${CURDIR}/Data/feve03/SAS_Sim_registration_request_03.conf
    ${registrationRequest}        Set Variable    ${CURDIR}/Data/feve03/registrationRequest.json
    ${registrationResponse}       Set Variable    ${CURDIR}/Data/feve03/registrationResponse.json
    ${registrationResponse_106}   Set Variable    ${CURDIR}/Data/feve03/registrationResponse_106.json
    &{expected_alarm}             Create Dictionary    fault_id=6826    fault_name=SAS Registration Failure    severity=Critical
    ...    reason=Register Exception with Reason: 106. ResponseMessage: Do not contact SAS for the time being. ResponseData: 60.
    ${expected_alarms_objects}    Create Watchdog Alarm List    ${expected_alarm}
    ${bts_side}   Set Variable    *

    Synchronize Time Between VM And eNB In Case Of Difference
    Disable CBRS Feature On eNB
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}
    Wait Until BTS Is Not Busy
    Add ICG And CCG Group ID
    Wait Until BTS Is Not Busy
    Kill All SAS Processes
    ${first_registration_log_start}   Get Time
    ${sas_pid}    ${sas_log}   Start SAS Process    config=${sas_new_config}

    Log To Console    Step 2: Enable CBRS feature, expecting CBSD registrationRequest and Response with code 106, checking alarms and CBSD status
    Wait Until Keyword Succeeds    10x    10s    Required CBSD Status Should Be Reached    expected_status=Unregistered    enb_id=${enb_id}
    Enable CBRS Feature On eNB
    Wait For Watchdog Alarm Activation    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                   severity=${expected_alarm}[severity]    reason=${expected_alarm}[reason]    timeout=90
    ${unreg_CBSD_IDs}   Get Unregistered CBSD IDs    ${enb_id}    ${bts_side}    ${alias}
    ${first_registration_log_stop}   Get Time

    Log To Console    Step 3: Getting data from Infomodel and waiting for second registrationRequest and SAS registrationResponse with code 0
    ${second_registration_log_start}   Get Time
    ${request_message_unreg}   Create Registration Request Messages According to CBSD State
    ...    ${bts_side}    ${enb_id}    ${alias}    ${registrationRequest}    Unregistered
    ${response_message_106_unreg}   Create Registration Response Messages With Error Code
    ...    ${bts_side}    ${enb_id}    ${alias}    ${registrationResponse_106}    Unregistered    60
    ${response_message_0_unreg}   Create Messages With Required CBSD State
    ...    ${bts_side}    ${enb_id}    ${alias}    ${registrationResponse}    Unregistered
    Wait Until Keyword Succeeds    10x    10s    Required CBSD Status Should Be Reached    expected_status=Registered    enb_id=${enb_id}
    Wait For Watchdog Alarm Deactivation    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                     severity=${expected_alarm}[severity]    reason=${expected_alarm}[reason]    timeout=90
    Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                        severity=${expected_alarm}[severity]    reason=${expected_alarm}[reason]
    Wait For All Cells To Be OnAir
    Wait Until Keyword Succeeds    5x    1min    Check If TS Version Is As Expected    ${enb_id}    ${alias}    2.0
    ${second_registration_log_stop}   Get Time
    ${request_message_reg}   Create Registration Request Messages According to CBSD State
    ...    ${bts_side}    ${enb_id}    ${alias}    ${registrationRequest}    Registered
    ${request_message}   Create List    ${request_message_reg}    ${request_message_unreg}
    ${response_message_0_reg}   Create Messages With Required CBSD State
    ...    ${bts_side}    ${enb_id}    ${alias}    ${registrationResponse}    Registered
    ${response_message}   Create List    ${response_message_106_unreg}    ${response_message_0_reg}

    Log To Console    ${\n}Step 4: Checking if second request was sent after specified 60s period
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
    Should Be True    '${time_string}'=='60.0' or '${time_string}'=='61.0' or '${time_string}'=='59.0'

    Log To Console    ${\n}Step 5: Getting first registrationRequests from SAS_Sim.log and checking if messeges are correct
    ${first_registration_requests}   Get Messages From SAS Log
    ...    ${sas_log}    ${first_registration_log_start}    ${first_registration_log_stop}    registrationRequest
    FOR    ${line}    IN    @{request_message[0]}
        Compare Messages    ${line}    ${first_registration_requests}
    END

    Log To Console    ${\n}Step 6: Getting second registrationRequests from SAS_Sim.log and checking if messeges are correct
    ${second_registration_requests}   Get Messages From SAS Log
    ...    ${sas_log}    ${first_registration_log_start}    ${first_registration_log_stop}    registrationRequest
    FOR    ${line}    IN    @{request_message[0]}
        Compare Messages    ${line}    ${second_registration_requests}
    END

    [Teardown]    Run Keywords    Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Wait Until BTS Is Not Busy    AND
    ...                           Delete ICG And CCG Group ID    AND
    ...                           Get SAS Logs To Logs Dir    alias=default
