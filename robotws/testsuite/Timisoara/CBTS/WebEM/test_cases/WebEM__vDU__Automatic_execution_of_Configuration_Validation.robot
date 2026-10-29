*** Settings ***
Documentation  This suite contains WebEM__vDU__Automatic_execution_of_Configuration_Validation TC

Resource  ../test_resources/WebEM__vDU__Automatic_execution_of_Configuration_Validation.robot


*** Test Cases ***
WebEM__vDU__Automatic_execution_of_Configuration_Validation
    [Setup]  TC Setup
    TC__WebEM__vDU__Automatic_execution_of_Configuration_Validation
    [Teardown]  TC Teardown
