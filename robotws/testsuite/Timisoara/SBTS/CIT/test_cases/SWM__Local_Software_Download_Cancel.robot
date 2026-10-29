*** Settings ***
Documentation  This suite contains SWM__Local_Software_Download_Cancel TC

Resource  ../test_resources/SWM__Local_Software_Download_Cancel.robot


*** Test Cases ***
SWM__Local_Software_Download_Cancel
    [Setup]  TC Setup
    TC__SWM__Local_Software_Download_Cancel
    [Teardown]  TC Teardown
