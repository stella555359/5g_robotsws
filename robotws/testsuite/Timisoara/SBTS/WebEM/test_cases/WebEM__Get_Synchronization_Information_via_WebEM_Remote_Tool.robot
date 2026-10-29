*** Settings ***
Documentation  This suite contains WebEM__Get_Synchronization_Information_via_WebEM_Remote_Tool TC

Resource  ../test_resources/WebEM__Get_Synchronization_Information_via_WebEM_Remote_Tool.robot


*** Test Cases ***
WebEM__Get_Synchronization_Information_via_WebEM_Remote_Tool
    [Setup]  TC Setup
    TC__WebEM__Get_Synchronization_Information_via_WebEM_Remote_Tool
    [Teardown]  TC Teardown
