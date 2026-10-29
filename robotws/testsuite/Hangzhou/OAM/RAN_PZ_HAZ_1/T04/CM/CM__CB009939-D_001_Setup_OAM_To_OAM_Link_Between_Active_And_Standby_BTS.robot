*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables         ../test_line_specific/SBTS_SYVE_1905/My_Variables.py
Resource          ../test_resources/CM/CM__CB009939-D_001_Setup_OAM_To_OAM_Link_Between_Active_And_Standby_BTS.robot

*** Test Cases ***
CM__CB009939-D_001_Setup_OAM_To_OAM_Link_Between_Active_And_Standby_BTS
    [Setup]    Common Test Setup SBTS    scf_check=${FALSE}
    CM__CB009939-D_001_Setup_OAM_To_OAM_Link_Between_Active_And_Standby_BTS
    [Teardown]    Case Special Teardown
