*** Settings ***
Documentation  This suite contains WebEM__Compare_Managed_Objects TC

Resource  ../test_resources/WebEM__Compare_Managed_Objects.robot


*** Test Cases ***
WebEM__Compare_Managed_Objects
    [Setup]  TC Setup
    TC__WebEM__Compare_Managed_Objects
    [Teardown]  TC Teardown
