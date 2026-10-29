*** Settings ***
Documentation       Test suite for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Test Timeout    75h
Variables     ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource      ../test_resources/SyVe/SyVe_CM_CB009451-H_001_Installing_New_FCT_Tool_Version_To_The_FCE_In_NetAct.robot

*** Test Cases ***
SyVe_CM_CB009451-H_001_Installing_New_FCT_Tool_Version_To_The_FCE_In_NetAct
    [Setup]    SetUp
    [Timeout]    72h
    SyVe_CM_CB009451-H_001_Installing_New_FCT_Tool_Version_To_The_FCE_In_NetAct
    [Teardown]    TearDown