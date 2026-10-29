*** Settings ***
Documentation  This suite contains WebEM__Troubleshooting_scripts_cli TC

Resource  ../test_resources/WebEM__Troubleshooting_scripts_cli.robot


*** Test Cases ***
WebEM__Troubleshooting_scripts_cli
    [Setup]  TC Setup
    TC__WebEM__Troubleshooting_scripts_cli
    [Teardown]  TC Teardown
