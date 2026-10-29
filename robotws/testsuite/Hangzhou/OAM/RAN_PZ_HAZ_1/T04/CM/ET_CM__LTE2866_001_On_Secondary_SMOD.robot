*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables         ../test_line_specific/SBTS_SYVE_1894/My_Variables.py
Resource          ../test_resources/CM/CM__ET_LTE2866_001_On_Secondary_SMOD.robot

*** Test Cases ***
ET_LTE2866_001_On_Secondary_SMOD
    CM__ET_LTE2866_001_On_Secondary_SMOD
    [Teardown]    CaseTearDown