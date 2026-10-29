*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/NRL__CM__LTE_Recomissioning_pmax_with_LTE_template.robot

*** Test Cases ***
[1]NRL__CM__LTE_Recomissioning_pmax_with_LTE_template
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__NRL__CM__LTE_Recomissioning_pmax_with_LTE_template

