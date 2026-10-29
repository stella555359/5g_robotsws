*** Settings ***
Resource    ../test_resources/FM__RAT_reset_actForceAutoReset_false_faulty_cells.robot

*** Test Cases ***
FM__RAT_reset_actForceAutoReset_false_faulty_cells
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__FM__RAT_reset_actForceAutoReset_false_faulty_cells

