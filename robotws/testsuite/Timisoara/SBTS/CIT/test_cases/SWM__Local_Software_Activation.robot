*** Settings ***
Documentation  This suite contains SWM__Local_Software_Activation TC

Resource  ../test_resources/SWM__Local_Software_Activation.robot


*** Test Cases ***
SWM__Local_Software_Activation
    [Setup]  TC Setup
    TC__SWM__Local_Software_Activation
    [Teardown]  TC Teardown
