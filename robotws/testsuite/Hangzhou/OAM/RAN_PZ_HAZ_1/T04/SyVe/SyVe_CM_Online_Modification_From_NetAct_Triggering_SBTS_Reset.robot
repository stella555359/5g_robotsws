*** Settings ***
Documentation       Test suite for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Test Timeout    75h
Variables     ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource      ../test_resources/SyVe/SyVe_CM_Online_Modification_From_NetAct_Triggering_SBTS_Reset.robot

*** Test Cases ***
SyVe_CM_Online_Modification_From_NetAct_Triggering_SBTS_Reset
    [Setup]    TC Setup
    [Timeout]    72h
    [Teardown]    TC Teardown
    TC__SyVe_CM_Online_Modification_From_NetAct_Triggering_SBTS_Reset


