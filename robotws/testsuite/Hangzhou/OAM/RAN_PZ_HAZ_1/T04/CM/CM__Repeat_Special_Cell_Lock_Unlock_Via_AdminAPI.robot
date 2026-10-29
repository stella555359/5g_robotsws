*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables         ../test_line_specific/SBTS1906_Top50/My_Variables.py
Resource          ../test_resources/CM/CM__Repeat_Special_Cell_Lock_Unlock_Via_AdminAPI.robot

*** Test Cases ***
CM__Repeat_BB_Module_Lock_Unlock_via_AdminAPI
    [Setup]    SetUp
    CM__Repeat_Special_Cell_Lock_Unlock_Via_AdminAPI
    [Teardown]    CaseTearDown
