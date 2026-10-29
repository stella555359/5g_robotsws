*** Settings ***
Documentation
...    = Author = Bartosz Rutkowski
...    _bartosz.rutkowski@nokia.com_
...    = Maintainer =
...    _bartosz.rutkowski@nokia.com_
...    = Reviewer =
...    _aleksandra.dagiel@nokia.com_
...    = Summary =
...    N/A
...    = Pre - Requirements =
...    _robotlte/config/<testline name>/__init__.py and site specific keyword_
...    = Additional Info =
...    Test development in progress

*** Keywords ***
LTE3663_Q_FeVe_11_Verify_deregistration_requested_by_SAS_is_successful
    [Documentation]  The purpose of first step of this test is to check if CBSD could deregister from SAS successfully.
    ...              This is done by triggering CBRS feature.
    ...              Second step is to check CBSD behaviour on 105 response code send from SAS - CBSD should go to
    ...              unregistered state and then CBSD should refresh its registration.
    ...              Remark: deregistration triggers are:
    ...               CBRS feature deactivation
    ...               CBRS configuration data change
    ...               CBSD configuration data change
    ...              SAS is configured to respond with heartbeatResponse with 105 for every 3rd heartbeatRequest.
    ...              Requirement: OM_GEN_SFS_CBRS.353

    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${deregistrationResponse}   Load JSON From File    ${CURDIR}/Data/deregistrationResponse.json
    ${sas_new_config}   Set Variable    ${CURDIR}/Data/SAS_Sim_deregistration_request.conf
    ${num_of_cells}   Get Number of Cells    ${enb_id}
    ${supplementary_info}   Catenate
    ...    Heartbeat Exception with Reason: 105. ResponseMessage: A CBSD receiving this responseCode
    ...    is automatically deregistered by the SAS.
    &{expected_alarm_1}   Create Dictionary    fault_id=6829    fault_name=SAS Heartbeat Failure    severity=Critical
    ...                                          reason=${supplementary_info}
    &{expected_alarm_2}   Create Dictionary    fault_id=6826    fault_name=SAS Registration Failure    severity=Critical
    # below fault is visible only on AEQM environment
    &{expected_alarm_3}   Create Dictionary    fault_id=6829    fault_name=SAS Heartbeat Failure    severity=Minor
    ...                                          reason=${supplementary_info}
    ${expected_alarms_list}   Create List    ${expected_alarm_1}    ${expected_alarm_2}    ${expected_alarm_3}
    ${expected_alarms_objects}   Create Watchdog Alarm List    ${expected_alarms_list}

    Log To Console    Step1: Setup environment, cbsdRegistrationState=Registered, no alarms, get cbsdId
    Kill All SAS Processes
    ${sas_pid}    ${sas_log}   Start SAS Process    alias=one    version=1.2
    Wait Until BTS Is Not Busy
    Enable CBRS Feature On eNB
    ${deregister_start_time}   Get Time
    Sleep And Display Progress    60    s
    Wait Until Keyword Succeeds    10x    10s    Required CBSD Status Should Be Reached    expected_status=Registered    enb_id=${enb_id}
    ${cbsd_id_list}    ${cbsd_count}    Return Assigned ID For Every Registered CBSD    enb_id=${enb_id}
    ${cbsdId}   Set Variable    ${cbsd_id_list[0]}
    Log To Console    CBSDID: ${cbsdId}
    Wait For All Cells To Be OnAir
    BTS Operational State Should Be OnAir
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}

    Log To Console    Step2: Disable CBRS to cause deregistration and wait for eNB to process
    Wait Until BTS Is Not Busy
    Disable CBRS Feature On eNB
    Sleep And Display Progress    10    s
    Wait Until Keyword Succeeds    10x    10s    Required CBSD Status Should Be Reached    expected_status=Unregistered    enb_id=${enb_id}
    ${deregister_stop_time}   Get Time

    Log To Console    Step3: Verify deregistration messages
    ${parsed_log_file}   Parse Sas Log File    log_file_name=${sas_log}
    ...                                          date_start=${deregister_start_time}
    ...                                          date_stop=${deregister_stop_time}
    ...                                          verbose=True

    Required Packets Should Have Proper CbsdId    parsed_log_file=${parsed_log_file}
    ...                                           cbsd_count=${cbsd_count}
    ...                                           cbsd_id_list=${cbsd_id_list}
    ...                                           deregistrationResponse=${deregistrationResponse}

    Kill All SAS Processes
    Get SAS Logs To Logs Dir    alias=one
    ${sas_pid}    ${sas_log}   Start SAS Process    alias=two    config=${sas_new_config}

    Log To Console    Step4: Enable CBRS feature, wait for onair and no alarms
    Wait Until BTS Is Not Busy
    ${heartbeat_start_time}   Get Time
    Enable CBRS Feature On eNB
    Wait For Watchdog Alarm Activation    fault_id=${expected_alarm_1}[fault_id]    fault_name=${expected_alarm_1}[fault_name]
    ...                                   severity=${expected_alarm_1}[severity]    reason=${expected_alarm_1}[reason]    timeout=240
    Wait For Watchdog Alarm Deactivation    fault_id=${expected_alarm_1}[fault_id]    fault_name=${expected_alarm_1}[fault_name]
    ...                                     severity=${expected_alarm_1}[severity]    reason=${expected_alarm_1}[reason]    timeout=60
    Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm_1}[fault_id]    fault_name=${expected_alarm_1}[fault_name]
    ...                                        severity=${expected_alarm_1}[severity]    reason=${expected_alarm_1}[reason]
    Wait For Watchdog Alarm Activation    fault_id=${expected_alarm_2}[fault_id]    fault_name=${expected_alarm_2}[fault_name]
    ...                                   severity=${expected_alarm_2}[severity]    timeout=60
    Wait For Watchdog Alarm Deactivation    fault_id=${expected_alarm_2}[fault_id]    fault_name=${expected_alarm_2}[fault_name]
    ...                                     severity=${expected_alarm_2}[severity]    timeout=120
    Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm_2}[fault_id]    fault_name=${expected_alarm_2}[fault_name]
    ...                                        severity=${expected_alarm_2}[severity]
    BTS Operational State Should Be OnAir

    Log To Console    Step5: Wait for deregistration and check heartbeatResponse for responsecode 105
    BTS Operational State Should Be OnAir
    ${heartbeat_stop_time}   Get Time
    ${parsed_log_file}   Parse Sas Log File    log_file_name=${sas_log}
    ...                                          date_start=${heartbeat_start_time}
    ...                                          date_stop=${heartbeat_stop_time}
    ...                                          verbose=True
    Query Sas Log    log_name=${parsed_log_file}    data_type=heartbeatRequest    parameter=cbsdId    value=${cbsdId}
    Query Sas Log    log_name=${parsed_log_file}    data_type=heartbeatResponse    parameter=cbsdId    value=${cbsdId}
    ${response_codes}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...                                                  parameter=responseCode
    ...                                                  data_type=heartbeatResponse
    ...                                                  packet_amount=3
    Log To Console    SAS response codes:${response_codes}
    Run Keyword And Continue On Failure    Should Contain X Times    container=@{response_codes}    item=${105}   count=${num_of_cells}
    ${cbsd_ids}   Extract Values From Sas Log    log_name=${parsed_log_file}
    ...                                            parameter=cbsdId
    ...                                            data_type=heartbeatResponse
    Log To Console    cbsdIds: ${cbsd_ids}
    CBSDIds Should Be Equal To Value    cbsd_ids_list=${cbsd_ids}    value=${cbsdId}
    ${fccid}    ${userid}   Get FCC And User Ids From Infomodel
    Query Sas Log    log_name=${parsed_log_file}    data_type=registrationRequest    parameter=fccId     value=${fccid}
    Query Sas Log    log_name=${parsed_log_file}    data_type=registrationRequest    parameter=userId    value=${userid}

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=one    AND
    ...                           Get SAS Logs To Logs Dir    alias=two    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Kill All SAS Processes

*** Keywords ***
CBSDIds Should Be Equal To Value
    [Arguments]    ${cbsd_ids_list}    ${value}
    FOR    ${elem}    IN    @{cbsd_ids_list}
        Should Be Equal As Strings    first=${elem}    second=${value}    ignore_case=true
    END

Return Assigned ID For Every Registered CBSD
    [Arguments]        ${enb_id}
    [Documentation]    Queries the Infomodel for details of each CBSD, extracts its assignedCbsdId value and appends it to the returned list.
    ...                Parameters:
    ...                enb_id - ID of the eNB
    @{cbsd_param_list}   ute_admin_infomodel.Query Infomodel    alias=RAT_1ST
    ...    query=get list /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-${enb_id}/CBSD_R-*
    ${cbsd_count}   Get Length    ${cbsd_param_list}
    ${cbsd_id_list}   Create List
    FOR    ${i}    IN RANGE    ${cbsd_count}
        Append To List    ${cbsd_id_list}    ${cbsd_param_list[${i}]['assignedCbsdId']}
    END
    RETURN    ${cbsd_id_list}    ${cbsd_count}

Required Packets Should Have Proper CbsdId
    [Arguments]    ${parsed_log_file}    ${cbsd_count}    ${cbsd_id_list}    ${deregistrationResponse}
    [Documentation]    Queries SAS Sim log looking for all IDs assigned to CBSDs within deregistrationRequest and deregistrationResponse
    Query Sas Log    log_name=${parsed_log_file}    data_type=deregistrationResponse    parameter=response    value=${deregistrationResponse}
    FOR    ${i}    IN RANGE    ${cbsd_count}
        Query Sas Log    log_name=${parsed_log_file}    data_type=deregistrationRequest     parameter=cbsdId    value=${cbsd_id_list[${i}]}
        Query Sas Log    log_name=${parsed_log_file}    data_type=deregistrationResponse    parameter=cbsdId    value=${cbsd_id_list[${i}]}
    END
