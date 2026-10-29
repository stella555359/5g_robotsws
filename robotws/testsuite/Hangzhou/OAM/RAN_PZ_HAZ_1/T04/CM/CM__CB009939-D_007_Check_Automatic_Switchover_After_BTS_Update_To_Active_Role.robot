*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables         ../test_line_specific/SBTS_SYVE_1905/My_Variables.py
Resource          ../test_resources/CM/CM__CB009939-D_007_Check_Automatic_Switchover_After_BTS_Update_To_Active_Role.robot

*** Test Cases ***
CM__CB009939-D_007_Check_Automatic_Switchover_After_BTS_Update_To_Active_Role
    [Setup]    Common Test Setup SBTS    scf_check=${FALSE}
    CM__CB009939-D_007_Check_Automatic_Switchover_After_BTS_Update_To_Active_Role
    [Teardown]    Case Special Teardown
