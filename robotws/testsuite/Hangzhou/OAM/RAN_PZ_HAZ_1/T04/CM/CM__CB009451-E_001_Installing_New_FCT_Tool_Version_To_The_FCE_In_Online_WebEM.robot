*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables         ../test_line_specific/SBTS_SYVE_1905/My_Variables.py
Resource          ../test_resources/CM/CM__CB009451-E_001_Installing_New_FCT_Tool_Version_To_The_FCE_In_Online_WebEM.robot

*** Test Cases ***
CM__Installing_New_FCT_Tool_Version_To_The_FCE_In_Online_WebEM_CB009451-E_001
    [Setup]    SetUp
    CM__CB009451-E_001_Installing_New_FCT_Tool_Version_To_The_FCE_In_Online_WebEM
    [Teardown]    TearDown
