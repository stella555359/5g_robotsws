*** Settings ***
Documentation
...                 author/contact: Hubert Kowalczyk / hubert.kowalczyk@nokia.com
...                 maintainer/contact: Hubert Kowalczyk / hubert.kowalczyk@nokia.com
...                 Test suite veryfing correctness of CNI-114758 feature activation.

Library             resources/CNI_114758_Keywords.py
Resource            resources/CNI_114758_Keywords.robot

Suite Setup         Suite Setup
Suite Teardown      Suite Teardown
Test Setup          Test Setup
Test Teardown       Test Teardown

Force Tags          rf50


*** Variables ***
# robocop: disable=0920
${sw_config_path}               /home/ute/test_repository/testsuite/Krakow/OAM/regression/RAN_PZ_KRK8/CNI_114758/resources/swconfig.txt
${fault_x2_link}                No X2 link available
${diag_files}                   Diagnostic Files collected
${high_memory_consumption}      High memory consumption
${x2_gnb}                       Setup of X2 connectivity to gNB failed
@{CUSTOM_ALLOWED_ALARMS}
...                             ${fault_x2_link}
...                             ${diag_files}
...                             ${high_memory_consumption}
...                             ${x2_gnb}

# Can be set to False when debugging locally, skips initial comissionings and other long setup procedures
${full_test_setup}              ${True}


*** Test Cases ***
# robocop: disable=0301

[1]CNI-114758 1. Activation of feature CB009794
    ${counter_list}=    Generate counter list
    ${merged_counter_list}=    Set Variable    ${{ ','.join($counter_list) }}
    Log    \n--Counter list: ${counter_list}--\n    console=${True}
    ${test_start_time}=    get_current_datetime
    Log    \n--Test start time: ${test_start_time}--\n    console=${True}
    Set NR RTWP Counters Status    false
    Set NR RTWP Counters Interval    disabled

    ${configuration_change_finish_time}=    get_current_datetime
    Log    \n--Configuration change finish time: ${configuration_change_finish_time}--\n    console=${True}
    Wait For Counter Interval To Expire
    Run Keyword And Expect Error    *    Verify Counters Existence

    ${time_before_tput}=    get_current_datetime
    Set NR RTWP Counters Status    true
    Set NR RTWP Counters Interval    5min
    #${kpi_collection_start}=    Get time point for kpis
    ${kpi_collection_start}=    Set Variable    ${{(datetime.datetime.now() - datetime.timedelta(days=1)).strftime("%Y-%m-%d %H:%M:%S")}}
    Log to console    \n-- kpi start time: ${kpi_collection_start} --\n
    Wait For Counter Interval To Expire
    Start DLUL Data Transfer And Verify Throughput Android
    ...    ue_index=1
    ...    duration=330s
    ...    dl_throughput=400 MBits/sec
    ...    ul_throughput=20 MBits/sec
    ...    max_deviation=50%
    ${time_after_tput}=    get_current_datetime

    Wait For Counter Interval To Expire    wait_time=1910s
    #${kpi_collection_end}=    Get time point for kpis
    ${kpi_collection_end}=    Set Variable    ${{(datetime.datetime.now() + datetime.timedelta(days=1)).strftime("%Y-%m-%d %H:%M:%S")}}
    Log to console    \n-- kpi end time: ${kpi_collection_end} --\n
    Sleep    20s
    ${negative_value_detected}=    Set Variable    ${False}
    ${value_increase_detected}=    Set Variable    ${False}
    FOR    ${current_counter}    IN    @{counter_list}
        TRY
            Log    Verifying counter ${current_counter}    console=${True}
            ${counter_data}=    Run Keyword And Retry On Error    .*    Extract data from counter gui    current_counter=${current_counter}
            ${stripped_counter_data}=    strip_counter_values_before_date    ${counter_data}    ${configuration_change_finish_time}
            ${negative_detected}    ${increase_detected}=    verify_enabled_nr_rtwp_counter_correctness    ${stripped_counter_data}
            IF    $negative_detected == ${True}
                ${negative_value_detected}=    Set Variable    ${True}
            END
            IF    $increase_detected == ${True}
                ${value_increase_detected}=    Set Variable    ${True}
            END
        EXCEPT    .*    type=regexp    AS    ${error_message}
            Log    \n--Exception occured: ${error_message}--\n    console=${True}
        END
    END
    IF    $negative_value_detected == ${False}
        Fail    No negative values detected in counters
    ELSE
        Log    \n--Counter Values are in correct range--\n    console=${True}
    END

    IF    $value_increase_detected == ${False}
        Fail    No increase in value detected in counters
    ELSE
        Log    \n--Counter Values change in expected manner--\n    console=${True}
    END
    verify_average_ue_related_sinr_and_rssi    ${kpi_collection_start}    ${kpi_collection_end}
    Sleep    10s
    ${cell_ids}=    gnbcell.get_all_cells_id
    Log to console    ${cell_ids}
    Sleep    60s
    Lock RMOD    ${1}
    Sleep    60s
    Unlock RMOD    ${1}
    Sleep    10s
    Collect logs early
    ${snapshot_paths}=    Find snapshots    ${LOG_PATH}
    Log    ${snapshot_paths}    console=${True}
    FOR    ${snapshot_path}    IN    @{snapshot_paths}
        Log    Unpacking snapshot ${snapshot_path}    console=${True}
        extract_rmod_runtime_snapshot    ${snapshot_path}
        Log To Console    Unpacked: ${snapshot_path}
        ${log_files}=    find rmod logfiles    ${LOG_PATH}
	${rxscalingfound}=    Set Variable    ${False}
        FOR    ${log_file}    IN    @{log_files}
            ${result}=    verify_rxpowerscalingfactor    ${log_file}
	    IF    ${result} == ${TRUE}
	    	${rxscalingfound}=    Set Variable    ${True}
	    END
        END
    END


    IF    ${rxscalingfound} == ${False}
    	FAIL    \n-- Appropriate rxScalingPowerFactor was not found --\n
    END

    Wait For cells To Be OnAir
