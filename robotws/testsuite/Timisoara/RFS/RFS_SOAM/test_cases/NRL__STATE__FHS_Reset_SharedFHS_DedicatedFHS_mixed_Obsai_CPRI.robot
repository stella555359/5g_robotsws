*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/NRL__STATE__FHS_Reset_SharedFHS_DedicatedFHS_mixed_Obsai_CPRI.robot

*** Test Cases ***
[1]NRL__STATE__FHS_Reset_SharedFHS_DedicatedFHS_mixed_Obsai_CPRI
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__NRL__STATE__FHS_Reset_SharedFHS_DedicatedFHS_mixed_Obsai_CPRI

