*** Settings ***
Library    ../PythonKeywords/data_collector_handler/DataCollectorHandler.py
...    WITH NAME    data_collector
Library    Collections
Library    OperatingSystem

*** Variables ***
${case_id}

*** Keywords ***

Create DataCollector Test Run
    [Documentation]    Creates new data collector test run
    [Arguments]    ${id}=
    ${run_id}    data_collector.create_test_run    run_id=${id}
    Set Suite Variable    ${test_run_id}    ${run_id}

Start DataCollector
    [Documentation]    Start data collectors
    [Arguments]    ${step_id}=
    data_collector.check_start_time
    ${response}    data_collector.start_data_collectors
    ...    run_id=${test_run_id}     case_id=${case_id}    step_id=${step_id}    phase_name=${TEST NAME}
    ${test_case_id}    Get From Dictionary    ${response}    test_case_id
    ${id}    Get From Dictionary    ${response}    bts_id
    ${build}    Get From Dictionary    ${response}    sw_build
    ${package}    Get From Dictionary    ${response}    sw_package
    Set Test Variable    ${bts_id}    ${id}
    Set Test Variable    ${case_id}    ${test_case_id}
    Set Test Variable    ${sw_build}    ${build}
    Set Test Variable    ${sw_package}    ${package}
    Set Test Variable    ${test_phase_name}    ${TEST NAME}
    Set Test Variable    ${test_step_id}    ${step_id}

Stop DataCollector
    [Documentation]    Stop data collectors
    data_collector.stop_data_collectors
    ...    run_id=${test_run_id}     case_id=${case_id}    step_id=${test_step_id}    phase_name=${test_phase_name}

Stop DataCollector Test Run
    [Documentation]    Stop data collector test run
    data_collector.stop_test_run    ${test_run_id}

Run Analysis And Wait Result
    [Documentation]    Run analysis using analysis service and wait result
    [Arguments]    ${analysis_template}=
    ${result}    data_collector.run_analysis
    ...    analysis_template=${analysis_template}    bts_id=${bts_id}
    ...    test_phase_name=${test_phase_name}    test_run_id=${test_run_id}    sw_package=${sw_package}
    ...    sw_build=${sw_build}    test_case_id=${case_id}
    ${analysis_result}    Get From Dictionary    ${result}    result
    Log    ${result}    repr=True
    data_collector.write_result_to_file    ${OUTPUT DIR}/elastic_kpi_analysis.json    ${result}
    data_collector.log_results    ${result}

Write Test Parameters To File
    ${analysis_parameters}    Catenate    SEPARATOR=\n
    ...    DATA_COLLECTOR_BTS_ID=${bts_id}
    ...    DATA_COLLECTOR_SW_BUILD=${sw_build}
    ...    DATA_COLLECTOR_SW_PACKAGE=${sw_package}
    ...    DATA_COLLECTOR_TEST_CASE_ID=${case_id}
    ...    DATA_COLLECTOR_TEST_PHASE_NAME=${test_phase_name}
    ...    DATA_COLLECTOR_TEST_RUN_ID=${test_run_id}
    Create File    ${OUTPUT DIR}/data_collector_identifiers_${TEST NAME}.env    ${analysis_parameters}

Stop DataCollectors and Run Analysis
    [Arguments]    ${ANALYSIS_TEMPLATE}=
    Stop DataCollector
    Run Analysis And Wait Result    ${ANALYSIS_TEMPLATE}
    Write Test Parameters To File
