*** Settings ***
Documentation       Test suite for SyVe_CM_CB012523_006
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
Test Timeout    3h
Variables     ../test_line_specific/SBTS_SYVE_37376/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource      ../test_resources/SyVe/SyVe_CM_CB012523_006_Prevent_Enable_Cells_with_Feature_Enable_In_Case_gNB_Restarts.robot

*** Test Cases ***
SyVe_CM_CB012523_006_Prevent_Enable_Cells_with_Feature_Enable_In_Case_gNB_Restarts
    [Setup]    TC Setup
    [Timeout]    3h
    SyVe_CM_CB012523_006_Prevent_Enable_Cells_with_Feature_Enable_In_Case_gNB_Restarts
    [Teardown]    TC Teardown