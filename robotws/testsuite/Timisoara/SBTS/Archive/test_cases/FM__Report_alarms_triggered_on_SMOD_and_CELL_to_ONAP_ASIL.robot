*** Settings ***
Resource    ../test_resources/FM__Report_alarms_triggered_on_SMOD_and_CELL_to_ONAP_ASIL.robot

*** Test Cases ***
TC__Report_alarms_triggered_on_SMOD_and_CELL_to_ONAP_ASIL
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    FM__Report_alarms_triggered_on_SMOD_and_CELL_to_ONAP_ASIL
