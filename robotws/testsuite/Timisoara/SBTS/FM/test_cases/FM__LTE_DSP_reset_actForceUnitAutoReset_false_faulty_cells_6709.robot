*** Settings ***
Documentation  This suite contains FM__LTE_DSP_reset_actForceUnitAutoReset_false_faulty_cells_6709 TC

Resource  ../test_resources/FM__LTE_DSP_reset_actForceUnitAutoReset_false_faulty_cells_6709.robot


*** Test Cases ***
FM__LTE_DSP_reset_actForceUnitAutoReset_false_faulty_cells_6709
    [Setup]  TC Setup
    TC__FM__LTE_DSP_reset_actForceUnitAutoReset_false_faulty_cells_6709
    [Teardown]  TC Teardown
