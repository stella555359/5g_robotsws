*** Settings ***
Documentation  This suite contains WebEM__Navigation_Menu TC

Resource  ../test_resources/WebEM__Navigation_Menu.robot


*** Test Cases ***
WebEM__Navigation_Menu
    [Setup]  TC Setup
    TC__WebEM__Navigation_Menu
    [Teardown]  TC Teardown
