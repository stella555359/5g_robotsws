*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables         ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Resource          ../test_resources/CM/CM__GSM_Cell_Addition_And_Deletion_Via_Parameter_Editor.robot

*** Test Cases ***
CM__GSM_Cell_Addition_And_Deletion_Via_Parameter_Editor
    [Setup]    Set Up
	Log    CM__GSM_Cell_Addition_And_Deletion_Via_Parameter_Editor
    CM__GSM_Cell_Addition_And_Deletion_Via_Parameter_Editor
    [Teardown]    TearDown