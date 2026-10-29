*** Settings ***
Documentation
...    = Author =
...    michal.moskala@nokia.com
...    = Maintainer =
...    michal.moskala@nokia.com
...    = Reviewer =
...    lukasz.lechowicz@nokia.com
...    piotr.lukaszewicz@nokia.com
...    katarzyna.olszewska@nokia.com
...    = Summary =
...    The purpose of this test case is to check when the following requirements are met:
...    -feature is activated,
...    -the measurement timer expired,
...    -eNB wants to get a new frequency inquiry triggered by new carrier creation,
...    eNB would execute enhanced RSSI measurement

*** Keywords ***
CBRS_LTE3974_FeVe_11_Verify_the_CBRS_enhanced_measurement_is_triggered_by_new_carrier_creation_after_the_measurement_timer_expires
    [Documentation]    Requirement: OM_GEN_SFS_CBRS.365
    [Timeout]    30min

    Kill All SAS Processes
    ${enb_id}    Set Variable    ${testlines.${testline_id}.enb_id}
    ${alias}     Set Variable    RAT_1ST
    ${measurement_timer}       Set Variable    60
    ${blocked_cell_number}   Set Variable    1
    &{expected_alarm}   Create Dictionary    fault_id=49    fault_name=Cell blocked    severity=Critical
    ${expected_alarms_objects}   Create Watchdog Alarm List     ${expected_alarm}

    Change Swconfig Flag    flag=0x45000c    value=${measurement_timer}
    taf.sbts.oam.coam.admin.Reset    alias=RAT_1ST
    ${sas_pid}    ${sas_logs_dir} =    Start SAS Process    alias=default    port=4433    config=${CURDIR}/Data/SAS_Sim.conf
    Wait For All Cells To Be OnAir
    ${feature_is_enabled}   Run Keyword And Return Status      Check If CBRS Enhanced Measurement Feature Is Enabled
    IF  ${feature_is_enabled}==${FALSE}  Enable CBRS Enhanced Measurement Feature  enb_id=${enb_id}
    ${runtime_view_id}   Set Variable    *
    Wait Until BTS Is Not Busy
    taf.sbts.oam.coam.admin.Block Cell    dist_name=/MRBTS-${enb_id}/LNBTS-${enb_id}/LNCEL-${blocked_cell_number}    connection=RAT_1ST

    Wait Until BTS Is Not Busy
    Disable CBRS Feature On eNB
    Wait Until BTS Is Not Busy
    Enable CBRS Feature On eNB
    Wait Until BTS Is Not Busy
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}

    ${cbsd_id}   Fetch CBSD ID    enb_id=${enb_id}
    ${first_measurement_result}   Fetch Measurement Results
    ${cellGrantId}   Fetch Grant ID Of Selected Cell    enb_id=${enb_id}    cell_number=${blocked_cell_number}
    Sleep And Display Progress    waiting_time=${measurement_timer}   unit=s  #sleep is necessary since the measurement timer must pass
    taf.sbts.oam.coam.admin.Unblock Cell    dist_name=/MRBTS-${enb_id}/LNBTS-${enb_id}/LNCEL-${blocked_cell_number}    connection=RAT_1ST
    Wait For All Cells To Be OnAir
    Wait For Watchdog Alarm Deactivation    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                     severity=${expected_alarm}[severity]    timeout=60
    Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                        severity=${expected_alarm}[severity]

    ${second_measurement_result}   Fetch Measurement Results
    Check If The CBRS Enhanced Measurement Occured    ${first_measurement_result}    ${second_measurement_result}

    [Teardown]    Run Keywords    Stop Watchdog Alarm Detection And Check For Failures
    ...                           AND    Remove Swconfig Flag    0x45000c
    ...                           AND    Get SAS Logs To Logs Dir    alias=default
    ...                           AND    Kill All SAS Processes
