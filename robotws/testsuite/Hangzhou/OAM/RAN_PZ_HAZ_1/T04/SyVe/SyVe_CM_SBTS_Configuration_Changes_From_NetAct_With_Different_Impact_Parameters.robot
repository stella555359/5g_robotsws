*** Settings ***
Documentation       Test suite for EDA 02874260
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
Test Timeout    2h
Variables     ../test_line_specific/SBTS_SYVE_37376/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource      ../test_resources/SyVe/SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_Different_Impact_Parameters.robot

*** Test Cases ***
SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_Different_Impact_Parameters
    [Setup]    TC Setup
    [Timeout]    2h
    [Teardown]    TC Teardown
    SyVe_CM_SBTS_Configuration_Changes_From_NetAct_With_Different_Impact_Parameters