*** Settings ***
Documentation
...  author:  Squad 69
...  contact: I_MN_RAN_SW_ULM_ET_AP_PET_GMS
...  Description: Basic L3 Call

Library    taf.sw.wtssim  # wts_manager -> taf_sw_wtssim_wrapper dependency

Library    ./resources/python/perf_keywords.py
Library    ./resources/python/wts_manager.py
Library    ./resources/python/wts_wrapper.py

Resource   ./resources/performance_log_collection.robot
Resource   ./resources/performance_keywords.robot
Resource   ./resources/performance_common_tc.robot
Resource   ./resources/performance_test_setup.robot

Suite Setup       performance_test_setup.Suite Setup For Performance Test
Suite Teardown    performance_test_setup.Suite Teardown For Performance Test
Test Setup        performance_test_setup.Test Case Setup For Performance Test
Test Teardown     performance_test_setup.Test Case Teardown For Performance Test


*** Test Cases ***
Basic_L3_Call_TDD
    [Documentation]
    ...    Author: noli.valdez@nokia.com
    ${argp}     Create Dictionary
    ...                         start_cell=1
    ...                           end_cell=1
    ...                       active_cells=all
    ...                        ue_per_cell=1
    ...                                lua=sansa_tdd_1cell.lua
    ...                configuration_entry=run_configuration()
    ...                      json_scenario=basic.json
    ${argp2}    perf_keywords.Calculate Values For Common Run Dictionary Py    get_from_cli=${true}    &{argp}
    ${argpy}    perf_keywords.Pop Args From Common Args    ${argp2}    perf_keywords.wts_manager_non_supported_params
    &{args}     Set Variable   ${argpy}  # convert to robot style dictionary
    performance_keywords.Set Up On air status    ${args}

    ${exists}    Run keyword and return status     File Should Exist    ${WORKSPACE}/archive/scenario.json
    IF    ${exists}
        ${json_scenario}    Set Variable    ${WORKSPACE}/archive/scenario.json
        Log to Console     Scenario  uploaded: ${json_scenario}
    ELSE
        ${json_scenario}    Set Variable    ${args.json_scenario_dir}/${args.json_scenario}
        Log to Console     Scenario (default): ${json_scenario}
    END

    Log to console    Running ${json_scenario}...
    wts_manager.Send UE Commands From Json    ${json_scenario}    start_ue=${args.start_ue}    num_cells=${args.num_cells}
    ...                                                                                      active_cells=${args.active_cells}
    ...                                                                                      ue_count=${args.total_active_ue}
    ${table}    wts_wrapper.Get UE Count Per Cell Table    num_cells=${args.num_cells}    active_cells=${args.active_cells}
    ...                                                    expected=${args.expect_ue_count}
    Log to console    ${table}

    performance_log_collection.Wait And Collect One Measurement Cycle

    performance_keywords.Common Log Teardown        subfolder=${args.subfolder}    label=${args.label}
    ...                                             tti_trace_duration=${args.tti_trace_duration}
    performance_keywords.Common Log Teardown Verification    ${args}    sublabel=${args.sublabel}


Basic_L3_Call_FDD
    [Documentation]
    ...    Author: noli.valdez@nokia.com

    ${argp}     Create Dictionary
    ...                         start_cell=1
    ...                           end_cell=1
    ...                       active_cells=all
    ...                        ue_per_cell=1
    ...                                lua=sansa_fdd_1cell.lua
    ...                configuration_entry=run_configuration()
    ...                      json_scenario=basic.json
    ${argp2}    perf_keywords.Calculate Values For Common Run Dictionary Py    get_from_cli=${true}    &{argp}
    ${argpy}    perf_keywords.Pop Args From Common Args    ${argp2}    perf_keywords.wts_manager_non_supported_params
    &{args}     Set Variable   ${argpy}  # convert to robot style dictionary
    performance_keywords.Set Up On air status    ${args}

    ${exists}    Run keyword and return status     File Should Exist    ${WORKSPACE}/archive/scenario.json
    IF    ${exists}
        ${json_scenario}    Set Variable    ${WORKSPACE}/archive/scenario.json
        Log to Console     Scenario  uploaded: ${json_scenario}
    ELSE
        ${json_scenario}    Set Variable    ${args.json_scenario_dir}/${args.json_scenario}
        Log to Console     Scenario (default): ${json_scenario}
    END

    Log to console    Running...
    wts_manager.Send UE Commands From Json    ${json_scenario}    start_ue=${args.start_ue}    num_cells=${args.num_cells}
    ...                                                                                      active_cells=${args.active_cells}
    ...                                                                                      ue_count=${args.total_active_ue}
    ${table}    wts_wrapper.Get UE Count Per Cell Table    num_cells=${args.num_cells}    active_cells=${args.active_cells}
    ...                                                    expected=${args.expect_ue_count}
    Log to console    ${table}

    performance_log_collection.Wait And Collect One Measurement Cycle

    performance_keywords.Common Log Teardown    subfolder=${args.subfolder}    label=${args.label}    tti_trace_duration=${args.tti_trace_duration}
    performance_keywords.Common Log Teardown Verification    ${args}    sublabel=${args.sublabel}
