*** Settings ***
Documentation  This suite contains WebEM__vDU__CW_Activate_Configuration_plan_in_vDU TC

Resource  ../test_resources/WebEM__vDU__CW_Activate_Configuration_plan_in_vDU.robot


*** Test Cases ***
WebEM__vDU__CW_Activate_Configuration_plan_in_vDU
    [Setup]  TC Setup
    TC__WebEM__vDU__CW_Activate_Configuration_plan_in_vDU
    [Teardown]  TC Teardown
