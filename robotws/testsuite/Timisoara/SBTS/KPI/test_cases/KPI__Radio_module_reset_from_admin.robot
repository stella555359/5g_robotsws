*** Settings ***
Documentation  This suite contains KPI__Radio_module_reset_from_admin TC

Resource  ../test_resources/KPI__Radio_module_reset_from_admin.robot


*** Test Cases ***
KPI__Radio_module_reset_from_admin
    [Setup]  TC Setup
    TC__KPI__Radio_module_reset_from_admin
    [Teardown]  TC Teardown
