*** Settings ***
Documentation  This suite contains WebEM__5G_Test_Models_Running_5G_Downlink_Test TC

Resource  ../test_resources/WebEM__5G_Test_Models_Running_5G_Downlink_Test.robot


*** Test Cases ***
WebEM__5G_Test_Models_Running_5G_Downlink_Test
    [Setup]  TC Setup
    TC__WebEM__5G_Test_Models_Running_5G_Downlink_Test
    [Teardown]  TC Teardown
