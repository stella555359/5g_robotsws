*** Settings ***
Documentation  This suite contains WebEM__script_launch_failed_due_to_script_already_ongoing TC

Resource  ../test_resources/WebEM__script_launch_failed_due_to_script_already_ongoing.robot


*** Test Cases ***
WebEM__script_launch_failed_due_to_script_already_ongoing
    [Setup]  TC Setup
    TC__WebEM__script_launch_failed_due_to_script_already_ongoing
    [Teardown]  TC Teardown
