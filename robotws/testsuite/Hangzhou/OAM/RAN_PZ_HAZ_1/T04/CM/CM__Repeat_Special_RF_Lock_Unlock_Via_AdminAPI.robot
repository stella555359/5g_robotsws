*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables         ../test_line_specific/SBTS_SYVE_37376/My_Variables.py
Resource          ../test_resources/CM/CM__Repeat_Special_RF_Lock_Unlock_Via_AdminAPI.robot

*** Test Cases ***
CM__Repeat_Special_RF_Lock_Unlock_Via_AdminAPI
    [Setup]    TC Setup
    CM__Repeat_Special_RF_Lock_Unlock_Via_AdminAPI
    [Teardown]    TC Teardown