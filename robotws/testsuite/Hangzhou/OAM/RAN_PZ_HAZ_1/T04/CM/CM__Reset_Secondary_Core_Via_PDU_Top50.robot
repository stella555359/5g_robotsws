*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables         ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Resource          ../test_resources/CM/CM__Reset_Secondary_Core_Via_PDU_Top50.robot

*** Test Cases ***
CM__Reset_Secondary_Core_Via_PDU_Top50
    [Setup]    TC SetUp
    CM__Reset_Secondary_Core_Via_PDU_Top50
    [Teardown]    TC TearDown