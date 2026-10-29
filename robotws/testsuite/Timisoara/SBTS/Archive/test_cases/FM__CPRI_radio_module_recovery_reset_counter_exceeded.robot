*** Settings ***
Resource    ../test_resources/FM__CPRI_radio_module_recovery_reset_counter_exceeded.robot

*** Test Cases ***
TC__CPRI_radio_module_recovery_reset_counter_exceeded
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    FM__CPRI_radio_module_recovery_reset_counter_exceeded
