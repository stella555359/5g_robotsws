*** Settings ***
Documentation
...    = Author =
...    Lukasz.lechowicz@nokia.com
...    = Maintainer =
...    Lukasz.lechowicz@nokia.com
...    = Reviewer =
...    michal.moskala@nokia.com
...    albert.sakowicz@nokia.com
...    = Summary =
...    Purpose: EDA CAS-307092 improvement - A new scenario verifying if eNB handles SAS communication breaks correctly

*** Keywords ***
CBRS_Robustness_04_grantResponse_not_received_periodically
    [Documentation]    Requirement: OM_GEN_SFS_CBRS.314

    ${ims_alias}   Set Variable    RAT_1ST
    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    &{expected_alarm_1}   Create Dictionary    fault_id=6829    fault_name=SAS Heartbeat Failure    severity=Critical
    &{expected_alarm_2}   Create Dictionary    fault_id=6825    fault_name=SAS Grant Suspension Failure    severity=Critical
    ...                                          reason=responseCode : 501 transmitExpireTime expires.

    Kill All SAS Processes
    ${sas_pid}    ${sas_logs_dir} =    Start SAS Process    config=${CURDIR}/Data/Robustness_04/SAS_Sim.conf

    Wait For All Cells To Be OnAir
    Start Watchdog Alarm Detection

    ${cbsd_id}   Fetch CBSD ID    ${enb_id}
    FOR  ${i}    IN RANGE    12
        ${iteration}   Evaluate    ${i}+1
        ${active_grant_list}   List Values of GrantId For All Cells    ${enb_id}
        ${random_grant_to_suspend}   Evaluate    random.choice(${active_grant_list})    modules=random
        Add Fault To Watchdog Ignored List    fault_id=${expected_alarm_1}[fault_id]    fault_name=${expected_alarm_1}[fault_name]
        ...                                   severity=${expected_alarm_1}[severity]
        Add Fault To Watchdog Ignored List    fault_id=${expected_alarm_2}[fault_id]    fault_name=${expected_alarm_2}[fault_name]
        ...                                   severity=${expected_alarm_2}[severity]    reason=${expected_alarm_2}[reason]
        ${grant_suspend_time}   Get Time
        Send Command To SAS Manager    alias=default    command=grant_suspend ${cbsd_id} ${random_grant_to_suspend}
        Append To File    ${TEST_LOGS_DIR_PATH}/GrantSuspendingHistory.txt
        ...               ${grant_suspend_time} Grant ${random_grant_to_suspend} -- SUSPENDED ${\n}
        Log To Console    Iteration ${iteration} - Grant ${random_grant_to_suspend} suspended on ${grant_suspend_time}
        Wait For Any Cell To Be Dropped
        Wait For All Cells To Be OnAir
        Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm_1}[fault_id]    fault_name=${expected_alarm_1}[fault_name]
        ...                                        severity=${expected_alarm_1}[severity]
        Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm_2}[fault_id]    fault_name=${expected_alarm_2}[fault_name]
        ...                                        severity=${expected_alarm_2}[severity]    reason=${expected_alarm_2}[reason]
        Watchdog Check For Failures
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
