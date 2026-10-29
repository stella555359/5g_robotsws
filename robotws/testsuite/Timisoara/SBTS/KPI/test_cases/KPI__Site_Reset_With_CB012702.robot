*** Settings ***
Documentation  This suite contains KPI__Site_Reset_With_CB012702 TC

Resource  ../test_resources/KPI__Site_Reset_With_CB012702.robot


*** Test Cases ***
KPI__Site_Reset_With_CB012702
    [Setup]  TC Setup
    TC__KPI__Site_Reset_With_CB012702
    [Teardown]  TC Teardown
