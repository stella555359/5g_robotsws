*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables         ../test_line_specific/SBTS_SYVE_1905/My_Variables.py
Resource          ../test_resources/CM/CM__CB009939-D_004_CM_Trigger_Automatic_Switchover_When_minCellAvailability_Is_Met.robot

*** Test Cases ***
CM__CB009939-D_004_CM_Trigger_Automatic_Switchover_When_minCellAvailability_Is_Met
    [Setup]    Common Test Setup SBTS    scf_check=${FALSE}
    CM__CB009939-D_004_CM_Trigger_Automatic_Switchover_When_minCellAvailability_Is_Met
    [Teardown]    Case Special Teardown
