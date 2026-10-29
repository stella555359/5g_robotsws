*** Settings ***
Documentation  This suite contains DEV__Power_Hardware TC

Resource  ../test_resources/DEV__Power_Hardware.robot


*** Test Cases ***
DEV__Power_Hardware
    [Setup]  TC Setup
    TC__DEV__Power_Hardware
    [Teardown]  TC Teardown
