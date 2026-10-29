*** Settings ***
Documentation
...    custom Run Keyword if not present in robot builtin

*** Keywords ***

Run Keyword if Suite Setup Passed
    [Documentation]    Only works in suite teardowns. Skip execution of the provided keyword if suite setup failed.
    [Arguments]    @{keyword}
    ${status}=    run keyword and return status    Should not Match    ${SUITE MESSAGE}    pattern=Suite setup failed:*
    run keyword if    ${status}    @{keyword}
    ...    ELSE       log    suite setup failed, skipping excecution of '${keyword}[0]'.
