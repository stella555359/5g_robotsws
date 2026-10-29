*** Settings ***
Documentation
...    = Author = Aleksandra Dagiel
...    _aleksandra.dagiel@nokia.com_
...    = Maintainer =
...    _aleksandra.chudzik@nokia.com_
...    = Reviewer =
...    _artur.czainski@nokia.com_
...    _karol.palamarz@nokia.com_
...    = Pre - Requirements =
...    _robotlte/config/<testline name>/__init__.py and site specific keyword_

*** Keywords ***
CBRS_LTE5703_FeVe_56_SAS_sends_DeregistrationResponse_with_Response_Code_106_and_responseData_is_valid
    [Documentation]    The purpose of this test is to verify whether whether eNB initiates deregistration of CBSD
    ...                and reacts properly for successful Deregistration Response from SAS.
    ...    Tested Requirement: OM_GEN_SFS_CBRS.353, OM_GEN_SFS_CBRS.372
    [Timeout]   15min
    Start Capturing Historical Alarms
    @{allowed_alarms}   Set Variable    ${enb_allowed_alarms}
    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    @{expected_alarms}   Create List    SAS Server Communication Failure    SAS Registration Failure    SAS Spectrum Deregistration Failure

    Disable CBRS Feature On eNB
    Kill All SAS Processes
    Check If Cells Are Disabled    ${enb_id}
    Log    Setting SAS to repond with 106 for 2nd deregistration attempt with valid waiting interval    console=true
    ${sas_pid}    ${sas_log}   Start SAS Process    config=${CURDIR}/Data/FeVe_56/SAS_Sim.conf
    Wait Until BTS Is Not Busy
    Enable CBRS Feature On eNB
    Log    CBRS enabled, waiting to get onair    console=true
    Wait Until Keyword Succeeds    10x    10s    Admin Alarms Get And Check
    ...                                          mandatory=${EMPTY}
    ...                                          allowed=${allowed_alarms}
    ...                                          alias=RAT_1ST
    Wait For All Cells To Be OnAir
    BTS Operational State Should Be OnAir

    Log    Changing antennaGain parameter to force deregistration  console=true
    Wait Until BTS Is Not Busy
    Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${enb_id}/LNBTS-${enb_id}/CBSD-1
    ...    parameter=antennaGain
    ...    operation=update
    ...    value=8
    ...    connection=RAT_1ST
    Log    Checking if FID:6831 is present    console=true
    #an alarm can not appear if deregistration and re-registration is too short- it's not PR: same reason as in PR513925
    @{mandatory_alarms}  Create List   {'faultId': '6831', 'faultName': 'SAS Spectrum Deregistration Failure', 'severity': 'Warning'}
    Wait Until Keyword Succeeds    10x    10s    Admin Alarms Get And Check
    ...                                          mandatory=@{mandatory_alarms}
    ...                                          allowed=${allowed_alarms}
    ...                                          alias=RAT_1ST
    Log    Checking if eNB is OnAir  console=true
    Wait For All Cells To Be OnAir
    Sleep    60s

    Log   Grepping needed messages from SAS_Sim.log    console=true
    ${deregistrationRequest_amount}   Run    grep -i '"deregistrationRequest"' ${sas_log} | wc -l
    ${deregistration_code106_amount}   Run    grep -i '"responseCode": 106' ${sas_log} | wc -l
    ${deregistrationResponse_amount}   Run    grep -i '"deregistrationResponse"' ${sas_log} | wc -l
    ${registrationRequest_amount}   Run    grep -i '"registrationRequest"' ${sas_log} | wc -l
    ${registrationResponse_amount}   Run    grep -i '"registrationResponse"' ${sas_log} | wc -l

    Log    Amount of registrationRequests: ${registrationRequest_amount}    console=true
    Log    Amount of registrationResponse: ${registrationResponse_amount}    console=true
    Log    Amount of deregistrationRequest: ${deregistrationRequest_amount}    console=true
    Log    Amount of deregistrationResponse with code 106: ${deregistration_code106_amount}    console=true
    Log    Amount of deregistrationResponse: ${deregistrationResponse_amount}    console=true

    IF  ${SUM_OF_CBSDS}==3
        Should Be Equal As Numbers    ${registrationRequest_amount}   4
    ELSE
        Should Be Equal As Numbers    ${registrationRequest_amount}    2
    END
    IF  ${SUM_OF_CBSDS}==3
        Should Be Equal As Numbers    ${registrationResponse_amount}    4
    ELSE
        Should Be Equal As Numbers    ${registrationResponse_amount}    2
    END
    Should Be Equal As Numbers    ${deregistrationRequest_amount}    2
    Should Be Equal As Numbers    ${deregistration_code106_amount}    1
    Should Be Equal As Numbers    ${deregistrationResponse_amount}    2

    Check If Termination Request Is Re-send After Code:106 In Given Time    waining_interval=20    logs_path=${sas_log}
    Log   Scenario passed!    console=true

    [Teardown]    Run Keywords    Wait Until BTS Is Not Busy    AND
    ...                           Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Perform Parameter Recommissioning
    ...                           dist_name=MRBTS-${enb_id}/LNBTS-${enb_id}/CBSD-1
    ...                           parameter=antennaGain
    ...                           operation=update
    ...                           value=0
    ...                           alias=RAT_1ST    AND
    ...                           Save And Check Historical Alarms    expected_alarms=@{expected_alarms}


Check If Termination Request Is Re-send After Code:106 In Given Time
    [Arguments]    ${waining_interval}    ${logs_path}
    ${SAS_logs}   OperatingSystem.Get File    ${logs_path}
    ${deregistration_request_msg_regex}   Get Regexp Matches    string=${SAS_logs}
    ...    pattern=\"deregistrationRequest.*\n.*received CBSD deregistration request
    @{request_time_list}   Create List
    FOR    ${request}    IN    @{deregistration_request_msg_regex}
        ${req_msg_time_regex}   Get Regexp Matches   string=${request}    pattern=(\\d\\d:\\d\\\d:\\d\\d)
        ${request_time_list}   Combine Lists  ${request_time_list}    ${req_msg_time_regex}
    END
    Log    deregistrationRequest messages time: ${request_time_list}    console=true

    ${deregistration_response_code_106_msg_regex}   Get Regexp Matches    string=${SAS_logs}
    ...    pattern=\\"deregistrationResponse\\".*\\"responseCode\\"\\: 106.*\\n.*
    @{response_code106_time_list}   Create List
    FOR    ${response}    IN    @{deregistration_response_code_106_msg_regex}
        ${resp_msg_time_regex}    Get Regexp Matches   string=${response}    pattern=(\\d\\d:\\d\\\d:\\d\\d)
        ${response_code106_time_list}   Combine Lists  ${response_code106_time_list}    ${resp_msg_time_regex}
    END
    Log    deregistrationResponse with code 106 message time: ${response_code106_time_list}    console=true

    @{timestamp_list}    Create List
    FOR    ${deregistration_request_time}    IN    @{request_time_list}
        ${time_diff}   Subtract Time From Time    ${response_code106_time_list[0]}    ${deregistration_request_time}
        ${time_diff_string}   Convert To String    ${time_diff}
        Append To List    ${timestamp_list}    ${time_diff_string}
    END
    Log    Difference in seconds between messages: @{timestamp_list}    console=true
    Log    Difference should contain ${waining_interval} seconds between code:106 and re-sent deregistration_request    console=true

    Should Contain Any    ${timestamp_list}    ${waining_interval}.0

