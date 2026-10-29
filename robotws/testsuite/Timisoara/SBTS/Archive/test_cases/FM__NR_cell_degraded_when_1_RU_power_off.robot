*** Settings ***
Resource    ../test_resources/FM__NR_cell_degraded_when_1_RU_power_off.robot

*** Test Cases ***
TC__FM__NR_cell_degraded_when_1_RU_power_off
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    FM__NR_cell_degraded_when_1_RU_power_off