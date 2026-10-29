*** Settings ***
Resource    ../test_resources/FM__link_break_S1_short.robot

*** Test Cases ***
FM__link_break_S1_short
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__FM__link_break_S1_short

