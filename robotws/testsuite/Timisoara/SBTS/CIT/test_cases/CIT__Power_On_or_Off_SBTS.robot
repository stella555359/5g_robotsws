*** Settings ***
Documentation  This suite contains CIT__Power_On_or_Off_SBTS TC

Resource  ../test_resources/CIT__Power_On_or_Off_SBTS.robot


*** Test Cases ***
CIT__Power_On_or_Off_SBTS
    [Setup]  TC Setup
    TC__CIT__Power_On_or_Off_SBTS
    [Teardown]  TC Teardown
