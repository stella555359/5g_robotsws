*** Settings ***
Documentation  This suite contains UE__WCDMA_PS_call TC

Resource  ../test_resources/UE__WCDMA_PS_call.robot


*** Test Cases ***
UE__WCDMA_PS_call
    [Setup]  TC Setup
    UE__WCDMA_PS_call
    [Teardown]  TC Teardown
