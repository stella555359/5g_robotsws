*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__STATE__RMOD_high_temp_alarm_and_counters_check_CB011167.robot

*** Test Cases ***
[1]SBTS_SBTS__STATE__RMOD_high_temp_alarm_and_counters_check_CB011167
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__STATE__RMOD_high_temp_alarm_and_counters_check_CB011167