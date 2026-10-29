*** Settings ***
Documentation  This suite contains WebEM__vCU__Configuration_and_Session_Expiration TC

Resource  ../test_resources/WebEM__vCU__Configuration_and_Session_Expiration.robot


*** Test Cases ***
WebEM__vCU__Configuration_and_Session_Expiration
    [Setup]  TC Setup
    TC__WebEM__vCU__Configuration_and_Session_Expiration
    [Teardown]  TC Teardown
