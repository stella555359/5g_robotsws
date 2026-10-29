*** Settings ***
Documentation  This suite contains PM__vDU__Clean_Up_PM_Files TC

Resource  ../test_resources/PM__vDU__Clean_Up_PM_Files.robot


*** Test Cases ***
PM__vDU__Clean_Up_PM_Files
    [Setup]  TC Setup
    TC__PM__vDU__Clean_Up_PM_Files
    [Teardown]  TC Teardown
