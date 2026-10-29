*** Settings ***
Documentation  This suite contains WebEM__Admin_CLI_availability_of_downloadSwConfig TC

Resource  ../test_resources/WebEM__Admin_CLI_availability_of_downloadSwConfig.robot


*** Test Cases ***
WebEM__Admin_CLI_availability_of_downloadSwConfig
    [Setup]  TC Setup
    TC__WebEM__Admin_CLI_availability_of_downloadSwConfig
    [Teardown]  TC Teardown
