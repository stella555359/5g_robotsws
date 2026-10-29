*** Settings ***
Resource    ../test_resources/WebEM__Lock_Unlock_LANE.robot

*** Test Cases ***
WebEM__Lock_Unlock_LANE
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__WebEM__Lock_Unlock_LANE
