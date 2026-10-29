*** Settings ***
Documentation  This suite contains WebEM__Check_test_dedicated_state TC

Resource  ../test_resources/WebEM__Check_test_dedicated_state.robot


*** Test Cases ***
WebEM__Check_test_dedicated_state
    [Setup]  TC Setup
    TC__WebEM__Check_test_dedicated_state
    [Teardown]  TC Teardown
