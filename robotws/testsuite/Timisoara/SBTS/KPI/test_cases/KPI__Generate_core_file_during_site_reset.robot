*** Settings ***
Documentation  This suite contains KPI__Generate_core_file_during_site_reset TC

Resource  ../test_resources/KPI__Generate_core_file_during_site_reset.robot


*** Test Cases ***
KPI__Generate_core_file_during_site_reset
    [Setup]  TC Setup
    TC__KPI__Generate_core_file_during_site_reset
    [Teardown]  TC Teardown
