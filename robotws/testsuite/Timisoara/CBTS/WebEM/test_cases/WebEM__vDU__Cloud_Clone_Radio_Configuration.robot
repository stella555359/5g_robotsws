*** Settings ***
Documentation  This suite contains WebEM__vDU__Cloud_Clone_Radio_Configuration TC

Resource  ../test_resources/WebEM__vDU__Cloud_Clone_Radio_Configuration.robot


*** Test Cases ***
WebEM__vDU__Cloud_Clone_Radio_Configuration
    [Setup]  TC Setup
    TC__WebEM__vDU__Cloud_Clone_Radio_Configuration
    [Teardown]  TC Teardown
