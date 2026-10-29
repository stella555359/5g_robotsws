*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables         ../test_line_specific/SBTS_SYVE_1905/My_Variables.py
Resource          ../test_resources/CM/CM__CB009939-A_009_010_Do_Controlled_Switchover_And_Disable_Redundancy.robot

*** Test Cases ***
CM__CB009939-A_009_010_Do_Controlled_Switchover_And_Disable_Redundancy
    [Setup]    Common Test Setup SBTS    scf_check=${FALSE}
    CM__CB009939-A_009_010_Do_Controlled_Switchover_And_Disable_Redundancy
    [Teardown]    Case Special Teardown
