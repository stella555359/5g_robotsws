*** Settings ***
Resource    ../test_resources/CIT__BBMOD_reset_during_cell_establishing.robot

*** Test Cases ***
CIT__BBMOD_reset_during_cell_establishing
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__CIT__BBMOD_reset_during_cell_establishing
