*** Settings ***
Documentation  This suite contains WebEM__User_access_control_permission_for_BBMOD_power_reset TC

Resource  ../test_resources/WebEM__User_access_control_permission_for_BBMOD_power_reset.robot


*** Test Cases ***
WebEM__User_access_control_permission_for_BBMOD_power_reset
    [Setup]  TC Setup
    TC__WebEM__User_access_control_permission_for_BBMOD_power_reset
    [Teardown]  TC Teardown
