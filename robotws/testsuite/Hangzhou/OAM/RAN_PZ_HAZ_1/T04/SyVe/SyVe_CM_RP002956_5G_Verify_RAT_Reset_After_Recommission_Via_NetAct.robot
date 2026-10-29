*** Settings ***
Documentation       Test suite for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Test Timeout    75h
Variables        ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Variables        ../test_line_specific/Variables/NetActs.py
Resource          ../test_resources/SyVe/SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct.robot

*** Test Cases ***
SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct
    [Setup]    TC Setup
    [Timeout]    72h
    SyVe_CM_RP002956_5G_Verify_RAT_Reset_After_Recommission_Via_NetAct
    [Teardown]    TC Teardown
