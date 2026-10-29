*** Settings ***
Documentation  This suite contains WebEM__BTS_Startup_view_show_resources TC

Resource  ../test_resources/WebEM__BTS_Startup_view_show_resources.robot


*** Test Cases ***
WebEM__BTS_Startup_view_show_resources
    [Setup]  TC Setup
    TC__WebEM__BTS_Startup_view_show_resources
    [Teardown]  TC Teardown
