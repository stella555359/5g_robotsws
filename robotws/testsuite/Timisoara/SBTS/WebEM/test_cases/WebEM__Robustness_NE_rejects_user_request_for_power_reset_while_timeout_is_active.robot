*** Settings ***
Documentation  This suite contains WebEM__Robustness_NE_rejects_user_request_for_power_reset_while_timeout_is_active TC

Resource  ../test_resources/WebEM__Robustness_NE_rejects_user_request_for_power_reset_while_timeout_is_active.robot


*** Test Cases ***
WebEM__Robustness_NE_rejects_user_request_for_power_reset_while_timeout_is_active
    [Setup]  TC Setup
    TC__WebEM__Robustness_NE_rejects_user_request_for_power_reset_while_timeout_is_active
    [Teardown]  TC Teardown
