*** Settings ***
Documentation  This suite contains WebEM__vDU__Configuration_and_Session_Expiration TC

Resource  ../test_resources/WebEM__vDU__Configuration_and_Session_Expiration.robot


*** Test Cases ***
WebEM__vDU__Configuration_and_Session_Expiration
    [Setup]  TC Setup
    TC__WebEM__vDU__Configuration_and_Session_Expiration
    [Teardown]  TC Teardown
