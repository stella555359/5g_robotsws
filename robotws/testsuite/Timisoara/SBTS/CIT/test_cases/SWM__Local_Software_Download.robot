*** Settings ***
Documentation  This suite contains SWM__Local_Software_Download TC

Resource  ../test_resources/SWM__Local_Software_Download.robot


*** Test Cases ***
SWM__Local_Software_Download
    [Setup]  TC Setup
    TC__SWM__Local_Software_Download
    [Teardown]  TC Teardown
