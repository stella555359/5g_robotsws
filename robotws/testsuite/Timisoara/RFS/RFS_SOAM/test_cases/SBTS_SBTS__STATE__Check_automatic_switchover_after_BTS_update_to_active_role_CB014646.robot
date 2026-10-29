*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__STATE__Check_automatic_switchover_after_BTS_update_to_active_role_CB014646.robot

*** Test Cases ***
[1]SBTS_SBTS__STATE__Check_automatic_switchover_after_BTS_update_to_active_role_CB014646
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__STATE__Check_automatic_switchover_after_BTS_update_to_active_role_CB014646
