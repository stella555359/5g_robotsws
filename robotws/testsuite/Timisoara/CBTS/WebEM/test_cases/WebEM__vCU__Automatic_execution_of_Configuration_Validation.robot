*** Settings ***
Documentation  This suite contains WebEM__vCU__Automatic_execution_of_Configuration_Validation TC

Resource  ../test_resources/WebEM__vCU__Automatic_execution_of_Configuration_Validation.robot


*** Test Cases ***
WebEM__vCU__Automatic_execution_of_Configuration_Validation
    [Setup]  TC Setup
    TC__WebEM__vCU__Automatic_execution_of_Configuration_Validation
    [Teardown]  TC Teardown
