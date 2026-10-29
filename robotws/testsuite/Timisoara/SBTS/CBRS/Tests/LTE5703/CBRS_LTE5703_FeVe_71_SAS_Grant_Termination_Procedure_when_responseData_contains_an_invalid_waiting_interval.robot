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
...    The purpose of this test is to verify whether Termination Procedure fullfills
...    requirements of modified behavior. This scenario simulates procedure where invalid waiting interval is received.

*** Keywords ***
CBRS_LTE5703_FeVe_71_SAS_Grant_Termination_Procedure_when_responseData_contains_an_invalid_waiting_interval
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
    ${sas_sim_conf}   Set Variable If    '${sw_ver}'=='SBTS21A' or '${sw_ver}'=='SBTS20C'    SAS_Sim_71_SBTS21A.conf    SAS_Sim.conf
    Log To Console    Setting SAS to repond with 500 for 2nd heartbeat request and code 106 for 2nd grant request
    ${sas_pid}    ${sas_log}   Start SAS Process    config=${CURDIR}/Data/FeVe_71/SAS_Sim.conf
    Wait Until BTS Is Not Busy
    ${time_start}   Get Time
    Enable CBRS Feature On eNB
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}
    Log To Console    CBRS enabled, waiting to get onair
    Wait For Watchdog Alarm Activation    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                   severity=${expected_alarm}[severity]    reason=${expected_alarm}[reason]    timeout=30
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
    Log To Console    ${heartbeats_with_termination_MSG}
    ${deregistrationRequest_amount}   Run    grep -i 'deregistrationRequest' ${sas_log} | wc -l
    ${grantResponse_106_amount}   Run    grep -i '"responseCode": 106' ${sas_log} | wc -l
    ${deregistrationResponse_amount}   Run    grep -i 'deregistrationResponse' ${sas_log} | wc -l

    Check If Grant Request Is Re-send After Code:106 In Given Time
    ...    waiting_interval=${30}    logs_path=${sas_log}    time_start=${time_start}    time_stop=${time_stop}

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

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           BTS Operational State Should Be OnAir    alias=${alias}    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures
