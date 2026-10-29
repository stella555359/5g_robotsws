*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/PM__RFS__PM_File_Availability_Check_from_BTSSM.robot

*** Test Cases ***
[1]PM__RFS__PM_File_Availability_Check_from_BTSSM
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__PM__RFS__PM_File_Availability_Check_from_BTSSM

