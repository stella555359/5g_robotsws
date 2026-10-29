*** Settings ***
Documentation
...    = Author =
...    Lukasz.lechowicz@nokia.com
...    = Maintainer =
...    Lukasz.lechowicz@nokia.com
...    = Reviewer =
...    Artur.Czainski@nokia.com
...    = Summary =
...    Purpose: Verify the behavior of acquiring new grant when receiving suspension in heartbeat response

*** Keywords ***
LTE4236_FeVe_07_Verify_the_behavior_of_acquiring_new_grant_when_receiving_suspension_in_heartbeat_response
    [Documentation]  Requirement: OM_GEN_SFS_CBRS.314

    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    &{expected_alarm}   Create Dictionary    fault_id=6825    fault_name=SAS Grant Suspension Failure    severity=Critical
    ...                                        reason=responseCode : 501 transmitExpireTime expires.
    ${expected_alarms_objects}   Create Watchdog Alarm List     ${expected_alarm}

    Kill All SAS Processes
    Check If Cells Are Disabled    ${enb_id}

    ${AEQM_present}   Run Keyword And Return Status    Query Infomodel    timeout=30    alias=RAT_1ST
    ...    query=check /MRBTS-*/RAT-*/BTS_L-*/EQM_L-*/RMOD_L-* is [productName=regex"(?i)AEQM"]

    Enable CBRS Feature On eNB

    IF  '${AEQM_present}'=='False'
        ${sas_pid}  ${sas_logs_dir}  Start SAS Process    config=${CURDIR}/Data/FeVe07/SAS_Sim.conf
    ELSE
        ${sas_pid}  ${sas_logs_dir}  Start SAS Process    config=${CURDIR}/Data/FeVe07/SAS_Sim_AEQM.conf
    END
    Wait For All Cells To Be OnAir

    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}
    ${cbsd_id}   Fetch CBSD ID    ${enb_id}
    Log To Console    Starting loop...
    FOR  ${i}   IN RANGE   10
        Wait For All Cells To Be OnAir
        ${active_grant_list}   List Values of GrantId For All Cells    ${enb_id}
        ${random_grant_to_suspend}   Evaluate    random.choice(${active_grant_list})    modules=random
        ${grant_suspend_time}   Get Time
        Send Command To SAS Manager    alias=default    command=grant_suspend ${cbsd_id} ${random_grant_to_suspend}

        Append To File    ${TEST_LOGS_DIR_PATH}/GrantSuspendingHistory.txt
        ...    ${grant_suspend_time} Grant ${random_grant_to_suspend} -- SUSPENDED ${\n}

        Log To Console    Grant ${random_grant_to_suspend} suspended on ${grant_suspend_time}
        Wait For Any Cell To Be Dropped
        Wait For All Cells To Be OnAir

        ${new_active_grant_list}   List Values of GrantId For All Cells    ${enb_id}
        Should Not Be Equal    ${new_active_grant_list}    ${active_grant_list}
        ${grant_free_time}   Get Time
        Send Command To SAS Manager    alias=default    command=grant_free ${cbsd_id} ${random_grant_to_suspend}
        Append To File    ${TEST_LOGS_DIR_PATH}/GrantSuspendingHistory.txt
        ...    ${grant_free_time} Grant ${random_grant_to_suspend} -- suspension cleared ${\n}

        Log To Console    Grant ${random_grant_to_suspend} freed on ${grant_free_time}
    END

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Kill All SAS Processes
