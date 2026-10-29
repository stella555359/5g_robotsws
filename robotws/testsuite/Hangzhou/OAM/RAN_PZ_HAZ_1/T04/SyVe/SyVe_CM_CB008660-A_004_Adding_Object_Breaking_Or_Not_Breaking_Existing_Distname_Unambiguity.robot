*** Settings ***
Documentation       Test suite for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Test Timeout    75h
Variables     ../test_line_specific/SBTS_SYVE_1905/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource      ../test_resources/SyVe/SyVe_CM_CB008660-A_004_Adding_Object_Breaking_Or_Not_Breaking_Existing_Distname_Unambiguity.robot

*** Test Cases ***
SyVe_CM_CB008660-A_004_Adding_Object_Breaking_Or_Not_Breaking_Existing_Distname_Unambiguity
    [Setup]    TC Setup
    [Timeout]    72h
    SyVe_CM_CB008660-A_004_Adding_Object_Breaking_Or_Not_Breaking_Existing_Distname_Unambiguity
    [Teardown]    TC TearDown
