*** Settings ***
Documentation  This suite contains WebEM__Check_the_CSV_file_with_PRB_measurements TC

Resource  ../test_resources/WebEM__Check_the_CSV_file_with_PRB_measurements.robot


*** Test Cases ***
WebEM__Check_the_CSV_file_with_PRB_measurements
    [Setup]  TC Setup
    TC__WebEM__Check_the_CSV_file_with_PRB_measurements
    [Teardown]  TC Teardown
