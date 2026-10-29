*** Settings ***
Documentation  This suite contains WebEM__Admin_CLI_Get_RAD_SW_Domains TC

Resource  ../test_resources/WebEM__Admin_CLI_Get_RAD_SW_Domains.robot


*** Test Cases ***
WebEM__Admin_CLI_Get_RAD_SW_Domains
    [Setup]  TC Setup
    TC__WebEM__Admin_CLI_Get_RAD_SW_Domains
    [Teardown]  TC Teardown
