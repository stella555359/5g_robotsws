*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables    ../test_line_specific/SBTS_SYVE_1905/My_Variables.py
Resource    ../test_resources/CM/CM__Prevent_Cell_Activation_via_Admin.robot

*** Test Cases ***
CM__Prevent_Cell_Activation_via_Admin
    [Setup]    Case SetUp
    CM__Prevent_Cell_Activation_via_Admin
    [Teardown]    Case TearDown
