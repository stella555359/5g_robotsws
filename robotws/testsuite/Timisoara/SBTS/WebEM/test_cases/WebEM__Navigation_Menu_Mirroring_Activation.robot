*** Settings ***
Documentation  This suite contains WebEM__Navigation_Menu_Mirroring_Activation TC

Resource  ../test_resources/WebEM__Navigation_Menu_Mirroring_Activation.robot


*** Test Cases ***
WebEM__Navigation_Menu_Mirroring_Activation
    [Setup]  TC Setup
    TC__WebEM__Navigation_Menu_Mirroring_Activation
    [Teardown]  TC Teardown
