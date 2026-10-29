*** Settings ***
Documentation       Test suite for CB013998_004_007
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
Test Timeout    3h
Variables     ../test_line_specific/SBTS_SYVE_1893/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource      ../test_resources/SyVe/SyVe_CM_CB013998_004_007_Modify_Parameter_With_RU_Reset.robot

*** Test Cases ***
SyVe_CM_CB013998_004_007_011_014_Modify_Parameter_With_RU_Reset
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    SyVe_CM_CB013998_004_007_Modify_Parameter_With_RU_Reset