*** Settings ***
Documentation  This suite contains WebEM__vDU__CW_Resume_Configuration_Plan_after_break TC

Resource  ../test_resources/WebEM__vDU__CW_Resume_Configuration_Plan_after_break.robot


*** Test Cases ***
WebEM__vDU__CW_Resume_Configuration_Plan_after_break
    [Setup]  TC Setup
    TC__WebEM__vDU__CW_Resume_Configuration_Plan_after_break
    [Teardown]  TC Teardown
