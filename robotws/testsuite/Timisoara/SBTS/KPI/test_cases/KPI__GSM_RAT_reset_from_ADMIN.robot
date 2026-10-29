*** Settings ***
Documentation  This suite contains KPI__GSM_RAT_reset_from_ADMIN TC

Resource  ../test_resources/KPI__GSM_RAT_reset_from_ADMIN.robot


*** Test Cases ***
KPI__GSM_RAT_reset_from_ADMIN
    [Setup]  TC Setup
    TC__KPI__GSM_RAT_reset_from_ADMIN
    [Teardown]  TC Teardown
