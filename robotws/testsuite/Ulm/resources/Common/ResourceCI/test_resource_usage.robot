*** Settings ***

Documentation
...   This is a test suite used in KW resourceCI running against real AP TL.
...   It verifies proper function of KWs in user library taf.ul.hanging_resources.
...   The suite prooves the listener handling but not the KWs!
...   KW checks are made in test_hanging_resources_keywords.robot.


Library   taf.ul.hanging_resources.listener
Library   taf.ul.hanging_resources

Suite Setup    Prepare Hanging Resources
*** Test Cases ***
Test running the Resource Usage
    Log To Console    \nTest Case Execution....
    Sleep    10s

Test without Running Resource Usage
    [TAGS]   NoResUsage
    Log To Console    \nTest Case Execution....

*** Keywords ***
Prepare Hanging Resources
    taf.ul.hanging_resources.Configure Default Excluding Resource Paths
    ...    add=//postTimerWheel
