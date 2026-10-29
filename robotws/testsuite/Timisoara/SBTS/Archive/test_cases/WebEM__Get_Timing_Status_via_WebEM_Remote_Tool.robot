*** Settings ***
Resource    ../test_resources/WebEM__Get_Timing_Status_via_WebEM_Remote_Tool.robot

*** Test Cases ***
WebEM__Get_Timing_Status_via_WebEM_Remote_Tool
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__WebEM__Get_Timing_Status_via_WebEM_Remote_Tool
