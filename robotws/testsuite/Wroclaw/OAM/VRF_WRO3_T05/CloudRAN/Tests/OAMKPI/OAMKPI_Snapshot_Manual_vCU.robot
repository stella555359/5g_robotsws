*** Settings ***
Documentation
    ...    This test case is used to verify the KPI for BTS and E2E Snapshot collection
    ...    for vCU.
    ...    History of changes:     04.08.2025 - Initial creation
    ...    Author:         iuliia.taupeka@nokia.com

*** Variables ***
@{vCU_KPI_BTS_results}                                 #list to store BTS KPI results
@{vCU_KPI_E2E_results}                                 #list to store E2E KPI  results
@{vCU_SNAPSHOT_SIZES_LIST}                             #list to store Collected Snapshots Sizes
@{vCU_TARGETS_FOR_SNAPSHOTS}                           #list to store choosen targets for snapshot sizes.

*** Keywords ***
OAMKPI Snapshot Manual vCU
    [Documentation]
    ...    This keyword verifies the KPI duration of Manual On Demand triggered snapshot (KPI BTS) and
    ...    whole time with upload to VM (KPI E2E).
    ...    It performs the following steps:
    ...    1. Checks vCU uptime and if less than 60 minutes waits to full hour of vCU OnAir.
    ...    2. Collects Manual Snapshot.
    ...    3. Verifies that Snapshot was downloaded to VM and file exists.
    ...    4. Calculates the KPIs results based on the time taken for the snapshot collection and download.
    ...    5. Checks Snapshot size and validates the KPI results against the targets.
    ...    6. Checks the average KPI results.
    ...    7. Generates a results file containing the KPI results, averages and target values.
    ...    Input:    test_iterations = number of iterations to run the test
    [Timeout]    12h
    [Arguments]    ${test_iterations}


    Get vCU Uptime And Wait 60min If Needed

    FOR   ${i}    IN RANGE    ${test_iterations}
        Prompt To Console    Execution measurement ${i + 1}
        Log    \n Execution measurement ${i + 1} \n    console=${True}
        ${measurement_starttime}=    DateTime.Get Current Date    time_zone=UTC
        BuiltIn.Sleep    1s    # small delay to avoid race condition
        Create Directory   ${Test_Results_Dir}/Iteration_${i}

        Log    Collect Local Snapshot    console=${True}
        ${snapshot_path}=    vcu_admin.Get Local Snapshot
        ...    directory=${Test_Results_Dir}/Iteration_${i}/
        ...    connection=${VCU_CONNECTION}
        ${snapshot_status}=    vcu_admin.check snapshot status    connection=${VCU_CONNECTION}
        Run Keyword If   '${snapshot_status}' == 'idle'
        ...   Log  Snapshot connection finished successfully. File name: ${snapshot_path}   console=${True}
        ...   ELSE IF   '${snapshot_status}'=='remote-ongoing' or '${snapshot_status}'=='cancel'
        ...   Wait Until Keyword Succeeds  1200  20s  _Check vCU Snapshot Status Is Idle  connection=${VCU_CONNECTION}
        ...   ELSE   Fail   Status unknown.
        ${file_exists}=    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${snapshot_path}
        ${measurement_stop}=    DateTime.Get Current Date    time_zone=UTC
        ${snapshot_size}=    OperatingSystem.Get File Size    ${snapshot_path}
        ${snapshot_size}    Evaluate    round(${snapshot_size} / (1024 * 1024), 1)
        ${bts_kpi_target}=    Get KPI Target Based On Snapshot Size    ${snapshot_size}
        Append To List    ${vCU_TARGETS_FOR_SNAPSHOTS}
        ...    BTS Target for size ${snapshot_size}MB snapshot: ${bts_kpi_target}s
        Append To List    ${vCU_SNAPSHOT_SIZES_LIST}
        ...    ${snapshot_size}
        Log    Snapshot file exists status: ${file_exists}. Snapshot size is= ${snapshot_size} MB.    console=${True}

        ${file_last_modification_time}=    Run    TZ=UTC stat -c '%y' '${snapshot_path}' | cut -d'+' -f1 | sed 's/ *$//'
        ${file_last_modification_time}    Remove String Using Regexp      ${file_last_modification_time}    .{3}$

        ${KPI_BTS}    ${KPI_E2E}    Check BTS Operation Time From Syslog And Calculate Operation Times on vCU
        ...    ${measurement_starttime}    ${measurement_stop}    ${file_last_modification_time}
        Log    Snapshot file Last modification time: ${file_last_modification_time}    console=${True}

        Log    Check KPI BTS is in target    console=${True}
        ${KPI_BTS_in_target}=    Evaluate    ${KPI_BTS} <= ${bts_kpi_target}
        Run Keyword And Continue On Failure    Should Be True    ${KPI_BTS_in_target}
        ...                                    msg=KPI_BTS value ${KPI_BTS} exceeds target ${bts_kpi_target}

        ${KPI_E2E_in_target}=    Evaluate    ${KPI_E2E} <= ${KPI_E2E_target}
        Run Keyword And Continue On Failure    Should Be True    ${KPI_E2E_in_target}
        ...                                    msg=KPI_BTS value ${KPI_BTS} exceeds target ${KPI_E2E_target}

        IF    ${KPI_BTS_in_target}==False or ${KPI_E2E_in_target}==False
              Log To Console    One of measured KPIs has exceeded the target. Gathering logs and continuing execution.
              Collect Logs
        END

    END

    Log To Console    ===== BTS results list ${vCU_KPI_BTS_results} =====
    Log To Console    ===== E2E results list ${vCU_KPI_E2E_results} =====
    Log To Console    ===== File sizes list: ${vCU_SNAPSHOT_SIZES_LIST} =====
    Calculate Average BTS and E2E Values    ${vCU_KPI_BTS_results}  ${vCU_KPI_E2E_results}  ${vCU_SNAPSHOT_SIZES_LIST}

    ${results}=     Create List
    ...    KPI BTS:    @{vCU_KPI_BTS_results}s
    ...    KPI E2E:    @{vCU_KPI_E2E_results}s
    ...    KPI SNAPSHOT SIZES:    @{vCU_SNAPSHOT_SIZES_LIST} MB
    ${averages}=    Create List
    ...    KPI BTS:    ${average_BTS}s
    ...    KPI E2E:    ${average_E2E}s
    ...    KPI SNAPSHOT SIZES:    ${average_file_size} MB
    ${targets}=     Create List     KPI Upload Target: ${KPI_E2E_target}s    KPI Target:    ${bts_kpi_target}
    Create Results File    test_results=${results}     average_results=${averages}    target_values=${targets}

Get vCU Uptime And Wait 60min If Needed
    [Documentation]    Description:    This keyword gets vCU Uptime and waits until uptime will be 60minutes.
    Log    Getting vCU uptime    console=${True}
    ${uptime}=    common_keywords.Get vCU Uptime
    Run Keyword If    int(${uptime}) > 3600
    ...    Log    Uptime of vCU is more than 60 minutes. Starting test.  console=${True}
    ...    ELSE    Run Keywords
    ...    Log    Uptime of vCU ${uptime}s is less than 60minutes.    console=${True}
    ...    AND    _Wait Until One Hour on vCU    ${uptime}

_Wait Until One Hour on vCU
    [Arguments]    ${uptime}
    ${remaining_time}=    Evaluate    3600 - int(${uptime})
    Log    Waiting ${remaining_time} seconds.    console=${True}
    BuiltIn.Sleep    ${remaining_time}

_Check vCU Snapshot Status Is Idle
    [Arguments]   ${connection}
    ${status}   vcu_admin.check_snapshot_status   connection=${connection}
    Run Keyword If   '${status}'!='idle'  Fail

Check BTS Operation Time From Syslog And Calculate Operation Times on vCU
    [Documentation]    This keyword checks BTS Operation Time From Syslog And Calculate Operation Times (BTS and E2E)
    [Arguments]    ${starttime}    ${endtime}    ${last_modification_time}
    Log    Start calculation of BTS KPI from Snapshot  console=${True}
    ${syslog_path}=    Download vCU Syslog
    ${snapshot_trigger_syslog_filtered}=    Filter Log File
        ...    file_path=${syslog_path}
        ...    component=oamasm
        ...    keyword=SnapshotApiImpl: receive trigger snapshot request
        ...    start_time_str=${starttime}
        ...    end_time_str=${endtime}
        ...    match_all_keywords=True
        ...    case_sensitive=True
    ${snapshot_trigger_timestamp}=    Get Timestamp Of Event    ${snapshot_trigger_syslog_filtered}    first
    Log    Snapshot trigger timestamp from syslog ${snapshot_trigger_timestamp}    console=${True}

    ${snapshot_generated_syslog_filtered}=    Filter Log File
        ...    file_path=${syslog_path}
        ...    component=oamasm
        ...    keyword=CleanupService: snapshot has already finished
        ...    start_time_str=${starttime}
        ...    end_time_str=${endtime}
        ...    match_all_keywords=True
        ...    case_sensitive=True
    ${snapshot_finish_timestamp}=    Get Timestamp Of Event    ${snapshot_generated_syslog_filtered}    first
    Log     Snapshot finish timestamp from syslog ${snapshot_finish_timestamp}        console=${True}

    ${KPI_BTS_res}=    DateTime.Subtract Date From Date    ${snapshot_finish_timestamp}    ${snapshot_trigger_timestamp}
    Append To List    ${vCU_KPI_BTS_results}    ${KPI_BTS_res}
    ${KPI_E2E_res}=    DateTime.Subtract Date From Date    ${last_modification_time}       ${snapshot_trigger_timestamp}
    Append To List    ${vCU_KPI_E2E_results}    ${KPI_E2E_res}
    [Return]     ${KPI_BTS_res}    ${KPI_E2E_res}
