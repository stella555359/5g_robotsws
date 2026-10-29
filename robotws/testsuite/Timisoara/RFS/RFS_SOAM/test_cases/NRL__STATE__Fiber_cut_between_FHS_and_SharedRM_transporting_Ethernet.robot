*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/NRL__STATE__Fiber_cut_between_FHS_and_SharedRM_transporting_Ethernet.robot

*** Test Cases ***
[1]NRL__STATE__Fiber_cut_between_FHS_and_SharedRM_transporting_Ethernet
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__NRL__STATE__Fiber_cut_between_FHS_and_SharedRM_transporting_Ethernet
