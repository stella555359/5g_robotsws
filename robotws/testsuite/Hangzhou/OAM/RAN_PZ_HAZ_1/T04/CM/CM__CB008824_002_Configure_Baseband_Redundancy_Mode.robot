*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables         ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Resource          ../test_resources/CM/CM__CB008824_002_Configure_Baseband_Redundancy_Mode.robot

*** Test Cases ***
CM__CB008824_002_Configure_Baseband_Redundancy_Mode
    [Setup]    Common Test Setup SBTS    scf_check=${FALSE}
    CM__CB008824_002_Configure_Baseband_Redundancy_Mode
    [Teardown]    Case Special Teardown
