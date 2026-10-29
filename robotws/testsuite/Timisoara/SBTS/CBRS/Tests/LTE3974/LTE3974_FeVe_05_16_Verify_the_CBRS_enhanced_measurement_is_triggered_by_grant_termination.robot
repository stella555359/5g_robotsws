*** Settings ***
Documentation
...    = Author =
...    michal.moskala@nokia.com
...    = Maintainer =
...    michal.moskala@nokia.com
...    = Reviewer =
...    bartosz.rutkowski@nokia.com
...    aleksandra.dagiel@nokia.com
...    = Summary =
...    The purpose of this test case is to check when the feature is activated, at least some certain time
...    (xxx minutes - defined by a R&D parameter) have passed since last measurement (including preTx measurement),
...    if eNB want to get a new frequency inquiry triggered by grant termination,
...    eNB would executes enhanced RSSI measurement and to check when the feature is activated,
...    CBRS enhanced measurement is only applied on the support spectrum.

*** Keywords ***
LTE3974_FeVe_05_16_Verify_the_CBRS_enhanced_measurement_is_triggered_by_grant_termination
    [Documentation]    Requirement: LTE3974_#02, OM_GEN_SFS_CBRS.365
    [Timeout]    60min

    Kill All SAS Processes
    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    &{expected_alarm}   Create Dictionary    fault_id=6823    fault_name=SAS Grant Termination Revocation Failure    severity=Critical
    ${expected_alarm_object}   Create Watchdog Alarm List    ${expected_alarm}
    ${blocked_cell_number}   Set Variable    1
    ${measurement_timer}   Set Variable    60
    Change Swconfig Flag    flag=0x45000c    value=${measurement_timer}
    taf.sbts.oam.coam.admin.Reset    alias=RAT_1ST
    ${sas_pid}    ${sas_logs_dir} =    Start SAS Process    alias=default    port=4433    config=${CURDIR}/Data/SAS_Sim.conf

    Wait For All Cells To Be OnAir
    ${time_start}   Get Time
    ${feature_is_enabled}   Run Keyword And Return Status    Check If CBRS Enhanced Measurement Feature Is Enabled
    IF  ${feature_is_enabled}==${FALSE}  Enable CBRS Enhanced Measurement Feature  ${enb_id}
    Wait For All Cells To Be OnAir
    ${required_spectrum}   Create List    3550    3555    3560    3565    3570    3575    3580    3585    3590    3595
    ...                                     3600    3605    3610    3615    3620    3625    3630    3635    3640    3645
    Set Supported Spectrum    bts_id=${enb_id}    target_spectrum_list=${required_spectrum}
    Wait For All Cells To Be OnAir
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarm_object}

    ${cbsd_id}   Fetch CBSD ID    ${enb_id}
    ${time_stop}   Get Time
    ${first_spectrum_inquiry}   Get Spectrum Inquiry Message    ${time_start}    ${time_stop}    sas_log_path=${sas_logs_dir}
    ${first_measurement_result}   Fetch Measurement Results
    ${cellGrantId}   Fetch Grant ID Of Selected Cell    enb_id=${enb_id}    cell_number=${blocked_cell_number}
    Sleep And Display Progress    ${measurement_timer}   s  #sleep is necessary since the measurement timer must pass

    ${time_start}   Get Time
    Terminate Grant And Confirm Cell Drop    cbsd_id=${cbsdId}    grant_id=${cellGrantId}
    Wait For All Cells To Be OnAir
    Wait For Watchdog Alarm Deactivation    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                     severity=${expected_alarm}[severity]    timeout=30
    Remove Fault From Watchdog Ignored List    fault_id=${expected_alarm}[fault_id]    fault_name=${expected_alarm}[fault_name]
    ...                                        severity=${expected_alarm}[severity]
    ${time_stop}   Get Time

    ${second_measurement_result}   Fetch Measurement Results
    ${second_spectrum_inquiry}   Get Spectrum Inquiry Message    ${time_start}    ${time_stop}    sas_log_path=${sas_logs_dir}
    Should Not Be Equal    ${first_measurement_result}    ${second_measurement_result}
    ${active_faults}   List Active eNB Faults

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Wait Until BTS Is Not Busy    AND
    ...                           Restore Supported Spectrum    bts_id=${enb_id}    AND
    ...                           Kill All SAS Processes    AND
    ...                           Remove Swconfig Flag    0x45000c
