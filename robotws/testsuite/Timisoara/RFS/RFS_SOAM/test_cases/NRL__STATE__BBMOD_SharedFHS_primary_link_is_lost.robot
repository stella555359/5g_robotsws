*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/NRL__STATE__BBMOD_SharedFHS_primary_link_is_lost.robot

*** Test Cases ***
[1]NRL__STATE__BBMOD_SharedFHS_primary_link_is_lost
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__NRL__STATE__BBMOD_SharedFHS_primary_link_is_lost
