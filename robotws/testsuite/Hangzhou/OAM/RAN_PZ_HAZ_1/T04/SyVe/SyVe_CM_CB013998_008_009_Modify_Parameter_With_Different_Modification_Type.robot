*** Settings ***
Documentation       Test suite for CB013998_008_009
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
Test Timeout    3h
Variables     ../test_line_specific/SBTS_SYVE_1905/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource      ../test_resources/SyVe/SyVe_CM_CB013998_008_009_Modify_Parameter_With_Different_Modification_Type.robot

*** Test Cases ***
SyVe_CM_CB013998_008_009_Modify_Parameter_With_Different_Modification_Type
    [Setup]    TC Setup
    [Timeout]    3h
    [Teardown]    TC Teardown
    SyVe_CM_CB013998_008_009_Modify_Parameter_With_Different_Modification_Type