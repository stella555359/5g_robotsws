*** Settings ***
Documentation  This suite contains WebEM__System_Critical_Log_contents_via_MPlane TC

Resource  ../test_resources/WebEM__System_Critical_Log_contents_via_MPlane.robot


*** Test Cases ***
WebEM__System_Critical_Log_contents_via_MPlane
    [Setup]  TC Setup
    TC__WebEM__System_Critical_Log_contents_via_MPlane
    [Teardown]  TC Teardown
