*** Settings ***
Resource    ../test_resources/FM__Report_alarms_triggered_on_RMOD_and_BBMOD_to_ONAP_ASIL.robot

*** Test Cases ***
TC__FM__Report_alarms_triggered_on_RMOD_and_BBMOD_to_ONAP_ASIL
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    FM__Report_alarms_triggered_on_RMOD_and_BBMOD_to_ONAP_ASIL
