*** Settings ***
Documentation  This suite contains UE__NR_PS_call TC

Resource  ../test_resources/UE__NR_SA_TCP_PS_call.robot


*** Test Cases ***
UE__NR_TCP_PS_call
    [Setup]  TC Setup
    UE__NR_SA_TCP_PS_call
    [Teardown]  TC Teardown
