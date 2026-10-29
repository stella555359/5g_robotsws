*** Settings ***
Library   taf.ul.hanging_resources.listener

*** Test Cases ***
Test running the Resource Usage
    Log To Console    \nTest Case Execution....
    Sleep    10s

Test without Running Resource Usage
    [TAGS]   NoResUsage
    Log To Console    \nTest Case Execution....


