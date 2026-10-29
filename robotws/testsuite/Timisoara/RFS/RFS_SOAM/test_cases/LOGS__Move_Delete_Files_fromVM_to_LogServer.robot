*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/LOGS__Move_Delete_Files_fromVM_to_LogServer.robot

*** Test Cases ***
[1]LOGS__Move_Delete_Files_fromVM_to_LogServer
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__LOGS__Move_Delete_Files_fromVM_to_LogServer

