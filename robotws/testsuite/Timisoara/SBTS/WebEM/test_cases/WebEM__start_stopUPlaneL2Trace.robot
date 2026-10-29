*** Settings ***
Documentation  This suite contains WebEM__start_stopUPlaneL2Trace TC

Resource  ../test_resources/WebEM__start_stopUPlaneL2Trace.robot


*** Test Cases ***
WebEM__start_stopUPlaneL2Trace
    [Setup]  TC Setup
    TC__WebEM__start_stopUPlaneL2Trace
    [Teardown]  TC Teardown
