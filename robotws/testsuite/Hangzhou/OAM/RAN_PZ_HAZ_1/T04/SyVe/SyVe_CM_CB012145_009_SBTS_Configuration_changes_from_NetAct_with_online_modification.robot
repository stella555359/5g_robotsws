*** Settings ***
Documentation       Test suite for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Test Timeout    2h
Variables     ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource      ../test_resources/SyVe/SyVe_CM_CB012145_009_SBTS_Configuration_changes_from_NetAct_with_online_modification.robot

*** Test Cases ***
SyVe_CM_CB012145_009_SBTS_Configuration_changes_from_NetAct_with_online_modification
    [Setup]    TC Setup
    [Timeout]    2h
    SyVe_CM_SBTS_Configuration_changes_from_NetAct_with_online_modification
    [Teardown]    TC Teardown
