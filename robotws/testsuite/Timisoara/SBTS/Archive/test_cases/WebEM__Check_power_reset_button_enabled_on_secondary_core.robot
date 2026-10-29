*** Settings ***
Resource    ../test_resources/WebEM__Check_power_reset_button_enabled_on_secondary_core.robot

*** Test Cases ***
WebEM__Check_power_reset_button_enabled_on_secondary_core
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__WebEM__Check_power_reset_button_enabled_on_secondary_core
