*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables         ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Resource          ../test_resources/CM/CM__CB009175_003_Simplified_Configure_New_Internal_Antenna_MAA_NRCELL_from_WebEM.robot

*** Test Cases ***
CM__CB009175_003_Simplified_Configure_New_Internal_Antenna_MAA_NRCELL_from_WebEM
    [Setup]    SetUp
    CM__CB009175_003_Simplified_Configure_New_Internal_Antenna_MAA_NRCELL_from_WebEM
    [Teardown]    TearDown