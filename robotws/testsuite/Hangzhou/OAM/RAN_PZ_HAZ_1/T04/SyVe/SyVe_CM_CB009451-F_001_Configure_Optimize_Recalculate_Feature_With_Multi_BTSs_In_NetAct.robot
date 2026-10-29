*** Settings ***
Documentation       Test suite for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Test Timeout    75h
Variables     ../test_line_specific/SBTS_SYVE_1905/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource      ../test_resources/SyVe/SyVe_CM_CB009451-F_001_Configure_Optimize_Recalculate_Feature_With_Multi_BTSs_In_NetAct.robot

*** Test Cases ***
SyVe_CM_CB009451-F_001_Configure_Optimize_Recalculate_Feature_With_Multi_BTSs_In_NetAct
    [Setup]    TC Setup
    [Timeout]    72h
    SyVe_CM_CB009451-F_001_Configure_Optimize_Recalculate_Feature_With_Multi_BTSs_In_NetAct
    [Teardown]    TC TearDown
