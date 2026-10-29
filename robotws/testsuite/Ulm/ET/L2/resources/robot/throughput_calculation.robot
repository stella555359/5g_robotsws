*** Settings ***
Documentation  Keywords used for  pm_counter collection and throughput calculation.


Library    ./../../libraries/pmcounter_throughput_evaluator.py             WITH NAME   pmc_throughput_evaluator
Library    ./../../libraries/tools.py                                      WITH NAME   tools
Library    ./../../libraries/template_functions.py                         WITH NAME   template
Library    ./../../libraries/ulm_common_library.py                         WITH NAME   ucl
Library    ./../../libraries/parse_out_log.py                              WITH NAME   parse_out_log
Resource   ../../../../resources/Common/pmcounters.robot

*** Keywords ***

Collect PM Counters and process throughput using PM counters
    ${pm_counters_dir}=  ucl.kwrun  pmcounters.Collect PM Counter  target_dir=${ts_log_dir}/PMC
    set suite variable  ${pm_counters_dir}
    ${status}=    run keyword and return status    Convert PM files to CSV    file_path=${pm_counters_dir}
    IF    not ${status}    log    Convert PM files to CSV FAILED!    level=ERROR
    @{scenarios}=    template.Get List Of All Scenarios    ${TEST_TAGS}
    ${PMC_SCENARIO_DICT}=    parse_out_log.get_pm_file_scenario_dict    ${ts_log_dir}    ${scenarios}
    Set Suite Variable    ${PMC_SCENARIO_DICT}
    Initialize PM Counter Throughput Validator
    Run Keyword And Warn On Failure    Calculate Throughput Using PM Counters For All Scenarios


Initialize PM Counter Throughput Validator
    [Arguments]  ${pm_counters_dir}=${ts_log_dir}/PMC/gnb_pm_counters
    ${pmc_obj_present}=  Run Keyword and Ignore Error  Evaluate  '${pmc_throughput_obj}'!='${EMPTY}'
    IF  '${pmc_obj_present[0]}'!='FAIL'   RETURN
    ${pmc_throughput_obj}=  pmc_throughput_evaluator.Initialize PMC Throughput Calculator  ${pm_counters_dir}
    Set Suite Variable  ${pmc_throughput_obj}


Calculate Throughput using PM Counters for all Scenarios
    ${list_of_scenarios}=  template.get_list_of_all_scenarios  ${TEST TAGS}
    ${througput_per_scenario}=  Create Dictionary
    FOR  ${scenario}  IN  @{list_of_scenarios}
        ${is_with_pm_counters}=  template.is_with_pm_counters   ${scenario}
        ${pm_counter_start_before_L3}=  template.pm_counter_start_before_L3  ${scenario}
        ${is_with_pm_counters}  Set Variable If    ${is_with_pm_counters} or ${pm_counter_start_before_L3}  ${True}  ${False}
        IF  not ${is_with_pm_counters}   RETURN
        Log to console  Computing throughput using PM Counter for scenario: ${scenario}
        ${througput_per_cell}=  Calculate Throughput using PM Counters for scenario  validate_with_scenario=${scenario}
        Set to dictionary  ${througput_per_scenario}  ${scenario}=${througput_per_cell}
    END
    tools.write_dictionary_to_json  dir_path=${ts_log_dir}/PMC/gnb_pm_counters
    ...  dictionary=${througput_per_scenario}    filename=pmc_average_tp_per_scenario_per_cell.json


Calculate Throughput using PM Counters for scenario
    [Arguments]  ${validate_with_scenario}
    ${pmc_index}=  tools.get_pmc_index  scenario=${validate_with_scenario}  pmc_scenario_dict=${PMC_SCENARIO_DICT}    ts_log_dir=${ts_log_dir}
    ${max_traffic_duration_for_scenario}=  template.get_max_traffic_length  scenario_name=${validate_with_scenario}
    ${througput_per_cell}=  Create Dictionary
    FOR  ${cell_dist_name}  IN  @{cell_distName_params}
        ${average_cell_throughput}=  Calculate Average throughput per cell using PMC    validate_with_scenario=${validate_with_scenario}
        ...  cell_dist_name=${cell_dist_name}
        ...  max_traffic_duration_for_scenario=${max_traffic_duration_for_scenario}
        ...  pmc_index=${pmc_index}
        ...  timestamps=@{PMC_SCENARIO_DICT}[${validate_with_scenario}][timestamps]
        Set to dictionary  ${througput_per_cell}  ${cell_dist_name}=${average_cell_throughput}
    END
    RETURN  ${througput_per_cell}


Calculate Average throughput per cell using PMC
    [Arguments]  ${validate_with_scenario}  ${cell_dist_name}  ${max_traffic_duration_for_scenario}  ${pmc_index}  ${timestamps}=${EMPTY}
    Log to console  Calculating Average througput for cell: ${cell_dist_name}
    ${average_cell_throughput}=  pmc_throughput_evaluator.get_average_cell_throughput_for_interval
    ...  object=${pmc_throughput_obj}
    ...  interval=${pmc_index}
    ...  traffic_duration_sec=${max_traffic_duration_for_scenario}
    ...  cell_dist_name=${cell_dist_name}
    ...  unit=Mbps
    ...  timestamps=${timestamps}
    Log to console  \tObserved UL TP: ${validate_with_scenario}: ${average_cell_throughput['throughput_ul']} ${average_cell_throughput['unit_ul']}
    Log to console  \tObserved DL TP: ${validate_with_scenario}: ${average_cell_throughput['throughput_dl']} ${average_cell_throughput['unit_dl']}
    RETURN  ${average_cell_throughput}

