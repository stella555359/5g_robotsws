*** Settings ***
Documentation  This suite contains WebEM__CLI_launches_script_with_RU_list_only TC

Resource  ../test_resources/WebEM__CLI_launches_script_with_RU_list_only.robot


*** Test Cases ***
WebEM__CLI_launches_script_with_RU_list_only
    [Setup]  TC Setup
    TC__WebEM__CLI_launches_script_with_RU_list_only
    [Teardown]  TC Teardown
