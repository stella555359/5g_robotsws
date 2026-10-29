*** Settings ***
Documentation
...    = Author =
...    michal.moskala@nokia.com
...    = Maintainer =
...    michal.moskala@nokia.com
...    = Reviewer =
...    lukasz.lechowicz@nokia.com
...    artur.czainski@nokia.com
...    = Summary =
...    The purpose of this test case is to check when the feature is activated,
...    if all frequency grants utilized by existing/current Tx carriers are terminated,
...    PreTx measurement is not restricted by timer CbsdMeasurementPeriod.

*** Keywords ***
CBRS_LTE3974_FeVe_13_Verify_CBRS_Pre-Tx_measurement_is_triggered_if_all_grants_of_one_CBSD_are_suspended
    [Documentation]    Requirement: LTE3974_#02

    Kill All SAS Processes
    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${alias}   Set Variable    RAT_1ST
    ${measurement_timer}   Set Variable    2510
    &{expected_alarm_1}   Create Dictionary    fault_id=6825    fault_name=SAS Grant Suspension Failure    severity=Critical
    &{expected_alarm_2}   Create Dictionary    fault_id=6829    fault_name=SAS Heartbeat Failure    severity=Critical
    ${expected_alarms_list}   Create List    ${expected_alarm_1}    ${expected_alarm_2}
    ${expected_alarms_objects}   Create Watchdog Alarm List    ${expected_alarms_list}

    Change Swconfig Flag    flag=0x450075    value=${measurement_timer}
    Reset Site    connection=RAT_1ST
    ${sas_pid}    ${sas_logs_dir} =    Start SAS Process    alias=default    port=4433    config=${CURDIR}/Data/SAS_Sim.conf
    Wait For All Cells To Be OnAir
    Wait Until BTS Is Not Busy
    ${feature_is_enabled}   Run Keyword And Return Status    Check If CBRS Enhanced Measurement Feature Is Enabled
    IF  ${feature_is_enabled}==${FALSE}  Enable CBRS Enhanced Measurement Feature  enb_id=${enb_id}
    Wait For All Cells To Be OnAir
    ${required_spectrum}   Create List    3550    3555    3560    3565    3570    3575    3580    3585
    Set Supported Spectrum    bts_id=${enb_id}    target_spectrum_list=${required_spectrum}
    Wait For All Cells To Be OnAir
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}

    ${cbsd_id}   Fetch CBSD ID    enb_id=${enb_id}
    ${first_measurement_result}   Fetch Measurement Results
    ${enabled_cells_list}   List Phycell Values For All Cells    enb_id=${enb_id}
    ${num_of_cells}   Get Number of Cells    ${enb_id}

    FOR    ${i}    IN RANGE    ${num_of_cells}
        ${cellGrantId}   Fetch Grant ID Of Selected Cell    enb_id=${enb_id}    cell_number=${enabled_cells_list[${i}]}
        Send Command To SAS Manager    alias=default    command=grant_suspend ${cbsdId} ${cellGrantId}
    END

    Wait For Any Cell To Be Dropped    wait_time=9min
    Wait For Watchdog Alarm Activation    fault_id=${expected_alarm_1}[fault_id]    fault_name=${expected_alarm_1}[fault_name]
    ...                                   severity=${expected_alarm_1}[severity]    timeout=30
    Sleep    120s

    FOR    ${i}    IN RANGE    ${num_of_cells}
        ${cellGrantId}   Fetch Grant ID Of Selected Cell    enb_id=${enb_id}    cell_number=${enabled_cells_list[${i}]}
        Send Command To SAS Manager    alias=default    command=grant_free ${cbsdId} ${cellGrantId}
    END

    Wait For All Cells To Be OnAir
    Wait For Watchdog Alarm Deactivation    fault_id=${expected_alarm_1}[fault_id]    fault_name=${expected_alarm_1}[fault_name]
    ...                                     severity=${expected_alarm_1}[severity]    timeout=30
    Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm_1}[fault_id]    fault_name=${expected_alarm_1}[fault_name]
    ...                                        severity=${expected_alarm_1}[severity]

    ${second_measurement_result}   Fetch Measurement Results
    Check If The CBRS Enhanced Measurement Occured    ${first_measurement_result}    ${second_measurement_result}

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Restore Supported Spectrum    bts_id=${enb_id}    AND
    ...                           Kill All SAS Processes    AND
    ...                           Wait Until BTS Is Not Busy    AND
    ...                           Remove Swconfig Flag    0x450075
