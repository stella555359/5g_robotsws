*** Settings ***
Documentation  This suite contains KPI__LTE_RAT_reset_from_ADMIN TC

Resource  ../test_resources/KPI__LTE_RAT_reset_from_ADMIN.robot


*** Test Cases ***
KPI__LTE_RAT_reset_from_ADMIN
    [Setup]  TC Setup
    TC__KPI__LTE_RAT_reset_from_ADMIN
    [Teardown]  TC Teardown
