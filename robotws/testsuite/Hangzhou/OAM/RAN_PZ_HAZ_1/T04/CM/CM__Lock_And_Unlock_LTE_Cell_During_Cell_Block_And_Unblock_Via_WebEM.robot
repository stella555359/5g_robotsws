*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables         ../test_line_specific/SBTS_SYVE_1905/My_Variables.py
Resource    ../test_resources/CM/CM__Lock_And_Unlock_LTE_Cell_During_Cell_Block_And_Unblock_Via_WebEM.robot

*** Test Cases ***
CM__Lock_And_Unlock_LTE_Cell_During_Cell_Block_And_Unblock_Via_WebEM
    [Setup]    SetUp
    CM__Lock_And_Unlock_LTE_Cell_During_Cell_Block_And_Unblock_Via_WebEM
    [Teardown]    CaseTearDown
