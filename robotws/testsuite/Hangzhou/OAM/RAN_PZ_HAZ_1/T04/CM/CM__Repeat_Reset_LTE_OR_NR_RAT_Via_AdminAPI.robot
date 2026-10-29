*** Settings ***
Documentation       Test suite for repeat rat reset
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables         ../test_line_specific/SBTS_SYVE_37376/My_Variables.py
Resource          ../test_resources/CM/CM__Repeat_Reset_LTE_OR_NR_RAT_Via_AdminAPI.robot

*** Test Cases ***
CM__Repeat_Reset_LTE_OR_NR_RAT_Via_AdminAPI
    [Setup]    Common Test Setup SBTS    scf_check=${FALSE}
    CM__Repeat_Reset_LTE_OR_NR_RAT_Via_AdminAPI
    [Teardown]    Common Test Teardown SBTS