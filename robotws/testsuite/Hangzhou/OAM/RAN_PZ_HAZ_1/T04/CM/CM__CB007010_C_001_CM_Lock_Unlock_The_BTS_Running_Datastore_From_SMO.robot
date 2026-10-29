*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Test Timeout    3h
Variables         ../test_line_specific/SBTS_SYVE_1905/My_Variables.py
Resource          ../test_resources/CM/CM__CB007010_C_001_CM_Lock_Unlock_The_BTS_Running_Datastore_From_SMO.robot

*** Test Cases ***
CM__CB007010_C_001_CM_Lock_Unlock_The_BTS_Running_Datastore_From_SMO
    [Setup]    TC SetUp
    [Timeout]    2h
    TC__CB007010_C_001_CM_Lock_Unlock_The_BTS_Running_Datastore_From_SMO
    [Teardown]    TC TearDown


