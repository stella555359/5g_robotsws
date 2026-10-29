*** Settings ***
Documentation  This suite contains KPI__Cell_lock_unlock_for_LTE_or_NR TC

Resource  ../test_resources/KPI__Cell_lock_unlock_for_LTE_or_NR.robot


*** Test Cases ***
KPI__Cell_lock_unlock_for_LTE_or_NR
    [Setup]  TC Setup
    TC__KPI__Cell_lock_unlock_for_LTE_or_NR
    [Teardown]  TC Teardown
