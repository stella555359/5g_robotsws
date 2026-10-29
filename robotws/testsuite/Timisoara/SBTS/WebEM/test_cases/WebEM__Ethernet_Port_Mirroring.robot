*** Settings ***
Documentation  This suite contains WebEM__Ethernet_Port_Mirroring TC

Resource  ../test_resources/WebEM__Ethernet_Port_Mirroring.robot


*** Test Cases ***
WebEM__Ethernet_Port_Mirroring
    [Setup]  TC Setup
    TC__WebEM__Ethernet_Port_Mirroring
    [Teardown]  TC Teardown
