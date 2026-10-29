*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables         ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Resource          ../test_resources/CM/CM__Site_Reset_After_Recommission_With_Multiple_Validation_Via_Parameter_Editor.robot

*** Test Cases ***
CM__Site_Reset_After_Recommission_With_Multiple_Validation_Via_Parameter_Editor
    [Setup]    Set Up
    CM__Site_Reset_After_Recommission_With_Multiple_Validation_Via_Parameter_Editor
    [Teardown]    Case TearDown