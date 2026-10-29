*** Settings ***
Documentation       Test suite for SyVe_CM_CB012523_003/005
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
Test Timeout    3h
Variables     ../test_line_specific/SBTS_SYVE_37376/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource      ../test_resources/SyVe/SyVe_CM_CB012523_003_005_Enable_Cells_That_Has_Been_Disabled.robot

*** Test Cases ***
SyVe_CM_CB012523_003_005_Enable_Cells_That_Has_Been_Disabled
    [Setup]    TC Setup
    [Timeout]    3h
    SyVe_CM_CB012523_003_005_Enable_Cells_That_Has_Been_Disabled
    [Teardown]    TC Teardown