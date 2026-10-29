*** Settings ***
Documentation  This suite contains WebEM__5G_RAT_Block_Unblock TC

Resource  ../test_resources/WebEM__5G_RAT_Block_Unblock.robot


*** Test Cases ***
WebEM__5G_RAT_Block_Unblock
    [Setup]  TC Setup
    TC__WebEM__5G_RAT_Block_Unblock
    [Teardown]  TC Teardown
