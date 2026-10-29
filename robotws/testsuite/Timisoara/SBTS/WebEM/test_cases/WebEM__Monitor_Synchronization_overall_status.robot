*** Settings ***
Documentation  This suite contains WebEM__Monitor_Synchronization_overall_status TC

Resource  ../test_resources/WebEM__Monitor_Synchronization_overall_status.robot


*** Test Cases ***
WebEM__Monitor_Synchronization_overall_status
    [Setup]  TC Setup
    TC__WebEM__Monitor_Synchronization_overall_status
    [Teardown]  TC Teardown
