*** Settings ***
Documentation  This suite contains WebEM__Displaying_selected_RAD_debug_parameter_documentation TC

Resource  ../test_resources/WebEM__Displaying_selected_RAD_debug_parameter_documentation.robot


*** Test Cases ***
WebEM__Displaying_selected_RAD_debug_parameter_documentation
    [Setup]  TC Setup
    TC__WebEM__Displaying_selected_RAD_debug_parameter_documentation
    [Teardown]  TC Teardown
