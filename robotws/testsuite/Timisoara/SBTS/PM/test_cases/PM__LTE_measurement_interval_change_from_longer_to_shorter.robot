*** Settings ***
Documentation  This suite contains PM__LTE_measurement_interval_change_from_longer_to_shorter TC

Resource  ../test_resources/PM__LTE_measurement_interval_change_from_longer_to_shorter.robot


*** Test Cases ***
PM__LTE_measurement_interval_change_from_longer_to_shorter
    [Setup]  TC Setup
    TC__PM__LTE_measurement_interval_change_from_longer_to_shorter
    [Teardown]  TC Teardown
