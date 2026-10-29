*** Settings ***
Documentation    Common keywords for Resource Checks

Library    taf.ul.hanging_resources
Library    ../libraries/resource_file_handling.py    WITH NAME  resource_checks
Library    ../libraries/template_functions.py        WITH NAME  template
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Resource    common_keywords.robot

*** Keywords ***


Compare Resource Usage for all Scenarios
    ${scenarios}=  template.get_list_of_all_scenarios  ${TEST TAGS}
    FOR    ${scenario}    IN    @{scenarios}
        Compare Resource Usage for Scenario  ${scenario}
    END



Compare Resource Usage for Scenario
    [Arguments]  ${scenario_name}
    ${resources_usage_before}  ${resources_usage_after}=  resource_checks.get_resources_for_current_scenario  ${scenario_name}  ${ts_log_dir}
    Run Keyword And Continue On Failure  taf.ul.hanging_resources.resources should be equal
    ...     ${resources_usage_before}
    ...     ${resources_usage_after}

