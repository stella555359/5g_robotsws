*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS__STATE__BTS_Configuration_Reset_using_Admin_CLI.robot

*** Test Cases ***
[1]SBTS__STATE__BTS_Configuration_Reset_using_Admin_CLI
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS__STATE__BTS_Configuration_Reset_using_Admin_CLI