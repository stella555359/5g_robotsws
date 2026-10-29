*** Settings ***
Documentation  This suite contains WebEM__Loading_duration_until_runtime_view TC

Resource  ../test_resources/WebEM__Loading_duration_until_runtime_view.robot


*** Test Cases ***
WebEM__Loading_duration_until_runtime_view
    [Setup]  TC Setup
    TC__WebEM__Loading_duration_until_runtime_view
    [Teardown]  TC Teardown
