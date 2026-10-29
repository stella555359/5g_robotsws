*** Settings ***
Documentation
    ...  This suite contains WebEM__CP_WebEM_usability_for_large_configurations_Mobile TC

Resource  ../test_resources/WebEM__CP_WebEM_usability_for_large_configurations_Mobile.robot


*** Test Cases ***
WebEM__CP_WebEM_usability_for_large_configurations_Mobile
    [Setup]  TC Setup
    TC__WebEM__CP_WebEM_usability_for_large_configurations_Mobile
    [Teardown]  TC Teardown