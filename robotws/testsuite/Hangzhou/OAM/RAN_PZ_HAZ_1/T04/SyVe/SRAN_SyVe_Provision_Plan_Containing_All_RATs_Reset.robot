*** Settings ***
Documentation       Test suite for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Test Timeout    75h
Variables     ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource      ../test_resources/SyVe/SRAN_SyVe_Provision_Plan_Containing_All_RATs_Reset.robot

*** Test Cases ***
SRAN_SyVe_Provision_Plan_Containing_All_RATs_Reset
    [Setup]    TC Setup
    [Timeout]    72h
    TC__SRAN_SyVe_Provision_Plan_Containing_All_RATs_Reset
    [Teardown]    TC Teardown
