*** Settings ***
Documentation    Library for handling integration with RePor

Library         ScoutReport.py
Library         support.py

Library         taf.sw.reporting_portal

*** Keywords ***
Add Scout External Execution ID To Reporting Portal
    ${manual_execution}=    is_manual_execution
    ${tl_name_scout}=    get_testline_name_in_scout
    ${scout_id}=    fetch_scout_configuration    ${tl_name_scout}    ${manual_execution}
    Run Keyword If    '${scout_id}'!='None'
    ...                Run Keyword If    '${manual_execution}'=='True'
    ...                Add To Test Data    data={"tc_execution_id": "${scout_id}"}
