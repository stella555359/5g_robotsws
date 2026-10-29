*** Settings ***
Documentation  This suite contains KPI__Site_reset TC

Resource  ../test_resources/KPI__Site_reset.robot


*** Test Cases ***
KPI__Site_reset
    [Setup]  TC Setup
    TC__KPI__Site_reset
    [Teardown]  TC Teardown
