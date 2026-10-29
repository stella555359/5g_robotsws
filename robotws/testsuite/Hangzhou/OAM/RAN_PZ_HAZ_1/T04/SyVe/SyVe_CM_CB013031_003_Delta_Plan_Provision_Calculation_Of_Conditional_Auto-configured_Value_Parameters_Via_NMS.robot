*** Settings ***
Documentation       Test suite for RAN_ST_CB013031_003_CM_Delta configuration plan provisioning
...                 (calculation and recalculation of conditional auto-configured value parameters) from NMS
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
Test Timeout    5h
Variables     ../test_line_specific/SBTS_SYVE_1894/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource
...    ../test_resources/SyVe/SyVe_CM_CB013031_003_Delta_Plan_Provision_Calculation_Of_Conditional_Auto-configured_Value_Parameters_Via_NMS.robot

*** Test Cases ***
SyVe_CM_CB013031_003_Delta_Plan_Provision_Calculation_Of_Conditional_Auto-configured_Value_Parameters_Via_NMS
    [Setup]    TC Setup
    [Timeout]    2h
    SyVe_CM_CB013031_003_Delta_Plan_Provision_Calculation_Of_Conditional_Auto-configured_Value_Parameters_Via_NMS
    [Teardown]    TC TearDown