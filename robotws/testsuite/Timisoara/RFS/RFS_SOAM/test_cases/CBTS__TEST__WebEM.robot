*** Settings ***
Documentation    CBTS__TEST__WebEM
Resource    ../test_resources/CBTS__TEST__WebEM.robot

*** Test Cases ***
[1]CBTS__TEST__WebEM
    [Tags]    robot:skip
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__CBTS__TEST__WebEM

