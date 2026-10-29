*** Settings ***
Resource    ../test_resources/FM__RMOD_reset_FID1981.robot

*** Test Cases ***
FM__RMOD_reset_FID1981
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__FM__RMOD_reset_FID1981

