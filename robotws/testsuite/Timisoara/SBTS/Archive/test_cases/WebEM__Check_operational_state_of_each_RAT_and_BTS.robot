*** Settings ***
Resource    ../test_resources/WebEM__Check_operational_state_of_each_RAT_and_BTS.robot

*** Test Cases ***
WebEM__Check_operational_state_of_each_RAT_and_BTS
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__WebEM__Check_operational_state_of_each_RAT_and_BTS
