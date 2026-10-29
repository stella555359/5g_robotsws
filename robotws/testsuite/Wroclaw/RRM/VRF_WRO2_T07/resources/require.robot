*** Settings ***
Documentation    Use `Require Keyword` if you want to run KW only once in whole suite


*** Keywords ***
Require Keyword
    [Arguments]   ${kw_name}
    ${kw_result}   Get Variable Value    ${${kw_name}}
    Run Keyword If 	'${kw_result}' in ['', None, 'None', False, 'False']   Run Pre Keyword  ${kw_name}


Run Pre Keyword
    [Arguments]       ${kw_name}
    ${kw_result}   Run Keyword And Return Status   ${kw_name}
    Set Suite Variable   ${${kw_name}}   ${kw_result}
