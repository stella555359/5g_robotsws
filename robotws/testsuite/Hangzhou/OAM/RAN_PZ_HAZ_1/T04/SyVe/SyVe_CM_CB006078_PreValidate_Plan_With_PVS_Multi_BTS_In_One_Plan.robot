*** Settings ***
Documentation       Test suite for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Test Timeout    75h
Variables     ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource      ../test_resources/SyVe/SyVe_CM_CB006078_PreValidate_Plan_With_PVS_Multi_BTS_In_One_Plan.robot

*** Test Cases ***
SyVe_CM_CB006078_PreValidate_Plan_With_PVS_Multi_BTS_In_One_Plan
    [Setup]    TC Setup
    [Timeout]    72h
    SyVe_CM_CB006078_PreValidate_Plan_With_PVS_Multi_BTS_In_One_Plan
    [Teardown]    TC Teardown
