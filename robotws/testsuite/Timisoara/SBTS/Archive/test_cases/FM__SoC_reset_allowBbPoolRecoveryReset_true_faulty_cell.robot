*** Settings ***
Resource    ../test_resources/FM__SoC_reset_allowBbPoolRecoveryReset_true_faulty_cell.robot

*** Test Cases ***
FM__SoC_reset_allowBbPoolRecoveryReset_true_faulty_cell
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__FM__SoC_reset_allowBbPoolRecoveryReset_true_faulty_cell
