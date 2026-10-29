*** Settings ***
Documentation  This suite contains WebEM__Duration_of_loading_WebEM_application_Web TC

Resource  ../test_resources/WebEM__Duration_of_loading_WebEM_application_Web.robot


*** Test Cases ***
WebEM__Duration_of_loading_WebEM_application_Web
    [Setup]  TC Setup
    TC__WebEM__Duration_of_loading_WebEM_application_Web
    [Teardown]  TC Teardown
