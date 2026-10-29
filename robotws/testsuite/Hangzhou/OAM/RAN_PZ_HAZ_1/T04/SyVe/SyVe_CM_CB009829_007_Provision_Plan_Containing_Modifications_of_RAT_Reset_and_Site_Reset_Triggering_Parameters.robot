*** Settings ***
Documentation       Test suite for SyVe_CM_CB009829_007
...                 Author: Kang Lixin
...                 Contact: lixin.kang@nokia-sbell.com
Test Timeout    2h
Variables     ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource
...    ../test_resources/SyVe/SyVe_CM_CB009829_007_Provision_Plan_Containing_Modifications_of_RAT_Reset_and_Site_Reset_Triggering_Parameters.robot

*** Test Cases ***
SyVe_CM_CB009829_007_Provision_Plan_Containing_Modifications_of_RAT_Reset_and_Site_Reset_Triggering_Parameters
    [Setup]    TC Setup
    [Timeout]    2h
    SyVe_CM_CB009829_007_Provision_Plan_Containing_Modifications_of_RAT_Reset_and_Site_Reset_Triggering_Parameters
    [Teardown]    TC Teardown