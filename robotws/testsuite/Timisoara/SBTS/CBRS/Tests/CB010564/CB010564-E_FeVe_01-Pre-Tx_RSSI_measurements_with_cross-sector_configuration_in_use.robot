*** Settings ***
Documentation
...    = Author =
...    karol.sadowski@nokia.com
...    = Maintainer =
...    karol.sadowski@nokia.com
...    = Reviewer =
...    aleksandra.chudzik@nokia.com
...    piotr.lukaszewicz@nokia.com
...    Review link:

*** Keywords ***
CB010564-E_FeVe_01-Pre-Tx_RSSI_measurements_with_cross-sector_configuration_in_use
    [Documentation]    Requirement: SRAN_SFS_SISO.3757, SRAN_SFS_SISO.3905, OAM_REQ_CBRS_542, OAM_REQ_CBRS_549
    ...                Purpose: This test case verifies presence of RSSI measurements in cross-sector BTS configuration.
    ...                It is expected that Pre-Tx measure will be triggered for two RRHs (creating one given sector).
    ...                Test case also verifies scenario when enhanced measurement is triggered by suspend, while grant
    ...                is in 'AUTHORIZED' state.
    ...
    ...                Test Steps:
    ...                Step 0: Prepare BTS cross-sector and SAS configuration
    ...                Step 1: Start SAS simulator and enable CBRS on BTS
    ...                Step 2: Check if Pre-Tx measurments occurred
    ...                Step 3: Suspend random grant
    ...                Step 4: Check if enhanced measurement occrred


    ${bts_id}   Set Variable    ${testlines.${testline_id}.enb_id}
    ${alias}   Set Variable    RAT_1ST

    Log To Console    ${\n}Step 0: Setting preconditions...
    Disable CBRS Feature On eNB
    Kill All SAS Processes
    Enable CBRS Feature On eNB

    Log To Console    Step 1: Starting SAS simulator...
    ${sas_pid}    ${sas_logs_dir}   Start SAS Process
    ${log_start_time}   Get Time
    ${log_start_time}   Convert Date    ${log_start_time}    result_format=%Y%m%d%H%M%S
    Wait Until Keyword Succeeds    6x    10s    Required CBSD Status Should Be Reached
    ...    expected_status=Registered    enb_id=${bts_id}
    Start Watchdog Alarm Detection

    Wait For All Cells To Be OnAir    wait_time=10min

    @{measurment_timestamp_list}   Create List
    @{measurment}   Run Keyword And Continue On Failure    ute_admin_infomodel.Query Infomodel
    ...    query=get list /MRBTS-*/RAT-*/BTS_L-*/EQM_L-*/RMOD_L-*/RU_L-*/CBRS_BAND_MEASUREMENT_REPORT-*
    ...    alias=${alias}
    ${timestamp_offset}   ute_admin_infomodel.Query Infomodel    query=get object /MRBTS-*/EQM-*/SMOD-*/TIME-1    alias=${alias}
    FOR    ${i}    IN    @{measurment}
        ${timestamp}   Set Variable    ${i["measurementReport"][0]["reportTimeStamp"]}
        ${measurment_timestamp_1}   Fetch From Left   ${timestamp}    .
        ${measurment_timestamp_1}   Remove String    ${timestamp}    -    T    :
        ${measurment_timestamp_1}   Add Time To Date    ${timestamp}    ${timestamp_offset["timeZone"]["timeZoneOffset"]}min
        ${measurment_timestamp_1}   Convert Date    ${measurment_timestamp_1}    result_format=%Y%m%d%H%M%S

        ${timestamp}   Set Variable    ${i["measurementReport"][1]["reportTimeStamp"]}
        ${measurment_timestamp_2}   Fetch From Left   ${timestamp}    .
        ${measurment_timestamp_2}   Remove String    ${timestamp}    -    T    :
        ${measurment_timestamp_2}   Add Time To Date    ${timestamp}    ${timestamp_offset["timeZone"]["timeZoneOffset"]}min
        ${measurment_timestamp_2}   Convert Date    ${measurment_timestamp_2}    result_format=%Y%m%d%H%M%S

        Append To List    ${measurment_timestamp_list}    ${measurment_timestamp_1}    ${measurment_timestamp_2}
    END

    ${measurments_count}   Get Length    ${measurment_timestamp_list}
    Should Be True    ${measurments_count}==${6}    msg=Wrong pre-tx measures number, expected 6 measures.

    FOR    ${i}    IN     @{measurment_timestamp_list}
        Should Be True    ${i}>${log_start_time}    msg=Wrong pre-tx timestamp: ${i} - test stardet at: ${log_start_time}
    END
#
#    ***************************************************************
#    ****  Enchanced PRE-TX PART - req removed due to PR740845  ****
#    ***************************************************************
#
#    ${feature_is_enabled}   Run Keyword And Return Status    Check If CBRS Enhanced Measurement Feature Is Enabled
#    IF  ${feature_is_enabled}==${FALSE}  Enable CBRS Enhanced Measurement Feature  enb_id=${enb_id}
#
#    #Check if enhanced measuremend occurred in last ~30min
#    Log To Console    Waiting ~30min for measurment timer exceeds
#    FOR    ${i}    IN RANGE    2000
#        ${now}   Get Time
#        ${now}   Convert Date    ${now}    result_format=%Y%m%d%H%M%S
#        ${next_measure_ready}   Add Time To Date    ${measurment_timestamp_list[0]}    32min
#        ${next_measure_ready}   Convert Date    ${next_measure_ready}    result_format=%Y%m%d%H%M%S
#        Exit For Loop If    ${now}>${next_measure_ready}
#        Sleep    1s
#    END
#
#    ${first_measurement_report}   Set Variable    ${measurment_timestamp_list}
#
#    ${suspended_cell_number}   Evaluate    random.sample(range(1, 4), 1)    modules=random
#    ${cbsd_id}   Fetch CBSD ID    enb_id=${bts_id}
#    ${cellGrantId}   Fetch Grant ID Of Selected Cell    enb_id=${bts_id}    cell_number=${suspended_cell_number}
#
#    Send Command To SAS Manager    alias=default    command=grant_suspend ${cbsd_id} ${cellGrantId}
#    Wait For Any Cell To Be Dropped    wait_time=10min
#    Wait For All Cells To Be OnAir
#
#    ${second_measurement_report}   Create List
#    @{measurment}   Run Keyword And Continue On Failure    ute_admin_infomodel.Query Infomodel
#    ...    query=get list /MRBTS-*/RAT-*/BTS_L-*/EQM_L-*/RMOD_L-*/RU_L-*/CBRS_BAND_MEASUREMENT_REPORT-*
#    ...    alias=${alias}
#    ${timestamp_offset}   ute_admin_infomodel.Query Infomodel    query=get object /MRBTS-*/EQM-*/SMOD-*/TIME-1    alias=${alias}
#    FOR    ${i}    IN    @{measurment}
#        ${timestamp}   Set Variable    ${i["measurementReport"][0]["reportTimeStamp"]}
#        ${measurment_timestamp_1}   Fetch From Left   ${timestamp}    .
#        ${measurment_timestamp_1}   Remove String    ${timestamp}    -    T    :
#        ${measurment_timestamp_1}   Add Time To Date    ${timestamp}    ${timestamp_offset["timeZone"]["timeZoneOffset"]}min
#        ${measurment_timestamp_1}   Convert Date    ${measurment_timestamp_1}    result_format=%Y%m%d%H%M%S
#
#        ${timestamp}   Set Variable    ${i["measurementReport"][1]["reportTimeStamp"]}
#        ${measurment_timestamp_2}   Fetch From Left   ${timestamp}    .
#        ${measurment_timestamp_2}   Remove String    ${timestamp}    -    T    :
#        ${measurment_timestamp_2}   Add Time To Date    ${timestamp}    ${timestamp_offset["timeZone"]["timeZoneOffset"]}min
#        ${measurment_timestamp_2}   Convert Date    ${measurment_timestamp_2}    result_format=%Y%m%d%H%M%S
#
#        Append To List    ${second_measurement_report}    ${measurment_timestamp_1}    ${measurment_timestamp_2}
#    END
#
#    ${measurments_count}   Get Length    ${second_measurement_report}
#    Should Be True    ${measurments_count}==${6}    msg=Wrong enhanced
#
#    #check if two measures list dont have same values inside
#    ${common_timestamps}   Evaluate    set(${first_measurement_report}) & set(${second_measurement_report})
#    ${common_timestamps_length}   Get Length    ${common_timestamps}
#    Should Be True    ${common_timestamps_length}==${0}    msg=Some of enhanced pre-tx measures were not triggered properly.

    [Teardown]    Run Keywords    Get SAS Logs To Logs Dir    alias=default    AND
    ...                           Stop Watchdog Alarm Detection And Check For Failures    AND
    ...                           Disable CBRS Feature On eNB    AND
    ...                           Kill All SAS Processes    AND
    ...                           Check If Cells Are Disabled    enb_id=${bts_id}
