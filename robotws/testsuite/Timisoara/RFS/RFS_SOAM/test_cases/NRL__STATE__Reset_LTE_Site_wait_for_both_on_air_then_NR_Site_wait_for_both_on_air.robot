*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/NRL__STATE__Reset_LTE_Site_wait_for_both_on_air_then_NR_Site_wait_for_both_on_air.robot

*** Test Cases ***
[1]NRL__STATE__Reset_LTE_Site_wait_for_both_on_air_then_NR_Site_wait_for_both_on_air
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__NRL__STATE__Reset_LTE_Site_wait_for_both_on_air_then_NR_Site_wait_for_both_on_air

