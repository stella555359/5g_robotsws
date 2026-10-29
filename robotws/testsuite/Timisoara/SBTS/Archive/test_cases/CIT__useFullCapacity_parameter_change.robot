*** Settings ***
Resource    ../test_resources/CIT__useFullCapacity_parameter_change.robot

*** Test Cases ***
CIT__useFullCapacity_parameter_change
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__CIT__useFullCapacity_parameter_change