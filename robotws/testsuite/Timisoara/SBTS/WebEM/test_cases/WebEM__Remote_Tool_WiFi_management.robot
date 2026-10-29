*** Settings ***
Documentation  This suite contains WebEM__Remote_Tool_WiFi_management TC

Resource  ../test_resources/WebEM__Remote_Tool_WiFi_management.robot


*** Test Cases ***
WebEM__Remote_Tool_WiFi_management
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__WebEM__Remote_Tool_WiFi_management
