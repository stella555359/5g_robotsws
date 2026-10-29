*** Settings ***
Documentation
...    = Author =
...    michal.moskala@nokia.com
...    = Maintainer =
...    michal.moskala@nokia.com
...    = Reviewer =
...    aleksandra.dagiel@nokia.com
...    = Summary =
...    The purpose of this test case is to check when the feature is activated, when the measurement timer expires,
...    if eNB want to get a new frequency inquiry triggered by relinquishment,
...    eNB executes enhanced RSSI measurement.

*** Keywords ***
CBRS_LTE3974_FeVe_09_Verify_the_CBRS_enhanced_measurement_is_triggered_by_grant_relinquishment_after_the_measurement_timer_expires
    [Documentation]    Requirement: LTE3974_#02, OM_GEN_SFS_CBRS.365
    [Timeout]    30min

    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    &{expected_alarm}   Create Dictionary    fault_id=49    fault_name=Cell blocked    severity=Critical
    ${expected_alarms_objects}   Create Watchdog Alarm List     ${expected_alarm}
    ${blocked_cell_number}   Set Variable    1
    ${measurement_timer}   Set Variable    60
    Kill All SAS Processes
    Change Swconfig flag    flag=0x45000c    value=60
    taf.sbts.oam.coam.admin.Reset    alias=RAT_1ST
    ${time_start}   Get Time
    ${sas_pid}    ${sas_logs_dir} =    Start SAS Process    alias=default    port=4433    config=${CURDIR}/Data/SAS_Sim.conf
    Wait For All Cells To Be OnAir

    ${feature_is_enabled}   Run Keyword And Return Status    Check If CBRS Enhanced Measurement Feature Is Enabled
    IF  ${feature_is_enabled}==${FALSE}  Enable CBRS Enhanced Measurement Feature  enb_id=${enb_id}
    Wait For All Cells To Be OnAir
    Restore Supported Spectrum    bts_id=${enb_id}
    Wait For All Cells To Be OnAir
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}

    ${enb_id}    Set Variable    ${testlines.${testline_id}.enb_id}
    ${cbsd_id}   Fetch CBSD ID    ${enb_id}
    ${time_stop}   Get Time
    ${first_measurement_result}   Fetch Measurement Results
    ${cellGrantId}   Fetch Grant ID Of Selected Cell    enb_id=${enb_id}    cell_number=${blocked_cell_number}

    Sleep And Display Progress    ${measurement_timer}   s  #sleep is necessary since the measurement timer must pass
    taf.sbts.oam.coam.admin.Block Cell    dist_name=/MRBTS-${enb_id}/LNBTS-${enb_id}/LNCEL-${blocked_cell_number}    connection=RAT_1ST
    Wait For Any Cell To Be Dropped
    Wait For Watchdog Alarm Activation    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                   severity=${expected_alarm}[severity]    timeout=60

    taf.sbts.oam.coam.admin.Unblock Cell    dist_name=/MRBTS-${enb_id}/LNBTS-${enb_id}/LNCEL-${blocked_cell_number}    connection=RAT_1ST
    Wait For All Cells To Be OnAir
    Wait For Watchdog Alarm Deactivation    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                     severity=${expected_alarm}[severity]    timeout=60
    Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                        severity=${expected_alarm}[severity]

    ${second_measurement_result}   Fetch Measurement Results
    Check If The CBRS Enhanced Measurement Occured    ${first_measurement_result}    ${second_measurement_result}

    [Teardown]    Run Keywords
    ...    Get SAS Logs To Logs Dir    alias=default    AND
    ...    Stop Watchdog Alarm Detection And Check For Failures    AND
    ...    Kill All SAS Processes
