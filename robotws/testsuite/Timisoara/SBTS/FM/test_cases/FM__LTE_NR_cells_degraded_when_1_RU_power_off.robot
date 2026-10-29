*** Settings ***
Documentation  This suite contains FM__LTE_NR_cells_degraded_when_1_RU_power_off TC

Resource  ../test_resources/FM__LTE_NR_cells_degraded_when_1_RU_power_off.robot


*** Test Cases ***
TC__FM__LTE_NR_cells_degraded_when_1_RU_power_off
    [Setup]  TC Setup
    FM__LTE_NR_cells_degraded_when_1_RU_power_off
    [Teardown]  TC Teardown
