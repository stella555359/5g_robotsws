*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables     ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Resource      ../test_resources/CM/Common_Reset_Configuration_CB007500_Secondary_Core.robot

*** Test Cases ***
Common_Reset_Configuration_CB007500_Secondary_Core
    [Setup]       TC Setup
    Common_Reset_Configuration_CB007500_Secondary_Core
    [Teardown]    TC Teardown

