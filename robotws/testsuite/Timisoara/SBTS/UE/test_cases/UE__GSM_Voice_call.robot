*** Settings ***
Documentation  This suite contains UE__GSM_Voice_call TC

Resource  ../test_resources/UE__GSM_Voice_call.robot


*** Test Cases ***
UE__GSM_Voice_call
    [Setup]  TC Setup
    UE__GSM_Voice_call
    [Teardown]  TC Teardown
