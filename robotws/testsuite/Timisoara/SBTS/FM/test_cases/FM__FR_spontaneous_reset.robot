*** Settings ***
Documentation  This suite contains FM__FR_spontaneous_reset TC

Resource  ../test_resources/FM__FR_spontaneous_reset.robot


*** Test Cases ***
FM__FR_spontaneous_reset
    [Setup]  TC Setup
    TC__FM__FR_spontaneous_reset
    [Teardown]  TC Teardown
