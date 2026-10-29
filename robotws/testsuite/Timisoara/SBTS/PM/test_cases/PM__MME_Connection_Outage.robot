*** Settings ***
Documentation  This suite contains PM__MME_Connection_Outage TC

Resource  ../test_resources/PM__MME_Connection_Outage.robot


*** Test Cases ***
PM__MME_Connection_Outage
    [Setup]  TC Setup
    TC__PM__MME_Connection_Outage
    [Teardown]  TC Teardown
