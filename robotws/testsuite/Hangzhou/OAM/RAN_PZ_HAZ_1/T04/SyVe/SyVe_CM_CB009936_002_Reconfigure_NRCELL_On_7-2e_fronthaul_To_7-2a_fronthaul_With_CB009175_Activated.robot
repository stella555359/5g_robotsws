*** Settings ***
Documentation       Test suite for CB009936_002
...                 Author: Yuyan Xu
...                 Contact: yuyan.xu@nokia-sbell.com
Test Timeout    5h
Variables     ../test_line_specific/SBTS_SYVE_1815/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource      ../test_resources/SyVe/SyVe_CM_CB009936_002_Reconfigure_NRCELL_On_7-2e_fronthaul_To_7-2a_fronthaul_With_CB009175_Activated.robot

*** Test Cases ***
SyVe_CM_CB009936_002_Reconfigure_NRCELL_On_7-2e_fronthaul_To_7-2a_fronthaul_With_CB009175_Activated
    [Setup]    TC Setup
    [Timeout]    2h
    SyVe_CM_CB009936_002_Reconfigure_NRCELL_On_7-2e_fronthaul_To_7-2a_fronthaul_With_CB009175_Activated
    [Teardown]    TC TearDown
