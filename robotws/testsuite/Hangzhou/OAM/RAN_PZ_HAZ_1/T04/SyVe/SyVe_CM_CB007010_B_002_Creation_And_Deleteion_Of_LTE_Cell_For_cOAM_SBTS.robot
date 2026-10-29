*** Settings ***
Documentation       Test suite for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Test Timeout    3h
Variables     ../test_line_specific/SBTS_SYVE_1894/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource      ../test_resources/SyVe/SyVe_CM_CB007010_B_002_Creation_And_Deleteion_Of_LTE_Cell_For_cOAM_SBTS.robot

*** Test Cases ***
SyVe_CM_CB007010_B_002_Creation_And_Deleteion_Of_LTE_Cell_For_cOAM_SBTS
    [Setup]    TC Setup
    [Timeout]    2h
    TC__SyVe_CM_CB007010_B_002_Creation_And_Deleteion_Of_LTE_Cell_For_cOAM_SBTS
    [Teardown]    TC Teardown
