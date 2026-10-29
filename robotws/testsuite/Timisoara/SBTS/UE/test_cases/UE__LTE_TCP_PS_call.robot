*** Settings ***
Documentation  This suite contains UE__LTE_PS_call TC

Resource  ../test_resources/UE__LTE_TCP_PS_call.robot


*** Test Cases ***
UE__LTE_TCP_PS_call
    [Setup]  TC Setup
    UE__LTE_TCP_PS_call
    [Teardown]  TC Teardown
