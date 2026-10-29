*** Settings ***
Documentation  This suite contains WebEM__Viewing_BTS_Performance_Counter_for_5G TC

Resource  ../test_resources/WebEM__Viewing_BTS_Performance_Counter_for_5G.robot


*** Test Cases ***
WebEM__Viewing_BTS_Performance_Counter_for_5G
    [Setup]  TC Setup
    TC__WebEM__Viewing_BTS_Performance_Counter_for_5G
    [Teardown]  TC Teardown
