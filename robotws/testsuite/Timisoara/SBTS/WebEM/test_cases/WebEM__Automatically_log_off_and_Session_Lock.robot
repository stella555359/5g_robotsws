*** Settings ***
Documentation  This suite contains WebEM__Automatically_log_off_and_Session_Lock TC

Resource  ../test_resources/WebEM__Automatically_log_off_and_Session_Lock.robot


*** Test Cases ***
WebEM__Automatically_log_off_and_Session_Lock
    [Setup]  TC Setup
    TC__WebEM__Automatically_log_off_and_Session_Lock
    [Teardown]  TC Teardown
