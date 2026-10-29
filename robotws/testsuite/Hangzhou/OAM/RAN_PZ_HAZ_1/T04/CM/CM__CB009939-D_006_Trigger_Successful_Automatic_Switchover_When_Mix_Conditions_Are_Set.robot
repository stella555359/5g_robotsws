*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables         ../test_line_specific/SBTS_SYVE_37376/My_Variables.py
Resource          ../test_resources/CM/CM__CB009939-D_006_Trigger_Successful_Automatic_Switchover_When_Mix_Conditions_Are_Set.robot

*** Test Cases ***
CM__CB009939-D_006_Trigger_Successful_Automatic_Switchover_When_Mix_Conditions_Are_Set
    [Setup]    Common Test Setup SBTS    scf_check=${FALSE}
    CM__CB009939-D_006_Trigger_Successful_Automatic_Switchover_When_Mix_Conditions_Are_Set
    [Teardown]    Case Special Teardown
