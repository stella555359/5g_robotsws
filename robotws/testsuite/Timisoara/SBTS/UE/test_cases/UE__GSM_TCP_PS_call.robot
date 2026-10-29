*** Settings ***
Documentation  This suite contains UE__GSM_PS_call TC

Resource  ../test_resources/UE__GSM_TCP_PS_call.robot


*** Test Cases ***
UE__GSM_TCP_PS_call
    [Setup]  TC Setup
    UE__GSM_TCP_PS_call
    [Teardown]  TC Teardown
