*** Settings ***
Resource    ../test_resources/WebEM__Run_RF_Diagnostic_test_using_WebEM_all_retrieved_measurements_do_fall_within_the_thresholds.robot

*** Test Cases ***
WebEM__Run_RF_Diagnostic_test_using_WebEM_all_retrieved_measurements_do_fall_within_the_thresholds
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__WebEM__Run_RF_Diagnostic_test_using_WebEM_all_retrieved_measurements_do_fall_within_the_thresholds
