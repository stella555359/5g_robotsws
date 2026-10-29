*** Settings ***
Documentation  This suite contains WebEM__RF_Monitoring TC

Resource  ../test_resources/WebEM__RF_Monitoring.robot


*** Test Cases ***
WebEM__RF_Monitoring
    [Setup]  TC Setup
    TC__WebEM__RF_Monitoring
    [Teardown]  TC Teardown
