*** Settings ***
Resource    ../test_resources/WebEM__Get_User_Login_Info.robot

*** Test Cases ***
WebEM__Get_User_Login_Info
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__WebEM__Get_User_Login_Info
