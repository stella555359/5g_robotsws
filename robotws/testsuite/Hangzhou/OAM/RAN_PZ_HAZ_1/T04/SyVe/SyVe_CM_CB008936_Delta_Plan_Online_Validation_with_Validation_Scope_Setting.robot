*** Settings ***
Documentation       Test suite for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Test Timeout    2h
Variables     ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource      ../test_resources/SyVe/SyVe_CM_CB008936_Delta_Plan_Online_Validation_with_Validation_Scope_Setting.robot

*** Test Cases ***
SyVe_CM_CB008936_Delta_Plan_Online_Validation_with_Validation_Scope_Setting
    [Setup]    TC Setup
    [Timeout]    2h
    SyVe_CM_CB008936_Delta_Plan_Online_Validation_with_Validation_Scope_Setting
    [Teardown]    TC Teardown
