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
...    Review link: https://wrgitlab.ext.net.nokia.com/RAN/robotlte/-/merge_requests/28315#note_3269761

*** Keywords ***
CBRS_CB008735_FeVe_18_ET_Grant_update_when_maxEirp_exceed_FCC_limit
    [Documentation]  Requirement: OAM_REQ_CBRS_132
    ...              Purpose: This test scenario verifies case when CBSD recievies HB response with code: 0 and
    ...                       operation param which exceeds 37dB FCC power limitation.
    ...              Step 1: Check if registration, grant and hb procedure suceeds
    ...              Step 2: Wait for HB with operation param to change maxEirp over 37dB limit (37 maxeirp)
    ...              Step 3: Check if pmax changed and maxEirp = 28.1dB

    ${bts_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${alias}   Set Variable    RAT_1ST

    Log To Console    ${\n}Step 1: Setting preconditions...
    Kill All SAS Processes
    Disable CBRS Feature On eNB
    Enable CBRS Feature On eNB
    Replace Variables In File    ${CURDIR}/Data/FeVe_18/precondition.json
    ...                          ${OUTPUT_DIR}/FeVe_18_precondition.json
    ...                          enb_id=${bts_id}
    Replace Variables In File    ${CURDIR}/Data/FeVe_18/postcondition.json
    ...                          ${OUTPUT_DIR}/FeVe_18_postcondition.json
    ...                          enb_id=${bts_id}
    Wait Until Keyword Succeeds    5x    10s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Delta Recommissioning    ${OUTPUT_DIR}/FeVe_18_precondition.json    connection=${alias}

    Log To Console    Step 2: Starting SAS simulator...
    ${sas_pid}    ${sas_logs_dir}   Start SAS Process    config=${CURDIR}/Data/FeVe_18/SAS_Sim.conf
    ${log_start_time}   Get Time
    Wait Until Keyword Succeeds    5x    10s    Required CBSD Status Should Be Reached
    ...    expected_status=Registered    enb_id=${bts_id}
    Start Watchdog Alarm Detection

    Wait For All Cells To Be OnAir

    ${pmax_dict_before}   List pMax Values For All Cells    enb_id=${bts_id}
    ${pmax_list_before}   Get Dictionary Values    ${pmax_dict_before}
    Sort List    ${pmax_list_before}
    ${expcted_result_before}   Create List    ${21.9}    ${25}    ${25}    ${25}
    Lists Should Be Equal    ${pmax_list_before}    ${expcted_result_before}    msg=Wrong Pmax parameter for cells
    Log To Console    Cells configured as expected:\n${pmax_dict_before}

    Wait For Any Cell To Be Dropped
    Wait For All Cells To Be OnAir

    ${pmax_dict_after}   List pMax Values For All Cells    enb_id=${bts_id}
    ${pmax_list_after}   Get Dictionary Values    ${pmax_dict_after}
    Sort List    ${pmax_list_after}
    ${expcted_result_after}   Create List    ${25}    ${25}    ${25}    ${25}
    Lists Should Be Equal    ${pmax_list_after}    ${expcted_result_after}    msg=Wrong Pmax parameter for cells
    Log To Console    Cells reconfigured as expected, pmax limited to desiredPmax 25dBm:\n${pmax_dict_after}

    ${log_end_time}   Get Time

    Log To Console    Step 3: Logs evaluation...
    Wait Until Keyword Succeeds    5x    10s    Check If TS Version Is As Expected    ${bts_id}    ${alias}    2.0
    ${parsed_log_file}   Parse Sas Log File    log_file_name=${sas_logs_dir}
    ...                                          date_start=${log_start_time}
    ...                                          date_stop=${log_end_time}

    ${parsed_heartbeat_response}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...                                                             data_type=heartbeatResponse
    ...                                                             parameter=maxEirp
    List Should Contain Value    ${parsed_heartbeat_response}    ${37.0}
    Log To Console    Found operationParam in heartbeat response with maxEirp equal to 37.0

    ${parsed_grant_request}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...                                                        data_type=grantRequest
    ...                                                        parameter=maxEirp
    ...                                                        start_from=heartbeatRequest
    List Should Contain Value    ${parsed_grant_request}    ${28.1}
    Log To Console    Found operationParam in grant request with limited maxEirp to 28.1

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Disable CBRS Feature On eNB    AND
    ...                           Wait Until BTS Is Not Busy    AND
    ...                           Wait Until Keyword Succeeds    30x    5s    Perform Delta Recommissioning
    ...                                                                       ${OUTPUT_DIR}/FeVe_18_postcondition.json
    ...                                                                       connection=${alias}    AND
    ...                           Kill All SAS Processes    AND
    ...                           Check If Cells Are Disabled    enb_id=${bts_id}
