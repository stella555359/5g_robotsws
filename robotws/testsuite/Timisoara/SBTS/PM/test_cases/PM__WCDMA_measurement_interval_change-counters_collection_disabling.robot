*** Settings ***
Documentation  This suite contains PM__WCDMA_measurement_interval_change TC

Resource  ../test_resources/PM__WCDMA_measurement_interval_change-counters_collection_disabling.robot


*** Test Cases ***
PM__WCDMA_measurement_interval_change-counters_collection_disabling
    [Setup]  TC Setup
    TC__PM__WCDMA_measurement_interval_change-counters_collection_disabling
    [Teardown]  TC Teardown
