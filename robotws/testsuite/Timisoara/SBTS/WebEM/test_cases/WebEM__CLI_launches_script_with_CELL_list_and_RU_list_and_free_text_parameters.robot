*** Settings ***
Documentation  This suite contains WebEM__CLI_launches_script_with_CELL_list_and_RU_list_and_free_text_parameters TC

Resource  ../test_resources/WebEM__CLI_launches_script_with_CELL_list_and_RU_list_and_free_text_parameters.robot


*** Test Cases ***
WebEM__CLI_launches_script_with_CELL_list_and_RU_list_and_free_text_parameters
    [Setup]  TC Setup
    TC__WebEM__CLI_launches_script_with_CELL_list_and_RU_list_and_free_text_parameters
    [Teardown]  TC Teardown
