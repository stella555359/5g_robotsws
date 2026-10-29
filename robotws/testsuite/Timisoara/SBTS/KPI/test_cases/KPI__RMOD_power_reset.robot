*** Settings ***
Documentation  This suite contains KPI__RMOD_power_reset TC

Resource  ../test_resources/KPI__RMOD_power_reset.robot


*** Test Cases ***
KPI__RMOD_power_reset
    [Setup]  TC Setup
    TC__KPI__RMOD_power_reset
    [Teardown]  TC Teardown
