*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/Test_line__Recover_BTS.robot

*** Test Cases ***
[1]Test_line_Recover_BTS
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__Test_line_Recover_BTS

