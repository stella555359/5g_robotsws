*** Settings ***
Documentation       Test suite for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Test Timeout    75h
Variables     ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource      ../test_resources/SyVe/SyVe_CM_CB008880-F_004_LTE_or_NR_RAT_Reset_By_SWRESETREQ.robot

*** Test Cases ***
SyVe_CM_CB008880-F_004_LTE_or_NR_RAT_Reset_By_SWRESETREQ
    [Setup]    TC Setup
    [Timeout]    72h
    SyVe_CM_CB008880-F_004_LTE_or_NR_RAT_Reset_By_SWRESETREQ
    [Teardown]    TC TearDown
