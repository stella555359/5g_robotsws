*** Settings ***
Resource    ../test_resources/FM__LTE_FSP_reset_actForceUnitAutoReset_true_faulty_cells.robot

*** Test Cases ***
FM__LTE_FSP_reset_actForceUnitAutoReset_true_faulty_cells
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__FM__LTE_FSP_reset_actForceUnitAutoReset_true_faulty_cells

