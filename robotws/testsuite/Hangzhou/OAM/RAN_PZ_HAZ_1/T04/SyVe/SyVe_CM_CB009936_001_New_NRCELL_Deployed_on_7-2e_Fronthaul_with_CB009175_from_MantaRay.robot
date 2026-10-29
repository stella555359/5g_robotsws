*** Settings ***
Documentation       Test suite for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Test Timeout    5h
Variables     ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource      ../test_resources/SyVe/SyVe_CM_CB009936_001_New_NRCELL_Deployed_on_7-2e_Fronthaul_with_CB009175_from_MantaRay.robot

*** Test Cases ***
SyVe_CM_CB009936_001_New_NRCELL_Deployed_on_7-2e_Fronthaul_with_CB009175_from_MantaRay
    [Setup]    TC Setup
    [Timeout]    2h
    SyVe_CM_CB009936_001_New_NRCELL_Deployed_on_7-2e_Fronthaul_with_CB009175_from_MantaRay
    [Teardown]    TC TearDown
