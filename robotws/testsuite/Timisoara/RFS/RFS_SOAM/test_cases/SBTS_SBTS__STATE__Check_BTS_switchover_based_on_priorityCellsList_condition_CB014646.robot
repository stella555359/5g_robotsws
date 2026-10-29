*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__STATE__Check_BTS_switchover_based_on_priorityCellsList_condition_CB014646.robot

*** Test Cases ***
[1]SBTS_SBTS__STATE__Check_BTS_switchover_based_on_priorityCellsList_condition_CB014646
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__STATE__Check_BTS_switchover_based_on_priorityCellsList_condition_CB014646
