*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables         ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Resource          ../test_resources/CM/CM__Repeat_RF_Module_Lock_Unlock_via_AdminAPI.robot

*** Test Cases ***
CM__Repeat_RF_Module_Lock_Unlock_via_AdminAPI
    [Setup]    SetUp
    CM__Repeat_RF_Module_Lock_Unlock_via_AdminAPI
    [Teardown]    CaseTearDown
