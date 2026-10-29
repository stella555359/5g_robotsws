*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables         ../test_line_specific/SBTS_SYVE_1910/My_Variables.py
Resource          ../test_resources/CM/CM__CA_Certificate_Retrieval_over_M-Plane.robot

*** Test Cases ***
CM__CA_Certificate_Retrieval_over_M-Plane
    [Setup]    TC SetUp
    CM__CA_Certificate_Retrieval_over_M-Plane
    [Teardown]    TC TearDown