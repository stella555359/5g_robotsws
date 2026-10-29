*** Settings ***
Documentation       Test suite for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Test Timeout    75h
Variables     ../test_line_specific/SBTS_SYVE_1816/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource      ../test_resources/SyVe/SyVe_CM_CB007010-B_007_STATE_HW_RMOD_Reset_Request_To_SBTS_Via_HWRESETREQ_From_SMO.robot

*** Test Cases ***
SyVe_CM_CB007010-B_007_STATE_HW_RMOD_Reset_Request_To_SBTS_Via_HWRESETREQ_From_SMO
    [Setup]    TC Setup
    [Timeout]    72h
    [Teardown]    TC Teardown
    SyVe_CM_CB007010-B_007_STATE_HW_RMOD_Reset_Request_To_SBTS_Via_HWRESETREQ_From_SMO