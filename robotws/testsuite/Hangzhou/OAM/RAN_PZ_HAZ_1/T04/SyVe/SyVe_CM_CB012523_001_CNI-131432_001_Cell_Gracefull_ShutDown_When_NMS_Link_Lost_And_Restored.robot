*** Settings ***
Documentation       Test suite for SyVe_CM_CB012523_001
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
Test Timeout    3h
Variables     ../test_line_specific/SBTS_SYVE_37376/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource      ../test_resources/SyVe/SyVe_CM_CB012523_001_CNI-131432_001_Cell_Gracefull_ShutDown_When_NMS_Link_Lost_And_Restored.robot

*** Test Cases ***
SyVe_CM_CB012523_001_CNI-131432_001_Cell_Gracefull_ShutDown_When_NMS_Link_Lost_And_Restored
    [Setup]    TC Setup
    [Timeout]    3h
    SyVe_CM_CB012523_001_CNI-131432_001_Cell_Gracefull_ShutDown_When_NMS_Link_Lost_And_Restored
    [Teardown]    TC Teardown