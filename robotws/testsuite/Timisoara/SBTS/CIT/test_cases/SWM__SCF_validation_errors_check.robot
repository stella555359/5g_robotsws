*** Settings ***
Documentation  This suite contains SWM__SCF_validation_errors_check TC

Resource  ../test_resources/SWM__SCF_validation_errors_check.robot


*** Test Cases ***
SWM__SCF_validation_errors_check
    [Setup]  TC Setup
    TC__SWM__SCF_validation_errors_check
    [Teardown]  TC Teardown
