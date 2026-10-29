*** Settings ***
Documentation
...    = Author =
...    michal.moskala@nokia.com
...    = Maintainer =
...    michal.moskala@nokia.com
...    = Reviewer =
...    albert.sakowicz@nokia.com
...    jakub.klein@nokia.com
...    = Summary =
...    The purpose of this test case is to check when the feature is activated,
...    if all frequency grants utilized by existing/current Tx carriers are reliquished,
...    PreTx measurement is not restricted by timer CbsdMeasurementPeriod.

*** Keywords ***
CBRS_LTE3974_FeVe_15_Verify_CBRS_Pre-Tx_measurement_is_triggered_if_all_grants_of_one_CBSD_are_relinquished
    [Documentation]    Requirement: LTE3974_#02/OM_GEN_SFS_RNL.21589
    [Timeout]    30min

    Kill All SAS Processes
    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${measurement_timer}   Set Variable    2510
    &{expected_alarm}   Create Dictionary    fault_id=49    fault_name=Cell blocked    severity=Critical
    ${expected_alarms_objects}   Create Watchdog Alarm List     ${expected_alarm}

    Change Swconfig Flag    flag=0x450075    value=${measurement_timer}
    taf.sbts.oam.coam.admin.Reset    alias=RAT_1ST
    ${sas_pid}    ${sas_logs_dir}   Start SAS Process    alias=default    port=4433    config=${CURDIR}/Data/SAS_Sim.conf
    Wait For All Cells To Be OnAir
    Wait Until BTS Is Not Busy
    ${feature_is_enabled}   Run Keyword And Return Status    Check If CBRS Enhanced Measurement Feature Is Enabled
    IF  ${feature_is_enabled}==${FALSE}  Enable CBRS Enhanced Measurement Feature  enb_id=${enb_id}
    Wait For All Cells To Be OnAir
    Restore Supported Spectrum    bts_id=${enb_id}
    Wait For All Cells To Be OnAir
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}

    ${first_measurement_result}   Fetch Measurement Results
    ${enabled_cells_list}   List Phycell Values For All Cells    enb_id=${enb_id}
    ${num_of_cells}   Get Number of Cells    ${enb_id}
    ${runtime_view_id}   Set Variable    *

    FOR    ${i}    IN RANGE    ${num_of_cells}
        taf.sbts.oam.coam.admin.Block Cell    dist_name=/MRBTS-${enb_id}/LNBTS-${enb_id}/LNCEL-${enabled_cells_list[${i}]}    connection=RAT_1ST
        Wait For Watchdog Alarm Activation    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
        ...                                   severity=${expected_alarm}[severity]    reason=${expected_alarm}[reason]    timeout=120
    END
    Wait For Any Cell To Be Dropped

    FOR    ${i}    IN RANGE    ${num_of_cells}
        taf.sbts.oam.coam.admin.Unblock Cell    dist_name=/MRBTS-${enb_id}/LNBTS-${enb_id}/LNCEL-${enabled_cells_list[${i}]}    connection=RAT_1ST
        Wait For Watchdog Alarm Deactivation    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
        ...                                     severity=${expected_alarm}[severity]    timeout=120
        Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
        ...                                        severity=${expected_alarm}[severity]
    END

    Wait For All Cells To Be OnAir

    ${second_measurement_result}   Fetch Measurement Results
    Check If The CBRS Enhanced Measurement Occured    ${first_measurement_result}    ${second_measurement_result}

    [Teardown]    Run Keywords
    ...    Stop Watchdog Alarm Detection And Check For Failures    AND
    ...    Remove Swconfig Flag   0x450075    AND
    ...    Get SAS Logs To Logs Dir    alias=default    AND
    ...    Kill All SAS Processes    AND
    ...    Sleep    600s
           #this test uses long transmit expiry timer so I want to make sure that cells are disabled within timeout
