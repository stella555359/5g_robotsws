*** Settings ***
Documentation
...    = Author = Karol Palamarz
...    _karol.palamarz@nokia.com_
...    = Maintainer =
...    _piotr.lukaszewicz@nokia.com_
...    = Reviewer =
...    _artur.czainski@nokia.com_
...    _michal.moskala@nokia.com_
...    = Summary =
...    First part of this Test Case checks whether CBSD successfully sends registration request to SASv1.2 if registration to SASv2.0 fails.
...    One reponse contain responseCode 100. Second part of this Test Case checks whether eNB raised an alarm in case of unsuccessful
...    registration to all SAS version fails. All responses contain responseCode 100.
...    = Pre - Requirements =
...    _robotlte/config/<testline name>/__init__.py and site specific keyword_
...    = Additional Info =

*** Keywords ***
CBRS_LTE5703_FeVe_02_Registration_procedure_modification_failure_with_TS_version_2_0
    [Documentation]    Requirement: OM_GEN_SFS_CBRS.281

    Log To Console    ${\n}Step 1: Test preparation, setup environment
    ${enb_id}                     Set Variable    ${testlines.${testline_id}.enb_id}
    ${alias}                      Set Variable    RAT_1ST
    ${sas_new_config_success}     Set Variable    ${CURDIR}/Data/feve02/SAS_Sim_registration_request_02_success.conf
    ${sas_new_config_unsuccess}   Set Variable    ${CURDIR}/Data/feve02/SAS_Sim_registration_request_02.conf
    ${sas_new_config}             Set Variable    ${CURDIR}/Data/feve02/SAS_Sim_registration_request.conf
    ${registrationRequest_v2.0}   Set Variable    ${CURDIR}/Data/feve02/registrationRequest.json
    ${registrationRequest_v1.2}   Set Variable    ${CURDIR}/Data/feve02/registrationRequest_v1.1_and_v1.2.json
    ${registrationRequest_v1.1}   Set Variable    ${CURDIR}/Data/feve02/registrationRequest_v1.1_and_v1.2.json
    ${registrationRequest_v1.0}   Set Variable    ${CURDIR}/Data/feve02/registrationRequest_v1.0.json
    ${registrationResponse_100}   Set Variable    ${CURDIR}/Data/feve02/registrationResponse_100.json
    &{expected_alarm_1}           Create Dictionary    fault_id=6832    fault_name=SAS Server Communication Failure    severity=Minor
    &{expected_alarm_2}           Create Dictionary    fault_id=6826    fault_name=SAS Registration Failure    severity=Critical
    ...    reason=Register Exception with Reason: 100. ResponseMessage: SAS protocol version used by CBSD is not supported by SAS. ResponseData: .
    ${expected_alarms_list}       Create List    ${expected_alarm_1}    ${expected_alarm_2}
    ${expected_alarms_objects}    Create Watchdog Alarm List    ${expected_alarms_list}
    ${bts_side}   Set Variable    *

    @{sas_user_group_list}   Query Infomodel
    ...    query=get list /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-${enb_id}/LNBTS_A-${enb_id}/SASUSERGROUP_A-*
    ...    timeout=30    alias=${alias}
    FOR    ${element}    IN    @{sas_user_group_list}
        ${element_str}   Convert To String    ${element}
        ${moc_id}   Get Regexp Matches    ${element_str}    (?<=SASUSERGROUP_A-)(\\d*)(?=')
        ${group_id_value}   Get Regexp Matches    ${element_str}    (?<=':\\su')(.*?)(?=\\',)
        ${is_group_id_not_empty}   Run Keyword And Return Status    Should Not Be Empty    ${group_id_value}
        IF  ${is_group_id_not_empty}==True    Log To Console    Removing value from SASUSERGROUP-${moc_id[0]}
        IF  ${is_group_id_not_empty}==True    Remove SASUSERGROUP    sas_user_group_id=${moc_id[0]}
    END
    Synchronize Time Between VM And eNB In Case Of Difference
    Disable CBRS Feature On eNB
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}
    Add SASUSEGROUP
    Wait Until BTS Is Not Busy
    Add ICG And CCG Group ID

    Log To Console    Step 2: Start SAS. Enable CBRS feature, expecting CBSD registrationRequest and Response with code 100, checking CBSD status
    Wait Until BTS Is Not Busy
    Kill All SAS Processes
    ${sas_pid}    ${sas_log}   Start SAS Process    config=${sas_new_config_success}
    Enable CBRS Feature On eNB
    Wait Until Keyword Succeeds    10x    10s    Required CBSD Status Should Be Reached    expected_status=Registered    enb_id=${enb_id}
    Wait For All Cells To Be OnAir
    Wait Until Keyword Succeeds    5x    1min    Check If TS Version Is As Expected    ${enb_id}    ${alias}    1.2

    Log To Console    ${\n}Step 3: Restore previous SAS configuration with registration to TS 2.0
    Wait Until BTS Is Not Busy
    Kill All SAS Processes
    Disable CBRS Feature On eNB
    Wait Until BTS Is Not Busy
    ${sas_pid}    ${sas_log}   Start SAS Process    config=${sas_new_config}
    Enable CBRS Feature On eNB
    Wait For Watchdog Alarm Deactivation    fault_id=${expected_alarm_1}[fault_id]    fault_name=${expected_alarm_1}[fault_name]
    ...                                     severity=${expected_alarm_1}[severity]    timeout=90
    Wait Until Keyword Succeeds    10x    10s    Required CBSD Status Should Be Reached    expected_status=Registered    enb_id=${enb_id}
    Wait Until Keyword Succeeds    10x    10s    Watchdog Check For Failures
    Wait For All Cells To Be OnAir
    Wait Until Keyword Succeeds    5x    1min    Check If TS Version Is As Expected    ${enb_id}    ${alias}    2.0

    Log    Step 4: Re-start new SAS and re-enable CBRS feature, expecting registrationResponses with code 100 in all reponses.
    Wait Until BTS Is Not Busy
    Kill All SAS Processes
    Disable CBRS Feature On eNB
    Wait Until BTS Is Not Busy
    ${registration_log_start}   Get Time
    ${sas_pid}    ${sas_log}   Start SAS Process    config=${sas_new_config_unsuccess}
    Enable CBRS Feature On eNB
    Wait For Watchdog Alarm Deactivation    fault_id=${expected_alarm_1}[fault_id]    fault_name=${expected_alarm_1}[fault_name]
    ...                                     severity=${expected_alarm_1}[severity]    timeout=90
    Wait For Watchdog Alarm Activation    fault_id=${expected_alarm_2}[fault_id]    fault_name=${expected_alarm_2}[fault_name]
    ...                                   severity=${expected_alarm_2}[severity]    reason=${expected_alarm_2}[reason]    timeout=90
    Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm_1}[fault_id]    fault_name=${expected_alarm_1}[fault_name]
    ...                                        severity=${expected_alarm_1}[severity]
    ${cbsd_ids}   Get CBSD IDs    ${enb_id}    ${bts_side}    ${alias}
    Wait Until Keyword Succeeds    30x    10s    Required CBSD Status Should Be Reached    expected_status=Unregistered    enb_id=${enb_id}
    ${registration_log_stop}   Get Time

    Log To Console    ${\n}Step 5: Getting data from Infomodel
    ${request_messages_to_SAS_2_0}   Create Registration Request Messages According to CBSD State
    ...    ${bts_side}    ${enb_id}    ${alias}    ${registrationRequest_v2.0}    Unregistered
    ${request_messages_to_SAS_1_2}   Create Registration Request Messages According to CBSD State
    ...    ${bts_side}    ${enb_id}    ${alias}    ${registrationRequest_v1.2}    Unregistered
    ${request_messages_to_SAS_1_1}   Create Registration Request Messages According to CBSD State
    ...    ${bts_side}    ${enb_id}    ${alias}    ${registrationRequest_v1.1}    Unregistered
    ${request_messages_to_SAS_1_0}   Create Registration Request Messages According to CBSD State
    ...    ${bts_side}    ${enb_id}    ${alias}    ${registrationRequest_v1.0}    Unregistered
    ${response_messages_100}         Create Registration Response Messages With Error Code
    ...    ${bts_side}    ${enb_id}    ${alias}    ${registrationResponse_100}    Unregistered    ${EMPTY}

    Log To Console    ${\n}Step 6: Getting registrationRequests from SAS_Sim.log and checking if messages are correct
    ${parsed_log_file}   Parse Sas Log File    log_file_name=${sas_log}
    ...                                          date_start=${registration_log_start}
    ...                                          date_stop=${registration_log_stop}
    ${registration_requests}   Get Messages From SAS Log
    ...    ${sas_log}    ${registration_log_start}    ${registration_log_stop}    registrationRequest
    ${cbsd_r_list}   Query Infomodel
    ...    query=get list /MRBTS-*/RAT-*/RUNTIME_VIEW-${bts_side}/MRBTS_R-*/LNBTS_R-${enb_id}/CBSD_R-*    timeout=30    alias=${alias}
    ${cbsd_count}   Get Length    ${cbsd_r_list}
    ${requests_should_be_sent}   Evaluate    4*${cbsd_count}    #it is multiple by 4 because CBSD is trying to reach to all (four) SAS versions
    ${request_count}   Get Length    ${registration_requests}
    Should Be Equal    ${requests_should_be_sent}    ${request_count}
    ${double_cbsd_count}   Evaluate    ${cbsd_count}*2
    ${triple_cbsd_count}   Evaluate    ${cbsd_count}*3

    #Example in case of 3 CBSDs : (lines below)
    #[0:3]  # takes requests from 1 to 3
    #[3:6]  # takes requests from 4 to 6
    #[6:9]  # takes requests from 7 to 9
    #[9:12]  # takes requests from 10 to 12
    ${registration_requests_to_SAS_2_0}   Set Variable    ${registration_requests[0:${cbsd_count}]}
    ${registration_requests_to_SAS_1_2}   Set Variable    ${registration_requests[${cbsd_count}:${double_cbsd_count}]}
    ${registration_requests_to_SAS_1_1}   Set Variable    ${registration_requests[${double_cbsd_count}:${triple_cbsd_count}]}
    ${registration_requests_to_SAS_1_0}   Set Variable    ${registration_requests[${triple_cbsd_count}:]}

    FOR    ${line}    IN    @{request_messages_to_SAS_2_0}
        Compare Messages    ${line}    ${registration_requests_to_SAS_2_0}
    END
    FOR    ${line}    IN    @{request_messages_to_SAS_1_2}
        Compare Messages    ${line}    ${registration_requests_to_SAS_1_2}
    END
    FOR    ${line}    IN    @{request_messages_to_SAS_1_1}
        Compare Messages    ${line}    ${registration_requests_to_SAS_1_1}
    END
    FOR    ${line}    IN    @{request_messages_to_SAS_1_0}
        Compare Messages    ${line}    ${registration_requests_to_SAS_1_0}
    END

    [Teardown]    Run Keywords    Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Wait Until BTS Is Not Busy    AND
    ...                           Delete ICG And CCG Group ID    AND
    ...                           Remove SASUSERGROUP    AND
    ...                           Get SAS Logs To Logs Dir    alias=default
