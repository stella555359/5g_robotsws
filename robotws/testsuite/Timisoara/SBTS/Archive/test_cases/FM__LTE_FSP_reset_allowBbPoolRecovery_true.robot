*** Settings ***
Resource    ../test_resources/FM__LTE_FSP_reset_allowBbPoolRecovery_true.robot

*** Test Cases ***
TC__FM__BBPOOL_reset_allowBbPoolRecoveryReset_true_testcase
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__FM__BBPOOL_reset_allowBbPoolRecoveryReset_true
