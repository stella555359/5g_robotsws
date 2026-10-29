*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables         ../test_line_specific/SBTS_SYVE_1910/My_Variables.py
Resource          ../test_resources/CM/CM__CB007010-A_006_Verify_Inactivity_Timeout_Between_NetConf_Operations.robot

*** Test Cases ***
CM__CB007010-A_006_Verify_Inactivity_Timeout_Between_NetConf_Operations-A_006
    [Setup]    TC SetUp
    CM__CB007010-A_006_Verify_Inactivity_Timeout_Between_NetConf_Operations
    [Teardown]    TC TearDown


