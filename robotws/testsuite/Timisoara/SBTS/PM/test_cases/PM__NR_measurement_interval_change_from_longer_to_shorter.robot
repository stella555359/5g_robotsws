*** Settings ***
Documentation  This suite contains PM__NR_measurement_interval_change_from_longer_to_shorter TC

Resource  ../test_resources/PM__NR_measurement_interval_change_from_longer_to_shorter.robot


*** Test Cases ***
PM__NR_measurement_interval_change_from_longer_to_shorter
    [Setup]  TC Setup
    TC__PM__NR_measurement_interval_change_from_longer_to_shorter
    [Teardown]  TC Teardown
