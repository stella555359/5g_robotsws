*** Settings ***
Documentation  This suite contains WebEM__vDU__CW_Configuration_plan_creation_of_a_new_configuration_plan TC

Resource  ../test_resources/WebEM__vDU__CW_Configuration_plan_creation_of_a_new_configuration_plan.robot


*** Test Cases ***
WebEM__vDU__CW_Configuration_plan_creation_of_a_new_configuration_plan
    [Setup]  TC Setup
    TC__WebEM__vDU__CW_Configuration_plan_creation_of_a_new_configuration_plan
    [Teardown]  TC Teardown
