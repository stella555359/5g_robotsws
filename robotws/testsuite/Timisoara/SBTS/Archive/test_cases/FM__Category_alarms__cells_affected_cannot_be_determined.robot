*** Settings ***
Resource    ../test_resources/FM__Category_alarms__cells_affected_cannot_be_determined.robot

*** Test Cases ***
FM__Category_alarms__cells_affected_cannot_be_determined
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__FM__Category_alarms__cells_affected_cannot_be_determined

