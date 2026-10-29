*** Settings ***
Documentation  This suite contains PM__vDU__Delete_PM_Processes TC

Resource  ../test_resources/PM__vDU__Delete_PM_Processes.robot


*** Test Cases ***
PM__vDU__Delete_PM_Processes
    [Setup]  TC Setup
    TC__PM__vDU__Delete_PM_Processes
    [Teardown]  TC Teardown
