*** Settings ***
Documentation       Test suite for CB013031_064
...                 Author: Kang Lixin
...                 Contact: lixin.kang@nokia-sbell.com
Test Timeout    3h
Variables     ../test_line_specific/SBTS_SYVE_1894/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource      ../test_resources/SyVe/SyVe_CM_CB013031_064_015_CM_Feature_Configuration_Engine_Run_in_NMS_with_CACVAS.robot

*** Test Cases ***
SyVe_CM_CB013031_064_015_CM_Feature_Configuration_Engine_Run_in_NMS_with_CACVAS    [Setup]    TC Setup
    [Teardown]    TC Teardown
    SyVe_CM_CB013031_064_015_CM_Feature_Configuration_Engine_Run_in_NMS_with_CACVAS