*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/NRL__STATE__NR_SharedFHS_Reset.robot

*** Test Cases ***
[1]NRL__STATE__NR_SharedFHS_Reset
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__NRL__STATE__NR_SharedFHS_Reset

