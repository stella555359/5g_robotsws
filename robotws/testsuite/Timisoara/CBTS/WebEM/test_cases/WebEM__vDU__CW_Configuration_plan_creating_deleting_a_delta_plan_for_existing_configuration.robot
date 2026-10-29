*** Settings ***
Documentation  This suite contains WebEM__vDU__CW_Configuration_plan_creating_deleting_a_delta_plan_for_existing_configuration TC

Resource  ../test_resources/WebEM__vDU__CW_Configuration_plan_creating_deleting_a_delta_plan_for_existing_configuration.robot


*** Test Cases ***
WebEM__vDU__CW_Configuration_plan_creating_deleting_a_delta_plan_for_existing_configuration
    [Setup]  TC Setup
    TC__WebEM__vDU__CW_Configuration_plan_creating_deleting_a_delta_plan_for_existing_configuration
    [Teardown]  TC Teardown
