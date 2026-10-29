*** Settings ***
Documentation
...    = Author = Albert Sakowicz
...    _albert.sakowicz@nokia.com_
...    = Maintainer = Albert Sakowicz
...    _albert.sakowicz@nokia.com_
...    = Reviewer = Aleksandra Dagiel
...    _aleksandra.dagiel@nokia.com_
...    = Pre - Requirements =
...    _robotlte/config/<testline name>/__init__.py and site specific keyword_

*** Keywords ***
CRL26697_FeVe_02_Verify_the_behavior_of_first_heartbeat_receiving_SUSPENDED_GRANT
    [Documentation]    The purpose of this test case is to check if CBSD behavior is correct in case first
    ...                heartbeat response is suspended_grant.
    ...                Requirement ID: OM_GEN_SFS_CBRS.356

    ${sas_port}                  Set Variable    4433
    ${sas_version}               Set Variable    1
    &{expected_alarm}            Create Dictionary    fault_id=6825    fault_name=SAS Grant Suspension Failure    severity=Critical
    ${expected_alarms_objects}   Create Watchdog Alarm List    ${expected_alarm}
    Disable CBRS Feature On eNB
    Kill All SAS Processes
    Log To Console    Setting SAS to repond with 501 for heartbeat request
    ${sas_pid}    ${sas_log}   Start SAS Process    alias=default    port=${sas_port}    config=${CURDIR}/Data/SAS_Sim_suspend.conf
    ${start_time}   Get Time
    Enable CBRS Feature On eNB
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}
    Log To Console    CBRS enabled, waiting for alarms
    Wait For Watchdog Alarm Activation    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                   severity=${expected_alarm}[severity]    timeout=30
    Log To Console    Checking SAS log
    ${stop_time}   Get Time
    ${parsed_log_file}   Parse Sas Log File    log_file_name=${sas_log}
    ...                                          date_start=${start_time}
    ...                                          date_stop=${stop_time}
    ${grant_response}       Extract Values From Sas Log    log_name=${parsed_log_file}
    ...                                                      parameter=responseMessage
    ...                                                      data_type=grantResponse
    ${heartbeat_response}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...                                                      parameter=responseMessage
    ...                                                      data_type=heartbeatResponse
    ${grant_response_code}       Extract Values From Sas Log    log_name=${parsed_log_file}
    ...                                                           parameter=responseCode
    ...                                                           data_type=grantResponse
    ${heartbeat_response code}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...                                                           parameter=responseCode
    ...                                                           data_type=heartbeatResponse
    Should Be Equal               ${grant_response[0]}    CBSD request is approved by SAS
    Should Be Equal As Numbers    ${grant_response_code[0]}    0
    Should Be Equal               ${heartbeat_response[0]}    The grant is suspended
    Should Be Equal As Numbers    ${heartbeat_response_code[0]}    501

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures
