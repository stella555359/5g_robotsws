*** Settings ***
Documentation
...    = Author = Albert Sakowicz
...    _albert.sakowicz@nokia.com_
...    = Maintainer = Albert Sakowicz
...    _albert.sakowicz@nokia.com_
...    = Reviewer = Aleksandra Dagiel
...    _aleksandra.dagiel@nokia.com_
...    = Pre - Requirements =
...    _robotlte/config/<testline name>/__init__.py and site specific keyword_

*** Keywords ***
CBRS_LTE5703_FeVe_44_Suspended_grant_is_terminated_before_transmitExpireTime_reached
    [Documentation]    The purpose of this test is to verify whether eNB behaves correctly when channel suspension
    ...                is released before transmit expiry time is reached. It is realized by SAS Sim configuration.
    ...                Tested Requirement: OM_GEN_SFS_CBRS.381

    &{expected_alarm}   Create Dictionary    fault_id=6823    fault_name=SAS Grant Termination Revocation Failure    severity=Critical
    ...                                        reason=Heartbeat Exception with Reason: 500.
    ${expected_alarms_objects}   Create Watchdog Alarm List    ${expected_alarm}
    Disable CBRS Feature On eNB
    Kill All SAS Processes

    Log To Console    Setting SAS to respond 500 for 3rd heartbeat and then terminate it
    ${sas_pid}    ${sas_log}   Start SAS Process    config=${CURDIR}/Data/SAS_conf_44.conf
    ${start_time}   Get Time
    Enable CBRS Feature On eNB
    Log To Console    CBRS enabled, waiting to get onair
    Wait For All Cells To Be OnAir
    BTS Operational State Should Be OnAir
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}

    Log To Console    Waiting for suspend and it's termination
    Wait For Any Cell To Be Dropped
    Wait For Watchdog Alarm Activation    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                   severity=${expected_alarm}[severity]    reason=${expected_alarm}[reason]    timeout=60
    Wait For All Cells To Be OnAir
    Wait For Watchdog Alarm Deactivation    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                     severity=${expected_alarm}[severity]    reason=${expected_alarm}[reason]    timeout=60
    Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                        severity=${expected_alarm}[severity]    reason=${expected_alarm}[reason]
    ${stop_time}   Get Time
    ${parsed_log}   Parse Sas Log File    log_file_name=${sas_log}
    ...                                     date_start=${start_time}
    ...                                     date_stop=${stop_time}
    ${parsed_log}   Convert To String    ${parsed_log}
    ${parsed_log_file}   Create File    path=${CURDIR}/Data/SAS_log.json    content=${parsed_log}

    Log To Console    Checking SAS log for amount of grants and suspensions
    ${sum_of_grant_request}   Run    grep -o 'grantRequest' ${CURDIR}/Data/SAS_log.json | wc -l
    ${sum_of_heartbeats_with_suspension}   Run    grep 'The grant is suspended' ${CURDIR}/Data/SAS_log.json | wc -l
    ${amout_of_heartbeats_with_termination}   Run    grep 'The grant is terminated' ${CURDIR}/Data/SAS_log.json | wc -l
    ${sum_of_relinquishment_requests}   Run    grep 'relinquishmentRequest' ${CURDIR}/Data/SAS_log.json | wc -l
    Log To Console    Amount of RMODs: ${SUM_OF_CBSDS}
    Log To Console    Amount of grants: ${sum_of_grant_request}
    Log To Console    Amount of suspensions: ${sum_of_heartbeats_with_suspension}
    Log To Console    Amount of terminations: ${amout_of_heartbeats_with_termination}
    Log To Console    Amount of relinquishments: ${sum_of_relinquishment_requests}
    ${grants_for_all_cbsds}   Evaluate    ${SUM_OF_CBSDS}*2
    Should Be Equal As Numbers    ${sum_of_grant_request}    ${grants_for_all_cbsds}
    Should Be Equal As Numbers    ${sum_of_heartbeats_with_suspension}    ${SUM_OF_CBSDS}
    Should Be Equal As Numbers    ${amout_of_heartbeats_with_termination}    ${SUM_OF_CBSDS}
    Should Be Equal As Numbers    ${sum_of_relinquishment_requests}    0

    Log To Console    Grants are ok, checking if eNB onair again
    Wait For All Cells To Be OnAir
    BTS Operational State Should Be OnAir
    Log To Console    eNB is onair, checking historical alarms

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures
