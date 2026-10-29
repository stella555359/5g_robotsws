*** Settings ***
Documentation  This suite contains SWM__SW_Update_in_loop_x3 TC

Resource  ../test_resources/SWM__SW_Update_in_loop_x3.robot


*** Test Cases ***
SWM__SW_Update_in_loop_x3
    [Setup]  TC Setup
    TC__SWM__SW_Update_in_loop_x3
    [Teardown]  TC Teardown
