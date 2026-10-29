*** Settings ***
Documentation  This suite contains WebEM__Duration_of_login_in_WebEM_application_BTS_DU TC

Resource  ../test_resources/WebEM__Duration_of_login_in_WebEM_application_BTS_DU.robot


*** Test Cases ***
WebEM__Duration_of_login_in_WebEM_application_BTS_DU
    [Setup]  TC Setup
    TC__WebEM__Duration_of_login_in_WebEM_application_BTS_DU
    [Teardown]  TC Teardown
