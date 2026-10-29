*** Settings ***
Documentation    Insert Feature Specific validation keywords here

Library  ./python/validation.py  WITH NAME  validation
Library  ./../../../../ET/L2/libraries/parse_out_log.py
Library  ./../../../../ET/L2/libraries/template_functions.py  WITH NAME  template
#Import required libraries for validation
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
Resource    ../../../../ET/L2/resources/common_keywords.robot

*** Keywords ***
Extract TTI Trace and Convert to JSON
    [Arguments]  @{varargs}
    RETURN


Extract TTI Trace and Convert to Pickle
    [Arguments]  ${path_to_tti_trace_pcap}
    ${events_required}=  Create List  csiSrReportData  dlHarqRxDataArray
    Convert TTI trace from pcap to data frame  input_file_path=${path_to_tti_trace_pcap}
    ...  events_list=${events_required}
    ...  write_to_pickle=${TRUE}

Test If Throughput was Achieved
    [Arguments]  ${log_path}
    @{scenarios}=  template.Get List Of All Scenarios  ${TEST_TAGS}
    FOR    ${scenario}    IN   @{scenarios}
        Log To Console    Analyzing traffic for ${scenario}
        ${expected_throughput_per_cell}=  template.get_expected_throughput_per_cell  ${scenario}
        ${result}=  validation.validate_traffic_for_scenario  ${scenario}
        ...  ${log_path}/PMC/gnb_pm_counters/pmc_average_tp_per_scenario_per_cell.json
        ...  ${expected_throughput_per_cell}
        Run Keyword and Warn on Failure  Should be true  ${result['test_result']}  msg=The measuered Traffic does not match the expected traffic.
        ${expected_throughput_per_ue}=  template.get_expected_throughput_per_ue  ${scenario}
        ${result_per_ue}  ${verdict}=  validation.validate_bearer_stats_traffic
        ...  ${log_path}/${scenario}_bearer_stats.pkl
        ...  ${expected_throughput_per_ue}
        Should be true  ${verdict}
    END

Test TTI Not EMPTY
    ${file content}=  OperatingSystem.Get File    ${ts_log_dir}/tti_trace_scenario_1_default_scenario/DecodeSummary.txt
    ${total_events}=  String.Get Lines Containing String    ${file_content}    [EventParser] Total number of events:
    ${total_events}=  String.Get Regexp Matches    ${total_events}    \\d+
    ${total_events}=  BuiltIn.Convert To Integer    ${total_events}[${0}]
    IF  ${total_events} == ${0}
        Fail  TTI trace is empty
    ELSE
        Log To Console    message=TTI trace is not empty and has ${total_events} events.
    END

Validate Logs offline
    [Arguments]  ${log_path}
    test_setup.Read Test Configuration from JSON File
    Test If Throughput was Achieved    ${log_path}
