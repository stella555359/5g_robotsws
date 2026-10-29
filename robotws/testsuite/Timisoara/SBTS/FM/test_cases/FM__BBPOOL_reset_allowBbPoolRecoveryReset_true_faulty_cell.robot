*** Settings ***
Documentation  This suite contains FM__BBPOOL_reset_allowBbPoolRecoveryReset_true_faulty_cell TC

Resource  ../test_resources/FM__BBPOOL_reset_allowBbPoolRecoveryReset_true_faulty_cell.robot


*** Test Cases ***
FM__BBPOOL_reset_allowBbPoolRecoveryReset_true_faulty_cell
    [Setup]  TC Setup
    TC__FM__BBPOOL_reset_allowBbPoolRecoveryReset_true_faulty_cell
    [Teardown]  TC Teardown
