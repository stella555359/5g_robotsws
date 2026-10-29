*** Settings ***

Documentation
...   This resource file provides specific helper KWs for calculating and reporting KPIs using Scout.

Library     taf.sw.scout    WITH NAME    scout
Library     BuiltIn
Library     DateTime
Library     python/json_operations.py   WITH NAME  json
Resource    testline.robot


*** Variables ***
${scout_api_key}    16f117f7-24ca-4c34-8a64-ac892e74d6be


*** Keywords ***
Enable KPI collection
    [Documentation]    Enables the collection of kpis in scout.
    ${tl_name}=    testline.Get Testline Name
    scout.Setup Scout    scout_testline_name=${tl_name}    api_key=${scout_api_key}    timeout=60
    scout.Enable Full Kpi Pm Collection
    [Teardown]    scout.Teardown Scout Api

Disable KPI collection
    [Documentation]    Enables the collection of kpis in scout.
    ${tl_name}=    testline.Get Testline Name
    scout.Setup Scout    scout_testline_name=${tl_name}    api_key=${scout_api_key}    timeout=60
    scout.Disable Full Kpi pm collection
    [Teardown]    scout.Teardown Scout Api

Calculate KPIs For Time Interval
    [Documentation]    This keyword calculates the KPI for a given time interval.
    [Arguments]    ${report_name}=${EMPTY}    ${template_id}=${EMPTY}    ${start_time}=''    ${end_time}=''    ${target_dir}=/home/ute/DEVELOPMENT
    ${tl_name}=    testline.Get Testline Name
    ${kpi}    BuiltIn.Wait Until Keyword Succeeds    15    60
    ...    scout.Generate Kpi Report
        ...    report_name=${report_name}
        ...    start_time=${start_time}
        ...    end_time=${end_time}
        ...    template_id=${template_id}
    json.Write Dictionary To Json    ${kpi}    ${target_dir}/kpi_results.json
    [Teardown]    scout.Teardown Scout Api


Get KPI For Time Interval
    [Documentation]    This Keyword calculates a single KPI for the given time interval
    [Arguments]    ${kpi_list}    ${start_time}    ${end_time}    ${target_dir}=/home/ute/DEVELOPMENT
    ${tl_name}=    testline.Get Testline Name
    scout.Setup Scout    scout_testline_name=${tl_name}    api_key=${scout_api_key}    timeout=60
    &{kpi_dict}=    BuiltIn.Create Dictionary
    FOR    ${kpi}    IN    @{kpi_list}
        Log    Sending request to calculate: ${kpi}    console=yes
        ${kpi_value}=    scout.Get Kpi    ${kpi}    ${start_time}    ${end_time}
        Collections.Set To Dictionary    ${kpi_dict}    ${kpi}=${kpi_value}
    END
    json.Write Dictionary To Json    ${kpi_dict}    ${target_dir}/kpi_results.json
