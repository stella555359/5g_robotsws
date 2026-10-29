*** Settings ***
Documentation       Test suite for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Test Timeout    75h
Variables     ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource      ../test_resources/SyVe/SyVe_CM_Recommission_Triggering_SBTS_Reset_via_NetAct_By_Importing_Prepared_Plan.robot

*** Test Cases ***
TC__SyVe_CM_Recommission_Triggering_SBTS_Reset_via_NetAct_By_Importing_Prepared_Plan
    [Setup]    TC Setup
    [Timeout]    72h
    [Teardown]    TC Teardown
    TC__SyVe_CM_Recommission_Triggering_SBTS_Reset_via_NetAct_By_Importing_Prepared_Plan


