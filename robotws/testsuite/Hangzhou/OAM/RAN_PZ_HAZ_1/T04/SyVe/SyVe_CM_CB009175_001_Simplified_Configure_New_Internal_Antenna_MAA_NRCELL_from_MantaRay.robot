*** Settings ***
Documentation       Test suite for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Test Timeout    75h
Variables     ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource      ../test_resources/SyVe/SyVe_CM_CB009175_001_Simplified_Configure_New_Internal_Antenna_MAA_NRCELL_from_MantaRay.robot

*** Test Cases ***
SyVe_CM_CB009175_001_Simplified_Configure_New_Internal_Antenna_MAA_NRCELL_from_MantaRay
    [Setup]    TC Setup
    [Timeout]    72h
    SyVe_CM_CB009175_001_Simplified_Configure_New_Internal_Antenna_MAA_NRCELL_from_MantaRay
    [Teardown]    TC TearDown
