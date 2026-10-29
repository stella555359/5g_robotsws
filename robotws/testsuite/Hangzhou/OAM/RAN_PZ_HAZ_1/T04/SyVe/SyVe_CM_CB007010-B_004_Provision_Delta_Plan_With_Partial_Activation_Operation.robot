*** Settings ***
Documentation       Test suite for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Test Timeout    75h
Variables     ../test_line_specific/SBTS_SYVE_1816/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource      ../test_resources/SyVe/SyVe_CM_CB007010-B_004_Provision_Delta_Plan_With_Partial_Activation_Operation.robot

*** Test Cases ***
SyVe_CM_CB007010-B_004_Provision_Delta_Plan_With_Partial_Activation_Operation
    [Setup]    TC Setup
    [Timeout]    72h
    [Teardown]    TC Teardown
    SyVe_CM_CB007010-B_004_Provision_Delta_Plan_With_Partial_Activation_Operation