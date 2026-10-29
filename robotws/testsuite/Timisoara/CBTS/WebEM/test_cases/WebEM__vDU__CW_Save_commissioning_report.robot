*** Settings ***
Documentation  This suite contains WebEM__vDU__CW_Save_commissioning_report TC

Resource  ../test_resources/WebEM__vDU__CW_Save_commissioning_report.robot


*** Test Cases ***
WebEM__vDU__CW_Save_commissioning_report
    [Setup]  TC Setup
    TC__WebEM__vDU__CW_Save_commissioning_report
    [Teardown]  TC Teardown
