*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__STATE__No_BTS_switchover_during_Cell_block_unblock_CB014646.robot

*** Test Cases ***
[1]SBTS_SBTS__STATE__No_BTS_switchover_during_Cell_block_unblock_CB014646
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__STATE__No_BTS_switchover_during_Cell_block_unblock_CB014646
