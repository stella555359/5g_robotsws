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
...    Review link: https://l3-sim-krk-serv.dynamic.nsn-net.net/r/1507/

*** Keywords ***
CBRS_CB008735_FeVe_16_ET_Grant_not_update_maxEirp_no_change_for_multi_cell_with_SAS_support_WF_GRANT_UPDATE
    [Documentation]  Requirement: OAM_REQ_CBRS_134
    ...              Purpose: This test scenario verifies case when CBSD received heartbeat response message with responseCode 0
    ...                       and with operationParam from SAS which support WF_GRANT_UPDATE feature.
    ...                       The CBSD has multi cells, and the maxEirp have no update actions.
    ...              Step 0: Force in heartbeatResponse change maxeirp=23.9
    ...              Step 1: Check if in 1st heartbeatResponse operationParam - maxEirp: 23.9 occured
    ...              Step 2: Check if no new grant request was send by CBSD

    ${bts_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${alias}   Set Variable    RAT_1ST

    Log To Console    ${\n}Step 1: Setting preconditions...
    Kill All SAS Processes
    Disable CBRS Feature On eNB
    Enable CBRS Feature On eNB
    Replace Variables In File    ${CURDIR}/Data/FeVe_16/precondition.json
    ...                          ${OUTPUT_DIR}/FeVe_16_precondition.json
    ...                          enb_id=${bts_id}
    Replace Variables In File    ${CURDIR}/Data/FeVe_16/postcondition.json
    ...                          ${OUTPUT_DIR}/FeVe_16_postcondition.json
    ...                          enb_id=${bts_id}
    Wait Until Keyword Succeeds    12x    10s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Delta Recommissioning    ${OUTPUT_DIR}/FeVe_16_precondition.json    connection=${alias}

    Log To Console    Step 2: Starting SAS simulator...
    ${sas_pid}    ${sas_logs_dir}   Start SAS Process    config=${CURDIR}/Data/FeVe_16/SAS_Sim.conf
    ${log_start_time}   Get Time
    Wait Until Keyword Succeeds    6x    10s    Required CBSD Status Should Be Reached
    ...    expected_status=Registered    enb_id=${bts_id}
    Start Watchdog Alarm Detection
    Sleep    30s    #wait for max eirp change
    Wait For All Cells To Be OnAir    wait_time=10min
    ${log_end_time}   Get Time

    Log To Console    Step 3: Logs evaluation...
    Wait Until Keyword Succeeds    6x    10s    Check If TS Version Is As Expected    ${bts_id}    ${alias}    2.0
    ${parsed_log_file}   Parse Sas Log File    log_file_name=${sas_logs_dir}
    ...                                          date_start=${log_start_time}
    ...                                          date_stop=${log_end_time}

    ${parsed_SAS_communication}   Communication CBSD SAS    SAS_Sim_log_file=${sas_logs_dir}
    ${count_grant_request}    Get Match Count    ${parsed_SAS_communication}     *grantRequest
    Should Be Equal As Integers    ${count_grant_request}    1    msg=Wrong number of grantRequest visible in SAS_Sim.log
    Log To Console    Exact one grantRequest found in SAS_Sim.log

    ${parsed_heartbeat_response}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...                                                             data_type=heartbeatResponse
    ...                                                             parameter=maxEirp
    ${operationparam_count}   Count Values In List    ${parsed_heartbeat_response}    ${23.9}
    Should Be Equal As Integers    ${operationparam_count}    2    msg=Wrong number of operation param maxeirp:23.9 in heartbeat response.
    Log To Console    Operation param change maxeirp:23.9 found in heartbeatResponse in SAS_Sim.log


    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Disable CBRS Feature On eNB    AND
    ...                           Wait Until BTS Is Not Busy    AND
    ...                           Wait Until Keyword Succeeds    30x    5s    Perform Delta Recommissioning
    ...                                                                       ${OUTPUT_DIR}/FeVe_16_postcondition.json
    ...                                                                       connection=${alias}    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Kill All SAS Processes    AND
    ...                           Check If Cells Are Disabled    enb_id=${bts_id}
