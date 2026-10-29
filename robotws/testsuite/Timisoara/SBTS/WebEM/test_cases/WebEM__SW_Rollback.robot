*** Settings ***
Documentation  This suite contains WebEM__SW_Rollback TC

Resource  ../test_resources/WebEM__SW_Rollback.robot


*** Test Cases ***
WebEM__SW_Rollback
    [Setup]  TC Setup
    TC__WebEM__SW_Rollback
    [Teardown]  TC Teardown
