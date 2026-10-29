*** Settings ***
Documentation  This suite contains WebEM__vDU__RF_statistic_diagnostic_test_can_run_from_WebEM_with_measurements_outside_thresholds TC

Resource  ../test_resources/WebEM__vDU__RF_statistic_diagnostic_test_can_run_from_WebEM_with_measurements_outside_thresholds.robot


*** Test Cases ***
WebEM__vDU__RF_statistic_diagnostic_test_can_run_from_WebEM_with_measurements_outside_thresholds
    [Setup]  TC Setup
    TC__WebEM__vDU__RF_statistic_diagnostic_test_can_run_from_WebEM_with_measurements_outside_thresholds
    [Teardown]  TC Teardown
