*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables         ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Resource          ../test_resources/CM/CM__CB012803_CB012663_CM_Verify_Duration_via_WebEM.robot

*** Test Cases ***
CM__CB012803_CB012663_CM_Verify_Duration_via_WebEM
    [Setup]    SetUp
    CM__CB012803_CB012663_CM_Verify_Duration_via_WebEM
    [Teardown]    TearDown