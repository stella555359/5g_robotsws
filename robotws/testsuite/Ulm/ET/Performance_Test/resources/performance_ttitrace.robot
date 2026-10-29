*** Settings ***
Documentation    Test variables and keyword resource file for Performance_Test

Resource    ../../../resources/Common/ttitrace.robot
Resource    performance_log_collection.robot

Library    python/perf_log_collection.py
Library    python/ttitrace_analysis.py

*** Variables ***
${S_TTI_TRACE_STARTED}         ${FALSE}

${ttitrace_nr_phy_cell_ids}    ${EMPTY}

@{T_DEFAULT_TTI_EVENTS}        ulTdSchedSubcellData
...                            dlTdSchedSubcellData
...                            ulAllocatedPooledResourcesData
...                            dlAllocatedPooledResourcesData

*** Keywords ***
Check AdativeSlotProcessingRatio Not Greater Than 90 Some Greater Than 78
    [Arguments]    ${df}=${T_TTI_TRACE_PATH_QUICK_DF}
    Log to console    Check AdativeSlotProcessingRatio Not Greater Than 90 Some Greater Than 78
    TRY
        ttitrace_analysis.Check AdativeSlotProcessingRatio Not Greater Than90 Some Greater Than 78    ${df}
    EXCEPT    .*AttributeError.*    type=regexp
        Run Keyword And Continue On Failure    Fail    TTI Trace dataframe is invalid or not loaded
    END

Check TTI Trace Total Number of Sched UEs Per L1Pool
    [Arguments]    ${df}=${T_TTI_TRACE_PATH_QUICK_DF}    ${inactive_cells}=@{empty}    ${count}=30
    TRY
        ttitrace_analysis.Check Total Number Of Scheduled Ues Per L1pool     ${df}    ${inactive_cells}    ${count}
    EXCEPT    .*AttributeError.*    type=regexp
        Run Keyword And Continue On Failure    Fail    TTI Trace dataframe is invalid or not loaded
    END

Check TTI Trace Total Number of Sched UEs Per L1Pool for DL
    [Arguments]    ${df}=${T_TTI_TRACE_PATH_QUICK_DF}    ${inactive_cells}=@{empty}    ${count}=30
    TRY
        ttitrace_analysis.Check Total Number Of Scheduled Ues Per L1pool DL     ${df}    ${inactive_cells}    ${count}
    EXCEPT    .*AttributeError.*    type=regexp
        Run Keyword And Continue On Failure    Fail    TTI Trace dataframe is invalid or not loaded
    END

Quick TTI Trace Collection
    [Arguments]    ${tti_trace_duration}=3
    ...            ${tti_trace_filename}=ttitrace_streaming_quick
    ...            ${nr_phy_cell_ids}=${ttitrace_nr_phy_cell_ids}
    ...            ${subfolder}=${EMPTY}
    Log    Collect TTI Traces in Streaming mode (${tti_trace_duration} seconds)    console=${P_console}
    ttitrace.Collect TTI Traces in Streaming mode     tti_trace_duration=${tti_trace_duration}
    ...                                      tti_trace_filename=${tti_trace_filename}
    ...                                      nr_phy_cell_ids=${nr_phy_cell_ids}

    Set Test Variable        ${T_TTI_TRACE_PATH_QUICK}    ${P_resultTestDir}/${tti_trace_filename}
    perf_log_collection.Queue Logs To Turandot    ${T_TTI_TRACE_PATH_QUICK}.pcap    subfolder=${subfolder}

Crate and setup TTI Trace Collector
    [Arguments]    ${nr_phy_cell_ids}=${ttitrace_nr_phy_cell_ids}    ${tti_trace_filename}=default
    Log    Create and setup TTI Trace Collector    console=${P_console}
    ${source_ip}=   Get Source IP Address For Classical BTS
    ${dest_ip}=     Get Target IP Address For Classical Bts   source_ip_address=${source_ip}
    ${collector}=    Run Keyword And Warn On Failure    ttitrace.Create TTI Trace Collector
    ...    nr_phy_cell_ids=${nr_phy_cell_ids}
    ...    dest_ip=${dest_ip}
    ...    tti_trace_filename=tti_stm_${tti_trace_filename}
    RETURN    ${collector}


Start TTI Trace Collector
    [Arguments]    ${collector_name}
    ttitrace.Start TTI Trace Generation    ${collector_name}


Stop TTI Trace Collector
    [Arguments]    ${collector_name}
    ttitrace.Stop TTI Trace Generation    ${collector_name}


Collect and Teardown TTI Trace Collector
    [Arguments]    ${collector}    ${storage_location}=${EMPTY}
    Log    Stop and Teardown TTI Trace Collector    console=${P_console}
    Run Keyword And Warn On Failure    ttitrace.Collect TTI Trace And Teardown Collectors
    ...    desired_storage_directory=${storage_location}
    ...    desired_file_name=${collector}


Start TTI Trace Collection
    [Arguments]    ${nr_phy_cell_ids}=${ttitrace_nr_phy_cell_ids}    ${tti_trace_filename}=default
    IF    ${S_TTI_TRACE_STARTED}
        Log    Start TTI Trace Collection: TTI Trace already started!    level=WARN    console=${P_console}
    ELSE
        TRY
            Log to Console    Start TTI Trace Collection: ${tti_trace_filename}
            ttitrace.Start TTI Traces in Streaming mode    nr_phy_cell_ids=${nr_phy_cell_ids}
            ...                                            tti_trace_filename=tti_stm_${tti_trace_filename}
            Set Suite Variable    $S_TTI_TRACE_STARTED    ${TRUE}
        EXCEPT
            Log    Start TTI Trace Collection Failed: ${tti_trace_filename}    level=ERROR
        END
    END

Stop TTI Trace Collection
    [Arguments]     ${tti_trace_filename}=default    ${subfolder}=${EMPTY}    ${compression_flags}=${EMPTY}
    IF    ${S_TTI_TRACE_STARTED}
        Log to Console    Stop TTI Trace Collection: ${tti_trace_filename} (${subfolder})
        ${_}    ${tti_trace_path}          Run Keyword And Warn On Failure    ttitrace.Stop TTI Traces in Streaming mode
        ...                                                                   tti_trace_path=${P_resultTestDir}/${subfolder}
        ...                                                                   tti_trace_filename=tti_stm_${tti_trace_filename}
        Set Suite Variable    $S_TTI_TRACE_STARTED    ${False}
        Set Test Variable        $T_TTI_TRACE_PATH    ${tti_trace_path}
        perf_log_collection.Queue Logs To Turandot    ${tti_trace_path}    compression_flags=${compression_flags}    subfolder=${subfolder}
    ELSE
        Log    Stop TTI Trace Collection: TTI Trace not started!    level=WARN    console=${P_console}
    END

Convert TTI Trace To Dataframe
    [Arguments]    ${tti_trace}    ${events_list}=${T_DEFAULT_TTI_EVENTS}
    Log    Convert TTI trace from pcap to data frame    console=${P_console}
    ${_}    ${T_TTI_TRACE_PATH_QUICK_DF}=   Run Keyword And Warn On Failure
    ...    ttitrace.Convert TTI Trace From PCAP To Data Frame
    ...            input_file_path=${tti_trace}
    ...            events_list=${events_list}
    ...            write_to_pickle=${true}
    RETURN    ${T_TTI_TRACE_PATH_QUICK_DF}
