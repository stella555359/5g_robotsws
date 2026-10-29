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
...    Check if CBSD Registration Procedure to SAS v2 fails after receiving responseCode 106 from SAS and resends
...    registration request message after the default time (30s) specified in SW. Scenario:
...        1. Prepare Environment
...        2. Enable CBRS feature flag and wait for expected registrationResponse with code 106
...        3. Wait for CBSD second registrationResponse with code 0, check if OnAir and no alarms
...        4. Check if period between registrationRequests is 30s

*** Keywords ***
CBRS_LTE5703_FeVe_04_Resending_register_request_without_response_data
    [Documentation]    Requirement: OM_GEN_SFS_CBRS.281
    Log To Console    Step 1: Test preparation, setup environment
    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${alias}   Set Variable    RAT_1ST
    ${sas_new_config}   Set Variable    ${CURDIR}/Data/feve04/SAS_Sim_registration_request_04.conf
    &{expected_alarm_1}   Create Dictionary    fault_id=6832    fault_name=SAS Server Communication Failure    severity=Critical
    &{expected_alarm_2}   Create Dictionary    fault_id=6826    fault_name=SAS Registration Failure    severity=Critical
    ...    reason=Register Exception with Reason: 106. ResponseMessage: Do not contact SAS for the time being. ResponseData: .
    ${expected_alarms_list}   Create List    ${expected_alarm_1}    ${expected_alarm_2}
    ${expected_alarms_objects}   Create Watchdog Alarm List    ${expected_alarms_list}
    ${bts_side}   Set Variable    *
    Disable CBRS Feature On eNB
    Kill All SAS Processes
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}
    Add ICG And CCG Group ID

    Log To Console    Step 2: Enable CBRS feature flag, expecting CBSD registrationRequest and SAS registrationResponse with code 106
    ${first_registration_log_start}   Get Time
    Enable CBRS Feature On eNB
    ${sas_pid}    ${sas_log}   Start SAS Process    port=4433    config=${sas_new_config}
    Wait Until Keyword Succeeds    10x    10s    Required CBSD Status Should Be Reached    expected_status=Unregistered    enb_id=${enb_id}
    ${unreg_CBSD_IDs}   Get Unregistered CBSD IDs    ${enb_id}    ${bts_side}    ${alias}
    Wait For Watchdog Alarm Activation    fault_id=${expected_alarm_1}[fault_id]    fault_name=${expected_alarm_1}[fault_name]
    ...                                   severity=${expected_alarm_1}[severity]    timeout=60
    Wait For Watchdog Alarm Deactivation    fault_id=${expected_alarm_1}[fault_id]    fault_name=${expected_alarm_1}[fault_name]
    ...                                     severity=${expected_alarm_1}[severity]    timeout=60
    Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm_1}[fault_id]    fault_name=${expected_alarm_1}[fault_name]
    ...                                        severity=${expected_alarm_1}[severity]
    Wait For Watchdog Alarm Activation    fault_id=${expected_alarm_2}[fault_id]    fault_name=${expected_alarm_2}[fault_name]
    ...                                   severity=${expected_alarm_2}[severity]    reason=${expected_alarm_2}[reason]    timeout=60
    ${first_registration_log_stop}   Get Time

    Log To Console    Checking if first registrationResponse contains responceCode 106
    ${first_parsed_log_file}   Parse Sas Log File    log_file_name=${sas_log}
    ...                                                date_start=${first_registration_log_start}
    ...                                                date_stop=${first_registration_log_stop}

    ${registrationResponse_responseCode}   Extract Values From Sas Log    log_name=${first_parsed_log_file}
    ...                                                                     parameter=response
    ...                                                                     data_type=registrationResponse
    ...                                                                     start_from=registrationRequest

    ${responseCode}   Get From Dictionary    ${registrationResponse_responseCode[0]}    responseCode
    Should Be Equal As Integers    ${responseCode}    106
    ...    msg=Can't find responseCode equals to 106 inside SAS Sim log file

    Log To Console    Step 3: Wait for CBSD second registrationRequest and registrationResponse with code 0, checking if OnAir and no alarms
    ${second_registration_log_start}   Get Time
    Wait Until Keyword Succeeds    10x    10s    Required CBSD Status Should Be Reached    expected_status=Registered    enb_id=${enb_id}
    Wait For All Cells To Be OnAir
    Wait Until Keyword Succeeds    5x    1min    Check If TS Version Is As Expected    ${enb_id}    ${alias}    2.0
    ${second_registration_log_stop}   Get Time
    Wait For Watchdog Alarm Deactivation    fault_id=${expected_alarm_2}[fault_id]    fault_name=${expected_alarm_2}[fault_name]
    ...                                     severity=${expected_alarm_2}[severity]    reason=${expected_alarm_2}[reason]    timeout=60
    Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm_2}[fault_id]    fault_name=${expected_alarm_2}[fault_name]
    ...                                        severity=${expected_alarm_2}[severity]    reason=${expected_alarm_2}[reason]

    Log To Console    Step 4: Checking if second Registration request was sent after specified 30s period
    ${second_parsed_log_file}   Parse Sas Log File    log_file_name=${sas_log}
    ...                                                 date_start=${second_registration_log_start}
    ...                                                 date_stop=${second_registration_log_stop}

    ${first_registrationRequest_date}   Extract Values From Sas Log    log_name=${first_parsed_log_file}
    ...                                                                  parameter=date
    ...                                                                  start_from=registrationRequest

    ${second_registrationRequest_date}   Extract Values From Sas Log    log_name=${second_parsed_log_file}
    ...                                                                   parameter=date
    ...                                                                   start_from=registrationRequest

    ${time_between_requests}   Subtract Date From Date    ${second_registrationRequest_date[0]}    ${first_registrationRequest_date[0]}
    Should Be True    ${time_between_requests}==${30} or ${time_between_requests}==${31}
    ...    msg=Second registrationRequest occured after ${time_between_requests}s rather than 30s after first one

    [Teardown]    Run Keywords    Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Delete ICG And CCG Group ID    AND
    ...                           Get SAS Logs To Logs Dir    alias=default
