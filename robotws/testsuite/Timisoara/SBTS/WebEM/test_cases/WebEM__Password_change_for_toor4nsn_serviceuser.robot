*** Settings ***
Documentation  This suite contains WebEM__Password_change_for_toor4nsn_serviceuser TC

Resource  ../test_resources/WebEM__Password_change_for_toor4nsn_serviceuser.robot


*** Test Cases ***
WebEM__Password_change_for_toor4nsn_serviceuser
    [Setup]  TC Setup
    TC__WebEM__Password_change_for_toor4nsn_serviceuser
    [Teardown]  TC Teardown
