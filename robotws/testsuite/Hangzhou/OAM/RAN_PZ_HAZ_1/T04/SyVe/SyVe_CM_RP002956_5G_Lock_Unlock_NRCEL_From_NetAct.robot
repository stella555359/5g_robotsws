*** Settings ***
Documentation       Test suite for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Test Timeout    75h
Variables     ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource      ../test_resources/SyVe/SyVe_CM_RP002956_5G_Lock_Unlock_NRCEL_From_NetAct.robot

*** Test Cases ***
SyVe_CM_RP002956_5G_Lock_Unlock_NRCEL_From_NetAct
    [Setup]    TC Setup
    [Timeout]    72h
    SyVe_CM_RP002956_5G_Lock_Unlock_NRCEL_From_NetAct
    [Teardown]    TC Teardown
