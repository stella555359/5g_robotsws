*** Settings ***
Documentation  This suite contains WebEM__vDU__CW_Delete_Plan_online_mode TC

Resource  ../test_resources/WebEM__vDU__CW_Delete_Plan_online_mode.robot


*** Test Cases ***
WebEM__vDU__CW_Delete_Plan_online_mode
    [Setup]  TC Setup
    TC__WebEM__vDU__CW_Delete_Plan_online_mode
    [Teardown]  TC Teardown
