*** Settings ***
Documentation  This suite contains PM__LTE_Cell_Availability TC

Resource  ../test_resources/PM__LTE_Cell_Availability.robot


*** Test Cases ***
PM__LTE_Cell_Availability
    [Setup]  TC Setup
    TC__PM__LTE_Cell_Availability
    [Teardown]  TC Teardown
