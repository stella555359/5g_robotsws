*** Settings ***
Documentation  This suite contains WebEM__WiFi_management TC

Resource    ../test_resources/WebEM__WiFi_management.robot

*** Test Cases ***
WebEM__WiFi_management
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__WebEM__WiFi_management