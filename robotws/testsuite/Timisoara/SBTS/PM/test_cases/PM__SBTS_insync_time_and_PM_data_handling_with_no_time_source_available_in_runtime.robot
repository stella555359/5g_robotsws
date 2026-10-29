*** Settings ***
Documentation  This suite contains PM__SBTS_insync_time_and_PM_data_handling_with_no_time_source_available_in_runtime TC

Resource  ../test_resources/PM__SBTS_insync_time_and_PM_data_handling_with_no_time_source_available_in_runtime.robot


*** Test Cases ***
PM__SBTS_insync_time_and_PM_data_handling_with_no_time_source_available_in_runtime
    [Setup]  TC Setup
    TC__PM__SBTS_insync_time_and_PM_data_handling_with_no_time_source_available_in_runtime
    [Teardown]  TC Teardown
