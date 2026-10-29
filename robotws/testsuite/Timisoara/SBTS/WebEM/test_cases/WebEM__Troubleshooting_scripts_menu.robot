*** Settings ***
Documentation  This suite contains WebEM__Troubleshooting_scripts_menu TC

Resource  ../test_resources/WebEM__Troubleshooting_scripts_menu.robot


*** Test Cases ***
WebEM__Troubleshooting_scripts_menu
    [Setup]  TC Setup
    TC__WebEM__Troubleshooting_scripts_menu
    [Teardown]  TC Teardown
