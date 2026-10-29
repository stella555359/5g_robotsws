*** Settings ***
Documentation       Test suite for CB013031_010
...                 Author: Kang Lixin
...                 Contact: lixin.kang@nokia-sbell.com
Test Timeout    3h
Variables     ../test_line_specific/SBTS_SYVE_1894/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource      ../test_resources/SyVe/SyVe_CM_CB013031_010_CM_Enabling_Feature_1st_Time_for_An_Existing_Operational_BTS_from_NMS.robot

*** Test Cases ***
SyVe_CM_CB013031_010_CM_Enabling_Feature_1st_Time_for_An_Existing_Operational_BTS_from_NMS
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    SyVe_CM_CB013031_010_CM_Enabling_Feature_1st_Time_for_An_Existing_Operational_BTS_from_NMS