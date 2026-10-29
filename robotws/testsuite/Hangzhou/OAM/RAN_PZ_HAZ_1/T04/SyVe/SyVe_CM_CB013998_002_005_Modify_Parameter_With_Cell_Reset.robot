*** Settings ***
Documentation       Test suite for CB013998_002_005
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
Test Timeout    3h
Variables     ../test_line_specific/SBTS_SYVE_1894/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource      ../test_resources/SyVe/SyVe_CM_CB013998_002_005_Modify_Parameter_With_Cell_Reset.robot

*** Test Cases ***
SyVe_CM_CB013998_002_005_Modify_Parameter_With_Cell_Reset
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    SyVe_CM_CB013998_002_005_Modify_Parameter_With_Cell_Reset