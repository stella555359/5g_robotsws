*** Settings ***
Documentation  This suite contains WebEM__vDU__Save_and_delete_RF_diagnostic_and_RF_statistic_diagonstic_test_results TC

Resource  ../test_resources/WebEM__vDU__Save_and_delete_RF_diagnostic_and_RF_statistic_diagonstic_test_results.robot


*** Test Cases ***
WebEM__vDU__Save_and_delete_RF_diagnostic_and_RF_statistic_diagonstic_test_results
    [Setup]  TC Setup
    TC__WebEM__vDU__Save_and_delete_RF_diagnostic_and_RF_statistic_diagonstic_test_results
    [Teardown]  TC Teardown
