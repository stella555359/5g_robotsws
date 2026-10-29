*** Settings ***
Documentation  This suite contains KPI__BTS_autonomous_reset_after_plan_activation TC

Resource  ../test_resources/KPI__BTS_autonomous_reset_after_plan_activation.robot


*** Test Cases ***
KPI__BTS_autonomous_reset_after_plan_activation
    [Setup]  TC Setup
    TC__KPI__BTS_autonomous_reset_after_plan_activation
    [Teardown]  TC Teardown
