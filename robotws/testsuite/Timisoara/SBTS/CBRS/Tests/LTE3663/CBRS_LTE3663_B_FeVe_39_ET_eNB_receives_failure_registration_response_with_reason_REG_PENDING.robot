*** Settings ***
Documentation
...    = Author =
...    _aleksandra.chudzik@nokia.com_
...    = Maintainer =
...    _aleksandra.chudzik@nokia.com_
...    = Reviewer =
...    lukasz.lechowicz@nokia.com
...    piotr.lukaszewicz@nokia.com
...    karol.sadowski@nokia.com
...    elzbieta.wlodarczyk@nokia.com
...    Review link: http://l3-sim-krk-serv.dynamic.nsn-net.net/r/1238/

*** Keywords ***
CBRS_LTE3663_B_FeVe_39_ET_eNB_receives_failure_registration_response_with_reason_REG_PENDING
    [Documentation]    Tested Requirement: OAM_REQ_FMRECOV_1004
    ...                Purpose: The purpose of the test case is to verify that CBSD can be handled when received
    ...                failure registration response with reason REG_PENDING.
    ...                CBSD should stay in status unregistered, alarm SAS Registration Failure should be raised.
	...                Test Steps:
	...                1.Start SAS process
	...                2.Check if CBSD status is 'Unregistered'
	...                3.Check if alarm 6826 'SAS Registration Failure' is visible on eNB
	...                4.Verify RegistrationResponse message with code 200 in SAS log

	${supplementary_info}   Catenate
    ...    Register Exception with Reason: 200. ResponseMessage: Incomplete registration information.
    ...    The registration process is pending.. ResponseData: resp_data.
    &{mandatory_alarm}   Create Dictionary
    ...    fault_id=6826
    ...    fault_name=SAS Registration Failure
    ...    severity=Critical
    ...    reason=${supplementary_info}

    Log To Console    Preconditions
    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    @{expected_alarms_objects}   Create Watchdog Alarm List    ${mandatory_alarm}

    Log To Console    Kill SAS if exists
    Disable CBRS Feature On eNB
    Kill All SAS Processes
    Check If Cells Are Disabled    enb_id=${enb_id}

    Log To Console    Step 1. Starting SAS Simulator with forced registration response code 200
    #in SAS Sim conf: force_sas_method = registration, force_response_code = 200
    ${sas_pid}    ${sas_logs_dir}   Start SAS Process
    ...                               alias=default
    ...                               port=4433
    ...                               config=${CURDIR}/Data/FeVe_39/SAS_Sim.conf
    Enable CBRS Feature On eNB

    ${time_start}   Get Time
    Sleep    20s    #time buffer for exchange registration messages CBSD-SAS and catch proper unregistered state
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}

    Log To Console    Step 2. Check if CBSD status is Unregistered
    Wait Until Keyword Succeeds    30x    2s    Required CBSD Status Should Be Reached
    ...                                         expected_status=Unregistered
    ...                                         enb_id=${enb_id}

    Log To Console    Step 3. Checking expected alarms on eNB
    Wait For Watchdog Alarm Activation
    ...    fault_id=${mandatory_alarm['fault_id']}
    ...    fault_name=${mandatory_alarm['fault_name']}
    ...    severity=${mandatory_alarm['severity']}
    ...    reason=${mandatory_alarm['reason']}

    ${time_stop}   Get Time

    Log To Console    Step 3. Checking SAS log, verifying RegistrationResponse message with code 200
    ${parsed_log_file}   Parse Sas Log File    log_file_name=${sas_logs_dir}
    ...                                          date_start=${time_start}
    ...                                          date_stop=${time_stop}
    ${registration_response_code}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...                                                              parameter=responseCode
    ...                                                              data_type=registrationResponse

    Should Be Equal As Numbers    ${registration_response_code[0]}    200

    [Teardown]    Run Keywords
    ...    Get SAS Logs To Logs Dir    alias=default    AND
    ...    Stop Watchdog Alarm Detection And Check For Failures    AND
    ...    Kill All SAS Processes    AND
    ...    Check If Cells Are Disabled    enb_id=${enb_id}
