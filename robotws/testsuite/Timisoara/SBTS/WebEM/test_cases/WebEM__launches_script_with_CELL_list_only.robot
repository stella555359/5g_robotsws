*** Settings ***
Documentation  This suite contains WebEM__launches_script_with_CELL_list_only TC

Resource  ../test_resources/WebEM__launches_script_with_CELL_list_only.robot


*** Test Cases ***
WebEM__launches_script_with_CELL_list_only
    [Setup]  TC Setup
    TC__WebEM__launches_script_with_CELL_list_only
    [Teardown]  TC Teardown
