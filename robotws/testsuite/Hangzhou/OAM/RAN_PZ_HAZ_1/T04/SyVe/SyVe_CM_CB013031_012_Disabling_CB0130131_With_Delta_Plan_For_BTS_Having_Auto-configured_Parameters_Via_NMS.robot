*** Settings ***
Documentation       Test suite for Test case for RAN_ST_CB013031_012_CM_Disabling CB0130131 with delta plan for an operational BTS
...                 having auto-configured parameters in actual configuration from NMS
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
Test Timeout    5h
Variables     ../test_line_specific/SBTS_SYVE_37376/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource
...    ../test_resources/SyVe/SyVe_CM_CB013031_012_Disabling_CB0130131_With_Delta_Plan_For_BTS_Having_Auto-configured_Parameters_Via_NMS.robot

*** Test Cases ***
SyVe_CM_CB013031_012_Disabling_CB0130131_With_Delta_Plan_For_BTS_Having_Auto-configured_Parameters_Via_NMS
    [Setup]    TC Setup
    [Timeout]    2h
    SyVe_CM_CB013031_012_Disabling_CB0130131_With_Delta_Plan_For_BTS_Having_Auto-configured_Parameters_Via_NMS
    [Teardown]    TC TearDown