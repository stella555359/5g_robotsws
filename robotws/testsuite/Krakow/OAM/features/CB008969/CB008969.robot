*** Settings ***
Documentation
...   contact: Jaroslaw Lezon, Arkadiusz Kowalczyk
...   maintainer: jaroslaw.lezon@nokia.com
...
...     Description: CB008969 - Unstable eCPRI link detection
...     Purpose of this test suite is to validate BTS behaviour when eCPRI link is unstable.

Library       taf.rfrl.bts.devices.du.du_operations.GnbDuOperations    WITH NAME    gnbbbu
Library       resources/AlarmsOperations.py    WITH NAME    alarms
Library       resources/JournalObserver.py    WITH NAME    JournalObserver
Library       resources/OpticalSwitch.py    WITH NAME    OpticalSwitch
Library       resources/ScfOperations.py    WITH NAME    ScfOperations
Library       resources/UlCounters.py    WITH NAME    UlCounters
Library       resources/test_specific_keywords.py    WITH NAME    keywords
Resource      taf/rfrl/bts/robot/gnb.robot
Resource      taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource      resources/DL_counters_from_SOAP.robot
Variables     taf/rfrl/procedures/resources/python/common_allowed_alarms.py


Suite Setup       common_setups_and_teardowns.Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
Suite Teardown    common_setups_and_teardowns.Common Suite Teardown

Test Setup        Common Preconditions With Watching Alarms
Test Teardown     Common Postconditions With Watching Alarms

*** Variables ***
@{additional_allowed_alarms}       Unstable eCPRI Link Detected
${breaks_number_per_minute}=       ${1}
${interval_minutes}=               ${10}
${optical_switch}=                 ${tl.optical_switches[0]}
${first_opt_port}=                 ${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[0].rus[0].optical_switch_channels[0].channel_no}
${second_opt_port}=                ${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[0].rus[0].optical_switch_channels[1].channel_no}

*** Test Cases ***
[1][1.0] CB008969_1_CB008969_Unstable_eCPRI_link_detection_link_lost_ SM
    alarms.Verify that fault is not present in active alarms
    Write and read R&D parameters L3    interval=${interval_minutes}
    ${interval_miliseconds}=    Evaluate    ${interval_minutes} * ${60000}
    Set and get R&D parameter L1    interval=${interval_miliseconds}
    UlCounters.enable_debug_logs_in_journal
    OpticalSwitch.Setup Optical Switch Connection    optical_switch_device=${optical_switch}    alias=OPT_SWITCH
    ${defined_time}    ${previous_journal_results}    Get UL and DL interval start times
    ...    link_id=${1}    port_number=${first_opt_port}
    ${previous_journal_results}=    Verify fault triggering and clearing on specified link    defined_time=${defined_time}
    ...    link_id=${1}    port_number=${first_opt_port}    previous_journal_results=${previous_journal_results}
    ${previous_journal_results}=    Verify fault triggering and clearing on specified link    defined_time=${defined_time}
    ...    link_id=${2}    port_number=${second_opt_port}    previous_journal_results=${previous_journal_results}

*** Keywords ***
Set and get R&D parameter L1
    [Arguments]    ${interval}
    gnbbbu.Set RAD Parameter Value    link_meas_window_len    ${interval}
    gnbbbu.Set RAD Parameter Value    link_down_meas_threshold    ${breaks_number_per_minute}
    ${window_len}=    gnbbbu.Get RAD Parameter Value    link_meas_window_len
    ${meas_threshold}=    gnbbbu.Get RAD Parameter Value    link_down_meas_threshold

Write and read R&D parameters L3
    [Arguments]    ${interval}
    gnbbbu.Set BTS rad parameters    component=25    params=601:${interval}
    gnbbbu.Set BTS rad parameters    component=25    params=604:${breaks_number_per_minute}
    gnbbbu.Reset Bts
    Wait until keyword succeeds     10 min    30    Verify gNB is onAir
    gnbbbu.Get BTS rad parameters      parameters_type=Requested

Get UL and DL interval start times
    [Arguments]    ${link_id}    ${port_number}
    OpticalSwitch.Trigger Short Link Break    alias=OPT_SWITCH    measurement_interval=${interval_minutes}
    ...    port_number=${port_number}    breaks_number=${4}
    ${pcs_status_change}    ${order}    CHECK_COUNTERS_receiverPcsStatusChangeCount    update_ru_ip=${True}
    ${dl_timestamp}    ${ul_timestamp}    alarms.Wait for fault    link_id=${link_id}    timeout=${interval_minutes}
    Start journal observer
    Sleep    ${interval_minutes} minutes
    ${results}=    Stop journal observer
    ${previous_journal_results}=    keywords.Validate link break number    breaks_number=${4}    interval=${interval_minutes}
    ...    journal_results=${results}    link_id=${link_id}    soap_results=${pcs_status_change}    validate=${False}
    ${defined_time}=    keywords.Wait until the start of measurement window    interval=${interval_minutes}
    ...    dl_timestamp=${dl_timestamp}    ul_timestamp=${ul_timestamp}
    [Return]    ${defined_time}    ${previous_journal_results}

Trigger Unstable eCPRI Link Fault
    [Arguments]    ${defined_time}    ${link_id}    ${port_number}    ${previous_journal_results}
    Start journal observer
    ${difference}=    keywords.Wait until the start of measurement window    interval=${interval_minutes}    defined_time=${defined_time}
    OpticalSwitch.Trigger Short Link Break    alias=OPT_SWITCH    measurement_interval=${interval_minutes}    port_number=${port_number}
    ...    timeframe=${difference[2]}    breaks_number=${breaks_number_per_minute}
    Wait until the next minute
    ${pcs_status_change}    ${order}    CHECK_COUNTERS_receiverPcsStatusChangeCount
    ${dl_timestamp}    ${ul_timestamp}    alarms.Wait for fault    link_id=${link_id}     timeout=${interval_minutes}
    ${results}=    Stop journal observer
    ${breaks_number}=    Evaluate     ${interval_minutes} * ${breaks_number_per_minute}
    ${previous_journal_results}=    keywords.Validate link break number    breaks_number=${breaks_number}
    ...    journal_results=${results}    link_id=${link_id}    soap_results=${pcs_status_change}
    ...    previous_journal_results=${previous_journal_results}    order=${order}    interval=${interval_minutes}
    [Return]    ${dl_timestamp}    ${ul_timestamp}    ${previous_journal_results}

Wait for fault clearing
    [Arguments]    ${dl_timestamp}    ${ul_timestamp}    ${link_id}    ${previous_journal_results}
    Start journal observer
    Sleep    ${interval_minutes} minutes
    ${results}=    Stop journal observer
    ${pcs_status_change}    ${order}    CHECK_COUNTERS_receiverPcsStatusChangeCount
    ${previous_journal_results}=    keywords.Validate link break number    breaks_number=${0}    journal_results=${results}
    ...    link_id=${link_id}    soap_results=${pcs_status_change}
    ...    previous_journal_results=${previous_journal_results}    order=${order}    interval=${interval_minutes}
    alarms.Verify that fault is not present in active alarms
    alarms.Verify that fault is present in alarms history
    ...    dl_timestamp=${dl_timestamp}    ul_timestamp=${ul_timestamp}    interval=${interval_minutes}
    [Return]        ${previous_journal_results}

Verify fault triggering and clearing on specified link
    [Arguments]    ${defined_time}    ${link_id}    ${port_number}    ${previous_journal_results}
    alarms.Verify that fault is not present in active alarms
    ${dl_timestamp}    ${ul_timestamp}    ${previous_journal_results}    Trigger Unstable eCPRI Link Fault
    ...    defined_time=${defined_time}    link_id=${link_id}
    ...    port_number=${port_number}    previous_journal_results=${previous_journal_results}
    ${previous_journal_results}=    Wait for fault clearing    dl_timestamp=${dl_timestamp}
    ...    ul_timestamp=${ul_timestamp}     link_id=${link_id}    previous_journal_results=${previous_journal_results}
    [Return]        ${previous_journal_results}
