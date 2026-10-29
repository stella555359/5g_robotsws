*** Settings ***
Documentation       :copyright: Nokia
...                 :author   : Hari Somu
...                 :contact  : hari.somu@nokia.com
...                 Scout Wrapper Keywords For Setup, KPI generation

Library    taf.sw.scout     WITH NAME    scout
Library    OperatingSystem
Library    Process
Library    String
Library    BuiltIn
Library    Collections

*** Keywords ***
Get Hostname With Underscore
    ${result}=    Run Process    hostname    shell=True    stdout=-    stderr=-
    Should Be Equal As Integers    ${result.rc}    0
    ${hostname}=    Set Variable    ${result.stdout.strip()}
    ${clean_hostname}=    Replace String    ${hostname}    -    _
    [Return]    ${clean_hostname}

Configure Scout API
    [Documentation]      Intial Scout Configuration. Requires Scout api key available in scout.
    [Arguments]    ${api_key}
    ${testline_name}    Get Hostname with Underscore
    scout.Setup Scout    scout_testline_name=${testline_name}    api_key=${api_key}    timeout=300    alias=scoutalias
    Log To Console    Scout API successfully configured for testline: ${testline_name}

Teardown Scout Connection
    [Documentation]      Teardowns the scout connection
    [Arguments]    ${alias}=scoutalias
    Log To Console    Attempting to tear down Scout API connection for alias: ${alias}
    Teardown Scout Api    alias=${alias}
    Log To Console    Scout API connection successfully torn down.

Enable Kpi Pm Collection
    [Documentation]      Teardowns the scout connection
    [Arguments]    ${alias}=scoutalias
    Log To Console    Attempting to tear down Scout API connection for alias: ${alias}
    scout.Enable Full Kpi Pm Collection    alias=${alias}
    Log To Console    Scout API connection successfully torn down.

Generate Scout Kpi Report
    [Documentation]    Generates a KPI report in Scout for a specified testline.
    ...    This keyword requires an API_KEY to be provided during the library setup
    [Arguments]    ${report_name}    ${template_id}    ${start_time}    ${end_time}=${None}    ${alias}=scoutalias
    ${KPI_REPORT}=    scout.Generate Kpi Report
    ...    report_name=${report_name}
    ...    template_id=${template_id}
    ...    start_time=${start_time}
    ...    end_time=${end_time}
    ...    alias=${alias}
    Create KPI Report JSON File     ${KPI_REPORT}   ${report_name}
    [Return]    ${KPI_REPORT}

Create KPI Report JSON File
    [Documentation]     Convert KPI report to JSON
    [Arguments]    ${KPI_REPORT}    ${filename}
    ${json_string}=    Evaluate    json.dumps($KPI_REPORT)    modules=json
    Create File    ${filename}    ${json_string}
    [Return]    ${json_string}

Generate Scout Comparator Report
    [Documentation]    Generates a comparator report in Scout for a specified testline.
    ...    This keyword requires an API_KEY. It should ideally be provided during the
    ...    'Configure Scout API' keyword call for the relevant alias.
    [Arguments]    ${report_name}
    ...    ${template_ids}
    ...    ${reference_start_time}
    ...    ${reference_end_time}
    ...    ${current_start_time}
    ...    ${current_end_time}
    ${COMPARATOR_REPORT}=    scout.Generate Comparator Report
    ...    report_name=${report_name}
    ...    template_ids=${template_ids}
    ...    reference_start_time=${reference_start_time}
    ...    reference_end_time=${reference_end_time}
    ...    current_start_time=${current_start_time}
    ...    current_end_time=${current_end_time}
    ...    alpha_factor=0.001
    ...    block_until_ready=True
    ...    timeout=600
    ...    alias=scoutalias
    [Return]    ${COMPARATOR_REPORT}

Get Active Software from Scout
    ${testline_name}    Get Hostname with Underscore
    ${testline}=    scout.Get Testline    name=${testline_name}    alias=scoutalias
    [RETURN]    ${testline['infomodel']['activesw']}
