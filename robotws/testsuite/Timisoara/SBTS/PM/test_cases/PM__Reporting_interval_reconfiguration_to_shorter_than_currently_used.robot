*** Settings ***
Documentation  This suite contains PM__Reporting_interval_reconfiguration_to_shorter_than_currently_used TC

Resource  ../test_resources/PM__Reporting_interval_reconfiguration_to_shorter_than_currently_used.robot


*** Test Cases ***
PM__Reporting_interval_reconfiguration_to_shorter_than_currently_used
    [Setup]  TC Setup
    TC__PM__Reporting_interval_reconfiguration_to_shorter_than_currently_used
    [Teardown]  TC Teardown
