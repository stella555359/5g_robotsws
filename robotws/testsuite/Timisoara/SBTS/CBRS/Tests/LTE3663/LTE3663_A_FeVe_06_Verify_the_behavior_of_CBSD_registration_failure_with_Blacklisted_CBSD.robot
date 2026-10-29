*** Settings ***
Documentation    The purpose of this test case is to verify if eNB behaves correctly, when it receives
...                response code 101 (blacklisted) in the registrationResponse.
...                Requirement: OM_GEN_SFS_CBRS.348
...                Author: michal.kosicki@nokia.com
...                Maintainer: Pawel Rokicki


*** Keywords ***
LTE3663_A_FeVe_06_Verify_the_behavior_of_CBSD_registration_failure_with_Blacklisted_CBSD
    [Timeout]   15min

    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    &{expected_alarm}   Create Dictionary    fault_id=6826    fault_name=SAS Registration Failure    severity=Critical
    ${expected_alarms_objects}   Create Watchdog Alarm List    ${expected_alarm}

    Disable CBRS Feature On eNB

    ${SAS_log_time_start}   Get Time
    ${sas_pid}    ${sas_log}   Start SAS Process    config=${CURDIR}/Data/SAS_Sim_blacklist.conf
    Enable CBRS Feature On eNB
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}
    Log To Console    Waiting for all required requests being processed
    Sleep And Display Progress    30    s
    Run Keyword And Continue On Failure    Check If Cells Are Disabled    enb_id=${enb_id}    timeout=60s
    ${SAS_log_time_stop}   Get Time

    ${parsed_log_file}   Parse Sas Log File    log_file_name=/home/ute/SASSim/default/SAS_Sim.log
    ...    date_start=${SAS_log_time_start}    date_stop=${SAS_log_time_stop}
    ${parsed_log_file}   Clear SAS Logs    ${parsed_log_file}

    Wait For Watchdog Alarm Activation    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                   severity=${expected_alarm}[severity]    timeout=30

    ${sum_of_blacklisted_messages}   Run    grep registrationResponse ${sas_log} | grep "CBSD is blacklisted" | wc -l
    ${blacklisted status}   Evaluate    0 < ${sum_of_blacklisted_messages} < 10
    Should Be True    ${blacklisted status}

    [Teardown]    Run Keywords    Kill All SAS Processes    AND
    ...                           Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures
