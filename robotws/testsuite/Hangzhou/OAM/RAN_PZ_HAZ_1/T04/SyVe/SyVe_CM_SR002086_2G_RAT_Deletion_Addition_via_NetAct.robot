*** Settings ***
Documentation       Test suite for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Test Timeout    75h
Variables     ../test_line_specific/SBTS_SYVE_1910/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource      ../test_resources/SyVe/SyVe_CM_SR002086_2G_RAT_Deletion_Addition_via_NetAct.robot

*** Test Cases ***
SyVe_CM_SR002086_2G_RAT_Deletion_Addition_via_NetAct
    [Setup]    TC Setup
    [Timeout]    72h
    [Teardown]    TC Teardown
    SyVe_CM_SR002086_2G_RAT_Deletion_Addition_via_NetAct

