*** Settings ***
Resource    ../test_resources/WebEM__Antenna_Line_Monitoring.robot

*** Test Cases ***
WebEM__Antenna_Line_Monitoring
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__WebEM__Antenna_Line_Monitoring
