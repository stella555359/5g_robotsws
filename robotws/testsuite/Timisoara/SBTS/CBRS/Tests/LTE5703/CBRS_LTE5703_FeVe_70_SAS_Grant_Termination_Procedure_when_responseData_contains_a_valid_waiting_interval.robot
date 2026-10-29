*** Settings ***
Documentation
...    = Author = Aleksandra Dagiel
...    _aleksandra.dagiel@nokia.com_
...    = Maintainer =
...    _aleksandra.chudzik@nokia.com_
...    = Reviewer =
...    _karol.palamarz@nokia.com_
...    = Pre - Requirements =
...    _robotlte/config/<testline name>/__init__.py and site specific keyword_
...    = Summary =
...    The purpose of this test is to verify whether whether eNB is able to react properly
...    when recives "DeregistrationResponse" with Response Code: 106 and at the same time responseData is valid.
...    UPDATE: Test case checks also grant termination modification introduced in LTE5659.

*** Keywords ***
CBRS_LTE5703_FeVe_70_SAS_Grant_Termination_Procedure_when_responseData_contains_a_valid_waiting_interval
    [Documentation]    SFS/CFAMrequirement: OM_GEN_SFS_CBRS.380

    Log To Console    Setting variables and getting environment ready
    ${alias}   Set Variable    RAT_1ST
    &{expected_alarm}   Create Dictionary    fault_id=6828    fault_name=SAS Grant Failure    severity=Critical
    ...    reason=Grant Exception with Reason: 106. ResponseMessage: Do not contact SAS for the time being.
    ${expected_alarms_objects}   Create Watchdog Alarm List    ${expected_alarm}
    Disable CBRS Feature On eNB
    Kill All SAS Processes
    ${sw_info}   Get Software Info    connection=${alias}
    ${sw_build}   Get From Dictionary    ${sw_info}    Active SW version
    ${sw_ver}   Fetch From Left    ${sw_build}    _
    ${sas_sim_conf}   Set Variable If    '${sw_ver}'=='SBTS21A' or '${sw_ver}'=='SBTS20C'    SAS_Sim_70_SBTS21A.conf    SAS_Sim.conf
    Log To Console    Setting SAS to repond with 500 for 2nd heartbeat request and code 106 for 2nd grant request
    ${sas_pid}    ${sas_log}   Start SAS Process    config=${CURDIR}/Data/FeVe_70/SAS_Sim.conf
    Wait Until BTS Is Not Busy
    ${time_start}   Get Time
    Enable CBRS Feature On eNB
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}
    Log To Console    CBRS enabled, waiting to get onair
    Wait For Watchdog Alarm Activation    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                   severity=${expected_alarm}[severity]    reason=${expected_alarm}[reason]    timeout=120
    Wait For All Cells To Be OnAir
    BTS Operational State Should Be OnAir
    Wait For Watchdog Alarm Deactivation    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                     severity=${expected_alarm}[severity]    reason=${expected_alarm}[reason]    timeout=30
    Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                        severity=${expected_alarm}[severity]    reason=${expected_alarm}[reason]
    Log To Console    Grant is terminated after 2nd heartbeat and when asking for new grant grantResponse has code 106
    ${time_stop}   Get Time

    ${grant_request_amount}   Run    grep -i 'grantrequest' ${sas_log} | wc -l
    ${heartbeats_with_termination}   Run    grep '"responseCode": 500' ${sas_log} | wc -l
    ${heartbeats_with_termination_MSG}   Run    grep '"The grant is terminated"' ${sas_log}
    Log To Console    Heartbeats with termination message: ${heartbeats_with_termination_MSG}
    ${deregistrationRequest_amount}   Run    grep -i 'deregistrationRequest' ${sas_log} | wc -l
    ${grantResponse_106_amount}   Run    grep -i '"responseCode": 106' ${sas_log} | wc -l
    ${deregistrationResponse_amount}   Run    grep -i 'deregistrationResponse' ${sas_log} | wc -l

    Check If Grant Request Is Re-send After Code:106 In Given Time
    ...    waiting_interval=${20}    logs_path=${sas_log}    time_start=${time_start}    time_stop=${time_stop}
    Log To Console    Amount of grantRequests: ${grant_request_amount}
    Log To Console    Amount of terminated grants with code 500: ${heartbeats_with_termination}
    Log To Console    Amount of grantResponse with code 106: ${grantResponse_106_amount}
    Log To Console    Amount of deregistrationRequest: ${deregistrationRequest_amount}
    Log To Console    Amount of deregistrationResponse: ${deregistrationResponse_amount}

    IF  ${SUM_OF_CBSDS}==3
        Should Be Equal As Numbers    ${grant_request_amount}    5
    ELSE
        Should Be Equal As Numbers    ${grant_request_amount}    3
    END
    Should Be Equal As Numbers    ${heartbeats_with_termination}    1
    Should Be Equal As Numbers    ${grantResponse_106_amount}    1
    Should Be Equal As Numbers    ${deregistrationRequest_amount}    0
    Should Be Equal As Numbers    ${deregistrationResponse_amount}    0

    ${parsed_log_file}   Parse Sas Log File    log_file_name=${sas_log}    date_start=${time_start}     date_stop=${time_stop}
    ${grantId_list}   Extract Values From Sas Log
    ...    log_name=${parsed_log_file}    parameter=grantId    data_type=grantResponse    start_from=heartbeatResponse
    Should Be Equal As Strings    ${grantId_list[0]}    3550000000_3560000000

    ${spectrum_inquiry_request_amount}   Run    grep -i 'spectrumInquiryRequest' ${sas_log} | wc -l
    ${spectrum_inquiry_response_amount}   Run    grep -i '"spectrumInquiryResponse"' ${sas_log} | wc -l

    Log To Console    Amount of spectrumInquiryRequest: ${spectrum_inquiry_request_amount}
    Log To Console    Amount of spectrumInquiryResponse: ${spectrum_inquiry_response_amount}

    Should Be True    '${spectrum_inquiry_request_amount}'=='1' or '${spectrum_inquiry_request_amount}'=='2'
    Should Be True    '${spectrum_inquiry_response_amount}'=='1' or '${spectrum_inquiry_response_amount}'=='2'

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           BTS Operational State Should Be OnAir    alias=${alias}    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures

Check If Grant Request Is Re-send After Code:106 In Given Time
    [Arguments]    ${waiting_interval}    ${logs_path}    ${time_start}    ${time_stop}

    ${parsed_log_file}   Parse Sas Log File    log_file_name=${logs_path}
    ...                                          date_start=${time_start}
    ...                                          date_stop=${time_stop}
    ${grantrequest_date}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...                                                     parameter=date
    ...                                                     data_type=grantRequest
    ...                                                     skip_packets=2
    ${grantresponse106_date}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...                                                         parameter=date
    ...                                                         data_type=grantResponse
    ...                                                         skip_packets=1
    ...                                                         packet_amount=2

    @{request_time_list}   Create List

    ${grantrequest_date}   Convert To String    ${grantrequest_date}
    ${grantresponse106_date}   Convert To String    ${grantresponse106_date}

    ${req_msg_time_regex}    Get Regexp Matches    string=${grantrequest_date}    pattern=(\\d\\d:\\d\\\d:\\d\\d)
    ${request_time_list}    Combine Lists    ${request_time_list}    ${req_msg_time_regex}
    Log To Console    grantRequest messages time: ${request_time_list}

    @{response_code106_time_list}   Create List

    ${resp_msg_time_regex}   Get Regexp Matches    string=${grantresponse106_date}    pattern=(\\d\\d:\\d\\\d:\\d\\d)
    ${response_code106_time_list}   Combine Lists    ${response_code106_time_list}    ${resp_msg_time_regex}
    Log To Console    grantResponse with code 106 message time: ${response_code106_time_list}

    ${time_diff}   Subtract Time From Time    ${request_time_list[0]}    ${response_code106_time_list[0]}
    ${time_diff}   Convert To Integer    ${time_diff}
    Log To Console    Difference in seconds between messages: ${time_diff}

    Should Be True    ${time_diff}==${waiting_interval} or ${time_diff}==${waiting_interval+${1}} or ${time_diff}==${waiting_interval+${2}}
    ...   msg=Grant Response with code 106 occured after: ${time_diff} s!
