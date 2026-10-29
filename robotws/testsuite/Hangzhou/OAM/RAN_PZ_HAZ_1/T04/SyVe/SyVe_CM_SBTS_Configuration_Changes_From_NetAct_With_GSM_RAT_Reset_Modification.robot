*** Settings ***
Documentation       Test suite for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Test Timeout    75h
Variables        ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Variables      ../test_line_specific/Variables/NetActs.py
Resource          ../test_resources/SyVe/SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_GSM_RAT_Reset_Modification.robot

*** Test Cases ***
[1]SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_GSM_RAT_Reset_Modification
    [Setup]    TC Setup
    [Timeout]    72h
    TC__SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_GSM_RAT_Reset_Modification
    [Teardown]    TC Teardown
