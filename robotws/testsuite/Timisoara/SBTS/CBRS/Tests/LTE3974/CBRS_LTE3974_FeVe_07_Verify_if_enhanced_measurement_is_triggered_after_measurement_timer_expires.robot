*** Settings ***
Documentation
...    = Author =
...    michal.moskala@nokia.com
...    = Maintainer =
...    michal.moskala@nokia.com
...    = Reviewer =
...    bartosz.rutkowski@nokia.com
...    aleksandra.dagiel@nokia.com
...    karol.palamarz@nokia.com
...    artur.czainski@nokia.com
...    lukasz.lechowicz@nokia.com
...    = Summary =
...    The purpose of this test case is to check when the feature is activated, at least some certain time
...    (xxx minutes - defined by a R&D parameter) have passed since last measurement (including preTx measurement),
...    if eNB want to get a new frequency inquiry triggered by grant suspension,
...    eNB would execute enhanced RSSI measurement.

*** Keywords ***
CBRS_LTE3974_FeVe_07_Verify_if_enhanced_measurement_is_triggered_after_measurement_timer_expires
    [Documentation]    Requirement: LTE3974_#02

    Kill All SAS Processes
    ${enb_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${alias}   Set Variable    RAT_1ST
    ${measurement_timer}   Set Variable    60
    ${suspended_cell_number}   Set Variable    1
    &{expected_alarm}   Create Dictionary    fault_id=6825    fault_name=SAS Grant Suspension Failure    severity=Critical
    ...                                        reason=responseCode : 501 transmitExpireTime expires.
    ${expected_alarms_objects}   Create Watchdog Alarm List     ${expected_alarm}

    Change Swconfig Flag    flag=0x45000c    value=${measurement_timer}
    Reset Site    connection=RAT_1ST
    Enable CBRS Feature On eNB
    ${sas_pid}    ${sas_logs_dir} =    Start SAS Process    alias=default    port=4433    config=${CURDIR}/Data/SAS_Sim.conf
    Wait For All Cells To Be OnAir

    ${feature_is_enabled}   Run Keyword And Return Status    Check If CBRS Enhanced Measurement Feature Is Enabled
    IF  ${feature_is_enabled}==${FALSE}  Enable CBRS Enhanced Measurement Feature  enb_id=${enb_id}
    Wait For All Cells To Be OnAir
    Restore Supported Spectrum    bts_id=${enb_id}
    Wait For All Cells To Be OnAir
    Start Watchdog Alarm Detection    expected_alarms=${expected_alarms_objects}

    ${cbsd_id}   Fetch CBSD ID    enb_id=${enb_id}
    ${first_measurement_result}   Fetch Measurement Results
    ${cellGrantId}   Fetch Grant ID Of Selected Cell    enb_id=${enb_id}    cell_number=${suspended_cell_number}
    Sleep And Display Progress    waiting_time=${measurement_timer}    unit=s  #sleep is necessary since the measurement timer must pass

    Send Command To SAS Manager    alias=default    command=grant_suspend ${cbsdId} ${cellGrantId}
    Wait For Any Cell To Be Dropped    wait_time=10min
    Wait For All Cells To Be OnAir

    ${second_measurement_result}   Fetch Measurement Results
    Check If The CBRS Enhanced Measurement Occured    ${first_measurement_result}    ${second_measurement_result}

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Kill All SAS Processes    AND
    ...                           Remove Swconfig Flag    0x45000c
