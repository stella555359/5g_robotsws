*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables         ../test_line_specific/SBTS_SYVE_1905/My_Variables.py
Resource          ../test_resources/CM/CM__CB009939-A_012_Forced_Active_BTS_Startup_When_Peer_BTS_Is_Existing.robot

*** Test Cases ***
CM__CB009939-A_012_Forced_Active_BTS_Startup_When_Peer_BTS_Is_Existing
    [Setup]    Common Test Setup SBTS    scf_check=${FALSE}
    CM__CB009939-A_012_Forced_Active_BTS_Startup_When_Peer_BTS_Is_Existing
    [Teardown]    Case Special Teardown
