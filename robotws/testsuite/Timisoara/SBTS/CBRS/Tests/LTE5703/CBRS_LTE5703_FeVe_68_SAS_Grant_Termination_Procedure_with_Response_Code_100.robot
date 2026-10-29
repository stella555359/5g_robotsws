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
...   The purpose of this test is to verify whether Termination Procedure fullfills
...    requirements of modified behavior. This scenario simulates procedure where Response code: 100 is received.
...    As a result, deregistration is started.

*** Keywords ***
CBRS_LTE5703_FeVe_68_SAS_Grant_Termination_Procedure_with_Response_Code_100
    [Documentation]    SFS/CFAMrequirement: OM_GEN_SFS_CBRS.380

    Log To Console    Setting variables and getting environment ready
    ${alias}   Set Variable    RAT_1ST
    &{expected_alarm}   Create Dictionary    fault_id=6828    fault_name=SAS Grant Failure    severity=Critical
    ...                                        reason=Grant Exception with Reason: 100.
    ${expected_alarms_objects}   Create Watchdog Alarm List    ${expected_alarm}
    Disable CBRS Feature On eNB
    Kill All SAS Processes
    ${sw_info}   Get Software Info    connection=${alias}
    ${sw_build}   Get From Dictionary    ${sw_info}    Active SW version
    ${sw_ver}   Fetch From Left    ${sw_build}    _
    ${sas_sim_conf}   Set Variable If    '${sw_ver}'=='SBTS21A' or '${sw_ver}'=='SBTS20C'    SAS_Sim_68_SBTS21A.conf    SAS_Sim.conf
    Log To Console    Setting SAS to repond with 500 for 2nd heartbeat request and code 100 for 2nd grant request
    ${sas_pid}    ${sas_log}   Start SAS Process    config=${CURDIR}/Data/FeVe_68/SAS_Sim.conf
    ${start_time}   Get Time
    Wait Until BTS Is Not Busy
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
    Log To Console    Grant is terminated after 2nd heartbeat and grantResponse has code 100 so deregistration process starts
    Log To Console    Parsing SAS log...
    ${stop_time}   Get Time
    ${parsed_log_file}   Parse Sas Log File    log_file_name=${sas_log}
    ...                                          date_start=${start_time}
    ...                                          date_stop=${stop_time}

    ${grant_request_amount}   Run    grep -i 'grantrequest' ${sas_log} | wc -l
    ${heartbeats_with_termination}   Run    grep '"responseCode": 500' ${sas_log} | wc -l
    ${heartbeats_with_termination_MSG}   Run    grep '"The grant is terminated"' ${sas_log}
    Log To Console    Heartbeats with termination message: ${heartbeats_with_termination_MSG}
    ${deregistrationRequest_amount}   Run    grep -i 'deregistrationRequest' ${sas_log} | wc -l
    ${grantResponse_100_amount}   Run    grep -i '"responseCode": 100' ${sas_log} | wc -l
    ${deregistrationResponse_amount}   Run    grep -i 'deregistrationResponse' ${sas_log} | wc -l

    Log To Console    Amount of grantRequests: ${grant_request_amount}
    Log To Console    Amount of terminated grants: ${heartbeats_with_termination}
    Log To Console    Amount of grantResponse: ${grantResponse_100_amount}
    Log To Console    Amount of deregistrationRequest: ${deregistrationRequest_amount}
    Log To Console    Amount of deregistrationResponse: ${deregistrationResponse_amount}

    IF  ${SUM_OF_CBSDS}==3
        Should Be Equal As Numbers    ${grant_request_amount}    5
    ELSE
        Should Be Equal As Numbers    ${grant_request_amount}    3
    END
    Should Be Equal As Numbers    ${heartbeats_with_termination}    1
    Should Be Equal As Numbers    ${grantResponse_100_amount}    1
    Should Be Equal As Numbers    ${deregistrationRequest_amount}    1
    Should Be Equal As Numbers    ${deregistrationResponse_amount}    1

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           BTS Operational State Should Be OnAir    alias=${alias}    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures
