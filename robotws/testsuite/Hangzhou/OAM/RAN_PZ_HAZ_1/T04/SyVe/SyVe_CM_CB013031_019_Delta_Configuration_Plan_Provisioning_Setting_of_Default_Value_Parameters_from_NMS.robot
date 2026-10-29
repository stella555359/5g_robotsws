*** Settings ***
Documentation       Test suite for CB013031_019
...                 Author: Kang Lixin
...                 Contact: lixin.kang@nokia-sbell.com
Test Timeout    3h
Variables     ../test_line_specific/SBTS_SYVE_1894/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource      ../test_resources/SyVe/SyVe_CM_CB013031_019_Delta_Configuration_Plan_Provisioning_Setting_of_Default_Value_Parameters_from_NMS.robot

*** Test Cases ***
SyVe_CM_CB013031_019_Delta_Configuration_Plan_Provisioning_Setting_of_Default_Value_Parameters_from_NMS
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    SyVe_CM_CB013031_019_Delta_Configuration_Plan_Provisioning_Setting_of_Default_Value_Parameters_from_NMS