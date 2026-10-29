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
CBRS_LTE5703_FeVe_45_Suspended_grant_gets_responseCode_502_before_transmitExpireTime_reached
    [Documentation]    The purpose of this test is to verify whether eNB behaves correctly when channel suspension
    ...                is released before transmit expiry time is reached. It is realized by SAS Sim configuration.
    ...                Tested Requirement: OM_GEN_SFS_CBRS.381

    ${supplementary_info}   Catenate    SEPARATOR=${SPACE}    Heartbeat Exception with Reason: 502. ResponseMessage:
    ...    Operation parameters or Grant state(s) is/are out of sync between the CBSD and the SAS.
    &{expected_alarm}   Create Dictionary    fault_id=6829    fault_name=SAS Heartbeat Failure    severity=Critical
    ...                                        reason=${supplementary_info}
    ${expected_alarms_objects}   Create Watchdog Alarm List     ${expected_alarm}
    Disable CBRS Feature On eNB
    Kill All SAS Processes

    Log To Console    Setting SAS to respond 501 for 3nd heartbeat and then send out of sync (502)
    ${sas_pid}    ${sas_log}   Start SAS Process    config=${CURDIR}/Data/SAS_conf_45.conf
    Enable CBRS Feature On eNB

    Log To Console    CBRS enabled, waiting to get onair
    Wait For All Cells To Be OnAir
    BTS Operational State Should Be OnAir
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}
    Log To Console    Waiting for suspend and out of sync
    Wait For Watchdog Alarm Activation    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                   severity=${expected_alarm}[severity]    reason=${expected_alarm}[reason]    timeout=90
    Wait For Watchdog Alarm Deactivation    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                     severity=${expected_alarm}[severity]    reason=${expected_alarm}[reason]    timeout=30
    Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                        severity=${expected_alarm}[severity]    reason=${expected_alarm}[reason]

    Log To Console    Checking SAS log for amount of grants and suspensions
    ${sum_of_grant_request}   Run    grep 'grantRequest' ${sas_log} | wc -l
    ${sum_of_heartbeats_with_suspension}   Run    grep 'The grant is suspended' ${sas_log} | wc -l
    ${sum_of_heartbeats_with_out_of_sync}   Run    grep 'out of sync between the CBSD and the SAS' ${sas_log} | wc -l
    ${sum_of_relinquishment_requests}   Run    grep 'relinquishmentRequest' ${sas_log} | wc -l
    Log To Console    Amount of RMODs: ${SUM_OF_CBSDS}
    Log To Console    Amount of grants: ${sum_of_grant_request}
    Log To Console    Amount of suspensions: ${sum_of_heartbeats_with_suspension}
    Log To Console    Amount of out of sync: ${sum_of_heartbeats_with_out_of_sync}
    Log To Console    Amount of relinquishments: ${sum_of_relinquishment_requests}
    ${reliquishments_for_all_cbsds}   Evaluate    ${SUM_OF_CBSDS}*4
    ${grant_status}   Evaluate    ((${SUM_OF_CBSDS}-1) < ${sum_of_grant_request} < 16)
    Should Be True    ${grant_status}
    ${status_heartbeat_with_suspension}   Evaluate    (${sum_of_heartbeats_with_suspension} >= ${SUM_OF_CBSDS})
    Should Be True    ${status_heartbeat_with_suspension}
    ${status_heartbeats_with_out_of_sync}   Evaluate    (${sum_of_heartbeats_with_out_of_sync} >= ${SUM_OF_CBSDS})
    Should Be True    ${status_heartbeats_with_out_of_sync}
    ${status_relinquishment_request}   Evaluate    (${sum_of_relinquishment_requests} >= ${reliquishments_for_all_cbsds})
    Should Be True    ${status_relinquishment_request}

    Log To Console    Grants are ok, checking if eNB onair again
    Wait For All Cells To Be OnAir
    BTS Operational State Should Be OnAir
    Log To Console    eNB is onair, checking historical alarms

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures
