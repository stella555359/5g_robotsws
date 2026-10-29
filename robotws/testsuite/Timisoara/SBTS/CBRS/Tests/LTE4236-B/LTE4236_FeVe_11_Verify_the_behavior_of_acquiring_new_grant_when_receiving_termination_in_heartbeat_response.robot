*** Settings ***
Documentation
...    = Author =
...    Lukasz.lechowicz@nokia.com
...    = Maintainer =
...    Lukasz.lechowicz@nokia.com
...    = Reviewer =
...    = Summary =
...    Purpose: Verify the behavior of acquiring new grant when receiving termination in heartbeat response

*** Keywords ***
LTE4236_FeVe_11_Verify_the_behavior_of_acquiring_new_grant_when_receiving_termination_in_heartbeat_response
    [Documentation]  Requirement: OM_GEN_SFS_CBRS.355

    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    &{expected_alarm_1}   Create Dictionary    fault_id=6823    fault_name=SAS Grant Termination Revocation Failure    severity=Critical
    &{expected_alarm_2}   Create Dictionary    fault_id=6828    fault_name=SAS Grant Failure    severity=Critical
    ${expected_alarms_list}   Create List    ${expected_alarm_1}    ${expected_alarm_2}
    ${expected_alarms_objects}   Create Watchdog Alarm List    ${expected_alarms_list}

    Wait Until BTS Is Not Busy

    Kill All SAS Processes
    Check If Cells Are Disabled    ${enb_id}  ##OPTIONAL STEP

    ${AEQM_present}   Run Keyword And Return Status    Query Infomodel    timeout=30    alias=RAT_1ST
    ...    query=check /MRBTS-*/RAT-*/BTS_L-*/EQM_L-*/RMOD_L-* is [productName=regex"(?i)AEQM"]

    Enable CBRS Feature On eNB
    IF  '${AEQM_present}'=='False'
        ${sas_pid}  ${sas_logs_dir}  Start SAS Process    config=${CURDIR}/Data/FeVe11/SAS_Sim.conf
    ELSE
        ${sas_pid}  ${sas_logs_dir}  Start SAS Process    config=${CURDIR}/Data/FeVe11/SAS_Sim_AEQM.conf
    END

    Wait For All Cells To Be OnAir
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}
    ${cbsd_id}   Fetch CBSD ID    ${enb_id}
    Log To Console    Starting loop...
    FOR    ${i}    IN RANGE    10
        ${active_grant_list}   List Values of GrantId For All Cells    ${enb_id}
        ${random_grant_to_terminate}   evaluate    random.choice(${active_grant_list})    modules=random
        ${grant_terminate_time}   Get Time

        Terminate Grant And Confirm Cell Drop    cbsd_id=${cbsd_id}    grant_id=${random_grant_to_terminate}    print_details=False

        Append To File    ${TEST_LOGS_DIR_PATH}/GrantTerminatingHistory.txt
        ...    ${grant_terminate_time} Grant ${random_grant_to_terminate} -- TERMINATED ${\n}

        Log To Console    Grant ${random_grant_to_terminate} terminated on ${grant_terminate_time}

        Wait For All Cells To Be OnAir

        ${new_active_grant_list}   List Values of GrantId For All Cells    ${enb_id}
        Should Not Be Equal    ${new_active_grant_list}      ${active_grant_list}

        ${grant_free_time}   Get Time
        Send Command To SAS Manager    alias=default    command=grant_free ${cbsd_id} ${random_grant_to_terminate}

        Append To File    ${TEST_LOGS_DIR_PATH}/GrantTerminatingHistory.txt
        ...    ${grant_free_time} Grant ${random_grant_to_terminate} -- termination cleared ${\n}

        Log To Console    Grant ${random_grant_to_terminate} freed on ${grant_free_time}
        Watchdog Check For Failures
    END
    Wait For Watchdog Alarm Deactivation    fault_id=${expected_alarm_1}[fault_id]    fault_name=${expected_alarm_1}[fault_name]
    ...                                     severity=${expected_alarm_1}[severity]    timeout=60
    Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm_1}[fault_id]    fault_name=${expected_alarm_1}[fault_name]
    ...                                        severity=${expected_alarm_1}[severity]

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Kill All SAS Processes
