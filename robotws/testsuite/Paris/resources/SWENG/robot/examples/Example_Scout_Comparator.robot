*** Settings ***
Documentation     Example suite for new Scout comparator keywords
Library           BuiltIn
Library           OperatingSystem
Resource          ../Scout.robot

*** Variables ***
## ${REPORT_ID}         1165894
${REPORT_ID}         1202361
${EXCEL_PATH}        /tmp/example_scout_comparator.xlsx
${EXCEL_PATH_KPI_FILTER}    /tmp/example_scout_comparator_kpi_filter.xlsx
${EXCEL_PATH_DIST_FILTER}    /tmp/example_scout_comparator_dist_filter.xlsx
${EXCEL_PATH_BOTH_FILTERS}   /tmp/example_scout_comparator_both_filters.xlsx
${SCOUT_API_TOKEN}    aa9dc9a5-8ec2-40d3-a1be-9d2b539c7134

*** Test Cases ***
Fetch Scout Comparator Report To Excel
    [Documentation]    Test fetching a Scout comparator report and saving as Excel
    ${token}=    Get Api Token
    ${result}=   Fetch Scout Comparator Report To Excel    ${REPORT_ID}    ${EXCEL_PATH}
    Should Be True    ${result}
    File Should Exist    ${EXCEL_PATH}

Fetch Scout Comparator Report With KPI Filter
    [Documentation]    Test fetching Scout comparator report with KPI filter parameter
    ...    Filters output to only include specified KPI codes (e.g., NR_5055c, NR_5057e)
    ...    This demonstrates the expected_kpis optional parameter functionality
    [Tags]    example    optional-parameters    kpi-filter
    ${token}=    Get Api Token
    @{kpi_list}=    Create List    NR_5055c    NR_5057e
    ${result}=    Fetch Scout Comparator Report To Excel
    ...    ${REPORT_ID}    ${EXCEL_PATH_KPI_FILTER}    None    ${kpi_list}
    Should Be True    ${result}
    File Should Exist    ${EXCEL_PATH_KPI_FILTER}
    Log    Excel file created with KPI filter: ${EXCEL_PATH_KPI_FILTER}

Fetch Scout Comparator Report With Entity Filter
    [Documentation]    Test fetching Scout comparator report with entity/distribution name filter
    ...    Filters output to only include specified entities (e.g., bts, NRCELL-1)
    ...    This demonstrates the expected_dist_names optional parameter functionality
    [Tags]    example    optional-parameters    entity-filter
    ${token}=    Get Api Token
    @{entity_list}=    Create List    bts    NRCELL-1
    ${result}=    Fetch Scout Comparator Report To Excel
    ...    ${REPORT_ID}    ${EXCEL_PATH_DIST_FILTER}    None    None    ${entity_list}
    Should Be True    ${result}
    File Should Exist    ${EXCEL_PATH_DIST_FILTER}
    Log    Excel file created with entity filter: ${EXCEL_PATH_DIST_FILTER}

Fetch Scout Comparator Report With Both Filters
    [Documentation]    Test fetching Scout comparator report with both KPI and entity filters
    ...    Demonstrates combined use of expected_kpis and expected_dist_names parameters
    ...    Output will contain only rows matching BOTH filter criteria (AND logic)
    [Tags]    example    optional-parameters    combined-filter
    ${token}=    Get Api Token
    @{kpi_list}=    Create List    NR_5055c    NR_5057e
    @{entity_list}=    Create List    bts    NRCELL-1
    ${result}=    Fetch Scout Comparator Report To Excel
    ...    ${REPORT_ID}    ${EXCEL_PATH_BOTH_FILTERS}    None    ${kpi_list}    ${entity_list}
    Should Be True    ${result}
    File Should Exist    ${EXCEL_PATH_BOTH_FILTERS}
    Log    Excel file created with KPI and entity filters: ${EXCEL_PATH_BOTH_FILTERS}
