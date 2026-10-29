*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS__CM__SMOD_Plug_and_Play.robot

*** Test Cases ***
[1]SBTS__CM__SMOD_Plug_and_Play
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS__CM__SMOD_Plug_and_Play