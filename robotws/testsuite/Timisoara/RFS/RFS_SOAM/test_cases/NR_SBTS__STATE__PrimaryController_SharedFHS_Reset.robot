*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/NR_SBTS__STATE__PrimaryController_SharedFHS_Reset.robot

*** Test Cases ***
[1]NR_SBTS__STATE__PrimaryController_SharedFHS_Reset
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__NR_SBTS__STATE__PrimaryController_SharedFHS_Reset