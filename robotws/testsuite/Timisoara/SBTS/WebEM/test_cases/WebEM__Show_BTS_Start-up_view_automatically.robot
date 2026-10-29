*** Settings ***
Documentation  This suite contains WebEM__Show_BTS_Start-up_view_automatically TC

Resource  ../test_resources/WebEM__Show_BTS_Start-up_view_automatically.robot


*** Test Cases ***
WebEM__Show_BTS_Start-up_view_automatically
    [Setup]  TC Setup
    TC__WebEM__Show_BTS_Start-up_view_automatically
    [Teardown]  TC Teardown
