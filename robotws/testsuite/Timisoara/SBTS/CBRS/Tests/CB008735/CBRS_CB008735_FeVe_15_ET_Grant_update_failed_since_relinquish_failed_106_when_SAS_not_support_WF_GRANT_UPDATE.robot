*** Settings ***
Documentation
...    = Author =
...    Karol.Sadowski@nokia.com
...    = Maintainer =
...    Karol.Sadowski@nokia.com
...    = Reviewer =
...    Lukasz.Lechowicz@nokia.com
...    Piotr.Lukaszewicz@nokia.com
...    Elzbieta.Wlodarczyk@nokia.com
...    Aleksandra.Chudzik@nokia.com
...    Review link: https://l3-sim-krk-serv.dynamic.nsn-net.net/r/1501/

*** Keywords ***
CBRS_CB008735_FeVe_15_ET_Grant_update_failed_since_relinquish_failed_106_when_SAS_not_support_WF_GRANT_UPDATE
    [Documentation]  Requirement: OAM_REQ_CBRS_134
    ...              Purpose: This test scenario verifies case when WF_GRANT_UPDATE feature is not supported by SAS
    ...                       and relinquish respose with response code 106 (unsuccessful) occurred.
    ...              Step 1: Wait for first relinquish procedure with rc: 106 and response data = 10 [s]
    ...              Step 2: Check if after 10s another relinquish procedure occured with rc: 0
    ...              Step 3: Check if new grant request was send by CBSD

    ${bts_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${alias}   Set Variable    RAT_1ST
    &{expected_alarms}   Create Dictionary    fault_id=6830
    ...                                         fault_name=SAS Spectrum Relinquishment Failure
    ...                                         severity=Warning
    ${expected_alarms_object}   Create Watchdog Alarm List     ${expected_alarms}

    Log To Console    ${\n}Step 1: Setting preconditions...
    Kill All SAS Processes
    Disable CBRS Feature On eNB
    Enable CBRS Feature On eNB
    Replace Variables In File    ${CURDIR}/Data/FeVe_15/precondition.json
    ...                          ${OUTPUT_DIR}/FeVe_15_precondition.json
    ...                          enb_id=${bts_id}
    Replace Variables In File    ${CURDIR}/Data/FeVe_15/postcondition.json
    ...                          ${OUTPUT_DIR}/FeVe_15_postcondition.json
    ...                          enb_id=${bts_id}
    Wait Until Keyword Succeeds    5x    10s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Delta Recommissioning    ${OUTPUT_DIR}/FeVe_15_precondition.json    connection=${alias}

    Log To Console    Step 2: Starting SAS simulator...
    ${sas_pid}    ${sas_logs_dir}   Start SAS Process    config=${CURDIR}/Data/FeVe_15/SAS_Sim.conf
    ${log_start_time}   Get Time
    Wait Until Keyword Succeeds    5x    10s    Required CBSD Status Should Be Reached
    ...    expected_status=Registered    enb_id=${bts_id}
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_object}
    Sleep    15s    #wait for 2nd reliquish
    Wait For All Cells To Be OnAir    wait_time=10min
    ${log_end_time}   Get Time

    Log To Console    Step 3: Logs evaluation...
    Wait Until Keyword Succeeds    5x    10s    Check If TS Version Is As Expected    ${bts_id}    ${alias}    2.0
    ${parsed_log_file}   Parse Sas Log File    log_file_name=${sas_logs_dir}
    ...                                          date_start=${log_start_time}
    ...                                          date_stop=${log_end_time}

    ${parsed_relinq_resp}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...                                                      data_type=relinquishmentResponse
    ...                                                      parameter=responseCode
    ${relinq_count}   Get Length    ${parsed_relinq_resp}
    Should Be Equal As Integers    ${relinq_count}    2    msg=Wrong number of relinquishResponse in parsed SAS_Sim.log
    ${parsed_first_relinq_resp_str}   Convert To String    ${parsed_relinq_resp}[0]
    ${parsed_second_relinq_resp_str}   Convert To String    ${parsed_relinq_resp}[1]
    Should Contain    ${parsed_first_relinq_resp_str}    106    msg=Not found response code 106 inside first relinquishment response
    Log To Console    Found response code 106 in first relinquishment response
    Should Contain    ${parsed_second_relinq_resp_str}    0    msg=Not found response code 0 inside second relinquishment response
    Log To Console    Found response code 0 in second relinquishment response

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Disable CBRS Feature On eNB    AND
    ...                           Wait Until BTS Is Not Busy    AND
    ...                           Wait Until Keyword Succeeds    30x    5s    Perform Delta Recommissioning
    ...                                                                       ${OUTPUT_DIR}/FeVe_15_postcondition.json
    ...                                                                       connection=${alias}    AND
    ...                           Kill All SAS Processes    AND
    ...                           Check If Cells Are Disabled    enb_id=${bts_id}
