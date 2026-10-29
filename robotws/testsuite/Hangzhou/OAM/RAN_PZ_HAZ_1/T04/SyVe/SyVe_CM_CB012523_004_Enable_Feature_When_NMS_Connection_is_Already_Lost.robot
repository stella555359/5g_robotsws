*** Settings ***
Documentation       Test suite for SyVe_CM_CB012523_004
...                 Author: Kang Lixin
...                 Contact: lixin.kang@nokia-sbell.com
Test Timeout    3h
Variables     ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource      ../test_resources/SyVe/SyVe_CM_CB012523_004_Enable_Feature_When_NMS_Connection_is_Already_Lost.robot

*** Test Cases ***
SyVe_CM_CB012523_004_Enable_Feature_When_NMS_Connection_is_Already_Lost
    [Setup]    TC Setup
    [Timeout]    3h
    SyVe_CM_CB012523_004_Enable_Feature_When_NMS_Connection_is_Already_Lost
    [Teardown]    TC TearDown