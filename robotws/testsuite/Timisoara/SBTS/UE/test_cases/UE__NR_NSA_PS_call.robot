*** Settings ***
Documentation  This suite contains UE__NR_PS_call TC

Resource  ../test_resources/UE__NR_NSA_PS_call.robot


*** Test Cases ***
UE__NR_PS_call
    [Setup]  TC Setup
    UE__NR_NSA_PS_call
    [Teardown]  TC Teardown
