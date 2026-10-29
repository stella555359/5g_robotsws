*** Settings ***
Documentation
...    = Author =
...    _elzbieta.wlodarczyk@nokia.com_
...    = Maintainer =
...    _elzbieta.wlodarczyk@nokia.com_
...    = Reviewer =
...    lukasz.lechowicz@nokia.com
...    piotr.lukaszewicz@nokia.com
...    karol.sadowski@nokia.com
...    aleksandra.chudzik@nokia.com
...    Review link: http://l3-sim-krk-serv.dynamic.nsn-net.net/r/1282/

*** Keywords ***
CBRS_LTE3663_B_FeVe_41_ET_eNB_receives_failure_registration_response_with_reason_MISSING_PARAM
    [Documentation]    Tested Requirement: OAM_REQ_FMRECOV_1004

    ...                Purpose: The purpose of the test case is to verify that CBSD can be handled exactly when received
    ...                failure registration response with reason MISSING_PARAM
    ...                CBSD should stay in status unregistered, alarm SAS Registration Failure should be raised.
    ...                Test Steps:
    ...                1.Start SAS process
    ...                2.Check if CBSD status is 'Unregistered'
    ...                3.Check if alarm 6826 'SAS Registration Failure' is visible on eNB
    ...                4.Verify RegistrationResponse message with code 103 in SAS log

    &{mandatory_alarm}   Create Dictionary
    ...    fault_id=6826
    ...    fault_name=SAS Registration Failure
    ...    severity=Critical
    ...    reason=Register Exception with Reason: 103. ResponseMessage: One or more parameters have invalid value. ResponseData: resp_data.

    Log to Console    ${mandatory_alarm}
    Log To Console    Preconditions
    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    @{expected_alarms_objects}   Create Watchdog Alarm List    ${mandatory_alarm}
    Log To Console    Kill SAS if exists
    Kill All SAS Processes
    Check If Cells Are Disabled    enb_id=${enb_id}

    Log To Console    Step 1: Starting SAS Simulator with forced registration response code 103
    ${sas_pid}    ${sas_logs_dir}   Start SAS Process
    ...                               alias=default
    ...                               port=4433
    ...                               config=${CURDIR}/Data/Feve41/SAS_Sim.conf

    ${time_start}   Get Time
    Sleep    20s    #time buffor for exchange registration messages CBSD-SAS and catch proper unregistered state
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}

    Log To Console    Step 2: Checking if CBSD status id 'Unregistered'
    Wait Until Keyword Succeeds    30x    2s    Required CBSD Status Should Be Reached
    ...                                         expected_status=Unregistered
    ...                                         enb_id=${enb_id}

    Log To Console    Step 3: Checking expected alarms on eNB
    Wait For Watchdog Alarm Activation
    ...    fault_id=${mandatory_alarm['fault_id']}
    ...    fault_name=${mandatory_alarm['fault_name']}
    ...    severity=${mandatory_alarm['severity']}
    ...    reason=${mandatory_alarm['reason']}

    ${time_stop}   Get Time

    Log To Console    Step 4: Checking SAS log, verifing RegistrationResponse message with code 103
    ${parsed_log_file}   Parse Sas Log File    log_file_name=${sas_logs_dir}
    ...                                          date_start=${time_start}
    ...                                          date_stop=${time_stop}
    ${registration_response_code}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...                                                              parameter=responseCode
    ...                                                              data_type=registrationResponse

    Should Be Equal As Numbers    ${registration_response_code[0]}    103

    [Teardown]    Run Keywords
    ...    Get SAS Logs To Logs Dir    alias=default    AND
    ...    Stop Watchdog Alarm Detection And Check For Failures    AND
    ...    Kill All SAS Processes    AND
    ...    Check If Cells Are Disabled    enb_id=${enb_id}
