*** Settings ***
Resource    ../test_resources/FM__Report_alarms_triggered_on_SMOD_CELL_to_ONAP.robot

*** Test Cases ***
FM__Report_alarms_triggered_on_SMOD_CELL_to_ONAP
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__FM__Report_alarms_triggered_on_SMOD_CELL_to_ONAP

