*** Settings ***
Documentation  This suite contains WebEM__5G_Delta_plan_activation_for_parameters TC

Resource  ../test_resources/WebEM__5G_Delta_plan_activation_for_parameters.robot


*** Test Cases ***
WebEM__5G_Delta_plan_activation_for_parameters
    [Setup]  TC Setup
    TC__WebEM__5G_Delta_plan_activation_for_parameters
    [Teardown]  TC Teardown
