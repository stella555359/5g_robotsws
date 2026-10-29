*** Settings ***
Documentation
...    = Author =
...    piotr.lukaszewicz@nokia.com
...    = Maintainer =
...    piotr.lukaszewicz@nokia.com
...    = Reviewer =
...    lukasz.lechowicz@nokia.com
...    aleksandra.chudzik@nokia.com
...    karol.sadowski@nokia.com
...    elzbieta.wlodarczyk@nokia.com
...    Review link: https://l3-sim-krk-serv.dynamic.nsn-net.net/r/1485/

*** Keywords ***
CBRS_CB008735_FeVe_17_ET_Relinquish_during_grant_update_higher_maxEirp_when_SAS_not_supports_WF_GRANT_UPDATE
    [Documentation]    Requirement: OM_GEN_SFS_CBRS.523;OAM_REQ_CBRS_134
    ...                Purpose: Verify a situation when CBSD received heartbeat response message with responseCode 0
    ...                and with operationParam from SAS which not support WF_GRANT_UPDATE feature. In such scenario
    ...                relinquish procedure should fail.
    ...                Test Steps:
    ...                Step 0: Prepare BTS and SAS configuration
    ...                Step 1: Start SAS simulator and verify registrationRequest (CBRS TS v2.0 expected)
    ...                Step 2: Check if:
    ...                - grantRequest contains operationParam with maxEirp=27
    ...                - heartbeatResponse contains operationParam with maxEirp=28.1
    ...                - relinquishmentResponse ends with response code 105 (auto deregister)

    ${bts_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${alias}   Set Variable    RAT_1ST
    &{expected_alarms}   Create Dictionary    fault_name=SAS Registration Failure
    ${expected_alarms_objects}   Create Watchdog Alarm List     ${expected_alarms}
    ${num_of_cells}   Get Number of Cells    enb_id=${bts_id}

    Log To Console    ${\n}Step 0: Setting preconditions...
    Disable CBRS Feature On eNB
    Kill All SAS Processes
    Enable CBRS Feature On eNB

    Replace Variables In File    ${CURDIR}/Data/FeVe_17/precondition.json
    ...                          ${OUTPUT_DIR}/precondition.json
    ...                          enb_id=${bts_id}
    Replace Variables In File    ${CURDIR}/Data/FeVe_17/postcondition.json
    ...                          ${OUTPUT_DIR}/postcondition.json
    ...                          enb_id=${bts_id}

    Wait Until Keyword Succeeds    12x    10s    Run Keywords
    ...    Wait Until BTS Is Not Busy    AND
    ...    Perform Delta Recommissioning    ${OUTPUT_DIR}/precondition.json    connection=${alias}

    Log To Console    Step 1: Starting SAS simulator...
    ${sas_pid}    ${sas_logs_dir}   Start SAS Process    config=${CURDIR}/Data/FeVe_17/SAS_Sim.conf
    ${log_start_time}   Get Time
    Wait Until Keyword Succeeds    6x    10s    Required CBSD Status Should Be Reached
    ...    expected_status=Registered    enb_id=${bts_id}
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}

    Wait For All Cells To Be OnAir    wait_time=10min
    ${log_end_time}   Get Time

    Log To Console    Step 2: Logs evaluation...
    Wait Until Keyword Succeeds    6x    10s    Check If TS Version Is As Expected    ${bts_id}    ${alias}    2.0

    ${parsed_log_file}   Parse Sas Log File    log_file_name=${sas_logs_dir}
    ...                                          date_start=${log_start_time}
    ...                                          date_stop=${log_end_time}
    ${oper_param_in_grant_req}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...                                                           parameter=operationParam
    ...                                                           start_from=grantRequest
    ${oper_param_in_grant_req_str}   Convert To String    ${oper_param_in_grant_req}[0]
    Should Contain    ${oper_param_in_grant_req_str}    27    msg=Not found maxEirp == 27 inside grant request
    Log To Console    Found operationParam in grant request with maxEirp equal to 27

    ${oper_param_in_hb_res}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...                                                        parameter=operationParam
    ...                                                        start_from=heartbeatRequest
    ${oper_param_in_hb_res_str}   Convert To String    ${oper_param_in_hb_res}[0]
    Should Contain    ${oper_param_in_hb_res_str}    28.1    msg=Not found maxEirp == 28.1 inside heartbeat response
    Log To Console    Found operationParam in heartbeat response with maxEirp equal to 28.1

    ${parsed_relinq_resp}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...                                                      data_type=relinquishmentResponse
    ...                                                      parameter=responseCode
    ${parsed_relinq_resp_str}   Convert To String    ${parsed_relinq_resp}[0]
    Should Contain    ${parsed_relinq_resp_str}    105    msg=Not found response code 105 inside relinquishment response
    Log To Console    Found response code 105 in relinquishment response

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Disable CBRS Feature On eNB    AND
    ...                           Wait Until BTS Is Not Busy    AND
    ...                           Wait Until Keyword Succeeds    30x    5s    Perform Delta Recommissioning
    ...                                                                       ${OUTPUT_DIR}/postcondition.json
    ...                                                                       connection=RAT_1ST    AND
    ...                           Kill All SAS Processes    AND
    ...                           Check If Cells Are Disabled    enb_id=${bts_id}
