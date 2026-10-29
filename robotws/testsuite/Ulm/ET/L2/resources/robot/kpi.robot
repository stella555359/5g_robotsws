*** Settings ***
Documentation       This File provides the Keyword(s) to run KPI calculation for a TEAL testcase. It should only be used within the TEAL Framework.

Library             ../../libraries/parse_out_log.py
Library             ../../libraries/template_functions.py    WITH NAME    template
Library             ../../../../resources/Common/python/ltepat/ltepat_setup.py
Library             ../../../../resources/Common/python/ltepat/ltepat_run.py
Library             ../../libraries/kpi_calculation.py
Library             Collections
Resource            ../../../../resources/Common/scout_kpi.robot
Resource            ../common_keywords.robot


*** Keywords ***
Calculate KPI For all scenarios
    @{scenarios}=    template.Get List Of All Scenarios    ${TEST_TAGS}
    IF    '${logs_and_traces_flags["KPI"]["calculation"]}'=='False'
        BuiltIn.Log To Console    Kpi calculation will not be performed
        RETURN
    ELSE
        BuiltIn.Log To Console    Starting KPI calculation
    END
    ${relevant_files}=    parse_out_log.Get Relevant Pm Files    ${ts_log_dir}    ${scenarios}
    ltepat_setup.Install Lte Pat
    kpi_calculation.Calculate KPI For all scenarios    ${ts_log_dir}    ${scenarios}    ${logs_and_traces_flags}
    ${pm_file_scenario_dict}=    parse_out_log.get pm file scenario dict    ${ts_log_dir}    ${scenarios}
    FOR    ${scenario_name}    ${scenario_data}    IN   &{pm_file_scenario_dict}
        Log    Calculating Scout KPI for ${scenario_name} with start_time: ${scenario_data['start']} and end_time: ${scenario_data['end']}
        scout_kpi.Calculate KPIs For Time Interval    start_time=${scenario_data['start']}    end_time=${scenario_data['end']}
        ...    template_id=2238
        ...    target_dir=${ts_log_dir}/${scenario_name}_scout_kpi
    END
