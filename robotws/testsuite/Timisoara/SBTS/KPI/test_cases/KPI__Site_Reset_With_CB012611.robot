*** Settings ***
Documentation  This suite contains KPI__Site_Reset_With_CB012611 TC

Resource  ../test_resources/KPI__Site_Reset_With_CB012611.robot


*** Test Cases ***
KPI__Site_Reset_With_CB012611
    [Setup]  TC Setup
    TC__KPI__Site_Reset_With_CB012611
    [Teardown]  TC Teardown