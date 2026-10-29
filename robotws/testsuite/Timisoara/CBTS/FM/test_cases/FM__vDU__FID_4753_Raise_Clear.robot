*** Settings ***
Documentation  This suite contains FM__vDU__FID_4753_Raise_Clear TC

Resource  ../test_resources/FM__vDU__FID_4753_Raise_Clear.robot

*** Test Cases ***
FM__vDU__FID_4753_Raise_Clear
    [Setup]  TC Setup
    TC__FM__vDU__FID_4753_Raise_Clear
    [Teardown]  TC Teardown
