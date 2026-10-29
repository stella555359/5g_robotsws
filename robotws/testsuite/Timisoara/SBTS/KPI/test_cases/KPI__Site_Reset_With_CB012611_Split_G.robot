*** Settings ***
Documentation  This suite contains KPI__Site_Reset_With_CB012611_Split_G TC

Resource  ../test_resources/KPI__Site_Reset_With_CB012611_Split_G.robot


*** Test Cases ***
KPI__Site_Reset_With_CB012611_Split_G
    [Setup]  TC Setup
    TC__KPI__Site_Reset_With_CB012611_Split_G
    [Teardown]  TC Teardown