*** Settings ***
Documentation  This suite contains PM__NE3S_Interface_Setup_In_Startup TC

Resource  ../test_resources/PM__NE3S_Interface_Setup_In_Startup.robot


*** Test Cases ***
PM__NE3S_Interface_Setup_In_Startup
    [Setup]  TC Setup
    TC__PM__NE3S_Interface_Setup_In_Startup
    [Teardown]  TC Teardown
