*** Settings ***
Documentation  This suite contains WebEM__vDU__CW_Create_plan_when_vDU_is_commissioned TC

Resource  ../test_resources/WebEM__vDU__CW_Create_plan_when_vDU_is_commissioned.robot


*** Test Cases ***
WebEM__vDU__CW_Create_plan_when_vDU_is_commissioned
    [Setup]  TC Setup
    TC__WebEM__vDU__CW_Create_plan_when_vDU_is_commissioned
    [Teardown]  TC Teardown
