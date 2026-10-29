*** Settings ***
Documentation  This suite contains PM__Reporting_interval_reconfiguration_to_longer_than_currently_used_30_min TC

Resource  ../test_resources/PM__Reporting_interval_reconfiguration_to_longer_than_currently_used_30_min.robot


*** Test Cases ***
PM__Reporting_interval_reconfiguration_to_longer_than_currently_used_30_min
    [Setup]  TC Setup
    TC__PM__Reporting_interval_reconfiguration_to_longer_than_currently_used_30_min
    [Teardown]  TC Teardown
