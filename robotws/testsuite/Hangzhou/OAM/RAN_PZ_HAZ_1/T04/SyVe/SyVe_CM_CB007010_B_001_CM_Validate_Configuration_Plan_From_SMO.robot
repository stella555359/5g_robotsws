*** Settings ***
Documentation       Test suite for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Test Timeout    3h
Variables     ../test_line_specific/SBTS_SYVE_1905/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource      ../test_resources/SyVe/SyVe_CM_CB007010_B_001_CM_Validate_Configuration_Plan_From_SMO.robot

*** Test Cases ***
SyVe_CM_CB007010_B_001_CM_Validate_Configuration_Plan_From_SMO
    [Setup]    TC Setup
    [Timeout]    2h
    TC__SyVe_CM_CB007010_B_001_CM_Validate_Configuration_Plan_From_SMO
    [Teardown]    TC Teardown
