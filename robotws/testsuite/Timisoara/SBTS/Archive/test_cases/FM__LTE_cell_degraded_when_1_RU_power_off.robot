*** Settings ***
Resource    ../test_resources/FM__LTE_cell_degraded_when_1_RU_power_off.robot

*** Test Cases ***
TC__FM__LTE_cell_degraded_when_1_RU_power_off
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    FM__LTE_cell_degraded_when_1_RU_power_off